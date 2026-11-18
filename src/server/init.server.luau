-- BRAINROT BONANZA - server boot: builds the world, wires every service and
-- handles players joining and leaving.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Remotes = require(Shared.Remotes)
local Catalog = require(Shared.BrainrotCatalog)

local WorldBuilder = require(script.WorldBuilder)
local PlotService = require(script.PlotService)
local PlayerState = require(script.PlayerState)
local EconomyService = require(script.EconomyService)
local StealService = require(script.StealService)
local TsunamiService = require(script.TsunamiService)
local RebirthService = require(script.RebirthService)

Remotes.initServer()
Players.CharacterAutoLoads = true

local world = WorldBuilder.build()
PlotService.init(world)
PlotService.startLockLoop()
EconomyService.init(world)
RebirthService.init(world)
TsunamiService.init()

local function onPlayerAdded(player)
	local state = PlayerState.create(player)
	local claimed = PlotService.claim(player, state)
	PlayerState.sync(player)
	if claimed then
		task.delay(6, function()
			if player.Parent then
				Remotes.get("Notify"):FireClient(player,
					"Plot " .. state.plot.index .. " is yours! Buy brainrots at the shop south of the plaza.", "info")
			end
		end)
	else
		task.delay(6, function()
			if player.Parent then
				Remotes.get("Notify"):FireClient(player,
					"All four bases are taken - wait for one to free up.", "bad")
			end
		end)
	end
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = 18
	end
end

Players.PlayerAdded:Connect(function(player)
	onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerRemoving:Connect(function(player)
	local state = PlayerState.get(player)
	if state then
		for _, record in ipairs(table.clone(state.brainrots)) do
			PlayerState.destroyBrainrot(record)
		end
	end
	PlotService.release(player)
	PlayerState.remove(player)
end)

print("[BrainrotBonanza] server ready with " .. Catalog.count() .. " brainrots in the catalog")
