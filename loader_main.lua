---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()
local game = game or env_global.game
local ipairs = ipairs or env_global.ipairs
local pcall = pcall or env_global.pcall
local os = os or env_global.os
local print = print or env_global.print
local error = error or env_global.error
local tostring = tostring or env_global.tostring
local table = table or env_global.table
local unpack = unpack or table.unpack
local load_func = (env_global.loadstring or env_global.load or loadstring or load)

env_global.ProjectileAura = env_global.ProjectileAura or false
env_global.VelocityHorizontal = env_global.VelocityHorizontal or 15
env_global.VelocityVertical = env_global.VelocityVertical or 100

print("Halol V5.0.0 開始加載 (優化效能與新增自動化)...")

-- 通知本地啟動器 (如果有的話)
task.spawn(function()
    local local_host = "http://localhost:8000/"
    pcall(function()
        game:HttpGet(local_host .. "status")
    end)
    -- 持續發送心跳以維持連線狀態
    while task.wait(5) do
        pcall(function()
            game:HttpGet(local_host .. "get_command")
        end)
    end
end)

-- 增加一個隨機數來徹底繞過快取
local sessionID = tostring(math.random(100000, 999999))

env_global.FPSBoost = env_global.FPSBoost or false
env_global.AutoBuyWool = env_global.AutoBuyWool or false
env_global.AutoArmor = env_global.AutoArmor or false
env_global.NoSlowdown = env_global.NoSlowdown or false
env_global.FastBreak = env_global.FastBreak or false
env_global.AutoBridge = env_global.AutoBridge or false

env_global.AI_Enabled = env_global.AI_Enabled or false
env_global.GodModeAI = env_global.GodModeAI or false
env_global.AutoToxic = env_global.AutoToxic or false
env_global.SpeedValue = env_global.SpeedValue or 23
env_global.KillAuraCPS = env_global.KillAuraCPS or 10
env_global.KillAuraMaxTargets = env_global.KillAuraMaxTargets or 1

local function Notify(title, text, duration)
    pcall(function()
        local d = 5
        if type(duration) == "number" then
            d = duration
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = d
        })
    end)
end

Notify("Halol V5.0.0", "正在從雲端獲取最新組件 (強制刷新)...", 3)

local success, err = pcall(function()
    local HOSTS = {
        "https://raw.githubusercontent.com/akiopz/Roblox-Scripts/main/",
        "https://raw.fastgit.org/akiopz/Roblox-Scripts/main/"
    }
    
    local function GetScript(path)
        print("正在獲取模組: " .. path)
        
        -- 優先嘗試從本地加載 (開發模式)
        if env_global.isfile and env_global.isfile(path) then
            print("偵測到本地檔案，優先加載: " .. path)
            local content = env_global.readfile(path)
            local func, parseErr = load_func(content)
            if func then
                local ok, result = pcall(func)
                if ok then return result end
                warn("本地執行錯誤: " .. tostring(result))
            else
                warn("本地語法錯誤: " .. tostring(parseErr))
            end
        end

        local lastErr
        for _, base in ipairs(HOSTS) do
            -- 使用隨機參數強制繞過 GitHub 和執行器的快取
            local url = base .. path .. "?nocache=" .. sessionID .. "&t=" .. os.time()
            local ok, content = pcall(function()
                return game:HttpGet(url)
            end)
            if ok and content and content ~= "" then
                local func, parseErr = load_func(content)
                if func then
                    local execSuccess, result = pcall(func)
                    if execSuccess then
                        return result
                    else
                        lastErr = "執行錯誤 (" .. path .. "): " .. tostring(result)
                    end
                else
                    lastErr = "語法錯誤 (" .. path .. "): " .. tostring(parseErr)
                end
            else
                lastErr = "無法獲取檔案: " .. path .. " 來源: " .. base
            end
        end
        error(lastErr or ("下載未知錯誤: " .. path))
    end



    local env = GetScript("src/core/env.lua")
    env.Notify = Notify
    
    local guiModule = GetScript("src/core/gui.lua")
    local mainGui = guiModule.CreateMainGui()
    
    print("DEBUG: 核心模組已加載")
    local utilsModule = GetScript("src/core/utils.lua")
    local GUtils = utilsModule.Init(mainGui)

    Notify("Halol V5.0.0", "核心組件已就緒，載入介面中...", 3)
    
    local functionsModule = GetScript("src/modules/functions.lua")
    local CatFunctions = functionsModule.Init(env)
    
    -- 為所有核心功能加入全局錯誤處理 (pcall)
    for name, func in pairs(CatFunctions) do
        if type(func) == "function" and name:find("Toggle") then
            local originalFunc = func
            CatFunctions[name] = function(...)
                local args = {...}
                local success, err = pcall(function()
                    return originalFunc(unpack(args))
                end)
                if not success then
                    warn("功能執行錯誤 (" .. tostring(name) .. "): " .. tostring(err))
                    Notify("系統錯誤", "功能 [" .. tostring(name) .. "] 執行失敗: " .. tostring(err), "Error")
                end
            end
        end
    end
    
    -- 啟動時自動開啟核心保護功能 (用戶要求)
    if CatFunctions.ToggleAntiReport then
        CatFunctions.ToggleAntiReport(true)
    end
    if CatFunctions.ToggleAntiVoid then
        CatFunctions.ToggleAntiVoid(true)
        Notify("Halol 系統", "核心保護功能 (抗舉報/防虛空) 已自動啟動", 3)
    end
    
    -- 優先載入設定
    if CatFunctions.LoadConfig then
        CatFunctions.LoadConfig()
    end

    local blatantModule = GetScript("src/modules/blatant.lua")
    local kitsModule = GetScript("src/modules/kits.lua")

    local Blatant = blatantModule.Init(mainGui, function(...) Notify("Halol V5.0.0", ...) end, CatFunctions)
    local Kits = kitsModule.Init(mainGui, function(...) Notify("Halol V5.0.0", ...) end, CatFunctions)

    local aiModule = GetScript("src/modules/ai.lua")
    local AI = aiModule.Init(CatFunctions, Blatant)

    local visualsModule = GetScript("src/modules/visuals.lua")
    local Visuals = visualsModule.Init(mainGui, function(...) Notify("Halol V5.0.0", ...) end)

    local utilityModule = GetScript("src/modules/utility.lua")
    local Utility = utilityModule.Init(env)

    -- 註冊全域卸載回調
    getgenv().HalolUnload = function(keepGui)
        pcall(function() 
            -- 1. 停止 AI
            if AI and AI.Stop then AI.Stop() end
            
            -- 2. 停止視覺功能 (重置全域標籤)
            env_global.FullESPEnabled = false
            env_global.TracersEnabled = false
            env_global.RadarEnabled = false
            env_global.ChestESPEnabled = false
            env_global.ShopESPEnabled = false
            env_global.FullbrightEnabled = false
            
            -- 3. 執行核心功能卸載 (含重置 WalkSpeed, 碰撞箱等)
            if CatFunctions and CatFunctions.UnloadAll then 
                CatFunctions.UnloadAll() 
            end
            
            -- 4. 銷毀 GUI (除非是從 GUI 觸發的淡出銷毀)
            if not keepGui and mainGui and mainGui.ScreenGui then
                mainGui.ScreenGui:Destroy()
            end
        end)
        getgenv().HalolUnload = nil
        if Notify then
            Notify("Halol 系統", "腳本已完全卸載並關閉所有功能", 5)
        else
            print("Halol 系統: 腳本已完全卸載並關閉所有功能")
        end
    end

    local utilityTab = GUtils.CreateTab("工具功能")
    GUtils.AddScript("工具功能", "自動進食 (Auto Eat)", "血量過低時自動進食", function(s) CatFunctions.ToggleAutoEat(s) end, Notify)
    GUtils.AddScript("工具功能", "自動穿甲 (Auto Armor)", "自動購買並穿戴護甲", function(s) CatFunctions.ToggleAutoArmor(s) end, Notify)
    GUtils.AddScript("工具功能", "動畫播放器", "播放自定義動畫 (待開發)", function(s) Utility.ToggleAnimationPlayer(s) end, Notify)
    GUtils.AddScript("工具功能", "防擊退 (Anti Ragdoll)", "防止角色被擊飛或倒地", function(s) CatFunctions.ToggleAntiRagdoll(s) end, Notify)
    GUtils.AddScript("工具功能", "自動排隊", "自動加入下一局遊戲", function(s) Utility.ToggleAutoQueue(s) end, Notify)
    GUtils.AddScript("工具功能", "閃現 (Blink)", "短暫切斷網路連接模擬閃現", function(s) Utility.ToggleBlink(s) end, Notify)
    GUtils.AddScript("工具功能", "聊天噴子 (Spammer)", "自動在聊天室發送宣傳訊息", function(s) Utility.ToggleChatSpammer(s) end, Notify)
    GUtils.AddScript("工具功能", "自動舉報 (Report)", "自動舉報其他玩家 (含大量舉報反擊)", function(s) Utility.ToggleAutoReport(s) end, Notify)
    GUtils.AddScript("工具功能", "自動噴人 (Toxic)", "擊殺玩家後自動發送嘲諷訊息", function(s) CatFunctions.ToggleAutoToxic(s) end, Notify)
    GUtils.AddScript("工具功能", "中鍵好友", "滑鼠中鍵點擊玩家加入白名單", function(s) Utility.ToggleMiddleClickFriends(s) end, Notify)
    GUtils.AddScript("工具功能", "防閒置 (Anti-AFK)", "防止因長時間不操作被伺服器踢出", function(s) CatFunctions.ToggleAntiAFK(s) end, Notify)
    
    local isBedWars = (game.PlaceId == 6872274481 or game.PlaceId == 6872265039 or game.GameId == 2619619178)
    local gameName = isBedWars and "Bed Wars" or "Universal (通用模式)"
    Notify("Halol 智慧偵測", "系統已識別當前遊戲為: " .. gameName, "Success")

    -- ==========================================
    -- 通用功能 (Universal Tab) - 所有遊戲可用
    -- ==========================================
    local universalTab = GUtils.CreateTab("通用功能")
    GUtils.AddScript("通用功能", "智慧型 ESP", "偵測所有遊戲中的玩家、NPC 與關鍵物品", function(s) CatFunctions.ToggleUniversalESP(s) end, Notify)
    GUtils.AddScript("通用功能", "方框透視 (Box)", "在目標周圍顯示 3D 方框", function(s) Visuals.ToggleBoxESP(s) end, Notify)
    GUtils.AddScript("通用功能", "血量顯示", "在目標上方顯示詳細血量與血條", function(s) Visuals.ToggleHealthDisplay(s) end, Notify)
    GUtils.AddScript("通用功能", "連線透視 (Tracer)", "顯示指向玩家的追蹤連線", function(s) Visuals.ToggleTracers(s) end, Notify)
    GUtils.AddScript("通用功能", "無限跳躍 (Inf Jump)", "解除跳躍次數限制，可在空中無限跳躍", function(s) CatFunctions.ToggleInfiniteJump(s) end, Notify)
    GUtils.AddScript("通用功能", "穿牆模式 (Noclip)", "使角色可以穿過牆壁與障礙物", function(s) CatFunctions.ToggleNoclip(s) end, Notify)
    GUtils.AddScript("通用功能", "爬牆模式 (Spider)", "使角色可以像蜘蛛一樣攀爬牆壁", function(s) CatFunctions.ToggleSpider(s) end, Notify)
    GUtils.AddScript("通用功能", "自動上階 (Step)", "自動跨越障礙物，提升移動流暢度", function(s) CatFunctions.ToggleStep(s) end, Notify)
    GUtils.AddScript("通用功能", "反擊退 (Velocity)", "抵消受到的擊退效果", function(s) CatFunctions.ToggleVelocity(s) end, Notify)
    GUtils.AddScript("通用功能", "透視牆壁 (Xray)", "使所有方塊半透明，方便尋找隱藏目標", function(s) CatFunctions.ToggleXray(s) end, Notify)
    GUtils.AddScript("通用功能", "自動重連", "斷開連線時自動嘗試重新加入遊戲", function(s) CatFunctions.ToggleAutoRejoin(s) end, Notify)
    GUtils.AddScript("通用功能", "全亮模式", "無視遊戲亮度設定，始終保持清晰視野", function(s) Visuals.ToggleFullbright(s) end, Notify)
    GUtils.AddScript("通用功能", "視野解鎖 (Zoom)", "解除攝影機最大縮放距離限制", function(s) Visuals.ToggleZoomUnlocker(s) end, Notify)
    GUtils.AddScript("通用功能", "儲存配置", "手動保存當前所有功能設定", function() CatFunctions.SaveConfig() end, Notify)
    GUtils.AddScript("通用功能", "載入配置", "手動載入已保存的功能設定", function() CatFunctions.LoadConfig() end, Notify)

    -- ==========================================
    -- 遊戲專屬功能 (僅在特定遊戲中顯示)
    -- ==========================================
    if isBedWars then
        local firstTab = GUtils.CreateTab("自動核心")
        GUtils.AddScript("自動核心", "不死模式 (Anti Dead)", "低血量自動升空避難並持續攻擊", function(s) CatFunctions.ToggleAntiDead(s) end, Notify)
        GUtils.AddScript("自動核心", "自動回血 (Auto Heal)", "血量過低時自動使用物品欄中的回血道具", function(s) CatFunctions.ToggleAutoHeal(s) end, Notify)
        GUtils.AddScript("自動核心", "快速食用 (Fast Eat)", "消除進食動畫與延遲，瞬間使用消耗品", function(s) CatFunctions.ToggleFastEat(s) end, Notify)
        GUtils.AddScript("自動核心", "物品吸取 (Item Stealer)", "自動將周圍 20 格內的掉落物吸取到身上", function(s) CatFunctions.ToggleItemStealer(s) end, Notify)
        GUtils.AddScript("自動核心", "自動勝出 (Auto Win)", "自動摧毀敵方床位並清除玩家以獲取勝利", function(s) CatFunctions.ToggleAutoWin(s) end, Notify)
        GUtils.AddScript("自動核心", "自動路徑 (AI)", "自動前往最近的目標或資源點", function(s) AI.Toggle(s) end, Notify)
        GUtils.AddScript("自動核心", "全自動資源收集", "自動採集地圖上的鐵、金、鑽石、翡翠", function(s) CatFunctions.ToggleAutoResourceFarm(s) end, Notify)
        GUtils.AddScript("自動核心", "自動採購氣球", "墜落時自動購買並使用氣球", function(s) CatFunctions.ToggleAutoBalloon(s) end, Notify)
        GUtils.AddScript("自動核心", "箱子自動搜刮", "快速自動拿取附近箱子內的資源", function(s) Blatant.ToggleChestStealer(s) end, Notify)
        GUtils.AddScript("自動核心", "自動切換工具", "根據方塊類型自動切換對應工具", function(s) Blatant.ToggleAutoTool(s) end, Notify)
    end

    local combatTab = GUtils.CreateTab("戰鬥功能")
    GUtils.AddScript("戰鬥功能", "靜默自瞄 (Silent Aim)", "攻擊時自動校正彈道指向最近的敵人", function(s) CatFunctions.ToggleSilentAim(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "反擊退 (Anti Ragdoll)", "防止角色因受到攻擊而倒地或被擊飛", function(s) CatFunctions.ToggleAntiRagdoll(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "自動陷阱 (Auto Trap)", "在最近的敵人四周快速放置方塊困住對方", function(s) CatFunctions.ToggleAutoTrap(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "自動鎖定敵人", "右鍵瞄準時自動鎖定最近的敵人", function(s) CatFunctions.ToggleAimbot(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "殺戮光環 (Kill Aura)", "自動攻擊範圍內的敵人", function(s) CatFunctions.ToggleKillAura(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "自瞄 (TriggerBot)", "鼠標指向敵人時自動攻擊", function(s) CatFunctions.ToggleTriggerBot(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "投擲物光環 (Projectile Aura)", "自動瞄準並打擊投擲物或使用遠程武器", function(s) Blatant.ToggleProjectileAura(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "自動格擋 (Auto Block)", "受到攻擊或附近有敵方時自動格擋", function(s) Blatant.ToggleAutoBlock(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "自動切換武器", "根據敵人距離自動切換最強武器", function(s) Blatant.ToggleAutoWeapon(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "攻擊距離擴展 (Reach)", "增加武器攻擊距離 (25格)", function(s) CatFunctions.ToggleReach(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "碰撞箱擴大 (Hitbox)", "極大化敵人碰撞箱以便打擊", function(s) CatFunctions.ToggleHitboxExpander(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "攻擊加強 (Criticals)", "每次攻擊必出暴擊傷害", function(s) CatFunctions.ToggleCriticals(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "快速攻擊 (Fast Attack)", "極大化攻擊頻率與冷卻縮減", function(s) CatFunctions.ToggleFastAttack(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "自動連點 (Clicker)", "快速自動模擬滑鼠點擊", function(s) CatFunctions.ToggleAutoClicker(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "擊退優化 (Velocity)", "減少或取消受到的擊退效果", function(s) CatFunctions.ToggleVelocity(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "目標繞圈 (TargetStrafe)", "自動繞著目標旋轉攻擊", function(s) CatFunctions.ToggleTargetStrafe(s) end, Notify)
    GUtils.AddScript("戰鬥功能", "靜默瞄準鎖定 (SilentAim Lock)", "強化靜默瞄準，鎖定目標頭部", function(s) CatFunctions.ToggleSilentAimLock(s) end, Notify)

    -- ==========================================
    -- 運動輔助 (通用)
    -- ==========================================
    local moveTab = GUtils.CreateTab("運動輔助")
    GUtils.AddScript("運動輔助", "脈衝加速 (Speed)", "繞過檢測的穩定移動加速", function(s) CatFunctions.ToggleSpeed(s) end, Notify)
    GUtils.AddScript("運動輔助", "反重力飛行 (Fly)", "全方向自由飛行 (含防回溯)", function(s) CatFunctions.ToggleFly(s) end, Notify)
    GUtils.AddScript("運動輔助", "無減速 (NoSlowdown)", "使用道具時不降低移動速度", function(s) CatFunctions.ToggleNoSlowdown(s) end, Notify)
    GUtils.AddScript("運動輔助", "超級跳躍 (LongJump)", "瞬間爆發性遠跳", function(s) CatFunctions.ToggleLongJump(s) end, Notify)
    GUtils.AddScript("運動輔助", "高跳 (HighJump)", "大幅增加跳躍高度", function(s) CatFunctions.ToggleHighJump(s) end, Notify)
    GUtils.AddScript("運動輔助", "防掉落 (NoFall)", "消除墜落傷害", function(s) CatFunctions.ToggleNoFall(s) end, Notify)
    GUtils.AddScript("運動輔助", "防虛空 (AntiVoid)", "掉入虛空時自動彈回", function(s) CatFunctions.ToggleAntiVoid(s) end, Notify, true)
    
    if isBedWars then
        GUtils.AddScript("運動輔助", "持續衝刺 (Keep Sprint)", "強制保持衝刺狀態，即使在攻擊時也不會減速", function(s) CatFunctions.ToggleKeepSprint(s) end, Notify)
        GUtils.AddScript("運動輔助", "無限飛行 (Infinite Fly)", "無重力全向飛行，支援上升(空白)與下降(Shift)", function(s) CatFunctions.ToggleInfiniteFly(s) end, Notify)
        GUtils.AddScript("運動輔助", "自動搭橋 (AutoBridge)", "走路時自動向前方空處鋪路", function(s) CatFunctions.ToggleAutoBridge(s) end, Notify)
        GUtils.AddScript("運動輔助", "自動搭路 (Scaffold)", "在腳下自動放置方塊", function(s) CatFunctions.ToggleScaffold(s) end, Notify)
    end

    -- ==========================================
    -- 伺服器強化 (Bed Wars 專屬)
    -- ==========================================
    if isBedWars then
        local serverTab = GUtils.CreateTab("伺服器強化")
        GUtils.AddScript("伺服器強化", "Auto Buy Wool (自動買羊毛)", "原理：檢查資源庫存並遠程調用商店封包。\n效果：在羊毛耗盡時自動補充，確保搭路不間斷。", function(s) CatFunctions.ToggleAutoBuyWool(s) end, Notify)
        GUtils.AddScript("伺服器強化", "Auto Armor (自動買甲)", "原理：掃描商店進度並自動執行購買與穿戴遠程。\n效果：全自動升級至最高級護甲，確保生存能力。", function(s) CatFunctions.ToggleAutoArmor(s) end, Notify)
        GUtils.AddScript("伺服器強化", "Auto Buy Upgrades (自動升級)", "原理：自動分配資源購買團隊傷害與保護升級。\n效果：全自動提升隊伍戰力。", function(s) CatFunctions.ToggleAutoBuyUpgrades(s) end, Notify)
        GUtils.AddScript("伺服器強化", "進階自動購買 (Advanced Buy)", "智慧資源判斷，優先購買 TNT/火球並確保物品欄不溢出", function(s) CatFunctions.ToggleAutoBuyAdvanced(s) end, Notify)
        GUtils.AddScript("伺服器強化", "自動嘲諷 (Auto Toxic)", "擊殺敵人後自動在公頻發送嘲諷訊息", function(s) CatFunctions.ToggleAutoToxic(s) end, Notify)
        GUtils.AddScript("伺服器強化", "遠程商店", "隨時隨地開啟商店數據交互", function(s) CatFunctions.ToggleInstantShop(s) end, Notify)
        GUtils.AddScript("伺服器強化", "自動領取獎勵", "自動領取每日、任務與通行證獎勵", function(s) CatFunctions.ToggleAutoClaimRewards(s) end, Notify)
        GUtils.AddScript("伺服器強化", "抗舉報模式", "模擬攔截傳出的玩家舉報封包", function(s) CatFunctions.ToggleAntiReport(s) end, Notify, true)
        GUtils.AddScript("伺服器強化", "全體防觀戰 (Global Stealth)", "除隊友外，所有人（敵方/觀戰者）都無法觀戰或看到你", function(s) CatFunctions.ToggleGlobalAntiSpectate(s) end, Notify)
        GUtils.AddScript("伺服器強化", "防觀戰模式", "使觀戰者看到你的位置異常或畫面劇烈抖動", function(s) CatFunctions.ToggleAntiSpectate(s) end, Notify)
        GUtils.AddScript("伺服器強化", "幽靈殘影 (Ghost Mode)", "在移動路徑上留下虛假殘影", function(s) CatFunctions.ToggleGhostMode(s) end, Notify)
    end
    
    -- ==========================================
    -- 伺服器級別 (Bed Wars 專屬)
    -- ==========================================
    if isBedWars then
        local levelTab = GUtils.CreateTab("伺服器級別")
        GUtils.AddScript("伺服器級別", "全自動主宰模式", "一鍵接管伺服器，自動處理所有高難度操作", function(s) CatFunctions.ToggleAutoMaster(s) end, Notify)
        GUtils.AddScript("伺服器級別", "Desync (網路同步篡改)", "位置偽造，敵方無法擊中你的幻影", function(s) CatFunctions.ToggleDesync(s) end, Notify)
        GUtils.AddScript("伺服器級別", "Global Nuker (全域安全破壞)", "無視距離拆除敵方床位", function(s) CatFunctions.ToggleGlobalNuker(s) end, Notify)
        GUtils.AddScript("伺服器級別", "Infinite Aura (全圖打擊)", "實現全地圖範圍內的自動打擊", function(s) CatFunctions.ToggleInfiniteAura(s) end, Notify)
    end
    
    local worldTab = GUtils.CreateTab("世界與雜項")
    GUtils.AddScript("世界與雜項", "自由視角 (Freecam)", "解鎖視角自由移動 (W/A/S/D)", function(s) CatFunctions.ToggleFreecam(s) end, Notify)
    GUtils.AddScript("世界與雜項", "視野修改 (FOV)", "修改玩家的視野範圍 (FOV)", function() 
        Notify("視野設定", "請輸入您想要的 FOV 數值 (預設 70, 建議 90-110):", "Info")
        -- 這裡簡化處理，通常會彈出一個輸入框
        CatFunctions.SetFOV(100)
    end, Notify)
    GUtils.AddScript("世界與雜項", "自動噴漆 (Auto Spray)", "自動在腳下進行噴漆", function(s) CatFunctions.ToggleAutoSpray(s) end, Notify)
    GUtils.AddScript("世界與雜項", "跑酷模式 (Parkour)", "自動跳過 1 格高的障礙物", function(s) CatFunctions.ToggleParkour(s) end, Notify)
    GUtils.AddScript("世界與雜項", "安全行走 (SafeWalk)", "防止從方塊邊緣掉落", function(s) CatFunctions.ToggleSafeWalk(s) end, Notify)
    GUtils.AddScript("世界與雜項", "透視方塊 (Xray)", "使方塊透明化以查看地下資源", function(s) CatFunctions.ToggleXray(s) end, Notify)
    GUtils.AddScript("世界與雜項", "快速破壞 (FastBreak)", "大幅提升破壞方塊的速度", function(s) CatFunctions.ToggleFastBreak(s) end, Notify)
    GUtils.AddScript("世界與雜項", "自動拆床 (BedNuker)", "自動破壞範圍內的床 (25格)", function(s) CatFunctions.ToggleBedNuker(s) end, Notify)
    GUtils.AddScript("世界與雜項", "效能極致優化 (FPS 999+)", "降低畫質並解除幀率限制以獲取最高 FPS", function(s) CatFunctions.ToggleFPSBoost(s) end, Notify)
    GUtils.AddScript("世界與雜項", "範圍破壞 (Nuker)", "自動破壞周圍所有可破壞方塊", function(s) CatFunctions.ToggleNuker(s) end, Notify)
    GUtils.AddScript("世界與雜項", "時間循環 (Cycle)", "使世界時間不斷流轉", function(s) CatFunctions.ToggleTimeCycle(s) end, Notify)
    GUtils.AddScript("世界與雜項", "重力修改 (Gravity)", "修改世界重力數值 (預設 50)", function(s) CatFunctions.ToggleGravity(s) end, Notify)
    GUtils.AddScript("世界與雜項", "移除霧氣 (NoFog)", "使地圖視線更加清晰", function(s) CatFunctions.ToggleNoFog(s) end, Notify)
    GUtils.AddScript("世界與雜項", "解鎖幀率 (FPS)", "解除 60 幀限制 (需執行器支持)", function(s) CatFunctions.ToggleFPSCap(s) end, Notify)
    GUtils.AddScript("世界與雜項", "防掛機 (AntiAFK)", "防止因長時間不操作被踢出", function(s) CatFunctions.ToggleAntiAFK(s) end, Notify)

    local visualTab = GUtils.CreateTab("視覺顯示")
    GUtils.AddScript("視覺顯示", "玩家透視 (ESP)", "穿牆顯示玩家位置與資訊", function(s) Visuals.ToggleESP(s) end, Notify)
    GUtils.AddScript("視覺顯示", "箭頭透視 (Arrows)", "在螢幕邊緣顯示玩家方向箭頭", function(s) Visuals.ToggleArrows(s) end, Notify)
    GUtils.AddScript("視覺顯示", "氣氛修改 (Atmosphere)", "修改世界的霧氣與氛圍效果", function(s) Visuals.ToggleAtmosphere(s) end, Notify)
    GUtils.AddScript("視覺顯示", "麵包屑軌跡 (Breadcrumbs)", "在走過的路徑留下足跡", function(s) Visuals.ToggleBreadcrumbs(s) end, Notify)
    GUtils.AddScript("視覺顯示", "自定義披風 (Cape)", "為角色增加酷炫的披風", function(s) Visuals.ToggleCape(s) end, Notify)
    GUtils.AddScript("視覺顯示", "透視上色 (Chams)", "使玩家模型呈現高亮純色", function(s) Visuals.ToggleChams(s) end, Notify)
    GUtils.AddScript("視覺顯示", "中國帽 (ChinaHat)", "在角色頭上顯示一個裝飾帽", function(s) Visuals.ToggleChinaHat(s) end, Notify)
    GUtils.AddScript("視覺顯示", "電競椅 (GamingChair)", "角色坐在一把電競椅上移動", function(s) Visuals.ToggleGamingChair(s) end, Notify)
    GUtils.AddScript("視覺顯示", "名稱標籤 (NameTags)", "優化玩家頭頂的名稱顯示", function(s) Visuals.ToggleNameTags(s) end, Notify)
    GUtils.AddScript("視覺顯示", "玩家模型修改", "修改玩家的視覺模型呈現", function(s) Visuals.TogglePlayerModel(s) end, Notify)
    GUtils.AddScript("視覺顯示", "搜索透視 (Search)", "高亮顯示特定的目標物品", function(s) Visuals.ToggleSearch(s) end, Notify)
    GUtils.AddScript("視覺顯示", "表情動作 (SetEmote)", "播放自定義的表情動作", function(s) Visuals.ToggleSetEmote(s) end, Notify)
    GUtils.AddScript("視覺顯示", "時間切換 (TimeChanger)", "自定義本地世界時間", function(s) Visuals.ToggleTimeChanger(s) end, Notify)
    GUtils.AddScript("視覺顯示", "床位標記 (Waypoints)", "在畫面上標記床位位置", function(s) Visuals.ToggleWaypoints(s) end, Notify)

    local configTab = GUtils.CreateTab("設定與配置")
    GUtils.AddScript("設定與配置", "保存當前配置", "將所有開關與數值保存至本地文件", function() CatFunctions.SaveConfig() end, Notify)
    GUtils.AddScript("設定與配置", "加載本地配置", "從本地文件讀取並應用先前保存的設定", function() CatFunctions.LoadConfig() end, Notify)
    GUtils.AddScript("設定與配置", "設定快捷鍵 (F)", "點擊後下次按下的鍵將綁定至 Kill Aura", function() 
        Notify("快捷鍵設定", "請按下您想要綁定至 Kill Aura 的按鍵...", "Info")
        local connection
        connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode ~= Enum.KeyCode.Unknown then
                CatFunctions.SetKeybind("KillAura", input.KeyCode)
                connection:Disconnect()
            end
        end)
    end, Notify)
    GUtils.AddScript("設定與配置", "重置所有設定", "清除所有自定義設定並恢復預設值", function() 
        if env_global.HalolUnload then env_global.HalolUnload(true) end
        Notify("配置系統", "所有設定已重置", "Info")
    end, Notify)

    local visualExtrasTab = GUtils.CreateTab("視覺顯示 (更多)")
    GUtils.AddScript("視覺顯示 (更多)", "天氣修改 (Weather)", "切換不同的天氣視覺效果", function(s) Visuals.ToggleWeather(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "視距解鎖 (ZoomUnlocker)", "解鎖相機的最大縮放距離", function(s) Visuals.ToggleZoomUnlocker(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "隱身 (Invisible)", "使自己角色對自己透明", function(s) CatFunctions.ToggleInvisible(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "資源透視 (Resource ESP)", "顯示鑽石、翡翠與發電機位置", function(s) Visuals.ToggleResourceESP(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "床位高亮 (Bed ESP)", "強化顯示地圖上所有床位", function(s) Visuals.ToggleBedESP(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "血量顯示", "在玩家頭頂顯示即時血量", function(s) Visuals.ToggleHealthDisplay(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "全亮模式 (FullBright)", "無視地圖陰影與夜晚環境", function(s) Visuals.ToggleFullbright(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "玩家連線 (Tracers)", "在畫面上顯示指向玩家的引導線", function(s) Visuals.ToggleTracers(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "小地圖雷達 (Radar)", "在左側顯示附近的玩家位置", function(s) Visuals.ToggleRadar(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "箱子透視 (Chest ESP)", "顯示地圖上所有箱子的位置", function(s) Visuals.ToggleChestESP(s) end, Notify)
    GUtils.AddScript("視覺顯示 (更多)", "傷害指示器", "顯示造成的傷害數值動畫", function(s) CatFunctions.ToggleDamageIndicator(s) end, Notify)

    local kitTab = GUtils.CreateTab("職業技能")
    GUtils.AddScript("職業技能", "全職業自動技能", "自動偵測並使用當前角色的特殊技能", function(s) Kits.ToggleAutoKitSkill(s) end, Notify)
    GUtils.AddScript("職業技能", "Yuzi 無限衝刺", "利用漏洞實現 Dao 的無限距離/次數衝刺", function(s) Kits.ToggleYuziDashExploit(s) end, Notify)
    GUtils.AddScript("職業技能", "Miner 自動採礦", "自動尋找並開採附近的礦石資源", function(s) Kits.ToggleMinerAutoMine(s) end, Notify)

    local utilityTab = GUtils.CreateTab("工具功能")
    GUtils.AddScript("工具功能", "動畫播放器 (AnimationPlayer)", "開啟動畫播放器介面", function(s) Utility.ToggleAnimationPlayer(s) end, Notify)
    GUtils.AddScript("工具功能", "防布娃娃 (AntiRagdoll)", "防止角色進入跌倒 or 布娃娃狀態", function(s) Utility.ToggleAntiRagdoll(s) end, Notify)
    GUtils.AddScript("工具功能", "自動排隊 (AutoQueue)", "遊戲結束後自動開始下一局", function(s) Utility.ToggleAutoQueue(s) end, Notify)
    GUtils.AddScript("工具功能", "自動重連 (AutoRejoin)", "斷線時自動重新連接伺服器", function(s) CatFunctions.ToggleAutoRejoin(s) end, Notify)
    GUtils.AddScript("工具功能", "閃現 (Blink)", "短時間內儲存位置並瞬間移動", function(s) Utility.ToggleBlink(s) end, Notify)
    GUtils.AddScript("工具功能", "聊天噴子 (ChatSpammer)", "在聊天頻道發送推廣或刷屏訊息", function(s) Utility.ToggleChatSpammer(s) end, Notify)
    GUtils.AddScript("工具功能", "失效器 (Disabler)", "嘗試禁用或繞過特定的反作弊檢測", function(s) Utility.ToggleDisabler(s) end, Notify)
    GUtils.AddScript("工具功能", "緊急停止 (Panic)", "立即關閉所有正在運行的功能", function(s) Utility.TogglePanic(s) end, Notify)
    GUtils.AddScript("工具功能", "立即重連 (Rejoin)", "立即重新連接當前伺服器", function(s) Utility.ToggleRejoin(s) end, Notify)
    GUtils.AddScript("工具功能", "伺服器跳轉 (ServerHop)", "尋找並加入一個新的公共伺服器", function(s) Utility.ToggleServerHop(s) end, Notify)
    GUtils.AddScript("工具功能", "管理員檢測 (StaffDetector)", "當有管理員進入伺服器時發出警告", function(s) CatFunctions.ToggleStaffDetector(s) end, Notify)

    Notify("Halol V5.0.0", "腳本已成功加載！\n請使用介面進行操作", 5)
end)

if not success then
    warn("加載失敗: " .. tostring(err))
    Notify("加載失敗", tostring(err), "Error")
end
