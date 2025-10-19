sm = require('preload.sounds')
te = require('lib.tesound')

local function copyTable(t)
    if type(t) ~= "table" then return t end
    local new = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            new[k] = copyTable(v)
        else
            new[k] = v
        end
    end
    return new
end

local function compareTable(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end

    for k, v in pairs(a) do
        local bv = b[k]
        if type(v) == "table" and type(bv) == "table" then
            if not compareTable(v, bv) then
                return false
            end
        elseif v ~= bv then
            return false
        end
    end

    for k in pairs(b) do
        if a[k] == nil then return false end
    end

    return true
end

if not mod.sConfigState then
    mod.sConfigState = copyTable(mod.config.music)
end

if imgui.Button("Open CS Folder") then
    local path = os.getenv("APPDATA") .. "\\beatblock\\Mods\\customsounds\\customsounds"
    os.execute('start "" "' .. path .. '"')
end

imgui.NewLine()
imgui.Separator()
imgui.NewLine()

imgui.SetWindowFontScale(2)
imgui.Text("SFX Replacements")
imgui.SetWindowFontScale(1)

local customsounds = {
    sfx = {
        { label = "Barely", value = "barely", fallback = "assets/sfx/barely.ogg" },
        { label = "Block", value = "block", fallback = "assets/sfx/click.ogg" },
        { label = "Click", value = "click", fallback = "assets/sfx/click.ogg" },
        { label = "Hold", value = "hold", fallback = "assets/sfx/hold.ogg" },
        { label = "Hover", value = "hover", fallback = "assets/sfx/click.ogg" },
        { label = "Mine", value = "mine", fallback = "assets/sfx/mine.ogg" },
        { label = "Pause", value = "pause", fallback = "assets/sfx/pause.ogg" },
        { label = "Side", value = "side", fallback = "assets/sfx/click.ogg" },
        { label = "Tap", value = "tap", fallback = "assets/sfx/tap.ogg" },
        { label = "Miss", value = "miss", fallback = "assets/sfx/mine.ogg" }
    },
    music = {
        { label = "Menu Loop", value = "menuloop", fallback = "assets/music/menuloop.ogg" },
        { label = "Caution", value = "caution", fallback = "assets/music/caution.ogg" }
    }
}

-- local audioFiles = {sfx = {}, music = {}}

local audioFileExtensions = {"mp3", "ogg", "wav", "aac", "flac", "m4a", "wma", "opus"} -- no idea if all of these work, but whatevs

local function isAudio(fileName)
    local ext = fileName:match("^.+%.(.+)$") -- get text after last "."
    if not ext then return false end
    ext = ext:lower()
    for _, validExt in ipairs(audioFileExtensions) do
        if ext == validExt then
            return true
        end
    end
    return false
end

if imgui.BeginTabBar("sfxconfig") then
    for i = 1, #customsounds.sfx, 1 do    
        if imgui.BeginTabItem(customsounds.sfx[i].label .. "##sfxconfig") then
    
            local sounds = love.filesystem.getDirectoryItems("Mods/customsounds/customsounds/sfx/" .. customsounds.sfx[i].value)

            imgui.Text("Selected: " .. mod.config.sfx[customsounds.sfx[i].value]);

            if imgui.Button("Default##" .. customsounds.sfx[i].value) then
                print("Reset " .. customsounds.sfx[i].value .. " to default")

                mod.config.sfx[customsounds.sfx[i].value] = "default"

                sm:replaceSound(customsounds.sfx[i].value, customsounds.sfx[i].fallback) 
            end

            imgui.NewLine()

            for _, sound in ipairs(sounds) do
                if isAudio(sound) then
                    if imgui.Button(sound .. "##" .. customsounds.sfx[i].value) then
                        print(sound)
                    
                        mod.config.sfx[customsounds.sfx[i].value] = sound
                    
                        sm:replaceSound(customsounds.sfx[i].value, "Mods/customsounds/customsounds/sfx/" .. customsounds.sfx[i].value .. "/" .. sound)
                    end
                end
            end

            imgui.EndTabItem()
        end
    end

    imgui.EndTabBar()
end

imgui.NewLine()
imgui.NewLine()
imgui.NewLine()

imgui.SetWindowFontScale(2)
imgui.Text("Music Replacements")
imgui.SetWindowFontScale(1)

if imgui.BeginTabBar("mconfig") then
    for i = 1, #customsounds.music, 1 do
        if imgui.BeginTabItem(customsounds.music[i].label .. "##mconfig") then
    
            local sounds = love.filesystem.getDirectoryItems("Mods/customsounds/customsounds/music/" .. customsounds.music[i].value)

            imgui.Text("Selected: " .. mod.config.music[customsounds.music[i].value]);

            if imgui.Button("Default##" .. customsounds.music[i].value) then
                print("Reset " .. customsounds.music[i].value .. " to default")

                mod.config.music[customsounds.music[i].value] = "default"
            end

            imgui.NewLine()

            for _, sound in ipairs(sounds) do
                if isAudio(sound) then
                    if imgui.Button(sound .. "##" .. customsounds.music[i].value) then
                        print(sound)
                    
                        mod.config.music[customsounds.music[i].value] = sound
                    
                        --sounds:replaceSound(customsounds.music[i].value, "Mods/customsounds/customsounds/music/" .. customsounds.music[i].value .. "/" .. sound)
                    end
                end
            end

            if customsounds.music[i].value == "menuloop" then
                imgui.NewLine()

                mod.config.music.menuloopBPM = helpers.InputInt("BPM (default: 108)", (mod.config.music.menuloopBPM))
            end

            imgui.EndTabItem()
        end
    end
    imgui.EndTabBar()
end

imgui.NewLine()
imgui.Separator()
imgui.NewLine()

if not compareTable(mod.sConfigState, mod.config.music) then 
    imgui.TextColored({1, 0.35, 0, 1}, "MUSIC CHANGES WERE MADE. RESTART REQUIRED AFTER SAVING.")

    imgui.NewLine()
end