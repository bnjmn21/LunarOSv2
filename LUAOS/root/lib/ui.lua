--#region helper functions

---Wrapps text to boundraries
---@param text string @the string to wrap
---@param max number @the maximum characters per line
---@param respectWord boolean @whether to wrap using word boundaries
---@return table @list of the wrapped lines
local function wrap(text,max,respectWord)
    if not respectWord then
        local startSub = 1
        local wrapped = {}
        for i = 1,max,1 do
            wrapped[i] = string.sub(text,startSub,i*max)
            startSub = i*max+1
        end
        return wrapped
    else
        local wrapped = {}
        local words = {}
        local strEnd = false
        local startIndex = 0
        local i = 1
        while true do
            local space = string.find(text," ",startIndex)
            if not space then break end
            words[i] = string.sub(text, startIndex, space)
            startIndex = space+1
            i = i+1
        end
        i = 1
        for j in pairs(words) do
            if string.len(words[j]) > max then
                local lines = math.ceil(string.len(words[j])+math.ceil(string.len(words[j])/max)-1/max)
                for k = 1,lines,1 do
                    i = i+1
                    wrapped[i] = string.sub(words[j],k-1*max,k*max-1).."-"
                end
            else
                if string.len(wrapped[i]) + string.len(words[j]) + 1 <= max then
                    wrapped[i] = wrapped[i] .." ".. words[j]
                else
                    i = i+1
                    wrapped[i] = words[j]
                end
            end
        end
        for i in pairs(wrapped) do
            wrapped[i] = wrapped[i]+string.rep(" ",max-string.len(wrapped[i]))
        end
        return wrapped
    end
end

---Clears an Area
local function clearArea(x,y,dx,dy,bg,display)
    display.setBackgroundColor(bg)
    for i=1,dy,1 do
        display.setCursorPos(x,y+i-1)
        display.write(string.rep(" ",dx))
    end
end

--#endregion
--#region class button
---@class button
---@field x number
---@field y number
---@field dx number
---@field dy number
---@field bg number
---@field txtc number
---@field txt string
---@field display table
local button = {x=0,y=0,dx=1,dy=1,bg=colors.black,txtc=colors.white,txt=""}

---@param param table @list of parameters for button
---@return table @the button object
function button:new(param)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    for i,o in pairs(param) do
        self[i] = o or self[i]
    end
    return obj
end

---draws the button
---@param UI table @the UI
function button:draw(UI)
    local wrapped = wrap(self.txt,self.dx)
    self.display.setBackgroundColor(self.bg)
    self.display.setTextColor(self.txtc)
    for i in pairs(wrapped) do
        if i > self.dy then break end
        if self.y+UI.param.Yscroll+i-1 > UI.param.dy then break end
        UI.param.display.setCursorPos(self.x,UI.param.y+self.y+UI.param.Yscroll+i-1)
        UI.param.display.write(string.sub(wrapped[i],1,UI.param.dx-self.x))
    end
end

function button:event(UI, event)
    local pressed = false
    if event[1] == "mouse_click" then
        if event[3] >= self.x and event[3] < self.x+self.dx and event[4] >= self.y+UI.param.Yscroll and event[4] < self.y+self.dy+UI.param.Yscroll then
            pressed = true
        end
    end

    if pressed then
        os.queueEvent("appevent",{event="ui:button_pressed",button=event[2]})
    end
end
--#endregion

--#region class switch

---@class switch
---@field x number
---@field y number
---@field dx number
---@field state boolean
---@field txtOn string
---@field txtOff string
---@field type string
local switch = {x=1,y=1,dx=1,state=false,txtOn="on",txtOff="off",type="apple_switch-light_gray-lime"}

---@param param table @list of parameters for switch
---@return table @the switch object
function switch:new(param)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    for i,o in pairs(param) do
        self[i] = o or self[i]
    end
    return obj
end

function switch:draw(UI)
    if type == "apple_switch-light_gray-lime" then
        UI.param.display.setBackgroundColor(UI.param.bg)
        UI.param.display.setTextColor(self.state and colors.lime or colors.light_gray)
        UI.param.display.setCursorPos(self.x,self.y+UI.param.Yscroll)
        UI.param.display.write(string.rep("-",self.dx+1))
        UI.param.display.setBackgroundColor(colors.light_gray)
        UI.param.display.setTextColor(colors.white)
        UI.param.display.setCursorPos(self.x + self.state and self.dx or 0, self.y + UI.param.Yscroll)
        UI.param.display.write(" ")
    end
end

--#endregion

--#region class ui

---@class ui
---@field name string
---@field x number
---@field y number
---@field dx number
---@field dy number
---@field bg number
---@field Yscroll number
---@field display table
local ui = {name="app",x=1,y=1,dx=1,dy=1,bg=colors.black,Yscroll=0,display=term}

---@param param table @list of parameters for ui
---@param objs table @list of all objects in the ui
---@return table @the ui object
function ui:new(param, objs)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    for i,o in pairs(param) do
        self["param"][i] = o or self["param"][i]
    end
    for i,o in pairs(objs) do
        self["obj"][i] = o or self["obj"][i]
    end
    return obj
end

---draws the UI
function ui:draw()
    clearArea(self.x,self.y,self.dx,self.dy,self.bg,self.display)
    for _,o in pairs(self.objs) do
        o:draw(self)
    end
end

---checks for events
function ui:event(event)
    if event[1] == "mouse_click" then
        if not (event[3] >= self.param.x and event[3] < self.param.x+self.param.dx and event[4]+self.param.Yscroll >= self.param.y and event[4]+self.param.Yscroll < self.param.y+self.param.dy) then
            return
        end
    end
    for i in pairs(self.objs) do
        if self["objs"][i]:event(self,event) then return end
    end
end

--#endregion