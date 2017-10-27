-- 日志输出
-- luaPrint, luaError 根据相应平台自行定义

local print = luaPrint or print
local error = luaError or error

local split = '|'

local function traceback( ... )
	return '\n' .. debug.traceback('lua stack:', 3)
end

local function dump(func, ...)
	local args = {...}
	local out = {}
	for i = 1, #args do
		out[i] = tostring(args[i])
	end

	func(table.concat(out, '|') .. traceback())
end


log = {}
function log.info( ... )
	dump(print, ...)
end

function log.error( ... )
	dump(error, ...)
end