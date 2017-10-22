local _M = module()

local SPEED = 5
local SCOPE = 40
local GAP = 25
local sqrt = math.sqrt(0.5)


local gameObject
local rootRetinue

local major = {
	holes = {},
}
local npcs = {}
local retinues = {}

local input = CS.UnityEngine.Input
local keyCode = CS.UnityEngine.KeyCode

local function init( ... )
	major.go = LuaInterface.Find(gameObject, 'major')
	local pos = LuaInterface.GetLocalPosition(major.go)
	major.pos = Vector3(pos[1], pos[2], pos[3])

	local rootNpc = LuaInterface.Find(gameObject, 'npcs')
	local goNpcs = LuaInterface.GetAllChild(rootNpc)
	for i = 1, #goNpcs do
		local pos = LuaInterface.GetLocalPosition(goNpcs[i])
		table.insert(npcs, {
				go = goNpcs[i],
				pos = Vector3(pos[1], pos[2], pos[3]),
			})
	end

	rootRetinue = LuaInterface.Find(gameObject, 'retinues')
end

local function addRetinue(retinue)
	local layer = math.ceil((#retinues+1)/8)
	local max = layer*8
	local sz = layer*2+1
	for i = 1, max do
		if not major.holes[i] then
			log.info('add to ', i)
			local offset
			if i >= 1 and i <= sz then
				offset = Vector3(GAP*(i-1-layer), GAP*layer, 0)
			elseif i <= max and i > max-sz then
				local j = i-(max-sz)
				offset = Vector3(GAP*(j-1-layer), -GAP*layer, 0)
			else
				local row = math.floor((i-sz-1)/2)+1
				local col = i%2 == 0 and -1 or 1
				offset = Vector3(col*GAP*layer, (layer-row)*GAP, 0)
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

	local newPos = major.pos + Vector3(x, y, 0)*SPEED
	newPos.x = math.min(1136/2-10, newPos.x)
	newPos.x = math.max(-1136/2+10, newPos.x)
	newPos.y = math.min(640/2-10, newPos.y)
	newPos.y = math.max(-640/2-10, newPos.y)

	if major.pos ~= newPos then
		major.pos = newPos
		LuaInterface.SetLocalPosition(major.go, newPos.x, newPos.y, newPos.z)
	end
end

local function updateRetinue( ... )
	for _, v in ipairs(retinues) do
		local newpos = major.pos + v.offset
		LuaInterface.SetLocalPosition(v.go, newpos.x, newpos.y, newpos.z)
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