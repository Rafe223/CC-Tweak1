local base = "https://raw.githubusercontent.com/Rafe223/CC-Tweak1/main"

local files = {
    ["startup.lua"] = "/startup.lua",
    ["os/desktop.lua"] = "/os/desktop.lua",
    ["apps/notepad.lua"] = "/apps/notepad.lua",
    ["apps/files.lua"] = "/apps/files.lua"
}

local function download(url, path)
    print("Downloading: " .. path)

    local response = http.get(url)
    if not response then
        print("Failed: " .. url)
        return
    end

    local data = response.readAll()
    response.close()

    local file = fs.open(path, "w")
    file.write(data)
    file.close()
end

-- tworzenie folderów
fs.makeDir("/os")
fs.makeDir("/apps")

-- pobieranie plików
for gitPath, localPath in pairs(files) do
    local url = base .. "/" .. gitPath
    download(url, localPath)
end

print("Install complete!")