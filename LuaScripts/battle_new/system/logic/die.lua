local Com = ecs.Com
local tuple = {
	general = {
		Com.general,
		Com.die,
	},
	retinue = {
		Com.retinue,
		Com.die,
	},
}
local sys = ecs.newsys('die', tuple)


function sys:_frameCalc( ... )
	local tmp = {}

	local retinues = self:getEntities('retinue')
	for k, v in pairs(retinues) do
		util.removeRetinue(k)
		table.insert(tmp, v)
	end

	local generals = self:getEntities('general')
	for k, v in pairs(generals) do
		util.dismiss(k)
		table.insert(tmp, v)
	end

	for _, v in ipairs(tmp) do
		v:destroy()
	end
end