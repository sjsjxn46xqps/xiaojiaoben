-- ============================================
-- YC GUI 多功能脚本 - 完整修复版
-- GitHub: https://raw.githubusercontent.com/sjsjxn46xqps/xiaojiaoben/refs/heads/main/xiaoan(2).lua
-- ============================================

print("🔍 YC GUI 多功能脚本开始加载...")

-- 创建最简单的UI脚本
local function CreateFullUI()
    -- 加载XA UI库
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sjsjxn46xqps/XA-UI/refs/heads/main/XA%20UI.lua"))()
    
    -- 创建主窗口
    local Main = Library:CreateMainControl("YC 主菜单")
    
    -- 创建子窗口
    local MovementWin = Library:CreateChildWindow("移动功能")
    local WorldWin = Library:CreateChildWindow("世界功能")
    local CombatWin = Library:CreateChildWindow("战斗功能")
    
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
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    
    -- 战斗功能变量
    local AimLockActive = false
    local AimLockConnection = nil
    local AimLockTarget = nil
    local AimLockDistance = 50
    local AimLockSmoothness = 0.1
    local AimLockPart = "Head"
    
    -- 子弹追踪变量
    local BulletTrackActive = false
    local BulletTrackConnection = nil
    
    -- ESP功能变量
    local ESPActive = false
    local ESPManager = {}
    
    -- 飞行功能变量
    local FlyActive = false
    local FlyBodyVelocity = nil
    local FlyConnection = nil
    local FlySpeed = 50
    
    -- 全局设置变量
    _G.SpeedValue = 16
    _G.JumpValue = 50
    _G.GravityValue = 196.2
    
    -- ==================== 辅助函数 ====================
    
    -- 获取最近的目标
    local function GetNearestTarget(maxDistance)
        local nearest = nil
        local nearestDistance = math.huge
        local myPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        
        if not myPosition then return nil end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
                local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and rootPart then
                    local targetPosition = rootPart.Position
                    local distance = (myPosition - targetPosition).Magnitude
                    
                    if distance <= maxDistance and distance < nearestDistance then
                        nearestDistance = distance
                        nearest = otherPlayer
                    end
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
    
    -- 修复ESP：重新检查所有玩家的ESP状态
    local function UpdateAllESP()
        if not ESPActive then return end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local hasESP = ESPManager.Boxes[otherPlayer] ~= nil
                local shouldHaveESP = otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and 
                                     otherPlayer.Character.Humanoid.Health > 0 and 
                                     otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if shouldHaveESP and not hasESP then
                    -- 玩家应该显示ESP但没有，重新创建
                    ESPManager.CreateESPForPlayer(otherPlayer)
                elseif not shouldHaveESP and hasESP then
                    -- 玩家不应该显示ESP但有，移除
                    ESPManager.RemoveESPForPlayer(otherPlayer)
                end
            end
        end
    end
    
    -- ==================== ESP透视功能管理器（修复版） ====================
    
    ESPManager = {
        Boxes = {},
        TextLabels = {},
        Connections = {},
        PlayerData = {},
        
        CreateESPForPlayer = function(self, otherPlayer)
            if otherPlayer == player or self.Boxes[otherPlayer] then return end
            
            self.PlayerData[otherPlayer] = {
                Character = nil,
                Humanoid = nil,
                RootPart = nil
            }
            
            -- 监听角色变化
            local function setupCharacter(character)
                if not character then return end
                
                local humanoid = character:WaitForChild("Humanoid", 5)
                local rootPart = character:WaitForChild("HumanoidRootPart", 5)
                
                if humanoid and rootPart then
                    self.PlayerData[otherPlayer].Character = character
                    self.PlayerData[otherPlayer].Humanoid = humanoid
                    self.PlayerData[otherPlayer].RootPart = rootPart
                    
                    -- 创建ESP框
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = otherPlayer.Name .. "_ESPBox"
                    box.Adornee = rootPart
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Size = Vector3.new(4, 6, 1)
                    box.Transparency = 0.3
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Parent = Workspace
                    
                    self.Boxes[otherPlayer] = box
                    
                    -- 创建BillboardGui显示信息
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = otherPlayer.Name .. "_ESPInfo"
                    billboard.Adornee = rootPart
                    billboard.Size = UDim2.new(0, 200, 0, 60)
                    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = 500
                    billboard.Parent = rootPart
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextSize = 14
                    textLabel.Text = otherPlayer.Name
                    textLabel.Parent = billboard
                    
                    self.TextLabels[otherPlayer] = textLabel
                    
                    -- 监听人类血量变化和死亡
                    local humanoidChangedConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        local health = humanoid.Health
                        if health <= 0 then
                            -- 玩家死亡，移除ESP
                            self:RemoveESPForPlayer(otherPlayer)
                        end
                    end)
                    
                    table.insert(self.Connections, humanoidChangedConn)
                end
            end
            
            -- 立即设置现有角色
            if otherPlayer.Character then
                setupCharacter(otherPlayer.Character)
            end
            
            -- 监听角色变化
            local characterAddedConn = otherPlayer.CharacterAdded:Connect(function(character)
                setupCharacter(character)
            end)
            
            local characterRemovingConn = otherPlayer.CharacterRemoving:Connect(function()
                self:RemoveESPForPlayer(otherPlayer)
            end)
            
            table.insert(self.Connections, characterAddedConn)
            table.insert(self.Connections, characterRemovingConn)
        end,
        
        RemoveESPForPlayer = function(self, otherPlayer)
            if self.Boxes[otherPlayer] then
                self.Boxes[otherPlayer]:Destroy()
                self.Boxes[otherPlayer] = nil
            end
            if self.TextLabels[otherPlayer] then
                self.TextLabels[otherPlayer].Parent:Destroy()
                self.TextLabels[otherPlayer] = nil
            end
            self.PlayerData[otherPlayer] = nil
        end,
        
        UpdateESPInfo = function(self)
            if not ESPActive then return end
            
            for otherPlayer, textLabel in pairs(self.TextLabels) do
                local data = self.PlayerData[otherPlayer]
                if data and data.Humanoid and data.RootPart and data.Humanoid.Health > 0 then
                    local myPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
                    if myPosition then
                        local distance = (myPosition - data.RootPart.Position).Magnitude
                        local health = math.floor(data.Humanoid.Health)
                        local maxHealth = data.Humanoid.MaxHealth
                        
                        textLabel.Text = string.format("%s\n距离: %d\n生命: %d/%d", 
                            otherPlayer.Name, math.floor(distance), health, maxHealth)
                    end
                else
                    -- 玩家死亡或数据无效，重新检查
                    if otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and 
                       otherPlayer.Character.Humanoid.Health > 0 then
                        -- 玩家复活了，重新创建ESP
                        self:RemoveESPForPlayer(otherPlayer)
                        self:CreateESPForPlayer(otherPlayer)
                    else
                        self:RemoveESPForPlayer(otherPlayer)
                    end
                end
            end
        end,
        
        Cleanup = function(self)
            for _, box in pairs(self.Boxes) do
                box:Destroy()
            end
            self.Boxes = {}
            
            for _, textLabel in pairs(self.TextLabels) do
                textLabel.Parent:Destroy()
            end
            self.TextLabels = {}
            
            for _, connection in ipairs(self.Connections) do
                connection:Disconnect()
            end
            self.Connections = {}
            
            self.PlayerData = {}
        end
    }
    
    -- ESP更新连接
    local ESPUpdateConnection = nil
    
    -- ==================== 移动功能（修复版） ====================
    
    -- 飞行功能（改进版，带弹窗控制）
    local FlyModule = MovementWin:CreateModule("飞行控制", function(state)
        print("飞行状态:", state)
        FlyActive = state
        
        if state then
            -- 创建飞行控制弹窗
            local FlyControlWindow = Library:CreateChildWindow("飞行控制面板")
            Main:BindWindow("飞行控制面板", false)
            FlyControlWindow.Main.Visible = true
            
            -- 向上飞行按钮
            FlyControlWindow:CreateButton("向上飞行", function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
                end
            end)
            
            -- 向下飞行按钮
            FlyControlWindow:CreateButton("向下飞行", function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    root.CFrame = root.CFrame + Vector3.new(0, -5, 0)
                end
            end)
            
            -- 向前飞行按钮
            FlyControlWindow:CreateButton("向前飞行", function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    root.CFrame = root.CFrame + root.CFrame.LookVector * 5
                end
            end)
            
            -- 向后飞行按钮
            FlyControlWindow:CreateButton("向后飞行", function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    root.CFrame = root.CFrame - root.CFrame.LookVector * 5
                end
            end)
            
            -- 飞行速度滑块
            FlyControlWindow:CreateSlider("飞行速度", 10, 200, 50, function(val)
                print("飞行速度设置为:", val)
                FlySpeed = val
            end)
            
            -- 启用自动飞行
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- 移除旧的BodyVelocity
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
                
                -- 创建飞行控制连接（手机触控版）
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
                    
                    -- 这里可以添加手机触控控制
                    -- 暂时保持为零，让用户通过按钮控制
                    FlyBodyVelocity.Velocity = direction.Unit * FlySpeed
                end)
            end
        else
            -- 关闭飞行
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
            
            -- 隐藏飞行控制面板
            for _, win in pairs(Library.Windows) do
                if win.Main and win.Main.Name == "飞行控制面板" then
                    win.Main.Visible = false
                end
            end
            
            print("飞行已关闭")
        end
    end)
    
    -- 速度功能（修复版）
    local Speed = MovementWin:CreateModule("速度", function(state)
        print("速度状态:", state)
        
        if state then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = _G.SpeedValue
                print("速度设置为:", _G.SpeedValue)
            end
        else
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = 16
                print("速度恢复默认")
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
    
    -- ==================== 战斗功能（手机版） ====================
    
    -- 自瞄功能（手机触控版）
    local AimLock = CombatWin:CreateModule("自瞄锁头", function(state)
        print("自瞄状态:", state)
        AimLockActive = state
        
        if state then
            -- 启用自瞄（自动锁定最近目标）
            if AimLockConnection then
                AimLockConnection:Disconnect()
            end
            
            AimLockConnection = RunService.RenderStepped:Connect(function()
                if not AimLockActive or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                -- 获取最近目标
                local target, distance = GetNearestTarget(AimLockDistance)
                
                if target and target.Character and target.Character:FindFirstChild("Humanoid") and 
                   target.Character.Humanoid.Health > 0 then
                    AimLockTarget = target
                    
                    local myRoot = player.Character.HumanoidRootPart
                    local targetPos = GetTargetPosition(target)
                    
                    if targetPos then
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
                else
                    AimLockTarget = nil
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
    AimLock:CreateSlider("自瞄距离", 10, 300, 50, function(val)
        print("自瞄距离设置为:", val)
        AimLockDistance = val
    end)
    
    -- 子弹追踪功能
    local BulletTrack = CombatWin:CreateModule("子弹追踪", function(state)
        print("子弹追踪状态:", state)
        BulletTrackActive = state
        
        if state then
            -- 尝试破解子弹并添加追踪
            if BulletTrackConnection then
                BulletTrackConnection:Disconnect()
            end
            
            BulletTrackConnection = RunService.Heartbeat:Connect(function()
                if not BulletTrackActive then return end
                
                -- 查找游戏中的子弹
                for _, obj in pairs(Workspace:GetChildren()) do
                    -- 尝试识别子弹对象
                    local isBullet = false
                    local bullet = nil
                    
                    -- 检查常见子弹名称
                    if obj.Name:lower():find("bullet") or 
                       obj.Name:lower():find("ammo") or 
                       obj.Name:lower():find("projectile") or
                       obj.Name:lower():find("shot") then
                        isBullet = true
                        bullet = obj
                    elseif obj:IsA("BasePart") and obj.Velocity.Magnitude > 50 then
                        -- 高速移动的部分可能是子弹
                        isBullet = true
                        bullet = obj
                    end
                    
                    if isBullet and bullet then
                        -- 获取最近目标
                        local target = AimLockTarget
                        if not target then
                            target, _ = GetNearestTarget(AimLockDistance)
                        end
                        
                        if target and target.Character and target.Character:FindFirstChild("Humanoid") and 
                           target.Character.Humanoid.Health > 0 then
                            local targetPos = GetTargetPosition(target)
                            
                            if targetPos then
                                -- 计算朝向目标的方向
                                local direction = (targetPos - bullet.Position).Unit
                                
                                -- 修改子弹速度和方向
                                pcall(function()
                                    if bullet:IsA("BasePart") then
                                        -- 直接修改速度
                                        bullet.Velocity = direction * 100
                                        
                                        -- 尝试修改其他属性
                                        bullet.CFrame = CFrame.new(bullet.Position, bullet.Position + direction)
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
            
            print("子弹追踪已启用（实验性功能）")
        else
            -- 关闭子弹追踪
            if BulletTrackConnection then
                BulletTrackConnection:Disconnect()
                BulletTrackConnection = nil
            end
            print("子弹追踪已关闭")
        end
    end)
    
    -- ==================== 世界功能（修复版） ====================
    
    -- 天空颜色功能（修复版）
    local SkyColor = WorldWin:CreateModule("天空颜色", function(state)
        print("天空颜色状态:", state)
        
        if not state then
            -- 尝试恢复默认天空
            pcall(function()
                -- 尝试重置天空属性
                Lighting.SkyboxBk = "rbxasset://textures/sky/sky_512_bk.tex"
                Lighting.SkyboxDn = "rbxasset://textures/sky/sky_512_dn.tex"
                Lighting.SkyboxFt = "rbxasset://textures/sky/sky_512_ft.tex"
                Lighting.SkyboxLf = "rbxasset://textures/sky/sky_512_lf.tex"
                Lighting.SkyboxRt = "rbxasset://textures/sky/sky_512_rt.tex"
                Lighting.SkyboxUp = "rbxasset://textures/sky/sky_512_up.tex"
            end)
        end
    end)
    
    -- 天空颜色下拉菜单（使用材质ID替代）
    SkyColor:CreateDropdown("天空颜色", {"蓝色天空", "红色天空", "绿色天空", "紫色天空", "橙色天空", "黑夜天空", "重置天空"}, function(selected)
        print("天空颜色选择:", selected)
        
        -- 使用颜色来设置天空盒材质
        local function setSkyColor(color)
            pcall(function()
                -- 创建新的材质
                local colorMaterial = Instance.new("Texture")
                colorMaterial.Name = "CustomSkyColor"
                colorMaterial.Texture = ""
                
                -- 应用颜色到所有面
                Lighting.SkyboxBk = color
                Lighting.SkyboxDn = color
                Lighting.SkyboxFt = color
                Lighting.SkyboxLf = color
                Lighting.SkyboxRt = color
                Lighting.SkyboxUp = color
            end)
        end
        
        if selected == "蓝色天空" then
            -- 尝试使用蓝色天空盒
            pcall(function()
                -- 使用蓝色材质
                local blueColor = Color3.fromRGB(135, 206, 235)
                setSkyColor(blueColor)
            end)
        elseif selected == "红色天空" then
            local redColor = Color3.fromRGB(255, 0, 0)
            setSkyColor(redColor)
        elseif selected == "绿色天空" then
            local greenColor = Color3.fromRGB(0, 255, 0)
            setSkyColor(greenColor)
        elseif selected == "紫色天空" then
            local purpleColor = Color3.fromRGB(150, 0, 255)
            setSkyColor(purpleColor)
        elseif selected == "橙色天空" then
            local orangeColor = Color3.fromRGB(255, 165, 0)
            setSkyColor(orangeColor)
        elseif selected == "黑夜天空" then
            local nightColor = Color3.fromRGB(25, 25, 112)
            setSkyColor(nightColor)
        elseif selected == "重置天空" then
            -- 尝试恢复默认
            pcall(function()
                Lighting.SkyboxBk = "rbxasset://textures/sky/sky_512_bk.tex"
                Lighting.SkyboxDn = "rbxasset://textures/sky/sky_512_dn.tex"
                Lighting.SkyboxFt = "rbxasset://textures/sky/sky_512_ft.tex"
                Lighting.SkyboxLf = "rbxasset://textures/sky/sky_512_lf.tex"
                Lighting.SkyboxRt = "rbxasset://textures/sky/sky_512_rt.tex"
                Lighting.SkyboxUp = "rbxasset://textures/sky/sky_512_up.tex"
            end)
        end
    end)
    
    -- 重力调整功能（修复版）
    local Gravity = WorldWin:CreateModule("重力调整", function(state)
        print("重力调整状态:", state)
        
        if state then
            Workspace.Gravity = _G.GravityValue
            print("重力设置为:", _G.GravityValue)
        else
            Workspace.Gravity = 196.2
            print("重力恢复默认")
        end
    end)
    
    Gravity:CreateSlider("重力强度", 0, 500, 196.2, function(val)
        print("重力强度设置为:", val)
        _G.GravityValue = val
        
        if Workspace.Gravity ~= 196.2 then
            Workspace.Gravity = val
        end
    end)
    
    -- 跳跃调整功能（修复版）
    local Jump = WorldWin:CreateModule("跳跃高度", function(state)
        print("跳跃高度状态:", state)
        
        if state then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = _G.JumpValue
                print("跳跃高度设置为:", _G.JumpValue)
            end
        else
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = 50
                print("跳跃高度恢复默认")
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
    
    -- ==================== ESP透视功能（修复版） ====================
    
    local ESP = WorldWin:CreateModule("透视功能", function(state)
        print("ESP透视状态:", state)
        ESPActive = state
        
        if state then
            -- 启用ESP
            ESPManager:Cleanup()  -- 先清理旧的
            
            -- 为所有玩家创建ESP
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player then
                    ESPManager:CreateESPForPlayer(otherPlayer)
                end
            end
            
            -- 监听新玩家加入
            local playerAddedConn = Players.PlayerAdded:Connect(function(newPlayer)
                if newPlayer ~= player then
                    ESPManager:CreateESPForPlayer(newPlayer)
                end
            end)
            
            table.insert(ESPManager.Connections, playerAddedConn)
            
            -- 监听玩家离开
            local playerRemovingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
                ESPManager:RemoveESPForPlayer(leavingPlayer)
            end)
            
            table.insert(ESPManager.Connections, playerRemovingConn)
            
            -- 启动ESP信息更新（添加定期修复）
            ESPUpdateConnection = RunService.RenderStepped:Connect(function()
                ESPManager:UpdateESPInfo()
                
                -- 每5秒检查一次所有玩家的ESP状态
                if tick() % 5 < 0.1 then
                    UpdateAllESP()
                end
            end)
            
            print("ESP透视已启用")
        else
            -- 关闭ESP
            ESPActive = false
            
            -- 清理所有连接和对象
            ESPManager:Cleanup()
            
            -- 断开更新连接
            if ESPUpdateConnection then
                ESPUpdateConnection:Disconnect()
                ESPUpdateConnection = nil
            end
            
            print("ESP透视已关闭")
        end
    end)
    
    -- ESP颜色选择下拉菜单
    ESP:CreateDropdown("框体颜色", {"红色", "蓝色", "绿色", "黄色", "紫色", "白色", "根据血量"}, function(selected)
        print("ESP颜色选择:", selected)
        
        local colorMap = {
            ["红色"] = Color3.fromRGB(255, 0, 0),
            ["蓝色"] = Color3.fromRGB(0, 0, 255),
            ["绿色"] = Color3.fromRGB(0, 255, 0),
            ["黄色"] = Color3.fromRGB(255, 255, 0),
            ["紫色"] = Color3.fromRGB(150, 0, 255),
            ["白色"] = Color3.fromRGB(255, 255, 255),
            ["根据血量"] = nil
        }
        
        local color = colorMap[selected]
        
        for otherPlayer, box in pairs(ESPManager.Boxes) do
            if selected == "根据血量" then
                local data = ESPManager.PlayerData[otherPlayer]
                if data and data.Humanoid then
                    local healthPercent = (data.Humanoid.Health / data.Humanoid.MaxHealth) * 100
                    if healthPercent > 50 then
                        box.Color3 = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 25 then
                        box.Color3 = Color3.fromRGB(255, 255, 0)
                    else
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                    end
                end
            elseif color then
                box.Color3 = color
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
    WorldWin:CreateButton("重置所有设置", function()
        print("所有设置已重置")
        
        -- 关闭所有功能
        if FlyModule then FlyModule:Set(false) end
        if Speed then Speed:Set(false) end
        if Noclip then Noclip:Set(false) end
        if InfJump then InfJump:Set(false) end
        if SkyColor then SkyColor:Set(false) end
        if Gravity then Gravity:Set(false) end
        if Jump then Jump:Set(false) end
        if ESP then ESP:Set(false) end
        if AimLock then AimLock:Set(false) end
        if BulletTrack then BulletTrack:Set(false) end
        
        -- 清理连接
        if _G.NoclipConnection then
            _G.NoclipConnection:Disconnect()
            _G.NoclipConnection = nil
        end
        if _G.InfJumpConnection then
            _G.InfJumpConnection:Disconnect()
            _G.InfJumpConnection = nil
        end
        
        -- 重置重力
        Workspace.Gravity = 196.2
        
        -- 重置速度
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
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
print("📁 移动功能: 飞行控制、速度、穿墙等")
print("🔫 战斗功能: 自瞄锁头、子弹追踪")
print("👁️ ESP透视: 修复死亡后重新显示")
print("🌍 世界功能: 天空颜色、重力、跳跃等")
print("📱 优化手机操作体验")
print("========================================")
