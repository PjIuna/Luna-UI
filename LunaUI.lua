--[[
    Luna UI
    Reusable UI library styled after the supplied Product Faker V2 reference.
    This is a UI toolkit only; callbacks are supplied by the script using it.
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

local FONT = Font.new("rbxasset://fonts/families/RobotoCondensed.json", Enum.FontWeight.Regular)
local FONT_BOLD = Font.new("rbxasset://fonts/families/RobotoCondensed.json", Enum.FontWeight.Bold)

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
    object.Parent = properties and properties.Parent or nil
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
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function textLabel(parent, text, properties)
    properties = properties or {}
    properties.Parent = parent
    properties.Text = text or ""
    properties.BackgroundTransparency = 1
    properties.BorderSizePixel = 0
    properties.FontFace = properties.FontFace or FONT
    properties.TextColor3 = properties.TextColor3 or COLORS.white
    properties.TextSize = properties.TextSize or 14
    properties.TextWrapped = properties.TextWrapped ~= false
    return make("TextLabel", properties)
end

local function makeButton(parent, text, size, position)
    local button = make("TextButton", {
        Parent = parent,
        Text = text or "",
        Size = size,
        Position = position or UDim2.new(),
        BackgroundColor3 = COLORS.button,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        FontFace = FONT_BOLD,
        TextSize = 14,
        TextColor3 = COLORS.icon,
        TextWrapped = true,
    })
    round(button, 8)
    outline(button, 0.86)
    local scale = make("UIScale", {Parent = button})
    button.MouseEnter:Connect(function()
        animate(button, 0.15, {BackgroundColor3 = COLORS.buttonHi, TextColor3 = COLORS.white})
    end)
    button.MouseLeave:Connect(function()
        animate(button, 0.2, {BackgroundColor3 = COLORS.button, TextColor3 = COLORS.icon})
        animate(scale, 0.2, {Scale = 1})
    end)
    button.MouseButton1Down:Connect(function()
        animate(scale, 0.08, {Scale = 0.94})
    end)
    button.MouseButton1Up:Connect(function()
        animate(scale, 0.25, {Scale = 1}, Enum.EasingStyle.Back)
    end)
    return button
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

    local parent
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok then parent = result end
    end
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent and player then
        parent = player:WaitForChild("PlayerGui")
    end
    screenGui.Parent = parent

    local main = make("Frame", {
        Name = "Main",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(options.Width or 440, options.Height or 355),
        BackgroundColor3 = COLORS.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    round(main, 9)
    outline(main, 0.74)
    make("UISizeConstraint", {
        Parent = main,
        MinSize = Vector2.new(340, 280),
        MaxSize = Vector2.new(850, 700),
    })
    make("UIAspectRatioConstraint", {
        Parent = main,
        AspectRatio = options.AspectRatio or 1.2415,
        DominantAxis = Enum.DominantAxis.Width,
    })

    local top = make("Frame", {
        Name = "TopBar",
        Parent = main,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
    })
    local title = textLabel(top, options.Title or "🌙 Luna UI", {
        Name = "Title",
        Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.new(1, -64, 1, 0),
        FontFace = FONT_BOLD,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local close = makeButton(top, "×", UDim2.fromOffset(28, 28), UDim2.new(1, -36, 0.5, -14))
    close.Name = "CloseButton"
    close.TextSize = 22
    close.MouseEnter:Connect(function()
        animate(close, 0.15, {BackgroundColor3 = Color3.fromRGB(150, 40, 40), TextColor3 = COLORS.white})
    end)

    local content = make("Frame", {
        Name = "Content",
        Parent = main,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 1, -92),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })

    local bottom = make("Frame", {
        Name = "BottomBar",
        Parent = main,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
    })
    local nav = make("Frame", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 5),
        Size = UDim2.new(1, -16, 1, -10),
    })
    make("UIListLayout", {
        Parent = nav,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local window = setmetatable({
        _gui = screenGui,
        _main = main,
        _content = content,
        _nav = nav,
        _tabs = {},
        _activeTab = nil,
        _connections = {},
        _destroyed = false,
        _title = title,
    }, {__index = LunaUI})

    local function track(connection)
        table.insert(window._connections, connection)
        return connection
    end

    local function setTab(tab)
        if window._destroyed or window._activeTab == tab then return end
        local previous = window._activeTab
        window._activeTab = tab
        for _, item in ipairs(window._tabs) do
            local selected = item == tab
            animate(item._button, 0.18, {
                BackgroundColor3 = selected and COLORS.active or COLORS.button,
                TextColor3 = selected and COLORS.white or COLORS.icon,
            })
        end
        if previous then
            previous._page.Visible = false
        end
        tab._page.Visible = true
        tab._page.Position = UDim2.fromOffset(10, 0)
        tab._page.GroupTransparency = 1
        animate(tab._page, 0.25, {
            Position = UDim2.fromOffset(0, 0),
            GroupTransparency = 0,
        })
    end

    function window:CreateTab(name)
        assert(not self._destroyed, "Cannot add a tab to a destroyed Luna UI window")
        local page = make("CanvasGroup", {
            Name = tostring(name) .. "Page",
            Parent = self._content,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            GroupTransparency = 1,
        })
        local scroll = make("ScrollingFrame", {
            Name = "Items",
            Parent = page,
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.new(1, -16, 1, -16),
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
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        make("UIPadding", {
            Parent = scroll,
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 4),
        })

        local tab = {_window = self, _page = page, _items = scroll, _name = tostring(name)}
        local button = makeButton(nav, tostring(name), UDim2.new(0, 76, 1, 0))
        button.LayoutOrder = #self._tabs + 1
        button.TextSize = 12
        tab._button = button
        button.MouseButton1Click:Connect(function() setTab(tab) end)
        table.insert(self._tabs, tab)

        function tab:CreateSection(sectionName)
            local section = make("Frame", {
                Name = "Section",
                Parent = self._items,
                Size = UDim2.new(1, -3, 0, 28),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            })
            textLabel(section, tostring(sectionName), {
                Position = UDim2.new(0, 3, 0, 0),
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

        function tab:CreateLabel(labelText)
            local row = make("Frame", {
                Parent = self._items,
                Size = UDim2.new(1, -3, 0, 34),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            round(row, 7); outline(row, 0.9)
            textLabel(row, tostring(labelText), {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = COLORS.icon,
                TextSize = 13,
            })
            return row
        end

        function tab:CreateButton(config)
            config = type(config) == "table" and config or {Name = tostring(config)}
            local buttonRow = makeButton(self._items, config.Name or "Button",
                UDim2.new(1, -3, 0, 34))
            buttonRow.TextXAlignment = Enum.TextXAlignment.Left
            buttonRow.TextSize = 13
            make("UIPadding", {
                Parent = buttonRow,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            })
            buttonRow.MouseButton1Click:Connect(function()
                if type(config.Callback) == "function" then
                    local ok, err = pcall(config.Callback)
                    if not ok then warn("[Luna UI] Button callback:", err) end
                end
            end)
            return buttonRow
        end

        function tab:CreateToggle(config)
            config = config or {}
            local enabled = config.Default == true
            local row = make("Frame", {
                Parent = self._items,
                Size = UDim2.new(1, -3, 0, 36),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            round(row, 7); outline(row, 0.9)
            textLabel(row, config.Name or "Toggle", {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -62, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
            })
            local switch = makeButton(row, "", UDim2.fromOffset(36, 20), UDim2.new(1, -45, 0.5, -10))
            round(switch, 10)
            local dot = make("Frame", {
                Parent = switch,
                Size = UDim2.fromOffset(14, 14),
                Position = UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = COLORS.white,
                BorderSizePixel = 0,
            })
            round(dot, 8)
            local function update(notify)
                animate(switch, 0.15, {BackgroundColor3 = enabled and COLORS.green or COLORS.button})
                animate(dot, 0.15, {Position = UDim2.new(0, enabled and 19 or 3, 0.5, -7)})
                if notify and type(config.Callback) == "function" then
                    local ok, err = pcall(config.Callback, enabled)
                    if not ok then warn("[Luna UI] Toggle callback:", err) end
                end
            end
            switch.MouseButton1Click:Connect(function()
                enabled = not enabled
                update(true)
            end)
            update(false)
            return {
                Instance = row,
                GetValue = function() return enabled end,
                SetValue = function(value)
                    enabled = value == true
                    update(true)
                end,
            }
        end

        function tab:CreateSlider(config)
            config = config or {}
            local minimum = tonumber(config.Min) or 0
            local maximum = tonumber(config.Max) or 100
            if maximum < minimum then maximum = minimum end
            local value = math.clamp(tonumber(config.Default) or minimum, minimum, maximum)
            local row = make("Frame", {
                Parent = self._items,
                Size = UDim2.new(1, -3, 0, 55),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
            })
            round(row, 7); outline(row, 0.9)
            local name = textLabel(row, config.Name or "Slider", {
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(0.7, 0, 0, 19),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
            })
            local number = textLabel(row, tostring(value), {
                Position = UDim2.new(0.7, 0, 0, 4),
                Size = UDim2.new(0.25, -6, 0, 19),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = COLORS.icon,
                TextSize = 13,
            })
            local track = make("TextButton", {
                Parent = row,
                Position = UDim2.new(0, 10, 0, 31),
                Size = UDim2.new(1, -20, 0, 8),
                BackgroundColor3 = COLORS.button,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
            })
            round(track, 4)
            local fill = make("Frame", {
                Parent = track,
                Size = UDim2.new(maximum == minimum and 1 or (value - minimum) / (maximum - minimum), 0, 1, 0),
                BackgroundColor3 = COLORS.white,
                BorderSizePixel = 0,
            })
            round(fill, 4)
            local dragging = false
            local function setFromX(x)
                local ratio = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                value = math.floor((minimum + (maximum - minimum) * ratio) + 0.5)
                number.Text = tostring(value)
                animate(fill, 0.06, {Size = UDim2.new(ratio, 0, 1, 0)})
                if type(config.Callback) == "function" then
                    local ok, err = pcall(config.Callback, value)
                    if not ok then warn("[Luna UI] Slider callback:", err) end
                end
            end
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setFromX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    setFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            return {
                Instance = row,
                GetValue = function() return value end,
                SetValue = function(newValue)
                    value = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
                    local ratio = maximum == minimum and 1 or (value - minimum) / (maximum - minimum)
                    number.Text = tostring(value)
                    fill.Size = UDim2.new(ratio, 0, 1, 0)
                    if type(config.Callback) == "function" then config.Callback(value) end
                end,
            }
        end

        if not self._activeTab then setTab(tab) end
        return tab
    end

    function window:CreateSection(name)
        assert(self._activeTab, "Create a tab before adding controls")
        return self._activeTab:CreateSection(name)
    end

    function window:CreateLabel(text)
        assert(self._activeTab, "Create a tab before adding controls")
        return self._activeTab:CreateLabel(text)
    end

    function window:CreateButton(config)
        assert(self._activeTab, "Create a tab before adding controls")
        return self._activeTab:CreateButton(config)
    end

    function window:CreateToggle(config)
        assert(self._activeTab, "Create a tab before adding controls")
        return self._activeTab:CreateToggle(config)
    end

    function window:CreateSlider(config)
        assert(self._activeTab, "Create a tab before adding controls")
        return self._activeTab:CreateSlider(config)
    end

    function window:Notify(config)
        config = config or {}
        if self._destroyed then return end
        local toast = make("TextLabel", {
            Parent = self._main,
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -58),
            Size = UDim2.new(0, 20, 0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = COLORS.panel,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Text = tostring(config.Content or "Notification"),
            TextColor3 = COLORS.white,
            TextSize = 13,
            FontFace = FONT,
            ZIndex = 10,
        })
        round(toast, 8); outline(toast, 0.8)
        make("UIPadding", {
            Parent = toast,
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        })
        toast.Text = tostring(config.Title and (config.Title .. "  •  " .. (config.Content or "")) or (config.Content or "Notification"))
        toast.TextTransparency = 1
        toast.BackgroundTransparency = 1
        toast.Position = UDim2.new(0.5, 0, 1, -48)
        animate(toast, 0.22, {
            TextTransparency = 0,
            BackgroundTransparency = 0.08,
            Position = UDim2.new(0.5, 0, 1, -58),
        })
        task.delay(tonumber(config.Duration) or 3, function()
            if toast.Parent then
                animate(toast, 0.2, {
                    TextTransparency = 1,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, -48),
                })
                task.delay(0.22, function()
                    if toast.Parent then toast:Destroy() end
                end)
            end
        end)
        return toast
    end

    function window:SetVisible(visible)
        if self._destroyed then return end
        visible = visible == true
        if visible then
            self._gui.Enabled = true
            self._main.Visible = true
            self._main.Size = UDim2.fromOffset(10, 10)
            animate(self._main, 0.3, {
                Size = UDim2.fromOffset(options.Width or 440, options.Height or 355),
            }, Enum.EasingStyle.Back)
        else
            animate(self._main, 0.18, {BackgroundTransparency = 1})
            task.delay(0.2, function()
                if not self._destroyed then
                    self._gui.Enabled = false
                    self._main.BackgroundTransparency = 0
                end
            end)
        end
    end

    function window:Toggle()
        self:SetVisible(not self._gui.Enabled)
    end

    function window:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        for _, connection in ipairs(self._connections) do
            pcall(function() connection:Disconnect() end)
        end
        self._gui:Destroy()
    end

    close.MouseButton1Click:Connect(function() window:Destroy() end)

    local dragging, dragInput, dragStart, startPosition
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey and not window._destroyed then
            window:Toggle()
        end
    end)

    return window
end

return LunaUI
