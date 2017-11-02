local function setfenv(fn, env)
	local i = 1
	while true do
		local name = debug.getupvalue(fn, i)
		if name == '_ENV' then
			debug.upvaluejoin(fn, i, function ( ... )
				return env
			end, 1)
		elseif not name then
			break
		end
		i = i + 1
	end
	return fn
end

function module( ... )
	local _M = setmetatable({}, {__index = _G})
	local f = debug.getinfo(2, 'f').func
	setfenv(f, _M)
	return _M
end