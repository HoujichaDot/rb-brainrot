-- BrainrotCatalog: the cast. 21 original brainrots across the seven tiers, each
-- carrying its price, income and the part recipe the factory assembles into a
-- 3D model (body/head shapes and colours, eyes, and silly accessories).

local BrainrotCatalog = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

BrainrotCatalog.Entries = {
	-- ----------------------------------------------------------------- Common
	{
		id = "soggy_steve",
		name = "Soggy Spaghetti Steve",
		rarity = "Common",
		income = 2,
		price = 30,
		build = {
			bodySize = Vector3.new(2.2, 1.5, 1.4),
			bodyColor = rgb(196, 142, 88),
			headSize = Vector3.new(1.9, 1.7, 1.6),
			headColor = rgb(226, 184, 126),
			headShape = "Ball",
			accessories = { "TopHat", "Sunglasses" },
			accentColor = rgb(236, 232, 220),
		},
	},
	{
		id = "wobbly_bog_frog",
		name = "Wobbly Bog Frog",
		rarity = "Common",
		income = 1,
		price = 25,
		build = {
			bodySize = Vector3.new(2.0, 1.1, 1.9),
			bodyColor = rgb(92, 158, 82),
			bodyShape = "Ball",
			headSize = Vector3.new(1.9, 1.1, 1.6),
			headColor = rgb(122, 190, 100),
			eyeStyle = "Top",
			headShape = "Ball",
			legs = true,
			accessories = { "Bowtie" },
			accentColor = rgb(220, 70, 70),
		},
	},
	{
		id = "sock_goblin",
		name = "Stinky Sock Goblin",
		rarity = "Common",
		income = 2,
		price = 40,
		build = {
			bodySize = Vector3.new(1.6, 1.9, 1.3),
			bodyColor = rgb(160, 162, 168),
			headSize = Vector3.new(1.5, 1.5, 1.3),
			headColor = rgb(198, 200, 204),
			legs = true,
			accessories = { "Mohawk", "Wings" },
			accentColor = rgb(200, 220, 235),
		},
	},
	{
		id = "grumpy_gummy_rat",
		name = "Grumpy Gummy Rat",
		rarity = "Common",
		income = 1,
		price = 35,
		build = {
			bodySize = Vector3.new(1.5, 1.4, 1.6),
			bodyColor = rgb(255, 128, 170),
			headSize = Vector3.new(1.4, 1.3, 1.3),
			headColor = rgb(255, 168, 200),
			headShape = "Ball",
			legs = true,
			accessories = { "Snout" },
			snoutColor = rgb(255, 220, 232),
		},
	},

	-- --------------------------------------------------------------- Uncommon
	{
		id = "toaster_tina",
		name = "Toaster Tango Tina",
		rarity = "Uncommon",
		income = 4,
		price = 150,
		build = {
			bodySize = Vector3.new(1.8, 1.6, 1.4),
			bodyColor = rgb(176, 182, 190),
			bodyMaterial = "Metal",
			headSize = Vector3.new(1.8, 1.2, 1.4),
			headColor = rgb(214, 218, 224),
			accessories = { "Antenna", "Sunglasses" },
			accentColor = rgb(230, 90, 70),
		},
	},
	{
		id = "baguette_boy",
		name = "Bombastic Baguette Boy",
		rarity = "Uncommon",
		income = 4,
		price = 170,
		build = {
			bodySize = Vector3.new(1.8, 1.8, 1.2),
			bodyColor = rgb(212, 166, 94),
			headSize = Vector3.new(1.5, 1.5, 1.2),
			headColor = rgb(236, 198, 132),
			legs = true,
			accessories = { "Bowtie", "TopHat" },
			accentColor = rgb(226, 86, 76),
		},
	},
	{
		id = "wet_sock_wizard",
		name = "Wet Sock Wizard",
		rarity = "Uncommon",
		income = 4,
		price = 160,
		build = {
			bodySize = Vector3.new(1.7, 1.7, 1.4),
			bodyColor = rgb(102, 84, 168),
			headSize = Vector3.new(1.6, 1.5, 1.4),
			headColor = rgb(168, 148, 226),
			accessories = { "TopHat", "Antenna" },
			accentColor = rgb(110, 230, 255),
		},
	},

	-- ------------------------------------------------------------------- Rare
	{
		id = "mango_mike",
		name = "Mango Motorcycle Mike",
		rarity = "Rare",
		income = 12,
		price = 700,
		build = {
			bodySize = Vector3.new(2.0, 1.6, 1.6),
			bodyColor = rgb(250, 158, 46),
			headSize = Vector3.new(1.7, 1.5, 1.5),
			headColor = rgb(255, 196, 92),
			headShape = "Ball",
			accessories = { "Wheels", "Sunglasses" },
			accentColor = rgb(235, 235, 240),
		},
	},
	{
		id = "caffeinated_capybara",
		name = "Caffeinated Capybara",
		rarity = "Rare",
		income = 12,
		price = 750,
		build = {
			bodySize = Vector3.new(2.2, 1.5, 1.7),
			bodyColor = rgb(150, 106, 68),
			headSize = Vector3.new(1.7, 1.5, 1.6),
			headColor = rgb(186, 140, 96),
			headShape = "Block",
			legs = true,
			accessories = { "Bowtie", "Sunglasses" },
			accentColor = rgb(255, 80, 80),
		},
	},
	{
		id = "disco_dumpster",
		name = "Disco Dumpster Diver",
		rarity = "Rare",
		income = 12,
		price = 650,
		build = {
			bodySize = Vector3.new(2.1, 1.7, 1.5),
			bodyColor = rgb(52, 158, 146),
			bodyMaterial = "Metal",
			headSize = Vector3.new(1.8, 1.4, 1.5),
			headColor = rgb(94, 200, 184),
			accessories = { "Ring", "Sunglasses" },
			accentColor = rgb(255, 210, 90),
		},
	},

	-- ------------------------------------------------------------------- Epic
	{
		id = "turbo_tuna",
		name = "Turbo Toilet Tuna",
		rarity = "Epic",
		income = 40,
		price = 2900,
		build = {
			bodySize = Vector3.new(2.4, 1.4, 1.5),
			bodyColor = rgb(64, 120, 196),
			headSize = Vector3.new(1.7, 1.4, 1.7),
			headColor = rgb(104, 164, 232),
			headShape = "Ball",
			accessories = { "Ring", "Sunglasses" },
			accentColor = rgb(240, 240, 250),
		},
	},
	{
		id = "cosmic_corn",
		name = "Cosmic Corn Cob",
		rarity = "Epic",
		income = 40,
		price = 3100,
		build = {
			bodySize = Vector3.new(1.4, 2.3, 1.4),
			bodyColor = rgb(246, 210, 74),
			bodyShape = "Cylinder",
			headSize = Vector3.new(1.5, 1.3, 1.4),
			headColor = rgb(255, 234, 132),
			headShape = "Ball",
			accessories = { "Halo" },
			accentColor = rgb(255, 255, 210),
		},
	},
	{
		id = "sneaker_shark",
		name = "Sneaker Shark",
		rarity = "Epic",
		income = 40,
		price = 3000,
		build = {
			bodySize = Vector3.new(2.3, 1.3, 1.5),
			bodyColor = rgb(96, 118, 140),
			headSize = Vector3.new(1.8, 1.2, 1.7),
			headColor = rgb(140, 164, 188),
			headPos = "Front",
			accessories = { "Wheels", "Snout", "Sunglasses" },
			snoutColor = rgb(220, 226, 234),
			accentColor = rgb(255, 255, 255),
		},
	},

	-- -------------------------------------------------------------- Legendary
	{
		id = "bananaconda",
		name = "Bananaconda",
		rarity = "Legendary",
		income = 130,
		price = 12500,
		build = {
			bodySize = Vector3.new(2.2, 1.8, 1.6),
			bodyColor = rgb(248, 214, 74),
			bodyShape = "Cylinder",
			headSize = Vector3.new(1.8, 1.5, 1.7),
			headColor = rgb(255, 236, 132),
			headShape = "Block",
			accessories = { "Crown", "Sunglasses" },
			accentColor = rgb(255, 205, 60),
		},
	},
	{
		id = "skyscraper_pigeon",
		name = "Skyscraper Pigeon",
		rarity = "Legendary",
		income = 130,
		price = 12000,
		build = {
			bodySize = Vector3.new(1.9, 1.9, 1.5),
			bodyColor = rgb(122, 132, 152),
			headSize = Vector3.new(1.5, 1.4, 1.4),
			headColor = rgb(160, 170, 190),
			legs = true,
			accessories = { "Wings", "TopHat" },
			accentColor = rgb(70, 74, 86),
		},
	},
	{
		id = "volcano_vulture",
		name = "Volcano Vulture",
		rarity = "Legendary",
		income = 130,
		price = 13000,
		build = {
			bodySize = Vector3.new(2.1, 1.7, 1.4),
			bodyColor = rgb(168, 58, 44),
			headSize = Vector3.new(1.6, 1.4, 1.5),
			headColor = rgb(212, 92, 62),
			headShape = "Ball",
			accessories = { "Wings", "Mohawk", "Snout" },
			snoutColor = rgb(240, 190, 90),
			accentColor = rgb(240, 120, 60),
		},
	},

	-- ----------------------------------------------------------------- Mythic
	{
		id = "hyper_hippo",
		name = "Hyperdimensional Hippo",
		rarity = "Mythic",
		income = 420,
		price = 55000,
		build = {
			bodySize = Vector3.new(2.6, 1.9, 2.0),
			bodyColor = rgb(142, 82, 196),
			headSize = Vector3.new(2.0, 1.7, 1.9),
			headColor = rgb(178, 118, 226),
			headShape = "Ball",
			legs = true,
			accessories = { "Halo", "Wings" },
			accentColor = rgb(255, 110, 220),
		},
	},
	{
		id = "gamer_gorilla",
		name = "Grandmaster Gorilla Gamer",
		rarity = "Mythic",
		income = 420,
		price = 58000,
		build = {
			bodySize = Vector3.new(2.4, 2.0, 1.8),
			bodyColor = rgb(72, 68, 82),
			headSize = Vector3.new(1.9, 1.7, 1.7),
			headColor = rgb(104, 100, 116),
			headShape = "Ball",
			accessories = { "Sunglasses", "Antenna" },
			accentColor = rgb(255, 80, 180),
		},
	},
	{
		id = "sushi_tsunami",
		name = "Sentient Sushi Tsunami",
		rarity = "Mythic",
		income = 420,
		price = 60000,
		build = {
			bodySize = Vector3.new(2.2, 1.6, 1.9),
			bodyColor = rgb(248, 146, 122),
			headSize = Vector3.new(1.8, 1.4, 1.6),
			headColor = rgb(255, 188, 168),
			accessories = { "Crown", "Wings", "Sunglasses" },
			accentColor = rgb(120, 220, 255),
		},
	},

	-- ----------------------------------------------------------------- Secret
	{
		id = "ascended_capybara_prime",
		name = "Ascended Capybara Prime",
		rarity = "Secret",
		income = 1500,
		price = 250000,
		build = {
			bodySize = Vector3.new(2.5, 2.0, 1.9),
			bodyColor = rgb(255, 206, 74),
			bodyMaterial = "Neon",
			headSize = Vector3.new(2.0, 1.8, 1.8),
			headColor = rgb(255, 230, 140),
			headShape = "Ball",
			legs = true,
			accessories = { "Crown", "Halo", "Wings" },
			accentColor = rgb(255, 240, 170),
		},
	},
	{
		id = "final_boss_of_ohio",
		name = "The Final Boss of Ohio",
		rarity = "Secret",
		income = 1500,
		price = 300000,
		build = {
			bodySize = Vector3.new(2.6, 2.1, 1.9),
			bodyColor = rgb(96, 128, 88),
			headSize = Vector3.new(2.0, 1.7, 1.8),
			headColor = rgb(132, 168, 110),
			headShape = "Ball",
			eyeScale = 1.4,
			accessories = { "Mohawk", "Sunglasses", "Wings" },
			accentColor = rgb(180, 255, 140),
		},
	},
}

BrainrotCatalog.ById = {}
BrainrotCatalog.ByRarity = {}

for _, entry in ipairs(BrainrotCatalog.Entries) do
	BrainrotCatalog.ById[entry.id] = entry
	BrainrotCatalog.ByRarity[entry.rarity] = BrainrotCatalog.ByRarity[entry.rarity] or {}
	table.insert(BrainrotCatalog.ByRarity[entry.rarity], entry)
end

function BrainrotCatalog.count()
	return #BrainrotCatalog.Entries
end

function BrainrotCatalog.get(id)
	return BrainrotCatalog.ById[id]
end

function BrainrotCatalog.ofRarity(tier)
	return BrainrotCatalog.ByRarity[tier] or BrainrotCatalog.ByRarity.Common
end

function BrainrotCatalog.randomOf(tier)
	local pool = BrainrotCatalog.ofRarity(tier)
	return pool[math.random(1, #pool)]
end

-- Kept as a clear alias for places that read better with the longer name.
BrainrotCatalog.randomOfRarity = BrainrotCatalog.randomOf

return BrainrotCatalog
