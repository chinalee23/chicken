local _M = module()

local random = require 'util.random'

-- map size
local width = 1136
local height = 640

local size = 5

foods = {}
local maxCount = 5
local bounds = {}

local function eat(characters)
	bounds = {}
	for k, v in pairs(characters) do
		local bound = v:calcBound()
		table.insert(bounds, bound)
		if v.moved then
			local rm = {}
			for i, f in ipairs(foods) do
				if f[1] >= bound[1] + size/2 and
					f[1] <= bound[2] - size/2 and
					f[2] >= bound[3] + size/2 and
					f[2] <= bound[4] - size/2 then
					v.size = v.size + size
					v:setPosition()
					table.insert(rm, i)
				end
			end
			for _, r in ipairs(rm) do
				table.remove(foods, r)
			end
		end
	end
end

 local function generate(characters)
 	if #foods == maxCount then return end

 	local start = os.clock()
 	for i = #foods+1, maxCount do
 		while true do
 			local i = random.range(1+size/2, width-size/2):tonumber()
 			local j = random.range(1+size/2, height-size/2):tonumber()
 			local flag = true
 			for _, bound in ipairs(bounds) do
 				if i > bound[1]-size/2 and i < bound[2]+size/2 and j > bound[3]-size/2 and j < bound[4]+size/2 then
 					flag = false
 					break
 				end
 			end
 			if flag then
 				table.insert(foods, {i, j})
 				break
 			end
 		end
 	end
 end

function calc(characters)
	eat(characters)
	generate(characters)
end

return _M