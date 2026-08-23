getgenv().espEnabled = true
getgenv().corpseEspEnabled = true
getgenv().itemEspEnabled = true
getgenv().mineEspEnabled = true
getgenv().aimbotEnabled = true
getgenv().aimbotMaxDist = 600

local lPlr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local inputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaProjectMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = game:GetService("CoreGui") or lPlr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 290)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
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

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(0.83, 0, 0.08, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = titleBar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 0, 255)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentFrame

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 200, 0, 35)
        minimizeBtn.Text = "+"
    else
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 200, 0, 290)
        minimizeBtn.Text = "—"
    end
end)

local function createToggle(text, env_val, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = contentFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local function updateVisuals()
        if getgenv()[env_val] then
            btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
            btn.Text = text .. ": ВКЛ"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
            btn.Text = text .. ": ВЫКЛ"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    updateVisuals()
    
    btn.MouseButton1Click:Connect(function()
        getgenv()[env_val] = not getgenv()[env_val]
        updateVisuals()
    end)
end

local pad = Instance.new("Frame")
pad.Size = UDim2.new(1, 0, 0, 2)
pad.BackgroundTransparency = 1
pad.LayoutOrder = 0
pad.Parent = contentFrame

createToggle("🎯 АИМБОТ", "aimbotEnabled", 1)
createToggle("👤 ESP ИГРОКИ", "espEnabled", 2)
createToggle("💀 ESP ТРУПЫ", "corpseEspEnabled", 3)
createToggle("📦 ESP ЛУТ (КЕЙСЫ)", "itemEspEnabled", 4)
createToggle("💥 ESP МИНЫ", "mineEspEnabled", 5)

local function getSentinelTarget()
    local target = nil
    local maxDist = getgenv().aimbotMaxDist
    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lPlr.Name then
            if v.Humanoid.Health > 0 then
                local dist = (myHrp.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < maxDist then
                    local head = v:FindFirstChild("Head")
                    if head then
                        local _, onScreen = cam:WorldToViewportPoint(head.Position)
                        if onScreen then
                            maxDist = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

runService.RenderStepped:Connect(function()
    if getgenv().aimbotEnabled and cam then
        local t = getSentinelTarget()
        if t and lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart") then 
            local targetTargetCFrame = CFrame.new(cam.CFrame.Position, t.Position)
            cam.CFrame = cam.CFrame:Lerp(targetTargetCFrame, 0.15) 
        end
    end
end)

local function applyLightESP(model)
    if not model or not model.Parent then return end
    
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlr.Name then return end
        local hrp = model.HumanoidRootPart
        
        local hl = model:FindFirstChild("MobileESP") or Instance.new("Highlight")
        if not hl.Parent then 
            hl.Name = "MobileESP" hl.Parent = model hl.FillTransparency = 1 hl.OutlineTransparency = 0 
        end
        
        local bGui = hrp:FindFirstChild("TextEspGui") or Instance.new("BillboardGui")
        if not bGui.Parent then
            bGui.Name = "TextEspGui" bGui.AlwaysOnTop = true bGui.Size = UDim2.new(0, 100, 0, 25) bGui.StudsOffset = Vector3.new(0, 3, 0) bGui.Parent = hrp
            local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextSize = 13 txt.Font = Enum.Font.SourceSansBold txt.Parent = bGui
            
            task.spawn(function()
                while model and model.Parent and hrp and txt and bGui and hl do
                    local isDead = model.Humanoid.Health <= 0
                    local state = isDead and getgenv().corpseEspEnabled or getgenv().espEnabled
                    hl.Enabled, bGui.Enabled = state, state
                    
                    if state then
                        local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            local d = math.floor((myHrp.Position - hrp.Position).Magnitude)
                            local base = isDead and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            local c = isDead and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor, txt.TextColor3 = c, c
                            txt.Text = base .. " " .. tostring(d) .. "m"
                            txt.Visible = true
                        else txt.Visible = false end
                    else txt.Visible = false end
                    task.wait(0.4)
                end
            end)
        end
        return
    end
    
    local nameL = string.lower(model.Name)
    
    if string.find(nameL, "mine") or string.find(nameL, "claymore") or string.find(nameL, "explosive") or string.find(nameL, "растяжка") or string.find(nameL, "mon-50") then
        local p = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not p or p:FindFirstChild("MineTextGui") then return end
        
        local b = Instance.new("BillboardGui") b.Name = "MineTextGui" b.AlwaysOnTop = true b.Size = UDim2.new(0, 100, 0, 25) b.StudsOffset = Vector3.new(0, 1.5, 0) b.Parent = p
        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 1, 0) t.BackgroundTransparency = 0.2 t.BackgroundColor3 = Color3.fromRGB(30, 0, 0) t.TextColor3 = Color3.fromRGB(255, 30, 30) t.TextSize = 12 t.Font = Enum.Font.SourceSansBold t.Text = "⚠️ МИНА" t.Parent = b
        Instance.new("UICorner").CornerRadius = UDim.new(0, 6) t.Parent = t
        
        task.spawn(function()
            while model and model.Parent and p and t and b do
                b.Enabled = getgenv().mineEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().mineEspEnabled then 
                    t.Text, t.Visible = "💥 МИНА [" .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)) .. "m]", true 
                else t.Visible = false end
                task.wait(0.5)
            end
        end)
        
    elseif model.Name == "AuroraBox" or model.Name == "BigBox" or string.find(nameL, "safe") or string.find(nameL, "сейф") or string.find(nameL, "loot") or string.find(nameL, "crate") then
        local p = model:IsA("BasePart") and model or model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
        if not p or p:FindFirstChild("LootTextGui") then return end
        
        local b = Instance.new("BillboardGui") b.Name = "LootTextGui" b.AlwaysOnTop = true b.Size = UDim2.new(0, 130, 0, 25) b.StudsOffset = Vector3.new(0, 2, 0) b.Parent = p
        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, 0, 1, 0) t.BackgroundTransparency = 0.3 t.BackgroundColor3 = Color3.fromRGB(20, 20, 20) t.TextColor3 = Color3.fromRGB(255, 215, 0) t.TextSize = 11 t.Font = Enum.Font.SourceSansBold t.Parent = b
        
        local cleanName = model.Name == "AuroraBox" and "✨ АВРОРА КЕЙС" or model.Name == "BigBox" and "🎁 БОЛЬШОЙ КЕЙС" or (string.find(nameL, "safe") or string.find(nameL, "сейф")) and "🗄️ СЕЙФ" or "📦 ЛУТ / ЯЩИК"
        t.Text = cleanName Instance.new("UICorner").CornerRadius = UDim.new(0, 6) t.Parent = t
        
        task.spawn(function()
            while model and model.Parent and p and t and b do
                b.Enabled = getgenv().itemEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then 
                    t.Text, t.Visible = cleanName .. " [" .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)) .. "m]", true 
                else t.Visible = false end
                task.wait(0.5)
            end
        end)
    end
end

workspace.ChildAdded:Connect(applyLightESP)
for _, v in pairs(workspace:GetDescendants()) do 
    pcall(function() applyLightESP(v) end) 
end
