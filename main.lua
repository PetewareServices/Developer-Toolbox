--[[
PLEASE READ - IMPORTANT

(C) 2026 Peteware
This project is part of Developer-Toolbox, an open-sourced debugging tool for roblox.

Licensed under the MIT License.  
See the full license at:  
https://opensource.org/licenses/MIT

**Attribution required:** You must give proper credit to Peteware when using or redistributing this project or its derivatives.

This software is provided "AS IS" without warranties of any kind.  
Violations of license terms may result in legal action.

Thank you for respecting the license and supporting open source software!

Peteware Development Team
]]

--// Loading Handler
if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait()
end

--// Settings Detection
local Settings = ... or {
    ["Owner"] = "Unknown",
    ["Build"] = "Roblox",
    ["Theme"] = "Default"
}

local repo_owner = Settings["Owner"]
local build = Settings["Build"]
local theme = Settings["Theme"]

--// Local References
local game = game
local PlaceId = game.PlaceId
local JobId = game.JobId
local HttpGet = game.HttpGet
local HttpGetAsync = game.HttpGetAsync
local GetService = game.GetService
local GetDescendants = game.GetDescendants
local Instance = Instance
local InstanceNew = Instance.new
local task = task
local taskwait = task.wait
local taskdelay = task.delay
local table = table
local tablefind = table.find
local tableconcat = table.concat
local tablecreate = table.create
local os = os
local osclock = os.clock
local osdate = os.date
local string = string
local stringrep = string.rep
local stringformat = string.format
local stringsub = string.sub
local stringgsub = string.gsub
local stringfind = string.find
local stringmatch = string.match
local stringchar = string.char
local coroutine = coroutine
local coroutinewrap = coroutine.wrap
local coroutineyield = coroutine.yield
local Enum = Enum
local TeleportState = Enum.TeleportState
local type = type
local assert = assert
local typeof = typeof
local pcall = pcall
local pairs = pairs
local ipairs = ipairs
local print = print
local tostring = tostring
local warn = warn
local setmetatable = setmetatable
local rawset = rawset
local loadstring = loadstring or load

--// CloneRef Function Initialisation
local cloneref = (type(cloneref) == "function" and cloneref) or (type(clonereference) == "function" and clonereference) or function(...)
    return ...
end

--// Executing Handler
local global_env = type(getgenv) == "function" and getgenv() or shared
local original_state = global_env["Developer Toolbox"]

if original_state and original_state.Main and original_state.Main.Executing then
    if original_state.Main.Supported then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Developer Toolbox",
            Text = "Already Loading. Please Wait!",
            Icon = "rbxassetid://108052242103510",
            Duration = 3.5
        })
    else
        local error_sound = InstanceNew("Sound")
        error_sound.Name = "PetewareErrorNotification"
        error_sound.SoundId = "rbxassetid://9066167010"
        error_sound.Volume = 1
        error_sound.Archivable = false
        error_sound.Parent = sound_service

        error_sound:Play()
        error_sound.Ended:Once(function()
            error_sound:Destroy()
        end)

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Developer Toolbox",
            Text = "Incompatible Exploit. Your exploit does not support the developer toolbox",
            Icon = "rbxassetid://108052242103510",
            Duration = duration or 3.5
        })
    end

    return
end

local state
local function ReactiveTable(tbl, root)
    tbl = type(tbl) == "table" and tbl or {}
    root = type(root) == "table" and root or tbl

    return setmetatable(tbl, {
        __index = function(t, key)
            local value = rawget(t, key)
            if type(value) == "table" then
                value = ReactiveTable(value, root)
                rawset(t, key, value)
            end
            return value
        end,

        __newindex = function(t, key, value)
            rawset(t, key, value)
            global_env["Developer Toolbox"] = root
        end
    })
end

state = ReactiveTable(original_state)
state.Main = (type(state.Main) == "table" and state.Main) or {["Executing"] = true}
state.CachedData = (type(state.CachedData) == "table" and state.CachedData) or {["Hydroxide"] = {}}
local MainState = state.Main
local CachedData = state.CachedData

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Developer Toolbox",
    Text = "Developers Toolbox Loading! Please wait...",
    Icon = "rbxassetid://108052242103510",
    Duration = 3.5
})

--// Error Handling
local yielding = false
local error_yielded = false
local loadstring_event = InstanceNew("BindableEvent")

if MainState.ErrorScheduled == nil then
    MainState.ErrorScheduled = true
    
    loadstring_event.Event:Connect(function()
        if loadstring_event then
            loadstring_event:Destroy()
        end
        
        MainState.ErrorScheduled = nil
        
        while yielding do
            error_yielded = true
            taskwait()
        end
        
        if error_yielded then
            taskwait(4)
        end
        
        if MainState.Executing then
            MainState.Executing = nil
            
            if cancel_toolbox_loading then
                return
            end
            
            local error_sound = InstanceNew("Sound")
            error_sound.Name = "PetewareErrorNotification"
            error_sound.SoundId = "rbxassetid://9066167010"
            error_sound.Volume = 1
            error_sound.Archivable = false
            error_sound.Parent = GetService(game, "SoundService")
        
            pcall(function() 
                error_sound:Play()
                error_sound.Ended:Once(function()
                    error_sound:Destroy()
                end)
            end)
        
            GetService(game, "StarterGui"):SetCore("SendNotification", {
                Title = "Developer Toolbox",
                Text = "An error has occured while loading the developer toolbox, Please try again. If this problem persists please report this to bug reports forum in the Peteware discord server.",
                Icon = "rbxassetid://108052242103510",
                Duration = 4.5
            })
        end
    end)
end

--// Incompatible Exploit Handling
if MainState.Supported == nil then
    local required_functions = {
        ["makefolder"] = type(makefolder) == "function" and makefolder or "nil",
        ["isfolder"] = type(isfolder) == "function" and isfolder or "nil",
        ["writefile"] = type(writefile) == "function" and writefile or "nil",
        ["isfile"] = type(isfile) == "function" and isfile or "nil",
        ["readfile"] = type(readfile) == "function" and readfile or "nil",
        ["loadstring"] = type(loadstring) == "function" and loadstring or "nil"
    }

    local core_access, core_gui_object = pcall(function()
        return cloneref(game:GetService("CoreGui"))
    end)

    if not core_access or typeof(core_gui_object) ~= "Instance" then
        local error_sound = InstanceNew("Sound")
        error_sound.Name = "PetewareErrorNotification"
        error_sound.SoundId = "rbxassetid://9066167010"
        error_sound.Volume = 1
        error_sound.Archivable = false
        error_sound.Parent = sound_service

        error_sound:Play()
        error_sound.Ended:Once(function()
            error_sound:Destroy()
        end)

        GetService(game, "StarterGui"):SetCore("SendNotification", {
            Title = "Developer Toolbox",
            Text = "Incompatible Exploit. Your exploit does not support the developer toolbox (missing " .. tostring(func_name) .. ")",
            Icon = bell_ring,
            Duration = duration or 3.5
        })

        MainState.Supported = false
        return
    end

    for func_name, func in pairs(required_functions) do
        if type(func) ~= "function" then
            local error_sound = InstanceNew("Sound")
            error_sound.Name = "PetewareErrorNotification"
            error_sound.SoundId = "rbxassetid://9066167010"
            error_sound.Volume = 1
            error_sound.Archivable = false
            error_sound.Parent = sound_service

            error_sound:Play()
            error_sound.Ended:Once(function()
                error_sound:Destroy()
            end)

            GetService(game, "StarterGui"):SetCore("SendNotification", {
                Title = "Developer Toolbox",
                Text = "Incompatible Exploit. Your exploit does not support the developer toolbox (missing " .. tostring(func_name) .. ")",
                Icon = bell_ring,
                Duration = duration or 3.5
            })

            MainState.Supported = false
            return
        end
    end

    MainState.Supported = true
end

--// Data Initialiser
local main_folder = "Peteware"
local toolbox_folder = main_folder .. "/Developer-Toolbox"
local assets_folder = toolbox_folder .. "/Assets"
local audios_folder = assets_folder .. "/Audios"
local images_folder = assets_folder .. "/Images"

local bell_ring_png = images_folder .. "/bell-ring.png"
local bell_ring_mp3 = audios_folder .. "/bell-ring.mp3"

--// Data Loader
local toolbox_directory = "https://raw.githubusercontent.com/" .. repo_owner .. "/Developer-Toolbox/refs/heads/main/"
local backups_directory = toolbox_directory .. "Backups/"
local assets_directory = toolbox_directory .. "Assets/"
local audios_directory = assets_directory .. "Audios/"
local images_directory = assets_directory .. "Images/"

local backups = {
    "Wizard-Backup"
}

local audios = {
    "bell-ring"
}

local images = {
    "bell-ring"
}

local loaded_audios = {}
local loaded_images = {}

yielding = true
loadstring_event:Fire()

for _, backup in pairs(backups) do
    local backup_name = stringgsub(backup, "-Backup", "")
    if type(CachedData[backup_name]) == "function" then
        continue
    end

    local success, loaded_backup = pcall(function()
        return loadstring(HttpGet(game, backups_directory .. backup .. ".lua"))
    end)
    
    if not success or not loaded_backup then
        print("failed:", backup_name)
        warn(loaded_backup)
        yielding = false
        return
    end
    
    CachedData[backup_name] = loaded_backup
end

for _, audio in pairs(audios) do
    if not isfile(audios_folder .. "/" .. audio .. ".mp3") then
        local success, loaded_audio = pcall(function()
            return HttpGet(game, audios_directory .. audio .. ".mp3")
        end)
    
        if not success or not loaded_audio then
            yielding = false
            return
        end
    
        loaded_audios[audio] = loaded_audio
    end
end

for _, image in pairs(images) do
    if not isfile(images_folder .. "/" .. image .. ".png") then
        local success, loaded_image = pcall(function()
            return HttpGet(game, images_directory .. image .. ".png")
        end)
    
        if not success or not loaded_image then
            yielding = false
            return
        end
    
        loaded_images[image] = loaded_image
    end
end

yielding = false

--// Services & Setup
local gethui = type(gethui) == "function" and gethui or function(...)
    return cloneref(game:GetService("CoreGui"))
end

local fireproximityprompt = type(fireproximityprompt) == "function" and fireproximityprompt or function(proximity_prompt)
    assert(typeof(proximity_prompt) == "Instance", stringformat("bad argument #1 to 'fireproximityprompt' (Instance expected, got %s)", typeof(proximity_prompt)))
    assert(proximity_prompt.ClassName == "ProximityPrompt", stringformat("bad argument #1 to 'fireproximityprompt' (ProximityPrompt expected, got %s)", proximity_prompt.ClassName))
    
    local modifying_properties = {
        "HoldDuration",
        "MaxActivationDistance",
        "Enabled",
        "RequiresLineOfSight"
    }

    local original_values = {}

    for index, property in pairs(modifying_properties) do
        original_values[property] = proximity_prompt[property]
        
        if index == 1 then
            proximity_prompt[property] = 0
        elseif index == 2 then
            proximity_prompt[property] = math.huge
        elseif index == 3 then
            proximity_prompt[property] = true
        else
            proximity_prompt[property] = false
        end
    end

    proximity_prompt:InputHoldBegin()
    taskwait()
    proximity_prompt:InputHoldEnd()

    for property, value in pairs(original_values) do
        proximity_prompt[property] = value
    end
end

local customasset = getcustomasset or getsynasset
local makefolder = makefolder
local isfolder = isfolder
local writefile = writefile
local isfile = isfile
local readfile = readfile
local delfile = delfile
local listfiles = listfiles
local httprequest = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
local queueteleport = queueonteleport or queue_on_teleport or ((syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
local identifyexecutor = identifyexecutor
local getthreadcontext = getthreadcontext

local loadfile = type(loadfile) == "function" and loadfile or function(file)
    return loadstring(readfile(file))
end

local player = cloneref(GetService(game, "Players").LocalPlayer)
local starter_gui = cloneref(GetService(game, "StarterGui"))
local teleport_service = cloneref(GetService(game, "TeleportService"))
local http_service = cloneref(GetService(game, "HttpService"))
local run_service = cloneref(GetService(game, "RunService"))
local user_input_service = cloneref(GetService(game, "UserInputService"))
local sound_service = cloneref(GetService(game, "SoundService"))
local proximity_prompt_service = cloneref(GetService(game, "ProximityPromptService"))

--// Data Handler
if not isfolder(main_folder) then
    makefolder(main_folder)
end

if not isfolder(toolbox_folder) then
    makefolder(toolbox_folder)
end

if not isfolder(assets_folder) then
    makefolder(assets_folder)
end

if not isfolder(audios_folder) then
    makefolder(audios_folder)
end

if not isfolder(images_folder) then
    makefolder(images_folder)
end

if not isfile(bell_ring_png) then
    writefile(bell_ring_png, loaded_images["bell-ring"])
end

if not isfile(bell_ring_mp3) then
    writefile(bell_ring_mp3, loaded_audios["bell-ring"])
end

--// Notification Sender
local notification_sound = InstanceNew("Sound", sound_service)
notification_sound.Name = "PetewareNotification"
notification_sound.SoundId = (customasset and bell_ring_mp3 and customasset(bell_ring_mp3)) or "rbxassetid://2502368191"
notification_sound.Volume = 1
notification_sound.Archivable = false
    
notification_sound.Loaded:Wait()

local notification_sounds = true
local bell_ring_asset = (customasset and bell_ring_png and customasset(bell_ring_png)) or "rbxassetid://108052242103510"

local function Notify(text, duration)
    if notification_sound and notification_sounds then
        notification_sound:Play()
    end
    
    starter_gui:SetCore("SendNotification", {
        Title = "Developer Toolbox",
        Text = text or "Text Content not specified.",
        Icon = bell_ring_asset,
        Duration = duration or 3.5
    })
end

local OldNotify = Notify

local function InteractiveNotify(options, yield)
    if notification_sound and notification_sounds then
        notification_sound:Play()
    end
    
    local bindable = InstanceNew("BindableFunction")
    local response_event = InstanceNew("BindableEvent")

    local text = options.Text or "Are you sure?"
    local duration = (yield and 1e9) or options.Duration or 3.5
    local button1 = options.Button1 or "Yes"
    local button2 = options.Button2 or "No"
    local callback = options.Callback

    bindable.OnInvoke = function(value)
        if callback then
            callback(value)
        end
        
        response_event:Fire(value)
        
        if bindable then
            bindable:Destroy()
        end
        
        if response_event then
            response_event:Destroy()
        end
        
        yielding = false
    end

    starter_gui:SetCore("SendNotification", {
        Title = "Developer Toolbox",
        Text = text,
        Icon = bell_ring_asset,
        Duration = duration,
        Button1 = button1,
        Button2 = button2,
        Callback = bindable
    })

    taskdelay(duration, function()
        if bindable then
            bindable:Destroy()
        end
        
        if response_event then
            response_event:Destroy()
        end
    end)
    
    if yield then
        yielding = true
        return response_event.Event:Wait()
    end
end

local optional_functions = {
    customasset,
    makefolder,
    isfolder,
    writefile,
    delfile,
    isfile,
    readfile,
    loadfile,
    listfiles,
    loadstring,
    httprequest,
    queueteleport,
    identifyexecutor,
    getthreadcontext
}

local compatibility_count = 0
for _, func in pairs(optional_functions) do
    if func then
        compatibility_count = compatibility_count + 1
    end
end

local compatibility_percentage = (compatibility_count / #optional_functions) * 100

if compatibility_percentage == 100 then
    Notify(stringformat("Your executor is %.0f%% compatible. All toolbox features should work as expected.", compatibility_percentage), 4)
else
    Notify(stringformat("Your executor is %.0f%% compatible. Some toolbox features may not be compatible with this executor.", compatibility_percentage), 4)
end
    
--// Basic Device Detection
local device
if user_input_service.KeyboardEnabled and user_input_service.MouseEnabled then
    device = "PC"
else
    device = "Mobile"
end

--// Server Rejoin
local function RejoinServer()
    Notify("Attempting to Rejoin Server")
    taskdelay(1, function()
        teleport_service:TeleportToPlaceInstance(PlaceId, JobId)
    end)
end

--// Server Hop
local server_hop_data = toolbox_folder .. "/server-hop-data-temp.json"

local server_ids = {}
local found_any_servers = ""
local actual_hour = osdate("!*t").hour

if isfile(server_hop_data) then
    server_ids = http_service:JSONDecode(readfile(server_hop_data))
end

if type(server_ids) ~= "table" or #server_ids == 0 then
    server_ids = { actual_hour }
    writefile(server_hop_data, http_service:JSONEncode(server_ids))
end

local function AttemptServerHop()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

    if found_any_servers ~= "" then
        url = url .. "&cursor=" .. found_any_servers
    end

    local success, site = pcall(function()
        return http_service:JSONDecode(HttpGet(game, url))
    end)

    if not success or not site or not site.data then
        return
    end

    if site.nextPageCursor then
        found_any_servers = site.nextPageCursor
    end

    for _, data in pairs(site.data) do
        if data.playing < data.maxPlayers then
            local server_id = tostring(data.id)
            local can_server_hop = true

            for i, existing in pairs(server_ids) do
                if i == 1 and existing ~= actual_hour then
                    if delfile then
                        delfile(server_hop_data)
                    end
                    server_ids = { actual_hour }
                    break
                end

                if server_id == tostring(existing) then
                    can_server_hop = false
                    break
                end
            end

            if can_server_hop then
                server_ids[#server_ids + 1] = server_id
                writefile(server_hop_data, http_service:JSONEncode(server_ids))
                teleport_service:TeleportToPlaceInstance(PlaceId, server_id)
                taskwait(4)
                return
            end
        end
    end
end

local function ServerHop()
    Notify("Attempting to Server Hop")

    while taskwait(1) do
        pcall(AttemptServerHop)

        if found_any_servers ~= "" then
            pcall(AttemptServerHop)
        end
    end
end

local function OpenDevConsole()
    starter_gui:SetCore("DevConsoleVisible", true) 
end

--// Queue on Teleport
local execute_on_teleport = true -- set to false if you dont want execution on server hop / rejoin

local valid_teleport_states = {
    TeleportState.Started,
    TeleportState.InProgress,
    TeleportState.WaitingForServer
}

if queueteleport and type(queueteleport) == "function" and execute_on_teleport and not MainState.QueueOnTeleport then
    MainState.QueueOnTeleport = true
    player.OnTeleport:Connect(function(state)
        if tablefind(valid_teleport_states, state) and MainState.QueueOnTeleport and queueteleport then
            queueteleport('loadstring(game:HttpGet("' .. toolbox_directory .. '/main.lua"))()')
        end
    end)
elseif not queueteleport or type(queueteleport) ~= "function" then
    Notify("Incompatible Exploit. Your exploit does not support execute on teleport (missing queueteleport)")
end

--// Instance Scanner
local arrow = stringchar(0xE2, 0x86, 0x92)

local show_properties = {
    -- Value containers
    IntValue = "Value",
    StringValue = "Value",
    BoolValue = "Value",
    NumberValue = "Value",
    Color3Value = "Value",
    Vector3Value = "Value",
    CFrameValue = "Value",
    ObjectValue = "Value",

    -- Common parts
    Part = "Transparency",        -- useful to detect invisible parts
    Model = "Parent",
    UnionOperation = "Transparency",
    Decal = "Texture",            
    Texture = "Texture",

    -- Characters and Gameplay
    Humanoid = "DisplayName",
    Tool = "ToolTip",
    Animation = "AnimationId",
    AnimationTrack = "Animation",

    -- Sounds and Effects
    Sound = "SoundId",
    ParticleEmitter = "Enabled",
}

local found_classes = {}
local order_list = {}
local in_show_props = nil
local property = nil

--// Addons Handler
local addons_folder = toolbox_folder .. "/Addons"

if not isfolder(addons_folder) then
    makefolder(addons_folder)
end

local addon_name
local addon_script
local selected_addon
local addon_dropdown

local function FetchAddonList()
    local files = listfiles(addons_folder)
    local list = tablecreate(#files)

    for _, path in pairs(files) do
        local filename = stringmatch(path, "[^/\\]+$") or path 
        filename = stringgsub(filename, "%.lua$", "")
        list[#list + 1] = filename
    end

    return list
end

local function RemoveFromTable(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            tbl[i] = tbl[#tbl]
            tbl[#tbl] = nil
            return
        end
    end

    return
end

local addon_list = FetchAddonList()

--// Instant Proximity Prompts
local proximity_prompt_conn

--// Executor Statistics
local platform = user_input_service:GetPlatform()
if platform == Enum.Platform.OSX then
    platform = "MacOS"
else
    platform = platform.Name
end

local executor_name = identifyexecutor and identifyexecutor() or "Unknown"
local executor_level = getthreadcontext and getthreadcontext() or "Unknown"
local executor_permissions = "Unknown"

if executor_level == 0 then
    executor_permissions = "None"
elseif executor_level == 1 then
    executor_permissions = "Plugin, RobloxPlace, LocalUser"
elseif executor_level == 2 then
    executor_permissions = "None"
elseif executor_level == 3 then
    executor_permissions = "RobloxPlace"
elseif executor_level == 4 then
    executor_permissions = "Plugin, RobloxPlace, LocalUser, RobloxScript"
elseif executor_level == 5 then
    executor_permissions = "Plugin, RobloxPlace, LocalUser"
elseif executor_level == 6 then
    if run_service:IsStudio() then
        executor_permissions = "Plugin (studio build)"
    else
        executor_permissions = "All permissions (non-studio build)"
    end
elseif executor_level == 7 then
    executor_permissions = "All permissions"
elseif executor_level == 8 then
    executor_permissions = "RobloxPlace, WritePlayer, RobloxScript"
else
    if type(executor_level) == "number" then
        executor_permissions = "None, plus an assertion failure"
    end
end

local function DumpTable(tbl, root_name)
    assert(type(tbl) == "table", stringformat("bad argument to #1 'DumpTable' (table expected, got %s)", type(tbl)))
    local global_path = {}
    local names = {}
    names[tbl] = root_name or "root"
    global_path[tbl] = true

    local function BuildTable(t, base_indent, extra_indent)
        if global_path[t] then
            return {stringrep(" ", base_indent + extra_indent).. "[Cyclic Reference: " .. (names[t] or "unknown") .. "]"}
        end

        global_path[t] = true
        local buffer = {}
        local is_empty = true

        for k, v in pairs(t) do
            is_empty = false
            local prefix = stringrep(" ", base_indent + extra_indent)
            local key_str = "[" .. tostring(k) .. "]"

            if type(v) == "table" then
                if not names[v] then
                    names[v] = (names[t] or "root") .. "[" .. tostring(k) .. "]"
                end

                local inner = BuildTable(v, base_indent, extra_indent + 4)

                if #inner == 1 and stringfind(inner[1], "%[Cyclic Reference") then
                    buffer[#buffer + 1] = prefix .. key_str .. " = " .. stringgsub(inner[1], "^%s*", "")
                elseif #inner == 0 then
                    buffer[#buffer + 1] = prefix .. key_str .. " = {}"
                else
                    buffer[#buffer + 1] = prefix .. key_str .. " = {"
                    for _, line in ipairs(inner) do
                        buffer[#buffer + 1] = line
                    end
                    buffer[#buffer + 1] = prefix .. "}"
                end
            else
                buffer[#buffer + 1] = prefix .. key_str .. " = " .. tostring(v)
            end
        end

        global_path[t] = nil
        return is_empty and {} or buffer
    end

    for k, v in pairs(tbl) do
        local key_str = "[" .. tostring(k) .. "]"

        if type(v) == "table" then
            if not names[v] then
                names[v] = names[tbl] .. "[" .. tostring(k) .. "]"
            end

            local inner = BuildTable(v, 12, 4)
            local buffer = {}

            if #inner == 0 then
                buffer[#buffer + 1] = key_str .. " = {}"
            else
                buffer[#buffer + 1] = key_str .. " = {"
                for _, line in ipairs(inner) do
                    buffer[#buffer + 1] = line
                end
                buffer[#buffer + 1] = stringrep(" ", 12) .. "}"
            end

            warn(tableconcat(buffer, "\n"))
        else
            warn(key_str .. " = " .. tostring(v))
        end
    end
end

local function FetchExecutorInfo()
    OpenDevConsole()
    print("Device:", platform)    
    print("Executor:", executor_name)
    print("Executor Level:", executor_level)
    print("Executor Permissions:", executor_permissions)
    
    print("Executor Environment:")
    DumpTable(global_env, "Environment")
end

--// Main UI
local WizardLibrary = CachedData["Wizard"](theme)

local LibraryObject = WizardLibrary.Object

local DeveloperToolbox = WizardLibrary:NewWindow("Developer Toolbox")

local Tools = DeveloperToolbox:NewSection("Tools")

Tools:CreateButton("Infinite Yield", function()
    if type(CachedData.InfiniteYield) ~= "function" then
        CachedData.InfiniteYield = loadstring(HttpGet(game, "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))
    end
    
    CachedData.InfiniteYield()
end)

Tools:CreateButton("Remote Spy", function()
    if type(CachedData.RemoteSpy) ~= "function" then
        CachedData.RemoteSpy = loadstring(HttpGet(game, "https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))
    end
    
    CachedData.RemoteSpy()
end)

Tools:CreateButton("Dex Explorer", function()
    if type(CachedData.DexExplorer) ~= "function" then
        CachedData.DexExplorer = loadstring(HttpGet(game, "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))
    end
    
    CachedData.DexExplorer()
end)

local repo_branch = "revision"

local function WebImport(file)
    if type(CachedData.Hydroxide[file]) ~= "function" then
        CachedData.Hydroxide[file] = loadstring(HttpGetAsync(game, stringformat("https://raw.githubusercontent.com/%s/Hydroxide-Backup/%s/%s.lua", repo_owner, repo_branch, file)), file .. '.lua')
    end

    return CachedData.Hydroxide[file]
end

Tools:CreateButton("Hydroxide", function()
    WebImport("init")()
    WebImport("ui/main")()
end)

Tools:CreateButton("Ketamine", function()
    if type(CachedData.Ketamine) ~= "function" then
        CachedData.Ketamine = loadstring(HttpGet(game, backups_directory .. "Ketamine-Backup.lua"))
    end
    
    CachedData.Ketamine()
end)

local InstanceScanner = DeveloperToolbox:NewSection("Instance Scanner")

InstanceScanner:CreateTextbox("Scan by Class", function(class_name)
    OpenDevConsole()
    local start_time = osclock()
    local found_instance_class = false

    print(stringformat([[
[Toolbox]: Scanning for Instances of Class: %s

---------------------------------------------------------------------------------------------------------------------------

]], class_name))

    for _, inst in pairs(GetDescendants(game)) do
        if inst.ClassName == class_name then
            found_instance_class = true

            local output = "Name " .. arrow .. " " .. inst.Name ..
               " | Path " .. arrow .. " " .. inst:GetFullName()
            local property_name = show_properties[class_name]
            if property_name and inst[property_name] then
                output = output .. " | " .. property_name .. " = " .. tostring(inst[property_name])
            end

            print(output)
        end
    end

    if not found_instance_class then
        warn(stringformat("[Toolbox]: No instances of class '%s' were found.", class_name))
    end

    local end_time = osclock()
    local final_time = end_time - start_time

    print(stringformat([[
[Toolbox]: Scan completed in %.4f seconds.

---------------------------------------------------------------------------------------------------------------------------

]], final_time))
end, true)

local Addons = DeveloperToolbox:NewSection("Addons")

Addons:CreateTextbox("Input Script Name", function(text)
    addon_name = text
end)

Addons:CreateTextbox("Input Script", function(text)
    addon_script = text
end)

Addons:CreateButton("Save Addon", function()
    if not addon_name or addon_name == "" or not addon_script or addon_script == "" then
        Notify("Missing name or script input. Make sure to press enter after inputting details.")
        return
    end

    writefile(addons_folder .. "/" .. addon_name .. ".lua", addon_script)
    addon_list[#addon_list + 1] = addon_name
    addon_dropdown:UpdateDropdown(addon_list)
    Notify("Saved Addon: " .. addon_name)
end)

addon_dropdown = Addons:CreateDropdown("Select Addon", addon_list, "None", function(text)
    selected_addon = text
end)

Addons:CreateButton("Load Selected Addon", function()
    if not selected_addon then
        Notify("No addon selected.")
        return
    end

    local path = addons_folder .. "/" .. selected_addon .. ".lua"

    local success, result = pcall(function()
        loadfile(path)()
    end)

    if success then
        Notify("Loaded Addon: " .. selected_addon)
    else
        Notify("Error loading addon:\n" .. tostring(result))
    end
end)

Addons:CreateButton("Delete Selected Addon", function()
    if type(delfile) ~= "function" then
        Notify("Incompatible Exploit. Your exploit does not support this feature (missing delfile)")
        return
    end

    if not selected_addon then
        Notify("No addon selected.")
        return
    end

    InteractiveNotify({
        Text = "Are you sure you want to delete this addon?",
        Button1 = "Yes",
        Button2 = "No",
        Callback = function(value)
            if value == "Yes" then
                delfile(addons_folder .. "/" .. selected_addon .. ".lua")
                RemoveFromTable(addon_list, selected_addon)
                Notify("Deleted Addon: " .. selected_addon)
                addon_dropdown:UpdateDropdown(addon_list)
                addon_dropdown:Select("None")
                selected_addon = nil
            elseif value == "No" then
                Notify("Addon deletion cancelled.")
            end
        end
    })
end)

local Other = DeveloperToolbox:NewSection("Other")

Notify = function() end

Other:CreateToggle("Instant Prompts", function(value)
    if value then
        proximity_prompt_conn = proximity_prompt_service.PromptButtonHoldBegan:Connect(function(prompt)
            if prompt.HoldDuration > 0 then
                fireproximityprompt(prompt)
            end
        end)
        Notify("Instant Proximity Prompts Enabled. You can now instantly interact with Proximity Prompts.")
    else
        if typeof(proximity_prompt_conn) == "RBXScriptConnection" then
            proximity_prompt_conn:Disconnect()
        end

        Notify("Instant Proximity Prompt Disabled. You are now unable to interact with Proximity Prompts instantly.")
    end
end)

Other:CreateToggle("Notification Sounds", function(value)
    notification_sounds = value
    
    if notification_sounds then
        Notify("Notification Sounds Enabled.")
    else
        Notify("Notification Sounds Disabled.")
    end
end, true)

Notify = OldNotify

Other:CreateButton("FPS Booster", function()
    if type(global_env.FPS_Booster_Settings) ~= "table" then
        global_env.FPS_Booster_Settings = {
            Players = {
                ["Ignore Me"] = true, -- Ignore your Character
                ["Ignore Others"] = true -- Ignore other Characters
            },
            Meshes = {
                Destroy = false, -- Destroy Meshes
                LowDetail = true -- Low detail meshes (NOT SURE IT DOES ANYTHING)
            },
            Images = {
                Invisible = true, -- Invisible Images
                LowDetail = false, -- Low detail images (NOT SURE IT DOES ANYTHING)
                Destroy = false, -- Destroy Images
            },
            ["No Particles"] = true, -- Disables all ParticleEmitter, Trail, Smoke, Fire and Sparkles
            ["No Camera Effects"] = true, -- Disables all PostEffect's (Camera/Lighting Effects)
            ["No Explosions"] = true, -- Makes Explosion's invisible
            ["No Clothes"] = true, -- Removes Clothing from the game
            ["Low Water Graphics"] = true, -- Removes Water Quality
            ["No Shadows"] = true, -- Remove Shadows
            ["Low Rendering"] = true, -- Lower Rendering
            ["Low Quality Parts"] = true -- Lower quality parts
        }
    end

    if type(CachedData.FPSBooster) ~= "function" then
        CachedData.FPSBooster = loadstring(HttpGet(game, backups_directory .. "FPS-Booster-Backup.lua"))
    end

    CachedData.FPSBooster()
end)

Other:CreateButton("Executor Info", FetchExecutorInfo)

Other:CreateButton("Rejoin", RejoinServer)

Other:CreateButton("Server Hop", ServerHop)

Other:CreateButton("Exit Developer Toolbox", function()
    InteractiveNotify({
        Text = "Are you sure you want to exit the developer toolbox?",
        Button1 = "Yes",
        Button2 = "No",
        Callback = function(value)
            if value == "Yes" then
                LibraryObject:Destroy()
            elseif value == "No" then
                Notify("Exit cancelled.")
            end
        end
    })
end)

--// Events
local ui_handler_conn; ui_handler_conn = LibraryObject.Destroying:Connect(function(child)
    ui_handler_conn:Disconnect()
        
    if notification_sound then
        notification_sound:Destroy()
    end
        
    if typeof(proximity_prompt_conn) == "RBXScriptConnection" then
        proximity_prompt_conn:Disconnect()
    end
        
    if MainState.QueueOnTeleport then
        MainState.QueueOnTeleport = false
    end
end)

--// Executing Finished
MainState.Executing = nil

--[[// Credits
Infinite Yield: Infinite Yield Admin, Remote Spy
Infinite Yield Discord Server: https://discord.gg/78ZuWSq
Chillz: Dex Explorer ++
Chillz Github: https://github.com/AZYsGithub
Hosvile: Hydroxide 
Hosvile Github: https://github.com/hosvile/
Cherry: Ketamine
Cherry Discord Server: https://discord.gg/7xYqrnwSWr
RIP#6666: FPS Booster
RIP#6666 Discord Server: https://discord.gg/rips
]]
