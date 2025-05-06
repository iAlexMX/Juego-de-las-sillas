local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local workspace = game.Workspace
local chairsFolder = workspace:WaitForChild("Chairs")
local ui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0.5, -110, 0.5, -100)
frame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)

local teleportButton = Instance.new("TextButton", frame)
teleportButton.Size = UDim2.new(1, 0, 0, 50)
teleportButton.Position = UDim2.new(0, 0, 0, 10)
teleportButton.Text = "Teletransportarse a Silla"
teleportButton.BackgroundColor3 = Color3.new(0, 1, 0)

local walkButton = Instance.new("TextButton", frame)
walkButton.Size = UDim2.new(1, 0, 0, 50)
walkButton.Position = UDim2.new(0, 0, 0, 70)
walkButton.Text = "Caminar hacia Silla"
walkButton.BackgroundColor3 = Color3.new(0, 0, 1)

local killGuiButton = Instance.new("TextButton", frame)
killGuiButton.Size = UDim2.new(1, 0, 0, 50)
killGuiButton.Position = UDim2.new(0, 0, 0, 130)
killGuiButton.Text = "Kill GUI"
killGuiButton.BackgroundColor3 = Color3.new(1, 0, 0)

local minimizeButton = Instance.new("TextButton", frame)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(0, 180, 0, 5)
minimizeButton.Text = "-"
minimizeButton.BackgroundColor3 = Color3.new(1, 0, 0)

local maximizeButton = Instance.new("TextButton", ui)
maximizeButton.Size = UDim2.new(0, 100, 0, 50)
maximizeButton.Position = UDim2.new(0.5, -50, 0.5, -25)
maximizeButton.Text = "Maximizar"
maximizeButton.BackgroundColor3 = Color3.new(0, 1, 0)
maximizeButton.Visible = false

local creditsLabel = Instance.new("TextLabel", frame)
creditsLabel.Size = UDim2.new(1, 0, 0, 30)
creditsLabel.Position = UDim2.new(0, 0, 1, -30)
creditsLabel.Text = "Créditos a iAlexMX"
creditsLabel.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
creditsLabel.TextColor3 = Color3.new(1, 1, 1)
creditsLabel.TextScaled = true
creditsLabel.TextStrokeTransparency = 0.5

local function getNearestChair()
    local nearestChair = nil
    local shortestDistance = math.huge
    
    for _, chair in ipairs(chairsFolder:GetChildren()) do
        if chair:IsA("Model") and chair:FindFirstChild("Seat") then
            local seat = chair.Seat
            
            if not seat.Occupant then
                local distance = (character.HumanoidRootPart.Position - seat.Position).magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestChair = seat
                end
            end
        end
    end
    
    return nearestChair
end

local teleportActive = false
local teleportConnection

local function teleportToChair()
    teleportConnection = game:GetService("RunService").Stepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local chair = getNearestChair()
            if chair then

                if chair.Position.Y > character.HumanoidRootPart.Position.Y + 5 then
                    character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                character:SetPrimaryPartCFrame(chair.CFrame)
            end
        end
    end)
end

local walkActive = false
local walkConnection

local function walkToChair()
    walkConnection = game:GetService("RunService").Stepped:Connect(function()
        if character and character:FindFirstChildOfClass("Humanoid") then
            local chair = getNearestChair()
            if chair then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                humanoid.WalkSpeed = 20
                humanoid:MoveTo(chair.Position)
                humanoid.MoveToFinished:Wait()
                humanoid.WalkSpeed = 16
            end
        end
    end)
end

local function makeDraggable(frame)
    local dragToggle = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

makeDraggable(frame)

minimizeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    maximizeButton.Visible = true
end)

maximizeButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    maximizeButton.Visible = false
end)

makeDraggable(maximizeButton)

teleportButton.MouseButton1Click:Connect(function()
    teleportActive = not teleportActive
    if teleportActive then
        teleportButton.BackgroundColor3 = Color3.new(1, 0, 0)
        teleportToChair()
    else
        teleportButton.BackgroundColor3 = Color3.new(0, 1, 0)
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end
end)

walkButton.MouseButton1Click:Connect(function()
    walkActive = not walkActive
    if walkActive then
        walkButton.BackgroundColor3 = Color3.new(1, 0, 0)
        walkToChair()
    else
        walkButton.BackgroundColor3 = Color3.new(0, 0, 1)
        if walkConnection then
            walkConnection:Disconnect()
            walkConnection = nil
        end
    end
end)

killGuiButton.MouseButton1Click:Connect(function()
    ui:Destroy()
    if teleportConnection then teleportConnection:Disconnect() end
    if walkConnection then walkConnection:Disconnect() end
end)

minimizeButton.TouchTap:Connect(function()
    minimizeButton.MouseButton1Click:Fire()
end)

maximizeButton.TouchTap:Connect(function()
    maximizeButton.MouseButton1Click:Fire()
end)

teleportButton.TouchTap:Connect(function()
    teleportButton.MouseButton1Click:Fire()
end)

walkButton.TouchTap:Connect(function()
    walkButton.MouseButton1Click:Fire()
end)

killGuiButton.TouchTap:Connect(function()
    killGuiButton.MouseButton1Click:Fire()
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)

makeDraggable(frame)
