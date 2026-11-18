-- Rarity: the ladder, its colours, shop-facing labels and helper lookups.

local Rarity = {}

Rarity.Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" }

Rarity.Tiers = {
	Common = {
		rank = 1,
		color = Color3.fromRGB(186, 190, 196),
		blurb = "Grey, sad, and somehow still profitable.",
	},
	Uncommon = {
		rank = 2,
		color = Color3.fromRGB(86, 214, 116),
		blurb = "Green means it has a hobby.",
	},
	Rare = {
		rank = 3,
		color = Color3.fromRGB(74, 150, 255),
		blurb = "Blue rarity, big opinions.",
	},
	Epic = {
		rank = 4,
		color = Color3.fromRGB(178, 96, 255),
		blurb = "Purple aura. Questionable smell.",
	},
	Legendary = {
		rank = 5,
		color = Color3.fromRGB(255, 152, 42),
		blurb = "Legends say it pays the rent.",
	},
	Mythic = {
		rank = 6,
		color = Color3.fromRGB(255, 62, 72),
		blurb = "Red flag, green numbers.",
	},
	Secret = {
		rank = 7,
		color = Color3.fromRGB(255, 214, 82),
		blurb = "Statistically impossible. You did it anyway.",
	},
}

function Rarity.get(tier)
	return Rarity.Tiers[tier] or Rarity.Tiers.Common
end

function Rarity.color(tier)
	return Rarity.get(tier).color
end

function Rarity.rank(tier)
	return Rarity.get(tier).rank
end

function Rarity.tag(tier)
	return string.upper(tostring(tier))
end

function Rarity.blurb(tier)
	return Rarity.get(tier).blurb
end

local INCOME_RANGES = {
	Common = "1-2/s",
	Uncommon = "4/s",
	Rare = "12/s",
	Epic = "40/s",
	Legendary = "130/s",
	Mythic = "420/s",
	Secret = "1500/s",
}

function Rarity.incomeRange(tier)
	return INCOME_RANGES[tier] or "?"
end

return Rarity
