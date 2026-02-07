---@diagnostic disable: undefined-global, undefined-field, deprecated
-- Halol 射擊類功能啟動器
-- 放置於: 射擊類/init.lua

local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()

-- 通知函數
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration or 5
        })
    end)
end

Notify("射擊模組", "正在加載射擊類專用功能...", 3)

-- 1. 加載戰鬥模組
local CombatModule
local combatPath = "射擊類/combat.lua"

if env_global.readfile and env_global.isfile and env_global.isfile(combatPath) then
    local content = env_global.readfile(combatPath)
    local func, err = loadstring(content)
    if func then
        CombatModule = func()
        Notify("射擊模組", "戰鬥模組已成功從本地加載", 2)
    else
        warn("加載戰鬥模組出錯: " .. tostring(err))
    end
end

-- 2. 整合進 Halol GUI (如果已加載)
task.spawn(function()
    -- 等待 GUI 準備就緒
    local timeout = 0
    while not env_global.HalolMainGui and timeout < 10 do
        task.wait(1)
        timeout = timeout + 1
    end

    if env_global.HalolMainGui and CombatModule then
        local Gui = env_global.HalolMainGui
        local Utils = env_global.HalolUtils
        
        -- 建立射擊功能分頁
        if Utils and Utils.CreateTab then
            local combatTab = Utils.CreateTab("射擊類")
            
            -- 初始化模組
            local combatActions = CombatModule.Init(Gui, Notify, env_global.HalolFunctions)
            
            -- 添加腳本到 GUI
            Utils.AddScript("射擊類", "自瞄 (Aimbot)", "自動瞄準最近的敵人", function(state)
                combatActions.ToggleAimbot(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "顯示 FOV 範圍", "顯示自瞄偵測圓圈", function(state)
                combatActions.ToggleShowFOV(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "自動開火 (TriggerBot)", "當準心指向敵人時自動攻擊", function(state)
                combatActions.ToggleTriggerBot(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "無後座力 (No Recoil)", "嘗試減少武器後座力", function(state)
                combatActions.ToggleNoRecoil(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：空中打人", "自動傳送到敵人上方並開火", function(state)
                combatActions.ToggleAirAttack(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "魔法子彈 (Magic Bullet)", "子彈自動導向敵人 (需執行器支持)", function(state)
                combatActions.ToggleMagicBullet(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "彈道軌跡 (Tracers)", "顯示子彈飛行軌跡", function(state)
                combatActions.ToggleBulletTracers(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "命中音效 (HitSound)", "擊中敵人時播放音效", function(state)
                combatActions.ToggleHitSound(state)
            end, Notify, false)
            
            Notify("射擊模組", "射擊類功能已整合至主介面", 3)
        end
    else
        Notify("射擊模組", "未偵測到主框架，部分介面功能將受限", 5)
    end
end)
