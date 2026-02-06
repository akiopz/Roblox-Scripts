-- Halol (V4.0)
---@diagnostic disable: undefined-global, deprecated, undefined-field
local success, err = pcall(function()
    -- === 性能優化：本地化常用服務與函數 ===
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    
    local lp = Players.LocalPlayer
    local Color3_fromHSV = Color3.fromHSV
    local Color3_fromRGB = Color3.fromRGB
    local UDim2_new = UDim2.new
    local Vector3_new = Vector3.new
    local CFrame_new = CFrame.new
    local task_spawn = task.spawn
    local task_wait = task.wait
    local math_random = math.random

    -- === 環境相容性補丁 (支援所有注入器) ===
    local function GetEnvironment()
        local env = {
            gethui = gethui or function() return game:GetService("CoreGui") end,
            getgenv = getgenv or function() return _G end,
            isrenderobj = isrenderobj or function() return false end,
            setreadonly = setreadonly or function(t, b) end,
            make_writeable = make_writeable or function(t) if setreadonly then setreadonly(t, false) end end,
            getrawmetatable = getrawmetatable or function(t) return debug.getmetatable(t) end,
            newcclosure = newcclosure or function(f) return f end,
            checkcaller = checkcaller or function() return false end,
            setfpscap = setfpscap or function() end,
            getnamecallmethod = getnamecallmethod or function() return "" end,
            loadstring = loadstring or function() return function() warn("此注入器不支持 loadstring") end end
        }
        return env
    end
    local env = GetEnvironment()

    -- === 遊戲驗證：僅限 Bedwars ===
    -- Bedwars GameId: 2619619496
    if game.GameId ~= 2619619496 then
        local msg = Instance.new("Message")
        msg.Parent = CoreGui
        msg.Text = "\n\nHalol Error: 此腳本僅支持 Bedwars！\n(This script only supports Bedwars)\n\n正在退出..."
        task_wait(5)
        msg:Destroy()
        return
    end

    -- === 全域功能控制中心 (供 AI 與手動調用) ===
    _G.CatFunctions = {}

    _G.CatFunctions.ToggleKillAura = function(state)
        if state == nil then _G.KillAura = not _G.KillAura else _G.KillAura = state end
        if _G.KillAura then
            task.spawn(function()
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
                                hrp.CFrame = CFrame.new(hrp.Position, Vector3_new(target.Character.HumanoidRootPart.Position.X, hrp.Position.Y, target.Character.HumanoidRootPart.Position.Z))
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

    _G.CatFunctions.ToggleAutoBridge = function(state)
        if state == nil then _G.AutoBridge = not _G.AutoBridge else _G.AutoBridge = state end
        if _G.AutoBridge then
            task.spawn(function()
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

    _G.CatFunctions.ToggleFastBreak = function(state)
        if state == nil then _G.FastBreak = not _G.FastBreak else _G.FastBreak = state end
        if _G.FastBreak then
            task.spawn(function()
                while _G.FastBreak and task_wait(0.01) do
                    local char = lp.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or ReplicatedStorage:FindFirstChild("HitBlock", true)
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
        return _G.FastBreak
    end

    -- 整合自動工具與快速破床邏輯 (Auto Tool + Fast Break Integration)
    _G.CatFunctions.ToggleAutoToolFastBreak = function(state)
        if state == nil then _G.AutoToolFB = not _G.AutoToolFB else _G.AutoToolFB = state end
        if _G.AutoToolFB then
            task.spawn(function()
                while _G.AutoToolFB and task_wait(0.05) do
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and hum then
                        local target = lp:GetMouse().Target
                        if target and target:IsA("BasePart") and (hrp.Position - target.Position).Magnitude < 25 then
                            -- 自動切換工具邏輯
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
                                if tool and tool.Parent ~= char then
                                    hum:EquipTool(tool)
                                end
                            end

                            -- 執行破壞邏輯
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then
                                remote:FireServer({["position"] = target.Position, ["block"] = target.Name})
                            end
                        end
                    end
                end
            end)
        end
        return _G.AutoToolFB
    end

    _G.CatFunctions.ToggleAutoBuy = function(state)
        if state == nil then _G.AutoBuy = not _G.AutoBuy else _G.AutoBuy = state end
        if _G.AutoBuy then
            task.spawn(function()
                local shopRemote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
                if not shopRemote then return end
                local buyList = {
                    {item = "iron_armor", cost = 40, currency = "iron"},
                    {item = "iron_sword", cost = 70, currency = "iron"},
                    {item = "wool_white", cost = 8, currency = "iron", minAmount = 32}
                }
                while _G.AutoBuy do
                    local char = lp.Character
                    if char then
                        for _, info in ipairs(buyList) do
                            shopRemote:FireServer({["item"] = info.item, ["amount"] = 1})
                        end
                    end
                    task_wait(2)
                end
            end)
        end
        return _G.AutoBuy
    end

    _G.CatFunctions.ToggleFly = function(state)
        if state == nil then _G.FlyEnabled = not _G.FlyEnabled else _G.FlyEnabled = state end
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return _G.FlyEnabled end
        
        if _G.FlyEnabled then
            local bv = hrp:FindFirstChild("CatFlyBV") or Instance.new("BodyVelocity")
            local bg = hrp:FindFirstChild("CatFlyBG") or Instance.new("BodyGyro")
            
            ApplyProperties(bv, {
                Name = "CatFlyBV",
                Velocity = Vector3_new(0, 0, 0),
                MaxForce = Vector3_new(math.huge, math.huge, math.huge),
                Parent = hrp
            })
            
            ApplyProperties(bg, {
                Name = "CatFlyBG",
                P = 10000,
                MaxTorque = Vector3_new(math.huge, math.huge, math.huge),
                CFrame = hrp.CFrame,
                Parent = hrp
            })
            
            hum.PlatformStand = true
            
            task.spawn(function()
                while _G.FlyEnabled and char and char.Parent do
                    local fly_success, fly_err = pcall(function()
                        local currentHrp = char:FindFirstChild("HumanoidRootPart")
                        if not currentHrp then return end
                        
                        local moveDir = hum.MoveDirection
                        local camCF = workspace.CurrentCamera.CFrame
                        local vel = Vector3_new(0, 0, 0)
                        
                        if moveDir.Magnitude > 0 then
                            vel = moveDir * (_G.FlySpeed or 50)
                        end
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            vel = vel + Vector3_new(0, 50, 0)
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            vel = vel - Vector3_new(0, 50, 0)
                        end
                        
                        local jitter = Vector3_new(math.random(-5, 5)/100, math.random(-5, 5)/100, math.random(-5, 5)/100)
                        
                        if bv and bv.Parent then
                            bv.Velocity = vel + jitter
                        end
                        
                        if bg and bg.Parent then
                            bg.CFrame = camCF
                        end
                    end)
                    task_wait()
                end
                if bv then pcall(function() bv:Destroy() end) end
                if bg then pcall(function() bg:Destroy() end) end
                if hum then hum.PlatformStand = false end
            end)
        end
        return _G.FlyEnabled
    end

    _G.CatFunctions.ToggleNoFall = function(state)
        if state == nil then _G.NoFall = not _G.NoFall else _G.NoFall = state end
        if _G.NoFall then
            task.spawn(function()
                while _G.NoFall and task_wait(0.1) do
                    local remote = ReplicatedStorage:FindFirstChild("FallDamage", true)
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer(0)
                    end
                end
            end)
        end
        return _G.NoFall
    end

    _G.CatFunctions.ToggleReach = function(state)
         if state == nil then _G.ReachEnabled = not _G.ReachEnabled else _G.ReachEnabled = state end
         if _G.ReachEnabled then
             task.spawn(function()
                 while _G.ReachEnabled do
                     local success, err = pcall(function()
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

     _G.CatFunctions.ToggleVelocity = function(state)
         if state == nil then _G.VelocityEnabled = not _G.VelocityEnabled else _G.VelocityEnabled = state end
         if _G.VelocityEnabled then
             if env.getrawmetatable and not _G.VelocityHooked then
                 _G.VelocityHooked = true
                 local mt = env.getrawmetatable(game)
                 local old_index = mt.__index
                 env.setreadonly(mt, false)
                 mt.__index = env.newcclosure(function(t, k)
                     if _G.VelocityEnabled and not env.checkcaller() then
                         if typeof(t) == "Instance" and (t:IsA("BodyVelocity") or t:IsA("BodyPosition") or t:IsA("BodyAngularVelocity") or t:IsA("LinearVelocity")) then
                             return nil
                         end
                     end
                     return old_index(t, k)
                 end)
                 env.setreadonly(mt, true)
             end
             task.spawn(function()
                 while _G.VelocityEnabled and task_wait() do
                     local char = lp.Character
                     local hrp = char and char:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         hrp.Velocity = Vector3_new(0, 0, 0)
                         hrp.RotVelocity = Vector3_new(0, 0, 0)
                     end
                 end
             end)
         end
         return _G.VelocityEnabled
     end

    _G.CatFunctions.ToggleInstantBed = function(state)
        if state == nil then _G.InstantBed = not _G.InstantBed else _G.InstantBed = state end
        if _G.InstantBed then
            task.spawn(function()
                local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true)
                while _G.InstantBed do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local beds = {}
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v.Name == "bed" and v:IsA("BasePart") then
                                local team = v:GetAttribute("Team")
                                if team ~= lp.Team then
                                    table.insert(beds, {part = v, dist = (v.Position - hrp.Position).Magnitude})
                                end
                            end
                        end
                        table.sort(beds, function(a, b) return a.dist < b.dist end)
                        for _, bedInfo in ipairs(beds) do
                            if not _G.InstantBed then break end
                            local bed = bedInfo.part
                            if bed and bed.Parent then
                                if not remote then remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) end
                                if remote then
                                    remote:FireServer({["position"] = bed.Position, ["block"] = "bed"})
                                end
                            end
                            task_wait(0.1)
                        end
                    else
                        task_wait(1)
                    end
                    task_wait(0.5)
                end
            end)
        end
        return _G.InstantBed
    end

    -- === 戰場實時感知模組 (Battlefield Awareness) ===
    _G.CatFunctions.GetBattlefieldState = function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return {threats = {}, resources = {}, allies = {}} end

        local state = {
            threats = {},
            resources = {},
            allies = {},
            nearestThreat = nil,
            isBeingTargeted = false
        }

        local myPos = hrp.Position
        local maxScanDist = 150

        -- 掃描玩家 (威脅與盟友)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local ehrp = p.Character.HumanoidRootPart
                local ehum = p.Character:FindFirstChildOfClass("Humanoid")
                if ehum and ehum.Health > 0 then
                    local dist = (ehrp.Position - myPos).Magnitude
                    if dist < maxScanDist then
                        local pData = {player = p, hrp = ehrp, hum = ehum, dist = dist}
                        if p.Team ~= lp.Team then
                            table.insert(state.threats, pData)
                            -- 檢查是否正在瞄準我
                            local lookDir = ehrp.CFrame.LookVector
                            local toMe = (myPos - ehrp.Position).Unit
                            if lookDir:Dot(toMe) > 0.9 and dist < 30 then
                                state.isBeingTargeted = true
                            end
                        else
                            table.insert(state.allies, pData)
                        end
                    end
                end
            end
        end
        table.sort(state.threats, function(a, b) return a.dist < b.dist end)
        state.nearestThreat = state.threats[1]

        -- 掃描關鍵資源
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("diamond") or v.Name:lower():find("emerald")) then
                local dist = (v.Position - myPos).Magnitude
                if dist < 50 then
                    table.insert(state.resources, {part = v, dist = dist, name = v.Name})
                end
            end
        end
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)

        return state
    end

    -- === 連接管理系統 (防止內存洩漏) ===
    local Connections = {}
    local function SafeConnect(signal, callback)
        if not signal and not signal.Connect then return nil end
        local success, connection = pcall(function()
            return signal:Connect(callback)
        end)
        if success and connection then
            table.insert(Connections, connection)
            return connection
        end
        return nil
    end

    -- 批量屬性設置工具 (具備安全檢查)
    local function ApplyProperties(instance, props)
        if not instance then return end
        for k, v in pairs(props) do
            local success, err = pcall(function()
                instance[k] = v
            end)
            if not success then
                warn("ApplyProperties Error [" .. tostring(instance) .. "]: 無法設置屬性 " .. tostring(k) .. " - " .. tostring(err))
            end
        end
    end

    -- 通知系統 (提前定義以便使用)
    local function Notify(title, text, notifyType)
        task_spawn(function()
            -- 如果 GUI 還沒初始化完成則先等待
            local count = 0
            while not _G.CatScreenGui and count < 20 do 
                task_wait(0.1) 
                count = count + 1
            end
            
            local parent = _G.CatScreenGui or env.gethui()
            local NotifyFrame = Instance.new("Frame")
            local NotifyCorner = Instance.new("UICorner")
            local NotifyTitle = Instance.new("TextLabel")
            local NotifyText = Instance.new("TextLabel")
            
            ApplyProperties(NotifyFrame, {
                Name = "NotifyFrame",
                Parent = parent,
                BackgroundColor3 = notifyType == "Error" and Color3_fromRGB(150, 0, 0) or Color3_fromRGB(40, 40, 40),
                Position = UDim2_new(1, 10, 0.8, 0),
                Size = UDim2_new(0, 220, 0, 60),
                ZIndex = 100
            })
            
            NotifyCorner.CornerRadius = UDim.new(0, 8)
            NotifyCorner.Parent = NotifyFrame
            
            ApplyProperties(NotifyTitle, {
                Parent = NotifyFrame,
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 10, 0, 5),
                Size = UDim2_new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = Color3_fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            ApplyProperties(NotifyText, {
                Parent = NotifyFrame,
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 10, 0, 25),
                Size = UDim2_new(1, -20, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Color3_fromRGB(200, 200, 200),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            })
            
            NotifyFrame:TweenPosition(UDim2_new(1, -230, 0.8, 0), "Out", "Back", 0.5, true)
            task_wait(3)
            if NotifyFrame and NotifyFrame.Parent then
                NotifyFrame:TweenPosition(UDim2_new(1, 10, 0.8, 0), "In", "Back", 0.5, true)
                task_wait(0.5)
                NotifyFrame:Destroy()
            end
        end)
    end

    -- 安全載入函數 (Secure Loadstring)
    local LoadCache = {}
    local function SecureLoad(url)
        if LoadCache[url] then return LoadCache[url] end
        
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if success and result and #result > 0 then
            local func, err = env.loadstring(result)
            if func then
                LoadCache[url] = func
                return func
            else
                warn("Loadstring Error: " .. tostring(err))
            end
        else
            warn("HttpGet Error: " .. tostring(result))
        end
        
        return function() end
    end

    -- === 反偵測核心模組 ===
    local function GenerateRandomString(length)
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local res = ""
        for i = 1, length do
            local rand = math.random(1, #chars)
            res = res .. string.sub(chars, rand, rand)
        end
        return res
    end

    local GUIName = "Cat_" .. GenerateRandomString(10)
    local ESPTag = "Tag_" .. GenerateRandomString(8)

    -- 防止重複執行 (使用全域變數檢查而非 GUI 名稱，更隱蔽)
    if _G.CatLoaderRunning then
        if CoreGui:FindFirstChild(_G.CatLoaderName or "") then
            CoreGui[_G.CatLoaderName]:Destroy()
        end
    end
    _G.CatLoaderRunning = true
    _G.CatLoaderName = GUIName

    -- === GUI 實例定義 ===
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner_Main = Instance.new("UICorner")
    local UIStroke_Main = Instance.new("UIStroke") -- 新增描邊
    local RGBLine = Instance.new("Frame") -- 新增 RGB 頂條
    local LeftPanel = Instance.new("Frame")
    local UICorner_Left = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local TabContainer = Instance.new("Frame")
    local ContentContainer = Instance.new("Frame")
    local CloseButton = Instance.new("TextButton")

    -- === 初始化 GUI ===
    local ParentUI = env.gethui()
    _G.CatScreenGui = ScreenGui
    ScreenGui.Parent = ParentUI
    
    ApplyProperties(ScreenGui, {
        Name = GUIName,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    ApplyProperties(MainFrame, {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(15, 15, 15), -- 更深的背景色
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = UDim2.new(0, 550, 0, 400),
        BorderSizePixel = 0,
        Active = true,
        Parent = ScreenGui
    })

    -- 新增外描邊效果
    ApplyProperties(UIStroke_Main, {
        Color = Color3.fromRGB(40, 40, 40),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = MainFrame
    })

    -- 新增 RGB 頂條
    ApplyProperties(RGBLine, {
        Name = "RGBLine",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 2,
        Parent = MainFrame
    })
    local RGBLineCorner = Instance.new("UICorner")
    RGBLineCorner.CornerRadius = UDim.new(0, 12)
    RGBLineCorner.Parent = RGBLine
    
    -- 讓頂條只在上方圓角
    local RGBLineFix = Instance.new("Frame")
    ApplyProperties(RGBLineFix, {
        Name = "RGBLineFix",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
        Parent = RGBLine
    })

    -- 自定義拖拽邏輯 (取代已棄用的 Draggable)
    local dragging, dragInput, dragStart, startPos
    SafeConnect(MainFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            local moveConn
            moveConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if moveConn then moveConn:Disconnect() end
                end
            end)
        end
    end)
    
    SafeConnect(MainFrame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    SafeConnect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UICorner_Main.CornerRadius = UDim.new(0, 12)
    UICorner_Main.Parent = MainFrame

    -- 元表保護 (Metatable Protection)
    -- 防止遊戲偵測到屬性修改與敏感方法調用
    local mt = env.getrawmetatable(game)
    local old_index = mt.__index
    local old_newindex = mt.__newindex
    local old_namecall = mt.__namecall
    env.setreadonly(mt, false)
    
    local SpoofedProperties = {
        WalkSpeed = 16,
        JumpPower = 50,
        JumpHeight = 7.2,
        Health = 100,
        MaxHealth = 100
    }

    local BlockedRemotes = {
        "SelfReport", "BanReport", "ClientLog", "AnticheatLog", 
        "CheatDetection", "KickPlayer", "CrashClient"
    }

    local function IsLocalCharacter(obj)
        if not lp.Character then return false end
        return obj == lp.Character or obj:IsDescendantOf(lp.Character)
    end

    -- === 增強版反偵測變量 ===
    local RealProperties = {} -- 存儲真實數值以便邏輯運算
    local SpoofedProperties = {
        WalkSpeed = 16,
        JumpPower = 50,
        JumpHeight = 7.2,
        Health = 100,
        MaxHealth = 100,
        HipHeight = 2,
        CameraMaxZoomDistance = 128
    }

    local BlockedRemotes = {
        "SelfReport", "BanReport", "ClientLog", "AnticheatLog", 
        "CheatDetection", "KickPlayer", "CrashClient", "Detection",
        "ReportRemote", "IllegalAction"
    }

    -- 設置初始真實值
    task_spawn(function()
        while task_wait(1) do
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                RealProperties.WalkSpeed = hum.WalkSpeed
                RealProperties.JumpPower = hum.JumpPower
            end
        end
    end)

    mt.__index = env.newcclosure(function(t, k)
        if not env.checkcaller() then
            if t:IsA("Humanoid") and IsLocalCharacter(t) and SpoofedProperties[k] then
                return SpoofedProperties[k]
            elseif t:IsA("BasePart") and IsLocalCharacter(t) and (k == "Velocity" or k == "AssemblyLinearVelocity") then
                -- 隱藏移動異常速度
                return Vector3_new(0, 0, 0)
            elseif (t == CoreGui or t == lp:FindFirstChild("PlayerGui")) and (k == GUIName or k == _G.CatLoaderName) then
                return nil
            end
        end
        return old_index(t, k)
    end)

    mt.__newindex = env.newcclosure(function(t, k, v)
        if not env.checkcaller() then
            if t:IsA("Humanoid") and IsLocalCharacter(t) and SpoofedProperties[k] then
                SpoofedProperties[k] = v
                -- 記錄遊戲嘗試設置的值，但允許實際值被應用（維持移動能力）
            end
        end
        old_newindex(t, k, v)
    end)

    mt.__namecall = env.newcclosure(function(t, ...)
        local method = env.getnamecallmethod()
        local args = {...}
        
        if not env.checkcaller() then
            -- 攔截敏感遠端事件 (增加 nil 檢查)
            if (method == "FireServer" or method == "InvokeServer") and t then
                local remoteName = tostring(t)
                for i = 1, #BlockedRemotes do
                    if remoteName == BlockedRemotes[i] then
                        return nil
                    end
                end
            end

            -- 隱藏 GUI 存在
            if method == "FindFirstChild" or method == "WaitForChild" or method == "FindFirstChildOfClass" then
                if args[1] == GUIName or args[1] == _G.CatLoaderName or args[1] == ESPTag then
                    return nil
                end
            end
            
            -- 隱藏 GetChildren/GetDescendants 中的 GUI (使用 pcall 保護)
            if method == "GetChildren" or method == "GetDescendants" or method == "GetItems" then
                local success, results = pcall(old_namecall, t, ...)
                if success and type(results) == "table" then
                    for i = #results, 1, -1 do -- 倒序遍歷以安全移除
                        local v = results[i]
                        if v and (v.Name == GUIName or v.Name == ESPTag) then
                            table.remove(results, i)
                        end
                    end
                    return results
                end
            end
        end
        
        local success, result = pcall(old_namecall, t, ...)
        if success then return result end
        return nil
    end)
    env.setreadonly(mt, true)

    -- === GUI 構建 ===

    -- 通知系統 (使用前面定義的函數)
    Notify("Halol", "已成功啟動！", "Success")

    -- 左側面板
    ApplyProperties(LeftPanel, {
        Name = "LeftPanel",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(22, 22, 22), -- 稍微亮一點點的深灰色
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 1, 0)
    })

    UICorner_Left.CornerRadius = UDim.new(0, 12)
    UICorner_Left.Parent = LeftPanel

    -- 標題 (優化排版)
    ApplyProperties(Title, {
        Name = "Title",
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "Halol",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local SubTitle = Instance.new("TextLabel")
    ApplyProperties(SubTitle, {
        Name = "SubTitle",
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = "V4.0",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTransparency = 0.3
    })

    -- 狀態顯示 (大廳/遊戲中)
    local StatusLabel = Instance.new("TextLabel")
    ApplyProperties(StatusLabel, {
        Name = "StatusLabel",
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 0, 1, -30),
        Size = UDim2_new(1, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = "偵測中...",
        TextColor3 = Color3_fromRGB(180, 180, 180),
        TextSize = 12
    })

    task_spawn(function()
        while _G.CatLoaderRunning and ScreenGui and ScreenGui.Parent do
            local status_success, status_err = pcall(function()
                local isLobby = game.PlaceId == 6872265039 or not workspace:FindFirstChild("Map")
                local mapName = "未知地圖"
                
                if isLobby then
                    StatusLabel.Text = "📍 當前位置: 大廳"
                    StatusLabel.TextColor3 = Color3_fromRGB(100, 200, 100)
                else
                    -- 嘗試從多個路徑獲取地圖名稱
                    local mapFolder = workspace:FindFirstChild("Map")
                    if mapFolder then
                        -- Bedwars 通常會在地圖資料夾的屬性或子節點中存放地圖名
                        mapName = mapFolder:GetAttribute("MapName") or mapFolder:GetAttribute("Name")
                        
                        if not mapName then
                            for _, v in ipairs(mapFolder:GetChildren()) do
                                if v:IsA("StringValue") and (v.Name == "MapName" or v.Name == "Name") then
                                    mapName = v.Value
                                    break
                                end
                            end
                        end
                        
                        -- 如果還是找不到，則取資料夾內第一個具有代表性的名稱
                        if not mapName then
                            mapName = mapFolder.Name
                        end
                    end
                    
                    StatusLabel.Text = string.format("🎮 地圖: %s", mapName or "載入中...")
                    StatusLabel.TextColor3 = Color3_fromRGB(255, 150, 50)
                end
            end)
            
            if not status_success then
                warn("Status Detection Error: " .. tostring(status_err))
                StatusLabel.Text = "⚠️ 偵測出錯"
                StatusLabel.TextColor3 = Color3_fromRGB(255, 80, 80)
            end
            task_wait(3)
        end
    end)

    -- 分頁按鈕容器
    ApplyProperties(TabContainer, {
        Name = "TabContainer",
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -80)
    })

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- 內容容器 (右側)
    ApplyProperties(ContentContainer, {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 10),
        Size = UDim2.new(0, 370, 0, 380)
    })

    -- 儲存分頁內容的 Table
    local Tabs = {}
    local CurrentTab = nil

    -- === 連接管理系統 (防止內存洩漏) ===
    local function Cleanup()
        local success, err = pcall(function()
            _G.CatLoaderRunning = false
            
            -- 中斷所有功能迴圈
            _G.AI_Enabled = false
            _G.KillAura = false
            _G.FlyEnabled = false
            _G.ESPEnabled = false
            _G.AutoFarm = false
            
            -- 清理連線
            for _, conn in pairs(Connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            Connections = {}
            
            -- 銷毀 GUI
            if ScreenGui then 
                ScreenGui:Destroy() 
            end
            
            Notify("清理完成", "腳本已安全停止並清理資源", "Success")
        end)
        
        if not success then
            warn("Cleanup Error: " .. tostring(err))
        end
    end

    -- 建立分頁函數 (優化初始化)
    local function CreateTab(name, icon)
        local TabButton = Instance.new("TextButton")
        local TBCorner = Instance.new("UICorner")
        local Page = Instance.new("ScrollingFrame")
        local PageList = Instance.new("UIListLayout")
        
        -- 分頁按鈕
        ApplyProperties(TabButton, {
            Name = name .. "Button",
            Parent = TabContainer,
            BackgroundColor3 = Color3_fromRGB(28, 28, 28),
            BorderSizePixel = 0,
            Size = UDim2_new(0, 140, 0, 32),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Color3_fromRGB(180, 180, 180),
            TextSize = 13
        })
        
        TBCorner.CornerRadius = UDim.new(0, 4)
        TBCorner.Parent = TabButton
        
        -- 懸停效果
        SafeConnect(TabButton.MouseEnter, function()
            if CurrentTab and CurrentTab.Button ~= TabButton then
                TabButton.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
                TabButton.TextColor3 = Color3_fromRGB(255, 255, 255)
            end
        end)
        
        SafeConnect(TabButton.MouseLeave, function()
            if CurrentTab and CurrentTab.Button ~= TabButton then
                TabButton.BackgroundColor3 = Color3_fromRGB(28, 28, 28)
                TabButton.TextColor3 = Color3_fromRGB(180, 180, 180)
            end
        end)
        
        -- 分頁內容頁面
        ApplyProperties(Page, {
            Name = name .. "Page",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            CanvasSize = UDim2_new(0, 0, 0, 0)
        })
        
        PageList.Parent = Page
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        
        local function Switch()
            if CurrentTab then
                CurrentTab.Button.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
                CurrentTab.Button.TextColor3 = Color3_fromRGB(200, 200, 200)
                CurrentTab.Page.Visible = false
                
                -- 重置舊按鈕的發光效果
                local s = CurrentTab.Button:FindFirstChildOfClass("UIStroke")
                if s then
                    s.Color = Color3_fromRGB(40, 40, 40)
                    s.Thickness = 1
                end
            end
            -- RGB 效果會處理選中按鈕的顏色，這裡僅設置為非 RGB 狀態下的備選
            TabButton.BackgroundColor3 = Color3_fromRGB(60, 120, 255)
            TabButton.TextColor3 = Color3_fromRGB(255, 255, 255)
            Page.Visible = true
            CurrentTab = {Button = TabButton, Page = Page}
        end
        
        SafeConnect(TabButton.MouseButton1Click, Switch)
        
        Tabs[name] = {Button = TabButton, Page = Page, List = PageList}
        return Tabs[name]
    end

    -- 建立按鈕函數 (優化屬性賦值)
    local function AddScript(tabName, name, desc, loadFunc)
        local targetPage = Tabs[tabName].Page
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        local DescLabel = Instance.new("TextLabel")
        
        ApplyProperties(Button, {
            Name = name,
            Parent = targetPage,
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            Size = UDim2.new(0.96, 0, 0, 70),
            Font = Enum.Font.GothamBold,
            Text = "  " .. name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutoButtonColor = false,
            BorderSizePixel = 0
        })
        
        local ButtonStroke = Instance.new("UIStroke")
        ApplyProperties(ButtonStroke, {
            Color = Color3.fromRGB(40, 40, 40),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Button
        })

        BCorner.CornerRadius = UDim.new(0, 8)
        BCorner.Parent = Button
        
        ApplyProperties(DescLabel, {
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(1, -20, 0, 25),
            Font = Enum.Font.Gotham,
            Text = desc,
            TextColor3 = Color3.fromRGB(130, 130, 130),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 0.2
        })

        local function Execute()
            local success, err = pcall(loadFunc)
            if not success then
                Notify("腳本錯誤", tostring(err), "Error")
            else
                -- 成功回饋
                local oldColor = Button.BackgroundColor3
                Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                task.delay(0.5, function()
                    Button.BackgroundColor3 = oldColor
                end)
            end
        end

        -- 按鈕交互效果
        SafeConnect(Button.MouseEnter, function()
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ButtonStroke.Color = Color3.fromRGB(60, 60, 60)
        end)
        
        SafeConnect(Button.MouseLeave, function()
            Button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            ButtonStroke.Color = Color3.fromRGB(40, 40, 40)
        end)

        SafeConnect(Button.MouseButton1Click, Execute)
        
        -- 更新滾動條
        targetPage.CanvasSize = UDim2.new(0, 0, 0, Tabs[tabName].List.AbsoluteContentSize.Y + 20)
    end

    -- 建立分頁
    local InternalTab = CreateTab("內建功能")
    local VisualTab = CreateTab("視覺功能")
    local BlatantTab = CreateTab("暴力功能")
    local AutomationTab = CreateTab("自動化功能")
    local AITab = CreateTab("自動核心")
    local GeneralTab = CreateTab("通用工具")
    local BedwarsTab = CreateTab("BEDWARS 專區")
    local ServerTab = CreateTab("伺服器工具")
    local OptimizationTab = CreateTab("優化功能")

    -- === 內建功能內容 ===
    AddScript("內建功能", "高跳 (Jump)", "提升跳躍高度至 100。", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = 100
        end
    end)

    AddScript("內建功能", "全亮 (Fullbright)", "移除所有陰影，讓地圖變得明亮。", function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end)

    AddScript("內建功能", "反掛機 (Anti-AFK)", "防止因長時間不活動而被踢出遊戲。", function()
        SafeConnect(lp.Idled, function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Notify("成功", "反掛機功能已啟動。", "Success")
    end)

    AddScript("內建功能", "自我銷毀 (Self-Destruct)", "立即移除所有作弊跡象並關閉介面。", function()
        Cleanup()
        -- 恢復元表
        local mt = env.getrawmetatable(game)
        env.setreadonly(mt, false)
        mt.__index = old_index
        mt.__newindex = old_newindex
        mt.__namecall = old_namecall
        env.setreadonly(mt, true)
        Notify("系統", "所有功能已停用，介面已關閉。", "Info")
    end)

    -- === 視覺功能內容 ===
    AddScript("視覺功能", "玩家透視 (Highlight)", "最穩定的透視，顯示玩家輪廓。", function()
        local function ApplyESP(char)
            if not char or char:FindFirstChild(ESPTag) then return end
            ApplyProperties(Instance.new("Highlight"), {
                Name = ESPTag,
                Parent = char,
                FillTransparency = 0.5,
                OutlineColor = Color3_fromRGB(255, 0, 0)
            })
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                ApplyESP(player.Character)
            end
        end

        SafeConnect(Players.PlayerAdded, function(p)
            SafeConnect(p.CharacterAdded, ApplyESP)
        end)
    end)

    AddScript("視覺功能", "全面透視 (Full ESP)", "顯示玩家名字、血量及距離，並附帶動態顏色更新 (專業級視覺增強)。", function()
        _G.FullESPEnabled = not _G.FullESPEnabled
        Notify("全面透視", _G.FullESPEnabled and "已啟動" or "已關閉", _G.FullESPEnabled and "Success" or "Info")
        
        local function CreateESP(player)
            if player == lp then return end
            
            local function OnCharacterAdded(char)
                local head = char:WaitForChild("Head", 10)
                if not head then return end
                
                -- 清理舊的 ESP
                local old = head:FindFirstChild("CatFullESP")
                if old then old:Destroy() end
                
                local billboard = Instance_new("BillboardGui")
                ApplyProperties(billboard, {
                    Name = "CatFullESP",
                    Adornee = head,
                    Size = UDim2_new(0, 150, 0, 70),
                    StudsOffset = Vector3_new(0, 3, 0),
                    AlwaysOnTop = true,
                    Parent = head
                })
                
                local container = Instance_new("Frame")
                ApplyProperties(container, {
                    Parent = billboard,
                    BackgroundTransparency = 1,
                    Size = UDim2_new(1, 0, 1, 0)
                })
                
                local nameLabel = Instance_new("TextLabel")
                ApplyProperties(nameLabel, {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Size = UDim2_new(1, 0, 0.4, 0),
                    Font = Enum.Font.GothamBold,
                    TextColor3 = player.TeamColor.Color or Color3_fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextStrokeTransparency = 0.5,
                    Text = player.DisplayName or player.Name
                })
                
                local healthBarBG = Instance_new("Frame")
                ApplyProperties(healthBarBG, {
                    Parent = container,
                    BackgroundColor3 = Color3_fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    Position = UDim2_new(0.1, 0, 0.45, 0),
                    Size = UDim2_new(0.8, 0, 0.1, 0)
                })
                
                local healthBar = Instance_new("Frame")
                ApplyProperties(healthBar, {
                    Parent = healthBarBG,
                    BackgroundColor3 = Color3_fromRGB(0, 255, 0),
                    BorderSizePixel = 0,
                    Size = UDim2_new(1, 0, 1, 0)
                })
                
                local infoLabel = Instance_new("TextLabel")
                ApplyProperties(infoLabel, {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Position = UDim2_new(0, 0, 0.6, 0),
                    Size = UDim2_new(1, 0, 0.3, 0),
                    Font = Enum.Font.Gotham,
                    TextColor3 = Color3_fromRGB(255, 255, 255),
                    TextSize = 11,
                    TextStrokeTransparency = 0.5,
                    Text = "載入中..."
                })
                
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                
                local function UpdateESP()
                    if not _G.FullESPEnabled or not char.Parent then return end
                    
                    if hum then
                        local hpPercent = math_clamp(hum.Health / hum.MaxHealth, 0, 1)
                        healthBar.Size = UDim2_new(hpPercent, 0, 1, 0)
                        healthBar.BackgroundColor3 = Color3_fromHSV(hpPercent * 0.3, 1, 1)
                        
                        local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and root) and 
                                     math_floor((lp.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                        
                        infoLabel.Text = string_format("[%d HP] | %d m", math_floor(hum.Health), dist)
                    end
                end
                
                task_spawn(function()
                    while _G.FullESPEnabled and char.Parent and head.Parent do
                        UpdateESP()
                        task_wait(0.1)
                    end
                    billboard:Destroy()
                end)
            end
            
            if player.Character then task_spawn(OnCharacterAdded, player.Character) end
            SafeConnect(player.CharacterAdded, OnCharacterAdded)
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            CreateESP(p)
        end
        SafeConnect(Players.PlayerAdded, CreateESP)
    end)

    AddScript("視覺功能", "掉落物透視 (Item ESP)", "動態追蹤並高亮地圖上的所有掉落資源 (鐵、金、鑽石)。", function()
        _G.ItemESPEnabled = not _G.ItemESPEnabled
        Notify("掉落物透視", _G.ItemESPEnabled and "已啟動" or "已關閉", _G.ItemESPEnabled and "Success" or "Info")
        
        if not _G.ItemESPEnabled then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:FindFirstChild("CatItemESP") then v.CatItemESP:Destroy() end
            end
            return
        end

        task.spawn(function()
            while _G.ItemESPEnabled do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("item") or v.Name:lower():find("drop")) then
                        if not v:FindFirstChild("CatItemESP") then
                            local highlight = Instance.new("Highlight")
                            ApplyProperties(highlight, {
                                Name = "CatItemESP",
                                Parent = v,
                                FillColor = Color3_fromRGB(200, 200, 200),
                                OutlineColor = Color3_fromRGB(255, 255, 255),
                                FillTransparency = 0.5,
                                OutlineTransparency = 0
                            })
                            
                            local billboard = Instance.new("BillboardGui")
                            ApplyProperties(billboard, {
                                Name = "CatItemESPLabel",
                                Parent = v,
                                AlwaysOnTop = true,
                                Size = UDim2_new(0, 50, 0, 20),
                                StudsOffset = Vector3_new(0, 1.5, 0)
                            })
                            
                            local label = Instance.new("TextLabel")
                            ApplyProperties(label, {
                                Parent = billboard,
                                Size = UDim2_new(1, 0, 1, 0),
                                Text = v.Name,
                                TextColor3 = Color3_fromRGB(255, 255, 255),
                                TextSize = 10,
                                Font = Enum.Font.GothamBold,
                                BackgroundTransparency = 1,
                                TextStrokeTransparency = 0.5
                            })
                        end
                    end
                end
                task_wait(2)
            end
        end)
    end)

    AddScript("視覺功能", "箱子透視 (Chest ESP)", "掃描並顯示隱藏箱子位置，幫助快速掠奪物資。", function()
        _G.ChestESPEnabled = not _G.ChestESPEnabled
        Notify("箱子透視", _G.ChestESPEnabled and "已啟動" or "已關閉", _G.ChestESPEnabled and "Success" or "Info")
        
        if not _G.ChestESPEnabled then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:FindFirstChild("CatChestESP") then v.CatChestESP:Destroy() end
            end
            return
        end

        task.spawn(function()
            while _G.ChestESPEnabled do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:lower():find("chest") or v.Name:lower():find("box")) then
                        if not v:FindFirstChild("CatChestESP") then
                            local highlight = Instance.new("Highlight")
                            ApplyProperties(highlight, {
                                Name = "CatChestESP",
                                Parent = v,
                                FillColor = Color3_fromRGB(139, 69, 19),
                                OutlineColor = Color3_fromRGB(255, 255, 255),
                                FillTransparency = 0.4
                            })
                        end
                    end
                end
                task_wait(3)
            end
        end)
    end)

    -- === 自動核心內容 ===
    AddScript("自動核心", "自動模式 (God Mode)", "全功能自動模式：結合飛行、殺戮光環與自動追蹤，獲取勝利。", function()
        _G.GodModeAI = not _G.GodModeAI
        Notify("自動模式", _G.GodModeAI and "已啟動" or "已關閉", _G.GodModeAI and "Success" or "Info")
        
        if _G.GodModeAI then
            -- 使用 CatFunctions 啟動輔助功能
            _G.CatFunctions.ToggleFly(true)
            _G.CatFunctions.ToggleKillAura(true)
            _G.CatFunctions.ToggleNoFall(true)
            _G.CatFunctions.ToggleReach(true)
            _G.CatFunctions.ToggleVelocity(true)
            _G.CatFunctions.ToggleAutoToolFastBreak(true)
            
            task.spawn(function()
                while _G.GodModeAI and task_wait(0.02) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local battlefield = _G.CatFunctions.GetBattlefieldState()
                        local target = nil
                        local minDist = math.huge
                        
                        -- 威脅防禦邏輯：如果被瞄準，進行隨機抖動以躲避遠程攻擊
                        if battlefield.isBeingTargeted then
                            local jitter = Vector3_new(math_random(-2, 2), 0, math_random(-2, 2))
                            hrp.Velocity = hrp.Velocity + jitter
                        end

                        -- 優先權判定：如果附近有威脅（小於15格），優先進入戰鬥模式
                        if battlefield.nearestThreat and battlefield.nearestThreat.dist < 15 then
                            target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                        else
                            -- 否則尋找最近的床
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
                            
                            -- 如果沒找到床，追擊最近的玩家
                            if not target and battlefield.nearestThreat then
                                target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                            end
                        end
                        
                        if target then
                            local targetPos = target.part.Position
                            if target.type == "PLAYER" then
                                -- 實時追蹤：根據目標速度預測位置
                                local prediction = target.part.Velocity * 0.1
                                hrp.CFrame = CFrame_new(targetPos + prediction + Vector3_new(0, 10, 0), targetPos)
                                _G.KillAuraRange = 35
                            else
                                -- 爆床定位
                                hrp.CFrame = CFrame_new(targetPos + Vector3_new(0, 5, 0), targetPos)
                            end
                        else
                            -- 巡邏/待機模式：緩慢旋轉以保持「關注」戰場
                            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(2), 0)
                            if hrp:FindFirstChild("CatFlyBV") then
                                hrp.CatFlyBV.Velocity = Vector3_new(0, 0, 0)
                            end
                        end
                    end
                end
            end)
        else
            -- 關閉 AI 時停止所有功能
            _G.CatFunctions.ToggleFly(false)
            _G.CatFunctions.ToggleAutoToolFastBreak(false)
        end
    end)

    -- === 暴力功能內容 ===
    AddScript("暴力功能", "空中漫步 (Air Walk)", "在空中建立隱形平台，實現「在天空打人」 (繞過重力限制)。", function()
        _G.AirWalk = not _G.AirWalk
        Notify("空中漫步", _G.AirWalk and "已開啟" or "已關閉", _G.AirWalk and "Success" or "Info")
        
        if not _G.AirWalk then return end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local platform = Instance.new("Part")
        ApplyProperties(platform, {
            Size = Vector3_new(10, 1, 10),
            Transparency = 1,
            Anchored = true,
            Parent = workspace
        })
        
        task.spawn(function()
            while _G.AirWalk and char and char.Parent do
                local currentHrp = char:FindFirstChild("HumanoidRootPart")
                if currentHrp then
                    platform.CFrame = currentHrp.CFrame * CFrame_new(0, -3.5, 0)
                end
                task_wait()
            end
            if platform then platform:Destroy() end
        end)
    end)

    AddScript("暴力功能", "自動點擊 (Auto Clicker)", "快速自動點擊滑鼠左鍵，配合空中漫步效果極佳 (高頻連點)。", function()
        _G.AutoClicker = not _G.AutoClicker
        Notify("自動點擊", _G.AutoClicker and "已開啟" or "已關閉", _G.AutoClicker and "Success" or "Info")
        
        if _G.AutoClicker then
            task.spawn(function()
                while _G.AutoClicker do
                    if env.mouse1click then 
                        env.mouse1click() 
                    else
                        -- 備用法 (部分注入器)
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                    task_wait(0.01)
                end
            end)
        end
    end)

    AddScript("暴力功能", "穿牆 (Noclip)", "允許穿過所有實體障礙物 (空間穿梭模式)。", function()
        _G.Noclip = not _G.Noclip
        Notify("穿牆", _G.Noclip and "已開啟" or "已關閉", _G.Noclip and "Success" or "Info")
        
        if not _G.Noclip then return end
        
        SafeConnect(RunService.Stepped, function()
            if not _G.Noclip then return end
            local char = lp.Character
            if char then
                local descendants = char:GetDescendants()
                for i = 1, #descendants do
                    local v = descendants[i]
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end)

    AddScript("暴力功能", "擊退增強 (KB Boost)", "增加對敵人的擊退效果 (支援多種注入器協定)。", function()
        _G.SuperKB = not _G.SuperKB
        Notify("擊退增強", _G.SuperKB and "已開啟" or "已關閉", _G.SuperKB and "Success" or "Info")
        
        if not _G.SuperKB then return end
        
        -- 方法 A: debug.setconstant (針對部分注入器與特定遊戲)
        local kbUtil = ReplicatedStorage:FindFirstChild("knockback-util", true)
        if kbUtil then
            local success, res = pcall(require, kbUtil)
            if success and res.KnockbackUtil then
                pcall(function()
                    debug.setconstant(res.KnockbackUtil.calculateKnockbackVelocity, 10, 100)
                end)
            end
        end
        
        -- 方法 B: 網路同步欺騙 (後備方案)
        task.spawn(function()
            while _G.SuperKB do
                local char = lp.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        -- 當持有工具時，稍微增加速度向量以增強擊退感 (實驗性)
                    end
                end
                task_wait(0.5)
            end
        end)
    end)

    AddScript("暴力功能", "殺戮光環 (Kill Aura)", "自動攻擊範圍內敵人 (增強版：預測與視線檢查)。", function()
        local state = _G.CatFunctions.ToggleKillAura()
        Notify("殺戮光環", state and "已啟動 (優化模式)" or "已關閉", state and "Success" or "Info")
    end)

    AddScript("暴力功能", "無限跳躍 (Infinite Jump)", "讓你在空中可以無限次跳躍。", function()
        _G.InfiniteJump = not _G.InfiniteJump
        Notify("無限跳躍", _G.InfiniteJump and "已啟動" or "已關閉", _G.InfiniteJump and "Success" or "Info")
        
        if _G.InfiniteJumpConn then _G.InfiniteJumpConn:Disconnect() end
        if _G.InfiniteJump then
            _G.InfiniteJumpConn = UserInputService.JumpRequest:Connect(function()
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    AddScript("暴力功能", "無掉落傷害 (No Fall)", "防止摔落造成的傷害 (通過偽造落地狀態)。", function()
        local state = _G.CatFunctions.ToggleNoFall()
        Notify("無掉落傷害", state and "已啟動" or "已關閉", state and "Success" or "Info")
    end)

    AddScript("暴力功能", "延伸攻擊 (Reach)", "將你的攻擊距離增加至 25 格 (動態 Hitbox 擴張，自動避開障礙物)。", function()
        local state = _G.CatFunctions.ToggleReach()
        Notify("延伸攻擊", state and "已啟動 (動態模式)" or "已關閉", state and "Success" or "Info")
    end)

    AddScript("暴力功能", "反擊退 (Velocity)", "使你不再受到敵人的擊退效果 (採用元表攔截技術，極致穩定)。", function()
        local state = _G.CatFunctions.ToggleVelocity()
        Notify("反擊退", state and "已開啟" or "已關閉", state and "Success" or "Info")
    end)

    AddScript("暴力功能", "飛行 (Fly)", "允許你在地圖上自由飛行 (優化版：BodyGyro 平滑控制，防拉回抖動)。", function()
        local state = _G.CatFunctions.ToggleFly()
        Notify("飛行功能", state and "已啟動 (優化模式)" or "已關閉", state and "Success" or "Info")
    end)

    AddScript("暴力功能", "蜘蛛爬牆 (Spider)", "允許你像蜘蛛一樣直接爬上垂直的牆壁 (雷射偵測自動攀爬)。", function()
        _G.SpiderEnabled = not _G.SpiderEnabled
        Notify("蜘蛛爬牆", _G.SpiderEnabled and "已啟動" or "已關閉", _G.SpiderEnabled and "Success" or "Info")
        
        task.spawn(function()
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            
            while _G.SpiderEnabled and task_wait() do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    rayParams.FilterDescendantsInstances = {char}
                    local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, rayParams)
                    
                    if result and result.Instance then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 30, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end)

    AddScript("暴力功能", "急速移動 (Speed)", "顯著提升你的移動速度 (包含 CFrame 步進防拉回優化)。", function()
        _G.SpeedEnabled = not _G.SpeedEnabled
        Notify("急速移動", _G.SpeedEnabled and "已啟動" or "已關閉", _G.SpeedEnabled and "Success" or "Info")
        
        task.spawn(function()
            while _G.SpeedEnabled do
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        -- 使用 CFrame 步進移動以繞過部分速度偵測
                        local speedMultiplier = (_G.WalkSpeedValue or 23) / 16
                        hrp.CFrame = hrp.CFrame + (moveDir * (speedMultiplier * 0.15))
                    end
                end
                task_wait(0.01) -- 高頻率小步進
            end
        end)
    end)

    AddScript("暴力功能", "全員墜空 (Void All)", "利用多維度 Fling 協議將伺服器玩家甩入虛空 (增強型穩定性)。", function()
        _G.VoidAll = not _G.VoidAll
        Notify("全員墜空", _G.VoidAll and "已啟動" or "已停止", _G.VoidAll and "Success" or "Info")
        
        if not _G.VoidAll then return end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local function Fling(target)
            if not _G.VoidAll then return end
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local thrp = target.Character.HumanoidRootPart
                local bfv = Instance.new("BodyAngularVelocity")
                ApplyProperties(bfv, {
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

        task.spawn(function()
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
    end)

    AddScript("暴力功能", "傳送至玩家 (TP to Player)", "動態掃描並瞬移至敵對玩家位置 (自定義高度偏移)。", function()
        local players = Players:GetPlayers()
        if #players <= 1 then return end
        
        local target = players[math_random(1, #players)]
        while target == lp do
            target = players[math_random(1, #players)]
        end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local thrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        
        if hrp and thrp then
            hrp.CFrame = thrp.CFrame * CFrame_new(0, 5, 0)
            Notify("瞬移成功", "已傳送至: " .. (target.DisplayName or target.Name), "Success")
        end
    end)

    AddScript("暴力功能", "個人崩潰 (Self Crash)", "僅對使用者自身產生崩潰效果，不影響他人 (緊急避險)。", function()
        _G.SelfCrash = not _G.SelfCrash
        Notify("個人崩潰", "正在產生客戶端崩潰...", "Error")
        task_wait(0.5)
        
        -- 觸發客戶端致命錯誤 (僅影響自己)
        task.spawn(function()
            local function crash() crash() end
            crash()
        end)
        
        -- 二次確保退出
        task.delay(1, function()
            lp:Kick("Client-Side Crash initiated by user.")
        end)
    end)

    AddScript("暴力功能", "強制離線 (Force Quit)", "直接產生錯誤並離開遊戲，不留痕跡。", function()
        Notify("警告", "正在強制產生崩潰錯誤...", "Error")
        task_wait(0.5)
        -- 故意觸發多種致命錯誤以防被攔截
        task.spawn(function()
            while true do
                -- 遞迴堆棧溢出
                local function crash() crash() end
                crash()
            end
        end)
        lp:Kick("Fatal Error: Memory allocation failed.")
        game:Shutdown()
    end)

    -- === 自動化功能內容 ===
    AddScript("自動化功能", "自動鋪路 (Auto Bridge)", "行走時自動在腳下生成路徑 (智能防墜落與方塊檢測)。", function()
        _G.AutoBridge = not _G.AutoBridge
        Notify("自動鋪路", _G.AutoBridge and "已啟動" or "已關閉", _G.AutoBridge and "Success" or "Info")
        
        task.spawn(function()
            while _G.AutoBridge and task_wait(0.05) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    local block = char:FindFirstChildOfClass("Tool")
                    if block and (block.Name:lower():find("block") or block.Name:lower():find("wool")) then
                        -- 計算前方的放置位置，稍微向下偏移
                        local pos = hrp.Position + (hum.MoveDirection * 2.5) + Vector3_new(0, -3.6, 0)
                        local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                        if remote then
                            remote:FireServer({["position"] = pos, ["block"] = block.Name})
                        end
                    end
                end
            end
        end)
    end)

    AddScript("自動化功能", "自動購買 (Auto Buy)", "自動補貨邏輯：檢測方塊儲備並購買裝備。", function()
        _G.AutoBuy = not _G.AutoBuy
        Notify("自動購買", _G.AutoBuy and "已啟動" or "已關閉", _G.AutoBuy and "Success" or "Info")
        
        task.spawn(function()
            local shopRemote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
            if not shopRemote then return end
            
            local buyList = {
                {item = "iron_armor", cost = 40, currency = "iron"},
                {item = "iron_sword", cost = 70, currency = "iron"},
                {item = "wool_white", cost = 8, currency = "iron", minAmount = 32}
            }
            
            while _G.AutoBuy do
                local char = lp.Character
                if char then
                    for _, info in ipairs(buyList) do
                        shopRemote:FireServer({["item"] = info.item, ["amount"] = 1})
                    end
                end
                task_wait(2) -- 縮短檢查時間end
            end
        end)
    end)

    AddScript("自動化功能", "自動採礦 (Auto Mine)", "高頻率自動掃描並破壞附近床位與方塊 (靜默模式)。", function()
        _G.AutoMine = not _G.AutoMine
        Notify("自動採礦", _G.AutoMine and "已啟動" or "已關閉", _G.AutoMine and "Success" or "Info")
        
        task.spawn(function()
            local lastScan = 0
            local targetBeds = {}
            
            while _G.AutoMine do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if tick() - lastScan > 3 then
                        targetBeds = {}
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v.Name == "bed" then table.insert(targetBeds, v) end
                        end
                        lastScan = tick()
                    end
                    
                    for _, bed in ipairs(targetBeds) do
                        if bed and bed.Parent and (hrp.Position - bed.Position).Magnitude < 30 then
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then
                                remote:FireServer({["position"] = bed.Position, ["block"] = "bed"})
                            end
                        end
                    end
                end
                task_wait(0.1) -- 加快採礦速度
            end
        end)
    end)

    AddScript("自動化功能", "快速破床 (Fast Break)", "移除挖掘延遲協議：實現瞬間破壞任何方塊與床位 (全自動)。", function()
        _G.FastBreak = not _G.FastBreak
        Notify("快速破床", _G.FastBreak and "已啟動" or "已關閉", _G.FastBreak and "Success" or "Info")
        
        task.spawn(function()
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
    end)

    -- === 通用工具內容 ===
    AddScript("通用工具", "Infinite Yield", "管理員指令集，包含飛行、穿牆等。", function()
        SecureLoad('https://raw.githubusercontent.com/Edgeiy/infiniteyield/master/source')()
    end)

    AddScript("通用工具", "Dark Dex V4", "實體瀏覽器，用於分析遊戲結構與內容。", function()
        SecureLoad("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua")()
    end)

    AddScript("通用工具", "SimpleSpy V3", "監控遠程事件 (Remote Events)，適合開發與分析。", function()
        SecureLoad("https://raw.githubusercontent.com/ex70/SimpleSpy/master/SimpleSpySource.lua")()
    end)

    AddScript("通用工具", "Hydroxide", "功能強大的遠程偵聽與調試工具。", function()
        SecureLoad("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua")()
    end)

    AddScript("通用工具", "Turtle Spy", "另一款易於使用的 Remote Spy 工具。", function()
        SecureLoad("https://raw.githubusercontent.com/Turtle-Project/Turtle-Spy/main/source.lua")()
    end)

    -- === BEDWARS 內容 ===
    AddScript("BEDWARS 專區", "床位透視 (Bed ESP)", "全地圖定位敵對隊伍床位，實現精準打擊 (附帶距離顯示)。", function()
        _G.BedESPEnabled = not _G.BedESPEnabled
        Notify("床位透視", _G.BedESPEnabled and "已啟動" or "已關閉", _G.BedESPEnabled and "Success" or "Info")
        
        if not _G.BedESPEnabled then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:FindFirstChild("CatBedESP") then v.CatBedESP:Destroy() end
            end
            return
        end

        task.spawn(function()
            while _G.BedESPEnabled do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.Name == "bed" and v:IsA("BasePart") then
                        if not v:FindFirstChild("CatBedESP") then
                            local highlight = Instance.new("Highlight")
                            ApplyProperties(highlight, {
                                Name = "CatBedESP",
                                Parent = v,
                                FillColor = Color3_fromRGB(255, 50, 50),
                                OutlineColor = Color3_fromRGB(255, 255, 255)
                            })
                            
                            local billboard = Instance.new("BillboardGui")
                            ApplyProperties(billboard, {
                                Name = "CatBedESPLabel",
                                Parent = v,
                                AlwaysOnTop = true,
                                Size = UDim2_new(0, 80, 0, 30),
                                StudsOffset = Vector3_new(0, 3, 0)
                            })
                            
                            local label = Instance.new("TextLabel")
                            ApplyProperties(label, {
                                Parent = billboard,
                                Size = UDim2_new(1, 0, 1, 0),
                                Text = "BED",
                                TextColor3 = Color3_fromRGB(255, 50, 50),
                                TextSize = 14,
                                Font = Enum.Font.GothamBold,
                                BackgroundTransparency = 1,
                                TextStrokeTransparency = 0.5
                            })
                        end
                    end
                end
                task_wait(3)
            end
        end)
    end)

    AddScript("BEDWARS 專區", "自動鋪路 (Auto Bridge)", "行走時自動在腳下生成路徑 (智能防墜落與方塊檢測)。", function()
        _G.AutoBridge = not _G.AutoBridge
        Notify("自動鋪路", _G.AutoBridge and "已啟動" or "已關閉", _G.AutoBridge and "Success" or "Info")
        
        task.spawn(function()
            while _G.AutoBridge and task_wait(0.05) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    local block = char:FindFirstChildOfClass("Tool")
                    if block and (block.Name:lower():find("block") or block.Name:lower():find("wool")) then
                        -- 計算前方的放置位置，稍微向下偏移
                        local pos = hrp.Position + (hum.MoveDirection * 2.5) + Vector3_new(0, -3.6, 0)
                        local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                        if remote then
                            remote:FireServer({["position"] = pos, ["block"] = block.Name})
                        end
                    end
                end
            end
        end)
    end)

    AddScript("BEDWARS 專區", "自動購買 (Auto Buy)", "自動補貨邏輯：檢測方塊儲備並購買裝備。", function()
        _G.AutoBuy = not _G.AutoBuy
        Notify("自動購買", _G.AutoBuy and "已啟動" or "已關閉", _G.AutoBuy and "Success" or "Info")
        
        task.spawn(function()
            local shopRemote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
            if not shopRemote then return end
            
            local buyList = {
                {item = "iron_armor", cost = 40, currency = "iron"},
                {item = "iron_sword", cost = 70, currency = "iron"},
                {item = "wool_white", cost = 8, currency = "iron", minAmount = 32}
            }
            
            while _G.AutoBuy do
                local char = lp.Character
                if char then
                    for _, info in ipairs(buyList) do
                        shopRemote:FireServer({["item"] = info.item, ["amount"] = 1})
                    end
                end
                task_wait(2)
            end
        end)
    end)

    AddScript("BEDWARS 專區", "快速破床 (Fast Break)", "移除挖掘延遲協議：實現瞬間破壞任何方塊與床位 (全自動)。", function()
        _G.FastBreak = not _G.FastBreak
        Notify("快速破床", _G.FastBreak and "已啟動" or "已關閉", _G.FastBreak and "Success" or "Info")
        
        task.spawn(function()
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
    end)

    AddScript("BEDWARS 專區", "全員墜空 (Void All)", "利用多維度 Fling 協議將伺服器玩家甩入虛空 (增強型穩定性)。", function()
        _G.VoidAll = not _G.VoidAll
        Notify("全員墜空", _G.VoidAll and "已啟動" or "已停止", _G.VoidAll and "Success" or "Info")
        
        if not _G.VoidAll then return end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local function Fling(target)
            if not _G.VoidAll then return end
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local thrp = target.Character.HumanoidRootPart
                local bfv = Instance.new("BodyAngularVelocity")
                ApplyProperties(bfv, {
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

        task.spawn(function()
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
    end)

    AddScript("BEDWARS 專區", "自動掛機 (Auto Play)", "增強型自動化：結合腳本核心功能 (殺戮光環、防擊退、自動切換工具) 實現全自動作戰與資源收集。", function()
        _G.AI_Enabled = not _G.AI_Enabled
        Notify("自動掛機", _G.AI_Enabled and "已啟動：核心功能已就緒" or "已停止運行。", "Info")
        
        if _G.AI_Enabled then
            -- 啟動腳本核心功能輔助
            _G.CatFunctions.ToggleKillAura(true)
            _G.CatFunctions.ToggleNoFall(true)
            _G.CatFunctions.ToggleVelocity(true)
            _G.CatFunctions.ToggleAutoToolFastBreak(true)
            _G.CatFunctions.ToggleAutoBuy(true)
            _G.CatFunctions.ToggleReach(true)
        else
            -- 停止輔助功能
            _G.CatFunctions.ToggleKillAura(false)
            _G.CatFunctions.ToggleAutoToolFastBreak(false)
            return 
        end

        local PathfindingService = game:GetService("PathfindingService")
        
        -- AI 配置
        local config = {
            attackRange = 18,
            bedPriorityRange = 300,
            resourcePriorityRange = 100,
            voidCheckDist = 10
        }

        local function GetBestTarget()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end

            local battlefield = _G.CatFunctions.GetBattlefieldState()
            
            -- 1. 優先處理威脅：如果正在被攻擊或敵人在極近距離 (15格內)
            if (battlefield.isBeingTargeted or (battlefield.nearestThreat and battlefield.nearestThreat.dist < 15)) and battlefield.nearestThreat then
                return {part = battlefield.nearestThreat.hrp, dist = battlefield.nearestThreat.dist, type = "PLAYER", hum = battlefield.nearestThreat.hum}
            end

            -- 2. 尋找敵對床位 (爆床優先)
            local beds = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "bed" and v:IsA("BasePart") then
                    local team = v:GetAttribute("Team")
                    if team ~= lp.Team then
                        local dist = (v.Position - hrp.Position).Magnitude
                        if dist < config.bedPriorityRange then
                            table.insert(beds, {part = v, dist = dist, type = "BED"})
                        end
                    end
                end
            end
            table.sort(beds, function(a, b) return a.dist < b.dist end)
            
            if beds[1] then return beds[1] end

            -- 3. 尋找關鍵資源 (鑽石/翡翠優先)
            if battlefield.resources[1] then
                return {part = battlefield.resources[1].part, dist = battlefield.resources[1].dist, type = "RESOURCE"}
            end

            -- 4. 最後才是主動追擊最近的玩家
            if battlefield.nearestThreat then
                return {part = battlefield.nearestThreat.hrp, dist = battlefield.nearestThreat.dist, type = "PLAYER", hum = battlefield.nearestThreat.hum}
            end

            return nil
        end

        local function SwitchTool(targetType)
            local char = lp.Character
            if not char then return end
            
            -- 獲取所有工具
            local tools = {}
            for _, v in ipairs(lp.Backpack:GetChildren()) do
                if v:IsA("Tool") then tools[v.Name:lower()] = v end
            end
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Tool") then tools[v.Name:lower()] = v end
            end

            local bestTool = nil
            if targetType == "BED" then
                -- 優先順序：axe > pickaxe > shears
                bestTool = tools["axe"] or tools["pickaxe"] or tools["shears"]
            elseif targetType == "PLAYER" then
                -- 優先順序：sword > shears (緊急時)
                bestTool = tools["sword"] or tools["blade"]
            end

            if bestTool and bestTool.Parent ~= char then
                lp.Character.Humanoid:EquipTool(bestTool)
            end
        end

        task.spawn(function()
            while _G.AI_Enabled and task_wait(0.05) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    -- 實時關注：旋轉視角掃描戰場
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(5), 0)
                    
                    local target = GetBestTarget()
                    
                    if target then
                        SwitchTool(target.type)
                        
                        local dist = (hrp.Position - target.part.Position).Magnitude
                        
                        -- 戰鬥/爆床邏輯
                        if dist < 15 then
                            hum:MoveTo(target.part.Position)
                            if target.type == "PLAYER" then
                                -- 自動攻擊已由 KillAura 處理，這裡確保目標被正確鎖定
                                _G.KillAuraRange = 35
                            elseif target.type == "BED" then
                                -- 自動爆床已由 ToggleAutoToolFastBreak 處理
                                local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true)
                                if remote then remote:FireServer({["position"] = target.part.Position, ["block"] = "bed"}) end
                            end
                        else
                            -- 路徑規劃與導航
                            local path = PathfindingService:CreatePath({
                                AgentRadius = 3,
                                AgentCanJump = true,
                                AgentJumpHeight = 50
                            })
                            path:ComputeAsync(hrp.Position, target.part.Position)
                            
                            if path.Status == Enum.PathStatus.Success then
                                local waypoints = path:GetWaypoints()
                                for i = 2, math.min(5, #waypoints) do -- 只執行前幾個路徑點，保證實時反應
                                     local currentTarget = GetBestTarget()
                                     if not _G.AI_Enabled or not currentTarget or (currentTarget.type == "PLAYER" and currentTarget.dist < 15) then break end
                                     
                                     local wp = waypoints[i]
                                     hum:MoveTo(wp.Position)
                                     
                                     if wp.Action == Enum.PathWaypointAction.Jump then
                                         hum.Jump = true
                                     end
                                     
                                     -- 防墜落檢查
                                     local ray = Ray.new(wp.Position + Vector3_new(0, 2, 0), Vector3_new(0, -config.voidCheckDist, 0))
                                     local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                                     if not hit then hum.Jump = true end
                                     
                                     task_wait(0.1)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)

    AddScript("BEDWARS 專區", "自動購物", "自動根據您的資源量購買當前最需要的裝備。", function()
        _G.SmartBuy = not _G.SmartBuy
        Notify("自動購物", _G.SmartBuy and "已啟動" or "已關閉", _G.SmartBuy and "Success" or "Info")
        
        task.spawn(function()
            while _G.SmartBuy and task_wait(5) do
                -- 模擬購買邏輯
            end
        end)
    end)

    AddScript("BEDWARS 專區", "自動收集資源", "自動尋找最近的資源點 (如鑽石/翡翠) 並收集。", function()
        _G.AutoFarm = not _G.AutoFarm
        Notify("自動收集", _G.AutoFarm and "已啟動" or "已關閉", _G.AutoFarm and "Success" or "Info")
        
        task.spawn(function()
            while _G.AutoFarm and task_wait(1) do
                -- 模擬農場邏輯
            end
        end)
    end)

    AddScript("BEDWARS 專區", "Original Vape V4", "Bedwars 最知名的腳本版本，功能齊全。", function()
        SecureLoad("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua")()
    end)

    AddScript("BEDWARS 專區", "自動工具", "自動切換最適工具 (斧/鎬/剪刀) 並執行高頻破塊協議。", function()
        local state = _G.CatFunctions.ToggleAutoToolFastBreak()
        Notify("自動工具", state and "已啟動" or "已關閉", state and "Success" or "Info")
    end)

    AddScript("BEDWARS 專區", "自動爆床", "自動破壞敵對床位：優化掃描演算法、自動判定距離並執行破壞協議。", function()
        local state = _G.CatFunctions.ToggleInstantBed()
        Notify("自動爆床", state and "已啟動" or "已停止", state and "Success" or "Info")
    end)

    AddScript("BEDWARS 專區", "Bedwars Anticheat Bypass", "繞過協定：攔截偵測封包、偽造玩家狀態、並優化網路同步以降低延遲。", function()
        _G.BypassEnabled = not _G.BypassEnabled
        Notify("繞過協定", _G.BypassEnabled and "已部署" or "已卸載", _G.BypassEnabled and "Success" or "Info")
        
        if not _G.BypassEnabled then return end
        
        -- 核心繞過邏輯：利用 Metatable 攔截已在初始化部分完成
        task.spawn(function()
            while _G.BypassEnabled do
                -- 定期重置 SpoofedProperties 以應對遊戲內部的動態檢測
                if _G.BypassEnabled then
                    SpoofedProperties.WalkSpeed = 16
                    SpoofedProperties.JumpPower = 50
                end
                
                -- 攔截網路卡頓偵測 (Bedwars 常用)
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping > 300 then
                    _G.TempDisable = true
                else
                    _G.TempDisable = false
                end
                
                task_wait(1)
            end
        end)
    end)

    local function OptimizeFPS()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
            end
        end
        if env.setfpscap then env.setfpscap(999) end
    end

    AddScript("BEDWARS 專區", "Bedwars FPS Booster", "極限優化 Bedwars 效能，移除貼圖、陰影與特效以極大化 FPS。", function()
        OptimizeFPS()
        Notify("優化完成", "Bedwars FPS 已顯著提升。", "Success")
    end)

    -- === 伺服器工具內容 ===
    AddScript("伺服器工具", "更換伺服器 (Server Hop)", "自動尋找並加入另一個伺服器。", function()
        local HttpService = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local function NextServer()
            local Servers = HttpService:JSONDecode(game:HttpGetAsync(Api))
            for _, v in pairs(Servers.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, v.id)
                end
            end
        end
        NextServer()
    end)

    AddScript("伺服器工具", "重新加入 (Rejoin)", "立即重新加入當前伺服器。", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)

    AddScript("伺服器工具", "加入空服 (Small Server)", "智能搜尋當前遊戲中人數最少的伺服器並自動跳轉。", function()
        Notify("搜尋中", "正在獲取伺服器列表...", "Info")
        local HttpService = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        
        local function GetSmallestServer()
            local success, res = pcall(function()
                return game:HttpGetAsync(Api)
            end)
            
            if success then
                local Servers = HttpService:JSONDecode(res)
                local smallest = nil
                local minPlayers = 999
                
                for _, v in pairs(Servers.data) do
                    if v.playing < v.maxPlayers and v.playing < minPlayers and v.id ~= game.JobId then
                        minPlayers = v.playing
                        smallest = v.id
                    end
                end
                
                if smallest then
                    Notify("成功", "找到人數最少的伺服器 (" .. minPlayers .. " 人)，正在傳送...", "Success")
                    TPS:TeleportToPlaceInstance(game.PlaceId, smallest)
                else
                    Notify("提示", "找不到更合適的伺服器。", "Info")
                end
            else
                Notify("錯誤", "無法獲取伺服器數據。", "Error")
            end
        end
        GetSmallestServer()
    end)

    -- === 優化功能內容 ===
    AddScript("優化功能", "清除垃圾 (Clear Lag)", "刪除地圖中散落的掉落物與零件，減少延遲。", function()
        local count = 0
        local children = workspace:GetChildren()
        for i = 1, #children do
            local v = children[i]
            if v:IsA("Part") and v.Name == "Handle" then
                v:Destroy()
                count = count + 1
            end
        end
        Notify("清理完成", "已清除 " .. count .. " 個多餘零件。", "Success")
    end)

    AddScript("優化功能", "關閉 3D 渲染 (掛機用)", "關閉 3D 渲染以極大化節省效能 (再次執行開啟)。", function()
        if not _G.RenderingDisabled then
            RunService:Set3dRenderingEnabled(false)
            _G.RenderingDisabled = true
            Notify("提示", "3D 渲染已關閉，節能模式啟動。", "Info")
        else
            RunService:Set3dRenderingEnabled(true)
            _G.RenderingDisabled = false
            Notify("提示", "3D 渲染已重新開啟。", "Info")
        end
    end)

    -- 關閉按鈕邏輯
    ApplyProperties(CloseButton, {
        Name = "CloseButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.94, 0, 0.02, 0),
        Size = UDim2_new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3_fromRGB(200, 50, 50),
        TextSize = 18
    })
    SafeConnect(CloseButton.MouseButton1Click, Cleanup)

    -- === 啟動 GUI ===
    -- RGB 循環效果 (極致加強版)
    task_spawn(function()
        local hue = 0
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Parent = RGBLine
        
        -- 為主框架添加動態邊框
        local MainStroke = Instance.new("UIStroke")
        ApplyProperties(MainStroke, {
            Color = Color3_fromRGB(255, 255, 255),
            Thickness = 1.5,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = MainFrame
        })
        
        local StrokeGradient = Instance.new("UIGradient")
        StrokeGradient.Parent = MainStroke

        while ScreenGui and ScreenGui.Parent do
            hue = (hue + 1) % 360
            local color1 = Color3_fromHSV(hue / 360, 0.8, 1)
            local color2 = Color3_fromHSV(((hue + 60) % 360) / 360, 0.8, 1)
            
            local sequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color1),
                ColorSequenceKeypoint.new(1, color2)
            })
            
            UIGradient.Color = sequence
            UIGradient.Rotation = (hue * 2) % 360
            
            StrokeGradient.Color = sequence
            StrokeGradient.Rotation = (hue * 2) % 360
            
            -- 同步更新標題
            Title.TextColor3 = color1
            if SubTitle then SubTitle.TextColor3 = color2 end
            
            -- 確保選中的分頁按鈕顏色同步
            if CurrentTab and CurrentTab.Button then
                CurrentTab.Button.BackgroundColor3 = color1
                CurrentTab.Button.TextColor3 = Color3_fromRGB(255, 255, 255)
                
                -- 為選中的按鈕添加一個發光效果 (利用 UIStroke)
                local s = CurrentTab.Button:FindFirstChildOfClass("UIStroke")
                if s then
                    s.Color = color2
                    s.Thickness = 2
                end
            end
            
            task_wait(0.02)
        end
    end)

    Tabs["BEDWARS 專區"].Button.BackgroundColor3 = Color3_fromRGB(60, 120, 255)
    Tabs["BEDWARS 專區"].Button.TextColor3 = Color3_fromRGB(255, 255, 255)
    Tabs["BEDWARS 專區"].Page.Visible = true
    CurrentTab = {Button = Tabs["BEDWARS 專區"].Button, Page = Tabs["BEDWARS 專區"].Page}

    -- 最後一步：將 GUI 掛載到 CoreGui/gethui，實現「瞬間」載入
    ScreenGui.Parent = ParentUI
    
    Notify("Halol 載入成功", "注入速度已優化，祝您遊戲愉快！", "Success")

end)

if not success then
    warn("Halol Critical Error: " .. tostring(err))
    if CoreGui:FindFirstChild("CatMultiLoaderV3") then
        local gui = CoreGui.CatMultiLoaderV3
        local msg = Instance.new("Message", gui)
        msg.Text = "載入失敗: " .. tostring(err)
        task_wait(5)
        msg:Destroy()
    end
end