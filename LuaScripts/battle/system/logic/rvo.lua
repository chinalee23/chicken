local Vector2 = require 'math.vector2'

local Com = ecs.Com

local tuple = {
	{
		Com.rvo,
		Com.logic.transform,
	},
}
local sys = ecs.newsys('rvo', tuple)

local RVO = CS.RVO

local radius = 0.2

function sys:init( ... )
	RVO.Simulator.Instance:setTimeStep(1)
	RVO.Simulator.Instance:setAgentDefaults(5, 8, 2, 1, radius, 10, RVO.Vector2(0, 0))
end

function sys:setup(entity)
	self:addAgent(entity:getComponent(Com.rvo), entity:getComponent(Com.logic.transform))
end

function sys:addAgent(comRvo, comTrans)
	comRvo.agentIndex = RVO.Simulator.Instance:addAgent(RVO.Vector2(comTrans.position.x, comTrans.position.y))
end

function sys:removeAgent(entity)
	local comRvo = entity:getComponent(Com.rvo)
	RVO.Simulator.Instance:removeAgent(comRvo.agentIndex)
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		if v.id ~= entity.id then
			local comRvo_v = v:getComponent(Com.rvo)
			if comRvo_v.agentIndex > comRvo.agentIndex then
				comRvo_v.agentIndex = comRvo_v.agentIndex - 1
			end
		end
	end
	comRvo.agentIndex = -1
end

function sys:addObstalce(comRvo, comTrans)
	local pos = comTrans.position
	local t = {}
	table.insert(t, RVO.Vector2(pos.x-radius, pos.y+radius))
	table.insert(t, RVO.Vector2(pos.x-radius, pos.y-radius))
	table.insert(t, RVO.Vector2(pos.x+radius, pos.y-radius))
	table.insert(t, RVO.Vector2(pos.x+radius, pos.y+radius))
	comRvo.obstacleIndex = LuaInterface.RvoAddObstacle(t)
end

function sys:removeObstacle(comRvo)
	for i = 1, 4 do
		RVO.Simulator.Instance:removeObstacle(comRvo.obstacleIndex)
	end
	comRvo.obstacleIndex = -1
end

function sys:calcGeneral(entity)
	local comRvo = entity:getComponent(Com.rvo)
	local comTrans = entity:getComponent(Com.logic.transform)
	if comTrans.velocity.x == 0 and comTrans.velocity.y == 0 then
		if comRvo.agentIndex >= 0 then
			self:addObstalce(comRvo, comTrans)
			self:removeAgent(entity)
			RVO.Simulator.Instance:processObstacles()
		end
	else
		if comRvo.obstacleIndex >= 0 then
			self:addAgent(comRvo, comTrans)
			self:removeObstacle(comRvo)
			RVO.Simulator.Instance:processObstacles()
		end
		RVO.Simulator.Instance:setAgentPrefVelocity(comRvo.agentIndex, RVO.Vector2(comTrans.velocity.x, comTrans.velocity.y))
	end
end

function sys:calcRetinue(entity)
	local comRvo = entity:getComponent(Com.rvo)
	local comTrans = entity:getComponent(Com.logic.transform)
	if comRvo.agentIndex < 0 then
		comRvo.agentIndex = RVO.Simulator.Instance:addAgent(RVO.Vector2(comTrans.position.x, comTrans.position.y))
	end
	RVO.Simulator.Instance:setAgentPrefVelocity(comRvo.agentIndex, RVO.Vector2(comTrans.velocity.x, comTrans.velocity.y))
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		if v:getComponent(Com.general) then
			self:calcGeneral(v)
		else
			self:calcRetinue(v)
		end

		local comRvo = v:getComponent(Com.rvo)
		if comRvo.agentIndex >= 0 then
			log.info(v.id, 'pref velocity', RVO.Simulator.Instance:getAgentPrefVelocity(comRvo.agentIndex))
		end
	end
	RVO.Simulator.Instance:doStep()
	for _, v in pairs(entities) do
		local comRvo = v:getComponent(Com.rvo)
		if comRvo.agentIndex >= 0 then
			local comTrans = v:getComponent(Com.logic.transform)
			local pos = RVO.Simulator.Instance:getAgentPosition(comRvo.agentIndex)
			local currPos = Vector2(pos:x(), pos:y())
			local offset = currPos - comTrans.position
			log.info(v.id, offset, Vector2.Magnitude(offset))
			comTrans.position = Vector2(pos:x(), pos:y())
		end
	end
end

sys:init()