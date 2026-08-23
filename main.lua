getgenv().espEnabled = false
getgenv().itemEspEnabled = false
getgenv().mineEspEnabled = false
getgenv().corpseEspEnabled = false
getgenv().aimbotEnabled = false
getgenv().aimbotMaxDist = 300
getgenv().fovCircleVisible = false
getgenv().fovCircleRadius = 120
getgenv().hitboxEnabled = false
getgenv().hitboxSize = 2

local lPlr = game:GetService("Players").LocalPlayer
getgenv().GMK_TargetParent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui") or lPlr:WaitForChild("PlayerGui")
if getgenv().GMK_TargetParent:FindFirstChild("GMK_Menu") then getgenv().GMK_TargetParent.GMK_Menu:Destroy() end

getgenv().GMK_MenuGui = Instance.new("ScreenGui")
getgenv().GMK_MenuGui.Name = "GMK_Menu"
getgenv().GMK_MenuGui.ResetOnSpawn = false
getgenv().GMK_MenuGui.Parent = getgenv().GMK_TargetParent

getgenv().GMK_MainFrame = Instance.new("Frame")
getgenv().GMK_MainFrame.Size = UDim2.new(0, 360, 0, 240)
getgenv().GMK_MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
getgenv().GMK_MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
getgenv().GMK_MainFrame.Active = true
getgenv().GMK_MainFrame.Visible = false
getgenv().GMK_MainFrame.ZIndex = 100
getgenv().GMK_MainFrame.Parent = getgenv().GMK_MenuGui
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) getgenv().GMK_MainFrame.Parent = getgenv().GMK_MainFrame

getgenv().GMK_ActiveObjects = {}

getgenv().GMK_ClearPanel = function()
    for _, obj in pairs(getgenv().GMK_ActiveObjects) do obj:Destroy() end
    getgenv().GMK_ActiveObjects = {}
end

getgenv().GMK_CreateToggle = function(text, globalVar, yPos, callback)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 170, 0, 25) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = getgenv().GMK_MainFrame
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 295, 0, yPos + 3) btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.ZIndex = 125 btn.Parent = getgenv().GMK_MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function()
        getgenv()[globalVar] = not getgenv()[globalVar]
        btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60)
        if callback then callback(getgenv()[globalVar]) end
    end)
    table.insert(getgenv().GMK_ActiveObjects, lbl) table.insert(getgenv().GMK_ActiveObjects, btn)
end

getgenv().GMK_CreateSlider = function(text, min, max, globalVar, yPos, callback)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 230, 0, 15) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. tostring(getgenv()[globalVar]) lbl.TextColor3 = Color3.fromRGB(180, 190, 180) lbl.TextSize = 11 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = getgenv().GMK_MainFrame
    local slideBar = Instance.new("TextButton") slideBar.Size = UDim2.new(0, 230, 0, 6) slideBar.Position = UDim2.new(0, 105, 0, yPos + 18) slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50) slideBar.Text = "" slideBar.ZIndex = 125 slideBar.Parent = getgenv().GMK_MainFrame
    local fill = Instance.new("Frame") fill.Size = UDim2.new((getgenv()[globalVar] - min)/(max - min), 0, 1, 0) fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150) fill.BorderSizePixel = 0 fill.ZIndex = 126 fill.Parent = slideBar
    local isDragging = false
    local function updateSlider(inputObject)
        local percentage = math.clamp((inputObject.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percentage) getgenv()[globalVar] = value
        lbl.Text = text .. ": " .. tostring(value) fill.Size = UDim2.new(percentage, 0, 1, 0)
        if callback then callback(value) end
    end
    slideBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true updateSlider(input) end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
    table.insert(getgenv().GMK_ActiveObjects, lbl) table.insert(getgenv().GMK_ActiveObjects, slideBar)
end
local dragging, dragInput, dragStart, startPos
getgenv().GMK_MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = getgenv().GMK_MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
getgenv().GMK_MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        getgenv().GMK_MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 65, 0, 30)
OpenBtn.Position = UDim2.new(0, 120, 0, 45)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenBtn.Text = "GMK"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.TextSize = 14
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Active = true
OpenBtn.ZIndex = 500
OpenBtn.Parent = getgenv().GMK_MenuGui
Instance.new("UICorner").CornerRadius = UDim.new(0, 6) OpenBtn.Parent = OpenBtn

local bDrag, bStart, bPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bDrag = true bStart = input.Position bPos = OpenBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then bDrag = false end end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if bDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - bStart
        OpenBtn.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + delta.X, bPos.Y.Scale, bPos.Y.Offset + delta.Y)
    end
end)
OpenBtn.MouseButton1Click:Connect(function() getgenv().GMK_MainFrame.Visible = not getgenv().GMK_MainFrame.Visible end)

local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 200, 0, 30) Title.Position = UDim2.new(0, 10, 0, 0) Title.BackgroundTransparency = 1 Title.Text = "GMK MENU" Title.TextColor3 = Color3.fromRGB(0, 255, 150) Title.TextSize = 14 Title.Font = Enum.Font.SourceSansBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.ZIndex = 105 Title.Parent = getgenv().GMK_MainFrame
local TabPanel = Instance.new("Frame") TabPanel.Size = UDim2.new(0, 90, 0, 210) TabPanel.Position = UDim2.new(0, 0, 0, 30) TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22) TabPanel.BorderSizePixel = 0 TabPanel.ZIndex = 105 TabPanel.Parent = getgenv().GMK_MainFrame
local EspTabBtn = Instance.new("TextButton") EspTabBtn.Size = UDim2.new(0, 90, 0, 35) EspTabBtn.Position = UDim2.new(0, 0, 0, 0) EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) EspTabBtn.Text = "ESP" EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) EspTabBtn.Font = Enum.Font.SourceSansBold EspTabBtn.TextSize = 13 EspTabBtn.ZIndex = 110 EspTabBtn.Parent = TabPanel
local AimTabBtn = Instance.new("TextButton") AimTabBtn.Size = UDim2.new(0, 90, 0, 35) AimTabBtn.Position = UDim2.new(0, 0, 0, 35) AimTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22) AimTabBtn.Text = "COMBAT" AimTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140) AimTabBtn.Font = Enum.Font.SourceSansBold AimTabBtn.TextSize = 13 AimTabBtn.ZIndex = 110 AimTabBtn.Parent = TabPanel

getgenv().GMK_OpenEspTab = function()
    getgenv().GMK_ClearPanel()
    getgenv().GMK_CreateToggle("Включить ESP на Игроков / Ботов", "espEnabled", 35)
    getgenv().GMK_CreateToggle("Включить ESP на Лут", "itemEspEnabled", 65)
    getgenv().GMK_CreateToggle("Включить ESP на Мины", "mineEspEnabled", 95)
    getgenv().GMK_CreateToggle("Включить ESP на Трупы типов", "corpseEspEnabled", 125)
end

getgenv().GMK_OpenCombatTab = function()
    getgenv().GMK_ClearPanel()
    local aimSub = {}
    local function toggleAim(state) for _, o in pairs(aimSub) do o.Visible = state end end
    getgenv().GMK_CreateToggle("Включить Sentinel Аимбот", "aimbotEnabled", 35, toggleAim)
    local al1, ab1 = getgenv().GMK_CreateSlider("Макс. Дистанция Аима", 1, 700, "aimbotMaxDist", 65)
    local al2, ab2 = getgenv().GMK_CreateToggle("Показывать FOV круг", "fovCircleVisible", 100)
    local al3, ab3 = getgenv().GMK_CreateSlider("Радиус FOV круга", 1, 150, "fovCircleRadius", 130)
    table.insert(aimSub, al1) table.insert(aimSub, ab1) table.insert(aimSub, al2) table.insert(aimSub, ab2) table.insert(aimSub, al3) table.insert(aimSub, ab3)
    toggleAim(getgenv().aimbotEnabled)
    
    local hbSub = {}
    local function toggleHb(state) for _, o in pairs(hbSub) do o.Visible = state end end
    getgenv().GMK_CreateToggle("Увеличение хитбокса головы", "hitboxEnabled", 170, toggleHb)
    local hl1, hb1 = getgenv().GMK_CreateSlider("Размер хитбокса головы", 2, 5, "hitboxSize", 195)
    table.insert(hbSub, hl1) table.insert(hbSub, hb1)
    toggleHb(getgenv().hitboxEnabled)
end

getgenv().GMK_OpenEspTab()
EspTabBtn.MouseButton1Click:Connect(function()
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255)
    AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140)
    getgenv().GMK_OpenEspTab()
end)
AimTabBtn.MouseButton1Click:Connect(function()
    AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255)
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140)
    getgenv().GMK_OpenCombatTab()
end)
