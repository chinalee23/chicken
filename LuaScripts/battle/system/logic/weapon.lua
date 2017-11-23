local Com = ecs.Com
local tuple = {
	general = {
		Com.general,
		Com.logic.transform,
	},
	retinue = {
		Com.retinue,
		Com.logic.transform,
	},
	weapon = {
		Com.weapon.unused,
		Com.logic.transform,
	},
}
local sys = ecs.newsys('weapon', tuple)

local pickGap = 2

function sys:pickup(eWeapon, eid)
	local eGeneral = self:getEntity(eid, 'general') or
		self:getEntity(self:getEntity(eid, 'retinue'):getComponent(Com.retinue).general, 'general')
end

function sys:_frameCalc( ... )
	local weapons = self:getEntities('weapon')
	for _, v in pairs(weapons) do
		local comTrans = v:getComponent(Com.logic.transform)
		local key = map.teamMap:findCloestInRangeByPos(comTrans.position, pickGap)
		if key then
			self:pickup(v, key)
		end
	end
end