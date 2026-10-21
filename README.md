# 🌙 Luna UI

A reusable, dark-themed Roblox UI library inspired by the Luna Scripts interface. It provides draggable windows, tabs, sections, buttons, toggles, sliders, notifications, and cleanup.

## Load the library

```lua
local LunaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PjIuna/Luna-UI/main/LunaUI.lua"))()
```

## Quick start

```lua
local Window = LunaUI:CreateWindow({
    Title = "🌙 Luna Scripts",
    Width = 560,
    Height = 410,
    ToggleKey = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab("Main")
Main:CreateSection("Example")
Main:CreateLabel({ Name = "Welcome to Luna UI!" })

Main:CreateButton({
    Name = "Test Button",
    Callback = function()
        print("Luna UI is working!")
    end,
})

Main:CreateToggle({
    Name = "Example toggle",
    Default = false,
    Callback = function(enabled)
        print("Toggle:", enabled)
    end,
})

Main:CreateSlider({
    Name = "Example slider",
    Range = {0, 100},
    Increment = 1,
    Default = 25,
    Callback = function(value)
        print("Slider:", value)
    end,
})

Window:Notify({
    Title = "Luna UI",
    Content = "The interface is ready.",
    Duration = 3,
})
```

## API

### Window
- `LunaUI:CreateWindow(options)` — create a window.
- `Window:CreateTab(name)` — create and return a tab.
- `Window:Notify({Title, Content, Duration, Color})` — show a toast.
- `Window:SetTitle(text)` — change the title.
- `Window:SetVisible(boolean)` — show or hide the window.
- `Window:Toggle()` — toggle visibility.
- `Window:Destroy()` — disconnect input handlers and remove the GUI.

Window options:
- `Title` — title text (default: `🌙 Luna UI`).
- `Width`, `Height` — window dimensions.
- `Position` — optional `UDim2` position.
- `ToggleKey` — keyboard key used to toggle the window (default: `Enum.KeyCode.RightShift`). Set to `false` to disable.

### Tab components
- `Tab:CreateSection(name)`
- `Tab:CreateLabel({Name, Text, Color, TextSize, Height})`
- `Tab:CreateButton({Name, Callback, TextSize, Height})`
- `Tab:CreateToggle({Name, Default, CurrentValue, Callback})`
- `Tab:CreateSlider({Name, Range={min, max}, Min, Max, Increment, Step, Default, CurrentValue, Callback})`

Toggle callbacks receive a boolean. Slider callbacks receive a number. Button callbacks receive no arguments. Component callbacks are protected with `pcall`, and callback errors are reported with `warn`.

Toggle and slider controls return objects with `GetValue()` and `SetValue(value)`. Labels and buttons return objects with `SetText(text)`; labels also support `SetColor(color)`, and buttons support `SetEnabled(boolean)`.

### Theme

Pass a `Theme` table to `CreateWindow` to override any of these colors: `Background`, `Panel`, `PanelHover`, `Button`, `ButtonHover`, `Accent`, `Text`, `Muted`, `Success`, `Warning`, and `Error`.

## Notes
- Designed for client-side use in a LocalScript or compatible executor environment.
- `loadstring` and `gethui` are not available in every Roblox environment. If `gethui` is unavailable, the library attempts to parent the UI to `CoreGui`.
- This is a UI library only. Button/toggle/slider callbacks are defined by the script that uses it.
- Only run scripts you understand and trust, and respect the rules of the Roblox experience you're using.
