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
	local comAttacker = entity:getComponent(Com.attacker)
	if comAttacker then
		if comAttacker.weapons['jinzhan'] then
			-- log.info(entity.id, 'die, drop jinzhan weapon', ecs.getEntity(comAttacker.weapons['jinzhan']):getComponent(Com.logic.weapon).id)
			dropWeapon(entity, 'jinzhan')
		end
		if comAttacker.weapons['yuancheng'] then
			-- log.info(entity.id, 'die, drop yuancheng weapon', ecs.getEntity(comAttacker.weapons['yuancheng']):getComponent(Com.logic.weapon).id)
			dropWeapon(entity, 'yuancheng')
		end
	end

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
		eRetinue:removeComponent(Com.attackee)

		local comAttacker = eRetinue:getComponent(Com.attacker)
		if comAttacker then
			if comAttacker.weapons['jinzhan'] then
				-- log.info(eRetinue.id, 'dismiss, drop jinzhan weapon', ecs.getEntity(comAttacker.weapons['jinzhan']):getComponent(Com.logic.weapon).id)
				dropWeapon(eRetinue, 'jinzhan')
			end
			if comAttacker.weapons['yuancheng'] then
				-- log.info(eRetinue.id, 'dismiss, drop yuancheng weapon', ecs.getEntity(comAttacker.weapons['jinzhan']):getComponent(Com.logic.weapon).id)
				dropWeapon(eRetinue, 'yuancheng')
			end
		end
		eRetinue:removeComponent(Com.attacker)
		

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

function pickupWeapon(eChar, eWeapon, weaponType)
	local comAttacker = eChar:getComponent(Com.attacker)
	comAttacker.weapons[weaponType] = eWeapon.id
	
	local comWeapon = eWeapon:getComponent(Com.logic.weapon)
	comWeapon.owner = eChar.id
end

function dropWeapon(eChar, weaponType)
	local comAttacker = eChar:getComponent(Com.attacker)
	local wid = comAttacker.weapons[weaponType]
	comAttacker.weapons[weaponType] = nil

	local eWeapon = ecs.getEntity(wid)
	local comWeapon = eWeapon:getComponent(Com.logic.weapon)
	comWeapon.owner = nil

	local pos = eChar:getComponent(Com.logic.transform).position
	comWeapon.position = pos:Clone()
end

function moveTowardTo(entity, eTarget, speed, distance)
	distance = distance or 0
	local comTrans_e = entity:getComponent(Com.logic.transform)
	local comTrans_t = eTarget:getComponent(Com.logic.transform)
	comTrans_e.direction = (comTrans_t.position - comTrans_e.position):Normalize()
	local distSq = (comTrans_t.position - comTrans_e.position):SqrMagnitude(0)
	if distSq < distance^2 then
		return
	else
		local distSqrt = math.sqrt(distSq)
		if distSqrt - distance > speed then
			comTrans_e.position = comTrans_e.position + comTrans_e.direction * speed
		else
			comTrans_e.position = comTrans_e.position + comTrans_e.direction * (distSqrt - distance)
		end
	end
end

return _M