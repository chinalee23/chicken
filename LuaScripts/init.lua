local util = {
	'log',
	'ut_string',
	'ut_table',
	'ut_math',
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


-- protobuf
local protobuf = require 'protobuf.protobuf'
local buff = LuaInterface.LoadProto()
protobuf.register(buff)