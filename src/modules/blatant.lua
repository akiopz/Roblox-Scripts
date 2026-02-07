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
local UDim2 = UDim2 or env_global.UDim2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local BlatantModule = {}

function BlatantModule.Init(Gui, Notify, CatFunctions)
    return {
        ToggleGlobalResourceCollect = function(state)
                    env_global.GlobalResourceCollect = state
                    if not env_global.GlobalResourceCollect then return end
                    task.spawn(function()
                        while env_global.GlobalResourceCollect and task.wait(0.5) do
                            local char = lp.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp and CatFunctions and CatFunctions.GetBattlefieldState then
                                local battlefield = CatFunctions.GetBattlefieldState()
                                if #battlefield.resources > 0 then
                                    for _, res in ipairs(battlefield.resources) do
                                        if not env_global.GlobalResourceCollect then break end
                                        if res.part and res.part.Parent then
                                            -- 檢查是否為掉落物 (ItemDrops 或 Pickups 內)
                                            local isPickup = res.part:IsDescendantOf(workspace:FindFirstChild("ItemDrops")) or 
                                                           res.part:IsDescendantOf(workspace:FindFirstChild("Pickups"))
                                            
                                            if isPickup then
                                                hrp.CFrame = res.part.CFrame + Vector3_new(0, 1, 0)
                                                task_wait(0.2)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end,

        ToggleVoidAll = function(state)
            env_global.VoidAll = state
            if not env_global.VoidAll then return end
            
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local function Fling(target)
                if not env_global.VoidAll then return end
                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Team ~= lp.Team then
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
                while env_global.VoidAll do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if not env_global.VoidAll then break end
                        if player ~= lp then
                            Fling(player)
                            task_wait(0.2)
                        end
                    end
                    task_wait(1)
                end
            end)
        end,

        ToggleFastBreak = function(state)
            env_global.FastBreak = state
            if not env_global.FastBreak then return end
            task_spawn(function()
                while env_global.FastBreak and task_wait(0.01) do
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
        end,

        ToggleChestStealer = function(state)
            env_global.ChestStealer = state
            if not env_global.ChestStealer then return end
            task_spawn(function()
                while env_global.ChestStealer and task_wait(0.3) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local nearestChest = nil
                        local minDist = 20
                        
                        -- 優化：只搜索附近的箱子
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                                local d = (hrp.Position - v.Position).Magnitude
                                if d < minDist then
                                    minDist = d
                                    nearestChest = v
                                end
                            end
                        end

                        if nearestChest then
                            local remote = ReplicatedStorage:FindFirstChild("ChestCollectItem", true) or 
                                           ReplicatedStorage:FindFirstChild("TakeItemFromChest", true)
                            
                            if remote then
                                -- 使用遠程交互，不需要物理傳送 (防止被反作弊檢測)
                                remote:FireServer({["chest"] = nearestChest})
                                task_wait(0.1)
                            end
                        end
                    end
                end
            end)
        end,

        ToggleProjectileAura = function(state)
            env_global.ProjectileAura = state
            if not env_global.ProjectileAura then return end
            task_spawn(function()
                while env_global.ProjectileAura and task_wait(0.1) do
                    local char = lp.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool and (tool.Name:lower():find("bow") or tool.Name:lower():find("fireball") or tool.Name:lower():find("snowball")) then
                        local nearest = nil
                        local minDist = 100
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearest = p.Character.HumanoidRootPart
                                end
                            end
                        end
                        if nearest then
                            local pos = nearest.Position + (nearest.Velocity * (minDist / 100))
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
                        end
                    end
                end
            end)
        end,

        ToggleAutoBuy = function(state)
            env_global.AutoBuy = state
            if not env_global.AutoBuy then return end
            task_spawn(function()
                local itemsToBuy = {"item_wool", "sword_iron", "armor_iron", "armor_diamond"}
                while env_global.AutoBuy and task_wait(2) do
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or 
                                   ReplicatedStorage:FindFirstChild("BuyItem", true)
                    if remote then
                        for _, item in ipairs(itemsToBuy) do
                            if not env_global.AutoBuy then break end
                            remote:FireServer({["item"] = item})
                        end
                    end
                end
            end)
        end,

        ToggleSpeed = function(state)
            env_global.Speed = state
            if state then
                Notify("移動加強", "極速移動已開啟 (Boost 模式)", "Success")
                task_spawn(function()
                    local lastPos = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position
                    while env_global.Speed do
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if hum and root then
                            local speed = env_global.SpeedValue or 23
                            local moveDir = hum.MoveDirection
                            
                            -- Boost 模式：結合 Velocity 與 CFrame 微調
                            if moveDir.Magnitude > 0 then
                                root.Velocity = Vector3_new(moveDir.X * speed, root.Velocity.Y, moveDir.Z * speed)
                                
                                -- 繞過部分反作弊的位移補償
                                if (speed > 20) then
                                    root.CFrame = root.CFrame + (moveDir * 0.1)
                                end
                            end
                        end
                        RunService.Heartbeat:Wait()
                    end
                end)
            end
        end,

        ToggleFly = function(state)
            env_global.Fly = state
            if state then
                Notify("移動加強", "飛行模式已開啟 (Heatbeat 繞過模式)", "Success")
                task_spawn(function()
                    local speed = env_global.FlySpeed or 50
                    local verticalVelocity = 0
                    while env_global.Fly do
                        local char = lp.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local moveDir = Vector3_new(0,0,0)
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector:Cross(Vector3_new(0,1,0)) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector:Cross(Vector3_new(0,1,0)) end
                            
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then verticalVelocity = 1 elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then verticalVelocity = -1 else verticalVelocity = 0 end
                            
                            -- Heatbeat 繞過：模擬微小的上下抖動防止被檢測為掛載飛行
                            local jitter = math.sin(tick() * 20) * 0.05
                            root.Velocity = Vector3_new(0, 0, 0)
                            root.CFrame = root.CFrame + (moveDir * (speed / 10)) + Vector3_new(0, (verticalVelocity * (speed / 15)) + jitter, 0)
                        end
                        RunService.Heartbeat:Wait()
                    end
                end)
            end
        end,

        ToggleSpider = function(state)
            env_global.Spider = state
            if state then
                Notify("移動加強", "蜘蛛爬牆已開啟", "Success")
                task_spawn(function()
                    while env_global.Spider do
                        local char = lp.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                            if hit then
                                root.Velocity = Vector3_new(root.Velocity.X, 30, root.Velocity.Z)
                            end
                        end
                        task_wait(0.1)
                     end
                 end)
             
             end
         end,

        ToggleNoSlowdown = function(state)
            env_global.NoSlowDown = state
            if state then
                Notify("戰鬥加強", "無減速已開啟", "Success")
                task_spawn(function()
                    while env_global.NoSlowDown do
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = env_global.SpeedValue or 23
                        end
                        task_wait()
                    end
                end)
            end
        end,

        ToggleNoclip = function(state)
            env_global.NoClip = state
            if state then
                Notify("移動加強", "穿牆模式已開啟", "Success")
                local conn
                conn = RunService.Stepped:Connect(function()
                    if not env_global.NoClip then 
                        conn:Disconnect()
                        return 
                    end
                    local char = lp.Character
                    if char then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end,

         ToggleAutoArmor = function(state)
            CatFunctions.ToggleAutoArmor(state)
        end,

        ToggleAutoBuyPro = function(state)
            env_global.AutoBuyPro = state
            if not env_global.AutoBuyPro then return end
            task_spawn(function()
                local priority = {
                    {id = "emerald_sword", cost = 20, currency = "emerald"},
                    {id = "diamond_sword", cost = 4, currency = "emerald"},
                    {id = "iron_sword", cost = 70, currency = "iron"},
                    {id = "emerald_armor", cost = 40, currency = "emerald"},
                    {id = "diamond_armor", cost = 8, currency = "emerald"},
                    {id = "iron_armor", cost = 120, currency = "iron"},
                    {id = "telepearl", cost = 1, currency = "emerald"},
                    {id = "balloon", cost = 2, currency = "emerald"},
                    {id = "fireball", cost = 40, currency = "iron"},
                    {id = "wool_white", cost = 16, currency = "iron"}
                }
                
                while env_global.AutoBuyPro and task_wait(3) do
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or 
                                   ReplicatedStorage:FindFirstChild("BuyItem", true)
                    if remote then
                        for _, item in ipairs(priority) do
                            if not env_global.AutoBuyPro then break end
                            remote:FireServer({["item"] = item.id})
                        end
                    end
                end
            end)
        end,

        ToggleAutoToxic = function(state)
            CatFunctions.ToggleAutoToxic(state)
        end,

        ToggleAutoTool = function(state)
            CatFunctions.ToggleAutoTool(state)
        end,

        ToggleAutoWeapon = function(state)
            CatFunctions.ToggleAutoWeapon(state)
        end,

        ToggleAutoBlock = function(state)
            CatFunctions.ToggleAutoBlock(state)
        end
    }
end

return BlatantModule
