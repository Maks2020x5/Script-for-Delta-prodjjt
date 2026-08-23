getgenv().espEnabled = false
getgenv().itemEspEnabled = false
getgenv().mineEspEnabled = false
getgenv().corpseEspEnabled = false

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
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) MainFrame.Parent = getgenv().GMK_MainFrame

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

getgenv().GMK_CreateMenuToggle = function(text, globalVar, yPos)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 200, 0, 25) lbl.Position = UDim2.new(0, 10, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = getgenv().GMK_Container
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 280, 0, yPos + 3) btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.Parent = getgenv().GMK_Container Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function() getgenv()[globalVar] = not getgenv()[globalVar] btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) end)
    table.insert(getgenv().GMK_ActiveObjects, lbl) table.insert(getgenv().GMK_ActiveObjects, btn)
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
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 1, 0) lbl.BackgroundTransparency = 1 lbl.Text = "[Вкладка COMBAT пустая. Ждет логику Аима]" lbl.TextColor3 = Color3.fromRGB(120, 120, 125) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.Parent = getgenv().GMK_Container table.insert(getgenv().GMK_ActiveObjects, lbl)
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

getgenv().GMK_ApplyPlrESP = function(model)
    if not lPlr then return end
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlr.Name then return end
        local hrp = model.HumanoidRootPart
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
                    if currentEspState then
                        local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                            local baseText = isCorpse and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            local color = isCorpse and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor, txt.TextColor3 = color, color
                            txt.Text, txt.Visible = baseText .. " " .. tostring(dist), true
                        else txt.Visible = false end
                    else txt.Visible = false end
                    task.wait(0.5)
                end
            end)
        end
    end
end
getgenv().GMK_ApplyLootESP = function(model)
    local lPlr = game:GetService("Players").LocalPlayer
    if not lPlr then return end
    local nameL = string.lower(model.Name)
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
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    txt.Text, txt.Visible = displayName .. " " .. tostring(dist), true
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end
getgenv().GMK_ApplyMineESP = function(model)
    local lPlr = game:GetService("Players").LocalPlayer
    if not lPlr then return end
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
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    txt.Text, txt.Visible = "⚠️ МИНА " .. tostring(dist), true
                else txt.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end

local function GMK_MasterESP(v)
    getgenv().GMK_ApplyPlrESP(v)
    getgenv().GMK_ApplyLootESP(v)
    getgenv().GMK_ApplyMineESP(v)
end

workspace.ChildAdded:Connect(GMK_MasterESP)
for _, v in pairs(workspace:GetChildren()) do GMK_MasterESP(v) end
