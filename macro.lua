local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local targetParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

if targetParent:FindFirstChild("SmartMacroV5") then
    targetParent.SmartMacroV5:Destroy()
end

-- ==========================================
-- 1. ANTI-AFK (CHỐNG VĂNG GAME)
-- ==========================================
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- 2. TẠO GIAO DIỆN (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", targetParent)
ScreenGui.Name = "SmartMacroV5"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(100, 200, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🧠 SMART MACRO V5 (FIXED)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11

local StatusText = Instance.new("TextLabel", MainFrame)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 25)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Trạng thái: Sẵn sàng"
StatusText.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 10

local TargetTextBox = Instance.new("TextBox", MainFrame)
TargetTextBox.Size = UDim2.new(0.9, 0, 0, 26)
TargetTextBox.Position = UDim2.new(0.05, 0, 0, 48)
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

local RecBtn = createMobButton("🔴 BẮT ĐẦU GHI", 80, Color3.fromRGB(180, 50, 50))
local StopBtn = createMobButton("⏹ DỪNG GHI", 112, Color3.fromRGB(100, 100, 100))
local ToggleRunBtn = createMobButton("▶ CHẠY MACRO: [TẮT]", 144, Color3.fromRGB(50, 160, 50))
local SaveBtn = createMobButton("💾 LƯU FILE MACRO", 176, Color3.fromRGB(50, 100, 180))
local LoadBtn = createMobButton("📂 TẢI FILE MACRO", 208, Color3.fromRGB(100, 50, 180))

-- ==========================================
-- 3. HỆ THỐNG GIẢ LẬP CHUỘT & KHẮC PHỤC LỆCH TRÁI/PHẢI
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
                    local clickTarget = v
                    -- Nếu TextLabel nằm trong nút bấm, ưu tiên lấy khung chứa nút bên ngoài
                    if v:IsA("TextLabel") and v.Parent and (v.Parent:IsA("GuiButton") or v.Parent:IsA("ImageButton") or v.Parent:IsA("Frame")) then
                        clickTarget = v.Parent
                    end
                    
                    local pos = clickTarget.AbsolutePosition
                    local size = clickTarget.AbsoluteSize
                    
                    -- Tính toán chính xác tâm của phần tử
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
-- 4. QUẢN LÝ FILE & LOGIC MACRO
-- ==========================================
local recordedActions = {}
local isRecording = false
local isMacroRunning = false
local lastTick = 0
local fileName = "AnimeDefenders_Macro.json"

local function saveMacroToFile()
    if #recordedActions == 0 then
        StatusText.Text = "⚠️ Chưa có dữ liệu để lưu!"
        return
    end
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(recordedActions)
    end)
    if success and writefile then
        writefile(fileName, encoded)
        StatusText.Text = "💾 Đã lưu file thành công!"
    else
        StatusText.Text = "❌ Lỗi lưu file!"
    end
end

local function loadMacroFromFile()
    if readfile and isfile and isfile(fileName) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and type(decoded) == "table" then
            recordedActions = decoded
            StatusText.Text = "📂 Tải xong (" .. #recordedActions .. " hành động)"
        else
            StatusText.Text = "❌ Lỗi đọc định dạng file!"
        end
    else
        StatusText.Text = "⚠️ Không tìm thấy file lưu!"
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
        StatusText.Text = "⚠️ Vui lòng tắt chạy Macro trước khi ghi!"
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
        StatusText.Text = "⚠️ Đang ghi, không thể bật chạy!"
        return
    end
    
    isMacroRunning = not isMacroRunning
    if isMacroRunning then
        ToggleRunBtn.Text = "▶ CHẠY MACRO: [BẬT]"
        ToggleRunBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
        
        task.spawn(function()
            while isMacroRunning do
                if #recordedActions == 0 then
                    StatusText.Text = "⚠️ Danh sách trống, hãy tải/ghi macro!"
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
