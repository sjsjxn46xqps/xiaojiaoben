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
-- YC GUI 多功能脚本 - 完全融合版
-- 结合测试版UI结构和完整版功能
-- GitHub: https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/xiaoan(2).lua
-- ============================================

print("🔍 YC GUI 多功能脚本开始加载...")

-- 创建最简单的UI脚本（使用测试代码的结构）
local function CreateFullUI()
    -- 加载UI库 - 这是必须的第一步！
    local Library = loadstring(game:HttpGet("https://gitee.com/cmbhbh/ycgui/raw/master/YCmain.lua"))()
    
    -- 创建主窗口
    local Main = Library:CreateMainControl("YC 主菜单")
    
    -- 创建子窗口
    local MovementWin = Library:CreateChildWindow("移动功能")
    local WorldWin = Library:CreateChildWindow("世界功能")
    local CombatWin = Library:CreateChildWindow("攻击功能")  -- 新增攻击功能窗口
    
    -- 绑定子窗口
    Main:BindWindow("移动功能", false)
    Main:BindWindow("世界功能", false)
    Main:BindWindow("攻击功能", false)  -- 绑定攻击功能窗口
    
    -- ==================== 攻击功能 ====================
    
    -- 自瞄功能（360度自瞄，可以设置距离）
    local AimLock = CombatWin:CreateModule("360度自瞄", function(state)
        print("自瞄状态:", state)
        
        if state then
            -- 启用自瞄
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local player = Players.LocalPlayer
            
            -- 保存原始鼠标设置
            _G.OriginalMouseBehavior = UserInputService.MouseBehavior
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            
            -- 自瞄连接
            _G.AimLockConnection = RunService.RenderStepped:Connect(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local myRoot = player.Character.HumanoidRootPart
                local myPosition = myRoot.Position
                local closestPlayer = nil
                local closestDistance = math.huge
                local aimDistance = _G.AimLockDistance or 50  -- 默认50距离
                
                -- 寻找最近的玩家
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") 
                       and otherPlayer.Character.Humanoid.Health > 0 and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        
                        local targetRoot = otherPlayer.Character.HumanoidRootPart
                        local distance = (myPosition - targetRoot.Position).Magnitude
                        
                        -- 检查是否在距离内且最近
                        if distance <= aimDistance and distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = otherPlayer
                        end
                    end
                end
                
                -- 如果找到目标，进行360度自瞄
                if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = closestPlayer.Character.HumanoidRootPart
                    
                    -- 获取目标头部位置（尝试获取Head，否则使用HumanoidRootPart）
                    local targetPosition
                    if closestPlayer.Character:FindFirstChild("Head") then
                        targetPosition = closestPlayer.Character.Head.Position
                    else
                        targetPosition = targetRoot.Position + Vector3.new(0, 2, 0)  -- 假设头部在身体上方
                    end
                    
                    -- 计算朝向目标的方向
                    local direction = (targetPosition - myPosition).Unit
                    
                    -- 计算朝向目标的CFrame
                    local lookAt = CFrame.lookAt(myPosition, targetPosition)
                    
                    -- 应用360度旋转（立即转向目标）
                    myRoot.CFrame = CFrame.new(myPosition, myPosition + direction)
                    
                    -- 可选：平滑转向（如果启用平滑转向）
                    if _G.AimSmoothness and _G.AimSmoothness > 0 then
                        local currentCF = myRoot.CFrame
                        local targetCF = CFrame.new(myPosition, targetPosition)
                        myRoot.CFrame = currentCF:Lerp(targetCF, math.min(1, _G.AimSmoothness / 10))
                    end
                end
            end)
        else
            -- 关闭自瞄
            if _G.AimLockConnection then
                _G.AimLockConnection:Disconnect()
                _G.AimLockConnection = nil
            end
            
            -- 恢复鼠标设置
            if _G.OriginalMouseBehavior then
                local UserInputService = game:GetService("UserInputService")
                UserInputService.MouseBehavior = _G.OriginalMouseBehavior
                _G.OriginalMouseBehavior = nil
            end
            
            print("自瞄已关闭")
        end
    end)
    
    -- 自瞄距离滑块
    AimLock:CreateSlider("自瞄距离", 10, 500, 50, function(val)
        print("自瞄距离设置为:", val)
        _G.AimLockDistance = val
    end)
    
    -- 自瞄平滑度滑块
    AimLock:CreateSlider("平滑度", 0, 10, 5, function(val)
        print("自瞄平滑度设置为:", val)
        _G.AimSmoothness = val
    end)
    
    -- 自瞄部位选择下拉菜单
    AimLock:CreateDropdown("瞄准部位", {"头部", "胸部", "身体"}, function(selected)
        print("瞄准部位选择:", selected)
        _G.AimTargetPart = selected
    end)
    
    -- 自动射击功能
    local AutoShoot = CombatWin:CreateModule("自动射击", function(state)
        print("自动射击状态:", state)
        
        if state then
            -- 启用自动射击
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            -- 这里需要根据具体游戏实现自动射击
            -- 以下是一个通用示例，实际使用时需要根据游戏调整
            _G.AutoShootConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    -- 检查是否有武器并自动射击
                    local humanoid = player.Character.Humanoid
                    
                    -- 这里可以根据具体游戏调整自动射击逻辑
                    print("自动射击中...")
                end
            end)
        else
            -- 关闭自动射击
            if _G.AutoShootConnection then
                _G.AutoShootConnection:Disconnect()
                _G.AutoShootConnection = nil
            end
            print("自动射击已关闭")
        end
    end)
    
    -- 射击间隔滑块
    AutoShoot:CreateSlider("射击间隔(ms)", 100, 2000, 500, function(val)
        print("射击间隔设置为:", val)
        _G.ShootInterval = val
    end)
    
    -- 无后坐力功能
    local NoRecoil = CombatWin:CreateModule("无后坐力", function(state)
        print("无后坐力状态:", state)
        
        if state then
            -- 这里需要根据具体游戏实现无后坐力
            -- 通常需要修改武器的后坐力参数或射击时的相机震动
            print("无后坐力已启用")
        else
            print("无后坐力已关闭")
        end
    end)
    
    -- 无限弹药功能
    local InfiniteAmmo = CombatWin:CreateModule("无限弹药", function(state)
        print("无限弹药状态:", state)
        
        if state then
            -- 启用无限弹药
            print("无限弹药已启用")
            -- 这里需要根据具体游戏修改弹药数量
        else
            print("无限弹药已关闭")
        end
    end)
    
    -- ==================== 攻击功能按钮 ====================
    
    -- 快速锁定最近敌人按钮
    CombatWin:CreateButton("快速锁定最近", function()
        print("快速锁定最近敌人")
        -- 这里可以添加快速锁定逻辑
    end)
    
    -- 切换锁定模式按钮
    CombatWin:CreateButton("切换锁定模式", function()
        if not _G.AimLockMode then
            _G.AimLockMode = "nearest"
        elseif _G.AimLockMode == "nearest" then
            _G.AimLockMode = "visible"
        else
            _G.AimLockMode = "nearest"
        end
        print("锁定模式切换为:", _G.AimLockMode)
    end)
    
    -- 显示敌人信息按钮
    CombatWin:CreateButton("显示敌人信息", function()
        print("正在显示敌人信息...")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                print(otherPlayer.Name .. " - 距离: " .. math.floor(distance) .. " 生命值: " .. math.floor(otherPlayer.Character.Humanoid.Health))
            end
        end
    end)
    
    -- ==================== 移动功能 ====================
    -- 飞天功能
    local Fly = MovementWin:CreateModule("飞天", function(state)
        print("飞天状态:", state)
        
        -- 实际功能代码
        if state then
            -- 启用飞天
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            
            local player = Players.LocalPlayer
            local character = player.Character
            
            if character and character:FindFirstChild("HumanoidRootPart") then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyVelocity.Parent = character.HumanoidRootPart
                
                local connection = RunService.Heartbeat:Connect(function()
                    if not character or not character:FindFirstChild("HumanoidRootPart") then
                        connection:Disconnect()
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
                        bodyVelocity.Velocity = direction.Unit * (_G.FlySpeed or 50)
                    else
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        else
            print("飞天已关闭")
        end
    end)
    
    Fly:CreateSlider("飞行速度", 10, 200, 50, function(val)
        print("飞行速度设置为:", val)
        _G.FlySpeed = val
    end)
    
    -- 速度功能
    local Speed = MovementWin:CreateModule("速度", function(state)
        print("速度状态:", state)
        
        -- 实际功能代码
        if state then
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = _G.SpeedValue or 16
            end
        else
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = 16
            end
        end
    end)
    
    Speed:CreateSlider("速度值", 1, 200, 16, function(val)
        print("速度值设置为:", val)
        _G.SpeedValue = val
        
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = game.Players.LocalPlayer.Character.Humanoid
            if humanoid.WalkSpeed > 16 then
                humanoid.WalkSpeed = val
            end
        end
    end)
    
    -- 穿墙功能
    local Noclip = MovementWin:CreateModule("穿墙", function(state)
        print("穿墙状态:", state)
        
        -- 实际功能代码
        if state then
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            local connection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            _G.NoclipConnection = connection
        else
            if _G.NoclipConnection then
                _G.NoclipConnection:Disconnect()
                _G.NoclipConnection = nil
            end
            print("穿墙已关闭")
        end
    end)
    
    -- 无限跳跃
    local InfJump = MovementWin:CreateModule("无限跳跃", function(state)
        print("无限跳跃状态:", state)
        
        -- 实际功能代码
        if state then
            local UserInputService = game:GetService("UserInputService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            local connection = UserInputService.JumpRequest:Connect(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            _G.InfJumpConnection = connection
        else
            if _G.InfJumpConnection then
                _G.InfJumpConnection:Disconnect()
                _G.InfJumpConnection = nil
            end
        end
    end)
    
    -- 防掉落功能
    local AntiFall = MovementWin:CreateModule("防掉落", function(state)
        print("防掉落状态:", state)
        
        -- 实际功能代码
        if state then
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            local connection = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    if root.Position.Y < (_G.AntiFallHeight or -50) then
                        root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
                    end
                end
            end)
            _G.AntiFallConnection = connection
        else
            if _G.AntiFallConnection then
                _G.AntiFallConnection:Disconnect()
                _G.AntiFallConnection = nil
            end
        end
    end)
    
    AntiFall:CreateSlider("防掉落高度", -100, 0, -50, function(val)
        print("防掉落高度设置为:", val)
        _G.AntiFallHeight = val
    end)
    
    -- ==================== 世界功能 ====================
    -- 天空颜色
    local SkyColor = WorldWin:CreateModule("天空颜色", function(state)
        print("天空颜色状态:", state)
        
        -- 实际功能代码
        if not state then
            local Lighting = game:GetService("Lighting")
            if _G.OriginalSkybox then
                for property, value in pairs(_G.OriginalSkybox) do
                    Lighting[property] = value
                end
            end
        end
    end)
    
    -- 保存原始天空
    local Lighting = game:GetService("Lighting")
    _G.OriginalSkybox = {
        SkyboxBk = Lighting.SkyboxBk,
        SkyboxDn = Lighting.SkyboxDn,
        SkyboxFt = Lighting.SkyboxFt,
        SkyboxLf = Lighting.SkyboxLf,
        SkyboxRt = Lighting.SkyboxRt,
        SkyboxUp = Lighting.SkyboxUp
    }
    
    SkyColor:CreateDropdown("天空颜色", {"红色", "蓝色", "绿色", "紫色", "橙色"}, function(selected)
        print("天空颜色选择:", selected)
        
        local colors = {
            ["红色"] = Color3.fromRGB(255, 0, 0),
            ["蓝色"] = Color3.fromRGB(0, 0, 255),
            ["绿色"] = Color3.fromRGB(0, 255, 0),
            ["紫色"] = Color3.fromRGB(150, 0, 255),
            ["橙色"] = Color3.fromRGB(255, 165, 0)
        }
        
        if colors[selected] then
            local color = colors[selected]
            Lighting.SkyboxBk = color
            Lighting.SkyboxDn = color
            Lighting.SkyboxFt = color
            Lighting.SkyboxLf = color
            Lighting.SkyboxRt = color
            Lighting.SkyboxUp = color
        end
    end)
    
    -- 重力调整
    local Gravity = WorldWin:CreateModule("重力调整", function(state)
        print("重力调整状态:", state)
        
        -- 实际功能代码
        if state then
            game.Workspace.Gravity = _G.GravityValue or 196.2
        else
            game.Workspace.Gravity = _G.OriginalGravity or 196.2
        end
    end)
    
    -- 保存原始重力
    _G.OriginalGravity = game.Workspace.Gravity
    
    Gravity:CreateSlider("重力强度", 0, 500, 196.2, function(val)
        print("重力强度设置为:", val)
        _G.GravityValue = val
        
        if game.Workspace.Gravity ~= _G.OriginalGravity then
            game.Workspace.Gravity = val
        end
    end)
    
    -- 跳跃调整功能
    local Jump = WorldWin:CreateModule("跳跃高度", function(state)
        print("跳跃高度状态:", state)
        
        -- 实际功能代码
        if state then
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = _G.JumpValue or 50
            end
        else
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = 50
            end
        end
    end)
    
    Jump:CreateSlider("跳跃高度", 50, 500, 50, function(val)
        print("跳跃高度设置为:", val)
        _G.JumpValue = val
        
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = game.Players.LocalPlayer.Character.Humanoid
            if humanoid.JumpPower > 50 then
                humanoid.JumpPower = val
            end
        end
    end)
    
    -- ==================== 实用按钮 ====================
    
    -- 移动功能窗口按钮
    MovementWin:CreateButton("快速设置: 16 速度", function()
        print("速度设置为: 16")
        _G.SpeedValue = 16
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = game.Players.LocalPlayer.Character.Humanoid
            if humanoid.WalkSpeed > 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end)
    
    MovementWin:CreateButton("快速设置: 50 速度", function()
        print("速度设置为: 50")
        _G.SpeedValue = 50
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = game.Players.LocalPlayer.Character.Humanoid
            if humanoid.WalkSpeed > 16 then
                humanoid.WalkSpeed = 50
            end
        end
    end)
    
    MovementWin:CreateButton("传送到出生点", function()
        print("传送到出生点")
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
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
        if _G.OriginalSkybox then
            for property, value in pairs(_G.OriginalSkybox) do
                Lighting[property] = value
            end
        end
    end)
    
    WorldWin:CreateButton("传送到上方", function()
        print("传送到上方")
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            root.CFrame = CFrame.new(root.Position + Vector3.new(0, 50, 0))
        end
    end)
    
    -- ==================== 主菜单按钮 ====================
    
    -- 重置所有设置按钮
    Main:CreateButton("重置所有设置", function()
        print("所有设置已重置")
        
        -- 关闭所有功能
        if Fly then Fly:Set(false) end
        if Speed then Speed:Set(false) end
        if Noclip then Noclip:Set(false) end
        if InfJump then InfJump:Set(false) end
        if AntiFall then AntiFall:Set(false) end
        if SkyColor then SkyColor:Set(false) end
        if Gravity then Gravity:Set(false) end
        if Jump then Jump:Set(false) end
        if AimLock then AimLock:Set(false) end
        if AutoShoot then AutoShoot:Set(false) end
        if NoRecoil then NoRecoil:Set(false) end
        if InfiniteAmmo then InfiniteAmmo:Set(false) end
        
        -- 清理连接
        if _G.NoclipConnection then
            _G.NoclipConnection:Disconnect()
            _G.NoclipConnection = nil
        end
        if _G.InfJumpConnection then
            _G.InfJumpConnection:Disconnect()
            _G.InfJumpConnection = nil
        end
        if _G.AntiFallConnection then
            _G.AntiFallConnection:Disconnect()
            _G.AntiFallConnection = nil
        end
        if _G.AimLockConnection then
            _G.AimLockConnection:Disconnect()
            _G.AimLockConnection = nil
        end
        if _G.AutoShootConnection then
            _G.AutoShootConnection:Disconnect()
            _G.AutoShootConnection = nil
        end
        
        -- 恢复天空
        if _G.OriginalSkybox then
            for property, value in pairs(_G.OriginalSkybox) do
                Lighting[property] = value
            end
        end
        
        -- 恢复重力
        game.Workspace.Gravity = _G.OriginalGravity or 196.2
        
        -- 恢复速度
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end)
    
    -- 显示/隐藏所有窗口按钮
    Main:CreateButton("显示/隐藏所有", function()
        local isVisible = not MovementWin.Main.Visible
        MovementWin.Main.Visible = isVisible
        WorldWin.Main.Visible = isVisible
        CombatWin.Main.Visible = isVisible  -- 新增攻击功能窗口
        print(isVisible and "显示所有窗口" or "隐藏所有窗口")
    end)
    
    -- ==================== 角色变化监听 ====================
    
    game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
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
    
    -- 返回库对象
    return Library
end

-- 执行创建
CreateFullUI()

-- 打印完成信息
print("========================================")
print("✅ YC GUI 多功能脚本已加载完成！")
print("🎮 点击屏幕顶部的'YC GUI'按钮")
print("📁 移动功能: 飞天、速度、穿墙等")
print("🔫 攻击功能: 360度自瞄、自动射击等")
print("🌍 世界功能: 天空颜色、重力、跳跃等")
print("========================================")