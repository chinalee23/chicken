local Vector2 = require 'math.Vector2'
local world = require 'battle.world'
local util = require 'battle.system.logic.util'

local Com = ecs.Com
local tuple = {
	bullet = {
		Com.bullet,
		Com.logic.transform,
	},
	attackee = {
		Com.attackee,
		Com.logic.transform,
	},
}
local sys = ecs.newsys('bullet', tuple)


function sys:calc(eBullet)
	local comBullet = eBullet:getComponent(Com.bullet)
	local eTarget = self:getEntity(comBullet.target, 'attackee')
	if eTarget then
		local comTrans_b = eBullet:getComponent(Com.logic.transform)
		local comTrans_t = eTarget:getComponent(Com.logic.transform)
		local distSq = (comTrans_b.position - comTrans_t.position):SqrMagnitude()
		if distSq > 0.0001 then
			local t = math.sqrt(distSq)/comBullet.speed
			comTrans_b.position = Vector2.Lerp(comTrans_b.position, comTrans_t.position, world.frameInterval/t)
		else
			util.attackCalc(comBullet.att, eTarget)
			return true
		end
	else
		return true
	end
end

function sys:_frameCalc( ... )
	local entities = self:getEntities('bullet')
	local rm = {}
	for _, v in pairs(entities) do
		if self:calc(v) then
			table.insert(rm, v)
		end
	end

	for _, v in ipairs(rm) do
		v:destroy()
	end
end