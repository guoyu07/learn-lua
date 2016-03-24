--
-- Created by IntelliJ IDEA.
-- User: zenus
-- Date: 16-3-24
-- Time: 下午10:31
-- To change this template use File | Settings | File Templates.
--

BaseObject = {
   super = nil,
   name = "Oject",
    new = function(class)
        local obj = {class = class }
        local meta = {
           __index = function(self,key) return class.methods[key] end
        }
        setmetatable(obj,meta)
        return obj
    end,
    methods = {classname = function(self) return(self.class.name) end},
    data = {}
}

function setclass(name, super)
    if (super == nil) then super = BaseObject end

    local class = {
       super = super;
        name = name;
        new = function(self,...)
            local arg = {...}
            local obj = super.new(self,"__CREATE_ONLY__");
            if(super.methods.init) then
                obj.init_super = super.methods.init
            end

            if (self.methods.init) then  obj.init_super = super.methods.init end

            if(self.methods.init) then
                if (tostring(arg[1]) ~= "__CREATE_ONLY__") then
                    obj.init = self.methods.init
                    if obj.init then
                        obj:init(table.unpack(arg))
                    end
                 end
            end
           return obj
       end,
        methods = {}
    }

    setmetatable(class,
        {
           __index = function(self,key) return self.super[key] end ,
            __call = function(self,...) return self.new(self,unpack(arg)) end
        }
    )

    setmetatable(class.methods,{
        __index = function(self,key) return class.super.methods[key] end
    })
    return class
end


cAnimal=setclass("Animal")

function cAnimal.methods:init(action, cutename)
    self.superaction = action
    self.supercutename = cutename
end

--==========================

cTiger=setclass("Tiger", cAnimal)

function cTiger.methods:init(cutename)
    self:init_super("HUNT (Tiger)", "Zoo Animal (Tiger)")
    self.action = "ROAR FOR ME!!"
    self.cutename = cutename
end

--==========================

Tiger1 = cAnimal:new("HUNT", "Zoo Animal")
Tiger2 = cTiger:new("Mr Grumpy")
Tiger3 = cTiger:new("Mr Hungry")

print("CLASSNAME FOR TIGER1 = ", Tiger1:classname())
print("CLASSNAME FOR TIGER2 = ", Tiger2:classname())
print("CLASSNAME FOR TIGER3 = ", Tiger3:classname())


