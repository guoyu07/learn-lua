--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-20
-- Time: 上午8:44
-- To change this template use File | Settings | File Templates.
----
--function table.ordered(fcomp)
--    local newmetatable = {}
--    newmetatable.fcomp = fcomp
--    newmetatable.sorted = {}
--
--    function newmetatable.__newindex(t,key,value)
--        if type(key) == 'string' then
--            local fcomp = getmetatable(t).fcomp
--            local tsorted =  getmetatable(t).sorted
--            table.binsert(tsorted,key,fcomp)
--            rawset(t,key,value)
--        end
--    end
--
--    function newmetatable.__index(t,key)
--        if key == "n" then
--            return table.getn(getmetatable(t).sorted)
--        end
--        local realkey = getmetatable(t).sorted[key]
--        if realkey then
--            return realkey, rawget(t,realkey)
--        end
--    end
--
--    local newtable = {}
--
--    return setmetatable(newtable,newmetatable)
--end

function table.binsert(t,value,fcomp)

    local fcomp = fcomp or function(a,b) return a < b end

    local iStart, iEnd, iMid, iState = 1, #t, 1, 0

    while iStart <= iEnd do
        iMid= math.floor( (iStart+iEnd)/2 )

        if fcomp(value, t[iMid]) then
            iEnd = iMid - 1
            iState = 0
        else
            iStart = iMid + 1
            iState = 1
        end
    end

    local pos = iMid + iState
    table.insert(t, pos, value)
    return pos
end

function orderedPairs(t)
    return orderedNext, t
end
function orderedNext(t, i)
    i = i or 0
    i = i + 1
    local indexvalue = getmetatable(t)._tsorted[i]
    if indexvalue then
        return i, indexvalue[1], indexvalue[2]
    end
end

--t2 = table.ordered()
--print(t2)
--t2["A"] = 1
--t2.B = 2
--t2.C = 3
--t2.D = 4
--t2.E = 5
--t2.F = 6
--t2.G = 7
--t2.H = 8

--for k,v in pairs(t2) do
--    print(k,v)
--    end

--print("Normal interaction ordered table")

--t3  = table.concat(t2,';')
--print('-------------------------------------')
--
--for i, index,v in ordersPairs(t2) do
--    print(index,v)
--    end

function table.ordered(ireverse,stype)
    local newmetatable = {}
    if ireverse then
        newmetatable._ireverse = 1
        function newmetatable.fcomp(a,b) return b[1] < a[1] end
    else
        function newmetatable.fcomp(a,b) return a[1] < b[1] end
    end

    newmetatable.stype = stype or "string"

    function newmetatable.fcompvar(value)
        return value[1]
    end

    newmetatable._tsorted = {}

    function newmetatable.__newindex(t,key,value)
        if type(key) == getmetatable(t).stype then
            local fcomp = getmetatable(t).fcomp
            local fcompvar = getmetatable(t).fcompvar
            local tsorted = getmetatable(t)._tsorted
            local ireverse = getmetatable(t)._ireverse

            if value then
                local pos,_ = table.bfind(tsorted,key,fcompvar,ireverse)
                if pos then
                   tsorted[pos] = {key,value }
                else
                   table.binsert(tsorted,{key,value},fcomp)
                end
            else
                local pos, _ = table.bfind(tsorted,key,fcompvar,ireverse)
                if pos then
                    table.remove(tsorted,pos)
                end
            end
        end
    end

    function newmetatable.__index(t,key)
       if type(key) == getmetatable(t).stype then
           local fcomp = getmetatable(t).fcomp
           local fcompvar = getmetatable(t).fcompvar
           local tsorted = getmetatable(t)._tosorted
           local ireverse = getmetatable(t)._ireverse

           local pos, value = table.bfind(tsorted, key, fcompvar,ireverse)
           if pos then
               return value[2]
           end
       end
    end
    return setmetatable({},newmetatable)
end

function table.bfind(t,value,fcompval,reverse)
    fcompval = fcompval or function(value) return value end
    fcomp = function(a,b) return a < b end
    if reverse then
        fcomp = function(a,b) return a > b end
    end

    local iStart, iEnd, iMid = 1, #t, 1

    while(iStart <= iEnd) do

        iMid = math.floor((iStart + iEnd) / 2)

        local value2 = fcompval(t[iMid])

        if value == value2 then
            return iMid, t[iMid]
        end

        if fcomp(value,value2) then
            iEnd = iMid - 1
        else
            iStart = iMid + 1
        end
    end
end

t2= table.ordered( "reverse" )
t2["A"] = 1
t2.B = 2
t2.C = 3
t2.D = 4
t2.E = 5
t2.F = 6
t2.G = 7
t2.H = 8

for i,index,v in orderedPairs(t2) do
    print(index,v)
end

--speed testing
--build a n big inassociative table
--search it n2 times by hash clac used tim
n1 = 100000
n2 = 100000

t = {}
i0 = os.clock()
for i=1,n1 do
    t[tostring(i)] = i
end
local i1 = os.clock()
for i=1, n2 do
    local v = t[tostring(i)]
    print(v,i)
end

print("Normal test of inassociative table")
print("Time to add  "..n2.." Items: "..(i1-i0))
print(os.clock())
print(i1)
print(os.clock() - i1)
print("Time to search  "..n1.." Items: "..(os.clock() - i1))

i0 = os.clock()
local ts = {}
table.foreach(t, function(i,v) table.insert(ts, i,i) end)
table.sort(ts, function(a, b) return b[1] < a[1] end )
print("Normalsort time: "..(os.clock()-i0))

-- Speed test with a ordered table
t = table.ordered()
i0 = os.clock()
for i = 1, n1 do
    t[tostring(i)] = i
end
local i1 = os.clock()
for i = 1, n2 do
--    local v = t[tostring(i)]
    --print(v , i)
end
print("Normal test of Ordered inassociative table")
print("Time to add  "..n2.." Items: "..(i1-i0))
print(os.clock())
print(i1)
print("Time to search  "..n1.." Items: "..(os.clock() - i1))



