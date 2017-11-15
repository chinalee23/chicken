local kdtree = require 'math.kdtree'
local Circle = require 'math.circle'
local utmath = require 'math.util'

local Com = ecs.Com
local concern_1 = {
	Com.troop,
	Com.transfrom,
}
local concern_2 = {
	Com.npc,
	Com.transfrom,
}
local sys = ecs.newsys('recruit', concern_1, concern_2)

local recruitGap = 3

local function recruit(npc, general)
	npc:removeComponent(Com.npc)
	npc:addComponent(Com.rvo)
	local troop_n = npc:addComponent(Com.troop)
	troop_n.rank = 'retinue'
	troop_n.generalId = general.id

	npc:addComponent(Com.attack, 2, 4, 15)
	npc:addComponent(Com.animation)
	
	local troop_g = general:getComponent(Com.troop)
	table.insert(troop_g.retinues, npc.id)
end

function sys:collectNodes( ... )
	local nodes = {}
	local entities = self:getEntities()
	for k, v in pairs(entities) do
		local troop = v:getComponent(Com.troop)
		local generalId = troop.generalId
		if not nodes[generalId] then
			nodes[generalId] = {}
		end
		local pos = v:getComponent(Com.transform).position
		table.insert(nodes[generalId], {dot = pos, data = k})
	end
	return nodes
end

function sys:_frameCalc( ... )
	local npcs = self:getEntities(2)
	local nodes = self:collectNodes()
	
	local trees = {}
	for k, v in pairs(nodes) do
		trees[k] = kdtree.new()
		trees[k]:createQuadrangle(v)
	end
	
	local record = {}
	for _, npc in pairs(npcs) do
		local posNpc = npc:getComponent(Com.transform).position
		local c = Circle.new(posNpc, recruitGap)
		for k, v in pairs(trees) do
			if utmath.intersect_q_c(v.quadrangle, c) then
				if not v.treeCreated then
					v:createTree(nodes[k])
				end
				if v:queryRangeTree(posNpc, recruitGap) then
					record[npc] = k
					break
				end
			end
		end
	end
	for k, v in pairs(record) do
		recruit(k, self:getEntity(v))
	end
end
