local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local targetParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("SmartMacroHub") then
    targetParent.SmartMacroHub:Destroy()
end

-- ==========================================
-- 1. BẬT ANTI-AFK (CHỐNG VĂNG GAME)
-- ==========================================
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("🛡️ Anti-AFK: Đã chặn game kick bạn ra ngoài.")
end)

-- ==========================================
-- 2. TẠO GIAO DIỆN (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", targetParent)
ScreenGui.Name = "SmartMacroHub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 200)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 200, 100)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🧠 SMART MACRO V3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

local StatusText = Instance.new("TextLabel", MainFrame)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 22)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Trạng thái: Sẵn sàng (Anti-AFK Bật)"
StatusText.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 10

-- Ô nhập chữ cần nhận diện
local TargetTextBox = Instance.new("TextBox", MainFrame)
TargetTextBox.Size = UDim2.new(0.9, 0, 0, 28)
TargetTextBox.Position = UDim2.new(0.05, 0, 0, 45)
TargetTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TargetTextBox.PlaceholderText = "Nhập chữ để qua màn (VD: Replay)"
TargetTextBox.Text = "Replay" -- Mặc định là Replay
TargetTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetTextBox.Font = Enum.Font.Gotham
TargetTextBox.TextSize = 11
Instance.new("UICorner", TargetTextBox).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", TargetTextBox).Color = Color3.fromRGB(150, 150, 150)

local function createMobButton(text, yPos, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local RecBtn = createMobButton("🔴 BẮT ĐẦU GHI", 80, Color3.fromRGB(180, 50, 50))
local StopBtn = createMobButton("⏹ DỪNG LẠI", 118, Color3.fromRGB(100, 100, 100))
local PlayBtn = createMobButton("▶ PHÁT LẠI (TỰ ĐỢI REPLAY)", 156, Color3.fromRGB(50, 160, 50))

-- ==========================================
-- 3. HÀM NHẬN DIỆN CHỮ VÀ BẤM NÚT
-- ==========================================
local guiInset = GuiService:GetGuiInset()
local offsetY = guiInset.Y

local function scanAndClickText(keyword)
    if keyword == "" then return false end
    local pGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    
    for _, v in pairs(pGui:GetDescendants()) do
        -- Quét các thành phần giao diện có chữ và đang hiện trên màn hình
        if pcall(function() return v.Text end) and v.Visible then
            if type(v.Text) == "string" and string.find(string.lower(v.Text), string.lower(keyword)) then
                if v.AbsolutePosition.X > 0 and v.AbsolutePosition.Y > 0 then
                    
                    -- Lấy tâm của nút đó để click
                    local clickTarget = v
                    if v:IsA("TextLabel") and v.Parent and (v.Parent:IsA("GuiButton") or v.Parent:IsA("ImageButton")) then
                        clickTarget = v.Parent
                    end
                    
                    local x = clickTarget.AbsolutePosition.X + (clickTarget.AbsoluteSize.X / 2)
                    local y = clickTarget.AbsolutePosition.Y + (clickTarget.AbsoluteSize.Y / 2) + offsetY
                    
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                    return true
                end
            end
        end
    end
    return false
end

-- ==========================================
-- 4. HỆ THỐNG GHI VÀ XỬ LÝ MACRO
-- ==========================================
local recordedActions = {}
local isRecording = false
local isPlaying = false
local lastTick = 0

UserInputService.TouchStarted:Connect(function(touch, processed)
    if isRecording then
        local touchPos = touch.Position
        
        -- BỘ LỌC CHỐNG CHẠM NHẦM VÀO MENU
        local menuPos = MainFrame.AbsolutePosition
        local menuSize = MainFrame.AbsoluteSize
        local minX = menuPos.X
        local maxX = menuPos.X + menuSize.X
        local minY = menuPos.Y + offsetY
        local maxY = menuPos.Y + offsetY + menuSize.Y
        
        -- Nếu ngón tay chạm vào Menu -> Không ghi lại điểm chạm đó
        if touchPos.X >= minX and touchPos.X <= maxX and touchPos.Y >= minY and touchPos.Y <= maxY then
            return 
        end
        
        local delayTime = tick() - lastTick
        lastTick = tick()
        local correctedY = touchPos.Y + offsetY
        
        table.insert(recordedActions, { Delay = delayTime, X = touchPos.X, Y = correctedY })
        StatusText.Text = "Đang ghi: " .. #recordedActions .. " điểm"
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    if isPlaying then return end
    recordedActions = {}
    isRecording = true
    lastTick = tick()
    RecBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    StatusText.Text = "🔴 ĐANG GHI THAO TÁC..."
end)

StopBtn.MouseButton1Click:Connect(function()
    if not isRecording then return end
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

    task.spawn(function()
        while isPlaying do
            -- BƯỚC 1: Xây lính theo Macro đã ghi
            StatusText.Text = "🔁 Đang xây đội hình..."
            for _, action in ipairs(recordedActions) do
                if not isPlaying then break end
                task.wait(action.Delay)
                
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(action.X, action.Y, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(action.X, action.Y, 0, false, game, 1)
                end)
            end
            
            -- BƯỚC 2: Chờ chữ xuất hiện (Nhận diện Replay/Next)
            if not isPlaying then break end
            local targetWord = TargetTextBox.Text
            StatusText.Text = "🔍 Đang đợi chữ: " .. targetWord
            
            while isPlaying do
                task.wait(2) -- Quét màn hình mỗi 2 giây
                if scanAndClickText(targetWord) then
                    StatusText.Text = "✅ Đã bấm " .. targetWord .. "! Đợi load map..."
                    task.wait(12) -- Nghỉ 12 giây cho game tải bản đồ mới hoàn tất
                    break -- Thoát vòng chờ, lặp lại vòng mới
                end
            end
        end
    end)
end)
