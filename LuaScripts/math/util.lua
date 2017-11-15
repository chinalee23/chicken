-- 判断两矩形相交
local function intersect_q_q(a, b)
	local lx = math.abs(a.min.x + a.max.x - b.min.x - b.max.x)
	local sx = a.max.x - a.min.x + b.max.x - b.min.x
	local ly = math.abs(a.min.y + a.max.y - b.min.y - b.max.y)
	local sy = a.max.y - a.min.y + b.max.y - b.min.y

	return lx <= sx and ly <= sy
end

-- 判断矩形和圆相交
local function intersect_q_c(q, c)
	local v = (q.center - c.center)
	v:Abs()
	local u = v - q.radius
	u.x = math.max(u.x, 0)
	u.y  = math.max(u.y, 0)
	-- log.info(v, q.radius, u)
	return u:SqrMagnitude() <= c.radius * c.radius
end

return {
	intersect_q_q = intersect_q_q,
	intersect_q_c = intersect_q_c,
}