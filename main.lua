local function getTargetData()
    local bestPart = nil
    local shortestFovDist = math.huge
    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil, nil end
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lPlr.Name then
            if v.Humanoid.Health > 0 then
                local visiblePart = getBestVisibleBone(v)
                if visiblePart then
                    local screenPos, onScreen = cam:WorldToViewportPoint(visiblePart.Position)
                    if onScreen then
                        local worldDist = (myHrp.Position - visiblePart.Position).Magnitude
                        if worldDist <= getgenv().aimbotMaxDist then
                            local mousePos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if fovDist <= getgenv().aimbotFov and fovDist < shortestFovDist then
                                shortestFovDist = fovDist
                                bestPart = visiblePart
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart, shortestFovDist
end

local lastAimTime = 0
runService.RenderStepped:Connect(function()
    fovCircle.Visible = getgenv().showFovCircle and getgenv().aimbotEnabled
    if fovCircle.Visible then
        fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovCircle.Radius = getgenv().aimbotFov
    end
    
    local now = os.clock()
    if getgenv().aimbotEnabled and (now - lastAimTime > 0.01) then
        lastAimTime = now
        local targetPart, fovDist = getTargetData()
        if targetPart and fovDist then
            local fovRatio = 1 - (fovDist / getgenv().aimbotFov)
            local baseLerp = 0.12
            local maxLerp = 0.45
            local dynamicAlpha = baseLerp + (maxLerp - baseLerp) * fovRatio
            local targetCFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, dynamicAlpha)
        end
    end
end)

local function applyLightESP(model)
    if not model or not model.Parent then return end
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlr.Name then return end
        local hrp = model.HumanoidRootPart
        local hl = model:FindFirstChild("MobileESP") or Instance.new("Highlight")
        if not hl.Parent then hl.Name = "MobileESP" hl.Parent = model hl.FillTransparency = 1 hl.OutlineTransparency = 0 end
        local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
        if not bGui.Parent then
            bGui.Name = "TextEspGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 3, 0) bGui.Parent = hrp
            local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextSize = 13 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
            task.spawn(function()
                local lastUpdate = 0
                while model and model.Parent and hrp and txt and bGui and hl do
                    local tickNow = os.clock()
                    if tickNow - lastUpdate > 0.3 then
                        lastUpdate = tickNow
                        local isDead = model.Humanoid.Health <= 0
                        local state = isDead and getgenv().corpseEspEnabled or getgenv().espEnabled
                        hl.Enabled, bGui.Enabled = state, state
                        if state then
                            local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                            if myHrp then
                                local d = math.floor((myHrp.Position - hrp.Position).Magnitude)
                                local visiblePart = getBestVisibleBone(model)
                                local base = isDead and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                                local c = isDead and Color3.fromRGB(150, 150, 150) or visiblePart and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                                hl.OutlineColor, txt.TextColor3 = c, c
                                txt.Text = base .. " " .. tostring(d) .. "m"
                                txt.Visible = true
                            else txt.Visible = false end
                        else txt.Visible = false end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
end

workspace.ChildAdded:Connect(applyLightESP)
task.spawn(function()
    while true do
        if getgenv().itemEspEnabled then
            local mapFolder = workspace:FindFirstChild("Map") or workspace
            for _, descendant in pairs(mapFolder:GetChildren()) do
                if descendant.Name == "AuroraBox" or descendant.Name == "BigBox" or string.find(string.lower(descendant.Name), "safe") or string.find(string.lower(descendant.Name), "сейф") then
                    local p = descendant:IsA("BasePart") and descendant or descendant:FindFirstChild("Part") or descendant:FindFirstChildWhichIsA("BasePart")
                    if p and not p:FindFirstChild("LootTextGui") and getgenv().itemEspEnabled then
                        local b = Instance.new("BillboardGui") b.Name = "LootTextGui" b.AlwaysOnTop = true b.Size = UDim2.new(0, 130, 0, 25) b.StudsOffset = Vector3.new(0, 2, 0) b.Parent = p
                        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 1, 0) t.BackgroundTransparency = 0.3 t.BackgroundColor3 = Color3.fromRGB(20, 20, 20) t.TextColor3 = Color3.fromRGB(255, 215, 0) t.TextSize = 11 t.Font = Enum.Font.SourceSansBold t.Parent = b
                        local cleanName = descendant.Name == "AuroraBox" and "✨ АВРОРА КЕЙС" or descendant.Name == "BigBox" and "🎁 БОЛЬШОЙ КЕЙС" or (string.find(string.lower(descendant.Name), "safe") or string.find(string.lower(descendant.Name), "сейф")) and "🗄️ СЕЙФ" or "📦 ЛУТ / ЯЩИК"
                        t.Text = cleanName Instance.new("UICorner").CornerRadius = UDim.new(0, 6) t.Parent = t
                    end
                    if p and p:FindFirstChild("LootTextGui") and getgenv().itemEspEnabled then
                        local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            local cleanName = descendant.Name == "AuroraBox" and "✨ АВРОРА КЕЙС" or descendant.Name == "BigBox" and "🎁 БОЛЬШОЙ КЕЙС" or (string.find(string.lower(descendant.Name), "safe") or string.find(string.lower(descendant.Name), "сейф")) and "🗄️ СЕЙФ" or "📦 ЛУТ / ЯЩИК"
                            p.LootTextGui.TextLabel.Text = cleanName .. " [" .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)) .. "m]"
                        end
                    end
                end
            end
        end
        task.wait(0.7)
    end
end)

task.spawn(function()
    local objects = workspace:GetChildren()
    for i, v in ipairs(objects) do
        pcall(function() applyLightESP(v) end)
        if i % 100 == 0 then task.wait(0.01) end
    end
end)
getgenv().espEnabled = true
getgenv().corpseEspEnabled = true
getgenv().itemEspEnabled = true
getgenv().mineEspEnabled = true
getgenv().aimbotEnabled = true
getgenv().aimbotMaxDist = 300
getgenv().aimbotFov = 120
getgenv().showFovCircle = true
getgenv().nvgButtonEnabled = false
getgenv().fpsBoostEnabled = false

local lPlr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local inputService = game:GetService("UserInputService")

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = getgenv().showFovCircle
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(0, 255, 150)
fovCircle.Transparency = 0.7
fovCircle.NumSides = 48

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaProjectMenu_" .. math.random(100, 999)
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = game:GetService("CoreGui") or lPlr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 370)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local subFrame = Instance.new("Frame")
subFrame.Name = "SubFrame"
subFrame.Size = UDim2.new(0, 190, 0, 180)
subFrame.Position = UDim2.new(1, 10, 0, 0)
subFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
subFrame.BorderSizePixel = 0
subFrame.Visible = true
subFrame.Parent = mainFrame

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 8)
subCorner.Parent = subFrame

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, 0, 0, 30)
subTitle.BackgroundTransparency = 1
subTitle.Text = "ТОНКИЕ НАСТРОЙКИ АИМА"
subTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
subTitle.TextSize = 12
subTitle.Font = Enum.Font.SourceSansBold
subTitle.Parent = subFrame

local subLayout = Instance.new("UIListLayout")
subLayout.Padding = UDim.new(0, 5)
subLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
subLayout.SortOrder = Enum.SortOrder.LayoutOrder
subLayout.Parent = subFrame
local subPad = Instance.new("Frame")
subPad.Size = UDim2.new(1, 0, 0, 15)
subPad.BackgroundTransparency = 1
subPad.LayoutOrder = 0
subPad.Parent = subFrame

local function createConfigButton(text, fovVal, distVal, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170, 0, 30)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.LayoutOrder = order
    btn.Parent = subFrame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        getgenv().aimbotFov = fovVal
        getgenv().aimbotMaxDist = distVal
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        task.delay(0.2, function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end)
    end)
end

createConfigButton("Предел: ЛЕГИТ (FOV 60 / 150m)", 60, 150, 1)
createConfigButton("Предел: СРЕДНИЙ (FOV 120 / 300m)", 120, 300, 2)
createConfigButton("Предел: ЖЕСТКИЙ (FOV 250 / 600m)", 250, 600, 3)

local fovToggleBtn = Instance.new("TextButton")
fovToggleBtn.Size = UDim2.new(0, 170, 0, 30)
fovToggleBtn.Font = Enum.Font.SourceSansBold
fovToggleBtn.TextSize = 11
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
fovToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fovToggleBtn.Text = "КРУГ FOV: ПОКАЗАТЬ"
fovToggleBtn.LayoutOrder = 4
fovToggleBtn.Parent = subFrame

local fovToggleCorner = Instance.new("UICorner")
fovToggleCorner.CornerRadius = UDim.new(0, 4)
fovToggleCorner.Parent = fovToggleBtn

fovToggleBtn.MouseButton1Click:Connect(function()
    getgenv().showFovCircle = not getgenv().showFovCircle
    if getgenv().showFovCircle then
        fovToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        fovToggleBtn.Text = "КРУГ FOV: ПОКАЗАТЬ"
    else
        fovToggleBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        fovToggleBtn.Text = "КРУГ FOV: СКРЫТЬ"
    end
end)

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.8, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DELTA CHEATS"
titleText.TextColor3 = Color3.fromRGB(0, 255, 150)
titleText.TextSize = 14
titleText.Font = Enum.Font.SourceSansBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
inputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

pcall(function()
    local old; old = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and (self == screenGui or self == mainFrame) then return nil end
        return old(self, key)
    end)
end)

local bonePriority = {"Head", "UpperTorso", "LeftHand", "RightHand"}
local wallCheckCache = {}
local lastCacheReset = os.clock()

local function getBestVisibleBone(character)
    if not character or not lPlr.Character then return nil end
    local now = os.clock()
    if now - lastCacheReset > 0.05 then table.clear(wallCheckCache) lastCacheReset = now end
    if wallCheckCache[character] ~= nil then return wallCheckCache[character] end
    local myHead = lPlr.Character:FindFirstChild("Head")
    if not myHead then return nil end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {lPlr.Character, cam, character}
    rayParams.IgnoreWater = true
    for _, boneName in ipairs(bonePriority) do
        local part = character:FindFirstChild(boneName)
        if part then
            local origin = myHead.Position
            local direction = part.Position - origin
            local cast = workspace:Raycast(origin, direction, rayParams)
            if not cast or cast.Instance.CanCollide == false or cast.Instance.Transparency > 0.7 then
                wallCheckCache[character] = part
                return part
            end
        end
    end
    wallCheckCache[character] = false
    return nil
end
local function getTargetData()
    local bestPart = nil
    local shortestFovDist = math.huge
    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil, nil end
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lPlr.Name then
            if v.Humanoid.Health > 0 then
                local visiblePart = getBestVisibleBone(v)
                if visiblePart then
                    local screenPos, onScreen = cam:WorldToViewportPoint(visiblePart.Position)
                    if onScreen then
                        local worldDist = (myHrp.Position - visiblePart.Position).Magnitude
                        if worldDist <= getgenv().aimbotMaxDist then
                            local mousePos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if fovDist <= getgenv().aimbotFov and fovDist < shortestFovDist then
                                shortestFovDist = fovDist
                                bestPart = visiblePart
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart, shortestFovDist
end

local lastAimTime = 0
runService.RenderStepped:Connect(function()
    fovCircle.Visible = getgenv().showFovCircle and getgenv().aimbotEnabled
    if fovCircle.Visible then
        fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovCircle.Radius = getgenv().aimbotFov
    end
    local now = os.clock()
    if getgenv().aimbotEnabled and (now - lastAimTime > 0.01) then
        lastAimTime = now
        local targetPart, fovDist = getTargetData()
        if targetPart and fovDist then
            local fovRatio = 1 - (fovDist / getgenv().aimbotFov)
            local baseLerp = 0.12
            local maxLerp = 0.45
            local dynamicAlpha = baseLerp + (maxLerp - baseLerp) * fovRatio
            local targetCFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, dynamicAlpha)
        end
    end
end)

local function applyLightESP(model)
    if not model or not model.Parent then return end
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlr.Name then return end
        local hrp = model.HumanoidRootPart
        local hl = model:FindFirstChild("MobileESP") or Instance.new("Highlight")
        if not hl.Parent then hl.Name = "MobileESP" hl.Parent = model hl.FillTransparency = 1 hl.OutlineTransparency = 0 end
        local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
        if not bGui.Parent then
            bGui.Name = "TextEspGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 3, 0) bGui.Parent = hrp
            local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextSize = 13 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
            task.spawn(function()
                local lastUpdate = 0
                while model and model.Parent and hrp and txt and bGui and hl do
                    local tickNow = os.clock()
                    if tickNow - lastUpdate > 0.3 then
                        lastUpdate = tickNow
                        local isDead = model.Humanoid.Health <= 0
                        local state = isDead and getgenv().corpseEspEnabled or getgenv().espEnabled
                        hl.Enabled, bGui.Enabled = state, state
                        if state then
                            local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                            if myHrp then
                                local d = math.floor((myHrp.Position - hrp.Position).Magnitude)
                                local visiblePart = getBestVisibleBone(model)
                                local base = isDead and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                                local c = isDead and Color3.fromRGB(150, 150, 150) or visiblePart and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                                hl.OutlineColor, txt.TextColor3 = c, c
                                txt.Text = base .. " " .. tostring(d) .. "m"
                                txt.Visible = true
                            else txt.Visible = false end
                        else txt.Visible = false end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
end

workspace.ChildAdded:Connect(applyLightESP)
task.spawn(function()
    while true do
        if getgenv().itemEspEnabled then
            local mapFolder = workspace:FindFirstChild("Map") or workspace
            for _, descendant in pairs(mapFolder:GetChildren()) do
                if descendant.Name == "AuroraBox" or descendant.Name == "BigBox" or string.find(string.lower(descendant.Name), "safe") or string.find(string.lower(descendant.Name), "сейф") then
                    local p = descendant:IsA("BasePart") and descendant or descendant:FindFirstChild("Part") or descendant:FindFirstChildWhichIsA("BasePart")
                    if p and not p:FindFirstChild("LootTextGui") and getgenv().itemEspEnabled then
                        local b = Instance.new("BillboardGui") b.Name = "LootTextGui" b.AlwaysOnTop = true b.Size = UDim2.new(0, 130, 0, 25) b.StudsOffset = Vector3.new(0, 2, 0) b.Parent = p
                        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 1, 0) t.BackgroundTransparency = 0.3 t.BackgroundColor3 = Color3.fromRGB(20, 20, 20) t.TextColor3 = Color3.fromRGB(255, 215, 0) t.TextSize = 11 t.Font = Enum.Font.SourceSansBold t.Parent = b
                        local cleanName = descendant.Name == "AuroraBox" and "✨ АВРОРА КЕЙС" or descendant.Name == "BigBox" and "🎁 БОЛЬШОЙ КЕЙС" or (string.find(string.lower(descendant.Name), "safe") or string.find(string.lower(descendant.Name), "сейф")) and "🗄️ СЕЙФ" or "📦 ЛУТ / ЯЩИК"
                        t.Text = cleanName Instance.new("UICorner").CornerRadius = UDim.new(0, 6) t.Parent = t
                    end
                    if p and p:FindFirstChild("LootTextGui") and getgenv().itemEspEnabled then
                        local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            local cleanName = descendant.Name == "AuroraBox" and "✨ АВРОРА КЕЙС" or descendant.Name == "BigBox" and "🎁 БОЛЬШОЙ КЕЙС" or (string.find(string.lower(descendant.Name), "safe") or string.find(string.lower(descendant.Name), "сейф")) and "🗄️ СЕЙФ" or "📦 ЛУТ / ЯЩИК"
                            p.LootTextGui.TextLabel.Text = cleanName .. " [" .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)) .. "m]"
                        end
                    end
                end
            end
        end
        task.wait(0.7)
    end
end)

task.spawn(function()
    local objects = workspace:GetChildren()
    for i, v in ipairs(objects) do
        pcall(function() applyLightESP(v) end)
        if i % 100 == 0 then task.wait(0.01) end
    end
end)
