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

-- Новые параметры для покостного ESP
getgenv().partEspColorVisible = Color3.fromRGB(0, 255, 120) -- Зеленый (когда виден)
getgenv().partEspColorHidden = Color3.fromRGB(255, 0, 0)   -- Красный (когда скрыт)
getgenv().hiddenTransparency = 0.4 -- Прозрачность 40% для закрытых костей

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64
function checkPointVisible(origin, part, character)
    local lPlrObj = game:GetService("Players").LocalPlayer
    local camObj = game:GetService("Workspace").CurrentCamera
    if not part or not lPlrObj or not camObj then return false end
    
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lPlrObj.Character, character, camObj}
    raycastParams.IgnoreWater = true
    
    local success, raycastResult = pcall(function()
        return game.Workspace:Raycast(origin, direction, raycastParams)
    end)
    
    if success and raycastResult then
        local hitObj = raycastResult.Instance
        if hitObj.CanCollide == false or hitObj.Transparency > 0.5 or string.find(string.lower(hitObj.Name), "leaf") or string.find(string.lower(hitObj.Name), "grass") or string.find(string.lower(hitObj.Name), "bush") or string.find(string.lower(hitObj.Name), "twig") then
            return true
        end
        return false
    end
    return true
end

function isPartVisible(part, character)
    local camObj = game:GetService("Workspace").CurrentCamera
    if not part or not camObj then return false end
    return checkPointVisible(camObj.CFrame.Position, part, character)
end

function getClosestTarget()
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
                    if targetPart and isPartVisible(targetPart, model) then
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
function applyPartESP(model)
    local lPlrObj = game:GetService("Players").LocalPlayer
    if not lPlrObj then return end
    
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlrObj.Name then return end
        local hrp = model.HumanoidRootPart
        local head = model:FindFirstChild("Head")
        
        --Billboard Gui Логика текста имени
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
            
            task.spawn(function()
                while model and model.Parent and hrp and txt and bGui do
                    bGui.Enabled = getgenv().espEnabled
                    if head and head:IsA("BasePart") then
                        pcall(function()
                            if getgenv().hitboxEnabled then
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
                    
                    -- Покостная проверка видимости и отрисовка SelectionBox
                    for _, child in pairs(model:GetChildren()) do
                        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                            local sBox = child:FindFirstChild("PartOutline")
                            if not sBox and getgenv().espEnabled then
                                sBox = Instance.new("SelectionBox")
                                sBox.Name = "PartOutline"
                                sBox.Adornee = child
                                sBox.LineThickness = 0.05
                                sBox.Parent = child
                            end
                            if sBox then
                                sBox.Enabled = getgenv().espEnabled
                                if getgenv().espEnabled then
                                    if isPartVisible(child, model) then
                                        sBox.Color3 = getgenv().partEspColorVisible
                                        sBox.SurfaceTransparency = 1
                                    else
                                        sBox.Color3 = getgenv().partEspColorHidden
                                        sBox.SurfaceTransparency = getgenv().hiddenTransparency -- 40% (0.4) прозрачность
                                    end
                                end
                            end
                        end
                    end
                    
                    local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and getgenv().espEnabled then
                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                        if dist <= getgenv().maxDist then
                            local baseText = game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            txt.TextColor3 = isPartVisible(head, model) and getgenv().partEspColorVisible or getgenv().partEspColorHidden
                            txt.Text = baseText .. " " .. tostring(dist)
                            txt.Visible = true
                        else txt.Visible = false end
                    else txt.Visible = false end
                    task.wait(0.3)
                end
            end)
        end
    end
    
    -- Логика для мин, сейфов, кейсов
    local nameL = string.lower(model.Name)
    if string.find(nameL, "mine") or string.find(nameL, "claymore") or string.find(nameL, "explosive") or string.find(nameL, "растяжка") then
        local triggerPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not triggerPart or triggerPart:FindFirstChild("MineTextGui") then return end
        local bGui = Instance.new("BillboardGui") bGui.Name = "MineTextGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 1.5, 0) bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 0.3 txt.BackgroundColor3 = Color3.fromRGB(15, 15, 15) txt.TextColor3 = Color3.fromRGB(238, 130, 238) txt.TextSize = 12 txt.Font = Enum.Font.SourceSansBold txt.Text = "⚠️ МИНА" txt.Parent = bGui
        local uiCorner = Instance.new("UICorner") uiCorner.CornerRadius = UDim.new(0, 6) uiCorner.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui do
                bGui.Enabled = getgenv().mineEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    if dist <= getgenv().mineMaxDist then txt.Text, txt.Visible = "⚠️ МИНА " .. tostring(dist), true
                    else txt.Visible = false end
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
        return
    end
    local isAurora, isBig, isSafe = model.Name == "AuroraBox", model.Name == "BigBox", string.find(nameL, "safe") or string.find(nameL, "сейф")
    local isDroppedItem = model:IsA("Model") and model:FindFirstChild("Part") and not model:FindFirstChild("Humanoid")
    if isAurora or isBig or isSafe or isDroppedItem then
        local triggerPart = model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
        if not triggerPart or triggerPart:FindFirstChild("LootTextGui") then return end
        local bGui = Instance.new("BillboardGui") bGui.Name = "LootTextGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 120, 0, 25) bGui.StudsOffset = Vector3.new(0, 2, 0) bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 0.4 txt.BackgroundColor3 = Color3.fromRGB(20, 20, 20) txt.TextColor3 = Color3.fromRGB(255, 215, 0) txt.TextSize = 11 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
        local displayName = isAurora and "✨ АВРОРА КЕЙС" or isBig and "🎁 БОЛЬШОЙ КЕЙС" or isSafe and "🗄️ СЕЙФ" or "📦 ПРЕДМЕТ"
        txt.Text = displayName local uiCorner = Instance.new("UICorner") uiCorner.CornerRadius = UDim.new(0, 6) uiCorner.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui do
                bGui.Enabled = getgenv().itemEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    if dist <= getgenv().itemMaxDist then txt.Text, txt.Visible = displayName .. " " .. tostring(dist), true
                    else txt.Visible = false end
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end
workspace.ChildAdded:Connect(applyPartESP)
for _, v in pairs(workspace:GetChildren()) do applyPartESP(v) end
local TargetParent = pcall(function() return gethui() end) and gethui() or game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
if not TargetParent then TargetParent = game:GetService("Players").LocalPlayer.PlayerGui end
if TargetParent:FindFirstChild("GMK_Menu") then TargetParent.GMK_Menu:Destroy() end
local GMK_Menu = Instance.new("ScreenGui") GMK_Menu.Name = "GMK_Menu" GMK_Menu.ResetOnSpawn = false GMK_Menu.Parent = TargetParent
local MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 360, 0, 240) MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120) MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.Visible = false MainFrame.ZIndex = 100 MainFrame.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) MainFrame.Parent = MainFrame
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
local OpenBtn = Instance.new("TextButton") OpenBtn.Size = UDim2.new(0, 60, 0, 35) OpenBtn.Position = UDim2.new(0.5, -30, 0.1, 0) OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) OpenBtn.Text = "GMK" OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150) OpenBtn.TextSize = 14 OpenBtn.Font = Enum.Font.SourceSansBold OpenBtn.Active = true OpenBtn.ZIndex = 500 OpenBtn.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 6) OpenBtn.Parent = OpenBtn
local btnDragging, btnDragStart, btnStartPos
OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then btnDragging = true btnDragStart = input.Position btnStartPos = OpenBtn.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then btnDragging = false end end) end end)
UserInputService.InputChanged:Connect(function(input) if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - btnDragStart OpenBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y) end end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 200, 0, 30) Title.Position = UDim2.new(0, 10, 0, 0) Title.BackgroundTransparency = 1 Title.Text = "GMK MENU" Title.TextColor3 = Color3.fromRGB(0, 255, 150) Title.TextSize = 14 Title.Font = Enum.Font.SourceSansBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.ZIndex = 105 Title.Parent = MainFrame
local TabPanel = Instance.new("Frame") TabPanel.Size = UDim2.new(0, 90, 0, 210) TabPanel.Position = UDim2.new(0, 0, 0, 30) TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22) TabPanel.BorderSizePixel = 0 TabPanel.ZIndex = 105 TabPanel.Parent = MainFrame
local EspTabBtn = Instance.new("TextButton") EspTabBtn.Size = UDim2.new(0, 90, 0, 35) EspTabBtn.Position = UDim2.new(0, 0, 0, 0) EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) EspTabBtn.Text = "ESP" EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) EspTabBtn.Font = Enum.Font.SourceSansBold EspTabBtn.TextSize = 13 EspTabBtn.ZIndex = 110 EspTabBtn.Parent = TabPanel
local AimTabBtn = Instance.new("TextButton") AimTabBtn.Size = UDim2.new(0, 90, 0, 35) AimTabBtn.Position = UDim2.new(0, 0, 0, 35) AimTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22) AimTabBtn.Text = "AIMBOT" AimTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140) AimTabBtn.Font = Enum.Font.SourceSansBold AimTabBtn.TextSize = 13 AimTabBtn.ZIndex = 110 AimTabBtn.Parent = TabPanel
function createToggleObj(text, globalVar, yPos)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 170, 0, 25) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = MainFrame
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 295, 0, yPos + 3) btn.BackgroundColor3 = (getgenv()[globalVar] ~= nil and getgenv()[globalVar]) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.ZIndex = 125 btn.Parent = MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function() if getgenv()[globalVar] ~= nil then getgenv()[globalVar] = not getgenv()[globalVar] btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) end end)
    return lbl, btn
end
function createSliderObj(text, min, max, globalVar, yPos)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 230, 0, 15) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 local currentVal = getgenv()[globalVar] or min lbl.Text = text .. ": " .. tostring(currentVal) lbl.TextColor3 = Color3.fromRGB(180, 190, 180) lbl.TextSize = 11 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = MainFrame
    local slideBar = Instance.new("TextButton") slideBar.Size = UDim2.new(0, 230, 0, 6) slideBar.Position = UDim2.new(0, 105, 0, yPos + 18) slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50) slideBar.Text = "" slideBar.ZIndex = 125 slideBar.Parent = MainFrame
    local fill = Instance.new("Frame") fill.Size = UDim2.new((currentVal - min)/(max - min), 0, 1, 0) fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150) fill.BorderSizePixel = 0 fill.ZIndex = 126 fill.Parent = slideBar
    local isDragging = false
    local function updateSlider(inputObject) local inputPos = inputObject.Position.X local barAbsolutePos = slideBar.AbsolutePosition.X local barAbsoluteSize = slideBar.AbsoluteSize.X local percentage = math.clamp((inputPos - barAbsolutePos) / barAbsoluteSize, 0, 1) local value = math.floor(min + (max - min) * percentage) getgenv()[globalVar] = value lbl.Text = text .. ": " .. tostring(value) fill.Size = UDim2.new(percentage, 0, 1, 0) end
    slideBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true updateSlider(input) end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
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
local function showEspPage(state) eL1.Visible, eB1.Visible, eL2.Visible, eB2.Visible, eL3.Visible, eB3.Visible, eL4.Visible, eB4.Visible = state, state, state, state, state, state, state, state end
local function showAimPage(state) aL1.Visible, aB1.Visible, aL2.Visible, aB2.Visible, aL3.Visible, aB3.Visible, aL4.Visible, aB4.Visible = state, state, state, state, state, state, state, state end
showEspPage(true) showAimPage(false)
EspTabBtn.MouseButton1Click:Connect(function() EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255) AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140) showEspPage(true) showAimPage(false) end)
AimTabBtn.MouseButton1Click:Connect(function() AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255) EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140) showEspPage(false) showAimPage(true) end)
