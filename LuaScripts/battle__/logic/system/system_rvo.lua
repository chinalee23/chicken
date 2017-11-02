local _M = module()

local RVO = CS.RVO

local timeStep = 0.02
local neighborDist = 10
local maxNeighbors = 10
local timeHorizon = 2
local timeHorizonObst = 2
local radius = 1
local generalAgentIndex = -1
local generalObstacleIndex = -1
local speed = 8
local retinueGap = 4

local function removeCharacterObstacle(c)
	for i = 1, 4 do
		RVO.Simulator.Instance:removeObstacle(c.generalObstacleIndex)
	end
	c.generalObstacleIndex = -1
end

local function addCharacterObstacle(c)
	local t = {}
	local pos = c.position
	table.insert(t, RVO.Vector2(pos.x - radius, pos.y + radius))
	table.insert(t, RVO.Vector2(pos.x - radius, pos.y - radius))
	table.insert(t, RVO.Vector2(pos.x + radius, pos.y - radius))
	table.insert(t, RVO.Vector2(pos.x + radius, pos.y + radius))
	c.generalObstacleIndex = LuaInterface.RvoAddObstacle(t)
end

local function removeCharacterAgent(c)
	RVO.Simulator.Instance:removeAgent(c.generalAgentIndex)
	c.agents[c] = nil
	for k, v in pairs(c.agents) do
		if v > c.generalAgentIndex then
			c.agents[k] = v - 1
		end
	end
	c.generalAgentIndex = -1
end

local function addCharacterAgent(c)
	local pos = c.position
	local v = RVO.Vector2(pos.x, pos.y)
	c.generalAgentIndex = RVO.Simulator.Instance:addAgent(v)
	c.agents[c] = c.generalAgentIndex
end

local function setCharacterVelocity(c)
	if c.inorigin then
		if c.generalAgentIndex >= 0 then
			removeCharacterAgent(c)
			addCharacterObstacle(c)
			RVO.Simulator.Instance:processObstacles()
			c.moving = false
		end
	else
		if c.generalObstacleIndex >= 0 then
			removeCharacterObstacle(c)
			RVO.Simulator.Instance:processObstacles()
			addCharacterAgent(c)
			c.moving = true
		end
		local velocity = RVO.Vector2(c.direction.x, c.direction.y)
		RVO.Simulator.Instance:setAgentPrefVelocity(c.generalAgentIndex, speed*velocity)
	end
end

local function setRetinueVelocity(c)
	local retinueDist = retinueGap * (math.floor((table.count(c.agents) - 2) / 10) + 1)
	local sqrDist = retinueDist * retinueDist
	for k, v in pairs(c.agents) do
		if v ~= c.generalAgentIndex then
			local velocity
			local offset = c.position - k.position
			-- local dist = (c.layers[k] * retinueGap) * (c.layers[k] * retinueGap)
			if offset:SqrMagnitude() > sqrDist then
				local normal = offset:Normalize()
				velocity = RVO.Vector2(normal.x, normal.y)
			else
				velocity = RVO.Vector2(c.direction.x, c.direction.y)
			end			
			RVO.Simulator.Instance:setAgentPrefVelocity(v, speed * velocity)
		end
	end
end

local function setPosition(c)
	for k, v in pairs(c.agents) do
		local v2 = RVO.Simulator.Instance:getAgentPosition(v)
		k.position = Vector2(v2:x(), v2:y())

		if v ~= c.generalAgentIndex then
			local velocity = RVO.Simulator.Instance:getAgentVelocity(v)
			k.moving = velocity:x() ~= 0 or velocity:y() ~= 0
		end
	end
end

function init( ... )
	RVO.Simulator.Instance:setTimeStep(timeStep)
	RVO.Simulator.Instance:setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, speed, RVO.Vector2(2, 2));
end

function setup(c)
	addCharacterObstacle(c)
	RVO.Simulator.Instance:processObstacles()
end

function calc(c)
	setCharacterVelocity(c)
	setRetinueVelocity(c)

	RVO.Simulator.Instance:doStep()

	setPosition(c)
end

init()

return _M