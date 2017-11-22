local util = require 'battle.system.util'

local Com = ecs.Com
local tuple = {
	general = {
		Com.general,
		Com.transform,
	},
	retinue = {
		Com.retinue,
		Com.transform,
	},
	npc = {
		Com.npc,
		Com.transform,
	},
}
local sys = ecs.newsys('recruit', tuple)

local map = ecs.Single.map
local recruitGap = 2

function sys:recruit(npc, eid)
	util.addRetinue(npc.id, eid)
	npc:addComponent(Com.retinue)
end

function sys:_frameCalc( ... )
	local npcs = self:getEntities('npc')
	for k, v in pairs(npcs) do
		local key = map:findCloestInRange(k, recruitGap)
		if key then
			self:recruit(v, key)
		end
	end
end