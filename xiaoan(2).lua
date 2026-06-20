--[[
    X-Style Dev Backdoor v7.6 (Fling System + Rainbow FloatWin + Music Player)
    Key: xa3765360431
    - 27-layer anti-cheat bypass system (always on)
    - Advanced aimbot with prediction, FOV, priority, keybind, sticky aim, etc.
    - GitHub images via writefile+getcustomasset (rbxassetid://)
    - Mobile touch flight (joystick + ↑↓ buttons)
    - Speed boost without WalkSpeed modification
    - Draggable floating icon
    - Hitbox expand, Kill Aura, Bunny Hop, Spin Bot, Air Walk
    - All features properly manage connections and state
    - Per-feature anti-cheat bypass
]]

-- ==================== GitHub 图片链接 ====================
local ICON_URL = "https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/XA%E5%9B%BE%E6%A0%87.png"
local BACKGROUND_URL = "https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/XA%E8%8F%9C%E5%8D%95%E8%83%8C%E6%99%AF.png"

-- 音乐URL
local MUSIC_BASE_URL = "https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/"
local MUSIC_LIST = {
    {name = "NIGHT DANCER", file = "NIGHT DANCER.mp3"},
    {name = "Summer express", file = "Summer express.mp3"},
    {name = "UNICUBE!", file = "UNICUBE!.mp3"},
}

-- ==================== Services ====================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ==================== 图片加载函数 ====================
-- 使用 writefile + getcustomasset 将网络图片转为 Roblox 可用的 rbxassetid://
local function tryLoadImage(url, filename)
    local success, data = pcall(function()
        return game:HttpGet(url)
    end)
    if success and data and #data > 0 then
        pcall(function()
            writefile(filename, data)
        end)
        local assetSuccess, assetId = pcall(function()
            return getcustomasset(filename)
        end)
        if assetSuccess and assetId then
            print("[DevTool] 图片加载成功: " .. assetId)
            return assetId
        end
    end
    warn("[DevTool] 图片加载失败，使用默认显示")
    return nil
end

local iconImage = tryLoadImage(ICON_URL, "XA_Icon.png")
local bgImage = tryLoadImage(BACKGROUND_URL, "XA_Bg.png")

-- ==================== LANGUAGE ====================
local Lang = "zh"
local L = {
    activate = {zh="激活", en="Activate"},
    enterKey = {zh="请输入开发者密钥", en="Enter Key"},
    invalidKey = {zh="密钥无效", en="Invalid Key"},
    speed = {zh="速度加成", en="Speed"},
    jump = {zh="超级跳跃", en="Jump Power"},
    fly = {zh="飞行", en="Fly"},
    flySpeed = {zh="飞行速度", en="Fly Speed"},
    noclip = {zh="穿墙", en="NoClip"},
    infjump = {zh="无限跳跃", en="Infinite Jump"},
    teleport = {zh="点击传送", en="Click TP"},
    fullbright = {zh="全图高亮", en="Fullbright"},
    esp = {zh="玩家透视", en="Player ESP"},
    god = {zh="无敌", en="God Mode"},
    time = {zh="时间控制", en="Time"},
    gravity = {zh="重力", en="Gravity"},
    invisible = {zh="隐身", en="Invisible"},
    fov = {zh="视野", en="FOV"},
    nofall = {zh="无跌落伤害", en="No Fall DMG"},
    on = {zh="ON", en="ON"},
    off = {zh="OFF", en="OFF"},
    movement = {zh="移动", en="Move"},
    combat = {zh="战斗", en="Fight"},
    world = {zh="世界", en="World"},
    langSwitch = {zh="EN", en="中文"},
    flyControls = {zh="飞行: 摇杆移动 ↑↓升降 滑动旋转", en="Fly: Joystick move ↑↓Up/Down Swipe rotate"},
    teleported = {zh="已传送", en="Teleported"},
    executed = {zh="已执行", en="executed"},
    activated = {zh="XA DevTool 已激活!", en="XA DevTool Activated!"},
    aimbot = {zh="自瞄", en="Aim"},
    dynAim = {zh="动态自瞄", en="Dynamic Aim"},
    cursorAim = {zh="光标自瞄", en="Cursor Aim"},
    aimPart = {zh="瞄准部位", en="Aim Part"},
    aimRadius = {zh="自瞄范围", en="Aim Radius"},
    aimSmooth = {zh="跟枪平滑", en="Smoothness"},
    teamCheck = {zh="队伍检测", en="Team Check"},
    wallCheck = {zh="穿墙检测", en="Wall Check"},
    lockTarget = {zh="锁定目标", en="Lock Target"},
    blackHole = {zh="黑洞", en="Black Hole"},
    aimHead = {zh="头部", en="Head"},
    aimTorso = {zh="躯干", en="Torso"},
    aimAll = {zh="无差别", en="All"},
    aimNearest = {zh="最近", en="Nearest"},
    -- 新增自瞄选项
    aimPrediction = {zh="弹道预测", en="Prediction"},
    aimPredStrength = {zh="预测强度", en="Pred Strength"},
    aimFovCircle = {zh="FOV圆圈", en="FOV Circle"},
    aimFovSize = {zh="FOV大小", en="FOV Size"},
    aimPriority = {zh="目标优先", en="Priority"},
    aimKey = {zh="瞄准按键", en="Aim Key"},
    aimKeyNone = {zh="无(常驻)", en="None(Always)"},
    aimKeyHold = {zh="按住瞄准", en="Hold"},
    aimShowTarget = {zh="显示目标", en="Show Target"},
    aimDeadzone = {zh="死区范围", en="Deadzone"},
    aimKnockback = {zh="反后坐力", en="Anti-Recoil"},
    aimAutoShoot = {zh="自动射击", en="Auto Shoot"},
    aimSticky = {zh="粘滞瞄准", en="Sticky Aim"},
    aimHealthBar = {zh="血量显示", en="Health Bar"},
    aimTracer = {zh="弹道追踪", en="Tracer"},
    aimClosestBone = {zh="最近骨骼", en="Closest Bone"},
    aimPriorityDist = {zh="最近距离", en="Nearest Dist"},
    aimPriorityHealth = {zh="最低血量", en="Lowest HP"},
    aimPriorityFOV = {zh="FOV中心", en="FOV Center"},
    aimPartHead = {zh="头部", en="Head"},
    aimPartTorso = {zh="躯干", en="Torso"},
    aimPartHRP = {zh="根部", en="Root"},
    aimPartRandom = {zh="随机", en="Random"},
    -- 新增战斗选项
    hitbox = {zh="命中箱扩大", en="Hitbox Expand"},
    hitboxSize = {zh="命中箱大小", en="Hitbox Size"},
    hitboxTransparency = {zh="命中箱透明", en="Hitbox Trans"},
    reach = {zh="攻击距离", en="Attack Reach"},
    reachDist = {zh="攻击距离值", en="Reach Dist"},
    killAura = {zh="杀戮光环", en="Kill Aura"},
    killAuraRange = {zh="光环范围", en="Aura Range"},
    -- 新增移动选项
    bhop = {zh="连跳", en="Bunny Hop"},
    airWalk = {zh="空中行走", en="Air Walk"},
    spinBot = {zh="旋转机器人", en="Spin Bot"},
    spinSpeed = {zh="旋转速度", en="Spin Speed"},
    -- 音乐
    music = {zh="音乐", en="Music"},
    musicPlay = {zh="播放", en="Play"},
    musicPause = {zh="暂停", en="Pause"},
    musicStop = {zh="停止", en="Stop"},
    musicVolume = {zh="音量", en="Volume"},
    musicTime = {zh="播放位置", en="Position"},
    musicLoading = {zh="加载中...", en="Loading..."},
    musicLoaded = {zh="已加载", en="Loaded"},
    musicNowPlaying = {zh="正在播放", en="Now Playing"},
    -- 悬浮窗
    floatWin = {zh="悬浮窗", en="Float"},
    floatWinRemove = {zh="移除悬浮窗", en="Remove Float"},
    clickToRemove = {zh="点击移除", en="Click to Remove"},
    -- 甩飞
    fling = {zh="甩飞", en="Fling"},
    flingPower = {zh="甩飞力度", en="Fling Power"},
    flingRange = {zh="甩飞范围", en="Fling Range"},
    flingMode = {zh="甩飞模式", en="Fling Mode"},
    flingModeAll = {zh="范围内全部", en="All in Range"},
    flingModeNearest = {zh="最近目标", en="Nearest"},
    flingModeTarget = {zh="指定目标", en="Target"},
    flingTarget = {zh="甩飞目标", en="Fling Target"},
    flingExecuted = {zh="已甩飞", en="Flung"},
    flingNoTarget = {zh="无目标", en="No Target"},
    antiFling = {zh="防甩飞", en="Anti-Fling"},
    antiFlingStrength = {zh="防甩飞强度", en="Anti-Fling Str"},
    antiFlingActive = {zh="防甩飞已激活", en="Anti-Fling On"},
    antiFlingBlocked = {zh="已拦截甩飞", en="Fling Blocked"},
    bypassAntiFling = {zh="反防甩飞", en="Bypass Anti-Fling"},
    bypassAntiFlingMode = {zh="绕过模式", en="Bypass Mode"},
    bypassModeForce = {zh="强制位移", en="Force Move"},
    bypassModeVelocity = {zh="高速冲击", en="Velocity Hit"},
    bypassModeMultiHit = {zh="连续冲击", en="Multi Hit"},
    bypassModeExploit = {zh="漏洞利用", en="Exploit"},
    flingAuto = {zh="自动甩飞", en="Auto Fling"},
    flingAutoInterval = {zh="自动间隔", en="Auto Interval"},
}
local function T(key) return L[key] and L[key][Lang] or key end

-- ==================== KEY ====================
local KEY = "xa3765360431"
local active = false

-- ####################################################################
-- ==================== ANTI-CHEAT BYPASS SYSTEM v5 ==================== --
-- 精确匹配策略：只销毁/禁用明确的反作弊实例，不误杀游戏正常功能
-- 不使用任何钩子，纯销毁/禁用
-- ####################################################################

-- === 伪装名称 ===
local FAKE_NAMES = {
    ui = "PlayerList",
    main = "Chat",
    bg = "Background",
    esp = "SelectionBox",
    espLabel = "BillboardGui",
    hitbox = "SpecialMesh",
    tracer = "Trail",
    healthbar = "SurfaceGui",
    notif = "Tooltip",
    icon = "HeadShot",
}

-- === 精确反作弊远程名称（只匹配这些确切名称，不做模糊匹配）===
local AC_EXACT_REMOTES = {
    -- 通用反作弊
    "AntiCheat","AntiExploit","ExploitDetected","ExploitDetect",
    "KickRemote","KickPlayer","AutoKick",
    "SecurityCheck","IntegrityCheck","ValidationCheck",
    "SanityCheck","HeartbeatCheck",
    "SpeedCheck","JumpCheck","FlyCheck","TeleportCheck",
    "NoClipCheck","GodCheck","HackDetected","CheatDetected",
    "SuspiciousActivity","BanPlayer","DetectCheat",
    "WalkSpeedCheck","JumpPowerCheck",
    "AntiHack","KickHack","ReportHack",
    -- Adonis 专用
    "Adonis_AntiCheat","Adonis_Event","Adonis_Function","Adonis_Data",
    "Adonis_Loader","AdonisRemote",
    -- Blox Fruits
    "BloxHack","FruitHack","MainRemotes","CombatRemotes",
    -- Da Hood
    "DaHoodAnti","HoodAnti","HoodKick","DaHoodKick",
    -- Arsenal
    "ArsenalAnti","ArsenalKick","ARS_AntiCheat",
    -- Brookhaven
    "BrookAnti","BrookKick","BH_AntiCheat",
    -- MM2
    "MM2Anti","MM2Kick","MurderAnti",
    -- King Legacy
    "KingAnti","KingKick","KLAntiCheat",
    -- Pet Simulator
    "PetAnti","PetKick","PetSimAnti",
    -- Tower of Hell
    "TOHAnti","TowerAnti","TOHKick",
    -- Adopt Me
    "AdoptAnti","AdoptKick","AM_AntiCheat",
}

-- === 精确反作弊脚本名称（只匹配包含这些关键词的脚本）===
-- 必须是明确的反作弊关键词，不会误杀正常功能
local AC_SCRIPT_KEYWORDS = {
    "anticheat","antihack","antikick","antifly","antispeed",
    "exploitdetect","hackdetect","cheatdetect",
    "adonis_anticheat","adonis_detect",
}

-- === 1. 精确销毁反作弊远程 ===
task.spawn(function()
    pcall(function()
        for _, desc in ipairs(game:GetDescendants()) do
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                local name = desc.Name
                for _, acName in ipairs(AC_EXACT_REMOTES) do
                    if name == acName then
                        pcall(function() desc:Destroy() end)
                        break
                    end
                end
            end
        end
    end)
end)

-- === 2. 精确禁用反作弊脚本 ===
task.spawn(function()
    pcall(function()
        for _, child in ipairs(game:GetDescendants()) do
            if child:IsA("LocalScript") then
                local name = child.Name:lower()
                for _, kw in ipairs(AC_SCRIPT_KEYWORDS) do
                    if name:find(kw) then
                        pcall(function() child.Disabled = true end)
                        break
                    end
                end
            end
        end
    end)
end)

-- === 3. Adonis 文件夹精确销毁 ===
-- 只销毁明确属于 Adonis 的文件夹，不销毁通用名称
task.spawn(function()
    pcall(function()
        local adonisExactPaths = {
            {game:GetService("ReplicatedStorage"), "Adonis"},
            {game:GetService("ReplicatedStorage"), "Adonis_Loader"},
            {game:GetService("ReplicatedStorage"), "Adonis_AntiCheat"},
        }
        for _, pathData in ipairs(adonisExactPaths) do
            local child = pathData[1]:FindFirstChild(pathData[2])
            if child then
                pcall(function() child:Destroy() end)
            end
        end
    end)
end)

-- === 4. 持续监控（精确匹配）===
task.spawn(function()
    pcall(function()
        game.DescendantAdded:Connect(function(desc)
            -- 远程
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                local name = desc.Name
                for _, acName in ipairs(AC_EXACT_REMOTES) do
                    if name == acName then
                        task.defer(function() pcall(function() desc:Destroy() end) end)
                        break
                    end
                end
            end
            -- 脚本
            if desc:IsA("LocalScript") then
                local name = desc.Name:lower()
                for _, kw in ipairs(AC_SCRIPT_KEYWORDS) do
                    if name:find(kw) then
                        task.defer(function() pcall(function() desc.Disabled = true end) end)
                        break
                    end
                end
            end
        end)
    end)
end)

-- === 5. Character 反作弊脚本禁用 ===
task.spawn(function()
    pcall(function()
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("LocalScript") or child:IsA("Script") then
                    local name = child.Name:lower()
                    for _, kw in ipairs(AC_SCRIPT_KEYWORDS) do
                        if name:find(kw) then
                            pcall(function() child.Disabled = true end)
                            break
                        end
                    end
                end
            end
        end)
    end)
end)

print("[DevTool] Anti-Cheat Bypass v5 loaded - Precise matching only")

-- ==================== Feature State Manager ====================
-- 集中管理所有功能的连接和状态，防止泄漏
local featureStates = {}

local function createFeatureState(name)
    featureStates[name] = {
        enabled = false,
        connections = {},
        savedValues = {},
        instances = {},
    }
    return featureStates[name]
end

local function cleanupFeature(name)
    local state = featureStates[name]
    if not state then return end
    -- 断开所有连接
    for _, conn in ipairs(state.connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    state.connections = {}
    -- 销毁所有实例
    for _, inst in ipairs(state.instances) do
        pcall(function() inst:Destroy() end)
    end
    state.instances = {}
    state.enabled = false
end

local function addConnection(name, conn)
    table.insert(featureStates[name].connections, conn)
    return conn
end

local function addInstance(name, inst)
    table.insert(featureStates[name].instances, inst)
    return inst
end

-- ==================== Character Helper ====================
local function getCharacter()
    local ch = player.Character
    if ch and ch.Parent then return ch end
    return nil
end

local function getHumanoid()
    local ch = getCharacter()
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum and hum.Parent then return hum end
    end
    return nil
end

local function getHRP()
    local ch = getCharacter()
    if ch then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Parent then return hrp end
    end
    return nil
end

-- ==================== TWEEN HELPER ====================
local function tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ==================== BLUR ====================
local blur = nil
local function enableBlur()
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Size = 24
        blur.Parent = Camera
    end
end
local function disableBlur()
    if blur then blur:Destroy(); blur = nil end
end

-- ==================== NOTIFICATIONS ====================
local NotifGui = Instance.new("ScreenGui"); NotifGui.Name = FAKE_NAMES.notif; NotifGui.Parent = CoreGui
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 240, 1, -20); notifFrame.Position = UDim2.new(1, -250, 0, 10)
notifFrame.BackgroundTransparency = 1; notifFrame.BorderSizePixel = 0; notifFrame.Parent = NotifGui

local notifList = Instance.new("UIListLayout"); notifList.Padding = UDim.new(0, 8)
notifList.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.SortOrder = Enum.SortOrder.LayoutOrder; notifList.Parent = notifFrame

local function notif(text)
    local nf = Instance.new("Frame"); nf.Size = UDim2.new(1, 0, 0, 36)
    nf.BackgroundColor3 = Color3.fromRGB(22,24,28); nf.BorderSizePixel = 0
    nf.BackgroundTransparency = 0.2; nf.Parent = notifFrame
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,12); nc.Parent = nf
    local nl = Instance.new("TextLabel"); nl.Text = text; nl.Font = Enum.Font.GothamMedium
    nl.TextSize = 14; nl.TextColor3 = Color3.fromRGB(255,255,255); nl.BackgroundTransparency = 1
    nl.Size = UDim2.new(1,-16,1,0); nl.Position = UDim2.new(0,8,0,0); nl.Parent = nf
    nf.AnchorPoint = Vector2.new(1,0); nf.Position = UDim2.new(1,0,1,-20)
    tween(nf, {Position = UDim2.new(1,0,1,-(36+8)*(#notifFrame:GetChildren()-1)-20)}, 0.25, Enum.EasingStyle.Back)
    task.delay(2, function()
        tween(nf, {BackgroundTransparency = 1}, 0.5); tween(nl, {TextTransparency = 1}, 0.5)
        task.delay(0.5, function() nf:Destroy() end)
    end)
end

-- ==================== SHADOW ====================
local function addShadow(parent, offX, offY, radius)
    local shadow = Instance.new("Frame"); shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1,0,1,0); shadow.Position = UDim2.new(0, offX or 6, 0, offY or 6)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0); shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0; shadow.ZIndex = parent.ZIndex - 1; shadow.Parent = parent
    if radius then local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,radius); c.Parent = shadow end
    return shadow
end

-- ==================== MAIN GUI ====================
local MainGui = Instance.new("ScreenGui"); MainGui.Name = FAKE_NAMES.ui; MainGui.Parent = CoreGui
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; MainGui.IgnoreGuiInset = true

-- ==================== ACTIVATION ====================
local ActFrame = Instance.new("Frame")
ActFrame.Size = UDim2.new(0, 300, 0, 200); ActFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
ActFrame.BackgroundColor3 = Color3.fromRGB(10,10,10); ActFrame.BorderSizePixel = 0; ActFrame.ZIndex = 10; ActFrame.Parent = MainGui
local ActCorner = Instance.new("UICorner"); ActCorner.CornerRadius = UDim.new(0,20); ActCorner.Parent = ActFrame
addShadow(ActFrame, 8, 8, 20)
local ActStroke = Instance.new("UIStroke"); ActStroke.Color = Color3.fromRGB(47,51,54)
ActStroke.Thickness = 1; ActStroke.Parent = ActFrame

-- XA 标题文字（始终显示）
local XATitle = Instance.new("TextLabel"); XATitle.Text = "XA"
XATitle.Font = Enum.Font.GothamBold; XATitle.TextSize = 36
XATitle.TextColor3 = Color3.fromRGB(29,155,240); XATitle.BackgroundTransparency = 1
XATitle.Size = UDim2.new(1,0,0,44); XATitle.Position = UDim2.new(0,0,0,10)
XATitle.ZIndex = 11; XATitle.Parent = ActFrame

if iconImage then
    local ActIcon = Instance.new("ImageLabel")
    ActIcon.Size = UDim2.new(0, 40, 0, 40); ActIcon.Position = UDim2.new(0.5, -20, 0, 8)
    ActIcon.BackgroundTransparency = 1; ActIcon.Image = iconImage
    ActIcon.ScaleType = Enum.ScaleType.Fit; ActIcon.ZIndex = 12; ActIcon.Parent = ActFrame
    XATitle.Visible = false
else
    XATitle.Visible = true
end

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Text = T("enterKey"); KeyTitle.Font = Enum.Font.GothamMedium; KeyTitle.TextSize = 13
KeyTitle.TextColor3 = Color3.fromRGB(150,155,160); KeyTitle.BackgroundTransparency = 1
KeyTitle.Size = UDim2.new(1,-40,0,18); KeyTitle.Position = UDim2.new(0,20,0,55)
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left; KeyTitle.ZIndex = 11; KeyTitle.Parent = ActFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1,-40,0,36); KeyBox.Position = UDim2.new(0,20,0,74)
KeyBox.BackgroundColor3 = Color3.fromRGB(30,30,30); KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
KeyBox.Font = Enum.Font.GothamMedium; KeyBox.TextSize = 14; KeyBox.BorderSizePixel = 0; KeyBox.Text = ""
KeyBox.PlaceholderText = "Key..."; KeyBox.ClearTextOnFocus = false; KeyBox.ZIndex = 11; KeyBox.Parent = ActFrame
local KeyCorner = Instance.new("UICorner"); KeyCorner.CornerRadius = UDim.new(0,12); KeyCorner.Parent = KeyBox

local ActBtn = Instance.new("TextButton")
ActBtn.Text = T("activate"); ActBtn.Font = Enum.Font.GothamBold; ActBtn.TextSize = 14
ActBtn.TextColor3 = Color3.fromRGB(255,255,255); ActBtn.BackgroundColor3 = Color3.fromRGB(29,155,240)
ActBtn.Size = UDim2.new(1,-40,0,38); ActBtn.Position = UDim2.new(0,20,0,118)
ActBtn.BorderSizePixel = 0; ActBtn.AutoButtonColor = false; ActBtn.ZIndex = 11; ActBtn.Parent = ActFrame
local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0,19); BtnCorner.Parent = ActBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = ""; StatusLabel.Font = Enum.Font.GothamMedium; StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(255,80,80); StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1,-40,0,18); StatusLabel.Position = UDim2.new(0,20,0,160)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center; StatusLabel.ZIndex = 11; StatusLabel.Parent = ActFrame

-- ==================== FLOATING ICON ====================
local FloatIcon = Instance.new("ImageButton")
FloatIcon.Size = UDim2.new(0, 52, 0, 52); FloatIcon.Position = UDim2.new(0, 20, 0, 20)
FloatIcon.BackgroundColor3 = Color3.fromRGB(29,155,240)
FloatIcon.BorderSizePixel = 0; FloatIcon.AutoButtonColor = false; FloatIcon.Visible = false; FloatIcon.ZIndex = 10; FloatIcon.Parent = MainGui
local IconCorner = Instance.new("UICorner"); IconCorner.CornerRadius = UDim.new(0,26); IconCorner.Parent = FloatIcon
addShadow(FloatIcon, 4, 4, 26)

if iconImage then
    FloatIcon.Image = iconImage; FloatIcon.BackgroundTransparency = 1; FloatIcon.ScaleType = Enum.ScaleType.Fit
else
    FloatIcon.BackgroundColor3 = Color3.fromRGB(29,155,240); FloatIcon.BackgroundTransparency = 0
    local FloatText = Instance.new("TextLabel"); FloatText.Text = "XA"
    FloatText.Font = Enum.Font.GothamBold; FloatText.TextSize = 22
    FloatText.TextColor3 = Color3.fromRGB(255,255,255); FloatText.BackgroundTransparency = 1
    FloatText.Size = UDim2.new(1,0,1,0); FloatText.ZIndex = 2; FloatText.Parent = FloatIcon
end

-- 图标拖拽功能
local iconDragging = false
local iconDragStart = nil
local iconStartPos = nil
local iconDragMoved = false

FloatIcon.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconDragStart = inp.Position
        iconStartPos = FloatIcon.Position
        iconDragMoved = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if iconDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - iconDragStart
        if delta.Magnitude > 5 then
            iconDragMoved = true
            FloatIcon.Position = UDim2.new(
                iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X,
                iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        iconDragging = false
    end
end)

-- ==================== MAIN WINDOW ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 320); MainFrame.Position = UDim2.new(0.5, -320, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 5; MainFrame.Parent = MainGui

if bgImage then
    local MainBg = Instance.new("ImageLabel"); MainBg.Size = UDim2.new(1,0,1,0); MainBg.Position = UDim2.new(0,0,0,0)
    MainBg.BackgroundTransparency = 1; MainBg.Image = bgImage; MainBg.ImageTransparency = 0.3
    MainBg.ScaleType = Enum.ScaleType.Crop; MainBg.ZIndex = 0; MainBg.Parent = MainFrame
    MainBg.Name = FAKE_NAMES.bg
else
    -- 无背景图时使用半透明黑色背景
    MainFrame.BackgroundTransparency = 0.15
end

local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0,24); MainCorner.Parent = MainFrame
addShadow(MainFrame, 10, 10, 24)
local MainStroke = Instance.new("UIStroke"); MainStroke.Color = Color3.fromRGB(60,65,70)
MainStroke.Thickness = 1.5; MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,38); TopBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
TopBar.BackgroundTransparency = 0.5; TopBar.BorderSizePixel = 0; TopBar.ZIndex = 2; TopBar.Parent = MainFrame

if iconImage then
    local TitleIcon = Instance.new("ImageLabel")
    TitleIcon.Size = UDim2.new(0,22,0,22); TitleIcon.Position = UDim2.new(0,12,0,8)
    TitleIcon.BackgroundTransparency = 1; TitleIcon.Image = iconImage
    TitleIcon.ScaleType = Enum.ScaleType.Fit; TitleIcon.ZIndex = 5; TitleIcon.Parent = TopBar
end

local Title = Instance.new("TextLabel")
Title.Text = "DevTool / XA"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255,255,255); Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0,200,1,0); Title.Position = UDim2.new(0, iconImage and 38 or 12, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 3; Title.Parent = TopBar

local FlyHelp = Instance.new("TextLabel"); FlyHelp.Text = ""
FlyHelp.Font = Enum.Font.GothamMedium; FlyHelp.TextSize = 10
FlyHelp.TextColor3 = Color3.fromRGB(150,155,160); FlyHelp.BackgroundTransparency = 1
FlyHelp.Size = UDim2.new(0,250,1,0); FlyHelp.Position = UDim2.new(0,180,0,0)
FlyHelp.TextXAlignment = Enum.TextXAlignment.Left; FlyHelp.ZIndex = 3; FlyHelp.Parent = TopBar

local LangBtn = Instance.new("TextButton")
LangBtn.Text = T("langSwitch"); LangBtn.Font = Enum.Font.GothamBold; LangBtn.TextSize = 11
LangBtn.TextColor3 = Color3.fromRGB(255,255,255); LangBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
LangBtn.Size = UDim2.new(0,36,0,24); LangBtn.Position = UDim2.new(1,-120,0,7)
LangBtn.BorderSizePixel = 0; LangBtn.ZIndex = 3; LangBtn.Parent = TopBar
local LangCorner = Instance.new("UICorner"); LangCorner.CornerRadius = UDim.new(0,12); LangCorner.Parent = LangBtn

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "─"; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(255,255,255); MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.Size = UDim2.new(0,36,0,24); MinBtn.Position = UDim2.new(1,-78,0,7)
MinBtn.BorderSizePixel = 0; MinBtn.ZIndex = 3; MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner"); MinCorner.CornerRadius = UDim.new(0,12); MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
CloseBtn.Size = UDim2.new(0,36,0,24); CloseBtn.Position = UDim2.new(1,-38,0,7)
CloseBtn.BorderSizePixel = 0; CloseBtn.ZIndex = 3; CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner"); CloseCorner.CornerRadius = UDim.new(0,12); CloseCorner.Parent = CloseBtn

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,34); TabBar.Position = UDim2.new(0,0,0,38)
TabBar.BackgroundColor3 = Color3.fromRGB(0,0,0); TabBar.BackgroundTransparency = 0.5
TabBar.BorderSizePixel = 0; TabBar.ZIndex = 2; TabBar.Parent = MainFrame

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0.19,0,0,3); TabIndicator.Position = UDim2.new(0.005,0,1,-3)
TabIndicator.BackgroundColor3 = Color3.fromRGB(29,155,240); TabIndicator.BorderSizePixel = 0
TabIndicator.ZIndex = 3; TabIndicator.Parent = TabBar

local tabs = {"movement","combat","world","aimbot","music"}
local curTab = "movement"
local tabBtns = {}
for i, tab in ipairs(tabs) do
    local b = Instance.new("TextButton"); b.Text = T(tab); b.Font = Enum.Font.GothamMedium; b.TextSize = 11
    b.TextColor3 = i==1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,185,190)
    b.BackgroundTransparency = 1; b.Size = UDim2.new(1/5,-6,1,0)
    b.Position = UDim2.new((i-1)/5,3,0,0); b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = TabBar
    tabBtns[tab] = b
end

-- Pages
local pages = {}
for _, tab in ipairs(tabs) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,-72); page.Position = UDim2.new(0,0,0,72)
    page.BackgroundColor3 = Color3.fromRGB(0,0,0); page.BackgroundTransparency = 0.7
    page.BorderSizePixel = 0; page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(29,155,240)
    page.CanvasSize = UDim2.new(0,0,0,0); page.Visible = false; page.ZIndex = 1; page.Parent = MainFrame
    local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0,8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = page
    local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0,10)
    pad.PaddingLeft = UDim.new(0,12); pad.PaddingRight = UDim.new(0,12); pad.Parent = page
    pages[tab] = {frame = page, list = list}
end

local function switchTab(t)
    curTab = t; local idx = table.find(tabs, t)
    tween(TabIndicator, {Position = UDim2.new((idx-1)/5+0.005,0,1,-3)}, 0.3, Enum.EasingStyle.Quart)
    for tn, btn in pairs(tabBtns) do
        tween(btn, {TextColor3 = tn==t and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,185,190)}, 0.2)
    end
    for tn, page in pairs(pages) do
        page.frame.Visible = (tn==t)
        if tn==t then page.frame.CanvasSize = UDim2.new(0,0,0, page.list.AbsoluteContentSize.Y+32) end
    end
end
for tn, btn in pairs(tabBtns) do btn.MouseButton1Click:Connect(function() switchTab(tn) end) end

-- ==================== FEATURE BUILDER ====================
local allFeatures = {}
local allFeaturesByKey = {}

local function CreateFeature(name, type, pageName, opt)
    opt = opt or {}
    local container, list = pages[pageName].frame, pages[pageName].list

    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,-20,0,42)
    Frame.BackgroundColor3 = Color3.fromRGB(22,24,28); Frame.BackgroundTransparency = 0.4
    Frame.BorderSizePixel = 0; Frame.ZIndex = 1; Frame.Parent = container
    local FrameCorner = Instance.new("UICorner"); FrameCorner.CornerRadius = UDim.new(0,12); FrameCorner.Parent = Frame
    addShadow(Frame, 3, 3, 12)

    local NameLabel = Instance.new("TextLabel"); NameLabel.Text = T(name)
    NameLabel.Font = Enum.Font.GothamMedium; NameLabel.TextSize = 13
    NameLabel.TextColor3 = Color3.fromRGB(240,240,240); NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.new(0,120,1,0); NameLabel.Position = UDim2.new(0,12,0,0)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left; NameLabel.ZIndex = 2; NameLabel.Parent = Frame

    local feat = {frame = Frame, type = type, key = name}

    if type == "Toggle" then
        local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Text = T("off")
        ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 11
        ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255); ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        ToggleBtn.Size = UDim2.new(0,50,0,26); ToggleBtn.Position = UDim2.new(1,-62,0.5,-13)
        ToggleBtn.BorderSizePixel = 0; ToggleBtn.AutoButtonColor = false; ToggleBtn.ZIndex = 2; ToggleBtn.Parent = Frame
        local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(0,13); ToggleCorner.Parent = ToggleBtn
        local state = false
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state; ToggleBtn.Text = state and T("on") or T("off")
            tween(ToggleBtn, {BackgroundColor3 = state and Color3.fromRGB(29,155,240) or Color3.fromRGB(60,60,60)}, 0.2)
            if opt.onToggle then opt.onToggle(state) end
            notif(T(name) .. ": " .. (state and T("on") or T("off")))
        end)
        feat.toggle = ToggleBtn
        feat.getState = function() return state end
        feat.setState = function(s)
            state = s
            ToggleBtn.Text = state and T("on") or T("off")
            tween(ToggleBtn, {BackgroundColor3 = state and Color3.fromRGB(29,155,240) or Color3.fromRGB(60,60,60)}, 0.2)
            if opt.onToggle then opt.onToggle(state) end
        end

    elseif type == "Slider" then
        local ValLabel = Instance.new("TextLabel"); ValLabel.Text = tostring(opt.default or 16)
        ValLabel.Font = Enum.Font.GothamMedium; ValLabel.TextSize = 12
        ValLabel.TextColor3 = Color3.fromRGB(200,200,200); ValLabel.BackgroundTransparency = 1
        ValLabel.Size = UDim2.new(0,36,1,0); ValLabel.Position = UDim2.new(1,-44,0,0); ValLabel.ZIndex = 2; ValLabel.Parent = Frame

        local Track = Instance.new("Frame"); Track.Size = UDim2.new(0,100,0,5); Track.Position = UDim2.new(1,-160,0.5,-2.5)
        Track.BackgroundColor3 = Color3.fromRGB(50,50,50); Track.BorderSizePixel = 0; Track.ZIndex = 2; Track.Parent = Frame
        local TrackCorner = Instance.new("UICorner"); TrackCorner.CornerRadius = UDim.new(0,3); TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        local ratio = (opt.default-(opt.min or 1))/((opt.max or 100)-(opt.min or 1))
        Fill.Size = UDim2.new(ratio,0,1,0); Fill.BackgroundColor3 = Color3.fromRGB(29,155,240)
        Fill.BorderSizePixel = 0; Fill.ZIndex = 2; Fill.Parent = Track
        local FillCorner = Instance.new("UICorner"); FillCorner.CornerRadius = UDim.new(0,3); FillCorner.Parent = Fill

        local Knob = Instance.new("TextButton"); Knob.Size = UDim2.new(0,14,0,14)
        Knob.Position = UDim2.new(ratio,-7,0.5,-7); Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Knob.Text = ""; Knob.BorderSizePixel = 0; Knob.AutoButtonColor = false; Knob.ZIndex = 3; Knob.Parent = Track
        local KnobCorner = Instance.new("UICorner"); KnobCorner.CornerRadius = UDim.new(0,9); KnobCorner.Parent = Knob

        local val = opt.default; local min, max = opt.min or 1, opt.max or 100; local dragging = false
        local function update(pos)
            local rel = math.clamp((pos.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
            val = math.floor(min+rel*(max-min)+0.5); ValLabel.Text = tostring(val)
            Fill.Size = UDim2.new(rel,0,1,0); Knob.Position = UDim2.new(rel,-7,0.5,-7)
            if opt.onChange then opt.onChange(val) end
        end
        Knob.MouseButton1Down:Connect(function() dragging = true end)
        Track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(inp.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then update(inp.Position) end
        end)
        feat.getValue = function() return val end
        feat.setValue = function(v)
            val = math.clamp(v, min, max)
            local r = (val-min)/(max-min)
            ValLabel.Text = tostring(val)
            Fill.Size = UDim2.new(r,0,1,0)
            Knob.Position = UDim2.new(r,-7,0.5,-7)
            if opt.onChange then opt.onChange(val) end
        end

    elseif type == "Button" then
        local Btn = Instance.new("TextButton"); Btn.Text = opt.text or T("execute")
        Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Btn.TextColor3 = Color3.fromRGB(255,255,255)
        Btn.BackgroundColor3 = Color3.fromRGB(29,155,240); Btn.Size = UDim2.new(0,70,0,28)
        Btn.Position = UDim2.new(1,-82,0.5,-14); Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false; Btn.ZIndex = 2; Btn.Parent = Frame
        local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0,14); BtnCorner.Parent = Btn
        Btn.MouseButton1Click:Connect(function()
            tween(Btn, {BackgroundColor3 = Color3.fromRGB(18,120,200)}, 0.1)
            task.wait(0.1); tween(Btn, {BackgroundColor3 = Color3.fromRGB(29,155,240)}, 0.1)
            if opt.onClick then opt.onClick() end; notif(T(name).." "..T("executed"))
        end)
    end
    table.insert(allFeatures, feat); allFeaturesByKey[name] = feat; container.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y+32)
    return feat
end

-- ==================== FLIGHT SYSTEM (Mobile Touch) ====================
local flyState = {
    enabled = false,
    speed = 50,
    bodyGyro = nil,
    bodyVelocity = nil,
    renderConn = nil,
    touchConn = nil,
    touchStart = nil,
    cameraAngleX = 0,
    cameraAngleY = 0,
    flyUp = false,
    flyDown = false,
}

-- 飞行触屏按钮
local flyUpBtn = nil
local flyDownBtn = nil

local function createFlyButtons()
    if flyUpBtn then pcall(function() flyUpBtn:Destroy() end) end
    if flyDownBtn then pcall(function() flyDownBtn:Destroy() end) end

    -- 上升按钮
    flyUpBtn = Instance.new("TextButton")
    flyUpBtn.Text = "↑"; flyUpBtn.Font = Enum.Font.GothamBold; flyUpBtn.TextSize = 24
    flyUpBtn.TextColor3 = Color3.fromRGB(255,255,255); flyUpBtn.BackgroundColor3 = Color3.fromRGB(29,155,240)
    flyUpBtn.Size = UDim2.new(0, 56, 0, 56); flyUpBtn.Position = UDim2.new(1, -70, 0.5, -70)
    flyUpBtn.BackgroundTransparency = 0.3; flyUpBtn.BorderSizePixel = 0
    flyUpBtn.AutoButtonColor = false; flyUpBtn.Visible = false; flyUpBtn.ZIndex = 50; flyUpBtn.Parent = MainGui
    local upCorner = Instance.new("UICorner"); upCorner.CornerRadius = UDim.new(0, 28); upCorner.Parent = flyUpBtn

    -- 下降按钮
    flyDownBtn = Instance.new("TextButton")
    flyDownBtn.Text = "↓"; flyDownBtn.Font = Enum.Font.GothamBold; flyDownBtn.TextSize = 24
    flyDownBtn.TextColor3 = Color3.fromRGB(255,255,255); flyDownBtn.BackgroundColor3 = Color3.fromRGB(29,155,240)
    flyDownBtn.Size = UDim2.new(0, 56, 0, 56); flyDownBtn.Position = UDim2.new(1, -70, 0.5, 0)
    flyDownBtn.BackgroundTransparency = 0.3; flyDownBtn.BorderSizePixel = 0
    flyDownBtn.AutoButtonColor = false; flyDownBtn.Visible = false; flyDownBtn.ZIndex = 50; flyDownBtn.Parent = MainGui
    local downCorner = Instance.new("UICorner"); downCorner.CornerRadius = UDim.new(0, 28); downCorner.Parent = flyDownBtn

    -- 触摸事件
    flyUpBtn.MouseButton1Down:Connect(function() flyState.flyUp = true end)
    flyUpBtn.MouseButton1Up:Connect(function() flyState.flyUp = false end)
    flyDownBtn.MouseButton1Down:Connect(function() flyState.flyDown = true end)
    flyDownBtn.MouseButton1Up:Connect(function() flyState.flyDown = false end)
end
createFlyButtons()

local function startFlight()
    local hrp = getHRP()
    if not hrp then return end

    -- 清理旧的飞行实例
    if flyState.bodyGyro and flyState.bodyGyro.Parent then flyState.bodyGyro:Destroy() end
    if flyState.bodyVelocity and flyState.bodyVelocity.Parent then flyState.bodyVelocity:Destroy() end
    if flyState.renderConn then pcall(function() flyState.renderConn:Disconnect() end) end
    if flyState.touchConn then pcall(function() flyState.touchConn:Disconnect() end) end

    local bg = Instance.new("BodyGyro"); bg.P = 9e4; bg.maxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = Camera.CFrame; bg.Parent = hrp; flyState.bodyGyro = bg
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = Vector3.new(0,0,0); bv.Parent = hrp; flyState.bodyVelocity = bv

    local lookVector = Camera.CFrame.LookVector
    flyState.cameraAngleX = math.atan2(lookVector.X, lookVector.Z)
    flyState.cameraAngleY = math.asin(math.clamp(lookVector.Y, -1, 1))

    -- 显示飞行按钮
    flyUpBtn.Visible = true
    flyDownBtn.Visible = true

    flyState.renderConn = RunService.RenderStepped:Connect(function()
        if not flyState.enabled then return end
        local currentHrp = getHRP()
        if not currentHrp then return end
        if not flyState.bodyGyro or not flyState.bodyGyro.Parent then return end
        if not flyState.bodyVelocity or not flyState.bodyVelocity.Parent then return end

        -- 跟随摄像机方向
        local camLook = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        flyState.bodyGyro.CFrame = Camera.CFrame

        -- 使用 Humanoid.MoveDirection（手机摇杆自动映射）
        local hum = getHumanoid()
        local moveDir = Vector3.new()
        if hum then
            moveDir = hum.MoveDirection
        end

        -- 上升/下降
        if flyState.flyUp then moveDir += Vector3.new(0,1,0) end
        if flyState.flyDown then moveDir -= Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            flyState.bodyVelocity.Velocity = moveDir.Unit * flyState.speed
        else
            flyState.bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end)

    -- 触摸旋转相机（在屏幕空白区域滑动）
    flyState.touchStart = nil
    flyState.touchConn = UserInputService.TouchMoved:Connect(function(touch, processed)
        if not flyState.enabled then return end
        if processed then return end
        if not flyState.touchStart then flyState.touchStart = touch.Position; return end
        local delta = touch.Position - flyState.touchStart; local sensitivity = 0.005
        flyState.cameraAngleX = flyState.cameraAngleX - delta.X*sensitivity
        flyState.cameraAngleY = math.clamp(flyState.cameraAngleY - delta.Y*sensitivity, -math.pi/2+0.1, math.pi/2-0.1)
        flyState.touchStart = touch.Position
    end)
end

local function stopFlight()
    flyState.enabled = false
    flyState.flyUp = false
    flyState.flyDown = false
    if flyState.renderConn then pcall(function() flyState.renderConn:Disconnect() end); flyState.renderConn = nil end
    if flyState.touchConn then pcall(function() flyState.touchConn:Disconnect() end); flyState.touchConn = nil end
    if flyState.bodyGyro and flyState.bodyGyro.Parent then flyState.bodyGyro:Destroy() end
    if flyState.bodyVelocity and flyState.bodyVelocity.Parent then flyState.bodyVelocity:Destroy() end
    flyState.bodyGyro = nil; flyState.bodyVelocity = nil; flyState.touchStart = nil
    -- 隐藏飞行按钮
    if flyUpBtn then flyUpBtn.Visible = false end
    if flyDownBtn then flyDownBtn.Visible = false end
end

-- ==================== FEATURE STATE VARIABLES ====================
-- 在功能注册前定义所有状态变量，避免引用未定义变量
local tpEnabled = false
local speedFeature, jumpFeature, flyFeature, flySpeedFeature
local noclipFeature, infjumpFeature, teleportFeature
local fullbrightFeature, espFeature, godFeature, nofallFeature
local timeFeature, gravityFeature, invisibleFeature, fovFeature

-- 保存原始值用于恢复
local savedLighting = {
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
}
local savedGravity = Workspace.Gravity
local savedFOV = Camera.FieldOfView

-- noclip: 保存原始 CanCollide 值
local noclipSavedCollisions = {}

-- invisible: 保存原始透明度
local invisibleSavedTransparency = {}

-- ==================== FEATURES ====================

-- === Speed ===
-- 使用 RenderStepped 移动加速，不修改 WalkSpeed（避免服务端反作弊检测掉血）
createFeatureState("speed")
local targetSpeed = 16
local speedConn = nil
speedFeature = CreateFeature("speed", "Slider", "movement", {default=16, min=16, max=200, onChange=function(v)
    targetSpeed = v
end})

local function applySpeedBoost()
    if speedConn then pcall(function() speedConn:Disconnect() end) end
    speedConn = RunService.RenderStepped:Connect(function(dt)
        if targetSpeed <= 16 then return end
        local hum = getHumanoid()
        local hrp = getHRP()
        if not hum or not hrp then return end
        -- 保持 WalkSpeed 为 16，不触发反作弊
        if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local boost = (targetSpeed - 16) * dt
            hrp.CFrame = hrp.CFrame + moveDir * boost
        end
    end)
    addConnection("speed", speedConn)
end
applySpeedBoost()

-- === Jump ===
createFeatureState("jump")
jumpFeature = CreateFeature("jump", "Slider", "movement", {default=50, min=50, max=300, onChange=function(v)
    local hum = getHumanoid()
    if hum then hum.JumpPower = v end
end})

-- === Fly ===
createFeatureState("fly")
flyFeature = CreateFeature("fly", "Toggle", "movement", {onToggle=function(state)
    flyState.enabled = state
    if state then
        startFlight()
        FlyHelp.Text = T("flyControls")
    else
        stopFlight()
        FlyHelp.Text = ""
    end
end})

-- === Fly Speed ===
flySpeedFeature = CreateFeature("flySpeed", "Slider", "movement", {default=50, min=10, max=200, onChange=function(v)
    flyState.speed = v
end})

-- === NoClip ===
createFeatureState("noclip")
noclipFeature = CreateFeature("noclip", "Toggle", "movement", {onToggle=function(state)
    local fs = featureStates.noclip
    if state then
        -- 保存原始碰撞状态
        noclipSavedCollisions = {}
        local ch = getCharacter()
        if ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    noclipSavedCollisions[p] = p.CanCollide
                end
            end
        end
        -- 使用 Stepped 每帧禁用碰撞
        local conn = RunService.Stepped:Connect(function()
            if not fs.enabled then return end
            local currentCh = getCharacter()
            if currentCh then
                for _, p in ipairs(currentCh:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
        addConnection("noclip", conn)
        fs.enabled = true
    else
        cleanupFeature("noclip")
        -- 恢复原始碰撞状态
        local ch = getCharacter()
        if ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and noclipSavedCollisions[p] ~= nil then
                    p.CanCollide = noclipSavedCollisions[p]
                end
            end
        end
        noclipSavedCollisions = {}
    end
end})

-- === Infinite Jump ===
createFeatureState("infjump")
infjumpFeature = CreateFeature("infjump", "Toggle", "movement", {onToggle=function(state)
    local fs = featureStates.infjump
    if state then
        local conn = UserInputService.JumpRequest:Connect(function()
            local hum = getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        addConnection("infjump", conn)
        fs.enabled = true
    else
        cleanupFeature("infjump")
    end
end})

-- === Click Teleport ===
createFeatureState("teleport")
teleportFeature = CreateFeature("teleport", "Toggle", "movement", {onToggle=function(state)
    tpEnabled = state
    featureStates.teleport.enabled = state
end})

-- === Fullbright ===
createFeatureState("fullbright")
fullbrightFeature = CreateFeature("fullbright", "Toggle", "combat", {onToggle=function(state)
    if state then
        -- 保存当前值
        savedLighting.Brightness = Lighting.Brightness
        savedLighting.GlobalShadows = Lighting.GlobalShadows
        savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        -- 应用全亮
        Lighting.Brightness = 3
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        featureStates.fullbright.enabled = true
    else
        -- 恢复原始值
        Lighting.Brightness = savedLighting.Brightness
        Lighting.GlobalShadows = savedLighting.GlobalShadows
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        featureStates.fullbright.enabled = false
    end
end})

-- === ESP ===
createFeatureState("esp")
local espHighlights = {}
local espLabels = {}

local function createESPForPlayer(plr)
    if plr == player then return end
    if espHighlights[plr] then return end

    local function applyESP(char)
        if not char then return end
        -- 清理旧的
        if espHighlights[plr] then pcall(function() espHighlights[plr]:Destroy() end) end
        if espLabels[plr] then pcall(function() espLabels[plr]:Destroy() end) end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp then return end

        -- 高亮
        local hl = Instance.new("Highlight")
        hl.Name = FAKE_NAMES.esp
        hl.FillColor = Color3.fromRGB(255,50,50)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.OutlineTransparency = 0
        hl.Adornee = char
        hl.Parent = char
        espHighlights[plr] = hl

        -- 名称+距离标签
        local billboard = Instance.new("BillboardGui")
        billboard.Name = FAKE_NAMES.espLabel
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 500
        billboard.Adornee = head or hrp
        billboard.Parent = char

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Text = plr.Name
        nameLabel.Parent = billboard

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(200,200,200)
        distLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        distLabel.TextStrokeTransparency = 0
        distLabel.Font = Enum.Font.GothamMedium
        distLabel.TextSize = 11
        distLabel.Text = ""
        distLabel.Parent = billboard

        espLabels[plr] = {billboard = billboard, distLabel = distLabel}
    end

    if plr.Character then applyESP(plr.Character) end
    -- 监听角色加载
    local charConn = plr.CharacterAdded:Connect(function(char)
        task.wait(1) -- 等待角色完全加载
        if featureStates.esp.enabled then applyESP(char) end
    end)
    addConnection("esp", charConn)
end

local function removeESPForPlayer(plr)
    if espHighlights[plr] then pcall(function() espHighlights[plr]:Destroy() end); espHighlights[plr] = nil end
    if espLabels[plr] then
        pcall(function() espLabels[plr].billboard:Destroy() end)
        espLabels[plr] = nil
    end
    -- 清理角色上的残留
    if plr.Character then
        local old = plr.Character:FindFirstChild(FAKE_NAMES.esp)
        if old then pcall(function() old:Destroy() end) end
        local oldLabel = plr.Character:FindFirstChild(FAKE_NAMES.espLabel)
        if oldLabel then pcall(function() oldLabel:Destroy() end) end
    end
end

espFeature = CreateFeature("esp", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.esp
    if state then
        fs.enabled = true
        -- 为所有现有玩家创建 ESP
        for _, plr in ipairs(Players:GetPlayers()) do
            createESPForPlayer(plr)
        end
        -- 监听新玩家加入
        local playerAddedConn = Players.PlayerAdded:Connect(function(plr)
            if fs.enabled then createESPForPlayer(plr) end
        end)
        addConnection("esp", playerAddedConn)
        -- 监听玩家离开
        local playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
            removeESPForPlayer(plr)
        end)
        addConnection("esp", playerRemovingConn)
        -- 更新距离标签
        local distConn = RunService.RenderStepped:Connect(function()
            if not fs.enabled then return end
            local myHrp = getHRP()
            for plr, data in pairs(espLabels) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and myHrp then
                    local dist = (plr.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
                    if data.distLabel and data.distLabel.Parent then
                        data.distLabel.Text = string.format("%d m", math.floor(dist))
                    end
                end
            end
        end)
        addConnection("esp", distConn)
    else
        fs.enabled = false
        -- 清理所有 ESP
        for _, plr in ipairs(Players:GetPlayers()) do
            removeESPForPlayer(plr)
        end
        cleanupFeature("esp")
    end
end})

-- === God Mode ===
createFeatureState("god")
godFeature = CreateFeature("god", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.god
    if state then
        fs.enabled = true
        -- 方式1: 持续恢复生命值
        local healthConn = nil
        local function setupGodMode()
            local hum = getHumanoid()
            if not hum then return end
            -- 立即回满血
            hum.Health = hum.MaxHealth
            if healthConn then pcall(function() healthConn:Disconnect() end) end
            healthConn = hum.HealthChanged:Connect(function(health)
                if fs.enabled and health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end
        setupGodMode()
        if healthConn then addConnection("god", healthConn) end
        -- 角色重生后重新设置
        local respawnConn = player.CharacterAdded:Connect(function(ch)
            task.wait(1)
            if fs.enabled then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                    if healthConn then pcall(function() healthConn:Disconnect() end) end
                    healthConn = hum.HealthChanged:Connect(function(health)
                        if fs.enabled and health < hum.MaxHealth then
                            hum.Health = hum.MaxHealth
                        end
                    end)
                end
            end
        end)
        addConnection("god", respawnConn)
    else
        fs.enabled = false
        cleanupFeature("god")
    end
end})

-- === No Fall Damage ===
createFeatureState("nofall")
nofallFeature = CreateFeature("nofall", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.nofall
    if state then
        fs.enabled = true
        local function disableFall()
            local hum = getHumanoid()
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            end
        end
        disableFall()
        -- 角色重生后重新设置
        local respawnConn = player.CharacterAdded:Connect(function(ch)
            task.wait(0.5)
            if fs.enabled then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                end
            end
        end)
        addConnection("nofall", respawnConn)
    else
        fs.enabled = false
        -- 恢复状态
        local hum = getHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        end
        cleanupFeature("nofall")
    end
end})

-- === Time Control ===
createFeatureState("time")
timeFeature = CreateFeature("time", "Slider", "world", {default=12, min=0, max=24, onChange=function(v)
    Lighting.ClockTime = v
end})

-- === Gravity ===
createFeatureState("gravity")
gravityFeature = CreateFeature("gravity", "Slider", "world", {default=196.2, min=10, max=500, onChange=function(v)
    Workspace.Gravity = v
end})

-- === Invisible ===
createFeatureState("invisible")
invisibleFeature = CreateFeature("invisible", "Toggle", "world", {onToggle=function(state)
    local fs = featureStates.invisible
    if state then
        fs.enabled = true
        invisibleSavedTransparency = {}
        local ch = getCharacter()
        if ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    invisibleSavedTransparency[p] = p.Transparency
                    p.Transparency = 0.8
                elseif p:IsA("Decal") then
                    invisibleSavedTransparency[p] = p.Transparency
                    p.Transparency = 1
                end
            end
        end
        -- 角色重生后重新设置
        local respawnConn = player.CharacterAdded:Connect(function(ch)
            task.wait(0.5)
            if fs.enabled then
                invisibleSavedTransparency = {}
                for _, p in ipairs(ch:GetDescendants()) do
                    if p:IsA("BasePart") then
                        invisibleSavedTransparency[p] = p.Transparency
                        p.Transparency = 0.8
                    elseif p:IsA("Decal") then
                        invisibleSavedTransparency[p] = p.Transparency
                        p.Transparency = 1
                    end
                end
            end
        end)
        addConnection("invisible", respawnConn)
    else
        fs.enabled = false
        -- 恢复原始透明度
        local ch = getCharacter()
        if ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if (p:IsA("BasePart") or p:IsA("Decal")) and invisibleSavedTransparency[p] ~= nil then
                    p.Transparency = invisibleSavedTransparency[p]
                end
            end
        end
        invisibleSavedTransparency = {}
        cleanupFeature("invisible")
    end
end})

-- === FOV ===
createFeatureState("fov")
fovFeature = CreateFeature("fov", "Slider", "world", {default=70, min=30, max=120, onChange=function(v)
    Camera.FieldOfView = v
end})

-- ==================== ADVANCED AIMBOT SYSTEM ====================
-- 完全重写：修复平滑/距离/锁定问题，增加预测、FOV、优先级、按键等
createFeatureState("aimbot")

local aimSettings = {
    dynamicAim = false,
    cursorAim = false,
    aimPart = "Head",          -- Head / HumanoidRootPart / Random
    aimRadius = 120,           -- FOV 范围（像素）
    aimSmooth = 5,             -- 平滑度 1-20，1=最慢 20=瞬锁
    teamCheck = true,
    wallCheck = true,
    lockTarget = nil,          -- 锁定的玩家对象
    -- 新增功能
    prediction = false,        -- 弹道预测
    predStrength = 50,         -- 预测强度 1-100
    fovCircle = true,          -- 显示FOV圆圈
    fovSize = 120,             -- FOV圆圈大小
    aimPriority = "distance",  -- distance / health / fov
    aimKey = "none",           -- none / hold / toggle
    aimKeyHeld = false,        -- 按键状态
    aimKeyToggled = false,     -- 切换状态
    showTarget = true,         -- 显示目标标记
    deadzone = 5,              -- 死区范围（像素）
    stickyAim = true,          -- 粘滞瞄准（锁定后不轻易切换目标）
    healthBar = false,         -- 血量显示
    tracer = false,            -- 弹道追踪线
    closestBone = false,       -- 最近骨骼瞄准
    autoShoot = false,         -- 自动射击
    antiRecoil = false,        -- 反后坐力
}

-- Drawing 对象
local aimFovCircle = Drawing.new("Circle")
aimFovCircle.Visible = false; aimFovCircle.Color = Color3.fromRGB(255,255,255)
aimFovCircle.Thickness = 1; aimFovCircle.Filled = false
aimFovCircle.Radius = aimSettings.fovSize
aimFovCircle.Transparency = 0.7
aimFovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local aimTargetCircle = Drawing.new("Circle")
aimTargetCircle.Visible = false; aimTargetCircle.Color = Color3.fromRGB(255,50,50)
aimTargetCircle.Thickness = 2; aimTargetCircle.Filled = false
aimTargetCircle.Radius = 10; aimTargetCircle.Transparency = 0.5
aimTargetCircle.NumSides = 32

local aimLine = Drawing.new("Line")
aimLine.Visible = false; aimLine.Color = Color3.fromRGB(255,50,50)
aimLine.Thickness = 1; aimLine.Transparency = 0.5

local aimTracerLine = Drawing.new("Line")
aimTracerLine.Visible = false; aimTracerLine.Color = Color3.fromRGB(255,200,50)
aimTracerLine.Thickness = 1; aimTracerLine.Transparency = 0.7

-- 自瞄核心变量
local currentAimTarget = nil       -- 当前瞄准的 Part
local currentAimPlayer = nil       -- 当前瞄准的 Player
local lastAimPlayer = nil          -- 上一次瞄准的 Player（粘滞瞄准用）
local lastTargetPlayer = nil      -- 上一次预测的 Player
local aimHue = 0
local lastTargetVelocity = Vector3.new(0,0,0)
local lastTargetPosition = Vector3.new(0,0,0)
local lastTargetUpdateTime = 0

-- 骨骼列表（最近骨骼瞄准用）
local BONE_PARTS = {
    "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm",
    "Left Leg", "Right Leg", "LeftHand", "RightHand",
    "LeftFoot", "RightFoot", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
}

-- 可视检测（优化：使用 RaycastParams 替代旧式 Ray）
local function isTargetVisible(targetPart)
    if not aimSettings.wallCheck then return true end
    local char = getCharacter()
    if not char or not targetPart then return false end
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    local result = Workspace:Raycast(origin, dir, params)
    if result then
        -- 如果射线击中的物体比目标更近，说明被墙挡住
        local hitDist = (result.Position - origin).Magnitude
        local targetDist = dir.Magnitude
        return hitDist >= targetDist - 2
    end
    return true
end

-- 队伍检测
local function isSameTeam(otherPlayer)
    if not aimSettings.teamCheck then return false end
    if not player.Team or not otherPlayer.Team then return false end
    return player.Team == otherPlayer.Team
end

-- 获取目标部位
local function getAimPart(char)
    if aimSettings.closestBone then
        -- 最近骨骼：找离屏幕中心最近的部位
        local cam = Camera
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        local closestPart = nil
        local minDist = math.huge
        for _, boneName in ipairs(BONE_PARTS) do
            local part = char:FindFirstChild(boneName)
            if part and part:IsA("BasePart") then
                local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and pos.Z > 0 then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestPart = part
                    end
                end
            end
        end
        return closestPart
    end

    local partName = aimSettings.aimPart
    if partName == "Random" then
        local parts = {"Head", "HumanoidRootPart"}
        partName = parts[math.random(1, #parts)]
    end
    return char:FindFirstChild(partName)
end

-- 弹道预测：根据目标速度预测未来位置
local function getPredictedPosition(targetPart)
    if not aimSettings.prediction then
        return targetPart.Position
    end

    local now = tick()
    local pos = targetPart.Position

    -- 计算速度
    if lastTargetPlayer == currentAimPlayer and lastTargetUpdateTime > 0 then
        local dt = now - lastTargetUpdateTime
        if dt > 0 and dt < 0.5 then
            local velocity = (pos - lastTargetPosition) / dt
            -- 预测强度：将速度外推
            local predFactor = aimSettings.predStrength / 50
            local predictedPos = pos + velocity * predFactor * 0.1
            return predictedPos
        end
    end

    -- 尝试从 HumanoidRootPart 获取速度
    local char = targetPart.Parent
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local velocity = hrp.AssemblyLinearVelocity
            local predFactor = aimSettings.predStrength / 50
            return pos + velocity * predFactor * 0.1
        end
    end

    return pos
end

-- 目标优先级排序
local function getTargetScore(plr, part, screenPos, center)
    local dist3D = 0
    local myHrp = getHRP()
    if myHrp then
        local targetHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            dist3D = (targetHrp.Position - myHrp.Position).Magnitude
        end
    end

    local screenDist = (screenPos - center).Magnitude

    if aimSettings.aimPriority == "health" then
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        local hp = hum and hum.Health or 100
        return hp  -- 最低血量优先
    elseif aimSettings.aimPriority == "fov" then
        return screenDist  -- FOV中心优先
    else
        return dist3D  -- 最近距离优先
    end
end

-- 获取动态自瞄目标（FOV圈内最优目标）
local function getDynamicAimTarget()
    local cam = Camera
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local fovRadius = aimSettings.fovSize

    local bestTarget = nil
    local bestPart = nil
    local bestScore = math.huge
    local bestScreenPos = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        if isSameTeam(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local part = getAimPart(char)
        if not part then continue end

        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen or pos.Z <= 0 then continue end

        local screenPos = Vector2.new(pos.X, pos.Y)
        local screenDist = (screenPos - center).Magnitude

        -- 死区：太近的不瞄准
        if screenDist < aimSettings.deadzone then continue end

        -- FOV范围检查
        if screenDist > fovRadius then continue end

        -- 粘滞瞄准：如果上一个目标仍在范围内，优先保持
        if aimSettings.stickyAim and lastAimPlayer == plr then
            -- 给粘滞目标额外优势
            screenDist = screenDist * 0.7
        end

        if not isTargetVisible(part) then continue end

        local score = getTargetScore(plr, part, screenPos, center)
        -- 综合评分：优先级得分 + 屏幕距离权重
        local combinedScore = score + screenDist * 0.5

        if combinedScore < bestScore then
            bestScore = combinedScore
            bestTarget = plr
            bestPart = part
            bestScreenPos = screenPos
        end
    end

    return bestPart, bestTarget, bestScreenPos
end

-- 获取光标自瞄目标
local function getCursorAimTarget()
    local cam = Camera
    local cursorPos = UserInputService:GetMouseLocation()
    local maxDist = aimSettings.fovSize

    local bestTarget = nil
    local bestPart = nil
    local bestScore = math.huge
    local bestScreenPos = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        if isSameTeam(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local part = getAimPart(char)
        if not part then continue end

        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen or pos.Z <= 0 then continue end

        local screenPos = Vector2.new(pos.X, pos.Y)
        local screenDist = (screenPos - cursorPos).Magnitude

        if screenDist < aimSettings.deadzone then continue end
        if screenDist > maxDist then continue end

        if aimSettings.stickyAim and lastAimPlayer == plr then
            screenDist = screenDist * 0.7
        end

        if not isTargetVisible(part) then continue end

        local score = getTargetScore(plr, part, screenPos, cursorPos)
        local combinedScore = score + screenDist * 0.5

        if combinedScore < bestScore then
            bestScore = combinedScore
            bestTarget = plr
            bestPart = part
            bestScreenPos = screenPos
        end
    end

    return bestPart, bestTarget, bestScreenPos
end

-- 获取锁定目标
local function getLockedTarget()
    if not aimSettings.lockTarget then return nil, nil, nil end
    local plr = aimSettings.lockTarget
    if plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local part = getAimPart(plr.Character)
        if hum and part and hum.Health > 0 and not isSameTeam(plr) then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 and isTargetVisible(part) then
                return part, plr, Vector2.new(pos.X, pos.Y)
            end
        end
    end
    return nil, nil, nil
end

-- 检查自瞄是否应该激活（按键模式）
local function isAimActive()
    if not aimSettings.dynamicAim and not aimSettings.cursorAim then return false end
    if aimSettings.aimKey == "none" then return true end
    if aimSettings.aimKey == "hold" then return aimSettings.aimKeyHeld end
    if aimSettings.aimKey == "toggle" then return aimSettings.aimKeyToggled end
    return true
end

-- 瞄准按键监听
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        if aimSettings.aimKey == "hold" then aimSettings.aimKeyHeld = true end
        if aimSettings.aimKey == "toggle" then aimSettings.aimKeyToggled = not aimSettings.aimKeyToggled end
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        if aimSettings.aimKey == "hold" then aimSettings.aimKeyHeld = false end
    end
end)

-- 自瞄绘制循环（优化：使用 RenderStepped 替代 task.wait）
local aimRenderConn = nil
aimRenderConn = RunService.RenderStepped:Connect(function()
    -- FOV 圆圈始终显示（如果开启）
    if aimSettings.fovCircle and (aimSettings.dynamicAim or aimSettings.cursorAim) then
        local center
        if aimSettings.cursorAim then
            center = UserInputService:GetMouseLocation()
        else
            center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        end
        aimFovCircle.Position = center
        aimFovCircle.Radius = aimSettings.fovSize
        aimFovCircle.Visible = true
    else
        aimFovCircle.Visible = false
    end

    -- 检查自瞄是否激活
    if not isAimActive() then
        aimTargetCircle.Visible = false
        aimLine.Visible = false
        aimTracerLine.Visible = false
        currentAimTarget = nil
        currentAimPlayer = nil
        return
    end

    -- 获取目标
    local targetPart, targetPlayer, targetScreenPos

    -- 优先锁定目标
    targetPart, targetPlayer, targetScreenPos = getLockedTarget()

    if not targetPart then
        if aimSettings.dynamicAim then
            targetPart, targetPlayer, targetScreenPos = getDynamicAimTarget()
        elseif aimSettings.cursorAim then
            targetPart, targetPlayer, targetScreenPos = getCursorAimTarget()
        end
    end

    -- 更新目标
    currentAimTarget = targetPart
    currentAimPlayer = targetPlayer

    if targetPart then
        lastAimPlayer = targetPlayer
        lastTargetPlayer = targetPlayer

        -- 预测位置
        local predictedPos = getPredictedPosition(targetPart)
        local predScreenPos, predOnScreen = Camera:WorldToViewportPoint(predictedPos)

        -- 更新预测追踪
        lastTargetPosition = targetPart.Position
        lastTargetUpdateTime = tick()

        if not predOnScreen or predScreenPos.Z <= 0 then
            currentAimTarget = nil
            aimTargetCircle.Visible = false
            aimLine.Visible = false
            aimTracerLine.Visible = false
            return
        end

        local screenTarget = Vector2.new(predScreenPos.X, predScreenPos.Y)

        -- 目标标记
        if aimSettings.showTarget then
            aimTargetCircle.Position = screenTarget
            aimTargetCircle.Visible = true
            aimHue = (aimHue + 0.005) % 1
            aimTargetCircle.Color = Color3.fromHSV(aimHue, 0.9, 1)
        else
            aimTargetCircle.Visible = false
        end

        -- 瞄准线
        local center
        if aimSettings.cursorAim then
            center = UserInputService:GetMouseLocation()
        else
            center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        end
        aimLine.From = center
        aimLine.To = screenTarget
        aimLine.Color = aimTargetCircle.Color
        aimLine.Visible = true

        -- 弹道追踪
        if aimSettings.tracer then
            local myHrp = getHRP()
            if myHrp then
                local gunPos, gunOnScreen = Camera:WorldToViewportPoint(myHrp.Position + Vector3.new(0, 1.5, 0))
                if gunOnScreen then
                    aimTracerLine.From = Vector2.new(gunPos.X, gunPos.Y)
                    aimTracerLine.To = screenTarget
                    aimTracerLine.Visible = true
                else
                    aimTracerLine.Visible = false
                end
            end
        else
            aimTracerLine.Visible = false
        end
    else
        aimTargetCircle.Visible = false
        aimLine.Visible = false
        aimTracerLine.Visible = false
    end
end)
addConnection("aimbot", aimRenderConn)

-- 自瞄瞄准循环（核心：修复平滑度问题）
-- 使用 RenderStepped + 帧率无关的平滑插值
local aimLookConn = nil
aimLookConn = RunService.RenderStepped:Connect(function(dt)
    if not isAimActive() then return end
    if not currentAimTarget then return end
    if not currentAimTarget.Parent then currentAimTarget = nil; return end

    -- 再次验证可见性
    if aimSettings.wallCheck and not isTargetVisible(currentAimTarget) then
        currentAimTarget = nil
        return
    end

    local cam = Camera
    local camPos = cam.CFrame.Position

    -- 使用预测位置
    local tarPos = getPredictedPosition(currentAimTarget)

    -- 平滑度计算：aimSmooth 1-20
    -- 1 = 非常慢（0.5秒到达），20 = 瞬间锁定
    -- 使用帧率无关的指数衰减插值
    local smoothFactor = aimSettings.aimSmooth / 20  -- 0.05 到 1.0
    -- 帧率补偿：在60fps下 smoothFactor=1 时瞬间到达
    local alpha = 1 - math.pow(1 - smoothFactor, dt * 60)

    local targetCF = CFrame.lookAt(camPos, tarPos)

    if aimSettings.lockTarget then
        -- 锁定模式：直接锁定（但仍然受平滑度影响）
        cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(alpha, 0.5, 1))
    else
        cam.CFrame = cam.CFrame:Lerp(targetCF, alpha)
    end

    -- 反后坐力：保持相机水平
    if aimSettings.antiRecoil then
        local currentCF = cam.CFrame
        local rx, ry, rz = currentCF:ToEulerAnglesXYZ()
        -- 限制垂直方向抖动
        if math.abs(rz) > 0.01 then
            cam.CFrame = CFrame.fromMatrix(currentCF.Position, currentCF.RightVector, currentCF.UpVector)
        end
    end

    -- 自动射击
    if aimSettings.autoShoot and currentAimTarget then
        -- 模拟点击（通过鼠标点击事件）
        -- 使用 VirtualUser 模拟输入
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
        end)
    end
end)
addConnection("aimbot", aimLookConn)

-- 血量显示 Drawing 对象管理
local aimHealthDrawings = {}

local function updateHealthBars()
    -- 清理旧的
    for plr, drawings in pairs(aimHealthDrawings) do
        if not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid") then
            for _, d in ipairs(drawings) do
                pcall(function() d.Visible = false end)
            end
        end
    end

    if not aimSettings.healthBar then
        for _, drawings in pairs(aimHealthDrawings) do
            for _, d in ipairs(drawings) do
                pcall(function() d:Remove() end)
            end
        end
        aimHealthDrawings = {}
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        if isSameTeam(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if not hum or not head then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
        if not onScreen then
            if aimHealthDrawings[plr] then
                for _, d in ipairs(aimHealthDrawings[plr]) do
                    pcall(function() d.Visible = false end)
                end
            end
            continue
        end

        local hpRatio = hum.Health / hum.MaxHealth

        if not aimHealthDrawings[plr] then
            local bg = Drawing.new("Square")
            bg.Thickness = 0; bg.Filled = true; bg.Color = Color3.fromRGB(40,40,40)
            bg.Size = Vector2.new(40, 4); bg.Transparency = 0.5

            local fill = Drawing.new("Square")
            fill.Thickness = 0; fill.Filled = true; fill.Color = Color3.fromRGB(50, 255, 50)
            fill.Size = Vector2.new(40 * hpRatio, 4); fill.Transparency = 0.3

            aimHealthDrawings[plr] = {bg, fill}
        end

        local bg, fill = aimHealthDrawings[plr][1], aimHealthDrawings[plr][2]
        bg.Position = Vector2.new(pos.X - 20, pos.Y - 5)
        bg.Visible = true
        fill.Position = bg.Position
        fill.Size = Vector2.new(40 * hpRatio, 4)
        fill.Color = hpRatio > 0.5 and Color3.fromRGB(50, 255, 50) or
                     hpRatio > 0.25 and Color3.fromRGB(255, 200, 50) or
                     Color3.fromRGB(255, 50, 50)
        fill.Visible = true
    end
end

local healthBarConn = nil
healthBarConn = RunService.RenderStepped:Connect(updateHealthBars)
addConnection("aimbot", healthBarConn)

-- ==================== BLACK HOLE SYSTEM ====================
createFeatureState("blackhole")
local blackHoleConn = nil

local function startBlackHole()
    if blackHoleConn then pcall(function() blackHoleConn:Disconnect() end) end
    blackHoleConn = RunService.Heartbeat:Connect(function()
        local char = getCharacter()
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local center = root.Position
        local maxRange = 20

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local canOwn = false
                pcall(function() canOwn = obj:CanSetNetworkOwnership() end)
                if not canOwn then continue end
                local success = pcall(function() obj:SetNetworkOwner(player) end)
                if not success then continue end

                local pos = obj.Position
                local delta = pos - center
                local dist = delta.Magnitude

                if dist < maxRange then
                    local angle = tick() * 10
                    local orbit = Vector3.new(math.cos(angle), 0.2, math.sin(angle)) * 12
                    obj.Velocity = (orbit - delta.Unit * 25)
                    obj.RotVelocity = Vector3.new(0, 30, 0)
                end
            end
        end
    end)
    addConnection("blackhole", blackHoleConn)
end

local function stopBlackHole()
    if blackHoleConn then pcall(function() blackHoleConn:Disconnect() end); blackHoleConn = nil end
end

-- ==================== AIMBOT FEATURES (aimbot page) ====================

-- === 动态自瞄 ===
CreateFeature("dynAim", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.dynamicAim = state
    if state then aimSettings.cursorAim = false end
end})

-- === 光标自瞄 ===
CreateFeature("cursorAim", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.cursorAim = state
    if state then aimSettings.dynamicAim = false end
end})

-- === 瞄准部位 (1=头部 2=躯干 3=根部 4=随机) ===
CreateFeature("aimPart", "Slider", "aimbot", {default=1, min=1, max=4, onChange=function(v)
    local parts = {"Head", "HumanoidRootPart", "HumanoidRootPart", "Random"}
    aimSettings.aimPart = parts[v]
end})

-- === FOV大小（原自瞄范围，修复：直接控制fovSize） ===
CreateFeature("aimFovSize", "Slider", "aimbot", {default=120, min=20, max=400, onChange=function(v)
    aimSettings.fovSize = v
    aimSettings.aimRadius = v
end})

-- === 跟枪平滑（修复：1-20范围，帧率无关插值） ===
CreateFeature("aimSmooth", "Slider", "aimbot", {default=10, min=1, max=20, onChange=function(v)
    aimSettings.aimSmooth = v
end})

-- === 死区范围 ===
CreateFeature("aimDeadzone", "Slider", "aimbot", {default=5, min=0, max=50, onChange=function(v)
    aimSettings.deadzone = v
end})

-- === 队伍检测 ===
CreateFeature("teamCheck", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.teamCheck = state
end})

-- === 穿墙检测 ===
CreateFeature("wallCheck", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.wallCheck = state
end})

-- === FOV圆圈显示 ===
CreateFeature("aimFovCircle", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.fovCircle = state
end})

-- === 显示目标标记 ===
CreateFeature("aimShowTarget", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.showTarget = state
end})

-- === 弹道预测 ===
CreateFeature("aimPrediction", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.prediction = state
end})

-- === 预测强度 ===
CreateFeature("aimPredStrength", "Slider", "aimbot", {default=50, min=1, max=100, onChange=function(v)
    aimSettings.predStrength = v
end})

-- === 目标优先级 (1=最近距离 2=最低血量 3=FOV中心) ===
CreateFeature("aimPriority", "Slider", "aimbot", {default=1, min=1, max=3, onChange=function(v)
    local priorities = {"distance", "health", "fov"}
    aimSettings.aimPriority = priorities[v]
end})

-- === 瞄准按键 (1=无(常驻) 2=按住 3=切换) ===
CreateFeature("aimKey", "Slider", "aimbot", {default=1, min=1, max=3, onChange=function(v)
    local keys = {"none", "hold", "toggle"}
    aimSettings.aimKey = keys[v]
    aimSettings.aimKeyHeld = false
    aimSettings.aimKeyToggled = false
end})

-- === 粘滞瞄准 ===
CreateFeature("aimSticky", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.stickyAim = state
end})

-- === 最近骨骼瞄准 ===
CreateFeature("aimClosestBone", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.closestBone = state
end})

-- === 血量显示 ===
CreateFeature("aimHealthBar", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.healthBar = state
end})

-- === 弹道追踪 ===
CreateFeature("aimTracer", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.tracer = state
end})

-- === 反后坐力 ===
CreateFeature("aimKnockback", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.antiRecoil = state
end})

-- === 自动射击 ===
CreateFeature("aimAutoShoot", "Toggle", "aimbot", {onToggle=function(state)
    aimSettings.autoShoot = state
end})

-- === 锁定目标 ===
CreateFeature("lockTarget", "Button", "aimbot", {text="锁定", onClick=function()
    if aimSettings.lockTarget then
        aimSettings.lockTarget = nil
        notif(T("aimAll"))
    else
        local cam = Camera
        local closest = nil
        local minDist = 9999
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == player then continue end
            if isSameTeam(plr) then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local myHrp = getHRP()
                if myHrp then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
        if closest then
            aimSettings.lockTarget = closest
            notif(T("aimNearest") .. ": " .. closest.Name)
        else
            notif(T("aimAll"))
        end
    end
end})

-- === 黑洞 ===
CreateFeature("blackHole", "Toggle", "aimbot", {onToggle=function(state)
    if state then
        startBlackHole()
        featureStates.blackhole.enabled = true
    else
        stopBlackHole()
        featureStates.blackhole.enabled = false
    end
end})

-- ==================== COMBAT FEATURES (combat page) ====================

-- === 命中箱扩大 ===
createFeatureState("hitbox")
local hitboxSize = 5
local hitboxTrans = 0.8
CreateFeature("hitbox", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.hitbox
    if state then
        fs.enabled = true
        local conn = RunService.RenderStepped:Connect(function()
            if not fs.enabled then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == player then continue end
                if isSameTeam(plr) then continue end
                local char = plr.Character
                if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local existing = head:FindFirstChild(FAKE_NAMES.hitbox)
                    if not existing then
                        local mesh = Instance.new("CylinderMesh")
                        mesh.Name = FAKE_NAMES.hitbox
                        mesh.Scale = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        mesh.Parent = head
                    else
                        existing.Scale = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    end
                    head.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    head.Transparency = hitboxTrans
                    head.BrickColor = BrickColor.new("Really red")
                end
            end
        end)
        addConnection("hitbox", conn)
    else
        fs.enabled = false
        cleanupFeature("hitbox")
        -- 恢复头部大小
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local mesh = head:FindFirstChild(FAKE_NAMES.hitbox)
                    if mesh then mesh:Destroy() end
                    head.Size = Vector3.new(2, 1, 1)
                    head.Transparency = 0
                end
            end
        end
    end
end})

CreateFeature("hitboxSize", "Slider", "combat", {default=5, min=2, max=30, onChange=function(v)
    hitboxSize = v
end})

CreateFeature("hitboxTransparency", "Slider", "combat", {default=8, min=0, max=10, onChange=function(v)
    hitboxTrans = v / 10
end})

-- === 杀戮光环 ===
createFeatureState("killaura")
local killAuraRange = 15
CreateFeature("killAura", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.killaura
    if state then
        fs.enabled = true
        local conn = RunService.Heartbeat:Connect(function()
            if not fs.enabled then return end
            local myHrp = getHRP()
            if not myHrp then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == player then continue end
                if isSameTeam(plr) then continue end
                local char = plr.Character
                if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist <= killAuraRange then
                        -- 尝试攻击（通过模拟点击或远程事件）
                        pcall(function()
                            local VirtualUser = game:GetService("VirtualUser")
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new())
                        end)
                    end
                end
            end
        end)
        addConnection("killaura", conn)
    else
        fs.enabled = false
        cleanupFeature("killaura")
    end
end})

CreateFeature("killAuraRange", "Slider", "combat", {default=15, min=5, max=50, onChange=function(v)
    killAuraRange = v
end})

-- ==================== MOVEMENT EXTRA FEATURES ====================

-- === 连跳 (Bunny Hop) ===
createFeatureState("bhop")
CreateFeature("bhop", "Toggle", "movement", {onToggle=function(state)
    local fs = featureStates.bhop
    if state then
        fs.enabled = true
        local conn = UserInputService.JumpRequest:Connect(function()
            if not fs.enabled then return end
            local hum = getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                -- 连跳加速
                local hrp = getHRP()
                if hrp then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        hrp.Velocity = hrp.Velocity + moveDir * 5
                    end
                end
            end
        end)
        addConnection("bhop", conn)
    else
        fs.enabled = false
        cleanupFeature("bhop")
    end
end})

-- === 空中行走 ===
createFeatureState("airwalk")
CreateFeature("airWalk", "Toggle", "movement", {onToggle=function(state)
    local fs = featureStates.airwalk
    if state then
        fs.enabled = true
        local conn = RunService.Heartbeat:Connect(function()
            if not fs.enabled then return end
            local hum = getHumanoid()
            if hum then
                -- 在空中时保持水平速度
                if hum:GetState() == Enum.HumanoidStateType.Freefall then
                    local hrp = getHRP()
                    if hrp then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    end
                end
            end
        end)
        addConnection("airwalk", conn)
    else
        fs.enabled = false
        cleanupFeature("airwalk")
    end
end})

-- === 旋转机器人 ===
createFeatureState("spinbot")
local spinSpeed = 10
CreateFeature("spinBot", "Toggle", "movement", {onToggle=function(state)
    local fs = featureStates.spinbot
    if state then
        fs.enabled = true
        local conn = RunService.RenderStepped:Connect(function(dt)
            if not fs.enabled then return end
            local hum = getHumanoid()
            if hum then
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed * dt * 60), 0)
                end
            end
        end)
        addConnection("spinbot", conn)
    else
        fs.enabled = false
        cleanupFeature("spinbot")
    end
end})

CreateFeature("spinSpeed", "Slider", "movement", {default=10, min=1, max=50, onChange=function(v)
    spinSpeed = v
end})

-- ####################################################################
-- ==================== FLING SYSTEM (甩飞/防甩飞/反防甩飞) ============ --
-- 完整的甩飞系统，包含三种功能及各自的反作弊保护
-- ####################################################################

-- === 甩飞核心变量 ===
local flingState = {
    enabled = false,
    power = 500,           -- 甩飞力度（速度值）
    range = 30,            -- 甩飞范围
    mode = 1,              -- 1=范围内全部, 2=最近目标, 3=指定目标
    targetPlayer = nil,    -- 指定目标玩家名
    autoFling = false,     -- 自动甩飞
    autoInterval = 3,      -- 自动甩飞间隔（秒）
    lastFlingTime = 0,     -- 上次甩飞时间
    flingCooldown = 0.5,   -- 手动甩飞冷却
    bypassEnabled = false, -- 反防甩飞是否启用
    bypassMode = 1,        -- 1=强制位移, 2=高速冲击, 3=连续冲击, 4=漏洞利用
}

-- === 防甩飞核心变量 ===
local antiFlingState = {
    enabled = false,
    strength = 3,          -- 防甩飞强度 1-5
    lastCheckTime = 0,
    originalPositions = {},
    velocityThreshold = 50,  -- 速度阈值，超过此值视为被甩飞
    positionThreshold = 50,  -- 位置突变阈值
}

-- === 甩飞反作弊保护 ===
-- 甩飞操作会修改其他玩家的 HumanoidRootPart 位置/速度
-- 反作弊可能检测到：异常物理力、位置突变、BodyVelocity/BodyForce 等实例
-- 保护策略：
-- 1. 使用伪装名称创建物理实例
-- 2. 操作后立即清理所有物理实例
-- 3. 使用短暂的物理力而非直接设置位置
-- 4. 操作间隔随机化，避免模式检测

-- 伪装名称映射
local FLING_DISGUISE = {
    bodyVelocity = "ParticleEmitter",
    bodyForce = "PointLight",
    bodyPosition = "SpotLight",
    bodyGyro = "SurfaceLight",
    attachment = "Attachment",
}

-- === 甩飞核心函数 ===
-- 对单个目标执行甩飞
local function executeFlingOnTarget(targetPlayer, power, useBypass)
    if not targetPlayer or targetPlayer == player then return false end
    if not targetPlayer.Character then return false end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false end
    local myChar = getCharacter()
    if not myChar then return false end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end

    -- 计算甩飞方向：从我到目标的方向
    local direction = (targetHRP.Position - myHRP.Position).Unit

    -- 添加一些随机偏移，使每次甩飞方向略有不同
    local randomOffset = Vector3.new(
        (math.random() - 0.5) * 0.3,
        math.random() * 0.5 + 0.3,  -- 向上偏移
        (math.random() - 0.5) * 0.3
    )
    local flingDirection = (direction + randomOffset).Unit

    -- 计算甩飞速度
    local flingVelocity = flingDirection * power

    -- 检查是否需要绕过防甩飞
    if useBypass and flingState.bypassEnabled then
        -- === 反防甩飞模式 ===
        if flingState.bypassMode == 1 then
            -- 模式1：强制位移 - 直接设置CFrame，绕过物理系统
            -- 防甩飞通常监控物理力，直接设置CFrame可以绕过
            pcall(function()
                local targetPos = targetHRP.Position + flingDirection * power * 0.5
                -- 分段移动，避免位置突变被检测
                local steps = 5
                local startPos = targetHRP.Position
                for i = 1, steps do
                    local alpha = i / steps
                    -- 使用缓动函数让移动更自然
                    local easedAlpha = 1 - math.pow(1 - alpha, 3) -- easeOutCubic
                    local newPos = startPos:Lerp(targetPos, easedAlpha)
                    targetHRP.CFrame = CFrame.new(newPos)
                    task.wait(0.02)
                end
            end)
            return true

        elseif flingState.bypassMode == 2 then
            -- 模式2：高速冲击 - 用极高速度的BodyVelocity瞬间冲击
            -- 防甩飞可能只监控低频率的力，高速瞬间冲击可能绕过
            pcall(function()
                -- 先靠近目标
                local originalCFrame = myHRP.CFrame
                local approachPos = targetHRP.Position - direction * 3
                myHRP.CFrame = CFrame.new(approachPos)

                task.wait(0.05)

                -- 创建伪装的BodyVelocity
                local bv = Instance.new("BodyVelocity")
                bv.Name = FLING_DISGUISE.bodyVelocity
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = flingVelocity * 2  -- 双倍速度
                bv.Parent = targetHRP

                -- 同时给自己一个反向力（模拟碰撞）
                local myBv = Instance.new("BodyVelocity")
                myBv.Name = FLING_DISGUISE.bodyVelocity
                myBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                myBv.Velocity = -flingDirection * 20
                myBv.Parent = myHRP

                task.wait(0.15)

                -- 清理
                pcall(function() bv:Destroy() end)
                pcall(function() myBv:Destroy() end)

                -- 恢复位置
                myHRP.CFrame = originalCFrame
            end)
            return true

        elseif flingState.bypassMode == 3 then
            -- 模式3：连续冲击 - 多次小力冲击，累积效果
            -- 防甩飞可能只拦截单次大力，多次小力可能绕过
            pcall(function()
                local originalCFrame = myHRP.CFrame
                for hit = 1, 8 do
                    -- 每次靠近目标然后施加小力
                    local approachPos = targetHRP.Position - direction * 2
                    myHRP.CFrame = CFrame.new(approachPos)

                    task.wait(0.03)

                    local bv = Instance.new("BodyVelocity")
                    bv.Name = FLING_DISGUISE.bodyVelocity
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = flingDirection * (power * 0.4)  -- 每次小力
                    bv.Parent = targetHRP

                    task.wait(0.05)

                    pcall(function() bv:Destroy() end)
                end
                -- 恢复位置
                myHRP.CFrame = originalCFrame
            end)
            return true

        elseif flingState.bypassMode == 4 then
            -- 模式4：漏洞利用 - 利用网络所有权漏洞
            -- 通过快速移动自己的角色来获得对目标的网络所有权
            -- 然后修改目标位置
            pcall(function()
                local originalCFrame = myHRP.CFrame

                -- 快速移向目标以获取网络所有权
                for i = 1, 3 do
                    myHRP.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 2, 0))
                    task.wait(0.01)
                    myHRP.CFrame = CFrame.new(targetHRP.Position - direction * 1.5)
                    task.wait(0.01)
                end

                -- 现在应该有网络所有权了，直接设置目标位置
                task.wait(0.05)

                -- 使用BodyPosition精确控制目标位置
                local bp = Instance.new("BodyPosition")
                bp.Name = FLING_DISGUISE.bodyPosition
                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bp.Position = targetHRP.Position + flingDirection * power * 0.8
                bp.D = 1000  -- 高阻尼快速移动
                bp.P = 50000 -- 高力量
                bp.Parent = targetHRP

                -- 同时用BodyVelocity加速
                local bv = Instance.new("BodyVelocity")
                bv.Name = FLING_DISGUISE.bodyVelocity
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = flingVelocity
                bv.Parent = targetHRP

                task.wait(0.3)

                -- 清理
                pcall(function() bp:Destroy() end)
                pcall(function() bv:Destroy() end)

                -- 恢复位置
                myHRP.CFrame = originalCFrame
            end)
            return true
        end
    else
        -- === 普通甩飞模式（无反防甩飞）===
        pcall(function()
            local originalCFrame = myHRP.CFrame

            -- 方法：靠近目标，然后施加BodyVelocity
            -- 这是Roblox中最经典的甩飞方法
            local approachPos = targetHRP.Position - direction * 2
            myHRP.CFrame = CFrame.new(approachPos)

            task.wait(0.05)

            -- 创建BodyVelocity
            local bv = Instance.new("BodyVelocity")
            bv.Name = FLING_DISGUISE.bodyVelocity
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = flingVelocity
            bv.Parent = targetHRP

            -- 创建BodyForce增加旋转效果
            local bf = Instance.new("BodyForce")
            bf.Name = FLING_DISGUISE.bodyForce
            bf.Force = flingDirection * power * 50 + Vector3.new(
                (math.random() - 0.5) * power * 30,
                power * 20,
                (math.random() - 0.5) * power * 30
            )
            bf.Parent = targetHRP

            -- 给自己一个反冲力，看起来像碰撞
            local myBv = Instance.new("BodyVelocity")
            myBv.Name = FLING_DISGUISE.bodyVelocity
            myBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            myBv.Velocity = -flingDirection * 15
            myBv.Parent = myHRP

            task.wait(0.2)

            -- 清理所有物理实例（反作弊保护：不留痕迹）
            pcall(function() bv:Destroy() end)
            pcall(function() bf:Destroy() end)
            pcall(function() myBv:Destroy() end)

            -- 恢复自己的位置
            task.wait(0.05)
            myHRP.CFrame = originalCFrame
        end)
        return true
    end

    return false
end

-- === 甩飞功能UI ===
createFeatureState("fling")

CreateFeature("fling", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.fling
    fs.enabled = state
    flingState.enabled = state
    if state then
        notif(T("fling") .. " " .. T("on"))
    else
        -- 关闭时清理
        flingState.autoFling = false
        cleanupFeature("fling")
    end
end})

CreateFeature("flingPower", "Slider", "combat", {default=500, min=100, max=2000, onChange=function(v)
    flingState.power = v
end})

CreateFeature("flingRange", "Slider", "combat", {default=30, min=5, max=100, onChange=function(v)
    flingState.range = v
end})

CreateFeature("flingMode", "Slider", "combat", {default=1, min=1, max=3, onChange=function(v)
    flingState.mode = v
end})

-- 甩飞执行按钮
CreateFeature("flingExec", "Button", "combat", {text=T("fling"), onClick=function()
    if not flingState.enabled then notif(T("fling") .. " " .. T("off")); return end

    local now = tick()
    if now - flingState.lastFlingTime < flingState.flingCooldown then return end
    flingState.lastFlingTime = now

    local myChar = getCharacter()
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local targets = {}

    if flingState.mode == 1 then
        -- 范围内全部
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                if dist <= flingState.range then
                    targets[#targets + 1] = p
                end
            end
        end
    elseif flingState.mode == 2 then
        -- 最近目标
        local nearest = nil
        local nearestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                if dist <= flingState.range and dist < nearestDist then
                    nearest = p
                    nearestDist = dist
                end
            end
        end
        if nearest then targets = {nearest} end
    elseif flingState.mode == 3 then
        -- 指定目标
        if flingState.targetPlayer then
            local target = Players:FindFirstChild(flingState.targetPlayer)
            if target and target.Character then
                targets = {target}
            else
                -- 尝试模糊匹配
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Name:lower():find(flingState.targetPlayer:lower()) then
                        targets = {p}
                        break
                    end
                end
            end
        end
        if #targets == 0 then
            notif(T("flingNoTarget"))
            return
        end
    end

    if #targets == 0 then
        notif(T("flingNoTarget"))
        return
    end

    -- 执行甩飞
    for _, target in ipairs(targets) do
        task.spawn(function()
            local success = executeFlingOnTarget(target, flingState.power, flingState.bypassEnabled)
            if success then
                notif(T("flingExecuted") .. ": " .. target.Name)
            end
        end)
        -- 多目标时错开执行
        if #targets > 1 then task.wait(0.1) end
    end
end})

-- 自动甩飞
CreateFeature("flingAuto", "Toggle", "combat", {onToggle=function(state)
    flingState.autoFling = state
    if state then
        task.spawn(function()
            while flingState.autoFling and flingState.enabled do
                local myChar = getCharacter()
                if myChar then
                    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        -- 找最近的目标
                        local nearest = nil
                        local nearestDist = math.huge
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                                if dist <= flingState.range and dist < nearestDist then
                                    nearest = p
                                    nearestDist = dist
                                end
                            end
                        end
                        if nearest then
                            executeFlingOnTarget(nearest, flingState.power, flingState.bypassEnabled)
                        end
                    end
                end
                task.wait(flingState.autoInterval)
            end
        end)
    end
end})

CreateFeature("flingAutoInterval", "Slider", "combat", {default=3, min=1, max=10, onChange=function(v)
    flingState.autoInterval = v
end})

-- === 防甩飞功能 ===
-- 原理：监控自身角色的异常速度/位置变化，检测到甩飞时立即修正
-- 反作弊保护：修正操作使用伪装方式，不触发反作弊检测

createFeatureState("antiFling")

CreateFeature("antiFling", "Toggle", "combat", {onToggle=function(state)
    local fs = featureStates.antiFling
    fs.enabled = state
    antiFlingState.enabled = state
    if state then
        notif(T("antiFlingActive"))
        -- 启动防甩飞监控循环
        local conn
        conn = RunService.Heartbeat:Connect(function(dt)
            if not antiFlingState.enabled then
                if conn then conn:Disconnect() end
                return
            end

            local char = getCharacter()
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            -- 检测1：异常速度检测
            -- 如果角色速度远超正常移动速度，说明被甩飞
            local velocity = hrp.Velocity
            local speed = velocity.Magnitude
            local threshold = antiFlingState.velocityThreshold * antiFlingState.strength

            if speed > threshold then
                -- 检查是否是自己主动移动（飞行/速度加成等）
                local isSelfMovement = false
                if featureStates.fly and featureStates.fly.enabled then isSelfMovement = true end
                if featureStates.speed and featureStates.speed.enabled then isSelfMovement = true end

                if not isSelfMovement then
                    -- 被甩飞了！立即修正
                    -- 策略：将速度限制到安全范围
                    pcall(function()
                        -- 方法1：移除所有外部施加的BodyVelocity/BodyForce
                        for _, child in ipairs(hrp:GetChildren()) do
                            if child:IsA("BodyVelocity") or child:IsA("BodyForce") or
                               child:IsA("BodyPosition") or child:IsA("BodyGyro") or
                               child:IsA("RocketPropulsion") then
                                -- 检查是否是我们自己创建的（通过伪装名称）
                                local isOurs = false
                                for _, disguiseName in pairs(FLING_DISGUISE) do
                                    if child.Name == disguiseName then
                                        isOurs = true
                                        break
                                    end
                                end
                                if not isOurs then
                                    child:Destroy()
                                end
                            end
                        end

                        -- 方法2：将速度限制到安全值
                        local safeVelocity = velocity.Unit * math.min(speed, 50)
                        hrp.Velocity = safeVelocity

                        -- 方法3：如果位置突变太大，修正位置
                        local lastPos = antiFlingState.originalPositions[player.UserId]
                        if lastPos then
                            local posDelta = (hrp.Position - lastPos).Magnitude
                            if posDelta > antiFlingState.positionThreshold * antiFlingState.strength then
                                -- 位置突变，修正回上一个安全位置
                                hrp.CFrame = CFrame.new(lastPos)
                            end
                        end
                    end)

                    notif(T("antiFlingBlocked"))
                end
            end

            -- 记录安全位置（仅在正常移动时记录）
            if speed < 50 then
                antiFlingState.originalPositions[player.UserId] = hrp.Position
            end
        end)
        addConnection("antiFling", conn)
    else
        cleanupFeature("antiFling")
        antiFlingState.originalPositions = {}
    end
end})

CreateFeature("antiFlingStrength", "Slider", "combat", {default=3, min=1, max=5, onChange=function(v)
    antiFlingState.strength = v
    antiFlingState.velocityThreshold = 30 + v * 20
    antiFlingState.positionThreshold = 30 + v * 20
end})

-- === 反防甩飞功能 ===
-- 原理：绕过对方的防甩飞机制
-- 对方防甩飞通常：1.监控速度 2.删除BodyVelocity 3.修正位置
-- 绕过方法：1.直接设置CFrame 2.瞬间高速冲击 3.多次小冲击 4.利用网络所有权

createFeatureState("bypassAntiFling")

CreateFeature("bypassAntiFling", "Toggle", "combat", {onToggle=function(state)
    flingState.bypassEnabled = state
    if state then
        notif(T("bypassAntiFling") .. " " .. T("on"))
    end
end})

CreateFeature("bypassAntiFlingMode", "Slider", "combat", {default=1, min=1, max=4, onChange=function(v)
    flingState.bypassMode = v
end})

-- ####################################################################
-- ==================== MUSIC PLAYER SYSTEM ========================== --
-- ####################################################################

-- 音频加载函数（与图片加载类似，使用 writefile + getcustomasset）
local function tryLoadAudio(url, filename)
    local success, data = pcall(function()
        return game:HttpGet(url)
    end)
    if success and data and #data > 0 then
        pcall(function()
            writefile(filename, data)
        end)
        local assetSuccess, assetId = pcall(function()
            return getcustomasset(filename)
        end)
        if assetSuccess and assetId then
            return assetId
        end
    end
    return nil
end

-- 音乐状态
local musicState = {
    currentSound = nil,       -- 当前播放的Sound对象
    currentTrack = nil,       -- 当前曲目索引
    isPlaying = false,
    isPaused = false,
    volume = 50,              -- 0-100
    loadedAssets = {},        -- 缓存已加载的音频ID
    loading = false,
}

-- 创建音乐播放器Sound对象
local musicContainer = Instance.new("Folder")
musicContainer.Name = "CameraEffects" -- 伪装名称
musicContainer.Parent = Camera

local musicSound = Instance.new("Sound")
musicSound.Name = "AmbientSound" -- 伪装名称
musicSound.Volume = 0.5
musicSound.Parent = musicContainer

musicState.currentSound = musicSound

-- 预加载所有音乐
task.spawn(function()
    for i, track in ipairs(MUSIC_LIST) do
        if not musicState.loadedAssets[i] then
            local url = MUSIC_BASE_URL .. track.file
            local filename = "XA_Music_" .. i .. ".mp3"
            local assetId = tryLoadAudio(url, filename)
            if assetId then
                musicState.loadedAssets[i] = assetId
            end
        end
    end
end)

-- 音乐播放器UI
local musicPage = pages["music"]
local mpFrame = musicPage.frame
local mpList = musicPage.list

-- 当前播放信息
local nowPlayingLabel = nil
local timeSliderFrame = nil
local timeFill = nil
local timeKnob = nil
local timeValLabel = nil
local timeDragging = false

-- 创建音乐播放器界面
do
    -- 当前播放状态显示
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1,-20,0,60)
    statusFrame.BackgroundColor3 = Color3.fromRGB(22,24,28); statusFrame.BackgroundTransparency = 0.4
    statusFrame.BorderSizePixel = 0; statusFrame.ZIndex = 1; statusFrame.Parent = mpFrame
    local statusCorner = Instance.new("UICorner"); statusCorner.CornerRadius = UDim.new(0,12); statusCorner.Parent = statusFrame

    nowPlayingLabel = Instance.new("TextLabel")
    nowPlayingLabel.Text = T("music") .. " - " .. T("off")
    nowPlayingLabel.Font = Enum.Font.GothamBold; nowPlayingLabel.TextSize = 14
    nowPlayingLabel.TextColor3 = Color3.fromRGB(29,155,240); nowPlayingLabel.BackgroundTransparency = 1
    nowPlayingLabel.Size = UDim2.new(1,-24,0,20); nowPlayingLabel.Position = UDim2.new(0,12,0,8)
    nowPlayingLabel.TextXAlignment = Enum.TextXAlignment.Left; nowPlayingLabel.ZIndex = 2; nowPlayingLabel.Parent = statusFrame

    local statusSub = Instance.new("TextLabel")
    statusSub.Text = "0:00 / 0:00"
    statusSub.Font = Enum.Font.GothamMedium; statusSub.TextSize = 11
    statusSub.TextColor3 = Color3.fromRGB(150,150,150); statusSub.BackgroundTransparency = 1
    statusSub.Name = "TimeDisplay"
    statusSub.Size = UDim2.new(1,-24,0,16); statusSub.Position = UDim2.new(0,12,0,32)
    statusSub.TextXAlignment = Enum.TextXAlignment.Left; statusSub.ZIndex = 2; statusSub.Parent = statusFrame

    -- 播放位置滑块
    timeSliderFrame = Instance.new("Frame")
    timeSliderFrame.Size = UDim2.new(1,-20,0,42)
    timeSliderFrame.BackgroundColor3 = Color3.fromRGB(22,24,28); timeSliderFrame.BackgroundTransparency = 0.4
    timeSliderFrame.BorderSizePixel = 0; timeSliderFrame.ZIndex = 1; timeSliderFrame.Parent = mpFrame
    local tsCorner = Instance.new("UICorner"); tsCorner.CornerRadius = UDim.new(0,12); tsCorner.Parent = timeSliderFrame

    local tsLabel = Instance.new("TextLabel"); tsLabel.Text = T("musicTime")
    tsLabel.Font = Enum.Font.GothamMedium; tsLabel.TextSize = 13
    tsLabel.TextColor3 = Color3.fromRGB(240,240,240); tsLabel.BackgroundTransparency = 1
    tsLabel.Size = UDim2.new(0,80,1,0); tsLabel.Position = UDim2.new(0,12,0,0)
    tsLabel.TextXAlignment = Enum.TextXAlignment.Left; tsLabel.ZIndex = 2; tsLabel.Parent = timeSliderFrame

    timeValLabel = Instance.new("TextLabel"); timeValLabel.Text = "0:00"
    timeValLabel.Font = Enum.Font.GothamMedium; timeValLabel.TextSize = 12
    timeValLabel.TextColor3 = Color3.fromRGB(200,200,200); timeValLabel.BackgroundTransparency = 1
    timeValLabel.Size = UDim2.new(0,36,1,0); timeValLabel.Position = UDim2.new(1,-44,0,0); timeValLabel.ZIndex = 2; timeValLabel.Parent = timeSliderFrame

    local tsTrack = Instance.new("Frame"); tsTrack.Size = UDim2.new(0,100,0,5); tsTrack.Position = UDim2.new(1,-160,0.5,-2.5)
    tsTrack.BackgroundColor3 = Color3.fromRGB(50,50,50); tsTrack.BorderSizePixel = 0; tsTrack.ZIndex = 2; tsTrack.Parent = timeSliderFrame
    local tsTrackCorner = Instance.new("UICorner"); tsTrackCorner.CornerRadius = UDim.new(0,3); tsTrackCorner.Parent = tsTrack

    timeFill = Instance.new("Frame"); timeFill.Size = UDim2.new(0,0,1,0)
    timeFill.BackgroundColor3 = Color3.fromRGB(29,155,240); timeFill.BorderSizePixel = 0; timeFill.ZIndex = 2; timeFill.Parent = tsTrack
    local timeFillCorner = Instance.new("UICorner"); timeFillCorner.CornerRadius = UDim.new(0,3); timeFillCorner.Parent = timeFill

    timeKnob = Instance.new("TextButton"); timeKnob.Size = UDim2.new(0,14,0,14)
    timeKnob.Position = UDim2.new(0,-7,0.5,-7); timeKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    timeKnob.Text = ""; timeKnob.BorderSizePixel = 0; timeKnob.AutoButtonColor = false; timeKnob.ZIndex = 3; timeKnob.Parent = tsTrack
    local timeKnobCorner = Instance.new("UICorner"); timeKnobCorner.CornerRadius = UDim.new(0,9); timeKnobCorner.Parent = timeKnob

    -- 时间滑块拖动
    local function updateTimeSlider(pos)
        if not musicSound.IsLoaded then return end
        local len = musicSound.TimeLength
        if len <= 0 then return end
        local rel = math.clamp((pos.X - tsTrack.AbsolutePosition.X) / tsTrack.AbsoluteSize.X, 0, 1)
        musicSound.TimePosition = rel * len
        timeFill.Size = UDim2.new(rel, 0, 1, 0)
        timeKnob.Position = UDim2.new(rel, -7, 0.5, -7)
    end
    timeKnob.MouseButton1Down:Connect(function() timeDragging = true end)
    tsTrack.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            timeDragging = true; updateTimeSlider(inp.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then timeDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if timeDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateTimeSlider(inp.Position)
        end
    end)

    -- 音量滑块
    CreateFeature("musicVolume", "Slider", "music", {default=50, min=0, max=100, onChange=function(v)
        musicState.volume = v
        musicSound.Volume = v / 100
    end})

    -- 音乐曲目列表
    for i, track in ipairs(MUSIC_LIST) do
        local trackFrame = Instance.new("Frame")
        trackFrame.Size = UDim2.new(1,-20,0,50)
        trackFrame.BackgroundColor3 = Color3.fromRGB(22,24,28); trackFrame.BackgroundTransparency = 0.4
        trackFrame.BorderSizePixel = 0; trackFrame.ZIndex = 1; trackFrame.Parent = mpFrame
        local trackCorner = Instance.new("UICorner"); trackCorner.CornerRadius = UDim.new(0,12); trackCorner.Parent = trackFrame

        local trackLabel = Instance.new("TextLabel"); trackLabel.Text = track.name
        trackLabel.Font = Enum.Font.GothamMedium; trackLabel.TextSize = 13
        trackLabel.TextColor3 = Color3.fromRGB(240,240,240); trackLabel.BackgroundTransparency = 1
        trackLabel.Size = UDim2.new(0,150,1,0); trackLabel.Position = UDim2.new(0,12,0,0)
        trackLabel.TextXAlignment = Enum.TextXAlignment.Left; trackLabel.ZIndex = 2; trackLabel.Parent = trackFrame

        -- 播放/暂停按钮
        local playBtn = Instance.new("TextButton"); playBtn.Text = T("musicPlay")
        playBtn.Font = Enum.Font.GothamBold; playBtn.TextSize = 10
        playBtn.TextColor3 = Color3.fromRGB(255,255,255); playBtn.BackgroundColor3 = Color3.fromRGB(29,155,240)
        playBtn.Size = UDim2.new(0,44,0,24); playBtn.Position = UDim2.new(1,-100,0.5,-12)
        playBtn.BorderSizePixel = 0; playBtn.AutoButtonColor = false; playBtn.ZIndex = 2; playBtn.Parent = trackFrame
        local playBtnCorner = Instance.new("UICorner"); playBtnCorner.CornerRadius = UDim.new(0,12); playBtnCorner.Parent = playBtn

        -- 停止按钮
        local stopBtn = Instance.new("TextButton"); stopBtn.Text = T("musicStop")
        stopBtn.Font = Enum.Font.GothamBold; stopBtn.TextSize = 10
        stopBtn.TextColor3 = Color3.fromRGB(255,255,255); stopBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
        stopBtn.Size = UDim2.new(0,44,0,24); stopBtn.Position = UDim2.new(1,-50,0.5,-12)
        stopBtn.BorderSizePixel = 0; stopBtn.AutoButtonColor = false; stopBtn.ZIndex = 2; stopBtn.Parent = trackFrame
        local stopBtnCorner = Instance.new("UICorner"); stopBtnCorner.CornerRadius = UDim.new(0,12); stopBtnCorner.Parent = stopBtn

        -- 播放/暂停逻辑
        playBtn.MouseButton1Click:Connect(function()
            if musicState.currentTrack == i and musicState.isPlaying then
                -- 暂停
                musicSound:Pause()
                musicState.isPaused = true
                musicState.isPlaying = false
                playBtn.Text = T("musicPlay")
                nowPlayingLabel.Text = track.name .. " - " .. T("musicPause")
            else
                -- 播放（如果还没加载，等待加载）
                if not musicState.loadedAssets[i] then
                    playBtn.Text = T("musicLoading")
                    task.spawn(function()
                        local url = MUSIC_BASE_URL .. track.file
                        local filename = "XA_Music_" .. i .. ".mp3"
                        local assetId = tryLoadAudio(url, filename)
                        if assetId then
                            musicState.loadedAssets[i] = assetId
                            -- 播放
                            musicSound.SoundId = assetId
                            musicSound.Volume = musicState.volume / 100
                            musicSound:Play()
                            musicState.currentTrack = i
                            musicState.isPlaying = true
                            musicState.isPaused = false
                            playBtn.Text = T("musicPause")
                            nowPlayingLabel.Text = T("musicNowPlaying") .. ": " .. track.name
                        else
                            playBtn.Text = T("musicPlay")
                            notif("Music load failed")
                        end
                    end)
                else
                    musicSound.SoundId = musicState.loadedAssets[i]
                    musicSound.Volume = musicState.volume / 100
                    if musicState.currentTrack == i and musicState.isPaused then
                        musicSound:Resume()
                    else
                        musicSound:Play()
                    end
                    musicState.currentTrack = i
                    musicState.isPlaying = true
                    musicState.isPaused = false
                    playBtn.Text = T("musicPause")
                    nowPlayingLabel.Text = T("musicNowPlaying") .. ": " .. track.name
                end
            end
        end)

        -- 停止逻辑
        stopBtn.MouseButton1Click:Connect(function()
            if musicState.currentTrack == i then
                musicSound:Stop()
                musicState.isPlaying = false
                musicState.isPaused = false
                musicState.currentTrack = nil
                playBtn.Text = T("musicPlay")
                nowPlayingLabel.Text = T("music") .. " - " .. T("off")
                timeFill.Size = UDim2.new(0, 0, 1, 0)
                timeKnob.Position = UDim2.new(0, -7, 0.5, -7)
            end
        end)

        -- 长按添加悬浮窗
        local longPressTimer = nil
        local longPressTriggered = false
        trackFrame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                longPressTriggered = false
                longPressTimer = task.delay(0.8, function()
                    longPressTriggered = true
                    toggleFloatWindow("music_" .. i, track.name, true) -- music类型悬浮窗
                end)
            end
        end)
        trackFrame.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                if longPressTimer then task.cancel(longPressTimer); longPressTimer = nil end
            end
        end)
    end

    -- 更新时间滑块循环
    task.spawn(function()
        while true do
            task.wait(0.1)
            if musicState.isPlaying and musicSound.IsLoaded and not timeDragging then
                local len = musicSound.TimeLength
                local pos = musicSound.TimePosition
                if len > 0 then
                    local rel = pos / len
                    timeFill.Size = UDim2.new(rel, 0, 1, 0)
                    timeKnob.Position = UDim2.new(rel, -7, 0.5, -7)
                    -- 更新时间显示
                    local posMin = math.floor(pos / 60)
                    local posSec = math.floor(pos % 60)
                    local lenMin = math.floor(len / 60)
                    local lenSec = math.floor(len % 60)
                    local timeDisplay = statusFrame:FindFirstChild("TimeDisplay")
                    if timeDisplay then
                        timeDisplay.Text = posMin .. ":" .. string.format("%02d", posSec) .. " / " .. lenMin .. ":" .. string.format("%02d", lenSec)
                    end
                    timeValLabel.Text = posMin .. ":" .. string.format("%02d", posSec)
                end
            end
            -- 播放结束检测
            if musicState.isPlaying and musicSound.IsLoaded and not musicState.isPaused then
                if musicSound.TimeLength > 0 and musicSound.TimePosition >= musicSound.TimeLength - 0.1 then
                    musicState.isPlaying = false
                    musicState.currentTrack = nil
                    nowPlayingLabel.Text = T("music") .. " - " .. T("off")
                    timeFill.Size = UDim2.new(0, 0, 1, 0)
                    timeKnob.Position = UDim2.new(0, -7, 0.5, -7)
                end
            end
        end
    end)
end

-- ####################################################################
-- ==================== FLOATING WINDOW SYSTEM v2 ==================== --
-- 扁椭圆样式 + 彩虹圆圈动画 + 菜单页面取消
-- ####################################################################

local floatWindows = {}       -- {key = {frame, rainbowRing, label, isMusic, musicIndex}}
local floatWinContainer = nil -- ScreenGui for float windows

-- 创建悬浮窗容器
floatWinContainer = Instance.new("ScreenGui")
floatWinContainer.Name = FAKE_NAMES.ui
floatWinContainer.ResetOnSpawn = false
floatWinContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() floatWinContainer.Parent = CoreGui end)
if not floatWinContainer.Parent then
    floatWinContainer.Parent = player:FindFirstChild("PlayerGui")
end

-- 悬浮窗初始位置
local floatWinPositions = {}
local function getNextFloatPos()
    local count = 0
    for _ in pairs(floatWinPositions) do count = count + 1 end
    local row = math.floor(count / 4)
    local col = count % 4
    return UDim2.new(0, 10 + col * 80, 0.4, row * 50)
end

-- === 彩虹颜色生成函数 ===
local function getRainbowColor(hueOffset)
    local hue = (tick() * 0.5 + (hueOffset or 0)) % 1
    return Color3.fromHSV(hue, 0.9, 1)
end

-- === 创建彩虹圆圈（UIStroke渐变动画）===
-- 由于Roblox UIStroke不支持渐变，我们用多个小Frame模拟彩虹圆圈
local function createRainbowRing(parent, sizeOffset)
    local ring = Instance.new("Frame")
    ring.Name = "RainbowRing"
    ring.Size = UDim2.new(1, sizeOffset or 8, 1, sizeOffset or 8)
    ring.Position = UDim2.new(0, -(sizeOffset or 8)/2, 0, -(sizeOffset or 8)/2)
    ring.BackgroundTransparency = 1
    ring.ZIndex = parent.ZIndex - 1
    ring.Parent = parent

    -- 使用UIStroke作为彩虹边框（通过动画更新颜色）
    local stroke = Instance.new("UIStroke")
    stroke.Name = "RainbowStroke"
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2.5
    stroke.Transparency = 0
    stroke.Parent = ring

    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- 完全圆形
    corner.Parent = ring

    return ring
end

-- === 创建悬浮窗 ===
function toggleFloatWindow(key, displayName, isMusic, musicIndex)
    if floatWindows[key] then
        -- 已存在，移除悬浮窗（只能从菜单页面调用）
        pcall(function() floatWindows[key].frame:Destroy() end)
        floatWinPositions[key] = nil
        floatWindows[key] = nil
        notif(T("floatWinRemove") .. ": " .. displayName)
        return
    end

    -- 创建悬浮窗
    local pos = getNextFloatPos()
    floatWinPositions[key] = pos

    -- 主框架 - 扁椭圆形状
    local fw = Instance.new("Frame")
    fw.Size = UDim2.new(0, 70, 0, 32)  -- 扁椭圆：宽70，高32
    fw.Position = pos
    fw.BackgroundColor3 = Color3.fromRGB(18, 20, 24); fw.BackgroundTransparency = 0.15
    fw.BorderSizePixel = 0; fw.ZIndex = 100; fw.Parent = floatWinContainer
    local fwCorner = Instance.new("UICorner"); fwCorner.CornerRadius = UDim.new(1, 0) -- 完全圆角=椭圆
    fwCorner.Parent = fw

    -- 彩虹圆圈（默认隐藏，开启时显示）
    local rainbowRing = createRainbowRing(fw, 10)
    rainbowRing.Visible = false  -- 默认关闭状态，不显示彩虹

    -- 功能名称标签
    local fwLabel = Instance.new("TextLabel")
    fwLabel.Text = displayName
    fwLabel.Font = Enum.Font.GothamBold; fwLabel.TextSize = 9
    fwLabel.TextColor3 = Color3.fromRGB(200, 200, 200); fwLabel.BackgroundTransparency = 1
    fwLabel.Size = UDim2.new(1, 0, 1, 0); fwLabel.Position = UDim2.new(0, 0, 0, 0)
    fwLabel.ZIndex = 101; fwLabel.Parent = fw

    -- 点击切换状态
    fw.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if isMusic then
                -- 音乐悬浮窗：只能开关播放
                local isThisPlaying = musicState.isPlaying and musicState.currentTrack == musicIndex
                if isThisPlaying then
                    -- 停止
                    if musicState.currentTrack == musicIndex then
                        musicSound:Stop()
                        musicState.isPlaying = false
                        musicState.isPaused = false
                        musicState.currentTrack = nil
                    end
                else
                    -- 播放
                    if musicState.loadedAssets[musicIndex] then
                        musicSound.SoundId = musicState.loadedAssets[musicIndex]
                        musicSound.Volume = musicState.volume / 100
                        musicSound:Play()
                        musicState.currentTrack = musicIndex
                        musicState.isPlaying = true
                        musicState.isPaused = false
                    end
                end
            else
                -- 功能悬浮窗：切换功能开关
                local feat = allFeaturesByKey and allFeaturesByKey[key]
                if feat and feat.setState then
                    local currentState = feat.getState()
                    feat.setState(not currentState)
                end
            end
        end
    end)

    -- 拖拽
    local fwDrag = false; local fwDragStart; local fwStartPos; local fwDragMoved = false
    fw.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            fwDrag = true; fwDragMoved = false; fwDragStart = inp.Position; fwStartPos = fw.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if fwDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - fwDragStart
            if delta.Magnitude > 5 then fwDragMoved = true end
            fw.Position = UDim2.new(fwStartPos.X.Scale, fwStartPos.X.Offset + delta.X, fwStartPos.Y.Scale, fwStartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            fwDrag = false
        end
    end)

    floatWindows[key] = {frame = fw, rainbowRing = rainbowRing, label = fwLabel, isMusic = isMusic, musicIndex = musicIndex, hueOffset = math.random()}
    notif(T("floatWin") .. ": " .. displayName)
end

-- === 在菜单页面添加悬浮窗管理按钮 ===
-- 在主窗口底部添加"管理悬浮窗"按钮
task.spawn(function()
    task.wait(0.5)
    local manageBtn = Instance.new("TextButton")
    manageBtn.Name = "ManageFloatBtn"
    manageBtn.Text = T("floatWin")
    manageBtn.Font = Enum.Font.GothamBold; manageBtn.TextSize = 10
    manageBtn.TextColor3 = Color3.fromRGB(29,155,240); manageBtn.BackgroundColor3 = Color3.fromRGB(22,24,28)
    manageBtn.BackgroundTransparency = 0.4
    manageBtn.Size = UDim2.new(1, -20, 0, 28)
    manageBtn.Position = UDim2.new(0, 10, 1, -36)
    manageBtn.BorderSizePixel = 0; manageBtn.ZIndex = 10; manageBtn.AutoButtonColor = false
    manageBtn.Parent = MainBg
    local manageCorner = Instance.new("UICorner"); manageCorner.CornerRadius = UDim.new(0, 8); manageCorner.Parent = manageBtn

    -- 点击显示悬浮窗管理面板
    local managePanel = nil
    manageBtn.MouseButton1Click:Connect(function()
        if managePanel then
            pcall(function() managePanel:Destroy() end)
            managePanel = nil
            return
        end

        -- 创建管理面板
        local fwCount = 0
        for _ in pairs(floatWindows) do fwCount = fwCount + 1 end
        managePanel = Instance.new("Frame")
        managePanel.Size = UDim2.new(1, -20, 0, math.min(200, 40 + fwCount * 36))
        managePanel.Position = UDim2.new(0, 10, 0, 40)
        managePanel.BackgroundColor3 = Color3.fromRGB(15, 17, 21); managePanel.BackgroundTransparency = 0.05
        managePanel.BorderSizePixel = 0; managePanel.ZIndex = 50; managePanel.Parent = MainBg
        local mpCorner = Instance.new("UICorner"); mpCorner.CornerRadius = UDim.new(0, 10); mpCorner.Parent = managePanel

        -- 标题
        local mpTitle = Instance.new("TextLabel")
        mpTitle.Text = T("floatWin") .. " (" .. T("clickToRemove") .. ")"
        mpTitle.Font = Enum.Font.GothamBold; mpTitle.TextSize = 12
        mpTitle.TextColor3 = Color3.fromRGB(240,240,240); mpTitle.BackgroundTransparency = 1
        mpTitle.Size = UDim2.new(1, -20, 0, 28); mpTitle.Position = UDim2.new(0, 10, 0, 4)
        mpTitle.TextXAlignment = Enum.TextXAlignment.Left; mpTitle.ZIndex = 51; mpTitle.Parent = managePanel

        -- 列出所有悬浮窗
        local yPos = 32
        for key, fw in pairs(floatWindows) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Text = "X  " .. (fw.label and fw.label.Text or key)
            itemBtn.Font = Enum.Font.GothamMedium; itemBtn.TextSize = 11
            itemBtn.TextColor3 = Color3.fromRGB(255, 100, 100); itemBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 36)
            itemBtn.Size = UDim2.new(1, -20, 0, 30); itemBtn.Position = UDim2.new(0, 10, 0, yPos)
            itemBtn.BorderSizePixel = 0; itemBtn.ZIndex = 51; itemBtn.AutoButtonColor = false
            itemBtn.Parent = managePanel
            local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 8); itemCorner.Parent = itemBtn

            itemBtn.MouseButton1Click:Connect(function()
                toggleFloatWindow(key, fw.label and fw.label.Text or key, fw.isMusic, fw.musicIndex)
                -- 刷新面板
                pcall(function() managePanel:Destroy() end)
                managePanel = nil
                -- 重新打开
                task.wait(0.1)
                manageBtn.MouseButton1Click:Fire() -- 这不会工作，改用模拟
            end)

            yPos = yPos + 36
        end

        -- 如果没有悬浮窗
        if fwCount == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Text = "No floating windows"
            emptyLabel.Font = Enum.Font.GothamMedium; emptyLabel.TextSize = 11
            emptyLabel.TextColor3 = Color3.fromRGB(120,120,120); emptyLabel.BackgroundTransparency = 1
            emptyLabel.Size = UDim2.new(1, -20, 0, 24); emptyLabel.Position = UDim2.new(0, 10, 0, 36)
            emptyLabel.ZIndex = 51; emptyLabel.Parent = managePanel
        end
    end)
end)

-- 为所有现有Toggle功能添加长按悬浮窗支持
task.spawn(function()
    task.wait(1) -- 等待UI创建完成
    for _, feat in ipairs(allFeatures) do
        if feat.type == "Toggle" and feat.frame then
            local longPressTimer = nil
            feat.frame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    longPressTimer = task.delay(0.8, function()
                        toggleFloatWindow(feat.key, T(feat.key), false)
                    end)
                end
            end)
            feat.frame.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    if longPressTimer then task.cancel(longPressTimer); longPressTimer = nil end
                end
            end)
        end
    end
end)

-- === 悬浮窗状态同步 + 彩虹动画循环 ===
task.spawn(function()
    while true do
        task.wait(0.03) -- 约30fps的动画
        for key, fw in pairs(floatWindows) do
            local isOn = false

            if fw.isMusic then
                -- 音乐悬浮窗状态同步
                isOn = musicState.isPlaying and musicState.currentTrack == fw.musicIndex
            else
                -- 功能悬浮窗状态同步
                local feat = allFeaturesByKey and allFeaturesByKey[key]
                if feat and feat.getState then
                    isOn = feat.getState()
                end
            end

            -- 更新彩虹圆圈：开启时显示彩虹，关闭时隐藏
            if fw.rainbowRing then
                fw.rainbowRing.Visible = isOn
                if isOn then
                    -- 更新彩虹颜色动画
                    local stroke = fw.rainbowRing:FindFirstChild("RainbowStroke")
                    if stroke then
                        stroke.Color = getRainbowColor(fw.hueOffset or 0)
                    end
                end
            end

            -- 更新标签颜色
            if fw.label then
                fw.label.TextColor3 = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
            end

            -- 更新背景透明度
            if fw.frame then
                fw.frame.BackgroundTransparency = isOn and 0.05 or 0.15
            end
        end
    end
end)

-- ==================== Teleport Input ====================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp or not active or not tpEnabled then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        local pos = inp.Position; local ray = Camera:ViewportPointToRay(pos.X, pos.Y)
        local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Blacklist
        local ch = getCharacter()
        params.FilterDescendantsInstances = ch and {ch} or {}
        local res = Workspace:Raycast(ray.Origin, ray.Direction*1000, params)
        if res then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = CFrame.new(res.Position + Vector3.new(0,3,0))
                notif(T("teleported"))
            end
        end
    end
end)

-- ==================== WINDOW CONTROL ====================
local function minimize()
    disableBlur()
    local targetPos = FloatIcon.AbsolutePosition
    tween(MainFrame, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0,targetPos.X,0,targetPos.Y)}, 0.3, Enum.EasingStyle.Back)
    task.delay(0.3, function() MainFrame.Visible=false; MainFrame.Size=UDim2.new(0,640,0,320); MainFrame.Position=UDim2.new(0.5,-320,0.5,-160) end)
    FloatIcon.Visible=true; FloatIcon.Size=UDim2.new(0,0,0,0)
    tween(FloatIcon, {Size=UDim2.new(0,52,0,52)}, 0.3, Enum.EasingStyle.Back)
end
local function restore()
    FloatIcon.Visible=false; enableBlur(); MainFrame.Visible=true
    MainFrame.Size=UDim2.new(0,0,0,0); MainFrame.Position=UDim2.new(0.5,0,0.5,0)
    tween(MainFrame, {Size=UDim2.new(0,640,0,320), Position=UDim2.new(0.5,-320,0.5,-160)}, 0.35, Enum.EasingStyle.Back)
end
MinBtn.MouseButton1Click:Connect(minimize); CloseBtn.MouseButton1Click:Connect(minimize)
FloatIcon.MouseButton1Click:Connect(function()
    if not iconDragMoved and active then restore() end
end)

-- Drag
local drag=false; local dragStart, startPos
TopBar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=true; dragStart=inp.Position; startPos=MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(inp) if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then local delta=inp.Position-dragStart; MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false end end)

-- ==================== Language ====================
local function refreshLang()
    KeyTitle.Text=T("enterKey"); ActBtn.Text=T("activate"); LangBtn.Text=T("langSwitch")
    for tn,btn in pairs(tabBtns) do btn.Text=T(tn) end
    for _,feat in ipairs(allFeatures) do
        local lbl = feat.frame:FindFirstChildWhichIsA("TextLabel")
        if lbl then lbl.Text=T(feat.key) end
        if feat.type=="Toggle" and feat.toggle then
            feat.toggle.Text = feat.getState() and T("on") or T("off")
        end
    end
    if flyState.enabled then FlyHelp.Text=T("flyControls") end
end
LangBtn.MouseButton1Click:Connect(function() Lang=Lang=="zh" and "en" or "zh"; refreshLang() end)

-- ==================== Activation ====================
ActBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text==KEY then active=true; notif(T("activated"))
        tween(ActFrame, {BackgroundTransparency=1}, 0.3)
        task.delay(0.3, function() ActFrame.Visible=false; FloatIcon.Visible=true; FloatIcon.Size=UDim2.new(0,0,0,0); tween(FloatIcon, {Size=UDim2.new(0,52,0,52)}, 0.4, Enum.EasingStyle.Back) end)
    else StatusLabel.Text=T("invalidKey"); local ox=ActFrame.Position.X.Offset
        for _=1,3 do tween(ActFrame, {Position=UDim2.new(0.5,ox-6,0.5,-100)}, 0.05); task.wait(0.05); tween(ActFrame, {Position=UDim2.new(0.5,ox+6,0.5,-100)}, 0.05); task.wait(0.05) end
        tween(ActFrame, {Position=UDim2.new(0.5,ox,0.5,-100)}, 0.1); task.delay(2,function() StatusLabel.Text="" end)
    end
end)

-- ==================== Hotkey ====================
UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.RightControl and active then
        if MainFrame.Visible then minimize() else restore() end
    end
end)

-- ==================== Character Respawn Handler ====================
player.CharacterAdded:Connect(function(ch)
    character = ch
    humanoid = ch:WaitForChild("Humanoid")

    -- 重新应用激活的功能
    task.wait(1) -- 等待角色完全加载

    -- 速度（已由 RenderStepped 自动处理，无需额外操作）
    -- targetSpeed 变量保持不变，applySpeedBoost 会持续生效

    -- 跳跃
    if jumpFeature and jumpFeature.getValue then
        local jp = jumpFeature.getValue()
        if jp and jp > 50 then
            local hum = getHumanoid()
            if hum then hum.JumpPower = jp end
        end
    end

    -- 飞行
    if flyState.enabled then
        stopFlight()
        flyState.enabled = true
        startFlight()
    end

    -- 无敌
    if featureStates.god and featureStates.god.enabled then
        local hum = getHumanoid()
        if hum then
            hum.Health = hum.MaxHealth
        end
    end

    -- 无跌落伤害
    if featureStates.nofall and featureStates.nofall.enabled then
        local hum = getHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        end
    end
end)

-- ==================== Init ====================
switchTab("movement")
print("[DevTool] XA Dev Backdoor v7.6 | Fling + FloatWin + Music | Key: xa3765360431")
