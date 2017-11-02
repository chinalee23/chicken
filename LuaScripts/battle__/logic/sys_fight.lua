local _M = module()

local function dotInBound(dot, bound)
	return dot[1] > bound[1] and dot[1] < bound[2] and dot[2] > bound[3] and dot[4] < bound[4]
end

local function intersect(a, b)
	return inBound({a[1], a[3]}, b) or inBound({a[1], a[4]}, b) or inBound({a[2], a[4]}, b) or inBound({a[2], a[3]}, b)
end

function calc(characters)
	local bounds = {}
	for k, v in pairs(characters) do
		table.insert(bounds, {
				id = k,
				bound = v:calcBound(),
			})
	end

	local i = 1
	while true do
		if i >= #bounds then
			break
		end
		local a = characters[bounds[i].id]
		local j = i+1
		while true do
			local b = characters[bounds[j].id]
			if intersect(bounds[i].bound, bounds[j].bound) then
				if a.size >= b.size then
					table.remove(bounds, j)
				else
					table.remove(bounds, i)
					break
				end
			end
			if j > #bounds then
				i = i + 1
				break
			end
		end
	end
end

return _M