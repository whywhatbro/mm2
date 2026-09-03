local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local targetParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("SmartMacroV6") then
    targetParent.SmartMacroV6:Destroy()
end

-- ==========================================
-- 1. ANTI-AFK
-- ==========================================
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- 2. GIAO DIỆN & MENU THU GỌN (TOGGLE)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", targetParent)
ScreenGui.Name = "SmartMacroV6"
ScreenGui.ResetOnSpawn = false

-- Nút thu gọn / mở rộng Menu nổi trên màn hình
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleMenuBtn.Text = "📱"
ToggleMenuBtn.TextSize = 20
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true
Instance.new("UICorner", ToggleMenuBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleMenuBtn).Color = Color3.fromRGB(100, 200, 255)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 325)
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(100, 200, 255)

-- Tính năng ẩn/hiện bảng điều khiển
local menuVisible = true
ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
    ToggleMenuBtn.Text = menuVisible and "📱" : "👁️"
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🧠 SMART MACRO V6 (MULTI-SLOT)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10

local StatusText = Instance.new("TextLabel", MainFrame)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 25)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Trạng thái: Sẵn sàng"
StatusText.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 10

-- Ô nhập tên Slot / File Macro để quản lý nhiều bản
local SlotTextBox = Instance.new("TextBox", MainFrame)
SlotTextBox.Size = UDim2.new(0.9, 0, 0, 26)
SlotTextBox.Position = UDim2.new(0.05, 0, 0, 48)
SlotTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SlotTextBox.PlaceholderText = "Tên Slot Macro (VD: Map1, FarmGold)"
SlotTextBox.Text = "MacroSlot1"
SlotTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SlotTextBox.Font = Enum.Font.Gotham
SlotTextBox.TextSize = 11
Instance.new("UICorner", SlotTextBox).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", SlotTextBox).Color = Color3.fromRGB(150, 150, 150)

-- Ô nhập chữ nhận diện qua màn
local TargetTextBox = Instance.new("TextBox", MainFrame)
TargetTextBox.Size = UDim2.new(0.9, 0, 0, 26)
TargetTextBox.Position = UDim2.new(0.05, 0, 0, 78)
TargetTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TargetTextBox.PlaceholderText = "Chữ cần nhận diện (VD: Replay)"
TargetTextBox.Text = "Replay"
TargetTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetTextBox.Font = Enum.Font.Gotham
TargetTextBox.TextSize = 11
Instance.new("UICorner", TargetTextBox).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", TargetTextBox).Color = Color3.fromRGB(150, 150, 150)

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

local RecBtn = createMobButton("🔴 BẮT ĐẦU GHI", 110, Color3.fromRGB(180, 50, 50))
local StopBtn = createMobButton("⏹ DỪNG GHI & LƯU", 142, Color3.fromRGB(100, 100, 100))
local ToggleRunBtn = createMobButton("▶ CHẠY MACRO: [TẮT]", 174, Color3.fromRGB(50, 160, 50))
local SaveBtn = createMobButton("💾 LƯU VÀO SLOT", 206, Color3.fromRGB(50, 100, 180))
local LoadBtn = createMobButton("📂 TẢI TỪ SLOT", 238, Color3.fromRGB(100, 50, 180))

-- ==========================================
-- 3. FIX TRIỆT ĐỂ LỆCH TÂM NÚT (DÙNG ABSOLUTE SIZE & VECTOR THỰC TẾ)
-- ==========================================
local guiInset = GuiService:GetGuiInset()
local offsetY = guiInset.Y

local function simulatedClick(x, y)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.08)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

local function scanAndClickText(keyword)
    if keyword == "" then return false end
    local pGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    
    for _, v in pairs(pGui:GetDescendants()) do
        if pcall(function() return v.Text end) and v.Visible then
            if type(v.Text) == "string" and string.find(string.lower(v.Text), string.lower(keyword)) then
                if v.AbsolutePosition.X > 0 and v.AbsolutePosition.Y > 0 then
                    local targetObj = v
                    -- Quét ngược lên tìm đối tượng Button hoặc Frame chứa toàn bộ nút bấm thay vì chỉ bám vào text
                    local parent = v.Parent
                    while parent and parent ~= pGui do
                        if parent:IsA("GuiButton") or parent:IsA("ImageButton") or parent:IsA("TextButton") then
                            targetObj = parent
                            break
                        end
                        parent = parent.Parent
                    end
                    
                    local pos = targetObj.AbsolutePosition
                    local size = targetObj.AbsoluteSize
                    
                    -- Lấy chính xác tâm tuyệt đối của nút bấm trên màn hình điện thoại
                    local centerX = pos.X + (size.X / 2)
                    local centerY = pos.Y + (size.Y / 2) + offsetY
                    
                    simulatedClick(centerX, centerY)
                    return true
                end
            end
        end
    end
    return false
end

-- ==========================================
-- 4. HỆ THỐNG QUẢN LÝ MULTI-SLOT FILE
-- ==========================================
local recordedActions = {}
local isRecording = false
local isMacroRunning = false
local lastTick = 0

local function getFileName()
    local slotName = SlotTextBox.Text
    if slotName == "" then slotName = "DefaultMacro" end
    -- Loại bỏ ký tự đặc biệt tránh lỗi tên file trên một số executor
    slotName = string.gsub(slotName, "[^%w%_]", "")
    return "Macro_" .. slotName .. ".json"
end

local function saveMacroToFile()
    if #recordedActions == 0 then
        StatusText.Text = "⚠️ Không có dữ liệu để lưu!"
        return
    end
    local filename = getFileName()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(recordedActions)
    end)
    if success and writefile then
        writefile(filename, encoded)
        StatusText.Text = "💾 Đã lưu: " .. filename
    else
        StatusText.Text = "❌ Lỗi ghi file trên Executor!"
    end
end

local function loadMacroFromFile()
    local filename = getFileName()
    if readfile and isfile and isfile(filename) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(filename))
        end)
        if success and type(decoded) == "table" then
            recordedActions = decoded
            StatusText.Text = "📂 Đã tải slot: " .. filename .. " (" .. #recordedActions .. " hành động)"
        else
            StatusText.Text = "❌ Lỗi đọc cấu trúc file!"
        end
    else
        StatusText.Text = "⚠️ Slot không tồn tại!"
    end
end

UserInputService.TouchStarted:Connect(function(touch, processed)
    if isRecording then
        local touchPos = touch.Position
        local menuPos = MainFrame.AbsolutePosition
        local menuSize = MainFrame.AbsoluteSize
        
        if touchPos.X >= menuPos.X and touchPos.X <= (menuPos.X + menuSize.X) and 
           touchPos.Y >= (menuPos.Y + offsetY) and touchPos.Y <= (menuPos.Y + offsetY + menuSize.Y) then
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
    if isMacroRunning then
        StatusText.Text = "⚠️ Hãy tắt chạy Macro trước!"
        return
    end
    recordedActions = {}
    isRecording = true
    lastTick = tick()
    RecBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    StatusText.Text = "🔴 ĐANG GHI THAO TÁC..."
end)

StopBtn.MouseButton1Click:Connect(function()
    if not isRecording then return end
    isRecording = false
    RecBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    StatusText.Text = "⏹ Đã dừng ghi (" .. #recordedActions .. " điểm)."
    saveMacroToFile()
end)

ToggleRunBtn.MouseButton1Click:Connect(function()
    if isRecording then
        StatusText.Text = "⚠️ Đang ghi, không thể chạy!"
        return
    end
    
    isMacroRunning = not isMacroRunning
    if isMacroRunning then
        ToggleRunBtn.Text = "▶ CHẠY MACRO: [BẬT]"
        ToggleRunBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        
        task.spawn(function()
            while isMacroRunning do
                if #recordedActions == 0 then
                    StatusText.Text = "⚠️ Chưa có dữ liệu! Hãy Tải hoặc Ghi."
                    isMacroRunning = false
                    ToggleRunBtn.Text = "▶ CHẠY MACRO: [TẮT]"
                    ToggleRunBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
                    break
                end
                
                StatusText.Text = "🔁 Đang thực thi dựng lính..."
                for _, action in ipairs(recordedActions) do
                    if not isMacroRunning then break end
                    task.wait(action.Delay)
                    simulatedClick(action.X, action.Y)
                end
                
                if not isMacroRunning then break end
                local targetWord = TargetTextBox.Text
                StatusText.Text = "🔍 Đang đợi chữ: " .. targetWord
                
                while isMacroRunning do
                    task.wait(2)
                    if scanAndClickText(targetWord) then
                        StatusText.Text = "✅ Đã bấm nút " .. targetWord .. "! Đợi load map..."
                        task.wait(12)
                        break
                    end
                end
            end
        end)
    else
        ToggleRunBtn.Text = "▶ CHẠY MACRO: [TẮT]"
        ToggleRunBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
        StatusText.Text = "⏹ Đã tắt vòng lặp Macro."
    end
end)

SaveBtn.MouseButton1Click:Connect(saveMacroToFile)
LoadBtn.MouseButton1Click:Connect(loadMacroFromFile)
