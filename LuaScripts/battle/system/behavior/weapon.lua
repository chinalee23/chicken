local config = require 'config.weapon'

local Com = ecs.Com
local tuple = {
	weapon = {
		Com.logic.weapon,
		Com.behavior.weapon,
	},
	character = {
		Com.attacker,
		Com.logic.transform,
		Com.behavior.transform,
	},
}
local sys = ecs.newsys('behavior.weapon', tuple)

local function showWeapon(comWeapon, status)
	if status then
		if not comWeapon.showing then
			comWeapon.gameObject:SetActive(true)
			comWeapon.showing = true
		end
	else
		if comWeapon.showing then
			comWeapon.gameObject:SetActive(false)
			comWeapon.showing = false
		end
	end
end

function sys:setup(entity, tupleIndex)
	if tupleIndex == 'weapon' then
		local comWeapon_l = entity:getComponent(Com.logic.weapon)
		local comWeapon_b = entity:getComponent(Com.behavior.weapon)

		comWeapon_b.gameObject:SetActive(true)
		LuaInterface.SetPosition(comWeapon_b.gameObject, comWeapon_l.position.x, 0.5, comWeapon_l.position.y)
		LuaInterface.SetLocalScale(comWeapon_b.gameObject, 2)
	end
end

function sys:update( ... )
	local entities = self:getEntities('weapon')
	for _, v in pairs(entities) do
		local comWeapon_l = v:getComponent(Com.logic.weapon)
		local comWeapon_b = v:getComponent(Com.behavior.weapon)
		if comWeapon_l.owner then
			local eChar = self:getEntity(comWeapon_l.owner, 'character')
			local comAttacker = eChar:getComponent(Com.attacker)
			if not comWeapon_b.equipped then
				local comTrans = eChar:getComponent(Com.behavior.transform)
				local mountPoint = LuaInterface.Find(comTrans.gameObject, 'weapon_prefab_r')
				if not mountPoint then
					mountPoint = LuaInterface.Find(comTrans.gameObject, 'Bip001/Bip001 Pelvis/Bip001 Spine/Bip001 Spine1/Bip001 Neck/Bip001 L Clavicle/Bip001 L UpperArm/Bip001 L Forearm/Bip001 L Hand/weapon')
				end
				LuaInterface.SetParent(comWeapon_b.gameObject, mountPoint)
				comWeapon_b.equipped = true
			end

			local weaponType = config[comWeapon_l.id].weaponType
			if weaponType == 'jinzhan' then
				showWeapon(comWeapon_b, comAttacker.attType == 'jinzhan' or not comAttacker.weapons['yuancheng'])
			else
				showWeapon(comWeapon_b, comAttacker.attType == 'yuancheng')
			end
		else
			showWeapon(comWeapon_b, true)
			if comWeapon_b.equipped then
				LuaInterface.SetParent(comWeapon_b.gameObject, ecs.Single.scene.rootWeapon)
				LuaInterface.SetPosition(comWeapon_b.gameObject, comWeapon_l.position.x, 0.5, comWeapon_l.position.y)
				LuaInterface.SetLocalScale(comWeapon_b.gameObject, 2)
				comWeapon_b.equipped = false
			end
		end
	end
end