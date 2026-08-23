getgenv().espEnabled = true
getgenv().maxDist = 2000
getgenv().hitboxEnabled = false
getgenv().hitboxSize = 2
getgenv().mineEspEnabled = true
getgenv().mineMaxDist = 200
getgenv().itemEspEnabled = true
getgenv().itemMaxDist = 300
getgenv().corpseEspEnabled = true
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
getgenv().GMK_FOV = FOVCircle
function checkPointVisible(origin, part, character)
    local lPlrObj = game:GetService("Players").LocalPlayer
    local camObj = game:GetService("Workspace").CurrentCamera
    if not part or not lPlrObj or not camObj then return false end
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lPlrObj.Character, character, camObj}
    raycastParams.IgnoreWater = true
    local success, raycastResult = pcall(function() return game.Workspace:Raycast(origin, direction, raycastParams) end)
    if success and raycastResult then
        local hitObj = raycastResult.Instance
        if hitObj.CanCollide == false or hitObj.Transparency > 0.5 or string.find(string.lower(hitObj.Name), "leaf") or string.find(string.lower(hitObj.Name), "grass") or string.find(string.lower(hitObj.Name), "bush") or string.find(string.lower(hitObj.Name), "twig") then
            return true
        end
        return false
    end
    return true
end

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
    local FOVCircle = getgenv().GMK_FOV
    if not camObj or not FOVCircle then return end
    if getgenv().aimbotEnabled then FOVCircle.Visible = getgenv().fovCircleVisible else FOVCircle.Visible = false end
    FOVCircle.Radius = getgenv().fovCircleRadius
    FOVCircle.Color = Color3.fromRGB(0, 255, 120)
    FOVCircle.Position = Vector2.new(camObj.ViewportSize.X / 2, camObj.ViewportSize.Y / 2)
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
local Kavo = loadstring(game:HttpGet("https://githubusercontent.com"))()
local Window = Kavo.CreateLib("GMK MENU", "DarkTheme")

local EspTab = Window:NewTab("ESP")
local EspSection = EspTab:NewSection("Функции ESP")

EspSection:NewToggle("ESP на Игроков и Ботов", "Включает силуэты", function(state) getgenv().espEnabled = state end)
EspSection:NewToggle("ESP на Лут (Кейсы/Сейфы)", "Подсветка предметов", function(state) getgenv().itemEspEnabled = state end)
EspSection:NewToggle("ESP на Мины и Растяжки", "Опасные объекты", function(state) getgenv().mineEspEnabled = state end)
EspSection:NewToggle("ESP на Трупы", "Показывает мертвых игроков", function(state) getgenv().corpseEspEnabled = state end)

local CombatTab = Window:NewTab("COMBAT")
local CombatSection = CombatTab:NewSection("Sentinel Аимбот")

CombatSection:NewToggle("Включить Аимбот", "Наведение прицела", function(state) getgenv().aimbotEnabled = state end)
CombatSection:NewSlider("Дистанция Аима", "Максимальное расстояние", 700, 1, function(v) getgenv().aimbotMaxDist = v end)
CombatSection:NewToggle("Показывать FOV круг", "Визуальный радиус", function(state) getgenv().fovCircleVisible = state end)
CombatSection:NewSlider("Радиус FOV круга", "Размер круга", 150, 1, function(v) getgenv().fovCircleRadius = v end)

local HitboxSection = CombatTab:NewSection("Хитбоксы головы")
HitboxSection:NewToggle("Увеличение хитбокса головы", "Хитбокс", function(state) getgenv().hitboxEnabled = state end)
HitboxSection:NewSlider("Размер хитбокса", "Размер головы", 5, 2, function(v) getgenv().hitboxSize = v end)
