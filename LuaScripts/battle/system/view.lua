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
	view.trans = view.gameObject.transform
	local pos = entity:getComponent(Com.transform).position
	view.trans.localPosition = UnityEngine.Vector3(pos.x, 0, pos.y)
	view.targetPos = pos:Clone()
end

function sys:frameCalc( ... )
	for _, v in pairs(self.entities) do
		local trans = v:getComponent(Com.transform)
		local view = v:getComponent(Com.view)
		
		view.trans.localPosition = UnityEngine.Vector3(view.targetPos.x, 0, view.targetPos.y)
		view.targetPos = trans.position:Clone()
		view.trans:LookAt(UnityEngine.Vector3(view.targetPos.x, 0, view.targetPos.y))
		view.moveTime = world.frameInterval - (UnityEngine.Time.realtimeSinceStartup - world.frameStartTime)

		if trans.moving and not view.moving then
			view.moving = true
			LuaInterface.PlayAnimation(view.gameObject, 'run')
		elseif not trans.moving and view.moving then
			view.moving = false
			LuaInterface.PlayAnimation(view.gameObject, 'idle1')
		end
	end
end

function sys:update( ... )
	for _, v in pairs(self.entities) do
		local view = v:getComponent(Com.view)
		local v3 = UnityEngine.Vector3(view.targetPos.x, 0, view.targetPos.y)
		view.trans.localPosition = UnityEngine.Vector3.Lerp(view.trans.localPosition, v3, UnityEngine.Time.deltaTime / view.moveTime)
	end
end