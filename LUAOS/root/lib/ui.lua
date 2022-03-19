--options
--  t=BUTTON
--      x
--      y
--      dx
--      dy
--      BG
--      FG
--      txt             text of button(wrapps,does not support /n, instead use string.rep(" ",options.dx))
--      onPress
--  t=TEXTBOX
--      x
--      y
--      dx
--      activeBG
--      activeFG
--      BG
--      FG
--      contextFG
--      context         the text to show when no text was entered (e.g. 'password:')
--      maxChar
--      input           the entered text(used internally)
--      active          whether textbox is selected(used internally)
--  t=DROPDOWN
--      x
--      y
--      dx
--      activeBG
--      activeFG
--      BG
--      FG
--      items
--      selected        the index of the selected item(used internally)
--      active          wether dropdown is shown(used internally)

UI = {}

---Draws a UI object onto the screen 
---@param options table @data of the object to draw
---@param display table @the display to draw object on(e.g. `term`)
---@param maxY number @the height of the UI to draw the object on
function UI:draw(options, display, maxY)
    if options.t == "button" then
        if options.BG then display.setBackgroundColor(options.BG) else display.setBackgroundColor(colors.black) end
        if options.FG then display.setTextColor(options.FG) else display.setTextColor(colors.white) end

        local wrappedTxt = {}
        local subStrStart = 1
        for i = 1,options.dy,1 do
            wrappedTxt[i] = string.sub(options.txt,subStrStart,i*options.dx)
            wrappedTxt[i] = wrappedTxt[i] .. string.rep(" ",options.dx-string.len(wrappedTxt[i]))
            subStrStart = i*options.dx+1
        end
        for i = 1,options.dy,1 do
            display.setCursorPos(options.x,options.y+i-1)
            display.write(wrappedTxt[i])
        end
    elseif options.t == "textBox" then
        if options.active == true then
            if options.activeBG then display.setBackgroundColor(options.activeBG) else display.setBackgroundColor(options.BG or colors.lightGray) end
            if options.activeFG then display.setTextColor(options.activeFG) else display.setTextColor(options.FG or colors.white) end
        else
            if options.BG then display.setBackgroundColor(options.BG) else display.setBackgroundColor(colors.grey) end
            if options.FG then display.setTextColor(options.FG) else display.setTextColor(colors.white) end
        end

        local text = ""
        if options.input == "" then
            if options.contextFG then display.setTextColor(options.contextFG) else display.setTextColor(colors.light_gray) end
            text = options.context..string.rep(" ",options.dx-string.len(options.context))
        else
            if string.len(options.input)+2 > options.dx then
                text = string.sub(options.input,string.len(options.input)-options.dx+2,string.len(options.input)+2) .. "_"
            else
                text = options.input .. "_" .. string.rep(" ",options.dx-string.len(options.input)-1)
            end
        end

        display.setCursorPos(options.x,options.y)
        display.write(text)
    elseif options.t == "dropdown" then
        if options.active == true then
            if options.activeBG then display.setBackgroundColor(options.activeBG) else display.setBackgroundColor(options.BG or colors.lightGray) end
            if options.activeFG then display.setBackgroundColor(options.activeFG) else display.setBackgroundColor(options.FG or colors.white) end
        else
            if options.BG then display.setBackgroundColor(options.BG) else display.setBackgroundColor(colors.grey) end
            if options.FG then display.setBackgroundColor(options.FG) else display.setBackgroundColor(colors.white) end
        end
        local text = {}
        local reverse = false
        if not options.active then text = options["items"][options.selected] .. string.rep(" ",options.dx-string.len(options["items"][options.selected])) else
            if maxY > options.y+#options.items then reverse = true end
            if not reverse then
                for i in pairs(options.items) do
                    text[i] = options["items"][i] .. string.rep(" ",options.dx-string.len(options["items"][i]))
                end
            else
                for i in pairs(options.items) do
                    text[#options.items-i+1] = options["items"][i] .. string.rep(" ",options.dx-string.len(options["items"][i]))
                end
            end
            for i in pairs(text) do
                display.setCursorPos(options.x,options.y+i-1)
                display.write(text[i])
            end
        end
    end
end

---updates the UI on an input event
---@param event table @a table of event data from `os.pullEvent()`
---@param _UI table @the UI to modify
---@param maxY number @the height of the UI to update
---@return table @the updated UI object
function UI:checkUI(event,_UI,maxY)
    local newUI = _UI
    if event[1] == "mouse_click" then
        if event[2] == 1 then
            for i in pairs(newUI) do
                local obj = newUI[i]
                if obj.t == "button" then
                    if event[3] >= obj.x and event[3] < obj.x+obj.dx and event[4] >= obj.y and event[4] < obj.y+obj.dy then
                        obj.onPress(i)
                    end
                elseif obj.t == "textBox" then
                    if event[3] >= obj.x and event[3] < obj.x+obj.dx and event[4] == obj.y then
                        obj.active = not obj.active
                    else obj.active = false end
                elseif obj.t == "dropdown" then
                    if not obj.active then
                        if event[3] >= obj.x and event[3] < obj.x+obj.dx and event[4] == obj.y then
                            obj.active = true
                        end
                    else
                        local reverse = false
                        if maxY > obj.y+#obj.items then reverse = true end
                        if (not reverse) and event[3] >= obj.x and event[3] < obj.x+obj.dx and event[4] >= obj.y and event[4] < obj.y+#obj.items then
                            obj.selected = event[4] - obj.y + 1
                        elseif reverse and event[3] >= obj.x and event[3] < obj.x+obj.dx and event[4] <= obj.y and event[4] > obj.y-#obj.items then
                            obj.selected = -(event[4] - obj.y + 1)
                        end
                    end
                end
            end
        end
    elseif event[1] == "char" then
        for i in pairs(newUI) do
            local obj = newUI[i]
            if obj.t == "textBox" then
                if obj.maxChar > string.len(obj.input) and obj.active then
                    obj.input = obj.input .. event[2]
                end
            end
        end
    elseif event[1] == "key" then
        for i in pairs(newUI) do
            local obj = newUI[i]
            if obj.t == "textBox" then
                if obj.active then
                    if event[2] == 259 then
                        obj.input = string.sub(obj.input,1,string.len(obj.input)-1)
                    end
                end
            end
        end
    end
    return newUI
end