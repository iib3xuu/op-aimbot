local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local aiming = false
local currentTarget = nil
local aimRange = 100 
local targetPart = "Head" 
local aimPredictionEnabled = true 
local predictionStrength = 1 
local guiLoaded = false

local function setupGUI()
    if guiLoaded then return end
    guiLoaded = true

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimAssistGUI"
    screenGui.ResetOnSpawn = false 
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = screenGui
    statusLabel.Size = UDim2.new(0.3, 0, 0.05, 0)
    statusLabel.Position = UDim2.new(0.35, 0, 0.85, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Text = "Idle"

    local aimRangeSlider = Instance.new("TextBox")
    aimRangeSlider.Name = "AimRangeSlider"
    aimRangeSlider.Parent = screenGui
    aimRangeSlider.Size = UDim2.new(0.2, 0, 0.05, 0)
    aimRangeSlider.Position = UDim2.new(0.4, 0, 0.75, 0)
    aimRangeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    aimRangeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimRangeSlider.TextScaled = true
    aimRangeSlider.Text = tostring(aimRange)
    aimRangeSlider.PlaceholderText = "Set Aim Range"

    aimRangeSlider.FocusLost:Connect(function()
        local newRange = tonumber(aimRangeSlider.Text)
        if newRange and newRange > 0 then
            aimRange = newRange
            statusLabel.Text = "Aim Range: " .. tostring(aimRange)
        else
            aimRangeSlider.Text = tostring(aimRange) 
        end
    end)

    local predictionToggle = Instance.new("TextButton")
    predictionToggle.Name = "PredictionToggle"
    predictionToggle.Parent = screenGui
    predictionToggle.Size = UDim2.new(0.2, 0, 0.05, 0)
    predictionToggle.Position = UDim2.new(0.4, 0, 0.65, 0)
    predictionToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    predictionToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    predictionToggle.TextScaled = true
    predictionToggle.Text = "Prediction: On"

    predictionToggle.MouseButton1Click:Connect(function()
        aimPredictionEnabled = not aimPredictionEnabled
        predictionToggle.Text = "Prediction: " .. (aimPredictionEnabled and "On" or "Off")
    end)

    local predictionStrengthSlider = Instance.new("TextBox")
    predictionStrengthSlider.Name = "PredictionStrengthSlider"
    predictionStrengthSlider.Parent = screenGui
    predictionStrengthSlider.Size = UDim2.new(0.2, 0, 0.05, 0)
    predictionStrengthSlider.Position = UDim2.new(0.4, 0, 0.55, 0)
    predictionStrengthSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    predictionStrengthSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    predictionStrengthSlider.TextScaled = true
    predictionStrengthSlider.Text = tostring(predictionStrength)
    predictionStrengthSlider.PlaceholderText = "Set Prediction Strength"

    predictionStrengthSlider.FocusLost:Connect(function()
        local newStrength = tonumber(predictionStrengthSlider.Text)
        if newStrength and newStrength > 0 then
            predictionStrength = newStrength
            statusLabel.Text = "Prediction Strength: " .. tostring(predictionStrength)
        else
            predictionStrengthSlider.Text = tostring(predictionStrength) 
        end
    end)
end

local function updateStatus(status, color)
    local gui = player.PlayerGui:FindFirstChild("AimAssistGUI")
    if gui then
        local statusLabel = gui:FindFirstChild("StatusLabel")
        if statusLabel then
            statusLabel.Text = status
            statusLabel.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
        end
    end
end

local function smoothAim(target)
    if target then
        local targetPosition = target.Position
        local cameraPosition = camera.CFrame.Position

        if aimPredictionEnabled and target.Parent and target.Parent:FindFirstChild("HumanoidRootPart") then
            local velocity = target.Parent.HumanoidRootPart.Velocity
            targetPosition = targetPosition + (velocity * predictionStrength)
        end

        local aimDirection = (targetPosition - cameraPosition).Unit
        camera.CFrame = CFrame.new(cameraPosition, cameraPosition + aimDirection)
    end
end

local function findClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild(targetPart) then
            local part = otherPlayer.Character[targetPart]
            local distance = (part.Position - player.Character.HumanoidRootPart.Position).Magnitude

            if distance <= aimRange then
                local screenPosition, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen and distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = part
                end
            end
        end
    end

    return closestPlayer
end

userInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        aiming = true
        updateStatus("Aiming...", Color3.fromRGB(0, 255, 0))
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        aiming = false
        updateStatus("Idle", Color3.fromRGB(0, 0, 0))
        currentTarget = nil
    end
end)

runService.RenderStepped:Connect(function()
    if aiming then
        if not currentTarget or not currentTarget:IsDescendantOf(workspace) then
            currentTarget = findClosestPlayer()
        end

        if currentTarget then
            smoothAim(currentTarget)
            updateStatus("Locked on: " .. currentTarget.Parent.Name, Color3.fromRGB(255, 255, 0))
        else
            updateStatus("No target found", Color3.fromRGB(255, 0, 0))
        end
    end
end)

setupGUI()