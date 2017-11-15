-- 伪随机运算

local fraction = require 'util.fraction'

local k = 16807
local m = 2147483647 -- 2^32 - 1
-- local m = 32767 -- 2^16 - 1
local seed = os.time()


local function srand(x)
	seed = x
end

local function rand( ... )
	seed = k * seed % m
	return seed
end

-- 左右闭包含，不带参数为 [0, 1], 返回 fraction
local function range(low, high)
	rand()
	if not low and not high then
		return fraction.new(seed, m - 1)
	end
	low = low or 0
	high = high or m - 1
	return fraction.new(seed % (high - low + 1) + low, 1)
end

-- set seed
local function srand(x)
	seed = x
end

return {
	range = range,
	srand = srand,
}