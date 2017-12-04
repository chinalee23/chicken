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


local maxCacheCnt = 100
function sys:calcQueuePosition_Circle( ... )
	self.queue = {}
	local d = 1
	local r = 2

	local cnt = 1
	local i = 0
	local n = math.floor(2*math.pi*r/d)
	local rad = d/r
	while cnt <= maxCacheCnt do
		if i == n then
			r = r*2
			n = n*2
			rad = rad/2
			i = 0
		end
		local x = r*math.cos(i*rad)
		local y = r*math.sin(i*rad)
		table.insert(self.queue, Vector2(x, y))

		i = i + 1
		cnt = cnt + 1
	end
end

function sys:calcQueuePosition_Rect( ... )
	self.queue = {}
	local r = 2
	
	local cnt = 1
	local layer = 0
	local i = 0
	local sideLen = 0
	local pos = Vector2(0, 0)
	while cnt <= maxCacheCnt do
		if i == layer*8 then
			layer = layer + 1
			i = 1
			sideLen = 2*layer + 1
			pos.x = -layer*r
			pos.y = -layer*r
			table.insert(self.queue, pos:Clone())
		else
			i = i + 1
			if i >= 1 and i <= sideLen then
				pos.y = pos.y + r
			elseif i > sideLen and i <= 2*sideLen-1 then
				pos.x = pos.x + r
			elseif i >= 2*sideLen and i <= 3*sideLen-2 then
				pos.y = pos.y - r
			else
				pos.x = pos.x - r
			end
			table.insert(self.queue, pos:Clone())
		end
	end
end


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