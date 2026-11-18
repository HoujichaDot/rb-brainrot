-- WorldBuilder: builds the place out of anchored parts. It returns the plot,
-- shop-pedestal and shrine data the services animate: BRAINROT BONANZA plaza,
-- four ring plots with six slots each and a shield pad, the Brainrot Shop row,
-- Thief Alley, the ocean plane and the lighting mood.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Rarity = require(Shared.Rarity)

local WorldBuilder = {}

local DARK = Color3.fromRGB(38, 40, 52)
local NEON = Color3.fromRGB(80, 220, 255)
local GOLD = Color3.fromRGB(255, 205, 80)

local function newPart(parent, name, size, cf, color, material, opts)
	opts = opts or {}
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if opts.transparency then
		part.Transparency = opts.transparency
	end
	if opts.canCollide == false then
		part.CanCollide = false
	end
	if opts.reflectance then
		part.Reflectance = opts.reflectance
	end
	if opts.shape then
		part.Shape = opts.shape
	end
	part.Parent = parent
	return part
end

local function makeSign(parent, name, size, cf, text, textColor, backgroundColor, pixelsPerStud)
	local part = newPart(parent, name, size, cf, backgroundColor, Enum.Material.SmoothPlastic)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "SignGui"
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = pixelsPerStud or 50
	surface.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.Size = UDim2.fromScale(0.94, 0.9)
	label.Position = UDim2.fromScale(0.03, 0.05)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor
	label.Parent = surface
	return part, label
end

local function addBillboard(part, name, offset, size, text, textColor, backgroundColor)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = name
	billboard.Adornee = part
	billboard.Size = size
	billboard.StudsOffset = offset
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 220
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = backgroundColor or Color3.fromRGB(14, 16, 26)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(0.92, 0.84)
	label.Position = UDim2.fromScale(0.04, 0.08)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	label.Parent = frame
	billboard.Parent = part
	return billboard, label
end

local function buildLighting()
	Lighting.ClockTime = 15.4
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(76, 86, 108)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 148, 176)
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.55
	Lighting.ShadowSoftness = 0.25
	Lighting.GeographicLatitude = 18
	Lighting.FogStart = 300
	Lighting.FogEnd = 1400
	Lighting.FogColor = Color3.fromRGB(158, 206, 240)

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "BrainrotAir"
	atmosphere.Density = 0.32
	atmosphere.Haze = 1.6
	atmosphere.Color = Color3.fromRGB(200, 224, 255)
	atmosphere.Decay = Color3.fromRGB(110, 140, 180)
	atmosphere.Glare = 0.2
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "NeonBloom"
	bloom.Intensity = 0.7
	bloom.Size = 36
	bloom.Threshold = 1.1
	bloom.Parent = Lighting
end

local function buildOcean(world)
	local size = GameConfig.World.OceanSize
	newPart(world.root, "OceanPlane", Vector3.new(size, 2, size), CFrame.new(0, GameConfig.World.OceanY, 0), Color3.fromRGB(28, 108, 168), Enum.Material.SmoothPlastic, {
		transparency = 0.12,
		canCollide = false,
		reflectance = 0.22,
	})
end

local function buildGround(world)
	local size = GameConfig.World.GroundSize
	newPart(world.root, "IslandGround", Vector3.new(size, 6, size), CFrame.new(0, -3, 0), Color3.fromRGB(88, 158, 92), Enum.Material.Grass)
	newPart(world.root, "SandRim", Vector3.new(size + 10, 1, size + 10), CFrame.new(0, -3.6, 0), Color3.fromRGB(212, 194, 142), Enum.Material.Sand, {
		canCollide = false,
	})
end

local function buildPlaza(world)
	local plazaSize = GameConfig.World.PlazaSize
	newPart(world.root, "SpawnPlaza", Vector3.new(plazaSize, 1, plazaSize), CFrame.new(0, 0, 0), Color3.fromRGB(104, 118, 148))

	newPart(world.root, "PlazaRing", Vector3.new(0.4, 30, 30), CFrame.new(0, 0.58, 0) * CFrame.Angles(0, 0, math.rad(90)), NEON, Enum.Material.Neon, {
		canCollide = false,
		transparency = 0.35,
		shape = Enum.PartType.Cylinder,
	})
	newPart(world.root, "PlazaDisc", Vector3.new(0.4, 18, 18), CFrame.new(0, 0.56, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(70, 84, 112), Enum.Material.SmoothPlastic, {
		canCollide = false,
		shape = Enum.PartType.Cylinder,
	})

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "BonanzaSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(GameConfig.World.SpawnPosition)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(64, 200, 255)
	spawn.Material = Enum.Material.Neon
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.Parent = world.root

	-- The welcome sign faces the plaza.
	local signCFrame = CFrame.lookAt(Vector3.new(0, 9, -36), Vector3.new(0, 9, 0))
	makeSign(world.root, "BonanzaSign", Vector3.new(50, 12, 1.2), signCFrame, "BRAINROT BONANZA", GOLD, Color3.fromRGB(22, 20, 34), 60)

	for _, x in ipairs({ -22, 22 }) do
		newPart(world.root, "SignPole", Vector3.new(1.4, 12, 1.4), CFrame.new(x, 4, -36), DARK, Enum.Material.Metal)
	end
	newPart(world.root, "SignLampBar", Vector3.new(50, 0.5, 0.5), CFrame.new(0, 15.2, -36), NEON, Enum.Material.Neon, {
		canCollide = false,
	})

	for index = 1, 4 do
		local angle = math.rad(45 + (index - 1) * 90)
		local position = Vector3.new(math.cos(angle) * 30, 0, math.sin(angle) * 30)
		newPart(world.root, "LampPost", Vector3.new(1, 12, 1), CFrame.new(position + Vector3.new(0, 6, 0)), Color3.fromRGB(46, 50, 62), Enum.Material.Metal)
		local bulb = newPart(world.root, "LampBulb", Vector3.new(2.2, 2.2, 2.2), CFrame.new(position + Vector3.new(0, 12.6, 0)), NEON, Enum.Material.Neon, {
			shape = Enum.PartType.Ball,
			canCollide = false,
		})
		local light = Instance.new("PointLight")
		light.Color = NEON
		light.Brightness = 1.4
		light.Range = 26
		light.Parent = bulb
	end
end

local function buildPlot(world, index)
	local plotConfig = GameConfig.Plot
	local angle = math.rad(plotConfig.RingStartAngle + (index - 1) * 360 / plotConfig.Count)
	local position = Vector3.new(math.cos(angle) * plotConfig.RingRadius, 0, math.sin(angle) * plotConfig.RingRadius)
	local cf = CFrame.lookAt(position, Vector3.new(0, 0, 0))

	local plot = {
		index = index,
		cf = cf,
		center = position,
		slots = {},
		lockedUntil = 0,
		ownerPlayer = nil,
	}

	newPart(world.root, "PlotPlatform", Vector3.new(plotConfig.Width, 1, plotConfig.Depth), cf, Color3.fromRGB(96, 92, 120))

	local halfDepth = plotConfig.Depth / 2
	newPart(world.root, "PlotTrimFront", Vector3.new(plotConfig.Width, 0.25, 0.6), cf * CFrame.new(0, 0.55, halfDepth - 0.3), NEON, Enum.Material.Neon, {
		canCollide = false,
		transparency = 0.25,
	})
	newPart(world.root, "PlotTrimBack", Vector3.new(plotConfig.Width, 0.25, 0.6), cf * CFrame.new(0, 0.55, -halfDepth + 0.3), NEON, Enum.Material.Neon, {
		canCollide = false,
		transparency = 0.25,
	})

	for slotIndex = 1, plotConfig.SlotCount do
		local offsetX = (slotIndex - (plotConfig.SlotCount + 1) / 2) * plotConfig.SlotSpacing
		local pedestalCF = cf * CFrame.new(offsetX, 1.1, 0)
		newPart(world.root, "PlotPedestal", Vector3.new(4, 1.2, 4), pedestalCF, Color3.fromRGB(64, 68, 88))
		local top = newPart(world.root, "PlotPedestalTop", Vector3.new(3.2, 0.3, 3.2), pedestalCF * CFrame.new(0, 0.6, 0), Color3.fromRGB(150, 156, 186), Enum.Material.SmoothPlastic, {
			canCollide = false,
		})
		table.insert(plot.slots, {
			anchor = cf * CFrame.new(offsetX, plotConfig.AnchorHeight, 0),
			pedestal = top,
			record = nil,
		})
	end

	-- Name sign at the inner edge, facing the plaza.
	local signPosition = cf * CFrame.new(0, 0, -halfDepth - 5)
	local signCF = CFrame.lookAt(Vector3.new(signPosition.X, 8.2, signPosition.Z), Vector3.new(0, 8.2, 0))
	local _, nameLabel = makeSign(world.root, "PlotNameSign", Vector3.new(13, 4.4, 0.6), signCF, "PLOT " .. index .. "\nVACANT", Color3.fromRGB(235, 240, 255), Color3.fromRGB(28, 30, 46), 55)

	for _, offset in ipairs({ -5, 5 }) do
		local polePosition = cf * CFrame.new(offset, 0, -halfDepth - 5)
		newPart(world.root, "PlotSignPole", Vector3.new(0.8, 6, 0.8), CFrame.new(polePosition.X, 3, polePosition.Z), DARK, Enum.Material.Metal)
	end

	local padCF = cf * CFrame.new(14, 0.9, -halfDepth - 1.4)
	local pad = newPart(world.root, "ShieldPad", Vector3.new(3, 1.8, 3), padCF, Color3.fromRGB(52, 56, 72), Enum.Material.Metal)
	local padTop = newPart(world.root, "ShieldPadTop", Vector3.new(2.2, 0.3, 2.2), padCF * CFrame.new(0, 0.95, 0), NEON, Enum.Material.Neon, {
		canCollide = false,
	})
	local glow = Instance.new("PointLight")
	glow.Color = NEON
	glow.Brightness = 1.2
	glow.Range = 14
	glow.Parent = padTop

	local _, lockLabel = addBillboard(pad, "ShieldStatus", Vector3.new(0, 4.2, 0), UDim2.fromOffset(190, 46), "SHIELD: OFF", NEON, Color3.fromRGB(18, 20, 30))

	plot.nameSign = nameLabel
	plot.lockPad = pad
	plot.lockSign = lockLabel
	return plot
end

local function buildShop(world)
	local rowZ = GameConfig.ShopRowZ
	local width = 104
	local depth = 26
	local spacing = 13

	newPart(world.root, "ShopFloor", Vector3.new(width, 1, depth), CFrame.new(0, 0, rowZ), Color3.fromRGB(70, 62, 104))
	newPart(world.root, "ShopBackWall", Vector3.new(width, 18, 2), CFrame.new(0, 9, rowZ + depth / 2 - 1), Color3.fromRGB(40, 36, 66), Enum.Material.Slate)
	newPart(world.root, "ShopNeonStrip", Vector3.new(width - 4, 0.6, 0.6), CFrame.new(0, 15, rowZ + depth / 2 - 2.2), Color3.fromRGB(255, 90, 190), Enum.Material.Neon, {
		canCollide = false,
	})

	local signCF = CFrame.lookAt(Vector3.new(0, 12.6, rowZ + depth / 2 - 2.4), Vector3.new(0, 12.6, rowZ - 20))
	makeSign(world.root, "ShopSign", Vector3.new(56, 7, 0.8), signCF, "BRAINROT SHOP", Color3.fromRGB(255, 110, 210), Color3.fromRGB(24, 20, 40), 60)

	for index, tier in ipairs(GameConfig.ShopTiers) do
		local offsetX = (index - 3.5) * spacing
		local pedestalCF = CFrame.new(offsetX, 1.2, rowZ - 2)
		local pad = newPart(world.root, "ShopPedestal", Vector3.new(5, 1.4, 5), pedestalCF, Color3.fromRGB(52, 48, 76))
		newPart(world.root, "ShopPedestalTop", Vector3.new(4.2, 0.3, 4.2), pedestalCF * CFrame.new(0, 0.7, 0), Rarity.color(tier), Enum.Material.Neon, {
			canCollide = false,
			transparency = 0.3,
		})
		local _, tierLabel = addBillboard(pad, "CrateLabel", Vector3.new(0, 7.4, 0), UDim2.fromOffset(180, 54), string.upper(tier), Rarity.color(tier))

		table.insert(world.shopPedestals, {
			index = index,
			tier = tier,
			pad = pad,
			anchor = CFrame.new(offsetX, 1.9, rowZ - 2),
			signLabel = tierLabel,
		})
	end
end

local function buildAlley(world)
	local alleyX = 170
	newPart(world.root, "AlleyFloor", Vector3.new(30, 1, 110), CFrame.new(alleyX, 0, 0), Color3.fromRGB(58, 52, 58), Enum.Material.Concrete)
	for _, offset in ipairs({ -15, 15 }) do
		newPart(world.root, "AlleyWall", Vector3.new(2, 16, 110), CFrame.new(alleyX + offset, 8, 0), Color3.fromRGB(34, 30, 38), Enum.Material.Brick)
	end
	newPart(world.root, "AlleyArch", Vector3.new(32, 2, 3), CFrame.new(alleyX, 16, -55), Color3.fromRGB(28, 24, 32), Enum.Material.Brick)

	local signCF = CFrame.lookAt(Vector3.new(alleyX, 11.5, -55.2), Vector3.new(alleyX, 11.5, 0))
	makeSign(world.root, "AlleySign", Vector3.new(24, 6, 0.6), signCF, "THIEF ALLEY", Color3.fromRGB(255, 76, 92), Color3.fromRGB(18, 12, 18), 60)

	for index = 4, 86, 26 do
		newPart(world.root, "AlleyLamp", Vector3.new(1.2, 1.2, 1.2), CFrame.new(alleyX - 12, 6, index - 50), Color3.fromRGB(255, 70, 90), Enum.Material.Neon, {
			shape = Enum.PartType.Ball,
			canCollide = false,
		})
	end
end

local function buildPaths(world)
	local pathColor = Color3.fromRGB(146, 150, 172)
	local function path(from, to, width)
		local midpoint = (from + to) / 2
		local length = (to - from).Magnitude
		local cf = CFrame.lookAt(Vector3.new(midpoint.X, 0.57, midpoint.Z), Vector3.new(to.X, 0.57, to.Z))
		newPart(world.root, "WalkPath", Vector3.new(width, 0.2, length), cf, pathColor, Enum.Material.SmoothPlastic, {
			canCollide = false,
		})
	end
	for index = 1, GameConfig.Plot.Count do
		local angle = math.rad(GameConfig.Plot.RingStartAngle + (index - 1) * 360 / GameConfig.Plot.Count)
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		path(direction * 36, direction * 92, 10)
	end
	path(Vector3.new(0, 0, 36), Vector3.new(0, 0, 158), 12)
end

local function buildShrine(world)
	local position = Vector3.new(28, 0, -14)
	newPart(world.root, "ShrineBase", Vector3.new(8, 1.2, 8), CFrame.new(position + Vector3.new(0, 0.6, 0)), Color3.fromRGB(70, 60, 44), Enum.Material.Marble)
	local pad = newPart(world.root, "ShrinePad", Vector3.new(5, 1.4, 5), CFrame.new(position + Vector3.new(0, 1.9, 0)), Color3.fromRGB(96, 82, 58), Enum.Material.Marble)
	newPart(world.root, "ShrineTorso", Vector3.new(2.4, 3.2, 1.8), CFrame.new(position + Vector3.new(0, 4.2, 0)), GOLD, Enum.Material.Neon, {
		canCollide = false,
	})
	newPart(world.root, "ShrineHead", Vector3.new(1.9, 1.9, 1.9), CFrame.new(position + Vector3.new(0, 6.8, 0)), GOLD, Enum.Material.Neon, {
		canCollide = false,
		shape = Enum.PartType.Ball,
	})
	for _, offset in ipairs({ -1.7, 1.7 }) do
		newPart(world.root, "ShrineArm", Vector3.new(0.8, 2.6, 0.8), CFrame.new(position + Vector3.new(offset, 4.4, 0)), GOLD, Enum.Material.Neon, {
			canCollide = false,
		})
	end
	newPart(world.root, "ShrineCrown", Vector3.new(2.6, 0.6, 2.6), CFrame.new(position + Vector3.new(0, 7.9, 0)), Color3.fromRGB(255, 120, 60), Enum.Material.Neon, {
		canCollide = false,
	})

	addBillboard(pad, "ShrineSign", Vector3.new(0, 6.4, 0), UDim2.fromOffset(260, 70), "REBIRTH SHRINE\n+25% INCOME PER REBIRTH", GOLD)
	world.shrinePad = pad
end

function WorldBuilder.build()
	local folder = Instance.new("Folder")
	folder.Name = "World"
	folder.Parent = Workspace

	local world = {
		root = folder,
		plots = {},
		shopPedestals = {},
	}

	buildLighting()
	buildOcean(world)
	buildGround(world)
	buildPlaza(world)
	for index = 1, GameConfig.Plot.Count do
		world.plots[index] = buildPlot(world, index)
	end
	buildShop(world)
	buildAlley(world)
	buildPaths(world)
	buildShrine(world)

	return world
end

return WorldBuilder
