local config = require 'config.weapon'
local util = require 'battle.system.logic.util'

local Com = ecs.Com
local tuple = {
	character = {
		Com.team,
		Com.attacker,
	},
	weapon = {
		Com.logic.weapon,
	},
}
local sys = ecs.newsys('pickup', tuple)

local map = ecs.Single.map
local pickGap = 2


function sys:pickup(cid, eWeapon, weaponType, pickLevel)
	local eChar = self:getEntity(cid, 'character')
	if not eChar then return end
	
	local weapons = eChar:getComponent(Com.attacker).weapons
	
	if weapons[weaponType] then
		local weaponId = self:getEntity(weapons[weaponType], 'weapon'):getComponent(Com.logic.weapon).id
		if config[weaponId].pickLevel < pickLevel then
			-- 丢弃
			-- log.info(cid, 'drop weapon', weaponId)
			util.dropWeapon(eChar, weaponType)
		else
			return
		end
	end

	-- 装备
	-- log.info(cid, 'pickup weapon', eWeapon:getComponent(Com.logic.weapon).id)
	util.pickupWeapon(eChar, eWeapon, weaponType)

	return true
end

function sys:_frameCalc( ... )
	local weapons = self:getEntities('weapon')
	local rm = {}
	for k, v in pairs(weapons) do
		local comWeapon = v:getComponent(Com.logic.weapon)
		if not comWeapon.owner then
			local rsts = map.teamMap:findKeysInRangeByPos(comWeapon.position, pickGap)
			if #rsts > 0 then
				local pickLevel = config[comWeapon.id].pickLevel
				local weaponType = config[comWeapon.id].weaponType
				for _, rst in ipairs(rsts) do
					local key = rst[1]
					if self:pickup(key, v, weaponType, pickLevel) then
						table.insert(rm, v)
						break
					end
				end
			end
		end
	end

	for _, v in ipairs(rm) do
		v:removeComponent(Com.behavior.transform)
	end
end