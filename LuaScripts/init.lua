local util = {
	'log',
	'ut_string',
	'ut_table',
	'async',
	'class',
	'module',
	'event',
}
for i = 1, #util do
	require('util.' .. util[i])
end

UnityEngine = CS.UnityEngine
LuaInterface = CS.LuaInterface
Time = UnityEngine.Time

require 'ecs.ecs'

require 'restrict_global'