local Vector2 = require 'math.vector2'
local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	{
		Com.logic.transform,
		Com.behavior.transform,
	},
}
local sys = ecs.newsys('behavior.transform', tuple)

function sys:setup(entity)
	local comTrans_l = entity:getComponent(Com.logic.transform)
	local comTrans_b = entity:getComponent(Com.behavior.transform)

	LuaInterface.SetLocalScale(comTrans_b.gameObject, comTrans_b.scale)

	comTrans_b.currPos = comTrans_l.position:Clone()
	comTrans_b.tarPos = comTrans_l.position:Clone()
	LuaInterface.SetPosition(comTrans_b.gameObject, comTrans_b.currPos.x, comTrans_b.height, comTrans_b.currPos.y)

	local lookPos = comTrans_b.tarPos + comTrans_l.direction
	LuaInterface.LookAt(comTrans_b.gameObject, lookPos.x, 0, lookPos.y)
end

function sys:_onEntityDestroy(entity)
	local comTrans_b = entity:getComponent(Com.behavior.transform)
	LuaInterface.DestroyGameObject(comTrans_b.gameObject)
end

function sys:updatePos(entity)
	local comTrans = entity:getComponent(Com.behavior.transform)
	local dist = (comTrans.tarPos - comTrans.currPos):SqrMagnitude()
	if dist > 0.0001 then
		comTrans.currPos = Vector2.Lerp(comTrans.moveStartPos, comTrans.tarPos, (Time.time - comTrans.moveStartTime)/comTrans.moveTime)
		LuaInterface.SetPosition(comTrans.gameObject, comTrans.currPos.x, comTrans.height, comTrans.currPos.y)
	end
end

function sys:calc(entity)
	local comTrans_l = entity:getComponent(Com.logic.transform)
	local comTrans_b = entity:getComponent(Com.behavior.transform)

	comTrans_b.currPos = comTrans_b.tarPos
	comTrans_b.tarPos = comTrans_l.position:Clone()
	LuaInterface.SetPosition(comTrans_b.gameObject, comTrans_b.currPos.x, comTrans_b.height, comTrans_b.currPos.y)

	local lookPos = comTrans_b.tarPos + comTrans_l.direction
	LuaInterface.LookAt(comTrans_b.gameObject, lookPos.x, 0, lookPos.y)

	comTrans_b.moveStartPos = comTrans_b.currPos:Clone()
	comTrans_b.moveStartTime = Time.time
	comTrans_b.moveTime = world.frameInterval - (Time.time - world.frameStartTime)
end

function sys:update( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:updatePos(v)
	end
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:calc(v)
	end
end