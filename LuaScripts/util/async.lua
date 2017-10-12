local function async_to_sync(async_func, callback_pos)
    return function(...)
        local co = coroutine.running() or error ('this function must be run in coroutine')
        local rets
        local waiting = false
        local function cb_func(...)
            if waiting then
                coroutine.resume(co, ...)
            else
                rets = {...}
            end
        end
        local params = {...}
        table.insert(params, callback_pos or (#params + 1), cb_func)
        async_func(unpack(params))
        if rets == nil then
            waiting = true
            rets = {coroutine.yield()}
        end
        
        return unpack(rets)
    end
end

local function coroutine_call(func)
    return function(...)
        local co = coroutine.create(func)
        assert(coroutine.resume(co, ...))
    end
end

async = {
	to_sync = async_to_sync,
	call = coroutine_call,
}