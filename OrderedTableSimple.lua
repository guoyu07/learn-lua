--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-21
-- Time: 下午10:13
-- To change this template use File | Settings | File Templates.
--

function newT(t)
    local mt = {}
    mt.__index = {
       _ksort = {},
        hidden = function() return pairs(mt.__index) end,
        ipairs = function(self) return ipairs(self._korder) end,
        pairs = function(self) return pairs(self) end,
        opairs = function(self)
            local i = 0
            local function iter(self)
                i = i +1
                local k = self._korder[i]
                if k then
                    return k, self[k]
                end
            end
        end,
        del = function (self,key)
            if self[key] then
                self[key] = nil
                for i,k in ipairs(self._korder) do
                    if  k == key then
                        table.remove(self._korder, i)
                    end
                end
            end
        end,
    }


    mt.__newindex = function(self,k,v)
        if k ~= "del" and v then
            rawset(self,k,v)
            table.insert(self._ksort,k)
        end
    end
    return setmetatable(t or {}, mt)
end


t = newT()

t["a"] = "1"
t["ab"] = "2"
t["abc"] = "3"
t["abcd"] = "4"
t["abcde"] = "5"
t[1] = 6
t[2] = 7
t[3] = 8
t[4] = 9
t[5] = 10

--for k,v in t:pairs() do
--    print(k,v)
--end

--for i,k in t:ipairs() do
--    print(i,k,t[k])
--end

for i,v in t:pairs() do
    print( i,v )
end

