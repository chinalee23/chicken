-- 枚举
-- start: 起始索引，默认为1
-- local e = enum {
-- 	'a',
-- 	'b',
-- 	'c',
-- }
-- print(e.a, e.b, e.c)

function enum(tbl, start)
	start = start or 1
	local t = {}
	for i = 1, #tbl do
		t[tbl[i]] = start + i - 1
	end

	return t
end