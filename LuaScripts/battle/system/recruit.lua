local Com = ecs.Com
local concern = {
	Com.troop,
	Com.transfrom,
}
local sys = ecs.newsys('recruit', concern)

local recruitGap = 3

local function recruit(npc, general)
	local troop_n = npc:getComponent(Com.troop)
	troop_n.rank = 'retinue'
	troop_n.generalId = general.id
	
	npc:addComponent(Com.rvo)
	
	local troop_g = general:getComponent(Com.troop)
	table.insert(troop_g.retinues, npc.id)
end

local function checkDistance(pos1, pos2)
	local dist = Vector2.Distance(pos1, pos2)
	return dist < recruitGap
end

function sys:_frameCalc( ... )
	local npcs = {}
	local generals = {}
	for _, v in pairs(self.entities) do
		local rank = v:getComponent(Com.troop).rank
		if rank == 'villager' then
			table.insert(npcs, v)
		elseif rank == 'general' then
			table.insert(generals, v)
		end
	end

	local i = 1
	while i < #npcs do
		local pos_i = npcs[i]:getComponent(Com.transform).position
		local flag = false
		for _, v in ipairs(generals) do
			local pos_g = v:getComponent(Com.transform).position
			if checkDistance(pos_i, pos_g) then
				recruit(npcs[i], v)
				flag = true
			else
				local troop = v:getComponent(Com.troop)
				for _, id in ipairs(troop.retinues) do
					local retinue = self.entities[id]
					local pos_r = retinue:getComponent(Com.transform).position
					if checkDistance(pos_i, pos_r) then
						recruit(npcs[i], v)
						flag = true
						break
					end
				end
			end
			if flag then
				break
			end
		end
		i = i + 1
	end
end
