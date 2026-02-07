---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local game = game or getgenv().game
local Color3 = Color3 or getgenv().Color3
local UDim2 = UDim2 or getgenv().UDim2
local Vector3 = Vector3 or getgenv().Vector3
local CFrame = CFrame or getgenv().CFrame
local task = task or getgenv().task
local math = math or getgenv().math
local warn = warn or getgenv().warn or print
local load_func = (getgenv().loadstring or getgenv().load or loadstring or load)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local Color3_fromHSV = Color3.fromHSV
local Color3_fromRGB = Color3.fromRGB
local UDim2_new = UDim2.new
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local task_spawn = task.spawn
local task_wait = task.wait
local math_random = math.random
local math_floor = math.floor

local function GetEnvironment()
    local g = getgenv()
    local e = {
        gethui = g.gethui or function() return game:GetService("CoreGui") end,
        getgenv = getgenv,
        isrenderobj = g.isrenderobj or function() return false end,
        setreadonly = g.setreadonly or function(_, _) end,
        make_writeable = g.make_writeable or function(target) 
            local sr = g.setreadonly
            if sr then sr(target, false) end 
        end,
        getrawmetatable = g.getrawmetatable or function(target) return debug.getmetatable(target) end,
        newcclosure = g.newcclosure or function(f) return f end,
        checkcaller = g.checkcaller or function() return false end,
        setfpscap = g.setfpscap or function() end,
        getnamecallmethod = g.getnamecallmethod or function() return "" end,
        loadstring = load_func,
        
        -- Launcher Support APIs
        request = g.request or g.http_request or (http and http.request) or function() warn("Executor does not support request API") end,
        identifyexecutor = g.identifyexecutor or g.getexecutorname or function() return "Unknown Executor" end,
        
        -- File System APIs
        writefile = g.writefile or function(...) warn("Executor does not support writefile") end,
        readfile = g.readfile or function(...) return "" end,
        isfile = g.isfile or function(...) return false end,
        listfiles = g.listfiles or function(...) return {} end,
        makefolder = g.makefolder or function(...) end,
        
        -- Interaction APIs
        fireclickdetector = g.fireclickdetector or function(...) end,
        fireproximityprompt = g.fireproximityprompt or function(...) end,
        firetouchinterest = g.firetouchinterest or function(...) end,
        
        -- Clipboard APIs
        setclipboard = g.setclipboard or g.toclipboard or function() end,
        getclipboard = g.getclipboard or function() return "" end,
        
        -- Asset APIs
        getcustomasset = g.getcustomasset or function() return "" end
    }
    
    -- 增加設置存取功能
    function e.SaveSettings(name, data)
        local success, json = pcall(function() 
            -- 處理 Vector3/Color3 等無法直接編碼的類型
            local cleanData = {}
            for k, v in pairs(data) do
                if typeof(v) == "Vector3" then
                    cleanData[k] = {type = "Vector3", x = v.X, y = v.Y, z = v.Z}
                elseif typeof(v) == "Color3" then
                    cleanData[k] = {type = "Color3", r = v.R, g = v.G, b = v.B}
                elseif typeof(v) == "UDim2" then
                    cleanData[k] = {type = "UDim2", xs = v.X.Scale, xo = v.X.Offset, ys = v.Y.Scale, yo = v.Y.Offset}
                else
                    cleanData[k] = v
                end
            end
            return HttpService:JSONEncode(cleanData) 
        end)
        if success then
            pcall(function() e.writefile(name .. ".json", json) end)
        end
    end

    function e.LoadSettings(name)
        if e.isfile(name .. ".json") then
            local success, content = pcall(function() return e.readfile(name .. ".json") end)
            if success then
                local success2, data = pcall(function() 
                    local decoded = HttpService:JSONDecode(content)
                    local finalData = {}
                    for k, v in pairs(decoded) do
                        if type(v) == "table" and v.type then
                            if v.type == "Vector3" then
                                finalData[k] = Vector3.new(v.x, v.y, v.z)
                            elseif v.type == "Color3" then
                                finalData[k] = Color3.new(v.r, v.g, v.b)
                            elseif v.type == "UDim2" then
                                finalData[k] = UDim2.new(v.xs, v.xo, v.ys, v.yo)
                            else
                                finalData[k] = v
                            end
                        else
                            finalData[k] = v
                        end
                    end
                    return finalData
                end)
                if success2 then return data end
            end
        end
        return nil
    end

    return e
end

return {
    env = GetEnvironment(),
    Players = Players,
    RunService = RunService,
    CoreGui = CoreGui,
    Lighting = Lighting,
    HttpService = HttpService,
    TeleportService = TeleportService,
    ReplicatedStorage = ReplicatedStorage,
    UserInputService = UserInputService,
    lp = lp,
    Color3_fromHSV = Color3_fromHSV,
    Color3_fromRGB = Color3_fromRGB,
    UDim2_new = UDim2_new,
    Vector3_new = Vector3_new,
    CFrame_new = CFrame_new,
    task_spawn = task_spawn,
    task_wait = task_wait,
    math_random = math_random,
    math_floor = math_floor
}
