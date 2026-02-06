-- Halol (V4.0) 視覺功能模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local UDim2_new = UDim2.new
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait
local math_floor = math.floor
local math_clamp = math.clamp
local string_format = string.format

local VisualsModule = {}

function VisualsModule.Init(Gui, Notify)
    local ESPTag = "CatESP"
    
    -- 玩家透視 (Highlight)
    local function ApplyHighlightESP(char)
        if not char or char:FindFirstChild(ESPTag) then return end
        Gui.ApplyProperties(Instance.new("Highlight"), {
            Name = ESPTag,
            Parent = char,
            FillTransparency = 0.5,
            OutlineColor = Color3_fromRGB(255, 0, 0)
        })
    end

    -- 全面透視 (Full ESP)
    local function CreateFullESP(player)
        if player == lp then return end
        
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
                Size = UDim2_new(1, 0, 0.4, 0),
                Font = Enum.Font.GothamBold,
                TextColor3 = player.TeamColor.Color or Color3_fromRGB(255, 255, 255),
                TextSize = 14,
                TextStrokeTransparency = 0.5,
                Text = player.DisplayName or player.Name
            })
            
            local healthBarBG = Instance.new("Frame")
            Gui.ApplyProperties(healthBarBG, {
                Parent = container,
                BackgroundColor3 = Color3_fromRGB(50, 50, 50),
                BorderSizePixel = 0,
                Position = UDim2_new(0.1, 0, 0.45, 0),
                Size = UDim2_new(0.8, 0, 0.1, 0)
            })
            
            local healthBar = Instance.new("Frame")
            Gui.ApplyProperties(healthBar, {
                Parent = healthBarBG,
                BackgroundColor3 = Color3_fromRGB(0, 255, 0),
                BorderSizePixel = 0,
                Size = UDim2_new(1, 0, 1, 0)
            })
            
            local infoLabel = Instance.new("TextLabel")
            Gui.ApplyProperties(infoLabel, {
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
            
            task_spawn(function()
                while _G.FullESPEnabled and char.Parent and head.Parent do
                    if hum then
                        local hpPercent = math_clamp(hum.Health / hum.MaxHealth, 0, 1)
                        healthBar.Size = UDim2_new(hpPercent, 0, 1, 0)
                        healthBar.BackgroundColor3 = Color3_fromHSV(hpPercent * 0.3, 1, 1)
                        
                        local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and root) and 
                                     math_floor((lp.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                        
                        infoLabel.Text = string_format("[%d HP] | %d m", math_floor(hum.Health), dist)
                    end
                    task_wait(0.1)
                end
                billboard:Destroy()
            end)
        end
        
        if player.Character then task_spawn(OnCharacterAdded, player.Character) end
        Gui.SafeConnect(player.CharacterAdded, OnCharacterAdded)
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
            _G.FullESPEnabled = state
            if _G.FullESPEnabled then
                for _, p in ipairs(Players:GetPlayers()) do CreateFullESP(p) end
                Gui.SafeConnect(Players.PlayerAdded, CreateFullESP)
            end
        end
    }
end

return VisualsModule
