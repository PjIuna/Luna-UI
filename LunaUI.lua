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
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

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

-- Public icon presets. Use them as Icon = "Money" or Icon = LunaUI.Icons.Money.
-- Presets refer to the icon images already used by the supplied reference UI.
local ICON_PRESETS = {
    home = IMAGES.Home,
    house = IMAGES.Home,

    money = IMAGES.Faker,
    cash = IMAGES.Faker,
    wallet = IMAGES.Faker,
    coins = IMAGES.Faker,
    faker = IMAGES.Faker,

    logger = IMAGES.Logger,
    logs = IMAGES.Logger,
    clipboard = IMAGES.Logger,

    supported = IMAGES.Supported,
    shield = IMAGES.Supported,

    passes = IMAGES.Passes,
    ticket = IMAGES.Passes,
    gamepass = IMAGES.Passes,

    join = IMAGES.Join,
    userplus = IMAGES.Join,

    copy = IMAGES.Copy,
    close = IMAGES.Close,
    x = IMAGES.Close,
}

LunaUI.Icons = {
    Home = IMAGES.Home,
    House = IMAGES.Home,
    Money = IMAGES.Faker,
    Cash = IMAGES.Faker,
    Wallet = IMAGES.Faker,
    Coins = IMAGES.Faker,
    Faker = IMAGES.Faker,
    Logger = IMAGES.Logger,
    Logs = IMAGES.Logger,
    Clipboard = IMAGES.Logger,
    Supported = IMAGES.Supported,
    Shield = IMAGES.Supported,
    Passes = IMAGES.Passes,
    Ticket = IMAGES.Passes,
    Gamepass = IMAGES.Passes,
    Join = IMAGES.Join,
    UserPlus = IMAGES.Join,
    Copy = IMAGES.Copy,
    Close = IMAGES.Close,
    X = IMAGES.Close,
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
        local preset = ICON_PRESETS[string.lower(provided)]
        if preset then
            return preset
        end
        if provided:match("^%d+$") then
            return "rbxassetid://" .. provided
        end
        -- Also accepts full Roblox asset IDs and image URLs.
        return provided
    end

    local key = tostring(name or "")
    local preset = ICON_PRESETS[string.lower(key)]
    if preset then
        return preset
    end
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

    -- Singleton registry: re-executing a script removes the previous Luna window.
    local runtimeEnv = _G
    if type(getgenv) == "function" then
        local ok, sharedEnv = pcall(getgenv)
        if ok and type(sharedEnv) == "table" then
            runtimeEnv = sharedEnv
        end
    end
    local singletonKey = tostring(options.SingletonKey or "__LunaUI_ACTIVE_WINDOW")
    if options.Singleton ~= false then
        local previous = runtimeEnv[singletonKey]
        if type(previous) == "table" and type(previous.Destroy) == "function" then
            pcall(function() previous:Destroy() end)
        end
        runtimeEnv[singletonKey] = nil

        -- Also clean up a named GUI left by an earlier library version.
        local holders = {}
        local function addHolder(holder)
            if holder and typeof(holder) == "Instance" then
                for _, known in ipairs(holders) do
                    if known == holder then return end
                end
                table.insert(holders, holder)
            end
        end
        if type(gethui) == "function" then
            local ok, holder = pcall(gethui)
            if ok then addHolder(holder) end
        end
        local coreOk, core = pcall(function() return game:GetService("CoreGui") end)
        if coreOk then addHolder(core) end
        if player then
            local playerGui = player:FindFirstChildOfClass("PlayerGui")
            addHolder(playerGui)
        end
        for _, holder in ipairs(holders) do
            for _, child in ipairs(holder:GetChildren()) do
                if child:IsA("ScreenGui") and child.Name == "LunaUI" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end

    -- Config files let values survive leaving and rejoining the game, when the
    -- executor supports readfile/writefile. Memory is used as a session fallback.
    local saveConfigEnabled = options.SaveConfig ~= false
    local rawConfigName = tostring(options.ConfigName or options.Title or "LunaUI")
    local configName = string.lower(rawConfigName):gsub("[^%w_-]", "_")
    if configName == "" then configName = "default" end
    local configPath = "LunaUI_" .. configName .. ".json"
    local configMemoryKey = "__LunaUI_CONFIG_" .. configName
    local configData = {Version = 1, Values = {}}
    local loadedFromFile = false

    if saveConfigEnabled and type(readfile) == "function" then
        local readOk, raw = pcall(function()
            if type(isfile) == "function" and not isfile(configPath) then
                return nil
            end
            return readfile(configPath)
        end)
        if readOk and type(raw) == "string" and raw ~= "" then
            local decodeOk, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if decodeOk and type(decoded) == "table" and type(decoded.Values) == "table" then
                configData = decoded
                loadedFromFile = true
            end
        end
    end

    if saveConfigEnabled and not loadedFromFile then
        local memoryConfig = runtimeEnv[configMemoryKey]
        if type(memoryConfig) == "table" and type(memoryConfig.Values) == "table" then
            configData = memoryConfig
        end
    end
    configData.Version = 1
    configData.Values = type(configData.Values) == "table" and configData.Values or {}

    local savedPosition = configData.Values.__windowPosition
    local initialPosition = UDim2.fromScale(0.5, 0.5)
    if type(savedPosition) == "table"
        and type(savedPosition.XScale) == "number"
        and type(savedPosition.XOffset) == "number"
        and type(savedPosition.YScale) == "number"
        and type(savedPosition.YOffset) == "number" then
        initialPosition = UDim2.new(
            savedPosition.XScale,
            savedPosition.XOffset,
            savedPosition.YScale,
            savedPosition.YOffset
        )
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LunaUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    -- Keep the screen hidden during construction so the intro starts from a clean frame.
    screenGui.Enabled = false

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

    local main = make("CanvasGroup", {
        Name = "Main",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = initialPosition,
        Size = mainSize,
        BackgroundColor3 = COLORS.bg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 2,
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
    local openDuration = math.clamp(tonumber(options.OpenAnimationDuration) or 0.34, 0.12, 1)
    local closeDuration = math.clamp(tonumber(options.CloseAnimationDuration) or 0.22, 0.1, 1)
    local openScale = math.clamp(tonumber(options.OpenAnimationScale) or 0.78, 0.5, 0.95)
    local mainScale = make("UIScale", {Parent = main, Scale = openScale})

    -- Animated ASCII-symbol backdrop from the original reference UI.
    -- The ASCII field is cut out wherever the main window sits, so the symbols
    -- glow around the panel instead of being drawn on top of its controls.
    local asciiConfig = {
        enabled = options.AsciiBackdrop ~= false,
        textSize = math.clamp(tonumber(options.AsciiTextSize) or 13, 8, 20),
        padding = math.clamp(tonumber(options.AsciiPadding) or 80, 35, 180),
        fps = math.clamp(tonumber(options.AsciiFPS) or 30, 8, 60),
        ramp = type(options.AsciiRamp) == "string" and #options.AsciiRamp > 1
            and options.AsciiRamp or " .,:;-=+*x#%@",
        color = typeof(options.AsciiColor) == "Color3" and options.AsciiColor or COLORS.white,
        mouse = options.AsciiMouseRipple ~= false,
    }

    local asciiHolder = make("Frame", {
        Name = "AsciiBackdrop",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = main.Position,
        Size = UDim2.fromOffset(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = asciiConfig.enabled,
        ZIndex = 1,
    })
    local asciiLabels = {}
    local asciiLayers = {
        {min = 0.1, transparency = 0.84},
        {min = 0.4, transparency = 0.62},
        {min = 0.7, transparency = 0.3},
    }
    for i = 1, #asciiLayers do
        asciiLabels[i] = make("TextLabel", {
            Name = "AsciiLayer" .. i,
            Parent = asciiHolder,
            Size = UDim2.fromOffset(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = Enum.Font.Code,
            TextSize = asciiConfig.textSize,
            TextColor3 = asciiConfig.color,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = false,
            RichText = false,
            Text = "",
            ZIndex = 1,
        })
    end
    local asciiAlpha = Instance.new("NumberValue")
    asciiAlpha.Name = "AsciiAlpha"
    asciiAlpha.Value = 0

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

    -- Small floating square that restores the menu after it is hidden.
    local restoreButton = make("TextButton", {
        Name = "LunaRestoreButton",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 22, 1, -22),
        Size = UDim2.fromOffset(42, 42),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "☾",
        FontFace = FONT_BOLD,
        TextSize = 24,
        TextColor3 = COLORS.white,
        Visible = false,
        ZIndex = 100,
    })
    round(restoreButton, 9)
    outline(restoreButton, 0.72)
    local restoreScale = make("UIScale", {
        Parent = restoreButton,
        Scale = 0.72,
    })
    local restoreStroke = restoreButton:FindFirstChildOfClass("UIStroke")
    restoreButton.MouseEnter:Connect(function()
        animate(restoreButton, 0.15, {BackgroundColor3 = COLORS.buttonHi})
        animate(restoreScale, 0.2, {Scale = 1.06}, Enum.EasingStyle.Back)
    end)
    restoreButton.MouseLeave:Connect(function()
        animate(restoreButton, 0.2, {BackgroundColor3 = COLORS.panel})
        animate(restoreScale, 0.2, {Scale = 1})
    end)

    local window = setmetatable({
        _gui = screenGui,
        _main = main,
        _runtimeEnv = runtimeEnv,
        _registryKey = singletonKey,
        _configEnabled = saveConfigEnabled,
        _configData = configData,
        _configPath = configPath,
        _configMemoryKey = configMemoryKey,
        _saveConfigToken = 0,
        _configWarned = false,
        _mainScale = mainScale,
        _content = content,
        _bottomBar = bottomBar,
        _buttons = buttonContainer,
        _indicator = indicator,
        _restoreButton = restoreButton,
        _restoreScale = restoreScale,
        _tabs = {},
        _activeTab = nil,
        _connections = {},
        _destroyed = false,
        _closing = false,
        _visible = true,
        _openDuration = openDuration,
        _closeDuration = closeDuration,
        _openScale = openScale,
        _restPosition = initialPosition,
        _openOffset = math.clamp(tonumber(options.OpenAnimationOffset) or 34, 12, 100),
        _closeOffset = math.clamp(tonumber(options.CloseAnimationOffset) or 24, 8, 80),
        _title = title,
        _asciiAlpha = asciiAlpha,
        _asciiHolder = asciiHolder,
        _asciiConfig = asciiConfig,
    }, {__index = LunaUI})

    local function track(connection)
        table.insert(window._connections, connection)
        return connection
    end

    local function writeConfigNow()
        if not window._configEnabled or window._destroyed then return end
        local data = window._configData
        data.Version = 1
        data.UpdatedAt = os.time()
        window._runtimeEnv[window._configMemoryKey] = data

        local encodeOk, encoded = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if not encodeOk then
            warn("[Luna UI] Could not encode config:", encoded)
            return
        end

        local writeOk, writeErr = pcall(function()
            if type(writefile) ~= "function" then
                error("writefile is not available in this executor")
            end
            writefile(window._configPath, encoded)
        end)
        if not writeOk and not window._configWarned then
            window._configWarned = true
            warn("[Luna UI] Config is stored in memory only. Cross-rejoin saving requires executor readfile/writefile support. " .. tostring(writeErr))
        end
    end

    local function queueConfigSave(debounce)
        if not window._configEnabled or window._destroyed then return end
        window._saveConfigToken += 1
        local token = window._saveConfigToken
        if not debounce then
            writeConfigNow()
        else
            task.delay(0.35, function()
                if not window._destroyed and token == window._saveConfigToken then
                    writeConfigNow()
                end
            end)
        end
    end

    function window:_ConfigKey(tabName, controlType, controlOptions)
        controlOptions = type(controlOptions) == "table" and controlOptions or {}
        if controlOptions.Flag ~= nil then
            return tostring(tabName) .. "/" .. tostring(controlOptions.Flag)
        end
        return tostring(tabName) .. "/" .. tostring(controlType) .. "/" .. tostring(controlOptions.Name or controlType)
    end

    function window:_HasSavedValue(key)
        return self._configEnabled and self._configData.Values[key] ~= nil
    end

    function window:_GetSavedValue(key, defaultValue)
        if self._configEnabled then
            local value = self._configData.Values[key]
            if value ~= nil and (defaultValue == nil or typeof(value) == typeof(defaultValue)) then
                return value
            end
        end
        return defaultValue
    end

    function window:_SetSavedValue(key, value, debounce)
        if not self._configEnabled then return end
        local valueType = typeof(value)
        if valueType == "table" then
            if key == "__windowPosition" then
                if type(value.XScale) ~= "number"
                    or type(value.XOffset) ~= "number"
                    or type(value.YScale) ~= "number"
                    or type(value.YOffset) ~= "number" then
                    return
                end
            else
                -- Multi-select dropdowns save a flat array of primitive values.
                for index, item in pairs(value) do
                    if type(index) ~= "number" or index < 1 or index % 1 ~= 0
                        or (type(item) ~= "string" and type(item) ~= "number" and type(item) ~= "boolean") then
                        return
                    end
                end
            end
        elseif valueType ~= "boolean" and valueType ~= "number" and valueType ~= "string" then
            return
        end
        self._configData.Values[key] = value
        queueConfigSave(debounce == true)
    end

    function window:SaveConfig()
        writeConfigNow()
    end

    -- Register this window so the next execution can destroy it cleanly.
    if options.Singleton ~= false then
        runtimeEnv[singletonKey] = window
    end

    -- Approximate monospace cell geometry with Roblox's own text metrics.
    local asciiFont = Enum.Font.Code
    local hugeTextArea = Vector2.new(100000, 100000)
    local asciiTextSize = asciiConfig.textSize
    local cellWidth = TextService:GetTextSize(string.rep("M", 40), asciiTextSize, asciiFont, hugeTextArea).X / 40
    local oneLineHeight = TextService:GetTextSize("M", asciiTextSize, asciiFont, hugeTextArea).Y
    local tenLineHeight = TextService:GetTextSize(string.rep("M\n", 10) .. "M", asciiTextSize, asciiFont, hugeTextArea).Y
    local cellHeight = (tenLineHeight - oneLineHeight) / 10
    if cellWidth <= 0 then cellWidth = asciiTextSize * 0.6 end
    if cellHeight <= 0 then cellHeight = asciiTextSize end
    local asciiRamp = {}
    for i = 1, #asciiConfig.ramp do
        asciiRamp[i] = asciiConfig.ramp:sub(i, i)
    end
    local asciiRampLength = #asciiRamp
    local asciiColumns, asciiRows = 0, 0
    local asciiOffsetX, asciiOffsetY = 0, 0
    local asciiGlow = {}
    local asciiBuffers = {{}, {}, {}}
    local asciiLines = {{}, {}, {}}
    local lastAsciiArea, asciiAccumulator = nil, 0
    local asciiStart = os.clock()

    local function rebuildAscii(area, inner)
        asciiColumns = math.max(1, math.floor(area.X / cellWidth))
        asciiRows = math.max(1, math.floor(area.Y / cellHeight))
        asciiOffsetX = (area.X - asciiColumns * cellWidth) / 2
        asciiOffsetY = (area.Y - asciiRows * cellHeight) / 2
        for _, textLayer in ipairs(asciiLabels) do
            textLayer.Position = UDim2.fromOffset(asciiOffsetX, asciiOffsetY)
            textLayer.Size = UDim2.fromOffset(asciiColumns * cellWidth + 4, asciiRows * cellHeight + 4)
        end

        local centerX, centerY = area.X / 2, area.Y / 2
        local halfWidth, halfHeight = inner.X / 2, inner.Y / 2
        table.clear(asciiGlow)
        for y = 0, asciiRows - 1 do
            local qy = math.max(math.abs(asciiOffsetY + (y + 0.5) * cellHeight - centerY) - halfHeight, 0)
            for x = 0, asciiColumns - 1 do
                local qx = math.max(math.abs(asciiOffsetX + (x + 0.5) * cellWidth - centerX) - halfWidth, 0)
                local index = y * asciiColumns + x + 1
                if qx == 0 and qy == 0 then
                    asciiGlow[index] = -1
                else
                    local g = math.clamp(1 - math.sqrt(qx * qx + qy * qy) / asciiConfig.padding, 0, 1)
                    asciiGlow[index] = g * g * (3 - 2 * g)
                end
            end
        end
        for _, buffer in ipairs(asciiBuffers) do table.clear(buffer) end
    end

    local function renderAscii(dt)
        asciiHolder.Position = main.Position
        if not asciiConfig.enabled then return end
        local alpha = asciiAlpha.Value
        if alpha <= 0.001 then return end

        asciiAccumulator += dt
        if asciiAccumulator < 1 / asciiConfig.fps then return end
        asciiAccumulator = 0

        local scale = mainScale.Scale > 0 and mainScale.Scale or 1
        local abs = main.AbsoluteSize
        if abs.X < 1 or abs.Y < 1 then return end
        local inner = Vector2.new(math.floor(abs.X / scale + 0.5), math.floor(abs.Y / scale + 0.5))
        local area = inner + Vector2.new(asciiConfig.padding * 2, asciiConfig.padding * 2)
        if area ~= lastAsciiArea then
            lastAsciiArea = area
            asciiHolder.Size = UDim2.fromOffset(area.X, area.Y)
            rebuildAscii(area, inner)
        end

        local mouseX, mouseY
        if asciiConfig.mouse then
            local mouse = UserInputService:GetMouseLocation() - asciiHolder.AbsolutePosition
            if mouse.X >= 0 and mouse.Y >= 0 and mouse.X <= area.X and mouse.Y <= area.Y then
                mouseX, mouseY = mouse.X / cellWidth, mouse.Y / cellHeight
            end
        end

        local t = os.clock() - asciiStart
        local noise, sin, cos, sqrt, exp, floor = math.noise, math.sin, math.cos, math.sqrt, math.exp, math.floor
        local b1, b2, b3 = asciiBuffers[1], asciiBuffers[2], asciiBuffers[3]
        local l1, l2, l3 = asciiLines[1], asciiLines[2], asciiLines[3]
        local min1, min2, min3 = asciiLayers[1].min, asciiLayers[2].min, asciiLayers[3].min
        local aspect = cellHeight / cellWidth
        for y = 0, asciiRows - 1 do
            local base = y * asciiColumns
            local ny = y * 0.11 - t * 0.35
            local wy = cos(y * 0.21 - t * 0.7)
            for x = 0, asciiColumns - 1 do
                local glow = asciiGlow[base + x + 1]
                local c1, c2, c3 = " ", " ", " "
                if glow > 0 then
                    local v = 0.45 + noise(x * 0.055, ny, t * 0.12) * 1.3
                        + sin(x * 0.12 + t * 1.1) * wy * 0.18
                    if mouseX then
                        local dx, dy = x - mouseX, (y - mouseY) * aspect
                        local distance = sqrt(dx * dx + dy * dy)
                        v += sin(distance * 0.45 - t * 7) * exp(-distance * 0.09) * 0.45
                    end
                    v *= glow * alpha
                    if v >= min1 then
                        local index = math.clamp(floor(v * asciiRampLength) + 1, 2, asciiRampLength)
                        local glyph = asciiRamp[index]
                        if v >= min3 then
                            c3 = glyph
                        elseif v >= min2 then
                            c2 = glyph
                        else
                            c1 = glyph
                        end
                    end
                end
                b1[x + 1], b2[x + 1], b3[x + 1] = c1, c2, c3
            end
            l1[y + 1] = table.concat(b1, "", 1, asciiColumns)
            l2[y + 1] = table.concat(b2, "", 1, asciiColumns)
            l3[y + 1] = table.concat(b3, "", 1, asciiColumns)
        end
        asciiLabels[1].Text = table.concat(l1, "\n", 1, asciiRows)
        asciiLabels[2].Text = table.concat(l2, "\n", 1, asciiRows)
        asciiLabels[3].Text = table.concat(l3, "\n", 1, asciiRows)
        for i, layer in ipairs(asciiLayers) do
            asciiLabels[i].TextTransparency = 1 - (1 - layer.transparency) * alpha
        end
    end
    track(RunService.RenderStepped:Connect(renderAscii))

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

    local function selectTab(tab, instant, persistSelection)
        if window._destroyed or window._activeTab == tab then
            return
        end
        local previous = window._activeTab
        window._activeTab = tab
        if persistSelection then
            window:_SetSavedValue("__activeTab", tab._name, false)
        end

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

            local description = controlOptions.Description or controlOptions.Subtext
            local hasDescription = type(description) == "string" and description ~= ""
            local rowHeight = hasDescription and 42 or 34

            -- Compact rounded button card with no icon tile or placeholder square.
            local row = make("TextButton", {
                Name = "ButtonRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, rowHeight),
                BackgroundTransparency = 0,
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                TextTransparency = 1,
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 7)
            outline(row, 0.9)

            local titleLabel = label(row, controlOptions.Name or "Button", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0, hasDescription and 12 or rowHeight / 2),
                Size = UDim2.new(1, -20, 0, 18),
                FontFace = FONT_BOLD,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextScaled = false,
                TextSize = 13,
                TextColor3 = COLORS.white,
            })

            local descriptionLabel
            if hasDescription then
                descriptionLabel = label(row, description, {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 13),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextColor3 = COLORS.icon,
                    TextScaled = false,
                    TextSize = 11,
                })
            end

            local hoverScale = make("UIScale", {Parent = row})
            row.MouseEnter:Connect(function()
                animate(row, 0.15, {BackgroundColor3 = COLORS.panelHi})
                animate(titleLabel, 0.15, {TextColor3 = COLORS.icon})
            end)
            row.MouseLeave:Connect(function()
                animate(row, 0.2, {BackgroundColor3 = COLORS.panel})
                animate(titleLabel, 0.2, {TextColor3 = COLORS.white})
                if descriptionLabel then
                    animate(descriptionLabel, 0.2, {TextColor3 = COLORS.icon})
                end
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
            local configKey = self._window:_ConfigKey(self._name, "Toggle", controlOptions)
            local hasSavedValue = self._window:_HasSavedValue(configKey)
            local enabled = self._window:_GetSavedValue(configKey, controlOptions.Default == true) == true
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
                self._window:_SetSavedValue(configKey, enabled, false)
                update(true)
            end))
            update(hasSavedValue)
            refreshEmpty()
            return {
                Instance = row,
                GetValue = function() return enabled end,
                SetValue = function(value)
                    enabled = value == true
                    self._window:_SetSavedValue(configKey, enabled, false)
                    update(true)
                end,
            }
        end

        function tab:CreateSlider(controlOptions)
            controlOptions = controlOptions or {}
            local configKey = self._window:_ConfigKey(self._name, "Slider", controlOptions)
            local hasSavedValue = self._window:_HasSavedValue(configKey)
            local minimum = tonumber(controlOptions.Min) or 0
            local maximum = tonumber(controlOptions.Max) or 100
            if maximum < minimum then maximum = minimum end
            local defaultValue = tonumber(controlOptions.Default) or minimum
            local restoredValue = tonumber(self._window:_GetSavedValue(configKey, defaultValue)) or defaultValue
            local value = math.clamp(restoredValue, minimum, maximum)
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
                self._window:_SetSavedValue(configKey, value, true)
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
                    -- Flush the final slider position immediately after dragging stops.
                    self._window:_SetSavedValue(configKey, value, false)
                end
            end))
            if hasSavedValue and type(controlOptions.Callback) == "function" then
                local ok, err = pcall(controlOptions.Callback, value)
                if not ok then warn("[Luna UI] Slider restore callback:", err) end
            end
            refreshEmpty()
            return {
                Instance = row,
                GetValue = function() return value end,
                SetValue = function(newValue)
                    value = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
                    number.Text = tostring(value)
                    local ratio = maximum == minimum and 1 or (value - minimum) / (maximum - minimum)
                    fill.Size = UDim2.new(ratio, 0, 1, 0)
                    self._window:_SetSavedValue(configKey, value, false)
                end,
            }
        end

        function tab:CreateDropdown(controlOptions)
            controlOptions = type(controlOptions) == "table" and controlOptions or {}
            local values = type(controlOptions.Values) == "table" and controlOptions.Values or {}
            local configKey = self._window:_ConfigKey(self._name, "Dropdown", controlOptions)
            local hasSavedValue = self._window:_HasSavedValue(configKey)
            local multi = controlOptions.Multi == true or controlOptions.MultiSelect == true
            local defaultValue = controlOptions.Default
            local selected = {}

            local function findValue(candidate)
                for _, option in ipairs(values) do
                    if option == candidate or tostring(option) == tostring(candidate) then
                        return option
                    end
                end
                if type(candidate) == "number" and values[candidate] ~= nil then
                    return values[candidate]
                end
                return nil
            end

            local savedValue = self._window:_GetSavedValue(configKey, defaultValue)
            local initial = hasSavedValue and savedValue or defaultValue
            if multi then
                if type(initial) == "table" then
                    for _, item in ipairs(initial) do
                        local found = findValue(item)
                        if found ~= nil then selected[found] = true end
                    end
                elseif initial ~= nil then
                    local found = findValue(initial)
                    if found ~= nil then selected[found] = true end
                end
            else
                local found = findValue(initial)
                if found == nil and type(initial) == "number" then found = values[initial] end
                if found == nil then found = values[1] end
                if found ~= nil then selected[found] = true end
            end

            local row = make("Frame", {
                Name = "DropdownRow",
                Parent = self._items,
                Size = UDim2.new(1, -4, 0, 48),
                BackgroundColor3 = COLORS.panel,
                BorderSizePixel = 0,
                ClipsDescendants = true,
            })
            row:SetAttribute("IsLunaRow", true)
            round(row, 7)
            outline(row, 0.9)

            label(row, controlOptions.Name or "Dropdown", {
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(1, -20, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = false,
                TextSize = 12,
                TextColor3 = COLORS.icon,
            })

            local selector = make("TextButton", {
                Name = "SelectedValue",
                Parent = row,
                Position = UDim2.new(0, 8, 0, 22),
                Size = UDim2.new(1, -16, 0, 22),
                BackgroundColor3 = COLORS.button,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                FontFace = FONT,
                TextSize = 12,
                TextColor3 = COLORS.white,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "",
            })
            round(selector, 5)
            make("UIPadding", {
                Parent = selector,
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            })

            local optionList = make("ScrollingFrame", {
                Name = "Options",
                Parent = row,
                Position = UDim2.new(0, 8, 0, 48),
                Size = UDim2.new(1, -16, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = COLORS.dim,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible = false,
            })
            make("UIListLayout", {
                Parent = optionList,
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            local expanded = false
            local function getValue()
                if multi then
                    local result = {}
                    for _, option in ipairs(values) do
                        if selected[option] then table.insert(result, option) end
                    end
                    return result
                end
                for _, option in ipairs(values) do
                    if selected[option] then return option end
                end
                return nil
            end

            local function refreshSelector()
                local display = {}
                for _, option in ipairs(values) do
                    if selected[option] then table.insert(display, tostring(option)) end
                end
                selector.Text = (#display > 0 and table.concat(display, ", ") or "Select...")
                    .. (expanded and "   ▲" or "   ▼")
            end

            local function resizeList()
                local visibleCount = math.min(#values, math.max(1, tonumber(controlOptions.MaxVisible) or 4))
                local listHeight = visibleCount * 25
                optionList.Size = UDim2.new(1, -16, 0, expanded and listHeight or 0)
                optionList.Visible = expanded
                row.Size = UDim2.new(1, -4, 0, expanded and (48 + listHeight + 5) or 48)
                refreshEmpty()
            end

            local function fireCallback()
                if type(controlOptions.Callback) == "function" then
                    local value = getValue()
                    local ok, err = pcall(controlOptions.Callback, value)
                    if not ok then warn("[Luna UI] Dropdown callback:", err) end
                end
                self._window:_SetSavedValue(configKey, getValue(), false)
                refreshSelector()
            end

            for index, option in ipairs(values) do
                local optionButton = make("TextButton", {
                    Name = "Option_" .. tostring(index),
                    Parent = optionList,
                    Size = UDim2.new(1, -2, 0, 22),
                    BackgroundColor3 = COLORS.panel,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    FontFace = FONT,
                    TextSize = 12,
                    TextColor3 = COLORS.white,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = tostring(option),
                    LayoutOrder = index,
                })
                round(optionButton, 5)
                make("UIPadding", {
                    Parent = optionButton,
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                })
                optionButton.MouseEnter:Connect(function()
                    animate(optionButton, 0.12, {BackgroundColor3 = COLORS.panelHi})
                end)
                optionButton.MouseLeave:Connect(function()
                    animate(optionButton, 0.12, {BackgroundColor3 = selected[option] and COLORS.active or COLORS.panel})
                end)
                optionButton.Activated:Connect(function()
                    if multi then
                        selected[option] = not selected[option] or nil
                    else
                        table.clear(selected)
                        selected[option] = true
                        expanded = false
                        resizeList()
                    end
                    optionButton.BackgroundColor3 = selected[option] and COLORS.active or COLORS.panel
                    fireCallback()
                    resizeList()
                end)
                optionButton.BackgroundColor3 = selected[option] and COLORS.active or COLORS.panel
            end

            selector.Activated:Connect(function()
                expanded = not expanded
                resizeList()
                refreshSelector()
            end)

            function row:GetValue()
                return getValue()
            end
            function row:SetValue(newValue)
                table.clear(selected)
                if multi and type(newValue) == "table" then
                    for _, item in ipairs(newValue) do
                        local found = findValue(item)
                        if found ~= nil then selected[found] = true end
                    end
                else
                    local found = findValue(newValue)
                    if found ~= nil then selected[found] = true end
                end
                for _, child in ipairs(optionList:GetChildren()) do
                    if child:IsA("TextButton") then
                        local option = values[tonumber(child.Name:match("(%d+)$"))]
                        child.BackgroundColor3 = selected[option] and COLORS.active or COLORS.panel
                    end
                end
                refreshSelector()
                self._window:_SetSavedValue(configKey, getValue(), false)
                if type(controlOptions.Callback) == "function" then
                    local ok, err = pcall(controlOptions.Callback, getValue())
                    if not ok then warn("[Luna UI] Dropdown callback:", err) end
                end
            end

            refreshSelector()
            resizeList()
            if hasSavedValue and type(controlOptions.Callback) == "function" then
                local ok, err = pcall(controlOptions.Callback, getValue())
                if not ok then warn("[Luna UI] Dropdown restore callback:", err) end
            end
            refreshEmpty()
            return row
        end

        function tab:CreateInput(controlOptions)
            controlOptions = controlOptions or {}
            local configKey = self._window:_ConfigKey(self._name, "Input", controlOptions)
            local hasSavedValue = self._window:_HasSavedValue(configKey)
            local defaultText = tostring(controlOptions.Default or "")
            local restoredText = tostring(self._window:_GetSavedValue(configKey, defaultText) or defaultText)
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
                Text = restoredText,
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
                self._window:_SetSavedValue(configKey, box.Text, false)
                if type(controlOptions.Callback) == "function" then
                    local ok, err = pcall(controlOptions.Callback, box.Text, enterPressed)
                    if not ok then warn("[Luna UI] Input callback:", err) end
                end
            end)
            if hasSavedValue and type(controlOptions.Callback) == "function" then
                local ok, err = pcall(controlOptions.Callback, box.Text, false)
                if not ok then warn("[Luna UI] Input restore callback:", err) end
            end
            refreshEmpty()
            return {
                Instance = row,
                TextBox = box,
                GetValue = function() return box.Text end,
                SetValue = function(newValue)
                    box.Text = tostring(newValue or "")
                    self._window:_SetSavedValue(configKey, box.Text, false)
                end,
            }
        end

        track(button.Activated:Connect(function()
            selectTab(tab, false, true)
        end))
        refreshEmpty()
        local savedTabName = self:_GetSavedValue("__activeTab", nil)
        if savedTabName == name then
            selectTab(tab, true, false)
        elseif #self._tabs == 1 then
            selectTab(tab, true, false)
        end
        return tab
    end

    function window:Notify(config)
        if self._destroyed then return end
        if type(config) ~= "table" then
            config = {Content = tostring(config or "")}
        end

        -- Notifications belong to the full screen, not the menu panel, so they
        -- remain visible when the main window is minimized.
        local existing = screenGui:FindFirstChild("LunaToast")
        if existing then existing:Destroy() end

        local toast = make("TextLabel", {
            Name = "LunaToast",
            Parent = screenGui,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -18, 1, 24),
            Size = UDim2.fromOffset(0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = COLORS.panel,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            FontFace = FONT,
            TextSize = 14,
            TextColor3 = config.Color or COLORS.white,
            TextTransparency = 1,
            Text = tostring(config.Content or config.Title or ""),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 200,
        }, {
            make("UICorner", {CornerRadius = UDim.new(0, 9)}),
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
            Position = UDim2.new(1, -22, 1, -22),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if toastStroke then animate(toastStroke, 0.3, {Transparency = 0.8}) end

        task.delay(tonumber(config.Duration) or 2.5, function()
            if toast.Parent and not self._destroyed then
                animate(toast, 0.25, {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    Position = UDim2.new(1, -18, 1, 24),
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                if toastStroke then animate(toastStroke, 0.25, {Transparency = 1}) end
                task.delay(0.3, function()
                    if toast.Parent then toast:Destroy() end
                end)
            end
        end)
    end

    local function offsetPosition(position, yOffset)
        return UDim2.new(
            position.X.Scale,
            position.X.Offset,
            position.Y.Scale,
            position.Y.Offset + yOffset
        )
    end

    local function destroyNow(self)
        if self._destroyed then return end
        -- Flush pending settings before marking this object destroyed.
        if self._configEnabled then
            pcall(function()
                self:SaveConfig()
            end)
        end
        self._destroyed = true
        self._closing = false
        if self._runtimeEnv and self._registryKey and self._runtimeEnv[self._registryKey] == self then
            self._runtimeEnv[self._registryKey] = nil
        end
        for _, connection in ipairs(self._connections) do
            pcall(function() connection:Disconnect() end)
        end
        pcall(function() self._asciiAlpha:Destroy() end)
        self._gui:Destroy()
    end

    local function playOpen(self)
        if self._destroyed or self._closing then return end
        local targetPosition = self._restPosition or self._main.Position

        self._gui.Enabled = true
        self._restoreButton.Visible = false
        self._main.Visible = true
        self._main.Position = offsetPosition(targetPosition, self._openOffset)
        self._mainScale.Scale = self._openScale
        self._main.GroupTransparency = 1

        if self._asciiConfig.enabled then
            self._asciiHolder.Visible = true
            self._asciiAlpha.Value = 0
        end

        -- Allow at least one rendered frame in the start state before tweening.
        task.spawn(function()
            RunService.RenderStepped:Wait()
            if self._destroyed or self._closing or not self._visible then return end

            animate(self._mainScale, self._openDuration, {
                Scale = 1,
            }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            animate(self._main, self._openDuration, {
                GroupTransparency = 0,
                Position = targetPosition,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            if self._asciiConfig.enabled then
                animate(self._asciiAlpha, self._openDuration + 0.12, {
                    Value = 1,
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            end
        end)
    end

    local function playHide(self)
        if self._destroyed then return end
        local targetPosition = self._restPosition or self._main.Position
        local duration = self._closeDuration
        local endingPosition = offsetPosition(targetPosition, self._closeOffset)

        -- Ensure the floating restore button and toasts can remain visible.
        self._gui.Enabled = true
        self._restoreButton.Visible = false

        animate(self._mainScale, duration, {
            Scale = self._openScale,
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        animate(self._main, duration, {
            GroupTransparency = 1,
            Position = endingPosition,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

        if self._asciiConfig.enabled then
            animate(self._asciiAlpha, duration, {
                Value = 0,
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        end

        task.delay(duration + 0.06, function()
            if self._destroyed or self._visible then return end
            self._main.Visible = false
            self._main.Position = targetPosition
            self._mainScale.Scale = 1
            self._main.GroupTransparency = 0
            if self._asciiConfig.enabled then
                self._asciiHolder.Visible = false
            end

            self._restoreButton.Visible = true
            self._restoreScale.Scale = 0.72
            animate(self._restoreScale, 0.24, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end

    function window:SetVisible(visible)
        if self._destroyed or self._closing then return end
        visible = visible == true
        if self._visible == visible then return end
        self._visible = visible

        if visible then
            playOpen(self)
        else
            playHide(self)
        end
    end

    function window:Toggle()
        self:SetVisible(not self._visible)
    end

    -- Close now minimizes to the floating restore square. Destroy() removes everything.
    function window:Close()
        self:SetVisible(false)
    end

    function window:Destroy()
        destroyNow(self)
    end

    track(restoreButton.Activated:Connect(function()
        window:SetVisible(true)
    end))

    track(closeButton.Activated:Connect(function()
        window:Close()
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
            local newPosition = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
            main.Position = newPosition
            window._restPosition = newPosition
            window:_SetSavedValue("__windowPosition", {
                XScale = newPosition.X.Scale,
                XOffset = newPosition.X.Offset,
                YScale = newPosition.Y.Scale,
                YOffset = newPosition.Y.Offset,
            }, true)
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

    -- First launch uses the same slide/pop/fade as later reopenings.
    task.defer(function()
        if window._destroyed or window._closing then return end
        playOpen(window)
    end)

    return window
end

return setmetatable({}, LunaUI)
