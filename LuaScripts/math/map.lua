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

	local maxX = math.ceil(width/sideLen + 1)
	local maxY = math.ceil(height/sideLen + 1)
	self.grids = {}
	for i = 1, maxX do
		self.grids[i] = {}
		for j = 1, maxY do
			self.grids[i][j] = classGrid.new(i, j)
		end
	end

	self.cache = {}
end

function classMap:calcGrid(pos)
	local x = math.floor(pos.x/self.sideLen) + 1
	local y = math.floor(pos.y/self.sideLen) + 1
	return self.grids[x][y]
end

-- 插入一关键字
function classMap:insert(key, pos)
	local grid = self:calcGrid(pos)
	grid.datas[key] = pos:Clone()
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

function classMap:getKey(key)
	if not self.cache[key] then
		log.info('map no key', key)
		return
	end
	log.info('pos', self.cache[key].datas[key])
	log.info('grid', self.cache[key].x, self.cahce[key].y)
end

-- 查找范围内的格子
-- 返回左下角和右上角的格子
function classMap:findGridsInRangeByPos(pos, radius)
	local dot1 = Vector2(math.max(pos.x-radius, 0), math.max(pos.y-radius, 0))
	local dot2 = Vector2(math.min(pos.x+radius, self.width), math.min(pos.y+radius, self.height))
	return self:calcGrid(dot1), self:calcGrid(dot2)
end
function classMap:findGridsInRangeByKey(key, radius)
	if not self.cache[key] then return end
	return self:findGridsInRangeByPos(self.cache[key].datas[key])
end

-- 查找范围内的关键字
-- 返回包含距离的关键字列表，并按照距离升序排列
function classMap:findKeysInRangeByPos(pos, radius, filtFunc)
	local rst = {}
	local rangeSq = radius^2
	local g1, g2 = self:findGridsInRangeByPos(pos, radius)
	for i = g1.x, g2.x do
		for j = g1.y, g2.y do
			local grid = self.grids[i][j]
			for k, v in pairs(grid.datas) do
				local distSq = (v-pos):SqrMagnitude()
				if distSq < rangeSq then
					if not filtFunc or filtFunc(k) then
						table.insert(rst, {k, distSq})
					end
				end
			end
		end
	end
	table.sort(rst, function (a, b)
		if a[2] == b[2] then
			return true
		end
		return a[2] < b[2]
	end)
	return rst
end
function classMap:findKeysInRangeByKey(key, radius)
	if not self.cache[key] then return end

	local rst = {}
	local pos = self.cache[key].datas[key]
	local rangeSq = radius^2
	local g1, g2 = self:findGridsInRangeByPos(pos, radius)
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
function classMap:findCloestInRangeByPos(pos, radius, filtFunc)
	local g1, g2 = self:findGridsInRangeByPos(pos, radius)
	local minKey
	local minDistSq = radius^2
	for i = g1.x, g2.x do
		for j = g1.y, g2.y do
			local grid = self.grids[i][j]
			for k, v in pairs(grid.datas) do
				if not filtFunc or filtFunc(k) then
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
function classMap:findCloestInRangeByKey(key, radius)
	if not self.cache[key] then return end
	
	local pos = self.cache[key].datas[key]
	local g1, g2 = self:findGridsInRangeByPos(pos, radius)
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