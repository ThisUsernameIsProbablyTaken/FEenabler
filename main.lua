-- ========================================

-- SERVICES & INITIALIZATION

-- ========================================

local Services = {

    Players = game:GetService("Players"),

    TweenService = game:GetService("TweenService"),

    UserInputService = game:GetService("UserInputService"),

    RunService = game:GetService("RunService")

}

local Player = Services.Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local HttpService = game:GetService("HttpService")

local function VerifyKey(key)
    local success, response = pcall(function()
        return request({
            Url = "https://feenabler.soundpegasusofficial.workers.dev/verify",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                key = key
            })
        })
    end)

    if not success then
        return false, "Request failed"
    end

    if not response.Success then
        return false, "Server error: " .. tostring(response.StatusCode)
    end

    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not decodeSuccess then
        return false, "Invalid server response"
    end

    if data.valid == true then
        return true, data
    end

    return false, data.error or "Invalid key"
end

-- ========================================

-- CONFIGURATION

-- ========================================

local Config = {

    MaxKeyLength = 50,

    AnimationSpeed = 0.4,

    ParticleCount = 60,

    ParticleSpeed = 60

}

-- ========================================

-- COLOR SCHEME

-- ========================================

local Colors = {

    Background = Color3.fromRGB(18, 18, 22),

    Surface = Color3.fromRGB(25, 25, 30),

    Primary = Color3.fromRGB(45, 45, 50),

    Secondary = Color3.fromRGB(35, 35, 40),

    Border = Color3.fromRGB(40, 40, 45),

    TextPrimary = Color3.fromRGB(220, 220, 225),

    TextSecondary = Color3.fromRGB(140, 140, 150),

    Success = Color3.fromRGB(25, 135, 84),

    Error = Color3.fromRGB(180, 50, 50),

    Warning = Color3.fromRGB(200, 120, 30),

    Discord = Color3.fromRGB(60, 70, 180),

    GetKey = Color3.fromRGB(40, 140, 100),

    HoverPrimary = Color3.fromRGB(55, 55, 60),

    HoverDiscord = Color3.fromRGB(50, 60, 160),

    HoverGetKey = Color3.fromRGB(30, 120, 80),

    NeonWhite = Color3.fromRGB(255, 255, 255),

    NeonGlow = Color3.fromRGB(240, 248, 255)

}

-- ========================================

-- STATE MANAGEMENT

-- ========================================

local State = {

    IsLoading = false,

    Particles = {},

    Animations = {},

    IsDestroyed = false,

    MousePosition = {X = 0, Y = 0},

    FocusStates = {

        InputFocused = false,

        ButtonHovered = {},

        AnimationsActive = true

    }

}

local UI = {}

-- ========================================

-- UI CREATION FUNCTIONS

-- ========================================

local function CreateMainGUI()

    local screenGui = Instance.new("ScreenGui")

    screenGui.Name = "KeySystemGUI"

    screenGui.ResetOnSpawn = false

    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    screenGui.IgnoreGuiInset = true

    screenGui.DisplayOrder = 100

    screenGui.Parent = PlayerGui

    UI.ScreenGui = screenGui

    return screenGui

end

local function CreateBackdrop(parent)

    local backdrop = Instance.new("Frame")

    backdrop.Name = "Backdrop"

    backdrop.Size = UDim2.new(1, 0, 1, 0)

    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

    backdrop.BackgroundTransparency = 0.1

    backdrop.BorderSizePixel = 0

    backdrop.ZIndex = 100

    backdrop.Parent = parent

    UI.Backdrop = backdrop

    return backdrop

end

local function CreateContainer(parent)

    local container = Instance.new("Frame")

    container.Name = "MainContainer"

    container.Size = UDim2.new(0, 420, 0, 600)

    container.Position = UDim2.new(0.5, -210, 0.5, -300)

    container.BackgroundColor3 = Colors.Background

    container.BorderSizePixel = 0

    container.ZIndex = 110

    container.Selectable = false

    container.Parent = parent

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 20)

    corner.Parent = container

    local stroke = Instance.new("UIStroke")

    stroke.Color = Colors.Border

    stroke.Thickness = 1

    stroke.Transparency = 0.3

    stroke.Parent = container

    UI.Container = container

    return container

end

local function CreateAnimatedBorder(parent)

    local border = Instance.new("Frame")

    border.Name = "AnimatedBorder"

    border.Size = UDim2.new(1, 6, 1, 6)

    border.Position = UDim2.new(0, -3, 0, -3)

    border.BackgroundTransparency = 1

    border.ZIndex = 109

    border.Selectable = false

    border.Parent = parent

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 23)

    corner.Parent = border

    local stroke = Instance.new("UIStroke")  

    stroke.Color = Colors.NeonWhite

    stroke.Thickness = 2

    stroke.Transparency = 0.3

    stroke.Parent = border

    local gradient = Instance.new("UIGradient")

    gradient.Color = ColorSequence.new{

        ColorSequenceKeypoint.new(0, Colors.NeonWhite),

        ColorSequenceKeypoint.new(0.5, Colors.NeonGlow),

        ColorSequenceKeypoint.new(1, Colors.NeonWhite)

    }

    gradient.Transparency = NumberSequence.new{

        NumberSequenceKeypoint.new(0, 0.9),

        NumberSequenceKeypoint.new(0.2, 0.1),

        NumberSequenceKeypoint.new(0.8, 0.1),

        NumberSequenceKeypoint.new(1, 0.9)

    }

    gradient.Parent = stroke

    UI.AnimatedBorder = {Frame = border, Gradient = gradient, Stroke = stroke}

    return border

end

-- ========================================

-- HEADER SECTION

-- ========================================

local function CreateHeader(parent)

    local header = Instance.new("Frame")

    header.Name = "Header"

    header.Size = UDim2.new(1, 0, 0, 100)

    header.BackgroundTransparency = 1

    header.ZIndex = 11

    header.Selectable = false

    header.Parent = parent

    local iconContainer = Instance.new("Frame")

    iconContainer.Size = UDim2.new(0, 56, 0, 56)

    iconContainer.Position = UDim2.new(0.5, -28, 0, 24)

    iconContainer.BackgroundColor3 = Colors.Primary

    iconContainer.BorderSizePixel = 0

    iconContainer.ZIndex = 12

    iconContainer.Selectable = false

    iconContainer.Parent = header

    local iconCorner = Instance.new("UICorner")

    iconCorner.CornerRadius = UDim.new(0, 14)

    iconCorner.Parent = iconContainer

    local iconGlow = Instance.new("Frame")

    iconGlow.Size = UDim2.new(1, 12, 1, 12)

    iconGlow.Position = UDim2.new(0, -6, 0, -6)

    iconGlow.BackgroundTransparency = 1

    iconGlow.ZIndex = 11

    iconGlow.Selectable = false

    iconGlow.Parent = iconContainer

    local glowCorner = Instance.new("UICorner")

    glowCorner.CornerRadius = UDim.new(0, 20)

    glowCorner.Parent = iconGlow

    local glowStroke = Instance.new("UIStroke")

    glowStroke.Color = Colors.NeonWhite

    glowStroke.Thickness = 3

    glowStroke.Transparency = 0.2

    glowStroke.Parent = iconGlow

    local glowGradient = Instance.new("UIGradient")

    glowGradient.Color = ColorSequence.new{

        ColorSequenceKeypoint.new(0, Colors.NeonWhite),

        ColorSequenceKeypoint.new(0.5, Colors.NeonGlow),

        ColorSequenceKeypoint.new(1, Colors.NeonWhite)

    }

    glowGradient.Transparency = NumberSequence.new{

        NumberSequenceKeypoint.new(0, 0.8),

        NumberSequenceKeypoint.new(0.2, 0.05),

        NumberSequenceKeypoint.new(0.8, 0.05),

        NumberSequenceKeypoint.new(1, 0.8)

    }

    glowGradient.Parent = glowStroke

    local iconImage = Instance.new("ImageLabel")

    iconImage.Size = UDim2.new(0.8, 0, 0.8, 0)

    iconImage.Position = UDim2.new(0.1, 0, 0.1, 0)

    iconImage.BackgroundTransparency = 1

    iconImage.Image = "rbxassetid://95233466475324"

    iconImage.ImageColor3 = Colors.NeonWhite

    iconImage.ImageTransparency = 0.1

    iconImage.ScaleType = Enum.ScaleType.Fit

    iconImage.ZIndex = 13

    iconImage.Parent = iconContainer

    UI.Header = {Container = header, IconGlow = glowGradient, IconStroke = glowStroke}

    return header

end

-- ========================================

-- CONTENT SECTION

-- ========================================

local function CreateContent(parent)

    local content = Instance.new("Frame")

    content.Name = "Content"

    content.Size = UDim2.new(1, -64, 0, 440)

    content.Position = UDim2.new(0, 32, 0, 120)

    content.BackgroundTransparency = 1

    content.ZIndex = 11

    content.Selectable = false

    content.Parent = parent

    local title = Instance.new("TextLabel")

    title.Size = UDim2.new(1, 0, 0, 32)

    title.BackgroundTransparency = 1

    title.Text = "Access Key Required"

    title.TextColor3 = Colors.TextPrimary

    title.TextSize = 24

    title.Font = Enum.Font.GothamBold

    title.TextXAlignment = Enum.TextXAlignment.Center

    title.ZIndex = 12

    title.Parent = content

    local subtitle = Instance.new("TextLabel")

    subtitle.Size = UDim2.new(1, 0, 0, 40)

    subtitle.Position = UDim2.new(0, 0, 0, 40)

    subtitle.BackgroundTransparency = 1

    subtitle.Text = "Enter your access key to continue"

    subtitle.TextColor3 = Colors.TextSecondary

    subtitle.TextSize = 16

    subtitle.Font = Enum.Font.Gotham

    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    subtitle.TextWrapped = true

    subtitle.ZIndex = 12

    subtitle.Parent = content

    UI.Content = content

    return content

end

-- ========================================

-- INPUT SECTION

-- ========================================

local function CreateInputSection(parent)

    local section = Instance.new("Frame")

    section.Size = UDim2.new(1, 0, 0, 100)

    section.Position = UDim2.new(0, 0, 0, 100)

    section.BackgroundTransparency = 1

    section.ZIndex = 12

    section.Selectable = false

    section.Parent = parent

    local inputContainer = Instance.new("Frame")

    inputContainer.Size = UDim2.new(1, 0, 0, 52)

    inputContainer.BackgroundColor3 = Colors.Surface

    inputContainer.BorderSizePixel = 0

    inputContainer.ZIndex = 13

    inputContainer.Selectable = false

    inputContainer.Parent = section

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 12)

    corner.Parent = inputContainer

    local stroke = Instance.new("UIStroke")

    stroke.Color = Colors.Border

    stroke.Thickness = 1

    stroke.Transparency = 0.3

    stroke.Parent = inputContainer

    local inputGlow = Instance.new("Frame")

    inputGlow.Size = UDim2.new(1, 8, 1, 8)

    inputGlow.Position = UDim2.new(0, -4, 0, -4)

    inputGlow.BackgroundTransparency = 1

    inputGlow.ZIndex = inputContainer.ZIndex - 1

    inputGlow.Visible = false

    inputGlow.Selectable = false

    inputGlow.Parent = inputContainer

    local glowCorner = Instance.new("UICorner")

    glowCorner.CornerRadius = UDim.new(0, 16)

    glowCorner.Parent = inputGlow

    local glowStroke = Instance.new("UIStroke")

    glowStroke.Color = Colors.NeonWhite

    glowStroke.Thickness = 2

    glowStroke.Transparency = 0.3

    glowStroke.Parent = inputGlow

    local glowGradient = Instance.new("UIGradient")

    glowGradient.Color = ColorSequence.new{

        ColorSequenceKeypoint.new(0, Colors.NeonWhite),

        ColorSequenceKeypoint.new(0.5, Colors.NeonGlow),

        ColorSequenceKeypoint.new(1, Colors.NeonWhite)

    }

    glowGradient.Transparency = NumberSequence.new{

        NumberSequenceKeypoint.new(0, 0.8),

        NumberSequenceKeypoint.new(0.2, 0.1),

        NumberSequenceKeypoint.new(0.8, 0.1),

        NumberSequenceKeypoint.new(1, 0.8)

    }

    glowGradient.Parent = glowStroke

    local textInput = Instance.new("TextBox")

    textInput.Size = UDim2.new(1, -24, 1, 0)

    textInput.Position = UDim2.new(0, 12, 0, 0)

    textInput.BackgroundTransparency = 1

    textInput.Text = ""

    textInput.PlaceholderText = "Enter key here"

    textInput.TextColor3 = Colors.TextPrimary

    textInput.PlaceholderColor3 = Colors.TextSecondary

    textInput.TextSize = 16

    textInput.Font = Enum.Font.Gotham

    textInput.TextXAlignment = Enum.TextXAlignment.Left

    textInput.ClearTextOnFocus = false

    textInput.ZIndex = 14

    textInput.Selectable = true

    textInput.Parent = inputContainer

    local charCounter = Instance.new("TextLabel")

    charCounter.Size = UDim2.new(0, 80, 0, 20)

    charCounter.Position = UDim2.new(1, -85, 0, 60)

    charCounter.BackgroundTransparency = 1

    charCounter.Text = "0/" .. Config.MaxKeyLength

    charCounter.TextColor3 = Colors.TextSecondary

    charCounter.TextSize = 12

    charCounter.Font = Enum.Font.Gotham

    charCounter.TextXAlignment = Enum.TextXAlignment.Right

    charCounter.ZIndex = 13

    charCounter.Parent = section

    UI.Input = {

        Container = inputContainer,

        TextBox = textInput,

        Counter = charCounter,

        Stroke = stroke,

        Glow = {Frame = inputGlow, Stroke = glowStroke, Gradient = glowGradient}

    }

    return section

end

-- ========================================

-- BUTTON SECTION

-- ========================================

local function CreateButtons(parent)

    local submitButton = Instance.new("TextButton")

    submitButton.Size = UDim2.new(1, 0, 0, 48)

    submitButton.Position = UDim2.new(0, 0, 0, 200)

    submitButton.BackgroundColor3 = Colors.Primary

    submitButton.BorderSizePixel = 0

    submitButton.Text = "Verify Access Key"

    submitButton.TextColor3 = Colors.TextPrimary

    submitButton.TextSize = 16

    submitButton.Font = Enum.Font.GothamMedium

    submitButton.AutoButtonColor = false

    submitButton.ZIndex = 13

    submitButton.Selectable = true

    submitButton.Parent = parent

    local submitCorner = Instance.new("UICorner")

    submitCorner.CornerRadius = UDim.new(0, 12)

    submitCorner.Parent = submitButton

    local loadingContainer = Instance.new("Frame")

    loadingContainer.Size = UDim2.new(0, 24, 0, 24)

    loadingContainer.Position = UDim2.new(0.5, -12, 0, 12)

    loadingContainer.BackgroundTransparency = 1

    loadingContainer.Visible = false

    loadingContainer.ZIndex = 14

    loadingContainer.Selectable = false

    loadingContainer.Parent = submitButton

    local spinner = Instance.new("Frame")

    spinner.Size = UDim2.new(1, 0, 1, 0)

    spinner.BackgroundColor3 = Colors.TextPrimary

    spinner.BorderSizePixel = 0

    spinner.ZIndex = 15

    spinner.Selectable = false

    spinner.Parent = loadingContainer

    local spinnerCorner = Instance.new("UICorner")

    spinnerCorner.CornerRadius = UDim.new(1, 0)

    spinnerCorner.Parent = spinner

    local spinnerGradient = Instance.new("UIGradient")

    spinnerGradient.Transparency = NumberSequence.new{

        NumberSequenceKeypoint.new(0, 0),

        NumberSequenceKeypoint.new(0.8, 0.8),

        NumberSequenceKeypoint.new(1, 1)

    }

    spinnerGradient.Parent = spinner

    local buttonsContainer = Instance.new("Frame")

    buttonsContainer.Size = UDim2.new(1, 0, 0, 48)

    buttonsContainer.Position = UDim2.new(0, 0, 0, 260)

    buttonsContainer.BackgroundTransparency = 1

    buttonsContainer.ZIndex = 12

    buttonsContainer.Selectable = false

    buttonsContainer.Parent = parent

    local getKeyButton = Instance.new("TextButton")

    getKeyButton.Size = UDim2.new(0.48, 0, 1, 0)

    getKeyButton.BackgroundColor3 = Colors.GetKey

    getKeyButton.BorderSizePixel = 0

    getKeyButton.Text = "Get Key"

    getKeyButton.TextColor3 = Colors.TextPrimary

    getKeyButton.TextSize = 14

    getKeyButton.Font = Enum.Font.GothamMedium

    getKeyButton.AutoButtonColor = false

    getKeyButton.ZIndex = 13

    getKeyButton.Selectable = true

    getKeyButton.Parent = buttonsContainer

    local getKeyCorner = Instance.new("UICorner")

    getKeyCorner.CornerRadius = UDim.new(0, 10)

    getKeyCorner.Parent = getKeyButton

    local discordButton = Instance.new("TextButton")

    discordButton.Size = UDim2.new(0.48, 0, 1, 0)

    discordButton.Position = UDim2.new(0.52, 0, 0, 0)

    discordButton.BackgroundColor3 = Colors.Discord

    discordButton.BorderSizePixel = 0

    discordButton.Text = "Discord"

    discordButton.TextColor3 = Colors.TextPrimary

    discordButton.TextSize = 14

    discordButton.Font = Enum.Font.GothamMedium

    discordButton.AutoButtonColor = false

    discordButton.ZIndex = 13

    discordButton.Selectable = true

    discordButton.Parent = buttonsContainer

    local discordCorner = Instance.new("UICorner")

    discordCorner.CornerRadius = UDim.new(0, 10)

    discordCorner.Parent = discordButton

    UI.Buttons = {

        Submit = submitButton,

        GetKey = getKeyButton,

        Discord = discordButton,

        Loading = {Container = loadingContainer, Spinner = spinner}

    }

    return {submitButton, getKeyButton, discordButton}

end

-- ========================================

-- STATUS SECTION

-- ========================================

local function CreateStatus(parent)

    local statusContainer = Instance.new("Frame")

    statusContainer.Size = UDim2.new(1, 0, 0, 60)

    statusContainer.Position = UDim2.new(0, 0, 0, 330)

    statusContainer.BackgroundTransparency = 1

    statusContainer.ZIndex = 12

    statusContainer.Selectable = false

    statusContainer.Parent = parent

    local statusLabel = Instance.new("TextLabel")

    statusLabel.Size = UDim2.new(1, 0, 1, 0)

    statusLabel.BackgroundTransparency = 1

    statusLabel.Text = ""

    statusLabel.TextColor3 = Colors.Error

    statusLabel.TextSize = 14

    statusLabel.Font = Enum.Font.Gotham

    statusLabel.TextXAlignment = Enum.TextXAlignment.Center

    statusLabel.TextWrapped = true

    statusLabel.ZIndex = 13

    statusLabel.Parent = statusContainer

    UI.Status = statusLabel

    return statusLabel

end

-- ========================================

-- PARTICLE SYSTEM

-- ========================================

local function CreateParticleContainer(parent)

    local container = Instance.new("Frame")

    container.Size = UDim2.new(1, 0, 1, 0)

    container.BackgroundTransparency = 1

    container.ZIndex = 105

    container.Selectable = false

    container.Parent = parent

    UI.ParticleContainer = container

    return container

end

local function CreateParticle()

    if not UI.ParticleContainer or not UI.ParticleContainer.Parent or State.IsDestroyed then

        return nil

    end

    local size = math.random(8, 24)

    local particle = Instance.new("Frame")

    particle.Size = UDim2.new(0, size, 0, size)

    particle.Position = UDim2.new(math.random() * 1.4 - 0.2, 0, 1.2, 0)

    particle.BackgroundColor3 = Colors.NeonWhite

    particle.BackgroundTransparency = math.random(60, 85) / 100

    particle.BorderSizePixel = 0

    particle.ZIndex = 106

    particle.Selectable = false

    particle.Parent = UI.ParticleContainer

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(1, 0)

    corner.Parent = particle

    local gradient = Instance.new("UIGradient")

    local bubbleColors = {

        Color3.fromRGB(200, 230, 255),

        Color3.fromRGB(180, 220, 255),

        Color3.fromRGB(220, 240, 255),

        Color3.fromRGB(190, 210, 240)

    }

    local color1 = bubbleColors[math.random(#bubbleColors)]

    local color2 = bubbleColors[math.random(#bubbleColors)]

    gradient.Color = ColorSequence.new{

        ColorSequenceKeypoint.new(0, color1),

        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),

        ColorSequenceKeypoint.new(0.7, color2),

        ColorSequenceKeypoint.new(1, color1)

    }

    gradient.Rotation = math.random(0, 360)

    gradient.Parent = particle

    local highlight = Instance.new("Frame")

    highlight.Size = UDim2.new(0.3, 0, 0.3, 0)

    highlight.Position = UDim2.new(0.2, 0, 0.15, 0)

    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    highlight.BackgroundTransparency = 0.3

    highlight.BorderSizePixel = 0

    highlight.ZIndex = particle.ZIndex + 1

    highlight.Parent = particle

    local highlightCorner = Instance.new("UICorner")

    highlightCorner.CornerRadius = UDim.new(1, 0)

    highlightCorner.Parent = highlight

    local glow = Instance.new("Frame")

    glow.Size = UDim2.new(1.8, 0, 1.8, 0)

    glow.Position = UDim2.new(-0.4, 0, -0.4, 0)

    glow.BackgroundColor3 = Color3.fromRGB(200, 230, 255)

    glow.BackgroundTransparency = 0.9

    glow.BorderSizePixel = 0

    glow.ZIndex = particle.ZIndex - 1

    glow.Parent = particle

    local glowCorner = Instance.new("UICorner")

    glowCorner.CornerRadius = UDim.new(1, 0)

    glowCorner.Parent = glow

    local particleData = {

        frame = particle,

        vx = (math.random() - 0.5) * 0.004,

        vy = -math.random(20, 50) / 10000,

        created = tick(),

        rotation = 0,

        rotationSpeed = (math.random() - 0.5) * 2,

        pulsePhase = math.random() * math.pi * 2,

        driftPhase = math.random() * math.pi * 2,

        originalTransparency = particle.BackgroundTransparency,

        glow = glow,

        highlight = highlight,

        lifetime = math.random(30, 60),

        originalSize = size,

        wobblePhase = math.random() * math.pi * 2,

        repelForce = {x = 0, y = 0},

        mass = size / 10

    }

    table.insert(State.Particles, particleData)

    return particle

end

local function UpdateParticles()

    if State.IsDestroyed or not UI.ParticleContainer then return end

    local screenSize = UI.ScreenGui.AbsoluteSize

    local mouseScreenX = State.MousePosition.X / screenSize.X

    local mouseScreenY = State.MousePosition.Y / screenSize.Y

    for i = #State.Particles, 1, -1 do

        local p = State.Particles[i]

        if not p or not p.frame or not p.frame.Parent then

            table.remove(State.Particles, i)

        else

            local currentPos = p.frame.Position

            local age = tick() - p.created

            if currentPos.Y.Scale < -0.3 or age > p.lifetime then

                p.frame:Destroy()

                table.remove(State.Particles, i)

            else

                local distanceToMouse = math.sqrt(

                    (currentPos.X.Scale - mouseScreenX)^2 + 

                    (currentPos.Y.Scale - mouseScreenY)^2

                )

                local repelStrength = 0.08

                local repelRadius = 0.15

                local repelForceX = 0

                local repelForceY = 0

                if distanceToMouse < repelRadius and distanceToMouse > 0 then

                    local repelPower = (repelRadius - distanceToMouse) / repelRadius

                    repelPower = repelPower * repelStrength / p.mass

                    local directionX = (currentPos.X.Scale - mouseScreenX) / distanceToMouse

                    local directionY = (currentPos.Y.Scale - mouseScreenY) / distanceToMouse

                    repelForceX = directionX * repelPower

                    repelForceY = directionY * repelPower

                end

                p.repelForce.x = p.repelForce.x * 0.85 + repelForceX * 0.15

                p.repelForce.y = p.repelForce.y * 0.85 + repelForceY * 0.15

                local newX = currentPos.X.Scale + p.vx + p.repelForce.x

                local newY = currentPos.Y.Scale + p.vy + p.repelForce.y

                if newX <= -0.2 then newX = 1.2

                elseif newX >= 1.2 then newX = -0.2 end

                local wobbleTime = tick() * 1.5 + p.wobblePhase

                newX = newX + math.sin(wobbleTime) * 0.002

                newY = newY + math.cos(wobbleTime * 0.7) * 0.001

                newX = newX + (math.random() - 0.5) * 0.0008

                newY = newY + (math.random() - 0.5) * 0.0005

                p.rotation = p.rotation + p.rotationSpeed

                p.frame.Rotation = p.rotation

                local breathe = math.sin(tick() * 2.5 + p.pulsePhase) * 0.1 + 1

                local currentSize = p.originalSize * breathe

                p.frame.Size = UDim2.new(0, currentSize, 0, currentSize)

                local transparencyPulse = math.sin(tick() * 3 + p.pulsePhase) * 0.1

                local newTransparency = math.max(0.5, math.min(0.95, p.originalTransparency + transparencyPulse))

                p.frame.BackgroundTransparency = newTransparency

                local glowIntensity = 0.9

                if distanceToMouse < 0.2 then

                    glowIntensity = 0.7 + (distanceToMouse / 0.2) * 0.2

                end

                p.glow.BackgroundTransparency = glowIntensity

                local shimmer = math.sin(tick() * 4 + p.pulsePhase) * 0.2 + 0.3

                p.highlight.BackgroundTransparency = shimmer

                p.vx = p.vx * 0.995

                p.vy = p.vy * 0.998

                p.frame.Position = UDim2.new(newX, 0, newY, 0)

            end

        end

    end

end

-- ========================================

-- VISUAL EFFECTS

-- ========================================

local function CreateButtonGlow(button, hoverColor, originalColor)

    local glowBorder = Instance.new("Frame")

    glowBorder.Size = UDim2.new(1, 8, 1, 8)

    glowBorder.Position = UDim2.new(0, -4, 0, -4)

    glowBorder.BackgroundTransparency = 1

    glowBorder.ZIndex = button.ZIndex - 1

    glowBorder.Visible = false

    glowBorder.Selectable = false

    glowBorder.Parent = button

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 14)

    corner.Parent = glowBorder

    local stroke = Instance.new("UIStroke")

    stroke.Color = Colors.NeonWhite

    stroke.Thickness = 2

    stroke.Transparency = 0.3

    stroke.Parent = glowBorder

    local gradient = Instance.new("UIGradient")

    gradient.Color = ColorSequence.new{

        ColorSequenceKeypoint.new(0, Colors.NeonWhite),

        ColorSequenceKeypoint.new(0.5, Colors.NeonGlow),

        ColorSequenceKeypoint.new(1, Colors.NeonWhite)

    }

    gradient.Transparency = NumberSequence.new{

        NumberSequenceKeypoint.new(0, 0.8),

        NumberSequenceKeypoint.new(0.2, 0.1),

        NumberSequenceKeypoint.new(0.8, 0.1),

        NumberSequenceKeypoint.new(1, 0.8)

    }

    gradient.Parent = stroke

    local currentTween = nil

    local buttonId = tostring(button)

    button.MouseEnter:Connect(function()

        State.FocusStates.ButtonHovered[buttonId] = true

        glowBorder.Visible = true

        Services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), 

            {BackgroundColor3 = hoverColor}):Play()

        Services.TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), 

            {Transparency = 0.1}):Play()

        if currentTween then currentTween:Cancel() end

        currentTween = Services.TweenService:Create(gradient, 

            TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 

            {Rotation = 360})

        currentTween:Play()

    end)

    button.MouseLeave:Connect(function()

        State.FocusStates.ButtonHovered[buttonId] = false

        Services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), 

            {BackgroundColor3 = originalColor}):Play()

        Services.TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 

            {Transparency = 0.8}):Play()

        if currentTween then

            currentTween:Cancel()

            gradient.Rotation = 0

        end

        task.spawn(function()

            task.wait(0.3)

            if glowBorder and glowBorder.Parent then

                glowBorder.Visible = false

            end

        end)

    end)

    return {glowBorder, stroke, gradient}

end

-- ========================================

-- STATUS & FEEDBACK FUNCTIONS

-- ========================================

local function ShowStatus(message, isError, isSuccess)

    if not UI.Status then return end

    UI.Status.Text = message

    if isSuccess then

        UI.Status.TextColor3 = Colors.Success

    elseif isError then

        UI.Status.TextColor3 = Colors.Error

    else

        UI.Status.TextColor3 = Colors.Warning

    end

    UI.Status.TextTransparency = 1

    Services.TweenService:Create(UI.Status, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 

        {TextTransparency = 0}):Play()

end

local function ClearStatus()

    if UI.Status then

        Services.TweenService:Create(UI.Status, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 

            {TextTransparency = 1}):Play()

    end

end

local function SetLoading(isLoading)

    State.IsLoading = isLoading

    if not UI.Buttons then return end

    UI.Buttons.Loading.Container.Visible = isLoading

    UI.Buttons.Submit.Text = isLoading and "" or "Verify Access Key"

    if isLoading then

        local tween = Services.TweenService:Create(UI.Buttons.Loading.Spinner, 

            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 

            {Rotation = 360})

        tween:Play()

        State.Animations.SpinTween = tween

    else

        if State.Animations.SpinTween then

            State.Animations.SpinTween:Cancel()

            UI.Buttons.Loading.Spinner.Rotation = 0

        end

    end

end

-- ========================================

-- INPUT HANDLING

-- ========================================

local function UpdateCharCounter()

    if not UI.Input then return end

    local currentLength = string.len(UI.Input.TextBox.Text)

    UI.Input.Counter.Text = currentLength .. "/" .. Config.MaxKeyLength

    if currentLength >= Config.MaxKeyLength then

        UI.Input.Counter.TextColor3 = Colors.Error

    elseif currentLength >= Config.MaxKeyLength * 0.8 then

        UI.Input.Counter.TextColor3 = Colors.Warning

    else

        UI.Input.Counter.TextColor3 = Colors.TextSecondary

    end

end

local function CopyToClipboard(text, successMessage)

    local success = pcall(function()

        if setclipboard then

            setclipboard(text)

            ShowStatus(successMessage, false, true)

        else

            ShowStatus("Link: " .. text, false, true)

        end

    end)

    if not success then

        ShowStatus("Link: " .. text, false, true)

    end

end

-- ========================================
-- AFTER-KEY HUB
-- ========================================

local HubState = {
    Speed = 16,
    FlingPower = 120,
    FlySpeed = 60,

    SpeedEnabled = false,
    WalkFlingEnabled = false,
    FlyEnabled = false,
    NoclipEnabled = false,

    Spectating = false,
    SpectateTarget = nil,

    OrbitEnabled = false,
    OrbitTarget = nil,
    OrbitDistance = 10,
    OrbitSpeed = 2,

    TargetLockEnabled = false,
    TargetLock = nil,

    Connections = {},
    FeatureConnections = {}
}

-- ========================================
-- CONNECTIONS
-- ========================================

local function HubConnect(connection)
    table.insert(HubState.Connections, connection)
    return connection
end

local function FeatureConnect(connection)
    table.insert(HubState.FeatureConnections, connection)
    return connection
end

local function ClearFeatureConnections()
    for _, connection in ipairs(HubState.FeatureConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    HubState.FeatureConnections = {}
end

local function HubDisconnect()
    ClearFeatureConnections()

    for _, connection in ipairs(HubState.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    HubState.Connections = {}
end

-- ========================================
-- CHARACTER
-- ========================================

local function GetCharacter()
    local character = Player.Character or Player.CharacterAdded:Wait()

    return character,
        character:FindFirstChildOfClass("Humanoid"),
        character:FindFirstChild("HumanoidRootPart")
end

-- ========================================
-- SPEED
-- ========================================

local function ApplySpeed()
    local _, humanoid = GetCharacter()

    if humanoid then
        humanoid.WalkSpeed =
            HubState.SpeedEnabled
            and HubState.Speed
            or 16
    end
end

-- ========================================
-- FLY
-- ========================================

local function StopFly()
    HubState.FlyEnabled = false

    if HubState.FlyVelocity then
        HubState.FlyVelocity:Destroy()
        HubState.FlyVelocity = nil
    end

    if HubState.FlyGyro then
        HubState.FlyGyro:Destroy()
        HubState.FlyGyro = nil
    end
end

local function StartFly()
    StopFly()

    local _, humanoid, root = GetCharacter()

    if not humanoid or not root then
        return
    end

    HubState.FlyEnabled = true

    local velocity = Instance.new("BodyVelocity")
    velocity.Name = "FEenablerFlyVelocity"
    velocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    velocity.P = 9000
    velocity.Velocity = Vector3.zero
    velocity.Parent = root

    local gyro = Instance.new("BodyGyro")
    gyro.Name = "FEenablerFlyGyro"
    gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    gyro.P = 9000
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    HubState.FlyVelocity = velocity
    HubState.FlyGyro = gyro

    FeatureConnect(
        Services.RunService.RenderStepped:Connect(function()

            if not HubState.FlyEnabled then
                return
            end

            if not root.Parent then
                StopFly()
                return
            end

            local camera = workspace.CurrentCamera

            if not camera then
                return
            end

            local direction = Vector3.zero

            if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += camera.CFrame.LookVector
            end

            if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= camera.CFrame.LookVector
            end

            if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= camera.CFrame.RightVector
            end

            if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += camera.CFrame.RightVector
            end

            if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.yAxis
            end

            if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction -= Vector3.yAxis
            end

            if direction.Magnitude > 0 then
                direction =
                    direction.Unit * HubState.FlySpeed
            end

            velocity.Velocity = direction
            gyro.CFrame = camera.CFrame
        end)
    )
end

-- ========================================
-- FLING
-- ========================================

local function SetWalkFling(enabled)
    HubState.WalkFlingEnabled = enabled

    if not enabled then
        return
    end

    local character, _, root = GetCharacter()

    if not character or not root then
        return
    end

    FeatureConnect(
        root.Touched:Connect(function(hit)

            if not HubState.WalkFlingEnabled then
                return
            end

            local target =
                hit and hit:FindFirstAncestorOfClass("Model")

            if not target or target == character then
                return
            end

            local targetHumanoid =
                target:FindFirstChildOfClass("Humanoid")

            local targetRoot =
                target:FindFirstChild("HumanoidRootPart")

            if not targetHumanoid or not targetRoot then
                return
            end

            if targetHumanoid.Health <= 0 then
                return
            end

            local direction =
                targetRoot.Position - root.Position

            if direction.Magnitude < 0.1 then
                direction = root.CFrame.LookVector
            else
                direction = direction.Unit
            end

            targetRoot.AssemblyLinearVelocity =
                direction * HubState.FlingPower
                + Vector3.new(
                    0,
                    HubState.FlingPower * 0.35,
                    0
                )
        end)
    )
end

-- ========================================
-- NOCLIP
-- ========================================

local function ApplyNoclip()
    local character = Player.Character

    if not character then
        return
    end

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            object.CanCollide = not HubState.NoclipEnabled
        end
    end
end

local function SetNoclip(enabled)
    HubState.NoclipEnabled = enabled

    if enabled then

        FeatureConnect(
            Services.RunService.Stepped:Connect(function()
                ApplyNoclip()
            end)
        )

        ApplyNoclip()

    else
        ApplyNoclip()
    end
end

-- ========================================
-- SPECTATE
-- ========================================

local function StopSpectate()
    HubState.Spectating = false
    HubState.SpectateTarget = nil

    local camera = workspace.CurrentCamera

    if camera then
        local _, humanoid = GetCharacter()

        if humanoid then
            camera.CameraSubject = humanoid
        end

        camera.CameraType = Enum.CameraType.Custom
    end
end

local function StartSpectate(target)
    if not target or target == Player then
        return
    end

    local humanoid =
        target.Character
        and target.Character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    HubState.Spectating = true
    HubState.SpectateTarget = target

    local camera = workspace.CurrentCamera

    if camera then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
    end
end

-- ========================================
-- TARGET HELPERS
-- ========================================

local function GetPlayerRoot(player)
    if not player then
        return nil
    end

    local character = player.Character

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local _, _, myRoot = GetCharacter()

    if not myRoot then
        return nil
    end

    local closest = nil
    local closestDistance = math.huge

    for _, player in ipairs(Services.Players:GetPlayers()) do

        if player ~= Player then

            local root = GetPlayerRoot(player)

            if root then
                local distance =
                    (root.Position - myRoot.Position).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closest = player
                end
            end
        end
    end

    return closest
end

-- ========================================
-- ORBIT
-- ========================================

local function StopOrbit()
    HubState.OrbitEnabled = false
    HubState.OrbitTarget = nil
end

local function StartOrbit(target)
    if not target or target == Player then
        return
    end

    StopOrbit()

    HubState.OrbitEnabled = true
    HubState.OrbitTarget = target

    FeatureConnect(
        Services.RunService.RenderStepped:Connect(function()

            if not HubState.OrbitEnabled then
                return
            end

            local _, _, myRoot = GetCharacter()
            local targetRoot = GetPlayerRoot(
                HubState.OrbitTarget
            )

            if not myRoot or not targetRoot then
                return
            end

            local time =
                os.clock() * HubState.OrbitSpeed

            local offset = Vector3.new(
                math.cos(time) * HubState.OrbitDistance,
                2,
                math.sin(time) * HubState.OrbitDistance
            )

            local desiredPosition =
                targetRoot.Position + offset

            myRoot.CFrame =
                CFrame.lookAt(
                    desiredPosition,
                    targetRoot.Position
                )
        end)
    )
end

-- ========================================
-- TARGET LOCK
-- ========================================

local function StopTargetLock()
    HubState.TargetLockEnabled = false
    HubState.TargetLock = nil
end

local function StartTargetLock(target)
    if not target or target == Player then
        return
    end

    StopTargetLock()

    HubState.TargetLockEnabled = true
    HubState.TargetLock = target

    FeatureConnect(
        Services.RunService.RenderStepped:Connect(function()

            if not HubState.TargetLockEnabled then
                return
            end

            local targetRoot =
                GetPlayerRoot(HubState.TargetLock)

            local camera =
                workspace.CurrentCamera

            if not targetRoot or not camera then
                return
            end

            camera.CFrame =
                CFrame.lookAt(
                    camera.CFrame.Position,
                    targetRoot.Position
                )
        end)
    )
end

-- ========================================
-- SLIDER
-- ========================================

local function CreateSlider(
    parent,
    y,
    labelText,
    minValue,
    maxValue,
    defaultValue,
    callback
)

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -30, 0, 76)
    holder.Position = UDim2.new(0, 15, 0, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Colors.TextPrimary
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 24)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Colors.TextSecondary
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 34)
    bar.BackgroundColor3 = Colors.Secondary
    bar.BorderSizePixel = 0
    bar.Parent = holder

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Colors.NeonWhite
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Colors.NeonWhite
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.Parent = bar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false

    local function SetValue(value)

        value = math.clamp(
            math.floor(value + 0.5),
            minValue,
            maxValue
        )

        local alpha =
            (value - minValue) /
            (maxValue - minValue)

        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)

        valueLabel.Text = tostring(value)

        callback(value)
    end

    local function MouseToValue(x)

        if bar.AbsoluteSize.X <= 0 then
            return
        end

        local alpha = math.clamp(
            (x - bar.AbsolutePosition.X) /
            bar.AbsoluteSize.X,
            0,
            1
        )

        SetValue(
            minValue +
            (maxValue - minValue) * alpha
        )
    end

    HubConnect(
        knob.MouseButton1Down:Connect(function()
            dragging = true
        end)
    )

    HubConnect(
        bar.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                MouseToValue(input.Position.X)
                dragging = true
            end

        end)
    )

    HubConnect(
        Services.UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = false
            end

        end)
    )

    HubConnect(
        Services.UserInputService.InputChanged:Connect(function(input)

            if dragging
                and input.UserInputType ==
                    Enum.UserInputType.MouseMovement then

                MouseToValue(input.Position.X)
            end

        end)
    )

    SetValue(defaultValue)
end

-- ========================================
-- TOGGLE
-- ========================================

local function CreateToggle(
    parent,
    y,
    titleText,
    description,
    defaultValue,
    callback
)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -30, 0, 62)
    button.Position = UDim2.new(0, 15, 0, y)
    button.BackgroundColor3 = Colors.Secondary
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 24)
    title.Position = UDim2.new(0, 14, 0, 7)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 14
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = button

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -80, 0, 20)
    desc.Position = UDim2.new(0, 14, 0, 33)
    desc.BackgroundTransparency = 1
    desc.Text = description
    desc.TextColor3 = Colors.TextSecondary
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Parent = button

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 42, 0, 22)
    switch.Position = UDim2.new(1, -56, 0.5, -11)
    switch.BackgroundColor3 = Colors.Primary
    switch.BorderSizePixel = 0
    switch.Parent = button

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.BackgroundColor3 = Colors.TextSecondary
    dot.BorderSizePixel = 0
    dot.Parent = switch

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local enabled = defaultValue

    local function Refresh()

        if enabled then
            switch.BackgroundColor3 = Colors.GetKey
            dot.BackgroundColor3 = Colors.NeonWhite
            dot.Position = UDim2.new(
                1, -19,
                0.5, -8
            )
        else
            switch.BackgroundColor3 = Colors.Primary
            dot.BackgroundColor3 = Colors.TextSecondary
            dot.Position = UDim2.new(
                0, 3,
                0.5, -8
            )
        end

        callback(enabled)
    end

    HubConnect(
        button.MouseButton1Click:Connect(function()

            enabled = not enabled
            Refresh()

        end)
    )

    Refresh()
end

-- ========================================
-- PLAYER BUTTON
-- ========================================

local function CreatePlayerButton(
    parent,
    y,
    player,
    callback
)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -30, 0, 44)
    button.Position = UDim2.new(0, 15, 0, y)
    button.BackgroundColor3 = Colors.Secondary
    button.BorderSizePixel = 0
    button.Text = player.DisplayName
        .. "  @" .. player.Name
    button.TextColor3 = Colors.TextPrimary
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.Parent = parent

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 14)
    padding.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    HubConnect(
        button.MouseButton1Click:Connect(function()
            callback(player)
        end)
    )

    return button
end

-- ========================================
-- CLEAR CONTENT
-- ========================================

local function ClearHubContent(content)

    for _, child in ipairs(content:GetChildren()) do

        if child:IsA("GuiObject") then
            child:Destroy()
        end

    end
end

-- ========================================
-- SPEED PANEL
-- ========================================

local function BuildSpeedPanel(content)

    ClearHubContent(content)

    CreateSlider(
        content,
        0,
        "Walk speed",
        1,
        250,
        HubState.Speed,
        function(value)

            HubState.Speed = value

            if HubState.SpeedEnabled then
                ApplySpeed()
            end

        end
    )

    CreateToggle(
        content,
        88,
        "Enable speed",
        "Apply the selected WalkSpeed.",
        HubState.SpeedEnabled,
        function(enabled)

            HubState.SpeedEnabled = enabled
            ApplySpeed()

        end
    )
end

-- ========================================
-- FLING PANEL
-- ========================================

local function BuildFlingPanel(content)

    ClearHubContent(content)

    CreateSlider(
        content,
        0,
        "Fling power",
        20,
        500,
        HubState.FlingPower,
        function(value)
            HubState.FlingPower = value
        end
    )

    CreateToggle(
        content,
        88,
        "Walk fling",
        "Push contacted characters away.",
        HubState.WalkFlingEnabled,
        function(enabled)

            SetWalkFling(enabled)

        end
    )
end

-- ========================================
-- FLY PANEL
-- ========================================

local function BuildFlyPanel(content)

    ClearHubContent(content)

    CreateSlider(
        content,
        0,
        "Fly speed",
        10,
        250,
        HubState.FlySpeed,
        function(value)
            HubState.FlySpeed = value
        end
    )

    CreateToggle(
        content,
        88,
        "Enable fly",
        "WASD move, Space rise, Ctrl descend.",
        HubState.FlyEnabled,
        function(enabled)

            if enabled then
                StartFly()
            else
                StopFly()
            end

        end
    )
end

-- ========================================
-- SPECTATE PANEL
-- ========================================

local function BuildSpectatePanel(content)

    ClearHubContent(content)

    local stop = Instance.new("TextButton")
    stop.Size = UDim2.new(1, -30, 0, 42)
    stop.Position = UDim2.new(0, 15, 0, 0)
    stop.BackgroundColor3 = Colors.Primary
    stop.BorderSizePixel = 0
    stop.Text = "Stop Spectating"
    stop.TextColor3 = Colors.TextPrimary
    stop.TextSize = 13
    stop.Font = Enum.Font.GothamMedium
    stop.Parent = content

    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stop

    HubConnect(
        stop.MouseButton1Click:Connect(function()
            StopSpectate()
        end)
    )

    local players = Services.Players:GetPlayers()

    local y = 52

    for _, player in ipairs(players) do

        if player ~= Player then

            CreatePlayerButton(
                content,
                y,
                player,
                function(target)
                    StartSpectate(target)
                end
            )

            y += 51
        end
    end
end

-- ========================================
-- ORBIT + TARGET PANEL
-- ========================================

local function BuildOrbitPanel(content)

    ClearHubContent(content)

    CreateSlider(
        content,
        0,
        "Orbit distance",
        3,
        50,
        HubState.OrbitDistance,
        function(value)
            HubState.OrbitDistance = value
        end
    )

    CreateSlider(
        content,
        88,
        "Orbit speed",
        1,
        10,
        HubState.OrbitSpeed,
        function(value)
            HubState.OrbitSpeed = value
        end
    )

    CreateToggle(
        content,
        176,
        "Orbit nearest player",
        "Automatically orbit the closest player.",
        HubState.OrbitEnabled,
        function(enabled)

            if enabled then

                local target = GetClosestPlayer()

                if target then
                    StartOrbit(target)
                else
                    HubState.OrbitEnabled = false
                end

            else
                StopOrbit()
            end

        end
    )

    CreateToggle(
        content,
        248,
        "Target lock",
        "Point the camera toward the selected target.",
        HubState.TargetLockEnabled,
        function(enabled)

            if enabled then

                local target =
                    HubState.OrbitTarget
                    or GetClosestPlayer()

                if target then
                    StartTargetLock(target)
                else
                    HubState.TargetLockEnabled = false
                end

            else
                StopTargetLock()
            end

        end
    )

    local y = 320

    for _, player in ipairs(
        Services.Players:GetPlayers()
    ) do

        if player ~= Player then

            CreatePlayerButton(
                content,
                y,
                player,
                function(target)

                    HubState.OrbitTarget = target

                    if HubState.OrbitEnabled then
                        StartOrbit(target)
                    end

                    if HubState.TargetLockEnabled then
                        StartTargetLock(target)
                    end

                end
            )

            y += 51
        end
    end
end

-- ========================================
-- NOCLIP PANEL
-- ========================================

local function BuildNoclipPanel(content)

    ClearHubContent(content)

    CreateToggle(
        content,
        0,
        "Enable noclip",
        "Disable character collisions.",
        HubState.NoclipEnabled,
        function(enabled)

            SetNoclip(enabled)

        end
    )

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -30, 0, 60)
    info.Position = UDim2.new(0, 15, 0, 82)
    info.BackgroundTransparency = 1
    info.Text =
        "When enabled, your character can pass through " ..
        "collidable parts. Respawning reapplies the setting."
    info.TextColor3 = Colors.TextSecondary
    info.TextSize = 13
    info.Font = Enum.Font.Gotham
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = content
end

-- ========================================
-- CREATE HUB
-- ========================================

function CreateAfterUI()

    if UI.HubGui then
        UI.HubGui.Enabled = true
        return
    end

    HubDisconnect()

    local hubGui = Instance.new("ScreenGui")
    hubGui.Name = "FEenablerHub"
    hubGui.ResetOnSpawn = false
    hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    hubGui.DisplayOrder = 200
    hubGui.Parent = PlayerGui

    UI.HubGui = hubGui

    -- ========================================
    -- MAIN WINDOW
    -- ========================================

    local hub = Instance.new("Frame")
    hub.Name = "Hub"
    hub.Size = UDim2.new(0, 720, 0, 440)
    hub.Position = UDim2.new(0.5, -360, 0.5, -220)
    hub.BackgroundColor3 = Colors.Background
    hub.BorderSizePixel = 0
    hub.Parent = hubGui

    local hubCorner = Instance.new("UICorner")
    hubCorner.CornerRadius = UDim.new(0, 14)
    hubCorner.Parent = hub

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Parent = hub

    -- ========================================
    -- TITLE BAR
    -- ========================================

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 64)
    titleBar.BackgroundColor3 = Colors.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = hub

    -- ========================================
    -- DRAGGING
    -- ========================================

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    HubConnect(
        titleBar.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                dragging = true
                dragStart = input.Position
                startPos = hub.Position

                input.Changed:Connect(function()

                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        dragging = false
                    end

                end)
            end

        end)
    )

    HubConnect(
        titleBar.InputChanged:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                dragInput = input
            end

        end)
    )

    HubConnect(
        Services.UserInputService.InputChanged:Connect(function(input)

            if input == dragInput and dragging then

                local delta =
                    input.Position - dragStart

                hub.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end

        end)
    )

    -- ========================================
    -- TITLE
    -- ========================================

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 22, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "FEenabler"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 21
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- ========================================
    -- AVATAR
    -- ========================================

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 38, 0, 38)
    avatar.Position = UDim2.new(1, -170, 0.5, -19)
    avatar.BackgroundColor3 = Colors.Secondary
    avatar.BorderSizePixel = 0
    avatar.Parent = titleBar

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar

    local avatarSuccess, avatarImage =
        pcall(function()

            return Services.Players:GetUserThumbnailAsync(
                Player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )

        end)

    if avatarSuccess then
        avatar.Image = avatarImage
    end

    -- ========================================
    -- DISPLAY NAME
    -- ========================================

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0, 120, 0, 38)
    name.Position = UDim2.new(1, -125, 0.5, -19)
    name.BackgroundTransparency = 1
    name.Text = Player.DisplayName
    name.TextColor3 = Colors.TextPrimary
    name.TextSize = 14
    name.Font = Enum.Font.GothamMedium
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = titleBar

    -- ========================================
    -- SIDEBAR
    -- ========================================

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, -64)
    sidebar.Position = UDim2.new(0, 0, 0, 64)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 3
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.Parent = hub

    local sidePadding = Instance.new("UIPadding")
    sidePadding.PaddingTop = UDim.new(0, 12)
    sidePadding.PaddingLeft = UDim.new(0, 10)
    sidePadding.PaddingRight = UDim.new(0, 10)
    sidePadding.PaddingBottom = UDim.new(0, 12)
    sidePadding.Parent = sidebar

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 7)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Parent = sidebar

    -- ========================================
    -- RIGHT PANEL
    -- ========================================

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(1, -200, 1, -84)
    panel.Position = UDim2.new(0, 190, 0, 74)
    panel.BackgroundColor3 = Colors.Surface
    panel.BorderSizePixel = 0
    panel.Parent = hub

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 10)
    panelCorner.Parent = panel

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -30, 0, 32)
    panelTitle.Position = UDim2.new(0, 15, 0, 12)
    panelTitle.BackgroundTransparency = 1
    panelTitle.TextColor3 = Colors.TextPrimary
    panelTitle.TextSize = 20
    panelTitle.Font = Enum.Font.GothamBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panel

    local panelDescription = Instance.new("TextLabel")
    panelDescription.Size = UDim2.new(1, -30, 0, 25)
    panelDescription.Position = UDim2.new(0, 15, 0, 45)
    panelDescription.BackgroundTransparency = 1
    panelDescription.TextColor3 = Colors.TextSecondary
    panelDescription.TextSize = 12
    panelDescription.Font = Enum.Font.Gotham
    panelDescription.TextXAlignment = Enum.TextXAlignment.Left
    panelDescription.Parent = panel

    -- ========================================
    -- CONTENT
    -- ========================================

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -10, 1, -80)
    content.Position = UDim2.new(0, 5, 0, 80)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = panel

    -- ========================================
    -- TABS
    -- ========================================

    local tabs = {}

    local function SelectTab(tabName)

        for name, tab in pairs(tabs) do

            if name == tabName then
                tab.BackgroundColor3 = Colors.Primary
                tab.TextColor3 = Colors.TextPrimary
            else
                tab.BackgroundColor3 = Colors.Secondary
                tab.TextColor3 = Colors.TextSecondary
            end

        end

        if tabName == "Speed" then

            panelTitle.Text = "Speed"
            panelDescription.Text =
                "Movement speed controls."

            BuildSpeedPanel(content)

        elseif tabName == "Fling" then

            panelTitle.Text = "Fling"
            panelDescription.Text =
                "Contact-based movement simulation."

            BuildFlingPanel(content)

        elseif tabName == "Fly" then

            panelTitle.Text = "Fly"
            panelDescription.Text =
                "Camera-relative flight controls."

            BuildFlyPanel(content)

        elseif tabName == "Spectate" then

            panelTitle.Text = "Spectate"
            panelDescription.Text =
                "View another player."

            BuildSpectatePanel(content)

        elseif tabName == "Orbit + Aimbot" then

            panelTitle.Text = "Orbit + Aimbot"
            panelDescription.Text =
                "Target selection and camera tracking."

            BuildOrbitPanel(content)

        elseif tabName == "Noclip" then

            panelTitle.Text = "Noclip"
            panelDescription.Text =
                "Character collision controls."

            BuildNoclipPanel(content)
        end
    end

    local function CreateTab(tabName, order)

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 44)
        button.BackgroundColor3 = Colors.Secondary
        button.BorderSizePixel = 0
        button.Text = tabName
        button.TextColor3 = Colors.TextSecondary
        button.TextSize = 14
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = false
        button.LayoutOrder = order
        button.Parent = sidebar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button

        tabs[tabName] = button

        HubConnect(
            button.MouseButton1Click:Connect(function()
                SelectTab(tabName)
            end)
        )
    end

    CreateTab("Speed", 1)
    CreateTab("Fling", 2)
    CreateTab("Fly", 3)
    CreateTab("Spectate", 4)
    CreateTab("Orbit + Aimbot", 5)
    CreateTab("Noclip", 6)

    SelectTab("Speed")

    -- ========================================
    -- PLAYER RESPAWN
    -- ========================================

    HubConnect(
        Player.CharacterAdded:Connect(function()

            task.wait(0.3)

            if HubState.SpeedEnabled then
                ApplySpeed()
            end

            if HubState.NoclipEnabled then
                ApplyNoclip()
            end

            if HubState.FlyEnabled then
                StartFly()
            end

            if HubState.WalkFlingEnabled then
                SetWalkFling(true)
            end

            if HubState.Spectating then
                StopSpectate()
            end

        end)
    )
end

-- ========================================

-- EVENT CONNECTIONS

-- ========================================

local function ConnectEvents()

    Services.UserInputService.InputChanged:Connect(function(input, gameProcessed)

        if input.UserInputType == Enum.UserInputType.MouseMovement then

            State.MousePosition.X = input.Position.X

            State.MousePosition.Y = input.Position.Y

        end

    end)

    UI.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()

        local currentText = UI.Input.TextBox.Text

        if string.len(currentText) > Config.MaxKeyLength then

            UI.Input.TextBox.Text = string.sub(currentText, 1, Config.MaxKeyLength)

            ShowStatus("Maximum character limit reached (" .. Config.MaxKeyLength .. ")", true)

        end

        UpdateCharCounter()

        ClearStatus()

    end)

    local inputGlowTween = nil

    UI.Input.TextBox.Focused:Connect(function()

        State.FocusStates.InputFocused = true

        UI.Input.Glow.Frame.Visible = true

        Services.TweenService:Create(UI.Input.Stroke, 

            TweenInfo.new(0.2, Enum.EasingStyle.Quad), 

            {Color = Colors.NeonWhite, Transparency = 0.1}):Play()

        Services.TweenService:Create(UI.Input.Glow.Stroke, 

            TweenInfo.new(0.2, Enum.EasingStyle.Quad), 

            {Transparency = 0.1}):Play()

        if inputGlowTween then inputGlowTween:Cancel() end

        inputGlowTween = Services.TweenService:Create(UI.Input.Glow.Gradient, 

            TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), 

            {Rotation = 360})

        inputGlowTween:Play()

        State.Animations.InputGlowTween = inputGlowTween

        ClearStatus()

    end)

    UI.Input.TextBox.FocusLost:Connect(function()

        State.FocusStates.InputFocused = false

        Services.TweenService:Create(UI.Input.Stroke, 

            TweenInfo.new(0.2, Enum.EasingStyle.Quad), 

            {Color = Colors.Border, Transparency = 0.3}):Play()

        Services.TweenService:Create(UI.Input.Glow.Stroke, 

            TweenInfo.new(0.3, Enum.EasingStyle.Quad), 

            {Transparency = 0.8}):Play()

        if inputGlowTween then

            inputGlowTween:Cancel()

            UI.Input.Glow.Gradient.Rotation = 0

            State.Animations.InputGlowTween = nil

        end

        task.spawn(function()

            task.wait(0.3)

            if UI.Input.Glow.Frame and UI.Input.Glow.Frame.Parent then

                UI.Input.Glow.Frame.Visible = false

            end

        end)

    end)

    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if gameProcessed or State.IsDestroyed then return end

        if input.KeyCode == Enum.KeyCode.Return and UI.Input.TextBox:IsFocused() then

            local key = UI.Input.TextBox.Text

            if key == "" then

                ShowStatus("Please enter an access key", true)

                UI.Input.TextBox:CaptureFocus()

                return

            end

            SetLoading(true)

            ShowStatus("Validating key...", false, false)

            task.spawn(function()
                local valid, result = VerifyKey(key)
                SetLoading(false)

                if valid then
                    ShowStatus("Access key verified!", false, true)
                    print("Valid key:", result.key)

                    UI.ScreenGui.Enabled = false
                    CreateAfterUI()
                else
                    ShowStatus(result, true)
                end
            end)

        end

    end)

    UI.Buttons.Submit.MouseButton1Click:Connect(function()

        if State.IsLoading then return end

        local key = UI.Input.TextBox.Text

        if key == "" then

            ShowStatus("Please enter an access key", true)

            UI.Input.TextBox:CaptureFocus()

            return

        end

        SetLoading(true)

        ShowStatus("Validating key...", false, false)

        task.spawn(function()
                local valid, result = VerifyKey(key)
                SetLoading(false)

                if valid then
                    ShowStatus("Access key verified!", false, true)
                    print("Valid key:", result.key)

                    UI.ScreenGui.Enabled = false
                    CreateAfterUI()
                else
                    ShowStatus(result, true)
                end
            end)

    end)

    UI.Buttons.GetKey.MouseButton1Click:Connect(function()

        ShowStatus("Opening key website...", false, false)

        CopyToClipboard("https://thisusernameisprobablytaken.github.io/FEenabler/", "Key website link copied to clipboard!")

    end)

    UI.Buttons.Discord.MouseButton1Click:Connect(function()

        ShowStatus("Opening Discord invite...", false, false)

        CopyToClipboard("https://discord.gg/EjxsXkYsQ2", "Discord link copied to clipboard!")

    end)

end

-- ========================================

-- ANIMATION LOOPS

-- ========================================

local function StartAnimationLoops()

    State.Animations.BorderTween = nil
    State.Animations.IconTween = nil
    State.FocusStates.AnimationsActive = true

    task.spawn(function()

        for i = 1, 25 do
            if State.IsDestroyed then
                break
            end

            CreateParticle()
            task.wait(math.random(20, 100) / 1000)
        end

        while not State.IsDestroyed and UI.ScreenGui.Parent do
            if #State.Particles < Config.ParticleCount then
                CreateParticle()
            end

            task.wait(math.random(400, 1200) / 1000)
        end

    end)

    task.spawn(function()

        while not State.IsDestroyed and UI.ScreenGui.Parent do
            pcall(UpdateParticles)
            task.wait(1 / Config.ParticleSpeed)
        end

    end)

    task.spawn(function()

        while not State.IsDestroyed
            and UI.AnimatedBorder
            and UI.AnimatedBorder.Frame
            and UI.AnimatedBorder.Frame.Parent do

            if State.Animations.BorderTween then
                State.Animations.BorderTween:Cancel()
            end

            local startRotation = UI.AnimatedBorder.Gradient.Rotation

            local tween = Services.TweenService:Create(
                UI.AnimatedBorder.Gradient,
                TweenInfo.new(4, Enum.EasingStyle.Linear),
                {Rotation = startRotation + 360}
            )

            State.Animations.BorderTween = tween

            tween:Play()

            local success = pcall(function()
                tween.Completed:Wait()
            end)

            if not success then
                task.wait(4)
            end

            if UI.AnimatedBorder
                and UI.AnimatedBorder.Gradient
                and UI.AnimatedBorder.Gradient.Parent then

                UI.AnimatedBorder.Gradient.Rotation =
                    UI.AnimatedBorder.Gradient.Rotation % 360
            end

            task.wait(0.1)
        end

    end)

    task.spawn(function()

        while not State.IsDestroyed
            and UI.Header
            and UI.Header.IconGlow
            and UI.Header.IconGlow.Parent do

            if State.Animations.IconTween then
                State.Animations.IconTween:Cancel()
            end

            local startRotation = UI.Header.IconGlow.Rotation

            State.Animations.IconTween = Services.TweenService:Create(
                UI.Header.IconGlow,
                TweenInfo.new(3, Enum.EasingStyle.Linear),
                {Rotation = startRotation + 360}
            )

            State.Animations.IconTween:Play()

            local success = pcall(function()
                State.Animations.IconTween.Completed:Wait()
            end)

            if not success then
                task.wait(3)
            end

            if UI.Header
                and UI.Header.IconGlow
                and UI.Header.IconGlow.Parent then

                UI.Header.IconGlow.Rotation =
                    UI.Header.IconGlow.Rotation % 360
            end

            task.wait(0.1)
        end

    end)

end

-- ========================================

-- MAIN INITIALIZATION

-- ========================================

local function Initialize()

    local screenGui = CreateMainGUI()

    local backdrop = CreateBackdrop(screenGui)

    CreateParticleContainer(backdrop)

    local container = CreateContainer(screenGui)

    CreateAnimatedBorder(container)

    CreateHeader(container)

    local content = CreateContent(container)

    CreateInputSection(content)

    CreateButtons(content)

    CreateStatus(content)

    CreateButtonGlow(UI.Buttons.Submit, Colors.HoverPrimary, Colors.Primary)

    CreateButtonGlow(UI.Buttons.GetKey, Colors.HoverGetKey, Colors.GetKey)

    CreateButtonGlow(UI.Buttons.Discord, Colors.HoverDiscord, Colors.Discord)

    UpdateCharCounter()

    ConnectEvents()

    StartAnimationLoops()

    PlayEntranceAnimation()

end

-- ========================================

-- START THE GUI

-- ========================================

Initialize()
