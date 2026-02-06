-- Halol (V4.0) AI 模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer
local task_spawn = task.spawn
local task_wait = task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local AIModule = {}

function AIModule.Init(CatFunctions)
    -- God Mode AI
    local function ToggleGodMode(state)
        _G.GodModeAI = state
        if _G.GodModeAI then
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleReach(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            
            task_spawn(function()
                while _G.GodModeAI and task_wait(0.02) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local battlefield = CatFunctions.GetBattlefieldState()
                        local target = nil
                        local minDist = math.huge
                        
                        if battlefield.isBeingTargeted then
                            hrp.Velocity = hrp.Velocity + Vector3_new(math.random(-2, 2), 0, math.random(-2, 2))
                        end

                        if battlefield.nearestThreat and battlefield.nearestThreat.dist < 15 then
                            target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                        else
                            for _, v in ipairs(workspace:GetDescendants()) do
                                if v.Name == "bed" and v:IsA("BasePart") then
                                    local team = v:GetAttribute("Team")
                                    if team ~= lp.Team then
                                        local dist = (hrp.Position - v.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            target = {part = v, type = "BED"}
                                        end
                                    end
                                end
                            end
                            if not target and battlefield.nearestThreat then
                                target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                            end
                        end
                        
                        if target then
                            -- 這裡可以擴展更複雜的移動邏輯
                        end
                    end
                end
            end)
        end
    end

    -- Auto Play AI (簡化版，整合 GetBestTarget)
    local function ToggleAutoPlay(state)
        _G.AI_Enabled = state
        if _G.AI_Enabled then
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            
            task_spawn(function()
                while _G.AI_Enabled and task_wait(0.05) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(5), 0)
                        local battlefield = CatFunctions.GetBattlefieldState()
                        -- AI 決策邏輯...
                    end
                end
            end)
        end
    end

    return {
        ToggleGodMode = ToggleGodMode,
        ToggleAutoPlay = ToggleAutoPlay
    }
end

return AIModule
