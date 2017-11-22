local Vector2 = require 'math.vector2'

local classGrid = class()
function classGrid:ctor(x, y)
	self.x = x
	self.y = y
	self.datas = {}
end


local classMap = class()

-- width, height: 地图长宽
-- sideLen: 切割后的正方形边长
function classMap:ctor(width, height, sideLen)
	self.width = width
	self.height = height
	self.sideLen = sideLen

	local maxX = math.ceil(width/sideLen)
	local maxY = math.ceil(height/sideLen)
	self.grids = {}
	for i = 0, maxX-1 do
		self.grids[i] = {}
		for j = 0, maxY-1 do
			self.grids[i][j] = classGrid.new(i, j)
		end
	end

	self.cache = {}
end

function classMap:calcGrid(pos)
	local x = math.floor(pos.x/self.sideLen)
	local y = math.floor(pos.y/self.sideLen)
	return self.grids[x][y]
end

-- 插入一关键字
function classMap:insert(key, pos)
	local grid = self:calcGrid(pos)
	grid.datas[key] = pos
	self.cache[key] = grid
end

-- 删除一关键字
function classMap:remove(key)
	local grid = self.cache[key]
	if not grid then return end
	
	grid.datas[key] = nil
	self.cache[key] = nil
end

-- 修改关键字
function classMap:modify(key, pos)
	self:remove(key)
	self:insert(key, pos)
end

-- 查找范围内的格子
-- 返回左下角和右上角的格子
function classMap:findGridsInRange(key, radius)
	if not self.cache[key] then return end
		
	local pos = self.cache[key].datas[key]
	local dot1 = Vector2(math.max(pos.x-radius, 0), math.max(pos.y-radius, 0))
	local dot2 = Vector2(math.min(pos.x+radius, self.width), math.min(pos.y+radius, self.height))
	return self:calcGrid(dot1), self:calcGrid(dot2)
end

-- 查找范围内的关键字
-- 返回包含距离的关键字列表，并按照距离升序排列
function classMap:findKeysInRange(key, radius)
	if not self.cache[key] then return end

	local rst = {}
	local pos = self.cache[key].datas[key]
	local rangeSq = radius^2
	local g1, g2 = self:findGridInRange(key, radius)
	for i = g1.x, g2.x do
		for j = g1.y, g2.y do
			local grid = self.grids[i][j]
			for k, v in pairs(grid.datas) do
				if k ~= key then
					local distSq = (v-pos):SqrMagnitude()
					if distSq < rangeSq then
						table.insert(rst, {k, distSq})
					end
				end
			end
		end
	end
	table.sort(rst, function (a, b)
		return a[2] <= b[2]
	end)
	return rst
end

-- 查找范围内最近的关键字
function classMap:findCloestInRange(key, radius)
	if not self.cache[key] then return end
	
	local pos = self.cache[key].datas[key]
	local g1, g2 = self:findGridInRange(key, radius)
	local minKey
	local minDistSq = radius^2
	for i = g1.x, g2.x do
		for j = g1.y, g2.y do
			local grid = self.grids[i][j]
			for k, v in pairs(grid.datas) do
				if k ~= key then
					local distSq = (v-pos):SqrMagnitude()
					if distSq < minDistSq then
						minKey = k
					end
				end
			end
		end
	end
	return minKey
end

return classMap