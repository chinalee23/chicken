local Com = ecs.Com
local map = ecs.Single.map

local _M = module()

function removeRetinue(rid)
	local comRetinue = ecs.getEntity(rid):getComponent(Com.retinue)
	local comGeneral = ecs.getEntity(comRetinue.general):getComponent(Com.general)
	table.removeV(comGeneral.retinues, rid)
end

function isHostile(id1, id2)
	local e1 = ecs.getEntity(id1)
	local e2 = ecs.getEntity(id2)
	local comTeam1 = e1:getComponent(Com.team)
	local comTeam2 = e2:getComponent(Com.team)
	return comTeam1 and comTeam2 and comTeam1.id ~= comTeam2.id
end

function attackCalc(att, eAttee)
	local comProperty = eAttee:getComponent(Com.property)
	local dmg = att^2 / (att + comProperty.def)
	comProperty.hp = comProperty.hp - dmg
	if comProperty.hp <= 0 then
		eAttee:addComponent(Com.die)
	end

	events.battle.hpChange(eAttee.id, dmg)
end

function die(entity)
	local comRetinue = entity:getComponent(Com.retinue)
	if comRetinue then
		dieRetinue(entity)
	else
		local comGeneral = entity:getComponent(Com.general)
		if comGeneral then
			dieGeneral(entity)
		end
	end

	map.teamMap:remove(entity.id)
	map.attackeeMap:remove(entity.id)

	entity:removeComponents({
			[Com.die] = true,
			[Com.logic.transform] = true,
			[Com.behavior.transform] = true,
			[Com.logic.animation] = true,
			[Com.behavior.animation] = true,
		})
end

function dieRetinue(entity)
	local comRetinue = entity:getComponent(Com.retinue)
	local comGeneral = ecs.getEntity(comRetinue.general):getComponent(Com.general)
	table.removeV(comGeneral.retinues, entity.id)
end

function dieGeneral(entity)
	local comGeneral = entity:getComponent(Com.general)
	for _, v in ipairs(comGeneral.retinues) do
		local eRetinue = ecs.getEntity(v)
		eRetinue:removeComponent(Com.retinue)
		eRetinue:removeComponent(Com.team)
		eRetinue:removeComponent(Com.attacker)
		eRetinue:removeComponent(Com.attackee)

		map.teamMap:remove(v)
		map.attackeeMap:remove(v)

		local comAnim = eRetinue:getComponent(Com.logic.animation)
		comAnim.anim = nil

		eRetinue:addComponent(Com.dismiss)
	end
end

function dismiss(gid)
	local comGeneral = ecs.getEntity(gid):getComponent(Com.general)
	for _, v in ipairs(comGeneral.retinues) do
		local eRetinue = ecs.getEntity(rid)
		eRetinue:removeComponent(Com.retinue)
		eRetinue:removeComponent(Com.team)
		eRetinue:removeComponent(Com.attacker)
		eRetinue:removeComponent(Com.attackee)

		eRetinue:addComponent(Com.dismiss)
	end
end

function updateMap(entity)
	local pos = entity:getComponent(Com.logic.transform).position

	local comTeam = entity:getComponent(Com.team)
	if comTeam then
		map.teamMap:modify(entity.id, pos)
	end

	local comAttackee = entity:getComponent(Com.attackee)
	if comAttackee then
		map.attackeeMap:modify(entity.id, pos)
	end
end

function createBullet(att, pos, target)
	local entity = ecs.Entity.new()
	entity:addComponent(Com.logic.transform, pos)
	entity:addComponent(Com.bullet, att, target)

	local go = LuaInterface.LoadPrefab('Fx/100301_001F_Prefab')
	entity:addComponent(Com.behavior.transform, go, 1, 1)
end

return _M