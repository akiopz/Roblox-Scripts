---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local Color3 = Color3 or getgenv().Color3
local UDim2 = UDim2 or getgenv().UDim2
local UDim = UDim or getgenv().UDim
local Enum = Enum or getgenv().Enum
local Instance = Instance or getgenv().Instance
local task = task or getgenv().task
local pairs = pairs or getgenv().pairs
local pcall = pcall or getgenv().pcall

local Color3_fromRGB = Color3.fromRGB
local UDim2_new = UDim2.new
local Enum_Font = Enum.Font

local GuiUtils = {}

function GuiUtils.Init(Gui)
    local Tabs = {}
    local ScriptStates = {}
    local Keybinds = {}
    
    -- 加載保存的設置
    if Gui.env and Gui.env.LoadSettings then
        local saved = Gui.env.LoadSettings("CatV4_Settings") or {}
        ScriptStates = saved.States or {}
        Keybinds = saved.Keybinds or {}
    end
    
    function GuiUtils.CreateTab(name)
        local TabButton = Instance.new("TextButton")
        local TBCorner = Instance.new("UICorner")
        local Page = Instance.new("ScrollingFrame")
        local PageList = Instance.new("UIListLayout")
        local TabStroke = Instance.new("UIStroke")

        Gui.ApplyProperties(TabButton, {
            Name = name .. "Button",
            Parent = Gui.TabContainer,
            BackgroundColor3 = Color3_fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 30),
            Font = Enum_Font.GothamBold,
            Text = name,
            TextColor3 = Color3_fromRGB(160, 160, 170),
            TextSize = 12,
            ZIndex = 15,
            Active = true
        })
        
        Gui.ApplyProperties(TabStroke, {
            Color = Color3_fromRGB(255, 255, 255),
            Thickness = 1,
            Transparency = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = TabButton
        })
        
        TBCorner.CornerRadius = UDim.new(0, 6)
        TBCorner.Parent = TabButton
        
        Gui.ApplyProperties(Page, {
            Name = name .. "Page",
            Parent = Gui.ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 0,
            CanvasSize = UDim2_new(0, 0, 0, 0)
        })
        
        PageList.Parent = Page
        PageList.Padding = UDim.new(0, 5)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local function Switch()
            if Page.Visible then return end

            for _, t in pairs(Tabs) do
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = Color3_fromRGB(160, 160, 170)
                local s = t.Button:FindFirstChildOfClass("UIStroke")
                if s then s.Transparency = 1 end
                t.Page.Visible = false
            end
            
            TabButton.BackgroundTransparency = 0.92
            TabButton.TextColor3 = Color3_fromRGB(255, 255, 255)
            local stroke = TabButton:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = 0.85 end
            
            Page.Visible = true
        end
        
        Gui.SafeConnect(TabButton.MouseButton1Click, Switch)
        
        Gui.SafeConnect(PageList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Page.CanvasSize = UDim2_new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
        
        local isFirst = true
        for _ in pairs(Tabs) do isFirst = false break end
        Page.Visible = isFirst
        
        if isFirst then
            TabButton.BackgroundTransparency = 0.92
            TabButton.TextColor3 = Color3_fromRGB(255, 255, 255)
            local stroke = TabButton:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = 0.85 end
        end

        Tabs[name] = {Button = TabButton, Page = Page, List = PageList, Switch = Switch}
        return Tabs[name]
    end

    function GuiUtils.AddScript(tabName, name, desc, loadFunc, Notify, defaultState)
        local targetTab = Tabs[tabName]
        if not targetTab then return end
        
        local container = targetTab.Page
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        local BStroke = Instance.new("UIStroke")
        local TitleLabel = Instance.new("TextLabel")
        local DescLabel = Instance.new("TextLabel")
        local StatusLight = Instance.new("Frame")
        
        Gui.ApplyProperties(Button, {
            Name = name,
            Parent = container,
            BackgroundColor3 = Color3_fromRGB(20, 20, 25),
            Size = UDim2_new(0.96, 0, 0, 45),
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Active = true,
            Selectable = true,
            ZIndex = 20,
            Text = ""
        })

        BCorner.CornerRadius = UDim.new(0, 6)
        BCorner.Parent = Button
        
        Gui.ApplyProperties(BStroke, {
            Color = Color3_fromRGB(40, 40, 50),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Button
        })
        
        Gui.ApplyProperties(TitleLabel, {
            Name = "Title",
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2_new(0, 12, 0, 6),
            Size = UDim2_new(1, -80, 0, 16),
            Font = Enum_Font.GothamBold,
            Text = name,
            TextColor3 = Color3_fromRGB(220, 220, 230),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 21
        })

        Gui.ApplyProperties(DescLabel, {
            Name = "Desc",
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2_new(0, 12, 0, 23),
            Size = UDim2_new(1, -20, 0, 12),
            Font = Enum_Font.Gotham,
            Text = desc,
            TextColor3 = Color3_fromRGB(120, 120, 130),
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 21
        })

        Gui.ApplyProperties(StatusLight, {
            Name = "Status",
            Parent = Button,
            BackgroundColor3 = Color3_fromRGB(45, 45, 55),
            Position = UDim2_new(1, -12, 0.5, -3),
            Size = UDim2_new(0, 6, 0, 6),
            ZIndex = 21
        })
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(1, 0)
        StatusCorner.Parent = StatusLight

        local KeyLabel = Instance.new("TextLabel")
        Gui.ApplyProperties(KeyLabel, {
            Size = UDim2_new(0, 45, 0, 14),
            Position = UDim2_new(1, -65, 0, 8),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = Color3_fromRGB(0, 0, 0),
            Font = Enum_Font.Gotham,
            Text = Keybinds[name] or "NONE",
            TextColor3 = Color3_fromRGB(130, 130, 140),
            TextSize = 8,
            Parent = Button,
            ZIndex = 22
        })
        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, 3)
        KeyCorner.Parent = KeyLabel

        local isBinding = false
        Gui.SafeConnect(Button.MouseButton2Click, function()
            if isBinding then return end
            isBinding = true
            KeyLabel.Text = "..."
            KeyLabel.TextColor3 = Color3_fromRGB(255, 255, 100)
            
            local connection
            connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local key = input.KeyCode.Name
                    if key == "Escape" or key == "Backspace" then key = nil end
                    
                    Keybinds[name] = key
                    KeyLabel.Text = key or "NONE"
                    KeyLabel.TextColor3 = Color3_fromRGB(130, 130, 140)
                    
                    if Gui.env and Gui.env.SaveSettings then
                        Gui.env.SaveSettings("CatV4_Settings", { States = ScriptStates, Keybinds = Keybinds })
                    end
                    
                    connection:Disconnect()
                    task.wait(0.2)
                    isBinding = false
                end
            end)
        end)

        Gui.SafeConnect(game:GetService("UserInputService").InputBegan, function(input, gpe)
            if gpe then return end
            if Keybinds[name] and input.KeyCode.Name == Keybinds[name] then
                Button:Click()
            end
        end)

        local active = (ScriptStates[name] ~= nil and ScriptStates[name]) or (defaultState or false)
        local isProcessing = false

        local function UpdateVisuals()
            local targetColor = active and Color3_fromRGB(28, 28, 38) or Color3_fromRGB(20, 20, 25)
            local targetStroke = active and Color3_fromRGB(0, 150, 255) or Color3_fromRGB(40, 40, 50)
            
            Button.BackgroundColor3 = targetColor
            BStroke.Color = targetStroke
            BStroke.Transparency = active and 0.4 or 0
            
            if active then
                StatusLight.BackgroundColor3 = Color3_fromRGB(0, 255, 180)
                TitleLabel.TextColor3 = Color3_fromRGB(255, 255, 255)
            else
                StatusLight.BackgroundColor3 = Color3_fromRGB(45, 45, 55)
                TitleLabel.TextColor3 = Color3_fromRGB(200, 200, 210)
            end
            
            ScriptStates[name] = active
            if Gui.env and Gui.env.SaveSettings then
                Gui.env.SaveSettings("CatV4_Settings", { States = ScriptStates, Keybinds = Keybinds })
            end
        end

        if active then
            UpdateVisuals()
            task.spawn(function() pcall(loadFunc, true) end)
        end

        Gui.SafeConnect(Button.MouseButton1Click, function()
            if isProcessing then return end
            isProcessing = true
            
            active = not active
            local success, err = pcall(loadFunc, active)
            
            if success then
                UpdateVisuals()
            else
                active = not active
                if Notify then Notify("系統錯誤", tostring(err), "Error") end
            end
            
            task.wait(0.1)
            isProcessing = false
        end)
        
        targetTab.Page.CanvasSize = UDim2_new(0, 0, 0, targetTab.List.AbsoluteContentSize.Y + 20)
    end

    return {
        CreateTab = GuiUtils.CreateTab,
        AddScript = GuiUtils.AddScript,
        GetStates = function() return ScriptStates end,
        SetStates = function(states) ScriptStates = states or {} end
    }
end

return GuiUtils
