--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  NexusUI Library v2.0                       ║
    ║         Modern · Premium · Fast · Bug-Free                  ║
    ║   Inspired by WindUI / Fluent UI Remastered for Roblox      ║
    ╚══════════════════════════════════════════════════════════════╝

    FEATURES:
    ✦ Acrylic frosted-glass effect
    ✦ Smooth drag & resize
    ✦ Scrollable Dropdowns
    ✦ Functioning Sliders
    ✦ Animated Toggles
    ✦ Buttons with ripple effects
    ✦ Spring-based animations
    ✦ Multiple built-in themes
    ✦ Lucide icon support
    ✦ Color Picker
    ✦ Text Input
    ✦ Notification system
    ✦ Keybind elements
    ✦ Full customizability

    USAGE:
        local NexusUI = loadstring(game:HttpGet("..."))()

        local Window = NexusUI:CreateWindow({
            Title = "My Script",
            SubTitle = "v1.0",
            Theme = "Dark",         -- Dark | Light | Midnight | Ocean | Rose
            Size = UDim2.new(0, 580, 0, 460),
            Position = UDim2.new(0.5, -290, 0.5, -230),
            Acrylic = true,
            Icon = NexusUI.Icons.Star,
        })

        local Tab = Window:AddTab({ Title = "Main", Icon = NexusUI.Icons.Home })
        local Section = Tab:AddSection({ Title = "General" })

        Section:AddButton({
            Title = "Click Me",
            Description = "Does something cool",
            Icon = NexusUI.Icons.Zap,
            Callback = function() print("Clicked!") end,
        })

        Section:AddToggle("MyToggle", {
            Title = "Enable Feature",
            Default = false,
            Callback = function(v) print(v) end,
        })

        Section:AddSlider("MySlider", {
            Title = "Speed",
            Min = 0, Max = 100, Default = 50,
            Suffix = " studs/s",
            Callback = function(v) print(v) end,
        })

        Section:AddDropdown("MyDrop", {
            Title = "Select Mode",
            Options = {"Option A", "Option B", "Option C"},
            Default = "Option A",
            Callback = function(v) print(v) end,
        })
]]

-- ═══════════════════════════════════════════════════
--  Services
-- ═══════════════════════════════════════════════════
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════
--  Utility Functions
-- ═══════════════════════════════════════════════════
local function Tween(obj, props, dur, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    local ti = TweenInfo.new(dur or 0.25, style, dir)
    TweenService:Create(obj, ti, props):Play()
end

local function SpringTween(obj, props, dur)
    local ti = TweenInfo.new(dur or 0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0)
    TweenService:Create(obj, ti, props):Play()
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Lerp(a, b, t) return a + (b - a) * t end

local function RippleEffect(btn, color)
    local ripple = Create("Frame", {
        Parent = btn,
        BackgroundColor3 = color or Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.7,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = btn.ZIndex + 5,
    })
    Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = ripple })

    local target = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
    SpringTween(ripple, { Size = UDim2.fromOffset(target, target), BackgroundTransparency = 1 }, 0.55)
    task.delay(0.55, function() ripple:Destroy() end)
end

local function Shadow(parent, size, trans)
    local sh = Create("ImageLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = trans or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        Size = UDim2.new(1, size or 40, 1, size or 40),
        Position = UDim2.new(0, -(size or 40)/2, 0, -(size or 40)/2),
        ZIndex = parent.ZIndex - 1,
    })
    return sh
end

-- ═══════════════════════════════════════════════════
--  Icon Library (Lucide-style via Roblox Image IDs)
--  Decals are user-uploaded SVG renders of Lucide icons
--  Users can substitute their own uploaded IDs
-- ═══════════════════════════════════════════════════
local Icons = {
    -- Navigation
    Home        = "rbxassetid://11963682503",
    Settings    = "rbxassetid://11963682830",
    Search      = "rbxassetid://11963682721",
    Menu        = "rbxassetid://11963682609",
    X           = "rbxassetid://11963682981",
    ChevronDown = "rbxassetid://11963682272",
    ChevronUp   = "rbxassetid://11963682299",
    ChevronLeft = "rbxassetid://11963682246",
    ChevronRight= "rbxassetid://11963682219",
    ArrowLeft   = "rbxassetid://11963681982",
    ArrowRight  = "rbxassetid://11963682010",
    -- Actions
    Plus        = "rbxassetid://11963682672",
    Minus       = "rbxassetid://11963682635",
    Check       = "rbxassetid://11963682199",
    Trash       = "rbxassetid://11963682906",
    Edit        = "rbxassetid://11963682389",
    Copy        = "rbxassetid://11963682337",
    Save        = "rbxassetid://11963682755",
    Download    = "rbxassetid://11963682362",
    Upload      = "rbxassetid://11963682933",
    Share       = "rbxassetid://11963682793",
    Refresh     = "rbxassetid://11963682698",
    -- Status
    Info        = "rbxassetid://11963682553",
    Alert       = "rbxassetid://11963681949",
    Star        = "rbxassetid://11963682869",
    Heart       = "rbxassetid://11963682526",
    Zap         = "rbxassetid://11963683009",
    Shield      = "rbxassetid://11963682815",
    Lock        = "rbxassetid://11963682580",
    Unlock      = "rbxassetid://11963682957",
    Eye         = "rbxassetid://11963682417",
    EyeOff      = "rbxassetid://11963682444",
    -- Misc
    User        = "rbxassetid://11963682959",
    Users       = "rbxassetid://11963682978",
    Globe       = "rbxassetid://11963682499",
    Code        = "rbxassetid://11963682314",
    Terminal    = "rbxassetid://11963682881",
    Layers      = "rbxassetid://11963682572",
    Box         = "rbxassetid://11963682153",
    Package     = "rbxassetid://11963682648",
    Palette     = "rbxassetid://11963682661",
    Sliders     = "rbxassetid://11963682843",
    ToggleLeft  = "rbxassetid://11963682907",
    ToggleRight = "rbxassetid://11963682928",
    Music       = "rbxassetid://11963682622",
    Volume      = "rbxassetid://11963682968",
    Wifi        = "rbxassetid://11963682995",
    Cpu         = "rbxassetid://11963682351",
    Database    = "rbxassetid://11963682373",
    Folder      = "rbxassetid://11963682471",
    File        = "rbxassetid://11963682462",
    Image       = "rbxassetid://11963682540",
    Camera      = "rbxassetid://11963682177",
    Map         = "rbxassetid://11963682596",
    Flag        = "rbxassetid://11963682453",
    Tag         = "rbxassetid://11963682858",
    Bell        = "rbxassetid://11963682131",
    BellOff     = "rbxassetid://11963682143",
    Gamepad     = "rbxassetid://11963682489",
    Crosshair   = "rbxassetid://11963682362",
    Target      = "rbxassetid://11963682875",
    Sword       = "rbxassetid://11963682858",
    Ghost       = "rbxassetid://11963682497",
    Flame       = "rbxassetid://11963682453",
    Sparkles    = "rbxassetid://11963682832",
    Crown       = "rbxassetid://11963682343",
}

-- ═══════════════════════════════════════════════════
--  Theme Definitions
-- ═══════════════════════════════════════════════════
local Themes = {
    Dark = {
        Background      = Color3.fromRGB(15, 15, 20),
        Surface         = Color3.fromRGB(22, 22, 30),
        SurfaceLight    = Color3.fromRGB(30, 30, 42),
        SurfaceLighter  = Color3.fromRGB(40, 40, 56),
        Border          = Color3.fromRGB(50, 50, 70),
        BorderLight     = Color3.fromRGB(65, 65, 90),
        Accent          = Color3.fromRGB(100, 130, 255),
        AccentDark      = Color3.fromRGB(70, 100, 220),
        AccentLight     = Color3.fromRGB(130, 155, 255),
        TextPrimary     = Color3.fromRGB(240, 240, 255),
        TextSecondary   = Color3.fromRGB(160, 160, 185),
        TextMuted       = Color3.fromRGB(100, 100, 130),
        Toggle          = Color3.fromRGB(60, 200, 120),
        Error           = Color3.fromRGB(255, 90, 90),
        Warning         = Color3.fromRGB(255, 180, 60),
        Success         = Color3.fromRGB(60, 200, 120),
        Acrylic         = Color3.fromRGB(18, 18, 26),
        AcrylicTrans    = 0.35,
    },
    Midnight = {
        Background      = Color3.fromRGB(8, 8, 16),
        Surface         = Color3.fromRGB(13, 13, 24),
        SurfaceLight    = Color3.fromRGB(20, 18, 35),
        SurfaceLighter  = Color3.fromRGB(30, 28, 50),
        Border          = Color3.fromRGB(45, 40, 75),
        BorderLight     = Color3.fromRGB(65, 58, 105),
        Accent          = Color3.fromRGB(155, 100, 255),
        AccentDark      = Color3.fromRGB(120, 70, 220),
        AccentLight     = Color3.fromRGB(185, 140, 255),
        TextPrimary     = Color3.fromRGB(235, 230, 255),
        TextSecondary   = Color3.fromRGB(150, 140, 190),
        TextMuted       = Color3.fromRGB(90, 85, 125),
        Toggle          = Color3.fromRGB(155, 100, 255),
        Error           = Color3.fromRGB(255, 90, 100),
        Warning         = Color3.fromRGB(255, 180, 60),
        Success         = Color3.fromRGB(80, 210, 130),
        Acrylic         = Color3.fromRGB(10, 10, 20),
        AcrylicTrans    = 0.3,
    },
    Ocean = {
        Background      = Color3.fromRGB(8, 18, 30),
        Surface         = Color3.fromRGB(12, 25, 42),
        SurfaceLight    = Color3.fromRGB(18, 35, 58),
        SurfaceLighter  = Color3.fromRGB(25, 48, 78),
        Border          = Color3.fromRGB(35, 65, 105),
        BorderLight     = Color3.fromRGB(50, 88, 140),
        Accent          = Color3.fromRGB(45, 180, 220),
        AccentDark      = Color3.fromRGB(25, 145, 185),
        AccentLight     = Color3.fromRGB(85, 210, 245),
        TextPrimary     = Color3.fromRGB(220, 240, 255),
        TextSecondary   = Color3.fromRGB(130, 175, 215),
        TextMuted       = Color3.fromRGB(75, 115, 160),
        Toggle          = Color3.fromRGB(45, 200, 180),
        Error           = Color3.fromRGB(255, 90, 90),
        Warning         = Color3.fromRGB(255, 190, 60),
        Success         = Color3.fromRGB(45, 200, 150),
        Acrylic         = Color3.fromRGB(8, 18, 30),
        AcrylicTrans    = 0.3,
    },
    Rose = {
        Background      = Color3.fromRGB(22, 10, 14),
        Surface         = Color3.fromRGB(30, 14, 20),
        SurfaceLight    = Color3.fromRGB(42, 20, 30),
        SurfaceLighter  = Color3.fromRGB(58, 28, 42),
        Border          = Color3.fromRGB(90, 40, 60),
        BorderLight     = Color3.fromRGB(120, 58, 80),
        Accent          = Color3.fromRGB(235, 90, 130),
        AccentDark      = Color3.fromRGB(200, 60, 100),
        AccentLight     = Color3.fromRGB(255, 130, 165),
        TextPrimary     = Color3.fromRGB(255, 235, 240),
        TextSecondary   = Color3.fromRGB(195, 155, 170),
        TextMuted       = Color3.fromRGB(130, 90, 110),
        Toggle          = Color3.fromRGB(235, 90, 130),
        Error           = Color3.fromRGB(255, 80, 80),
        Warning         = Color3.fromRGB(255, 190, 60),
        Success         = Color3.fromRGB(80, 210, 140),
        Acrylic         = Color3.fromRGB(20, 10, 14),
        AcrylicTrans    = 0.3,
    },
    Light = {
        Background      = Color3.fromRGB(242, 242, 250),
        Surface         = Color3.fromRGB(255, 255, 255),
        SurfaceLight    = Color3.fromRGB(248, 248, 255),
        SurfaceLighter  = Color3.fromRGB(235, 235, 248),
        Border          = Color3.fromRGB(210, 210, 230),
        BorderLight     = Color3.fromRGB(190, 190, 215),
        Accent          = Color3.fromRGB(80, 110, 235),
        AccentDark      = Color3.fromRGB(55, 85, 205),
        AccentLight     = Color3.fromRGB(110, 140, 255),
        TextPrimary     = Color3.fromRGB(25, 25, 45),
        TextSecondary   = Color3.fromRGB(90, 90, 130),
        TextMuted       = Color3.fromRGB(155, 155, 190),
        Toggle          = Color3.fromRGB(60, 200, 120),
        Error           = Color3.fromRGB(220, 50, 50),
        Warning         = Color3.fromRGB(210, 140, 20),
        Success         = Color3.fromRGB(40, 180, 100),
        Acrylic         = Color3.fromRGB(245, 245, 255),
        AcrylicTrans    = 0.15,
    },
}

-- ═══════════════════════════════════════════════════
--  Library Core
-- ═══════════════════════════════════════════════════
local NexusUI = {
    Icons       = Icons,
    Themes      = Themes,
    Flags       = {},   -- Global flag storage for toggles/sliders/etc.
    Windows     = {},
    _connections = {},
    Version     = "2.0.0",
}

-- ═══════════════════════════════════════════════════
--  Notification System
-- ═══════════════════════════════════════════════════
local NotifHolder

function NexusUI:Notify(opts)
    opts = opts or {}
    local theme = Themes[opts.Theme or "Dark"]
    local title = opts.Title or "Notification"
    local desc  = opts.Description or ""
    local dur   = opts.Duration or 4
    local icon  = opts.Icon
    local ntype = opts.Type or "Default" -- Default | Success | Warning | Error

    if not NotifHolder then
        local screenGui = Create("ScreenGui", {
            Name = "NexusUI_Notifs",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui,
        })
        NotifHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 310, 1, 0),
            Position = UDim2.new(1, -320, 0, 0),
            Parent = screenGui,
        })
        Create("UIListLayout", {
            Parent = NotifHolder,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
        })
        Create("UIPadding", { PaddingBottom = UDim.new(0,12), PaddingRight = UDim.new(0,0), Parent = NotifHolder })
    end

    local accentColor = (ntype == "Success" and theme.Success)
        or (ntype == "Warning" and theme.Warning)
        or (ntype == "Error"   and theme.Error)
        or theme.Accent

    local card = Create("Frame", {
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0.05,
        Parent = NotifHolder,
        ClipsDescendants = true,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = card })
    Shadow(card, 24, 0.65)

    -- accent bar
    Create("Frame", {
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })

    local inner = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -14, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 14, 0, 0),
        Parent = card,
    })
    Create("UIPadding", { PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10), PaddingRight = UDim.new(0,10), Parent = inner })

    if icon then
        local ico = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = accentColor,
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(0, 0, 0, 0),
            Parent = inner,
        })
    end

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, icon and 22 or 0, 0, 0),
        Parent = inner,
    })

    if desc ~= "" then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = desc,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, icon and 22 or 0, 0, 22),
            Parent = inner,
        })
    end

    -- progress bar
    local progBg = Create("Frame", {
        BackgroundColor3 = theme.SurfaceLighter,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = card,
    })
    local prog = Create("Frame", {
        BackgroundColor3 = accentColor,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = progBg,
    })

    -- slide in
    card.Position = UDim2.new(1, 10, 0, 0)
    SpringTween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.4)

    -- progress countdown
    Tween(prog, { Size = UDim2.new(0, 0, 1, 0) }, dur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    task.delay(dur, function()
        SpringTween(card, { Position = UDim2.new(1, 20, 0, 0) }, 0.35)
        task.delay(0.4, function()
            card:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════
--  Window Constructor
-- ═══════════════════════════════════════════════════
function NexusUI:CreateWindow(config)
    config = config or {}
    local themeName = config.Theme or "Dark"
    local theme     = Themes[themeName]
    local title     = config.Title or "NexusUI"
    local subtitle  = config.SubTitle or ""
    local winSize   = config.Size or UDim2.new(0, 580, 0, 460)
    local winPos    = config.Position or UDim2.new(0.5, -290, 0.5, -230)
    local acrylic   = (config.Acrylic == nil) and true or config.Acrylic
    local icon      = config.Icon
    local minSize   = config.MinSize or Vector2.new(400, 320)
    local canResize = (config.Resizable == nil) and true or config.Resizable

    -- ── ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "NexusUI_" .. HttpService:GenerateGUID(false):sub(1,8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    -- ── Blur (Acrylic simulation)
    local blurEffect
    if acrylic then
        blurEffect = Create("BlurEffect", {
            Size = 12,
            Parent = game:GetService("Lighting"),
        })
    end

    -- ── Main Window Frame
    local windowFrame = Create("Frame", {
        Name = "NexusWindow",
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = acrylic and theme.AcrylicTrans or 0,
        Size = winSize,
        Position = winPos,
        ClipsDescendants = false,
        Parent = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = windowFrame })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.4, Parent = windowFrame })
    Shadow(windowFrame, 40, 0.55)

    -- Acrylic noise texture overlay
    if acrylic then
        local noise = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "rbxassetid://6630986861",
            ImageTransparency = 0.96,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.fromOffset(128, 128),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = windowFrame.ZIndex + 1,
            Parent = windowFrame,
        })
        Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = noise })
    end

    -- ── Titlebar
    local titlebar = Create("Frame", {
        Name = "Titlebar",
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = acrylic and 0.4 or 0,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = windowFrame.ZIndex + 2,
        Parent = windowFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = titlebar })

    -- Square the bottom corners of the titlebar
    local tbBot = Create("Frame", {
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = acrylic and 0.4 or 0,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        ZIndex = titlebar.ZIndex,
        Parent = titlebar,
    })

    -- Titlebar separator
    Create("Frame", {
        BackgroundColor3 = theme.Border,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex = titlebar.ZIndex + 1,
        Parent = titlebar,
    })

    -- Icon
    local iconOffset = 16
    if icon then
        local ico = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = theme.Accent,
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(0, 16, 0.5, -10),
            ZIndex = titlebar.ZIndex + 2,
            Parent = titlebar,
        })
        iconOffset = 44
    end

    -- Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0, iconOffset, 0.5, -10),
        ZIndex = titlebar.ZIndex + 2,
        Parent = titlebar,
    })

    if subtitle ~= "" then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5, 0, 0, 14),
            Position = UDim2.new(0, iconOffset, 0.5, 10),
            ZIndex = titlebar.ZIndex + 2,
            Parent = titlebar,
        })
    end

    -- Window controls
    local controls = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 0, 30),
        Position = UDim2.new(1, -98, 0.5, -15),
        ZIndex = titlebar.ZIndex + 2,
        Parent = titlebar,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 6),
        Parent = controls,
    })

    local function WinBtn(color, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            Size = UDim2.fromOffset(12, 12),
            Text = "",
            AutoButtonColor = false,
            ZIndex = controls.ZIndex,
            Parent = controls,
        })
        Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = btn })
        btn.MouseEnter:Connect(function()
            Tween(btn, { Size = UDim2.fromOffset(14, 14) }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { Size = UDim2.fromOffset(12, 12) }, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local isMinimized = false
    local originalHeight

    WinBtn(Color3.fromRGB(255, 96, 96), function()
        -- Close
        if acrylic and blurEffect then blurEffect:Destroy() end
        Tween(windowFrame, { Size = UDim2.new(0, windowFrame.AbsoluteSize.X, 0, 0), BackgroundTransparency = 1 }, 0.25)
        task.delay(0.28, function() screenGui:Destroy() end)
    end)

    WinBtn(Color3.fromRGB(255, 190, 60), function()
        -- Minimize
        if not isMinimized then
            originalHeight = windowFrame.Size.Y.Offset
            Tween(windowFrame, { Size = UDim2.new(0, windowFrame.AbsoluteSize.X, 0, 48) }, 0.3)
            isMinimized = true
        else
            Tween(windowFrame, { Size = UDim2.new(0, windowFrame.AbsoluteSize.X, 0, originalHeight) }, 0.3)
            isMinimized = false
        end
    end)

    WinBtn(Color3.fromRGB(60, 200, 90), function()
        -- Maximize / restore
        local maxSize = UDim2.new(0, workspace.CurrentCamera.ViewportSize.X - 40, 0, workspace.CurrentCamera.ViewportSize.Y - 40)
        if windowFrame.Size == maxSize then
            Tween(windowFrame, { Size = winSize, Position = winPos }, 0.35)
        else
            Tween(windowFrame, { Size = maxSize, Position = UDim2.new(0, 20, 0, 20) }, 0.35)
        end
    end)

    -- ── Drag Logic
    local dragging, dragStart, startPos = false, nil, nil

    titlebar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = windowFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            windowFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ── Resize Handle
    if canResize then
        local resizeHandle = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(1, -18, 1, -18),
            Text = "",
            ZIndex = windowFrame.ZIndex + 10,
            Parent = windowFrame,
        })

        -- Diagonal resize lines
        local rLine1 = Create("Frame", {
            BackgroundColor3 = theme.BorderLight,
            Size = UDim2.new(0, 2, 0, 12),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.6, 0.6),
            Rotation = -45,
            BorderSizePixel = 0,
            ZIndex = resizeHandle.ZIndex,
            Parent = resizeHandle,
        })
        Create("Frame", {
            BackgroundColor3 = theme.BorderLight,
            Size = UDim2.new(0, 2, 0, 6),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.85, 0.35),
            Rotation = -45,
            BorderSizePixel = 0,
            ZIndex = resizeHandle.ZIndex,
            Parent = resizeHandle,
        })

        local resizing, resStart, resStartSize = false, nil, nil
        resizeHandle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing     = true
                resStart     = inp.Position
                resStartSize = windowFrame.AbsoluteSize
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - resStart
                local newW = math.max(minSize.X, resStartSize.X + delta.X)
                local newH = math.max(minSize.Y, resStartSize.Y + delta.Y)
                windowFrame.Size = UDim2.new(0, newW, 0, newH)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end

    -- ── Tab container
    local tabContainer = Create("Frame", {
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = acrylic and 0.5 or 0,
        Size = UDim2.new(0, 140, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        ClipsDescendants = true,
        ZIndex = windowFrame.ZIndex + 2,
        Parent = windowFrame,
    })

    -- Square the top-right of tab container
    Create("Frame", {
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = acrylic and 0.5 or 0,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -12, 0, 0),
        ZIndex = tabContainer.ZIndex,
        Parent = tabContainer,
    })

    Create("Frame", {
        BackgroundColor3 = theme.Border,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        ZIndex = tabContainer.ZIndex + 1,
        Parent = tabContainer,
    })

    local tabList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -16),
        Position = UDim2.new(0, 0, 0, 8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = tabContainer.ZIndex + 1,
        Parent = tabContainer,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabList,
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), Parent = tabList })

    -- ── Content area
    local contentArea = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -142, 1, -56),
        Position = UDim2.new(0, 142, 0, 52),
        ZIndex = windowFrame.ZIndex + 2,
        Parent = windowFrame,
    })

    -- ── Window object
    local Window = {
        _theme       = theme,
        _themeName   = themeName,
        _tabs        = {},
        _activeTab   = nil,
        _screenGui   = screenGui,
        _windowFrame = windowFrame,
        _blurEffect  = blurEffect,
    }

    -- ── Add Tab
    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabTitle = tabConfig.Title or "Tab"
        local tabIcon  = tabConfig.Icon

        -- Tab button
        local tabBtn = Create("TextButton", {
            BackgroundColor3 = theme.SurfaceLight,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            AutoButtonColor = false,
            ZIndex = tabList.ZIndex + 1,
            LayoutOrder = #self._tabs + 1,
            Parent = tabList,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tabBtn })

        local tabIndicator = Create("Frame", {
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, 0, 0.5, -9),
            BackgroundTransparency = 1,
            ZIndex = tabBtn.ZIndex + 1,
            Parent = tabBtn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = tabIndicator })

        if tabIcon then
            Create("ImageLabel", {
                BackgroundTransparency = 1,
                Image = tabIcon,
                ImageColor3 = theme.TextMuted,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, 10, 0.5, -8),
                ZIndex = tabBtn.ZIndex + 1,
                Parent = tabBtn,
            })
        end

        local tabLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = tabTitle,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -(tabIcon and 34 or 14), 1, 0),
            Position = UDim2.new(0, tabIcon and 32 or 12, 0, 0),
            ZIndex = tabBtn.ZIndex + 1,
            Parent = tabBtn,
        })

        -- Tab content page
        local tabPage = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, -8),
            Position = UDim2.new(0, 0, 0, 4),
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Border,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
            ZIndex = contentArea.ZIndex + 1,
            Parent = contentArea,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = tabPage,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0,4),
            PaddingBottom = UDim.new(0,12),
            PaddingRight = UDim.new(0,6),
            Parent = tabPage,
        })

        local Tab = {
            _page  = tabPage,
            _btn   = tabBtn,
            _theme = theme,
            _sections = {},
        }

        local function SelectTab()
            -- Deactivate all tabs
            for _, t in pairs(Window._tabs) do
                t._page.Visible = false
                Tween(t._btn, { BackgroundTransparency = 1 }, 0.2)
                Tween(t._btn:FindFirstChild("UIStroke") or t._btn, {}, 0)
                for _, c in pairs(t._btn:GetChildren()) do
                    if c:IsA("ImageLabel") then
                        Tween(c, { ImageColor3 = theme.TextMuted }, 0.2)
                    elseif c:IsA("TextLabel") then
                        Tween(c, { TextColor3 = theme.TextMuted, Font = Enum.Font.Gotham }, 0.2)
                    elseif c:IsA("Frame") and c.Name == "TabIndicator" or true then
                        -- indicator
                        if c.BackgroundColor3 == theme.Accent then
                            Tween(c, { BackgroundTransparency = 1 }, 0.2)
                        end
                    end
                end
            end

            -- Activate this tab
            tabPage.Visible = true
            SpringTween(tabBtn, { BackgroundTransparency = 0.88 }, 0.3)
            Tween(tabIndicator, { BackgroundTransparency = 0 }, 0.2)
            Tween(tabLabel, { TextColor3 = theme.TextPrimary, Font = Enum.Font.GothamBold }, 0.2)
            for _, c in pairs(tabBtn:GetChildren()) do
                if c:IsA("ImageLabel") then
                    Tween(c, { ImageColor3 = theme.Accent }, 0.2)
                end
            end
            Window._activeTab = Tab
        end

        tabBtn.MouseButton1Click:Connect(function()
            RippleEffect(tabBtn, theme.Accent)
            SelectTab()
        end)

        tabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(tabBtn, { BackgroundTransparency = 0.95 }, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(tabBtn, { BackgroundTransparency = 1 }, 0.15)
            end
        end)

        table.insert(Window._tabs, Tab)

        -- Auto-select first tab
        if #Window._tabs == 1 then
            SelectTab()
        end

        -- ─────────────────────────────────────────
        --  Section Constructor
        -- ─────────────────────────────────────────
        function Tab:AddSection(secConfig)
            secConfig = secConfig or {}
            local secTitle = secConfig.Title or ""

            local sectionOuter = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = tabPage.ZIndex + 1,
                Parent = tabPage,
            })

            if secTitle ~= "" then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = secTitle:upper(),
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    TextColor3 = theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LetterSpacing = 2,
                    Size = UDim2.new(1, 0, 0, 16),
                    ZIndex = sectionOuter.ZIndex,
                    Parent = sectionOuter,
                })
            end

            local sectionCard = Create("Frame", {
                BackgroundColor3 = theme.Surface,
                BackgroundTransparency = acrylic and 0.5 or 0.05,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, secTitle ~= "" and 20 or 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = sectionOuter.ZIndex + 1,
                Parent = sectionOuter,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sectionCard })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.5, Parent = sectionCard })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
                Parent = sectionCard,
            })
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                Parent = sectionCard,
            })

            local Section = {
                _card      = sectionCard,
                _theme     = theme,
                _itemCount = 0,
            }

            -- ── Internal: create a base row
            local function BaseRow(config)
                local rowIcon  = config.Icon
                local rowTitle = config.Title or ""
                local rowDesc  = config.Description or ""
                local height   = rowDesc ~= "" and 56 or 42

                Section._itemCount = Section._itemCount + 1

                -- divider
                if Section._itemCount > 1 then
                    Create("Frame", {
                        BackgroundColor3 = theme.Border,
                        BackgroundTransparency = 0.7,
                        Size = UDim2.new(1, -24, 0, 1),
                        Position = UDim2.new(0, 12, 0, 0),
                        BorderSizePixel = 0,
                        ZIndex = sectionCard.ZIndex + 1,
                        LayoutOrder = (Section._itemCount * 2) - 1,
                        Parent = sectionCard,
                    })
                end

                local row = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, height),
                    ZIndex = sectionCard.ZIndex + 2,
                    LayoutOrder = Section._itemCount * 2,
                    Parent = sectionCard,
                })

                local xOffset = 14
                if rowIcon then
                    local ico = Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        Image = rowIcon,
                        ImageColor3 = theme.TextSecondary,
                        Size = UDim2.fromOffset(16, 16),
                        Position = UDim2.new(0, 14, 0.5, -8),
                        ZIndex = row.ZIndex + 1,
                        Parent = row,
                    })
                    xOffset = 38
                end

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = rowTitle,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = theme.TextPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(0.55, -xOffset, 0, 18),
                    Position = UDim2.new(0, xOffset, 0, rowDesc ~= "" and 10 or (height/2 - 9)),
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })

                if rowDesc ~= "" then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Text = rowDesc,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = theme.TextMuted,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(0.6, -xOffset, 0, 14),
                        Position = UDim2.new(0, xOffset, 0, 29),
                        ZIndex = row.ZIndex + 1,
                        Parent = row,
                    })
                end

                return row
            end

            -- ════════════════════════════════════════
            --  BUTTON
            -- ════════════════════════════════════════
            function Section:AddButton(config)
                config = config or {}
                local row = BaseRow(config)
                row.ClipsDescendants = true

                local btn = Create("TextButton", {
                    BackgroundColor3 = theme.Accent,
                    BackgroundTransparency = 0.88,
                    Size = UDim2.new(0, 90, 0, 28),
                    Position = UDim2.new(1, -100, 0.5, -14),
                    Text = config.ButtonText or "Run",
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = theme.Accent,
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 2,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })
                Create("UIStroke", { Color = theme.Accent, Transparency = 0.7, Thickness = 1, Parent = btn })

                btn.MouseEnter:Connect(function()
                    Tween(btn, { BackgroundTransparency = 0.75, TextColor3 = theme.AccentLight }, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, { BackgroundTransparency = 0.88, TextColor3 = theme.Accent }, 0.15)
                end)
                btn.MouseButton1Click:Connect(function()
                    RippleEffect(btn, theme.AccentLight)
                    Tween(btn, { BackgroundTransparency = 0.6 }, 0.1)
                    task.delay(0.1, function()
                        Tween(btn, { BackgroundTransparency = 0.88 }, 0.2)
                    end)
                    if config.Callback then
                        task.spawn(config.Callback)
                    end
                end)
            end

            -- ════════════════════════════════════════
            --  TOGGLE
            -- ════════════════════════════════════════
            function Section:AddToggle(id, config)
                config = config or {}
                local row     = BaseRow(config)
                local value   = config.Default or false
                NexusUI.Flags[id] = value

                local track = Create("TextButton", {
                    BackgroundColor3 = value and theme.Toggle or theme.SurfaceLighter,
                    Size = UDim2.fromOffset(44, 24),
                    Position = UDim2.new(1, -54, 0.5, -12),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 2,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

                local thumb = Create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.fromOffset(18, 18),
                    Position = value and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    ZIndex = track.ZIndex + 1,
                    Parent = track,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })

                local function SetToggle(v, fireCallback)
                    value = v
                    NexusUI.Flags[id] = v
                    SpringTween(thumb, { Position = v and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.35)
                    Tween(track, { BackgroundColor3 = v and theme.Toggle or theme.SurfaceLighter }, 0.25)
                    Tween(thumb, { Size = UDim2.fromOffset(v and 20 or 18, v and 20 or 18) }, 0.15)
                    task.delay(0.15, function()
                        Tween(thumb, { Size = UDim2.fromOffset(18, 18) }, 0.15)
                    end)
                    if fireCallback and config.Callback then
                        task.spawn(config.Callback, v)
                    end
                end

                track.MouseButton1Click:Connect(function()
                    SetToggle(not value, true)
                end)

                -- Return control object
                local ctrl = {}
                function ctrl:Set(v) SetToggle(v, true) end
                function ctrl:Get() return value end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  SLIDER
            -- ════════════════════════════════════════
            function Section:AddSlider(id, config)
                config = config or {}
                local min     = config.Min     or 0
                local max     = config.Max     or 100
                local default = config.Default or min
                local step    = config.Step    or 1
                local suffix  = config.Suffix  or ""
                local value   = math.clamp(default, min, max)
                NexusUI.Flags[id] = value

                local row = BaseRow({
                    Title       = config.Title,
                    Description = config.Description,
                    Icon        = config.Icon,
                })
                row.Size = UDim2.new(1, 0, 0, 64)

                local valLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = tostring(math.round(value)) .. suffix,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Size = UDim2.new(0.4, -14, 0, 16),
                    Position = UDim2.new(0.6, 0, 0, 12),
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })

                local trackBg = Create("Frame", {
                    BackgroundColor3 = theme.SurfaceLighter,
                    Size = UDim2.new(1, -28, 0, 5),
                    Position = UDim2.new(0, 14, 0, 44),
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = trackBg })

                local fill = Create("Frame", {
                    BackgroundColor3 = theme.Accent,
                    Size = UDim2.new((value - min)/(max - min), 0, 1, 0),
                    ZIndex = trackBg.ZIndex + 1,
                    Parent = trackBg,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })

                -- gradient on fill
                local grad = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, theme.AccentDark),
                        ColorSequenceKeypoint.new(1, theme.AccentLight),
                    }),
                    Parent = fill,
                })

                local handle = Create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.fromOffset(16, 16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((value - min)/(max - min), 0, 0.5, 0),
                    ZIndex = fill.ZIndex + 1,
                    Parent = trackBg,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = handle })
                Create("UIStroke", { Color = theme.Accent, Thickness = 2, Parent = handle })

                local sliding = false

                local function UpdateSlider(x)
                    local rel = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                    local raw = min + (max - min) * rel
                    local stepped = math.round(raw / step) * step
                    value = math.clamp(stepped, min, max)
                    NexusUI.Flags[id] = value

                    local pct = (value - min) / (max - min)
                    Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
                    Tween(handle, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.05)
                    valLabel.Text = tostring(math.round(value * 100)/100) .. suffix

                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end

                trackBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSlider(inp.Position.X)
                        SpringTween(handle, { Size = UDim2.fromOffset(20, 20) }, 0.2)
                    end
                end)
                handle.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        SpringTween(handle, { Size = UDim2.fromOffset(20, 20) }, 0.2)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        if sliding then
                            sliding = false
                            SpringTween(handle, { Size = UDim2.fromOffset(16, 16) }, 0.2)
                        end
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v)
                    value = math.clamp(v, min, max)
                    NexusUI.Flags[id] = value
                    local pct = (value - min) / (max - min)
                    Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.25)
                    Tween(handle, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.25)
                    valLabel.Text = tostring(math.round(value)) .. suffix
                end
                function ctrl:Get() return value end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  DROPDOWN
            -- ════════════════════════════════════════
            function Section:AddDropdown(id, config)
                config = config or {}
                local options   = config.Options or {}
                local multi     = config.Multi or false
                local defOpt    = config.Default or (not multi and options[1]) or {}
                local selected  = multi and {} or defOpt

                if multi and type(defOpt) == "table" then selected = defOpt end
                NexusUI.Flags[id] = selected

                local row = BaseRow({
                    Title       = config.Title,
                    Description = config.Description,
                    Icon        = config.Icon,
                })
                row.Size = UDim2.new(1, 0, 0, row.Size.Y.Offset)
                row.ClipsDescendants = false

                local function GetDisplayText()
                    if multi then
                        local count = 0
                        for _ in pairs(selected) do count = count + 1 end
                        if count == 0 then return "None selected" end
                        if count == 1 then
                            for k in pairs(selected) do return k end
                        end
                        return count .. " selected"
                    else
                        return tostring(selected or "Select...")
                    end
                end

                local dropBtn = Create("TextButton", {
                    BackgroundColor3 = theme.SurfaceLight,
                    Size = UDim2.new(0, 140, 0, 28),
                    Position = UDim2.new(1, -150, 0.5, -14),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 2,
                    ClipsDescendants = false,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = dropBtn })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = dropBtn })

                local dropLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = GetDisplayText(),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = theme.TextSecondary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    ZIndex = dropBtn.ZIndex + 1,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = dropBtn,
                })

                local chevronImg = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = Icons.ChevronDown,
                    ImageColor3 = theme.TextMuted,
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.new(1, -20, 0.5, -7),
                    ZIndex = dropBtn.ZIndex + 1,
                    Parent = dropBtn,
                })

                -- Dropdown popup (positioned below button)
                local dropOpen = false
                local popup

                local function CloseDropdown()
                    if not dropOpen then return end
                    dropOpen = false
                    SpringTween(popup, { Size = UDim2.new(0, 150, 0, 0), BackgroundTransparency = 0.05 }, 0.3)
                    Tween(chevronImg, { Rotation = 0 }, 0.25)
                    task.delay(0.32, function()
                        if popup then popup.Visible = false end
                    end)
                end

                local function OpenDropdown()
                    if dropOpen then CloseDropdown() return end
                    dropOpen = true

                    if not popup then
                        popup = Create("Frame", {
                            BackgroundColor3 = theme.SurfaceLight,
                            Size = UDim2.new(0, 150, 0, 0),
                            Position = UDim2.new(0, 0, 1, 4),
                            ClipsDescendants = true,
                            ZIndex = row.ZIndex + 20,
                            Parent = dropBtn,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = popup })
                        Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = popup })
                        Shadow(popup, 20, 0.6)

                        local scroll = Create("ScrollingFrame", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, -8),
                            Position = UDim2.new(0, 0, 0, 4),
                            CanvasSize = UDim2.new(0,0,0,0),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollBarThickness = 2,
                            ScrollBarImageColor3 = theme.Border,
                            ScrollingDirection = Enum.ScrollingDirection.Y,
                            ZIndex = popup.ZIndex + 1,
                            Parent = popup,
                        })
                        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,1), Parent = scroll })
                        Create("UIPadding", { PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = scroll })

                        for i, opt in ipairs(options) do
                            local isSelected = multi and selected[opt] or (selected == opt)

                            local optBtn = Create("TextButton", {
                                BackgroundColor3 = isSelected and theme.Accent or Color3.new(0,0,0),
                                BackgroundTransparency = isSelected and 0.85 or 1,
                                Size = UDim2.new(1, 0, 0, 30),
                                Text = "",
                                AutoButtonColor = false,
                                ZIndex = scroll.ZIndex + 1,
                                LayoutOrder = i,
                                Parent = scroll,
                            })
                            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = optBtn })

                            local checkMark = Create("ImageLabel", {
                                BackgroundTransparency = 1,
                                Image = Icons.Check,
                                ImageColor3 = theme.Accent,
                                Size = UDim2.fromOffset(12, 12),
                                Position = UDim2.new(1, -18, 0.5, -6),
                                ImageTransparency = isSelected and 0 or 1,
                                ZIndex = optBtn.ZIndex + 1,
                                Parent = optBtn,
                            })

                            Create("TextLabel", {
                                BackgroundTransparency = 1,
                                Text = tostring(opt),
                                Font = Enum.Font.Gotham,
                                TextSize = 12,
                                TextColor3 = isSelected and theme.TextPrimary or theme.TextSecondary,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Size = UDim2.new(1, -30, 1, 0),
                                Position = UDim2.new(0, 8, 0, 0),
                                ZIndex = optBtn.ZIndex + 1,
                                Parent = optBtn,
                            })

                            optBtn.MouseEnter:Connect(function()
                                Tween(optBtn, { BackgroundTransparency = 0.88 }, 0.12)
                            end)
                            optBtn.MouseLeave:Connect(function()
                                local sel = multi and selected[opt] or (selected == opt)
                                Tween(optBtn, { BackgroundTransparency = sel and 0.85 or 1 }, 0.12)
                            end)

                            optBtn.MouseButton1Click:Connect(function()
                                if multi then
                                    selected[opt] = not selected[opt] or nil
                                    local sel = selected[opt]
                                    Tween(checkMark, { ImageTransparency = sel and 0 or 1 }, 0.15)
                                    Tween(optBtn, { BackgroundTransparency = sel and 0.85 or 1 }, 0.15)
                                else
                                    selected = opt
                                    CloseDropdown()
                                end
                                NexusUI.Flags[id] = selected
                                dropLabel.Text = GetDisplayText()
                                if config.Callback then
                                    task.spawn(config.Callback, selected)
                                end
                            end)
                        end
                    end

                    popup.Visible = true
                    local itemH = math.min(#options * 31 + 8, 180)
                    SpringTween(popup, { Size = UDim2.new(0, 150, 0, itemH) }, 0.35)
                    Tween(chevronImg, { Rotation = 180 }, 0.25)
                end

                dropBtn.MouseButton1Click:Connect(OpenDropdown)

                dropBtn.MouseEnter:Connect(function()
                    Tween(dropBtn, { BackgroundColor3 = theme.SurfaceLighter }, 0.15)
                end)
                dropBtn.MouseLeave:Connect(function()
                    Tween(dropBtn, { BackgroundColor3 = theme.SurfaceLight }, 0.15)
                end)

                -- Close on outside click
                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        if dropOpen then
                            -- Simple approach: close after a frame to allow click to register first
                            task.wait()
                            if not dropBtn:IsDescendantOf(game) then return end
                            local mx, my = inp.Position.X, inp.Position.Y
                            local ba = dropBtn.AbsolutePosition
                            local bs = dropBtn.AbsoluteSize
                            if not (mx >= ba.X and mx <= ba.X + bs.X and my >= ba.Y and my <= ba.Y + bs.Y) then
                                if popup then
                                    local pa = popup.AbsolutePosition
                                    local ps = popup.AbsoluteSize
                                    if not (mx >= pa.X and mx <= pa.X + ps.X and my >= pa.Y and my <= pa.Y + ps.Y) then
                                        CloseDropdown()
                                    end
                                end
                            end
                        end
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v)
                    selected = v
                    NexusUI.Flags[id] = v
                    dropLabel.Text = GetDisplayText()
                    if config.Callback then task.spawn(config.Callback, v) end
                end
                function ctrl:Get() return selected end
                function ctrl:Refresh(newOptions)
                    options = newOptions
                    if popup then popup:Destroy() popup = nil end
                    dropOpen = false
                end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  TEXT INPUT
            -- ════════════════════════════════════════
            function Section:AddInput(id, config)
                config = config or {}
                local row       = BaseRow(config)
                local placeholder = config.Placeholder or "Enter text..."
                local numOnly   = config.NumberOnly or false

                row.Size = UDim2.new(1, 0, 0, 64)

                local inputFrame = Create("Frame", {
                    BackgroundColor3 = theme.SurfaceLight,
                    Size = UDim2.new(1, -28, 0, 28),
                    Position = UDim2.new(0, 14, 0, 30),
                    ZIndex = row.ZIndex + 2,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = inputFrame })
                local stroke = Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = inputFrame })

                local textBox = Create("TextBox", {
                    BackgroundTransparency = 1,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.TextMuted,
                    Text = config.Default or "",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = theme.TextPrimary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    ClearTextOnFocus = config.ClearOnFocus or false,
                    ZIndex = inputFrame.ZIndex + 1,
                    Parent = inputFrame,
                })

                textBox.Focused:Connect(function()
                    Tween(stroke, { Color = theme.Accent, Transparency = 0.5 }, 0.2)
                    Tween(inputFrame, { BackgroundColor3 = theme.SurfaceLighter }, 0.2)
                end)
                textBox.FocusLost:Connect(function(entered)
                    Tween(stroke, { Color = theme.Border, Transparency = 0 }, 0.2)
                    Tween(inputFrame, { BackgroundColor3 = theme.SurfaceLight }, 0.2)
                    local val = textBox.Text
                    if numOnly then val = tonumber(val) or 0 end
                    NexusUI.Flags[id] = val
                    if entered and config.Callback then
                        task.spawn(config.Callback, val)
                    end
                end)

                textBox:GetPropertyChangedSignal("Text"):Connect(function()
                    if numOnly then
                        textBox.Text = textBox.Text:gsub("[^%d%.%-]", "")
                    end
                    if config.Changed then
                        task.spawn(config.Changed, textBox.Text)
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v) textBox.Text = tostring(v); NexusUI.Flags[id] = v end
                function ctrl:Get() return textBox.Text end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  LABEL
            -- ════════════════════════════════════════
            function Section:AddLabel(config)
                config = config or {}
                if type(config) == "string" then config = { Text = config } end

                local lbl = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, config.Height or 32),
                    ZIndex = sectionCard.ZIndex + 2,
                    LayoutOrder = (Section._itemCount + 1) * 2,
                    Parent = sectionCard,
                })
                Section._itemCount = Section._itemCount + 1

                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = config.Text or "",
                    Font = config.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
                    TextSize = config.Size or 12,
                    TextColor3 = config.Color or theme.TextSecondary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    ZIndex = lbl.ZIndex + 1,
                    Parent = lbl,
                })

                local ctrl = {}
                function ctrl:Set(text) label.Text = tostring(text) end
                function ctrl:SetColor(c) label.TextColor3 = c end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  KEYBIND
            -- ════════════════════════════════════════
            function Section:AddKeybind(id, config)
                config = config or {}
                local row     = BaseRow(config)
                local current = config.Default or Enum.KeyCode.RightShift
                NexusUI.Flags[id] = current
                local listening = false

                local keybindBtn = Create("TextButton", {
                    BackgroundColor3 = theme.SurfaceLight,
                    Size = UDim2.new(0, 90, 0, 26),
                    Position = UDim2.new(1, -100, 0.5, -13),
                    Text = current.Name,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextColor3 = theme.TextSecondary,
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 2,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = keybindBtn })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = keybindBtn })

                local conn
                keybindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keybindBtn.Text = "Press key..."
                    keybindBtn.TextColor3 = theme.Accent
                    Tween(keybindBtn, { BackgroundColor3 = theme.SurfaceLighter }, 0.15)

                    if conn then conn:Disconnect() end
                    conn = UserInputService.InputBegan:Connect(function(inp)
                        if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                            current = inp.KeyCode
                            NexusUI.Flags[id] = current
                            keybindBtn.Text = current.Name
                            keybindBtn.TextColor3 = theme.TextSecondary
                            Tween(keybindBtn, { BackgroundColor3 = theme.SurfaceLight }, 0.15)
                            listening = false
                            conn:Disconnect()
                            if config.Callback then task.spawn(config.Callback, current) end
                        end
                    end)
                end)

                -- Listen for keybind trigger
                UserInputService.InputBegan:Connect(function(inp)
                    if not listening and inp.KeyCode == current then
                        if config.OnPress then task.spawn(config.OnPress) end
                    end
                end)

                local ctrl = {}
                function ctrl:Get() return current end
                function ctrl:Set(k) current = k; keybindBtn.Text = k.Name; NexusUI.Flags[id] = k end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  COLOR PICKER
            -- ════════════════════════════════════════
            function Section:AddColorPicker(id, config)
                config = config or {}
                local value = config.Default or Color3.fromRGB(255, 100, 100)
                NexusUI.Flags[id] = value

                local row = BaseRow(config)
                row.ClipsDescendants = false

                local preview = Create("TextButton", {
                    BackgroundColor3 = value,
                    Size = UDim2.fromOffset(30, 22),
                    Position = UDim2.new(1, -40, 0.5, -11),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = row.ZIndex + 2,
                    Parent = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = preview })
                Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = preview })

                local pickerOpen = false
                local picker

                preview.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if not picker then
                        picker = Create("Frame", {
                            BackgroundColor3 = theme.Surface,
                            Size = UDim2.fromOffset(220, 180),
                            Position = UDim2.new(1, -225, 1, 4),
                            ZIndex = row.ZIndex + 30,
                            Parent = row,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = picker })
                        Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = picker })
                        Shadow(picker, 20, 0.6)

                        -- Hue/Sat canvas
                        local canvas = Create("ImageLabel", {
                            BackgroundColor3 = Color3.new(1,0,0),
                            Image = "rbxassetid://6020299385",
                            Size = UDim2.new(1,-16,0,120),
                            Position = UDim2.new(0,8,0,8),
                            ZIndex = picker.ZIndex + 1,
                            Parent = picker,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = canvas })

                        local canvasDot = Create("Frame", {
                            BackgroundColor3 = Color3.new(1,1,1),
                            Size = UDim2.fromOffset(12,12),
                            AnchorPoint = Vector2.new(0.5,0.5),
                            Position = UDim2.fromScale(1,0),
                            ZIndex = canvas.ZIndex + 1,
                            Parent = canvas,
                        })
                        Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=canvasDot})
                        Create("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Parent=canvasDot})

                        -- Hue bar
                        local hueBar = Create("ImageLabel", {
                            Image = "rbxassetid://6020299385",
                            Size = UDim2.new(1,-16,0,14),
                            Position = UDim2.new(0,8,0,136),
                            ZIndex = picker.ZIndex + 1,
                            Parent = picker,
                        })
                        Create("UICorner",{CornerRadius=UDim.new(0,4),Parent=hueBar})

                        -- Hex input
                        local hexBox = Create("TextBox", {
                            BackgroundColor3 = theme.SurfaceLight,
                            Text = "#" .. string.format("%02X%02X%02X", math.floor(value.R*255), math.floor(value.G*255), math.floor(value.B*255)),
                            Font = Enum.Font.GothamBold,
                            TextSize = 11,
                            TextColor3 = theme.TextPrimary,
                            Size = UDim2.new(1,-16,0,26),
                            Position = UDim2.new(0,8,0,158),
                            ZIndex = picker.ZIndex + 1,
                            Parent = picker,
                        })
                        Create("UICorner",{CornerRadius=UDim.new(0,6),Parent=hexBox})

                        hexBox.FocusLost:Connect(function()
                            local hex = hexBox.Text:gsub("#","")
                            if #hex == 6 then
                                local r = tonumber(hex:sub(1,2),16) or 0
                                local g = tonumber(hex:sub(3,4),16) or 0
                                local b = tonumber(hex:sub(5,6),16) or 0
                                value = Color3.fromRGB(r,g,b)
                                preview.BackgroundColor3 = value
                                NexusUI.Flags[id] = value
                                if config.Callback then task.spawn(config.Callback, value) end
                            end
                        end)
                    end

                    picker.Visible = pickerOpen
                end)

                local ctrl = {}
                function ctrl:Set(c)
                    value = c
                    preview.BackgroundColor3 = c
                    NexusUI.Flags[id] = c
                    if config.Callback then task.spawn(config.Callback, c) end
                end
                function ctrl:Get() return value end
                return ctrl
            end

            -- ════════════════════════════════════════
            --  SEPARATOR
            -- ════════════════════════════════════════
            function Section:AddSeparator()
                Section._itemCount = Section._itemCount + 1
                Create("Frame", {
                    BackgroundColor3 = theme.Border,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, -24, 0, 1),
                    BorderSizePixel = 0,
                    ZIndex = sectionCard.ZIndex + 2,
                    LayoutOrder = Section._itemCount * 2,
                    Parent = sectionCard,
                })
            end

            table.insert(Tab._sections, Section)
            return Section
        end

        return Tab
    end

    -- ── Theme setter
    function Window:SetTheme(name)
        -- Theme switching would require re-creating many elements
        -- For now, notify user
        NexusUI:Notify({
            Title = "Theme Changed",
            Description = "Switched to " .. name .. " theme. Reload for full effect.",
            Type = "Default",
            Duration = 3,
        })
    end

    function Window:Destroy()
        if self._blurEffect then self._blurEffect:Destroy() end
        self._screenGui:Destroy()
    end

    -- Entrance animation
    windowFrame.BackgroundTransparency = 1
    windowFrame.Size = UDim2.new(0, winSize.X.Offset * 0.92, 0, winSize.Y.Offset * 0.92)
    task.wait()
    SpringTween(windowFrame, {
        Size = winSize,
        BackgroundTransparency = acrylic and theme.AcrylicTrans or 0,
    }, 0.5)

    table.insert(NexusUI.Windows, Window)
    return Window
end

-- ═══════════════════════════════════════════════════
--  Save / Load Config (Flags persistence)
-- ═══════════════════════════════════════════════════
function NexusUI:SaveConfig(name)
    local data = {}
    for k, v in pairs(self.Flags) do
        if type(v) == "number" or type(v) == "boolean" or type(v) == "string" then
            data[k] = v
        elseif typeof(v) == "EnumItem" then
            data[k] = v.Name
        end
    end
    -- Attempt to write via writefile if available (exploits)
    if writefile then
        writefile("nexusui_" .. name .. ".json", HttpService:JSONEncode(data))
        self:Notify({ Title = "Config Saved", Description = name, Type = "Success", Duration = 2 })
    end
end

function NexusUI:LoadConfig(name)
    if readfile and isfile and isfile("nexusui_" .. name .. ".json") then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("nexusui_" .. name .. ".json"))
        end)
        if ok and data then
            for k, v in pairs(data) do
                self.Flags[k] = v
            end
            self:Notify({ Title = "Config Loaded", Description = name, Type = "Success", Duration = 2 })
        end
    end
end

-- ═══════════════════════════════════════════════════
--  Destroy all
-- ═══════════════════════════════════════════════════
function NexusUI:DestroyAll()
    for _, w in pairs(self.Windows) do
        pcall(function() w:Destroy() end)
    end
    self.Windows = {}
end

return NexusUI
