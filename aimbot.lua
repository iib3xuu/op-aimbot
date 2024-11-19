local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local aiming = false
local currentTarget = nil
local aimRange = 100 
local targetPart = "Head" 
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

    local targetPartDropdown = Instance.new("TextBox")
    targetPartDropdown.Name = "TargetPartDropdown"
    targetPartDropdown.Parent = screenGui
    targetPartDropdown.Size = UDim2.new(0.2, 0, 0.05, 0)
    targetPartDropdown.Position = UDim2.new(0.4, 0, 0.65, 0)
    targetPartDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    targetPartDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetPartDropdown.TextScaled = true
    targetPartDropdown.Text = targetPart
    targetPartDropdown.PlaceholderText = "Set Target Part"

    targetPartDropdown.FocusLost:Connect(function()
        local newPart = targetPartDropdown.Text
        if newPart == "Head" or newPart == "Torso" or newPart == "HumanoidRootPart" then
            targetPart = newPart
            statusLabel.Text = "Targeting: " .. targetPart
        else
            targetPartDropdown.Text = targetPart 
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