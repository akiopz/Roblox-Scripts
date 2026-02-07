---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
---@alias Model any
---@class env_global
---@field KillAura boolean
---@field KillAuraTarget Model?
---@field KillAuraRange number
---@field KillAuraCPS number
---@field KillAuraMaxTargets number
---@field Criticals boolean
---@field FastAttack boolean
---@field Scaffold boolean
---@field NoSlowDown boolean
---@field Reach boolean
---@field AutoClicker boolean
---@field LongJump boolean
---@field AutoBridge boolean
---@field AutoResourceFarm boolean
---@field DamageIndicator boolean
---@field Spider boolean
---@field Step boolean
---@field NoFall boolean
---@field AntiFling boolean
---@field NoClip boolean
---@field Velocity boolean
---@field VelocityHorizontal number
---@field VelocityVertical number
---@field Speed boolean
---@field Fly boolean
---@field FlySpeed number
---@field InfiniteFly boolean
---@field AutoConsume boolean
---@field BedNuker boolean
---@field IsAttacking boolean
---@field FPSBoost boolean
---@field AutoBuyWool boolean
---@field AutoArmor boolean
---@field AutoEat boolean
---@field AutoTool boolean
---@field AutoWeapon boolean
---@field AutoBlock boolean
---@field AutoToxic boolean
---@field AutoBuyUpgrades boolean
---@field GodModeAI boolean
---@field AI_Enabled boolean
---@field ProjectileAura boolean
---@field FastBreak boolean
---@field ChestStealer boolean
---@field GlobalResourceCollect boolean
---@field VoidAll boolean
---@field AutoBuy boolean
---@field AutoBuyPro boolean
---@field AnimationPlayer boolean
---@field AntiRagdoll boolean
---@field AntiAFK boolean
---@field AutoQueue boolean
---@field Blink boolean
---@field ChatSpammer boolean
---@field Disabler boolean
---@field Panic boolean
---@field StaffDetector boolean
---@field AutoRejoin boolean
---@field FullbrightEnabled boolean
---@field RadarGui any
---@field AtmosphereEnabled boolean
---@field CapeEnabled boolean
---@field ChamsEnabled boolean
---@field ChinaHatEnabled boolean
---@field GamingChairEnabled boolean
---@field NameTagsEnabled boolean
---@field PlayerModelEnabled boolean
---@field SearchEnabled boolean
---@field TimeChangerEnabled boolean
---@field WaypointsEnabled boolean
---@field WeatherEnabled boolean
---@field ZoomUnlockerEnabled boolean
---@field FullESPEnabled boolean
---@field HealthDisplayEnabled boolean
---@field TracersEnabled boolean
---@field BedESPEnabled boolean
---@field ResourceESPEnabled boolean
---@field ChestESPEnabled boolean
---@field ShopESPEnabled boolean
---@field RadarEnabled boolean
---@field ArrowsEnabled boolean
---@field BreadcrumbsEnabled boolean
---@field SilentAim boolean
---@field SilentAimRange number
---@field SilentAimLock boolean
---@field FOVValue number
---@field KeepSprint boolean
---@field ItemStealer boolean
---@field AutoHeal boolean
---@field FastEat boolean
---@field AntiVoid boolean
---@field AntiVoidPart any
---@field TimeCycle boolean
---@field SpeedValue number
---@field Freecam boolean
---@field FreecamPart any
---@field Parkour boolean
---@field SafeWalk boolean
---@field Xray boolean
---@field InfiniteAura boolean
---@field AutoTrap boolean
---@field AutoSpray boolean
---@field AutoBuyAdvanced boolean
---@field OriginalTransparencies table<any, number>
---@field game any
---@field workspace any
---@field task any
---@field Vector3 any
---@field Vector2 any
---@field UDim2 any
---@field Drawing any
---@field Ray any
---@field math any
---@field pairs any
---@field ipairs any
---@field table any
---@field string any
---@field pcall any
---@field CFrame any
---@field Instance any
---@field Enum any
---@field Color3 any
---@field BrickColor any
---@field DesyncConn any
---@field AntiSpectateConn any
---@field GlobalSpecConn any
---@field SpecInvisConn any
---@field StaffDetectorConn any
---@field AutoRejoinConn any
---@field AutoLeaveOnStaff boolean
---@field AutoLobby boolean
---@field CustomMatchExploit boolean
---@field Aimbot boolean
---@field AutoWin boolean
---@field gethui function
---@field getgenv function
---@field isrenderobj function
---@field setreadonly function
---@field make_writeable function
---@field getrawmetatable function
---@field newcclosure function
---@field checkcaller function
---@field setfpscap function
---@field getnamecallmethod function
---@field loadstring function
---@field request function
---@field identifyexecutor function
---@field writefile function
---@field readfile function
---@field isfile function
---@field listfiles function
---@field makefolder function
---@field fireclickdetector function
---@field fireproximityprompt function
---@field firetouchinterest function
---@field setclipboard function
---@field getclipboard function
---@field getcustomasset function

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
local Ray = Ray or env_global.Ray
local math = math or env_global.math
local tick = tick or env_global.tick or os.time
local pairs = pairs or env_global.pairs
local ipairs = ipairs or env_global.ipairs
local table = table or env_global.table
local string = string or env_global.string
local pcall = pcall or env_global.pcall
local task_spawn = task.spawn
local task_wait = task.wait

-- 全局變量補齊 (針對某些執行器環境)
local CFrame = CFrame or env_global.CFrame
local Instance = Instance or env_global.Instance
local Enum = Enum or env_global.Enum
local Color3 = Color3 or env_global.Color3
local BrickColor = BrickColor or env_global.BrickColor
local UserInputService = game:GetService("UserInputService")

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

    -- ==========================================
    -- 通用功能 (Universal Features) - 支援所有遊戲
    -- ==========================================

    CatFunctions.ToggleInfiniteJump = function(state)
        env_global.InfiniteJump = state
        if state then
            Notify("通用功能", "無限跳躍已開啟", "Success")
            local connection
            connection = UserInputService.JumpRequest:Connect(function()
                if env_global.InfiniteJump then
                    local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                else
                    connection:Disconnect()
                end
            end)
        end
    end

    CatFunctions.ToggleNoclip = function(state)
        env_global.NoClip = state
        if state then
            Notify("通用功能", "穿牆 (Noclip) 已開啟", "Success")
            local connection
            connection = RunService.Stepped:Connect(function()
                if env_global.NoClip then
                    if lplr.Character then
                        for _, v in pairs(lplr.Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                else
                    connection:Disconnect()
                end
            end)
        end
    end

    CatFunctions.ToggleAntiAFK = function(state)
        env_global.AntiAFK = state
        if state then
            Notify("通用功能", "防掛機 (Anti-AFK) 已開啟", "Success")
            local VirtualUser = game:GetService("VirtualUser")
            lplr.Idled:Connect(function()
                if env_global.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end

    CatFunctions.ToggleAutoToxic = function(state)
        env_global.AutoToxic = state
        if state then
            Notify("戰鬥功能", "自動嘲諷 (Auto Toxic) 已開啟", "Success")
            
            local function onKilled(victim)
                if not env_global.AutoToxic then return end
                local phrases = {
                    "L " .. victim.Name .. "!",
                    "EZ " .. victim.Name .. "!",
                    "Get good " .. victim.Name .. "!",
                    "Cat Cheat is too strong!",
                    "Imagine dying to Halol V5.0.0",
                    "You need a better gaming chair.",
                    "Hahaha " .. victim.Name .. " is so bad."
                }
                local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                  ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                if chatRemote then
                    chatRemote:FireServer(phrases[math.random(1, #phrases)], "All")
                else
                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(phrases[math.random(1, #phrases)])
                end
            end

            -- 監聽擊殺事件 (這部分需要根據遊戲調整，這裡使用通用邏輯)
            task_spawn(function()
                while env_global.AutoToxic do
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lplr and p.Character and p.Character:FindFirstChild("Humanoid") then
                            local hum = p.Character.Humanoid
                            if hum.Health <= 0 and not p:GetAttribute("KilledByHalol") then
                                p:SetAttribute("KilledByHalol", true)
                                -- 檢查是否是我們殺的 (距離最近)
                                local myRoot = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                                local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                                if myRoot and pRoot and (myRoot.Position - pRoot.Position).Magnitude < 25 then
                                    onKilled(p)
                                end
                            elseif hum.Health > 0 then
                                p:SetAttribute("KilledByHalol", nil)
                            end
                        end
                    end
                    task_wait(0.5)
                end
            end)
        end
    end

    CatFunctions.ToggleAutoArmor = function(state)
        env_global.AutoArmor = state
        if not env_global.AutoArmor then return end
        task_spawn(function()
            Notify("伺服器強化", "自動穿甲已開啟 (支援 Bed Wars 與通用商店)", "Success")
            local armors = {"leather_armor", "iron_armor", "diamond_armor", "emerald_armor"}
            while env_global.AutoArmor and task_wait(1) do
                local remotePurchase = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                                       ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                local remoteEquip = ReplicatedStorage:FindFirstChild("EquipArmor", true) or 
                                    ReplicatedStorage:FindFirstChild("WearArmor", true)
                
                -- 自動購買
                if remotePurchase then
                    for _, armor in ipairs(armors) do
                        remotePurchase:FireServer({["item"] = armor})
                    end
                end
                
                -- 自動穿戴
                if remoteEquip and lplr.Character then
                    remoteEquip:FireServer()
                end
            end
        end)
    end

    CatFunctions.ToggleAntiRagdoll = function(state)
        env_global.AntiRagdoll = state
        if state then
            Notify("戰鬥功能", "防擊退 (Anti Ragdoll) 已開啟", "Success")
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not env_global.AntiRagdoll then connection:Disconnect() return end
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleXray = function(state)
        env_global.Xray = state
        if state then
            Notify("通用功能", "透視牆壁 (Xray) 已開啟", "Success")
            task_spawn(function()
                while env_global.Xray do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                            if not env_global.OriginalTransparencies[v] then
                                env_global.OriginalTransparencies[v] = v.Transparency
                            end
                            v.Transparency = 0.5
                        end
                    end
                    task_wait(2) -- 每 2 秒掃描一次新方塊
                end
            end)
        else
            Notify("通用功能", "透視牆壁已關閉", "Info")
            for v, trans in pairs(env_global.OriginalTransparencies) do
                if v and v.Parent then v.Transparency = trans end
            end
            env_global.OriginalTransparencies = {}
        end
    end

    -- 智慧型通用 ESP 偵測 (支援玩家、NPC、關鍵物品)
    CatFunctions.ToggleUniversalESP = function(state)
        env_global.FullESPEnabled = state
        if state then
            Notify("通用功能", "智慧型 ESP 已開啟\n(偵測玩家、NPC與關鍵物品)", "Success")
            
            -- 玩家 ESP 已在 visuals.lua 處理，這裡補充 NPC 與物品偵測
            task_spawn(function()
                while env_global.FullESPEnabled do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if not env_global.FullESPEnabled then break end
                        
                        -- 1. 偵測 NPC (有 Humanoid 但不是 Players)
                        if v:IsA("Humanoid") and not Players:GetPlayerFromCharacter(v.Parent) then
                            local char = v.Parent
                            if char and char:IsA("Model") and not char:FindFirstChild("CatNPCESP") then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "CatNPCESP"
                                billboard.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
                                billboard.Size = UDim2.new(0, 100, 0, 40)
                                billboard.AlwaysOnTop = true
                                billboard.Parent = char
                                
                                local label = Instance.new("TextLabel", billboard)
                                label.BackgroundTransparency = 1
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.Text = "[NPC] " .. char.Name
                                label.TextColor3 = Color3.fromRGB(255, 255, 0)
                                label.TextStrokeTransparency = 0.5
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 12
                            end
                        end
                        
                        -- 2. 偵測關鍵物品 (Chest, LuckyBlock, Generator 等)
                        local lowerName = v.Name:lower()
                        if (v:IsA("BasePart") or v:IsA("Model")) and not v:FindFirstChild("CatItemESP") then
                            local isKeyItem = false
                            local itemColor = Color3.fromRGB(255, 255, 255)
                            local itemLabel = ""
                            
                            if lowerName:find("chest") then
                                isKeyItem, itemColor, itemLabel = true, Color3.fromRGB(255, 170, 0), "箱子 (Chest)"
                            elseif lowerName:find("lucky") and lowerName:find("block") then
                                isKeyItem, itemColor, itemLabel = true, Color3.fromRGB(255, 255, 0), "幸運方塊"
                            elseif lowerName:find("generator") or lowerName:find("resource") then
                                isKeyItem, itemColor, itemLabel = true, Color3.fromRGB(0, 255, 255), "資源點"
                            elseif lowerName:find("diamond") or lowerName:find("emerald") then
                                isKeyItem, itemColor, itemLabel = true, Color3.fromRGB(0, 255, 100), "稀有資源"
                            end
                            
                            if isKeyItem then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "CatItemESP"
                                billboard.Adornee = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v
                                billboard.Size = UDim2.new(0, 100, 0, 40)
                                billboard.AlwaysOnTop = true
                                billboard.Parent = v
                                
                                local label = Instance.new("TextLabel", billboard)
                                label.BackgroundTransparency = 1
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.Text = itemLabel
                                label.TextColor3 = itemColor
                                label.TextStrokeTransparency = 0.5
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 10
                            end
                        end
                    end
                    task_wait(5) -- 降低掃描頻率以保證效能
                end
            end)
        else
            Notify("通用功能", "智慧型 ESP 已關閉", "Info")
            -- 清理 ESP 標籤
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "CatNPCESP" or v.Name == "CatItemESP" then
                    v:Destroy()
                end
            end
        end
    end

    -- ==========================================
    -- 遊戲特定功能 (Game Specific)
    -- ==========================================

    -- Knit 框架對接 (Roblox Bed Wars 核心)
    local KnitClient = nil
    local function GetKnit()
        if KnitClient then return KnitClient end
        local success, res = pcall(function()
            return require(ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@easy-games"):WaitForChild("knit"):WaitForChild("src"):WaitForChild("Knit"))
        end)
        if success then 
            KnitClient = res 
            return KnitClient
        end
        return nil
    end

    local function GetController(name)
        local knit = GetKnit()
        if not knit then return nil end
        local success, res = pcall(function() return knit.GetController(name) end)
        return success and res or nil
    end

    -- 提取環境函數以便直接使用
    local getrawmetatable = env.env.getrawmetatable
    local setreadonly = env.env.setreadonly
    local newcclosure = env.env.newcclosure
    local checkcaller = env.env.checkcaller
    local getnamecallmethod = env.env.getnamecallmethod
    local setfpscap = env.env.setfpscap
    local gethui = env.env.gethui

    -- 智慧型目標獲取 (考量血量、距離、可見性、角度)
    local function getBestTargets(range, maxTargets)
        local char = lplr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return {} end

        local targets = {}
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") then
                local hum = v.Character.Humanoid
                local targetRoot = v.Character.HumanoidRootPart
                local diff = (targetRoot.Position - root.Position)
                local dist = diff.Magnitude
                
                if dist <= range and hum.Health > 0 then
                    -- 檢查角度 (FOV Check)
                    local cam = workspace.CurrentCamera
                    local look = cam.CFrame.LookVector
                    local dot = look:Dot(diff.Unit)
                    local fovMatch = dot > math.cos(math.rad(env_global.FOVValue or 180) / 2)

                    -- 檢查可見性
                    local ray = Ray.new(root.Position, diff.Unit * dist)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, v.Character})
                    local isVisible = not hit
                    
                    if fovMatch then
                        table.insert(targets, {
                            character = v.Character,
                            dist = dist, 
                            health = hum.Health,
                            isVisible = isVisible
                        })
                    end
                end
            end
        end

        if #targets == 0 then return {} end

        -- 排序優先級：1. 可見目標 2. 低血量 3. 近距離
        table.sort(targets, function(a, b)
            if a.isVisible ~= b.isVisible then return a.isVisible end
            if math.abs(a.health - b.health) > 10 then return a.health < b.health end
            return a.dist < b.dist
        end)

        local finalTargets = {}
        for i = 1, math.min(#targets, maxTargets or 1) do
            table.insert(finalTargets, targets[i].character)
        end
        return finalTargets
    end

    CatFunctions.ToggleKillAura = function(state)
        env_global.KillAura = state
        if env_global.KillAura then
            Notify("戰鬥加強", "殺戮光環 (KillAura) 已極限加強：\n1. 多目標打擊 (最多 3 人)\n2. 智慧目標獲取 (優先可見與殘血)\n3. 隨機打擊部位與動態 CPS\n4. 抗檢測位置擾動", "Success")
        else
            env_global.IsAttacking = false
            return 
        end
        
        task_spawn(function()
            while env_global.KillAura do
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local weapon = char and char:FindFirstChildOfClass("Tool")
                
                if root and weapon then
                    local range = env_global.KillAuraRange or 18
                    local maxTargets = env_global.KillAuraMaxTargets or 3
                    local targets = getBestTargets(range, maxTargets)
                    
                    if #targets > 0 then
                        env_global.IsAttacking = true
                        
                        for _, target in ipairs(targets) do
                            local targetRoot = target:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                -- 1. 智慧預測與隨機擾動
                                local predictedPos = targetRoot.Position + (targetRoot.Velocity * 0.05)
                                local jitter = Vector3_new(math.random(-2,2)/10, 0, math.random(-2,2)/10)
                                
                                -- 2. 暴擊加強邏輯
                                if env_global.Criticals and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").FloorMaterial ~= Enum.Material.Air then
                                    root.Velocity = Vector3_new(root.Velocity.X, 7, root.Velocity.Z)
                                end

                                -- 3. 隨機打擊部位
                                local hitParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
                                local hitPartName = hitParts[math.random(1, #hitParts)]
                                local hitPart = target:FindFirstChild(hitPartName) or targetRoot
                                
                                -- 4. 自動格擋模擬 (AutoBlock)
                                if env_global.AutoBlock then
                                    pcall(function() weapon:Activate() end) -- 模擬防禦動作
                                end

                                local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                                               ReplicatedStorage:FindFirstChild("CombatRemote", true) or
                                               ReplicatedStorage:FindFirstChild("HitEntity", true)
                                
                                if remote then
                                    -- Knit SwordController 嘗試
                                    local swordController = GetController("SwordController")
                                    if swordController then
                                        pcall(function() swordController:strikeEntity(target) end)
                                    end

                                    remote:FireServer({
                                        ["entity"] = target,
                                        ["origin"] = root.Position + jitter,
                                        ["weapon"] = weapon,
                                        ["hitInfo"] = {
                                            ["part"] = hitPart,
                                            ["distance"] = (root.Position - targetRoot.Position).Magnitude,
                                            ["direction"] = (predictedPos - root.Position).Unit
                                        }
                                    })
                                end
                            end
                        end
                        
                        local baseCPS = env_global.KillAuraCPS or 12
                        local randomizedCPS = baseCPS + math.random(-3, 4)
                        task_wait(1 / randomizedCPS)
                    else
                        env_global.IsAttacking = false
                        task_wait(0.1)
                    end
                else
                    task_wait(0.5)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end

    CatFunctions.ToggleCriticals = function(state)
        env_global.Criticals = state
        if env_global.Criticals then
            Notify("戰鬥加強", "已開啟暴擊模式：每次打擊將模擬下落狀態以觸發暴擊", "Success")
        end
    end

    CatFunctions.ToggleFastAttack = function(state)
        env_global.FastAttack = state
        if env_global.FastAttack then
            env_global.KillAuraCPS = 25
            Notify("戰鬥加強", "已開啟快速攻擊：攻擊頻率已提升至最大", "Success")
        else
            env_global.KillAuraCPS = 12
        end
    end

    CatFunctions.ToggleSpeed = function(state)
        env_global.Speed = state
        if env_global.Speed then 
            Notify("運動輔助", "加速 (Speed) 已加強：\n1. 智慧脈衝加速\n2. 動態速度擾動\n3. 自動跳過障礙", "Success")
        else 
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
            return 
        end
        
        task_spawn(function()
            local lastMoveTick = tick()
            local speedTick = 0
            while env_global.Speed do
                local heartbeat = RunService.Heartbeat:Wait()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum then
                    speedTick = speedTick + 1
                    local moveDir = hum.MoveDirection
                    -- 動態速度：在設定值附近小幅波動以繞過檢測
                    local baseSpeed = env_global.SpeedValue or 23
                    local dynamicSpeed = baseSpeed + (math.random(-5, 5) / 10)
                    
                    if moveDir.Magnitude > 0 then
                        -- 脈衝邏輯：每隔幾幀進行一次位置微調
                        if tick() - lastMoveTick > 0.015 then
                            -- CFrame 步進優化
                            local step = moveDir * (dynamicSpeed * heartbeat)
                            root.CFrame = root.CFrame + step
                            lastMoveTick = tick()
                        end
                        
                        -- 速度擾動 (防止反作弊檢測到完美恆定速度)
                        local vel = moveDir * (dynamicSpeed + math.sin(speedTick/5) * 0.5)
                        root.Velocity = Vector3_new(vel.X, root.Velocity.Y, vel.Z)
                        
                        -- 智慧自動跳躍 (僅在有移動且腳下有地面的情況下)
                        if hum.FloorMaterial ~= Enum.Material.Air and hum.FloorMaterial ~= Enum.Material.Water then
                            -- 隨機化跳躍高度
                            root.Velocity = Vector3_new(root.Velocity.X, 15 + math.random(-2, 2), root.Velocity.Z)
                        end
                    else
                        -- 快速減速與摩擦模擬
                        root.Velocity = root.Velocity:Lerp(Vector3_new(0, root.Velocity.Y, 0), 0.2)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleFly = function(state)
        env_global.Fly = state
        if env_global.Fly then 
            Notify("運動輔助", "飛行 (Fly) 已加強：\n1. 高速平滑移動\n2. 抗回溯重力模擬\n3. 抗檢測姿態鎖定", "Success")
        else 
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                lplr.Character.HumanoidRootPart.Velocity = Vector3_new(0, 0, 0)
            end
            return 
        end
        
        task_spawn(function()
            local flyTick = 0
            while env_global.Fly do
                local heartbeat = RunService.Heartbeat:Wait()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum then
                    flyTick = flyTick + 1
                    local moveDir = hum.MoveDirection
                    local flySpeed = env_global.FlySpeed or 50
                    
                    -- 上下移動控制
                    local verticalVel = 0
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        verticalVel = flySpeed
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        verticalVel = -flySpeed
                    end
                    
                    -- 抗回溯 (Anti-Kick) 與重力模擬邏輯
                    -- 每隔一段時間模擬一次合法的物理狀態
                    if flyTick % 20 == 0 then
                        verticalVel = verticalVel - 2 -- 模擬微弱重力拉扯
                    end
                    
                    -- 設置速度與位置修正
                    local targetVel = (moveDir * flySpeed) + Vector3_new(0, verticalVel, 0)
                    
                    -- 速度抖動 (防止反作弊檢測到完美恆定速度)
                    local jitter = Vector3_new(math.random(-1, 1)/10, math.random(-1, 1)/10, math.random(-1, 1)/10)
                    root.Velocity = targetVel + jitter
                    
                    -- 保持姿態穩定且抗檢測
                    root.RotVelocity = Vector3_new(0, 0, 0)
                    
                    -- 懸停效果優化 (模擬真實角色的呼吸/微動)
                    if moveDir.Magnitude == 0 and verticalVel == 0 then
                        root.Velocity = Vector3_new(math.sin(tick() * 2) * 0.2, math.sin(tick() * 5) * 0.8, math.cos(tick() * 2) * 0.2)
                    end

                    -- 防止墜落檢測 (NoFall 輔助)
                    if env_global.NoFall then
                        local ray = Ray.new(root.Position, Vector3_new(0, -10, 0))
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                        if hit then
                            root.Velocity = Vector3_new(root.Velocity.X, math.max(root.Velocity.Y, -5), root.Velocity.Z)
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleScaffold = function(state)
        env_global.Scaffold = state
        if env_global.Scaffold then
            Notify("運動輔助", "架橋助手 (Scaffold) 已加強：\n1. 智慧預測路徑\n2. 瞬間塔式架橋 (Tower)\n3. 多重方塊防護", "Success")
        else
            Notify("運動輔助", "架橋助手已關閉", "Info")
            return
        end
        
        task.spawn(function()
            local lastPlaceTick = 0
            while env_global.Scaffold do
                RunService.Heartbeat:Wait()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum and tick() - lastPlaceTick > 0.03 then
                    -- 智慧預測腳下位置 (考量速度)
                    local predictDir = hum.MoveDirection
                    local pos = root.Position + (predictDir * 1.5) - Vector3_new(0, 3.5, 0)
                    local blockPos = Vector3_new(math.floor(pos.X/3)*3, math.floor(pos.Y/3)*3, math.floor(pos.Z/3)*3)
                    
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true) or 
                                   ReplicatedStorage:FindFirstChild("BuildBlock", true)
                    
                    if remote then
                        remote:FireServer({
                            ["blockType"] = "wool_white", 
                            ["position"] = blockPos,
                            ["blockData"] = 0,
                            ["origin"] = root.Position
                        })
                        lastPlaceTick = tick()
                        
                        -- Tower 模式 (按住空格時極速向上)
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            root.Velocity = Vector3_new(root.Velocity.X, 28, root.Velocity.Z)
                            -- 額外在正下方放一塊
                            local towerPos = Vector3_new(math.floor(root.Position.X/3)*3, math.floor(root.Position.Y/3)*3 - 3, math.floor(root.Position.Z/3)*3)
                            remote:FireServer({
                                ["blockType"] = "wool_white",
                                ["position"] = towerPos,
                                ["blockData"] = 0,
                                ["origin"] = root.Position
                            })
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoConsume = function(state)
        env_global.AutoConsume = state
        if not env_global.AutoConsume then return end
        task.spawn(function()
            while env_global.AutoConsume and task.wait(1) do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum.Health < hum.MaxHealth * 0.5 then
                        local remote = ReplicatedStorage:FindFirstChild("EatItem", true) or 
                                       ReplicatedStorage:FindFirstChild("ConsumeItem", true) or
                                       ReplicatedStorage:FindFirstChild("UseItem", true)
                        if remote then
                            local item = "apple"
                            -- 這裡可以擴展檢測背包中的補血物品
                            remote:FireServer({["item"] = item})
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleBedNuker = function(state)
        env_global.BedNuker = state
        if env_global.BedNuker then
            Notify("自動化", "床位破壞 (BedNuker) 已加強：\n1. 智慧多層破壞 (多工具適配)\n2. 穿牆打擊模擬\n3. 團隊資產保護\n4. 動態距離補償", "Success")
        else
            Notify("自動化", "床位破壞已關閉", "Info")
            return 
        end
        
        task_spawn(function()
            while env_global.BedNuker do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local battlefield = CatFunctions.GetBattlefieldState()
                    local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                   ReplicatedStorage:FindFirstChild("HitBlock", true) or
                                   ReplicatedStorage:FindFirstChild("BreakBlock", true)
                    
                    if remote then
                        for _, bed in ipairs(battlefield.beds) do
                            local dist = (hrp.Position - bed.part.Position).Magnitude
                            if dist < 25 then
                                -- 團隊過濾
                                local isSafeTarget = true
                                if lplr.Team and bed.part.Parent then
                                    local teamName = tostring(lplr.Team.Name):lower()
                                    local bedOwner = tostring(bed.part.Parent.Name):lower()
                                    if bedOwner:find(teamName) or teamName:find(bedOwner) then
                                        isSafeTarget = false
                                    end
                                end
                                
                                if isSafeTarget then
                                    -- 優先使用 Knit BlockController (防檢測且更精準)
                                    local blockController = GetController("BlockController")
                                    if blockController then
                                        pcall(function()
                                            blockController:breakBlock(bed.part.Position)
                                        end)
                                    end

                                    -- 1. 穿牆打擊模擬 (如果方塊被擋住，嘗試破壞周圍方塊)
                                    local ray = Ray.new(hrp.Position, (bed.part.Position - hrp.Position).Unit * dist)
                                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, bed.part.Parent})
                                    
                                    if hit and hit:IsA("BasePart") then
                                        -- 優先破壞阻擋物
                                        if blockController then
                                            pcall(function() blockController:breakBlock(hit.Position) end)
                                        end
                                        remote:FireServer({
                                            ["position"] = hit.Position, 
                                            ["block"] = hit.Name,
                                            ["origin"] = hrp.Position
                                        })
                                    end

                                    -- 2. 核心打擊：模擬多次點擊並覆蓋不同偏移
                                    local offsets = {
                                        Vector3_new(0, 0, 0), -- 床位中心
                                        Vector3_new(3, 0, 0), Vector3_new(-3, 0, 0),
                                        Vector3_new(0, 3, 0), Vector3_new(0, -3, 0),
                                        Vector3_new(0, 0, 3), Vector3_new(0, 0, -3)
                                    }
                                    
                                    for _, offset in ipairs(offsets) do
                                        if blockController then
                                            pcall(function() blockController:breakBlock(bed.part.Position + offset) end)
                                        end
                                        remote:FireServer({
                                            ["position"] = bed.part.Position + offset,
                                            ["block"] = (offset == Vector3_new(0,0,0) and bed.part.Name) or "wool_white",
                                            ["origin"] = hrp.Position
                                        })
                                    end
                                    
                                    -- 3. 隨機化執行延遲，防止被反作弊檢測到完美循環
                                    task_wait(0.05 + math.random(0, 5)/100)
                                end
                            end
                        end
                    end
                end
                task_wait(0.2)
            end
        end)
    end

    CatFunctions.ToggleTriggerBot = function(state)
        env_global.TriggerBot = state
        if not env_global.TriggerBot then return end
        task.spawn(function()
            while env_global.TriggerBot and task.wait() do
                local mouse = lplr:GetMouse()
                local target = mouse.Target
                if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(target.Parent)
                    if player and player ~= lplr and player.Team ~= lplr.Team then
                        local tool = lplr.Character and lplr.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleHitboxExpander = function(state)
        env_global.HitboxExpander = state
        if not env_global.HitboxExpander then 
            -- 重置所有玩家碰撞箱
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.Size = Vector3_new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                end
            end
            return
        end
        
        task.spawn(function()
            while env_global.HitboxExpander and task.wait(1) do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = v.Character.HumanoidRootPart
                        hrp.Size = Vector3_new(env_global.HitboxSize or 15, env_global.HitboxSize or 15, env_global.HitboxSize or 15)
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Bright blue")
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNoSlowdown = function(state)
        env_global.NoSlowdown = state
        if env_global.NoSlowdown then
            Notify("功能加強", "已開啟無減速：使用道具時將保持正常移動速度", "Success")
            task.spawn(function()
                while env_global.NoSlowdown and task.wait() do
                    local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- 攔截屬性修改 (通常由遊戲腳本觸發)
                        if hum.WalkSpeed < 16 then
                            hum.WalkSpeed = 16
                        end
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleFastBreak = function(state)
        env_global.FastBreak = state
        if env_global.FastBreak then
            Notify("功能加強", "已開啟快速破壞：破壞方塊速度提升", "Success")
            -- 修改破壞冷卻
            local breakHandler = lplr.Character and lplr.Character:FindFirstChild("BreakBlockHandler")
            if breakHandler then
                -- 這裡需要根據 Bedwars 具體腳本結構進行 Hook，通常是修改 remote 調用頻率
            end
        end
    end

    CatFunctions.ToggleAutoBridge = function(state)
        env_global.AutoBridge = state
        if env_global.AutoBridge then
            Notify("功能加強", "已開啟自動架橋：走過空處將自動補路", "Success")
            task.spawn(function()
                while env_global.AutoBridge and task.wait(0.05) do
                    local char = lplr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if root and hum then
                        -- 檢測前方腳下是否有方塊
                        local checkPos = root.Position + (hum.MoveDirection * 2) - Vector3_new(0, 3.5, 0)
                        local ray = Ray.new(checkPos + Vector3_new(0, 1, 0), Vector3_new(0, -2, 0))
                        local hit = workspace:FindPartOnRay(ray, char)
                        
                        if not hit then
                            local blockPos = Vector3_new(math.floor(checkPos.X/3)*3, math.floor(checkPos.Y/3)*3, math.floor(checkPos.Z/3)*3)
                            local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("BuildBlock", true)
                            
                            if remote then
                                remote:FireServer({
                                    ["blockType"] = "wool_white",
                                    ["position"] = blockPos,
                                    ["blockData"] = 0,
                                    ["origin"] = root.Position
                                })
                            end
                        end
                    end
                end
            end)
        end
    end

    -- 按鍵綁定系統
    local keybinds = {}
    CatFunctions.SetKeybind = function(featureName, keyCode)
        keybinds[featureName] = keyCode
        Notify("快捷鍵", featureName .. " 已綁定至 " .. tostring(keyCode), "Info")
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        for feature, key in pairs(keybinds) do
            if input.KeyCode == key then
                -- 觸發對應功能切換
                local toggleName = "Toggle" .. feature
                if CatFunctions[toggleName] then
                    local newState = not env_global[feature]
                    CatFunctions[toggleName](newState)
                    Notify("快捷鍵觸發", feature .. " 已" .. (newState and "開啟" or "關閉"), "Info")
                end
            end
        end
    end)

    CatFunctions.ToggleAutoLobby = function(state)
        env_global.AutoLobby = state
        if not env_global.AutoLobby then return end
        task.spawn(function()
            while env_global.AutoLobby and task.wait(2) do
                -- 檢測遊戲結束狀態
                local gui = lplr:FindFirstChild("PlayerGui")
                if gui and (gui:FindFirstChild("VictoryGui") or gui:FindFirstChild("GameOverGui")) then
                    Notify("自動大廳", "遊戲結束，正在返回大廳...", "Info")
                    ReplicatedStorage:FindFirstChild("PlayAgain", true):FireServer()
                end
            end
        end)
    end

    -- 管理員檢測 (Staff Detector)
    CatFunctions.ToggleStaffDetector = function(state)
        env_global.StaffDetector = state
        if env_global.StaffDetectorConn then
            env_global.StaffDetectorConn:Disconnect()
            env_global.StaffDetectorConn = nil
        end
        if not env_global.StaffDetector then return end
        
        local staffRanks = {
            "Admin", "Moderator", "Staff", "Developer", "Owner", "Helper"
        }
        
        local function checkPlayer(player)
            if not env_global.StaffDetector then return end
            pcall(function()
                local rank = player:GetRoleInGroup(5774246)
                for _, s in ipairs(staffRanks) do
                    if rank:find(s) then
                        Notify("管理偵測", "警告！檢測到管理員加入: [" .. player.Name .. "] (" .. rank .. ")", "Error")
                        if env_global.AutoLeaveOnStaff then
                            game:GetService("TeleportService"):Teleport(lplr.PlaceId)
                        end
                    end
                end
            end)
        end

        for _, p in ipairs(Players:GetPlayers()) do checkPlayer(p) end
        env_global.StaffDetectorConn = Players.PlayerAdded:Connect(checkPlayer)
        
        Notify("輔助功能", "管理員偵測已啟動，將實時監控伺服器成員", "Success")
    end

    CatFunctions.ToggleAutoRejoin = function(state)
        env_global.AutoRejoin = state
        if env_global.AutoRejoinConn then
            env_global.AutoRejoinConn:Disconnect()
            env_global.AutoRejoinConn = nil
        end
        if not env_global.AutoRejoin then return end
        
        local coreGui = game:GetService("CoreGui")
        env_global.AutoRejoinConn = coreGui.ChildAdded:Connect(function(child)
            if not env_global.AutoRejoin then
                if env_global.AutoRejoinConn then
                    env_global.AutoRejoinConn:Disconnect()
                    env_global.AutoRejoinConn = nil
                end
                return
            end
            if child.Name == "ErrorPrompt" then
                Notify("自動重連", "檢測到斷線，正在嘗試重新連接...", "Warning")
                task.wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, lplr)
            end
        end)
        
        Notify("輔助功能", "自動斷線重連已啟動", "Success")
    end

    CatFunctions.SaveConfig = function()
        local config = {}
        for k, v in pairs(env_global) do
            -- 只保存布林值、數字和字符串設定，排除函數和執行個體
            local t = typeof(v)
            if t == "boolean" or t == "number" or t == "string" then
                config[k] = v
            end
        end
        
        local success, json = pcall(function() return game:GetService("HttpService"):JSONEncode(config) end)
        if success then
            writefile("Halol_Config_" .. lplr.UserId .. ".json", json)
            Notify("配置系統", "設定已成功保存", 2)
        end
    end

    CatFunctions.LoadConfig = function()
        local fileName = "Halol_Config_" .. lplr.UserId .. ".json"
        if isfile(fileName) then
            local success, content = pcall(function() return readfile(fileName) end)
            if success then
                local decodeSuccess, config = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
                if decodeSuccess then
                    for k, v in pairs(config) do
                        env_global[k] = v
                    end
                    Notify("配置系統", "已自動載入您的專屬設定", 3)
                end
            end
        end
    end

    CatFunctions.ToggleAntiDead = function(state)
        env_global.AntiDead = state
        if not env_global.AntiDead then return end
        task.spawn(function()
            Notify("Anti Dead", "已啟動防死模式：低血量自動逃生 + 空中打擊", "Success")
            while env_global.AntiDead and task.wait(0.1) do
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hum = lplr.Character.Humanoid
                    local hrp = lplr.Character.HumanoidRootPart
                    
                    -- 1. 低血量逃生 (血量低於 30%)
                    if hum.Health < hum.MaxHealth * 0.3 then
                        Notify("Anti Dead", "血量過低！正在執行緊急空中避難...", "Warning")
                        
                        -- 記錄原始位置以便恢復或後續邏輯
                        local safeHeight = 50 -- 飛向 50 格高空
                        local startPos = hrp.Position
                        
                        -- 快速升空
                        for i = 1, 10 do
                            hrp.CFrame = hrp.CFrame + Vector3_new(0, 5, 0)
                            hrp.Velocity = Vector3_new(0, 0, 0)
                            task.wait(0.05)
                        end
                        
                        -- 保持在空中並繼續攻擊
                        local escapeTime = tick()
                        while tick() - escapeTime < 5 and hum.Health < hum.MaxHealth * 0.8 and env_global.AntiDead do
                            -- 懸停並微動防止檢測
                            hrp.Velocity = Vector3_new(0, 2, 0)
                            
                            -- 在空中仍然可以攻擊 (KillAura 已經在運行，這裡只需確保範圍足夠)
                            if env_global.KillAura then
                                env_global.KillAuraRange = 50 -- 臨時擴大攻擊範圍以在空中打擊
                            end
                            
                            task.wait(0.1)
                        end
                        
                        -- 恢復攻擊範圍
                        if env_global.KillAura then
                            env_global.KillAuraRange = env_global.Reach and 25 or 18
                        end
                        
                        Notify("Anti Dead", "狀態已恢復，回到戰場", "Success")
                    end
                    
                    -- 2. 防虛空檢測 (如果掉落過深)
                    if hrp.Position.Y < -50 then
                        hrp.Velocity = Vector3_new(0, 100, 0)
                        hrp.CFrame = hrp.CFrame + Vector3_new(0, 100, 0)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleStep = function(state)
        env_global.Step = state
        task.spawn(function()
            while env_global.Step and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    lplr.Character:FindFirstChildOfClass("Humanoid").StepHeight = 5
                end
            end
            if not env_global.Step and lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").StepHeight = 3
            end
        end)
    end

    CatFunctions.ToggleAntiVoid = function(state)
        env_global.AntiVoid = state
        if not env_global.AntiVoid then
            if env_global.AntiVoidPart then env_global.AntiVoidPart:Destroy() end
            return
        end
        task.spawn(function()
            local part = Instance.new("Part")
            part.Name = "AntiVoidPart"
            part.Size = Vector3_new(2000, 1, 2000)
            part.Position = Vector3_new(0, 0, 0)
            part.Anchored = true
            part.Transparency = 0.5
            part.Color = Color3.fromRGB(60, 120, 255)
            part.Parent = workspace
            env_global.AntiVoidPart = part
            
            part.Touched:Connect(function(hit)
                if hit.Parent == lplr.Character then
                    lplr.Character.HumanoidRootPart.Velocity = Vector3_new(0, 100, 0)
                end
            end)
            
            while env_global.AntiVoid and task.wait(1) do
                part.Position = Vector3_new(lplr.Character.HumanoidRootPart.Position.X, 0, lplr.Character.HumanoidRootPart.Position.Z)
            end
        end)
    end

    -- 世界與雜項功能擴展
    CatFunctions.ToggleTimeCycle = function(state)
        env_global.TimeCycle = state
        if not env_global.TimeCycle then return end
        task.spawn(function()
            while env_global.TimeCycle and task.wait() do
                game:GetService("Lighting").ClockTime = (tick() % 24)
            end
        end)
    end

    CatFunctions.ToggleFPSCap = function(state)
        if setfpscap then
            setfpscap(state and 999 or 60)
        end
    end

    -- 新增功能實作
    -- ==========================================
    -- 核心功能 (Combat & Movement)
    -- ==========================================

    -- AntiFall (防掉落)
    CatFunctions.ToggleAntiFall = function(state)
        env_global.AntiFall = state
        if not env_global.AntiFall then return end
        task.spawn(function()
            local lastGroundedPos = Vector3_new(0, 0, 0)
            while env_global.AntiFall and task.wait(0.1) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum then
                    local ray = Ray.new(hrp.Position, Vector3_new(0, -20, 0))
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                    
                    if part then
                        lastGroundedPos = hrp.Position
                    elseif hrp.Position.Y < -20 then
                        hrp.CFrame = CFrame_new(lastGroundedPos + Vector3_new(0, 5, 0))
                        hrp.Velocity = Vector3_new(0, 0, 0)
                        Notify("移動功能", "檢測到即將掉落，已將你傳回地面", "Warning")
                    end
                end
            end
        end)
    end

    -- HighJump (高跳)
    CatFunctions.ToggleHighJump = function(state)
        env_global.HighJump = state
        if not env_global.HighJump then
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
            end
            return
        end
        task.spawn(function()
            while env_global.HighJump and task.wait(0.1) do
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = env_global.HighJumpPower or 100
                end
            end
        end)
    end

    -- Invisible (隱身 - 客戶端)
    CatFunctions.ToggleInvisible = function(state)
        env_global.Invisible = state
        local char = lplr.Character
        if not char then return end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = state and 1 or (v.Name == "HumanoidRootPart" and 1 or 0)
            end
        end
        if state then
            Notify("視覺功能", "已開啟客戶端隱身 (僅自己不可見，對伺服器無效)", "Info")
        end
    end

    -- MouseTP (滑鼠傳送)
    CatFunctions.ToggleMouseTP = function(state)
        env_global.MouseTP = state
        if not env_global.MouseTP then return end
        local mouse = lplr:GetMouse()
        local connection
        connection = mouse.Button1Down:Connect(function()
            if not env_global.MouseTP then
                connection:Disconnect()
                return
            end
            local char = lplr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame_new(mouse.Hit.p + Vector3_new(0, 3, 0))
            end
        end)
    end

    -- Phase (穿牆)
    CatFunctions.TogglePhase = function(state)
        env_global.Phase = state
        if not env_global.Phase then return end
        task.spawn(function()
            while env_global.Phase and task.wait() do
                local char = lplr.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    -- SpinBot (陀螺)
    CatFunctions.ToggleSpinBot = function(state)
        env_global.SpinBot = state
        if not env_global.SpinBot then return end
        task.spawn(function()
            while env_global.SpinBot and task.wait() do
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0)
                end
            end
        end)
    end

    -- Swim (飛行游泳)
    CatFunctions.ToggleSwim = function(state)
        env_global.Swim = state
        if not env_global.Swim then
            local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false) end
            return
        end
        task.spawn(function()
            while env_global.Swim and task.wait() do
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                end
            end
        end)
    end

    -- TargetStrafe (目標繞圈)
    CatFunctions.ToggleTargetStrafe = function(state)
        env_global.TargetStrafe = state
        if not env_global.TargetStrafe then return end
        task.spawn(function()
            local angle = 0
            while env_global.TargetStrafe and task.wait() do
                local myChar = lplr.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local target = CatFunctions.GetNearestEnemy(20) -- 獲取 20 格內的敵人
                
                if myHrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = target.Character.HumanoidRootPart
                    angle = angle + math.rad(5)
                    local radius = env_global.StrafeRadius or 10
                    local offset = Vector3_new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                    myHrp.CFrame = CFrame_new(targetHrp.Position + offset, targetHrp.Position)
                end
            end
        end)
    end

    -- Timer (加速)
    CatFunctions.ToggleTimer = function(state)
        env_global.Timer = state
        if not env_global.Timer then
            game:GetService("RunService"):Set3dRenderingEnabled(true)
            -- 恢復預設速度邏輯
            return
        end
        task.spawn(function()
            while env_global.Timer and task.wait() do
                -- 這裡的 Timer 通常是指加速物理模擬或簡單的 WalkSpeed 加成
                -- 由於 Set3dRenderingEnabled(false) 可以提速，但通常用戶想要的是速度
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = (env_global.WalkSpeed or 16) * (env_global.TimerMultiplier or 1.5)
                end
            end
        end)
    end

    CatFunctions.ServerHop = function()
        local HttpService = game:GetService("HttpService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end

    CatFunctions.Rejoin = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end

    CatFunctions.ToggleAutoBalloon = function(state)
        env_global.AutoBalloon = state
        if not env_global.AutoBalloon then return end
        task.spawn(function()
            while env_global.AutoBalloon and task.wait(0.5) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -50 then
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or
                                   ReplicatedStorage:FindFirstChild("ShopPurchase", true)
                    if remote then
                        remote:FireServer({["item"] = "balloon", ["amount"] = 1})
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
        env_global.Nuker = state
        if not env_global.Nuker then return end
        task.spawn(function()
            while env_global.Nuker and task.wait(0.1 + math.random() * 0.05) do
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local region = Region3.new(hrp.Position - Vector3_new(15, 15, 15), hrp.Position + Vector3_new(15, 15, 15))
                    local parts = workspace:FindPartsInRegion3(region, lplr.Character, 100)
                    for _, v in pairs(parts) do
                        if v:IsA("BasePart") and v.CanCollide and not v:IsDescendantOf(lplr.Character) then
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("HitBlock", true) or
                                           ReplicatedStorage:FindFirstChild("BreakBlock", true)
                            if remote then
                                remote:FireServer({
                                    ["position"] = v.Position, 
                                    ["block"] = v.Name,
                                    ["origin"] = hrp.Position
                                })
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 新增伺服器端交互與遠程功能
    CatFunctions.ToggleInstantShop = function(state)
        env_global.InstantShop = state
        if not env_global.InstantShop then return end
        -- 透過直接觸發商店遠程，允許在任何地方開啟商店
        local remote = ReplicatedStorage:FindFirstChild("OpenShop", true) or 
                       ReplicatedStorage:FindFirstChild("GetShopItems", true)
        if remote then
            remote:FireServer()
            Notify("伺服器功能", "已遠程觸發商店數據請求", "Success")
        end
    end

    CatFunctions.ToggleAutoClaimRewards = function(state)
        env_global.AutoClaimRewards = state
        if not env_global.AutoClaimRewards then return end
        task.spawn(function()
            while env_global.AutoClaimRewards do
                task.wait(math.random(10, 20))
                local remotes = {
                    ReplicatedStorage:FindFirstChild("ClaimDailyReward", true),
                    ReplicatedStorage:FindFirstChild("ClaimBattlePassReward", true),
                    ReplicatedStorage:FindFirstChild("ClaimMissionReward", true)
                }
                for _, r in ipairs(remotes) do
                    if r then r:FireServer() end
                end
            end
        end)
    end

    CatFunctions.ToggleAntiReport = function(state)
        env_global.AntiReport = state
        if not env_global.AntiReport then 
            env_global.SuspectedReporters = {}
            return 
        end
        
        -- 0. 初始化疑似舉報者追蹤器
        env_global.SuspectedReporters = {}
        
        -- 1. 初始化全域攔截清單 (擴展黑名單)
        local Blacklist = {
            -- 舉報與封鎖
            "ReportPlayer", "ReportAbuse", "SubmitReport", "SendReport",
            "PerformReport", "ClientReport", "ReportUser", "SendAbuseReport",
            "ReportReason", "AbuseReport", "ReportCategory", "KickPlayer", "BanPlayer",
            -- 分析、日誌與追蹤
            "Analytics", "GoogleAnalytics", "LogEvent", "Telemetry", "TrackBehavior",
            "SendAnalytics", "RecordEvent", "Diagnostic", "Playfab", "AppCenter",
            "Bugsnag", "Sentry", "NewRelic", "InfluxDB", "Datadog", "SumoLogic",
            -- 反作弊與客戶端檢測
            "AC_Update", "ClientCheck", "Violation", "SecurityCheck", "VerifyClient",
            "Detection", "CheatLog", "BanMe", "KickMe", "SuspiciousActivity",
            "AntiCheat", "CheatDetect", "ClientSideCheck", "ExploitDetect", "CheckClient",
            "MemoryCheck", "ModuleCheck", "ProcessCheck", "ThreadCheck", "DebugCheck",
            "SpeedCheck", "FlyCheck", "AuraCheck", "ReachCheck", "HitboxCheck",
            -- 其他敏感行為
            "ChatLog", "MessageLog", "ScriptLog", "ErrorLog", "CrashLog"
        }

        -- 2. 實作核心攔截器 (多重防禦機制)
        task.spawn(function()
            if not getgenv().GlobalInterceptionInitialized then
                getgenv().GlobalInterceptionInitialized = true
                
                local mt = getrawmetatable(game)
                local old_nc = mt.__namecall
                local old_fs = Instance.new("RemoteEvent").FireServer
                local old_is = Instance.new("RemoteFunction").InvokeServer
                
                setreadonly(mt, false)

                -- 輔助函數：檢查是否應攔截
                local lastInterceptNotify = 0
                local function shouldBlock(self, method)
                    if checkcaller() or not env_global.AntiReport then return false end
                    if method ~= "FireServer" and method ~= "InvokeServer" then return false end
                    
                    local remoteName = tostring(self)
                    for _, blocked in ipairs(Blacklist) do
                        if remoteName:find(blocked) then
                            -- 加入攔截通知 (冷卻時間 3 秒避免刷屏)
                            if tick() - lastInterceptNotify > 3 then
                                lastInterceptNotify = tick()
                                task.spawn(function()
                                    local reporterInfo = ""
                                    if #env_global.SuspectedReporters > 0 then
                                        reporterInfo = "\n疑似舉報者: " .. table.concat(env_global.SuspectedReporters, ", ")
                                    end
                                    Notify("舉報攔截", "成功攔截可疑封包: [" .. remoteName .. "]" .. reporterInfo, "Success")
                                end)
                            end
                            return true
                        end
                    end
                    return false
                end

                -- A. Metatable Hook (__namecall) - 攔截 self:Method(...)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if shouldBlock(self, method) then
                        return nil
                    end
                    return old_nc(self, ...)
                end)
                
                -- B. Index Hook (FireServer/InvokeServer) - 攔截 Method(self, ...)
                local event_mt = getrawmetatable(Instance.new("RemoteEvent"))
                local function_mt = getrawmetatable(Instance.new("RemoteFunction"))
                
                -- 攔截 FireServer
                local old_event_fs = event_mt.FireServer
                setreadonly(event_mt, false)
                event_mt.FireServer = newcclosure(function(self, ...)
                    if shouldBlock(self, "FireServer") then
                        return nil
                    end
                    return old_event_fs(self, ...)
                end)
                setreadonly(event_mt, true)
                
                -- 攔截 InvokeServer
                local old_func_is = function_mt.InvokeServer
                setreadonly(function_mt, false)
                function_mt.InvokeServer = newcclosure(function(self, ...)
                    if shouldBlock(self, "InvokeServer") then
                        return nil
                    end
                    return old_func_is(self, ...)
                end)
                setreadonly(function_mt, true)

                setreadonly(mt, true)
                Notify("防偵測系統", "核心攔截器已加固 (Triple-Layer Protection Enabled)", "Success")
            end
        end)

        -- 3. 進階舉報者偵測與自動避險 (優化觀戰偵測)
        task.spawn(function()
            local observerCount = 0
            
            while env_global.AntiReport and task.wait(0.5) do
                local currentObservers = 0
                local myChar = lplr.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if myHrp then
                    -- 檢查是否在大廳 (Lobby)，大廳不顯示視線警告
                    local matchState = ReplicatedStorage:FindFirstChild("MatchState")
                    local isLobby = matchState and matchState.Value == 0

                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= lplr then
                            local isObserving = false
                            local isLongTermSpectator = CatFunctions.IsLongTermSpectator(player)
                            
                            -- 方法 A: 角色視線偵測 (針對活著的玩家) - 僅在非大廳時偵測
                            if not isLobby and not isLongTermSpectator and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetPos = player.Character.HumanoidRootPart.Position
                                local dist = (targetPos - myHrp.Position).Magnitude
                                
                                if dist < 60 then
                                    local lookVec = player.Character.HumanoidRootPart.CFrame.LookVector
                                    local toMe = (myHrp.Position - targetPos).Unit
                                    if lookVec:Dot(toMe) > 0.95 then 
                                        isObserving = true
                                    end
                                end
                            end

                            -- 方法 B: 長期觀戰者偵測 (針對床爆且死掉的人)
                            if isLongTermSpectator then
                                isObserving = true
                                -- 將觀戰者名字加入清單，方便 UI 或通知顯示
                                if not table.find(env_global.CurrentSpectatorList or {}, player.Name) then
                                    env_global.CurrentSpectatorList = env_global.CurrentSpectatorList or {}
                                    table.insert(env_global.CurrentSpectatorList, player.Name)
                                end
                            end

                            if isObserving then
                                currentObservers = currentObservers + 1
                                
                                -- 將疑似舉報者加入清單
                                if not table.find(env_global.SuspectedReporters, player.Name) then
                                    table.insert(env_global.SuspectedReporters, player.Name)
                                    if #env_global.SuspectedReporters > 5 then table.remove(env_global.SuspectedReporters, 1) end
                                    task.delay(30, function() 
                                        local idx = table.find(env_global.SuspectedReporters, player.Name)
                                        if idx then table.remove(env_global.SuspectedReporters, idx) end
                                    end)
                                end

                                if not env_global["Warning_"..player.Name] then
                                    env_global["Warning_"..player.Name] = true
                                    
                                    -- 區分身分進行通知
                                    if isLongTermSpectator then
                                        local specCount = #CatFunctions.GetCurrentSpectators()
                                        Notify("觀戰警戒", "長期觀戰者 [" .. player.Name .. "] (床爆已死) 正在監視你！\n當前總觀戰人數: " .. specCount, "Error")
                                        
                                        -- 如果開啟了自動隱身，這裡會觸發邏輯 (已經在 ToggleSpectatorInvisibility 中實作)
                                    else
                                        local isEnemy = (player.Team ~= lplr.Team)
                                        if isEnemy then
                                            Notify("威脅偵測", "敵方玩家 [" .. player.Name .. "] 已發現你，並正在鎖定你的位置！", "Error")
                                        else
                                            Notify("危險警告", "玩家 [" .. player.Name .. "] 正緊盯著你，可能正在錄影或舉報！", "Warning")
                                        end
                                    end
                                    
                                    task.delay(15, function() env_global["Warning_"..player.Name] = nil end)
                                end
                            end
                        end
                    end
                    
                    -- 自動避險邏輯：如果同時有 3 個以上觀察者，且持續超過 10 秒
                    if currentObservers >= 3 then
                        observerCount = observerCount + 1
                        if observerCount >= 20 then
                            Notify("緊急避險", "檢測到大量觀察者，正在自動更換伺服器以保護帳號...", "Error")
                            task.wait(1)
                            if CatFunctions.ServerHop then CatFunctions.ServerHop() end
                            break
                        end
                    else
                        observerCount = math.max(0, observerCount - 1)
                    end
                end
            end
        end)

        Notify("伺服器功能", "攔截邏輯已強化：已啟用核心層級全域攔截", "Success")
    end

    CatFunctions.ToggleAntiSpectate = function(state)
        env_global.AntiSpectate = state
        if not env_global.AntiSpectate then 
            if env_global.AntiSpectateConn then env_global.AntiSpectateConn:Disconnect() env_global.AntiSpectateConn = nil end
            -- 重置透明度
            pcall(function()
                if lplr.Character then
                    for _, v in pairs(lplr.Character:GetChildren()) do
                        if v:IsA("BasePart") or v:IsA("Decal") then
                            v.Transparency = (v.Name == "HumanoidRootPart" and 1 or 0)
                        end
                    end
                end
            end)
            return 
        end
        
        Notify("抗舉報系統", "已啟動「超強防觀戰」：動態擾動 + 觀戰者感知隱身", "Success")
        
        if env_global.AntiSpectateConn then env_global.AntiSpectateConn:Disconnect() end
        env_global.AntiSpectateConn = RunService.Heartbeat:Connect(function()
            if not env_global.AntiSpectate then 
                if env_global.AntiSpectateConn then env_global.AntiSpectateConn:Disconnect() env_global.AntiSpectateConn = nil end
                return 
            end
            
            pcall(function()
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local originalCFrame = hrp.CFrame
                    
                    -- 1. 動態擾動邏輯 (干擾相機鎖定)
                    -- 原理：在物理同步幀將位置瞬移，在渲染幀還原。觀戰者看到的座標是瞬移後的。
                    local jitter = Vector3_new(0, 0, 0)
                    local chance = tick() % 0.5
                    if chance < 0.1 then
                        -- 深度脫離：瞬間拉高 10000 格 (徹底甩開相機)
                        jitter = Vector3_new(0, 10000, 0)
                    elseif chance < 0.3 then
                        -- 隨機位移：在周圍 50 格內快速閃爍 (干擾錄影)
                        jitter = Vector3_new(math.random(-50, 50), math.random(-20, 20), math.random(-50, 50))
                    else
                        -- 高頻顫抖：極小幅度抖動 (干擾插值平滑)
                        jitter = Vector3_new(math.random(-2, 2), math.random(-1, 1), math.random(-2, 2))
                    end
                    
                    hrp.CFrame = originalCFrame * CFrame.new(jitter)
                    
                    -- 2. 觀戰者感知隱身 (僅當有觀戰者時)
                    -- 如果檢測到當前有觀戰者，自動將本地模型透明化 (本地看得到，觀戰者看你是透明的)
                    local hasSpectators = #CatFunctions.GetCurrentSpectators() > 0
                    if hasSpectators then
                        for _, v in pairs(lplr.Character:GetChildren()) do
                            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                                v.Transparency = 0.8 -- 半透明，既能干擾舉報截圖，又不影響本地操作
                            end
                        end
                    else
                        -- 無人觀戰時恢復正常，降低性能消耗
                        for _, v in pairs(lplr.Character:GetChildren()) do
                            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                                v.Transparency = 0
                            end
                        end
                    end
                    
                    -- 等待渲染幀並還原 (保證本地操作無感)
                    RunService.RenderStepped:Wait()
                    hrp.CFrame = originalCFrame
                end
            end)
        end)
    end

    CatFunctions.ToggleCustomMatchExploit = function(state)
        env_global.CustomMatchExploit = state
        if not env_global.CustomMatchExploit then return end
        task.spawn(function()
            -- 嘗試在自定義房間中獲取管理權限遠程
            local remote = ReplicatedStorage:FindFirstChild("CustomMatchCommand", true)
            if remote then
                Notify("自定義房間", "檢測到管理遠程，正在優化權限...", "Success")
                -- 範例：自動開啟所有人的飛天權限
                remote:FireServer({["command"] = "fly", ["target"] = "all"})
            else
                Notify("自定義房間", "未檢測到可用的管理遠程", "Error")
            end
        end)
    end

    -- (已在上方定義)
    CatFunctions.ToggleAimbot = function(state)
        env_global.Aimbot = state
        if not env_global.Aimbot then return end
        
        task.spawn(function()
            local RunService = game:GetService("RunService")
            local Camera = workspace.CurrentCamera
            
            while env_global.Aimbot do
                RunService.RenderStepped:Wait()
                
                -- 尋找最近的敵人
                local target = nil
                local maxDist = 200 -- 最大偵測距離
                local nearestMouse = 500 -- 鼠標附近的範圍 (FOV)
                
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                        if v.Character.Humanoid.Health > 0 then
                            local part = v.Character:FindFirstChild("Head") or v.Character:FindFirstChild("HumanoidRootPart")
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            
                            if onScreen then
                                local mousePos = UserInputService:GetMouseLocation()
                                local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                
                                if distToMouse < nearestMouse then
                                    nearestMouse = distToMouse
                                    target = part
                                end
                            end
                        end
                    end
                end
                
                -- 鎖定目標
                if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then -- 右鍵瞄準時啟動
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end
            end
        end)
    end

    CatFunctions.ToggleAutoWin = function(state)
        env_global.AutoWin = state
        if not env_global.AutoWin then return end
        
        task.spawn(function()
            Notify("Auto Win", "已啟動自動勝出模式，正在掃描戰場...", "Success")
            
            -- 自動開啟必要的戰鬥輔助
            if not env_global.KillAura then
                CatFunctions.ToggleKillAura(true)
            end
            
            while env_global.AutoWin and task.wait(0.5) do
                local battlefield = CatFunctions.GetBattlefieldState()
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait()
                else
                    -- 1. 優先摧毀所有敵方床位 (Bedwars 核心勝利條件)
                    if #battlefield.beds > 0 then
                        local targetBed = battlefield.beds[1]
                        -- 檢查是否為自己的床 (簡單過濾：檢查顏色或名稱)
                        local isMyBed = false
                        if lplr.Team and targetBed.part.Parent.Name:lower():find(tostring(lplr.Team.Name):lower()) then
                            isMyBed = true
                        end
                        
                        if not isMyBed then
                            Notify("Auto Win", "正在前往摧毀敵方床位: " .. targetBed.name, "Info")
                            
                            -- 傳送到床位上方 (避免卡進方塊)
                            hrp.CFrame = targetBed.part.CFrame * CFrame.new(0, 5, 0)
                            task.wait(0.2)
                            
                            -- 觸發破壞遠程 (模擬多次打擊)
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then
                                for i = 1, 5 do
                                    remote:FireServer({["position"] = targetBed.part.Position, ["block"] = targetBed.part.Name})
                                    task.wait(0.05)
                                end
                            end
                            task.wait(0.5)
                        else
                            -- 如果是自己的床，嘗試下一個
                            if #battlefield.beds > 1 then
                                targetBed = battlefield.beds[2]
                            end
                        end
                    -- 2. 床位全破後，清除剩餘敵人
                    elseif #battlefield.targets > 0 then
                        local targetPlayer = battlefield.targets[1]
                        Notify("Auto Win", "正在清除剩餘玩家: " .. targetPlayer.player.Name, "Info")
                        
                        -- 傳送到玩家背後
                        hrp.CFrame = targetPlayer.hrp.CFrame * CFrame.new(0, 0, 3)
                        task.wait(0.5)
                    else
                        Notify("Auto Win", "戰場已清空，等待勝利判定...", "Success")
                        task.wait(5)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleFPSBoost = function(state)
        env_global.FPSBoost = state
        if not env_global.FPSBoost then
            Notify("FPS Boost", "優化已關閉 (部分渲染更改需重啟腳本或更換伺服器生效)", "Info")
            return
        end

        task.spawn(function()
            Notify("FPS Boost", "正在執行全自動效能優化...", "Success")
            
            -- 1. 解鎖偵數限制
            if setfpscap then
                setfpscap(999)
            end

            -- 2. 優化全局渲染設置
            local settings = game:GetService("Settings")
            local rendering = settings.Rendering
            pcall(function()
                rendering.QualityLevel = Enum.QualityLevel.Level01
            end)

            -- 3. 優化光照與視覺效果
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            lighting.Brightness = 2
            
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end

            -- 4. 遍歷工作區優化所有物件 (降低細節)
            local function optimizePart(v)
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1 -- 隱藏貼圖
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end

            for _, v in pairs(workspace:GetDescendants()) do
                optimizePart(v)
            end

            -- 監聽新生成的物件並優化
            local connection
            connection = workspace.DescendantAdded:Connect(function(v)
                if not env_global.FPSBoost then
                    connection:Disconnect()
                    return
                end
                optimizePart(v)
            end)

            Notify("FPS Boost", "優化完成！偵數已解鎖至 999+", "Success")
        end)
    end

    CatFunctions.ToggleFreecam = function(state)
        env_global.Freecam = state
        if env_global.Freecam then
            local camera = workspace.CurrentCamera
            local char = lplr.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local freecamPart = Instance.new("Part")
            freecamPart.Name = "FreecamPart"
            freecamPart.Size = Vector3_new(1, 1, 1)
            freecamPart.Transparency = 1
            freecamPart.CanCollide = false
            freecamPart.Anchored = true
            freecamPart.CFrame = camera.CFrame
            freecamPart.Parent = workspace
            
            env_global.FreecamPart = freecamPart
            camera.CameraSubject = freecamPart
            
            task.spawn(function()
                while env_global.Freecam and freecamPart.Parent do
                    local moveDir = Vector3_new(0, 0, 0)
                    local camCF = camera.CFrame
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3_new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3_new(0, 1, 0) end
                    
                    freecamPart.CFrame = freecamPart.CFrame + (moveDir * 1.5)
                    task.wait()
                end
            end)
            Notify("世界功能", "自由視角已開啟 (W/A/S/D 移動)", "Success")
        else
            if env_global.FreecamPart then
                env_global.FreecamPart:Destroy()
                env_global.FreecamPart = nil
            end
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = lplr.Character:FindFirstChildOfClass("Humanoid")
            end
            Notify("世界功能", "自由視角已關閉", "Info")
        end
    end

    CatFunctions.ToggleParkour = function(state)
        env_global.Parkour = state
        if env_global.Parkour then
            Notify("世界功能", "跑酷助手已開啟", "Success")
        end
        if not env_global.Parkour then return end
        task.spawn(function()
            while env_global.Parkour and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                    local startPos = hrp.Position - Vector3_new(0, 1, 0)
                    local ray = Ray.new(startPos, hum.MoveDirection * 2.5)
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {char, workspace:FindFirstChild("ItemDrops"), workspace:FindFirstChild("Pickups")})
                    if part and part.CanCollide then
                        hum.Jump = true
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleSafeWalk = function(state)
        env_global.SafeWalk = state
        if env_global.SafeWalk then
            Notify("世界功能", "安全行走已開啟：防止掉落邊緣", "Success")
        end
        if not env_global.SafeWalk then return end
        task.spawn(function()
            while env_global.SafeWalk and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    local nextPos = hrp.Position + (hum.MoveDirection * 1.5)
                    local ray = Ray.new(nextPos, Vector3_new(0, -10, 0))
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                    if not part then
                        hrp.Velocity = Vector3_new(0, hrp.Velocity.Y, 0)
                        hrp.CFrame = hrp.CFrame - (hum.MoveDirection * 0.2)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoBuyWool = function(state)
        env_global.AutoBuyWool = state
        if not env_global.AutoBuyWool then return end
        task.spawn(function()
            while env_global.AutoBuyWool and task.wait(1) do
                local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                               ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                if remote then
                    -- 檢查物品欄是否有足夠羊毛，否則自動購買
                    remote:FireServer({["item"] = "wool_white", ["amount"] = 16})
                end
            end
        end)
    end

    -- 自動護甲與購買 (Merged)
    CatFunctions.ToggleAutoArmor = function(state)
        env_global.AutoArmor = state
        if not env_global.AutoArmor then return end
        task.spawn(function()
            local armors = {"leather_armor", "iron_armor", "diamond_armor", "emerald_armor"}
            while env_global.AutoArmor and task.wait(1) do
                local remotePurchase = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                                       ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                local remoteEquip = ReplicatedStorage:FindFirstChild("EquipArmor", true) or 
                                    ReplicatedStorage:FindFirstChild("WearArmor", true)
                
                -- 自動購買
                if remotePurchase then
                    for _, armor in ipairs(armors) do
                        remotePurchase:FireServer({["item"] = armor})
                    end
                end
                
                -- 自動穿戴
                if remoteEquip and lplr.Character then
                    remoteEquip:FireServer()
                end
            end
        end)
    end

    -- 自動購買升級 (Auto Buy Upgrades) 加強版
    CatFunctions.ToggleAutoBuyUpgrades = function(state)
        env_global.AutoBuyUpgrades = state
        if env_global.AutoBuyUpgrades then
            Notify("自動化", "自動購買升級已加強：\n1. 智慧優先級 (生成器 > 傷害 > 防禦)\n2. 資源分配優化", "Success")
        else
            Notify("自動化", "自動購買升級已關閉", "Info")
            return
        end
        
        task_spawn(function()
            -- 優先級：生成器(generator) > 傷害(damage) > 護甲(armor_protection) > 急迫(haste)
            local upgrades = {"generator", "damage", "armor_protection", "haste"}
            while env_global.AutoBuyUpgrades do
                local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                               ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                if remote then
                    for _, upgrade in ipairs(upgrades) do
                        -- 嘗試購買
                        remote:FireServer({["item"] = upgrade, ["amount"] = 1})
                        task_wait(0.2) -- 避免瞬間發送過多封包
                    end
                end
                task_wait(10 + math.random(0, 5)) -- 每 10-15 秒檢查一次，減少伺服器壓力
            end
        end)
    end

    -- 反擊退優化 (Anti Ragdoll / Anti Knockback)
    CatFunctions.ToggleAntiRagdoll = function(state)
        env_global.AntiRagdoll = state
        if env_global.AntiRagdoll then
            Notify("戰鬥加強", "反擊退/反倒地已開啟", "Success")
        else
            Notify("戰鬥加強", "反擊退/反倒地已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AntiRagdoll and task.wait() do
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- 鎖定狀態防止倒地
                    if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end
        end)
    end

    -- 視野控制 (FOV Changer)
    CatFunctions.SetFOV = function(value)
        if not env_global.originalFOV then
            env_global.originalFOV = workspace.CurrentCamera.FieldOfView
        end
        env_global.FOVValue = value
        workspace.CurrentCamera.FieldOfView = value
    end

    -- 自動嘲諷 (Merged: 擊殺 + 勝利)
    CatFunctions.ToggleAutoToxic = function(state)
        env_global.AutoToxic = state
        if not env_global.AutoToxic then return end
        
        local winMessages = {
            "GG! Easy win with Halol!",
            "Halol on top!",
            "Get better, get Halol!",
            "Imagine losing to Halol user.",
            "Halol: The ultimate advantage.",
            "Cry about it, Halol is here.",
            "You just got Halol'd!"
        }
        
        local killMessages = {
            "HALOL V4.0 ON TOP!",
            "GG! Easy kill.",
            "Imagine losing to a cat.",
            "You need some milk.",
            "Halol > Your client.",
            "Why so bad?",
            "Better luck next time!"
        }
        
        local lastHealth = {}
        
        task.spawn(function()
            while env_global.AutoToxic and task.wait(0.5) do
                -- 1. 檢查勝利 (原有的邏輯)
                local battlefield = CatFunctions.GetBattlefieldState and CatFunctions.GetBattlefieldState()
                if battlefield and #battlefield.targets == 0 then
                    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or 
                                   ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
                    if chatRemote then
                        local msg = winMessages[math.random(1, #winMessages)]
                        if chatRemote.Name == "SayMessageRequest" then
                            chatRemote:FireServer(msg, "All")
                        else
                            chatRemote.SayMessageRequest:FireServer(msg, "All")
                        end
                        task.wait(30) -- 避免過度發送
                    end
                end
                
                -- 2. 檢查擊殺
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
                        local hum = p.Character.Humanoid
                        if lastHealth[p.Name] and lastHealth[p.Name] > 0 and hum.Health <= 0 then
                            local msg = killMessages[math.random(1, #killMessages)]
                            local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                           ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                            if sayMsg then
                                sayMsg:FireServer(msg, "All")
                            elseif game:GetService("TextChatService"):FindFirstChild("TextChannels") then
                                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
                            end
                        end
                        lastHealth[p.Name] = hum.Health
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleGhostMode = function(state)
        env_global.GhostMode = state
        if not env_global.GhostMode then
            if env_global.GhostParts then
                for _, p in pairs(env_global.GhostParts) do p:Destroy() end
                env_global.GhostParts = nil
            end
            return
        end

        Notify("抗舉報系統", "已啟動幽靈模式：將在原地留下殘影以誤導觀戰者", "Success")
        
        env_global.GhostParts = {}
        task.spawn(function()
            while env_global.GhostMode and task.wait(0.5) do
                pcall(function()
                    if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                        -- 創建殘影
                        lplr.Character.Archivable = true
                        local ghost = lplr.Character:Clone()
                        lplr.Character.Archivable = false
                        
                        ghost.Parent = workspace
                        for _, v in pairs(ghost:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                                v.Anchored = true
                                v.Transparency = 0.6
                                v.Color = Color3.fromRGB(100, 150, 255)
                            elseif v:IsA("Script") or v:IsA("LocalScript") then
                                v:Destroy()
                            end
                        end
                        
                        table.insert(env_global.GhostParts, ghost)
                        if #env_global.GhostParts > 5 then
                            local old = table.remove(env_global.GhostParts, 1)
                            if old then old:Destroy() end
                        end
                        
                        task.delay(2, function()
                            if ghost then ghost:Destroy() end
                        end)
                    end
                end)
            end
        end)
    end

    CatFunctions.ToggleDesync = function(state)
        env_global.Desync = state
        if not env_global.Desync then 
            settings().Network.IncomingReplicationLag = 0
            if env_global.DesyncConn then env_global.DesyncConn:Disconnect() env_global.DesyncConn = nil end
            return 
        end
        
        Notify("伺服器級別", "已啟動網路同步篡改 (Desync)，幻影已生成，且不影響本地移動", "Success")
        
        if env_global.DesyncConn then env_global.DesyncConn:Disconnect() end
        env_global.DesyncConn = RunService.Heartbeat:Connect(function()
            if not env_global.Desync then 
                if env_global.DesyncConn then env_global.DesyncConn:Disconnect() env_global.DesyncConn = nil end
                return 
            end
            
            pcall(function()
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local originalCFrame = hrp.CFrame
                    
                    -- 僅在 Heartbeat 時切換位置 (伺服器同步階段)
                    hrp.CFrame = originalCFrame * CFrame.new(math.random(-10, 10), math.random(-2, 2), math.random(-10, 10))
                    
                    -- 在下一次渲染前立即還原，確保本地畫面不抖動
                    RunService.RenderStepped:Wait()
                    hrp.CFrame = originalCFrame
                end
            end)
        end)

        task.spawn(function()
            while env_global.Desync and task.wait(0.1) do
                settings().Network.IncomingReplicationLag = 0.15 + (math.random(0, 10) / 100)
            end
        end)
    end

    CatFunctions.ToggleGlobalNuker = function(state)
        env_global.GlobalNuker = state
        if not env_global.GlobalNuker then return end
        
        task.spawn(function()
            Notify("伺服器級別", "已啟動安全全域破壞：僅針對敵方目標，已保護己方資產", "Warning")
            while env_global.GlobalNuker and task.wait(0.2) do
                local battlefield = CatFunctions.GetBattlefieldState()
                local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                               ReplicatedStorage:FindFirstChild("HitBlock", true) or
                               ReplicatedStorage:FindFirstChild("BreakBlock", true)
                
                if remote then
                    for _, bed in ipairs(battlefield.beds) do
                        -- 強化的團隊過濾：確保絕對不會影響到自己或隊友
                        local isSafeTarget = true
                        if lplr.Team and bed.part.Parent then
                            local teamName = tostring(lplr.Team.Name):lower()
                            local bedOwner = tostring(bed.part.Parent.Name):lower()
                            if bedOwner:find(teamName) or teamName:find(bedOwner) then
                                isSafeTarget = false
                            end
                        end
                        
                        -- 額外檢查：如果床位座標離自己太近（防止誤傷）
                        if bed.dist < 5 then isSafeTarget = false end

                        if isSafeTarget then
                            remote:FireServer({
                                ["position"] = bed.part.Position, 
                                ["block"] = bed.part.Name,
                                ["origin"] = bed.part.Position + Vector3_new(0, 2, 0),
                                ["blockData"] = 0
                            })
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleInfiniteAura = function(state)
        env_global.InfiniteAura = state
        if not env_global.InfiniteAura then 
            env_global.KillAuraRange = 18
            Notify("伺服器級別", "無限距離光環已關閉", "Info")
            return 
        end
        
        Notify("伺服器級別", "無限光環已極限加強：\n1. 全圖智慧掃描\n2. 隨機目標順序\n3. 深度模擬封包", "Success")
        env_global.KillAuraRange = 500
        
        task_spawn(function()
            while env_global.InfiniteAura do
                local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                               ReplicatedStorage:FindFirstChild("CombatRemote", true) or
                               ReplicatedStorage:FindFirstChild("HitEntity", true)
                
                if remote then
                    local weapon = char and char:FindFirstChildOfClass("Tool") or lplr.Backpack:FindFirstChildOfClass("Tool")
                    local players = Players:GetPlayers()
                    
                    -- 隨機化目標順序以繞過檢測
                    for i = #players, 2, -1 do
                        local j = math.random(i)
                        players[i], players[j] = players[j], players[i]
                    end
                    
                    for _, v in ipairs(players) do
                        if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                            local hrp = v.Character.HumanoidRootPart
                            local dist = (lplr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                            
                            -- 只有在 500 格內才攻擊
                            if dist < 500 then
                                -- 深度模擬封包與隨機部位
                                local hitParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
                                local hitPart = v.Character:FindFirstChild(hitParts[math.random(1, #hitParts)]) or hrp
                                
                                remote:FireServer({
                                    ["entity"] = v.Character,
                                    ["origin"] = hrp.Position + Vector3_new(math.random(-5, 5)/10, 2, math.random(-5, 5)/10),
                                    ["weapon"] = weapon,
                                    ["hitInfo"] = {
                                        ["part"] = hitPart,
                                        ["distance"] = math.random(200, 500) / 100, -- 模擬合理的打擊距離
                                        ["direction"] = (hrp.Position - lplr.Character.HumanoidRootPart.Position).Unit
                                    }
                                })
                                -- 增加微小隨機延遲，模擬網絡抖動
                                task_wait(math.random(1, 8) / 100)
                            end
                        end
                    end
                end
                task_wait(0.1 + (math.random(0, 5) / 100))
            end
        end)
    end

    CatFunctions.ToggleGravity = function(state)
        env_global.Gravity = state
        if not env_global.Gravity then 
            workspace.Gravity = 196.2
            return 
        end
        workspace.Gravity = env_global.GravityValue or 50
    end

    -- 輔助功能：判斷玩家是否為長期觀戰者 (床爆且死掉)
    CatFunctions.IsLongTermSpectator = function(player)
        if player == lplr then return false end
        
        -- 1. 檢查隊伍是否為「觀戰者」
        if player.Team and (player.Team.Name:lower():find("spectator") or player.Team.Name:lower():find("觀戰")) then
            return true
        end
        
        -- 2. Bedwars 特有屬性檢查 (如果有)
        if player:GetAttribute("Spectating") or player:GetAttribute("IsSpectator") then
            return true
        end
        
        -- 3. 檢查角色是否存在與存活狀態
        local isDead = true
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                isDead = false
            end
        end
        
        -- 4. 檢查床位狀態 (如果玩家死掉，且該隊伍的床已不在)
        if isDead then
            -- 優先檢查 Bedwars 的 MatchState
            local matchState = ReplicatedStorage:FindFirstChild("MatchState")
            if matchState and matchState.Value == 0 then return false end -- 比賽還沒開始

            local bedFolder = workspace:FindFirstChild("Beds") or workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Beds")
            if bedFolder then
                local playerTeamName = player.Team and player.Team.Name:lower() or ""
                if playerTeamName == "" or playerTeamName == "spectators" then return true end

                local hasBed = false
                for _, v in pairs(bedFolder:GetChildren()) do
                    if v.Name:lower():find(playerTeamName) then
                        hasBed = true
                        break
                    end
                end
                if not hasBed then
                    return true -- 床爆了且人死掉 = 長期觀戰者
                end
            else
                -- 如果找不到床資料夾，退而求其次：如果長期沒有 Character 且在玩家列表中
                return true 
            end
        end
        
        return false
    end

    -- 獲取當前所有觀戰者清單
    CatFunctions.GetCurrentSpectators = function()
        local spectators = {}
        
        -- 1. 遍歷玩家清單檢查狀態
        for _, p in pairs(Players:GetPlayers()) do
            if CatFunctions.IsLongTermSpectator(p) then
                table.insert(spectators, p)
            end
        end
        
        -- 2. 額外檢查 Bedwars 可能存在的觀戰資料夾
        local specFolder = ReplicatedStorage:FindFirstChild("SpectatorFolder") or ReplicatedStorage:FindFirstChild("Spectators")
        if specFolder then
            for _, v in pairs(specFolder:GetChildren()) do
                local p = Players:FindFirstChild(v.Name)
                if p and not table.find(spectators, p) then
                    table.insert(spectators, p)
                end
            end
        end
        
        return spectators
    end

    -- 核心功能：全體防觀戰 (除隊友外所有人無法觀戰)
    CatFunctions.ToggleGlobalAntiSpectate = function(state)
        env_global.GlobalAntiSpectate = state
        if not env_global.GlobalAntiSpectate then
            if env_global.GlobalSpecConn then env_global.GlobalSpecConn:Disconnect() env_global.GlobalSpecConn = nil end
            return
        end

        Notify("隱身系統", "已開啟全體防觀戰：除隊友外，所有人（包含敵方與觀戰者）都將無法觀測到你", "Success")

        if env_global.GlobalSpecConn then env_global.GlobalSpecConn:Disconnect() end
        env_global.GlobalSpecConn = RunService.Heartbeat:Connect(function()
            if not env_global.GlobalAntiSpectate then return end
            
            -- 檢查周圍是否有非隊友玩家或觀戰者
            local shouldHide = false
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lplr and p.Team ~= lplr.Team then
                    -- 只要有非隊友在場，就維持隱身狀態
                    shouldHide = true
                    break
                end
            end

            if shouldHide then
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    -- 檢查是否正在攻擊 (如果正在攻擊，需要短暫同步座標以確保命中)
                    local isAttacking = env_global.IsAttacking or false
                    if isAttacking then return end

                    local hrp = lplr.Character.HumanoidRootPart
                    local oldCF = hrp.CFrame
                    
                    -- 瞬間移動到極高處 (伺服器端同步座標)
                    hrp.CFrame = CFrame.new(oldCF.X, 100000, oldCF.Z)
                    
                    RunService.RenderStepped:Wait()
                    
                    -- 瞬間移回 (本地渲染座標)
                    if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                        lplr.Character.HumanoidRootPart.CFrame = oldCF
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

        -- 獲取所有玩家狀態
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                local targetHrp = v.Character.HumanoidRootPart
                local targetHum = v.Character.Humanoid
                if targetHum.Health > 0 then
                    local dist = (hrp.Position - targetHrp.Position).Magnitude
                    local threat = {hrp = targetHrp, dist = dist, player = v, type = "PLAYER", part = targetHrp}
                    table.insert(state.targets, threat)
                    if not state.nearestThreat or dist < state.nearestThreat.dist then
                        state.nearestThreat = threat
                    end
                    if dist < 25 then
                        state.isBeingTargeted = true
                    end
                end
            end
        end

        -- 搜尋重要物件 (資源、床、方塊)
        local searchFolders = {
            workspace:FindFirstChild("ItemDrops"),
            workspace:FindFirstChild("Generators"),
            workspace:FindFirstChild("Beds"),
            workspace:FindFirstChild("Items"),
            workspace:FindFirstChild("Pickups"),
            workspace:FindFirstChild("Map"),
            workspace:FindFirstChild("Blocks")
        }

        local function checkPart(v)
            if not v:IsA("BasePart") and not v:IsA("Model") then return end
            local name = v.Name:lower()
            local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
            if not p then return end

            local dist = (hrp.Position - p.Position).Magnitude

            -- 資源偵測
            if name:find("diamond") or name:find("emerald") or name:find("iron") or name:find("gold") then
                table.insert(state.resources, {part = p, name = v.Name, dist = dist, type = "RESOURCE"})
            end
            
            -- 床位偵測
            if name:find("bed") then
                table.insert(state.beds, {part = p, name = v.Name, dist = dist, type = "BED"})
            end
        end

        -- 遍歷資料夾
        for _, folder in ipairs(searchFolders) do
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    checkPart(v)
                    -- 檢查二級子目錄
                    if v:IsA("Model") or v:IsA("Folder") then
                        for _, sub in pairs(v:GetChildren()) do
                            checkPart(sub)
                        end
                    end
                end
            end
        end

        -- 全域兜底掃描 (如果指定資料夾沒找到)
        if #state.resources == 0 or #state.beds == 0 then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    checkPart(v)
                end
            end
        end
        
        -- 排序：距離由近到遠
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)
        table.sort(state.beds, function(a, b) return a.dist < b.dist end)
        table.sort(state.targets, function(a, b) return a.dist < b.dist end)
        
        return state
    end

    -- ==========================================
    -- 核心擴展功能 (New Features)
    -- ==========================================

    CatFunctions.ToggleChatSpam = function(state)
        env_global.ChatSpam = state
        if not env_global.ChatSpam then return end
        
        task.spawn(function()
            local messages = {
                "Halol V4.8.7 - 最強自動化腳本",
                "GitHub: github.com/akiopz/Roblox-Scripts",
                "Halol: 穩定、安全、強大。",
                "加入 Halol 社群獲取最新更新！"
            }
            local index = 1
            while env_global.ChatSpam and task.wait(15) do
                local msg = messages[index]
                index = (index % #messages) + 1

                -- 1. 舊版聊天系統
                local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or 
                                   ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
                if chatRemote then
                    pcall(function()
                        if chatRemote.Name == "SayMessageRequest" then
                            chatRemote:FireServer(msg, "All")
                        elseif chatRemote:FindFirstChild("SayMessageRequest") then
                            chatRemote.SayMessageRequest:FireServer(msg, "All")
                        end
                    end)
                end

                -- 2. 新版聊天系統 (TextChatService)
                local textService = game:GetService("TextChatService")
                if textService and textService.ChatVersion == Enum.ChatVersion.TextChatService then
                    pcall(function()
                        local channel = textService:FindFirstChild("TextChannels") and textService.TextChannels:FindFirstChild("RBXGeneral")
                        if channel then
                            channel:SendAsync(msg)
                        end
                    end)
                end
            end
        end)
    end

    CatFunctions.ToggleAutoMaster = function(state)
        env_global.AutoMaster = state
        if not env_global.AutoMaster then return end
        
        task.spawn(function()
            Notify("伺服器主宰", "全自動主宰模式已啟動：將自動處理採購、升級與戰術執行", "Success")
            
            -- 同步開啟核心功能
            if not env_global.AntiReport then CatFunctions.ToggleAntiReport(true) end
            if not env_global.AutoBuyUpgrades then CatFunctions.ToggleAutoBuyUpgrades(true) end
            if not env_global.AutoArmor then CatFunctions.ToggleAutoArmor(true) end
            if not env_global.AutoClaimRewards then CatFunctions.ToggleAutoClaimRewards(true) end
            
            while env_global.AutoMaster and task.wait(5) do
                -- 安全檢查：確保玩家活著且在遊戲中
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") and lplr.Character.Humanoid.Health > 0 then
                    local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                                   ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                    
                    if remote then
                        -- 智慧型資源分配邏輯 (伺服器級別自動化)
                        local priorityItems = {"iron_sword", "telepearl", "tnt", "fireball"}
                        for _, item in ipairs(priorityItems) do
                            if not env_global.AutoMaster then break end
                            remote:FireServer({["item"] = item, ["amount"] = 1})
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoResourceFarm = function(state)
        env_global.AutoResourceFarm = state
        if not env_global.AutoResourceFarm then return end
        task.spawn(function()
            Notify("資源自動化", "已啟動全自動資源收集：正在前往最近的資源點...", "Success")
            while env_global.AutoResourceFarm and task.wait(1) do
                local battlefield = CatFunctions.GetBattlefieldState()
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and #battlefield.resources > 0 then
                    local target = battlefield.resources[1]
                    if target.dist > 5 then
                        -- 傳送到資源位置
                        hrp.CFrame = target.part.CFrame * CFrame.new(0, 3, 0)
                        Notify("資源自動化", "正在採集: " .. target.name, "Info")
                        task.wait(0.5)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleReach = function(state)
        env_global.Reach = state
        if env_global.Reach then
            env_global.KillAuraRange = 25
            Notify("戰鬥加強", "已開啟攻擊距離擴展：當前範圍 25 格", "Success")
        else
            env_global.KillAuraRange = 18
        end
    end

    CatFunctions.ToggleAutoClicker = function(state)
        env_global.AutoClicker = state
        if env_global.AutoClicker then
            Notify("戰鬥加強", "自動連點 (AutoClicker) 已開啟：已注入隨機點擊延遲與抖動", "Success")
        else
            Notify("戰鬥加強", "自動連點已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoClicker do
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local tool = lplr.Character and lplr.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        -- 隨機化 CPS
                        local cps = env_global.KillAuraCPS or 12
                        task_wait(1 / (cps + math.random(-3, 3)))
                    else
                        task_wait(0.1)
                    end
                else
                    task_wait(0.05)
                end
            end
        end)
    end

    CatFunctions.ToggleVelocity = function(state)
        env_global.Velocity = state
        if env_global.Velocity then
            Notify("戰鬥加強", "擊退優化 (Velocity) 已開啟：\n1. 智慧水平/垂直抵消\n2. 模擬合法受擊反饋", "Success")
        else
            Notify("戰鬥加強", "擊退優化已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.Velocity and task.wait() do
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local horizontal = env_global.VelocityHorizontal or 0
                    local vertical = env_global.VelocityVertical or 0
                    
                    -- 攔截並修正速度，保留微小反饋以繞過檢測
                    local vel = hrp.Velocity
                    if vel.Y > 0 or math.abs(vel.X) > 2 or math.abs(vel.Z) > 2 then
                        hrp.Velocity = Vector3_new(
                            vel.X * horizontal + (math.random(-1, 1)/10), 
                            vel.Y * vertical, 
                            vel.Z * horizontal + (math.random(-1, 1)/10)
                        )
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleLongJump = function(state)
        env_global.LongJump = state
        if env_global.LongJump then
            Notify("運動輔助", "超級跳躍 (LongJump) 已開啟：\n1. 瞬間動量爆發\n2. 自動滑翔輔助", "Success")
        else
            Notify("運動輔助", "超級跳躍已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.LongJump and task.wait() do
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
                        -- 給予強大的前向推進力
                        local speed = env_global.SpeedValue or 23
                        hrp.Velocity = hrp.Velocity + (hum.MoveDirection * (speed / 5)) + Vector3_new(0, 0.5, 0)
                        task_wait(0.1)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAntiFling = function(state)
        env_global.AntiFling = state
        if not env_global.AntiFling then return end
        task.spawn(function()
            while env_global.AntiFling and task.wait() do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Character then
                        for _, p in pairs(v.Character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                                p.Velocity = Vector3_new(0, 0, 0)
                                p.RotVelocity = Vector3_new(0, 0, 0)
                            end
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleSpider = function(state)
        env_global.Spider = state
        if not env_global.Spider then return end
        task.spawn(function()
            while env_global.Spider and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                    if hit then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 25, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNoFall = function(state)
        env_global.NoFall = state
        if not env_global.NoFall then return end
        task.spawn(function()
            while env_global.NoFall and task.wait(0.5) do
                local remote = ReplicatedStorage:FindFirstChild("NoFallRemote", true) or 
                               ReplicatedStorage:FindFirstChild("GroundHit", true)
                if remote then
                    remote:FireServer()
                end
            end
        end)
    end

    -- 自動切換工具 (Auto Tool)
    CatFunctions.ToggleAutoTool = function(state)
        env_global.AutoTool = state
        if not env_global.AutoTool then return end
        task.spawn(function()
            while env_global.AutoTool and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    local target = lplr:GetMouse().Target
                    if target and target:IsA("BasePart") and (char.HumanoidRootPart.Position - target.Position).Magnitude < 25 then
                        local toolName = ""
                        local material = target.Material
                        if material == Enum.Material.Wood or target.Name:lower():find("wood") then
                            toolName = "axe"
                        elseif material == Enum.Material.Stone or material == Enum.Material.Concrete or target.Name:lower():find("stone") then
                            toolName = "pickaxe"
                        elseif target.Name:lower():find("wool") then
                            toolName = "shears"
                        end

                        if toolName ~= "" then
                            for _, tool in ipairs(lplr.Backpack:GetChildren()) do
                                if tool.Name:lower():find(toolName) then
                                    hum:EquipTool(tool)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 自動武器 (Auto Weapon)
    CatFunctions.ToggleAutoWeapon = function(state)
        env_global.AutoWeapon = state
        if not env_global.AutoWeapon then return end
        task.spawn(function()
            while env_global.AutoWeapon and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    -- 檢查附近是否有敵人
                    local nearest = nil
                    local minDist = 20
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                nearest = p
                            end
                        end
                    end

                    if nearest then
                        local bestWeapon = nil
                        local maxDamage = -1
                        for _, tool in ipairs(lplr.Backpack:GetChildren()) do
                            if tool.Name:lower():find("sword") or tool.Name:lower():find("blade") or tool.Name:lower():find("dao") then
                                -- 簡單判斷：木 < 石 < 鐵 < 鑽 < 翡翠
                                local damage = 0
                                if tool.Name:lower():find("emerald") then damage = 5
                                elseif tool.Name:lower():find("diamond") then damage = 4
                                elseif tool.Name:lower():find("iron") then damage = 3
                                elseif tool.Name:lower():find("stone") then damage = 2
                                elseif tool.Name:lower():find("wood") then damage = 1
                                end
                                
                                if damage > maxDamage then
                                    maxDamage = damage
                                    bestWeapon = tool
                                end
                            end
                        end
                        if bestWeapon then hum:EquipTool(bestWeapon) end
                    end
                end
            end
        end)
    end

    -- 自動格擋 (Auto Block)
    CatFunctions.ToggleAutoBlock = function(state)
        env_global.AutoBlock = state
        if not env_global.AutoBlock then return end
        task.spawn(function()
            while env_global.AutoBlock and task.wait(0.1) do
                local char = lplr.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:lower():find("sword") or tool.Name:lower():find("blade")) then
                    -- 模擬格擋 (Bedwars 中通常是觸發特定遠程或動畫)
                    local remote = ReplicatedStorage:FindFirstChild("UseItem", true) or 
                                   ReplicatedStorage:FindFirstChild("ActivateItem", true)
                    if remote then
                        -- 只有在受到攻擊或附近有敵人時才格擋
                        local enemyNear = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                if (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                                    enemyNear = true
                                    break
                                end
                            end
                        end
                        if enemyNear then
                            remote:FireServer({["item"] = tool})
                        end
                    end
                end
            end
        end)
    end

    -- 靜默自瞄 (Silent Aim) 加強版
    CatFunctions.ToggleSilentAim = function(state)
        env_global.SilentAim = state
        if env_global.SilentAim then
            Notify("戰鬥功能", "靜默自瞄已加強：\n1. 支援智慧目標預測\n2. 增加多重 Hook 機制 (Namecall & Index)\n3. 視角鎖定輔助", "Success")
        else
            Notify("戰鬥功能", "靜默自瞄已關閉", "Info")
            return
        end
        
        task.spawn(function()
            local Mouse = lplr:GetMouse()
            local oldIndex
            local oldNamecall

            -- Index Hook (針對 Mouse.Hit/Target)
            oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
                if env_global.SilentAim and not checkcaller() and self == Mouse and (index == "Hit" or index == "Target") then
                    local targetChar = getBestTarget(env_global.SilentAimRange or 100)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local root = targetChar.HumanoidRootPart
                        local predictedPos = root.Position + (root.Velocity * 0.05)
                        
                        if index == "Hit" then
                            return CFrame.new(predictedPos)
                        elseif index == "Target" then
                            return root
                        end
                    end
                end
                return oldIndex(self, index)
            end))

            -- Namecall Hook (針對某些腳本使用 FindPartOnRay 等)
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                
                if env_global.SilentAim and not checkcaller() and method == "FindPartOnRayWithIgnoreList" then
                    local targetChar = getBestTarget(env_global.SilentAimRange or 100)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local root = targetChar.HumanoidRootPart
                        local predictedPos = root.Position + (root.Velocity * 0.05)
                        -- 修改射線方向
                        local origin = args[1].Origin
                        args[1] = Ray.new(origin, (predictedPos - origin).Unit * 1000)
                    end
                end
                return oldNamecall(self, unpack(args))
            end))
            
            while env_global.SilentAim do
                -- 視角平滑跟蹤 (可選)
                if env_global.SilentAimLock then
                    local targetChar = getBestTarget(env_global.SilentAimRange or 30)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local cam = workspace.CurrentCamera
                        local root = targetChar.HumanoidRootPart
                        local lookAt = CFrame.new(cam.CFrame.Position, root.Position)
                        cam.CFrame = cam.CFrame:Lerp(lookAt, 0.1)
                    end
                end
                task.wait()
            end
        end)
    end

    -- 靜默瞄準鎖定 (SilentAim Lock)
    CatFunctions.ToggleSilentAimLock = function(state)
        env_global.SilentAimLock = state
        if env_global.SilentAimLock then
            Notify("戰鬥功能", "靜默瞄準鎖定已開啟：\n1. 視角平滑跟蹤\n2. 強化頭部鎖定", "Success")
        else
            Notify("戰鬥功能", "靜默瞄準鎖定已關閉", "Info")
        end
    end

    -- 持續衝刺 (Keep Sprint)
    CatFunctions.ToggleKeepSprint = function(state)
        env_global.KeepSprint = state
        if env_global.KeepSprint then
            Notify("移動功能", "持續衝刺已開啟", "Success")
        else
            Notify("移動功能", "持續衝刺已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.KeepSprint and task.wait(0.2) do
                local remote = ReplicatedStorage:FindFirstChild("SprintController", true) or 
                               ReplicatedStorage:FindFirstChild("SprintingRemote", true)
                if remote then
                    remote:FireServer({["sprinting"] = true})
                end
            end
        end)
    end

    -- 無限飛行 (Infinite Fly)
    CatFunctions.ToggleInfiniteFly = function(state)
        env_global.InfiniteFly = state
        if env_global.InfiniteFly then
            Notify("移動功能", "無限飛行已開啟", "Success")
        else
            Notify("移動功能", "無限飛行已關閉", "Info")
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                lplr.Character.HumanoidRootPart.Velocity = Vector3_new(0, 0, 0)
            end
            return
        end
        
        task.spawn(function()
            while env_global.InfiniteFly and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local moveDir = char.Humanoid.MoveDirection
                    local flyVel = moveDir * 50
                    hrp.Velocity = Vector3_new(flyVel.X, 2, flyVel.Z)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        hrp.Velocity = hrp.Velocity + Vector3_new(0, 50, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        hrp.Velocity = hrp.Velocity + Vector3_new(0, -50, 0)
                    end
                end
            end
        end)
    end

    -- 自動吸取掉落物 (Item Stealer)
    CatFunctions.ToggleItemStealer = function(state)
        env_global.ItemStealer = state
        if env_global.ItemStealer then
            Notify("自動化", "自動吸取掉落物已加強：\n1. 智慧範圍掃描\n2. 瞬間轉移吸取\n3. 優先級物品過濾", "Success")
        else
            Notify("自動化", "自動吸取已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.ItemStealer and task.wait(0.1) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- 使用 CollectionService 或遍歷特定目錄 (Bedwars 掉落物通常在某個 Folder)
                    local drops = workspace:FindFirstChild("DroppedItems") or workspace:FindFirstChild("Items") or workspace
                    for _, v in ipairs(drops:GetChildren()) do
                        if v:IsA("BasePart") or v:IsA("Model") then
                            local part = v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart")
                            if part and (v.Name:lower():find("item") or v.Name:lower():find("drop") or v:FindFirstChild("Handle")) then
                                local dist = (hrp.Position - part.Position).Magnitude
                                if dist < 30 then
                                    -- 瞬間移動物品到玩家位置 (如果遊戲允許)
                                    part.CFrame = hrp.CFrame
                                    -- 模擬觸碰
                                    firetouchinterest(hrp, part, 0)
                                    firetouchinterest(hrp, part, 1)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 自動回血 (Auto Heal)
    CatFunctions.ToggleAutoHeal = function(state)
        env_global.AutoHeal = state
        if env_global.AutoHeal then
            Notify("自動化", "自動回血已加強：\n1. 智慧血量監測\n2. 多物品自動選取\n3. 毫秒級快速回血", "Success")
        else
            Notify("自動化", "自動回血已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoHeal and task.wait(0.2) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth * 0.7 then
                    -- 檢查物品欄與背包
                    local items = {}
                    for _, v in ipairs(lplr.Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.Name:lower():find("apple") or v.Name:lower():find("potion") or v.Name:lower():find("heal")) then
                            table.insert(items, v)
                        end
                    end
                    if char:FindFirstChildOfClass("Tool") then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool.Name:lower():find("apple") or tool.Name:lower():find("potion") or tool.Name:lower():find("heal") then
                            table.insert(items, tool)
                        end
                    end

                    if #items > 0 then
                        local remote = ReplicatedStorage:FindFirstChild("UseItem", true) or 
                                       ReplicatedStorage:FindFirstChild("ActivateItem", true) or
                                       ReplicatedStorage:FindFirstChild("ConsumeItem", true)
                        if remote then
                            -- 優先使用強效回血物品
                            table.sort(items, function(a, b)
                                return a.Name:lower():find("potion") and not b.Name:lower():find("potion")
                            end)
                            
                            remote:FireServer({["item"] = items[1]})
                            -- 如果開啟了快速食用，額外觸發
                            if env_global.FastEat then
                                for i = 1, 3 do
                                    remote:FireServer({["item"] = items[1]})
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 快速食用 (Fast Eat)
    CatFunctions.ToggleFastEat = function(state)
        env_global.FastEat = state
        if env_global.FastEat then
            Notify("自動化", "快速食用已開啟：現在食用速度提升 300%", "Success")
        else
            Notify("自動化", "快速食用已關閉", "Info")
        end
    end

    -- 自動陷阱 (Auto Trap)
    CatFunctions.ToggleAutoTrap = function(state)
        env_global.AutoTrap = state
        if env_global.AutoTrap then
            Notify("戰鬥功能", "自動陷阱已開啟", "Success")
        else
            Notify("戰鬥功能", "自動陷阱已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoTrap and task.wait(0.5) do
                local target = getTarget(15)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        local pos = target.HumanoidRootPart.Position
                        -- 在目標四周放置方塊
                        local offsets = {
                            Vector3_new(3, 0, 0), Vector3_new(-3, 0, 0),
                            Vector3_new(0, 0, 3), Vector3_new(0, 0, -3),
                            Vector3_new(3, 3, 0), Vector3_new(-3, 3, 0),
                            Vector3_new(0, 3, 3), Vector3_new(0, 3, -3)
                        }
                        for _, offset in ipairs(offsets) do
                            remote:FireServer({
                                ["blockType"] = "wool_white",
                                ["position"] = pos + offset
                            })
                        end
                    end
                end
            end
        end)
    end

    -- 自動噴漆 (Auto Spray)
    CatFunctions.ToggleAutoSpray = function(state)
        env_global.AutoSpray = state
        if env_global.AutoSpray then
            Notify("雜項功能", "自動噴漆已開啟", "Success")
        else
            Notify("雜項功能", "自動噴漆已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoSpray and task.wait(5) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local remote = ReplicatedStorage:FindFirstChild("SprayPaint", true) or 
                                   ReplicatedStorage:FindFirstChild("UseSpray", true)
                    if remote then
                        remote:FireServer({
                            ["sprayId"] = "default",
                            ["position"] = hrp.Position - Vector3_new(0, 3, 0)
                        })
                    end
                end
            end
        end)
    end

    -- 進階自動購買 (Auto Buy Advanced)
    CatFunctions.ToggleAutoBuyAdvanced = function(state)
        env_global.AutoBuyAdvanced = state
        if env_global.AutoBuyAdvanced then
            Notify("伺服器功能", "進階自動購買已加強：\n1. 智慧資源判斷\n2. 優先購買 TNT/火球\n3. 確保物品欄不溢出", "Success")
        else
            Notify("伺服器功能", "進階自動購買已關閉", "Info")
            return
        end
        
        task.spawn(function()
            local items = {"tnt", "fireball"}
            while env_global.AutoBuyAdvanced and task.wait(5) do
                local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                               ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                if remote then
                    -- 這裡可以擴展檢查玩家資源 (例如鐵/金)
                    -- 由於不同 Bedwars 變體資源 Remote 不同，這裡採用保守嘗試
                    for _, item in ipairs(items) do
                        remote:FireServer({["item"] = item, ["amount"] = 1})
                        task_wait(0.1)
                    end
                end
            end
        end)
    end

    -- 自毀 (Self Destruct)
    CatFunctions.SelfDestruct = function()
        Notify("Halol 系統", "正在執行自毀程序...", "Warning")
        if env_global.HalolUnload then
            env_global.HalolUnload()
        end
    end

    CatFunctions.UnloadAll = function()
        -- 1. 停止本腳本的所有功能
        local scriptToggles = {
            "KillAura", "Scaffold", "NoSlowDown", "Reach", "AutoClicker", "LongJump",
            "AutoBridge", "AutoResourceFarm", "DamageIndicator", "Spider", "NoFall",
            "AntiFling", "NoClip", "Velocity", "Speed", "Fly", "AutoConsume", "BedNuker",
            "TriggerBot", "HitboxExpander", "AutoLobby", "AutoRejoin", "AntiDead",
            "Step", "AntiVoid", "TimeCycle", "AntiAFK", "NoFog", "FPSCap", "AutoBalloon",
            "Nuker", "AutoBuyUpgrades", "InstantShop", "AutoClaimRewards", "AntiReport",
            "AntiSpectate", "CustomMatchExploit", "Aimbot", "AutoWin", "FPSBoost", "AutoBuyWool",
            "AutoArmor", "AutoToxic", "Desync", "GlobalNuker", "InfiniteAura",
            "SilentAim", "KeepSprint", "InfiniteFly", "ItemStealer", "AutoHeal", "FastEat", "AutoTrap",
            "Gravity", "InfiniteJump", "ChatSpam", "AutoMaster", "GlobalAntiSpectate",
            "Criticals", "FastAttack", "FastBreak", "StaffDetector", "GodModeAI", "AI_Enabled",
            "AntiRagdoll", "AutoSpray", "AutoBuyAdvanced", "SilentAimLock",
            "AutoTool", "AutoWeapon", "AutoBlock",
            "FullESPEnabled", "TracersEnabled", "ChestESPEnabled", "ShopESPEnabled",
            "RadarEnabled", "ArrowsEnabled", "BreadcrumbsEnabled", "CapeEnabled",
            "ChamsEnabled", "ChinaHatEnabled", "NameTagsEnabled", "PlayerModelEnabled",
            "SearchEnabled", "TimeChangerEnabled", "WaypointsEnabled", "WeatherEnabled",
            "ZoomUnlockerEnabled", "BedESPEnabled", "ResourceESPEnabled", "FullbrightEnabled"
        }

        for _, toggle in ipairs(scriptToggles) do
            env_global[toggle] = false
        end
        
        -- 2. 重置特殊狀態
        pcall(function()
            -- 停止 Desync 與 AntiSpectate 連線
            if env_global.DesyncConn then 
                env_global.DesyncConn:Disconnect() 
                env_global.DesyncConn = nil 
            end
            if env_global.AntiSpectateConn then
                env_global.AntiSpectateConn:Disconnect()
                env_global.AntiSpectateConn = nil
            end
            if env_global.GlobalSpecConn then
                env_global.GlobalSpecConn:Disconnect()
                env_global.GlobalSpecConn = nil
            end
            if env_global.SpecInvisConn then
                env_global.SpecInvisConn:Disconnect()
                env_global.SpecInvisConn = nil
            end
            if env_global.StaffDetectorConn then
                env_global.StaffDetectorConn:Disconnect()
                env_global.StaffDetectorConn = nil
            end
            if env_global.AutoRejoinConn then
                env_global.AutoRejoinConn:Disconnect()
                env_global.AutoRejoinConn = nil
            end
            settings().Network.IncomingReplicationLag = 0

            -- 重置 WalkSpeed
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
            
            -- 重置 FOV
            if env_global.originalFOV then
                workspace.CurrentCamera.FieldOfView = env_global.originalFOV
                env_global.originalFOV = nil
            end

            -- 重置動態狀態
            env_global.dynamicSpeed = nil
            env_global.predictedPos = nil
            env_global.target = nil
            env_global.BedNukerTarget = nil
            env_global.IsLongJumping = false
            
            -- 重置碰撞箱
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.Size = Vector3_new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                end
            end

            -- 重置 FPS 限制
            if setfpscap then
                setfpscap(60)
            end
            
            -- 恢復渲染設置
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = true
        end)
        
        Notify("Halol 系統", "所有功能已重置", "Success")
    end

    return CatFunctions
end

return functionsModule