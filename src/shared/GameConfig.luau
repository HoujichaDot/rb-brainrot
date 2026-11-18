-- GameConfig: every tuning number for Brainrot Bonanza, in one place. The
-- server simulation, the world builder and the client HUD all read this module.

local GameConfig = {}

GameConfig.GameName = "BRAINROT BONANZA"
GameConfig.StartingCash = 75

-- Economy
GameConfig.IncomeTickSeconds = 1
GameConfig.ShopRestockSeconds = 12

-- Plot shield
GameConfig.LockCost = 300
GameConfig.LockDurationSeconds = 60

-- Mutations (rolled on every purchase)
GameConfig.RainbowChance = 0.03
GameConfig.RainbowMultiplier = 5
GameConfig.GoldChance = 0.10
GameConfig.GoldMultiplier = 2
GameConfig.SecretFromMythicChance = 0.08

-- Stealing
GameConfig.StealHoldSeconds = 3
GameConfig.StealGraceSeconds = 8
GameConfig.StealCashOutSeconds = 25
GameConfig.StealMaxDistance = 14

-- Tsunami
GameConfig.TsunamiIntervalSeconds = 90
GameConfig.TsunamiWarningSeconds = 10
GameConfig.TsunamiSweepSeconds = 7
GameConfig.TsunamiBandHalf = 12
GameConfig.TsunamiStartZ = -220
GameConfig.TsunamiEndZ = 220

-- Rebirth
GameConfig.RebirthBaseCost = 2500
GameConfig.RebirthGrowth = 4
GameConfig.RebirthIncomeBonus = 0.25

function GameConfig.rebirthCost(rebirths)
	return math.floor(GameConfig.RebirthBaseCost * GameConfig.RebirthGrowth ^ (rebirths or 0))
end

function GameConfig.rebirthMultiplier(rebirths)
	return 1 + (rebirths or 0) * GameConfig.RebirthIncomeBonus
end

-- The four plots around the plaza.
GameConfig.Plot = {
	Count = 4,
	RingRadius = 110,
	RingStartAngle = 45,
	SlotCount = 6,
	SlotSpacing = 7,
	Width = 46,
	Depth = 26,
	AnchorHeight = 1.85,
}

-- The map.
GameConfig.World = {
	OceanSize = 1600,
	OceanY = -4,
	GroundSize = 420,
	PlazaSize = 70,
	SpawnPosition = Vector3.new(0, 0.55, 6),
}

GameConfig.ShopRowZ = 170
GameConfig.ShopTiers = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }

return GameConfig
