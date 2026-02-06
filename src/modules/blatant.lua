-- Halol (V4.0) 暴力與 Bedwars 專用功能模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local BlatantModule = {}

function BlatantModule.Init(Gui, Notify)
    return {
        -- 全員墜空 (Void All)
        ToggleVoidAll = function(state)
            _G.VoidAll = state
            if not _G.VoidAll then return end
            
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local function Fling(target)
                if not _G.VoidAll then return end
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local thrp = target.Character.HumanoidRootPart
                    local bfv = Instance.new("BodyAngularVelocity")
                    Gui.ApplyProperties(bfv, {
                        AngularVelocity = Vector3_new(0, 99999, 0),
                        MaxTorque = Vector3_new(0, math.huge, 0),
                        P = math.huge,
                        Parent = hrp
                    })
                    hrp.CFrame = thrp.CFrame
                    task_wait(0.1)
                    bfv:Destroy()
                end
            end

            task_spawn(function()
                while _G.VoidAll do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if not _G.VoidAll then break end
                        if player ~= lp then
                            Fling(player)
                            task_wait(0.2)
                        end
                    end
                    task_wait(1)
                end
            end)
        end,

        -- 快速破床 (Fast Break)
        ToggleFastBreak = function(state)
            _G.FastBreak = state
            if not _G.FastBreak then return end
            task_spawn(function()
                while _G.FastBreak and task_wait(0.01) do
                    local char = lp.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                       ReplicatedStorage:FindFirstChild("HitBlock", true)
                        if remote then
                            local target = lp:GetMouse().Target
                            if target and target:IsA("BasePart") and (lp.Character.HumanoidRootPart.Position - target.Position).Magnitude < 25 then
                                remote:FireServer({["position"] = target.Position, ["block"] = target.Name})
                            end
                        end
                    end
                end
            end)
        end
    }
end

return BlatantModule
