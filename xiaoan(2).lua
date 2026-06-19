--[[
    X-Style Dev Backdoor v5.2 (Mobile Touch)
    Key: xa3765360431
    - GitHub images via writefile+getcustomasset (rbxassetid://)
    - Mobile touch flight (joystick + ↑↓ buttons)
    - Speed boost without WalkSpeed modification (anti-cheat bypass)
    - Transparent UI layers to show background image
    - All features properly manage connections and state
]]

-- ==================== GitHub 图片链接 ====================
local ICON_URL = "https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/XA%E5%9B%BE%E6%A0%87.png"
local BACKGROUND_URL = "https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/XA%E8%8F%9C%E5%8D%95%E8%83%8C%E6%99%AF.png"

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
}
local function T(key) return L[key] and L[key][Lang] or key end

-- ==================== KEY ====================
local KEY = "xa3765360431"
local active = false

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
local NotifGui = Instance.new("ScreenGui"); NotifGui.Name = "NotifGui"; NotifGui.Parent = CoreGui
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
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "XDev"; MainGui.Parent = CoreGui
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

-- ==================== MAIN WINDOW ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 320); MainFrame.Position = UDim2.new(0.5, -320, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 5; MainFrame.Parent = MainGui

if bgImage then
    local MainBg = Instance.new("ImageLabel"); MainBg.Size = UDim2.new(1,0,1,0); MainBg.Position = UDim2.new(0,0,0,0)
    MainBg.BackgroundTransparency = 1; MainBg.Image = bgImage; MainBg.ImageTransparency = 0.3
    MainBg.ScaleType = Enum.ScaleType.Crop; MainBg.ZIndex = 0; MainBg.Parent = MainFrame
    MainBg.Name = "MainBg"
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
TabIndicator.Size = UDim2.new(0.24,0,0,3); TabIndicator.Position = UDim2.new(0.005,0,1,-3)
TabIndicator.BackgroundColor3 = Color3.fromRGB(29,155,240); TabIndicator.BorderSizePixel = 0
TabIndicator.ZIndex = 3; TabIndicator.Parent = TabBar

local tabs = {"movement","combat","world"}
local curTab = "movement"
local tabBtns = {}
for i, tab in ipairs(tabs) do
    local b = Instance.new("TextButton"); b.Text = T(tab); b.Font = Enum.Font.GothamMedium; b.TextSize = 12
    b.TextColor3 = i==1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,185,190)
    b.BackgroundTransparency = 1; b.Size = UDim2.new(1/3,-10,1,0)
    b.Position = UDim2.new((i-1)/3,5,0,0); b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = TabBar
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
    tween(TabIndicator, {Position = UDim2.new((idx-1)/3+0.005,0,1,-3)}, 0.3, Enum.EasingStyle.Quart)
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
    table.insert(allFeatures, feat); container.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y+32)
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
        hl.Name = "ESPHighlight"
        hl.FillColor = Color3.fromRGB(255,50,50)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.OutlineTransparency = 0
        hl.Adornee = char
        hl.Parent = char
        espHighlights[plr] = hl

        -- 名称+距离标签
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPLabel"
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
        local old = plr.Character:FindFirstChild("ESPHighlight")
        if old then pcall(function() old:Destroy() end) end
        local oldLabel = plr.Character:FindFirstChild("ESPLabel")
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
FloatIcon.MouseButton1Click:Connect(function() if active then restore() end end)

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
print("[DevTool] XA Dev Backdoor v5.2 | Mobile Touch | Key: xa3765360431")
