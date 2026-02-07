-- Halol (V4.0) 環境模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local env = {}
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
    local e = {
        gethui = gethui or function() return game:GetService("CoreGui") end,
        getgenv = getgenv or function() return _G end,
        isrenderobj = isrenderobj or function() return false end,
        setreadonly = setreadonly or function(t, b) end,
        make_writeable = make_writeable or function(t) if setreadonly then setreadonly(t, false) end end,
        getrawmetatable = getrawmetatable or function(t) return debug.getmetatable(t) end,
        newcclosure = newcclosure or function(f) return f end,
        checkcaller = checkcaller or function() return false end,
        setfpscap = setfpscap or function() end,
        getnamecallmethod = getnamecallmethod or function() return "" end,
        loadstring = loadstring or function() return function() warn("此注入器不支持 loadstring") end end
    }
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
