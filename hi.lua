--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-19
-- Time: 上午8:46
-- To change this template use File | Settings | File Templates.
--


function Point(_x, _y, _z)
    return function(fn) return fn(_x,_y,_z) end
end

function x(_x,_y,_z) return _x end
function y(_x,_y,_z) return _y end
function z(_x,_y,_z) return _z end

p1 = Point(1,2,4)

--print(p1(x))
--print(p1(z))
function vlength(_x,_y,_z)
    return math.sqrt(_x*_x+_y*_y+_z*_z)
end
--print(p1(vlength))

function subst_x(_x)
    return function(_,_y,_z) return Point(_x,_y,_z) end
end
function subst_y(_y)
    return function(_x,_,_z) return Point(_x,_y,_z) end
end
function subst_z(_z)
    return function(_x,_y,_) return Point(_x,_y,_z) end
end

p2 = p1(subst_x(43))
--p2(print)

function vadd(v2)
    return function(_x,_y,_z)
        return Point(_x+v2(x),_y+v2(y),_z+v2(z))
    end
end
function vsubstract(v2)
    return function(_x,_y,_z)
        return Point(_x-v2(x),_y-v2(y),_z-v2(z))
    end
end


function subtractPoint(x,y,z)
    return function(_x,_y,_z) return _x-x,_y-y,_z-z end
end

--p1(print)
--p1(vadd(p1))(print)
--p1(print)

centre = Point(0.5,0.5,0.5)

--centre(print)

tt = Point(p1(centre(subtractPoint)))
--tt(print)
tt = 'abadf'
--print(#tt)

function mutable(func)
   local currentfunc = func
    local function mutate(func, newfunc)
        local lastfunc = currentfunc
        currentfunc = function(...) return newfunc(lastfunc,...)end
    end
    local wrapper = function(...) return currentfunc(...) end
    return wrapper,mutate
end

local sqrt, mutate = mutable(math.sqrt)
print(sqrt(4));
--assert(sqrt(4) == 2)
--assert(sqrt(-4) ~= sqrt(-4))
mutate(sqrt,function(old,x) return x<0 and old(-x) ..'i' or old(x) end)
--assert(sqrt(4) == 2)
--assert(sqrt(-4) == "2i")
--print(sqrt(-4));

local t,mutate = mutable(function() end)
mutate(t,function(old,x,y) if x ==1 then return "first" else return old(x,y) end end)
mutate(t,function(old,x,y) if x ==2 then return "second" else return old(x,y) end end)
mutate(t,function(old,x,y) if x > 2 then return "large number" else return old(x,y) end end)
mutate(t,function(old,x,y) if y ~= 0 then return "off axis", math.sqrt(x^2+y^2) else return old(x,y) end end)
_,a = t(3,4)
--print(a)

local SET = function() end
local MUTATE = function() end

function mutable_helper(func,mutate)
    mutate(func, function(old_func,...)
   if select(1, ...) == SET then
       local k = select(2, ...)
       local v = select(3, ...)
       mutable(func,function(old_func,...)
           if select(1,...) ==k then return v
           else return old_func(...) end
       end)
   else
   return old_func(...)
       end
end)
    mutate(func,function(old_func,...)
        if select(1,...) == MUTATE then
           local new_func = select(2,...)
            mutate(func,function(old_func,...)
                return new_func(old_func,...)
            end)
        else
        return old_func(...)
        end
    end)
    return func
end

local t = mutable_helper(mutable(function() end))
t(MUTATE,function(old,...)
    local x = select(1,...)
    if(type(x) == 'number') and x>2 then return "large" else return old(...) end
end)
t(SET,1,'first')
t(SET,2,'second')
function enable_table_access()
    local mt = {
       __index = function(t,k) return t(k) end,
       __newindex = function(t,k,v) return t(SET,k,v)  end
    }
    debug.setmetatable(function() end,mt)
end

function T()  return mutable_helper(mutable(function() end)) end
local t = T();
t[1] = 'first'
t[2] = 'second'
print(t[1])
