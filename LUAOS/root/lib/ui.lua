--#region class button
---@class button
---@field x number
---@field y number
---@field dx number
---@field dy number
---@field bgc number
---@field txtc number
---@field txt string
---@field onPress function
---@field onRelease function
---@field display table
local button = {}

---@param param table @list of parameters for button
---@return table @the button object
function button:new(param)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    for i,o in pairs(param) do
        self[i] = o
    end
    return obj
end

---draws the button
function button:draw()

end
--#endregion

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
