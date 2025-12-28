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
-- YC GUI 多功能脚本 - 完整版
-- 使用官方UI库 + 自定义功能
-- ============================================

-- 加载官方UI库
local Library = loadstring(game:HttpGet("https://gitee.com/cmbhbh/ycgui/raw/master/YCmain.lua"))()

-- 创建主窗口
local Main = Library:CreateMainControl("YC 主菜单")

-- 创建子窗口
local MovementWin = Library:CreateChildWindow("移动功能")
local WorldWin = Library:CreateChildWindow("世界功能")

-- 绑定子窗口
Main:BindWindow("移动功能", false)
Main:BindWindow("世界功能", false)

-- 获取游戏服务
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

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

-- ==================== 移动功能 ====================
-- 飞天功能
local Fly = MovementWin:CreateModule("飞天", function(state)
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
local Noclip = MovementWin:CreateModule("穿墙", function(state)
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
local Speed = MovementWin:CreateModule("速度", function(state)
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

-- 速度模式下拉菜单
Speed:CreateDropdown("速度模式", {"行走", "跑步", "冲刺", "超级"}, function(selected)
    local speeds = {
        ["行走"] = 16,
        ["跑步"] = 25,
        ["冲刺"] = 50,
        ["超级"] = 100
    }
    
    if speeds[selected] then
        Features.Speed.Value = speeds[selected]
        if Features.Speed.Enabled then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = speeds[selected]
            end
        end
        print("速度模式设置为:", selected, "值:", speeds[selected])
    end
end)

-- 无限跳跃
local InfJump = MovementWin:CreateModule("无限跳跃", function(state)
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
local AntiFall = MovementWin:CreateModule("防掉落", function(state)
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

-- 防掉落高度设置开关
AntiFall:CreateSwitch("启用高度限制", function(state)
    if state then
        print("高度限制已启用")
    else
        print("高度限制已禁用")
    end
end, true)

-- 速度预设按钮
MovementWin:CreateButton("快速设置: 16 速度", function()
    if Features.Speed.Enabled then
        Features.Speed.Value = 16
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
        print("速度设置为: 16")
    end
end)

MovementWin:CreateButton("快速设置: 50 速度", function()
    if Features.Speed.Enabled then
        Features.Speed.Value = 50
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 50
        end
        print("速度设置为: 50")
    end
end)

-- ==================== 世界功能 ====================
-- 天空颜色功能
local SkyColor = WorldWin:CreateModule("天空颜色", function(state)
    if not state then
        -- 关闭时恢复默认天空
        for property, value in pairs(OriginalSettings.Skybox) do
            Lighting[property] = value
        end
    end
end)

-- 天空颜色下拉菜单
SkyColor:CreateDropdown("天空预设", {"默认", "红色", "蓝色", "紫色", "绿色", "橙色"}, function(selected)
    local colors = {
        ["默认"] = OriginalSettings.Skybox,
        ["红色"] = Color3.fromRGB(255, 0, 0),
        ["蓝色"] = Color3.fromRGB(0, 0, 255),
        ["紫色"] = Color3.fromRGB(150, 0, 255),
        ["绿色"] = Color3.fromRGB(0, 255, 0),
        ["橙色"] = Color3.fromRGB(255, 165, 0)
    }
    
    if colors[selected] then
        if selected == "默认" then
            for property, value in pairs(colors[selected]) do
                Lighting[property] = value
            end
        else
            local color = colors[selected]
            Lighting.SkyboxBk = color
            Lighting.SkyboxDn = color
            Lighting.SkyboxFt = color
            Lighting.SkyboxLf = color
            Lighting.SkyboxRt = color
            Lighting.SkyboxUp = color
        end
        print("天空颜色设置为:", selected)
    end
end)

-- 天空颜色开关
SkyColor:CreateSwitch("启用动态天空", function(state)
    if state then
        print("动态天空已启用")
        -- 这里可以添加动态天空效果的代码
    else
        print("动态天空已禁用")
    end
end, false)

-- 天空颜色按钮
WorldWin:CreateButton("红色天空", function()
    local color = Color3.fromRGB(255, 0, 0)
    Lighting.SkyboxBk = color
    Lighting.SkyboxDn = color
    Lighting.SkyboxFt = color
    Lighting.SkyboxLf = color
    Lighting.SkyboxRt = color
    Lighting.SkyboxUp = color
    print("天空颜色设置为: 红色")
end)

WorldWin:CreateButton("蓝色天空", function()
    local color = Color3.fromRGB(0, 0, 255)
    Lighting.SkyboxBk = color
    Lighting.SkyboxDn = color
    Lighting.SkyboxFt = color
    Lighting.SkyboxLf = color
    Lighting.SkyboxRt = color
    Lighting.SkyboxUp = color
    print("天空颜色设置为: 蓝色")
end)

WorldWin:CreateButton("恢复默认天空", function()
    for property, value in pairs(OriginalSettings.Skybox) do
        Lighting[property] = value
    end
    print("天空颜色已恢复默认")
end)

-- 重力调整
local Gravity = WorldWin:CreateModule("重力调整", function(state)
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

-- 重力模式下拉菜单
Gravity:CreateDropdown("重力模式", {"正常", "月球", "零重力", "超重"}, function(selected)
    local gravities = {
        ["正常"] = 196.2,
        ["月球"] = 32,
        ["零重力"] = 0,
        ["超重"] = 400
    }
    
    if gravities[selected] then
        Features.Gravity.Value = gravities[selected]
        if Features.Gravity.Enabled then
            Workspace.Gravity = gravities[selected]
        end
        print("重力模式设置为:", selected, "值:", gravities[selected])
    end
end)

-- 跳跃调整
local Jump = WorldWin:CreateModule("跳跃高度", function(state)
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

-- 跳跃模式下拉菜单
Jump:CreateDropdown("跳跃模式", {"正常", "高跳", "超级跳", "极限跳"}, function(selected)
    local jumps = {
        ["正常"] = 50,
        ["高跳"] = 100,
        ["超级跳"] = 250,
        ["极限跳"] = 500
    }
    
    if jumps[selected] then
        Features.Jump.Value = jumps[selected]
        if Features.Jump.Enabled then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = jumps[selected]
            end
        end
        print("跳跃模式设置为:", selected, "值:", jumps[selected])
    end
end)

-- 传送功能按钮
WorldWin:CreateButton("传送到上方", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        root.CFrame = CFrame.new(root.Position + Vector3.new(0, 50, 0))
        print("传送到上方")
    end
end)

WorldWin:CreateButton("传送到中心", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        root.CFrame = CFrame.new(0, 50, 0)
        print("传送到中心")
    end
end)

-- 传送下拉菜单
WorldWin:CreateButton("传送到出生点", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        if spawn then
            character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            print("传送到出生点")
        else
            print("未找到出生点")
        end
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
    
    -- 恢复重力
    Workspace.Gravity = OriginalSettings.Gravity
    
    print("所有设置已重置")
end)

-- 显示/隐藏所有窗口按钮
Main:CreateButton("显示/隐藏所有窗口", function()
    local isVisible = not MovementWin.Main.Visible
    MovementWin.Main.Visible = isVisible
    WorldWin.Main.Visible = isVisible
    print(isVisible and "显示所有窗口" or "隐藏所有窗口")
end)

-- 保存配置按钮
Main:CreateButton("保存当前配置", function()
    -- 这里可以添加保存配置的代码
    print("配置已保存（功能待实现）")
end)

-- 加载配置按钮
Main:CreateButton("加载上次配置", function()
    -- 这里可以添加加载配置的代码
    print("配置已加载（功能待实现）")
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

-- ==================== 创建设置窗口 ====================
-- 使用UI库的设置功能
Library:SetupSettings()

-- 打印完成信息
print("========================================")
print("✅ YC GUI 多功能脚本已加载完成！")
print("🎮 点击屏幕顶部的'YC GUI'按钮")
print("📁 移动功能: 飞天、速度、穿墙等")
print("🌍 世界功能: 天空颜色、重力、跳跃等")
print("========================================")

-- 延迟显示通知
task.spawn(function()
    task.wait(2)
    Library:Notify("YC GUI 已加载", true)
end)

-- 返回库对象（可选）
return Library