--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-21
-- Time: 下午10:41
-- To change this template use File | Settings | File Templates.
--


local function noProxyNewIndex()
    error "Cannot set field in a proxy object"
end

function makeEncapsulator()

    local proxy2rep = setmetatable({},{__mode = 'kv'})

    local rep2proxy = {}

    local function genMethod(methods,k)

        local result = function(proxy,...)
            local rep = proxy2rep[proxy]
            return rep[k](rep,...)
        end
        methods[k] = result
        return result
    end

    local proxyIndex = setmetatable({}, {__index = genMethod})

    local function makeProxy(rep)
        local proxyMeta = {
           __metatable = "<protected proxy metatable>",
            rep = rep,
            __index =proxyIndex,
            __newindex = noProxyIndex
        }

        local proxy = setmetatable({},proxyMeta)
        proxy2rep[proxy] = rep
        rep2proxy [rep] = proxy
        return proxy
    end

    setmetatable(rep2proxy,{
       __mode = "kv",
        __metatable = "<protected>",
        __index = function(t,k)
            local proxy = makeProxy(k)
            t[k] = proxy
            return proxy
        end,
    })
    return rep2proxy, proxy2rep
end

local encapsulator = makeEncapsulator()


local foo = { hello =
function(self) print("Hello from " .. tostring(self)) end }
print("foo = " .. tostring(foo))

local efoo = encapsulator[foo]
print("efoo = " .. tostring(efoo))