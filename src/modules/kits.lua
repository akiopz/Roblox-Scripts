---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
---@return env_global
local function get_env_safe()
    ---@type env_global
    local env = (getgenv or function() return _G end)()
    return env
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
                                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if d < minDist then
                                        minDist = d
                                        nearest = p.Character.HumanoidRootPart
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
                                if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
                                    local hum = p.Character.Humanoid
                                    if hum.Health > 0 and hum.Health < 30 then -- 稍微提高閾值
                                        if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then
                                            hannahRemote:FireServer({["target"] = p.Character})
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- 3. 收集類技能 (Zephyr, Eldertree, Evelynn, Aery, Grim, Lucia)
                        local collectTypes = {
                            {name = "ZephyrOrb", remote = "ZephyrOrbCollect", arg = "orb"},
                            {name = "EldertreeOrb", remote = "EldertreeOrbCollect", arg = "orb"},
                            {name = "EvelynnOrb", remote = "EvelynnOrbCollect", arg = "orb"},
                            {name = "AeryButterfly", remote = "AeryButterflyCollect", arg = "butterfly"},
                            {name = "GrimReaperSoul", remote = "GrimReaperSoulCollect", arg = "soul"},
                            {name = "Candy", remote = "LuciaCandyCollect", arg = "candy"}
                        }

                        for _, v in ipairs(workspace:GetChildren()) do
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
                                    if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                        if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < skill.dist then
                                            remote:FireServer({["target"] = p.Character})
                                        end
                                    end
                                end
                            end
                        end

                        -- 5. 自保/自動類 (Umbra, Warden, Amy, Noelle)
                        local health = char.Humanoid.Health
                        if health < 40 then
                            local rescueRemotes = {"UmbraTeleport", "WardenUseShield", "NoelleUseGift"}
                            for _, rName in ipairs(rescueRemotes) do
                                local remote = getRemote(rName)
                                if remote then remote:FireServer() end
                            end
                        end
                        if health < 70 then
                            local amy = getRemote("AxolotlAmyUseAxolotl")
                            if amy then amy:FireServer() end
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
                while env_global.YuziDashExploit and task.wait(0.01) do
                    local dao = lp.Character and lp.Character:FindFirstChild("dao")
                    if dao then
                        local remote = dao:FindFirstChild("Dash", true)
                        if remote then remote:FireServer({["direction"] = lp.Character.HumanoidRootPart.CFrame.LookVector}) end
                    end
                end
            end)
        end,
        
        ToggleMinerAutoMine = function(state)
            env_global.MinerAutoMine = state
            if not env_global.MinerAutoMine then return end
            task.spawn(function()
                while env_global.MinerAutoMine and task.wait(0.5) do
                    local remote = ReplicatedStorage:FindFirstChild("MinerMine", true)
                    if remote then
                        for _, v in ipairs(workspace:GetChildren()) do
                            if v:IsA("BasePart") and v.Name == "MinerRock" and (v.Position - lp.Character.HumanoidRootPart.Position).Magnitude < 20 then
                                remote:FireServer({["rock"] = v})
                            end
                        end
                    end
                end
            end)
        end
    }
end

return KitsModule
