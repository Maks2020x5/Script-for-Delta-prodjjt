local maxDist = 1800
local lootMaxDist = 1000
local mineMaxDist = 300
local lPlr = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

local espEnabled = true
local distEnabled = true
local lootEspEnabled = true
local mineEspEnabled = true
local hitboxEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaXenoCrossGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lPlr:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 110, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "МЕНЮ ESP"
toggleBtn.Parent = screenGui

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 0, 0)
btnStroke.Thickness = 1.5
btnStroke.Parent = toggleBtn

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 290)
mainFrame.Position = UDim2.new(0.5, -100, 0.4, -145)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 0, 0)
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.Text = "DELTA MULTIHACK"
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

local function createMenuBtn(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.Parent = mainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.Activated:Connect(callback)
    return btn
end

toggleBtn.Activated:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local boxBtn = createMenuBtn("ESP ИГРОКИ: ВКЛ", UDim2.new(0, 20, 0, 50), function()
    espEnabled = not espEnabled
    boxBtn.Text = "ESP ИГРОКИ: " .. (espEnabled and "ВКЛ" or "ВЫКЛ")
    boxBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

local distBtn = createMenuBtn("ДИСТАНЦИЯ: ВКЛ", UDim2.new(0, 20, 0, 100), function()
    distEnabled = not distEnabled
    distBtn.Text = "ДИСТАНЦИЯ: " .. (distEnabled and "ВКЛ" or "ВЫКЛ")
    distBtn.BackgroundColor3 = distEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

local lootBtn = createMenuBtn("ESP ЛУТ: ВКЛ", UDim2.new(0, 20, 0, 150), function()
    lootEspEnabled = not lootEspEnabled
    lootBtn.Text = "ESP ЛУТ: " .. (lootEspEnabled and "ВКЛ" or "ВЫКЛ")
    lootBtn.BackgroundColor3 = lootEspEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

local mineBtn = createMenuBtn("ESP МИНЫ: ВКЛ", UDim2.new(0, 20, 0, 200), function()
    mineEspEnabled = not mineEspEnabled
    mineBtn.Text = "ESP МИНЫ: " .. (mineEspEnabled and "ВКЛ" or "ВЫКЛ")
    mineBtn.BackgroundColor3 = mineEspEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

local hbBtn = createMenuBtn("ХИТБОКС (х3): ВЫКЛ", UDim2.new(0, 20, 0, 240), function()
    hitboxEnabled = not hitboxEnabled
    hbBtn.Text = "ХИТБОКС (х3): " .. (hitboxEnabled and "ВКЛ" or "ВЫКЛ")
    hbBtn.BackgroundColor3 = hitboxEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)
hbBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local function checkTopLoot(name)
    local lootName = string.lower(name)
    if string.find(lootName, "m4a1") then return "M4A1" end
    if string.find(lootName, "thermal") or string.find(lootName, "teplak") then return "ТЕПЛАК" end
    if string.find(lootName, "flare") or string.find(lootName, "flayer") then return "ФЛАЕР" end
    if string.find(lootName, "altyn") or string.find(lootName, "алтын") then return "АЛТЫН" end
    if string.find(lootName, "tor") or string.find(lootName, "тор") then return "ТОР-М" end
    if string.find(lootName, "pkm") or string.find(lootName, "пкм") then return "ПКМ" end
    if string.find(lootName, "money") or string.find(lootName, "rub") or string.find(lootName, "usd") then return "ДЕНЬГИ" end
    if string.find(lootName, "ghillie") or string.find(lootName, "маскхалат") then return "МАСКХАЛАТ" end
    if string.find(lootName, "heavy") or string.find(lootName, "armor") then return "ТОП БРОНЯ" end
    return nil
end

local function checkPointVisible(origin, part, character)
    if not part then return false end
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
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if checkPointVisible(origin, head, character) or checkPointVisible(origin, torso, character) or checkPointVisible(origin, hrp, character) then
        return true
    end
    return false
end
local function applyESP(model)
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
                    highlight.Enabled = espEnabled
                    bGui.Enabled = espEnabled
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
                    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and espEnabled then
                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                        if dist <= maxDist then
                            local baseText = game.Players:FindFirstChild(model.Name) and "[ИГРОК]" or "[БОТ]"
                            if isPlayerVisible(model) then
                                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                txt.TextColor3 = Color3.fromRGB(0, 255, 0)
                            else
                                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                txt.TextColor3 = Color3.fromRGB(255, 0, 0)
                            end
                            txt.Text = distEnabled and (baseText .. " " .. tostring(dist)) or baseText
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
                bGui.Enabled = mineEspEnabled
                mineHighlight.Enabled = mineEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and mineEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    if dist <= mineMaxDist then
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
        local topLootFound = nil
        for _, item in pairs(model:GetDescendants()) do
            topLootFound = checkTopLoot(item.Name)
            if topLootFound then break end
        end
        if not topLootFound and isDroppedItem then topLootFound = checkTopLoot(model.Name) end
        local baseColor = Color3.fromRGB(255, 255, 255)
        local boxTypeLabel = "[ЯЩИК]"
        if isAurora then baseColor = Color3.fromRGB(0, 0, 255) boxTypeLabel = "[АВРОРА]" end
        if isSafe then baseColor = Color3.fromRGB(255, 0, 0) boxTypeLabel = "[СЕЙФ]" end
        if isBig then baseColor = Color3.fromRGB(255, 255, 255) boxTypeLabel = "[БОЛЬШОЙ ЯЩИК]" end
        if isDroppedItem then baseColor = Color3.fromRGB(200, 200, 200) boxTypeLabel = "[ЛУТ]" end
        local lootHighlight = model:FindFirstChild("LootHighlight") or Instance.new("Highlight")
        if not lootHighlight.Parent then
            lootHighlight.Name = "LootHighlight"
            lootHighlight.FillTransparency = topLootFound and 0.5 or 1
            lootHighlight.OutlineTransparency = 0
            lootHighlight.OutlineColor = topLootFound and Color3.fromRGB(255, 100, 0) or baseColor
            if topLootFound then lootHighlight.FillColor = Color3.fromRGB(255, 100, 0) end
            lootHighlight.Parent = model
        end
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "LootTextGui"
        bGui.AlwaysOnTop = true
        bGui.Size = UDim2.new(0, 140, 0, 25)
        bGui.StudsOffset = Vector3.new(0, 2, 0)
        bGui.Parent = triggerPart
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 0.3
        txt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        txt.TextColor3 = topLootFound and Color3.fromRGB(255, 100, 0) or baseColor
        txt.TextSize = 13
        txt.Font = Enum.Font.SourceSansBold
        txt.Text = topLootFound and ("🔥 " .. topLootFound) or boxTypeLabel
        txt.Parent = bGui
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 6)
        uiCorner.Parent = txt
        task.spawn(function()
            while model and model.Parent and triggerPart and txt and bGui and lootHighlight do
                bGui.Enabled = lootEspEnabled
                lootHighlight.Enabled = lootEspEnabled
                local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and lootEspEnabled then
                    local dist = math.floor((myHrp.Position - triggerPart.Position).Magnitude)
                    if dist <= lootMaxDist then
                        local activeText = topLootFound and ("🔥 " .. topLootFound) or boxTypeLabel
                        if topLootFound then
                            if dist <= 10 then txt.Text = "🔥 " .. topLootFound .. " " .. tostring(dist) else txt.Text = "🔥 " .. topLootFound end
                        else
                            txt.Text = distEnabled and (activeText .. " " .. tostring(dist)) or activeText
                        end
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

for _, v in pairs(game.Workspace:GetDescendants()) do pcall(function() applyESP(v) end) end
game.Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.2)
    pcall(function() applyESP(descendant) end)
end)
