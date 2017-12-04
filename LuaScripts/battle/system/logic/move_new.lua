local Vector2 = require 'math.vector2'
local world = require 'battle.world'
local util = require 'battle.system.logic.util'

local Com = ecs.Com

local tuple = {
	general = {
		Com.general,
		Com.logic.transform,
		Com.logic.animation,
	},
	retinue = {
		Com.retinue,
		Com.logic.transform,
		Com.logic.animation,
	},
	attacker = {
		Com.attacker,
	},
}
local sys = ecs.newsys('move', tuple)

local normalSpeed = 0.7
local maxSpeed = 1.2
local retinueGap = 1


function sys:move(eGeneral, direction, accelerate)
	self:moveGeneral(eGeneral, direction, accelerate)
	self:moveRetinue(eGeneral, direction)
end

function sys:moveGeneral(eGeneral, direction, accelerate)
	local comTrans = eGeneral:getComponent(Com.logic.transform)
	if accelerate then
		comTrans.speed = (accelerate == 'on' and maxSpeed or normalSpeed)
	end
	if direction then
		comTrans.velocity = direction * comTrans.speed
	else
		comTrans.velocity:Set(0, 0)
	end
end

function sys:moveRetinue(eGeneral, direction)
	local comTrans_g = eGeneral:getComponent(Com.logic.transform)
	local comGeneral = eGeneral:getComponent(Com.general)
	for i, v in ipairs(comGeneral.retinues) do
		local eRetinue = self:getEntity(v, 'retinue')
		local comTrans_r = eRetinue:getComponent(Com.logic.transform)
		comTrans_r.speed = comTrans_g.speed
	end
end


function sys:_frameCalc( ... )
	local geenrals = self:getEntities('general')
	local tmp = {}
	for k, v in pairs(geenrals) do
		local input = ecs.Single.inputs[k]
		if input and (input.direction or input.accelerate) then
			self:move(v, input.direction, input.accelerate)
		else
			table.insert(tmp, v)
		end
	end

	for _, v in ipairs(tmp) do
		self:move(v)
	end
end