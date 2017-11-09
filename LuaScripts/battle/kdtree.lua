-- 2维 kdtree


local classTreeNode = class()
function classTreeNode:ctor()
	-- 点
	self.dot = nil
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



local function calcVariance(dots, dismension)
	local tmp1 = 0
	local tmp2 = 0
	local cnt = #dots
	for _, v in ipairs(dots) do
		tmp1 = tmp1 + v[dismension]*v[dismension]/cnt
		tmp2 = tmp2 + v[dismension]/cnt
	end
	return tmp1 - tmp2*tmp2
end

local function chooseSplit(dots, sortDismension)
	local vx = calcVariance(dots, 'x')
	local vy = calcVariance(dots, 'y')
	local splitDismension = vx >= vy and 'x' or 'y'

	if sortDismension ~= splitDismension then
		table.sort(dots, function (a, b)
			if a[splitDismension] == b[splitDismension] then
				return false
			end
			return a[splitDismension] < b[splitDismension]
		end)
		sortDismension = splitDismension
	end
		
	return math.floor(#dots/2)+1, splitDismension
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

local function createTree(dots, root, sortDismension)
	local splitIndex, splitDismension = chooseSplit(dots, sortDismension)
	root.dot = dots[splitIndex]
	root.splitDismension = splitDismension

	local leftTbl = splitTable(dots, 1, splitIndex-1)
	local rightTbl = splitTable(dots, splitIndex+1)
	if #leftTbl > 0 then
		root.left = classTreeNode.new()
		createTree(leftTbl, root.left, splitDismension)
	end
	if #rightTbl > 0 then
		root.right = classTreeNode.new()
		createTree(rightTbl, root.right, splitDismension)
	end
end




local classTree = class()
function classTree:ctor()
	self.root = classTreeNode.new()

	self.minX = 0
	self.maxX = 0
	self.minY = 0
	self.maxY = 0
end

function classTree:create(dots)
	self:createQuadrangle(dots)
	createTree(dots, self.root)
end

function classTree:traverse(node, out)
	node = node or self.root
	out = out or {}
	if node.left then
		pre = self:traverse(node.left)
	end
	if node.right then
		pre = self:traverse(node.right)
	end
end

function classTree:createQuadrangle(dots)
	self.minX = dots[1].x
	self.maxX = dots[1].x
	self.minY = dots[1].y
	self.maxY = dots[1].y
	for i = 2, #dots do
		local dot = dots[i]
		self.minX = math.min(self.minX, dot.x)
		self.maxX = math.max(self.maxX, dot.x)
		self.minY = math.min(self.minY, dot.y)
		self.maxY = math.min(self.maxY, dot.y)
	end
end

function classTree:query(dot, range)
	if not checkQuadrangle(dot, range) then
		return false
	end
end

function classTree:checkQuadrangle(dot, range)
	if (Vector2(self.minX, self.minY) - dot):SqrMagnitude() < range then
		return true
	end
	if (Vector2(self.minX, self.maxY) - dot):SqrMagnitude() < range then
		return true
	end
	if (Vector2(self.maxX, self.minY) - dot):SqrMagnitude() < range then
		return true
	end
	if (Vector2(self.maxX, self.maxY) - dot):SqrMagnitude() < range then
		return true
	end

	if dot.x > self.minX and dot.x < self.maxX and dot.y > self.minY and dot.y < self.maxY then
		return true
	end

	return false
end

function classTree:checkTree(dot, range)
	local radius = math.sqrt(range)

	local path = {}
	local root = self.root
	while true do
		table.insert(path, root)
		if dot[root.splitDismension] <= root.dot[root.splitDismension] then
			if root.left then
				root = root.left
			else
				break
			end
		else
			if root.right then
				root = root.right
			else
				break
			end
		end
	end
	
	while #path > 0 do
		local node = path[#path]
		table.remove(path, #path)
		if (node.dot - dot):SqrMagnitude() < range then
			return true
		end
		if not node:isLeaf() then
			if (dot[node.splitDismension] + radius) > node.dot[node.splitDismension] or
				(dot[node.splitDismension] - radius) < node.dot[node.splitDismension] then
				if dot[node.splitDismension] <= node.dot[node.splitDismension] then
					if node.right then
						table.insert(path, node.right)
					end
				else
					if node.left then
						table.insert(path, node.left)
					end
				end
			end
		end
	end

	return false
end

return classTree