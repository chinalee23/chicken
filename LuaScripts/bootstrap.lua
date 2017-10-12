local _M = module()

function update( ... )
	events.update()
end

function fixedUpdate( ... )
	events.fixedUpdate()
end

return _M