local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local GUI_NAME = "UltraLuxuryHub_UI"

if CoreGui:FindFirstChild(GUI_NAME) then
	CoreGui[GUI_NAME]:Destroy()
end
if gethui and gethui():FindFirstChild(GUI_NAME) then
	gethui()[GUI_NAME]:Destroy()
end

local Library = {
	Flags = {},
	ActiveToggles = {},
	CurrentTheme = "Dark",
	Themes = {
		Dark = {
			Background = Color3.fromRGB(13, 15, 23),
			Topbar = Color3.fromRGB(18, 20, 31),
			Sidebar = Color3.fromRGB(15, 17, 26),
			Container = Color3.fromRGB(22, 25, 38),
			Element = Color3.fromRGB(28, 32, 48),
			Accent = Color3.fromRGB(168, 85, 247),
			AccentGlow = Color3.fromRGB(192, 132, 252),
			Text = Color3.fromRGB(245, 245, 250),
			SubText = Color3.fromRGB(140, 145, 170),
			Border = Color3.fromRGB(45, 50, 75),
			Hover = Color3.fromRGB(35, 40, 60)
		},
		Midnight = {
			Background = Color3.fromRGB(8, 8, 14),
			Topbar = Color3.fromRGB(12, 12, 20),
			Sidebar = Color3.fromRGB(10, 10, 17),
			Container = Color3.fromRGB(15, 16, 26),
			Element = Color3.fromRGB(20, 22, 36),
			Accent = Color3.fromRGB(59, 130, 246),
			AccentGlow = Color3.fromRGB(96, 165, 250),
			Text = Color3.fromRGB(240, 245, 255),
			SubText = Color3.fromRGB(120, 130, 160),
			Border = Color3.fromRGB(30, 35, 60),
			Hover = Color3.fromRGB(25, 28, 45)
		},
		Crimson = {
			Background = Color3.fromRGB(16, 10, 12),
			Topbar = Color3.fromRGB(24, 14, 17),
			Sidebar = Color3.fromRGB(20, 12, 14),
			Container = Color3.fromRGB(30, 18, 22),
			Element = Color3.fromRGB(40, 22, 28),
			Accent = Color3.fromRGB(239, 68, 68),
			AccentGlow = Color3.fromRGB(248, 113, 113),
			Text = Color3.fromRGB(255, 240, 242),
			SubText = Color3.fromRGB(170, 130, 135),
			Border = Color3.fromRGB(65, 30, 38),
			Hover = Color3.fromRGB(50, 24, 30)
		},
		Emerald = {
			Background = Color3.fromRGB(9, 15, 13),
			Topbar = Color3.fromRGB(13, 22, 19),
			Sidebar = Color3.fromRGB(11, 18, 16),
			Container = Color3.fromRGB(17, 28, 24),
			Element = Color3.fromRGB(22, 36, 30),
			Accent = Color3.fromRGB(16, 185, 129),
			AccentGlow = Color3.fromRGB(52, 211, 153),
			Text = Color3.fromRGB(240, 253, 248),
			SubText = Color3.fromRGB(130, 165, 150),
			Border = Color3.fromRGB(35, 60, 50),
			Hover = Color3.fromRGB(28, 45, 38)
		}
	}
}

local Icons = nil
pcall(function()
	Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function GetIcon(name)
	if not Icons or type(name) ~= "string" then return nil end
	name = string.lower(name):gsub("^%s*(.-)%s*$", "%1")
	local iconData = Icons["48px"] and Icons["48px"][name]
	if iconData then
		return {
			Id = "rbxassetid://" .. tostring(iconData[1]),
			RectSize = Vector2.new(iconData[2][1], iconData[2][2]),
			RectOffset = Vector2.new(iconData[3][1], iconData[3][2])
		}
	end
	return nil
end

local function ApplyIcon(imgLabel, icon)
	if type(icon) == "string" then
		local data = GetIcon(icon)
		if data then
			imgLabel.Image = data.Id
			imgLabel.ImageRectSize = data.RectSize
			imgLabel.ImageRectOffset = data.RectOffset
			imgLabel.Visible = true
		else
			imgLabel.Visible = false
		end
	elseif type(icon) == "number" and icon > 0 then
		imgLabel.Image = "rbxassetid://" .. tostring(icon)
		imgLabel.ImageRectSize = Vector2.zero
		imgLabel.ImageRectOffset = Vector2.zero
		imgLabel.Visible = true
	else
		imgLabel.Visible = false
	end
end

local function Corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Library.Themes[Library.CurrentTheme].Border
	s.Thickness = thickness or 1.2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function MakeDraggable(gui, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			TweenService:Create(gui, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}):Play()
		end
	end)
end

function Library:CreateWindow(Settings)
	Settings = Settings or {}
	local WindowName = Settings.Name or "Modern Hub"
	local WindowIcon = Settings.Icon
	local CurrentToggleKey = Settings.ToggleUIKeybind or "K"

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = GUI_NAME
	ScreenGui.ResetOnSpawn = false
	
	if gethui then
		ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	else
		ScreenGui.Parent = CoreGui
	end

	local Main = Instance.new("Frame")
	Main.Name = "MainFrame"
	Main.Size = UDim2.new(0, 640, 0, 440)
	Main.Position = UDim2.new(0.5, -320, 0.5, -220)
	Main.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui

	Corner(Main, 14)
	local MainStroke = Stroke(Main, Library.Themes[Library.CurrentTheme].Border, 1.5)

	local GlowBg = Instance.new("ImageLabel")
	GlowBg.Name = "Glow"
	GlowBg.Size = UDim2.new(1, 0, 1, 0)
	GlowBg.Position = UDim2.new(0, -30, 0, -30)
	GlowBg.BackgroundTransparency = 1
	GlowBg.ImageColor3 = Library.Themes[Library.CurrentTheme].Accent
	GlowBg.ImageTransparency = 0.8
	GlowBg.Parent = Main

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 50)
	Topbar.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Main

	Corner(Topbar, 14)
	Topbar.WaitForChild("UICorner").BottomLeftRadius = UDim2.new(0, 0)
	Topbar.WaitForChild("UICorner").BottomRightRadius = UDim2.new(0, 0)
	MakeDraggable(Main, Topbar)

	local GlowLine = Instance.new("Frame")
	GlowLine.Size = UDim2.new(1, 0, 0, 1)
	GlowLine.Position = UDim2.new(0, 0, 1, -1)
	GlowLine.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent
	GlowLine.BorderSizePixel = 0
	GlowLine.Parent = Topbar

	local TopbarIcon = Instance.new("ImageLabel")
	TopbarIcon.Size = UDim2.new(0, 22, 0, 22)
	TopbarIcon.Position = UDim2.new(0, 16, 0.5, -11)
	TopbarIcon.BackgroundTransparency = 1
	TopbarIcon.ImageColor3 = Library.Themes[Library.CurrentTheme].Accent
	TopbarIcon.Parent = Topbar
	ApplyIcon(TopbarIcon, WindowIcon)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -100, 1, 0)
	Title.Position = UDim2.new(0, TopbarIcon.Visible and 46 or 16, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = WindowName
	Title.TextColor3 = Library.Themes[Library.CurrentTheme].Text
	Title.TextSize = 15
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Topbar

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "CloseButton"
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
	CloseBtn.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Library.Themes[Library.CurrentTheme].SubText
	CloseBtn.TextSize = 22
	CloseBtn.Font = Enum.Font.GothamMedium
	CloseBtn.AutoButtonColor = false
	CloseBtn.Parent = Topbar
	Corner(CloseBtn, 8)
	local CloseStroke = Stroke(CloseBtn, Library.Themes[Library.CurrentTheme].Border, 1)

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 170, 1, -50)
	Sidebar.Position = UDim2.new(0, 0, 0, 50)
	Sidebar.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	local SidebarUiCorner = Instance.new("UICorner")
	SidebarUiCorner.CornerRadius = UDim2.new(0, 0)
	SidebarUiCorner.BottomLeftRadius = UDim2.new(0, 14)
	SidebarUiCorner.Parent = Sidebar

	local TabHolder = Instance.new("ScrollingFrame")
	TabHolder.Size = UDim2.new(1, -12, 1, -60)
	TabHolder.Position = UDim2.new(0, 6, 0, 8)
	TabHolder.BackgroundTransparency = 1
	TabHolder.ScrollBarThickness = 2
	TabHolder.ScrollBarImageColor3 = Library.Themes[Library.CurrentTheme].Accent
	TabHolder.Parent = Sidebar

	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 6)
	TabList.Parent = TabHolder

	local SystemTabHolder = Instance.new("Frame")
	SystemTabHolder.Size = UDim2.new(1, -12, 0, 42)
	SystemTabHolder.Position = UDim2.new(0, 6, 1, -48)
	SystemTabHolder.BackgroundTransparency = 1
	SystemTabHolder.Parent = Sidebar

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -182, 1, -62)
	ContentContainer.Position = UDim2.new(0, 176, 0, 56)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = Main

	local Tabs = {}
	local FirstTab = true
	local IsOpen = true
	local IsAnimating = false

	local function ToggleUI()
		if IsAnimating then return end
		IsAnimating = true

		if IsOpen then
			TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 640, 0, 0),
				Position = UDim2.new(0.5, -320, 0.5, 0)
			}):Play()
			task.wait(0.3)
			Main.Visible = false
			IsOpen = false
		else
			Main.Visible = true
			TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 640, 0, 440),
				Position = UDim2.new(0.5, -320, 0.5, -220)
			}):Play()
			task.wait(0.4)
			IsOpen = true
		end
		IsAnimating = false
	end

	CloseBtn.MouseButton1Click:Connect(ToggleUI)

	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(239, 68, 68),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element,
			TextColor3 = Library.Themes[Library.CurrentTheme].SubText
		}):Play()
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == (Enum.KeyCode[CurrentToggleKey] or Enum.KeyCode.K) then
			ToggleUI()
		end
	end)

	local ThemeObjects = {
		Frames = {Main, Topbar, Sidebar},
		Containers = {},
		Elements = {CloseBtn},
		Strokes = {MainStroke, CloseStroke},
		Accents = {GlowLine, GlowBg},
		Texts = {Title},
		SubTexts = {CloseBtn}
	}

	local function UpdateTheme(themeName)
		if not Library.Themes[themeName] then return end
		Library.CurrentTheme = themeName
		local t = Library.Themes[themeName]

		TweenService:Create(Main, TweenInfo.new(0.3), {BackgroundColor3 = t.Background}):Play()
		TweenService:Create(Topbar, TweenInfo.new(0.3), {BackgroundColor3 = t.Topbar}):Play()
		TweenService:Create(Sidebar, TweenInfo.new(0.3), {BackgroundColor3 = t.Sidebar}):Play()
		TweenService:Create(GlowLine, TweenInfo.new(0.3), {BackgroundColor3 = t.Accent}):Play()
		TweenService:Create(GlowBg, TweenInfo.new(0.3), {ImageColor3 = t.Accent}):Play()
		TweenService:Create(Title, TweenInfo.new(0.3), {TextColor3 = t.Text}):Play()
		TweenService:Create(TopbarIcon, TweenInfo.new(0.3), {ImageColor3 = t.Accent}):Play()
		TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = t.Border}):Play()

		for _, tab in pairs(Tabs) do
			if tab.Active then
				TweenService:Create(tab.Btn, TweenInfo.new(0.3), {BackgroundColor3 = t.Container}):Play()
				TweenService:Create(tab.Title, TweenInfo.new(0.3), {TextColor3 = t.Text}):Play()
				TweenService:Create(tab.Icon, TweenInfo.new(0.3), {ImageColor3 = t.Accent}):Play()
			else
				TweenService:Create(tab.Title, TweenInfo.new(0.3), {TextColor3 = t.SubText}):Play()
				TweenService:Create(tab.Icon, TweenInfo.new(0.3), {ImageColor3 = t.SubText}):Play()
			end
		end
	end

	local WindowApi = {}

	function WindowApi:CreateTab(Name, Icon, IsSystem)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 36)
		TabBtn.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = IsSystem and SystemTabHolder or TabHolder
		Corner(TabBtn, 8)

		local TabStroke = Stroke(TabBtn, Library.Themes[Library.CurrentTheme].Border, 1)
		TabStroke.Enabled = false

		local TabIcon = Instance.new("ImageLabel")
		TabIcon.Size = UDim2.new(0, 18, 0, 18)
		TabIcon.Position = UDim2.new(0, 10, 0.5, -9)
		TabIcon.BackgroundTransparency = 1
		TabIcon.ImageColor3 = Library.Themes[Library.CurrentTheme].SubText
		TabIcon.Parent = TabBtn
		ApplyIcon(TabIcon, Icon)

		local TabTitle = Instance.new("TextLabel")
		TabTitle.Size = UDim2.new(1, -38, 1, 0)
		TabTitle.Position = UDim2.new(0, TabIcon.Visible and 36 or 12, 0, 0)
		TabTitle.BackgroundTransparency = 1
		TabTitle.Text = Name
		TabTitle.TextColor3 = Library.Themes[Library.CurrentTheme].SubText
		TabTitle.TextSize = 13
		TabTitle.Font = Enum.Font.GothamMedium
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left
		TabTitle.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Library.Themes[Library.CurrentTheme].Accent
		Page.Parent = ContentContainer

		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page

		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 12)
		end)

		local TabData = {Btn = TabBtn, Page = Page, Title = TabTitle, Icon = TabIcon, Active = false, Stroke = TabStroke}

		local function ActivateTab()
			for _, tab in pairs(Tabs) do
				tab.Active = false
				tab.Page.Visible = false
				tab.Stroke.Enabled = false
				TweenService:Create(tab.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(tab.Title, TweenInfo.new(0.2), {TextColor3 = Library.Themes[Library.CurrentTheme].SubText}):Play()
				TweenService:Create(tab.Icon, TweenInfo.new(0.2), {ImageColor3 = Library.Themes[Library.CurrentTheme].SubText}):Play()
			end
			TabData.Active = true
			Page.Visible = true
			TabData.Stroke.Enabled = true
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container}):Play()
			TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = Library.Themes[Library.CurrentTheme].Text}):Play()
			TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Themes[Library.CurrentTheme].Accent}):Play()
		end

		TabBtn.MouseButton1Click:Connect(ActivateTab)
		table.insert(Tabs, TabData)

		if FirstTab and not IsSystem then
			FirstTab = false
			ActivateTab()
		end

		local TabApi = {}

		function TabApi:CreateButton(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Button"
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 8)
			local FrStroke = Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = Name
			Btn.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Btn.Font = Enum.Font.GothamSemibold
			Btn.TextSize = 13
			Btn.Parent = Frame

			Btn.MouseEnter:Connect(function()
				TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element}):Play()
				TweenService:Create(FrStroke, TweenInfo.new(0.2), {Color = Library.Themes[Library.CurrentTheme].Accent}):Play()
			end)
			Btn.MouseLeave:Connect(function()
				TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container}):Play()
				TweenService:Create(FrStroke, TweenInfo.new(0.2), {Color = Library.Themes[Library.CurrentTheme].Border}):Play()
			end)

			Btn.MouseButton1Click:Connect(function()
				TweenService:Create(Frame, TweenInfo.new(0.08), {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent}):Play()
				task.wait(0.08)
				TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container}):Play()
				pcall(Callback)
			end)
		end

		function TabApi:CreateToggle(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Toggle"
			local Default = Settings.CurrentValue or false
			local Flag = Settings.Flag
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ToggleBox = Instance.new("Frame")
			ToggleBox.Size = UDim2.new(0, 40, 0, 22)
			ToggleBox.Position = UDim2.new(1, -52, 0.5, -11)
			ToggleBox.BackgroundColor3 = Default and Library.Themes[Library.CurrentTheme].Accent or Library.Themes[Library.CurrentTheme].Element
			ToggleBox.Parent = Frame
			Corner(ToggleBox, 11)

			local Indicator = Instance.new("Frame")
			Indicator.Size = UDim2.new(0, 16, 0, 16)
			Indicator.Position = Default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
			Indicator.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Text
			Indicator.Parent = ToggleBox
			Corner(Indicator, 10)

			local Toggled = Default

			local function SetState(val)
				Toggled = val
				if Flag then Library.Flags[Flag] = Toggled end
				TweenService:Create(ToggleBox, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					BackgroundColor3 = Toggled and Library.Themes[Library.CurrentTheme].Accent or Library.Themes[Library.CurrentTheme].Element
				}):Play()
				TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = Toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
				}):Play()
				pcall(Callback, Toggled)
			end

			table.insert(Library.ActiveToggles, function()
				if Toggled then SetState(false) end
			end)

			local Clickable = Instance.new("TextButton")
			Clickable.Size = UDim2.new(1, 0, 1, 0)
			Clickable.BackgroundTransparency = 1
			Clickable.Text = ""
			Clickable.Parent = Frame
			Clickable.MouseButton1Click:Connect(function() SetState(not Toggled) end)

			if Flag then Library.Flags[Flag] = Toggled end
			return {Set = SetState}
		end

		function TabApi:CreateSlider(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Slider"
			local Min = Settings.Range and Settings.Range[1] or 0
			local Max = Settings.Range and Settings.Range[2] or 100
			local Default = Settings.CurrentValue or Min
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 52)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 0, 22)
			Label.Position = UDim2.new(0, 14, 0, 6)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ValLabel = Instance.new("TextLabel")
			ValLabel.Size = UDim2.new(0, 50, 0, 22)
			ValLabel.Position = UDim2.new(1, -64, 0, 6)
			ValLabel.BackgroundTransparency = 1
			ValLabel.Text = tostring(Default)
			ValLabel.TextColor3 = Library.Themes[Library.CurrentTheme].SubText
			ValLabel.Font = Enum.Font.Gotham
			ValLabel.TextSize = 12
			ValLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValLabel.Parent = Frame

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(1, -28, 0, 6)
			Track.Position = UDim2.new(0, 14, 0, 34)
			Track.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element
			Track.Parent = Frame
			Corner(Track, 4)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new(math.clamp((Default - Min)/(Max - Min), 0, 1), 0, 1, 0)
			Fill.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent
			Fill.Parent = Track
			Corner(Fill, 4)

			local Dragging = false
			local function Update(input)
				local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local val = math.floor(Min + (Max - Min) * pos)
				ValLabel.Text = tostring(val)
				TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
				pcall(Callback, val)
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					Update(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					Update(input)
				end
			end)
		end

		function TabApi:CreateDropdown(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Dropdown"
			local Options = Settings.Options or {}
			local Current = Settings.CurrentOption or Options[1] or ""
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.ClipsDescendants = true
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -30, 0, 42)
			Label.Position = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name .. ": " .. tostring(Current)
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local Open = false
			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
			ToggleBtn.BackgroundTransparency = 1
			ToggleBtn.Text = ""
			ToggleBtn.Parent = Frame

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, #Options * 30)
			Holder.Position = UDim2.new(0, 0, 0, 42)
			Holder.BackgroundTransparency = 1
			Holder.Parent = Frame

			local List = Instance.new("UIListLayout")
			List.SortOrder = Enum.SortOrder.LayoutOrder
			List.Parent = Holder

			for _, opt in ipairs(Options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1, 0, 0, 30)
				OptBtn.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element
				OptBtn.BackgroundTransparency = 0.4
				OptBtn.Text = tostring(opt)
				OptBtn.TextColor3 = Library.Themes[Library.CurrentTheme].SubText
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 12
				OptBtn.Parent = Holder

				OptBtn.MouseButton1Click:Connect(function()
					Current = opt
					Label.Text = Name .. ": " .. tostring(Current)
					Open = false
					TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -6, 0, 42)}):Play()
					pcall(Callback, Current)
				end)
			end

			ToggleBtn.MouseButton1Click:Connect(function()
				Open = not Open
				TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, -6, 0, Open and (42 + #Options * 30) or 42)
				}):Play()
			end)
		end

		function TabApi:CreateInput(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Input"
			local Placeholder = Settings.PlaceholderText or "Enter text..."
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.45, 0, 1, 0)
			Label.Position = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local Box = Instance.new("TextBox")
			Box.Size = UDim2.new(0.5, 0, 0, 26)
			Box.Position = UDim2.new(0.5, -10, 0.5, -13)
			Box.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element
			Box.Text = ""
			Box.PlaceholderText = Placeholder
			Box.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Box.PlaceholderColor3 = Library.Themes[Library.CurrentTheme].SubText
			Box.Font = Enum.Font.Gotham
			Box.TextSize = 12
			Box.Parent = Frame
			Corner(Box, 6)
			Stroke(Box, Library.Themes[Library.CurrentTheme].Border, 1)

			Box.FocusLost:Connect(function(enterPressed)
				pcall(Callback, Box.Text)
			end)
		end

		function TabApi:CreateLabel(Text)
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 32)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 6)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -28, 1, 0)
			Label.Position = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = tostring(Text)
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].SubText
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 12
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame
		end

		function TabApi:CreateColorPicker(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Color Picker"
			local Default = Settings.Color or Color3.fromRGB(255, 0, 0)
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ColorPreview = Instance.new("Frame")
			ColorPreview.Size = UDim2.new(0, 32, 0, 22)
			ColorPreview.Position = UDim2.new(1, -44, 0.5, -11)
			ColorPreview.BackgroundColor3 = Default
			ColorPreview.Parent = Frame
			Corner(ColorPreview, 6)
			Stroke(ColorPreview, Library.Themes[Library.CurrentTheme].Border, 1)

			local Colors = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(0, 120, 255),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(168, 85, 247),
				Color3.fromRGB(255, 255, 255)
			}
			local curIndex = 1

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = ""
			Btn.Parent = Frame

			Btn.MouseButton1Click:Connect(function()
				curIndex = (curIndex % #Colors) + 1
				local newCol = Colors[curIndex]
				TweenService:Create(ColorPreview, TweenInfo.new(0.2), {BackgroundColor3 = newCol}):Play()
				pcall(Callback, newCol)
			end)
		end

		function TabApi:CreateKeybind(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Keybind"
			local Default = Settings.CurrentKeybind or "K"
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Themes[Library.CurrentTheme].Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.6, 0, 1, 0)
			Label.Position = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Themes[Library.CurrentTheme].Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local BindBtn = Instance.new("TextButton")
			BindBtn.Size = UDim2.new(0, 80, 0, 26)
			BindBtn.Position = UDim2.new(1, -92, 0.5, -13)
			BindBtn.BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element
			BindBtn.Text = Default
			BindBtn.TextColor3 = Library.Themes[Library.CurrentTheme].SubText
			BindBtn.Font = Enum.Font.GothamSemibold
			BindBtn.TextSize = 12
			BindBtn.Parent = Frame
			Corner(BindBtn, 6)
			Stroke(BindBtn, Library.Themes[Library.CurrentTheme].Border, 1)

			local Listening = false

			BindBtn.MouseButton1Click:Connect(function()
				Listening = true
				BindBtn.Text = "..."
				TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = Library.Themes[Library.CurrentTheme].Accent}):Play()
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if Listening and not processed and input.UserInputType == Enum.UserInputType.Keyboard then
					Listening = false
					CurrentToggleKey = input.KeyCode.Name
					BindBtn.Text = CurrentToggleKey
					TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = Library.Themes[Library.CurrentTheme].SubText}):Play()
					pcall(Callback, CurrentToggleKey)
				end
			end)
		end

		return TabApi
	end

	local SettingsTab = WindowApi:CreateTab("Settings", "settings", true)

	SettingsTab:CreateKeybind({
		Name = "Toggle Keybind",
		CurrentKeybind = CurrentToggleKey,
		Callback = function(Key)
			CurrentToggleKey = Key
		end
	})

	SettingsTab:CreateDropdown({
		Name = "UI Theme",
		Options = {"Dark", "Midnight", "Crimson", "Emerald"},
		CurrentOption = "Dark",
		Callback = function(ThemeName)
			UpdateTheme(ThemeName)
		end
	})

	return WindowApi
end

return Library
