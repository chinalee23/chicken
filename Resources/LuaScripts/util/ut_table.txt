-- table 扩展

local srep = string.rep
local sformat = string.format
local tconcat = table.concat

-- 设置 table 为只读
function table.readonly()
	return setmetatable({}, {
			__index = t,
			__newindex = function (t, key, value)
				error('Attempt to modify readonly table!!')
			end,
			__metatable = 'locked',
		})
end

-- 判断 table 是否为空
function table.isempty(t)
	for k, v in pairs(t) do
		return false
	end
	return true
end

-- 判断 table 中是否存在 element
function table.exist(t, element)
	for k, v in pairs(t) do
		if v == element then
			return true
		end
	end
	return false
end

-- 删除 table 中某一元素（只删除一个）
function table.deleteV(t, element)
	for k, v in pairs(t) do
		if v == element then
			t[k] = nil
			return
		end
	end
end

-- 删除数组中某一元素， 并保持数组紧凑
function table.removeV(t, element)
	for i = 1, #t do
		if t[i] == element then
			remove(t, i)
			return
		end
	end
end

-- 获得 table 的元素个数
function table.count(t)
	local cnt = 0
	for k, v in pairs(t) do
		cnt = cnt + 1
	end
	return cnt
end

-- 浅拷贝
function table.scopy(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[k] = v
	end
	return rtn
end

-- 打印
function table.print(t)
	local dump = function ()
		local out = {}
		local write = function (value)
			out[#out + 1] = value
		end

		local indent = 0
		local format
		format = function(write, msg, indent)
			for k, v in pairs(msg) do
			  	write(srep(' ', indent))
		    	if type(v) == 'table' then
				    write(tostring(k) .. ': {\n')
				    format(write, v, indent+4)
				    write(srep(' ', indent))
				    write('}\n')
		    	else
		      		write(sformat('%s: %s\n', tostring(k), tostring(v)))
		    	end
			end
		end

		format(write, t, 0)
		return tconcat(out)
	end

	log.info(dump())
end