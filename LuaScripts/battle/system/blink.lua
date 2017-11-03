local world = require 'battle.world'

local Com = ecs.Com
local concerns = {
	Com.transform,
	Com.troop,
}
local sys = ecs.newsys('blink', concerns)

local input = ecs.Single.input
local distance = 10

function sys:blink(entity)
	local troop = entity:getComponent(Com.troop)
	local trans_g = entity:getComponent(Com.transform)
	trans_g.position = trans_g.position + trans_g.face * distance
	for _, v in ipairs(troop.retinues) do
		local retinue = self.entities[v]
		local trans_r = retinue:getComponent(Com.transform)
		trans_r.position = trans_r.position + trans_g.face * distance
	end
end

function sys:_frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		if v.blink then
			self:blink(self.entities[v.id])
		end
	end
end