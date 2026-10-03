local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("Feenabler")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "Feenabler"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(850, 520)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 45, 55)
stroke.Thickness = 1
stroke.Parent = main

-- TITLE BAR

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 52)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.fromOffset(18, 0)
title.BackgroundTransparency = 1
title.Text = "feenabler"
title.TextColor3 = Color3.fromRGB(245, 245, 248)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromOffset(150, 30)
subtitle.Position = UDim2.new(1, -170, 0, 11)
subtitle.BackgroundTransparency = 1
subtitle.Text = "SIMULATOR"
subtitle.TextColor3 = Color3.fromRGB(110, 110, 125)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Right
subtitle.Parent = titleBar

-- DRAGGING

local dragging = false
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- SIDEBAR

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 190, 1, -52)
sidebar.Position = UDim2.fromOffset(0, 52)
sidebar.BackgroundColor3 = Color3.fromRGB(19, 19, 24)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 15)
sidePadding.PaddingLeft = UDim.new(0, 12)
sidePadding.PaddingRight = UDim.new(0, 12)
sidePadding.Parent = sidebar

local sideList = Instance.new("UIListLayout")
sideList.Padding = UDim.new(0, 5)
sideList.Parent = sidebar

local tabs = {
    "Speed",
    "Fly",
    "Fling",
    "Noclip",
    "Orbit",
    "Aimbot",
    "ESP",
    "Pathfinding"
}

local pages = {}
local tabButtons = {}

-- CONTENT

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -190, 1, -52)
content.Position = UDim2.fromOffset(190, 52)
content.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
content.BorderSizePixel = 0
content.Parent = main

local function createLabel(parent, text, x, y, size, textSize)
    local label = Instance.new("TextLabel")

    label.Size = size or UDim2.fromOffset(500, 30)
    label.Position = UDim2.fromOffset(x, y)

    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 235)
    label.TextSize = textSize or 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = parent

    return label
end

local function createButton(parent, text, x, y, width)
    local button = Instance.new("TextButton")

    button.Size = UDim2.fromOffset(width or 170, 38)
    button.Position = UDim2.fromOffset(x, y)

    button.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
    button.BorderSizePixel = 0

    button.Text = text
    button.TextColor3 = Color3.fromRGB(220, 220, 225)
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium

    button.AutoButtonColor = false
    button.Parent = parent

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(38, 38, 47)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
    end)

    return button
end

local function createToggle(parent, text, x, y)
    local button = createButton(parent, text .. "    OFF", x, y, 210)

    local enabled = false

    button.MouseButton1Click:Connect(function()
        enabled = not enabled

        if enabled then
            button.Text = text .. "    ON"
            button.BackgroundColor3 = Color3.fromRGB(45, 75, 55)
        else
            button.Text = text .. "    OFF"
            button.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
        end

        print("[Feenabler]", text, enabled)
    end)

    return button
end

local function createInput(parent, text, default, x, y)
    createLabel(parent, text, x, y, UDim2.fromOffset(180, 25), 13)

    local box = Instance.new("TextBox")

    box.Size = UDim2.fromOffset(210, 38)
    box.Position = UDim2.fromOffset(x, y + 28)

    box.BackgroundColor3 = Color3.fromRGB(25, 25, 31)
    box.BorderSizePixel = 0

    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(230, 230, 235)
    box.PlaceholderText = tostring(default)
    box.TextSize = 13
    box.Font = Enum.Font.Gotham

    box.ClearTextOnFocus = false
    box.Parent = parent

    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        print("[Feenabler]", text, "=", box.Text)
    end)

    return box
end

-- PAGES

for _, tabName in ipairs(tabs) do

    local page = Instance.new("Frame")
    page.Name = tabName
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    pages[tabName] = page

    createLabel(
        page,
        tabName,
        28,
        24,
        UDim2.fromOffset(500, 35),
        21
    )

    createLabel(
        page,
        "Configure " .. tabName .. " settings",
        28,
        57,
        UDim2.fromOffset(500, 25),
        12
    )

    if tabName == "Speed" then

        createToggle(page, "Speed", 28, 105)
        createInput(page, "Speed value", 100, 28, 165)

    elseif tabName == "Fly" then

        createToggle(page, "Fly", 28, 105)
        createInput(page, "Fly speed", 50, 28, 165)

    elseif tabName == "Fling" then

        createToggle(page, "Fling", 28, 105)
        createInput(page, "Power", 100, 28, 165)

        createButton(
            page,
            "Target player",
            270,
            165,
            190
        )

    elseif tabName == "Noclip" then

        createToggle(page, "Noclip", 28, 105)

    elseif tabName == "Orbit" then

        createToggle(page, "Orbit", 28, 105)
        createInput(page, "Radius", 10, 28, 165)
        createInput(page, "Orbit speed", 5, 270, 165)

    elseif tabName == "Aimbot" then

        createToggle(page, "Aimbot", 28, 105)
        createToggle(page, "Team check", 28, 165)
        createInput(page, "FOV", 100, 270, 165)
        createInput(page, "Smoothness", 5, 270, 245)

    elseif tabName == "ESP" then

        createToggle(page, "ESP", 28, 105)
        createToggle(page, "Names", 28, 165)
        createToggle(page, "Distance", 28, 225)
        createToggle(page, "Health", 270, 165)

    elseif tabName == "Pathfinding" then

        createToggle(page, "Pathfinding", 28, 105)
        createInput(page, "Range", 100, 28, 165)

        createButton(
            page,
            "Follow target",
            270,
            165,
            190
        )

        createButton(
            page,
            "Generate path",
            270,
            215,
            190
        )
    end
end

-- TAB BUTTONS

for _, tabName in ipairs(tabs) do

    local button = createButton(
        sidebar,
        tabName,
        0,
        0,
        166
    )

    tabButtons[tabName] = button

    button.MouseButton1Click:Connect(function()

        for name, page in pairs(pages) do
            page.Visible = name == tabName
        end

        for name, tab in pairs(tabButtons) do
            if name == tabName then
                tab.BackgroundColor3 =
                    Color3.fromRGB(45, 45, 55)
            else
                tab.BackgroundColor3 =
                    Color3.fromRGB(29, 29, 36)
            end
        end
    end)
end

-- DEFAULT TAB

pages.Speed.Visible = true
tabButtons.Speed.BackgroundColor3 =
    Color3.fromRGB(45, 45, 55)

print("Feenabler loaded")
