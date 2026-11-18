-- Verified: brainrot parts anchored at their welded offsets.
-- BrainrotFactory: assembles every brainrot out of parts (body, head, eyes,
-- silly accessories), gives it a world-space label and a gentle bob-and-spin
-- animation, and can fly it from one pedestal to another.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Rarity = require(Shared.Rarity)
local Format = require(Shared.Format)

local BrainrotFactory = {}

local BOB_HEIGHT = 0.45
local BOB_HALF_TIME = 1.3
local GROUND = -0.2 -- root-space height of the surface a model stands on

local modelFolder = nil
local function folder()
	if modelFolder == nil or modelFolder.Parent == nil then
		local f = Instance.new("Folder")
		f.Name = "PlacedBrainrots"
		f.Parent = workspace
		modelFolder = f
	end
	return modelFolder
end

local SHAPES = {
	Block = Enum.PartType.Block,
	Ball = Enum.PartType.Ball,
	Cylinder = Enum.PartType.Cylinder,
	Wedge = Enum.PartType.Wedge,
}

local MATERIALS = {
	Neon = Enum.Material.Neon,
	Metal = Enum.Material.Metal,
	Glass = Enum.Material.Glass,
}

-- One welded part of the model, placed in the root's frame. The part is anchored
-- at its exact offset while it is assembled and only unanchored once the weld
-- that pins it to the root exists, so it can never fall while it is being built.
-- The weld carries the offset in its C0, so the part's placement does not depend
-- on when the engine captured the two parts' CFrames.
local function piece(model, root, name, size, offsetCF, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Anchored = true
	p.CFrame = root.CFrame * offsetCF
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = model
	local weld = Instance.new("Weld")
	weld.Name = "RootWeld"
	weld.Part0 = root
	weld.Part1 = p
	weld.C0 = offsetCF
	weld.C1 = CFrame.identity
	weld.Parent = p
	-- The root is anchored, so the welded assembly is anchored too; the part now
	-- follows every root CFrame change (bob, spin, flyTo) exactly.
	p.Anchored = false
	return p
end

-- All the numbers the builders need, in the root's frame. Models face -Z.
local function geometry(build)
	local ground = GROUND
	local bodyH = build.bodySize.Y
	local bodyBottom = ground + (build.legs and 0.6 or 0.15)
	local bodyCenterY = bodyBottom + bodyH / 2
	local headH = build.headSize.Y
	local headZ = 0
	local headCenterY = 0
	if build.headPos == "Front" then
		headZ = -(build.bodySize.Z / 2) - build.headSize.Z * 0.25
		headCenterY = bodyCenterY + bodyH * 0.1
	else
		headCenterY = bodyBottom + bodyH + headH / 2 - 0.1
	end
	local headFrontZ = build.headSize.Z / 2
	if build.headShape == "Ball" then
		headFrontZ = build.headSize.Y / 2 * 0.85
	end
	return {
		bodySize = build.bodySize,
		bodyBottom = bodyBottom,
		bodyCenterY = bodyCenterY,
		bodyFrontZ = -(build.bodySize.Z / 2),
		headSize = build.headSize,
		headCenterY = headCenterY,
		headTopY = headCenterY + headH / 2,
		headZ = headZ,
		headFrontZ = headFrontZ,
		accent = build.accentColor or Color3.fromRGB(245, 245, 245),
	}
end

local function buildBody(model, root, build, geom)
	local shape = SHAPES[build.bodyShape] or Enum.PartType.Block
	local material = MATERIALS[build.bodyMaterial or ""] or Enum.Material.SmoothPlastic
	local offset = CFrame.new(0, geom.bodyCenterY, 0)
	if build.bodyShape == "Cylinder" then
		-- cylinder height runs along X; stand it upright
		offset = offset * CFrame.Angles(0, 0, math.rad(90))
	end
	local body = piece(model, root, "Body", build.bodySize, offset, build.bodyColor, material, shape)
	if build.legs then
		local legX = build.bodySize.X * 0.22
		piece(model, root, "LegL", Vector3.new(0.55, 0.6, 0.55), CFrame.new(-legX, geom.bodyBottom - 0.3, 0), build.bodyColor)
		piece(model, root, "LegR", Vector3.new(0.55, 0.6, 0.55), CFrame.new(legX, geom.bodyBottom - 0.3, 0), build.bodyColor)
	end
	return body
end

local function addEyes(model, root, build, geom)
	local scale = build.eyeScale or 1
	local size = 0.34 * scale
	local eyeColor = Color3.fromRGB(20, 20, 24)
	local dx = geom.headSize.X * 0.18
	local base = CFrame.new(0, geom.headCenterY, geom.headZ)
	if build.eyeStyle == "Top" then
		piece(model, root, "EyeL", Vector3.new(size, size, size), base * CFrame.new(-dx, geom.headSize.Y / 2, 0), eyeColor, nil, Enum.PartType.Ball)
		piece(model, root, "EyeR", Vector3.new(size, size, size), base * CFrame.new(dx, geom.headSize.Y / 2, 0), eyeColor, nil, Enum.PartType.Ball)
	else
		local dy = geom.headSize.Y * 0.08
		piece(model, root, "EyeL", Vector3.new(size, size, size), base * CFrame.new(-dx, dy, -geom.headFrontZ), eyeColor, nil, Enum.PartType.Ball)
		piece(model, root, "EyeR", Vector3.new(size, size, size), base * CFrame.new(dx, dy, -geom.headFrontZ), eyeColor, nil, Enum.PartType.Ball)
	end
end

-- Silly accessories, each a couple of parts -------------------------------

local ACCESSORY_BUILDERS = {}

ACCESSORY_BUILDERS.TopHat = function(model, root, build, geom)
	piece(model, root, "HatBrim", Vector3.new(0.35, 2.3, 2.3), CFrame.new(0, geom.headTopY + 0.08, geom.headZ) * CFrame.Angles(0, 0, math.rad(90)), geom.accent, nil, Enum.PartType.Cylinder)
	piece(model, root, "HatCrown", Vector3.new(1.5, 1.3, 1.3), CFrame.new(0, geom.headTopY + 1.0, geom.headZ) * CFrame.Angles(0, 0, math.rad(90)), geom.accent, nil, Enum.PartType.Cylinder)
end

ACCESSORY_BUILDERS.Crown = function(model, root, build, geom)
	local gold = Color3.fromRGB(255, 196, 40)
	piece(model, root, "CrownBand", Vector3.new(0.4, 1.5, 1.5), CFrame.new(0, geom.headTopY + 0.35, geom.headZ) * CFrame.Angles(0, 0, math.rad(90)), gold, Enum.Material.Neon, Enum.PartType.Cylinder)
	for i = 0, 2 do
		local a = (i / 3) * math.pi * 2
		piece(model, root, "CrownSpike" .. i, Vector3.new(0.32, 0.32, 0.32), CFrame.new(math.cos(a) * 0.55, geom.headTopY + 0.75, geom.headZ + math.sin(a) * 0.55), gold, Enum.Material.Neon, Enum.PartType.Ball)
	end
end

ACCESSORY_BUILDERS.Sunglasses = function(model, root, build, geom)
	piece(model, root, "Shades", Vector3.new(geom.headSize.X * 0.95, 0.32, 0.3), CFrame.new(0, geom.headCenterY + geom.headSize.Y * 0.1, geom.headZ - geom.headFrontZ - 0.05), Color3.fromRGB(20, 20, 24))
end

ACCESSORY_BUILDERS.Wings = function(model, root, build, geom)
	for _, s in ipairs({ -1, 1 }) do
		local cf = CFrame.new(s * (geom.bodySize.X / 2 + 0.5), geom.bodyCenterY + geom.bodySize.Y * 0.35, geom.bodySize.Z * 0.35)
			* CFrame.Angles(0, -s * math.rad(30), s * math.rad(18))
		piece(model, root, "Wing", Vector3.new(2.4, 0.25, 1.1), cf, geom.accent)
	end
end

ACCESSORY_BUILDERS.Antenna = function(model, root, build, geom)
	piece(model, root, "AntennaPole", Vector3.new(0.16, 1.2, 0.16), CFrame.new(0, geom.headTopY + 0.6, geom.headZ), geom.accent)
	piece(model, root, "AntennaBall", Vector3.new(0.34, 0.34, 0.34), CFrame.new(0, geom.headTopY + 1.3, geom.headZ), geom.accent, nil, Enum.PartType.Ball)
end

ACCESSORY_BUILDERS.Bowtie = function(model, root, build, geom)
	local color = build.accentColor or Color3.fromRGB(220, 60, 60)
	local y = geom.bodyCenterY + geom.bodySize.Y * 0.18
	local z = geom.bodyFrontZ - 0.06
	piece(model, root, "TieL", Vector3.new(0.5, 0.32, 0.18), CFrame.new(-0.3, y, z), color)
	piece(model, root, "TieR", Vector3.new(0.5, 0.32, 0.18), CFrame.new(0.3, y, z), color)
	piece(model, root, "TieKnot", Vector3.new(0.22, 0.22, 0.22), CFrame.new(0, y, z - 0.06), color)
end

ACCESSORY_BUILDERS.Mohawk = function(model, root, build, geom)
	local color = build.accentColor or Color3.fromRGB(230, 80, 80)
	local heights = { 0.7, 1.0, 0.7 }
	local offsets = { -0.34, 0, 0.34 }
	for i = 1, 3 do
		piece(model, root, "Mohawk" .. i, Vector3.new(0.3, heights[i], 0.3), CFrame.new(offsets[i], geom.headTopY + heights[i] / 2 - 0.06, geom.headZ), color)
	end
end

ACCESSORY_BUILDERS.Halo = function(model, root, build, geom)
	piece(model, root, "Halo", Vector3.new(0.28, 2.0, 2.0), CFrame.new(0, geom.headTopY + 0.65, geom.headZ) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 200, 60), Enum.Material.Neon, Enum.PartType.Cylinder)
end

ACCESSORY_BUILDERS.Snout = function(model, root, build, geom)
	local color = build.snoutColor or Color3.fromRGB(255, 150, 40)
	local z = geom.headZ - geom.headFrontZ - 0.35
	piece(model, root, "Snout", Vector3.new(0.9, 0.5, 0.8), CFrame.new(0, geom.headCenterY - geom.headSize.Y * 0.12, z), color)
end

ACCESSORY_BUILDERS.Wheels = function(model, root, build, geom)
	local black = Color3.fromRGB(35, 35, 40)
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			local cf = CFrame.new(sx * (geom.bodySize.X / 2), GROUND + 0.55, sz * (geom.bodySize.Z / 2 - 0.3))
			piece(model, root, "Wheel", Vector3.new(0.5, 1.1, 1.1), cf, black, nil, Enum.PartType.Cylinder)
		end
	end
end

ACCESSORY_BUILDERS.Arms = function(model, root, build, geom)
	for _, s in ipairs({ -1, 1 }) do
		piece(model, root, "Arm", Vector3.new(0.7, 2.0, 0.8), CFrame.new(s * (geom.bodySize.X / 2 + 0.4), geom.bodyCenterY - 0.1, 0) * CFrame.Angles(0, 0, s * math.rad(10)), build.bodyColor)
	end
end

ACCESSORY_BUILDERS.Tentacles = function(model, root, build, geom)
	for i = 0, 3 do
		local a = (i / 4) * math.pi * 2
		local cf = CFrame.new(math.cos(a) * 0.95, geom.bodyBottom - 0.45, math.sin(a) * 0.95)
			* CFrame.Angles(0, -a, 0)
			* CFrame.Angles(math.rad(24), 0, 0)
		piece(model, root, "Tentacle" .. i, Vector3.new(0.55, 1.7, 0.55), cf, build.bodyColor)
	end
end

ACCESSORY_BUILDERS.Ring = function(model, root, build, geom)
	local ring = piece(model, root, "Ring", Vector3.new(0.45, 4.8, 4.8), CFrame.new(0, geom.bodyCenterY, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 200, 60), Enum.Material.Neon, Enum.PartType.Cylinder)
	ring.Transparency = 0.25
end

-- Mutations ------------------------------------------------------------------

local function startRainbow(body)
	local colors = {}
	for i = 0, 5 do
		table.insert(colors, Color3.fromHSV(i / 6, 0.75, 1))
	end
	local index = 0
	local function step()
		if body.Parent == nil then
			return
		end
		index = index + 1
		if index > #colors then
			index = 1
		end
		local tween = TweenService:Create(body, TweenInfo.new(0.7, Enum.EasingStyle.Linear), { Color = colors[index] })
		tween.Completed:Connect(function(state)
			if state == Enum.PlaybackState.Completed then
				step()
			end
		end)
		tween:Play()
	end
	step()
end

local function applyMutation(body, build, mutation)
	if mutation == "Gold" then
		body.Color = build.bodyColor:Lerp(Color3.fromRGB(255, 200, 40), 0.65)
	elseif mutation == "Rainbow" then
		startRainbow(body)
	end
end

-- World-space label ----------------------------------------------------------

local function buildLabel(head, entry, mutation)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(190, mutation ~= nil and 104 or 84)
	gui.StudsOffset = Vector3.new(0, head.Size.Y / 2 + 1.6, 0)
	gui.MaxDistance = 90
	gui.LightInfluence = 0
	gui.Adornee = head

	local function line(text, y, height, color, fontSize)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, height)
		label.Position = UDim2.new(0, 0, 0, y)
		label.Font = Enum.Font.FredokaOne
		label.Text = text
		label.TextSize = fontSize
		label.TextScaled = true
		label.TextColor3 = color
		label.TextStrokeTransparency = 0.25
		label.Parent = gui
		return label
	end

	local multiplier = 1
	if mutation == "Gold" then
		multiplier = 2
	elseif mutation == "Rainbow" then
		multiplier = 5
	end

	line(entry.name, 0, 30, Color3.new(1, 1, 1), 20)
	line(Rarity.tag(entry.rarity), 30, 24, Rarity.color(entry.rarity), 16)
	line(Format.rate(entry.income * multiplier), 54, 24, Color3.fromRGB(190, 255, 190), 16)
	if mutation ~= nil then
		local tag = line(mutation == "Gold" and "GOLD x2" or "RAINBOW x5", 78, 24, Color3.fromRGB(255, 200, 40), 16)
		if mutation == "Rainbow" then
			local gradient = Instance.new("UIGradient")
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 255, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 160, 255)),
			})
			gradient.Parent = tag
		end
	end

	gui.Parent = head
	return gui
end

-- The bob-and-spin loop: one tween up with a half turn, one tween back down.

local function startLoop(handle, baseCF)
	local root = handle.root
	local info = TweenInfo.new(BOB_HALF_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local upCF = baseCF * CFrame.new(0, BOB_HEIGHT, 0) * CFrame.Angles(0, math.pi, 0)
	local upTween = TweenService:Create(root, info, { CFrame = upCF })
	local downTween = TweenService:Create(root, info, { CFrame = baseCF })
	local connUp = upTween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			downTween:Play()
		end
	end)
	local connDown = downTween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			upTween:Play()
		end
	end)
	handle.connections = { connUp, connDown }
	handle.tweens = { upTween, downTween }
	upTween:Play()
end

local function stopLoop(handle)
	for _, conn in ipairs(handle.connections or {}) do
		conn:Disconnect()
	end
	for _, tween in ipairs(handle.tweens or {}) do
		tween:Cancel()
	end
	handle.connections = nil
	handle.tweens = nil
end

-- spawn ----------------------------------------------------------------------

function BrainrotFactory.spawn(entry, mutation, anchor)
	local build = entry.build
	local geom = geometry(build)

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1.2, 0.4, 1.2)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = true
	root.CFrame = anchor * CFrame.new(0, 0.2, 0)

	local model = Instance.new("Model")
	model.Name = entry.name

	local body = buildBody(model, root, build, geom)
	local head = piece(model, root, "Head", build.headSize, CFrame.new(0, geom.headCenterY, geom.headZ), build.headColor, nil, SHAPES[build.headShape] or Enum.PartType.Ball)
	addEyes(model, root, build, geom)
	for _, accessoryName in ipairs(build.accessories or {}) do
		local builder = ACCESSORY_BUILDERS[accessoryName]
		if builder then
			builder(model, root, build, geom)
		end
	end
	buildLabel(head, entry, mutation)

	model.PrimaryPart = root
	-- Freeze every part at its welded offset from the root, so the model is
	-- always assembled where the root stands (never falls through the world).
	for _, piece in ipairs(model:GetDescendants()) do
		if piece:IsA("BasePart") then
			local rootWeld = piece:FindFirstChild("RootWeld")
			if rootWeld and rootWeld:IsA("Weld") then
				piece.CFrame = root.CFrame * rootWeld.C0
			end
			piece.Anchored = true
		end
	end
	model.Parent = folder()

	model:SetAttribute("BrainrotName", entry.name)
	model:SetAttribute("Rarity", entry.rarity)
	model:SetAttribute("BaseIncome", entry.income)
	model:SetAttribute("Mutation", mutation or "")
	model:SetAttribute("OwnerId", 0)

	applyMutation(body, build, mutation)

	local handle = {
		model = model,
		root = root,
		entry = entry,
		mutation = mutation,
		income = entry.income,
	}
	handle.stop = function()
		stopLoop(handle)
	end
	handle.play = function(base)
		startLoop(handle, base)
	end
	model.Destroying:Connect(function()
		stopLoop(handle)
	end)
	startLoop(handle, root.CFrame)
	return handle
end

-- Fly a model to a new pedestal in a little arc, then resume the bob loop.

function BrainrotFactory.flyTo(handle, targetAnchor, seconds, onDone)
	stopLoop(handle)
	local root = handle.root
	local start = root.CFrame
	local target = targetAnchor * CFrame.new(0, 0.2, 0)
	local lift = start:Lerp(target, 0.5) + Vector3.new(0, 7, 0)
	local first = TweenService:Create(root, TweenInfo.new(seconds / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = lift })
	local second = TweenService:Create(root, TweenInfo.new(seconds / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { CFrame = target })
	first.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			second:Play()
		end
	end)
	second.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			startLoop(handle, target)
			if onDone then
				onDone()
			end
		end
	end)
	first:Play()
end

return BrainrotFactory
