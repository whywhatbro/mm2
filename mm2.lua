-- Macro Recorder dành riêng cho Điện Thoại (Mobile)
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local targetParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("MobileMacroHub") then
    targetParent.MobileMacroHub:Destroy()
end

-- 1. TẠO GIAO DIỆN NỔI GỌN NHẸ TRÊN MÀN HÌNH
local ScreenGui = Instance.new("ScreenGui", targetParent)
ScreenGui.Name = "MobileMacroHub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(100, 200, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "📱 MOBILE MACRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

local StatusText = Instance.new("TextLabel", MainFrame)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 25)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Trạng thái: Sẵn sàng"
StatusText.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 11

local function createMobButton(text, yPos, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local RecBtn = createMobButton("🔴 BẮT ĐẦU GHI", 50, Color3.fromRGB(180, 50, 50))
local StopBtn = createMobButton("⏹ DỪNG LẠI", 82, Color3.fromRGB(100, 100, 100))
local PlayBtn = createMobButton("▶ PHÁT LẠI (VÒNG LẶP)", 114, Color3.fromRGB(50, 160, 50))

-- 2. HỆ THỐNG GHI NHẬN CHẠM (TOUCH) TRÊN DI ĐỘNG
local recordedActions = {}
local isRecording = false
local isPlaying = false
local lastTick = 0

UserInputService.TouchStarted:Connect(function(touch, processed)
    if isRecording then
        local delayTime = tick() - lastTick
        lastTick = tick()
        table.insert(recordedActions, {
            Delay = delayTime,
            X = touch.Position.X,
            Y = touch.Position.Y
        })
        StatusText.Text = "Đang ghi: " .. #macroData .. " điểm"
    end
end)

-- 3. XỬ LÝ SỰ KIỆN NÚT BẤM
RecBtn.MouseButton1Click:Connect(function()
    if isPlaying then return end
    recordedActions = {}
    isRecording = true
    lastTick = tick()
    RecBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    StatusText.Text = "🔴 ĐANG GHI THAO TÁC..."
end)

StopBtn.MouseButton1Click:Connect(function()
    isRecording = false
    isPlaying = false
    RecBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    PlayBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
    StatusText.Text = "Đã lưu " .. #recordedActions .. " hành động."
end)

PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying or #recordedActions == 0 then return end
    isPlaying = true
    PlayBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
    StatusText.Text = "🔁 Đang lặp lại macro..."

    task.spawn(function()
        while isPlaying do
            for _, action in ipairs(recordedActions) do
                if not isPlaying then break end
                task.wait(action.Delay)
                
                pcall(function()
                    -- Giả lập chạm màn hình điện thoại tại tọa độ X, Y đã ghi
                    VirtualInputManager:SendMouseButtonEvent(action.X, action.Y, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(action.X, action.Y, 0, false, game, 1)
                end)
            end
            task.wait(1.5) -- Nghỉ 1.5 giây giữa mỗi vòng lặp trận đấu
        end
    end)
end)
