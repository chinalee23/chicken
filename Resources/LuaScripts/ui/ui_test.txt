local _M = module()

local random = require 'util.random'

local SPEED = 5
local SCOPE = 60
local GAP = 35
local sqrt = math.sqrt(0.5)


local gameObject
local rootRetinue
local camera

local major = {
	holes = {},
}
local npcs = {}
local retinues = {}

local input = CS.UnityEngine.Input
local keyCode = CS.UnityEngine.KeyCode

local function init( ... )
	major.go = LuaInterface.LoadPrefab('Prefab/Major', gameObject)
	major.pos = Vector2(0, 0)
	LuaInterface.SetLocalPosition(major.go, major.pos.x, major.pos.y, 0)

	local rootNpc = LuaInterface.Find(gameObject, 'npcs')
	for i = 1, 20 do
		local go = LuaInterface.LoadPrefab('Prefab/Npc', rootNpc)
		local x = random.range(-1000, 1000):tonumber()
		local y = random.range(-1000, 1000):tonumber()
		LuaInterface.SetLocalPosition(go, x, y, 0)
		table.insert(npcs, {
				go = go,
				pos = Vector2(x, y),
			})
	end

	rootRetinue = LuaInterface.Find(gameObject, 'retinues')

	camera = LuaInterface.Find(gameObject, 'Camera')
end

local function addRetinue(retinue)
	local layer = math.ceil((#retinues+1)/8)
	local max = layer*8
	local sz = layer*2+1
	for i = 1, max do
		if not major.holes[i] then
			local offset
			if i >= 1 and i <= sz then
				offset = Vector2(GAP*(i-1-layer), GAP*layer)
			elseif i <= max and i > max-sz then
				local j = i-(max-sz)
				offset = Vector2(GAP*(j-1-layer), -GAP*layer)
			else
				local row = math.floor((i-sz-1)/2)+1
				local col = i%2 == 0 and -1 or 1
				offset = Vector2(col*GAP*layer, (layer-row)*GAP)
			end
			major.holes[i] = true
			retinue.offset = offset
			table.insert(retinues, retinue)

			if #retinues == max then
				major.holes = {}
			end

			break
		end
	end
end

local function updateMajor( ... )
	local x = 0
	local y = 0
	if input.GetKey(keyCode.W) then
		y = y + 1
	end
	if input.GetKey(keyCode.S) then
		y = y - 1
	end
	if input.GetKey(keyCode.A) then
		x = x - 1
	end
	if input.GetKey(keyCode.D) then
		x = x + 1
	end
	if x*y ~= 0 then
		x = x * sqrt
		y = y * sqrt
	end

	local newPos = major.pos + Vector2(x, y)*SPEED
	newPos.x = math.min(1136/2-10, newPos.x)
	newPos.x = math.max(-1136/2+10, newPos.x)
	newPos.y = math.min(640/2-10, newPos.y)
	newPos.y = math.max(-640/2-10, newPos.y)

	if major.pos ~= newPos then
		major.pos = newPos
		LuaInterface.SetLocalPosition(major.go, newPos.x, newPos.y, 0)
	end
end

local function updateRetinue( ... )
	for _, v in ipairs(retinues) do
		local newpos = major.pos + v.offset
		LuaInterface.SetLocalPosition(v.go, newpos.x, newpos.y, 0)
	end
end

local function updateNpc( ... )
	local i = 1
	while true do
		if i > #npcs then break end
		local npc = npcs[i]
		local offset = npc.pos - major.pos
		local distance = offset:Magnitude()
		if distance < SCOPE then
			table.remove(npcs, i)
			npc.go.name = 'retinue'
			LuaInterface.SetParent(npc.go, rootRetinue)

			addRetinue(npc)
		else
			i = i + 1
		end
	end
end

local function updateCamera( ... )
	-- body
end



function awake(go)
	gameObject = go

	init()
end

function start( ... )
	-- body
end

function update( ... )
	updateMajor()
	updateRetinue()
	updateNpc()
end

function ondestroy( ... )
	-- body
end

return _M