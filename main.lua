getgenv().espEnabled = true
getgenv().itemEspEnabled = true
getgenv().mineEspEnabled = true
getgenv().corpseEspEnabled = true
getgenv().aimbotEnabled = true
getgenv().aimbotMaxDist = 600
getgenv().hitboxEnabled = true
getgenv().hitboxSize = 2.5

local lPlr = game:GetService("Players").LocalPlayer
local cam = workspace.CurrentCamera

local function getSentinelTarget()
    local target = nil
    local maxDist = math.huge
    local myHrp = lPlr.Character and lPlr.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lPlr.Name then
            if v.Humanoid.Health > 0 then
                local dist = (myHrp.Position - v.HumanoidRootPart.Position).Magnitude
                if dist <= getgenv().aimbotMaxDist and dist < maxDist then
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

game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().aimbotEnabled and cam then
        local t = getSentinelTarget()
        if t then 
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, t.Position), 0.12) 
        end
    end
end)
getgenv().GMK_CORE_READY = true
while not getgenv().GMK_CORE_READY do task.wait(0.1) end
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
