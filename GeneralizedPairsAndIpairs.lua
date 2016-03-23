--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-23
-- Time: 下午10:01
-- To change this template use File | Settings | File Templates.
--

function tnext(t,o)
    local i,v

    if o then
        local r = t
        while not rawget(r,o) do
            local m = getmetatable(r)
            r = m and m.__index
            assert(type(r) == "table", 'key not in table')
        end

--        grab the next non-shadowed index

        local s
--        start with the current index
        i = o
        repeat
--            get next real index
            i,v = next(r,i)
            while (i==nil) do
                local m = getmetatable(r)
                r = m and m.__index
                if (r==nil) then return nil,nil end
                assert(type(r) == "table", "__index must be table or nil")
                i,v = next(r)
            end
--            find the next index's level
            s = t
            while not rawget(s,i) do
                local m = getmetatable(s)
                s = m and m.__index
            end
        until(r == s)
        return i,v
    else

        while t do
            i,v = next(t)
            if i then break end
            local m = getmetatable(t)
            t = m and m.__index
            assert(t == nil or type(t) == "table", "index must be table")
        end
        return i,v
    end
end

t = {a=111,b=222,c=333}
u = {a=123,d=444 }
setmetatable(t,{__index=u})
for i,v in tnext, t  do print(i,v) end


