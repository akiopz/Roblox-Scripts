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
    
    -- 科幻裝飾元素
    local BgPattern = Instance.new("ImageLabel")
    local GlowEffect = Instance.new("ImageLabel")
    local ScanLine = Instance.new("Frame")

    ApplyProperties(ScreenGui, {
        Name = RandomString(math.random(10, 20)),
        Parent = (getgenv().gethui and getgenv().gethui()) or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999
    })

    -- 收起/展開切換按鈕 (浮窗)
    ApplyProperties(ToggleButton, {
        Name = "ToggleButton",
        Parent = ScreenGui,
        BackgroundColor3 = Color3_fromRGB(10, 10, 20),
        Position = UDim2_new(0, 20, 0.5, -20), -- 預設靠左中間
        Size = UDim2_new(0, 50, 0, 50),
        Font = Enum.Font.GothamBold,
        Text = "", 
        ZIndex = 100,
        Visible = true
    })

    -- 自定義科技圖標容器
    local IconContainer = Instance.new("Frame")
    ApplyProperties(IconContainer, {
        Name = "IconContainer",
        Parent = ToggleButton,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.5, -15, 0.5, -15),
        Size = UDim2_new(0, 30, 0, 30),
        ZIndex = 101
    })

    -- 繪製科技感「H」或「Cat」圖標
    local function CreateTechIcon(parent)
        -- 左側柱
        local LeftBar = Instance.new("Frame")
        local LBCorner = Instance.new("UICorner")
        ApplyProperties(LeftBar, {
            Name = "LeftBar",
            Parent = parent,
            BackgroundColor3 = Color3_fromRGB(0, 255, 255),
            Position = UDim2_new(0.1, 0, 0.2, 0),
            Size = UDim2_new(0.15, 0, 0.6, 0),
            ZIndex = 102
        })
        LBCorner.CornerRadius = UDim.new(1, 0)
        LBCorner.Parent = LeftBar

        -- 右側柱
        local RightBar = Instance.new("Frame")
        local RBCorner = Instance.new("UICorner")
        ApplyProperties(RightBar, {
            Name = "RightBar",
            Parent = parent,
            BackgroundColor3 = Color3_fromRGB(0, 255, 255),
            Position = UDim2_new(0.75, 0, 0.2, 0),
            Size = UDim2_new(0.15, 0, 0.6, 0),
            ZIndex = 102
        })
        RBCorner.CornerRadius = UDim.new(1, 0)
        RBCorner.Parent = RightBar

        -- 中間橫桿 (閃爍)
        local MidBar = Instance.new("Frame")
        local MBCorner = Instance.new("UICorner")
        ApplyProperties(MidBar, {
            Name = "MidBar",
            Parent = parent,
            BackgroundColor3 = Color3_fromRGB(0, 255, 255),
            Position = UDim2_new(0.25, 0, 0.45, 0),
            Size = UDim2_new(0.5, 0, 0.1, 0),
            ZIndex = 102
        })
        MBCorner.CornerRadius = UDim.new(1, 0)
        MBCorner.Parent = MidBar

        -- 裝飾點
        local Dot = Instance.new("Frame")
        local DotCorner = Instance.new("UICorner")
        ApplyProperties(Dot, {
            Name = "Dot",
            Parent = parent,
            BackgroundColor3 = Color3_fromRGB(255, 255, 255),
            Position = UDim2_new(0.425, 0, 0.1, 0),
            Size = UDim2_new(0.15, 0, 0.15, 0),
            ZIndex = 103
        })
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = Dot

        return {LeftBar, RightBar, MidBar, Dot}
    end

    local IconParts = CreateTechIcon(IconContainer)

    -- 科幻裝飾圈
    local OrbitFrame = Instance.new("Frame")
    ApplyProperties(OrbitFrame, {
        Name = "OrbitFrame",
        Parent = ToggleButton,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.5, 0, 0.5, 0),
        Size = UDim2_new(0, 0, 0, 0),
        ZIndex = 99
    })

    local OrbitImage = Instance.new("ImageLabel")
    ApplyProperties(OrbitImage, {
        Name = "OrbitImage",
        Parent = OrbitFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, -35, 0, -35),
        Size = UDim2_new(0, 70, 0, 70),
        Image = "rbxassetid://6031094630", -- 圓形旋轉裝飾
        ImageColor3 = Color3_fromRGB(0, 150, 255),
        ImageTransparency = 0.5,
        ZIndex = 98
    })

    -- 旋轉動畫
    task_spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if ToggleButton.Visible then
                OrbitImage.Rotation = OrbitImage.Rotation + 2
            end
            task.wait(0.01)
        end
    end)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12) -- 圓角矩形更具科技感
    ToggleCorner.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ApplyProperties(ToggleStroke, {
        Color = Color3_fromRGB(0, 150, 255),
        Thickness = 2,
        Parent = ToggleButton
    })

    -- 呼吸效果與動態圖標動畫
    task_spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if ToggleButton.Visible then
                local tickTime = tick()
                local transparency = 0.4 + (math.sin(tickTime * 2) * 0.2)
                local glowScale = 1 + (math.sin(tickTime * 4) * 0.1)
                
                ToggleStroke.Transparency = transparency
                
                -- 圖標動態效果
                for i, part in ipairs(IconParts) do
                    part.BackgroundTransparency = transparency - 0.2
                    if part.Name == "MidBar" then
                        part.Size = UDim2_new(0.5, 0, 0.1 * glowScale, 0)
                    end
                end
                
                task.wait(0.05)
            end
            task.wait(0.1)
        end
    end)

    ApplyProperties(MainFrame, {
        Name = RandomString(math.random(10, 20)),
        Parent = ScreenGui,
        BackgroundColor3 = Color3_fromRGB(10, 10, 20),
        Position = UDim2_new(0.5, -300, 0.5, -200),
        Size = UDim2_new(0, 600, 0, 400),
        ClipsDescendants = false,
        Active = true,
        Selectable = true,
        ZIndex = 5
    })

    -- 切換功能實作
    local function ToggleGui()
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.Visible = not MainFrame.Visible
    end

    -- 綁定快捷鍵切換 (預設為 RightShift)
    SafeConnect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            ToggleGui()
        end
    end)

    -- 點擊切換按鈕展開
    SafeConnect(ToggleButton.MouseButton1Click, ToggleGui)

    -- 手動實現拖動功能 (替代已過時的 Draggable)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    SafeConnect(MainFrame.InputBegan, function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
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
            update(input)
        end
    end)

    -- 切換按鈕拖動功能
    local t_dragging, t_dragInput, t_dragStart, t_startPos
    SafeConnect(ToggleButton.InputBegan, function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            t_dragging = true
            t_dragStart = input.Position
            t_startPos = ToggleButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then t_dragging = false end
            end)
        end
    end)
    SafeConnect(UserInputService.InputChanged, function(input)
        if t_dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - t_dragStart
            ToggleButton.Position = UDim2_new(t_startPos.X.Scale, t_startPos.X.Offset + delta.X, t_startPos.Y.Scale, t_startPos.Y.Offset + delta.Y)
        end
    end)

    -- 背景網格裝飾
    ApplyProperties(BgPattern, {
        Name = "BgPattern",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 1, 0),
        Image = "rbxassetid://215157333", -- 網格紋理
        ImageColor3 = Color3_fromRGB(100, 100, 255),
        ImageTransparency = 0.9,
        TileSize = UDim2_new(0, 64, 0, 64),
        ZIndex = 0,
        Active = false -- 禁止攔截點擊
    })

    -- 外發光霓虹效果
    ApplyProperties(GlowEffect, {
        Name = "GlowEffect",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, -20, 0, -20),
        Size = UDim2_new(1, 40, 1, 40),
        Image = "rbxassetid://5028857084", -- 柔和發光
        ImageColor3 = Color3_fromRGB(0, 150, 255),
        ImageTransparency = 0.6,
        ZIndex = -1,
        Active = false -- 禁止攔截點擊
    })

    -- 動態掃描線
    ApplyProperties(ScanLine, {
        Name = "ScanLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 0, 1),
        ZIndex = 5,
        Active = false -- 禁止攔截點擊
    })

    MainCorner.CornerRadius = UDim.new(0, 5) -- 更硬朗的圓角
    MainCorner.Parent = MainFrame

    ApplyProperties(RGBLine, {
        Name = "RGBLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 0, 2),
        ZIndex = 10,
        Active = false -- 禁止攔截點擊
    })

    ApplyProperties(Title, {
        Name = "Title",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 20, 0, 15),
        Size = UDim2_new(0, 120, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "HALOL",
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    ApplyProperties(SubTitle, {
        Name = "SubTitle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 105, 0, 22),
        Size = UDim2_new(0, 100, 0, 20),
        Font = Enum.Font.Code, -- 改用程式碼字體更有科幻感
        Text = "V4.8 // SYSTEM_ACTIVE",
        TextColor3 = Color3_fromRGB(0, 255, 255),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    ApplyProperties(TabContainer, {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 10, 0, 60),
        Size = UDim2_new(0, 150, 1, -70),
        CanvasSize = UDim2_new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ZIndex = 10
    })

    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 8)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    ApplyProperties(ContentContainer, {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(15, 15, 25),
        Position = UDim2_new(0, 170, 0, 60),
        Size = UDim2_new(1, -180, 1, -70),
        ZIndex = 10
    })

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 4)
    ContentCorner.Parent = ContentContainer

    -- 為內容容器添加細微邊框
    local ContentStroke = Instance.new("UIStroke")
    ApplyProperties(ContentStroke, {
        Color = Color3_fromRGB(40, 40, 60),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = ContentContainer
    })

    ApplyProperties(CloseButton, {
        Name = "CloseButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.94, 0, 0, 8), -- 調整位置使其更對齊
        Size = UDim2_new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3_fromRGB(255, 50, 50),
        TextSize = 24,
        ZIndex = 11 -- 確保在最上層
    })

    -- 收起按鈕 (在關閉按鈕旁邊)
    local HideButton = Instance.new("TextButton")
    ApplyProperties(HideButton, {
        Name = "HideButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.88, 0, 0, 8),
        Size = UDim2_new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Color3_fromRGB(200, 200, 200),
        TextSize = 24,
        ZIndex = 11
    })
    
    SafeConnect(HideButton.MouseButton1Click, ToggleGui)

    -- 綁定關閉事件
    SafeConnect(CloseButton.MouseButton1Click, function()
        -- 執行清理回調 (如果存在)
        -- 注意：HalolUnload 會處理功能關閉，我們這裡處理 GUI 銷毀動畫
        if getgenv().HalolUnload then
            getgenv().HalolUnload(true) -- 傳入 true 表示是由 GUI 觸發，延後銷毀 GUI
        end
        
        -- 加入淡出動畫後銷毀
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

    -- 加入滑鼠懸停效果
    SafeConnect(CloseButton.MouseEnter, function()
        CloseButton.TextColor3 = Color3_fromRGB(255, 100, 100)
    end)
    SafeConnect(CloseButton.MouseLeave, function()
        CloseButton.TextColor3 = Color3_fromRGB(255, 50, 50)
    end)
    
    SafeConnect(HideButton.MouseEnter, function()
        HideButton.TextColor3 = Color3_fromRGB(255, 255, 255)
    end)
    SafeConnect(HideButton.MouseLeave, function()
        HideButton.TextColor3 = Color3_fromRGB(200, 200, 200)
    end)

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

        -- 動態掃描線與背景動畫
        task_spawn(function()
            local scanPos = 0
            while ScreenGui and ScreenGui.Parent do
                if MainFrame.Visible then
                    scanPos = (scanPos + 2) % 400
                    ScanLine.Position = UDim2_new(0, 0, 0, scanPos)
                    
                    -- 背景網格緩慢漂移
                    BgPattern.Position = UDim2_new(0, math.sin(tick()) * 5, 0, math.cos(tick()) * 5)
                end
                task_wait(0.03)
            end
        end)

        -- 優化 RGB 動畫更新頻率
        while ScreenGui and ScreenGui.Parent do
            hue = (hue + 1) % 360
            local color1 = Color3_fromHSV(hue / 360, 0.7, 1)
            local color2 = Color3_fromHSV(((hue + 60) % 360) / 360, 0.7, 1)
            
            local sequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color1),
                ColorSequenceKeypoint.new(1, color2)
            })
            
            UIGradient.Color = sequence
            StrokeGradient.Color = sequence
            GlowEffect.ImageColor3 = color1
            ToggleStroke.Color = color1
            
            -- 文字與霓虹效果同步
            Title.TextColor3 = color1
            SubTitle.TextColor3 = color2
            LogoImage.ImageColor3 = color1
            ToggleButton.TextColor3 = color1
            
            if not MainFrame.Visible and not ToggleButton.Visible then
                while not MainFrame.Visible and not ToggleButton.Visible and ScreenGui and ScreenGui.Parent do
                    task.wait(0.5)
                end
            end
            
            task_wait(0.05)
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
