function applyESP(model)
    local lPlrObj = game:GetService("Players").LocalPlayer
    if not lPlrObj then return end
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlrObj.Name then return end
        local hrp = model.HumanoidRootPart
        local head = model:FindFirstChild("Head")
        local humanoid = model.Humanoid
        local highlight = model:FindFirstChild("MobileESP") or Instance.new("Highlight")
        if not highlight.Parent then highlight.Name = "MobileESP" highlight.Parent = model highlight.FillTransparency = 1 highlight.OutlineTransparency = 0 end
        local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
        if not bGui.Parent then
            bGui.Name = "TextEspGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 3, 0) bGui.Parent = hrp
            local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextSize = 13 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
            task.spawn(function()
                while model and model.Parent and hrp and txt and bGui and highlight do
                    local isCorpse = humanoid.Health <= 0
                    local currentEspState = isCorpse and getgenv().corpseEspEnabled or getgenv().espEnabled
                    highlight.Enabled, bGui.Enabled = currentEspState, currentEspState
                    if head and head:IsA("BasePart") then pcall(function()
                        if getgenv().hitboxEnabled and not isCorpse then
                            head.Size = Vector3.new(getgenv().hitboxSize, getgenv().hitboxSize, getgenv().hitboxSize)
                            head.Transparency = 0.7 head.CanCollide = false
                        else head.Size = Vector3.new(1.2, 1.2, 1.2) head.Transparency = 0 head.CanCollide = true end
                    end) end
                    local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and currentEspState then
                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                        if dist <= getgenv().maxDist then
                            local baseText = isCorpse and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            local color = isCorpse and Color3.fromRGB(150, 150, 150) or isPlayerVisible(model) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor, txt.TextColor3 = color, color
                            txt.Text, txt.Visible, highlight.Enabled = baseText .. " " .. tostring(dist), true, true
                        else txt.Visible, highlight.Enabled = false, false end
                    else txt.Visible, highlight.Enabled = false, false end
                    task.wait(0.3)
                end
            end)
        end
    end
    local nameL = string.lower(model.Name)
    if string.find(nameL, "mine") or string.find(nameL, "claymore") or string.find(nameL, "explosive") or string.find(nameL, "растяжка") then
        local triggerPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not triggerPart or triggerPart:FindFirstChild("MineTextGui") then return end
        local bGui = Instance.new("BillboardGui") bGui.Name = "MineTextGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 1.5, 0) bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 0.3 txt.BackgroundColor3 = Color3.fromRGB(15, 15, 15) txt.TextColor3 = Color3.fromRGB(238, 130, 238) txt.TextSize = 12 txt.Font = Enum.Font.SourceSansBold txt.Text = "⚠️ МИНА" txt.Parent = bGui
        Instance.new("UICorner").CornerRadius = UDim.new(0, 6) txt.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui do
                bGui.Enabled = getgenv().mineEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    txt.Text, txt.Visible = "⚠️ МИНА " .. tostring(dist), (dist <= getgenv().mineMaxDist)
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
        txt.Text = displayName Instance.new("UICorner").CornerRadius = UDim.new(0, 6) txt.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui do
                bGui.Enabled = getgenv().itemEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    txt.Text, txt.Visible = displayName .. " " .. tostring(dist), (dist <= getgenv().itemMaxDist)
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end
workspace.ChildAdded:Connect(applyESP)
for _, v in pairs(workspace:GetChildren()) do applyESP(v) end
function isPlayerVisible(character)
    local camObj = game:GetService("Workspace").CurrentCamera
    if not character or not camObj then return false end
    local origin = camObj.CFrame.Position
    local head = character:FindFirstChild("Head", true)
    local torso = character:FindFirstChild("UpperTorso", true) or character:FindFirstChild("Torso", true)
    local hrp = character:FindFirstChild("HumanoidRootPart", true)
    if checkPointVisible(origin, head, character) or checkPointVisible(origin, torso, character) or checkPointVisible(origin, hrp, character) then return true end
    return false
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
                if (myHrp.Position - hrp.Position).Magnitude <= getgenv().aimbotMaxDist then
                    local targetPart = model:FindFirstChild("Head", true) or hrp
                    if targetPart and isPlayerVisible(model) then
                        local screenPosition, onScreen = camObj:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local mousePos = Vector2.new(camObj.ViewportSize.X / 2, camObj.ViewportSize.Y / 2)
                            local distanceToMouse = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude
                            if distanceToMouse < maxMouseDistance then maxMouseDistance = distanceToMouse closestTarget = targetPart end
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
        if getgenv().aimbotEnabled then FOVCircle.Visible = getgenv().fovCircleVisible else FOVCircle.Visible = false end
        FOVCircle.Radius = getgenv().fovCircleRadius
        FOVCircle.Color = Color3.fromRGB(0, 255, 120)
        FOVCircle.Position = Vector2.new(camObj.ViewportSize.X / 2, camObj.ViewportSize.Y / 2)
    end
    if getgenv().aimbotEnabled then
        local target = getClosestTarget()
        if target then camObj.CFrame = camObj.CFrame:Lerp(CFrame.new(camObj.CFrame.Position, target.Position), getgenv().aimbotSmoothness) end
    end
end)
function applyESP(model)
    local lPlrObj = game:GetService("Players").LocalPlayer
    if not lPlrObj then return end
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlrObj.Name then return end
        local hrp = model.HumanoidRootPart
        local head = model:FindFirstChild("Head")
        local humanoid = model.Humanoid
        local highlight = model:FindFirstChild("MobileESP") or Instance.new("Highlight")
        if not highlight.Parent then highlight.Name = "MobileESP" highlight.Parent = model highlight.FillTransparency = 1 highlight.OutlineTransparency = 0 end
        local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
        if not bGui.Parent then
            bGui.Name = "TextEspGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 3, 0) bGui.Parent = hrp
            local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextSize = 13 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
            task.spawn(function()
                while model and model.Parent and hrp and txt and bGui and highlight do
                    local isCorpse = humanoid.Health <= 0
                    local currentEspState = isCorpse and getgenv().corpseEspEnabled or getgenv().espEnabled
                    highlight.Enabled, bGui.Enabled = currentEspState, currentEspState
                    if head and head:IsA("BasePart") then pcall(function()
                        if getgenv().hitboxEnabled and not isCorpse then
                            head.Size = Vector3.new(getgenv().hitboxSize, getgenv().hitboxSize, getgenv().hitboxSize)
                            head.Transparency = 0.7 head.CanCollide = false
                        else head.Size = Vector3.new(1.2, 1.2, 1.2) head.Transparency = 0 head.CanCollide = true end
                    end) end
                    local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and currentEspState then
                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                        if dist <= getgenv().maxDist then
                            local baseText = isCorpse and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            local color = isCorpse and Color3.fromRGB(150, 150, 150) or isPlayerVisible(model) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor, txt.TextColor3 = color, color
                            txt.Text, txt.Visible, highlight.Enabled = baseText .. " " .. tostring(dist), true, true
                        else txt.Visible, highlight.Enabled = false, false end
                    else txt.Visible, highlight.Enabled = false, false end
                    task.wait(0.3)
                end
            end)
        end
    end
    local nameL = string.lower(model.Name)
    if string.find(nameL, "mine") or string.find(nameL, "claymore") or string.find(nameL, "explosive") or string.find(nameL, "растяжка") then
        local triggerPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not triggerPart or triggerPart:FindFirstChild("MineTextGui") then return end
        local bGui = Instance.new("BillboardGui") bGui.Name = "MineTextGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 1.5, 0) bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 0.3 txt.BackgroundColor3 = Color3.fromRGB(15, 15, 15) txt.TextColor3 = Color3.fromRGB(238, 130, 238) txt.TextSize = 12 txt.Font = Enum.Font.SourceSansBold txt.Text = "⚠️ МИНА" txt.Parent = bGui
        Instance.new("UICorner").CornerRadius = UDim.new(0, 6) txt.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui do
                bGui.Enabled = getgenv().mineEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    txt.Text, txt.Visible = "⚠️ МИНА " .. tostring(dist), (dist <= getgenv().mineMaxDist)
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
        txt.Text = displayName Instance.new("UICorner").CornerRadius = UDim.new(0, 6) txt.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui do
                bGui.Enabled = getgenv().itemEspEnabled
                local myHrp = lPlrObj.Character and lPlrObj.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    txt.Text, txt.Visible = displayName .. " " .. tostring(dist), (dist <= getgenv().itemMaxDist)
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end
workspace.ChildAdded:Connect(applyESP)
for _, v in pairs(workspace:GetChildren()) do applyESP(v) end

local TargetParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("GMK_Menu") then TargetParent.GMK_Menu:Destroy() end
local GMK_Menu = Instance.new("ScreenGui") GMK_Menu.Name = "GMK_Menu" GMK_Menu.ResetOnSpawn = false GMK_Menu.Parent = TargetParent
local MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 360, 0, 240) MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120) MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) MainFrame.Active = true MainFrame.Visible = false MainFrame.ZIndex = 100 MainFrame.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) MainFrame.Parent = MainFrame
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
local OpenBtn = Instance.new("TextButton") OpenBtn.Size = UDim2.new(0, 65, 0, 30) OpenBtn.Position = UDim2.new(0, 120, 0, 45) OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) OpenBtn.Text = "GMK" OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150) OpenBtn.TextSize = 14 OpenBtn.Font = Enum.Font.SourceSansBold OpenBtn.Active = true OpenBtn.ZIndex = 500 OpenBtn.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 6) OpenBtn.Parent = OpenBtn
local btnDragging, btnDragStart, btnStartPos
OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then btnDragging = true btnDragStart = input.Position btnStartPos = OpenBtn.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then btnDragging = false end end) end end)
UserInputService.InputChanged:Connect(function(input) if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - btnDragStart OpenBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y) end end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 200, 0, 30) Title.Position = UDim2.new(0, 10, 0, 0) Title.BackgroundTransparency = 1 Title.Text = "GMK MENU" Title.TextColor3 = Color3.fromRGB(0, 255, 150) Title.TextSize = 14 Title.Font = Enum.Font.SourceSansBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.ZIndex = 105 Title.Parent = MainFrame
local TabPanel = Instance.new("Frame") TabPanel.Size = UDim2.new(0, 90, 0, 210) TabPanel.Position = UDim2.new(0, 0, 0, 30) TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22) TabPanel.BorderSizePixel = 0 TabPanel.ZIndex = 105 TabPanel.Parent = MainFrame
local EspTabBtn = Instance.new("TextButton") EspTabBtn.Size = UDim2.new(0, 90, 0, 35) EspTabBtn.Position = UDim2.new(0, 0, 0, 0) EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) EspTabBtn.Text = "ESP" EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) EspTabBtn.Font = Enum.Font.SourceSansBold EspTabBtn.TextSize = 13 EspTabBtn.ZIndex = 110 EspTabBtn.Parent = TabPanel
local AimTabBtn = Instance.new("TextButton") AimTabBtn.Size = UDim2.new(0, 90, 0, 35) AimTabBtn.Position = UDim2.new(0, 0, 0, 35) AimTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22) AimTabBtn.Text = "COMBAT" AimTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140) AimTabBtn.Font = Enum.Font.SourceSansBold AimTabBtn.TextSize = 13 AimTabBtn.ZIndex = 110 AimTabBtn.Parent = TabPanel
local activeObjects = {}
function clearRightPanel() for _, obj in pairs(activeObjects) do obj:Destroy() end activeObjects = {} end
function createToggle(text, globalVar, yPos, callback)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 170, 0, 25) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = MainFrame
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 295, 0, yPos + 3) btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.ZIndex = 125 btn.Parent = MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function() getgenv()[globalVar] = not getgenv()[globalVar] btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) if callback then callback(getgenv()[globalVar]) end end)
    table.insert(activeObjects, lbl) table.insert(activeObjects, btn)
    return lbl, btn
end
function createSlider(text, min, max, globalVar, yPos)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 230, 0, 15) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. tostring(getgenv()[globalVar]) lbl.TextColor3 = Color3.fromRGB(180, 190, 180) lbl.TextSize = 11 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = MainFrame
    local slideBar = Instance.new("TextButton") slideBar.Size = UDim2.new(0, 230, 0, 6) slideBar.Position = UDim2.new(0, 105, 0, yPos + 18) slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50) slideBar.Text = "" slideBar.ZIndex = 125 slideBar.Parent = MainFrame
    local fill = Instance.new("Frame") fill.Size = UDim2.new((getgenv()[globalVar] - min)/(max - min), 0, 1, 0) fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150) fill.BorderSizePixel = 0 fill.ZIndex = 126 fill.Parent = slideBar
    local isDragging = false
    local function updateSlider(inputObject)
        local percentage = math.clamp((inputObject.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percentage) getgenv()[globalVar] = value lbl.Text = text .. ": " .. tostring(value) fill.Size = UDim2.new(percentage, 0, 1, 0)
    end
    slideBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true updateSlider(input) end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
    table.insert(activeObjects, lbl) table.insert(activeObjects, slideBar)
    return lbl, slideBar
end
function openEspTab()
    clearRightPanel()
    createToggle("Включить ESP (Игроки и Боты)", "espEnabled", 35)
    createToggle("ESP на Лут (Сейфы/Кейсы)", "itemEspEnabled", 65)
    createToggle("ESP на Мины и Растяжки", "mineEspEnabled", 95)
    createToggle("ESP на Трупы игроков", "corpseEspEnabled", 125)
end
function openCombatTab()
    clearRightPanel()
    local aimSubObjects = {}
    local function toggleAimSettings(state) for _, obj in pairs(aimSubObjects) do obj.Visible = state end end
    createToggle("Включить Sentinel Аимбот", "aimbotEnabled", 35, function(state) toggleAimSettings(state) end)
    local al1, ab1 = createSlider("Макс. Дистанция Аима", 1, 700, "aimbotMaxDist", 65)
    local al2, ab2 = createToggle("Показывать FOV круг", "fovCircleVisible", 100)
    local al3, ab3 = createSlider("Радиус FOV круга", 1, 150, "fovCircleRadius", 130)
    table.insert(aimSubObjects, al1) table.insert(aimSubObjects, ab1) table.insert(aimSubObjects, al2) table.insert(aimSubObjects, ab2) table.insert(aimSubObjects, al3) table.insert(aimSubObjects, ab3)
    toggleAimSettings(getgenv().aimbotEnabled)
    local hitboxSubObjects = {}
    local function toggleHitboxSettings(state) for _, obj in pairs(hitboxSubObjects) do obj.Visible = state end end
    createToggle("Увеличение хитбокса головы", "hitboxEnabled", 170, function(state) toggleHitboxSettings(state) end)
    local hl1, hb1 = createSlider("Размер хитбокса головы", 2, 5, "hitboxSize", 195)
    table.insert(hitboxSubObjects, hl1) table.insert(hitboxSubObjects, hb1)
    toggleHitboxSettings(getgenv().hitboxEnabled)
end
openEspTab()
EspTabBtn.MouseButton1Click:Connect(function() EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255) AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140) openEspTab() end)
AimTabBtn.MouseButton1Click:Connect(function() AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255) EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140) openCombatTab() end)
