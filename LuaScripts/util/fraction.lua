-- 分数
-- fraction 和 number 之间的比较, lua5.1 和 lua5.3 不一样，最好不要这么比较
-- % 只支持两个整数运算
-- ^ 第二个参数必须为整数

local fraction = {}
setmetatable(fraction, fraction)
fraction.__index = fraction
fraction.__metatable = 'fraction'

local function is_number(x)
	return type(x) == 'number'
end

local function is_fraction(x)
	return getmetatable(x) == 'fraction'
end

local function to_fraction(x)
	if is_number(x) then
		x = fraction.newn(x)
	end
	return x
end

local function to_integer(x)
	if is_number(x) then
		return (x == math.floor(x) and x == math.ceil(x)) and x or nil
	elseif is_fraction(x) then
		return x[2] == 1 and x[1] or nil
	end
end

local function max_common_divisor(a, b)
	assert(a ~= 0 and b ~= 0)
	local c = a % b
	while c ~= 0 do
		a = b
		b = c
		c = a % b
	end
	return b
end

function fraction.new(numerator, denominator)
	assert(numerator and denominator)
	assert(type(numerator) == 'number' and type(denominator) == 'number')
	assert(denominator ~= 0)

	if numerator == 0 then
		denominator = 1
	else
		local divisor = max_common_divisor(numerator, denominator)
		numerator = numerator / divisor
		denominator = denominator / divisor
	end
	
	local t = {
		numerator, denominator
	}
	setmetatable(t, fraction)
	return t
end

function fraction.newn(n)
	assert(type(n) == 'number')
	local integer, fractional = math.modf(n)
	if fractional == 0 then
		return fraction.new(integer, 1)
	else
		local s = tostring(fractional)
		s = string.split(s, '.')[2]
		local denominator = math.pow(10, #s)
		local numerator = integer * denominator + fractional * denominator
		return fraction.new(numerator, denominator)
	end
end

function fraction:tonumber( ... )
	return self[1] / self[2]
end

function fraction.__tostring(a)
	return string.format('%.0f/%.0f', a[1], a[2])
end

function fraction.__eq(a, b)
	a = to_fraction(a)
	b = to_fraction(b)
	return a[1] == b[1] and a[2] == b[2]
end

function fraction.__lt(a, b)
	a = to_fraction(a)
	b = to_fraction(b)
	return a:tonumber() < b:tonumber()
end

function fraction.__add(a, b)
	a = to_fraction(a)
	b = to_fraction(b)
	return fraction.new(a[1]*b[2] + b[1]*a[2], a[2]*b[2])
end

function fraction.__sub(a, b)
	a = to_fraction(a)
	b = to_fraction(b)
	return fraction.new(a[1]*b[2] - b[1]*a[2], a[2]*b[2])
end

function fraction.__mul(a, b)
	a = to_fraction(a)
	b = to_fraction(b)
	return fraction.new(a[1]*b[1], a[2]*b[2])
end

function fraction.__div(a, b)
	a = to_fraction(a)
	b = to_fraction(b)
	assert(b[1] ~= 0, 'divisor should not be 0')
	return fraction.new(a[1]*b[2], a[2]*b[1])
end

function fraction.__pow(a, b)
	b = to_integer(b)
	assert(b, 'power should be integer')
	if is_number(a) then
		return fraction.newn(math.pow(a, b))
	elseif is_fraction(a) then
		return fraction.new(math.pow(a[1], b), math.pow(a[2], b))
	end
end

function fraction.__mod(a, b)
	a = to_integer(a)
	b = to_integer(b)
	assert(a and b, 'mod should be integer')
	return fraction.newn(a % b)
end

return fraction