local args = {...}
local file = args[1]

local mon = peripheral.find("monitor")
if not mon then
    print("No monitor!")
    return
end

mon.setTextScale(0.5)

local w, h = mon.getSize()

local file = nil
local lines = {""}
local cx, cy = 1, 1 -- cursor position
local scroll = 1

-- ===== DRAW =====

local function draw()
    mon.clear()

    -- top bar
    mon.setCursorPos(1,1)
    mon.write("[SAVE]")

    mon.setCursorPos(10,1)
    mon.write("[EXIT]")

    if file then
        mon.setCursorPos(20,1)
        mon.write(file)
    end

    -- text area
    for i = 1, h-2 do
        local lineIndex = scroll + i - 1
        if lines[lineIndex] then
            mon.setCursorPos(1, i+1)
            mon.write(lines[lineIndex])
        end
    end

    -- cursor
    local drawY = cy - scroll + 2
    if drawY >= 2 and drawY <= h then
        mon.setCursorPos(cx, drawY)
        mon.setCursorBlink(true)
    else
        mon.setCursorBlink(false)
    end
end

-- ===== FILE =====

local function openFile(path)
    file = path
    lines = {}

    if fs.exists(path) then
        local f = fs.open(path, "r")
        while true do
            local l = f.readLine()
            if not l then break end
            table.insert(lines, l)
        end
        f.close()
    end

    if #lines == 0 then
        lines = {""}
    end

    cx, cy = 1, 1
    scroll = 1
end

local function saveFile()
    if not file then return end

    local f = fs.open(file, "w")
    for _, l in ipairs(lines) do
        f.writeLine(l)
    end
    f.close()
end

-- ===== INPUT =====

local function insertChar(c)
    local line = lines[cy]
    lines[cy] = line:sub(1, cx-1) .. c .. line:sub(cx)
    cx = cx + 1
end

local function newLine()
    local line = lines[cy]
    local before = line:sub(1, cx-1)
    local after = line:sub(cx)

    lines[cy] = before
    table.insert(lines, cy+1, after)

    cy = cy + 1
    cx = 1
end

local function backspace()
    if cx > 1 then
        local line = lines[cy]
        lines[cy] = line:sub(1, cx-2) .. line:sub(cx)
        cx = cx - 1
    elseif cy > 1 then
        local prev = lines[cy-1]
        cx = #prev + 1
        lines[cy-1] = prev .. lines[cy]
        table.remove(lines, cy)
        cy = cy - 1
    end
end

local function moveCursor(key)
    if key == keys.left then
        if cx > 1 then
            cx = cx - 1
        elseif cy > 1 then
            cy = cy - 1
            cx = #lines[cy] + 1
        end
    elseif key == keys.right then
        if cx <= #lines[cy] then
            cx = cx + 1
        elseif cy < #lines then
            cy = cy + 1
            cx = 1
        end
    elseif key == keys.up then
        if cy > 1 then
            cy = cy - 1
            cx = math.min(cx, #lines[cy]+1)
        end
    elseif key == keys.down then
        if cy < #lines then
            cy = cy + 1
            cx = math.min(cx, #lines[cy]+1)
        end
    end

    -- scroll
    if cy < scroll then scroll = cy end
    if cy > scroll + (h-3) then scroll = cy - (h-3) end
end

local function handleClick(x, y)
    -- SAVE
    if y == 1 and x <= 6 then
        saveFile()
        return
    end

    -- EXIT
    if y == 1 and x >= 10 and x <= 15 then
        return "exit"
    end

    -- cursor positioning
    local lineIndex = scroll + y - 2
    if lines[lineIndex] then
        cy = lineIndex
        cx = math.min(x, #lines[cy]+1)
    end
end

-- ===== MAIN =====

print("Enter file name:")
local name = read()
openFile(name)

while true do
    draw()

    local e, p1, p2, p3 = os.pullEvent()

    if e == "char" then
        insertChar(p1)
    elseif e == "key" then
        if p1 == keys.enter then
            newLine()
        elseif p1 == keys.backspace then
            backspace()
        else
            moveCursor(p1)
        end
    elseif e == "monitor_touch" then
        if handleClick(p2, p3) == "exit" then
            break
        end
    end
end

mon.setCursorBlink(false)
mon.clear()
