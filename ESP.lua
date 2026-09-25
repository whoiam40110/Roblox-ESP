local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local ESP_ENABLED = true
local PLAYERS_ENABLED = true
local BOTS_ENABLED = true
local THROUGH_WALLS = true

local PLAYER_COLOR = Color3.fromRGB(0, 170, 255)
local BOT_COLOR = Color3.fromRGB(255, 70, 70)

--==================================================
-- ESP SYSTEM
--==================================================

local function createESP(model, color)
	if not model or not model:IsA("Model") then
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local player = Players:GetPlayerFromCharacter(model)

	local isPlayer = player ~= nil
	local isBot = not isPlayer

	if isPlayer and not PLAYERS_ENABLED then
		return
	end

	if isBot and not BOTS_ENABLED then
		return
	end

	local highlight = model:FindFirstChild("ESP_Highlight")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "ESP_Highlight"
		highlight.Adornee = model
		highlight.Parent = model
	end

	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Enabled = ESP_ENABLED

	if THROUGH_WALLS then
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	else
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	end
end

local function updateAllESP()
	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Model") then
			local humanoid = object:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local player = Players:GetPlayerFromCharacter(object)

				if player then
					if PLAYERS_ENABLED then
						createESP(object, PLAYER_COLOR)
					else
						local esp = object:FindFirstChild("ESP_Highlight")

						if esp then
							esp.Enabled = false
						end
					end
				else
					if BOTS_ENABLED then
						createESP(object, BOT_COLOR)
					else
						local esp = object:FindFirstChild("ESP_Highlight")

						if esp then
							esp.Enabled = false
						end
					end
				end
			end
		end
	end
end

--==================================================
-- PLAYER ESP
--==================================================

local function setupPlayer(player)
	if player == LocalPlayer then
		return
	end

	if player.Character then
		createESP(player.Character, PLAYER_COLOR)
	end

	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)

		if PLAYERS_ENABLED then
			createESP(character, PLAYER_COLOR)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

--==================================================
-- BOT ESP
--==================================================

workspace.DescendantAdded:Connect(function(object)
	if not object:IsA("Model") then
		return
	end

	task.wait()

	if object:FindFirstChildOfClass("Humanoid") then
		local player = Players:GetPlayerFromCharacter(object)

		if not player and BOTS_ENABLED then
			createESP(object, BOT_COLOR)
		end
	end
end)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ESP_Menu"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 300, 0, 390)
main.Position = UDim2.new(0.5, -150, 0.15, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = main

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -55, 0, 45)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ESP MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 40, 0, 40)
minimize.Position = UDim2.new(1, -45, 0, 3)
minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minimize.Text = "-"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.TextSize = 25
minimize.Font = Enum.Font.GothamBold
minimize.Parent = main

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 10)
minimizeCorner.Parent = minimize

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(text, y)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -30, 0, 42)
	button.Position = UDim2.new(0, 15, 0, y)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 17
	button.Font = Enum.Font.GothamBold
	button.Parent = main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = button

	return button
end

--==================================================
-- ESP TOGGLE
--==================================================

local espButton = createButton("ESP: ON", 55)

espButton.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED

	if ESP_ENABLED then
		espButton.Text = "ESP: ON"
		espButton.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
	else
		espButton.Text = "ESP: OFF"
		espButton.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
	end

	updateAllESP()
end)

--==================================================
-- PLAYERS TOGGLE
--==================================================

local playersButton = createButton("Players: ON", 105)

playersButton.MouseButton1Click:Connect(function()
	PLAYERS_ENABLED = not PLAYERS_ENABLED

	if PLAYERS_ENABLED then
		playersButton.Text = "Players: ON"
	else
		playersButton.Text = "Players: OFF"
	end

	updateAllESP()
end)

--==================================================
-- BOTS TOGGLE
--==================================================

local botsButton = createButton("Bots: ON", 155)

botsButton.MouseButton1Click:Connect(function()
	BOTS_ENABLED = not BOTS_ENABLED

	if BOTS_ENABLED then
		botsButton.Text = "Bots: ON"
	else
		botsButton.Text = "Bots: OFF"
	end

	updateAllESP()
end)

--==================================================
-- THROUGH WALLS TOGGLE
--==================================================

local wallsButton = createButton("Through Walls: ON", 205)

wallsButton.MouseButton1Click:Connect(function()
	THROUGH_WALLS = not THROUGH_WALLS

	if THROUGH_WALLS then
		wallsButton.Text = "Through Walls: ON"
	else
		wallsButton.Text = "Through Walls: OFF"
	end

	updateAllESP()
end)

--==================================================
-- RGB COLOR SECTION
--==================================================

local function createRGBSection(name, y, currentColor, callback)
	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(1, -30, 0, 25)
	label.Position = UDim2.new(0, 15, 0, y)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 15
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = main

	local values = {
		math.floor(currentColor.R * 255),
		math.floor(currentColor.G * 255),
		math.floor(currentColor.B * 255)
	}

	local boxes = {}

	for i = 1, 3 do
		local box = Instance.new("TextBox")

		box.Size = UDim2.new(0, 75, 0, 32)
		box.Position = UDim2.new(0, 15 + ((i - 1) * 85), 0, y + 27)
		box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		box.BorderSizePixel = 0
		box.Text = tostring(values[i])
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.TextSize = 15
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = false
		box.Parent = main

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 7)
		corner.Parent = box

		boxes[i] = box

		box.FocusLost:Connect(function()
			local r = tonumber(boxes[1].Text) or 255
			local g = tonumber(boxes[2].Text) or 255
			local b = tonumber(boxes[3].Text) or 255

			r = math.clamp(r, 0, 255)
			g = math.clamp(g, 0, 255)
			b = math.clamp(b, 0, 255)

			local color = Color3.fromRGB(r, g, b)

			callback(color)
		end)
	end
end

--==================================================
-- PLAYER COLOR
--==================================================

createRGBSection(
	"Player Color (R / G / B)",
	255,
	PLAYER_COLOR,

	function(color)
		PLAYER_COLOR = color
		updateAllESP()
	end
)

--==================================================
-- BOT COLOR
--==================================================

createRGBSection(
	"Bot Color (R / G / B)",
	325,
	BOT_COLOR,

	function(color)
		BOT_COLOR = color
		updateAllESP()
	end
)

--==================================================
-- COLLAPSED MENU
--==================================================

local collapsed = false

local small = Instance.new("Frame")
small.Name = "SmallMenu"
small.Size = UDim2.new(0, 120, 0, 45)
small.Position = main.Position
small.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
small.BorderSizePixel = 0
small.Visible = false
small.Parent = gui

local smallCorner = Instance.new("UICorner")
smallCorner.CornerRadius = UDim.new(0, 15)
smallCorner.Parent = small

local smallTitle = Instance.new("TextLabel")
smallTitle.Size = UDim2.new(1, -40, 1, 0)
smallTitle.Position = UDim2.new(0, 10, 0, 0)
smallTitle.BackgroundTransparency = 1
smallTitle.Text = "ESP"
smallTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
smallTitle.TextSize = 18
smallTitle.Font = Enum.Font.GothamBold
smallTitle.Parent = small

local expand = Instance.new("TextButton")
expand.Size = UDim2.new(0, 35, 0, 35)
expand.Position = UDim2.new(1, -40, 0, 5)
expand.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
expand.Text = "+"
expand.TextColor3 = Color3.fromRGB(255, 255, 255)
expand.TextSize = 22
expand.Font = Enum.Font.GothamBold
expand.Parent = small

local expandCorner = Instance.new("UICorner")
expandCorner.CornerRadius = UDim.new(0, 9)
expandCorner.Parent = expand

--==================================================
-- MINIMIZE / EXPAND
--==================================================

minimize.MouseButton1Click:Connect(function()
	collapsed = true

	small.Position = main.Position

	main.Visible = false
	small.Visible = true
end)

expand.MouseButton1Click:Connect(function()
	collapsed = false

	main.Position = small.Position

	small.Visible = false
	main.Visible = true
end)

--==================================================
-- DRAG SYSTEM
--==================================================

local function makeDraggable(object)
	local dragging = false
	local dragStart
	local startPos

	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	object.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart

			object.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(main)
makeDraggable(small)

--==================================================
-- INITIALIZE
--==================================================

updateAllESP()
