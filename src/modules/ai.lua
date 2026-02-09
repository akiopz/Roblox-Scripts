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
        -- 智慧評分系統
        local bestTarget = nil
        local highestScore = -math.huge
        local myTeam = lp.Team and lp.Team.Name:lower()
        
        -- 1. 評估床位 (Bed)
        for _, bed in ipairs(state.beds) do
            local team = bed.part.Parent and bed.part.Parent.Name:lower()
            if team and myTeam and not team:find(myTeam) then
                local score = 1000 - (bed.dist * 2) -- 距離越近分數越高
                if bed.dist < 30 then score = score + 500 end -- 極近距離優先級暴增
                
                if score > highestScore then
                    highestScore = score
                    bestTarget = bed
                    ai_state.currentTask = "ATTACKING_BED"
                end
            end
        end
        
        -- 2. 評估玩家 (Player)
        for _, threat in ipairs(state.threats or {}) do
            local p = Players:GetPlayerFromCharacter(threat.part.Parent)
            if p and p.Team ~= lp.Team then
                local score = 500 - (threat.dist * 3)
                -- 優先獵殺殘血玩家
                local hum = threat.part.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < 40 then score = score + 300 end
                -- 如果正在攻擊我們，優先級提高
                if threat.dist < 15 then score = score + 400 end
                
                if score > highestScore then
                    highestScore = score
                    bestTarget = threat
                    ai_state.currentTask = "ATTACKING_PLAYER"
                end
            end
        end
        
        -- 3. 評估資源 (Resource) - 僅在無威脅且無目標床時
        if not bestTarget and #state.resources > 0 then
            local res = state.resources[1]
            bestTarget = res
            ai_state.currentTask = "FARMING"
        end
        
        return bestTarget, ai_state.currentTask
    end

    -- 強化：路徑規劃與導航
    local function computePath(targetPos)
        local path = PathfindingService:CreatePath({
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
            AgentJumpHeight = 12,
            AgentMaxSlope = 50,
            Costs = {
                Water = 20,
                Neon = 10 -- 假設某些危險方塊
            }
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
            Notify("AI 主宰", "上帝模式 AI 已啟動：全自動戰局接管中...", "Success")
            
            -- 啟動配套功能
            env_global.KillAuraRange = 22
            env_global.KillAuraMaxTargets = 8
            env_global.SpeedValue = 28
            
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleBedNuker(true)
            CatFunctions.ToggleAutoBuy(true)
            CatFunctions.ToggleAntiVoid(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleAutoTool(true)
            
            task_spawn(function()
                while env_global.GodModeAI and task_wait(0.05) do
                    pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if not hrp or not hum or hum.Health <= 0 then return end

                        -- 戰場分析
                        local battleState = CatFunctions.GetBattlefieldState()
                        local target, taskType = getBestTarget(battleState)
                        ai_state.target = target
                        
                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude
                            
                            -- 1. 智慧移動模式切換
                            -- 檢查是否有地面
                            local ray = Ray.new(hrp.Position + Vector3_new(0, -2, 0), Vector3_new(0, -20, 0))
                            local floor = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                            
                            if not floor or dist > 40 or (targetPos.Y > hrp.Position.Y + 10) then
                                if not env_global.Fly then CatFunctions.ToggleFly(true) end
                            elseif dist < 12 and floor then
                                if env_global.Fly then CatFunctions.ToggleFly(false) end
                            end

                            -- 2. 執行導航
                            if dist > 3 then
                                local moveDir = (targetPos - hrp.Position).Unit
                                if env_global.Fly then
                                    -- 混合飛行：CFrame 推進 + 物理速度
                                    local flySpeed = env_global.FlySpeed or 60
                                    hrp.Velocity = moveDir * flySpeed
                                    hrp.CFrame = CFrame_new(hrp.Position + (moveDir * 1.5), targetPos)
                                else
                                    -- 地面精準導航
                                    if not ai_state.path or (ai_state.target and ai_state.target.part ~= target.part) then
                                        computePath(targetPos)
                                    end

                                    if ai_state.path and ai_state.waypointIndex <= #ai_state.path then
                                        local waypoint = ai_state.path[ai_state.waypointIndex]
                                        local wPos = waypoint.Position
                                        local wDist = (hrp.Position - wPos).Magnitude
                                        local wDir = (wPos - hrp.Position).Unit
                                        
                                        hum:Move(wDir, true)
                                        if waypoint.Action == Enum.PathWaypointAction.Jump or wPos.Y > hrp.Position.Y + 2 then
                                            hum.Jump = true
                                        end
                                        
                                        if wDist < 4 then
                                            ai_state.waypointIndex = ai_state.waypointIndex + 1
                                        end
                                    else
                                        -- 備用移動：直接朝向
                                        hum:Move(moveDir, true)
                                        if (targetPos.Y > hrp.Position.Y + 3) then hum.Jump = true end
                                    end
                                end
                            end

                            -- 3. 戰鬥鎖定優化
                            if taskType == "ATTACKING_PLAYER" then
                                env_global.KillAuraTarget = target.part.Parent
                                -- 智慧走位：繞著敵人轉 (Strafe)
                                if dist < 15 and not env_global.Fly then
                                    local strafeDir = hrp.CFrame.RightVector * (math.sin(tick() * 5) * 10)
                                    hum:Move(moveDir + strafeDir, true)
                                end
                            end
                        end

                        -- 4. 卡住檢測優化 (自動開啟穿牆飛行脫困)
                        if (hrp.Position - ai_state.lastPos).Magnitude < 0.2 and target then
                            ai_state.stuckTime = ai_state.stuckTime + 0.05
                            if ai_state.stuckTime > 1.5 then
                                CatFunctions.ToggleFly(true)
                                hrp.CFrame = hrp.CFrame * CFrame_new(0, 10, 0)
                                ai_state.stuckTime = 0
                                ai_state.path = nil -- 重置路徑
                            end
                        else
                            ai_state.stuckTime = 0
                        end
                        ai_state.lastPos = hrp.Position
                    end)
                end
            end)
        else
            -- 關閉所有自動化模組
            CatFunctions.ToggleKillAura(false)
            CatFunctions.ToggleBedNuker(false)
            CatFunctions.ToggleFly(false)
            CatFunctions.ToggleAutoBuy(false)
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
