---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
-- Halol 射擊類戰鬥模組 (Combat Module)
-- 放置於: 射擊類/combat.lua

local function get_env_safe()
    local env = (getgenv or function() return _G end)()
    return env
end

local env_global = get_env_safe()
local game = game or env_global.game
local workspace = workspace or env_global.workspace
local task = task or env_global.task
local Vector3 = Vector3 or env_global.Vector3
local CFrame = CFrame or env_global.CFrame
local math = math or env_global.math
local table = table or env_global.table
local pairs = pairs or env_global.pairs
local ipairs = ipairs or env_global.ipairs
local pcall = pcall or env_global.pcall
local Instance = Instance or env_global.Instance
local Enum = Enum or env_global.Enum
local Color3 = Color3 or env_global.Color3
local Vector2 = Vector2 or env_global.Vector2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Combat = {}

-- [[ 配置與狀態 ]]
env_global.AimbotEnabled = env_global.AimbotEnabled or false
env_global.AimbotSmoothness = env_global.AimbotSmoothness or 0.2
env_global.AimbotFOV = env_global.AimbotFOV or 150
env_global.AimbotTargetPart = env_global.AimbotTargetPart or "Head"
env_global.ShowFOV = env_global.ShowFOV or false

env_global.TriggerBotEnabled = env_global.TriggerBotEnabled or false
env_global.TriggerBotDelay = env_global.TriggerBotDelay or 0.05

env_global.NoRecoilEnabled = env_global.NoRecoilEnabled or false

env_global.AirAttackEnabled = env_global.AirAttackEnabled or false
env_global.AirAttackHeight = env_global.AirAttackHeight or 20

env_global.BulletTracersEnabled = env_global.BulletTracersEnabled or false
env_global.HitSoundEnabled = env_global.HitSoundEnabled or false

env_global.MagicBulletEnabled = env_global.MagicBulletEnabled or false
env_global.MagicBulletRange = env_global.MagicBulletRange or 500

-- [[ 反偵測配置 ]]
env_global.AntiCheatBypass = env_global.AntiCheatBypass or true
env_global.SafeMode = env_global.SafeMode or true -- 開啟後會限制某些過於暴力的參數
env_global.SpoofRemote = env_global.SpoofRemote or true

-- [[ 工具函數 ]]

-- 獲取最近的敵人 (基於鼠標位置與 FOV)
local function GetNearestEnemy()
    local nearest = nil
    local maxDist = env_global.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character then
            local targetPart = player.Character:FindFirstChild(env_global.AimbotTargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        nearest = targetPart
                    end
                end
            end
        end
    end
    return nearest
end

-- [[ 核心邏輯 ]]

-- Aimbot 主循環
RunService.RenderStepped:Connect(function()
    if env_global.AimbotEnabled then
        local targetPart = GetNearestEnemy()
        if targetPart then
            local targetPos = targetPart.Position
            -- 考慮預測 (如果目標有速度)
            if targetPart.Parent:FindFirstChild("HumanoidRootPart") then
                targetPos = targetPos + (targetPart.Parent.HumanoidRootPart.Velocity * 0.1)
            end
            
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, env_global.AimbotSmoothness)
        end
    end
end)

-- [[ 魔法子彈 (Magic Bullet) 核心實作 ]]
local function SetupMagicBullet()
    local oldIndex
    local oldNamecall
    
    -- 獲取偽裝環境
    local function IsRealRequest()
        if not env_global.AntiCheatBypass then return true end
        local stack = debug.traceback()
        -- 如果堆棧包含某些關鍵字，可能是反外掛的檢測腳本在讀取屬性
        if stack:find("Anticheat") or stack:find("Adonis") or stack:find("Sentinel") then
            return false
        end
        return true
    end

    -- 嘗試 Hook Metatable (如果執行器支持)
    pcall(function()
        if not env_global.hookmetamethod then return end
        
        -- Hook __index 攔截 Mouse.Hit 和 Mouse.Target
        oldIndex = env_global.hookmetamethod(game, "__index", function(self, key)
            if env_global.MagicBulletEnabled and IsRealRequest() then
                if tostring(self) == "Mouse" then
                    if key == "Hit" or key == "Target" then
                        local target = GetNearestTarget(env_global.MagicBulletRange)
                        if target then
                            if key == "Hit" then return target.CFrame end
                            if key == "Target" then return target end
                        end
                    end
                end
            end
            
            -- 反偵測：偽裝本地玩家屬性
            if env_global.AntiCheatBypass and self == lp then
                if key == "WalkSpeed" then return 16 end -- 永遠返回正常速度
                if key == "JumpPower" then return 50 end
            end

            return oldIndex(self, key)
        end)
        
        -- Hook __namecall 攔截 Raycast 與 Remote 事件
        oldNamecall = env_global.hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            -- 1. 魔法子彈攔截
            if env_global.MagicBulletEnabled and method == "Raycast" and IsRealRequest() then
                local target = GetNearestTarget(env_global.MagicBulletRange)
                if target then
                    local origin = args[1]
                    local direction = (target.Position - origin).Unit * 1000
                    args[2] = direction
                    return oldNamecall(self, unpack(args))
                end
            end
            
            -- 2. 攔截反外掛 Remote (阻止上報)
            if env_global.SpoofRemote and method == "FireServer" then
                local remoteName = tostring(self):lower()
                if remoteName:find("check") or remoteName:find("detect") or remoteName:find("ban") or remoteName:find("kick") or remoteName:find("flag") then
                    warn("攔截到疑似反外掛上報: " .. remoteName)
                    return nil -- 吞掉該請求
                end
            end

            return oldNamecall(self, ...)
        end)
    end)
end

SetupMagicBullet()

-- [[ 暴力模式邏輯 ]]

-- 繪製彈道線條
local function CreateTracer(from, to)
    if not env_global.Drawing then return end
    local line = env_global.Drawing.new("Line")
    line.Visible = true
    line.From = from
    line.To = to
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 1.5
    line.Transparency = 1
    
    task.spawn(function()
        for i = 1, 10 do
            line.Transparency = line.Transparency - 0.1
            task.wait(0.05)
        end
        line:Remove()
    end)
end

-- 播放命中音效 (使用 Roblox 內建音效)
local function PlayHitSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://160433791" -- 經典命中音效
    sound.Volume = 1
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- 獲取範圍內最近的敵人 (不限於準心，純距離)
local function GetNearestTarget(maxRange)
    local nearest = nil
    local minDist = maxRange or 500
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = player.Character.HumanoidRootPart
            end
        end
    end
    return nearest
end

-- 暴力模式循環 (TriggerBot + 空中打人)
task.spawn(function()
    while true do
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- 1. 空中打人 (Air Attack)
        if env_global.AirAttackEnabled and hrp then
            local target = GetNearestTarget(100) -- 偵測 100 格內的敵人
            if target then
                -- 增加隨機偏移防止過於死板 (Anti-Cheat Bypass)
                local jitter = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                hrp.CFrame = target.CFrame * CFrame.new(0, env_global.AirAttackHeight, 0) * CFrame.new(jitter.X, 0, jitter.Z)
                
                -- 鎖定垂直速度防止掉落太快
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                
                -- 自動開火
                if env_global.mouse1click then
                    env_global.mouse1click()
                    
                    -- 彈道與音效
                    if env_global.BulletTracersEnabled then
                        local screenFrom, onScreen1 = Camera:WorldToViewportPoint(hrp.Position)
                        local screenTo, onScreen2 = Camera:WorldToViewportPoint(target.Position)
                        if onScreen1 and onScreen2 then
                            CreateTracer(Vector2.new(screenFrom.X, screenFrom.Y), Vector2.new(screenTo.X, screenTo.Y))
                        end
                    end
                    
                    if env_global.HitSoundEnabled then
                        PlayHitSound()
                    end
                end
            end
        end
        
        -- 2. 標準 TriggerBot (僅在暴力模式未啟動或未發現目標時運行)
        if env_global.TriggerBotEnabled and not (env_global.AirAttackEnabled and GetNearestTarget(30)) then
            local mouse = lp:GetMouse()
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(target.Parent)
                if player and player ~= lp and player.Team ~= lp.Team then
                    if env_global.mouse1click then
                        env_global.mouse1click()
                    end
                end
            end
        end
        
        task.wait(env_global.TriggerBotDelay or 0.05)
    end
end)

-- FOV 繪製 (使用 Drawing API)
local fovCircle = nil
if env_global.Drawing then
    fovCircle = env_global.Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Radius = env_global.AimbotFOV
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(0, 255, 255)
    fovCircle.Visible = false
    
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Visible = env_global.ShowFOV and env_global.AimbotEnabled
            fovCircle.Radius = env_global.AimbotFOV
            fovCircle.Position = UserInputService:GetMouseLocation()
        end
    end)
end

-- [[ 模組接口 ]]
function Combat.Init(Gui, Notify, CatFunctions)
    -- 如果有 GUI 系統，可以在這裡添加選項
    return {
        ToggleAimbot = function(state)
            env_global.AimbotEnabled = state
            Notify("自瞄系統", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        SetAimbotSmoothness = function(val)
            env_global.AimbotSmoothness = val
        end,
        
        ToggleShowFOV = function(state)
            env_global.ShowFOV = state
        end,
        
        ToggleTriggerBot = function(state)
            env_global.TriggerBotEnabled = state
            Notify("自動開火", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleNoRecoil = function(state)
            env_global.NoRecoilEnabled = state
            Notify("無後座力", "狀態: " .. (state and "開啟" or "關閉") .. " (需視遊戲環境而定)")
        end,
        
        ToggleAirAttack = function(state)
            env_global.AirAttackEnabled = state
            Notify("暴力模式", "空中打人: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleMagicBullet = function(state)
            env_global.MagicBulletEnabled = state
            Notify("魔法子彈", "狀態: " .. (state and "開啟" or "關閉") .. " (需執行器支持 Hook)")
        end,
        
        ToggleAntiCheatBypass = function(state)
            env_global.AntiCheatBypass = state
            env_global.SpoofRemote = state
            Notify("安全系統", "反外掛繞過: " .. (state and "強化開啟" or "關閉"))
        end,
        
        ToggleBulletTracers = function(state)
            env_global.BulletTracersEnabled = state
        end,
        
        ToggleHitSound = function(state)
            env_global.HitSoundEnabled = state
        end
    }
end

-- 導出模組
if env_global.HalolModules then
    env_global.HalolModules.Combat = Combat
end

return Combat
