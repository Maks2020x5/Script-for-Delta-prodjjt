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
getgenv().SentinelHitChance = 100

local lPlr = game:GetService("Players").LocalPlayer
getgenv().GMK_TargetParent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui") or lPlr:WaitForChild("PlayerGui")
if getgenv().GMK_TargetParent:FindFirstChild("GMK_SimpleMenu") then getgenv().GMK_TargetParent.GMK_SimpleMenu:Destroy() end

getgenv().GMK_SimpleMenu = Instance.new("ScreenGui")
getgenv().GMK_SimpleMenu.Name = "GMK_SimpleMenu"
getgenv().GMK_SimpleMenu.ResetOnSpawn = false
getgenv().GMK_SimpleMenu.Parent = getgenv().GMK_TargetParent

getgenv().GMK_MainFrame = Instance.new("Frame")
getgenv().GMK_MainFrame.Size = UDim2.new(0, 360, 0, 240)
getgenv().GMK_MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
getgenv().GMK_MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
getgenv().GMK_MainFrame.Active = true
getgenv().GMK_MainFrame.Visible = false
getgenv().GMK_MainFrame.ZIndex = 100
getgenv().GMK_MainFrame.Parent = getgenv().GMK_SimpleMenu
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) getgenv().GMK_MainFrame.Parent = getgenv().GMK_MainFrame

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 30)
OpenBtn.Position = UDim2.new(0, 10, 0, 50)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
OpenBtn.Text = "GMK"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.TextSize = 14
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.ZIndex = 500
OpenBtn.Parent = getgenv().GMK_SimpleMenu
Instance.new("UICorner").CornerRadius = UDim.new(0, 6) OpenBtn.Parent = OpenBtn

local dragging, dragInput, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = OpenBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
OpenBtn.MouseButton1Click:Connect(function() getgenv().GMK_MainFrame.Visible = not getgenv().GMK_MainFrame.Visible end)
local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 150, 0, 30) Title.Position = UDim2.new(0, 10, 0, 0) Title.BackgroundTransparency = 1 Title.Text = "GMK MENU" Title.TextColor3 = Color3.fromRGB(0, 255, 150) Title.TextSize = 13 Title.Font = Enum.Font.SourceSansBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.Parent = getgenv().GMK_MainFrame
local TopBar = Instance.new("Frame") TopBar.Size = UDim2.new(0, 180, 0, 30) TopBar.Position = UDim2.new(0, 170, 0, 0) TopBar.BackgroundTransparency = 1 TopBar.Parent = getgenv().GMK_MainFrame
local EspTabBtn = Instance.new("TextButton") EspTabBtn.Size = UDim2.new(0, 85, 0, 25) EspTabBtn.Position = UDim2.new(0, 0, 0, 2) EspTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) EspTabBtn.Text = "ESP" EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) EspTabBtn.Font = Enum.Font.SourceSansBold EspTabBtn.TextSize = 12 EspTabBtn.Parent = TopBar Instance.new("UICorner").CornerRadius = UDim.new(0, 4) EspTabBtn.Parent = EspTabBtn
local CombatTabBtn = Instance.new("TextButton") CombatTabBtn.Size = UDim2.new(0, 85, 0, 25) CombatTabBtn.Position = UDim2.new(0, 90, 0, 2) CombatTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25) CombatTabBtn.Text = "COMBAT" CombatTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150) CombatTabBtn.Font = Enum.Font.SourceSansBold CombatTabBtn.TextSize = 12 CombatTabBtn.Parent = TopBar Instance.new("UICorner").CornerRadius = UDim.new(0, 4) CombatTabBtn.Parent = CombatTabBtn

getgenv().GMK_Container = Instance.new("Frame") getgenv().GMK_Container.Size = UDim2.new(1, -20, 1, -40) getgenv().GMK_Container.Position = UDim2.new(0, 10, 0, 35) getgenv().GMK_Container.BackgroundTransparency = 1 getgenv().GMK_Container.Parent = getgenv().GMK_MainFrame
getgenv().GMK_ActiveObjects = {}
getgenv().GMK_ClearContainer = function() for _, o in pairs(getgenv().GMK_ActiveObjects) do o:Destroy() end getgenv().GMK_ActiveObjects = {} end

getgenv().GMK_CreateMenuToggle = function(text, globalVar, yPos, callback)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 200, 0, 25) lbl.Position = UDim2.new(0, 10, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = getgenv().GMK_Container
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 280, 0, yPos + 3) btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.Parent = getgenv().GMK_Container Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function() 
        getgenv()[globalVar] = not getgenv()[globalVar] 
        btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60)
        if callback then callback(getgenv()[globalVar]) end
    end)
    table.insert(getgenv().GMK_ActiveObjects, lbl) table.insert(getgenv().GMK_ActiveObjects, btn)
end

getgenv().GMK_CreateMenuSlider = function(text, min, max, globalVar, yPos, callback)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 230, 0, 15) lbl.Position = UDim2.new(0, 10, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. tostring(getgenv()[globalVar]) lbl.TextColor3 = Color3.fromRGB(180, 190, 180) lbl.TextSize = 11 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = getgenv().GMK_Container
    local slideBar = Instance.new("TextButton") slideBar.Size = UDim2.new(0, 230, 0, 6) slideBar.Position = UDim2.new(0, 10, 0, yPos + 18) slideBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50) slideBar.Text = "" slideBar.ZIndex = 125 slideBar.Parent = getgenv().GMK_Container
    local fill = Instance.new("Frame") fill.Size = UDim2.new((getgenv()[globalVar] - min)/(max - min), 0, 1, 0) fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150) fill.BorderSizePixel = 0 fill.Parent = slideBar
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

getgenv().GMK_DrawEspTab = function()
    getgenv().GMK_ClearContainer()
    getgenv().GMK_CreateMenuToggle("Включить ESP на Игроков / Ботов", "espEnabled", 10)
    getgenv().GMK_CreateMenuToggle("Включить ESP на Лут", "itemEspEnabled", 40)
    getgenv().GMK_CreateMenuToggle("Включить ESP на Мины", "mineEspEnabled", 70)
    getgenv().GMK_CreateMenuToggle("Включить ESP на Трупы типов", "corpseEspEnabled", 100)
end

getgenv().GMK_DrawCombatTab = function()
    getgenv().GMK_ClearContainer()
    local aimSub = {}
    local function toggleAim(state) for _, o in pairs(aimSub) do o.Visible = state end end
    getgenv().GMK_CreateMenuToggle("Включить Sentinel Аимбот", "aimbotEnabled", 10, toggleAim)
    local al1, ab1 = getgenv().GMK_CreateMenuSlider("Макс. Дистанция Аима", 1, 700, "aimbotMaxDist", 35)
    local al2, ab2 = getgenv().GMK_CreateMenuToggle("Показывать FOV круг", "fovCircleVisible", 70)
    local al3, ab3 = getgenv().GMK_CreateMenuSlider("Радиус FOV круга", 1, 150, "fovCircleRadius", 95)
    table.insert(aimSub, al1) table.insert(aimSub, ab1) table.insert(aimSub, al2) table.insert(aimSub, ab2) table.insert(aimSub, al3) table.insert(aimSub, ab3)
    toggleAim(getgenv().aimbotEnabled)
    
    local hbSub = {}
    local function toggleHb(state) for _, o in pairs(hbSub) do o.Visible = state end end
    getgenv().GMK_CreateMenuToggle("Увеличение хитбокса головы", "hitboxEnabled", 135, toggleHb)
    local hl1, hb1 = getgenv().GMK_CreateMenuSlider("Размер хитбокса головы", 2, 5, "hitboxSize", 160)
    table.insert(hbSub, hl1) table.insert(hbSub, hb1)
    toggleHb(getgenv().hitboxEnabled)
end

getgenv().GMK_DrawEspTab()
EspTabBtn.MouseButton1Click:Connect(function()
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255)
    CombatTabBtn.BackgroundColor3, CombatTabBtn.TextColor3 = Color3.fromRGB(20, 20, 25), Color3.fromRGB(150, 150, 150)
    getgenv().GMK_DrawEspTab()
end)
CombatTabBtn.MouseButton1Click:Connect(function()
    CombatTabBtn.BackgroundColor3, CombatTabBtn.TextColor3 = Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255)
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(20, 20, 25), Color3.fromRGB(150, 150, 150)
    getgenv().GMK_DrawCombatTab()
end)
getgenv().GMK_GUI_LOADED = true
while not getgenv().GMK_GUI_LOADED do task.wait(0.1) end
local lPlr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64

local function getSentinelTarget()
    local target = nil
    local maxDist = getgenv().fovCircleRadius
    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lPlr.Name then
            if v.Humanoid.Health > 0 and (myHrp.Position - v.HumanoidRootPart.Position).Magnitude <= getgenv().aimbotMaxDist then
                local head = v:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mPos = game:GetService("UserInputService"):GetMouseLocation()
                        local mDist = (Vector2.new(screenPos.X, screenPos.Y) - mPos).Magnitude
                        if mDist < maxDist then maxDist = mDist target = v end
                    end
                end
            end
        end
    end
    return target
end

game:GetService("RunService").RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Visible = getgenv().aimbotEnabled and getgenv().fovCircleVisible or false
        FOVCircle.Radius = getgenv().fovCircleRadius
        FOVCircle.Color = Color3.fromRGB(0, 255, 120)
        FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
    end
end)

local MetaTable = getrawmetatable(game)
if MetaTable and setreadonly then
    setreadonly(MetaTable, false)
    local OriginalNamecall = MetaTable.__namecall
    MetaTable.__namecall = newcclosure(function(Self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        if getgenv().aimbotEnabled and (Method == "Raycast" or Method == "FindPartOnRay") then
            local tChar = getSentinelTarget()
            if tChar and tChar:FindFirstChild("Head") then
                if math.random(1, 100) <= getgenv().SentinelHitChance then
                    if Method == "Raycast" then Args = (tChar.Head.Position - Args).Unit * 1000
                    else Args = Ray.new(cam.CFrame.Position, (tChar.Head.Position - cam.CFrame.Position).Unit * 1000) end
                end
            end
        end
        return OriginalNamecall(Self, unpack(Args))
    end)
    setreadonly(MetaTable, true)
end
getgenv().GMK_AIM_LOADED = true
while not getgenv().GMK_AIM_LOADED do task.wait(0.1) end
local lPlr = game:GetService("Players").LocalPlayer

local function applyLightESP(model)
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlr.Name then return end
        local hrp = model.HumanoidRootPart
        local head = model:FindFirstChild("Head")
        local humanoid = model.Humanoid
        local hl = model:FindFirstChild("MobileESP") or Instance.new("Highlight")
        if not hl.Parent then hl.Name = "MobileESP" hl.Parent = model hl.FillTransparency = 1 hl.OutlineTransparency = 0 end
        local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
        if not bGui.Parent then
            bGui.Name = "TextEspGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 3, 0) bGui.Parent = hrp
            local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextSize = 13 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
            task.spawn(function()
                while model and model.Parent and hrp and txt and bGui and hl do
                    local isDead = model.Humanoid.Health <= 0
                    local state = isDead and getgenv().corpseEspEnabled or getgenv().espEnabled
                    hl.Enabled, bGui.Enabled = state, state
                    if head and head:IsA("BasePart") then pcall(function()
                        if getgenv().hitboxEnabled and not isDead then
                            head.Size = Vector3.new(getgenv().hitboxSize, getgenv().hitboxSize, getgenv().hitboxSize)
                            head.Transparency = 0.7 head.CanCollide = false
                        else head.Size = Vector3.new(1.2, 1.2, 1.2) head.Transparency = 0 head.CanCollide = true end
                    end) end
                    if state then
                        local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            local d = math.floor((myHrp.Position - hrp.Position).Magnitude)
                            local base = isDead and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            local c = isDead and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor, txt.TextColor3 = c, c
                            txt.Text = base .. " " .. tostring(d) txt.Visible = true
                        else txt.Visible = false end
                    else txt.Visible = false end
                    task.wait(0.5)
                end
            end)
        end
    end
    local nameL = string.lower(model.Name)
    if string.find(nameL, "mine") or string.find(nameL, "claymore") or string.find(nameL, "explosive") or string.find(nameL, "растяжка") then
        local p = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not p or p:FindFirstChild("MineTextGui") then return end
        local b = Instance.new("BillboardGui") b.Name = "MineTextGui" b.AlwaysOnTop = true b.Size = UDim2.new(0, 100, 0, 25) b.StudsOffset = Vector3.new(0, 1.5, 0) b.Parent = p
        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 1, 0) t.BackgroundTransparency = 0.3 t.BackgroundColor3 = Color3.fromRGB(15, 15, 15) t.TextColor3 = Color3.fromRGB(238, 130, 238) t.TextSize = 12 t.Font = Enum.Font.SourceSansBold t.Text = "⚠️ МИНА" t.Parent = b
        Instance.new("UICorner").CornerRadius = UDim.new(0, 6) t.Parent = t
        task.spawn(function()
            while model and model.Parent and p and t and b do
                b.Enabled = getgenv().mineEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then t.Text, t.Visible = "⚠️ МИНА " .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)), true else t.Visible = false end
                task.wait(0.5)
            end
        end)
    elseif model.Name == "AuroraBox" or model.Name == "BigBox" or string.find(nameL, "safe") or string.find(nameL, "сейф") or (model:IsA("Model") and model:FindFirstChild("Part") and not model:FindFirstChild("Humanoid")) then
        local p = model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
        if not p or p:FindFirstChild("LootTextGui") then return end
        local b = Instance.new("BillboardGui") b.Name = "LootTextGui" b.AlwaysOnTop = true b.Size = UDim2.new(0, 120, 0, 25) b.StudsOffset = Vector3.new(0, 2, 0) b.Parent = p
        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 1, 0) t.BackgroundTransparency = 0.4 t.BackgroundColor3 = Color3.fromRGB(20, 20, 20) t.TextColor3 = Color3.fromRGB(255, 215, 0) t.TextSize = 11 t.Font = Enum.Font.SourceSansBold t.Parent = b
        local name = model.Name == "AuroraBox" and "✨ АВРОРА КЕЙС" or model.Name == "BigBox" and "🎁 БОЛЬШОЙ КЕЙС" or string.find(nameL, "safe") and "🗄️ СЕЙФ" or "📦 ПРЕДМЕТ"
        t.Text = name Instance.new("UICorner").CornerRadius = UDim.new(0, 6) t.Parent = t
        task.spawn(function()
            while model and model.Parent and p and t and b do
                b.Enabled = getgenv().itemEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then t.Text, t.Visible = name .. " " .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)), true else t.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end
workspace.ChildAdded:Connect(applyLightESP)
for _, v in pairs(workspace:GetChildren()) do applyLightESP(v) end
