local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local CustomLibrary = {
	Flags = {},
	Theme = {
		Background = Color3.fromRGB(15, 15, 22),
		Topbar = Color3.fromRGB(22, 22, 32),
		Container = Color3.fromRGB(28, 28, 40),
		Accent = Color3.fromRGB(138, 43, 226),
		Text = Color3.fromRGB(240, 240, 245),
		SubText = Color3.fromRGB(150, 150, 170),
		Border = Color3.fromRGB(45, 45, 65)
	}
}

local Icons = nil
pcall(function()
	Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function GetLucideIcon(name)
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

local function ApplyIcon(imageLabel, icon)
	if type(icon) == "string" then
		local lucide = GetLucideIcon(icon)
		if lucide then
			imageLabel.Image = lucide.Id
			imageLabel.ImageRectSize = lucide.RectSize
			imageLabel.ImageRectOffset = lucide.RectOffset
			imageLabel.Visible = true
		else
			imageLabel.Visible = false
		end
	elseif type(icon) == "number" and icon > 0 then
		imageLabel.Image = "rbxassetid://" .. tostring(icon)
		imageLabel.ImageRectSize = Vector2.zero
		imageLabel.ImageRectOffset = Vector2.zero
		imageLabel.Visible = true
	else
		imageLabel.Visible = false
	end
end

local function CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function CreateStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or CustomLibrary.Theme.Border
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function MakeDraggable(gui, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			TweenService:Create(gui, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}):Play()
		end
	end)
end

function CustomLibrary:CreateWindow(Settings)
	Settings = Settings or {}
	local WindowName = Settings.Name or "Custom Hub"
	local WindowIcon = Settings.Icon
	local ToggleKey = Settings.ToggleUIKeybind or "K"

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CustomLibraryUI"
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
	Main.Size = UDim2.new(0, 550, 0, 380)
	Main.Position = UDim2.new(0.5, -275, 0.5, -190)
	Main.BackgroundColor3 = CustomLibrary.Theme.Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui

	CreateCorner(Main, 10)
	CreateStroke(Main, CustomLibrary.Theme.Border, 1.5)

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 45)
	Topbar.BackgroundColor3 = CustomLibrary.Theme.Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Main

	CreateCorner(Topbar, 10)
	MakeDraggable(Main, Topbar)

	local TopbarIcon = Instance.new("ImageLabel")
	TopbarIcon.Name = "Icon"
	TopbarIcon.Size = UDim2.new(0, 20, 0, 20)
	TopbarIcon.Position = UDim2.new(0, 15, 0.5, -10)
	TopbarIcon.BackgroundTransparency = 1
	TopbarIcon.ImageColor3 = CustomLibrary.Theme.Accent
	TopbarIcon.Parent = Topbar
	ApplyIcon(TopbarIcon, WindowIcon)

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, TopbarIcon.Visible and 42 or 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = WindowName
	Title.TextColor3 = CustomLibrary.Theme.Text
	Title.TextSize = 16
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Topbar

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 140, 1, -45)
	Sidebar.Position = UDim2.new(0, 0, 0, 45)
	Sidebar.BackgroundColor3 = CustomLibrary.Theme.Topbar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	local TabHolder = Instance.new("ScrollingFrame")
	TabHolder.Name = "TabHolder"
	TabHolder.Size = UDim2.new(1, -10, 1, -10)
	TabHolder.Position = UDim2.new(0, 5, 0, 5)
	TabHolder.BackgroundTransparency = 1
	TabHolder.ScrollBarThickness = 2
	TabHolder.ScrollBarImageColor3 = CustomLibrary.Theme.Accent
	TabHolder.Parent = Sidebar

	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 5)
	TabList.Parent = TabHolder

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -150, 1, -55)
	ContentContainer.Position = UDim2.new(0, 145, 0, 50)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = Main

	local Tabs = {}
	local FirstTab = true

	local KeyCodeEnum = Enum.KeyCode[ToggleKey] or Enum.KeyCode.K
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == KeyCodeEnum then
			Main.Visible = not Main.Visible
		end
	end)

	local WindowApi = {}

	function WindowApi:CreateTab(Name, Icon)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = Name .. "Tab"
		TabBtn.Size = UDim2.new(1, 0, 0, 32)
		TabBtn.BackgroundColor3 = CustomLibrary.Theme.Container
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = TabHolder

		CreateCorner(TabBtn, 6)

		local TabIcon = Instance.new("ImageLabel")
		TabIcon.Name = "Icon"
		TabIcon.Size = UDim2.new(0, 16, 0, 16)
		TabIcon.Position = UDim2.new(0, 10, 0.5, -8)
		TabIcon.BackgroundTransparency = 1
		TabIcon.ImageColor3 = CustomLibrary.Theme.SubText
		TabIcon.Parent = TabBtn
		ApplyIcon(TabIcon, Icon)

		local TabTitle = Instance.new("TextLabel")
		TabTitle.Name = "Title"
		TabTitle.Size = UDim2.new(1, -35, 1, 0)
		TabTitle.Position = UDim2.new(0, TabIcon.Visible and 32 or 10, 0, 0)
		TabTitle.BackgroundTransparency = 1
		TabTitle.Text = Name
		TabTitle.TextColor3 = CustomLibrary.Theme.SubText
		TabTitle.TextSize = 13
		TabTitle.Font = Enum.Font.GothamMedium
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left
		TabTitle.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = CustomLibrary.Theme.Accent
		Page.Parent = ContentContainer

		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page

		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
		end)

		local function ActivateTab()
			for _, tabData in pairs(Tabs) do
				tabData.Page.Visible = false
				TweenService:Create(tabData.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(tabData.Title, TweenInfo.new(0.2), {TextColor3 = CustomLibrary.Theme.SubText}):Play()
				TweenService:Create(tabData.Icon, TweenInfo.new(0.2), {ImageColor3 = CustomLibrary.Theme.SubText}):Play()
			end
			Page.Visible = true
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = CustomLibrary.Theme.Text}):Play()
			TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = CustomLibrary.Theme.Accent}):Play()
		end

		TabBtn.MouseButton1Click:Connect(ActivateTab)

		table.insert(Tabs, {Btn = TabBtn, Page = Page, Title = TabTitle, Icon = TabIcon})

		if FirstTab then
			FirstTab = false
			ActivateTab()
		end

		local TabApi = {}

		function TabApi:CreateButton(Settings)
			Settings = Settings or {}
			local BtnName = Settings.Name or "Button"
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -5, 0, 36)
			Frame.BackgroundColor3 = CustomLibrary.Theme.Container
			Frame.Parent = Page
			CreateCorner(Frame, 6)
			CreateStroke(Frame, CustomLibrary.Theme.Border, 1)

			local Button = Instance.new("TextButton")
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.BackgroundTransparency = 1
			Button.Text = BtnName
			Button.TextColor3 = CustomLibrary.Theme.Text
			Button.Font = Enum.Font.GothamSemibold
			Button.TextSize = 13
			Button.Parent = Frame

			Button.MouseButton1Click:Connect(function()
				TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = CustomLibrary.Theme.Accent}):Play()
				task.wait(0.1)
				TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = CustomLibrary.Theme.Container}):Play()
				pcall(Callback)
			end)
		end

		function TabApi:CreateToggle(Settings)
			Settings = Settings or {}
			local ToggleName = Settings.Name or "Toggle"
			local Default = Settings.CurrentValue or false
			local Flag = Settings.Flag
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -5, 0, 36)
			Frame.BackgroundColor3 = CustomLibrary.Theme.Container
			Frame.Parent = Page
			CreateCorner(Frame, 6)
			CreateStroke(Frame, CustomLibrary.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -50, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = ToggleName
			Label.TextColor3 = CustomLibrary.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ToggleBox = Instance.new("Frame")
			ToggleBox.Size = UDim2.new(0, 34, 0, 18)
			ToggleBox.Position = UDim2.new(1, -40, 0.5, -9)
			ToggleBox.BackgroundColor3 = Default and CustomLibrary.Theme.Accent or CustomLibrary.Theme.Topbar
			ToggleBox.Parent = Frame
			CreateCorner(ToggleBox, 10)

			local Indicator = Instance.new("Frame")
			Indicator.Size = UDim2.new(0, 14, 0, 14)
			Indicator.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			Indicator.BackgroundColor3 = CustomLibrary.Theme.Text
			Indicator.Parent = ToggleBox
			CreateCorner(Indicator, 10)

			local Toggled = Default

			local function SetState(val)
				Toggled = val
				if Flag then CustomLibrary.Flags[Flag] = Toggled end
				TweenService:Create(ToggleBox, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and CustomLibrary.Theme.Accent or CustomLibrary.Theme.Topbar}):Play()
				TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
				pcall(Callback, Toggled)
			end

			local Clickable = Instance.new("TextButton")
			Clickable.Size = UDim2.new(1, 0, 1, 0)
			Clickable.BackgroundTransparency = 1
			Clickable.Text = ""
			Clickable.Parent = Frame

			Clickable.MouseButton1Click:Connect(function()
				SetState(not Toggled)
			end)

			if Flag then CustomLibrary.Flags[Flag] = Toggled end

			return {Set = SetState}
		end

		function TabApi:CreateSlider(Settings)
			Settings = Settings or {}
			local SliderName = Settings.Name or "Slider"
			local Min = Settings.Range and Settings.Range[1] or 0
			local Max = Settings.Range and Settings.Range[2] or 100
			local Default = Settings.CurrentValue or Min
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -5, 0, 45)
			Frame.BackgroundColor3 = CustomLibrary.Theme.Container
			Frame.Parent = Page
			CreateCorner(Frame, 6)
			CreateStroke(Frame, CustomLibrary.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 0, 20)
			Label.Position = UDim2.new(0, 10, 0, 5)
			Label.BackgroundTransparency = 1
			Label.Text = SliderName
			Label.TextColor3 = CustomLibrary.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size = UDim2.new(0, 50, 0, 20)
			ValueLabel.Position = UDim2.new(1, -55, 0, 5)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(Default)
			ValueLabel.TextColor3 = CustomLibrary.Theme.SubText
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.TextSize = 12
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = Frame

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(1, -20, 0, 6)
			Track.Position = UDim2.new(0, 10, 0, 30)
			Track.BackgroundColor3 = CustomLibrary.Theme.Topbar
			Track.Parent = Frame
			CreateCorner(Track, 4)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = CustomLibrary.Theme.Accent
			Fill.Parent = Track
			CreateCorner(Fill, 4)

			local Dragging = false

			local function Update(input)
				local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local val = math.floor(Min + (Max - Min) * pos)
				ValueLabel.Text = tostring(val)
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
			local DropName = Settings.Name or "Dropdown"
			local Options = Settings.Options or {}
			local Current = Settings.CurrentOption or Options[1] or ""
			local Callback = Settings.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -5, 0, 36)
			Frame.BackgroundColor3 = CustomLibrary.Theme.Container
			Frame.ClipsDescendants = true
			Frame.Parent = Page
			CreateCorner(Frame, 6)
			CreateStroke(Frame, CustomLibrary.Theme.Border, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -30, 0, 36)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = DropName .. ": " .. tostring(Current)
			Label.TextColor3 = CustomLibrary.Theme.Text
			Label.Font = Enum.Font.GothamMedium
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local Open = false

			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
			ToggleBtn.BackgroundTransparency = 1
			ToggleBtn.Text = ""
			ToggleBtn.Parent = Frame

			local OptionHolder = Instance.new("Frame")
			OptionHolder.Size = UDim2.new(1, 0, 0, #Options * 28)
			OptionHolder.Position = UDim2.new(0, 0, 0, 36)
			OptionHolder.BackgroundTransparency = 1
			OptionHolder.Parent = Frame

			local OptionList = Instance.new("UIListLayout")
			OptionList.SortOrder = Enum.SortOrder.LayoutOrder
			OptionList.Parent = OptionHolder

			for _, opt in ipairs(Options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1, 0, 0, 28)
				OptBtn.BackgroundColor3 = CustomLibrary.Theme.Topbar
				OptBtn.BackgroundTransparency = 0.5
				OptBtn.Text = tostring(opt)
				OptBtn.TextColor3 = CustomLibrary.Theme.SubText
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 12
				OptBtn.Parent = OptionHolder

				OptBtn.MouseButton1Click:Connect(function()
					Current = opt
					Label.Text = DropName .. ": " .. tostring(Current)
					Open = false
					TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -5, 0, 36)}):Play()
					pcall(Callback, Current)
				end)
			end

			ToggleBtn.MouseButton1Click:Connect(function()
				Open = not Open
				local targetSize = Open and (36 + #Options * 28) or 36
				TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -5, 0, targetSize)}):Play()
			end)
		end

		return TabApi
	end

	return WindowApi
end

return CustomLibrary
