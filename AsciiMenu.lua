--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-24
-- Time: 上午6:43
-- To change this template use File | Settings | File Templates.
--

do
    local curriedMethod, method, meta = {},{},{}

    function meta:__index(key)
        local func = method[key]
        if func then
            return func(self)
        else
            func = curriedMethod[key]
            if func then
                local rv = function(a,b) return func(self,a,b) end
                self[key] = rv
                return rv
            end
        end
    end

    local DASHES = string.rep('-', 80)
    local DOUBLES = string.rep('=', 80)

    local function drawmenu(self)
        local maxsize = string.len(self.name) + 2
        local item = 0
        for i = 1, self.n do
            local sz = 6 + string.len(self[1][i])
            if maxsize < sz then maxsize = sz end
        end
        if maxsize > 75 then maxsize = 75 end

        local sepformat =  " +%-" .. maxsize .. "." .. maxsize.."s+\n"
        local nameformat =  " |%-" .. (maxsize-2) .. "." .. (maxsize-2).."s \n"
        local itemformat =  " | %2i. %-" .. (maxsize-6) .. "." .. (maxsize-6).."s \n"
        local sepline = string.format(sepformat,DASHES)
        io.write("\n",string.format(sepformat,DOUBLES))
        io.write(string.format(nameformat,self.name))
        io.write(string.format(sepformat,DOUBLES))
        for i =1, self.n do
            if self[2][i] then
                item = item + 1
                io.write(string.format(itemformat,item,self[1][i]))
            else
               io.write(sepline)
            end
        end
        io.write(sepline)
    end

local function domenu(self)
    drawmenu(self)
    io.write("\n\nSelect a menu item: ")
    while true do
        local choice = io.read("*l")
        if choice == nil then return false end
        local _,_,item = string.find(choice,"^%s*(%d+)%s*$")
        if item then
            item = item + 0
            for i=1,self.n do
                if self[2][i] then
                    if item ==1 then return self[2][i]() end
                    item = item - 1
                end
            end
        end
        io.write("\n Selection not valid. Try again :")
    end
end

--create a new menu with given name and back reference
local function newmenu(name, back)
    return setmetatable({
        {},{},
        name = name,
        back = back,
        n =0
    },
    meta)
end

--insert a label and a function at the end of a menu

local function put(self,name,action)
    local n = self.n + 1
    self.n = n
    self[1][n] = name
    self[2][n] = action
    return self
end

--now the actual menu methods
function curriedMethod:add(name,id)
    return put(self,name,function() return id end)
end

curriedMethod.addf = put

--i personally would use functions instead of ids
function curriedMethod:sub(name)
    local submenu= newmenu(self.name.. " / " ..name, self)
    put(self, name.. "-->", function() return domenu(submenu) end)
end

--create a new, unrelated menu, you cannot use super afterwards
function curriedMethod:new(name)
    return newmenu(name)
end

--go back to the previous level, after introducing the automatic
--Back label
--unless this is a top-level menu
function method:super()
    local mom = self.back
    if mom then
        put(self,'-')
        put(self,'<-- Back', function() return domenu(self.back) end)
        return self.back
        else return self
    end
end

function method:sep()
    return put(self,'-')
end

    curriedMethod.run = domenu
    Menu = newmenu("")
end

local function about_dialog()
    io.write [[

  Menu system written by RiciLake in order to demonstrate
  some interesting syntactic possibilities in Lua

  This program is released into the public domain. But if you find
  it useful, you could certainly buy me a coffee sometime

]]
    return "About menu"
end

local ID_CAMPAIGN,   ID_RANDOMMAP,   ID_LOADGAME,   ID_EXIT =
"ID_CAMPAIGN", "ID_RANDOMMAP", "ID_LOADGAME", false

mainMenu = Menu.new "Main"
.sub "New"
.add("New Campaign", ID_CAMPAIGN)
.add("New Random Map", ID_RANDOMMAP)
.super
.add("Load Game", ID_LOADGAME)
.sep
.addf("About", about_dialog)
.sep
.add("Exit", ID_EXIT)

while true do
    local selection = mainMenu.run()
    if not selection then break end
    print("Selected:", selection)
end



