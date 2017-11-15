local kdtree = require 'math.kdtree'
local utmath = require 'math.util'
local world = require 'battle.world'

local Com = ecs.Com
local concern = {
	Com.troop,
	Com.transform,
	Com.attack,
	Com.animation,
	Com.view,
}
local sys = ecs.newsys('attack', concern)

local maxAttDist = 10


local treeNodes
local troops
local trees
local collisions
function sys:collectNodes( ... )
	local entities = self:getEntities()
	treeNodes = {}
	troops = {}
	for k, v in pairs(entities) do
		local troop = v:getComponent(Com.troop)
		local generalId = troop.generalId
		if not treeNodes[generalId] then
			treeNodes[generalId] = {}
			table.insert(troops, generalId)
		end
		local pos = v:getComponent(Com.transform).position
		table.insert(treeNodes[generalId], {dot = pos, data = k})
	end
end

function sys:createTrees()
	trees = {}
	for k, v in pairs(treeNodes) do
		local tree = kdtree.new()
		tree:createQuadrangle(v)
		trees[k] = tree
	end
end

function sys:calcCollisions( ... )
	self:collectNodes()
	self:createTrees()
	collisions = {}
	for i = 1, #troops do
		local general_i = troops[i]
		if not collisions[general_i] then collisions[general_i] = {} end
		local tree_i = trees[general_i]
		local qi = tree_i.quadrangle:expend(maxAttDist)
		for j = i + 1, #troops do
			local general_j = troops[j]
			local tree_j = trees[general_j]
			if utmath.intersect_q_q(qi, tree_j.quadrangle) then
				if not tree_i.treeCreated then tree_i:createTree(treeNodes[general_i]) end
				if not tree_j.treeCreated then tree_j:createTree(treeNodes[general_j]) end
				table.insert(collisions[general_i], general_j)

				if not collisions[general_j] then collisions[general_j] = {} end
				table.insert(collisions[general_j], general_i)
			end
		end
	end
end

function sys:findTarget(entity)
	local pos = entity:getComponent(Com.transform).position
	local generalId = entity:getComponent(Com.troop).generalId
	local attDist = entity:getComponent(Com.attack).attDist
	local minNode, minDist
	for _, c in ipairs(collisions[generalId]) do
		local tree = trees[c]
		local n, m = tree:queryClosestInRange(pos, attDist)
		if n and (not minNode or m < minDist) then
			minNode = n
			minDist = m
		end
	end
	if minNode then
		return minNode
	end
end

function sys:checkTargetInRange(entity, target)
	local attDist = entity:getComponent(Com.attack).attDist
	local pos_e = entity:getComponent(Com.transform).position
	local pos_t = target:getComponent(Com.transform).position
	return (pos_e - pos_t):SqrMagnitude() < attDist^2
end

function sys:handleEntity(entity)
	local attack = entity:getComponent(Com.attack)
	if attack.status == 'idle' then
		self:inIdle(entity, attack)
	elseif attack.status == 'qianyao' then
		self:inQianyao(entity, attack)
	elseif attack.status == 'houyao' then
		self:inHouyao(entity, attack)
	end
end

function sys:inIdle(entity, attack)
	local targetNode = self:findTarget(entity)
	if not targetNode then return end
	
	attack.target = targetNode.data
	attack.status = 'qianyao'
	attack.startFrame = world.frameNo

	local target = self:getEntity(attack.target)
	local view = entity:getComponent(Com.view)
	view.lookPos = target:getComponent(Com.transform).position

	local anim = entity:getComponent(Com.animation)
	anim.tarAnim = 'skill1'
end

function sys:inQianyao(entity, attack)
	if (world.frameNo - attack.startFrame) < attack.attFrame then return end
	-- log.info('frame', world.frameNo, 'entity', entity.id, 'attack', attack.target)
	attack.status = 'houyao'
end

function sys:inHouyao(entity, attack)
	if (world.frameNo - attack.startFrame) < attack.totalFrame then return end

	local anim = entity:getComponent(Com.animation)
	if self:checkTargetInRange(entity, self:getEntity(attack.target)) then
		attack.status = 'qianyao'
		attack.startFrame = world.frameNo
		anim.currAnim = nil
	else
		attack.status = 'idle'
		anim.tarAnim = nil
	end
end

function sys:_frameCalc( ... )
	self:calcCollisions()
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:handleEntity(v)
	end
end