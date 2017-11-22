local Vector3 = require 'math.vector3'

local Com = ecs.Com
local tuple = {
	{
		Com.playercamera,
		Com.unit,
	},
}
local sys = ecs.newsys('playercamera', tuple)

function sys:update( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local comUnit = v:getComponent(Com.unit)
		local comCamera = v:getComponent(Com.playercamera)
		local pos = comCamera.offset + Vector3(comUnit.currPos.x, 0, comUnit.currPos.y)
		LuaInterface.SetPosition(comCamera.gameObject, pos.x, pos.y, pos.z)
	end
end