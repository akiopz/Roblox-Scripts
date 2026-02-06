-- Halol (V4.0) 功能模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local task_spawn = task.spawn
local task_wait = task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local FunctionsModule = {}

function FunctionsModule.Init(env)
    local CatFunctions = {}
    _G.CatFunctions = CatFunctions

    -- KillAura
    CatFunctions.ToggleKillAura = function(state)
        if state == nil then _G.KillAura = not _G.KillAura else _G.KillAura = state end
        if _G.KillAura then
            task_spawn(function()
                while _G.KillAura and task_wait(0.02) do
                    local loop_success, loop_err = pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local maxDist = _G.KillAuraRange or 22
                        local target = nil
                        local minDist = maxDist
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= lp and player.Team ~= lp.Team and player.Character then
                                local ehum = player.Character:FindFirstChildOfClass("Humanoid")
                                local ehrp = player.Character:FindFirstChild("HumanoidRootPart")
                                if ehum and ehum.Health > 0 and ehrp then
                                    local predictedPos = ehrp.Position + (ehrp.Velocity * 0.1)
                                    local dist = (hrp.Position - predictedPos).Magnitude
                                    if dist < minDist then
                                        local dotProduct = hrp.CFrame.LookVector:Dot((ehrp.Position - hrp.Position).Unit)
                                        if dotProduct > -0.5 then
                                            minDist = dist
                                            target = player
                                        end
                                    end
                                end
                            end
                        end
                        if target then
                            if _G.KillAuraFaceTarget then
                                hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(target.Character.HumanoidRootPart.Position.X, hrp.Position.Y, target.Character.HumanoidRootPart.Position.Z))
                            end
                            local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or ReplicatedStorage:FindFirstChild("CombatEvents", true)
                            if remote and remote:IsA("RemoteEvent") then
                                remote:FireServer({["entity"] = target.Character})
                            else
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                            end
                        end
                    end)
                    if not loop_success then task_wait(0.5) end
                end
            end)
        end
        return _G.KillAura
    end

    -- AutoBridge
    CatFunctions.ToggleAutoBridge = function(state)
        if state == nil then _G.AutoBridge = not _G.AutoBridge else _G.AutoBridge = state end
        if _G.AutoBridge then
            task_spawn(function()
                while _G.AutoBridge and task_wait(0.05) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                        local block = char:FindFirstChildOfClass("Tool")
                        if block and (block.Name:lower():find("block") or block.Name:lower():find("wool")) then
                            local pos = hrp.Position + (hum.MoveDirection * 2.5) + Vector3_new(0, -3.6, 0)
                            local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                            if remote then remote:FireServer({["position"] = pos, ["block"] = block.Name}) end
                        end
                    end
                end
            end)
        end
        return _G.AutoBridge
    end

    -- AutoToolFastBreak
    CatFunctions.ToggleAutoToolFastBreak = function(state)
        if state == nil then _G.AutoToolFB = not _G.AutoToolFB else _G.AutoToolFB = state end
        if _G.AutoToolFB then
            task_spawn(function()
                while _G.AutoToolFB and task_wait(0.05) do
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and hum then
                        local target = lp:GetMouse().Target
                        if target and target:IsA("BasePart") and (hrp.Position - target.Position).Magnitude < 25 then
                            local blockName = target.Name:lower()
                            local bestToolName = nil
                            if blockName:find("bed") or blockName:find("wool") then
                                bestToolName = "shears"
                            elseif blockName:find("wood") or blockName:find("plank") then
                                bestToolName = "axe"
                            elseif blockName:find("stone") or blockName:find("ore") or blockName:find("ceramic") then
                                bestToolName = "pickaxe"
                            end
                            if bestToolName then
                                local tool = lp.Backpack:FindFirstChild(bestToolName, true) or char:FindFirstChild(bestToolName, true)
                                if tool and tool.Parent ~= char then hum:EquipTool(tool) end
                            end
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then remote:FireServer({["position"] = target.Position, ["block"] = target.Name}) end
                        end
                    end
                end
            end)
        end
        return _G.AutoToolFB
    end

    -- NoFall
    CatFunctions.ToggleNoFall = function(state)
        if state == nil then _G.NoFall = not _G.NoFall else _G.NoFall = state end
        if _G.NoFall then
            task_spawn(function()
                while _G.NoFall and task_wait(0.1) do
                    local remote = ReplicatedStorage:FindFirstChild("FallDamage", true)
                    if remote and remote:IsA("RemoteEvent") then remote:FireServer(0) end
                end
            end)
        end
        return _G.NoFall
    end

    -- Reach
    CatFunctions.ToggleReach = function(state)
        if state == nil then _G.ReachEnabled = not _G.ReachEnabled else _G.ReachEnabled = state end
        if _G.ReachEnabled then
            task_spawn(function()
                while _G.ReachEnabled do
                    pcall(function()
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= lp and player.Character then
                                local root = player.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 100
                                    local targetSize = (dist < 30) and Vector3_new(15, 15, 15) or Vector3_new(2, 2, 2)
                                    root.Size = targetSize
                                    root.Transparency = 0.7
                                    root.CanCollide = false
                                end
                            end
                        end
                    end)
                    task_wait(0.5)
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Size = Vector3_new(2, 2, 2)
                            root.Transparency = 1
                            root.CanCollide = true
                        end
                    end
                end
            end)
        end
        return _G.ReachEnabled
    end

    -- Auto Resource Farm
    CatFunctions.ToggleAutoResourceFarm = function(state)
        if state == nil then _G.AutoResourceFarm = not _G.AutoResourceFarm else _G.AutoResourceFarm = state end
        if _G.AutoResourceFarm then
            task_spawn(function()
                while _G.AutoResourceFarm and task_wait(0.5) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local battlefield = CatFunctions.GetBattlefieldState()
                        if #battlefield.resources > 0 then
                            local targetRes = battlefield.resources[1]
                            if targetRes.dist < 50 then
                                -- 傳送到資源位置 (暴力模式) 或 移動 (平滑模式)
                                hrp.CFrame = targetRes.part.CFrame + Vector3_new(0, 3, 0)
                            end
                        end
                    end
                end
            end)
        end
        return _G.AutoResourceFarm
    end

    -- Infinite Jump
    CatFunctions.ToggleInfiniteJump = function(state)
        if state == nil then _G.InfiniteJump = not _G.InfiniteJump else _G.InfiniteJump = state end
        if _G.InfiniteJump then
            local connection
            connection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJump then
                    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                else
                    connection:Disconnect()
                end
            end)
        end
        return _G.InfiniteJump
    end

    -- No Slowdown
    CatFunctions.ToggleNoSlowdown = function(state)
        if state == nil then _G.NoSlowdown = not _G.NoSlowdown else _G.NoSlowdown = state end
        if _G.NoSlowdown then
            task_spawn(function()
                while _G.NoSlowdown and task_wait(0.05) do
                    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- Bedwars 物品使用時通常會修改 WalkSpeed
                        -- 這裡強制保持速度，並嘗試攔截速度修改
                        if hum.WalkSpeed < (_G.CustomWalkSpeed or 16) then
                            hum.WalkSpeed = _G.CustomWalkSpeed or 16
                        end
                    end
                end
            end)
        end
        return _G.NoSlowdown
    end

    -- Velocity (Anti-Knockback)
    CatFunctions.ToggleVelocity = function(state)
        if state == nil then _G.VelocityEnabled = not _G.VelocityEnabled else _G.VelocityEnabled = state end
        if _G.VelocityEnabled then
            task_spawn(function()
                while _G.VelocityEnabled and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- 監控並重置垂直以外的衝量
                        hrp.Velocity = Vector3_new(0, hrp.Velocity.Y, 0)
                    end
                end
            end)
        end
        return _G.VelocityEnabled
    end

    -- Auto Sprint
    CatFunctions.ToggleAutoSprint = function(state)
        if state == nil then _G.AutoSprint = not _G.AutoSprint else _G.AutoSprint = state end
        if _G.AutoSprint then
            task_spawn(function()
                while _G.AutoSprint and task_wait(0.5) do
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        -- 這裡調用 Bedwars 內部的 Sprint 遠程或簡單修改屬性
                        -- 具體視遊戲版本而定，通常修改 WalkSpeed 即可
                        hum.WalkSpeed = (_G.CustomWalkSpeed or 16) * 1.3
                    end
                end
            end)
        end
        return _G.AutoSprint
    end

    -- Battlefield State
    CatFunctions.GetBattlefieldState = function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return {threats = {}, resources = {}, allies = {}} end
        local state = {threats = {}, resources = {}, allies = {}, nearestThreat = nil, isBeingTargeted = false}
        local myPos = hrp.Position
        local maxScanDist = 150
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local ehrp = player.Character.HumanoidRootPart
                local ehum = player.Character:FindFirstChildOfClass("Humanoid")
                local dist = (myPos - ehrp.Position).Magnitude
                if dist < maxScanDist then
                    local pData = {player = player, hrp = ehrp, hum = ehum, dist = dist}
                    if player.Team == lp.Team then
                        table.insert(state.allies, pData)
                    else
                        table.insert(state.threats, pData)
                        if not state.nearestThreat or dist < state.nearestThreat.dist then
                            state.nearestThreat = pData
                        end
                        local dot = ehrp.CFrame.LookVector:Dot((myPos - ehrp.Position).Unit)
                        if dot > 0.8 and dist < 40 then state.isBeingTargeted = true end
                    end
                end
            end
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("diamond") or v.Name:lower():find("emerald")) then
                local dist = (myPos - v.Position).Magnitude
                if dist < 100 then table.insert(state.resources, {part = v, dist = dist, name = v.Name}) end
            end
        end
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)
        return state
    end

    return CatFunctions
end

return FunctionsModule
