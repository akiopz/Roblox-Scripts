---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
---@return env_global
local function get_env_safe()
    local env = (getgenv or function() return _G end)()
    ---@type any
    local env_any = env
    return env_any
end

local env_global = get_env_safe()
local game = game or env_global.game
local workspace = workspace or env_global.workspace
local task = task or env_global.task
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local KitsModule = {}

function KitsModule.Init(Gui, Notify, CatFunctions)
    -- 預先緩存常用 Remote
    local cachedRemotes = {}
    local function getRemote(name)
        if cachedRemotes[name] then return cachedRemotes[name] end
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r then cachedRemotes[name] = r end
        return r
    end

    return {
        ToggleAutoKitSkill = function(state)
            env_global.AutoKitSkill = state
            if not env_global.AutoKitSkill then return end
            
            Notify("職業系統", "已啟動全職業自動技能優化 (智慧緩存模式)", "Success")
            
            task.spawn(function()
                while env_global.AutoKitSkill and task.wait(0.1) do
                    pcall(function()
                        local char = lp.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        
                        -- 1. Yuzi (Dao Dash)
                        local dao = char:FindFirstChild("dao") or lp.Backpack:FindFirstChild("dao")
                        if dao then
                            local nearest = nil
                            local minDist = 25
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local targetHrp = p.Character.HumanoidRootPart
                                    local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
                                    if targetHum and targetHum.Health > 0 then
                                        local d = (root.Position - targetHrp.Position).Magnitude
                                        if d < minDist then
                                            minDist = d
                                            nearest = targetHrp
                                        end
                                    end
                                end
                            end
                            if nearest and minDist > 8 then
                                local remote = dao:FindFirstChild("Dash", true) or getRemote("DaoDash")
                                if remote then 
                                    remote:FireServer({["direction"] = (nearest.Position - root.Position).Unit}) 
                                end
                            end
                        end
                        
                        -- 2. Hannah (Execute)
                        local hannahRemote = getRemote("HannahExecute")
                        if hannahRemote then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local hum = p.Character.Humanoid
                                    if hum.Health > 0 and hum.Health < 35 then -- 優化執行閾值
                                        if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then
                                            hannahRemote:FireServer({["target"] = p.Character})
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- 3. 收集類技能 (優化為掃描特定資料夾，減少 workspace 全局掃描壓力)
                        local collectTypes = {
                            {name = "ZephyrOrb", remote = "ZephyrOrbCollect", arg = "orb"},
                            {name = "EldertreeOrb", remote = "EldertreeOrbCollect", arg = "orb"},
                            {name = "EvelynnOrb", remote = "EvelynnOrbCollect", arg = "orb"},
                            {name = "AeryButterfly", remote = "AeryButterflyCollect", arg = "butterfly"},
                            {name = "GrimReaperSoul", remote = "GrimReaperSoulCollect", arg = "soul"},
                            {name = "Candy", remote = "LuciaCandyCollect", arg = "candy"}
                        }

                        -- 優先掃描可能的掉落物容器，若無則回退到 workspace
                        local containers = {workspace:FindFirstChild("ItemDrops"), workspace:FindFirstChild("Pickups"), workspace}
                        for _, container in ipairs(containers) do
                            if container then
                                for _, v in ipairs(container:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        for _, info in ipairs(collectTypes) do
                                            if v.Name == info.name and (v.Position - root.Position).Magnitude < 25 then
                                                local remote = getRemote(info.remote)
                                                if remote then
                                                    remote:FireServer({[info.arg] = v})
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        -- 4. 目標類技能 (Kaliyah, Pyro, Freya, Vulcan, Gompy)
                        local targetSkills = {
                            {remote = "KaliyahFirePunch", dist = 12},
                            {remote = "PyroUseFlamethrower", dist = 15},
                            {remote = "FreyaIceSkill", dist = 15},
                            {remote = "VulcanFireTurret", dist = 60},
                            {remote = "GompyUseVacuum", dist = 18}
                        }

                        for _, skill in ipairs(targetSkills) do
                            local remote = getRemote(skill.remote)
                            if remote then
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                                        if p.Character.Humanoid.Health > 0 and (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < skill.dist then
                                            remote:FireServer({["target"] = p.Character})
                                        end
                                    end
                                end
                            end
                        end

                        -- 5. 自保/自動類 (Umbra, Warden, Amy, Noelle)
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local health = hum.Health
                            if health < 45 then -- 稍微提高自保靈敏度
                                local rescueRemotes = {"UmbraTeleport", "WardenUseShield", "NoelleUseGift"}
                                for _, rName in ipairs(rescueRemotes) do
                                    local remote = getRemote(rName)
                                    if remote then remote:FireServer() end
                                end
                            end
                            if health < 75 then
                                local amy = getRemote("AxolotlAmyUseAxolotl")
                                if amy then amy:FireServer() end
                            end
                        end

                    end)
                end
            end)
        end,
        
        ToggleYuziDashExploit = function(state)
            env_global.YuziDashExploit = state
            if not env_global.YuziDashExploit then return end
            Notify("Yuzi 增強", "已啟動無限衝刺漏洞 (需 Dao 在手)", "Warning")
            task.spawn(function()
                while env_global.YuziDashExploit and task.wait(0.05) do -- 優化衝刺頻率，減少伺服器負擔
                    local char = lp.Character
                    local dao = char and char:FindFirstChild("dao")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if dao and hrp then
                        local remote = dao:FindFirstChild("Dash", true)
                        if remote then 
                            remote:FireServer({["direction"] = hrp.CFrame.LookVector}) 
                        end
                    end
                end
            end)
        end,
        
        ToggleMinerAutoMine = function(state)
            env_global.MinerAutoMine = state
            if not env_global.MinerAutoMine then return end
            task.spawn(function()
                while env_global.MinerAutoMine and task.wait(0.5) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local remote = ReplicatedStorage:FindFirstChild("MinerMine", true)
                        if remote then
                            -- 優化：僅掃描 HumanoidRootPart 附近的物件
                            for _, v in ipairs(workspace:GetChildren()) do
                                if v:IsA("BasePart") and v.Name == "MinerRock" then
                                    if (v.Position - hrp.Position).Magnitude < 25 then
                                        remote:FireServer({["rock"] = v})
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    }
end

return KitsModule
