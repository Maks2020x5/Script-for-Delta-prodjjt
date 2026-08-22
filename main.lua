local lPlr = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera 

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
local direction = part.Position - origin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {lPlr.Character, character, camera}
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
local origin = camera.CFrame.Position
local head = character:FindFirstChild("Head", true)
local torso = character:FindFirstChild("UpperTorso", true) or character:FindFirstChild("Torso", true)
local hrp = character:FindFirstChild("HumanoidRootPart", true)
if checkPointVisible(origin, head, character) or checkPointVisible(origin, torso, character) or checkPointVisible(origin, hrp, character) then
return true
end
return false
endlocal function getClosestTarget()
local closestTarget = nil
local maxMouseDistance = getgenv().fovCircleRadius
local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart", true)
if not myHrp then return nil end 

for _, model in pairs(game.Workspace:GetChildren()) do
if model:FindFirstChild("Humanoid", true) and model:FindFirstChild("HumanoidRootPart", true) and model.Name ~= lPlr.Name then
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
local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
local headPos, _ = camera:WorldToViewportPoint(head.Position)
local torsoPos, _ = camera:WorldToViewportPoint(torso.Position)
local distHead = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
local distTorso = (Vector2.new(torsoPos.X, torsoPos.Y) - mousePos).Magnitude
targetPart = (distHead < distTorso) and head or torso
else
targetPart = head or hrp
end
end
if targetPart and isPlayerVisible(model) then
local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
if onScreen then
local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
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
if FOVCircle then
FOVCircle.Visible = getgenv().fovCircleVisible
FOVCircle.Radius = getgenv().fovCircleRadius
FOVCircle.Color = Color3.fromRGB(0, 255, 120)
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end
if getgenv().aimbotEnabled then
local target = getClosestTarget()
if target then
local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
camera.CFrame = camera.CFrame:Lerp(targetCFrame, getgenv().aimbotSmoothness)
end
end
end)local function applyESP(model)
if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
if model.Name == lPlr.Name then return end
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
            local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
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
local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
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
local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
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
for _, v in pairs(workspace:GetChildren()) do applyESP(v) endlocal CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("GMK_Menu") then CoreGui.GMK_Menu:Destroy() end 

local GMK_Menu = Instance.new("ScreenGui")
GMK_Menu.Name = "GMK_Menu"
GMK_Menu.Parent = CoreGui 

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 280)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 10) MainFrame.Parent = MainFrame 

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  GMK GUI | DELTA & XENO"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame 

local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 100, 1, -35)
TabPanel.Position = UDim2.new(0, 0, 0, 35)
TabPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TabPanel.BorderSizePixel = 0
TabPanel.Parent = MainFrame 

local EspPage = Instance.new("ScrollingFrame")
EspPage.Size = UDim2.new(1, -110, 1, -45)
EspPage.Position = UDim2.new(0, 105, 0, 40)
EspPage.BackgroundTransparency = 1
EspPage.CanvasSize = UDim2.new(0, 0, 0, 400)
EspPage.ScrollBarThickness = 4
EspPage.Visible = true
EspPage.Parent = MainFrame 

local AimPage = Instance.new("ScrollingFrame")
AimPage.Size = EspPage.Size
AimPage.Position = EspPage.Position
AimPage.BackgroundTransparency = 1
AimPage.CanvasSize = UDim2.new(0, 0, 0, 400)
AimPage.ScrollBarThickness = 4
AimPage.Visible = false
AimPage.Parent = MainFrame 

local UIList1 = Instance.new("UIListLayout") UIList1.Padding = UDim.new(0,8) UIList1.Parent = EspPage
local UIList2 = Instance.new("UIListLayout") UIList2.Padding = UDim.new(0,8) UIList2.Parent = AimPage 

local function createToggle(parent, text, globalVar)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -10, 0, 35)
frame.BackgroundTransparency = 1
frame.Parent = parent
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 45, 0, 22)
btn.Position = UDim2.new(1, -50, 0.5, -11)
btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 65)
btn.Text = ""
btn.Parent = frame
Instance.new("UICorner").CornerRadius = UDim.new(0,6) btn.Parent = btn
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, -60, 1, 0)
lbl.Text = "  " .. text
lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
lbl.TextSize = 14
lbl.Font = Enum.Font.SourceSans
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.BackgroundTransparency = 1
lbl.Parent = frame
btn.MouseButton1Click:Connect(function()
getgenv()[globalVar] = not getgenv()[globalVar]
btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 65)
end)
end 

local function createSlider(parent, text, min, max, globalVar)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -10, 0, 45)
frame.BackgroundTransparency = 1
frame.Parent = parent
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, 0, 0, 20)
lbl.Text = "  " .. text .. ": " .. tostring(getgenv()[globalVar])
lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
lbl.TextSize = 13
lbl.Font = Enum.Font.SourceSans
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.BackgroundTransparency = 1
lbl.Parent = frame
local slideBar = Instance.new("TextButton")
slideBar.Size = UDim2.new(1, -20, 0, 8)
slideBar.Position = UDim2.new(0, 10, 0, 25)
slideBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
slideBar.Text = ""
slideBar.Parent = frame
local fill = Instance.new("Frame")
fill.Size = UDim2.new((getgenv()[globalVar] - min)/(max - min), 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
fill.BorderSizePixel = 0
fill.Parent = slideBar 

local isDragging = false
local function updateSlider(inputObject)
local inputPos = inputObject.Position.X
local barAbsolutePos = slideBar.AbsolutePosition.X
local barAbsoluteSize = slideBar.AbsoluteSize.X
local percentage = math.clamp((inputPos - barAbsolutePos) / barAbsoluteSize, 0, 1)
local value = math.floor(min + (max - min) * percentage)
getgenv()[globalVar] = value
lbl.Text = "  " .. text .. ": " .. tostring(value)
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
end 

local EspTabBtn = Instance.new("TextButton")
EspTabBtn.Size = UDim2.new(1, 0, 0, 40)
EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
EspTabBtn.Text = "ESP"
EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspTabBtn.Font = Enum.Font.SourceSansBold
EspTabBtn.Parent = TabPanel 

local AimTabBtn = Instance.new("TextButton")
AimTabBtn.Size = UDim2.new(1, 0, 0, 40)
AimTabBtn.Position = UDim2.new(0, 0, 0, 40)
AimTabBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
AimTabBtn.Text = "AIMBOT"
AimTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
AimTabBtn.Font = Enum.Font.SourceSansBold
AimTabBtn.Parent = TabPanel 

EspTabBtn.MouseButton1Click:Connect(function()
EspPage.Visible = true AimPage.Visible = false
EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) EspTabBtn.TextColor3 = Color3.fromRGB(255,255,255)
AimTabBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18) AimTabBtn.TextColor3 = Color3.fromRGB(150,150,150)
end) 

AimTabBtn.MouseButton1Click:Connect(function()
EspPage.Visible = false AimPage.Visible = true
AimTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) AimTabBtn.TextColor3 = Color3.fromRGB(255,255,255)
EspTabBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18) EspTabBtn.TextColor3 = Color3.fromRGB(150,150,150)
end) 

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner").CornerRadius = UDim.new(0,6) CloseBtn.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() GMK_Menu:Destroy() end) 

createToggle(EspPage, "Включить ESP игрока", "espEnabled")
createSlider(EspPage, "Дистанция ESP игрока", 100, 2000, "maxDist")
createToggle(EspPage, "Увеличить Хитбоксы головы", "hitboxEnabled")
createToggle(EspPage, "ESP Мины / Растяжки", "mineEspEnabled")
createSlider(EspPage, "Дистанция до Мин", 50, 500, "mineMaxDist")
createToggle(EspPage, "ESP Сейфы и Кейсы", "itemEspEnabled")
createSlider(EspPage, "Дистанция до Лута", 50, 1000, "itemMaxDist") 

createToggle(AimPage, "Включить Sentinel Аим", "aimbotEnabled")
createSlider(AimPage, "Дистанция работы Аима", 10, 500, "aimbotMaxDist") 

local partFrame = Instance.new("Frame")
partFrame.Size = UDim2.new(1, -10, 0, 35)
partFrame.BackgroundTransparency = 1
partFrame.Parent = AimPage
local partLbl = Instance.new("TextLabel")
partLbl.Size = UDim2.new(1, -120, 1, 0)
partLbl.Text = "  Цель аима: " .. getgenv().aimbotPartMode
partLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
partLbl.TextSize = 14
partLbl.BackgroundTransparency = 1
partLbl.TextXAlignment = Enum.TextXAlignment.Left
partLbl.Parent = partFrame
local partBtn = Instance.new("TextButton")
partBtn.Size = UDim2.new(0, 100, 0, 25)
partBtn.Position = UDim2.new(1, -105, 0.5, -12)
partBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
partBtn.Text = "ИЗМЕНИТЬ"
partBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
partBtn.Font = Enum.Font.SourceSansBold
partBtn.Parent = partFrame
Instance.new("UICorner").CornerRadius = UDim.new(0,6) partBtn.Parent = partBtn 

partBtn.MouseButton1Click:Connect(function()
if getgenv().aimbotPartMode == "Closest" then getgenv().aimbotPartMode = "Head"
elseif getgenv().aimbotPartMode == "Head" then getgenv().aimbotPartMode = "Torso"
else getgenv().aimbotPartMode = "Closest" end
partLbl.Text = "  Цель аима: " .. getgenv().aimbotPartMode
end) 

createToggle(AimPage, "Показывать круг FOV", "fovCircleVisible")
createSlider(AimPage, "Радиус круга аима", 30, 400, "fovCircleRadius")
