-- RebirthService: at the shrine (or from the HUD button) a player past the
-- earned-this-life threshold can reset cash and brainrots for a permanent
-- +25% income multiplier per rebirth.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Remotes = require(Shared.Remotes)
local Format = require(Shared.Format)

local PlayerState = require(script.Parent.PlayerState)
local Effects = require(script.Parent.Effects)

local Rebirth = {}

function Rebirth.attempt(player)
	local state = PlayerState.get(player)
	if state == nil then
		return
	end
	local need = GameConfig.rebirthCost(state.rebirths)
	if state.earnedThisLife < need then
		Remotes.get("Notify"):FireClient(player,
			"Rebirth needs " .. Format.money(need) .. " earned this life (you have earned " .. Format.money(state.earnedThisLife) .. ").",
			"info")
		return
	end

	-- clear the board, then reset and promote
	for i = #state.brainrots, 1, -1 do
		PlayerState.destroyBrainrot(state.brainrots[i], Color3.fromRGB(255, 200, 60))
	end
	state.cash = GameConfig.StartingCash
	state.earnedThisLife = 0
	state.rebirths = state.rebirths + 1
	PlayerState.sync(player)

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		Effects.burst(root.Position, Color3.fromRGB(255, 200, 60), 30, 1.2)
	end
	Remotes.get("Notify"):FireClient(player,
		"REBIRTH " .. state.rebirths .. "! Income is now x" .. string.format("%.2f", GameConfig.rebirthMultiplier(state.rebirths)) .. " forever.",
		"gold")
	Remotes.get("Flash"):FireClient(player, Color3.fromRGB(255, 210, 80))
	Remotes.get("Shake"):FireClient(player, 0.8)
end

function Rebirth.init(world)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "RebirthPrompt"
	prompt.ActionText = "Rebirth"
	prompt.ObjectText = "Rebirth Shrine - reset for +25% income each"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = world.shrinePad
	prompt.Triggered:Connect(function(player)
		Rebirth.attempt(player)
	end)

	Remotes.get("RebirthRequest").OnServerEvent:Connect(function(player)
		Rebirth.attempt(player)
	end)
end

return Rebirth
