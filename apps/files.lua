local mon = peripheral.find("monitor")
mon.setTextScale(0.5)

local path = "/"

while true do
    mon.clear()
    mon.setCursorPos(1,1)
    mon.write("Files: "..path)

    local files = fs.list(path)

    for i, f in ipairs(files) do
        mon.setCursorPos(1, i+2)
        mon.write(i..": "..f)
    end

    local e, s, x, y = os.pullEvent("monitor_touch")

    local index = y - 2
    if files[index] then
        local full = fs.combine(path, files[index])

        if fs.isDir(full) then
            path = full
        else
            shell.run("/apps/notepad.lua", full)
        end
    end

    -- klik góry = powrót
    if y == 1 then break end
end