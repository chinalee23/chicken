-- string 扩展

function string.split(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end)
    return rt
end

function string.trim(s)
	return string.gsub(str, '^%s*(.-)%s*$', '%1')
end