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
-- ================================
-- 防止重复加载
-- ============================================
-- ============================================
-- YC GUI 多功能脚本 - 完全按照你的格式
-- 使用官方UI库 + 自定义功能
-- ============================================

-- ============================================
-- YC GUI 多功能脚本 - 融合修复版
-- 结合测试版UI显示和完整版功能
-- GitHub链接: https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/main/xiaoan(2).lua
-- ============================================

print("🔍 开始加载 YC GUI...")

-- 获取游戏服务
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

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

-- 全局变量存储
local Connections = {}
local FlyConnection, FlyBodyVelocity
local NoclipConnection
local InfJumpConnection
local AntiFallConnection

-- 创建功能完整的UI
local function CreateYCUI()
    print("📦 正在加载UI库...")
    
    -- 加载官方UI库
    local Library = loadstring(game:HttpGet("https://gitee.com/cmbhbh/ycgui/raw/master/YCmain.lua"))()
    
    print("🖼️ 创建UI窗口...")
    
    -- 创建主窗口
    local Main = Library:CreateMainControl("YC 主菜单")
    
    -- 创建子窗口
    local MovementWin = Library:CreateChildWindow("移动功能")
    local WorldWin = Library:CreateChildWindow("世界功能")
    
    -- 绑定子窗口
    Main:BindWindow("移动功能", false)
    Main:BindWindow("世界功能", false)
    
    -- ==================== 移动功能 ====================
    
    -- 飞天功能
    local Fly = MovementWin:CreateModule("飞天", function(state)
        print("飞天状态:", state)
        
        if state then
            -- 启用飞天
            local character = player.Character or player.CharacterAdded:Wait()
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- 移除旧的BodyVelocity（如果存在）
                if FlyBodyVelocity then
                    FlyBodyVelocity:Destroy()
                    FlyBodyVelocity = nil
                end
                
                -- 创建新的BodyVelocity
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                FlyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                FlyBodyVelocity.Parent = character.HumanoidRootPart
                
                -- 断开旧的连接
                if FlyConnection then
                    FlyConnection:Disconnect()
                end
                
                -- 创建飞行控制连接
                FlyConnection = RunService.Heartbeat:Connect(function()
                    if not character or not character:FindFirstChild("HumanoidRootPart") or not FlyBodyVelocity then
                        if FlyConnection then
                            FlyConnection:Disconnect()
                            FlyConnection = nil
                        end
                        return
                    end
                    
                    local root = character.HumanoidRootPart
                    local direction = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + root.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - root.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - root.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + root.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        direction = direction + Vector3.new(0, -1, 0)
                    end
                    
                    if direction.Magnitude > 0 then
                        FlyBodyVelocity.Velocity = direction.Unit * (_G.FlySpeed or 50)
                    else
                        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        else
            -- 关闭飞天
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
            print("飞天已关闭")
        end
    end)
    
    -- 飞行速度滑块
    Fly:CreateSlider("飞行速度", 10, 200, 50, function(val)
        print("飞行速度设置为:", val)
        _G.FlySpeed = val
    end)
    
    -- 穿墙功能
    local Noclip = MovementWin:CreateModule("穿墙", function(state)
        print("穿墙状态:", state)
        
        if state then
            -- 断开旧的连接
            if NoclipConnection then
                NoclipConnection:Disconnect()
            end
            
            -- 创建穿墙连接
            NoclipConnection = RunService.Stepped:Connect(function()
                local character = player.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- 关闭穿墙
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            print("穿墙已关闭")
        end
    end)
    
    -- 速度功能
    local Speed = MovementWin:CreateModule("速度", function(state)
        print("速度状态:", state)
        
        if state then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = _G.SpeedValue or 16
            end
        else
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = 16
            end
        end
    end)
    
    -- 速度值滑块
    Speed:CreateSlider("速度值", 1, 200, 16, function(val)
        print("速度值设置为:", val)
        _G.SpeedValue = val
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.WalkSpeed > 16 then  -- 如果速度已开启
                humanoid.WalkSpeed = val
            end
        end
    end)
    
    -- 无限跳跃功能
    local InfJump = MovementWin:CreateModule("无限跳跃", function(state)
        print("无限跳跃状态:", state)
        
        if state then
            -- 断开旧的连接
            if InfJumpConnection then
                InfJumpConnection:Disconnect()
            end
            
            -- 创建无限跳跃连接
            InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            -- 关闭无限跳跃
            if InfJumpConnection then
                InfJumpConnection:Disconnect()
                InfJumpConnection = nil
            end
        end
    end)
    
    -- 防掉落功能
    local AntiFall = MovementWin:CreateModule("防掉落", function(state)
        print("防掉落状态:", state)
        
        if state then
            -- 断开旧的连接
            if AntiFallConnection then
                AntiFallConnection:Disconnect()
            end
            
            -- 创建防掉落连接
            AntiFallConnection = RunService.Heartbeat:Connect(function()
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local root = character.HumanoidRootPart
                    if root.Position.Y < (_G.AntiFallHeight or -50) then
                        root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
                    end
                end
            end)
        else
            -- 关闭防掉落
            if AntiFallConnection then
                AntiFallConnection:Disconnect()
                AntiFallConnection = nil
            end
        end
    end)
    
    -- 防掉落高度滑块
    AntiFall:CreateSlider("防掉落高度", -100, 0, -50, function(val)
        print("防掉落高度设置为:", val)
        _G.AntiFallHeight = val
    end)
    
    -- ==================== 世界功能 ====================
    
    -- 天空颜色功能
    local SkyColor = WorldWin:CreateModule("天空颜色", function(state)
        print("天空颜色状态:", state)
        
        if not state then
            -- 关闭时恢复默认天空
            for property, value in pairs(OriginalSettings.Skybox) do
                Lighting[property] = value
            end
        end
    end)
    
    -- 天空颜色下拉菜单
    SkyColor:CreateDropdown("天空颜色", {"红色", "蓝色", "绿色", "紫色", "橙色", "恢复默认"}, function(selected)
        print("天空颜色选择:", selected)
        
        local colors = {
            ["红色"] = Color3.fromRGB(255, 0, 0),
            ["蓝色"] = Color3.fromRGB(0, 0, 255),
            ["绿色"] = Color3.fromRGB(0, 255, 0),
            ["紫色"] = Color3.fromRGB(150, 0, 255),
            ["橙色"] = Color3.fromRGB(255, 165, 0)
        }
        
        if selected == "恢复默认" then
            -- 恢复默认天空
            for property, value in pairs(OriginalSettings.Skybox) do
                Lighting[property] = value
            end
        elseif colors[selected] then
            -- 设置颜色天空
            local color = colors[selected]
            Lighting.SkyboxBk = color
            Lighting.SkyboxDn = color
            Lighting.SkyboxFt = color
            Lighting.SkyboxLf = color
            Lighting.SkyboxRt = color
            Lighting.SkyboxUp = color
        end
    end)
    
    -- 重力调整功能
    local Gravity = WorldWin:CreateModule("重力调整", function(state)
        print("重力调整状态:", state)
        
        if state then
            Workspace.Gravity = _G.GravityValue or 196.2
        else
            Workspace.Gravity = OriginalSettings.Gravity
        end
    end)
    
    -- 重力强度滑块
    Gravity:CreateSlider("重力强度", 0, 500, 196.2, function(val)
        print("重力强度设置为:", val)
        _G.GravityValue = val
        
        if Workspace.Gravity ~= OriginalSettings.Gravity then  -- 如果重力调整已开启
            Workspace.Gravity = val
        end
    end)
    
    -- 跳跃调整功能
    local Jump = WorldWin:CreateModule("跳跃高度", function(state)
        print("跳跃高度状态:", state)
        
        if state then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = _G.JumpValue or 50
            end
        else
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = 50
            end
        end
    end)
    
    -- 跳跃高度滑块
    Jump:CreateSlider("跳跃高度", 50, 500, 50, function(val)
        print("跳跃高度设置为:", val)
        _G.JumpValue = val
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.JumpPower > 50 then  -- 如果跳跃调整已开启
                humanoid.JumpPower = val
            end
        end
    end)
    
    -- ==================== 实用按钮 ====================
    
    -- 移动功能窗口按钮
    MovementWin:CreateButton("快速设置: 16 速度", function()
        print("速度设置为: 16")
        _G.SpeedValue = 16
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.WalkSpeed > 16 then  -- 如果速度已开启
                humanoid.WalkSpeed = 16
            end
        end
    end)
    
    MovementWin:CreateButton("快速设置: 50 速度", function()
        print("速度设置为: 50")
        _G.SpeedValue = 50
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.WalkSpeed > 16 then  -- 如果速度已开启
                humanoid.WalkSpeed = 50
            end
        end
    end)
    
    MovementWin:CreateButton("传送到出生点", function()
        print("传送到出生点")
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end)
    
    -- 世界功能窗口按钮
    WorldWin:CreateButton("红色天空", function()
        print("天空颜色设置为: 红色")
        local color = Color3.fromRGB(255, 0, 0)
        Lighting.SkyboxBk = color
        Lighting.SkyboxDn = color
        Lighting.SkyboxFt = color
        Lighting.SkyboxLf = color
        Lighting.SkyboxRt = color
        Lighting.SkyboxUp = color
    end)
    
    WorldWin:CreateButton("蓝色天空", function()
        print("天空颜色设置为: 蓝色")
        local color = Color3.fromRGB(0, 0, 255)
        Lighting.SkyboxBk = color
        Lighting.SkyboxDn = color
        Lighting.SkyboxFt = color
        Lighting.SkyboxLf = color
        Lighting.SkyboxRt = color
        Lighting.SkyboxUp = color
    end)
    
    WorldWin:CreateButton("恢复默认天空", function()
        print("天空颜色已恢复默认")
        for property, value in pairs(OriginalSettings.Skybox) do
            Lighting[property] = value
        end
    end)
    
    WorldWin:CreateButton("传送到上方", function()
        print("传送到上方")
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            root.CFrame = CFrame.new(root.Position + Vector3.new(0, 50, 0))
        end
    end)
    
    -- ==================== 主菜单按钮 ====================
    
    -- 重置所有设置按钮
    Main:CreateButton("重置所有设置", function()
        print("所有设置已重置")
        
        -- 关闭所有功能
        Fly:Set(false)
        Noclip:Set(false)
        Speed:Set(false)
        InfJump:Set(false)
        AntiFall:Set(false)
        SkyColor:Set(false)
        Gravity:Set(false)
        Jump:Set(false)
        
        -- 清理连接
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if InfJumpConnection then
            InfJumpConnection:Disconnect()
            InfJumpConnection = nil
        end
        if AntiFallConnection then
            AntiFallConnection:Disconnect()
            AntiFallConnection = nil
        end
        
        -- 恢复天空
        for property, value in pairs(OriginalSettings.Skybox) do
            Lighting[property] = value
        end
        
        -- 恢复重力
        Workspace.Gravity = OriginalSettings.Gravity
        
        -- 恢复速度
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
    end)
    
    -- 显示/隐藏所有窗口按钮
    Main:CreateButton("显示/隐藏所有", function()
        local isVisible = not MovementWin.Main.Visible
        MovementWin.Main.Visible = isVisible
        WorldWin.Main.Visible = isVisible
        print(isVisible and "显示所有窗口" or "隐藏所有窗口")
    end)
    
    -- 显示窗口位置信息按钮
    Main:CreateButton("窗口位置", function()
        print("移动功能窗口位置:", MovementWin.Main.Position)
        print("世界功能窗口位置:", WorldWin.Main.Position)
    end)
    
    -- ==================== 角色变化监听 ====================
    
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        
        -- 恢复速度设置
        if _G.SpeedValue then
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.WalkSpeed = _G.SpeedValue
            print("角色重生，恢复速度设置:", _G.SpeedValue)
        end
        
        -- 恢复跳跃设置
        if _G.JumpValue then
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.JumpPower = _G.JumpValue
            print("角色重生，恢复跳跃设置:", _G.JumpValue)
        end
    end)
    
    -- ==================== 设置窗口 ====================
    
    -- 建议在脚本末尾添加，用于管理全局设置
    Library:SetupSettings()
    
    print("✅ YC GUI 加载完成！")
    
    -- 自动显示窗口
    MovementWin.Main.Visible = true
    WorldWin.Main.Visible = true
    
    return Library
end

-- 执行创建
local success, err = pcall(function()
    local Library = CreateYCUI()
    
    -- 打印完成信息
    print("========================================")
    print("✅ YC GUI 多功能脚本已加载完成！")
    print("🎮 点击屏幕顶部的'YC GUI'按钮")
    print("📁 移动功能: 飞天、速度、穿墙等")
    print("🌍 世界功能: 天空颜色、重力、跳跃等")
    print("========================================")
    
    -- 返回库对象
    return Library
end)

if not success then
    print("❌ YC GUI 加载失败:", err)
    
    -- 创建简单备用UI
    local simpleLibrary = loadstring(game:HttpGet("https://gitee.com/cmbhbh/ycgui/raw/master/YCmain.lua"))()
    local simpleMain = simpleLibrary:CreateMainControl("YC GUI (简单版)")
    simpleMain:CreateButton("完整版加载失败", function()
        print("完整版UI加载失败，请检查网络连接或脚本代码。")
    end)
    print("✅ 已加载简单备用UI")
end