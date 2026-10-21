--[[
    Luna UI
    A reusable, dark-themed Roblox UI library by PjIuna.
    Generic interface components only; this library does not perform game actions.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LunaUI = {}
LunaUI.__index = LunaUI

local DEFAULT_THEME = {
    Background = Color3.fromRGB(13, 13, 13),
    Panel = Color3.fromRGB(30, 30, 30),
    PanelHover = Color3.fromRGB(42, 42, 42),
    Button = Color3.fromRGB(56, 56, 56),
    ButtonHover = Color3.fromRGB(72, 72, 72),
    Accent = Color3.fromRGB(145, 105, 255),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(155, 155, 155),
    Success = Color3.fromRGB(110, 230, 150),
    Warning = Color3.fromRGB(245, 195, 90),
    Error = Color3.fromRGB(255, 95, 95),
}

local function merge(base, override)
    local result = {}
    for key, value in pairs(base) do result[key] = value end
    if type(override) == "table" then
        for key, value in pairs(override) do
            if result[key] ~= nil then result[key] = value end
        end
    end
    return result
end

local function create(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, transparency)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0.65,
        Thickness = 1,
    }, parent)
end

local function tween(object, duration, properties)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function addConnection(owner, connection)
    table.insert(owner._connections, connection)
    return connection
end

function LunaUI:CreateWindow(options)
    options = options or {}
    local theme = merge(DEFAULT_THEME, options.Theme)
    local player = Players.LocalPlayer
    assert(player, "Luna UI must be loaded on the client.")

    local parent
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok then parent = result end
    end
    parent = parent or game:GetService("CoreGui")
    if not parent then parent = player:WaitForChild("PlayerGui") end

    local gui = create("ScreenGui", {
        Name = "LunaUI_" .. tostring(math.floor(os.clock() * 1000)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, parent)

    local window = setmetatable({
        _theme = theme,
        _gui = gui,
        _connections = {},
        _tabs = {},
        _destroyed = false,
        _visible = true,
        _activeTab = nil,
        _options = options,
    }, { __index = LunaUI })

    local width = math.clamp(tonumber(options.Width) or 560, 360, 900)
    local height = math.clamp(tonumber(options.Height) or 410, 260, 700)
    local initialPosition = options.Position or UDim2.new(0.5, -width / 2, 0.5, -height / 2)

    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(width, height),
        Position = initialPosition,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    corner(main, 12)
    stroke(main, theme.Text, 0.88)
    window._main = main

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
    }, main)
    corner(topbar, 12)
    window._topbar = topbar

    -- Cover the lower rounded portion of the title bar so only the window top is rounded.
    create("Frame", {
        Name = "TopbarFill",
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
    }, topbar)

    local title = create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -76, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(options.Title or "🌙 Luna UI"),
        TextColor3 = theme.Text,
        TextSize = 17,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, topbar)
    window._title = title

    local close = create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(27, 27),
        BackgroundColor3 = theme.Button,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = theme.Text,
        TextSize = 22,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
    }, topbar)
    corner(close, 7)
    addConnection(window, close.MouseEnter:Connect(function()
        tween(close, 0.12, { BackgroundColor3 = theme.Error })
    end))
    addConnection(window, close.MouseLeave:Connect(function()
        tween(close, 0.12, { BackgroundColor3 = theme.Button })
    end))
    addConnection(window, close.MouseButton1Click:Connect(function() window:Destroy() end))

    local sidebar = create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(10, 56),
        Size = UDim2.new(0, 142, 1, -66),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
    }, main)
    corner(sidebar, 9)
    window._sidebar = sidebar

    local tabScroll = create("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(7, 7),
        Size = UDim2.new(1, -14, 1, -14),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabScroll)
    window._tabScroll = tabScroll

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 162, 0, 56),
        Size = UDim2.new(1, -172, 1, -66),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)
    corner(content, 9)
    window._content = content

    -- Drag the window from the title bar.
    local dragging, dragStart, startPosition
    addConnection(window, topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            local ended
            ended = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if ended then ended:Disconnect() end
                end
            end)
            addConnection(window, ended)
        end
    end))
    addConnection(window, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end))

    local toggleKey = options.ToggleKey
    if toggleKey == nil then toggleKey = Enum.KeyCode.RightShift end
    if toggleKey ~= false then
        addConnection(window, UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == toggleKey and not window._destroyed then
                window:Toggle()
            end
        end))
    end

    return window
end

function LunaUI:CreateTab(name)
    assert(not self._destroyed, "Cannot create a tab on a destroyed window.")
    local theme = self._theme
    local tabName = tostring(name or ("Tab " .. (#self._tabs + 1)))

    local tabButton = create("TextButton", {
        Name = "TabButton",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = theme.Button,
        BorderSizePixel = 0,
        Text = tabName,
        TextColor3 = theme.Muted,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, self._tabScroll)
    corner(tabButton, 7)

    local page = create("ScrollingFrame", {
        Name = "Page_" .. tabName:gsub("%W", ""),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, self._content)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, page)
    local pageLayout = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    local tab = {
        Name = tabName,
        _window = self,
        _page = page,
        _button = tabButton,
        _theme = theme,
        _order = 0,
    }
    tab.__index = tab

    local function selectTab()
        if self._destroyed then return end
        self._activeTab = tab
        for _, other in ipairs(self._tabs) do
            other._page.Visible = (other == tab)
            tween(other._button, 0.16, {
                BackgroundColor3 = other == tab and theme.Accent or theme.Button,
                TextColor3 = other == tab and theme.Text or theme.Muted,
            })
        end
    end
    tab._select = selectTab

    addConnection(self, tabButton.MouseButton1Click:Connect(selectTab))
    addConnection(self, tabButton.MouseEnter:Connect(function()
        if self._activeTab ~= tab then tween(tabButton, 0.12, { BackgroundColor3 = theme.PanelHover }) end
    end))
    addConnection(self, tabButton.MouseLeave:Connect(function()
        if self._activeTab ~= tab then tween(tabButton, 0.12, { BackgroundColor3 = theme.Button }) end
    end))

    local function makeRow(height, background)
        tab._order = tab._order + 1
        local row = create("Frame", {
            LayoutOrder = tab._order,
            Size = UDim2.new(1, -2, 0, height),
            BackgroundColor3 = background or theme.Background,
            BorderSizePixel = 0,
        }, page)
        corner(row, 8)
        return row
    end

    function tab:CreateSection(sectionName)
        local row = makeRow(30, theme.Panel)
        local label = create("TextLabel", {
            Position = UDim2.fromOffset(2, 0),
            Size = UDim2.new(1, -4, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(sectionName or "Section"),
            TextColor3 = theme.Accent,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        return label
    end

    function tab:CreateLabel(config)
        if type(config) == "string" then config = { Name = config } end
        config = config or {}
        local row = makeRow(tonumber(config.Height) or 38, theme.Background)
        local label = create("TextLabel", {
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(config.Name or config.Text or "Label"),
            TextColor3 = config.Color or theme.Text,
            TextSize = tonumber(config.TextSize) or 13,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, row)
        local control = {}
        function control:SetText(value) label.Text = tostring(value) end
        function control:SetColor(value) label.TextColor3 = value end
        return control
    end

    function tab:CreateButton(config)
        config = config or {}
        local button = create("TextButton", {
            LayoutOrder = tab._order + 1,
            Size = UDim2.new(1, -2, 0, tonumber(config.Height) or 38),
            BackgroundColor3 = theme.Button,
            BorderSizePixel = 0,
            Text = tostring(config.Name or "Button"),
            TextColor3 = theme.Text,
            TextSize = tonumber(config.TextSize) or 13,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, page)
        tab._order = tab._order + 1
        corner(button, 8)
        addConnection(self._window, button.MouseEnter:Connect(function()
            tween(button, 0.12, { BackgroundColor3 = theme.ButtonHover })
        end))
        addConnection(self._window, button.MouseLeave:Connect(function()
            tween(button, 0.12, { BackgroundColor3 = theme.Button })
        end))
        addConnection(self._window, button.MouseButton1Click:Connect(function()
            if type(config.Callback) == "function" then
                local ok, err = pcall(config.Callback)
                if not ok then warn("[Luna UI] Button callback failed: " .. tostring(err)) end
            end
        end))
        local control = {}
        function control:SetText(value) button.Text = tostring(value) end
        function control:SetEnabled(enabled)
            button.Active = enabled
            button.TextTransparency = enabled and 0 or 0.45
            button.BackgroundTransparency = enabled and 0 or 0.35
        end
        return control
    end

    function tab:CreateToggle(config)
        config = config or {}
        local state = config.CurrentValue == true or config.Default == true
        local row = makeRow(42, theme.Background)
        local label = create("TextLabel", {
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -72, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(config.Name or "Toggle"),
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        local track = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(42, 22),
            BackgroundColor3 = state and theme.Accent or theme.Button,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, row)
        corner(track, 11)
        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            BackgroundColor3 = theme.Text,
            BorderSizePixel = 0,
        }, track)
        corner(knob, 8)

        local function setState(value, callCallback)
            state = value == true
            tween(track, 0.15, { BackgroundColor3 = state and theme.Accent or theme.Button })
            tween(knob, 0.15, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
            if callCallback and type(config.Callback) == "function" then
                local ok, err = pcall(config.Callback, state)
                if not ok then warn("[Luna UI] Toggle callback failed: " .. tostring(err)) end
            end
        end
        addConnection(self._window, track.MouseButton1Click:Connect(function() setState(not state, true) end))
        local control = {}
        function control:SetValue(value) setState(value, false) end
        function control:GetValue() return state end
        return control
    end

    function tab:CreateSlider(config)
        config = config or {}
        local minimum = tonumber(config.Range and config.Range[1]) or tonumber(config.Min) or 0
        local maximum = tonumber(config.Range and config.Range[2]) or tonumber(config.Max) or 100
        if maximum < minimum then minimum, maximum = maximum, minimum end
        local value = math.clamp(tonumber(config.CurrentValue or config.Default) or minimum, minimum, maximum)
        local row = makeRow(58, theme.Background)
        local label = create("TextLabel", {
            Position = UDim2.fromOffset(10, 2),
            Size = UDim2.new(1, -20, 0, 20),
            BackgroundTransparency = 1,
            TextColor3 = theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local bar = create("TextButton", {
            Position = UDim2.new(0, 10, 0, 31),
            Size = UDim2.new(1, -20, 0, 12),
            BackgroundColor3 = theme.Button,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, row)
        corner(bar, 6)
        local fill = create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
        }, bar)
        corner(fill, 6)

        local function updateVisual()
            local fraction = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
            label.Text = tostring(config.Name or "Slider") .. "  •  " .. tostring(value)
            tween(fill, 0.08, { Size = UDim2.new(fraction, 0, 1, 0) })
        end
        local function setFromX(x, callCallback)
            local fraction = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local nextValue = minimum + (maximum - minimum) * fraction
            local step = tonumber(config.Increment or config.Step)
            if step and step > 0 then nextValue = minimum + math.floor((nextValue - minimum) / step + 0.5) * step end
            value = math.clamp(math.floor(nextValue * 100 + 0.5) / 100, minimum, maximum)
            updateVisual()
            if callCallback and type(config.Callback) == "function" then
                local ok, err = pcall(config.Callback, value)
                if not ok then warn("[Luna UI] Slider callback failed: " .. tostring(err)) end
            end
        end
        local sliding = false
        addConnection(self._window, bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                setFromX(input.Position.X, true)
            end
        end))
        addConnection(self._window, UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X, true)
            end
        end))
        addConnection(self._window, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end))
        updateVisual()
        local control = {}
        function control:SetValue(nextValue)
            value = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
            updateVisual()
        end
        function control:GetValue() return value end
        return control
    end

    table.insert(self._tabs, tab)
    if #self._tabs == 1 then
        selectTab()
    end
    return tab
end

function LunaUI:SetTitle(value)
    if not self._destroyed then self._title.Text = tostring(value) end
end

function LunaUI:SetVisible(visible)
    if self._destroyed then return end
    visible = visible == true
    if self._visible == visible then return end
    self._visible = visible
    if visible then
        self._main.Visible = true
        self._main.BackgroundTransparency = 1
        tween(self._main, 0.18, { BackgroundTransparency = 0 })
    else
        tween(self._main, 0.14, { BackgroundTransparency = 1 }).Completed:Once(function()
            if not self._destroyed and not self._visible then self._main.Visible = false end
        end)
    end
end

function LunaUI:Toggle()
    self:SetVisible(not self._visible)
end

function LunaUI:Notify(config)
    if self._destroyed then return end
    config = config or {}
    local theme = self._theme
    local notification = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 320, 1, -18),
        Size = UDim2.fromOffset(290, 78),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
    }, self._gui)
    corner(notification, 10)
    stroke(notification, config.Color or theme.Accent, 0.35)
    local accent = create("Frame", {
        Size = UDim2.new(0, 4, 1, -18),
        Position = UDim2.fromOffset(9, 9),
        BackgroundColor3 = config.Color or theme.Accent,
        BorderSizePixel = 0,
    }, notification)
    corner(accent, 3)
    create("TextLabel", {
        Position = UDim2.fromOffset(23, 9),
        Size = UDim2.new(1, -32, 0, 23),
        BackgroundTransparency = 1,
        Text = tostring(config.Title or "Luna UI"),
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, notification)
    create("TextLabel", {
        Position = UDim2.fromOffset(23, 32),
        Size = UDim2.new(1, -32, 0, 35),
        BackgroundTransparency = 1,
        Text = tostring(config.Content or config.Text or ""),
        TextColor3 = theme.Muted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, notification)
    tween(notification, 0.28, { Position = UDim2.new(1, -18, 1, -18) })
    task.delay(math.clamp(tonumber(config.Duration) or 3, 1, 10), function()
        if notification.Parent then
            tween(notification, 0.2, { Position = UDim2.new(1, 320, 1, -18), BackgroundTransparency = 1 }).Completed:Once(function()
                if notification.Parent then notification:Destroy() end
            end)
        end
    end)
end

function LunaUI:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    self._connections = {}
    if self._gui then self._gui:Destroy() end
end

function LunaUI:CreateLabel(config)
    local tab = self._activeTab
    assert(tab, "Create a tab first, then create components on that tab.")
    return tab:CreateLabel(config)
end

function LunaUI:CreateButton(config)
    local tab = self._activeTab
    assert(tab, "Create a tab first, then create components on that tab.")
    return tab:CreateButton(config)
end

function LunaUI:CreateToggle(config)
    local tab = self._activeTab
    assert(tab, "Create a tab first, then create components on that tab.")
    return tab:CreateToggle(config)
end

function LunaUI:CreateSlider(config)
    local tab = self._activeTab
    assert(tab, "Create a tab first, then create components on that tab.")
    return tab:CreateSlider(config)
end

function LunaUI:CreateSection(name)
    local tab = self._activeTab
    assert(tab, "Create a tab first, then create components on that tab.")
    return tab:CreateSection(name)
end

return setmetatable({}, {
    __index = LunaUI,
    __call = function(_, options)
        return LunaUI:CreateWindow(options)
    end,
})
