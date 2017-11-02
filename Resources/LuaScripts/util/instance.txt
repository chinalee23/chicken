function instance(p, ...)
	assert(p and type(p) == 'table')

	local t = {}
	for k, v in pairs(p) do
		if type(v) == 'table' then
			t[k] = {}
		end
	end
	setmetatable(t, {__index = p})

	if t.ctor then
		t:ctor(...)
	end

	return t
end