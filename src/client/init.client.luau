-- BRAINROT BONANZA - client boot: builds the HUD and reacts to server state.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local GameConfig = require(Shared.GameConfig)

local HUD = require(script.HUD)
local Effects = require(script.Effects)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local hud = HUD.build()
Effects.bind(hud.flashFrame)

local function bind(instance, attribute, callback)
	callback(instance:GetAttribute(attribute))
	instance:GetAttributeChangedSignal(attribute):Connect(function()
		callback(instance:GetAttribute(attribute))
	end)
end

bind(player, "Cash", function(value)
	hud.setCash(value or 0)
end)
bind(player, "IncomePerSecond", function(value)
	hud.setIncome(value or 0)
end)

local function refreshRebirth()
	hud.setRebirths(
		player:GetAttribute("Rebirths") or 0,
		player:GetAttribute("EarnedThisLife") or 0,
		player:GetAttribute("RebirthNeed") or 0
	)
end
bind(player, "Rebirths", refreshRebirth)
bind(player, "EarnedThisLife", refreshRebirth)
bind(player, "RebirthNeed", refreshRebirth)

local function refreshTsunami()
	hud.setTsunami(
		Workspace:GetAttribute("TsunamiState") or "idle",
		Workspace:GetAttribute("TsunamiSeconds") or GameConfig.TsunamiIntervalSeconds
	)
end
bind(Workspace, "TsunamiState", refreshTsunami)
bind(Workspace, "TsunamiSeconds", refreshTsunami)

Remotes.get("Notify").OnClientEvent:Connect(function(text, kind)
	hud.toast(text, kind)
end)
Remotes.get("Shake").OnClientEvent:Connect(function(power)
	Effects.shake(power)
end)
Remotes.get("Flash").OnClientEvent:Connect(function(color)
	Effects.flash(color)
end)

hud.rebirthButton.MouseButton1Click:Connect(function()
	Remotes.get("RebirthRequest"):FireServer()
end)

hud.gui.Parent = playerGui

task.delay(2, function()
	hud.toast("Welcome to BRAINROT BONANZA! The shop is south of the plaza.", "info")
end)
