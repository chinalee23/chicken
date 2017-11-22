local world = require 'battle.world'

local Com = ecs.Com
local concerns_1 = {
	Com.transform,
	Com.troop,
}
local concerns_2 = {
	Com.general,
}
local sys = ecs.newsys('blink', concerns_1, concerns_2)

local input = ecs.Single.input
local distance = 10

function sys:blink(id)
	local comGeneral = self:getEntity(id, 2):getComponent(Com.general)
	local comTrans_g = self:getEntity(id, 1):getComponent(Com.transform)

	local blinkOffset = comTrans_g.face * distance
	log.info('blink', blinkOffset)
	comTrans_g.position = comTrans_g.position + blinkOffset
	for _, v in ipairs(comGeneral.retinues) do
		local comTrans_r = self:getEntity(v, 1):getComponent(Com.transform)
		comTrans_r.position = comTrans_r.position + blinkOffset
	end
end

function sys:_frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		if v.blink then
			self:blink(v.id)
		end
	end
end