local Vector2 = require 'math.vector2'

local world = require 'battle.world'

local Com = ecs.Com
local concerns = {
	Com.view,
	Com.transform,
}
local sys = ecs.newsys('view', concerns)

function sys:setup(entity)
	local comView = entity:getComponent(Com.view)
	comView.gameObject = LuaInterface.LoadPrefab(comView.prefab, comView.root)
	LuaInterface.SetLocalScale(comView.gameObject, comView.scale)
	comView.trans = comView.gameObject.transform
	local pos = entity:getComponent(Com.transform).position
	comView.trans.localPosition = UnityEngine.Vector3(pos.x, 0, pos.y)
	comView.targetPos = pos:Clone()

	local angle = math.random(0, 360)
	LuaInterface.SetLocalEulerAngle(comView.gameObject, 0, angle, 0)
end

function sys:_onEntityDestroy(entity)
	local comView = entity:getComponent(Com.view)
	LuaInterface.DestroyGameObject(comView.gameObject)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local trans = v:getComponent(Com.transform)
		local comView = v:getComponent(Com.view)
		
		comView.moveStartTime = Time.realtimeSinceStartup
		comView.moveTime = world.frameInterval
		comView.moveStartPos = comView.targetPos:Clone()

		LuaInterface.SetLocalPosition(comView.gameObject, comView.targetPos.x, 0, comView.targetPos.y)
		comView.targetPos = trans.position:Clone()

		local comTrans = v:getComponent(Com.transform)
		LuaInterface.LookAt(comView.gameObject, comTrans.face.x, 0, comTrans.face.y)
		-- LuaInterface.LookAt(comView.gameObject, comTrans.position.x, 0, comTrans.position.y)
	end
end

function sys:update( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local comView = v:getComponent(Com.view)
		local comTrans = v:getComponent(Com.transform)
		local offset = Time.realtimeSinceStartup - comView.moveStartTime
		local newPos = Vector2.Lerp(comView.moveStartPos, comView.targetPos, offset/comView.moveTime)
		LuaInterface.SetLocalPosition(comView.gameObject, newPos.x, 0, newPos.y)
	end
end