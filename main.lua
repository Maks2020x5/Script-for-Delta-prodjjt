getgenv().espEnabled = true
getgenv().corpseEspEnabled = true
getgenv().itemEspEnabled = true
getgenv().mineEspEnabled = true
getgenv().aimbotEnabled = true
getgenv().aimMode = "Sentinel"
getgenv().aimbotMaxDist = 300
getgenv().aimbotFov = 120
getgenv().showFovCircle = true

local lPlr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = getgenv().showFovCircle
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(0, 255, 150)
fovCircle.Transparency = 0.7
fovCircle.NumSides = 64

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

local subFrame = Instance.new("Frame")
subFrame.Name = "SubFrame"
subFrame.Size = UDim2.new(0, 190, 0, 240)
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
subPad.Size = UDim2.new(1, 0, 0, 25)
subPad.BackgroundTransparency = 1
subPad.LayoutOrder = 0
subPad.Parent = subFrame

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0, 170, 0, 30)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextSize = 11
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Text = "ТИП: " .. getgenv().aimMode
modeBtn.LayoutOrder = 1
modeBtn.Parent = subFrame

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 4)
modeCorner.Parent = modeBtn

modeBtn.MouseButton1Click:Connect(function()
    if getgenv().aimMode == "Sentinel" then
        getgenv().aimMode = "Legit"
    else
        getgenv().aimMode = "Sentinel"
    end
    modeBtn.Text = "ТИП: " .. getgenv().aimMode
end)

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

createConfigButton("Предел: ЛЕГИТ (FOV 60 / 150m)", 60, 150, 2)
createConfigButton("Предел: СРЕДНИЙ (FOV 120 / 300m)", 120, 300, 3)
createConfigButton("Предел: ЖЕСТКИЙ (FOV 250 / 600m)", 250, 600, 4)

local fovToggleBtn = Instance.new("TextButton")
fovToggleBtn.Size = UDim2.new(0, 170, 0, 30)
fovToggleBtn.Font = Enum.Font.SourceSansBold
fovToggleBtn.TextSize = 11
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
fovToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fovToggleBtn.Text = "КРУГ FOV: ПОКАЗАТЬ"
fovToggleBtn.LayoutOrder = 5
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

local boneNames = {"Head", "UpperTorso", "LeftHand", "RightHand", "LeftLowerLeg", "RightLowerLeg"}
local checkCache = {}
local boneCache = {}
local lastCacheClear = os.clock()

local function getVisiblePart(character)
    if not character then return nil end
    local now = os.clock()
    if now - lastCacheClear > 0.05 then
        table.clear(checkCache)
        table.clear(boneCache)
        lastCacheClear = now
    end
    if checkCache[character] ~= nil then return boneCache[character] end

    local ignoreList = {lPlr.Character, cam}
    for _, bName in ipairs(boneNames) do
        local part = character:FindFirstChild(bName)
        if part then
            local obscuring = cam:GetPartsObscuringTarget({part.Position}, ignoreList)
            if #obscuring == 0 then
                checkCache[character] = true
                boneCache[character] = part
                return part
            end
        end
    end
    checkCache[character] = false
    boneCache[character] = nil
    return nil
end
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
        subFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 200, 0, 35)
        minimizeBtn.Text = "+"
    else
        contentFrame.Visible = true
        subFrame.Visible = getgenv().aimbotEnabled
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
            if env_val == "aimbotEnabled" and not isMinimized then subFrame.Visible = true end
        else
            btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
            btn.Text = text .. ": ВЫКЛ"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            if env_val == "aimbotEnabled" then subFrame.Visible = false end
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

local function getTargetInFov()
    local targetPart = nil
    local shortestDist = math.huge
    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lPlr.Name then
            if v.Humanoid.Health > 0 then
                local visiblePart = getVisiblePart(v)
                if visiblePart then
                    local screenPos, onScreen = cam:WorldToViewportPoint(visiblePart.Position)
                    if onScreen then
                        local worldDist = (myHrp.Position - visiblePart.Position).Magnitude
                        if worldDist <= getgenv().aimbotMaxDist then
                            local mousePos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if fovDist <= getgenv().aimbotFov and fovDist < shortestDist then
                                shortestDist = fovDist
                                targetPart = visiblePart
                            end
                        end
                    end
                end
            end
        end
    end
    return targetPart
end
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    local res = oldNamecall(self, ...)
    if getgenv().aimbotEnabled and getgenv().aimMode == "Sentinel" and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = getTargetInFov()
        if target then
            if method == "Raycast" and res then
                local fakeRes = {Instance = target, Position = target.Position, Material = target.Material, Normal = Vector3.new(0,1,0), Distance = res.Distance}
                setmetatable(fakeRes, getmetatable(res))
                return fakeRes
            elseif method ~= "Raycast" then
                return target, target.Position, Vector3.new(0, 1, 0), target.Material
            end
        end
    end
    return res
end)

runService.RenderStepped:Connect(function()
    fovCircle.Visible = getgenv().showFovCircle and getgenv().aimbotEnabled
    if fovCircle.Visible then
        fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovCircle.Radius = getgenv().aimbotFov
    end
    
    if getgenv().aimbotEnabled and getgenv().aimMode == "Legit" then
        local targetPart = getTargetInFov()
        if targetPart then
            local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local mousePos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                local currentDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                local lerpAlpha = currentDist > 40 and 0.14 or 0.05
                local targetCFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
                cam.CFrame = cam.CFrame:Lerp(targetCFrame, lerpAlpha)
            end
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
                            local visiblePart = getVisiblePart(model)
                            local base = isDead and "[ТРУП]" or game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            
                            local c = isDead and Color3.fromRGB(150, 150, 150) or visiblePart and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                            
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
                t.Visible = getgenv().itemEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and getgenv().itemEspEnabled then 
                    t.Text = cleanName .. " [" .. tostring(math.floor((myHrp.Position - p.Position).Magnitude)) .. "m]"
                end
                task.wait(0.5)
            end
        end)
    end
end

workspace.ChildAdded:Connect(applyLightESP)
for _, v in pairs(workspace:GetDescendants()) do 
    pcall(function() applyLightESP(v) end) 
end
