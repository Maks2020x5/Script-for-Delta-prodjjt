getgenv().espEnabled = true
getgenv().maxDist = 2000
getgenv().hitboxEnabled = false
getgenv().mineEspEnabled = true
getgenv().mineMaxDist = 200
getgenv().itemEspEnabled = true
getgenv().itemMaxDist = 300

getgenv().aimbotEnabled = false
getgenv().aimbotMaxDist = 300
getgenv().aimbotPartMode = "Closest"
getgenv().aimbotSmoothness = 0.15
getgenv().fovCircleVisible = false
getgenv().fovCircleRadius = 120

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64

local function checkPointVisible(origin, part, character)
    local lPlrObj = game:GetService("Players").LocalPlayer
    local camObj = game:GetService("Workspace").CurrentCamera
    if not part or not lPlrObj or not camObj then return false end
    
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lPlrObj.Character, character, camObj}
    raycastParams.IgnoreWater = true
    local raycastResult = game.Workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        local hitObj = raycastResult.Instance
        if hitObj.CanCollide == false or hitObj.Transparency > 0.5 or string.find(string.lower(hitObj.Name), "leaf") or string.find(string.lower(hitObj.Name), "grass") or string.find(string.lower(hitObj.Name), "bush") or string.find(string.lower(hitObj.Name), "twig") then
            return true
        end
        return false
    end
    return true
end

local function isPlayerVisible(character)
    local camObj = game:GetService("Workspace").CurrentCamera
    if not character or not camObj then return false end
    
    local origin = camObj.CFrame.Position
    local head = character:FindFirstChild("Head", true)
    local torso = character:FindFirstChild("UpperTorso", true) or character:FindFirstChild("Torso", true)
    local hrp = character:FindFirstChild("HumanoidRootPart", true)
    if checkPointVisible(origin, head, character) or checkPointVisible(origin, torso, character) or checkPointVisible(origin, hrp, character) then
        return true
    end
    return false
end
local function getClosestTarget()
    local lPlrObj = game:GetService("Players").LocalPlayer
    local camObj = game:GetService("Workspace").CurrentCamera
    if not lPlrObj or not camObj then return nil end
    
    local closestTarget = nil
    local maxMouseDistance = getgenv().fovCircleRadius
    local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart", true)
    if not myHrp then return nil end

    for _, model in pairs(game.Workspace:GetChildren()) do
        if model:FindFirstChild("Humanoid", true) and model:FindFirstChild("HumanoidRootPart", true) and model.Name ~= lPlrObj.Name then
            local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
            local hrp = model:FindFirstChild("HumanoidRootPart", true)
            if humanoid and humanoid.Health > 0 and hrp then
                local worldDist = (myHrp.Position - hrp.Position).Magnitude
                if worldDist <= getgenv().aimbotMaxDist then
                    local targetPart = nil
                    if getgenv().aimbotPartMode == "Head" then
                        targetPart = model:FindFirstChild("Head", true)
                    elseif getgenv().aimbotPartMode == "Torso" then
                        targetPart = model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("Torso", true)
                    elseif getgenv().aimbotPartMode == "Closest" then
                        local head = model:FindFirstChild("Head", true)
                        local torso = model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("Torso", true)
                        if head and torso then
                            local mousePos = Vector2.new(camObj.ViewportSize.X / 2, camObj.ViewportSize.Y / 2)
                            local headPos, _ = camObj:WorldToViewportPoint(head.Position)
                            local torsoPos, _ = camObj:WorldToViewportPoint(torso.Position)
                            local distHead = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                            local distTorso = (Vector2.new(torsoPos.X, torsoPos.Y) - mousePos).Magnitude
                            targetPart = (distHead < distTorso) and head or torso
                        else
                            targetPart = head or hrp
                        end
                    end
                    if targetPart and isPlayerVisible(model) then
                        local screenPosition, onScreen = camObj:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local mousePos = Vector2.new(camObj.ViewportSize.X / 2, camObj.ViewportSize.Y / 2)
                            local targetPos = Vector2.new(screenPosition.X, screenPosition.Y)
                            local distanceToMouse = (targetPos - mousePos).Magnitude
                            if distanceToMouse < maxMouseDistance then
                                maxMouseDistance = distanceToMouse
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

game:GetService("RunService").RenderStepped:Connect(function()
    local camObj = game:GetService("Workspace").CurrentCamera
    if not camObj then return end
    
    if FOVCircle then
        FOVCircle.Visible = getgenv().fovCircleVisible
        FOVCircle.Radius = getgenv().fovCircleRadius
        FOVCircle.Color = Color3.fromRGB(0, 255, 120)
        FOVCircle.Position = Vector2.new(camObj.ViewportSize.X / 2, camObj.ViewportSize.Y / 2)
    end
    if getgenv().aimbotEnabled then
        local target = getClosestTarget()
        if target then
            local targetCFrame = CFrame.new(camObj.CFrame.Position, target.Position)
            camObj.CFrame = camObj.CFrame:Lerp(targetCFrame, getgenv().aimbotSmoothness)
        end
    end
end)
local function applyESP(model)
    local lPlrObj = game:GetService("Players").LocalPlayer
    if not lPlrObj then return end
    
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlrObj.Name then return end
        local hrp = model.HumanoidRootPart
        local head = model:FindFirstChild("Head")
        local highlight = model:FindFirstChild("MobileESP")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "MobileESP"
            highlight.Parent = model
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        end
        local bGui = hrp:FindFirstChild("TextEspGui")
        if not bGui then
            bGui = Instance.new("BillboardGui")
            bGui.Name = "TextEspGui"
            bGui.AlwaysOnTop = true
            bGui.Size = UDim2.new(0, 100, 0, 25)
            bGui.StudsOffset = Vector3.new(0, 3, 0)
            bGui.Parent = hrp
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextSize = 13
            txt.Font = Enum.Font.SourceSansBold
            txt.Parent = bGui
            if game.Players:FindFirstChild(model.Name) then
                txt.TextColor3 = Color3.fromRGB(255, 0, 0)
                txt.Text = "[ИГРОК]"
            else
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.Text = "[БОТ]"
            end
            task.spawn(function()
                while model and model.Parent and hrp and txt and bGui and highlight do
                    highlight.Enabled = getgenv().espEnabled
                    bGui.Enabled = getgenv().espEnabled
                    if head and head:IsA("BasePart") then
                        pcall(function()
                            if hitboxEnabled then
                                head.Size = Vector3.new(3, 3, 3)
                                head.Transparency = 0.7
                                head.CanCollide = false
                            else
                                head.Size = Vector3.new(1.2, 1.2, 1.2)
                                head.Transparency = 0
                                head.CanCollide = true
                            end
                        end)
                    end
                    local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and getgenv().espEnabled then
                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                        if dist <= getgenv().maxDist then
                            local baseText = game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            if isPlayerVisible(model) then
                                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                txt.TextColor3 = Color3.fromRGB(0, 255, 0)
                            else
                                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                txt.TextColor3 = Color3.fromRGB(255, 0, 0)
                            end
                            txt.Text = baseText .. " " .. tostring(dist)
                            txt.Visible = true
                            highlight.Enabled = true
                        else
                            txt.Visible = false
                            highlight.Enabled = false
                        end
                    else
                        txt.Visible = false
                        highlight.Enabled = false
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
    local nameL = string.lower(model.Name)
    local isMine = string.find(nameL, "mine") or string.find(nameL, "claymore") or string.find(nameL, "explosive") or string.find(nameL, "растяжка")
    if isMine then
        local triggerPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not triggerPart or triggerPart:FindFirstChild("MineTextGui") then return end
        local mineHighlight = model:FindFirstChild("MineHighlight") or Instance.new("Highlight")
        if not mineHighlight.Parent then
            mineHighlight.Name = "MineHighlight"
            mineHighlight.FillTransparency = 0.7
            mineHighlight.OutlineTransparency = 0
            mineHighlight.OutlineColor = Color3.fromRGB(138, 43, 226)
            mineHighlight.FillColor = Color3.fromRGB(138, 43, 226)
            mineHighlight.Parent = model
        end
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "MineTextGui"
        bGui.AlwaysOnTop = true
        bGui.Size = UDim2.new(0, 100, 0, 25)
        bGui.StudsOffset = Vector3.new(0, 1.5, 0)
        bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 0.3
        txt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        txt.TextColor3 = Color3.fromRGB(238, 130, 238)
        txt.TextSize = 12
        txt.Font = Enum.Font.SourceSansBold
        txt.Text = "⚠️ МИНА"
        txt.Parent = bGui
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 6)
        uiCorner.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui and mineHighlight do
                bGui.Enabled = getgenv().mineEspEnabled
                mineHighlight.Enabled = getgenv().mineEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    if dist <= getgenv().mineMaxDist then
                        txt.Text = "⚠️ МИНА " .. tostring(dist)
                        txt.Visible = true
                        mineHighlight.Enabled = true
                    else
                        txt.Visible = false
                        mineHighlight.Enabled = false
                    end
                else
                    txt.Visible = false
                    mineHighlight.Enabled = false
                end
                task.wait(0.5)
            end
        end)
        return
    end
    local isAurora = model.Name == "AuroraBox"
    local isBig = model.Name == "BigBox"
    local isSafe = string.find(nameL, "safe") or string.find(nameL, "сейф")
    local isDroppedItem = model:IsA("Model") and model:FindFirstChild("Part") and not model:FindFirstChild("Humanoid")
    if isAurora or isBig or isSafe or isDroppedItem then
        local triggerPart = model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
        if not triggerPart or triggerPart:FindFirstChild("LootTextGui") then return end
        local lootHighlight = model:FindFirstChild("LootHighlight") or Instance.new("Highlight")
        if not lootHighlight.Parent then
            lootHighlight.Name = "LootHighlight"
            lootHighlight.FillTransparency = 0.8
            lootHighlight.OutlineTransparency = 0
            lootHighlight.OutlineColor = Color3.fromRGB(255, 215, 0)
            lootHighlight.FillColor = Color3.fromRGB(255, 215, 0)
            lootHighlight.Parent = model
        end
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "LootTextGui"
        bGui.AlwaysOnTop = true
        bGui.Size = UDim2.new(0, 120, 0, 25)
        bGui.StudsOffset = Vector3.new(0, 2, 0)
        bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 0.4
        txt.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        txt.TextColor3 = Color3.fromRGB(255, 215, 0)
        txt.TextSize = 11
        txt.Font = Enum.Font.SourceSansBold
        local displayName = "📦 ПРЕДМЕТ"
        if isAurora then displayName = "✨ АВРОРА КЕЙС"
        elseif isBig then displayName = "🎁 БОЛЬШОЙ КЕЙС"
        elseif isSafe then displayName = "🗄️ СЕЙФ" end
        txt.Text = displayName
        txt.Parent = bGui
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 6)
        uiCorner.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui and lootHighlight do
                bGui.Enabled = getgenv().itemEspEnabled
                lootHighlight.Enabled = getgenv().itemEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    if dist <= getgenv().itemMaxDist then
                        txt.Text = displayName .. " " .. tostring(dist)
                        txt.Visible = true
                        lootHighlight.Enabled = true
                    else
                        txt.Visible = false
                        lootHighlight.Enabled = false
                    end
                else
                    txt.Visible = false
                    lootHighlight.Enabled = false
                end
                task.wait(0.5)
            end
        end)
    end
end
workspace.ChildAdded:Connect(applyESP)
for _, v in pairs(workspace:GetChildren()) do applyESP(v) end
local TargetParent = nil
if pcall(function() return gethui() end) and gethui() then
    TargetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    TargetParent = game:GetService("CoreGui")
else
    TargetParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
end

if not TargetParent then TargetParent = game:GetService("Players").LocalPlayer.PlayerGui end

if TargetParent:FindFirstChild("GMK_Menu") then TargetParent.GMK_Menu:Destroy() end

local GMK_Menu = Instance.new("ScreenGui")
GMK_Menu.Name = "GMK_Menu"
GMK_Menu.ResetOnSpawn = false
GMK_Menu.Parent = TargetParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ZIndex = 100
MainFrame.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) MainFrame.Parent = MainFrame

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 35)
OpenBtn.Position = UDim2.new(0.5, -30, 0.5, -17)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenBtn.Text = "GMK"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.TextSize = 14
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.ZIndex = 500
OpenBtn.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 6) OpenBtn.Parent = OpenBtn

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GMK MENU"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 105
Title.Parent = MainFrame

local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 90, 0, 210)
TabPanel.Position = UDim2.new(0, 0, 0, 30)
TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabPanel.BorderSizePixel = 0
TabPanel.ZIndex = 105
TabPanel.Parent = MainFrame

local EspTabBtn = Instance.new("TextButton")
EspTabBtn.Size = UDim2.new(0, 90, 0, 35)
EspTabBtn.Position = UDim2.new(0, 0, 0, 0)
EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
EspTabBtn.Text = "ESP"
EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspTabBtn.Font = Enum.Font.SourceSansBold
EspTabBtn.TextSize = 13
EspTabBtn.ZIndex = 110
EspTabBtn.Parent = TabPanel

local AimTabBtn = Instance.new("TextButton")
AimTabBtn.Size = UDim2.new(0, 90, 0, 35)
AimTabBtn.Position = UDim2.new(0, 0, 0, 35)
AimTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
AimTabBtn.Text = "AIMBOT"
AimTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
AimTabBtn.Font = Enum.Font.SourceSansBold
AimTabBtn.TextSize = 13
AimTabBtn.ZIndex = 110
AimTabBtn.Parent = TabPanel

local function createToggleObj(text, globalVar, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 170, 0, 25)
    lbl.Position = UDim2.new(0, 105, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 125
    lbl.Parent = MainFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 18)
    btn.Position = UDim2.new(0, 295, 0, yPos + 3)
    btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60)
    btn.Text = ""
    btn.ZIndex = 125
    btn.Parent = MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn

    btn.MouseButton1Click:Connect(function()
        getgenv()[globalVar] = not getgenv()[globalVar]
        btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60)
    end)
    return lbl, btn
end

local function createSliderObj(text, min, max, globalVar, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 230, 0, 15)
    lbl.Position = UDim2.new(0, 105, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(getgenv()[globalVar])
    lbl.TextColor3 = Color3.fromRGB(180, 190, 180)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 125
    lbl.Parent = MainFrame

    local slideBar = Instance.new("TextButton")
    slideBar.Size = UDim2.new(0, 230, 0, 6)
    slideBar.Position = UDim2.new(0, 105, 0, yPos + 18)
    slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    slideBar.Text = ""
    slideBar.ZIndex = 125
    slideBar.Parent = MainFrame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getgenv()[globalVar] - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    fill.BorderSizePixel = 0
    fill.ZIndex = 126
    fill.Parent = slideBar

    local isDragging = false
    local function updateSlider(inputObject)
        local inputPos = inputObject.Position.X
        local barAbsolutePos = slideBar.AbsolutePosition.X
        local barAbsoluteSize = slideBar.AbsoluteSize.X
        local percentage = math.clamp((inputPos - barAbsolutePos) / barAbsoluteSize, 0, 1)
        local value = math.floor(min + (max - min) * percentage)
        getgenv()[globalVar] = value
        lbl.Text = text .. ": " .. tostring(value)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
    end

    slideBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true updateSlider(input)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    return lbl, slideBar
end

local eL1, eB1 = createToggleObj("Включить ESP игрока", "espEnabled", 35)
local eL2, eB2 = createSliderObj("Дистанция ESP", 100, 2000, "maxDist", 65)
local eL3, eB3 = createToggleObj("ESP Мины / Растяжки", "mineEspEnabled", 105)
local eL4, eB4 = createToggleObj("ESP Сейфы / Кейсы", "itemEspEnabled", 135)

local aL1, aB1 = createToggleObj("Включить Sentinel Аим", "aimbotEnabled", 35)
local aL2, aB2 = createSliderObj("Дистанция Аима", 10, 500, "aimbotMaxDist", 65)
local aL3, aB3 = createSliderObj("Радиус FOV круга", 30, 400, "fovCircleRadius", 105)
local aL4, aB4 = createToggleObj("Показывать круг FOV", "fovCircleVisible", 145)

local function showEspPage(state)
    eL1.Visible = state eB1.Visible = state eL2.Visible = state eB2.Visible = state
    eL3.Visible = state eB3.Visible = state eL4.Visible = state eB4.Visible = state
end

local function showAimPage(state)
    aL1.Visible = state aB1.Visible = state aL2.Visible = state aB2.Visible = state
    aL3.Visible = state aB3.Visible = state aL4.Visible = state aB4.Visible = state
end

showEspPage(true)
showAimPage(false)

EspTabBtn.MouseButton1Click:Connect(function()
    EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22) AimTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    showEspPage(true)
    showAimPage(false)
end)

AimTabBtn.MouseButton1Click:Connect(function()
    AimTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) AimTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    EspTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22) EspTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    showEspPage(false)
    showAimPage(true)
end)
