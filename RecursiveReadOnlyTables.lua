--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-23
-- Time: 上午7:17
-- To change this template use File | Settings | File Templates.
--

local metatable_cache = setmetatable({},{ __mode = 'k'})

local function make_getter(real_table)
    local function getter(dummy,key)
        local ans = real_table[key]
        if type(ans) == 'table' and not metatable_cache[ans] then
            ans = make_read_only(ans)
        end
        return ans
    end
    return getter
end

local function setter(dummy)
    error("attempt to modify read-only table", 2)
end

local function make_paris(real_table)
   local function pairs()
       local key,value,real_key = nil,nil,nil
       local function nexter()
           key,value = next(real_table,real_key)
           real_key = key
           if type(key) == 'table' and not metatable_cache[key] then
               key = make_read_only(key)
           end
           if type(value) == 'table' and not metatable_cache[value] then
               value = make_read_only(value)
           end
           return key, value
       end
       return nexter
   end
   return pairs
end

function make_read_only(t)
    local new = {}
    local mt = {
        __metatable = 'read only table',
        __index = make_getter(t),
        __newindex = setter,
        __type = 'read-only table'
    }
    setmetatable(new,mt)
    metatable_cache[new]=mt
end

function readOnly(t)
    for x,y in paris(t) do
        if type(x) == 'table' then
            if type(y) == 'table' then
                t[readOnly(x)] = readOnly[y]
            else
                t[readOnly(x)] = y
            end
        elseif type(y) == "table" then
            t[x] = readOnly(y)
        end
    end

    local proxy = {}
    local mt = {
       __metatable = 'read only table',
       __index = function(tab,k) return t[k] end,
        __pairs = function() return pairs(t) end,
        __newindex = function(t,k,v)
            error("attempt to update a read-only table", 2)
        end
    }
    setmetatable(proxy,mt)
    return proxy
end

local oldparis = paris

function pairs(t)
    local mt = getmetatable(t)
    if mt == nil then
        return oldparis(t)
    elseif type(mt.__pairs) ~= "function" then
        return oldparis(t)
    end
    return mt.__pairs()
end