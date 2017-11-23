local Vector3 = require 'math.vector3'

local Com = ecs.Com
local tuple = {
	{
		Com.playercamera,
		Com.behavior.transform,
	},
}
local sys = ecs.newsys('playercamera', tuple)

function sys:update( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local comTrans = v:getComponent(Com.behavior.transform)
		local comCamera = v:getComponent(Com.playercamera)
		local pos = comCamera.offset + Vector3(comTrans.currPos.x, 0, comTrans.currPos.y)
		LuaInterface.SetPosition(comCamera.gameObject, pos.x, pos.y, pos.z)
	end
end