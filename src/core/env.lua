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
    local e = {
        gethui = (getgenv and getgenv().gethui) or function() return game:GetService("CoreGui") end,
        getgenv = getgenv,
        isrenderobj = (getgenv and getgenv().isrenderobj) or function() return false end,
        setreadonly = (getgenv and getgenv().setreadonly) or function(_, _) end,
        make_writeable = (getgenv and getgenv().make_writeable) or function(target) 
            local sr = (getgenv and getgenv().setreadonly)
            if sr then sr(target, false) end 
        end,
        getrawmetatable = (getgenv and getgenv().getrawmetatable) or function(target) return debug.getmetatable(target) end,
        newcclosure = (getgenv and getgenv().newcclosure) or function(f) return f end,
        checkcaller = (getgenv and getgenv().checkcaller) or function() return false end,
        setfpscap = (getgenv and getgenv().setfpscap) or function() end,
        getnamecallmethod = (getgenv and getgenv().getnamecallmethod) or function() return "" end,
        loadstring = load_func
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
