-- ================================================================
-- YC GUI /XAjiaoben - Roblox 多功能脚本库
-- 版本: 1.0.0
-- 作者: xiaoanbilibili
-- GitHub: https://github.com/[SJSJXN46xQPS]
--/xiaojiaoben
-- 许可证: MIT License
-- 
-- 功能特性:
--  借用 GUI 界面
-- 小部分功能
-- 🔧 可自定义设置
-- 📱 响应式设计
-- 🔔 通知系统
-- 🎯 主题系统
-- ================================================================

--[[
    使用方法:
    在 Roblox 执行器中运行:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/[你的用户名]/xiaojiaoben/main/yc_gui.lua"))()
]]

-- ==================== 安全检查与初始化 ====================
-- 防止重复加载
if _G.YCGUILoaded then
    print("⚠️ YC GUI 已经加载，跳过重复加载")
    return _G.YCGUIInstance
end

_G.YCGUILoaded = true

-- 打印加载信息
print("========================================")
print("🎮 YC GUI Library v1.0.0")
print("📂 GitHub: github.com/[你的用户名]/xiaojiaoben")
print("🔄 正在初始化...")
print("========================================")

-- 安全检查函数
local function SecurityChecks()
    -- 检查是否在 Roblox 环境中
    if not game or not game:IsA("DataModel") then
        warn("❌ 错误：不在 Roblox 环境中运行")
        return false
    end
    
    -- 检查必要服务是否存在
    local requiredServices = {
        "HttpService",
        "UserInputService", 
        "TweenService",
        "RunService",
        "Players"
    }
    
    for _, serviceName in ipairs(requiredServices) do
        if not pcall(function() return game:GetService(serviceName) end) then
            warn("❌ 错误：缺少必要服务 " .. serviceName)
            return false
        end
    end
    
    -- 检查玩家
    local Players = game:GetService("Players")
    if not Players.LocalPlayer then
        warn("⚠️ 警告：未找到本地玩家，某些功能可能受限")
    end
    
    return true
end

-- 执行安全检查
if not SecurityChecks() then
    warn("❌ YC GUI 安全检查失败，脚本终止")
    return nil
end

-- 网络请求重试机制
local function SafeHttpGet(url, retries)
    retries = retries or 3
    for attempt = 1, retries do
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        if success and result then
            return result
        end
        if attempt < retries then
            task.wait(1) -- 等待1秒后重试
            print("🔄 网络请求重试 (" .. attempt .. "/" .. retries .. ")")
        end
    end
    error("❌ 网络请求失败: " .. url)
end

-- 调试模式开关
local DEBUG_MODE = false
local function DebugPrint(...)
    if DEBUG_MODE then
        print("[DEBUG]", ...)
    end
end

-- 版本信息
local VERSION_INFO = {
    Major = 1,
    Minor = 0,
    Patch = 0,
    Codename = "Stable",
    BuildDate = "2024"
}

-- ==================== 主脚本开始 ====================
-- 从这里开始是你的原始代码，我将直接添加

-- ==================== 多功能脚本 - 完整工作版 ====================
-- 第一部分：完全复制你的UI库源代码
-- [[ YC GUI Library - Final Release ]]

local Library = {}
local ConfigName = "YCUI/settings_final.json"
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// 辅助函数 //--
local function GetFirstChar(str)
    local first = ""
    for _, code in utf8.codes(str) do first = utf8.char(code); break end
    return first ~= "" and first or string.sub(str, 1, 1)
end

local function ToHSV(color)
    local h, s, v = Color3.toHSV(color)
    return h, s, v
end

local function FromHSV(h, s, v)
    return Color3.fromHSV(h, s, v)
end

--// 默认配置 //--
local DefaultConfig = {
    ShowHUD = true,
    ShowNotifs = true,
    NotifDuration = 3,
    UIScale = 1.0,
    WindowWidth = 200,
    WindowMaxHeight = 350,
    ItemHeight = 34,
    Theme = "Default",
    UIVisible = true,
    UseCorners = true,
    UseStroke = true
}

Library.Config = HttpService:JSONDecode(HttpService:JSONEncode(DefaultConfig))
Library.Globals = {
    Windows = {},
    Elements = {},
    ThemeObjects = {},
    StyleObjects = {},
    ActiveNotifs = {},
    BoundKeys = {},
    IslandPosition = Vector2.new(0,0),
    IslandObject = nil,
    HUDGradients = {},
    SubWindows = {},
    TopZIndex = 100,
    ActivePicker = nil
}

--// 主题系统 //--
Library.Themes = {
    ["Default"] = {
        Name = "紫罗兰 (Default)",
        Main = Color3.fromRGB(20, 20, 25), MainTrans = 0.1, Gradient1 = Color3.fromRGB(140, 40, 255),
        Text = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(160, 160, 170),
        SettingBg = Color3.fromRGB(25, 25, 30), Accent = Color3.fromRGB(100, 20, 220),
        Scroll = Color3.fromRGB(80, 60, 100), PickerBg = Color3.fromRGB(30, 30, 35)
    },
    ["Ocean"] = {
        Name = "深海蓝 (Ocean)",
        Main = Color3.fromRGB(15, 25, 30), MainTrans = 0.1, Gradient1 = Color3.fromRGB(0, 160, 255),
        Text = Color3.fromRGB(240, 255, 255), TextDark = Color3.fromRGB(140, 160, 170),
        SettingBg = Color3.fromRGB(20, 30, 35), Accent = Color3.fromRGB(0, 100, 180),
        Scroll = Color3.fromRGB(50, 70, 90), PickerBg = Color3.fromRGB(20, 35, 40)
    }
}

local CurrentThemeData = Library.Themes["Default"]

local function CheckFolder()
    if not isfolder("YCUI") then
        makefolder("YCUI")
    end
end

local function SaveConfig()
    CheckFolder()
    pcall(function()
        writefile(ConfigName, HttpService:JSONEncode(Library.Config))
    end)
end

local function LoadConfig()
    CheckFolder()
    if isfile(ConfigName) then
        local s, r = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigName))
        end)
        if s and r then
            for k,v in pairs(r) do
                Library.Config[k] = v
            end
            CurrentThemeData = Library.Themes[Library.Config.Theme] or Library.Themes["Default"]
        end
    end
end

LoadConfig()

if game.CoreGui:FindFirstChild("YC_GUI_Final") then
    game.CoreGui.YC_GUI_Final:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YC_GUI_Final"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = false

-- 尝试放入CoreGui，如果不行则放入PlayerGui
local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not success or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 防止穿透的背景
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Parent = ScreenGui
Backdrop.BackgroundColor3 = Color3.new(0,0,0)
Backdrop.BackgroundTransparency = 1
Backdrop.Size = UDim2.new(1,0,1,0)
Backdrop.ZIndex = 0
Backdrop.Visible = false
Backdrop.Active = true

--// 样式系统 //--
local function RegisterStyle(obj, hasStroke, cornerRadius)
    table.insert(Library.Globals.StyleObjects, {
        Object = obj,
        HasStroke = hasStroke,
        Radius = cornerRadius
    })
    
    local Corner = obj:FindFirstChild("UICorner") or Instance.new("UICorner")
    Corner.Parent = obj
    Corner.CornerRadius = UDim.new(0, Library.Config.UseCorners and cornerRadius or 0)
    
    if hasStroke then
        local Stroke = obj:FindFirstChild("UIStroke") or Instance.new("UIStroke")
        Stroke.Parent = obj
        Stroke.Thickness = 1.5
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Color = CurrentThemeData.Accent
        Stroke.Transparency = Library.Config.UseStroke and 0 or 1
    end
end

-- 主题对象注册
local function RegisterObject(obj, type)
    table.insert(Library.Globals.ThemeObjects, {Object = obj, Type = type})
    
    if type == "Window" then
        obj.BackgroundColor3 = CurrentThemeData.Main
        obj.BackgroundTransparency = CurrentThemeData.MainTrans
    elseif type == "Text" then
        obj.TextColor3 = CurrentThemeData.Text
    elseif type == "TextDark" then
        obj.TextColor3 = CurrentThemeData.TextDark
    elseif type == "SettingBg" then
        obj.BackgroundColor3 = CurrentThemeData.SettingBg
    elseif type == "Accent" then
        obj.BackgroundColor3 = CurrentThemeData.Accent
    elseif type == "PickerBg" then
        obj.BackgroundColor3 = CurrentThemeData.PickerBg
    elseif type == "Scroll" then
        obj.ScrollBarImageColor3 = CurrentThemeData.Scroll
    end
end

--// 通知系统 //--
function Library:Notify(title, status)
    if not Library.Config.ShowNotifs then return end
    
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(0,200,0,35)
    Frame.Position = UDim2.new(1,50,1,-50)
    Frame.ZIndex = 100
    
    local Bar = Instance.new("Frame")
    Bar.Parent = Frame
    Bar.Size = UDim2.new(0,2,1,0)
    Bar.BorderSizePixel = 0
    Bar.BackgroundColor3 = status and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
    
    local TitleLab = Instance.new("TextLabel")
    TitleLab.Parent = Frame
    TitleLab.Text = title
    TitleLab.Font = Enum.Font.GothamBold
    TitleLab.TextSize = 14
    TitleLab.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLab.BackgroundTransparency = 1
    TitleLab.Size = UDim2.new(1,-10,0.5,0)
    TitleLab.Position = UDim2.new(0,10,0,3)
    TitleLab.TextXAlignment = Enum.TextXAlignment.Left
    
    local StateLab = Instance.new("TextLabel")
    StateLab.Parent = Frame
    StateLab.Text = status and "已开启" or "已关闭"
    StateLab.Font = Enum.Font.Gotham
    StateLab.TextSize = 11
    StateLab.TextColor3 = status and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
    StateLab.BackgroundTransparency = 1
    StateLab.Size = UDim2.new(1,-10,0.5,0)
    StateLab.Position = UDim2.new(0,10,0.5,-2)
    StateLab.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 添加到通知列表
    local yOffset = 0
    for i = #Library.Globals.ActiveNotifs, 1, -1 do
        local n = Library.Globals.ActiveNotifs[i]
        if n and n.Parent then
            yOffset = yOffset + 40
        end
    end
    
    table.insert(Library.Globals.ActiveNotifs, Frame)
    
    Frame.Position = UDim2.new(1,-210,1,-50-yOffset)
    
    -- 定时消失
    task.delay(Library.Config.NotifDuration, function()
        if Frame and Frame.Parent then
            for i, v in ipairs(Library.Globals.ActiveNotifs) do
                if v == Frame then
                    table.remove(Library.Globals.ActiveNotifs, i)
                    break
                end
            end
            
            local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.3), {
                Position = Frame.Position + UDim2.new(0,250,0,0)
            })
            tweenOut:Play()
            
            tweenOut.Completed:Connect(function()
                if Frame and Frame.Parent then
                    Frame:Destroy()
                end
            end)
        end
    end)
end

--// 创建窗口系统 //--
function Library:CreateWindow(title, pos, isMain, isSub)
    local Window = {}
    local isFolded = false
    local isOpen = not isSub
    
    if isSub and not Library.Config.UIVisible then
        isOpen = false
    end
    
    local HeaderH = Library.Config.ItemHeight + 6
    
    -- 主窗口框架
    local Main = Instance.new("Frame")
    Main.Name = "Window_" .. title
    Main.Parent = ScreenGui
    Main.Position = pos
    Main.Size = UDim2.new(0, Library.Config.WindowWidth, 0, HeaderH)
    Main.BorderSizePixel = 0
    Main.Visible = isOpen
    Main.ZIndex = 10
    
    RegisterObject(Main, "Window")
    RegisterStyle(Main, true, 10)
    
    -- 缩放
    local Scale = Instance.new("UIScale")
    Scale.Parent = Main
    Scale.Scale = Library.Config.UIScale
    
    -- 标题栏
    local Header = Instance.new("Frame")
    Header.Parent = Main
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, HeaderH)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.Text = title
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = math.clamp(HeaderH * 0.45, 12, 24)
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    RegisterObject(Title, "Text")
    
    -- 内容容器
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 0, 0, HeaderH)
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.ScrollBarThickness = 3
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RegisterObject(Container, "Scroll")
    
    local List = Instance.new("UIListLayout")
    List.Parent = Container
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 5)
    
    local winData = {
        Main = Main,
        Header = Header,
        Title = Title,
        Container = Container,
        List = List,
        IsOpen = isOpen,
        IsSub = isSub
    }
    
    table.insert(Library.Globals.Windows, winData)
    if isSub then
        Library.Globals.SubWindows[title] = winData
    end
    
    -- 刷新高度
    local function RefreshHeight()
        local contentH = List.AbsoluteContentSize.Y
        local curHeadH = HeaderH
        
        if isFolded then
            Main.Size = UDim2.new(0, Library.Config.WindowWidth, 0, curHeadH)
            Container.Visible = false
        else
            Container.Visible = true
            local finalH = math.min(contentH, Library.Config.WindowMaxHeight)
            Main.Size = UDim2.new(0, Library.Config.WindowWidth, 0, curHeadH + finalH)
            Container.Size = UDim2.new(1, 0, 0, finalH)
        end
    end
    
    winData.RefreshHeight = RefreshHeight
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshHeight)
    
    -- 拖拽功能
    local drag, dStart, sPos, sTime
    Header.Active = true
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType.Name:match("Mouse") or input.UserInputType.Name:match("Touch") then
            Library.Globals.TopZIndex = Library.Globals.TopZIndex + 1
            Main.ZIndex = Library.Globals.TopZIndex
            drag = true
            dStart = input.Position
            sPos = Main.Position
            sTime = tick()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType.Name:match("Mouse") or input.UserInputType.Name:match("Touch")) then
            local delta = input.Position - dStart
            Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType.Name:match("Mouse") or input.UserInputType.Name:match("Touch") then
            drag = false
            if (input.Position - dStart).Magnitude < 5 and tick() - sTime < 0.3 then
                isFolded = not isFolded
                RefreshHeight()
            end
        end
    end)
    
    -- 创建按钮
    function Window:CreateButton(name, callback)
        local H = Library.Config.ItemHeight
        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1, 0, 0, H)
        Btn.Text = ""
        Btn.BorderSizePixel = 0
        Btn.ClipsDescendants = true
        
        RegisterStyle(Btn, false, 6)
        
        local Txt = Instance.new("TextLabel")
        Txt.Parent = Btn
        Txt.Text = name
        Txt.Font = Enum.Font.GothamSemibold
        Txt.TextSize = math.clamp(H * 0.42, 12, 18)
        Txt.BackgroundTransparency = 1
        Txt.Size = UDim2.new(1, -10, 1, 0)
        Txt.Position = UDim2.new(0, 10, 0, 0)
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        RegisterObject(Txt, "TextDark")
        
        Btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        
        return Btn
    end
    
    -- 绑定子窗口
    function Window:BindWindow(subWindowName, defaultState)
        local Mod = self:CreateModule(subWindowName, function(bool)
            local target = Library.Globals.SubWindows[subWindowName]
            if target then
                target.IsOpen = bool
                target.Main.Visible = bool and Library.Config.UIVisible
                if bool and Library.Config.UIVisible then
                    if target.Main.Position.X.Offset == 0 and target.Main.Position.Y.Offset == 0 then
                        target.Main.Position = UDim2.new(0.5, -Library.Config.WindowWidth/2, 0.5, -100)
                    end
                end
            end
        end, false)
        if defaultState then Mod:Set(true) end
    end
    
    -- 创建模块（开关）
    function Window:CreateModule(name, callback, allowBind)
        if allowBind == nil then allowBind = true end
        
        local enabled = false
        local H = Library.Config.ItemHeight
        
        -- 主按钮
        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1, 0, 0, H)
        Btn.Text = ""
        Btn.BorderSizePixel = 0
        Btn.ClipsDescendants = true
        
        RegisterStyle(Btn, false, 6)
        
        local Txt = Instance.new("TextLabel")
        Txt.Parent = Btn
        Txt.Text = name
        Txt.Font = Enum.Font.GothamSemibold
        Txt.TextSize = math.clamp(H * 0.42, 12, 18)
        Txt.BackgroundTransparency = 1
        Txt.Size = UDim2.new(1, -35, 1, 0)
        Txt.Position = UDim2.new(0, 10, 0, 0)
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        RegisterObject(Txt, "TextDark")
        
        -- 三个点按钮
        local Dots = Instance.new("TextButton")
        Dots.Parent = Btn
        Dots.Text = "..."
        Dots.Font = Enum.Font.GothamBold
        Dots.TextSize = math.clamp(H * 0.42, 12, 18) + 4
        Dots.BackgroundTransparency = 1
        Dots.Size = UDim2.new(0, H, 1, 0)
        Dots.Position = UDim2.new(1, -H, 0, 0)
        Dots.Visible = allowBind
        RegisterObject(Dots, "TextDark")
        
        -- 设置框架
        local SetFrame = Instance.new("Frame")
        SetFrame.Parent = Container
        SetFrame.BackgroundTransparency = 0.5
        RegisterObject(SetFrame, "SettingBg")
        SetFrame.Size = UDim2.new(1, 0, 0, 0)
        SetFrame.ClipsDescendants = true
        SetFrame.Visible = false
        SetFrame.BorderSizePixel = 0
        
        local SetList = Instance.new("UIListLayout")
        SetList.Parent = SetFrame
        SetList.Padding = UDim.new(0, 5)
        
        -- 切换函数
        local function Toggle(isRemote)
            enabled = not enabled
            
            if enabled then
                RegisterObject(Txt, "Text")
                RegisterObject(Dots, "Text")
            else
                RegisterObject(Txt, "TextDark")
                RegisterObject(Dots, "TextDark")
            end
            
            Library:Notify(name, enabled)
            pcall(callback, enabled)
        end
        
        -- 模块控制函数
        local Module = {}
        function Module:Set(bool)
            if bool ~= enabled then
                Toggle()
            end
        end
        
        -- 主按钮点击事件
        Btn.MouseButton1Click:Connect(function()
            Toggle()
        end)
        
        -- 三个点按钮点击事件
        local setOpen = false
        Dots.MouseButton1Click:Connect(function()
            setOpen = not setOpen
            SetFrame.Visible = true
            
            local targetHeight = setOpen and SetList.AbsoluteContentSize.Y or 0
            TweenService:Create(SetFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
            
            if not setOpen then
                task.delay(0.3, function()
                    SetFrame.Visible = false
                end)
            end
        end)
        
        -- 创建滑块
        function Module:CreateSlider(txt, min, max, def, callback)
            Dots.Visible = true
            
            local F = Instance.new("Frame")
            F.Parent = SetFrame
            F.BackgroundTransparency = 1
            F.Size = UDim2.new(1, 0, 0, 35)
            F.BorderSizePixel = 0
            
            local L = Instance.new("TextLabel")
            L.Parent = F
            L.Text = txt .. ": " .. def
            L.Font = Enum.Font.Gotham
            L.TextSize = 12
            L.BackgroundTransparency = 1
            L.Size = UDim2.new(1, 0, 0, 20)
            
            local B = Instance.new("Frame")
            B.Parent = F
            B.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            B.BorderSizePixel = 0
            B.Position = UDim2.new(0, 8, 0, 20)
            B.Size = UDim2.new(1, -16, 0, 6)
            
            local Fil = Instance.new("Frame")
            Fil.Parent = B
            Fil.BorderSizePixel = 0
            Fil.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
            Fil.BackgroundColor3 = CurrentThemeData.Accent
            
            local T = Instance.new("TextButton")
            T.Parent = F
            T.BackgroundTransparency = 1
            T.Text = ""
            T.Size = UDim2.new(1, 0, 0, 30)
            T.Position = UDim2.new(0, 0, 0, 5)
            T.ZIndex = 10
            
            local currentValue = def
            local dragging = false
            
            local function updateValue(pos)
                local percentage = math.clamp(pos, 0, 1)
                currentValue = math.floor(min + (max - min) * percentage)
                L.Text = txt .. ": " .. currentValue
                Fil.Size = UDim2.new(percentage, 0, 1, 0)
                pcall(callback, currentValue)
            end
            
            T.InputBegan:Connect(function(input)
                if input.UserInputType.Name:match("Mouse") then
                    dragging = true
                    local x = (input.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X
                    updateValue(x)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType.Name:match("Mouse") then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = (input.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X
                    updateValue(x)
                end
            end)
            
            pcall(callback, currentValue)
            
            return {
                Set = function(value)
                    local perc = (value - min) / (max - min)
                    updateValue(perc)
                end
            }
        end
        
        return Module
    end
    
    return Window
end

-- 创建主控制窗口
function Library:CreateMainControl(title)
    return self:CreateWindow(title, UDim2.new(0, 20, 0, 60), true, false)
end

-- 创建子窗口
function Library:CreateChildWindow(title)
    return self:CreateWindow(title, UDim2.new(0.5, -Library.Config.WindowWidth/2, 0.5, -100), false, true)
end

-- 创建设置窗口（简化版）
function Library:SetupSettings()
    local Sets = self:CreateWindow("UI设置", UDim2.new(0.5, -100, 0.5, -100))
    
    Sets:CreateButton("关闭设置", function()
        Sets.Main.Visible = false
    end)
    
    return Sets
end

-- 创建动态岛
local function CreateDynamicIsland()
    local Island = Instance.new("TextButton")
    Island.Name = "DynamicIsland"
    Island.Parent = ScreenGui
    Island.Size = UDim2.new(0,120,0,35)
    Island.Position = UDim2.new(0.5,0,0,15)
    Island.AnchorPoint = Vector2.new(0.5,0)
    Island.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Island.BackgroundTransparency = Library.Config.UIVisible and 0.1 or 0.6
    Island.Text = "多功能菜单"
    Island.Font = Enum.Font.GothamBold
    Island.TextSize = 14
    Island.TextColor3 = Color3.new(1,1,1)
    Island.AutoButtonColor = false
    Island.ZIndex = 100
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1,0)
    UICorner.Parent = Island
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1.5
    UIStroke.Color = CurrentThemeData.Accent
    UIStroke.Transparency = Library.Config.UIVisible and 0.3 or 0.8
    UIStroke.Parent = Island
    
    Library.Globals.IslandObject = Island
    
    Island.MouseButton1Click:Connect(function()
        TweenService:Create(Island, TweenInfo.new(0.1), {
            Size = UDim2.new(0,110,0,30)
        }):Play()
        
        task.delay(0.1, function()
            TweenService:Create(Island, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
                Size = UDim2.new(0,120,0,35)
            }):Play()
        end)
        
        -- 切换界面显示
        Library.Config.UIVisible = not Library.Config.UIVisible
        Backdrop.Visible = Library.Config.UIVisible
        
        TweenService:Create(Backdrop, TweenInfo.new(0.3), {
            BackgroundTransparency = Library.Config.UIVisible and 0.4 or 1
        }):Play()
        
        TweenService:Create(Island, TweenInfo.new(0.3), {
            BackgroundTransparency = Library.Config.UIVisible and 0.1 or 0.6
        }):Play()
        
        TweenService:Create(UIStroke, TweenInfo.new(0.3), {
            Transparency = Library.Config.UIVisible and 0.3 or 0.8
        }):Play()
        
        -- 显示/隐藏所有窗口
        for _, win in ipairs(Library.Globals.Windows) do
            if win.IsOpen then
                win.Main.Visible = Library.Config.UIVisible
            end
        end
    end)
    
    return Island
end

-- ==================== 第二部分：我的多功能脚本代码 ====================
-- 现在在UI库代码的基础上添加我的功能

-- 获取游戏服务
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- 启用ScreenGui
task.spawn(function()
    task.wait(1)
    ScreenGui.Enabled = true
end)

-- ==================== 功能状态管理 ====================
local Features = {
    Fly = {
        Enabled = false,
        Speed = 50,
        BodyVelocity = nil,
        Connection = nil
    },
    Noclip = {
        Enabled = false,
        Connection = nil
    },
    Speed = {
        Enabled = false,
        Value = 16,
        Original = 16
    },
    Jump = {
        Enabled = false,
        Value = 50,
        Original = 50
    },
    Gravity = {
        Enabled = false,
        Value = 196.2,
        Original = 196.2
    },
    InfJump = {
        Enabled = false,
        Connection = nil
    },
    AntiFall = {
        Enabled = false,
        Connection = nil
    }
}

-- 保存原始设置
local OriginalSettings = {
    Skybox = {
        SkyboxBk = Lighting.SkyboxBk,
        SkyboxDn = Lighting.SkyboxDn,
        SkyboxFt = Lighting.SkyboxFt,
        SkyboxLf = Lighting.SkyboxLf,
        SkyboxRt = Lighting.SkyboxRt,
        SkyboxUp = Lighting.SkyboxUp
    },
    Gravity = Workspace.Gravity
}

-- ==================== 创建窗口 ====================
-- 创建主窗口
local Main = Library:CreateMainControl("YC 主菜单")

-- 创建子窗口
local CombatWin = Library:CreateChildWindow("战斗功能")
local VisualsWin = Library:CreateChildWindow("视觉功能")

-- 绑定子窗口
Main:BindWindow("战斗功能", false)
Main:BindWindow("视觉功能", false)

-- ==================== 战斗功能 ====================
-- 飞天功能
local Fly = CombatWin:CreateModule("飞天", function(state)
    Features.Fly.Enabled = state
    
    if state then
        -- 启用飞天
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            if Features.Fly.BodyVelocity then
                Features.Fly.BodyVelocity:Destroy()
            end
            
            Features.Fly.BodyVelocity = Instance.new("BodyVelocity")
            Features.Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            Features.Fly.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            Features.Fly.BodyVelocity.Parent = character.HumanoidRootPart
            
            Features.Fly.Connection = RunService.Heartbeat:Connect(function()
                if Features.Fly.Enabled and character and character:FindFirstChild("HumanoidRootPart") and Features.Fly.BodyVelocity then
                    local root = character.HumanoidRootPart
                    
                    -- 检测按键
                    local up = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                    local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                    local forward = UserInputService:IsKeyDown(Enum.KeyCode.W)
                    local backward = UserInputService:IsKeyDown(Enum.KeyCode.S)
                    local left = UserInputService:IsKeyDown(Enum.KeyCode.A)
                    local right = UserInputService:IsKeyDown(Enum.KeyCode.D)
                    
                    -- 计算方向
                    local direction = Vector3.new(0, 0, 0)
                    if up then direction = direction + Vector3.new(0, 1, 0) end
                    if down then direction = direction + Vector3.new(0, -1, 0) end
                    if forward then direction = direction + root.CFrame.LookVector end
                    if backward then direction = direction - root.CFrame.LookVector end
                    if left then direction = direction - root.CFrame.RightVector end
                    if right then direction = direction + root.CFrame.RightVector end
                    
                    -- 应用速度
                    if direction.Magnitude > 0 then
                        Features.Fly.BodyVelocity.Velocity = direction.Unit * Features.Fly.Speed
                    else
                        Features.Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                    Features.Fly.BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                end
            end)
        end
    else
        -- 禁用飞天
        if Features.Fly.Connection then
            Features.Fly.Connection:Disconnect()
            Features.Fly.Connection = nil
        end
        if Features.Fly.BodyVelocity then
            Features.Fly.BodyVelocity:Destroy()
            Features.Fly.BodyVelocity = nil
        end
    end
end)

-- 飞行速度滑块
Fly:CreateSlider("飞行速度", 10, 200, 50, function(val)
    Features.Fly.Speed = val
    print("飞行速度设置为:", val)
end)

-- 穿墙功能
local Noclip = CombatWin:CreateModule("穿墙", function(state)
    Features.Noclip.Enabled = state
    
    if state then
        Features.Noclip.Connection = RunService.Stepped:Connect(function()
            if Features.Noclip.Enabled and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Features.Noclip.Connection then
            Features.Noclip.Connection:Disconnect()
            Features.Noclip.Connection = nil
        end
    end
end)

-- 速度功能
local Speed = CombatWin:CreateModule("速度", function(state)
    Features.Speed.Enabled = state
    
    if state then
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            Features.Speed.Original = character.Humanoid.WalkSpeed
            character.Humanoid.WalkSpeed = Features.Speed.Value
        end
    else
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Features.Speed.Original
        end
    end
end)

-- 速度滑块
Speed:CreateSlider("速度值", 1, 200, 16, function(val)
    Features.Speed.Value = val
    print("速度值设置为:", val)
    
    if Features.Speed.Enabled then
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = val
        end
    end
end)

-- 速度预设按钮
CombatWin:CreateButton("快速设置: 16 速度", function()
    if Features.Speed.Enabled then
        Features.Speed.Value = 16
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
        print("速度设置为: 16")
    end
end)

-- 无限跳跃
local InfJump = CombatWin:CreateModule("无限跳跃", function(state)
    Features.InfJump.Enabled = state
    
    if state then
        Features.InfJump.Connection = UserInputService.JumpRequest:Connect(function()
            if Features.InfJump.Enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Features.InfJump.Connection then
            Features.InfJump.Connection:Disconnect()
            Features.InfJump.Connection = nil
        end
    end
end)

-- 防掉落
local AntiFall = CombatWin:CreateModule("防掉落", function(state)
    Features.AntiFall.Enabled = state
    
    if state then
        Features.AntiFall.Connection = RunService.Heartbeat:Connect(function()
            if Features.AntiFall.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                if root.Position.Y < -50 then
                    root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
                end
            end
        end)
    else
        if Features.AntiFall.Connection then
            Features.AntiFall.Connection:Disconnect()
            Features.AntiFall.Connection = nil
        end
    end
end)

-- ==================== 视觉功能 ====================
-- 天空颜色功能
local SkyColor = VisualsWin:CreateModule("天空颜色", function(state)
    if not state then
        -- 关闭时恢复默认天空
        for property, value in pairs(OriginalSettings.Skybox) do
            Lighting[property] = value
        end
    end
end)

-- 天空颜色按钮
VisualsWin:CreateButton("红色天空", function()
    local color = Color3.fromRGB(255, 0, 0)
    Lighting.SkyboxBk = color
    Lighting.SkyboxDn = color
    Lighting.SkyboxFt = color
    Lighting.SkyboxLf = color
    Lighting.SkyboxRt = color
    Lighting.SkyboxUp = color
    print("天空颜色设置为: 红色")
end)

VisualsWin:CreateButton("蓝色天空", function()
    local color = Color3.fromRGB(0, 0, 255)
    Lighting.SkyboxBk = color
    Lighting.SkyboxDn = color
    Lighting.SkyboxFt = color
    Lighting.SkyboxLf = color
    Lighting.SkyboxRt = color
    Lighting.SkyboxUp = color
    print("天空颜色设置为: 蓝色")
end)

VisualsWin:CreateButton("恢复默认天空", function()
    for property, value in pairs(OriginalSettings.Skybox) do
        Lighting[property] = value
    end
    print("天空颜色已恢复默认")
end)

-- 重力调整
local Gravity = VisualsWin:CreateModule("重力调整", function(state)
    Features.Gravity.Enabled = state
    
    if state then
        OriginalSettings.Gravity = Workspace.Gravity
        Workspace.Gravity = Features.Gravity.Value
    else
        Workspace.Gravity = OriginalSettings.Gravity
    end
end)

Gravity:CreateSlider("重力强度", 0, 500, 196.2, function(val)
    Features.Gravity.Value = val
    print("重力强度设置为:", val)
    
    if Features.Gravity.Enabled then
        Workspace.Gravity = val
    end
end)

-- 跳跃调整
local Jump = VisualsWin:CreateModule("跳跃高度", function(state)
    Features.Jump.Enabled = state
    
    if state then
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            Features.Jump.Original = character.Humanoid.JumpPower
            character.Humanoid.JumpPower = Features.Jump.Value
        end
    else
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Features.Jump.Original
        end
    end
end)

Jump:CreateSlider("跳跃高度", 50, 500, 50, function(val)
    Features.Jump.Value = val
    print("跳跃高度设置为:", val)
    
    if Features.Jump.Enabled then
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = val
        end
    end
end)

-- 传送功能按钮
VisualsWin:CreateButton("传送到上方", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        root.CFrame = CFrame.new(root.Position + Vector3.new(0, 50, 0))
        print("传送到上方")
    end
end)

-- ==================== 主菜单按钮 ====================
-- 重置所有设置按钮
Main:CreateButton("重置所有设置", function()
    -- 重置所有功能
    if Features.Fly.Enabled then Fly:Set(false) end
    if Features.Noclip.Enabled then Noclip:Set(false) end
    if Features.Speed.Enabled then Speed:Set(false) end
    if Features.Jump.Enabled then Jump:Set(false) end
    if Features.Gravity.Enabled then Gravity:Set(false) end
    if Features.InfJump.Enabled then InfJump:Set(false) end
    if Features.AntiFall.Enabled then AntiFall:Set(false) end
    
    -- 恢复天空
    for property, value in pairs(OriginalSettings.Skybox) do
        Lighting[property] = value
    end
    
    print("所有设置已重置")
end)

-- 显示/隐藏所有窗口按钮
Main:CreateButton("显示/隐藏所有", function()
    local isVisible = not CombatWin.Main.Visible
    CombatWin.Main.Visible = isVisible
    VisualsWin.Main.Visible = isVisible
    print(isVisible and "显示所有窗口" or "隐藏所有窗口")
end)

-- ==================== 角色变化监听 ====================
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    
    -- 恢复速度设置
    if Features.Speed.Enabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = Features.Speed.Value
        print("角色重生，恢复速度设置:", Features.Speed.Value)
    end
    
    -- 恢复跳跃设置
    if Features.Jump.Enabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.JumpPower = Features.Jump.Value
        print("角色重生，恢复跳跃设置:", Features.Jump.Value)
    end
end)

-- ==================== 启动脚本 ====================
-- 创建动态岛
CreateDynamicIsland()

print("========================================")
print("多功能脚本已加载完成！")
print("点击屏幕顶部的'多功能菜单'按钮")
print("========================================")

-- 初始通知
task.spawn(function()
    task.wait(2)
    Library:Notify("多功能脚本已加载", true)
end)

-- ==================== 脚本结束部分 ====================
-- 添加版本信息和元数据到库中
Library.Version = VERSION_INFO
Library.Repository = "https://github.com/[你的用户名]/xiaojiaoben"
Library.Author = "[你的名字]"
Library.License = "MIT"

-- 保存库实例到全局变量
_G.YCGUIInstance = Library

-- 最终的加载完成信息
print("========================================")
print("✅ YC GUI 加载完成!")
print("🎨 主题: " .. (Library.Config.Theme or "Default"))
print("📱 点击屏幕顶部的 '多功能菜单' 按钮")
print("🆔 版本: " .. VERSION_INFO.Major .. "." .. VERSION_INFO.Minor .. "." .. VERSION_INFO.Patch)
print("========================================")

-- 返回库对象
return Library