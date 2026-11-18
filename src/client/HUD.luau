-- HUD: the whole ScreenGui  Ecash panel, tsunami banner, rarity legend,
-- how-to panel, toast stack, rebirth button and the flash frame.
-- Nothing sits in the top-left corner (the Roblox menu buttons live there).

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Rarity = require(Shared.Rarity)
local Format = require(Shared.Format)
local GameConfig = require(Shared.GameConfig)

local HUD = {}

local KIND_COLORS = {
	info = Color3.fromRGB(150, 170, 220),
	good = Color3.fromRGB(120, 230, 130),
	bad = Color3.fromRGB(255, 110, 100),
	gold = Color3.fromRGB(255, 210, 80),
	steal = Color3.fromRGB(255, 170, 60),
}

function HUD.build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 10

	local function panel(name, size, position, anchorPoint, bgColor, transparency)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.AnchorPoint = anchorPoint or Vector2.new(0, 0)
		frame.Position = position
		frame.Size = size
		frame.BackgroundColor3 = bgColor or Color3.fromRGB(22, 24, 34)
		frame.BackgroundTransparency = transparency or 0.25
		frame.BorderSizePixel = 0
		frame.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.75
		stroke.Thickness = 1.5
		stroke.Parent = frame
		return frame
	end

	local function label(parent, name, text, position, size, textSize, color, font, xalign)
		local l = Instance.new("TextLabel")
		l.Name = name
		l.BackgroundTransparency = 1
		l.Position = position
		l.Size = size
		l.Font = font or Enum.Font.Gotham
		l.Text = text
		l.TextSize = textSize
		l.TextColor3 = color or Color3.new(1, 1, 1)
		l.TextXAlignment = xalign or Enum.TextXAlignment.Left
		l.TextWrapped = true
		l.Parent = parent
		return l
	end

	-- cash panel, top right
	local cashPanel = panel("CashPanel", UDim2.fromOffset(236, 124), UDim2.new(1, -14, 0, 14), Vector2.new(1, 0))
	local cashLabel = label(cashPanel, "Cash", "$0", UDim2.new(0, 14, 0, 6), UDim2.new(1, -28, 0, 40), 34, Color3.new(1, 1, 1), Enum.Font.FredokaOne)
	local incomeLabel = label(cashPanel, "Income", "+$0/s", UDim2.new(0, 14, 0, 48), UDim2.new(1, -28, 0, 20), 18, Color3.fromRGB(120, 230, 130))
	local rebirthLabel = label(cashPanel, "Rebirths", "Rebirths: 0 (x1.00)", UDim2.new(0, 14, 0, 70), UDim2.new(1, -28, 0, 18), 14, Color3.fromRGB(255, 210, 80))
	local needLabel = label(cashPanel, "Need", "Next rebirth: earn $2,500", UDim2.new(0, 14, 0, 88), UDim2.new(1, -28, 0, 16), 13, Color3.fromRGB(200, 205, 220))
	local waveLabel = label(cashPanel, "Wave", "Next wave: 90s", UDim2.new(0, 14, 0, 104), UDim2.new(1, -28, 0, 16), 13, Color3.fromRGB(130, 200, 255))

	-- tsunami banner, top centre
	local banner = panel("TsunamiBanner", UDim2.fromOffset(520, 54), UDim2.new(0.5, 0, 0, 16), Vector2.new(0.5, 0), Color3.fromRGB(190, 40, 40), 0.15)
	banner.Visible = false
	label(banner, "Text", "TSUNAMI!", UDim2.new(0, 10, 0, 0), UDim2.new(1, -20, 1, 0), 24, Color3.new(1, 1, 1), Enum.Font.FredokaOne, Enum.TextXAlignment.Center)
	local bannerText = banner:FindFirstChild("Text")
	local bannerPulse = TweenService:Create(banner, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundColor3 = Color3.fromRGB(120, 20, 20) })

	-- rarity legend, bottom left
	local legend = panel("RarityLegend", UDim2.fromOffset(210, 190), UDim2.new(0, 14, 1, -14), Vector2.new(0, 1), nil, 0.35)
	label(legend, "Title", "RARITY LADDER", UDim2.new(0, 12, 0, 6), UDim2.new(1, -24, 0, 20), 15, Color3.new(1, 1, 1), Enum.Font.FredokaOne)
	for i, rarityName in ipairs(Rarity.Order) do
		local y = 28 + (i - 1) * 22
		local chip = Instance.new("Frame")
		chip.Name = "Chip" .. i
		chip.Position = UDim2.new(0, 12, 0, y + 4)
		chip.Size = UDim2.fromOffset(12, 12)
		chip.BackgroundColor3 = Rarity.color(rarityName)
		chip.BorderSizePixel = 0
		chip.Parent = legend
		local chipCorner = Instance.new("UICorner")
		chipCorner.CornerRadius = UDim.new(1, 0)
		chipCorner.Parent = chip
		label(legend, "Row" .. i, rarityName .. " - " .. Rarity.incomeRange(rarityName), UDim2.new(0, 30, 0, y), UDim2.new(1, -40, 0, 20), 13, Color3.fromRGB(225, 228, 240))
	end

	-- how to play, bottom right
	local howto = panel("HowTo", UDim2.fromOffset(330, 150), UDim2.new(1, -14, 1, -14), Vector2.new(1, 1), nil, 0.35)
	label(howto, "Title", "HOW TO PLAY", UDim2.new(0, 12, 0, 6), UDim2.new(1, -24, 0, 18), 15, Color3.new(1, 1, 1), Enum.Font.FredokaOne)
	local lines = {
		"1. Buy a brainrot at the south shop - it lands on your base and earns $/s.",
		"2. Hold E at someone else's brainrot to STEAL it (3s).",
		"3. Buy a lock at your lock pad to block thieves for 60s.",
		"4. When the TSUNAMI banner counts down, stand on YOUR base!",
		"5. Earn enough and hit REBIRTH for +25% income, forever.",
	}
	for i, lineText in ipairs(lines) do
		label(howto, "Line" .. i, lineText, UDim2.new(0, 12, 0, 26 + (i - 1) * 24), UDim2.new(1, -24, 0, 24), 13, Color3.fromRGB(225, 228, 240))
	end

	-- rebirth button, above the how-to panel
	local rebirthButton = Instance.new("TextButton")
	rebirthButton.Name = "RebirthButton"
	rebirthButton.AnchorPoint = Vector2.new(1, 1)
	rebirthButton.Position = UDim2.new(1, -14, 1, -176)
	rebirthButton.Size = UDim2.fromOffset(330, 46)
	rebirthButton.BackgroundColor3 = Color3.fromRGB(255, 196, 64)
	rebirthButton.BackgroundTransparency = 0.1
	rebirthButton.BorderSizePixel = 0
	rebirthButton.Font = Enum.Font.FredokaOne
	rebirthButton.Text = "REBIRTH NOW (+25% income)"
	rebirthButton.TextSize = 20
	rebirthButton.TextColor3 = Color3.fromRGB(60, 40, 10)
	rebirthButton.Visible = false
	rebirthButton.Parent = gui
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 12)
	buttonCorner.Parent = rebirthButton

	-- toast stack, bottom centre
	local toastContainer = Instance.new("Frame")
	toastContainer.Name = "Toasts"
	toastContainer.AnchorPoint = Vector2.new(0.5, 1)
	toastContainer.Position = UDim2.new(0.5, 0, 1, -180)
	toastContainer.Size = UDim2.fromOffset(500, 210)
	toastContainer.BackgroundTransparency = 1
	toastContainer.Parent = gui
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = toastContainer

	local hint = label(gui, "Hint", "Hold E near things: buy, steal, lock, rebirth",
		UDim2.new(0.5, 0, 1, -10), UDim2.new(0, 620, 0, 18), 13, Color3.fromRGB(210, 214, 230), Enum.Font.Gotham, Enum.TextXAlignment.Center)
	hint.AnchorPoint = Vector2.new(0.5, 1)

	-- full-screen flash frame
	local flashFrame = Instance.new("Frame")
	flashFrame.Name = "Flash"
	flashFrame.Size = UDim2.fromScale(1, 1)
	flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	flashFrame.BackgroundTransparency = 1
	flashFrame.BorderSizePixel = 0
	flashFrame.ZIndex = 50
	flashFrame.Parent = gui

	-- toast behaviour
	local toastOrder = 0
	local function toast(text, kind)
		local color = KIND_COLORS[kind or "info"] or KIND_COLORS.info
		toastOrder = toastOrder + 1
		local frame = Instance.new("Frame")
		frame.Name = "Toast"
		frame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
		frame.BackgroundTransparency = 0.2
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromOffset(500, 40)
		frame.LayoutOrder = toastOrder
		frame.Parent = toastContainer
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Transparency = 0.25
		stroke.Thickness = 2
		stroke.Parent = frame
		local toastLabel = Instance.new("TextLabel")
		toastLabel.BackgroundTransparency = 1
		toastLabel.Size = UDim2.new(1, -20, 1, 0)
		toastLabel.Position = UDim2.new(0, 10, 0, 0)
		toastLabel.Font = Enum.Font.Gotham
		toastLabel.Text = text
		toastLabel.TextSize = 15
		toastLabel.TextColor3 = color
		toastLabel.TextWrapped = true
		toastLabel.Parent = frame
		-- keep at most four toasts on screen
		local frames = {}
		for _, child in ipairs(toastContainer:GetChildren()) do
			if child:IsA("Frame") then
				table.insert(frames, child)
			end
		end
		table.sort(frames, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		while #frames > 4 do
			local oldest = table.remove(frames, 1)
			oldest:Destroy()
		end
		task.delay(4.5, function()
			if frame.Parent then
				TweenService:Create(frame, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
				TweenService:Create(toastLabel, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
				TweenService:Create(stroke, TweenInfo.new(0.35), { Transparency = 1 }):Play()
				task.wait(0.4)
				frame:Destroy()
			end
		end)
	end

	-- tsunami banner behaviour
	local function setTsunami(state, seconds)
		if state == "warning" then
			banner.Visible = true
			bannerText.Text = "TSUNAMI IN " .. math.max(1, math.floor(seconds)) .. "s - RUN TO YOUR BASE!"
			if bannerPulse.PlaybackState ~= Enum.PlaybackState.Playing then
				bannerPulse:Play()
			end
			waveLabel.Text = "WAVE INCOMING!"
			waveLabel.TextColor3 = Color3.fromRGB(255, 110, 100)
		elseif state == "sweeping" then
			banner.Visible = true
			bannerText.Text = "TSUNAMI!!!"
			if bannerPulse.PlaybackState ~= Enum.PlaybackState.Playing then
				bannerPulse:Play()
			end
			waveLabel.Text = "WAVE INCOMING!"
			waveLabel.TextColor3 = Color3.fromRGB(255, 110, 100)
		else
			banner.Visible = false
			bannerPulse:Cancel()
			waveLabel.Text = "Next wave: " .. math.max(0, math.floor(seconds)) .. "s"
			waveLabel.TextColor3 = Color3.fromRGB(130, 200, 255)
		end
	end

	-- rebirth panel behaviour
	local function setRebirths(rebirths, earned, need)
		rebirthLabel.Text = "Rebirths: " .. rebirths .. " (x" .. string.format("%.2f", GameConfig.rebirthMultiplier(rebirths)) .. ")"
		local remaining = math.max(0, need - earned)
		needLabel.Text = "Next rebirth: earn " .. Format.money(remaining) .. " more"
		rebirthButton.Visible = need > 0 and earned >= need
	end

	return {
		gui = gui,
		flashFrame = flashFrame,
		rebirthButton = rebirthButton,
		setCash = function(value)
			cashLabel.Text = (value >= 1e6) and Format.compact(value) or Format.money(value)
		end,
		setIncome = function(value)
			incomeLabel.Text = "+" .. Format.compact(value) .. "/s"
		end,
		setRebirths = setRebirths,
		setTsunami = setTsunami,
		toast = toast,
	}
end

return HUD
