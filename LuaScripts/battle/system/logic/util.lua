local Com = ecs.Com

local _M = module()


function addRetinue(rid, tid)
	local en = ecs.getEntity(rid)

	local et = ecs.getEntity(tid)
	local comGeneral = et:getComponent(Com.general)
	if not comGeneral then
		local comRetinue = et:getComponent(Com.retinue)
		if comRetinue then
			comGeneral = ecs.getEntity(comRetinue.general):getComponent(Com.general)
		end
	end

	if comGeneral then
		table.insert(comGeneral.retinues, rid)
	end
end

function removeRetinue(rid)
	local comRetinue = ecs.getEntity(rid):getComponent(Com.retinue)
	local comGeneral = ecs.getEntity(comRetinue.general):getComponent(Com.general)
	table.removeV(comGeneral.retinues, rid)
end

function isHostile(e1, e2)
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

return _M