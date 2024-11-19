local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = screenGui
statusLabel.Size = UDim2.new(0.3, 0, 0.05, 0)
statusLabel.Position = UDim2.new(0.35, 0, 0.9, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Text = "Idle"
statusLabel.Visible = true

local aiming = false
local currentTarget = nil
local aimRange = 100 

local function updateStatus(status, color)
    statusLabel.Text = status
    statusLabel.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
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
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            local distance = (head.Position - player.Character.HumanoidRootPart.Position).Magnitude

            if distance <= aimRange then
                local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen and distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = head
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
