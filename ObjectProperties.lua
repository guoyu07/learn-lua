--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-19
-- Time: 上午10:04
-- To change this template use File | Settings | File Templates.
--
--Some object-orientated languages support properties, which appear like public data fields on objects but are really
--syntactic sugar accessor function (getter and setter ),In Lua it might look like this:
--
--obj.field = 123  -- same as obj:set_field(123)
--x = obj.field  -- same as obj:get_field()

local function make_proxy(class,priv,getters,setters,is_expose)
    setmetatable(priv,class)
    local fallback = is_expose and priv or class
    local index = getters and
            function(self,key)
                local func = getters[key]
                if func then return func(self) else return fallback[key] end
            end
            or fallback
    local newindex = setters and
            function(self,key,value)
                local func = setters[key]
                if func then return func(self,value)
                else rawset(self,key,value) end
            end
            or fallback
    local proxy_mt = {
       __index=index,
    __newindex=newindex,
        priv = priv
    }
    local self = setmetatable({},proxy_mt)
    return self
end

local Apple = {}
Apple.__index = Apple
function Apple:drop() return self.color .. " apple drop" end
local Apple_attribute_setters = {
   color = function(self,color)
       local priv = getmetatable(self).priv
       priv.color = string.upper(color)
   end
}

function Apple:new()
    local priv = { color="RED" }
    local self = make_proxy(Apple,priv,nil,Apple_attribute_setters,true)
    return self
end
--local a = Apple:new()
--s = a:drop()
--print(s)
--a.color = 'green'
--s = a:drop()
--print(s)

local T = {}
T.__index = T
local T_setters = {
   a = function(self,value)
       local priv = getmetatable(self).priv
       priv.a = value * 2
   end
}
local T_getters = {
    b = function(self,value)
        local priv = getmetatable(self).priv
        return priv.a + 1
    end
}
function T:hello()
    return 123
end
function T:new()
    return make_proxy(T,{a=5},T_getters,T_setters,true)
end

local t = T:new()
--print(t:hello())
--t.a = 10
--print(t.a)

array = {
   new = function(self,size)
       local o = {
           _size = size,
           _array = {}
       }
       for i = 1, o._size do
           o._array[i] = 0
       end
       setmetatable(o,self)
       return o
   end,
    size = function(self)
        return self._size
    end,
    get = function(self,i)
        return self._array[tonumber[i]]
    end,
    set = function(self,i,v)
        self._array[tonumber[i]] = tonumber(v)
    end,
    __index = function(self,key)
        return getmetatable(self)[key] or self:get(key)
    end,
    __newindex = function(self,i,v)
        self:set(i,v)
    end
}





