--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-21
-- Time: 下午9:44
-- To change this template use File | Settings | File Templates.
--

local function Ordered()
    local key2lua, nextkey, firstkey = {},{},{}
    nextkey[nextkey] = firstkey

    local function onext(self, key)
        while key ~= nil do
            key = nextkey[key]
            local val = self[key]
            if val ~= nil then return key,val end
        end
    end

    local selfmeta = firstkey

    selfmeta.__nextkey = nextkey

    function selfmeta:__newindex(key,val)
        rawset(self,key,val)
        if nextkey[key] == nil then
            nextkey[nextkey[nextkey]] = key
            nextkey[nextkey] = key
        end
    end

    function selfmeta:__pairs() return onext, self, firstkey end
    return selfmetatable(key2val,selfmeta)
end

