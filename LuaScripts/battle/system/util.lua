local Com = ecs.Com

local function die(entity)
	entity:addComponent(Com.attack.die)

	-- if general then dismiss retinues
	local comGeneral = entity:getComponent(Com.general)
	if not comGeneral then return end
	for _, v in ipairs(comGeneral.retinues) do
		local retinue = ecs.getEntity(v)
		retinue:addComponent(Com.attack.dismiss)
	end
end

local function isDead(entity)
	return entity:getComponent(Com.attack.die) ~= nil
end

local function attack(att, attee)
	local comProperty = attee:getComponent(Com.property)
	local dmg = att^2 / (att + comProperty.def)
	comProperty.hp = comProperty.hp - dmg
	events.battle.hpChange(attee.id, dmg)
	if comProperty.hp <= 0 then
		die(attee)
	end
end