-- MM2 Custom Helper V2 (Upgraded & Optimized)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. KHỞI TẠO GIAO DIỆN (CUSTOM GUI)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local targetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("MM2_CustomHubV2") then
    targetParent.MM2_CustomHubV2:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", targetParent)
ScreenGui.Name = "MM2_CustomHubV2"
ScreenGui.ResetOnSpawn = false

-- Nút Tắt/Bật Menu
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 85, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Text = "MENU MM2"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(255, 150, 100)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 330)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Hình nền tùy chỉnh (Thay ID vào đây)
local BackgroundImage = Instance.new("ImageLabel", MainFrame)
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Image = "rbxassetid://13583279541" 
BackgroundImage.ImageTransparency = 0.4
BackgroundImage.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 10)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TabContainer = Instance.new("ScrollingFrame", MainFrame)
TabContainer.Position = UDim2.new(0, 10, 0, 15)
TabContainer.Size = UDim2.new(0.96, 0, 0.9, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", TabContainer)
UIList.Padding = UDim.new(0, 6)

local function createToggle(text, callback)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. text .. ": [TẮT]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local isOn = false
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        btn.Text = "  " .. text .. (isOn and ": [BẬT]" or ": [TẮT]")
        btn.TextColor3 = isOn and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(200, 200, 200)
        callback(isOn)
    end)
    return btn
end

-- ==========================================
-- 2. HỆ THỐNG ESP (SỬA LỖI LAG & GIỚI HẠN)
-- ==========================================
local function checkRole(player)
    if not player or not player.Character then return "Innocent" end
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    
    if (char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife")) then return "Murderer" end
    if (char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

local espConfig = {All = false, Murder = false, Sheriff = false, Innocent = false}

RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local role = checkRole(p)
                local hl = p.Character:FindFirstChild("MM2_ESP")
                
                local show = espConfig.All or (espConfig.Murder and role == "Murderer") or (espConfig.Sheriff and role == "Sheriff") or (espConfig.Innocent and role == "Innocent")
                
                if show then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "MM2_ESP"
                        hl.Parent = p.Character
                        hl.FillTransparency = 0.5
                    end
                    if role == "Murderer" then hl.FillColor = Color3.fromRGB(255, 30, 30)
                    elseif role == "Sheriff" then hl.FillColor = Color3.fromRGB(30, 150, 255)
                    else hl.FillColor = Color3.fromRGB(30, 255, 100) end
                elseif hl then
                    hl:Destroy()
                end
            end
        end
    end)
end)

createToggle("👁️ ESP Tất Cả", function(v) espConfig.All = v end)
createToggle("🔴 ESP Kẻ Sát Nhân", function(v) espConfig.Murder = v end)
createToggle("🔵 ESP Cảnh Sát", function(v) espConfig.Sheriff = v end)
createToggle("🟢 ESP Dân Thường", function(v) espConfig.Innocent = v end)

-- ==========================================
-- 3. CƠ CHẾ NÚT ẢO DI ĐỘNG CHUẨN (GIỮ 2 GIÂY KÉO)
-- ==========================================
local function createVirtualButton(name, color, pos)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Name = name
    btn.Size = UDim2.new(0, 65, 0, 65)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Visible = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(255, 255, 255)
    return btn
end

local ShootBtn = createVirtualButton("SHOOT", Color3.fromRGB(200, 50, 50), UDim2.new(0.8, 0, 0.4, 0))
local ThrowBtn = createVirtualButton("THROW", Color3.fromRGB(150, 50, 200), UDim2.new(0.8, 0, 0.6, 0))

local function setupDraggable(button, clickAction)
    local holding, dragging = false, false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = true
            dragStart = input.Position
            startPos = button.Position
            
            task.spawn(function()
                task.wait(2)
                if holding then
                    dragging = true
                    button.BackgroundColor3 = Color3.fromRGB(255, 200, 50) -- Đổi màu vàng khi có thể kéo
                end
            end)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = false
            if dragging then
                dragging = false
                button.BackgroundColor3 = button.Name == "SHOOT" and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(150, 50, 200)
            else
                clickAction() -- Kích hoạt chức năng bắn/ném nếu bấm nhanh dưới 2s
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- 4. AIMBOT, RAYCAST & AUTO-SHOOT TỐI ƯU
-- ==========================================
local aimPart = "HumanoidRootPart"
local partsList = {{"Head", "ĐẦU"}, {"HumanoidRootPart", "THÂN"}, {"RightLowerLeg", "CHÂN"}}
local pIndex = 2

local PartBtn = Instance.new("TextButton", TabContainer)
PartBtn.Size = UDim2.new(1, -10, 0, 32)
PartBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
PartBtn.Text = "🎯 Vị trí ngắm: [THÂN]"
PartBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
PartBtn.Font = Enum.Font.GothamMedium
PartBtn.TextSize = 11
Instance.new("UICorner", PartBtn).CornerRadius = UDim.new(0, 6)
PartBtn.MouseButton1Click:Connect(function()
    pIndex = (pIndex % #partsList) + 1
    aimPart = partsList[pIndex][1]
    PartBtn.Text = "🎯 Vị trí ngắm: [" .. partsList[pIndex][2] .. "]"
end)

local function checkVisible(targetChar)
    if not targetChar or not targetChar:FindFirstChild(aimPart) or not LocalPlayer.Character then return false end
    local head = LocalPlayer.Character:FindFirstChild("Head")
    if not head then return false end
    
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    
    local result = Workspace:Raycast(head.Position, targetChar[aimPart].Position - head.Position, ray)
    return result == nil
end

local function triggerShootAction()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and checkRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild(aimPart) then
            -- Chĩa thẳng tâm (Camera) vào mục tiêu mượt mà
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character[aimPart].Position)
            -- Kích hoạt súng
            local gun = LocalPlayer.Character:FindFirstChild("Gun")
            if gun then gun:Activate() end
        end
    end
end

local function triggerThrowAction()
    local target, minDist = nil, math.huge
    local targetInvisible, minInvDist = nil, math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and checkRole(p) ~= "Murderer" and p.Character and p.Character:FindFirstChild(aimPart) then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if checkVisible(p.Character) then
                if dist < minDist then minDist = dist; target = p.Character end
            else
                if dist < minInvDist then minInvDist = dist; targetInvisible = p.Character end
            end
        end
    end
    
    local finalTarget = target or targetInvisible
    if finalTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, finalTarget[aimPart].Position)
        local knife = LocalPlayer.Character:FindFirstChild("Knife")
        if knife then knife:Activate() end
    end
end

setupDraggable(ShootBtn, triggerShootAction)
setupDraggable(ThrowBtn, triggerThrowAction)

createToggle("🎯 Bật Nút Bắn Ảo (Sheriff)", function(v) ShootBtn.Visible = v end)
createToggle("🗡️ Bật Nút Ném Dao (Murderer)", function(v) ThrowBtn.Visible = v end)

-- Shiftlock / Auto-Shoot
local isShiftLock = false
local isAutoShoot = false

createToggle("🔒 ShiftLock Ngắm Tự Động", function(v) isShiftLock = v end)
createToggle("⚡ Tự Động Bắn (Chỉ khi qua tường)", function(v) isAutoShoot = v end)

RunService.RenderStepped:Connect(function()
    if isShiftLock or isAutoShoot then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and checkRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild(aimPart) then
                    if checkVisible(p.Character) then
                        if isShiftLock then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character[aimPart].Position)
                        end
                        if isAutoShoot and LocalPlayer.Character:FindFirstChild("Gun") then
                            LocalPlayer.Character.Gun:Activate()
                        end
                    end
                end
            end
        end)
    end
end)
