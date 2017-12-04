local util = require 'battle.system.logic.util'

local Com = ecs.Com
local tuple = {
	general = {
		Com.general,
		Com.logic.transform,
	},
	retinue = {
		Com.retinue,
		Com.logic.transform,
	},
	npc = {
		Com.npc,
		Com.logic.transform,
	},
}
local sys = ecs.newsys('recruit', tuple)

local map = ecs.Single.map
local recruitGap = 2

function sys:setup(entity, tupleIndex)
	if tupleIndex == 'general' or tupleIndex == 'retinue' then
		util.updateMap(entity)
	end
end

function sys:recruit(npc, eid)
	local eGeneral = self:getEntity(eid, 'general') or
		self:getEntity(self:getEntity(eid, 'retinue'):getComponent(Com.retinue).general, 'general')

	local comGeneral = eGeneral:getComponent(Com.general)
	table.insert(comGeneral.retinues, npc.id)

	npc:addComponent(Com.rvo)
	npc:addComponent(Com.retinue, eGeneral.id)
	npc:addComponent(Com.team, eGeneral.id)
	npc:addComponent(Com.attackee)

	npc:addComponent(Com.attacker)
	npc:getComponent(Com.attacker).attType = eGeneral:getComponent(Com.attacker).attType
end

function sys:_frameCalc( ... )
	local npcs = self:getEntities('npc')
	local rm = {}
	for k, v in pairs(npcs) do
		local comTrans = v:getComponent(Com.logic.transform)
		local key = map.teamMap:findCloestInRangeByPos(comTrans.position, recruitGap)
		if key then
			self:recruit(v, key)
			table.insert(rm, v)
		end
	end

	for _, v in ipairs(rm) do
		v:removeComponent(Com.npc)
	end
end