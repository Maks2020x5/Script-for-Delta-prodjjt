local TargetParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("GMK_Menu") then TargetParent.GMK_Menu:Destroy() end

local GMK_Menu = Instance.new("ScreenGui")
GMK_Menu.Name = "GMK_Menu"
GMK_Menu.ResetOnSpawn = false
GMK_Menu.Parent = TargetParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.ZIndex = 100
MainFrame.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) MainFrame.Parent = MainFrame

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
OpenBtn.Parent = GMK_Menu
Instance.new("UICorner").CornerRadius = UDim.new(0, 6) OpenBtn.Parent = OpenBtn

local btnDragging, btnDragStart, btnStartPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true btnDragStart = input.Position btnStartPos = OpenBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then btnDragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        OpenBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 200, 0, 30) Title.Position = UDim2.new(0, 10, 0, 0) Title.BackgroundTransparency = 1 Title.Text = "GMK MENU" Title.TextColor3 = Color3.fromRGB(0, 255, 150) Title.TextSize = 14 Title.Font = Enum.Font.SourceSansBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.ZIndex = 105 Title.Parent = MainFrame
local TabPanel = Instance.new("Frame") TabPanel.Size = UDim2.new(0, 90, 0, 210) TabPanel.Position = UDim2.new(0, 0, 0, 30) TabPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22) TabPanel.BorderSizePixel = 0 TabPanel.ZIndex = 105 TabPanel.Parent = MainFrame
local EspTabBtn = Instance.new("TextButton") EspTabBtn.Size = UDim2.new(0, 90, 0, 35) EspTabBtn.Position = UDim2.new(0, 0, 0, 0) EspTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30) EspTabBtn.Text = "ESP" EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) EspTabBtn.Font = Enum.Font.SourceSansBold EspTabBtn.TextSize = 13 EspTabBtn.ZIndex = 110 EspTabBtn.Parent = TabPanel
local AimTabBtn = Instance.new("TextButton") AimTabBtn.Size = UDim2.new(0, 90, 0, 35) AimTabBtn.Position = UDim2.new(0, 0, 0, 35) AimTabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22) AimTabBtn.Text = "COMBAT" AimTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140) AimTabBtn.Font = Enum.Font.SourceSansBold AimTabBtn.TextSize = 13 AimTabBtn.ZIndex = 110 AimTabBtn.Parent = TabPanel

local activeObjects = {}
function clearRightPanel() for _, obj in pairs(activeObjects) do obj:Destroy() end activeObjects = {} end

function createToggle(text, startState, yPos, callback)
    local state = startState
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 170, 0, 25) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = MainFrame
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 295, 0, yPos + 3) btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.ZIndex = 125 btn.Parent = MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60)
        if callback then callback(state) end
    end)
    table.insert(activeObjects, lbl) table.insert(activeObjects, btn)
    return lbl, btn
end

function createSlider(text, min, max, startVal, yPos, callback)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 230, 0, 15) lbl.Position = UDim2.new(0, 105, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. tostring(startVal) lbl.TextColor3 = Color3.fromRGB(180, 190, 180) lbl.TextSize = 11 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 125 lbl.Parent = MainFrame
    local slideBar = Instance.new("TextButton") slideBar.Size = UDim2.new(0, 230, 0, 6) slideBar.Position = UDim2.new(0, 105, 0, yPos + 18) slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50) slideBar.Text = "" slideBar.ZIndex = 125 slideBar.Parent = MainFrame
    local fill = Instance.new("Frame") fill.Size = UDim2.new((startVal - min)/(max - min), 0, 1, 0) fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150) fill.BorderSizePixel = 0 fill.ZIndex = 126 fill.Parent = slideBar
    local isDragging = false
    local function updateSlider(inputObject)
        local percentage = math.clamp((inputObject.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percentage)
        lbl.Text = text .. ": " .. tostring(value) fill.Size = UDim2.new(percentage, 0, 1, 0)
        if callback then callback(value) end
    end
    slideBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true updateSlider(input) end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
    table.insert(activeObjects, lbl) table.insert(activeObjects, slideBar)
    return lbl, slideBar
end
function openEspTab()
    clearRightPanel()
    createToggle("Включить ESP на Игроков / Ботов", true, 35, function(s) print("ESP игрока:", s) end)
    createToggle("Включить ESP на Лут", true, 65, function(s) print("ESP лута:", s) end)
    createToggle("Включить ESP на Мины", true, 95, function(s) print("ESP мин:", s) end)
    createToggle("Включить ESP на Трупы типов", true, 125, function(s) print("ESP трупов:", s) end)
end

function openCombatTab()
    clearRightPanel()
    local aimSubObjects = {}
    local function toggleAimSettings(state) for _, obj in pairs(aimSubObjects) do obj.Visible = state end end
    createToggle("Включить Sentinel Аимбот", false, 35, function(state) toggleAimSettings(state) end)
    local al1, ab1 = createSlider("Макс. Дистанция Аима", 1, 700, 300, 65, function(v) print("Дистанция аима:", v) end)
    local al2, ab2 = createToggle("Показывать FOV круг", false, 100, function(s) print("Показ FOV:", s) end)
    local al3, ab3 = createSlider("Радиус FOV круга", 1, 150, 120, 130, function(v) print("Радиус FOV:", v) end)
    table.insert(aimSubObjects, al1) table.insert(aimSubObjects, ab1) table.insert(aimSubObjects, al2) table.insert(aimSubObjects, ab2) table.insert(aimSubObjects, al3) table.insert(aimSubObjects, ab3)
    toggleAimSettings(false)
    
    local hitboxSubObjects = {}
    local function toggleHitboxSettings(state) for _, obj in pairs(hitboxSubObjects) do obj.Visible = state end end
    createToggle("Увеличение хитбокса головы", false, 170, function(state) toggleHitboxSettings(state) end)
    local hl1, hb1 = createSlider("Размер хитбокса головы", 2, 5, 2, 195, function(v) print("Размер хитбокса:", v) end)
    table.insert(hitboxSubObjects, hl1) table.insert(hitboxSubObjects, hb1)
    toggleHitboxSettings(false)
end

openEspTab()
EspTabBtn.MouseButton1Click:Connect(function()
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255)
    AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140)
    openEspTab()
end)
AimTabBtn.MouseButton1Click:Connect(function()
    AimTabBtn.BackgroundColor3, AimTabBtn.TextColor3 = Color3.fromRGB(25, 25, 30), Color3.fromRGB(255, 255, 255)
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(18, 18, 22), Color3.fromRGB(140, 140, 140)
    openCombatTab()
end)
