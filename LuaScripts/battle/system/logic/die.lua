local util = require 'battle.system.logic.util'
local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	{
		Com.die,
		Com.logic.animation,
	},
}
local sys = ecs.newsys('die', tuple)

local interval = 20

function sys:_frameCalc( ... )
	local rm = {}

	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local comDie = v:getComponent(Com.die)
		if comDie.dying then
			if world.frameNo - comDie.startFrame >= interval then
				table.insert(rm, v)
			end
		else
			util.die(v)
			local comAnim = v:getComponent(Com.logic.animation)
			comAnim.anim = 'die'
			comDie.dying = true
			comDie.startFrame = world.frameNo
		end
	end

	for _, v in ipairs(rm) do
		v:destroy()
	end
end