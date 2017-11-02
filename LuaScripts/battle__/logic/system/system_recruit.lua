local Com = ecs.Com

local concerns = {
	Com.charactertype,
	Com.transform,
}

local _M = ecs.newsys('recruit', concerns)

local npcs = {}
local generals = {}

function _M:setup(id)
	local charactertype = self.entities[id][Com.charactertype].type
	if charactertype == 'npc' then
		table.insert(npcs, id)
	elseif charactertype == 'general' then
		table.insert(generals, id)
	end
end

function _M:frameCalc( ... )
	local i = 1
	while i <= #npcs do
		for _, g in ipairs(generals) do
			local flag = false
			
		end
	end
end