local Vector2 = require 'math.vector2'

local world = require 'battle.world'

local Com = ecs.Com
local concerns = {
	Com.view,
	Com.transform,
}
local sys = ecs.newsys('view', concerns)

function sys:setup(entity)
	local view = entity:getComponent(Com.view)
	view.gameObject = LuaInterface.LoadPrefab(view.prefab, view.root)
	LuaInterface.SetLocalScale(view.gameObject, view.scale)
	view.trans = view.gameObject.transform
	local pos = entity:getComponent(Com.transform).position
	view.trans.localPosition = UnityEngine.Vector3(pos.x, 0, pos.y)
	view.targetPos = pos:Clone()

	local angle = math.random(0, 360)
	LuaInterface.SetLocalEulerAngle(view.gameObject, 0, angle, 0)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local trans = v:getComponent(Com.transform)
		local view = v:getComponent(Com.view)
		
		view.moveStartTime = Time.realtimeSinceStartup
		view.moveTime = world.frameInterval
		view.moveStartPos = view.targetPos:Clone()

		LuaInterface.SetLocalPosition(view.gameObject, view.targetPos.x, 0, view.targetPos.y)
		view.targetPos = trans.position:Clone()
	end
end

function sys:update( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local view = v:getComponent(Com.view)
		local offset = Time.realtimeSinceStartup - view.moveStartTime
		local newPos = Vector2.Lerp(view.moveStartPos, view.targetPos, offset/view.moveTime)
		LuaInterface.SetLocalPosition(view.gameObject, newPos.x, 0, newPos.y)

		LuaInterface.LookAt(view.gameObject, view.lookPos.x, 0, view.lookPos.y)
	end
end