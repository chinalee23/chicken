local Com = ecs.Com
local concern_1 = {
	Com.attack.attack,
}

local concern_2 = {
	Com.property
}
local sys = ecs.newsys('attack.attack', concern_1)

function sys:calc(entity)
	local comAttack = entity:getComponent(Com.attack.attack)
	local attacker = self:getEntity(comAttack)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:calc(v)
	end
end