local mon = peripheral.find("monitor")
if not mon then error("No monitor") end

mon.setTextScale(0.5)

local apps = {
    {name="Notepad", x=2, y=3, file="/apps/notepad.lua"},
    {name="Files", x=2, y=6, file="/apps/files.lua"}
}

local function draw()
    mon.clear()
    mon.setCursorPos(1,1)
    mon.write("CC-OS v1")

    for _, app in ipairs(apps) do
        mon.setCursorPos(app.x, app.y)
        mon.write("["..app.name.."]")
    end
end

while true do
    draw()

    local e, side, x, y = os.pullEvent("monitor_touch")

    for _, app in ipairs(apps) do
        if y == app.y and x >= app.x and x <= app.x + #app.name + 1 then
            shell.run(app.file)
        end
    end
end