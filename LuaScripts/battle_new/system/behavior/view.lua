local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	{
		Com.transform,
		Com.view,
	},
}
local sys = ecs.newsys('view', tuple)


function sys:updatePos(entity)
	local comView = entity:getComponent(Com.view)
	local pos = Vector2.Lerp(comView.currPos, comView.tarPos, Time.deltaTime/world.frameInterval)
	local dist = (pos - comView.currPos):SqrMagnitude()
	if dist > 0.01 then
		comView.currPos = pos
	end
end

function sys:calc(entity)
	local comView = entity:getComponent(Com.view)
	comView.currPos = comView.tarPos:Clone()

	local comTrans = entity:getComponent(Com.transform)
	comView.tarPos = comTrans.position:Clone()
end

function sys:update()
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:updatePos()
	end
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:calc(v)
	end
end