local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
repeat task.wait() until LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "CANDY_GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 250, 0, 650)
panel.Position = UDim2.new(0, 10, 0.5, -325)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "CANDY.GUI"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.Text = "X"
closeBtn.Parent = panel
closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = not gui.Enabled
end)

UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F4 then
        gui.Enabled = not gui.Enabled
    end
end)

local function createButton(name, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    btn.Parent = panel
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createLabel(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = panel
    return lbl
end

local function createTextBox(y, placeholder)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = panel
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -10, 1, -10)
    textBox.Position = UDim2.new(0, 5, 0, 5)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 16
    textBox.Text = ""
    textBox.PlaceholderText = placeholder
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = frame
    
    return textBox
end

local flying = false
local bodyGyro, bodyVelocity, flyConn
local control = {F=0, B=0, L=0, R=0, U=0, D=0}
local flySpeed = 50

local function startFlying()
    if flying then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    flying = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local dir = (cam.CFrame.LookVector * (control.F + control.B) +
                     cam.CFrame.RightVector * (control.R + control.L) +
                     Vector3.new(0, control.U + control.D, 0))
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFlying()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then control.F = 1 end
    if key == Enum.KeyCode.S then control.B = -1 end
    if key == Enum.KeyCode.A then control.L = -1 end
    if key == Enum.KeyCode.D then control.R = 1 end
    if key == Enum.KeyCode.Space then control.U = 1 end
    if key == Enum.KeyCode.LeftShift then control.D = -1 end
end)

UIS.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then control.F = 0 end
    if key == Enum.KeyCode.S then control.B = 0 end
    if key == Enum.KeyCode.A then control.L = 0 end
    if key == Enum.KeyCode.D then control.R = 0 end
    if key == Enum.KeyCode.Space then control.U = 0 end
    if key == Enum.KeyCode.LeftShift then control.D = 0 end
end)

local espEnabled = false
local espConn
local activeOutlines = {}

local function createOutlinePart(part)
    local outline = Instance.new("BoxHandleAdornment")
    outline.Adornee = part
    outline.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
    outline.Color3 = Color3.new(1, 0, 0)
    outline.AlwaysOnTop = true
    outline.ZIndex = 10
    outline.Transparency = 0.3
    outline.Name = "ESP_Outline"
    outline.Parent = part
    return outline
end

local function clearOutlines()
    for _, outline in pairs(activeOutlines) do
        if outline and outline.Parent then
            outline:Destroy()
        end
    end
    activeOutlines = {}
end

local function updateESP()
    clearOutlines()
    if not espEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local outline = createOutlinePart(part)
                        table.insert(activeOutlines, outline)
                    end
                end
            end
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        espConn = RunService.Heartbeat:Connect(updateESP)
    else
        if espConn then espConn:Disconnect() end
        clearOutlines()
    end
end

local noclipEnabled = false
local noclipConn

local function noclipLoop()
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(noclipLoop)
    else
        if noclipConn then noclipConn:Disconnect() end
        noclipLoop()
    end
end

local function setWalkSpeed(speed)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end

local function sendSystemMessage(message)
    if message == "" then return end
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[SYSTEM] "..message,
        Color = Color3.new(1, 1, 0),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    })
end

local currentSkybox

local function changeSkybox(imageId)
    if currentSkybox then
        currentSkybox:Destroy()
    end

    if not imageId or imageId == "" then
        Lighting.Sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
        Lighting.Sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
        Lighting.Sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
        Lighting.Sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
        Lighting.Sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
        Lighting.Sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
        return
    end

    currentSkybox = Instance.new("Sky")
    currentSkybox.SkyboxBk = "rbxassetid://"..imageId
    currentSkybox.SkyboxDn = "rbxassetid://"..imageId
    currentSkybox.SkyboxFt = "rbxassetid://"..imageId
    currentSkybox.SkyboxLf = "rbxassetid://"..imageId
    currentSkybox.SkyboxRt = "rbxassetid://"..imageId
    currentSkybox.SkyboxUp = "rbxassetid://"..imageId
    currentSkybox.Parent = Lighting
end

local function flingPlayer(player, power)
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(math.random(-power,power), power, math.random(-power,power))
    bodyVelocity.MaxForce = Vector3.new(1,1,1) * power
    bodyVelocity.P = power
    bodyVelocity.Parent = hrp
    
    game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
end

local function flingSelf()
    flingPlayer(LocalPlayer, 5000)
end

local function flingAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            flingPlayer(player, 5000)
        end
    end
end

local y = 35

createLabel("Flight Controls", y); y = y + 20
createButton("Fly (Hold Space/Shift)", y, startFlying); y = y + 35
createButton("Stop Flying", y, stopFlying); y = y + 35

createLabel("ESP Controls", y); y = y + 20
local espBtn = createButton("ESP: OFF", y, function()
    toggleESP()
    espBtn.Text = "ESP: "..(espEnabled and "ON" or "OFF")
end); y = y + 35

createLabel("Noclip Controls", y); y = y + 20
local noclipBtn = createButton("Noclip: OFF", y, function()
    toggleNoclip()
    noclipBtn.Text = "Noclip: "..(noclipEnabled and "ON" or "OFF")
end); y = y + 35

createLabel("Speed Controls", y); y = y + 20
createButton("Normal (16)", y, function() setWalkSpeed(16) end); y = y + 35
createButton("Fast (50)", y, function() setWalkSpeed(50) end); y = y + 35
createButton("Slow (8)", y, function() setWalkSpeed(8) end); y = y + 35

createLabel("Fling Controls", y); y = y + 20
createButton("Fling Self", y, flingSelf); y = y + 35
createButton("Fling Others", y, flingAll); y = y + 35

createLabel("System Message", y); y = y + 20
local msgBox = createTextBox(y, "Enter message"); y = y + 35
createButton("Send as [SYSTEM]", y, function()
    sendSystemMessage(msgBox.Text)
    msgBox.Text = ""
end); y = y + 35

createLabel("Skybox Changer", y); y = y + 20
local skyboxBox = createTextBox(y, "Enter Image ID"); y = y + 35
createButton("Change Skybox", y, function()
    changeSkybox(skyboxBox.Text)
end); y = y + 35
createButton("Reset Skybox", y, function()
    changeSkybox("")
    skyboxBox.Text = ""
end); y = y + 35

local statusLabel = createLabel("GUI Ready - F4 to toggle", y)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

print("CANDY GUI loaded successfully! Press F4 to toggle visibility.")
