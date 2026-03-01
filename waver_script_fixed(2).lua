--[[
WAVER UI LIBRARY
A modular, customizable UI library for Roblox
--]]

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Theme Definitions
local Themes = {
    Midnight = {
        Background = Color3.fromRGB(25, 25, 30),
        TopBar = Color3.fromRGB(35, 35, 45),
        Sidebar = Color3.fromRGB(30, 30, 38),
        Content = Color3.fromRGB(28, 28, 35),
        Accent = Color3.fromRGB(88, 101, 242),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 190),
        Border = Color3.fromRGB(45, 45, 55),
        Button = Color3.fromRGB(40, 40, 50),
        ButtonHover = Color3.fromRGB(50, 50, 65),
        ToggleOn = Color3.fromRGB(88, 101, 242),
        ToggleOff = Color3.fromRGB(60, 60, 70),
        SliderBar = Color3.fromRGB(45, 45, 55),
        SliderFill = Color3.fromRGB(88, 101, 242),
        Dropdown = Color3.fromRGB(40, 40, 50),
        Input = Color3.fromRGB(35, 35, 45)
    },
    Pink = {
        Background = Color3.fromRGB(35, 25, 30),
        TopBar = Color3.fromRGB(45, 35, 40),
        Sidebar = Color3.fromRGB(40, 30, 35),
        Content = Color3.fromRGB(38, 28, 33),
        Accent = Color3.fromRGB(255, 105, 180),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(190, 180, 185),
        Border = Color3.fromRGB(55, 45, 50),
        Button = Color3.fromRGB(50, 40, 45),
        ButtonHover = Color3.fromRGB(65, 50, 58),
        ToggleOn = Color3.fromRGB(255, 105, 180),
        ToggleOff = Color3.fromRGB(70, 60, 65),
        SliderBar = Color3.fromRGB(55, 45, 50),
        SliderFill = Color3.fromRGB(255, 105, 180),
        Dropdown = Color3.fromRGB(50, 40, 45),
        Input = Color3.fromRGB(45, 35, 40)
    },
    Purple = {
        Background = Color3.fromRGB(28, 22, 35),
        TopBar = Color3.fromRGB(38, 30, 48),
        Sidebar = Color3.fromRGB(33, 26, 42),
        Content = Color3.fromRGB(31, 24, 40),
        Accent = Color3.fromRGB(147, 88, 242),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(185, 180, 195),
        Border = Color3.fromRGB(48, 40, 58),
        Button = Color3.fromRGB(42, 34, 52),
        ButtonHover = Color3.fromRGB(55, 45, 68),
        ToggleOn = Color3.fromRGB(147, 88, 242),
        ToggleOff = Color3.fromRGB(65, 58, 75),
        SliderBar = Color3.fromRGB(48, 40, 58),
        SliderFill = Color3.fromRGB(147, 88, 242),
        Dropdown = Color3.fromRGB(42, 34, 52),
        Input = Color3.fromRGB(38, 30, 48)
    },
    Ocean = {
        Background = Color3.fromRGB(22, 30, 35),
        TopBar = Color3.fromRGB(30, 42, 48),
        Sidebar = Color3.fromRGB(26, 36, 42),
        Content = Color3.fromRGB(24, 34, 40),
        Accent = Color3.fromRGB(0, 170, 204),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 190, 195),
        Border = Color3.fromRGB(40, 52, 58),
        Button = Color3.fromRGB(34, 46, 52),
        ButtonHover = Color3.fromRGB(45, 60, 68),
        ToggleOn = Color3.fromRGB(0, 170, 204),
        ToggleOff = Color3.fromRGB(58, 68, 75),
        SliderBar = Color3.fromRGB(40, 52, 58),
        SliderFill = Color3.fromRGB(0, 170, 204),
        Dropdown = Color3.fromRGB(34, 46, 52),
        Input = Color3.fromRGB(30, 42, 48)
    },
    Forest = {
        Background = Color3.fromRGB(25, 35, 28),
        TopBar = Color3.fromRGB(35, 48, 38),
        Sidebar = Color3.fromRGB(30, 42, 33),
        Content = Color3.fromRGB(28, 40, 31),
        Accent = Color3.fromRGB(76, 175, 80),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 195, 185),
        Border = Color3.fromRGB(45, 58, 48),
        Button = Color3.fromRGB(40, 52, 42),
        ButtonHover = Color3.fromRGB(50, 68, 55),
        ToggleOn = Color3.fromRGB(76, 175, 80),
        ToggleOff = Color3.fromRGB(60, 75, 62),
        SliderBar = Color3.fromRGB(45, 58, 48),
        SliderFill = Color3.fromRGB(76, 175, 80),
        Dropdown = Color3.fromRGB(40, 52, 42),
        Input = Color3.fromRGB(35, 48, 38)
    },
    Crimson = {
        Background = Color3.fromRGB(35, 25, 25),
        TopBar = Color3.fromRGB(48, 35, 35),
        Sidebar = Color3.fromRGB(42, 30, 30),
        Content = Color3.fromRGB(40, 28, 28),
        Accent = Color3.fromRGB(220, 53, 69),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(195, 180, 180),
        Border = Color3.fromRGB(58, 45, 45),
        Button = Color3.fromRGB(52, 40, 40),
        ButtonHover = Color3.fromRGB(68, 50, 50),
        ToggleOn = Color3.fromRGB(220, 53, 69),
        ToggleOff = Color3.fromRGB(75, 60, 60),
        SliderBar = Color3.fromRGB(58, 45, 45),
        SliderFill = Color3.fromRGB(220, 53, 69),
        Dropdown = Color3.fromRGB(52, 40, 40),
        Input = Color3.fromRGB(48, 35, 35)
    }
}

local Library = {
    _config = {
        FolderName = "WAVER",
        FileName = "config.json"
    },
    _themed_elements = {
        Modules = {},
        Strokes = {},
        ActiveToggles = {},
        SliderDrags = {},
        Dropdowns = {},
        Buttons = {},
        Inputs = {}
    }
}

Library.__index = Library

-- Utility Functions
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function Tween(obj, props, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easingStyle, easingDirection), props)
    tween:Play()
    return tween
end

-- Theme System
function Library.apply_theme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    
    Library._current_theme = themeName
    
    for _, module in ipairs(Library._themed_elements.Modules) do
        if module and module.Background then
            Tween(module.Background, {BackgroundColor3 = theme.Background}, 0.2)
        end
        if module and module.TopBar then
            Tween(module.TopBar, {BackgroundColor3 = theme.TopBar}, 0.2)
        end
        if module and module.Sidebar then
            Tween(module.Sidebar, {BackgroundColor3 = theme.Sidebar}, 0.2)
        end
        if module and module.Content then
            Tween(module.Content, {BackgroundColor3 = theme.Content}, 0.2)
        end
    end
    
    for _, stroke in ipairs(Library._themed_elements.Strokes) do
        if stroke then
            Tween(stroke, {Color = theme.Border}, 0.2)
        end
    end
    
    for _, toggle in ipairs(Library._themed_elements.ActiveToggles) do
        if toggle and toggle.Indicator then
            local targetColor = toggle.State and theme.ToggleOn or theme.ToggleOff
            Tween(toggle.Indicator, {BackgroundColor3 = targetColor}, 0.2)
        end
    end
    
    for _, slider in ipairs(Library._themed_elements.SliderDrags) do
        if slider then
            Tween(slider, {BackgroundColor3 = theme.SliderFill}, 0.2)
        end
    end
    
    for _, btn in ipairs(Library._themed_elements.Buttons) do
        if btn then
            Tween(btn, {BackgroundColor3 = theme.Button}, 0.2)
        end
    end
    
    for _, input in ipairs(Library._themed_elements.Inputs) do
        if input then
            Tween(input, {BackgroundColor3 = theme.Input}, 0.2)
        end
    end
end

-- Config System
function Library:SaveConfig(data)
    local folder = self._config.FolderName
    local file = self._config.FileName
    
    if not isfolder(folder) then
        makefolder(folder)
    end
    
    data.Theme = Library._current_theme or "Midnight"
    writefile(folder .. "/" .. file, HttpService:JSONEncode(data))
end

function Library:LoadConfig()
    local folder = self._config.FolderName
    local file = self._config.FileName
    
    if isfile(folder .. "/" .. file) then
        local data = HttpService:JSONDecode(readfile(folder .. "/" .. file))
        return data
    end
    return {}
end

-- Library Constructor
function Library.new(title)
    local self = setmetatable({}, Library)
    
    self.Title = title or "WAVER"
    self.Tabs = {}
    self.ActiveTab = nil
    self.ConfigData = {}
    
    -- Load saved config
    self.ConfigData = self:LoadConfig()
    local savedTheme = self.ConfigData.Theme or "Midnight"
    Library._current_theme = savedTheme
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "WAVER_" .. tostring(math.random(1000, 9999))
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    -- Create Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 700, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    self.MainFrame.BackgroundColor3 = Themes[Library._current_theme].Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = self.MainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Themes[Library._current_theme].Border
    mainStroke.Thickness = 1
    mainStroke.Parent = self.MainFrame
    table.insert(Library._themed_elements.Strokes, mainStroke)
    
    -- Top Bar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 40)
    self.TopBar.BackgroundColor3 = Themes[Library._current_theme].TopBar
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.MainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = self.TopBar
    
    -- Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Themes[Library._current_theme].Text
    self.TitleLabel.TextSize = 18
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TopBar
    
    -- Close Button
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Name = "Close"
    self.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    self.CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    self.CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    self.CloseBtn.Text = "X"
    self.CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseBtn.TextSize = 14
    self.CloseBtn.Font = Enum.Font.GothamBold
    self.CloseBtn.Parent = self.TopBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = self.CloseBtn
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    self.MinBtn = Instance.new("TextButton")
    self.MinBtn.Name = "Minimize"
    self.MinBtn.Size = UDim2.new(0, 30, 0, 30)
    self.MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
    self.MinBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    self.MinBtn.Text = "-"
    self.MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    self.MinBtn.TextSize = 18
    self.MinBtn.Font = Enum.Font.GothamBold
    self.MinBtn.Parent = self.TopBar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = self.MinBtn
    
    self.Minimized = false
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            Tween(self.MainFrame, {Size = UDim2.new(0, 700, 0, 40)}, 0.3)
            self.MinBtn.Text = "+"
        else
            Tween(self.MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.3)
            self.MinBtn.Text = "-"
        end
    end)
    
    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 150, 1, -40)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 40)
    self.Sidebar.BackgroundColor3 = Themes[Library._current_theme].Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainFrame
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 5)
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = self.Sidebar
    
    -- Content Area
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -150, 1, -40)
    self.Content.Position = UDim2.new(0, 150, 0, 40)
    self.Content.BackgroundColor3 = Themes[Library._current_theme].Content
    self.Content.BorderSizePixel = 0
    self.Content.ClipsDescendants = true
    self.Content.Parent = self.MainFrame
    
    -- Make draggable
    MakeDraggable(self.MainFrame, self.TopBar)
    
    return self
end

-- Create Tab
function Library:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Modules = {}
    
    -- Tab Button
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name .. "Tab"
    tab.Button.Size = UDim2.new(1, 0, 0, 35)
    tab.Button.BackgroundColor3 = Themes[Library._current_theme].Button
    tab.Button.Text = name
    tab.Button.TextColor3 = Themes[Library._current_theme].Text
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.GothamSemibold
    tab.Button.Parent = self.Sidebar
    table.insert(Library._themed_elements.Buttons, tab.Button)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tab.Button
    
    -- Tab Content
    tab.Frame = Instance.new("ScrollingFrame")
    tab.Frame.Name = name .. "Content"
    tab.Frame.Size = UDim2.new(1, 0, 1, 0)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.ScrollBarThickness = 4
    tab.Frame.ScrollBarImageColor3 = Themes[Library._current_theme].Accent
    tab.Frame.Visible = false
    tab.Frame.Parent = self.Content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = tab.Frame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.Parent = tab.Frame
    
    -- Tab Switch Logic
    tab.Button.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.Frame.Visible = false
            Tween(self.ActiveTab.Button, {BackgroundColor3 = Themes[Library._current_theme].Button}, 0.2)
        end
        
        tab.Frame.Visible = true
        Tween(tab.Button, {BackgroundColor3 = Themes[Library._current_theme].Accent}, 0.2)
        self.ActiveTab = tab
    end)
    
    -- Auto-select first tab
    if not self.ActiveTab then
        tab.Frame.Visible = true
        Tween(tab.Button, {BackgroundColor3 = Themes[Library._current_theme].Accent}, 0)
        self.ActiveTab = tab
    end
    
    table.insert(self.Tabs, tab)
    
    -- Module Creator
    function tab:CreateModule(name)
        local module = {}
        module.Name = name
        module.Options = {}
        
        -- Module Frame
        module.Frame = Instance.new("Frame")
        module.Frame.Name = name .. "Module"
        module.Frame.Size = UDim2.new(1, 0, 0, 40)
        module.Frame.BackgroundColor3 = Themes[Library._current_theme].Button
        module.Frame.BorderSizePixel = 0
        module.Frame.Parent = tab.Frame
        
        local moduleCorner = Instance.new("UICorner")
        moduleCorner.CornerRadius = UDim.new(0, 6)
        moduleCorner.Parent = module.Frame
        
        -- Module Header
        module.Header = Instance.new("TextButton")
        module.Header.Name = "Header"
        module.Header.Size = UDim2.new(1, 0, 0, 40)
        module.Header.BackgroundTransparency = 1
        module.Header.Text = name
        module.Header.TextColor3 = Themes[Library._current_theme].Text
        module.Header.TextSize = 14
        module.Header.Font = Enum.Font.GothamSemibold
        module.Header.Parent = module.Frame
        
        -- Expand Icon
        module.ExpandIcon = Instance.new("TextLabel")
        module.ExpandIcon.Name = "Icon"
        module.ExpandIcon.Size = UDim2.new(0, 20, 0, 20)
        module.ExpandIcon.Position = UDim2.new(1, -25, 0.5, -10)
        module.ExpandIcon.BackgroundTransparency = 1
        module.ExpandIcon.Text = "▼"
        module.ExpandIcon.TextColor3 = Themes[Library._current_theme].SubText
        module.ExpandIcon.TextSize = 12
        module.ExpandIcon.Parent = module.Header
        
        -- Options Container
        module.OptionsContainer = Instance.new("Frame")
        module.OptionsContainer.Name = "Options"
        module.OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
        module.OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
        module.OptionsContainer.BackgroundTransparency = 1
        module.OptionsContainer.ClipsDescendants = true
        module.OptionsContainer.Parent = module.Frame
        
        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Padding = UDim.new(0, 8)
        optionsLayout.Parent = module.OptionsContainer
        
        local optionsPadding = Instance.new("UIPadding")
        optionsPadding.PaddingTop = UDim.new(0, 5)
        optionsPadding.PaddingLeft = UDim.new(0, 10)
        optionsPadding.PaddingRight = UDim.new(0, 10)
        optionsPadding.PaddingBottom = UDim.new(0, 10)
        optionsPadding.Parent = module.OptionsContainer
        
        module.Expanded = false
        
        module.Header.MouseButton1Click:Connect(function()
            module.Expanded = not module.Expanded
            
            if module.Expanded then
                local contentHeight = optionsLayout.AbsoluteContentSize.Y + 20
                Tween(module.Frame, {Size = UDim2.new(1, 0, 0, 40 + contentHeight)}, 0.3)
                Tween(module.OptionsContainer, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.3)
                module.ExpandIcon.Text = "▲"
            else
                Tween(module.Frame, {Size = UDim2.new(1, 0, 0, 40)}, 0.3)
                Tween(module.OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                module.ExpandIcon.Text = "▼"
            end
        end)
        
        -- Track module for theme changes
        table.insert(Library._themed_elements.Modules, module)
        
        -- Option Creators
        function module:CreateToggle(text, default, callback)
            local toggle = {}
            toggle.State = default or false
            toggle.Callback = callback or function() end
            
            local frame = Instance.new("Frame")
            frame.Name = text .. "Toggle"
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = module.OptionsContainer
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -60, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Themes[Library._current_theme].Text
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local btn = Instance.new("TextButton")
            btn.Name = "Toggle"
            btn.Size = UDim2.new(0, 50, 0, 24)
            btn.Position = UDim2.new(1, -50, 0.5, -12)
            btn.BackgroundColor3 = toggle.State and Themes[Library._current_theme].ToggleOn or Themes[Library._current_theme].ToggleOff
            btn.Text = ""
            btn.Parent = frame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 12)
            btnCorner.Parent = btn
            
            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(0, 18, 0, 18)
            indicator.Position = toggle.State and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            indicator.BorderSizePixel = 0
            indicator.Parent = btn
            
            local indCorner = Instance.new("UICorner")
            indCorner.CornerRadius = UDim.new(1, 0)
            indCorner.Parent = indicator
            
            toggle.Indicator = btn
            table.insert(Library._themed_elements.ActiveToggles, toggle)
            
            btn.MouseButton1Click:Connect(function()
                toggle.State = not toggle.State
                Tween(indicator, {Position = toggle.State and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.2)
                Tween(btn, {BackgroundColor3 = toggle.State and Themes[Library._current_theme].ToggleOn or Themes[Library._current_theme].ToggleOff}, 0.2)
                toggle.Callback(toggle.State)
            end)
            
            if default then
                toggle.Callback(default)
            end
            
            return toggle
        end
        
        function module:CreateSlider(text, min, max, default, callback)
            local slider = {}
            slider.Min = min or 0
            slider.Max = max or 100
            slider.Value = default or min
            slider.Callback = callback or function() end
            
            local frame = Instance.new("Frame")
            frame.Name = text .. "Slider"
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundTransparency = 1
            frame.Parent = module.OptionsContainer
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0.7, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Themes[Library._current_theme].Text
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "Value"
            valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(slider.Value)
            valueLabel.TextColor3 = Themes[Library._current_theme].SubText
            valueLabel.TextSize = 13
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = frame
            
            local bar = Instance.new("Frame")
            bar.Name = "Bar"
            bar.Size = UDim2.new(1, 0, 0, 8)
            bar.Position = UDim2.new(0, 0, 0, 32)
            bar.BackgroundColor3 = Themes[Library._current_theme].SliderBar
            bar.BorderSizePixel = 0
            bar.Parent = frame
            
            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(0, 4)
            barCorner.Parent = bar
            
            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0)
            fill.BackgroundColor3 = Themes[Library._current_theme].SliderFill
            fill.BorderSizePixel = 0
            fill.Parent = bar
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 4)
            fillCorner.Parent = fill
            
            table.insert(Library._themed_elements.SliderDrags, fill)
            
            local dragging = false
            
            local function update(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                slider.Value = math.floor(slider.Min + (pos * (slider.Max - slider.Min)))
                fill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(slider.Value)
                slider.Callback(slider.Value)
            end
            
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input)
                end
            end)
            
            bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            
            return slider
        end
        
        function module:CreateDropdown(text, options, callback)
            local dropdown = {}
            dropdown.Options = options or {}
            dropdown.Callback = callback or function() end
            dropdown.Open = false
            
            local frame = Instance.new("Frame")
            frame.Name = text .. "Dropdown"
            frame.Size = UDim2.new(1, 0, 0, 35)
            frame.BackgroundTransparency = 1
            frame.Parent = module.OptionsContainer
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Themes[Library._current_theme].Text
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local btn = Instance.new("TextButton")
            btn.Name = "Button"
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.Position = UDim2.new(0, 0, 0, 20)
            btn.BackgroundColor3 = Themes[Library._current_theme].Dropdown
            btn.Text = options[1] or "Select..."
            btn.TextColor3 = Themes[Library._current_theme].Text
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.Parent = frame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            
            local icon = Instance.new("TextLabel")
            icon.Name = "Icon"
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(1, -22, 0.5, -10)
            icon.BackgroundTransparency = 1
            icon.Text = "▼"
            icon.TextColor3 = Themes[Library._current_theme].SubText
            icon.TextSize = 10
            icon.Parent = btn
            
            local list = Instance.new("Frame")
            list.Name = "List"
            list.Size = UDim2.new(1, 0, 0, 0)
            list.Position = UDim2.new(0, 0, 1, 5)
            list.BackgroundColor3 = Themes[Library._current_theme].Dropdown
            list.BorderSizePixel = 0
            list.ClipsDescendants = true
            list.ZIndex = 10
            list.Visible = false
            list.Parent = btn
            
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 4)
            listCorner.Parent = list
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = list
            
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Name = opt
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = opt
                optBtn.TextColor3 = Themes[Library._current_theme].Text
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.ZIndex = 10
                optBtn.Parent = list
                
                optBtn.MouseButton1Click:Connect(function()
                    btn.Text = opt
                    dropdown.Callback(opt)
                    Tween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    dropdown.Open = false
                    icon.Text = "▼"
                    list.Visible = false
                end)
            end
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Open = not dropdown.Open
                if dropdown.Open then
                    list.Visible = true
                    local height = math.min(#options * 25, 150)
                    Tween(list, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
                    icon.Text = "▲"
                else
                    Tween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    icon.Text = "▼"
                    task.delay(0.2, function()
                        list.Visible = false
                    end)
                end
            end)
            
            return dropdown
        end
        
        function module:CreateButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Name = text .. "Button"
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Themes[Library._current_theme].Accent
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 13
            btn.Font = Enum.Font.GothamSemibold
            btn.Parent = module.OptionsContainer
            table.insert(Library._themed_elements.Buttons, btn)
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Themes[Library._current_theme].ButtonHover}, 0.2)
            end)
            
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Themes[Library._current_theme].Accent}, 0.2)
            end)
            
            return btn
        end
        
        function module:CreateInput(text, placeholder, callback)
            local frame = Instance.new("Frame")
            frame.Name = text .. "Input"
            frame.Size = UDim2.new(1, 0, 0, 55)
            frame.BackgroundTransparency = 1
            frame.Parent = module.OptionsContainer
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Themes[Library._current_theme].Text
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local input = Instance.new("TextBox")
            input.Name = "Input"
            input.Size = UDim2.new(1, 0, 0, 30)
            input.Position = UDim2.new(0, 0, 0, 22)
            input.BackgroundColor3 = Themes[Library._current_theme].Input
            input.Text = ""
            input.PlaceholderText = placeholder or "Enter text..."
            input.TextColor3 = Themes[Library._current_theme].Text
            input.PlaceholderColor3 = Themes[Library._current_theme].SubText
            input.TextSize = 12
            input.Font = Enum.Font.Gotham
            input.ClearTextOnFocus = false
            input.Parent = frame
            table.insert(Library._themed_elements.Inputs, input)
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 4)
            inputCorner.Parent = input
            
            input.FocusLost:Connect(function()
                if callback then
                    callback(input.Text)
                end
            end)
            
            return input
        end
        
        return module
    end
    
    return tab
end

-- Theme Dropdown Creator
function Library:CreateThemeDropdown(parentModule, text)
    local themeOptions = {}
    for name, _ in pairs(Themes) do
        table.insert(themeOptions, name)
    end
    
    local dropdown = parentModule:CreateDropdown(text or "Theme", themeOptions, function(selected)
        Library.apply_theme(selected)
        self:SaveConfig({Theme = selected})
    end)
    
    return dropdown
end

-- Initialize Library
local Waver = Library.new("WAVER UI")

-- Player Tab
local PlayerTab = Waver:CreateTab("Player")

-- Teleport Module
local TeleportModule = PlayerTab:CreateModule("Teleport")

TeleportModule:CreateToggle("Tp to All Players", false, function(state)
    _G.TpToAll = state
    task.spawn(function()
        while _G.TpToAll do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        -- Check if player is in game
                        local inGame = false
                        if player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("InGame") then
                            inGame = player.PlayerData.InGame.Value
                        end
                        
                        if inGame then
                            local targetChar = player.Character
                            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

TeleportModule:CreateToggle("Tp Away from It", false, function(state)
    _G.TpAway = state
    task.spawn(function()
        while _G.TpAway do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local targetChar = player.Character
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            local distance = (char.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Magnitude
                            if distance < 50 then
                                local awayCFrame = CFrame.new(char.HumanoidRootPart.Position + (char.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Unit * 100)
                                char.HumanoidRootPart.CFrame = awayCFrame
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Auto Collect Module
local AutoCollectModule = PlayerTab:CreateModule("Auto Collect")

AutoCollectModule:CreateToggle("Auto Collect Coins", false, function(state)
    _G.AutoCoins = state
    task.spawn(function()
        while _G.AutoCoins do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                        local name = obj.Name:lower()
                        if name:find("credit") or name:find("coin") then
                            if _G.CoinMode == "T2C" then
                                char.HumanoidRootPart.CFrame = obj.CFrame
                            else
                                obj.CFrame = char.HumanoidRootPart.CFrame
                            end
                            task.wait(0.1)
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end)

AutoCollectModule:CreateDropdown("Collection Mode", {"T2C", "C2P"}, function(selected)
    _G.CoinMode = selected
end)

-- Game Tab
local GameTab = Waver:CreateTab("Game")

-- Auto Hide Module
local AutoHideModule = GameTab:CreateModule("Auto Hide")

AutoHideModule:CreateToggle("Auto Hide", false, function(state)
    _G.AutoHide = state
    task.spawn(function()
        while _G.AutoHide do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, spot in ipairs(Workspace:GetDescendants()) do
                    if spot:IsA("BasePart") and spot.Name:lower():find("hidespot") then
                        char.HumanoidRootPart.CFrame = spot.CFrame
                        break
                    end
                end
            end
            task.wait(5)
        end
    end)
end)

-- Highlight Module
local HighlightModule = GameTab:CreateModule("Player Highlight")

HighlightModule:CreateToggle("Highlight Players", false, function(state)
    _G.HighlightPlayers = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "WaverHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = char
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char and char:FindFirstChild("WaverHighlight") then
                char.WaverHighlight:Destroy()
            end
        end
    end
end)

-- Orbit Module
local OrbitModule = GameTab:CreateModule("Orbit Around It")

OrbitModule:CreateToggle("Orbit Mode", false, function(state)
    _G.OrbitMode = state
    task.spawn(function()
        local angle = 0
        while _G.OrbitMode do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local targetChar = player.Character
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            angle = angle + 0.05
                            local radius = 20
                            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                            char.HumanoidRootPart.CFrame = CFrame.new(targetChar.HumanoidRootPart.Position + offset, targetChar.HumanoidRootPart.Position)
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- Face It Module
local FaceItModule = GameTab:CreateModule("Face It")

FaceItModule:CreateToggle("Always Face It", false, function(state)
    _G.FaceIt = state
    task.spawn(function()
        while _G.FaceIt do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local targetChar = player.Character
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, targetChar.HumanoidRootPart.Position)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Settings Tab
local SettingsTab = Waver:CreateTab("Settings")

-- Theme Module
local ThemeModule = SettingsTab:CreateModule("Theme Settings")

ThemeModule:CreateDropdown("Select Theme", {"Midnight", "Pink", "Purple", "Ocean", "Forest", "Crimson"}, function(selected)
    Library.apply_theme(selected)
    Waver:SaveConfig({Theme = selected})
end)

-- Config Module
local ConfigModule = SettingsTab:CreateModule("Configuration")

ConfigModule:CreateButton("Save Config", function()
    Waver:SaveConfig({Theme = Library._current_theme or "Midnight"})
    print("Config Saved!")
end)

ConfigModule:CreateButton("Load Config", function()
    local config = Waver:LoadConfig()
    if config.Theme then
        Library.apply_theme(config.Theme)
    end
    print("Config Loaded!")
end)

print("WAVER UI Library Loaded Successfully!")
