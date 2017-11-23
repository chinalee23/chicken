local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	{Com.dismiss},
}
local sys = ecs.newsys('dismiss', tuple)

local interval = 20

function sys:setup(entity)
	local comDismiss = entity:getComponent(Com.dismiss)
	comDismiss.startFrame = world.frameNo
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	local rm = {}
	for _, v in pairs(entities) do
		local comDismiss = v:getComponent(Com.dismiss)
		if world.frameNo - comDismiss.startFrame >= interval then
			table.insert(rm, v)
		end
	end

	for _, v in ipairs(rm) do
		v:removeComponent(Com.dismiss)
		v:addComponent(Com.npc)
	end
end