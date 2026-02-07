---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local game = game or getgenv().game
local workspace = workspace or getgenv().workspace
local task = task or getgenv().task
local Vector3 = Vector3 or getgenv().Vector3
local CFrame = CFrame or getgenv().CFrame
local Ray = Ray or getgenv().Ray
local Enum = Enum or getgenv().Enum
local math = math or getgenv().math
local ipairs = ipairs or getgenv().ipairs
local pairs = pairs or getgenv().pairs
local pcall = pcall or getgenv().pcall

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer
local task_spawn = task.spawn
local task_wait = task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local AIModule = {}

function AIModule.Init(CatFunctions, Blatant)
    local function ToggleGodMode(state)
        _G.GodModeAI = state
        if _G.GodModeAI then
            _G.KillAuraRange = 25
            _G.KillAuraMaxTargets = 5
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleReach(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            _G.AutoBuyPro = true
            _G.AutoArmor = true
            Blatant.ToggleAutoBuyPro(true)
            Blatant.ToggleAutoArmor(true)
            
            local lastPos = Vector3_new(0,0,0)
            local lastMoveTime = tick()

            task_spawn(function()
                while _G.GodModeAI and task_wait(0.02) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        -- Stuck Detection
                        if (hrp.Position - lastPos).Magnitude < 0.5 then
                            if tick() - lastMoveTime > 2 then
                                hum.Jump = true
                                hum:Move(Vector3_new(math.random(-1, 1), 0, math.random(-1, 1)), true)
                                lastMoveTime = tick()
                            end
                        else
                            lastPos = hrp.Position
                            lastMoveTime = tick()
                        end

                        local battlefield = CatFunctions.GetBattlefieldState()
                        local target = nil
                        local minDist = math.huge
                        
                        if battlefield.isBeingTargeted then
                            hrp.Velocity = hrp.Velocity + Vector3_new(math.random(-2, 2), 0, math.random(-2, 2))
                        end

                        if battlefield.nearestThreat and battlefield.nearestThreat.dist < 15 then
                            target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                        else
                            if #battlefield.beds > 0 then
                                for _, bed in ipairs(battlefield.beds) do
                                    local team = bed.part:GetAttribute("Team")
                                    if team ~= lp.Team then
                                        target = {part = bed.part, type = "BED"}
                                        break
                                    end
                                end
                            end
                            if not target and battlefield.nearestThreat then
                                target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                            end
                        end
                        
                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude
                            
                            if dist > 4 then
                                local moveDir = (targetPos - hrp.Position).Unit
                                if hum then
                                    hum:Move(moveDir, true)
                                end
                                
                                local ray = Ray.new(hrp.Position, moveDir * 3)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                                if hit and hit.CanCollide then
                                    hum.Jump = true
                                end
                            else
                                if hum then hum:Move(Vector3_new(0,0,0), true) end
                            end

                            if target.type == "PLAYER" and _G.KillAura then
                                hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(targetPos.X, hrp.Position.Y, targetPos.Z))
                                _G.KillAuraTarget = target.part.Parent
                            end
                        else
                            if hum then hum:Move(Vector3_new(0,0,0), true) end
                        end
                    end
                end
            end)
        end
    end

    local function ToggleAutoPlay(state)
        _G.AI_Enabled = state
        if _G.AI_Enabled then
            _G.KillAuraRange = 22
            _G.KillAuraMaxTargets = 3
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            CatFunctions.ToggleSpeed(true)
            _G.AutoBuyPro = true
            _G.AutoArmor = true
            Blatant.ToggleAutoBuyPro(true)
            Blatant.ToggleAutoArmor(true)
            
            local lastPos = Vector3_new(0,0,0)
            local lastMoveTime = tick()

            task_spawn(function()
                while _G.AI_Enabled and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        -- Stuck Detection
                        if (hrp.Position - lastPos).Magnitude < 0.5 then
                            if tick() - lastMoveTime > 2 then
                                hum.Jump = true
                                hum:Move(Vector3_new(math.random(-1, 1), 0, math.random(-1, 1)), true)
                                lastMoveTime = tick()
                            end
                        else
                            lastPos = hrp.Position
                            lastMoveTime = tick()
                        end

                        local battlefield = CatFunctions.GetBattlefieldState()
                        local target = nil
                        
                        local nearResource = nil
                        for _, res in ipairs(battlefield.resources) do
                            if res.dist < 15 then
                                nearResource = res
                                break
                            end
                        end

                        if nearResource then
                             target = {part = nearResource.part, type = "RESOURCE"}
                             if nearResource.dist < 5 then
                                 hum:Move(Vector3_new(0,0,0), true)
                                 task_wait(0.5)
                             end
                        elseif battlefield.nearestThreat and battlefield.nearestThreat.dist < 60 then
                            target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                        elseif #battlefield.resources > 0 then
                            local bestRes = battlefield.resources[1]
                            for _, res in ipairs(battlefield.resources) do
                                local name = res.name:lower()
                                if name:find("emerald") or name:find("diamond") then
                                    bestRes = res
                                    break
                                end
                            end
                            target = {part = bestRes.part, type = "RESOURCE"}
                        elseif #battlefield.beds > 0 then
                            for _, bed in ipairs(battlefield.beds) do
                                local team = bed.part:GetAttribute("Team")
                                if team ~= lp.Team then
                                    target = {part = bed.part, type = "BED"}
                                    break
                                end
                            end
                        end

                        if target then
                            local path = PathfindingService:CreatePath({AgentHeight = 5, AgentRadius = 3, AgentCanJump = true})
                            local success, errorMessage = pcall(function()
                                path:ComputeAsync(hrp.Position, target.part.Position)
                            end)

                            if success and path.Status == Enum.PathStatus.Success then
                                local waypoints = path:GetWaypoints()
                                if #waypoints > 1 then
                                    local nextWaypoint = waypoints[2]
                                    local moveDir = (nextWaypoint.Position - hrp.Position).Unit
                                    hum:Move(moveDir, true)
                                    
                                    if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
                                        hum.Jump = true
                                    end

                                    if target.type == "PLAYER" then
                                        hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(target.part.Position.X, hrp.Position.Y, target.part.Position.Z))
                                        _G.KillAuraTarget = target.part.Parent
                                    end
                                end
                            else
                                local moveDir = (target.part.Position - hrp.Position).Unit
                                hum:Move(moveDir, true)
                            end

                            if hrp.Position.Y < 0 then
                                local spawnPos = lp.RespawnLocation and lp.RespawnLocation.Position or Vector3_new(0, 100, 0)
                                if (hrp.Position - spawnPos).Magnitude > 50 then
                                    if CatFunctions.ToggleFly then
                                        CatFunctions.ToggleFly(true)
                                        hrp.Velocity = Vector3_new(0, 50, 0)
                                    end
                                end
                            end
                        end
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
