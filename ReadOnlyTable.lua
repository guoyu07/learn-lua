--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-20
-- Time: 上午8:39
-- To change this template use File | Settings | File Templates.
--

function readonlytable(table)
    return setmetatable({},{
       __index = table,
        __newindex = function(table,key,value)
            error("Attempt to modify read-only table");
        end,
        __metatable = false
    })
end
