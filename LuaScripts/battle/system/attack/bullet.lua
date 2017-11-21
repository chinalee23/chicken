local Vector2 = require 'math.vector2'
local util = require 'battle.system.util'
local world = require 'battle.world'

local Com = ecs.Com
local concern_1 = {
	Com.attack.bullet,
	Com.transform,
}
local concern_2 = {
	Com.attack.attackee,
	Com.transform,
}
local sys = ecs.newsys('attack.bullet', concern_1, concern_2)

function sys:calc(entity)
	local comBullet = entity:getComponent(Com.attack.bullet)
	local attee = self:getEntity(comBullet.attee, 2)
	if attee and not util.isDead(attee) then
		local comTrans_b = entity:getComponent(Com.transform)
		local comTrans_e = attee:getComponent(Com.transform)
		local distSq = (comTrans_e.position, comTrans_b.position):SqrMagnitude()
		if distSq < 0.01 then
			util.attack(comBullet.att, attee)
		else
			local t = math.sqrt(distSq) / comBullet.speed
			comTrans_b.position = Vector2.Lerp(comTrans_b.position, comTrans_e.position, world.frameInterval / t)
		end
	else
	end
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:calc(v)
	end
end