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

function sys:setup(entity, tupleIndex)
	if tupleIndex == 'general' or tupleIndex == 'retinue' then
		local comTrans = entity:getComponent(Com.transform)
		map:modify(entity.id, comTrans.position)
	end
end

function sys:recruit(npc, eid)
	local eGeneral = self:getEntity(eid, 'general')
	if not eGeneral then
		local comRetinue = self:getEntity(eid, 'retinue'):getComponent(Com.retinue)
		eGeneral = self:getEntity(comRetinue.general, 'general')
	end

	local comGeneral = eGeneral:getComponent(Com.general)
	table.insert(comGeneral.retinues, npc.id)

	npc:addComponent(Com.retinue, eGeneral.id)
	npc:removeComponent(Com.npc)
end

function sys:_frameCalc( ... )
	local npcs = self:getEntities('npc')
	for k, v in pairs(npcs) do
		local comTrans = v:getComponent(Com.transform)
		local key = map:findCloestInRangeByPos(comTrans.position, recruitGap)
		if key then
			self:recruit(v, key)
		end
	end
end