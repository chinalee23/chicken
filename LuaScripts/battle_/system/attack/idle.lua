local kdtree = require 'math.kdtree'
local utmath = require 'math.util'
local world = require 'battle.world'

local Com = ecs.Com
local concern_1 = {
	Com.transform,
	Com.troop,
	Com.property,
	Com.attack.attacker,
	Com.attack.idle,
}
local concern_2 = {
	Com.transform,
	Com.troop,
	Com.attack.attackee,
}

local sys = ecs.newsys('attack.idle', concern_1, concern_2)

local maxAttDist = 10
local treeAttackers
local treeAttackees
local collisions

function sys:createOneTree(entities)
	local trees = {}

	local nodes = {}
	for _, v in pairs(entities) do
		local troopId = v:getComponent(Com.troop).id
		if not nodes[troopId] then
			nodes[troopId] = {}
		end
		table.insert(nodes[troopId], {dot = v:getComponent(Com.transform).position, data = v.id})
	end
	for k, v in pairs(nodes) do
		trees[k] = kdtree.new(v)
	end

	return trees
end

function sys:createTrees( ... )
	local eAttackers = self:getEntities()
	treeAttackers = self:createOneTree(eAttackers)

	local eAttackees = self:getEntities(2)
	treeAttackees = self:createOneTree(eAttackees)
end

function sys:calcCollisions( ... )
	collisions = {}
	for k, atter in pairs(treeAttackers) do
		collisions[k] = {}
		local q = atter:getQuadrangle():expend(maxAttDist)
		for kk, attee in pairs(treeAttackees) do
			if k ~= kk then
				if utmath.intersect_q_q(q, attee:getQuadrangle()) then
					table.insert(collisions[k], attee)
				end
			end
		end
	end
end

function sys:findTarget(entity)
	local pos = entity:getComponent(Com.transform).position
	local troopId = entity:getComponent(Com.troop).id
	local attDist = entity:getComponent(Com.property).attDist
	local minNode, minDist
	for _, tree in ipairs(collisions[troopId]) do
		local n, m = tree:queryClosestInRange(pos, attDist)
		if n and (not minNode or m < minDist) then
			minNode = n
			minDist = m
		end
	end
	if minNode then
		return minNode.data
	end
end

function sys:attack(entity, target)
	entity:addComponent(Com.attack.qianyao, target, world.frameNo)
end

function sys:_frameCalc( ... )
	self:createTrees()
	self:calcCollisions()

	local attackers = self:getEntities()
	local tmp = {}
	for _, v in pairs(attackers) do
		local target = self:findTarget(v)
		if target then
			self:attack(v, target)
			table.insert(tmp, v)
		end
	end
	for _, v in ipairs(tmp) do
		v:removeComponent(Com.attack.idle)
	end
end