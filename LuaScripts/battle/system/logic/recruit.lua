local util = require 'battle.system.logic.util'

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

function sys:setup(entity, tupleKey)
	local comTrans = entity:getComponent(Com.transform)
	map:modify(entity.id, comTrans.position)
end

function sys:recruit(npc, eid)
	util.addRetinue(npc.id, eid)

	npc:removeComponent(Com.npc)
	npc:addComponent(Com.retinue, eid)
end

function sys:_frameCalc( ... )
	local npcs = self:getEntities('npc')
	for k, v in pairs(npcs) do
		local key = map:findCloestInRangeByKey(k, recruitGap)
		if key then
			self:recruit(v, key)
		end
	end
end