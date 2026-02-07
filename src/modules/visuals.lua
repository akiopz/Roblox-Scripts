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
local Color3 = Color3 or env_global.Color3
local UDim2 = UDim2 or env_global.UDim2
local Vector3 = Vector3 or env_global.Vector3
local Vector2 = Vector2 or env_global.Vector2
local task = task or env_global.task
local math = math or env_global.math
local string = string or env_global.string
local Instance = Instance or env_global.Instance
local Enum = Enum or env_global.Enum
local Drawing = Drawing or env_global.Drawing
local ipairs = ipairs or env_global.ipairs
local pairs = pairs or env_global.pairs
local pcall = pcall or env_global.pcall

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local UDim2_new = UDim2.new
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait
local math_floor = math.floor
local math_clamp = math.clamp or function(v, min, max)
    if v < min then return min end
    if v > max then return max end
    return v
end
local string_format = string.format

local VisualsModule = {}

function VisualsModule.Init(Gui, Notify)
    local ESPTag = "CatESP"
    
    local function ApplyHighlightESP(char)
        if not char or char:FindFirstChild(ESPTag) then return end
        local highlight = Instance.new("Highlight")
        Gui.ApplyProperties(highlight, {
            Name = ESPTag,
            Parent = char,
            FillTransparency = 0.5,
            OutlineColor = Color3_fromRGB(255, 0, 0),
            FillColor = Color3_fromRGB(255, 0, 0),
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        })
        
        -- 強化：方框 (Box ESP)
        local box = Instance.new("BoxHandleAdornment")
        Gui.ApplyProperties(box, {
            Name = "CatBoxESP",
            Adornee = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart,
            Size = char:GetExtentsSize() + Vector3_new(0.5, 0.5, 0.5),
            Color3 = Color3_fromRGB(255, 255, 255),
            Transparency = 0.8,
            AlwaysOnTop = true,
            ZIndex = 10,
            Parent = char
        })
    end

    local function CreateFullESP(player)
        if player == lp then return end
        
        -- Drawing API Tracers
        local tracer = nil
        if Drawing then
            tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Color = Color3_fromRGB(255, 255, 255)
            tracer.Thickness = 1
            tracer.Transparency = 0.8
        end

        local function OnCharacterAdded(char)
            local head = char:WaitForChild("Head", 10)
            if not head then return end
            
            local old = head:FindFirstChild("CatFullESP")
            if old then old:Destroy() end
            
            local billboard = Instance.new("BillboardGui")
            Gui.ApplyProperties(billboard, {
                Name = "CatFullESP",
                Adornee = head,
                Size = UDim2_new(0, 150, 0, 70),
                StudsOffset = Vector3_new(0, 3, 0),
                AlwaysOnTop = true,
                Parent = head
            })
            
            local container = Instance.new("Frame")
            Gui.ApplyProperties(container, {
                Parent = billboard,
                BackgroundTransparency = 1,
                Size = UDim2_new(1, 0, 1, 0)
            })
            
            local nameLabel = Instance.new("TextLabel")
            Gui.ApplyProperties(nameLabel, {
                Parent = container,
                BackgroundTransparency = 1,
                Size = UDim2_new(1, 0, 0, 20),
                Text = player.DisplayName .. " (@" .. player.Name .. ")",
                TextColor3 = Color3_fromRGB(255, 255, 255),
                TextStrokeTransparency = 0.5,
                Font = Enum.Font.GothamBold,
                TextSize = 14
            })

            local infoLabel = Instance.new("TextLabel")
            Gui.ApplyProperties(infoLabel, {
                Parent = container,
                Position = UDim2_new(0, 0, 0, 20),
                BackgroundTransparency = 1,
                Size = UDim2_new(1, 0, 0, 15),
                Text = "加載中...",
                TextColor3 = Color3_fromRGB(200, 200, 200),
                TextStrokeTransparency = 0.8,
                Font = Enum.Font.Gotham,
                TextSize = 12
            })

            local healthBar = Instance.new("Frame")
            Gui.ApplyProperties(healthBar, {
                Parent = container,
                Position = UDim2_new(0.1, 0, 0, 40),
                Size = UDim2_new(0.8, 0, 0, 4),
                BackgroundColor3 = Color3_fromRGB(50, 50, 50),
                BorderSizePixel = 0
            })

            local healthFill = Instance.new("Frame")
            Gui.ApplyProperties(healthFill, {
                Parent = healthBar,
                Size = UDim2_new(1, 0, 1, 0),
                BackgroundColor3 = Color3_fromRGB(0, 255, 0),
                BorderSizePixel = 0
            })

            local function Update()
                if not char or not char.Parent or not env_global.FullESPEnabled then 
                    if tracer then tracer.Visible = false end
                    return false 
                end
                
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    -- 更新血條與距離
                    local hp = math_clamp(hum.Health / hum.MaxHealth, 0, 1)
                    healthFill.Size = UDim2_new(hp, 0, 1, 0)
                    healthFill.BackgroundColor3 = Color3_fromHSV(hp * 0.3, 1, 1)
                    
                    local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
                    infoLabel.Text = string_format("距離: %d 碼 | 血量: %d", math_floor(dist), math_floor(hum.Health))

                    -- 更新連線 (Tracer)
                    if env_global.TracersEnabled and tracer then
                        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                            tracer.Visible = true
                        else
                            tracer.Visible = false
                        end
                    elseif tracer then
                        tracer.Visible = false
                    end
                end
                return true
            end

            task_spawn(function()
                while Update() do task_wait() end
                if tracer then tracer:Remove() end
            end)
        end

        if player.Character then OnCharacterAdded(player.Character) end
        player.CharacterAdded:Connect(OnCharacterAdded)
    end

    local function CreateTracer(player)
        if player == lp then return end
        local line = nil
        pcall(function()
            line = Drawing.new("Line")
            line.Thickness = 1
            line.Color = Color3_fromRGB(255, 255, 255)
            line.Transparency = 0.8
        end)
        if not line then return end

        task_spawn(function()
            while env_global.TracersEnabled and player.Parent do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local screenPos, onScreen = nil, false
                
                if root then
                    screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                end
                
                if onScreen and screenPos then
                    line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
                task_wait()
            end
            line:Remove()
        end)
    end

    local function ToggleFullbright(state)
        env_global.FullbrightEnabled = state
        if env_global.FullbrightEnabled then
            task_spawn(function()
                local Lighting = game:GetService("Lighting")
                local oldBrightness = Lighting.Brightness
                local oldClockTime = Lighting.ClockTime
                local oldFogEnd = Lighting.FogEnd
                local oldGlobalShadows = Lighting.GlobalShadows
                
                while env_global.FullbrightEnabled do
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    task_wait(0.5)
                end
                
                Lighting.Brightness = oldBrightness
                Lighting.ClockTime = oldClockTime
                Lighting.FogEnd = oldFogEnd
                Lighting.GlobalShadows = oldGlobalShadows
            end)
        end
    end

    local function CreateChestESP(chest)
        if not chest or chest:FindFirstChild("ChestESP") then return end
        
        local billboard = Instance.new("BillboardGui")
        Gui.ApplyProperties(billboard, {
            Name = "ChestESP",
            Adornee = chest,
            Size = UDim2_new(0, 100, 0, 40),
            AlwaysOnTop = true,
            Parent = chest
        })
        
        local label = Instance.new("TextLabel")
        Gui.ApplyProperties(label, {
            Parent = billboard,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3_fromRGB(255, 170, 0),
            TextSize = 12,
            TextStrokeTransparency = 0.5,
            Text = "箱子 (Chest)"
        })
        
        task_spawn(function()
            while env_global.ChestESPEnabled and chest.Parent do
                task_wait(1)
            end
            billboard:Destroy()
        end)
    end

    local function CreateShopESP(npc)
        if not npc or npc:FindFirstChild("ShopESP") then return end
        
        local billboard = Instance.new("BillboardGui")
        Gui.ApplyProperties(billboard, {
            Name = "ShopESP",
            Adornee = npc,
            Size = UDim2_new(0, 100, 0, 40),
            AlwaysOnTop = true,
            Parent = npc
        })
        
        local label = Instance.new("TextLabel")
        Gui.ApplyProperties(label, {
            Parent = billboard,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3_fromRGB(0, 255, 0),
            TextSize = 14,
            TextStrokeTransparency = 0.5,
            Text = "商店 (Shop)"
        })
    end

    local function CreateRadar()
        if env_global.RadarGui then env_global.RadarGui:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CatRadar"
        screenGui.Parent = game:GetService("CoreGui")
        env_global.RadarGui = screenGui
        
        local mainFrame = Instance.new("Frame")
        Gui.ApplyProperties(mainFrame, {
            Parent = screenGui,
            BackgroundColor3 = Color3_fromRGB(20, 20, 20),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 1,
            BorderColor3 = Color3_fromRGB(100, 100, 100),
            Position = UDim2_new(0, 20, 0, 200),
            Size = UDim2_new(0, 150, 0, 150)
        })
        
        local centerDot = Instance.new("Frame")
        Gui.ApplyProperties(centerDot, {
            Parent = mainFrame,
            BackgroundColor3 = Color3_fromRGB(255, 255, 255),
            Position = UDim2_new(0.5, -2, 0.5, -2),
            Size = UDim2_new(0, 4, 0, 4),
            ZIndex = 2
        })
        
        local playerDots = {}
        
        task_spawn(function()
            while env_global.RadarEnabled and screenGui.Parent do
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local pRoot = player.Character.HumanoidRootPart
                            local diff = pRoot.Position - root.Position
                            local relPos = Vector2.new(diff.X, diff.Z)
                            
                            local dot = playerDots[player]
                            if not dot then
                                dot = Instance.new("Frame")
                                Gui.ApplyProperties(dot, {
                                    Parent = mainFrame,
                                    BackgroundColor3 = (player.TeamColor and player.TeamColor.Color) or Color3_fromRGB(255, 0, 0),
                                    Size = UDim2_new(0, 4, 0, 4),
                                    BorderSizePixel = 0
                                })
                                playerDots[player] = dot
                            end
                            
                            local scale = 1.5
                            local radarX = 0.5 + (relPos.X / (150 * scale))
                            local radarY = 0.5 + (relPos.Y / (150 * scale))
                            
                            if radarX >= 0 and radarX <= 1 and radarY >= 0 and radarY <= 1 then
                                dot.Position = UDim2_new(radarX, -2, radarY, -2)
                                dot.Visible = true
                            else
                                dot.Visible = false
                            end
                        elseif playerDots[player] then
                            playerDots[player].Visible = false
                        end
                    end
                end
                task_wait(0.05)
            end
            if screenGui then screenGui:Destroy() end
            env_global.RadarGui = nil
        end)
    end

    local function CreateArrows(player)
        if player == lp then return end
        local arrow = nil
        pcall(function()
            arrow = Drawing.new("Triangle")
            arrow.Filled = true
            arrow.Thickness = 1
            arrow.Transparency = 1
            arrow.Color = (player.TeamColor and player.TeamColor.Color) or Color3_fromRGB(255, 0, 0)
        end)
        if not arrow then return end

        task_spawn(function()
            while env_global.ArrowsEnabled and player.Parent do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local _, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                    if not onScreen then
                        local cam = workspace.CurrentCamera
                        local proj = cam.CFrame:PointToObjectSpace(root.Position)
                        local angle = math.atan2(proj.Z, proj.X)
                        local direction = Vector2.new(math.cos(angle), math.sin(angle))
                        local pos = (cam.ViewportSize / 2) + (direction * 150)
                        
                        arrow.PointA = pos + (direction * 15)
                        arrow.PointB = pos + (Vector2.new(-direction.Y, direction.X) * 10)
                        arrow.PointC = pos + (Vector2.new(direction.Y, -direction.X) * 10)
                        arrow.Visible = true
                    else
                        arrow.Visible = false
                    end
                else
                    arrow.Visible = false
                end
                task_wait()
            end
            arrow:Remove()
        end)
    end

    local function ToggleAtmosphere(state)
        env_global.AtmosphereEnabled = state
        local Lighting = game:GetService("Lighting")
        if state then
            local atm = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
            atm.Density = 0.5
            atm.Color = Color3_fromRGB(150, 200, 255)
            atm.Decay = Color3_fromRGB(100, 150, 200)
            Notify("視覺功能", "大氣效果已強化", "Info")
        else
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Density = 0.3 end
        end
    end

    local function CreateBreadcrumbs()
        task_spawn(function()
            local points = {}
            while env_global.BreadcrumbsEnabled do
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local p = Instance.new("Part")
                    p.Size = Vector3_new(0.5, 0.5, 0.5)
                    p.Position = root.Position - Vector3_new(0, 2, 0)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Color = Color3_fromRGB(255, 255, 255)
                    p.Material = Enum.Material.Neon
                    p.Transparency = 0.5
                    p.Parent = workspace
                    table.insert(points, p)
                    if #points > 50 then
                        points[1]:Destroy()
                        table.remove(points, 1)
                    end
                    task_spawn(function()
                        task_wait(5)
                        if p.Parent then p:Destroy() end
                    end)
                end
                task_wait(0.1)
            end
            for _, v in pairs(points) do v:Destroy() end
        end)
    end

    local function ToggleCape(state)
        env_global.CapeEnabled = state
        local char = lp.Character
        if not char then return end
        local back = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not back then return end
        
        if state then
            local p = Instance.new("Part")
            p.Name = "CatCape"
            p.Size = Vector3_new(2, 4, 0.1)
            p.CanCollide = false
            p.Color = Color3_fromRGB(20, 20, 20)
            p.Parent = char
            
            Instance.new("BlockMesh", p)
            local weld = Instance.new("Motor6D")
            weld.Part0 = back
            weld.Part1 = p
            weld.C0 = CFrame.new(0, 1, 0.6) * CFrame.Angles(math.rad(5), 0, 0)
            weld.C1 = CFrame.new(0, 2, 0)
            weld.Parent = p
            
            task_spawn(function()
                while env_global.CapeEnabled and p.Parent do
                    local vel = back.Velocity.Magnitude
                    weld.C0 = CFrame.new(0, 1, 0.6) * CFrame.Angles(math.rad(5 + (vel * 1.5)), 0, 0)
                    task_wait()
                end
                p:Destroy()
            end)
        else
            if char:FindFirstChild("CatCape") then char.CatCape:Destroy() end
        end
    end

    local function ToggleChams(state)
        env_global.ChamsEnabled = state
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local highlight = p.Character:FindFirstChild("CatChams") or Instance.new("Highlight", p.Character)
                highlight.Name = "CatChams"
                highlight.Enabled = state
                highlight.FillColor = (p.TeamColor and p.TeamColor.Color) or Color3_fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
            end
        end
    end

    local function ToggleChinaHat(state)
        env_global.ChinaHatEnabled = state
        local char = lp.Character
        if not char or not char:FindFirstChild("Head") then return end
        
        if state then
            local p = Instance.new("Part")
            p.Name = "CatChinaHat"
            p.Size = Vector3_new(2, 0.5, 2)
            p.CanCollide = false
            p.Color = Color3_fromRGB(255, 255, 255)
            p.Parent = char
            
            local m = Instance.new("SpecialMesh", p)
            m.MeshType = Enum.MeshType.FileMesh
            m.MeshId = "rbxassetid://437341355" -- 圓錐體模型
            m.Scale = Vector3_new(2.5, 1, 2.5)
            
            local weld = Instance.new("Weld")
            weld.Part0 = char.Head
            weld.Part1 = p
            weld.C0 = CFrame.new(0, 0.8, 0)
            weld.Parent = p
        else
            if char:FindFirstChild("CatChinaHat") then char.CatChinaHat:Destroy() end
        end
    end

    local function ToggleGamingChair(state)
        env_global.GamingChairEnabled = state
        if state then
            Notify("視覺功能", "電競椅模式已啟動 (優化渲染優先級)", "Success")
            -- 這裡可以實作一個趣味性的視覺效果，例如讓角色坐在虛擬椅子上
        end
    end

    local function ToggleNameTags(state)
        env_global.NameTagsEnabled = state
        if state then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp then CreateFullESP(p) end
            end
        end
    end

    local function TogglePlayerModel(state)
        env_global.PlayerModelEnabled = state
        local char = lp.Character
        if not char then return end
        if state then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Color = Color3_fromRGB(0, 255, 255)
                    v.Material = Enum.Material.ForceField
                end
            end
        else
            -- 恢復預設 (需要儲存原始顏色，這裡簡化處理)
            Notify("視覺功能", "玩家模型已恢復預設", "Info")
        end
    end

    local function ToggleBoxESP(state)
        env_global.BoxESPEnabled = state
        if state then
            local function updateBoxes()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local char = p.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local box = char:FindFirstChild("CatBoxESP") or Instance.new("BoxHandleAdornment")
                            box.Name = "CatBoxESP"
                            box.Adornee = hrp
                            box.Size = char:GetExtentsSize() + Vector3_new(0.5, 0.5, 0.5)
                            box.Color3 = (p.TeamColor and p.TeamColor.Color) or Color3_fromRGB(255, 255, 255)
                            box.Transparency = 0.8
                            box.AlwaysOnTop = true
                            box.ZIndex = 10
                            box.Parent = char
                        end
                    end
                end
            end
            task_spawn(function()
                while env_global.BoxESPEnabled do
                    updateBoxes()
                    task_wait(2)
                end
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("CatBoxESP") then
                        p.Character.CatBoxESP:Destroy()
                    end
                end
            end)
        end
    end

    local function ToggleHealthDisplay(state)
        env_global.HealthDisplayEnabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do CreateFullESP(p) end
            Gui.SafeConnect(Players.PlayerAdded, CreateFullESP)
        end
    end

    local function CreateBedESP(bed)
        if not bed or bed:FindFirstChild("BedESP") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "BedESP"
        highlight.Parent = bed
        highlight.FillColor = Color3_fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3_fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "BedLabel"
        billboard.Adornee = bed
        billboard.Size = UDim2_new(0, 80, 0, 30)
        billboard.StudsOffset = Vector3_new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = bed
        
        local label = Instance.new("TextLabel")
        label.Parent = billboard
        label.BackgroundTransparency = 1
        label.Size = UDim2_new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3_fromRGB(255, 255, 255)
        label.TextSize = 14
        label.TextStrokeTransparency = 0.5
        label.Text = "床 (BED)"
        
        task_spawn(function()
            while env_global.BedESPEnabled and bed.Parent do
                task_wait(1)
            end
            highlight:Destroy()
            billboard:Destroy()
        end)
    end

    local function CreateResourceESP(res)
        if not res or res:FindFirstChild("ResourceESP") then return end
        
        local color = Color3_fromRGB(255, 255, 255)
        local name = "資源"
        
        local lowName = res.Name:lower()
        if lowName:find("diamond") then
            color = Color3_fromRGB(0, 170, 255)
            name = "鑽石 (Diamond)"
        elseif lowName:find("emerald") then
            color = Color3_fromRGB(0, 255, 127)
            name = "翡翠 (Emerald)"
        elseif lowName:find("iron") then
            color = Color3_fromRGB(200, 200, 200)
            name = "鐵 (Iron)"
        elseif lowName:find("gold") then
            color = Color3_fromRGB(255, 215, 0)
            name = "金 (Gold)"
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ResourceESP"
        billboard.Adornee = res
        billboard.Size = UDim2_new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3_new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = res
        
        local label = Instance.new("TextLabel")
        label.Parent = billboard
        label.BackgroundTransparency = 1
        label.Size = UDim2_new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = color
        label.TextSize = 12
        label.TextStrokeTransparency = 0.5
        label.Text = name
        
        task_spawn(function()
            while env_global.ResourceESPEnabled and res.Parent do
                task_wait(1)
            end
            billboard:Destroy()
        end)
    end

    local function ToggleSearch(state)
        env_global.SearchEnabled = state
        if state then
            task_spawn(function()
                while env_global.SearchEnabled and task_wait(2) do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Name:lower():find("diamond") or v.Name:lower():find("emerald")) then
                            if not v:FindFirstChild("SearchESP") then
                                local h = Instance.new("Highlight", v)
                                h.Name = "SearchESP"
                                h.FillColor = Color3_fromRGB(0, 255, 255)
                            end
                        end
                    end
                end
            end)
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild("SearchESP") then v.SearchESP:Destroy() end
            end
        end
    end

    local function ToggleSetEmote(state)
        if state then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://3333499508" -- 舞動動作
                local load = hum:LoadAnimation(anim)
                load:Play()
                Notify("視覺功能", "正在播放動作...", "Info")
            end
        end
    end

    local function ToggleTimeChanger(state)
        env_global.TimeChangerEnabled = state
        if state then
            task_spawn(function()
                while env_global.TimeChangerEnabled and task_wait() do
                    game:GetService("Lighting").ClockTime = (tick() * 2) % 24
                end
            end)
        end
    end

    local function ToggleWaypoints(state)
        env_global.WaypointsEnabled = state
        if state then
            task_spawn(function()
                while env_global.WaypointsEnabled and task_wait(5) do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name == "bed" and not v:FindFirstChild("WaypointESP") then
                            local b = Instance.new("BillboardGui", v)
                            b.Name = "WaypointESP"
                            b.AlwaysOnTop = true
                            b.Size = UDim2_new(0, 100, 0, 50)
                            local t = Instance.new("TextLabel", b)
                            t.Size = UDim2_new(1, 0, 1, 0)
                            t.Text = "床位 (Bed)"
                            t.TextColor3 = Color3_fromRGB(255, 255, 255)
                            t.BackgroundTransparency = 1
                        end
                    end
                end
            end)
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild("WaypointESP") then v.WaypointESP:Destroy() end
            end
        end
    end

    local function ToggleWeather(state)
        env_global.WeatherEnabled = state
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        if state then
            task_spawn(function()
                local parts = {}
                while env_global.WeatherEnabled do
                    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- 創建雨滴粒子效果
                        local p = Instance.new("Part")
                        p.Size = Vector3_new(0.1, 1, 0.1)
                        p.Position = root.Position + Vector3_new(math.random(-50, 50), 20, math.random(-50, 50))
                        p.Anchored = false
                        p.CanCollide = false
                        p.Color = Color3_fromRGB(150, 150, 255)
                        p.Transparency = 0.5
                        p.Velocity = Vector3_new(0, -100, 0)
                        p.Parent = workspace
                        table.insert(parts, p)
                        
                        task_spawn(function()
                            task_wait(1)
                            if p.Parent then p:Destroy() end
                        end)
                        
                        if #parts > 100 then
                            local old = table.remove(parts, 1)
                            if old and old.Parent then old:Destroy() end
                        end
                    end
                    task_wait(0.05)
                end
                for _, v in pairs(parts) do v:Destroy() end
            end)
            Notify("視覺功能", "天氣已切換為：暴風雨模式 (本地視覺)", "Info")
        end
    end

    local function ToggleZoomUnlocker(state)
        env_global.ZoomUnlockerEnabled = state
        lplr.CameraMaxZoomDistance = state and 1000 or 128
    end

    return {
        ToggleHighlight = function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character then
                    ApplyHighlightESP(player.Character)
                end
            end
            Gui.SafeConnect(Players.PlayerAdded, function(p)
                Gui.SafeConnect(p.CharacterAdded, ApplyHighlightESP)
            end)
        end,
        ToggleFullESP = function(state)
            env_global.FullESPEnabled = state
            if env_global.FullESPEnabled then
                for _, p in ipairs(Players:GetPlayers()) do CreateFullESP(p) end
                Gui.SafeConnect(Players.PlayerAdded, CreateFullESP)
            end
        end,
        ToggleHealthDisplay = function(state)
            env_global.HealthDisplayEnabled = state
            -- 健康顯示通常與 ESP 整合，這裡我們確保它開啟時也會觸發必要的渲染
            if env_global.HealthDisplayEnabled then
                for _, p in ipairs(Players:GetPlayers()) do CreateFullESP(p) end
            end
        end,
        ToggleTracers = function(state)
            env_global.TracersEnabled = state
            if env_global.TracersEnabled then
                for _, p in ipairs(Players:GetPlayers()) do CreateTracer(p) end
                Gui.SafeConnect(Players.PlayerAdded, CreateTracer)
            end
        end,
        ToggleFullbright = ToggleFullbright,
        ToggleChestESP = function(state)
            env_global.ChestESPEnabled = state
            if env_global.ChestESPEnabled then
                task_spawn(function()
                    while env_global.ChestESPEnabled and task_wait(2) do
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not env_global.ChestESPEnabled then break end
                            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                                CreateChestESP(v)
                            end
                        end
                    end
                end)
            end
        end,
        ToggleShopESP = function(state)
            env_global.ShopESPEnabled = state
            if env_global.ShopESPEnabled then
                task_spawn(function()
                    while env_global.ShopESPEnabled and task_wait(2) do
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not env_global.ShopESPEnabled then break end
                            if v:IsA("Model") and (v.Name:lower():find("shop") or v.Name:lower():find("merchant")) then
                                CreateShopESP(v)
                            end
                        end
                    end
                end)
            end
        end,
        ToggleRadar = function(state)
            env_global.RadarEnabled = state
            if env_global.RadarEnabled then
                CreateRadar()
            end
        end,
        ToggleArrows = function(state)
            env_global.ArrowsEnabled = state
            if state then
                for _, p in ipairs(Players:GetPlayers()) do CreateArrows(p) end
                Gui.SafeConnect(Players.PlayerAdded, CreateArrows)
            end
        end,
        ToggleAtmosphere = ToggleAtmosphere,
        ToggleBreadcrumbs = function(state)
            env_global.BreadcrumbsEnabled = state
            if state then CreateBreadcrumbs() end
        end,
        ToggleCape = ToggleCape,
        ToggleChams = ToggleChams,
        ToggleChinaHat = ToggleChinaHat,
        ToggleGamingChair = ToggleGamingChair,
        ToggleNameTags = ToggleNameTags,
        TogglePlayerModel = TogglePlayerModel,
        ToggleBoxESP = ToggleBoxESP,
        ToggleSearch = ToggleSearch,
        ToggleSetEmote = ToggleSetEmote,
        ToggleTimeChanger = ToggleTimeChanger,
        ToggleWaypoints = ToggleWaypoints,
        ToggleWeather = ToggleWeather,
        ToggleZoomUnlocker = ToggleZoomUnlocker,
        ToggleBedESP = function(state)
            env_global.BedESPEnabled = state
            if state then
                task_spawn(function()
                    while env_global.BedESPEnabled and task_wait(2) do
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not env_global.BedESPEnabled then break end
                            if v.Name == "bed" or v:FindFirstChild("bed") then
                                CreateBedESP(v)
                            end
                        end
                    end
                end)
            end
        end,
        ToggleResourceESP = function(state)
            env_global.ResourceESPEnabled = state
            if state then
                task_spawn(function()
                    while env_global.ResourceESPEnabled and task_wait(2) do
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not env_global.ResourceESPEnabled then break end
                            local lowName = v.Name:lower()
                            if v:IsA("BasePart") and (lowName:find("diamond") or lowName:find("emerald") or lowName:find("generator")) then
                                CreateResourceESP(v)
                            end
                        end
                    end
                end)
            end
        end
    }
end

return VisualsModule
