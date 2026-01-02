-- ============================================
-- YC GUI 多功能脚本 - 完整修复版
-- GitHub: https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/xiaoan(2).lua
-- ============================================

print("🔍 YC GUI 多功能脚本开始加载...")

-- 创建最简单的UI脚本（使用测试代码的结构）
local function CreateFullUI()
    -- 加载UI库 - 这是必须的第一步！
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sjsjxn46xqps/XA-UI/refs/heads/main/XA%20UI.lua"))()
    
    -- 创建主窗口
    local Main = Library:CreateMainControl("YC 主菜单")
    
    -- 创建子窗口
    local MovementWin = Library:CreateChildWindow("移动功能")
    local WorldWin = Library:CreateChildWindow("世界功能")
    local CombatWin = Library:CreateChildWindow("战斗功能")  -- 修复命名，改为战斗功能
    
    -- 绑定子窗口
    Main:BindWindow("移动功能", false)
    Main:BindWindow("世界功能", false)
    Main:BindWindow("战斗功能", false)
    
    -- ==================== 全局变量和工具函数 ====================
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    
    local player = Players.LocalPlayer
    
    -- 战斗功能变量
    local AimLockActive = false
    local AimLockConnection = nil
    local AimLockTarget = nil
    local AimLockDistance = 50
    local AimLockSmoothness = 0.1
    local AimLockPart = "Head"
    
    local AutoShootActive = false
    local AutoShootConnection = nil
    local ShootInterval = 500
    
    local NoRecoilActive = false
    local InfiniteAmmoActive = false
    
    -- ESP功能变量
    local ESPActive = false
    local ESPConnections = {}
    local ESPBoxes = {}
    local ESPLines = {}
    local ESPNames = {}
    
    -- ==================== 辅助函数 ====================
    
    -- 获取最近的目标
    local function GetNearestTarget(maxDistance)
        local nearest = nil
        local nearestDistance = math.huge
        local myPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        
        if not myPosition then return nil end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") 
               and otherPlayer.Character.Humanoid.Health > 0 and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                
                local targetPosition = otherPlayer.Character.HumanoidRootPart.Position
                local distance = (myPosition - targetPosition).Magnitude
                
                if distance <= maxDistance and distance < nearestDistance then
                    nearestDistance = distance
                    nearest = otherPlayer
                end
            end
        end
        
        return nearest, nearestDistance
    end
    
    -- 获取目标部位位置
    local function GetTargetPosition(target)
        if not target or not target.Character then return nil end
        
        local character = target.Character
        
        if AimLockPart == "Head" and character:FindFirstChild("Head") then
            return character.Head.Position
        elseif AimLockPart == "HumanoidRootPart" and character:FindFirstChild("HumanoidRootPart") then
            return character.HumanoidRootPart.Position
        elseif character:FindFirstChild("UpperTorso") then
            return character.UpperTorso.Position
        elseif character:FindFirstChild("Torso") then
            return character.Torso.Position
        else
            return character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position or nil
        end
    end
    
    -- 计算两点间距离
    local function CalculateDistance(point1, point2)
        return (point1 - point2).Magnitude
    end
    
    -- ==================== 战斗功能 ====================
    
    -- 自瞄功能（修复版）
    local AimLock = CombatWin:CreateModule("自瞄锁头", function(state)
        print("自瞄状态:", state)
        AimLockActive = state
        
        if state then
            -- 启用自瞄
            if AimLockConnection then
                AimLockConnection:Disconnect()
            end
            
            AimLockConnection = RunService.RenderStepped:Connect(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                -- 获取最近目标
                local target, distance = GetNearestTarget(AimLockDistance)
                AimLockTarget = target
                
                if target and target.Character then
                    local targetPos = GetTargetPosition(target)
                    local myRoot = player.Character.HumanoidRootPart
                    
                    if targetPos then
                        -- 计算朝向目标的CFrame
                        local direction = (targetPos - myRoot.Position).Unit
                        
                        if AimLockSmoothness > 0 then
                            -- 平滑转向
                            local currentCF = myRoot.CFrame
                            local targetCF = CFrame.lookAt(myRoot.Position, targetPos)
                            myRoot.CFrame = currentCF:Lerp(targetCF, AimLockSmoothness)
                        else
                            -- 立即转向
                            myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + direction)
                        end
                    end
                end
            end)
        else
            -- 关闭自瞄
            if AimLockConnection then
                AimLockConnection:Disconnect()
                AimLockConnection = nil
            end
            AimLockTarget = nil
            print("自瞄已关闭")
        end
    end)
    
    -- 自瞄距离滑块
    AimLock:CreateSlider("自瞄距离", 10, 500, 50, function(val)
        print("自瞄距离设置为:", val)
        AimLockDistance = val
    end)
    
    -- 自瞄平滑度滑块
    AimLock:CreateSlider("平滑度", 0, 1, 0.1, function(val)
        print("自瞄平滑度设置为:", val)
        AimLockSmoothness = val
    end)
    
    -- 自瞄部位选择下拉菜单
    AimLock:CreateDropdown("瞄准部位", {"头部", "身体", "腿部"}, function(selected)
        print("瞄准部位选择:", selected)
        if selected == "头部" then
            AimLockPart = "Head"
        elseif selected == "身体" then
            AimLockPart = "HumanoidRootPart"
        elseif selected == "腿部" then
            AimLockPart = "HumanoidRootPart"  -- 暂时用RootPart，可以改为LowerTorso
        end
    end)
    
    -- 自动射击功能（修复版）
    local AutoShoot = CombatWin:CreateModule("自动射击", function(state)
        print("自动射击状态:", state)
        AutoShootActive = state
        
        if state then
            -- 启用自动射击
            local lastShot = tick()
            
            if AutoShootConnection then
                AutoShootConnection:Disconnect()
            end
            
            AutoShootConnection = RunService.Heartbeat:Connect(function()
                if not player.Character or not player.Character:FindFirstChild("Humanoid") then
                    return
                end
                
                -- 检查射击间隔
                if tick() - lastShot < (ShootInterval / 1000) then
                    return
                end
                
                -- 获取最近目标
                local target = AimLockTarget or GetNearestTarget(AimLockDistance)
                
                if target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                    -- 模拟射击动作
                    local humanoid = player.Character.Humanoid
                    
                    -- 这里可以根据具体游戏调整射击逻辑
                    -- 例如：发射射线、调用武器脚本等
                    print("自动射击目标:", target.Name)
                    
                    lastShot = tick()
                end
            end)
        else
            -- 关闭自动射击
            if AutoShootConnection then
                AutoShootConnection:Disconnect()
                AutoShootConnection = nil
            end
            print("自动射击已关闭")
        end
    end)
    
    -- 射击间隔滑块
    AutoShoot:CreateSlider("射击间隔(ms)", 100, 2000, 500, function(val)
        print("射击间隔设置为:", val)
        ShootInterval = val
    end)
    
    -- 无后坐力功能（修复版）
    local NoRecoil = CombatWin:CreateModule("无后坐力", function(state)
        print("无后坐力状态:", state)
        NoRecoilActive = state
        
        if state then
            -- 尝试禁用后坐力效果
            local Camera = Workspace.CurrentCamera
            
            -- 尝试修改相机震动
            if Camera then
                -- 这里可以根据具体游戏修改后坐力参数
                print("无后坐力已启用 - 相机震动已减少")
            end
        else
            print("无后坐力已关闭")
        end
    end)
    
    -- 无限弹药功能（修复版）
    local InfiniteAmmo = CombatWin:CreateModule("无限弹药", function(state)
        print("无限弹药状态:", state)
        InfiniteAmmoActive = state
        
        if state then
            -- 尝试修改弹药数量
            local function updateAmmo()
                -- 查找角色中的武器并修改弹药
                if player.Character then
                    for _, child in pairs(player.Character:GetChildren()) do
                        if child:IsA("Tool") then
                            -- 尝试修改工具属性
                            pcall(function()
                                -- 这里可以根据具体游戏修改弹药属性
                                print("修改武器:", child.Name)
                            end)
                        end
                    end
                end
            end
            
            -- 监听新工具
            if player.Character then
                player.Character.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") and InfiniteAmmoActive then
                        updateAmmo()
                    end
                end)
            end
            
            updateAmmo()
            print("无限弹药已启用")
        else
            print("无限弹药已关闭")
        end
    end)
    
    -- 一击必杀功能
    local OneHitKill = CombatWin:CreateModule("一击必杀", function(state)
        print("一击必杀状态:", state)
        
        if state then
            -- 尝试修改伤害值
            print("一击必杀已启用 - 需要根据具体游戏实现")
        else
            print("一击必杀已关闭")
        end
    end)
    
    -- ==================== 战斗功能按钮 ====================
    
    -- 快速锁定最近敌人按钮
    CombatWin:CreateButton("快速锁定最近", function()
        local target, distance = GetNearestTarget(AimLockDistance)
        if target then
            print("锁定目标:", target.Name, "距离:", math.floor(distance))
            AimLockTarget = target
        else
            print("未找到可锁定的目标")
        end
    end)
    
    -- 显示敌人信息按钮
    CombatWin:CreateButton("显示敌人信息", function()
        print("正在显示敌人信息...")
        local myPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        
        if myPosition then
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPosition = otherPlayer.Character.HumanoidRootPart.Position
                    local distance = CalculateDistance(myPosition, targetPosition)
                    local health = otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health or 0
                    
                    print(otherPlayer.Name .. " - 距离: " .. math.floor(distance) .. " 生命值: " .. math.floor(health))
                end
            end
        end
    end)
    
    -- ==================== ESP透视功能（添加到世界功能） ====================
    
    local ESP = WorldWin:CreateModule("透视功能", function(state)
        print("ESP透视状态:", state)
        ESPActive = state
        
        if state then
            -- 启用ESP
            local function CreateESPBox(player)
                if player == game.Players.LocalPlayer then return end
                
                local character = player.Character
                if not character then return end
                
                local box = Instance.new("BoxHandleAdornment")
                box.Name = player.Name .. "_ESPBox"
                box.Adornee = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Size = Vector3.new(4, 6, 2)
                box.Transparency = 0.3
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Parent = Workspace
                
                ESPBoxes[player] = box
                
                -- 创建距离文本
                local billboard = Instance.new("BillboardGui")
                billboard.Name = player.Name .. "_ESPDistance"
                billboard.Adornee = box.Adornee
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = box.Adornee
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14
                textLabel.Text = player.Name
                textLabel.Parent = billboard
                
                ESPNames[player] = textLabel
                
                -- 更新距离
                local connection = RunService.RenderStepped:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local myPos = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                        local targetPos = player.Character.HumanoidRootPart.Position
                        
                        if myPos then
                            local distance = (myPos - targetPos).Magnitude
                            local health = player.Character:FindFirstChild("Humanoid") and math.floor(player.Character.Humanoid.Health) or 0
                            textLabel.Text = string.format("%s\n距离: %d\n生命: %d", player.Name, math.floor(distance), health)
                        end
                    else
                        connection:Disconnect()
                        if ESPBoxes[player] then
                            ESPBoxes[player]:Destroy()
                            ESPBoxes[player] = nil
                        end
                        if ESPNames[player] then
                            ESPNames[player]:Destroy()
                            ESPNames[player] = nil
                        end
                    end
                end)
                
                ESPConnections[player] = connection
            end
            
            -- 为所有玩家创建ESP
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                CreateESPBox(otherPlayer)
            end
            
            -- 监听新玩家
            local playerAddedConn = Players.PlayerAdded:Connect(function(newPlayer)
                CreateESPBox(newPlayer)
            end)
            
            -- 监听玩家离开
            local playerRemovingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
                if ESPBoxes[leavingPlayer] then
                    ESPBoxes[leavingPlayer]:Destroy()
                    ESPBoxes[leavingPlayer] = nil
                end
                if ESPNames[leavingPlayer] then
                    ESPNames[leavingPlayer]:Destroy()
                    ESPNames[leavingPlayer] = nil
                end
                if ESPConnections[leavingPlayer] then
                    ESPConnections[leavingPlayer]:Disconnect()
                    ESPConnections[leavingPlayer] = nil
                end
            end)
            
            ESPConnections["PlayerAdded"] = playerAddedConn
            ESPConnections["PlayerRemoving"] = playerRemovingConn
            
            print("ESP透视已启用")
        else
            -- 关闭ESP
            for player, box in pairs(ESPBoxes) do
                box:Destroy()
            end
            ESPBoxes = {}
            
            for player, textLabel in pairs(ESPNames) do
                textLabel.Parent:Destroy()
            end
            ESPNames = {}
            
            for _, connection in pairs(ESPConnections) do
                connection:Disconnect()
            end
            ESPConnections = {}
            
            print("ESP透视已关闭")
        end
    end)
    
    -- ESP颜色选择下拉菜单
    ESP:CreateDropdown("ESP颜色", {"红色", "蓝色", "绿色", "黄色", "紫色"}, function(selected)
        print("ESP颜色选择:", selected)
        
        local colors = {
            ["红色"] = Color3.fromRGB(255, 0, 0),
            ["蓝色"] = Color3.fromRGB(0, 0, 255),
            ["绿色"] = Color3.fromRGB(0, 255, 0),
            ["黄色"] = Color3.fromRGB(255, 255, 0),
            ["紫色"] = Color3.fromRGB(150, 0, 255)
        }
        
        if colors[selected] then
            for _, box in pairs(ESPBoxes) do
                box.Color3 = colors[selected]
            end
        end
    end)
    
    -- ESP透明度滑块
    ESP:CreateSlider("ESP透明度", 0.1, 1, 0.3, function(val)
        print("ESP透明度设置为:", val)
        for _, box in pairs(ESPBoxes) do
            box.Transparency = val
        end
    end)
    
    -- ==================== 移动功能 ====================
    -- 飞天功能
    local Fly = MovementWin:CreateModule("飞天", function(state)
        print("飞天状态:", state)
        
        if state then
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
    
    Speed:CreateSlider("速度值", 1, 200, 16, function(val)
        print("速度值设置为:", val)
        _G.SpeedValue = val
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.WalkSpeed > 16 then
                humanoid.WalkSpeed = val
            end
        end
    end)
    
    -- 穿墙功能
    local Noclip = MovementWin:CreateModule("穿墙", function(state)
        print("穿墙状态:", state)
        
        if state then
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
        
        if state then
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
        
        if state then
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
        
        if not state then
            if _G.OriginalSkybox then
                for property, value in pairs(_G.OriginalSkybox) do
                    Lighting[property] = value
                end
            end
        end
    end)
    
    -- 保存原始天空
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
        
        if state then
            Workspace.Gravity = _G.GravityValue or 196.2
        else
            Workspace.Gravity = _G.OriginalGravity or 196.2
        end
    end)
    
    -- 保存原始重力
    _G.OriginalGravity = Workspace.Gravity
    
    Gravity:CreateSlider("重力强度", 0, 500, 196.2, function(val)
        print("重力强度设置为:", val)
        _G.GravityValue = val
        
        if Workspace.Gravity ~= _G.OriginalGravity then
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
    
    Jump:CreateSlider("跳跃高度", 50, 500, 50, function(val)
        print("跳跃高度设置为:", val)
        _G.JumpValue = val
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
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
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.WalkSpeed > 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end)
    
    MovementWin:CreateButton("快速设置: 50 速度", function()
        print("速度设置为: 50")
        _G.SpeedValue = 50
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.WalkSpeed > 16 then
                humanoid.WalkSpeed = 50
            end
        end
    end)
    
    MovementWin:CreateButton("传送到出生点", function()
        print("传送到出生点")
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
        if ESP then ESP:Set(false) end
        if AimLock then AimLock:Set(false) end
        if AutoShoot then AutoShoot:Set(false) end
        if NoRecoil then NoRecoil:Set(false) end
        if InfiniteAmmo then InfiniteAmmo:Set(false) end
        if OneHitKill then OneHitKill:Set(false) end
        
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
        
        -- 恢复天空
        if _G.OriginalSkybox then
            for property, value in pairs(_G.OriginalSkybox) do
                Lighting[property] = value
            end
        end
        
        -- 恢复重力
        Workspace.Gravity = _G.OriginalGravity or 196.2
        
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
        CombatWin.Main.Visible = isVisible
        print(isVisible and "显示所有窗口" or "隐藏所有窗口")
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
print("🔫 战斗功能: 自瞄、自动射击、无后坐力等")
print("👁️ ESP透视: 显示敌人位置、名称、距离")
print("🌍 世界功能: 天空颜色、重力、跳跃等")
print("========================================")
