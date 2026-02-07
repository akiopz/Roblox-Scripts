---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local game = game or getgenv().game
local workspace = workspace or getgenv().workspace
local task = task or getgenv().task
local Vector3 = Vector3 or getgenv().Vector3
local Ray = Ray or getgenv().Ray
local math = math or getgenv().math
local tick = tick or getgenv().tick or os.time
local pairs = pairs or getgenv().pairs
local ipairs = ipairs or getgenv().ipairs
local table = table or getgenv().table
local string = string or getgenv().string
local pcall = pcall or getgenv().pcall

local functionsModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local lplr = Players.LocalPlayer
local Vector3_new = Vector3.new

function functionsModule.Init(env)
    local CatFunctions = {}
    local Notify = env.Notify

    CatFunctions.ToggleKillAura = function(state)
        _G.KillAura = state
        if not _G.KillAura then return end
        task.spawn(function()
            while _G.KillAura and task.wait() do
                local target = _G.KillAuraTarget or nil
                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp and (lplr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude > (_G.KillAuraRange or 18) then
                        target = nil
                    end
                else
                    target = nil
                end

                if not target then
                    local dist = _G.KillAuraRange or 18
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then
                                target = v.Character
                                dist = d
                            end
                        end
                    end
                end

                if target then
                    local delay = math.random(8, 12) / 100
                    task.wait(delay)
                    local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                                   ReplicatedStorage:FindFirstChild("CombatRemote", true)
                    if remote then
                        remote:FireServer({["entity"] = target})
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleScaffold = function(state)
        _G.Scaffold = state
        if not _G.Scaffold then return end
        task.spawn(function()
            while _G.Scaffold and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local pos = hrp.Position + (hrp.CFrame.LookVector * 1) - Vector3_new(0, 3.5, 0)
                    local blockPos = Vector3_new(math.floor(pos.X/3)*3, math.floor(pos.Y/3)*3, math.floor(pos.Z/3)*3)
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        remote:FireServer({["blockType"] = "wool_white", ["position"] = blockPos})
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleInfiniteJump = function(state)
        _G.InfiniteJump = state
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if _G.InfiniteJump and lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end

    CatFunctions.ToggleNoSlowDown = function(state)
        _G.NoSlowDown = state
        task.spawn(function()
            while _G.NoSlowDown and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = _G.SpeedValue or 23
                end
            end
        end)
    end

    CatFunctions.ToggleReach = function(state)
        _G.Reach = state
        if not _G.Reach then
            _G.KillAuraRange = 18
            return
        end
        _G.KillAuraRange = 25
    end

    CatFunctions.ToggleAutoClicker = function(state)
        _G.AutoClicker = state
        if not _G.AutoClicker then return end
        task.spawn(function()
            while _G.AutoClicker and task.wait(1 / (_G.KillAuraCPS or 10)) do
                local char = lplr.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end)
    end

    CatFunctions.ToggleLongJump = function(state)
        _G.LongJump = state
        if not _G.LongJump then return end
        task.spawn(function()
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = lplr.Character.HumanoidRootPart
                local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                hum:ChangeState("Jumping")
                hrp.Velocity = hrp.Velocity + (hrp.CFrame.LookVector * 50) + Vector3_new(0, 30, 0)
                task.wait(0.5)
                _G.LongJump = false
            end
        end)
    end

    CatFunctions.ToggleAutoBridge = function(state)
        _G.AutoBridge = state
        if not _G.AutoBridge then return end
        task.spawn(function()
            while _G.AutoBridge and task.wait(0.1) do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local pos = hrp.Position + (hrp.CFrame.LookVector * 3) - Vector3_new(0, 4, 0)
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        remote:FireServer({["blockType"] = "wool_white", ["position"] = pos})
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoResourceFarm = function(state)
        _G.AutoResourceFarm = state
        if not _G.AutoResourceFarm then return end
        task.spawn(function()
            while _G.AutoResourceFarm and task.wait(1) do
                local state = CatFunctions.GetBattlefieldState()
                if #state.resources > 0 then
                    local target = state.resources[1]
                    local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and target.dist > 5 then
                        local tween = TweenService:Create(hrp, TweenInfo.new(target.dist / 20), {CFrame = target.part.CFrame + Vector3_new(0, 3, 0)})
                        tween:Play()
                        tween.Completed:Wait()
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleDamageIndicator = function(state)
        _G.DamageIndicator = state
    end

    CatFunctions.ToggleSpider = function(state)
        _G.Spider = state
        task.spawn(function()
            while _G.Spider and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
                    local hit = workspace:FindPartOnRay(ray, lplr.Character)
                    if hit then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 30, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNoFall = function(state)
        _G.NoFall = state
        if not _G.NoFall then return end
        task.spawn(function()
            while _G.NoFall and task.wait(0.5) do
                local remote = ReplicatedStorage:FindFirstChild("FallDamage", true) or 
                               ReplicatedStorage:FindFirstChild("GroundHit", true)
                if remote then
                    remote:FireServer({["damage"] = 0, ["distance"] = 0})
                end
            end
        end)
    end

    CatFunctions.ToggleVelocity = function(state)
        _G.Velocity = state
        if not _G.Velocity then return end
        task.spawn(function()
            while _G.Velocity and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local horizontal = _G.VelocityHorizontal or 15
                    local vertical = _G.VelocityVertical or 100
                    hrp.Velocity = Vector3_new(hrp.Velocity.X * (horizontal / 100), hrp.Velocity.Y * (vertical / 100), hrp.Velocity.Z * (horizontal / 100))
                end
            end
        end)
    end

    CatFunctions.ToggleSpeed = function(state)
        _G.Speed = state
        if not _G.Speed then return end
        task.spawn(function()
            local count = 0
            while _G.Speed and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    count = count + 1
                    if count % 3 == 0 then
                        hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * (_G.SpeedValue or 0.5))
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleFly = function(state)
        _G.Fly = state
        if not _G.Fly then return end
        task.spawn(function()
            while _G.Fly and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local vel = hrp.Velocity
                    hrp.Velocity = Vector3_new(vel.X, 2 + math.sin(tick() * 10) * 0.5, vel.Z)
                end
            end
        end)
    end

    CatFunctions.ToggleAutoConsume = function(state)
        _G.AutoConsume = state
        if not _G.AutoConsume then return end
        task.spawn(function()
            while _G.AutoConsume and task.wait(1) do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum.Health < hum.MaxHealth * 0.5 then
                        local remote = ReplicatedStorage:FindFirstChild("EatItem", true) or 
                                       ReplicatedStorage:FindFirstChild("ConsumeItem", true)
                        if remote then
                            remote:FireServer({["item"] = "apple"})
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleBedNuker = function(state)
        _G.BedNuker = state
        if not _G.BedNuker then return end
        task.spawn(function()
            while _G.BedNuker and task.wait(0.2) do
                local battlefield = CatFunctions.GetBattlefieldState()
                for _, bed in ipairs(battlefield.beds) do
                    if bed.dist < 25 then
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                       ReplicatedStorage:FindFirstChild("HitBlock", true)
                        if remote then
                            remote:FireServer({["position"] = bed.part.Position, ["block"] = bed.part.Name})
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoBalloon = function(state)
        _G.AutoBalloon = state
        if not _G.AutoBalloon then return end
        task.spawn(function()
            while _G.AutoBalloon and task.wait(0.5) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -50 then
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
                    if remote then
                        remote:FireServer({["item"] = "balloon"})
                    end
                    task.wait(0.2)
                    local balloon = char:FindFirstChild("balloon") or lplr.Backpack:FindFirstChild("balloon")
                    if balloon then
                        balloon.Parent = char
                        balloon:Activate()
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNuker = function(state)
        _G.Nuker = state
        if not _G.Nuker then return end
        task.spawn(function()
            while _G.Nuker and task.wait(0.1) do
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetPartBoundsInRadius(hrp.Position, 15)) do
                        if v:IsA("BasePart") and v.CanCollide and not v:IsDescendantOf(lplr.Character) then
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then
                                remote:FireServer({["position"] = v.Position, ["block"] = v.Name})
                            end
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.GetBattlefieldState = function()
        local state = {
            targets = {},
            resources = {},
            beds = {},
            nearestThreat = nil,
            isBeingTargeted = false
        }
        local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return state end

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = v.Character.HumanoidRootPart
                local dist = (hrp.Position - targetHrp.Position).Magnitude
                local threat = {hrp = targetHrp, dist = dist, player = v}
                table.insert(state.targets, threat)
                if not state.nearestThreat or dist < state.nearestThreat.dist then
                    state.nearestThreat = threat
                end
                if dist < 20 then
                    state.isBeingTargeted = true
                end
            end
        end

        local searchFolders = {
            workspace:FindFirstChild("ItemDrops"),
            workspace:FindFirstChild("Generators"),
            workspace:FindFirstChild("Beds"),
            workspace:FindFirstChild("Items"),
            workspace:FindFirstChild("Pickups")
        }

        for _, folder in ipairs(searchFolders) do
            if folder then
                for _, v in pairs(folder:GetDescendants()) do
                    local name = v.Name:lower()
                    if name:find("diamond") or name:find("emerald") or name:find("iron") then
                        local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if p then
                            table.insert(state.resources, {part = p, name = v.Name, dist = (hrp.Position - p.Position).Magnitude})
                        end
                    end
                    if name:find("bed") then
                        local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if p then
                            table.insert(state.beds, {part = p, dist = (hrp.Position - p.Position).Magnitude})
                        end
                    end
                end
            end
        end

        if #state.resources == 0 or #state.beds == 0 then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    local name = v.Name:lower()
                    if name:find("diamond") or name:find("emerald") or name:find("iron") then
                        local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if p then
                            table.insert(state.resources, {part = p, name = v.Name, dist = (hrp.Position - p.Position).Magnitude})
                        end
                    end
                    if name:find("bed") then
                        local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if p then
                            table.insert(state.beds, {part = p, dist = (hrp.Position - p.Position).Magnitude})
                        end
                    end
                end
            end
        end
        
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)
        
        return state
    end

    return CatFunctions
end

return functionsModule
