local Vector2 = require 'math.Vector2'
local world = require 'battle.world'
local util = require 'battle.system.util'

local Com = ecs.Com
local tuple = {
	bullet = {
		Com.bullet,
		Com.transform,
	},
	attackee = {
		Com.attackee,
		Com.transform,
	},
}
local sys = ecs.newsys('bullet', tuple)


function sys:calc(eBullet)
	local comBullet = eBullet:getComponent(Com.bullet)
	local eTarget = self:getEntity(comBullet.target, 'attackee')
	if eTarget then
		local comTrans_b = eBullet:getComponent(Com.transform)
		local comTrans_t = eTarget:getComponent(Com.transform)
		local distSq = comTrans_b.position - comTrans_t.position):SqrMagnitude()
		if distSq > 0.01 then
			local t = math.sqrt(distSq)/comBullet.speed
			comTrans_b.position = Vector2.Lerp(comTrans_b.position, comTrans_t.position, world.frameInterval/t)
		else
			util.attackCalc(comBullet.att, eTarget)
		end
	end
end

function sys:_frameCalc( ... )
	local entities = self:getEntities('bullet')
	for _, v in pairs(entities) do
		self:calc(v)
	end
end