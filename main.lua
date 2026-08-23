getgenv().espEnabled = false
getgenv().maxDist = 2000
getgenv().mineEspEnabled = false
getgenv().mineMaxDist = 200
getgenv().itemEspEnabled = false
getgenv().itemMaxDist = 300
getgenv().corpseEspEnabled = false

getgenv().aimbotEnabled = false
getgenv().aimbotMaxDist = 300
getgenv().fovCircleVisible = false
getgenv().fovCircleRadius = 120
getgenv().hitboxEnabled = false
getgenv().hitboxSize = 2

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64

function checkPartVisible(part, character)
    local lPlr = game:GetService("Players").LocalPlayer
    local cam = game:GetService("Workspace").CurrentCamera
    if not part or not lPlr or not cam or not lPlr.Character then return false end
    local direction = part.Position - cam.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lPlr.Character, character, cam}
    raycastParams.IgnoreWater = true
    local success, result = pcall(function() return game.Workspace:Raycast(cam.CFrame.Position, direction, raycastParams) end)
    if success and result then
        local hit = result.Instance
        if hit.CanCollide == false or hit.Transparency > 0.5 or string.find(string.lower(hit.Name), "leaf") or string.find(string.lower(hit.Name), "grass") or string.find(string.lower(hitObj.Name), "bush") then
            return true
        end
        return false
    end
    return true
end

function applyPartESP(model)
    local lPlr = game:GetService("Players").LocalPlayer
    if not lPlr then return end
    if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if model.Name == lPlr.Name then return end
        task.spawn(function()
            while model and model.Parent do
                if getgenv().espEnabled then
                    for _, child in pairs(model:GetChildren()) do
                        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                            local sBox = child:FindFirstChild("PartOutline")
                            if not sBox then
                                sBox = Instance.new("SelectionBox")
                                sBox.Name = "PartOutline"
                                sBox.Adornee = child
                                sBox.LineThickness = 0.03
                                sBox.Parent = child
                            end
                            sBox.Enabled = true
                            if checkPartVisible(child, model) then
                                sBox.Color3 = Color3.fromRGB(0, 255, 0)
                            else
                                sBox.Color3 = Color3.fromRGB(255, 0, 0)
                            end
                        end
                    end
                else
                    for _, child in pairs(model:GetChildren()) do
                        if child:IsA("BasePart") then
                            local sBox = child:FindFirstChild("PartOutline")
                            if sBox then sBox.Enabled = false end
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end
workspace.ChildAdded:Connect(applyPartESP)
for _, v in pairs(workspace:GetChildren()) do applyPartESP(v) end
local lPlr = game:GetService("Players").LocalPlayer
local TargetParent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui") or lPlr:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("GMK_SimpleMenu") then TargetParent.GMK_SimpleMenu:Destroy() end

local GMK_SimpleMenu = Instance.new("ScreenGui")
GMK_SimpleMenu.Name = "GMK_SimpleMenu"
GMK_SimpleMenu.ResetOnSpawn = false
GMK_SimpleMenu.Parent = TargetParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = GMK_SimpleMenu
Instance.new("UICorner").CornerRadius = UDim.new(0, 8) MainFrame.Parent = MainFrame

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 30)
OpenBtn.Position = UDim2.new(0, 10, 0, 50)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
OpenBtn.Text = "GMK"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.TextSize = 14
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Parent = GMK_SimpleMenu
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
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 150, 0, 30) Title.Position = UDim2.new(0, 10, 0, 0) Title.BackgroundTransparency = 1 Title.Text = "GMK MENU" Title.TextColor3 = Color3.fromRGB(0, 255, 150) Title.TextSize = 13 Title.Font = Enum.Font.SourceSansBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.Parent = MainFrame

local TopBar = Instance.new("Frame") TopBar.Size = UDim2.new(0, 180, 0, 30) TopBar.Position = UDim2.new(0, 170, 0, 0) TopBar.BackgroundTransparency = 1 TopBar.Parent = MainFrame
local EspTabBtn = Instance.new("TextButton") EspTabBtn.Size = UDim2.new(0, 85, 0, 25) EspTabBtn.Position = UDim2.new(0, 0, 0, 2) EspTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) EspTabBtn.Text = "ESP" EspTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) EspTabBtn.Font = Enum.Font.SourceSansBold EspTabBtn.TextSize = 12 EspTabBtn.Parent = TopBar Instance.new("UICorner").CornerRadius = UDim.new(0, 4) EspTabBtn.Parent = EspTabBtn
local CombatTabBtn = Instance.new("TextButton") CombatTabBtn.Size = UDim2.new(0, 85, 0, 25) CombatTabBtn.Position = UDim2.new(0, 90, 0, 2) CombatTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25) CombatTabBtn.Text = "COMBAT" CombatTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150) CombatTabBtn.Font = Enum.Font.SourceSansBold CombatTabBtn.TextSize = 12 CombatTabBtn.Parent = TopBar Instance.new("UICorner").CornerRadius = UDim.new(0, 4) CombatTabBtn.Parent = CombatTabBtn

local Container = Instance.new("Frame") Container.Size = UDim2.new(1, -20, 1, -40) Container.Position = UDim2.new(0, 10, 0, 35) Container.BackgroundTransparency = 1 Container.Parent = MainFrame
local activeObjects = {}
local function clearContainer() for _, o in pairs(activeObjects) do o:Destroy() end activeObjects = {} end

local function createMenuToggle(text, globalVar, yPos)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 200, 0, 25) lbl.Position = UDim2.new(0, 10, 0, yPos) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = Container
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 40, 0, 18) btn.Position = UDim2.new(0, 280, 0, yPos + 3) btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) btn.Text = "" btn.Parent = Container Instance.new("UICorner").CornerRadius = UDim.new(0, 4) btn.Parent = btn
    btn.MouseButton1Click:Connect(function() getgenv()[globalVar] = not getgenv()[globalVar] btn.BackgroundColor3 = getgenv()[globalVar] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60) end)
    table.insert(activeObjects, lbl) table.insert(activeObjects, btn)
end

local function drawEspTab()
    clearContainer()
    createMenuToggle("Покостный ESP (Игроки / Боты)", "espEnabled", 10)
    createMenuToggle("Включить ESP на Лут", "itemEspEnabled", 40)
    createMenuToggle("Включить ESP на Мины", "mineEspEnabled", 70)
    createMenuToggle("Включить ESP на Трупы типов", "corpseEspEnabled", 100)
end

local function drawCombatTab()
    clearContainer()
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 1, 0) lbl.BackgroundTransparency = 1 lbl.Text = "[Вкладка COMBAT пустая. Ждет логику Аима]" lbl.TextColor3 = Color3.fromRGB(120, 120, 125) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.Parent = Container table.insert(activeObjects, lbl)
end

drawEspTab()
EspTabBtn.MouseButton1Click:Connect(function()
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255)
    CombatTabBtn.BackgroundColor3, CombatTabBtn.TextColor3 = Color3.fromRGB(20, 20, 25), Color3.fromRGB(150, 150, 150)
    drawEspTab()
end)
CombatTabBtn.MouseButton1Click:Connect(function()
    CombatTabBtn.BackgroundColor3, CombatTabBtn.TextColor3 = Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255)
    EspTabBtn.BackgroundColor3, EspTabBtn.TextColor3 = Color3.fromRGB(20, 20, 25), Color3.fromRGB(150, 150, 150)
    drawCombatTab()
end)
