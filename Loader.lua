local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Unique ID für altes UI Cleanup
local GUI_NAME = "UltraLuxuryHub_UI"

-- Clean up falls Script erneut geladen wird
if CoreGui:FindFirstChild(GUI_NAME) then
	CoreGui[GUI_NAME]:Destroy()
end
if gethui and gethui():FindFirstChild(GUI_NAME) then
	gethui()[GUI_NAME]:Destroy()
end

local Library = {
	Flags = {},
	ActiveToggles = {},
	Theme = {
		Background = Color3.fromRGB(11, 12, 18),
		Topbar = Color3.fromRGB(16, 17, 26),
		Container = Color3.fromRGB(20, 22, 34),
		Element = Color3.fromRGB(26, 28, 44),
		Accent = Color3.fromRGB(168, 85, 247), -- Neon Purple/Violet
		AccentGlow = Color3.fromRGB(192, 132, 252),
		Text = Color3.fromRGB(245, 245, 250),
		SubText = Color3.fromRGB(140, 145, 170),
		Border = Color3.fromRGB(40, 44, 68),
		Hover = Color3.fromRGB(32, 35, 54)
	}
}

-- Lucide Icon Engine
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
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Library.Theme.Border
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
	local ToggleKey = Settings.ToggleUIKeybind or "K"

	-- ScreenGui setup
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

	-- Main Window Frame
	local Main = Instance.new("Frame")
	Main.Name = "MainFrame"
	Main.Size = UDim2.new(0, 620, 0, 420)
	Main.Position = UDim2.new(0.5, -310, 0.5, -210)
	Main.BackgroundColor3 = Library.Theme.Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui

	Corner(Main, 12)
	local MainStroke = Stroke(Main, Library.Theme.Border, 1.5)

	-- Topbar
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 50)
	Topbar.BackgroundColor3 = Library.Theme.Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Main

	Corner(Topbar, 12)
	MakeDraggable(Main, Topbar)

	-- Sub-line separator glow
	local GlowLine = Instance.new("Frame")
	GlowLine.Size = UDim2.new(1, 0, 0, 1)
	GlowLine.Position = UDim2.new(0, 0, 1, -1)
	GlowLine.BackgroundColor3 = Library.Theme.Accent
	GlowLine.BorderSizePixel = 0
	GlowLine.Parent = Topbar

	local TopbarIcon = Instance.new("ImageLabel")
	TopbarIcon.Size = UDim2.new(0, 22, 0, 22)
	TopbarIcon.Position = UDim2.new(0, 16, 0.5, -11)
	TopbarIcon.BackgroundTransparency = 1
	TopbarIcon.ImageColor3 = Library.Theme.Accent
	TopbarIcon.Parent = Topbar
	ApplyIcon(TopbarIcon, WindowIcon)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -80, 1, 0)
	Title.Position = UDim2.new(0, TopbarIcon.Visible and 46 or 16, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = WindowName
	Title.TextColor3 = Library.Theme.Text
	Title.TextSize = 16
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Topbar

	-- Sidebar (Tabs Container)
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 160, 1, -50)
	Sidebar.Position = UDim2.new(0, 0, 0, 50)
	Sidebar.BackgroundColor3 = Library.Theme.Topbar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	local TabHolder = Instance.new("ScrollingFrame")
	TabHolder.Size = UDim2.new(1, -12, 1, -16)
	TabHolder.Position = UDim2.new(0, 6, 0, 8)
	TabHolder.BackgroundTransparency = 1
	TabHolder.ScrollBarThickness = 2
	TabHolder.ScrollBarImageColor3 = Library.Theme.Accent
	TabHolder.Parent = Sidebar

	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 6)
	TabList.Parent = TabHolder

	-- Main Content Container
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -172, 1, -62)
	ContentContainer.Position = UDim2.new(0, 166, 0, 56)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = Main

	local Tabs = {}
	local FirstTab = true

	-- Keybind zum Ausblenden
	local KeyCodeEnum = Enum.KeyCode[ToggleKey] or Enum.KeyCode.K
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == KeyCodeEnum then
			Main.Visible = not Main.Visible
		end
	end)

	local WindowApi = {}

	function WindowApi:CreateTab(Name, Icon)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 36)
		TabBtn.BackgroundColor3 = Library.Theme.Container
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = TabHolder
		Corner(TabBtn, 8)

		local TabIcon = Instance.new("ImageLabel")
		TabIcon.Size = UDim2.new(0, 18, 0, 18)
		TabIcon.Position = UDim2.new(0, 10, 0.5, -9)
		TabIcon.BackgroundTransparency = 1
		TabIcon.ImageColor3 = Library.Theme.SubText
		TabIcon.Parent = TabBtn
		ApplyIcon(TabIcon, Icon)

		local TabTitle = Instance.new("TextLabel")
		TabTitle.Size = UDim2.new(1, -38, 1, 0)
		TabTitle.Position = UDim2.new(0, TabIcon.Visible and 36 or 12, 0, 0)
		TabTitle.BackgroundTransparency = 1
		TabTitle.Text = Name
		TabTitle.TextColor3 = Library.Theme.SubText
		TabTitle.TextSize = 13
		TabTitle.Font = Enum.Font.GothamMedium
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left
		TabTitle.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Library.Theme.Accent
		Page.Parent = ContentContainer

		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page

		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 12)
		end)

		local function ActivateTab()
			for _, tab in pairs(Tabs) do
				tab.Page.Visible = false
				TweenService:Create(tab.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(tab.Title, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play()
				TweenService:Create(tab.Icon, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.SubText}):Play()
			end
			Page.Visible = true
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play()
			TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.Accent}):Play()
		end

		TabBtn.MouseButton1Click:Connect(ActivateTab)

		table.insert(Tabs, {Btn = TabBtn, Page = Page, Title = TabTitle, Icon = TabIcon})
		if FirstTab then FirstTab = false; ActivateTab() end

		local TabApi = {}

		-- 1. BUTTON
		function TabApi:CreateButton(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Button"
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 40)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Theme.Border, 1)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = Name
			Btn.TextColor3 = Library.Theme.Text
			Btn.Font = Enum.Font.GothamSemibold
			Btn.TextSize = 13
			Btn.Parent = Frame

			Btn.MouseButton1Click:Connect(function()
				TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent}):Play()
				task.wait(0.1)
				TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Container}):Play()
				pcall(Callback)
			end)
		end

		-- 2. TOGGLE (Mit Auto-Reset-Tracking)
		function TabApi:CreateToggle(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Toggle"
			local Default = Settings.CurrentValue or false
			local Flag = Settings.Flag
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 40)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ToggleBox = Instance.new("Frame")
			ToggleBox.Size = UDim2.new(0, 36, 0, 20)
			ToggleBox.Position = UDim2.new(1, -48, 0.5, -10)
			ToggleBox.BackgroundColor3 = Default and Library.Theme.Accent or Library.Theme.Element
			ToggleBox.Parent = Frame
			Corner(ToggleBox, 10)

			local Indicator = Instance.new("Frame")
			Indicator.Size = UDim2.new(0, 14, 0, 14)
			Indicator.Position = Default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			Indicator.BackgroundColor3 = Library.Theme.Text
			Indicator.Parent = ToggleBox
			Corner(Indicator, 10)

			local Toggled = Default

			local function SetState(val)
				Toggled = val
				if Flag then Library.Flags[Flag] = Toggled end
				TweenService:Create(ToggleBox, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and Library.Theme.Accent or Library.Theme.Element}):Play()
				TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = Toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
				pcall(Callback, Toggled)
			end

			-- Für Reset-Funktionalität registrieren
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

		-- 3. SLIDER
		function TabApi:CreateSlider(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Slider"
			local Min = Settings.Range and Settings.Range[1] or 0
			local Max = Settings.Range and Settings.Range[2] or 100
			local Default = Settings.CurrentValue or Min
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 50)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 0, 22)
			Label.Position = UDim2.new(0, 12, 0, 4)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ValLabel = Instance.new("TextLabel")
			ValLabel.Size = UDim2.new(0, 50, 0, 22)
			ValLabel.Position = UDim2.new(1, -62, 0, 4)
			ValLabel.BackgroundTransparency = 1
			ValLabel.Text = tostring(Default)
			ValLabel.TextColor3 = Library.Theme.SubText
			ValLabel.Font = Enum.Font.Gotham
			ValLabel.TextSize = 12
			ValLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValLabel.Parent = Frame

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(1, -24, 0, 6)
			Track.Position = UDim2.new(0, 12, 0, 32)
			Track.BackgroundColor3 = Library.Theme.Element
			Track.Parent = Frame
			Corner(Track, 4)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new(math.clamp((Default - Min)/(Max - Min), 0, 1), 0, 1, 0)
			Fill.BackgroundColor3 = Library.Theme.Accent
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

		-- 4. DROPDOWN
		function TabApi:CreateDropdown(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Dropdown"
			local Options = Settings.Options or {}
			local Current = Settings.CurrentOption or Options[1] or ""
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 40)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.ClipsDescendants = true
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -30, 0, 40)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name .. ": " .. tostring(Current)
			Label.TextColor3 = Library.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local Open = false
			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
			ToggleBtn.BackgroundTransparency = 1
			ToggleBtn.Text = ""
			ToggleBtn.Parent = Frame

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, #Options * 30)
			Holder.Position = UDim2.new(0, 0, 0, 40)
			Holder.BackgroundTransparency = 1
			Holder.Parent = Frame

			local List = Instance.new("UIListLayout")
			List.SortOrder = Enum.SortOrder.LayoutOrder
			List.Parent = Holder

			for _, opt in ipairs(Options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1, 0, 0, 30)
				OptBtn.BackgroundColor3 = Library.Theme.Element
				OptBtn.BackgroundTransparency = 0.4
				OptBtn.Text = tostring(opt)
				OptBtn.TextColor3 = Library.Theme.SubText
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 12
				OptBtn.Parent = Holder

				OptBtn.MouseButton1Click:Connect(function()
					Current = opt
					Label.Text = Name .. ": " .. tostring(Current)
					Open = false
					TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -6, 0, 40)}):Play()
					pcall(Callback, Current)
				end)
			end

			ToggleBtn.MouseButton1Click:Connect(function()
				Open = not Open
				TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -6, 0, Open and (40 + #Options * 30) or 40)}):Play()
			end)
		end

		-- 5. INPUT (Text Box)
		function TabApi:CreateInput(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Input"
			local Placeholder = Settings.PlaceholderText or "Enter text..."
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 42)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.45, 0, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local Box = Instance.new("TextBox")
			Box.Size = UDim2.new(0.5, 0, 0, 26)
			Box.Position = UDim2.new(0.5, -10, 0.5, -13)
			Box.BackgroundColor3 = Library.Theme.Element
			Box.Text = ""
			Box.PlaceholderText = Placeholder
			Box.TextColor3 = Library.Theme.Text
			Box.PlaceholderColor3 = Library.Theme.SubText
			Box.Font = Enum.Font.Gotham
			Box.TextSize = 12
			Box.Parent = Frame
			Corner(Box, 6)
			Stroke(Box, Library.Theme.Border, 1)

			Box.FocusLost:Connect(function(enterPressed)
				pcall(Callback, Box.Text)
			end)
		end

		-- 6. LABEL
		function TabApi:CreateLabel(Text)
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 30)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.Parent = Page
			Corner(Frame, 6)
			Stroke(Frame, Library.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -24, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = tostring(Text)
			Label.TextColor3 = Library.Theme.SubText
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 12
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame
		end

		-- 7. COLORPICKER
		function TabApi:CreateColorPicker(Settings)
			Settings = Settings or {}
			local Name = Settings.Name or "Color Picker"
			local Default = Settings.Color or Color3.fromRGB(255, 0, 0)
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -6, 0, 40)
			Frame.BackgroundColor3 = Library.Theme.Container
			Frame.Parent = Page
			Corner(Frame, 8)
			Stroke(Frame, Library.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Library.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ColorPreview = Instance.new("Frame")
			ColorPreview.Size = UDim2.new(0, 30, 0, 20)
			ColorPreview.Position = UDim2.new(1, -42, 0.5, -10)
			ColorPreview.BackgroundColor3 = Default
			ColorPreview.Parent = Frame
			Corner(ColorPreview, 6)
			Stroke(ColorPreview, Library.Theme.Border, 1)

			-- Ein simpler ColorPicker Cycle/Trigger
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

		return TabApi
	end

	return WindowApi
end

return Library
