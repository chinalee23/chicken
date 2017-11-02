local _M = module()

local RVO = CS.RVO

local recruitGap = 5

function calc(characters, npcs)
	local i = 1
	while i <= #npcs do
		for _, c in pairs(characters) do
			local flag = false
			for k, _ in pairs(c.agents) do
				local distance = Vector2.Distance(npcs[i].position, k.position)
				if distance < recruitGap then
					c.agents[npcs[i]] = RVO.Simulator.Instance:addAgent(RVO.Vector2(npcs[i].position.x, npcs[i].position.y))
					c.layers[npcs[i]] = math.floor((table.count(c.agents) - 2) / 10) + 1
					table.remove(npcs, i)
					i = i - 1
					flag = true
					break
				end
			end
			if flag then
				break
			end
		end
		i = i + 1
	end
end

return _M