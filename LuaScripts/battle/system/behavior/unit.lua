local Vector2 = require 'math.vector2'
local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	{
		Com.transform,
		Com.unit,
	},
}
local sys = ecs.newsys('unit', tuple)

function sys:setup(entity)
	local comUnit = entity:getComponent(Com.unit)
	comUnit.gameObject = LuaInterface.LoadPrefab(comUnit.prefab, comUnit.root)
	comUnit.gameObject.name = entity.id

	local comTrans = entity:getComponent(Com.transform)
	comUnit.currPos = comTrans.position:Clone()
	comUnit.tarPos = comTrans.position:Clone()
	LuaInterface.SetPosition(comUnit.gameObject, comUnit.currPos.x, 0, comUnit.currPos.y)

	local lookPos = comUnit.tarPos + comTrans.direction
	LuaInterface.LookAt(comUnit.gameObject, lookPos.x, 0, lookPos.y)
end


function sys:updatePos(entity)
	local comUnit = entity:getComponent(Com.unit)
	local dist = (comUnit.tarPos - comUnit.currPos):SqrMagnitude()
	if dist > 0.0001 then
		comUnit.currPos = Vector2.Lerp(comUnit.currPos, comUnit.tarPos, Time.deltaTime/world.frameInterval)
		LuaInterface.SetPosition(comUnit.gameObject, comUnit.currPos.x, 0, comUnit.currPos.y)
		if not comUnit.currAnim or comUnit.currAnim ~= 'run' then
			comUnit.currAnim = 'run'
			LuaInterface.PlayAnimation(comUnit.gameObject, comUnit.currAnim)
		end
	else
		if not comUnit.currAnim or comUnit.currAnim ~= 'idle' then
			comUnit.currAnim = 'idle'
			LuaInterface.PlayAnimation(comUnit.gameObject, comUnit.currAnim)
		end
	end
end

function sys:calc(entity)
	local comUnit = entity:getComponent(Com.unit)
	comUnit.currPos = comUnit.tarPos:Clone()

	local comTrans = entity:getComponent(Com.transform)
	comUnit.tarPos = comTrans.position:Clone()

	local lookPos = comUnit.tarPos + comTrans.direction
	LuaInterface.LookAt(comUnit.gameObject, lookPos.x, 0, lookPos.y)
end

function sys:update()
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