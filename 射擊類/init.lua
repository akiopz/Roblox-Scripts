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
            -- [[ 戰鬥模組 ]]
            Utils.AddScript("射擊類", "自瞄 (Aimbot)", "自動瞄準最近的敵人", function(state)
                combatActions.ToggleAimbot(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "可見度檢查 (VisCheck)", "僅瞄準障礙物外的敵人", function(state)
                combatActions.ToggleAimbotVisibility(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "彈道預測 (Prediction)", "根據目標速度預測位置", function(state)
                combatActions.ToggleAimbotPrediction(state)
            end, Notify, true)
            
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
            
            Utils.AddScript("射擊類", "暴力：殺戮光環", "自動攻擊範圍內所有敵人", function(state)
                combatActions.ToggleKillAura(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：極速移動", "大幅提升移動速度", function(state)
                combatActions.ToggleBlatantSpeed(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：飛行模式", "自由在空中飛行", function(state)
                combatActions.ToggleFly(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：大陀螺 (Spin Bot)", "角色快速旋轉，極其暴力", function(state)
                combatActions.ToggleSpinBot(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：防瞄準 (Anti-Aim)", "抖動位移與速度偽造，使敵方打不中", function(state)
                combatActions.ToggleAntiAim(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：假替身模式", "生成一個假替身吸引敵方火力", function(state)
                combatActions.ToggleFakeClone(state)
            end, Notify, false)

            Utils.AddScript("射擊類", "暴力：自動獲勝 (Auto Win)", "嘗試殺死所有人並傳送至終點", function(state)
                combatActions.ToggleAutoWin(state)
            end, Notify, false)

            Utils.AddScript("射擊類", "暴力：自動卡頓 (Lag Switch)", "使自己間歇性卡頓，干擾敵方瞄準", function(state)
                combatActions.ToggleLagSwitch(state)
            end, Notify, false)

            Utils.AddScript("射擊類", "安全：刪除反外掛 (AC Nuker)", "掃描並嘗試刪除遊戲內的反外掛腳本", function(state)
                combatActions.ToggleServerACNuker(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "魔法子彈 (Magic Bullet)", "子彈自動導向敵人 (需執行器支持)", function(state)
                combatActions.ToggleMagicBullet(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "暴力：穿牆擊殺 (WallHack Kill)", "子彈無視地形直接命中敵人", function(state)
                combatActions.ToggleWallHackKill(state)
            end, Notify, false)

            -- [[ 伺服器等級模組 (Server-Level) ]]
            Utils.AddScript("射擊類", "全服：伺服器延遲 (Server Lag)", "過載伺服器 Remote 導致全服延遲", function(state)
                combatActions.ToggleServerLag(state)
            end, Notify, false)

            Utils.AddScript("射擊類", "全服：自動擊殺 (Kill All)", "嘗試掃描漏洞 Remote 並攻擊全服玩家", function(state)
                combatActions.ToggleKillAll(state)
            end, Notify, false)

            Utils.AddScript("射擊類", "全服：聊天轟炸 (Chat Spam)", "持續發送腳本宣傳信息", function(state)
                combatActions.ToggleChatSpam(state)
            end, Notify, false)
            
            -- [[ 透視模組 (ESP) ]]
            Utils.AddScript("射擊類", "全屏透視 (Full ESP)", "開啟/關閉所有玩家透視", function(state)
                combatActions.ToggleESP(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "方框透視 (Boxes)", "顯示玩家方框", function(state)
                combatActions.ToggleESPBoxes(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "名字顯示 (Names)", "顯示玩家名稱", function(state)
                combatActions.ToggleESPNames(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "血量顯示 (Health)", "顯示玩家血條", function(state)
                combatActions.ToggleESPHealth(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "距離顯示 (Distance)", "顯示玩家與您的距離", function(state)
                combatActions.ToggleESPDistance(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "追蹤射線 (Snaplines)", "顯示連向玩家的射線", function(state)
                combatActions.ToggleESPSnaplines(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "角色發光 (Chams)", "使玩家角色發光透視", function(state)
                combatActions.ToggleESPChams(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "骨骼透視 (Skeleton)", "顯示玩家人形骨骼結構", function(state)
                combatActions.ToggleESPSkeleton(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "RGB 彩虹模式 (RGB)", "透視顏色動態變換", function(state)
                combatActions.ToggleESPRGB(state)
            end, Notify, false)
            
            Utils.AddScript("射擊類", "切換透視顏色 (Color)", "循環切換透視顯示顏色", function()
                combatActions.CycleESPColor()
            end, Notify, false)
            
            Utils.AddScript("射擊類", "隊友過濾 (Team Check)", "不顯示隊友透視", function(state)
                combatActions.ToggleESPTeamCheck(state)
            end, Notify, true)
            
            -- [[ 安全與增強 ]]
            Utils.AddScript("射擊類", "反偵測繞過 (Anti-Cheat Bypass)", "偽裝屬性並攔截舉報 (推薦開啟)", function(state)
                combatActions.ToggleAntiCheatBypass(state)
            end, Notify, true)
            
            Utils.AddScript("射擊類", "深度隱蔽模式 (Stealth)", "人性化自瞄移動與強化反偵測", function(state)
                combatActions.ToggleStealthMode(state)
            end, Notify, true)
            
            Utils.AddScript("射擊類", "反閃光彈 (Anti-Flash)", "無視視覺干擾與閃光效果", function(state)
                combatActions.ToggleAntiFlash(state)
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
