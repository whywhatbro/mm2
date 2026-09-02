-- MM2 Custom UI & Advanced Role Helper
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. THIẾT KẾ GIAO DIỆN HÌNH NỀN TỰ LÀM (CUSTOM GUI)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local targetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("MM2_CustomHub") then
    targetParent.MM2_CustomHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", targetParent)
ScreenGui.Name = "MM2_CustomHub"
ScreenGui.ResetOnSpawn = false

-- Nút Bật/Tắt Menu Chính
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "MENU MM2"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(255, 200, 100)

-- Khung Menu Chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 120, 150)

-- Hình nền Custom (Dán ID hình ảnh Roblox của bạn vào đây)
local BackgroundImage = Instance.new("ImageLabel", MainFrame)
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Image = "rbxassetid://13583279541" -- Thay ID ảnh của bạn tại đây
BackgroundImage.ImageTransparency = 0.35 -- Mờ hình để nổi chữ
BackgroundImage.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 10)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Tiêu đề Menu
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Header.BackgroundTransparency = 0.4
Header.Text = "  🗡️ MURDER MYSTERY 2 - CUSTOM HELPER"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 12
Header.TextXAlignment = Enum.TextXAlignment.Left

-- Container chứa các Tab
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.Size = UDim2.new(0.96, 0, 0.83, 0)
TabContainer.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", TabContainer)
UIList.Padding = UDim.new(0, 6)

-- Hàm tạo Button Toggle tùy chỉnh
local function createToggleBtn(text, callback)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.BackgroundTransparency = 0.3
    btn.Text = "  " .. text .. ": [TẮT]"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = "  " .. text .. (enabled and ": [BẬT]" or ": [TẮT]")
        btn.TextColor3 = enabled and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(220, 220, 220)
        callback(enabled)
    end)
    return btn
end

-- ==========================================
-- 2. HỆ THỐNG PHÂN LOẠI VAI TRÒ & ESP
-- ==========================================
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    if (char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    elseif (char:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local espState = { All = false, Murder = false, Sheriff = false, Innocent = false }

local function updateESP()
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local role = getRole(target)
            local highlight = target.Character:FindFirstChild("CustomESP")
            
            local shouldShow = espState.All or 
                (espState.Murder and role == "Murderer") or
                (espState.Sheriff and role == "Sheriff") or
                (espState.Innocent and role == "Innocent")
                
            if shouldShow then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "CustomESP"
                    highlight.Parent = target.Character
                    highlight.FillTransparency = 0.5
                end
                if role == "Murderer" then
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                elseif role == "Sheriff" then
                    highlight.FillColor = Color3.fromRGB(50, 150, 255)
                else
                    highlight.FillColor = Color3.fromRGB(50, 255, 100)
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

createToggleBtn("👁️ ESP Tất Cả (ESP All)", function(v) espState.All = v end)
createToggleBtn("🔴 ESP Kẻ Sát Nhân (Murderer)", function(v) espState.Murder = v end)
createToggleBtn("🔵 ESP Cảnh Sát (Sheriff)", function(v) espState.Sheriff = v end)
createToggleBtn("🟢 ESP Dân Thường (Innocent)", function(v) espState.Innocent = v end)

-- ==========================================
-- 3. CHỨC NĂNG SHERIFF (BẮN & KHOẢNG CÁCH)
-- ==========================================
local targetPartName = "HumanoidRootPart" -- Mặc định: Thân (Torso)

-- Kiểm tra vật cản (Raycast Check)
local function isVisible(targetChar)
    if not targetChar or not targetChar:FindFirstChild(targetPartName) or not LocalPlayer.Character then return false end
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local targetPos = targetChar[targetPartName].Position
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    
    local result = Workspace:Raycast(origin, targetPos - origin, rayParams)
    return result == nil -- Trả về true nếu KHÔNG có vật cản
end

local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" and p.Character then
            return p.Character
        end
    end
    return nil
end

-- NÚT BẮN ẢO DI ĐỘNG (DỪNG 2s ĐỂ KÉO)
local ShootBtn = Instance.new("TextButton", ScreenGui)
ShootBtn.Size = UDim2.new(0, 65, 0, 65)
ShootBtn.Position = UDim2.new(0.8, 0, 0.5, 0)
ShootBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ShootBtn.Text = "SHOOT"
ShootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootBtn.Font = Enum.Font.GothamBold
ShootBtn.TextSize = 12
ShootBtn.Visible = false
Instance.new("UICorner", ShootBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ShootBtn).Color = Color3.fromRGB(255, 255, 255)

local holdTime = 0
local isDragging = false
local touchStartPos = nil

ShootBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        holdTime = tick()
        touchStartPos = input.Position
        
        task.spawn(function()
            task.wait(2)
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:GetFocusedTextBox() == nil then
                if (tick() - holdTime) >= 2 then
                    isDragging = true
                    ShootBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                end
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        ShootBtn.Position = UDim2.new(0, input.Position.X - 32, 0, input.Position.Y - 32)
    end
end)

local function triggerShoot()
    local murdererChar = getMurderer()
    if murdererChar and murdererChar:FindFirstChild(targetPartName) then
        local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
        if gun then
            -- Xử lý bắn tự động vào vị trí mục tiêu
            local targetPos = murdererChar[targetPartName].Position
            gun:Activate()
        end
    end
end

ShootBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isDragging then
            isDragging = false
            ShootBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        else
            if (tick() - holdTime) < 2 then
                triggerShoot()
            end
        end
    end
end)

createToggleBtn("🎯 Bật Nút Bắn Ảo (Virtual Shoot Button)", function(v) ShootBtn.Visible = v end)

-- Chọn vị trí bắn (Đầu / Thân / Chân)
local PartBtn = Instance.new("TextButton", TabContainer)
PartBtn.Size = UDim2.new(1, 0, 0, 32)
PartBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
PartBtn.Text = "🎯 Vị trí ngắm: [THÂN (TORSO)]"
PartBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
PartBtn.Font = Enum.Font.GothamMedium
PartBtn.TextSize = 11
Instance.new("UICorner", PartBtn).CornerRadius = UDim.new(0, 6)

local parts = { { "Head", "ĐẦU" }, { "HumanoidRootPart", "THÂN" }, { "RightLowerLeg", "CHÂN" } }
local partIndex = 2
PartBtn.MouseButton1Click:Connect(function()
    partIndex = (partIndex % #parts) + 1
    targetPartName = parts[partIndex][1]
    PartBtn.Text = "🎯 Vị trí ngắm: [" .. parts[partIndex][2] .. "]"
end)

-- ShiftLock Aimbot & Auto-Shoot khi thấy Murderer
local autoShootVisible = false
local shiftLockAim = false

createToggleBtn("🔒 ShiftLock Aim Tự Động Ngắm", function(v) shiftLockAim = v end)
createToggleBtn("⚡ Auto-Shoot Khi Thấy Murderer (Check Tường)", function(v) autoShootVisible = v end)

RunService.RenderStepped:Connect(function()
    local mur = getMurderer()
    if mur and isVisible(mur) then
        if shiftLockAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = mur[targetPartName].Position
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(targetPos.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, targetPos.Z))
        end
        
        if autoShootVisible then
            triggerShoot()
        end
    end
end)

-- ==========================================
-- 4. CHỨC NĂNG MURDERER (NẾM DAO TỰ ĐỘNG)
-- ==========================================
local ThrowBtn = Instance.new("TextButton", ScreenGui)
ThrowBtn.Size = UDim2.new(0, 65, 0, 65)
ThrowBtn.Position = UDim2.new(0.8, 0, 0.65, 0)
ThrowBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
ThrowBtn.Text = "THROW"
ThrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThrowBtn.Font = Enum.Font.GothamBold
ThrowBtn.TextSize = 11
ThrowBtn.Visible = false
Instance.new("UICorner", ThrowBtn).CornerRadius = UDim.new(1, 0)

createToggleBtn("🗡️ Nút Ném Dao Mục Tiêu Gần Nhất", function(v) ThrowBtn.Visible = v end)

ThrowBtn.MouseButton1Click:Connect(function()
    local nearestChar = nil
    local minDistance = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if isVisible(p.Character) then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    nearestChar = p.Character
                end
            end
        end
    end
    
    if nearestChar then
        local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
        if knife then
            knife:Activate()
        end
    end
end)
