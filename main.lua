getgenv().espEnabled = true
getgenv().corpseEspEnabled = true
getgenv().itemEspEnabled = true
getgenv().aimbotEnabled = true
getgenv().aimbotMaxDist = 1000
getgenv().aimbotFov = 120
getgenv().showFovCircle = true
getgenv().nvgButtonEnabled = false
getgenv().thermalButtonEnabled = false
getgenv().fpsBoostEnabled = false
getgenv().zoomMultiplier = 2
getgenv().zoomButtonEnabled = false

local lPlr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local inputService = game:GetService("UserInputService")
local soundService = game:GetService("SoundService")

local lastAimTime = os.clock()

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

if gethui then screenGui.Parent = gethui()
elseif syn and syn.protect_gui then syn.protect_gui(screenGui); screenGui.Parent = game:GetService("CoreGui")
else screenGui.Parent = game:GetService("CoreGui") or lPlr:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 420)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
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
createConfigButton("Предел: СРЕДНИЙ (FOV 120 / 400m)", 120, 400, 2)
createConfigButton("Предел: МАКСИМУМ (FOV 250 / 1000m)", 250, 1000, 3)

local function getAllCharacters()
    local list = {}
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p.Character)
        end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and not game:GetService("Players"):GetPlayerFromCharacter(v) then
            table.insert(list, v)
        end
    end
    return list
end

local function playHitSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9114223193"; sound.Volume = 0.4; sound.PlayOnRemove = true; sound.Parent = soundService; sound:Destroy()
end

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

local bonePriority = {"Head", "UpperTorso", "LeftHand", "RightHand"}
local wallCheckCache = {}
local lastCacheReset = os.clock()
local targetHealthTracker = {}

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.8, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DELTA CHEATS (FIXED)"
titleText.TextColor3 = Color3.fromRGB(0, 255, 150)
titleText.TextSize = 14
titleText.Font = Enum.Font.SourceSansBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
titleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
inputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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
            local direction = (part.Position - origin).Unit * 1000
            local cast = workspace:Raycast(origin, direction, rayParams)
            if not cast or cast.Instance.CanCollide == false or cast.Instance.Transparency > 0.7 then
                wallCheckCache[character] = part; return part
            end
        end
    end
    wallCheckCache[character] = false; return nil
end

local function getTargetData()
    local bestPart = nil; local shortestFovDist = math.huge; local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil, nil end
    for _, v in pairs(getAllCharacters()) do
        if v.Name ~= lPlr.Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local visiblePart = getBestVisibleBone(v)
            if visiblePart then
                local screenPos, onScreen = cam:WorldToViewportPoint(visiblePart.Position)
                if onScreen then
                    local worldDist = (myHrp.Position - visiblePart.Position).Magnitude
                    if worldDist <= getgenv().aimbotMaxDist then
                        local mousePos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if fovDist <= getgenv().aimbotFov and fovDist < shortestFovDist then shortestFovDist = fovDist; bestPart = visiblePart end
                    end
                end
            end
        end
    end
    return bestPart, shortestFovDist
end

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(0.9, 0, 0.08, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = titleBar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 0, 380)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local layout = Instance.new("UIGridLayout")
layout.Padding = UDim2.new(0, 10, 0, 10)
layout.CellSize = UDim2.new(0, 185, 0, 32)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentFrame
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        contentFrame.Visible = false; subFrame.Visible = false; mainFrame.Size = UDim2.new(0, 400, 0, 35); minimizeBtn.Text = "+"
    else
        contentFrame.Visible = true; subFrame.Visible = getgenv().aimbotEnabled; mainFrame.Size = UDim2.new(0, 400, 0, 420); minimizeBtn.Text = "—"
    end
end)

local function makeButtonDraggable(button)
    local bDragging, bDragInput, bDragStart, bStartPos
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bDragging = true; bDragStart = input.Position; bStartPos = button.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then bDragging = false end end)
        end
    end)
    button.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then bDragInput = input end end)
    inputService.InputChanged:Connect(function(input)
        if input == bDragInput and bDragging then
            local delta = input.Position - bDragStart
            button.Position = UDim2.new(bStartPos.X.Scale, bStartPos.X.Offset + delta.X, button.Position.Y.Scale, bStartPos.Y.Offset + delta.Y)
        end
    end)
end

local actionButton = Instance.new("TextButton")
actionButton.Name = "NvgScreenButton"
actionButton.Size = UDim2.new(0, 55, 0, 55)
actionButton.Position = UDim2.new(0.85, 0, 0.35, 0)
actionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
actionButton.TextColor3 = Color3.fromRGB(0, 255, 0)
actionButton.TextSize = 12
actionButton.Font = Enum.Font.SourceSansBold
actionButton.Text = "NVG"
actionButton.Visible = false
actionButton.Parent = screenGui
Instance.new("UICorner", actionButton).CornerRadius = UDim.new(1, 0)
local actStroke = Instance.new("UIStroke")
actStroke.Color = Color3.fromRGB(0, 255, 0)
actStroke.Thickness = 2
actStroke.Parent = actionButton
makeButtonDraggable(actionButton)

local thermalActionButton = Instance.new("TextButton")
thermalActionButton.Name = "ThermalScreenButton"
thermalActionButton.Size = UDim2.new(0, 55, 0, 55)
thermalActionButton.Position = UDim2.new(0.85, 0, 0.45, 0)
thermalActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
thermalActionButton.TextColor3 = Color3.fromRGB(255, 100, 0)
thermalActionButton.TextSize = 11
thermalActionButton.Font = Enum.Font.SourceSansBold
thermalActionButton.Text = "THRM"
thermalActionButton.Visible = false
thermalActionButton.Parent = screenGui
Instance.new("UICorner", thermalActionButton).CornerRadius = UDim.new(1, 0)
local thrmStroke = Instance.new("UIStroke")
thrmStroke.Color = Color3.fromRGB(255, 100, 0)
thrmStroke.Thickness = 2
thrmStroke.Parent = thermalActionButton
makeButtonDraggable(thermalActionButton)

local zoomActionButton = Instance.new("TextButton")
zoomActionButton.Name = "ZoomScreenButton"
zoomActionButton.Size = UDim2.new(0, 55, 0, 55)
zoomActionButton.Position = UDim2.new(0.85, 0, 0.55, 0)
zoomActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
zoomActionButton.TextColor3 = Color3.fromRGB(0, 220, 255)
zoomActionButton.TextSize = 11
zoomActionButton.Font = Enum.Font.SourceSansBold
zoomActionButton.Text = "ZOOM"
zoomActionButton.Visible = false
zoomActionButton.Parent = screenGui
Instance.new("UICorner", zoomActionButton).CornerRadius = UDim.new(1, 0)
local zoomStroke = Instance.new("UIStroke")
zoomStroke.Color = Color3.fromRGB(0, 220, 255)
zoomStroke.Thickness = 2
zoomStroke.Parent = zoomActionButton
makeButtonDraggable(zoomActionButton)

local extSliderFrame = Instance.new("Frame")
extSliderFrame.Name = "ExtSliderFrame"
extSliderFrame.Size = UDim2.new(0, 130, 0, 14)
extSliderFrame.Position = UDim2.new(0, -140, 0, 20)
extSliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
extSliderFrame.Visible = false
extSliderFrame.Parent = zoomActionButton
Instance.new("UICorner", extSliderFrame).CornerRadius = UDim.new(0, 4)

local extSliderBtn = Instance.new("TextButton")
extSliderBtn.Size = UDim2.new(0, 14, 1, 0)
extSliderBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
extSliderBtn.Text = ""
extSliderBtn.Parent = extSliderFrame
Instance.new("UICorner", extSliderBtn).CornerRadius = UDim.new(0, 4)

local extSliderLabel = Instance.new("TextLabel")
extSliderLabel.Size = UDim2.new(0, 130, 0, 16)
extSliderLabel.Position = UDim2.new(0, 0, 0, -18)
extSliderLabel.BackgroundTransparency = 1
extSliderLabel.Font = Enum.Font.SourceSansBold
extSliderLabel.TextSize = 11
extSliderLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
extSliderLabel.Text = "ЗУМ: 2x"
extSliderLabel.Parent = extSliderFrame

local nvgActive, thermalActive, zoomActive, origAmbient, origOutdoor, origColorCorr
local function resetLightingEffects()
    if origAmbient then lighting.Ambient = origAmbient end
    if origOutdoor then lighting.OutdoorAmbient = origOutdoor end
    local cc = lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if cc and origColorCorr then 
        cc.TintColor = origColorCorr.TintColor; cc.Brightness = origColorCorr.Brightness
        cc.Contrast = origColorCorr.Contrast; cc.Saturation = origColorCorr.Saturation
    end
end

local function turnOffNvg()
    nvgActive = false; actionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); actionButton.TextColor3 = Color3.fromRGB(0, 255, 0)
    if not thermalActive then resetLightingEffects() end
end

actionButton.MouseButton1Click:Connect(function()
    nvgActive = not nvgActive
    if nvgActive then
        if thermalActive then thermalActive = false; thermalActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); thermalActionButton.TextColor3 = Color3.fromRGB(255, 100, 0) end
        actionButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0); actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        if not origAmbient then origAmbient = lighting.Ambient; origOutdoor = lighting.OutdoorAmbient end
        lighting.Ambient = Color3.fromRGB(100, 255, 100); lighting.OutdoorAmbient = Color3.fromRGB(100, 255, 100)
        local cc = lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", lighting)
        if not origColorCorr then origColorCorr = {TintColor = cc.TintColor, Brightness = cc.Brightness, Contrast = cc.Contrast, Saturation = cc.Saturation} end
        cc.TintColor = Color3.fromRGB(120, 255, 120); cc.Brightness = 0.2; cc.Contrast = 0; cc.Saturation = 0
    else turnOffNvg() end
end)

thermalActionButton.MouseButton1Click:Connect(function()
    thermalActive = not thermalActive
    if thermalActive then
        if nvgActive then turnOffNvg() end
        thermalActionButton.BackgroundColor3 = Color3.fromRGB(180, 50, 0); thermalActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        if not origAmbient then origAmbient = lighting.Ambient; origOutdoor = lighting.OutdoorAmbient end
        lighting.Ambient = Color3.fromRGB(15, 20, 60); lighting.OutdoorAmbient = Color3.fromRGB(10, 15, 40)
        local cc = lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", lighting)
        if not origColorCorr then origColorCorr = {TintColor = cc.TintColor, Brightness = cc.Brightness, Contrast = cc.Contrast, Saturation = cc.Saturation} end
        cc.TintColor = Color3.fromRGB(80, 120, 255); cc.Brightness = 0.1; cc.Contrast = 0.6; cc.Saturation = -0.8
    else
        thermalActive = false; thermalActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); thermalActionButton.TextColor3 = Color3.fromRGB(255, 100, 0); resetLightingEffects()
    end
end)

zoomActionButton.MouseButton1Click:Connect(function()
    zoomActive = not zoomActive
    if zoomActive then zoomActionButton.BackgroundColor3 = Color3.fromRGB(0, 120, 150); zoomActionButton.TextColor3 = Color3.fromRGB(255, 255, 255); extSliderFrame.Visible = true
    else zoomActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); zoomActionButton.TextColor3 = Color3.fromRGB(0, 220, 255); extSliderFrame.Visible = false end
end)

local backupEffects, origShadows = {}, lighting.GlobalShadows
local function toggleFpsBoost(enable)
    lighting.GlobalShadows = not enable
    if enable then
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Sky") or effect:IsA("Clouds") or effect:IsA("Atmosphere") then
                table.insert(backupEffects, {effect = effect, parent = effect.Parent}); effect.Parent = nil
            end
        end
    else
        lighting.GlobalShadows = origShadows
        for _, data in pairs(backupEffects) do if data.effect then data.effect.Parent = data.parent end end; table.clear(backupEffects)
    end
end

local function destroyAllLootGuis()
    for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BillboardGui") and (v.Name == "LootTextGui") then v:Destroy() end end
end

local function createToggle(text, env_val, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 185, 0, 32); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 13; btn.BorderSizePixel = 0; btn.LayoutOrder = order; btn.Parent = contentFrame
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn
    local function updateVisuals()
        if getgenv()[env_val] then
            btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34); btn.Text = text .. ": ВКЛ"; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if env_val == "aimbotEnabled" and not isMinimized then subFrame.Visible = true end
            if env_val == "nvgButtonEnabled" then actionButton.Visible = true end
            if env_val == "thermalButtonEnabled" then thermalActionButton.Visible = true end
            if env_val == "zoomButtonEnabled" then zoomActionButton.Visible = true end
            if env_val == "fpsBoostEnabled" then toggleFpsBoost(true) end
        else
            btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0); btn.Text = text .. ": ВЫКЛ"; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            if env_val == "aimbotEnabled" then subFrame.Visible = false end
            if env_val == "fpsBoostEnabled" then toggleFpsBoost(false) end
            if env_val == "nvgButtonEnabled" then actionButton.Visible = false; turnOffNvg() end
            if env_val == "thermalButtonEnabled" then thermalActionButton.Visible = false; thermalActive = false; thermalActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); resetLightingEffects() end
            if env_val == "zoomButtonEnabled" then zoomActionButton.Visible = false; zoomActive = false; extSliderFrame.Visible = false; zoomActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
            if env_val == "itemEspEnabled" then destroyAllLootGuis() end
        end
    end
    updateVisuals(); btn.MouseButton1Click:Connect(function() getgenv()[env_val] = not getgenv()[env_val]; updateVisuals() end)
end

createToggle("🎯 АИМБОТ", "aimbotEnabled", 1)
createToggle("👤 ESP ИГРОКИ", "espEnabled", 2)
createToggle("💀 ESP ТРУПЫ", "corpseEspEnabled", 3)
createToggle("📦 ESP ЛУТ / КЕЙСЫ", "itemEspEnabled", 4)
createToggle("🟢 ПНВ КНОПКА", "nvgButtonEnabled", 6)
createToggle("🔥 ТЕПЛОВИЗОР ФУНКЦИЯ", "thermalButtonEnabled", 7)
createToggle("🔭 ЗУМ ОПТИКА КНОПКА", "zoomButtonEnabled", 8)
createToggle("⚡ ФПС БУСТ", "fpsBoostEnabled", 9)

local slidingZoom = false
extSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then slidingZoom = true end end)
inputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then slidingZoom = false end end)
inputService.InputChanged:Connect(function(input)
    if slidingZoom and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X; local frameLeft = extSliderFrame.AbsolutePosition.X; local frameWidth = extSliderFrame.AbsoluteSize.X
        local percentage = math.clamp((mousePos - frameLeft) / frameWidth, 0, 1)
        extSliderBtn.Position = UDim2.new(percentage * (1 - 14/frameWidth), 0, 0, 0)
        local calculatedZoom = math.floor(2 + (percentage * 14))
        getgenv().zoomMultiplier = calculatedZoom; extSliderLabel.Text = "ЗУМ: " .. tostring(calculatedZoom) .. "x"
    end
end)

runService.RenderStepped:Connect(function()
    local targetMultiplier = zoomActive and getgenv().zoomMultiplier or 1
    cam.FieldOfView = cam.FieldOfView + ((70 / targetMultiplier) - cam.FieldOfView) * 0.2
    fovCircle.Visible = getgenv().showFovCircle and getgenv().aimbotEnabled
    if fovCircle.Visible then fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); fovCircle.Radius = getgenv().aimbotFov end
    if getgenv().aimbotEnabled and (os.clock() - lastAimTime > 0.01) then
        lastAimTime = os.clock()
        local targetPart, fovDist = getTargetData()
        if targetPart and fovDist then
            local enemyHrp = targetPart.Parent:FindFirstChild("HumanoidRootPart")
            local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
            local finalPos = targetPart.Position
            if enemyHrp and myHrp then 
                local bulletSpeed = 950; local distance = (myHrp.Position - targetPart.Position).Magnitude; local travelTime = distance / bulletSpeed
                local movePrediction = enemyHrp.Velocity * travelTime; local gravityCorrection = Vector3.new(0, 0.5 * 196.2 * (travelTime ^ 2), 0)
                finalPos = targetPart.Position + movePrediction + gravityCorrection
            end
            local fovRatio = 1 - (fovDist / getgenv().aimbotFov)
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, finalPos), 0.12 + (0.33 * fovRatio))
        end
    end
end)

local function applyLightESP(m)
    if not m or not m.Parent or not m:IsA("Model") or not m:FindFirstChild("Humanoid") or not m:FindFirstChild("HumanoidRootPart") or m.Name == lPlr.Name then return end
    local hrp, hum = m.HumanoidRootPart, m.Humanoid; targetHealthTracker[m] = hum.Health
    if not m:GetAttribute("ConnectedESP") then
        m:SetAttribute("ConnectedESP", true)
        hum.HealthChanged:Connect(function(nh)
            local oh = targetHealthTracker[m] or nh
            if nh < oh and getgenv().aimbotEnabled and m:FindFirstChild("Head") then
                local screenPos, onScreen = cam:WorldToViewportPoint(m.Head.Position)
                if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude <= getgenv().aimbotFov then playHitSound() end
            end
            targetHealthTracker[m] = nh
        end)
    end
    local hl = m:FindFirstChild("MobileESP") or Instance.new("Highlight")
    if not hl.Parent then hl.Name = "MobileESP"; hl.Parent = m; hl.FillTransparency = 1; hl.OutlineTransparency = 0 end
    local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
    if not bGui.Parent then
        bGui.Name = "TextEspGui"; bGui.AlwaysOnTop = true; bGui.MaxDistance = 4000; bGui.Size = UDim2.new(0, 140, 0, 25); bGui.StudsOffset = Vector3.new(0, 3, 0); bGui.Parent = hrp
        local txt = Instance.new("TextLabel", bGui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.TextSize = 13; txt.Font = Enum.Font.SourceSansBold
        task.spawn(function()
            while m and m.Parent and hrp and txt and bGui and hl do
                local isDead = hum.Health <= 0; local state = isDead and getgenv().corpseEspEnabled or getgenv().espEnabled
                hl.Enabled, bGui.Enabled = state, state
                if state and lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart") then
                    local d = math.floor((lPlr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    if d <= 4000 then
                        local isReal = game.Players:FindFirstChild(m.Name) ~= nil; local base = isDead and "[ТРУП]" or isReal and "[ИГРОК]" or "[БОТ]"
                        local c = isDead and Color3.fromRGB(150, 150, 150) or getBestVisibleBone(m) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                        if thermalActive and not isDead then hl.FillColor = Color3.fromRGB(255, 80, 0); hl.FillTransparency = 0.25; c = Color3.fromRGB(255, 230, 0) else hl.FillTransparency = 1 end
                        hl.OutlineColor, txt.TextColor3 = c, c; txt.Text = base .. " " .. tostring(d) .. "m" .. (isDead and "" or " [" .. math.floor(hum.Health) .. " HP]"); txt.Visible = true
                    else txt.Visible = false end
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end

workspace.DescendantAdded:Connect(applyLightESP)
task.spawn(function()
    while true do
        if getgenv().itemEspEnabled and lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart") then
            for _, descendant in ipairs(workspace:GetChildren()) do
                local nameLower = string.lower(descendant.Name)
                local isLoot = string.find(nameLower, "aurora") or string.find(nameLower, "case") or string.find(nameLower, "safe") or string.find(nameLower, "сейф") or string.find(nameLower, "box")
                local isDrop = string.find(nameLower, "drop") or string.find(nameLower, "airdrop") or string.find(nameLower, "supply")
                if isLoot or isDrop then
                    local p = descendant:IsA("BasePart") and descendant or descendant:FindFirstChildWhichIsA("BasePart")
                    if p then
                        local dist = math.floor((lPlr.Character.HumanoidRootPart.Position - p.Position).Magnitude)
                        if dist <= 3000 then
                            local guiName = "LootTextGui"; local b = p:FindFirstChild(guiName)
                            if not b then
                                b = Instance.new("BillboardGui", p); b.Name = guiName; b.AlwaysOnTop = true; b.MaxDistance = 3000; b.Size = UDim2.new(0, 140, 0, 25); b.StudsOffset = Vector3.new(0, 2, 0)
                                local t = Instance.new("TextLabel", b); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 0.3; t.BackgroundColor3 = Color3.fromRGB(20, 20, 20); t.TextSize = 11; t.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
                            end
                            local cleanName = "📦 ОБЪЕКТ"
                            if isDrop then cleanName = "✈️ АИРДРОП"; b.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                            elseif string.find(nameLower, "aurora") then cleanName = "✨ АВРОРА КЕЙС"; b.TextLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                            elseif string.find(nameLower, "safe") or string.find(nameLower, "сейф") then cleanName = "🗄️ СЕЙФ"; b.TextLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                            else cleanName = "🎁 ЯЩИК"; b.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 100) end
                            b.TextLabel.Text = cleanName .. " [" .. tostring(dist) .. "m]"
                        end
                    end
                end
            end
        end
        task.wait(1.5)
    end
end)
for _, v in pairs(workspace:GetChildren()) do pcall(function() applyLightESP(v) end) end
