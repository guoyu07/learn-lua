--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-24
-- Time: 下午9:30
-- To change this template use File | Settings | File Templates.
--


local struct_mt = {
   __call = function(s,t)
       local obj =t or {}
       local fields = s._fields
       for k,v in pairs(obj) do
           if not fields[k] then
               s._error_nf(nil,k)
            end
       end

       for k,v in pairs(fields) do
           if not obj[k] then
               obj[k] = v
           end
       end
       setmetatable(obj,s._mt)
       return obj
   end
}

struct = setmetatable({},{
    __index = function(tbl,sname)
--       so we create a new struct object with a name
        local s= {_name = sname }
--        and put the struct in the enclosing context
        _G[sname] = s
--        the not-found error
        s._error_nf = function(tbl,key)
            error("field " .. key .. " is not in " .. s._name)
        end
--        reading or writing an  undefined field of this struct is an error
        s._mt = {
            _name = s._name;
            __index=  s._error_nf;
            __newindex=  s._error_nf;
        }
--        the struct has a ctor
        setmetatable(s,struct_mt)
--        return a function that sets the struct's fields
        return function(t)
            s._fields = t
        end
    end
})


struct.Alice {
    x = 1;
    y = 2;
}

--And instantiated like so:

a = Alice {x = 10, y = 20 }
 a.x = 12
print(a.x)

