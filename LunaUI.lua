--[[
    Luna UI
    A reusable interface library that follows the supplied Product Faker V2 layout:
    compact black window, Roboto Condensed, image-only bottom navigation, moving
    underline indicator, rounded controls, hover animations, draggable title bar,
    and RightShift visibility toggle.

    This is a UI toolkit. Add your own safe feature callbacks to controls.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LunaUI = {}
LunaUI.__index = LunaUI

local COLORS = {
    bg = Color3.fromRGB(13, 13, 13),
    panel = Color3.fromRGB(30, 30, 30),
    panelHi = Color3.fromRGB(38, 38, 38),
    button = Color3.fromRGB(56, 56, 56),
    buttonHi = Color3.fromRGB(72, 72, 72),
    active = Color3.fromRGB(84, 84, 84),
    icon = Color3.fromRGB(193, 193, 193),
    dim = Color3.fromRGB(120, 120, 120),
    white = Color3.fromRGB(255, 255, 255),
    red = Color3.fromRGB(255, 57, 57),
    blue = Color3.fromRGB(94, 115, 255),
    yellow = Color3.fromRGB(238, 255, 131),
    green = Color3.fromRGB(110, 255, 150),
}

local IMAGES = {
    Close = "rbxassetid://89309313651390",
    Home = "rbxassetid://70573525526341",
    Faker = "rbxassetid://117975333704340",
    Logger = "rbxassetid://109982256018444",
    Supported = "rbxassetid://133954136637154",
    Passes = "rbxassetid://84787327728949",
    Join = "rbxassetid://88984171145049",
    Copy = "rbxassetid://101160281432561",
}

local FONT_FAMILY = "rbxasset://fonts/families/RobotoCondensed.json"
local FONT = Font.new(FONT_FAMILY, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local FONT_BOLD = Font.new(FONT_FAMILY, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local FONT_ITALIC = Font.new(FONT_FAMILY, Enum.FontWeight.Regular, Enum.FontStyle.Italic)

local function make(className, properties, children)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        if key ~= "Parent" then
            object[key] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    if properties and properties.Parent then
        object.Parent = properties.Parent
    end
    return object
end

local function round(object, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = object,
    })
end

local function outline(object, transparency)
    make("UIStroke", {
        Color = COLORS.white,
        Transparency = transparency or 0.86,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = object,
    })
end

local function animate(object, duration, properties, style, direction)
    local ok, tween = pcall(function()
        return TweenService:Create(
            object,
            TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
            properties
        )
    end)
    if ok and tween then
        tween:Play()
    end
    return tween
end

local function label(parent, text, properties)
    properties = properties or {}
    properties.Parent = parent
    properties.Text = text or ""
    properties.BackgroundTransparency = properties.BackgroundTransparency or 1
    properties.BorderSizePixel = 0
    properties.FontFace = properties.FontFace or FONT
    properties.TextColor3 = properties.TextColor3 or COLORS.white
    properties.TextSize = properties.TextSize or 14
    properties.TextWrapped = properties.TextWrapped ~= false
    return make("TextLabel", properties)
end

local function imageButton(parent, name, image, size, position)
    local button = make("ImageButton", {
        Name = name,
        Parent = parent,
        Size = size,
        Position = position or UDim2.new(),
        BackgroundColor3 = COLORS.button,
        BorderSizePixel = 0,
        Image = image or "",
        ImageColor3 = COLORS.icon,
        AutoButtonColor = false,
    })
    round(button, 8)
    outline(button, 0.86)
    local scale = make("UIScale", {Parent = button})
    button.MouseEnter:Connect(function()
        animate(button, 0.15, {BackgroundColor3 = COLORS.buttonHi, ImageColor3 = COLORS.white})
    end)
    button.MouseLeave:Connect(function()
        animate(button, 0.2, {BackgroundColor3 = COLORS.button, ImageColor3 = COLORS.icon})
        animate(scale, 0.2, {Scale = 1})
    end)
    button.MouseButton1Down:Connect(function()
        animate(scale, 0.08, {Scale = 0.9})
    end)
    button.MouseButton1Up:Connect(function()
        animate(scale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
    end)
    return button
end

local function resolveIcon(name, provided)
    if type(provided) == "string" and provided ~= "" then
        if provided:match("^%d+$") then
            return "rbxassetid://" .. provided
        end
        return provided
    end
    local key = tostring(name or "")
    for known, asset in pairs(IMAGES) do
        if string.lower(known) == string.lower(key) then
            return asset
        end
    end
    return ""
end

function LunaUI:CreateWindow(options)
    options = options or {}
    local player = Players.LocalPlayer

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LunaUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mounted = false
    if typeof(gethui) == "function" then
        local ok, holder = pcall(gethui)
        if ok and holder then
            mounted = pcall(function() screenGui.Parent = holder end) and screenGui.Parent ~= nil
        end
    end
    if not mounted then
        local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
        if ok and coreGui then
            mounted = pcall(function() screenGui.Parent = coreGui end) and screenGui.Parent ~= nil
        end
    end
    if not mounted and player then
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end

    local width = tonumber(options.Width)
    local height = tonumber(options.Height)
    local mainSize
    if width then
        mainSize = UDim2.fromOffset(width, height or (width / 1.2415))
    else
        -- The original layout uses a scale-based size with a 1.2415 aspect ratio.
        mainSize = UDim2.fromScale(0.285, 0.439)
    end

    local main = make("Frame", {
        Name = "Main",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = mainSize,
        BackgroundColor3 = COLORS.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    round(main, 8)
    outline(main, 0.74)
    make("UISizeConstraint", {
        Parent = main,
        MinSize = Vector2.new(380, 306),
        MaxSize = Vector2.new(900, 724),
    })
    make("UIAspectRatioConstraint", {
        Parent = main,
        AspectRatio = tonumber(options.AspectRatio) or 1.2415,
        DominantAxis = Enum.DominantAxis.Width,
    })
    local mainScale = make("UIScale", {Parent = main, Scale = 1})

    local topBar = make("Frame", {
        Name = "TopBar",
        Parent = main,
        Size = UDim2.fromScale(1, 0.125),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
    }, {
        make("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })
    local title = label(topBar, options.Title or "🌙 Luna Scripts", {
        Name = "Title",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0.034, 0.5),
        Size = UDim2.fromScale(0.8, 0.386),
        FontFace = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = true,
    })

    local closeButton = imageButton(
        topBar,
        "CloseButton",
        IMAGES.Close,
        UDim2.fromScale(0.069, 0.693),
        UDim2.fromScale(0.914, 0.1535)
    )
    closeButton.AnchorPoint = Vector2.new(0, 0)
    closeButton.MouseEnter:Connect(function()
        animate(closeButton, 0.15, {
            BackgroundColor3 = Color3.fromRGB(150, 40, 40),
            ImageColor3 = COLORS.white,
        })
    end)

    local content = make("Frame", {
        Name = "SectionsContainer",
        Parent = main,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.938, 0.665),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })

    local bottomBar = make("Frame", {
        Name = "BottomBar",
        Parent = main,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1, 0.125),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
    })
    make("UICorner", {
        Parent = bottomBar,
        CornerRadius = UDim.new(0, 8),
    })

    local buttonContainer = make("Frame", {
        Name = "ButtonContainer",
        Parent = bottomBar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.9588, 0.636),
        BackgroundTransparency = 1,
    })
    make("UIListLayout", {
        Parent = buttonContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local indicator = make("Frame", {
        Name = "TabIndicator",
        Parent = bottomBar,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.fromOffset(14, 2),
        BackgroundColor3 = COLORS.white,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    round(indicator, 1)

    local window = setmetatable({
        _gui = screenGui,
        _main = main,
        _mainScale = mainScale,
        _content = content,
        _bottomBar = bottomBar,
        _buttons = buttonContainer,
        _indicator = indicator,
        _tabs = {},
        _activeTab = nil,
        _connections = {},
        _destroyed = false,
        _visible = true,
        _title = title,
    }, {__index = LunaUI})

    local function track(connection)
        table.insert(window._connections, connection)
        return connection
    end

    local function updateIndicator(instant)
        local tab = window._activeTab
        if not tab or not tab._button.Parent then
            return
        end
        local x = tab._button.AbsolutePosition.X + tab._button.AbsoluteSize.X / 2 - bottomBar.AbsolutePosition.X
        local goal = {Position = UDim2.new(0, x, 1, -2)}
        if instant then
            indicator.Position = goal.Position
        else
            animate(indicator, 0.4, goal)
        end
    end

    local function selectTab(tab, instant)
        if window._destroyed or window._activeTab == tab then
            return
        end
        local previous = window._activeTab
        window._activeTab = tab

        for _, entry in ipairs(window._tabs) do
            local selected = entry == tab
            animate(entry._button, instant and 0 or 0.2, {
                BackgroundColor3 = selected and COLORS.active or COLORS.button,
                ImageColor3 = selected and COLORS.white or COLORS.icon,
            })
        end
        updateIndicator(instant)

        if previous then
            previous._page.Visible = false
        end
        tab._page.Visible = true
        if instant then
            tab._page.Position = UDim2.new()
            tab._page.BackgroundTransparency = 1
        else
            tab._page.Position = UDim2.fromScale(0.06, 0)
            animate(tab._page, 0.35, {Position = UDim2.new()})
        end
    end

    function window:SetTitle(newTitle)
        if not self._destroyed then
            self._title.Text = tostring(newTitle or "")
        end
    end

    function window:CreateTab(name, config)
        assert(not self._destroyed, "Cannot add a tab to a destroyed Luna UI window")
        name = tostring(name or "Tab")
        config = type(config) == "table" and config or {}

        local page = make("Frame", {
            Name = name:gsub("%W", "") .. "Screen",
            Parent = content,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            ClipsDescendants = true,
        })
        local scroll = make("ScrollingFrame", {
            Name = "Items",
            Parent = page,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = COLORS.button,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        })
        make("UIListLayout", {
            Parent = scroll,
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        make("UIPadding", {
            Parent = scroll,
            PaddingTop = UDim.new(0, 1),
            PaddingBottom = UDim.new(0, 1),
            PaddingLeft = UDim.new(0, 1),
            PaddingRight = UDim.new(0, 4),
        })
        local empty = label(scroll, "Nothing here yet.", {
            Name = "Empty",
            AnchorPoint = Vector2.new(0, 0),
            Size = UDim2.new(1, -8, 0, 40),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextScaled = false,
            TextSize = 14,
            TextColor3 = COLORS.dim,
            LayoutOrder = -1000000,
        })

        local button = imageButton(
            buttonContainer,
            name .. "Button",
            resolveIcon(name, config.Icon),
            UDim2.fromScale(0.0668, 1)
        )
        button.LayoutOrder = #self._tabs + 1
        button:SetAttribute("TabName", name)

        local tab = {
            _window = self,
            _name = name,
            _page = page,
            _items = scroll,
            _button = button,
            _empty = empty,
        }
        table.insert(self._tabs, tab)
        track(button.MouseButton1Click:Connect(function()
            selectTab(tab, false)
        end))

        local function refreshEmpty()
            if not empty.Parent then
                return
            end
            local hasItem = false
            for _, child in ipairs(scroll:GetChildren()) do
                if child:GetAttribute("IsLunaRow") then
                    hasItem = true
                    break
                end
            end
            empty.Visible = not hasItem
        end
        track(scroll.ChildAdded:Connect(refreshEmpty))
        track(scroll.ChildRemoved:Connect(refreshEmpty))

        function tab:CreateSection(sectionName)
            local section = make("Frame", {
                Name = "Section",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 28),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            })
            section:SetAttribute("IsLunaRow", true)
            label(section, tostring(sectionName or "Section"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.new(1, -6, 1, 0),
                FontFace = FONT_BOLD,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = COLORS.icon,
            })
            make("Frame", {
                Parent = section,
                Position = UDim2.new(0, 3, 1, -1),
                Size = UDim2.new(1, -6, 0, 1),
                BackgroundColor3 = COLORS.white,
                BackgroundTransparency = 0.9,
                BorderSizePixel = 0,
            })
            return section
        end

        function tab:CreateLabel(text)
            local row = make("Frame", {
                Name = "LabelRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 34),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 7)
            outline(row, 0.9)
            label(row, tostring(text or ""), {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(1, -20, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = COLORS.icon,
                TextSize = 13,
                TextScaled = false,
            })
            refreshEmpty()
            return row
        end

        function tab:CreateParagraph(text, paragraphOptions)
            paragraphOptions = paragraphOptions or {}
            local row = make("Frame", {
                Name = "Paragraph",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, paragraphOptions.Height or 54),
                BackgroundColor3 = paragraphOptions.Background and COLORS.panel or COLORS.bg,
                BackgroundTransparency = paragraphOptions.Background and 0 or 1,
                BorderSizePixel = 0,
            })
            row:SetAttribute("IsLunaRow", true)
            if paragraphOptions.Background then
                round(row, 7)
                outline(row, 0.9)
            end
            label(row, tostring(text or ""), {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 4, 0.5, 0),
                Size = UDim2.new(1, -8, 1, 0),
                FontFace = paragraphOptions.Italic and FONT_ITALIC or FONT,
                TextXAlignment = paragraphOptions.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = paragraphOptions.Color or COLORS.white,
                TextScaled = false,
                TextSize = paragraphOptions.TextSize or 14,
            })
            refreshEmpty()
            return row
        end

        function tab:CreateButton(controlOptions)
            if type(controlOptions) ~= "table" then
                controlOptions = {Name = tostring(controlOptions or "Button")}
            end
            local row = make("TextButton", {
                Name = "ButtonRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 66),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 8)
            outline(row, 0.9)
            local icon = make("ImageLabel", {
                Name = "Icon",
                Parent = row,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 35, 0.5, 0),
                Size = UDim2.fromOffset(49, 49),
                BackgroundColor3 = COLORS.button,
                BorderSizePixel = 0,
                Image = resolveIcon(controlOptions.Name, controlOptions.Icon),
                ImageColor3 = COLORS.icon,
                ScaleType = Enum.ScaleType.Crop,
            })
            round(icon, 7)
            outline(icon, 0.9)
            label(row, controlOptions.Name or "Button", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 71, 0, 24),
                Size = UDim2.new(1, -120, 0, 17),
                FontFace = FONT_BOLD,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = false,
                TextSize = 14,
            })
            if controlOptions.Description or controlOptions.Subtext then
                label(row, controlOptions.Description or controlOptions.Subtext, {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 71, 0, 43),
                    Size = UDim2.new(1, -120, 0, 16),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = COLORS.icon,
                    TextScaled = false,
                    TextSize = 12,
                })
            end
            local hoverScale = make("UIScale", {Parent = row})
            row.MouseEnter:Connect(function()
                animate(row, 0.15, {BackgroundColor3 = COLORS.panelHi})
            end)
            row.MouseLeave:Connect(function()
                animate(row, 0.2, {BackgroundColor3 = COLORS.panel})
                animate(hoverScale, 0.2, {Scale = 1})
            end)
            row.MouseButton1Down:Connect(function()
                animate(hoverScale, 0.08, {Scale = 0.98})
            end)
            row.MouseButton1Up:Connect(function()
                animate(hoverScale, 0.25, {Scale = 1}, Enum.EasingStyle.Back)
            end)
            track(row.Activated:Connect(function()
                if type(controlOptions.Callback) == "function" then
                    local ok, err = pcall(controlOptions.Callback)
                    if not ok then warn("[Luna UI] Button callback:", err) end
                end
            end))
            refreshEmpty()
            return row
        end

        function tab:CreateToggle(controlOptions)
            controlOptions = type(controlOptions) == "table" and controlOptions or {}
            local enabled = controlOptions.Default == true
            local row = make("Frame", {
                Name = "ToggleRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 40),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 7)
            outline(row, 0.9)
            label(row, controlOptions.Name or "Toggle", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(1, -64, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = false,
                TextSize = 13,
            })
            local switch = make("TextButton", {
                Name = "Switch",
                Parent = row,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(1, -48, 0.5, 0),
                Size = UDim2.fromOffset(36, 20),
                BackgroundColor3 = COLORS.button,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
            })
            round(switch, 10)
            local dot = make("Frame", {
                Parent = switch,
                Position = UDim2.new(0, 3, 0.5, -7),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = COLORS.white,
                BorderSizePixel = 0,
            })
            round(dot, 8)
            local function update(callCallback)
                animate(switch, 0.15, {BackgroundColor3 = enabled and COLORS.green or COLORS.button})
                animate(dot, 0.15, {Position = UDim2.new(0, enabled and 19 or 3, 0.5, -7)})
                if callCallback and type(controlOptions.Callback) == "function" then
                    local ok, err = pcall(controlOptions.Callback, enabled)
                    if not ok then warn("[Luna UI] Toggle callback:", err) end
                end
            end
            track(switch.Activated:Connect(function()
                enabled = not enabled
                update(true)
            end))
            update(false)
            refreshEmpty()
            return {
                Instance = row,
                GetValue = function() return enabled end,
                SetValue = function(value)
                    enabled = value == true
                    update(true)
                end,
            }
        end

        function tab:CreateSlider(controlOptions)
            controlOptions = controlOptions or {}
            local minimum = tonumber(controlOptions.Min) or 0
            local maximum = tonumber(controlOptions.Max) or 100
            if maximum < minimum then maximum = minimum end
            local value = math.clamp(tonumber(controlOptions.Default) or minimum, minimum, maximum)
            local row = make("Frame", {
                Name = "SliderRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 55),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 7)
            outline(row, 0.9)
            label(row, controlOptions.Name or "Slider", {
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(0.7, 0, 0, 19),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = false,
                TextSize = 13,
            })
            local number = label(row, tostring(value), {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -10, 0, 4),
                Size = UDim2.new(0.25, 0, 0, 19),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = COLORS.icon,
                TextScaled = false,
                TextSize = 13,
            })
            local trackBar = make("TextButton", {
                Name = "Track",
                Parent = row,
                Position = UDim2.new(0, 10, 0, 31),
                Size = UDim2.new(1, -20, 0, 8),
                BackgroundColor3 = COLORS.button,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
            })
            round(trackBar, 4)
            local initialRatio = maximum == minimum and 1 or (value - minimum) / (maximum - minimum)
            local fill = make("Frame", {
                Name = "Fill",
                Parent = trackBar,
                Size = UDim2.new(initialRatio, 0, 1, 0),
                BackgroundColor3 = COLORS.white,
                BorderSizePixel = 0,
            })
            round(fill, 4)
            local dragging = false
            local function setFromX(x)
                local ratio = math.clamp((x - trackBar.AbsolutePosition.X) / math.max(trackBar.AbsoluteSize.X, 1), 0, 1)
                value = math.floor((minimum + (maximum - minimum) * ratio) + 0.5)
                number.Text = tostring(value)
                animate(fill, 0.06, {Size = UDim2.new(ratio, 0, 1, 0)})
                if type(controlOptions.Callback) == "function" then
                    local ok, err = pcall(controlOptions.Callback, value)
                    if not ok then warn("[Luna UI] Slider callback:", err) end
                end
            end
            track(trackBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setFromX(input.Position.X)
                end
            end))
            track(UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    setFromX(input.Position.X)
                end
            end))
            track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))
            refreshEmpty()
            return {
                Instance = row,
                GetValue = function() return value end,
                SetValue = function(newValue)
                    value = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
                    number.Text = tostring(value)
                    local ratio = maximum == minimum and 1 or (value - minimum) / (maximum - minimum)
                    fill.Size = UDim2.new(ratio, 0, 1, 0)
                end,
            }
        end

        function tab:CreateInput(controlOptions)
            controlOptions = controlOptions or {}
            local row = make("Frame", {
                Name = "InputRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 42),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 7)
            local stroke = make("UIStroke", {
                Parent = row,
                Color = COLORS.white,
                Transparency = 0.86,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            local box = make("TextBox", {
                Name = "TextBox",
                Parent = row,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = FONT,
                TextSize = 14,
                TextColor3 = COLORS.white,
                PlaceholderColor3 = COLORS.dim,
                PlaceholderText = controlOptions.Placeholder or controlOptions.Name or "Enter text...",
                Text = controlOptions.Default or "",
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            box.Focused:Connect(function()
                animate(stroke, 0.2, {Transparency = 0.55})
                animate(row, 0.2, {BackgroundColor3 = COLORS.panelHi})
            end)
            box.FocusLost:Connect(function(enterPressed)
                animate(stroke, 0.2, {Transparency = 0.86})
                animate(row, 0.2, {BackgroundColor3 = COLORS.panel})
                if type(controlOptions.Callback) == "function" then
                    local ok, err = pcall(controlOptions.Callback, box.Text, enterPressed)
                    if not ok then warn("[Luna UI] Input callback:", err) end
                end
            end)
            refreshEmpty()
            return {
                Instance = row,
                TextBox = box,
                GetValue = function() return box.Text end,
                SetValue = function(newValue) box.Text = tostring(newValue or "") end,
            }
        end

        track(button.Activated:Connect(function()
            selectTab(tab, false)
        end))
        refreshEmpty()
        if #self._tabs == 1 then
            selectTab(tab, true)
        end
        return tab
    end

    function window:Notify(config)
        if self._destroyed then return end
        if type(config) ~= "table" then
            config = {Content = tostring(config or "")}
        end
        local existing = main:FindFirstChild("LunaToast")
        if existing then existing:Destroy() end
        local toast = make("TextLabel", {
            Name = "LunaToast",
            Parent = main,
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 0.875, 6),
            Size = UDim2.fromOffset(0, 26),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = COLORS.panel,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            FontFace = FONT,
            TextSize = 14,
            TextColor3 = config.Color or COLORS.white,
            TextTransparency = 1,
            Text = tostring(config.Content or config.Title or ""),
            ZIndex = 20,
        }, {
            make("UICorner", {CornerRadius = UDim.new(0, 13)}),
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            }),
            make("UIStroke", {
                Color = COLORS.white,
                Transparency = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            }),
        })
        local toastStroke = toast:FindFirstChildOfClass("UIStroke")
        animate(toast, 0.3, {
            BackgroundTransparency = 0,
            TextTransparency = 0,
            Position = UDim2.new(0.5, 0, 0.875, -6),
        })
        if toastStroke then animate(toastStroke, 0.3, {Transparency = 0.8}) end
        task.delay(tonumber(config.Duration) or 2.5, function()
            if toast.Parent and not self._destroyed then
                animate(toast, 0.25, {BackgroundTransparency = 1, TextTransparency = 1})
                if toastStroke then animate(toastStroke, 0.25, {Transparency = 1}) end
                task.delay(0.3, function()
                    if toast.Parent then toast:Destroy() end
                end)
            end
        end)
    end

    function window:SetVisible(visible)
        if self._destroyed then return end
        self._visible = visible == true
        if self._visible then
            self._gui.Enabled = true
            self._main.Visible = true
            self._mainScale.Scale = 0.96
            animate(self._mainScale, 0.2, {Scale = 1}, Enum.EasingStyle.Back)
        else
            animate(self._mainScale, 0.15, {Scale = 0.96})
            task.delay(0.16, function()
                if not self._visible and not self._destroyed then
                    self._gui.Enabled = false
                end
            end)
        end
    end

    function window:Toggle()
        self:SetVisible(not self._visible)
    end

    function window:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        for _, connection in ipairs(self._connections) do
            pcall(function() connection:Disconnect() end)
        end
        self._gui:Destroy()
    end

    track(closeButton.Activated:Connect(function()
        window:Destroy()
    end))

    -- Drag the window from the title area, like the reference script.
    local dragging, dragStart, startPosition
    track(topBar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        local endConnection
        endConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if endConnection then endConnection:Disconnect() end
            end
        end)
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))
    track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            window:Toggle()
        end
    end))
    track(bottomBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        updateIndicator(true)
    end))
    track(bottomBar:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        updateIndicator(true)
    end))

    return window
end

return setmetatable({}, LunaUI)
