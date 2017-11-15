local _M = module()

function attack(att, def)
	local damage = (att * att) / (att + def)
end

return _M