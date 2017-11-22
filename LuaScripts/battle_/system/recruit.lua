local Circle = require 'math.circle'
local utmath = require 'math.util'
local kdtree = require 'math.kdtree'

local Com = ecs.Com
local concern_1 = {
	Com.troop,
	Com.transfrom,
}
local concern_2 = {
	Com.npc,
	Com.transfrom,
}
local concern_3 = {
	Com.general,
}
local sys = ecs.newsys('recruit', concern_1, concern_2, concern_3)

local recruitGap = 2
local trees


function sys:recruit(npc, generalId)
	npc:removeComponent(Com.npc)
	npc:addComponent(Com.rvo, false)

	npc:addComponent(Com.troop, generalId)
	npc:addComponent(Com.attack.attacker)
	npc:addComponent(Com.attack.attackee)
	npc:addComponent(Com.attack.idle)
	npc:addComponent(Com.animation)
end

function sys:createTree(id)
	local nodes = {}
	local comGeneral = self:getEntity(id, 3):getComponent(Com.general)
	local pos = self:getEntity(id, 1):getComponent(Com.transform).position
	table.insert(nodes, {dot = pos, data = id})
	for _, v in ipairs(comGeneral.retinues) do
		if not self:getEntity(v, 1) then
			log.info('can not find retinue', v)
		end
		local pos = self:getEntity(v, 1):getComponent(Com.transform).position
		table.insert(nodes, {dot = pos, data = v})
	end
	
	local tree = kdtree.new(nodes)
	trees[id] = tree
	return tree
end

-- 
-- for npc
--   for general
--     search tree, if in range recruit  
-- 
function sys:_frameCalc( ... )
	trees = {}

	local npcs = self:getEntities(2)
	if table.count(npcs) == 0 then return end

	local record = {}
	local generals = self:getEntities(3)
	for _, npc in pairs(npcs) do
		local pos_n = npc:getComponent(Com.transform).position
		local c = Circle.new(pos_n, recruitGap)
		for _, g in pairs(generals) do
			local tree = trees[g.id] or self:createTree(g.id)
			if utmath.intersect_q_c(tree:getQuadrangle(), c) and tree:queryRangeTree(pos_n, recruitGap) then
				record[npc] = g.id
				break
			end
		end
	end
	for k, v in pairs(record) do
		self:recruit(k, v)
	end
end
