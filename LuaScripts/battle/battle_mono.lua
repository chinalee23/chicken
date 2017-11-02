local _M = module()

local world = require 'battle.world'
local game = require 'game'
local input = require 'battle.input'

local RVO = CS.RVO

------------------- rvo params ---------------
local timeStep = 0.033
local neighborDist = 10
local maxNeighbors = 10
local timeHorizon = 2
local timeHorizonObst = 2
local radius = 1
local generalAgentIndex = -1
local generalObstacleIndex = -1
local agents = {}
local layers = {}

local speed = 1
local retinueGap = 4
local recruitGap = 5
local retinueMinMove = 1


local gameObject

local camera
local general
local npcs
local rocker
local moving

---------------- local functions ---------------
local init
local initCamera
local initGeneral
local initNpcs
local initUI
local addGeneralObstacle
local removeGeneralAgent
local removeGeneralObstacle
local addGeneralAgent
local setScenario
local updateAgent
local updateNpc
local updateCamera
local setPosition
local setPreferVelocity
local setMajorVelocity
local setRetinueVelocity
local stop
local move

function init( ... )
	-- initGeneral()
	-- initNpcs()

	initUI()
	-- initCamera()

	-- setScenario()

	-- moving = false
end

function initCamera( ... )
	local go = LuaInterface.Find(gameObject, 'Camera')
	camera = {
		trans = go.transform,
		offset = go.transform.localPosition
	}
end

function initGeneral( ... )
	general = {}
	general.go = LuaInterface.LoadPrefab('Prefab/Player/Male01/male01_base_prefab', gameObject)
	general.trans = general.go.transform
	LuaInterface.SetLocalScale(general.go, 1.5, 1.5, 1.5)
end

function initNpcs( ... )
	npcs = {}
	local root = LuaInterface.Find(gameObject, 'npcs')
	for i = 0, root.transform.childCount - 1 do
		local trans = root.transform:GetChild(i)
		LuaInterface.PlayAnimation(trans.gameObject, 'idle1')
		table.insert(npcs, {
				go = trans.gameObject,
				trans = trans,
			})
	end
end

function initUI( ... )
	rocker = LuaInterface.Find(gameObject, 'UIRoot/Canvas/rocker', 'Rocker')
end

function setScenario( ... )
	RVO.Simulator.Instance:setTimeStep(0.25)
	RVO.Simulator.Instance:setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, speed, RVO.Vector2(2, 2));

	addGeneralObstacle()
	RVO.Simulator.Instance:processObstacles()
end

function addGeneralObstacle( ... )
	local t = {}
	local pos = general.trans.localPosition
	table.insert(t, RVO.Vector2(pos.x - 20, pos.z + 20))
	table.insert(t, RVO.Vector2(pos.x - 20, pos.z - 20))
	table.insert(t, RVO.Vector2(pos.x + 20, pos.z - 20))
	table.insert(t, RVO.Vector2(pos.x + 20, pos.z + 20))
	generalObstacleIndex = LuaInterface.RvoAddObstacle(t)
end

function removeGeneralAgent( ... )
	RVO.Simulator.Instance:removeAgent(generalAgentIndex)
	agents[general.trans] = nil
	for k, v in pairs(agents) do
		if v > generalAgentIndex then
			agents[k] = v - 1
		end
	end
	generalAgentIndex = -1
end

function removeGeneralObstacle( ... )
	for i = 1, 4 do
		RVO.Simulator.Instance:removeObstacle(generalObstacleIndex)
	end
	generalObstacleIndex = -1
end

function addGeneralAgent( ... )
	local pos = general.trans.localPosition
	local v = RVO.Vector2(pos.x, pos.z)
	generalAgentIndex = RVO.Simulator.Instance:addAgent(v)
	agents[general.trans] = generalAgentIndex
end

function updateAgent( ... )
	setPreferVelocity()
	RVO.Simulator.Instance:doStep()
	setPosition()
end

function updateNpc( ... )
	local i = 1
	while i <= #npcs do
		for k, v in pairs(agents) do
			local pos = npcs[i].trans.localPosition
			local offset = pos - k.localPosition
			if offset.magnitude < recruitGap then
				log.info('recruit a npc')
				agents[npcs[i].trans] = RVO.Simulator.Instance:addAgent(RVO.Vector2(pos.x, pos.z))
				layers[npcs[i].trans] = math.floor((table.count(agents) - 2) / 10) + 1
				table.remove(npcs, i)
				i = i - 1
				break
			end
		end
		i = i + 1
	end
end

function updateCamera( ... )
	camera.trans.localPosition = camera.offset + general.trans.localPosition
end

function setPosition( ... )
	for k, v in pairs(agents) do
		local v2 = RVO.Simulator.Instance:getAgentPosition(v)
		local pos = UnityEngine.Vector3(v2:x(), 0, v2:y())
		k:LookAt(pos)
		k.localPosition = pos

		local velocity = RVO.Simulator.Instance:getAgentVelocity(v)
		if velocity:x() ~= 0 and velocity:y() ~= 0 then
			LuaInterface.PlayAnimation(k.gameObject, 'run')
		else
			LuaInterface.PlayAnimation(k.gameObject, 'idle1')
		end
	end
end

function setPreferVelocity( ... )
	setMajorVelocity()
	setRetinueVelocity()
end

function setMajorVelocity( ... )
	if rocker.inorigin then
		if moving then
			stop()
			removeGeneralAgent()
			addGeneralObstacle()
			RVO.Simulator.Instance:processObstacles()
		end
	else
		if not moving then
			move()
			removeGeneralObstacle()
			RVO.Simulator.Instance:processObstacles()
			addGeneralAgent()
		end
		local velocity = RVO.Vector2(rocker.direction.x, rocker.direction.y)
		RVO.Simulator.Instance:setAgentPrefVelocity(generalAgentIndex, speed * velocity)
	end
end

function setRetinueVelocity( ... )
	for k, v in pairs(agents) do
		if v ~= generalAgentIndex then
			local velocity
			local offset = general.trans.localPosition - k.localPosition
			local dist = layers[k] * retinueGap
			if offset.magnitude > dist then
				local normal = offset.normalized
				velocity = RVO.Vector2(normal.x, normal.z)
			else
				velocity = RVO.Vector2(rocker.direction.x, rocker.direction.y)
			end
			RVO.Simulator.Instance:setAgentPrefVelocity(v, speed * velocity)
		end
	end
end

function stop( ... )
	moving = false
	LuaInterface.PlayAnimation(general.go, 'idle0')
end

function move( ... )
	moving = true
	LuaInterface.PlayAnimation(general.go, 'run')
end


------------------------- unity callback ------------------
function awake(go)
	gameObject = go

	init()
end

function start( ... )
	-- behavior.prepare(gameObject)
	world.build(game.battleData, gameObject)
	events.battleMonoPrepared()
end

function update( ... )
	input.inorigin = rocker.inorigin
	input.direction = Vector2(rocker.direction.x, rocker.direction.y)
end

function ondestroy( ... )
	-- body
end

function fixedupdate( ... )
	-- updateAgent()
	-- updateNpc()
end

return _M