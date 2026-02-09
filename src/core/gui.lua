---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local game = game or getgenv().game
local Color3 = Color3 or getgenv().Color3
local UDim2 = UDim2 or getgenv().UDim2
local UDim = UDim or getgenv().UDim
local Vector3 = Vector3 or getgenv().Vector3
local task = task or getgenv().task
local Instance = Instance or getgenv().Instance
local Enum = Enum or getgenv().Enum
local ColorSequence = ColorSequence or getgenv().ColorSequence
local ColorSequenceKeypoint = ColorSequenceKeypoint or getgenv().ColorSequenceKeypoint
local pairs = pairs or getgenv().pairs
local ipairs = ipairs or getgenv().ipairs
local pcall = pcall or getgenv().pcall
local gethui = (getgenv().gethui or function() return game:GetService("CoreGui") end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local UDim2_new = UDim2.new
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local GuiModule = {}

function GuiModule.ApplyProperties(instance, props)
    for k, v in pairs(props) do
        instance[k] = v
    end
    return instance
end

local function SafeConnect(signal, callback)
    local success, conn = pcall(function()
        return signal:Connect(callback)
    end)
    if success then return conn end
    return nil
end

local function RandomString(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = ""
    for i = 1, len do
        local rand = math.random(1, #chars)
        res = res .. chars:sub(rand, rand)
    end
    return res
end

function GuiModule.CreateMainGui()
    local ApplyProperties = GuiModule.ApplyProperties
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local RGBLine = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local SubTitle = Instance.new("TextLabel")
    local TabContainer = Instance.new("ScrollingFrame")
    local TabList = Instance.new("UIListLayout")
    local ContentContainer = Instance.new("Frame")
    local CloseButton = Instance.new("TextButton")
    local ToggleButton = Instance.new("TextButton")
    
    -- 現代裝飾元素
    local GlowEffect = Instance.new("ImageLabel")
    local SidebarBg = Instance.new("Frame")
    local SidebarCorner = Instance.new("UICorner")

    ApplyProperties(ScreenGui, {
        Name = RandomString(math.random(10, 20)),
        Parent = (getgenv().gethui and getgenv().gethui()) or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999
    })

    -- 收起/展開切換按鈕
    ApplyProperties(ToggleButton, {
        Name = "ToggleButton",
        Parent = ScreenGui,
        BackgroundColor3 = Color3_fromRGB(10, 10, 15),
        Position = UDim2_new(0, 30, 0.5, -25),
        Size = UDim2_new(0, 45, 0, 45),
        Font = Enum.Font.GothamBold,
        Text = "", 
        ZIndex = 100,
        Visible = true,
        BackgroundTransparency = 0.1
    })
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ApplyProperties(ToggleStroke, {
        Color = Color3_fromRGB(0, 150, 255),
        Thickness = 1.5,
        Parent = ToggleButton
    })

    local IconLabel = Instance.new("TextLabel")
    ApplyProperties(IconLabel, {
        Name = "IconLabel",
        Parent = ToggleButton,
        BackgroundTransparency = 1,
        Size = UDim2_new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "V4",
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextSize = 18,
        ZIndex = 101
    })

    ApplyProperties(MainFrame, {
        Name = RandomString(math.random(10, 20)),
        Parent = ScreenGui,
        BackgroundColor3 = Color3_fromRGB(10, 10, 12),
        Position = UDim2_new(0.5, -280, 0.5, -180),
        Size = UDim2_new(0, 560, 0, 360),
        ClipsDescendants = false,
        Active = true,
        Selectable = true,
        ZIndex = 5,
        BackgroundTransparency = 0.02,
        Visible = false
    })

    local function ToggleGui()
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.Visible = not MainFrame.Visible
    end

    SafeConnect(ToggleButton.MouseButton1Click, ToggleGui)
    SafeConnect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            ToggleGui()
        end
    end)

    -- 拖動功能
    local function EnableDragging(frame, dragHandle)
        local dragging, dragInput, dragStart, startPos
        SafeConnect(dragHandle.InputBegan, function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        SafeConnect(UserInputService.InputChanged, function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    EnableDragging(MainFrame, MainFrame)
    EnableDragging(ToggleButton, ToggleButton)

    ApplyProperties(SidebarBg, {
        Name = "SidebarBg",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(13, 13, 16),
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(0, 150, 1, 0),
        BackgroundTransparency = 0,
        ZIndex = 6
    })
    
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = SidebarBg

    local SidebarLine = Instance.new("Frame")
    ApplyProperties(SidebarLine, {
        Name = "SidebarLine",
        Parent = SidebarBg,
        BackgroundColor3 = Color3_fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        Position = UDim2_new(1, -1, 0, 10),
        Size = UDim2_new(0, 1, 1, -20),
        ZIndex = 7
    })

    ApplyProperties(GlowEffect, {
        Name = "GlowEffect",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, -20, 0, -20),
        Size = UDim2_new(1, 40, 1, 40),
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3_fromRGB(0, 150, 255),
        ImageTransparency = 0.8,
        ZIndex = -1,
        Active = false
    })

    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    ApplyProperties(RGBLine, {
        Name = "RGBLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 150, 0, 0),
        Size = UDim2_new(1, -150, 0, 1),
        ZIndex = 10,
        Active = false,
        BackgroundTransparency = 0.2
    })

    ApplyProperties(Title, {
        Name = "Title",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 20, 0, 20),
        Size = UDim2_new(0, 110, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "CAT V4",
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    ApplyProperties(SubTitle, {
        Name = "SubTitle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 20, 0, 42),
        Size = UDim2_new(0, 110, 0, 12),
        Font = Enum.Font.Gotham,
        Text = "STABLE BUILD",
        TextColor3 = Color3_fromRGB(120, 120, 130),
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    ApplyProperties(TabContainer, {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 10, 0, 75),
        Size = UDim2_new(0, 130, 1, -85),
        CanvasSize = UDim2_new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ZIndex = 10
    })

    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 4)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    ApplyProperties(ContentContainer, {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(15, 15, 18),
        Position = UDim2_new(0, 160, 0, 20),
        Size = UDim2_new(1, -175, 1, -35),
        ZIndex = 10,
        BackgroundTransparency = 0.5
    })

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer

    local ContentStroke = Instance.new("UIStroke")
    ApplyProperties(ContentStroke, {
        Color = Color3_fromRGB(30, 30, 35),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = ContentContainer
    })

    ApplyProperties(CloseButton, {
        Name = "CloseButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(1, -30, 0, 8),
        Size = UDim2_new(0, 22, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3_fromRGB(200, 200, 200),
        TextSize = 20,
        ZIndex = 11
    })

    local HideButton = Instance.new("TextButton")
    ApplyProperties(HideButton, {
        Name = "HideButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(1, -55, 0, 8),
        Size = UDim2_new(0, 22, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = Color3_fromRGB(200, 200, 200),
        TextSize = 18,
        ZIndex = 11
    })
    
    SafeConnect(HideButton.MouseButton1Click, ToggleGui)

    SafeConnect(CloseButton.MouseButton1Click, function()
        if getgenv().HalolUnload then
            getgenv().HalolUnload(true)
        end
        task.spawn(function()
            for i = 0, 1, 0.1 do
                if not MainFrame or not ScreenGui or not ScreenGui.Parent then break end
                MainFrame.BackgroundTransparency = 0.05 + (i * 0.95)
                for _, child in pairs(MainFrame:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        pcall(function() child.Transparency = child.Transparency + (i * (1 - child.Transparency)) end)
                    end
                end
                task.wait(0.01)
            end
            if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
        end)
    end)

    -- RGB 循環邏輯 (優化版本：預計算序列與減少屬性更新)
    task_spawn(function()
        local hue = 0
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Parent = RGBLine
        
        local MainStroke = Instance.new("UIStroke")
        ApplyProperties(MainStroke, {
            Color = Color3_fromRGB(255, 255, 255),
            Thickness = 1.2,
            Transparency = 0.4,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = MainFrame
        })
        
        local StrokeGradient = Instance.new("UIGradient")
        StrokeGradient.Parent = MainStroke

        -- 緩存序列以減少每幀對象創建 (如果顏色變化不頻繁，甚至可以預生成一組序列)
        while ScreenGui and ScreenGui.Parent do
            if MainFrame.Visible or ToggleButton.Visible then
                hue = (hue + 1) % 360
                local color1 = Color3_fromHSV(hue / 360, 0.7, 1)
                local color2 = Color3_fromHSV(((hue + 60) % 360) / 360, 0.7, 1)
                
                local sequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, color1),
                    ColorSequenceKeypoint.new(1, color2)
                })
                
                -- 批量更新屬性
                UIGradient.Color = sequence
                StrokeGradient.Color = sequence
                GlowEffect.ImageColor3 = color1
                ToggleStroke.Color = color1
                
                Title.TextColor3 = color1
                IconLabel.TextColor3 = color1
                SidebarLine.BackgroundColor3 = color1
                
                -- ToggleButton 呼吸效果 (僅在可見時更新)
                if ToggleButton.Visible then
                    ToggleStroke.Transparency = 0.3 + (math.sin(tick() * 2) * 0.2)
                end
            end
            
            task_wait(0.05) -- 保持 20 FPS 的 UI 更新頻率，足以保證流暢且不耗資源
        end
    end)

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ToggleButton = ToggleButton,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        CloseButton = CloseButton,
        ApplyProperties = GuiModule.ApplyProperties,
        SafeConnect = SafeConnect
    }
end

return GuiModule
