local world = require 'battle.world'

local RVO = CS.RVO

local Com = ecs.Com
local concerns = {
	Com.transform,
	Com.rvo,
	Com.troop,
	Com.animation,
	Com.view,
}
local sys = ecs.newsys('rvo', concerns)


local timeStep = world.frameInterval
local neighborDist = 10
local maxNeighbors = 10
local timeHorizon = 2
local timeHorizonObst = 2
local radius = 0.2
local maxSpeed = 20


function sys:addAgent(entity)
	local pos = entity:getComponent(Com.transform).position
	local rvo = entity:getComponent(Com.rvo)
	rvo.agentIndex = RVO.Simulator.Instance:addAgent(RVO.Vector2(pos.x, pos.y))
end

function sys:removeAgent(entity)
	local rvo = entity:getComponent(Com.rvo)
	RVO.Simulator.Instance:removeAgent(rvo.agentIndex)

	local entities = self:getEntities()
	for _, v in pairs(entities) do
		if v.id ~= entity.id then
			local r = v:getComponent(Com.rvo)
			if r.agentIndex > rvo.agentIndex then
				r.agentIndex = r.agentIndex - 1
			end
		end
	end

	rvo.agentIndex = -1
end

function sys:addObstacle(entity)
	local t = {}
	local pos = entity:getComponent(Com.transform).position
	table.insert(t, RVO.Vector2(pos.x - radius, pos.y + radius))
	table.insert(t, RVO.Vector2(pos.x - radius, pos.y - radius))
	table.insert(t, RVO.Vector2(pos.x + radius, pos.y - radius))
	table.insert(t, RVO.Vector2(pos.x + radius, pos.y + radius))
	entity:getComponent(Com.rvo).obstacleIndex = LuaInterface.RvoAddObstacle(t)
end

function sys:removeObstacle(entity)
	local rvo = entity:getComponent(Com.rvo)
	for i = 1, 4 do
		RVO.Simulator.Instance:removeObstacle(rvo.obstacleIndex)
	end
	rvo.obstacleIndex = -1
end

function sys:initPosition( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local rvo = v:getComponent(Com.rvo)
		local trans = v:getComponent(Com.transform)
		if rvo.agentIndex >= 0 then
			RVO.Simulator.Instance:setAgentPosition(rvo.agentIndex, RVO.Vector2(trans.position.x, trans.position.y))
		end
	end
end

function sys:setPrefVelocity( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local rvo = v:getComponent(Com.rvo)
		local trans = v:getComponent(Com.transform)
		local troop = v:getComponent(Com.troop)
		if troop.rank == 'general' then
			if trans.direction.x == 0 and trans.direction.y == 0 then
				if rvo.agentIndex >= 0 then
					self:removeAgent(v)
					self:addObstacle(v)
					RVO.Simulator.Instance:processObstacles()
				end
			else
				if rvo.obstacleIndex >= 0 then
					self:removeObstacle(v)
					RVO.Simulator.Instance:processObstacles()
					self:addAgent(v)
				end
				local velocity = RVO.Vector2(trans.direction.x, trans.direction.y)
				RVO.Simulator.Instance:setAgentPrefVelocity(rvo.agentIndex, trans.speed*velocity)
			end
		else
			local velocity = RVO.Vector2(trans.direction.x, trans.direction.y)
			RVO.Simulator.Instance:setAgentPrefVelocity(rvo.agentIndex, trans.speed*velocity)
			trans.direction:Set(0, 0)
		end
		trans.direction:Set(0, 0)
	end
end

function sys:setPosition( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local rvo = v:getComponent(Com.rvo)
		local trans = v:getComponent(Com.transform)
		local anim = v:getComponent(Com.animation)

		local moving
		if rvo.agentIndex >= 0 then
			local v2 = RVO.Simulator.Instance:getAgentPosition(rvo.agentIndex)
			trans.position.x = v2:x()
			trans.position.y = v2:y()

			local velocity = RVO.Simulator.Instance:getAgentVelocity(rvo.agentIndex)
			moving = velocity:x() ~= 0 or velocity:y() ~= 0
		else
			moving = false
		end
		
		local animName = moving and 'run' or 'idle'
		if not anim.tarAnim or anim.tarAnim == 'idle' or anim.tarAnim == 'run' then
			anim.tarAnim = animName
			anim.tarSpeed = 1

			local view = v:getComponent(Com.view)
			view.lookPos = trans.position
		end
	end
end

function sys:setup(entity)
	local rvo = entity:getComponent(Com.rvo)
	local pos = entity:getComponent(Com.transform).position
	local v = RVO.Vector2(pos.x, pos.y)
	rvo.agentIndex = RVO.Simulator.Instance:addAgent(v)
end

function sys:noRVO( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local trans = v:getComponent(Com.transform)
		trans.position = trans.position + trans.direction * trans.speed * timeStep
		trans.moving = trans.direction.x ~= 0 or trans.direction.y ~= 0
	end
end

function sys:_frameCalc( ... )
	if CS.Config.USE_RVO then
		sys:initPosition()
		self:setPrefVelocity()
		RVO.Simulator.Instance:doStep()
		self:setPosition()
	else
		self:noRVO()
	end
end

RVO.Simulator.Instance:setTimeStep(timeStep)
RVO.Simulator.Instance:setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, RVO.Vector2(0, 0));