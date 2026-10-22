# 🌙 Luna UI

A reusable Roblox UI toolkit modeled on the supplied Product Faker V2 interface: a compact near-black window, Roboto Condensed typography, charcoal rounded controls, a draggable title bar, image-only bottom navigation, a moving underline indicator, animated hover/selection states, an opening pop-in and closing shrink/fade, an opening slide/pop/fade and closing shrink/slide/fade animation, and the original-style animated ASCII-symbol field around the window. The symbols use a three-layer glow, fade outward from the panel, and ripple around the mouse.

Luna UI provides the interface and callbacks. It does not include the original Product Faker features.

## Load

```lua
local LunaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PjIuna/Luna-UI/main/LunaUI.lua"
))()
```

## Test script

Use the same five icon tabs as the reference interface. Names such as `Home`, `Faker`, `Logger`, `Supported`, and `Passes` automatically use the matching reference icons.

```lua
local Window = LunaUI:CreateWindow({
    Title = "🌙 Luna Scripts",
    ToggleKey = Enum.KeyCode.RightShift,
})

local Home = Window:CreateTab("Home")
Home:CreateParagraph("Welcome to Luna UI", {
    Center = true,
    TextSize = 18,
    Height = 42,
})
Home:CreateParagraph("A reusable interface with the Product Faker V2 layout.", {
    Center = true,
    Color = Color3.fromRGB(193, 193, 193),
    Height = 42,
})
Home:CreateButton({
    Name = "Test Notification",
    Description = "Click to test the toast animation",
    Callback = function()
        Window:Notify({
            Title = "🌙 Luna UI",
            Content = "The notification works!",
            Duration = 3,
        })
    end,
})

local Faker = Window:CreateTab("Faker")
Faker:CreateSection("Control tests")
Faker:CreateLabel("This label uses the reference panel style.")
Faker:CreateButton({
    Name = "Test Button",
    Description = "Writes a message to the output",
    Callback = function()
        print("[Luna UI] Button callback works")
    end,
})
Faker:CreateToggle({
    Name = "Test Toggle",
    Default = false,
    Callback = function(enabled)
        print("[Luna UI] Toggle:", enabled)
    end,
})
Faker:CreateSlider({
    Name = "Test Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("[Luna UI] Slider:", value)
    end,
})
Faker:CreateInput({
    Name = "Test Input",
    Placeholder = "Type something, then press Enter",
    Callback = function(value, enterPressed)
        print("[Luna UI] Input:", value, "Enter:", enterPressed)
    end,
})

local Logger = Window:CreateTab("Logger")
Logger:CreateSection("Logger test")
Logger:CreateLabel("This is the Logger page.")

local Supported = Window:CreateTab("Supported")
Supported:CreateSection("Supported test")
Supported:CreateLabel("This is the Supported page.")

local Passes = Window:CreateTab("Passes")
Passes:CreateSection("Passes test")
Passes:CreateLabel("This is the Passes page.")

Window:Notify({
    Title = "🌙 Luna UI",
    Content = "UI test loaded",
    Duration = 3,
})
```

## Window API

- `LunaUI:CreateWindow(options)`
- `Window:CreateTab(name, {Icon = "rbxassetid://..."})`
- `Window:SetTitle(text)`
- `Window:Notify({Title, Content, Duration, Color})`
- `Window:SetVisible(boolean)`
- `Window:Toggle()`
- `Window:Close()` plays the close animation and then removes the GUI.
- `Window:Destroy()` immediately removes the GUI.

Window options: `Title`, `Width`, `Height`, `AspectRatio`, `ToggleKey`, `OpenAnimationDuration`, `CloseAnimationDuration`, `OpenAnimationScale`, `OpenAnimationOffset`, `CloseAnimationOffset`, `AsciiBackdrop`, `AsciiTextSize`, `AsciiPadding`, `AsciiFPS`, `AsciiRamp`, `AsciiColor`, and `AsciiMouseRipple`. The animated symbol backdrop is enabled by default. Set `AsciiBackdrop = false` to disable it; tweak the text size, border padding, frame rate, glyph ramp, color, or mouse ripple with the other `Ascii*` options. By default the window uses the same scale-based sizing and a 1.2415 aspect ratio as the reference. Press **RightShift** to hide or show it.

## Tab controls

- `Tab:CreateSection(name)`
- `Tab:CreateLabel(text)`
- `Tab:CreateParagraph(text, {Center, Color, TextSize, Height, Italic, Background})`
- `Tab:CreateButton({Name, Description, Subtext, Icon, Callback})`
- `Tab:CreateToggle({Name, Default, Callback})`
- `Tab:CreateSlider({Name, Min, Max, Default, Callback})`
- `Tab:CreateInput({Name, Placeholder, Default, Callback})`

Toggle callbacks receive a boolean. Slider callbacks receive a number. Input callbacks receive the text and an `enterPressed` boolean when focus is lost. Callback errors are sent to `warn`.

Toggle and slider controls return objects with `GetValue()`, `SetValue(value)`, and an `Instance` reference.

## Notes

- The library provides the UI only; callbacks are where your script's own behavior goes.
- Intended for client-side UI in an experience you control or a compatible test environment.
- Executor-only functions such as `gethui` and `loadstring` are not available in standard Roblox scripts.
- The revised layout has not yet been runtime-tested in Roblox. If it errors, use the exact console message to diagnose it.
