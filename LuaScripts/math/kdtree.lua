-- 2维 kdtree

local Quadrangle = require 'math.quadrangle'
local Vector2 = require 'math.vector2'

local function calcVariance(nodes, dismension)
	local tmp1 = 0
	local tmp2 = 0
	local cnt = #nodes
	for _, v in ipairs(nodes) do
		tmp1 = tmp1 + v.dot[dismension]*v.dot[dismension]/cnt
		tmp2 = tmp2 + v.dot[dismension]/cnt
	end
	return tmp1 - tmp2*tmp2
end

local function chooseSplit(nodes, sortDismension)
	local vx = calcVariance(nodes, 'x')
	local vy = calcVariance(nodes, 'y')
	local splitDismension = vx >= vy and 'x' or 'y'

	if sortDismension ~= splitDismension then
		table.sort(nodes, function (a, b)
			if a.dot[splitDismension] == b.dot[splitDismension] then
				return false
			end
			return a.dot[splitDismension] < b.dot[splitDismension]
		end)
		sortDismension = splitDismension
	end
		
	return math.floor(#nodes/2)+1, splitDismension
end

local function splitTable(tbl, first, last)
	first = first or 1
	last = last or #tbl
	local t = {}
	for i = first, last do
		table.insert(t, tbl[i])
	end
	return t
end


local classTreeNode = class()
function classTreeNode:ctor()
	-- 点
	self.dot = nil
	-- 数据
	self.data = nil
	-- 分隔维度
	self.splitDismension = nil
	-- 左子树
	self.left = nil
	-- 右子树
	self.right = nil
end

function classTreeNode:isLeaf( ... )
	return not self.left and not self.right
end


local classTree = class()
local function createTree(nodes, root, sortDismension)
	local splitIndex, splitDismension = chooseSplit(nodes, sortDismension)
	root.dot = nodes[splitIndex].dot
	root.data = nodes[splitIndex].data
	root.splitDismension = splitDismension

	local leftTbl = splitTable(nodes, 1, splitIndex-1)
	local rightTbl = splitTable(nodes, splitIndex+1)
	if #leftTbl > 0 then
		root.left = classTreeNode.new()
		createTree(leftTbl, root.left, splitDismension)
	end
	if #rightTbl > 0 then
		root.right = classTreeNode.new()
		createTree(rightTbl, root.right, splitDismension)
	end
end
function classTree:ctor(nodes)
	self.nodes = nodes
	self.quadrangle = nil
	self.root = nil
end

function classTree:createTree()
	self.root = classTreeNode.new()
	createTree(self.nodes, self.root)
end

function classTree:createQuadrangle()
	local minX = self.nodes[1].dot.x
	local maxX = self.nodes[1].dot.x
	local minY = self.nodes[1].dot.y
	local maxY = self.nodes[1].dot.y
	for i = 2, #self.nodes do
		local dot = self.nodes[i].dot
		minX = math.min(minX, dot.x)
		maxX = math.max(maxX, dot.x)
		minY = math.min(minY, dot.y)
		maxY = math.max(maxY, dot.y)
	end
	self.quadrangle = Quadrangle.new(Vector2(minX, minY), Vector2(maxX, maxY))
end

function classTree:getQuadrangle( ... )
	if not self.quadrangle then
		self:createQuadrangle()
	end
	return self.quadrangle
end

function classTree:print()
	local level = self:getLevel()
	local t = {}
	for i = 1, 2^level - 1 do
		t[i] = 'none'
	end

	local foo
	foo = function (node, index)
		t[index] = node
		if node.left then
			foo(node.left, index*2)
		end
		if node.right then
			foo(node.right, index*2+1)
		end
	end
	foo(self.root, 1)
	local out = {}
	for i = level, 1, -1 do
		local s = ''
		for j = 2^(i-1), 2^i - 1 do
			if t[j] == 'none' then
				s = s .. '[none]'
			else
				s = s .. tostring(t[j].dot)
			end
		end
		table.insert(out, s)
	end
	log.info(table.concat(out, '\n'))
end

function classTree:getLevel( ... )
	local level = 0
	local tmp = {self.root}
	while #tmp > 0 do
		level = level + 1
		local t = {}
		for _, v in ipairs(tmp) do
			if v.left then
				table.insert(t, v.left)
			end
			if v.right then
				table.insert(t, v.right)
			end
		end
		tmp = t
	end
	return level
end

-- 查找目标点所在区域
function classTree:getSearchPath(dot)
	local path = {}
	local root = self.root
	while true do
		table.insert(path, root)
		if dot[root.splitDismension] <= root.dot[root.splitDismension] then
			if root.left then root = root.left else break end
		else
			if root.right then root = root.right else break end
		end
	end
	return path
end



-- 查找树上是否有节点在目标点的范围内
-- dot: 目标点
-- radius: 目标点的范围
function classTree:queryRangeTree(dot, radius)
	if not self.root then self:createTree() end

	local path = self:getSearchPath(dot)
	
	local range = radius^2
	while #path > 0 do
		local node = path[#path]
		table.remove(path, #path)
		if (node.dot - dot):SqrMagnitude() < range then
			return true
		end
		if not node:isLeaf() then
			-- 判断范围圆是否和分割线相交
			local f = dot[node.splitDismension] - node.dot[node.splitDismension]
			if math.abs(f) < radius then
				if f <= 0 and node.right then
					table.insert(path, node.right)
				elseif f > 0 and node.left then
					table.insert(path, node.left)
				end
			end
		end
	end

	return false
end

-- 查找树上离目标点最近的节点
function classTree:queryClosest(dot)
	if not self.root then self:createTree() end

	local path = self:getSearchPath(dot)
	local minDist = 0
	local minNode = nil
	while #path > 0 do
		local node = path[#path]
		table.remove(path, #path)
		local dist = (node.dot - dot):SqrMagnitude()
		if not minNode or dist < minDist then
			minDist = dist
			minNode = node
		end
		if not node:isLeaf() then
			local f = dot[node.splitDismension] - node.dot[node.splitDismension]
			if f^2 < minDist then
				if f <= 0 and node.right then
					table.insert(path, node.right)
				elseif f > 0 and node.left then
					table.insert(path, node.left)
				end
			end
		end
	end

	return minNode, minDist
end

-- 查找树上在目标点范围内的最近点
function classTree:queryClosestInRange(dot, radius)
	local minNode, minDist = self:queryClosest(dot)
	if minDist < radius^2 then
		return minNode, minDist
	end
end

return classTree