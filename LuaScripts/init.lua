local util = {
	'log',
	'ut_string',
	'ut_table',
	'async',
	'instance',
	'module',
	'event',
	'vector2',
	'vector3',
	'vector4',
}
for i = 1, #util do
	require('util.' .. util[i])
end

LuaInterface = CS.LuaInterface

require 'restrict_global'