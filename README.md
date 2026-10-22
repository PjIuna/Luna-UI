# 🌙 Luna UI

A reusable Roblox UI library styled after the supplied Product Faker V2 reference: compact near-black window, charcoal panels, Roboto Condensed text, rounded corners, subtle outlines, animated bottom navigation, hover effects, and a draggable title bar.

Luna UI is a toolkit only. Your own callbacks decide what buttons, toggles, and sliders do.

## Load the library

```lua
local LunaUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PjIuna/Luna-UI/main/LunaUI.lua"
))()
```

## Quick start

```lua
local Window = LunaUI:CreateWindow({
    Title = "🌙 Luna Scripts",
    Width = 440,
    Height = 355,
    ToggleKey = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab("Main")
Main:CreateSection("Welcome")
Main:CreateLabel("Welcome to Luna UI!")

Main:CreateButton({
    Name = "Test Button",
    Callback = function()
        print("Luna UI is working!")
        Window:Notify({
            Title = "Button Test",
            Content = "The button works!",
            Duration = 3,
        })
    end,
})

Main:CreateToggle({
    Name = "Example Toggle",
    Default = false,
    Callback = function(enabled)
        print("Toggle enabled:", enabled)
    end,
})

Main:CreateSlider({
    Name = "Example Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Slider value:", value)
    end,
})

local Extras = Window:CreateTab("Extras")
Extras:CreateSection("Other tests")
Extras:CreateButton({
    Name = "Show Notification",
    Callback = function()
        Window:Notify({
            Title = "🌙 Luna UI",
            Content = "Notifications are working!",
            Duration = 3,
        })
    end,
})
```

## API

### Window
- `LunaUI:CreateWindow(options)` creates a window.
- `Window:CreateTab(name)` creates a bottom-navigation tab.
- `Window:Notify({Title, Content, Duration})` shows a notification.
- `Window:SetVisible(boolean)` shows or hides the window.
- `Window:Toggle()` toggles visibility.
- `Window:Destroy()` removes the GUI and disconnects the window's tracked connections.

Window options:
- `Title`: title text; defaults to `🌙 Luna UI`.
- `Width` and `Height`: starting window dimensions.
- `AspectRatio`: optional aspect-ratio override; defaults to `1.2415`.
- `ToggleKey`: keyboard key used to toggle visibility; defaults to `Enum.KeyCode.RightShift`.

### Tab components
- `Tab:CreateSection(name)`
- `Tab:CreateLabel(text)`
- `Tab:CreateButton({Name, Callback})`
- `Tab:CreateToggle({Name, Default, Callback})`
- `Tab:CreateSlider({Name, Min, Max, Default, Callback})`

Toggle callbacks receive a boolean. Slider callbacks receive a number. Button callbacks receive no arguments. Callback errors are caught and sent to `warn`.

Toggle and slider controls return objects with `GetValue()`, `SetValue(value)`, and an `Instance` reference to their row.

## Notes
- Intended for client-side LocalScript use in an experience you control or a compatible test environment.
- Some executor-specific functions, such as `gethui` and `loadstring`, are not available in standard Roblox scripts.
- The UI code has not been runtime-tested in Roblox yet; report the exact console error if you find an issue.
- Only run code you understand and trust, and follow the rules of the Roblox experience you're using.
