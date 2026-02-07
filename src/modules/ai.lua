---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
---@return env_global
local function get_env_safe()
    ---@type env_global
    local env = (getgenv or function() return _G end)() --[[@as env_global]]
    return env
end

local env_global = get_env_safe()
local game = game or env_global.game
local task = task or env_global.task
local Vector3 = Vector3 or env_global.Vector3
local CFrame = CFrame or env_global.CFrame
local Enum = Enum or env_global.Enum
local pcall = pcall or env_global.pcall

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer
local task_spawn = task.spawn
local task_wait = task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local AIModule = {}

function AIModule.Init(CatFunctions, _)
    -- AI 狀態管理
    local ai_state = {
        currentTask = "IDLE", -- IDLE, ATTACKING_BED, ATTACKING_PLAYER, FARMING, RETREATING
        target = nil,
        lastPos = Vector3_new(0,0,0),
        stuckTime = 0,
        path = nil,
        waypointIndex = 1
    }

    local function getBestTarget(state)
        -- 優先級：床位 (近距離) > 威脅 (極近) > 床位 (遠距離) > 威脅 (中距離) > 資源
        if #state.beds > 0 then
            local nearestBed = state.beds[1]
            if nearestBed.dist < 50 then return nearestBed, "ATTACKING_BED" end
        end

        if state.nearestThreat and state.nearestThreat.dist < 20 then
            return state.nearestThreat, "ATTACKING_PLAYER"
        end

        if #state.beds > 0 then
            return state.beds[1], "ATTACKING_BED"
        end

        if state.nearestThreat then
            return state.nearestThreat, "ATTACKING_PLAYER"
        end

        if #state.resources > 0 then
            return state.resources[1], "FARMING"
        end

        return nil, "IDLE"
    end

    -- 強化：路徑規劃與導航
    local function computePath(targetPos)
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentJumpHeight = 10,
            AgentMaxSlope = 45,
        })
        
        local success, _ = pcall(function()
            path:ComputeAsync(lp.Character.HumanoidRootPart.Position, targetPos)
        end)

        if success and path.Status == Enum.PathStatus.Success then
            ai_state.path = path:GetWaypoints()
            ai_state.waypointIndex = 1
            return true
        end
        return false
    end

    local function ToggleGodMode(state)
        env_global.GodModeAI = state
        if env_global.GodModeAI then
            -- 啟動配套功能
            env_global.KillAuraRange = 25
            env_global.KillAuraMaxTargets = 5
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleReach(true)
            CatFunctions.ToggleAutoTool(true)
            CatFunctions.ToggleAutoArmor(true)
            CatFunctions.ToggleAutoBuyUpgrades(true)
            
            task_spawn(function()
                while env_global.GodModeAI and task_wait(0.1) do
                    pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if not hrp or not hum or hum.Health <= 0 then return end

                        -- 自動旋轉
                        hum.AutoRotate = true

                        -- 戰場分析
                        local battleState = CatFunctions.GetBattlefieldState()
                        local target, taskType = getBestTarget(battleState)
                        ai_state.currentTask = taskType
                        ai_state.target = target

                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude

                            -- 智慧型移動決策
                            if dist > 30 then
                                if not env_global.Fly then CatFunctions.ToggleFly(true) end
                            elseif dist < 8 then
                                if env_global.Fly then CatFunctions.ToggleFly(false) end
                            end

                            -- 執行移動 (上帝模式優先使用 CFrame 瞬移/滑翔)
                            if dist > 4 then
                                local moveDir = (targetPos - hrp.Position).Unit
                                if env_global.Fly then
                                    -- 平滑滑翔至目標
                                    local nextPos = hrp.Position + (moveDir * 2.5)
                                    hrp.CFrame = CFrame_new(nextPos, targetPos)
                                    hum:Move(moveDir, true)
                                else
                                    -- 地面移動優化：使用路徑導航
                                    if not ai_state.path or (ai_state.target and ai_state.target.part.Position ~= targetPos) then
                                        computePath(targetPos)
                                    end

                                    if ai_state.path and ai_state.waypointIndex <= #ai_state.path then
                                        local waypoint = ai_state.path[ai_state.waypointIndex]
                                        local wPos = waypoint.Position
                                        local wDist = (hrp.Position - wPos).Magnitude
                                        
                                        local wDir = (wPos - hrp.Position).Unit
                                        hum:Move(wDir, true)
                                        
                                        if waypoint.Action == Enum.PathWaypointAction.Jump then
                                            hum.Jump = true
                                        end
                                        
                                        if wDist < 3 then
                                            ai_state.waypointIndex = ai_state.waypointIndex + 1
                                        end
                                    else
                                        -- 回退到直接移動
                                        hum:Move(moveDir, true)
                                        if (targetPos.Y > hrp.Position.Y + 2) then hum.Jump = true end
                                    end
                                end
                            end

                            -- 戰鬥目標鎖定
                            if taskType == "ATTACKING_PLAYER" then
                                env_global.KillAuraTarget = target.part.Parent
                                -- 自動切換至劍
                                CatFunctions.ToggleAutoWeapon(true)
                            elseif taskType == "ATTACKING_BED" then
                                -- 自動切換至斧頭或鎬子
                                CatFunctions.ToggleAutoTool(true)
                            end
                        end

                        -- 卡住檢測與處理
                        if (hrp.Position - ai_state.lastPos).Magnitude < 0.5 then
                            ai_state.stuckTime = ai_state.stuckTime + 0.1
                            if ai_state.stuckTime > 2 then
                                hum.Jump = true
                                hrp.CFrame = hrp.CFrame * CFrame_new(0, 5, 0)
                                ai_state.stuckTime = 0
                            end
                        else
                            ai_state.stuckTime = 0
                        end
                        ai_state.lastPos = hrp.Position
                    end)
                end
            end)
            Notify("AI 主宰", "上帝模式 AI 已啟動 - 接管全場戰鬥與資源", "Success")
        else
            CatFunctions.ToggleKillAura(false)
            CatFunctions.ToggleFly(false)
            Notify("AI 主宰", "上帝模式 AI 已關閉", "Info")
        end
    end

    local function ToggleAutoPlay(state)
        env_global.AI_Enabled = state
        if env_global.AI_Enabled then
            Notify("AI 主宰", "自動玩遊戲已啟動 - 正在分析最佳路徑", "Success")
            task_spawn(function()
                while env_global.AI_Enabled and task_wait(0.3) do
                    pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if not hrp or not hum or hum.Health <= 0 then return end

                        local battleState = CatFunctions.GetBattlefieldState()
                        local target, taskType = getBestTarget(battleState)

                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude

                            -- 根據任務類型決定速度
                            if dist > 50 then
                                if not env_global.Speed then CatFunctions.ToggleSpeed(true) end
                            else
                                if env_global.Speed then CatFunctions.ToggleSpeed(false) end
                            end

                            -- 移動邏輯：優先使用路徑導航
                            if not ai_state.path or (ai_state.target and ai_state.target.part.Position ~= targetPos) then
                                computePath(targetPos)
                            end

                            if ai_state.path and ai_state.waypointIndex <= #ai_state.path then
                                local waypoint = ai_state.path[ai_state.waypointIndex]
                                local wPos = waypoint.Position
                                local wDist = (hrp.Position - wPos).Magnitude
                                local wDir = (wPos - hrp.Position).Unit
                                
                                hum:Move(wDir, true)
                                if waypoint.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                                
                                if wDist < 3 then
                                    ai_state.waypointIndex = ai_state.waypointIndex + 1
                                end
                            else
                                -- 簡單避障
                                local moveDir = (targetPos - hrp.Position).Unit
                                hum:Move(moveDir, true)
                                if (hrp.Position - ai_state.lastPos).Magnitude < 1 then
                                    hum.Jump = true
                                end
                            end
                        end
                        ai_state.lastPos = hrp.Position
                    end)
                end
            end)
        else
            CatFunctions.ToggleFly(false)
            CatFunctions.ToggleSpeed(false)
            Notify("AI 主宰", "自動玩遊戲已關閉", "Info")
        end
    end

    return {
        ToggleGodMode = ToggleGodMode,
        ToggleAutoPlay = ToggleAutoPlay,
        Stop = function()
            ToggleGodMode(false)
            ToggleAutoPlay(false)
        end
    }
end

return AIModule
