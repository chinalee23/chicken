--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--
--      Use, modification and distribution are subject to the "New BSD License"
--      as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
--------------------------------------------------------------------------------

local sqrt = math.sqrt
local abs = math.abs
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget

local clamp = function (t, min, max) 
	if t < min then 
		return min 
	elseif t > max then
		return max
	else
		return t
	end
end

local Vector2 = 
{
--[[	x = 0,
	y = 0,		
	
	class = "Vector2",--]]
}

setmetatable(Vector2, Vector2)

Vector2.__index = Vector2

Vector2.__call = function(t,x,y)
	return Vector2.New(x,y)
end

function Vector2.New(x, y)
	local v = {x = x or 0, y = y or 0}
	setmetatable(v, Vector2)	
	return v
end

function Vector2:Set(x,y)
	self.x = x or 0
	self.y = y or 0	
end

function Vector2:Get()
	return self.x, self.y
end

function Vector2:SqrMagnitude()
	return self.x * self.x + self.y * self.y
end

function Vector2:Clone()
	return Vector2.New(self.x, self.y)
end

function Vector2:Cover(v)
	self.x = v.x
	self.y = v.y
end

function Vector2:Normalize()
	local v = self:Clone()
	return v:SetNormalize()	
end

function Vector2:SetNormalize()
	local num = self:Magnitude()	
	
	if num == 1 then
		return self
    elseif num > 1e-05 then    
        self:Div(num)
    else    
        self:Set(0,0)
	end 

	return self
end

function Vector2:Abs( ... )
	self.x = abs(self.x)
	self.y = abs(self.y)
end

function Vector2.Dot(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y
end

function Vector2.Cross(lhs, rhs)
	return (lhs.x * rhs.y) - (lhs.y * rhs.x)
end

function Vector2.Angle(from, to)
	return acos(clamp(Vector2.dot(from:Normalize(), to:Normalize()), -1, 1)) * 57.29578
end


function Vector2.Magnitude(v2)
	return sqrt(v2.x * v2.x + v2.y * v2.y)
end

function Vector2.Distance(lhs, rhs)
	return Vector2.Magnitude(rhs - lhs)
end


function Vector2:Div(d)
	self.x = self.x / d
	self.y = self.y / d	
	
	return self
end

function Vector2:Mul(d)
	self.x = self.x * d
	self.y = self.y * d
	
	return self
end

function Vector2:Add(b)
	self.x = self.x + b.x
	self.y = self.y + b.y
	
	return self
end

function Vector2:Sub(b)
	self.x = self.x - b.x
	self.y = self.y - b.y
	
	return
end

function Vector2.Lerp(from, to, t)
	if t <= 0 then return from:Clone() end
	if t >= 1 then return to:Clone() end
	local v = Vector2()
	v.x = from.x + (to.x - from.x) * t
	v.y = from.y + (to.y - from.y) * t
	return v
end

Vector2.__tostring = function(self)
	return string.format("[%f,%f]", self.x, self.y)
end

Vector2.__div = function(va, d)
	return Vector2.New(va.x / d, va.y / d)
end

Vector2.__mul = function(va, d)
	return Vector2.New(va.x * d, va.y * d)
end

Vector2.__add = function(va, vb)
	return Vector2.New(va.x + vb.x, va.y + vb.y)
end

Vector2.__sub = function(va, vb)
	return Vector2.New(va.x - vb.x, va.y - vb.y)
end

Vector2.__unm = function(va)
	return Vector2.New(-va.x, -va.y)
end

Vector2.__eq = function(va,vb)
	return va.x == vb.x and va.y == vb.y
end

return Vector2