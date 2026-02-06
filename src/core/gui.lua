-- Halol (V4.0) GUI 模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
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

-- 輔助函數：屬性賦值
local function ApplyProperties(instance, props)
    for k, v in pairs(props) do
        instance[k] = v
    end
    return instance
end

-- 輔助函數：安全連接
local function SafeConnect(signal, callback)
    local success, conn = pcall(function()
        return signal:Connect(callback)
    end)
    if success then return conn end
    return nil
end

function GuiModule.CreateMainGui()
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

    -- ScreenGui 設置
    ApplyProperties(ScreenGui, {
        Name = "HalolV4",
        Parent = (gethui and gethui()) or CoreGui,
        ResetOnSpawn = false,
        DisplayOrder = 9999
    })

    -- 主框架
    ApplyProperties(MainFrame, {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3_fromRGB(18, 18, 18),
        Position = UDim2_new(0.5, -300, 0.5, -200),
        Size = UDim2_new(0, 600, 0, 400),
        ClipsDescendants = true,
        Active = true,
        Draggable = true
    })

    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- RGB 線
    ApplyProperties(RGBLine, {
        Name = "RGBLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 0, 2)
    })

    -- 標題
    ApplyProperties(Title, {
        Name = "Title",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 20, 0, 15),
        Size = UDim2_new(0, 120, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "HALOL",
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    ApplyProperties(SubTitle, {
        Name = "SubTitle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 100, 0, 22),
        Size = UDim2_new(0, 100, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = "V4.0",
        TextColor3 = Color3_fromRGB(180, 180, 180),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- 分頁容器
    ApplyProperties(TabContainer, {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 10, 0, 60),
        Size = UDim2_new(0, 150, 1, -70),
        CanvasSize = UDim2_new(0, 0, 0, 0),
        ScrollBarThickness = 0
    })

    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- 內容容器
    ApplyProperties(ContentContainer, {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(24, 24, 24),
        Position = UDim2_new(0, 170, 0, 60),
        Size = UDim2_new(1, -180, 1, -70)
    })

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer

    -- 關閉按鈕
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

    -- RGB 循環
    task_spawn(function()
        local hue = 0
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Parent = RGBLine
        
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
            Title.TextColor3 = color1
            SubTitle.TextColor3 = color2
            task_wait(0.05)
        end
    end)

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        CloseButton = CloseButton,
        ApplyProperties = ApplyProperties,
        SafeConnect = SafeConnect
    }
end

return GuiModule
