require 'util.class'
local Vector2 = require 'math.vector2'

local classMap = require 'battle_new.map'
local map = classMap.new(100, 100, 10)
map:insert(1, Vector2(5, 13))
map:insert(2, Vector2(5, 21))

local rst = map:findKeyInRange(1, 10)
for _, v in ipairs(rst) do
	print(v[1], v[2])
end