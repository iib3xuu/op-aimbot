local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local aiming = false
local aimAssistEnabled = true
local currentTarget = nil
local aimRange = 100
local targetPart = "Head"
local aimPredictionEnabled = true
local predictionStrength = 1
local toggleCooldown = false
local cooldownTime = 3 
local guiLoaded = false

local backgroundColor = Color3.fromRGB(30, 30, 30)
local textColor = Color3.fromRGB(255, 255, 255)
local buttonColor = Color3.fromRGB(50, 50, 50)
local activeColor = Color3.fromRGB(0, 255, 0)
local inactiveColor = Color3.fromRGB(255, 0, 0)

local function setupGUI()
    if guiLoaded then return end
    guiLoaded = true

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimAssistGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0.35, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.325, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = backgroundColor
    mainFrame.BorderSizePixel = 0

    local frameUICorner = Instance.new("UICorner")
    frameUICorner.CornerRadius = UDim.new(0, 10)
    frameUICorner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = mainFrame
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = backgroundColor
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Ultimate Aim Assist"
    titleLabel.TextColor3 = textColor
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold

    local aimRangeLabel = Instance.new("TextLabel")
    aimRangeLabel.Parent = mainFrame
    aimRangeLabel.Size = UDim2.new(0.5, -10, 0.1, 0)
    aimRangeLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
    aimRangeLabel.BackgroundColor3 = backgroundColor
    aimRangeLabel.BorderSizePixel = 0
    aimRangeLabel.Text = "Aim Range:"
    aimRangeLabel.TextColor3 = textColor
    aimRangeLabel.TextScaled = true
    aimRangeLabel.Font = Enum.Font.Gotham

    local aimRangeSlider = Instance.new("TextBox")
    aimRangeSlider.Parent = mainFrame
    aimRangeSlider.Size = UDim2.new(0.4, -10, 0.1, 0)
    aimRangeSlider.Position = UDim2.new(0.55, 0, 0.2, 0)
    aimRangeSlider.BackgroundColor3 = buttonColor
    aimRangeSlider.BorderSizePixel = 0
    aimRangeSlider.Text = tostring(aimRange)
    aimRangeSlider.TextColor3 = textColor
    aimRangeSlider.TextScaled = true
    aimRangeSlider.Font = Enum.Font.Gotham

    aimRangeSlider.FocusLost:Connect(function()
        local newRange = tonumber(aimRangeSlider.Text)
        if newRange and newRange > 0 then
            aimRange = newRange
        else
            aimRangeSlider.Text = tostring(aimRange)
        end
    end)

    local targetPartLabel = Instance.new("TextLabel")
    targetPartLabel.Parent = mainFrame
    targetPartLabel.Size = UDim2.new(0.5, -10, 0.1, 0)
    targetPartLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
    targetPartLabel.BackgroundColor3 = backgroundColor
    targetPartLabel.BorderSizePixel = 0
    targetPartLabel.Text = "Target Part:"
    targetPartLabel.TextColor3 = textColor
    targetPartLabel.TextScaled = true
    targetPartLabel.Font = Enum.Font.Gotham

    local targetPartDropdown = Instance.new("TextBox")
    targetPartDropdown.Parent = mainFrame
    targetPartDropdown.Size = UDim2.new(0.4, -10, 0.1, 0)
    targetPartDropdown.Position = UDim2.new(0.55, 0, 0.35, 0)
    targetPartDropdown.BackgroundColor3 = buttonColor
    targetPartDropdown.BorderSizePixel = 0
    targetPartDropdown.Text = targetPart
    targetPartDropdown.TextColor3 = textColor
    targetPartDropdown.TextScaled = true
    targetPartDropdown.Font = Enum.Font.Gotham

    targetPartDropdown.FocusLost:Connect(function()
        local newPart = targetPartDropdown.Text
        if newPart == "Head" or newPart == "Torso" or newPart == "HumanoidRootPart" then
            targetPart = newPart
        else
            targetPartDropdown.Text = targetPart
        end
    end)

    local predictionButton = Instance.new("TextButton")
    predictionButton.Parent = mainFrame
    predictionButton.Size = UDim2.new(0.9, 0, 0.1, 0)
    predictionButton.Position = UDim2.new(0.05, 0, 0.5, 0)
    predictionButton.BackgroundColor3 = aimPredictionEnabled and activeColor or inactiveColor
    predictionButton.Text = "Prediction: " .. (aimPredictionEnabled and "On" or "Off")
    predictionButton.TextColor3 = textColor
    predictionButton.TextScaled = true
    predictionButton.Font = Enum.Font.GothamBold

    predictionButton.MouseButton1Click:Connect(function()
        aimPredictionEnabled = not aimPredictionEnabled
        predictionButton.BackgroundColor3 = aimPredictionEnabled and activeColor or inactiveColor
        predictionButton.Text = "Prediction: " .. (aimPredictionEnabled and "On" or "Off")
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = mainFrame
    statusLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
    statusLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
    statusLabel.BackgroundColor3 = backgroundColor
    statusLabel.BorderSizePixel = 0
    statusLabel.Text = "Status: Idle"
    statusLabel.TextColor3 = textColor
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
end

local function updateStatus(text)
    local gui = player.PlayerGui:FindFirstChild("AimAssistGUI")
    if gui then
        local statusLabel = gui:FindFirstChild("StatusLabel", true)
        if statusLabel then
            statusLabel.Text = "Status: " .. text
        end
    end
end

local function smoothAim(target)
    if target then
        local targetPosition = target.Position
        if aimPredictionEnabled and target.Parent and target.Parent:FindFirstChild("HumanoidRootPart") then
            local velocity = target.Parent.HumanoidRootPart.Velocity
            targetPosition = targetPosition + (velocity * predictionStrength)
        end
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

runService.RenderStepped:Connect(function()
    if aiming and currentTarget then
        smoothAim(currentTarget)
    end
end)

setupGUI()