---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
-- Halol 射擊類戰鬥模組 (Combat Module)
-- 放置於: 射擊類/combat.lua

local function get_env_safe()
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
local Vector2 = Vector2 or env_global.Vector2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Combat = {}

-- [[ 配置與狀態 ]]
env_global.AimbotEnabled = env_global.AimbotEnabled or false
env_global.AimbotSmoothness = env_global.AimbotSmoothness or 0.2
env_global.AimbotFOV = env_global.AimbotFOV or 150
env_global.AimbotTargetPart = env_global.AimbotTargetPart or "Head"
env_global.ShowFOV = env_global.ShowFOV or false
env_global.AimbotVisibilityCheck = env_global.AimbotVisibilityCheck or false
env_global.AimbotPrediction = env_global.AimbotPrediction or true
env_global.AimbotPredictionAmount = env_global.AimbotPredictionAmount or 0.165

env_global.TriggerBotEnabled = env_global.TriggerBotEnabled or false
env_global.TriggerBotDelay = env_global.TriggerBotDelay or 0.05

env_global.NoRecoilEnabled = env_global.NoRecoilEnabled or false

env_global.AirAttackEnabled = env_global.AirAttackEnabled or false
env_global.AirAttackHeight = env_global.AirAttackHeight or 20

env_global.KillAuraEnabled = env_global.KillAuraEnabled or false
env_global.KillAuraRange = env_global.KillAuraRange or 100

env_global.BlatantSpeedEnabled = env_global.BlatantSpeedEnabled or false
env_global.BlatantSpeedValue = env_global.BlatantSpeedValue or 100

env_global.FlyEnabled = env_global.FlyEnabled or false
env_global.FlySpeed = env_global.FlySpeed or 50

env_global.SpinBotEnabled = env_global.SpinBotEnabled or false
env_global.SpinBotSpeed = env_global.SpinBotSpeed or 50
env_global.AntiAimEnabled = env_global.AntiAimEnabled or false
env_global.FakeCloneEnabled = env_global.FakeCloneEnabled or false
env_global.AutoWinEnabled = env_global.AutoWinEnabled or false
env_global.LagSwitchEnabled = env_global.LagSwitchEnabled or false
env_global.ServerACNukerEnabled = env_global.ServerACNukerEnabled or false

-- [[ 伺服器等級 (Server-Level) 配置 ]]
env_global.ServerLagEnabled = env_global.ServerLagEnabled or false
env_global.ServerLagPower = env_global.ServerLagPower or 100 -- 請求數量
env_global.KillAllEnabled = env_global.KillAllEnabled or false
env_global.ChatSpamEnabled = env_global.ChatSpamEnabled or false
env_global.ChatSpamMessage = env_global.ChatSpamMessage or "Halol Framework | Server Level Exploit"

env_global.BulletTracersEnabled = env_global.BulletTracersEnabled or false
env_global.HitSoundEnabled = env_global.HitSoundEnabled or false

env_global.MagicBulletEnabled = env_global.MagicBulletEnabled or false
env_global.MagicBulletRange = env_global.MagicBulletRange or 500
env_global.SilentAimFOV = env_global.SilentAimFOV or 200
env_global.WallHackKillEnabled = env_global.WallHackKillEnabled or false

-- [[ ESP 配置 ]]
env_global.ESPEnabled = env_global.ESPEnabled or false
env_global.ESPBoxes = env_global.ESPBoxes or false
env_global.ESPBoxType = env_global.ESPBoxType or "2D" -- "2D", "3D"
env_global.ESPNames = env_global.ESPNames or false
env_global.ESPHealth = env_global.ESPHealth or false
env_global.ESPDistance = env_global.ESPDistance or false
env_global.ESPSkeleton = env_global.ESPSkeleton or false
env_global.ESPSnaplines = env_global.ESPSnaplines or false
env_global.ESPSnaplineOrigin = env_global.ESPSnaplineOrigin or "Bottom" -- "Top", "Center", "Bottom"
env_global.ESPChams = env_global.ESPChams or false
env_global.ESPTeamCheck = env_global.ESPTeamCheck or true
env_global.ESPColor = env_global.ESPColor or Color3.fromRGB(255, 255, 255)
env_global.ESPVisibleColor = env_global.ESPVisibleColor or Color3.fromRGB(0, 255, 0)
env_global.ESPRGBEnabled = env_global.ESPRGBEnabled or false

-- [[ 反偵測配置 - 預設立即開啟 ]]
env_global.AntiCheatBypass = true -- 腳本啟動即開啟
env_global.SafeMode = true 
env_global.SpoofRemote = true -- 腳本啟動即開啟
env_global.HumanizedAim = true -- 人性化自瞄

env_global.AntiFlashEnabled = env_global.AntiFlashEnabled or false

-- [[ 工具函數 ]]

-- 檢查目標是否可見 (Raycast)
local function IsVisible(part)
    if not env_global.AimbotVisibilityCheck then return true end
    local char = lp.Character
    if not char then return false end
    
    local ignoreList = {char, Camera}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local result = workspace:Raycast(origin, direction, params)
    
    if result and result.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    return false
end

-- 獲取最近的敵人 (基於鼠標位置與 FOV)
local function GetNearestEnemy()
    local nearest = nil
    local maxDist = env_global.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character then
            local targetPart = player.Character:FindFirstChild(env_global.AimbotTargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < maxDist then
                        if IsVisible(targetPart) then
                            maxDist = dist
                            nearest = targetPart
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- [[ 核心邏輯 ]]

-- Aimbot 主循環
RunService.RenderStepped:Connect(function()
    if env_global.AimbotEnabled then
        local targetPart = GetNearestEnemy()
        if targetPart then
            local targetPos = targetPart.Position
            
            -- 人性化偏移：不總是精確瞄準中心
            if env_global.HumanizedAim then
                local offset = Vector3.new(
                    math.random(-5, 5) / 10,
                    math.random(-5, 5) / 10,
                    math.random(-5, 5) / 10
                )
                targetPos = targetPos + offset
            end

            -- 考慮預測 (如果目標有速度)
            if env_global.AimbotPrediction and targetPart.Parent:FindFirstChild("HumanoidRootPart") then
                local velocity = targetPart.Parent.HumanoidRootPart.Velocity
                targetPos = targetPos + (velocity * env_global.AimbotPredictionAmount)
                
                -- 加入加速度補償 (如果目標在跳躍或掉落)
                if velocity.Y > 5 or velocity.Y < -5 then
                    targetPos = targetPos + Vector3.new(0, (workspace.Gravity * 0.5 * env_global.AimbotPredictionAmount^2), 0)
                end
            end
            
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            
            -- 人性化平滑：隨機化平滑度防止機械化移動
            local smooth = env_global.AimbotSmoothness
            if env_global.HumanizedAim then
                smooth = smooth * (math.random(8, 12) / 10)
            end
            
            Camera.CFrame = currentCF:Lerp(targetCF, math.clamp(smooth, 0.01, 1))
        end
    end
end)

-- [[ 魔法子彈 (Magic Bullet) 核心實作 ]]
local function SetupMagicBullet()
    local oldIndex
    local oldNamecall
    
    -- 獲取偽裝環境
    local function IsRealRequest()
        if not env_global.AntiCheatBypass then return true end
        
        -- checkcaller() 是最重要的反偵測手段，判斷調用者是否為執行器
        if env_global.checkcaller and env_global.checkcaller() then
            return true -- 來自腳本自身的調用，允許通過
        end

        local stack = debug.traceback()
        -- 增加更多敏感關鍵字
        local ac_keywords = {
            "Anticheat", "Adonis", "Sentinel", "AC", "Detection", "Flag", "Log",
            "Watcher", "Checker", "Ban", "Kick", "Verify", "Protect"
        }
        
        for _, word in ipairs(ac_keywords) do
            if stack:find(word) then
                return false
            end
        end
        return true
    end

    -- 嘗試 Hook Metatable (如果執行器支持)
    pcall(function()
        if not env_global.hookmetamethod then return end
        
        -- Hook __index 攔截 Mouse.Hit 和 Mouse.Target
        oldIndex = env_global.hookmetamethod(game, "__index", function(self, key)
            if env_global.MagicBulletEnabled and IsRealRequest() then
                if tostring(self) == "Mouse" then
                    if key == "Hit" or key == "Target" then
                        local target = GetNearestTarget(env_global.MagicBulletRange)
                        if target then
                            -- 加入 FOV 限制檢測
                            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                            local mousePos = UserInputService:GetMouseLocation()
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            
                            if onScreen and dist <= env_global.SilentAimFOV then
                                if key == "Hit" then return target.CFrame end
                                if key == "Target" then return target end
                            end
                        end
                    end
                end
            end
            
            -- 反偵測：偽裝本地玩家屬性
            if env_global.AntiCheatBypass and self == lp then
                if key == "WalkSpeed" then return 16 end -- 永遠返回正常速度
                if key == "JumpPower" then return 50 end
            end

            return oldIndex(self, key)
        end)
        
        -- Hook __namecall 攔截 Raycast 與 Remote 事件
        oldNamecall = env_global.hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            -- 1. 魔法子彈攔截 (Raycast / FindPartOnRay)
            if (env_global.MagicBulletEnabled or env_global.WallHackKillEnabled) and IsRealRequest() then
                if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                    local target = GetNearestTarget(env_global.MagicBulletRange)
                    if target then
                        -- FOV 限制 (穿牆擊殺時可選是否無視 FOV，這裡暫定暴力模式無視部分限制)
                        local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- 如果是穿牆擊殺，只要在範圍內就觸發
                        local shouldTrigger = (onScreen and dist <= env_global.SilentAimFOV) or env_global.WallHackKillEnabled
                        
                        if shouldTrigger then
                            if method == "Raycast" then
                                local origin = args[1]
                                local direction = (target.Position - origin).Unit * 1000
                                args[2] = direction
                            elseif method:find("FindPartOnRay") then
                                local ray = args[1]
                                local direction = (target.Position - ray.Origin).Unit * 1000
                                args[1] = Ray.new(ray.Origin, direction)
                            end
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
            end
            
            -- 2. 攔截反外掛 Remote (阻止上報)
        if env_global.SpoofRemote and method == "FireServer" then
            local remoteName = tostring(self):lower()
            -- 增加更多暴力模式相關的攔截
            if remoteName:find("check") or remoteName:find("detect") or remoteName:find("ban") or remoteName:find("kick") or remoteName:find("flag") or remoteName:find("report") or remoteName:find("cheat") then
                warn("攔截到疑似反外掛上報: " .. remoteName)
                return nil -- 吞掉該請求
            end
        end

            return oldNamecall(self, ...)
        end)
    end)
end

-- 立即啟動反偵測與 Hook 系統
task.spawn(function()
    SetupMagicBullet()
    -- 由於 Notify 可能還沒準備好，我們先用 warn 記錄
    warn("[Halol] 反偵測防護與 Hook 系統已立即啟動")
end)

-- [[ 伺服器等級 (Server-Level) 實作 ]]
task.spawn(function()
    while true do
        -- 0. 自動獲勝 (Auto Win)
        if env_global.AutoWinEnabled then
            -- 嘗試殺死所有人
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Team ~= lp.Team and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        for _, v in ipairs(game:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                local name = v.Name:lower()
                                if name:find("hit") or name:find("damage") or name:find("attack") then
                                    v:FireServer(head, 100)
                                end
                            end
                        end
                    end
                end
            end
            -- 嘗試尋找目標點並移動
             for _, v in ipairs(workspace:GetDescendants()) do
                 if v:IsA("BasePart") or v:IsA("Model") then
                     local name = v.Name:lower()
                     if name:find("win") or name:find("flag") or name:find("goal") or name:find("objective") or name:find("end") then
                         local targetCF = (v:IsA("Model") and v:GetModelCFrame() or v.CFrame)
                         SmoothMoveTo(targetCF, 5) -- 以每步 5 格的速度移動
                     end
                 end
             end
        end

        -- 1. 伺服器延遲 (Server Lag)
        if env_global.ServerLagEnabled then
            -- 尋找並嘗試過載伺服器端的 Remote
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    for i = 1, (env_global.ServerLagPower or 100) do
                        v:FireServer(string.rep("LAG", 100), {["Lag"] = string.rep("0", 100)})
                    end
                end
            end
        end

        -- 2. 全服擊殺 (Kill All) 嘗試
        if env_global.KillAllEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Team ~= lp.Team and player.Character then
                    -- 尋找通用攻擊 Remote
                    for _, v in ipairs(game:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            local name = v.Name:lower()
                            if name:find("hit") or name:find("damage") or name:find("attack") or name:find("shoot") then
                                -- 模擬命中請求
                                v:FireServer(player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart"), 100)
                            end
                        end
                    end
                end
            end
        end

        -- 3. 全服聊天轟炸 (Chat Spam)
        if env_global.ChatSpamEnabled then
            local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
                chatEvent.SayMessageRequest:FireServer(env_global.ChatSpamMessage, "All")
            else
                -- 嘗試新版 TextChatService
                local tcs = game:GetService("TextChatService")
                if tcs and tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral") then
                    tcs.TextChannels.RBXGeneral:SendAsync(env_global.ChatSpamMessage)
                end
            end
        end

        task.wait(1) -- 避免客戶端崩潰
    end
end)

-- [[ ESP 實作 ]]
local ESP_Objects = {}

-- RGB 邏輯
task.spawn(function()
    local counter = 0
    while true do
        if env_global.ESPRGBEnabled then
            counter = counter + 0.01
            local color = Color3.fromHSV(counter % 1, 1, 1)
            env_global.ESPColor = color
            env_global.ESPVisibleColor = color
        end
        task.wait(0.03)
    end
end)

-- 骨骼連接定義
local SkeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function CreateESP(player)
    local objects = {
        Box = env_global.Drawing.new("Square"),
        Name = env_global.Drawing.new("Text"),
        Distance = env_global.Drawing.new("Text"),
        Snapline = env_global.Drawing.new("Line"),
        HealthBarOutline = env_global.Drawing.new("Square"),
        HealthBar = env_global.Drawing.new("Square"),
        Highlight = Instance.new("Highlight"),
        Skeleton = {}
    }
    
    -- 初始化骨骼線條
    for i = 1, #SkeletonConnections do
        local line = env_global.Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        table.insert(objects.Skeleton, line)
    end
    
    -- 初始化屬性
    objects.Box.Thickness = 1
    objects.Box.Filled = false
    objects.Box.Transparency = 1
    
    objects.Name.Size = 16
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Transparency = 1
    
    objects.Distance.Size = 14
    objects.Distance.Center = true
    objects.Distance.Outline = true
    objects.Distance.Transparency = 1
    
    objects.Snapline.Thickness = 1
    objects.Snapline.Transparency = 1
    
    objects.HealthBarOutline.Thickness = 1
    objects.HealthBarOutline.Filled = true
    objects.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Filled = true
    
    objects.Highlight.Parent = nil -- 初始不顯示
    
    ESP_Objects[player] = objects
end

local function RemoveESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            if obj.Remove then obj:Remove() elseif obj.Destroy then obj:Destroy() end
        end
        ESP_Objects[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not env_global.ESPEnabled then
        for player, _ in pairs(ESP_Objects) do RemoveESP(player) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            if not ESP_Objects[player] then CreateESP(player) end
            local objects = ESP_Objects[player]
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            local visible = false
            if char and hum and hrp and hum.Health > 0 then
                if not (env_global.ESPTeamCheck and player.Team == lp.Team) then
                    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        visible = true
                        local topPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                        local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width = height / 1.5
                        
                        -- 更新顏色
                        local espColor = env_global.ESPColor
                        if IsVisible(hrp) then espColor = env_global.ESPVisibleColor end
                        
                        -- 方框
                        objects.Box.Visible = env_global.ESPBoxes
                        if env_global.ESPBoxes then
                            objects.Box.Size = Vector2.new(width, height)
                            objects.Box.Position = Vector2.new(hrpPos.X - width/2, hrpPos.Y - height/2)
                            objects.Box.Color = espColor
                        end
                        
                        -- 名字
                        objects.Name.Visible = env_global.ESPNames
                        if env_global.ESPNames then
                            objects.Name.Text = player.Name
                            objects.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y - height/2 - 20)
                            objects.Name.Color = espColor
                        end
                        
                        -- 距離
                        objects.Distance.Visible = env_global.ESPDistance
                        if env_global.ESPDistance then
                            local dist = math.floor((lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            objects.Distance.Text = "[" .. dist .. "m]"
                            objects.Distance.Position = Vector2.new(hrpPos.X, hrpPos.Y + height/2 + 5)
                            objects.Distance.Color = Color3.fromRGB(255, 255, 255)
                        end
                        
                        -- 血條
                        objects.HealthBar.Visible = env_global.ESPHealth
                        objects.HealthBarOutline.Visible = env_global.ESPHealth
                        if env_global.ESPHealth then
                            local healthPercent = hum.Health / hum.MaxHealth
                            objects.HealthBarOutline.Size = Vector2.new(4, height)
                            objects.HealthBarOutline.Position = Vector2.new(hrpPos.X - width/2 - 6, hrpPos.Y - height/2)
                            
                            objects.HealthBar.Size = Vector2.new(2, height * healthPercent)
                            objects.HealthBar.Position = Vector2.new(hrpPos.X - width/2 - 5, hrpPos.Y + height/2 - (height * healthPercent))
                            objects.HealthBar.Color = Color3.fromRGB(255 * (1-healthPercent), 255 * healthPercent, 0)
                        end
                        
                        -- 射線
                        objects.Snapline.Visible = env_global.ESPSnaplines
                        if env_global.ESPSnaplines then
                            local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            if env_global.ESPSnaplineOrigin == "Top" then
                                origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                            elseif env_global.ESPSnaplineOrigin == "Center" then
                                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            end
                            objects.Snapline.From = origin
                            objects.Snapline.To = Vector2.new(hrpPos.X, hrpPos.Y + height/2)
                            objects.Snapline.Color = espColor
                        end
                        
                        -- Chams (Highlight)
                        if env_global.ESPChams then
                            objects.Highlight.Parent = char
                            objects.Highlight.FillColor = espColor
                            objects.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            objects.Highlight.FillTransparency = 0.5
                        else
                            objects.Highlight.Parent = nil
                        end
                        
                        -- 骨骼透視
                        if env_global.ESPSkeleton then
                            for i, connection in ipairs(SkeletonConnections) do
                                local part1 = char:FindFirstChild(connection[1])
                                local part2 = char:FindFirstChild(connection[2])
                                local line = objects.Skeleton[i]
                                
                                if part1 and part2 and line then
                                    local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                                    local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                    
                                    if on1 and on2 then
                                        line.Visible = true
                                        line.From = Vector2.new(pos1.X, pos1.Y)
                                        line.To = Vector2.new(pos2.X, pos2.Y)
                                        line.Color = espColor
                                    else
                                        line.Visible = false
                                    end
                                end
                            end
                        else
                            for _, line in ipairs(objects.Skeleton) do line.Visible = false end
                        end
                    end
                end
            end
            
            if not visible then
                for _, obj in pairs(objects) do 
                    if obj.Visible ~= nil then obj.Visible = false end 
                end
                for _, line in ipairs(objects.Skeleton) do line.Visible = false end
                objects.Highlight.Parent = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- [[ 暴力模式邏輯 ]]

-- 繪製彈道線條
local function CreateTracer(from, to)
    if not env_global.Drawing then return end
    local line = env_global.Drawing.new("Line")
    line.Visible = true
    line.From = from
    line.To = to
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 1.5
    line.Transparency = 1
    
    task.spawn(function()
        for i = 1, 10 do
            line.Transparency = line.Transparency - 0.1
            task.wait(0.05)
        end
        line:Remove()
    end)
end

-- 播放命中音效 (使用 Roblox 內建音效)
local function PlayHitSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://160433791" -- 經典命中音效
    sound.Volume = 1
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- 獲取範圍內最近的敵人 (不限於準心，純距離)
local function GetNearestTarget(maxRange)
    local nearest = nil
    local minDist = maxRange or 500
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = player.Character.HumanoidRootPart
            end
        end
    end
    return nearest
end

-- [[ 暴力模式功能實作 ]]

-- 平滑移動至目標 (替代傳送)
local function SmoothMoveTo(targetCFrame, speed)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance > 2 then
        local direction = (targetCFrame.Position - hrp.Position).Unit
        -- 使用 Velocity 或直接增量 CFrame 來模擬移動
        hrp.CFrame = hrp.CFrame + (direction * (speed or 2))
        -- 保持水平，防止旋轉混亂
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
    end
end

-- 本地卡頓 (Lag Switch) 實作
task.spawn(function()
    while true do
        if env_global.LagSwitchEnabled then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- 暫時錨定 HRP，停止位置同步到伺服器
                hrp.Anchored = true
                task.wait(0.5) -- 卡頓 0.5 秒
                hrp.Anchored = false
            end
        end
        task.wait(0.1)
    end
end)

local fakeCloneModel = nil
local function ClearFakeClone()
    if fakeCloneModel then
        fakeCloneModel:Destroy()
        fakeCloneModel = nil
    end
end

local function CreateFakeClone()
    ClearFakeClone()
    local char = lp.Character
    if not char then return end
    
    char.Archivable = true
    fakeCloneModel = char:Clone()
    char.Archivable = false
    
    fakeCloneModel.Name = "FakeClone_" .. lp.Name
    fakeCloneModel.Parent = workspace
    
    -- 移除腳本與不必要的組件
    for _, v in ipairs(fakeCloneModel:GetDescendants()) do
        if v:IsA("LocalScript") or v:IsA("Script") then
            v:Destroy()
        end
    end
    
    local hum = fakeCloneModel:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        -- 確保替身不會亂動
        hum.PlatformStand = true
    end
    
    -- 設置外觀顏色 (可選，讓玩家區分)
    for _, v in ipairs(fakeCloneModel:GetChildren()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.3 -- 半透明方便區分
            v.CanCollide = false
            v.Anchored = true -- 固定在原位
        end
    end
    
    -- 設置初始位置
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local cloneHRP = fakeCloneModel:FindFirstChild("HumanoidRootPart")
    if hrp and cloneHRP then
        cloneHRP.CFrame = hrp.CFrame
    end
    
    Notify("暴力模式", "假替身已部署")
end

local function NukeAntiCheat()
    local keywords = {"anticheat", "ac", "detection", "flag", "kick", "ban", "watcher", "checker", "sentinel", "adonis"}
    local count = 0
    for _, v in ipairs(game:GetDescendants()) do
        pcall(function()
            if v:IsA("LocalScript") or v:IsA("Script") or v:IsA("ModuleScript") then
                local name = v.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then
                        v.Disabled = true
                        v:Destroy()
                        count = count + 1
                        break
                    end
                end
            elseif v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local name = v.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then
                        -- 嘗試銷毀或禁用 Remote
                        v:Destroy()
                        count = count + 1
                        break
                    end
                end
            end
        end)
    end
    return count
end

-- 暴力模式循環 (TriggerBot + 空中打人 + 殺戮光環 + 暴力移動)
task.spawn(function()
    while true do
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum then
            -- 1. 空中打人 (Air Attack)
            if env_global.AirAttackEnabled then
                local target = GetNearestTarget(100) -- 偵測 100 格內的敵人
                if target then
                    -- 增加隨機偏移防止過於死板 (Anti-Cheat Bypass)
                    local jitter = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                    local targetPos = target.CFrame * CFrame.new(0, env_global.AirAttackHeight, 0) * CFrame.new(jitter.X, 0, jitter.Z)
                    
                    -- 使用平滑移動替代瞬移
                    SmoothMoveTo(targetPos, 3)
                    
                    -- 鎖定垂直速度防止掉落太快
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    
                    -- 自動開火
                    if env_global.mouse1click then
                        env_global.mouse1click()
                        
                        -- 彈道與音效
                        if env_global.BulletTracersEnabled then
                            local screenFrom, onScreen1 = Camera:WorldToViewportPoint(hrp.Position)
                            local screenTo, onScreen2 = Camera:WorldToViewportPoint(target.Position)
                            if onScreen1 and onScreen2 then
                                CreateTracer(Vector2.new(screenFrom.X, screenFrom.Y), Vector2.new(screenTo.X, screenTo.Y))
                            end
                        end
                        
                        if env_global.HitSoundEnabled then
                            PlayHitSound()
                        end
                    end
                end
            end
            
            -- 2. 殺戮光環 (Kill Aura)
            if env_global.KillAuraEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = player.Character.HumanoidRootPart
                        local dist = (hrp.Position - targetHRP.Position).Magnitude
                        if dist <= env_global.KillAuraRange then
                            -- 自動點擊 (假設遊戲使用鼠標點擊觸發攻擊)
                            if env_global.mouse1click then
                                env_global.mouse1click()
                            end
                        end
                    end
                end
            end

            -- 3. 暴力移動 (Blatant Speed)
            if env_global.BlatantSpeedEnabled then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (moveDir * (env_global.BlatantSpeedValue / 10))
                end
            end

            -- 4. 飛行模式 (Fly)
            if env_global.FlyEnabled then
                local cameraCF = Camera.CFrame
                local flyDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyDir = flyDir + cameraCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyDir = flyDir - cameraCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyDir = flyDir - cameraCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyDir = flyDir + cameraCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyDir = flyDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then flyDir = flyDir - Vector3.new(0, 1, 0) end
                
                if flyDir.Magnitude > 0 then
                    hrp.Velocity = flyDir.Unit * env_global.FlySpeed
                else
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
                -- 防止重力影響
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.0001, 0) 
            end
        end
        
        -- 5. 大陀螺 (Spin Bot) & 防瞄準 (Anti-Aim)
        if (env_global.SpinBotEnabled or env_global.AntiAimEnabled) and hrp then
            -- 旋轉
            if env_global.SpinBotEnabled then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(env_global.SpinBotSpeed or 50), 0)
            end
            
            -- 防瞄準 (Anti-Aim / Jitter) - 使敵方難以鎖定
            if env_global.AntiAimEnabled then
                local jitter = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                hrp.Velocity = jitter * 50 -- 偽造速度干擾自瞄預測
                -- 快速抖動位置 (微小到不影響移動，但足以干擾光線投射)
                hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-100, 100)/1000, 0, math.random(-100, 100)/1000)
            end
        end
        
        -- 6. 標準 TriggerBot (僅在暴力模式未啟動或未發現目標時運行)
        if env_global.TriggerBotEnabled and not (env_global.AirAttackEnabled and GetNearestTarget(30)) then
            local mouse = lp:GetMouse()
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(target.Parent)
                if player and player ~= lp and player.Team ~= lp.Team then
                    if env_global.mouse1click then
                        env_global.mouse1click()
                    end
                end
            end
        end
        
        task.wait(env_global.TriggerBotDelay or 0.05)
    end
end)

-- FOV 繪製 (使用 Drawing API)
local fovCircle = nil
if env_global.Drawing then
    fovCircle = env_global.Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Radius = env_global.AimbotFOV
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(0, 255, 255)
    fovCircle.Visible = false
    
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Visible = env_global.ShowFOV and env_global.AimbotEnabled
            fovCircle.Radius = env_global.AimbotFOV
            fovCircle.Position = UserInputService:GetMouseLocation()
        end
    end)
end

-- [[ 反閃光彈 (Anti-Flash) ]]
task.spawn(function()
    while true do
        if env_global.AntiFlashEnabled then
            -- 1. 處理 Lighting 效果
            local Lighting = game:GetService("Lighting")
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") then
                    if effect.Name:lower():find("flash") or effect.Name:lower():find("stun") then
                        effect.Enabled = false
                    end
                end
            end
            
            -- 2. 處理本地玩家 GUI
            local playerGui = lp:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetDescendants()) do
                    if gui:IsA("Frame") and gui.Visible and gui.BackgroundTransparency < 0.5 then
                        if gui.Name:lower():find("flash") or gui.Name:lower():find("white") then
                            gui.Visible = false
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [[ 模組接口 ]]
function Combat.Init(Gui, Notify, CatFunctions)
    -- 如果有 GUI 系統，可以在這裡添加選項
    return {
        ToggleAimbot = function(state)
            env_global.AimbotEnabled = state
            Notify("自瞄系統", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAimbotVisibility = function(state)
            env_global.AimbotVisibilityCheck = state
            Notify("自瞄系統", "可見度檢查: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAimbotPrediction = function(state)
            env_global.AimbotPrediction = state
            Notify("自瞄系統", "彈道預測: " .. (state and "開啟" or "關閉"))
        end,
        
        SetAimbotSmoothness = function(val)
            env_global.AimbotSmoothness = val
        end,
        
        ToggleShowFOV = function(state)
            env_global.ShowFOV = state
        end,
        
        SetAimbotFOV = function(val)
            env_global.AimbotFOV = val
        end,
        
        ToggleTriggerBot = function(state)
            env_global.TriggerBotEnabled = state
            Notify("自動開火", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleNoRecoil = function(state)
            env_global.NoRecoilEnabled = state
            Notify("無後座力", "狀態: " .. (state and "開啟" or "關閉") .. " (需視遊戲環境而定)")
        end,
        
        ToggleAirAttack = function(state)
            env_global.AirAttackEnabled = state
            Notify("暴力模式", "空中打人: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleKillAura = function(state)
            env_global.KillAuraEnabled = state
            Notify("暴力模式", "殺戮光環: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleBlatantSpeed = function(state)
            env_global.BlatantSpeedEnabled = state
            Notify("暴力模式", "極速移動: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleFly = function(state)
            env_global.FlyEnabled = state
            Notify("暴力模式", "飛行模式: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleSpinBot = function(state)
            env_global.SpinBotEnabled = state
            Notify("暴力模式", "大陀螺: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAntiAim = function(state)
            env_global.AntiAimEnabled = state
            Notify("暴力模式", "防瞄準 (Anti-Aim): " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleFakeClone = function(state)
            env_global.FakeCloneEnabled = state
            if state then
                CreateFakeClone()
            else
                ClearFakeClone()
                Notify("暴力模式", "假替身已移除")
            end
        end,

        ToggleAutoWin = function(state)
            env_global.AutoWinEnabled = state
            Notify("暴力模式", "自動獲勝: " .. (state and "開啟" or "關閉"))
        end,

        ToggleLagSwitch = function(state)
            env_global.LagSwitchEnabled = state
            Notify("暴力模式", "自動卡頓 (Lag Switch): " .. (state and "開啟" or "關閉"))
        end,

        ToggleServerACNuker = function(state)
            env_global.ServerACNukerEnabled = state
            if state then
                local count = NukeAntiCheat()
                Notify("安全系統", "反外掛清理: 刪除了 " .. count .. " 個疑似組件")
            end
        end,

        -- 伺服器等級功能
        ToggleServerLag = function(state)
            env_global.ServerLagEnabled = state
            Notify("伺服器等級", "伺服器延遲: " .. (state and "開啟" or "關閉"))
        end,

        ToggleKillAll = function(state)
            env_global.KillAllEnabled = state
            Notify("伺服器等級", "全服擊殺嘗試: " .. (state and "開啟" or "關閉"))
        end,

        ToggleChatSpam = function(state)
            env_global.ChatSpamEnabled = state
            Notify("伺服器等級", "全服聊天轟炸: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleMagicBullet = function(state)
            env_global.MagicBulletEnabled = state
            Notify("魔法子彈", "狀態: " .. (state and "開啟" or "關閉") .. " (需執行器支持 Hook)")
        end,
        
        ToggleWallHackKill = function(state)
            env_global.WallHackKillEnabled = state
            Notify("暴力模式", "穿牆擊殺: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAntiCheatBypass = function(state)
            env_global.AntiCheatBypass = state
            env_global.SpoofRemote = state
            Notify("安全系統", "反外掛繞過: " .. (state and "強化開啟" or "關閉"))
        end,
        
        ToggleBulletTracers = function(state)
            env_global.BulletTracersEnabled = state
        end,
        
        ToggleHitSound = function(state)
            env_global.HitSoundEnabled = state
        end,
        
        ToggleAntiFlash = function(state)
            env_global.AntiFlashEnabled = state
            Notify("視覺增強", "反閃光彈: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleStealthMode = function(state)
            env_global.HumanizedAim = state
            env_global.AntiCheatBypass = state
            env_global.SpoofRemote = state
            Notify("隱蔽模式", "深度隱蔽: " .. (state and "強化" or "正常"))
        end,
        
        -- ESP 相關
        ToggleESP = function(state)
            env_global.ESPEnabled = state
            Notify("透視系統", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleESPBoxes = function(state)
            env_global.ESPBoxes = state
        end,
        
        ToggleESPNames = function(state)
            env_global.ESPNames = state
        end,
        
        ToggleESPHealth = function(state)
            env_global.ESPHealth = state
        end,
        
        ToggleESPDistance = function(state)
            env_global.ESPDistance = state
        end,
        
        ToggleESPSnaplines = function(state)
            env_global.ESPSnaplines = state
        end,
        
        ToggleESPChams = function(state)
            env_global.ESPChams = state
        end,
        
        ToggleESPSkeleton = function(state)
            env_global.ESPSkeleton = state
        end,
        
        ToggleESPTeamCheck = function(state)
            env_global.ESPTeamCheck = state
        end,
        
        ToggleESPRGB = function(state)
            env_global.ESPRGBEnabled = state
            Notify("透視系統", "RGB 模式: " .. (state and "開啟" or "關閉"))
        end,
        
        CycleESPColor = function()
            local colors = {
                Color3.fromRGB(255, 255, 255), -- 白色
                Color3.fromRGB(255, 0, 0),     -- 紅色
                Color3.fromRGB(0, 0, 255),     -- 藍色
                Color3.fromRGB(255, 255, 0),   -- 黃色
                Color3.fromRGB(255, 0, 255),   -- 紫色
                Color3.fromRGB(0, 255, 255)    -- 青色
            }
            
            -- 找到當前顏色的索引
            local currentIndex = 1
            for i, color in ipairs(colors) do
                if env_global.ESPColor == color then
                    currentIndex = i
                    break
                end
            end
            
            -- 切換到下一個
            local nextIndex = (currentIndex % #colors) + 1
            env_global.ESPColor = colors[nextIndex]
            
            local colorNames = {"白色", "紅色", "藍色", "黃色", "紫色", "青色"}
            Notify("透視系統", "當前顏色: " .. colorNames[nextIndex])
        end
    }
end

-- 導出模組
if env_global.HalolModules then
    env_global.HalolModules.Combat = Combat
end

return Combat
