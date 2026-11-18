-- EconomyService: the shop pedestals (stock, price signs, buy prompts),
-- buying brainrots onto a base, lock pads, and the income tick.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Rarity = require(Shared.Rarity)
local Catalog = require(Shared.BrainrotCatalog)
local Remotes = require(Shared.Remotes)
local Format = require(Shared.Format)

local PlayerState = require(script.Parent.PlayerState)
local PlotService = require(script.Parent.PlotService)
local Factory = require(script.Parent.BrainrotFactory)
local StealService = require(script.Parent.StealService)
local Effects = require(script.Parent.Effects)

local Economy = {}

local function notify(player, text, kind)
	Remotes.get("Notify"):FireClient(player, text, kind or "info")
end

local function mutationMultiplier(mutation)
	if mutation == "Rainbow" then
		return GameConfig.RainbowMultiplier
	end
	if mutation == "Gold" then
		return GameConfig.GoldMultiplier
	end
	return 1
end

-- 3% Rainbow (x5), then 10% Gold (x2), else nothing.
local function rollMutation()
	local r = math.random()
	if r < GameConfig.RainbowChance then
		return "Rainbow"
	end
	if r < GameConfig.RainbowChance + GameConfig.GoldChance then
		return "Gold"
	end
	return nil
end

-- (re)stock one pedestal with a random character of its tier. The Mythic
-- pedestal sometimes rolls a Secret instead.
function Economy.restock(pedestal)
	local rarity = pedestal.tier
	if pedestal.tier == "Mythic" and math.random() < GameConfig.SecretFromMythicChance then
		rarity = "Secret"
	end
	local entry = Catalog.randomOf(rarity)
	if entry == nil then
		entry = Catalog.randomOf("Common")
	end
	if entry == nil then
		return
	end
	pedestal.entry = entry
	pedestal.mutation = rollMutation()
	if pedestal.display then
		pedestal.display.stop()
		pedestal.display.model:Destroy()
		pedestal.display = nil
	end
	pedestal.display = Factory.spawn(entry, pedestal.mutation, pedestal.anchor)
	local effective = entry.income * mutationMultiplier(pedestal.mutation)
	pedestal.signLabel.Text = Format.money(entry.price)
	pedestal.signLabel.TextColor3 = Rarity.color(entry.rarity)
	pedestal.prompt.ObjectText = entry.name .. " - " .. Format.money(entry.price) .. " (" .. Format.rate(effective) .. ")"
	pedestal.prompt.Enabled = true
	pedestal.locked = false
end

local function clearDisplay(pedestal)
	if pedestal.display then
		pedestal.display.stop()
		pedestal.display.model:Destroy()
		pedestal.display = nil
	end
	pedestal.entry = nil
	pedestal.mutation = nil
end

-- Buy the brainrot a pedestal is showing. Reserve-first so two players
-- triggering in the same instant cannot both buy it.
function Economy.attemptBuy(player, pedestal)
	if pedestal.locked or pedestal.entry == nil then
		return
	end
	pedestal.locked = true
	local state = PlayerState.get(player)
	if state == nil then
		pedestal.locked = false
		return
	end
	if state.plot == nil then
		notify(player, "You have no base yet - one frees up when someone leaves.", "bad")
		pedestal.locked = false
		return
	end
	local slot = PlotService.firstFreeSlot(state.plot)
	if slot == nil then
		notify(player, "Your base is full!", "bad")
		pedestal.locked = false
		return
	end
	local entry = pedestal.entry
	local mutation = pedestal.mutation
	if not PlayerState.spend(player, entry.price) then
		notify(player, "You need " .. Format.money(entry.price) .. " for " .. entry.name .. ".", "bad")
		pedestal.locked = false
		return
	end

	-- off the market, onto the buyer's base
	pedestal.prompt.Enabled = false
	pedestal.signLabel.Text = "RESTOCKING..."
	pedestal.signLabel.TextColor3 = Color3.fromRGB(225, 225, 230)
	clearDisplay(pedestal)

	local record = Factory.spawn(entry, mutation, slot.anchor)
	record.slot = slot
	record.state = "placed"
	PlayerState.register(player, record)
	StealService.attach(record)
	PlayerState.sync(player)

	Effects.burst(slot.anchor.Position + Vector3.new(0, 2.5, 0), Rarity.color(entry.rarity), 22)
	notify(player, "Bought " .. entry.name .. (mutation and (" [" .. string.upper(mutation) .. "]") or "") .. "!", "good")

	task.delay(GameConfig.ShopRestockSeconds, function()
		Economy.restock(pedestal)
	end)
end

-- Buy the 60-second plot lock at a lock pad.
function Economy.attemptLock(player, plot)
	if plot.ownerPlayer ~= player then
		notify(player, "That is not your base!", "bad")
		return
	end
	if PlotService.isLocked(plot) then
		notify(player, "Your base is already locked (" .. math.ceil(plot.lockedUntil - time()) .. "s left).", "info")
		return
	end
	if not PlayerState.spend(player, GameConfig.LockCost) then
		notify(player, "A lock costs " .. Format.money(GameConfig.LockCost) .. ".", "bad")
		return
	end
	PlotService.lock(plot)
	Effects.burst(plot.lockPad.Position + Vector3.new(0, 2, 0), Color3.fromRGB(90, 220, 110), 14)
	notify(player, "Base locked for " .. GameConfig.LockDurationSeconds .. " seconds!", "good")
end

-- Every IncomeTickSeconds, every placed brainrot pays its rate.
function Economy.startIncomeLoop()
	task.spawn(function()
		while true do
			task.wait(GameConfig.IncomeTickSeconds)
			local snapshot = {}
			for _, state in pairs(PlayerState.all()) do
				snapshot[#snapshot + 1] = state
			end
			for _, state in ipairs(snapshot) do
				PlayerState.addEarned(state.player, PlayerState.incomeOf(state))
			end
		end
	end)
end

function Economy.init(world)
	for _, pedestal in ipairs(world.shopPedestals) do
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "BuyPrompt"
		prompt.ActionText = "Buy"
		prompt.ObjectText = "..."
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 11
		prompt.RequiresLineOfSight = false
		prompt.Parent = pedestal.pad
		pedestal.prompt = prompt
		prompt.Triggered:Connect(function(player)
			Economy.attemptBuy(player, pedestal)
		end)
		task.delay(1 + pedestal.index * 1.5, function()
			Economy.restock(pedestal)
		end)
	end

	for _, plot in ipairs(world.plots) do
		local lockPrompt = Instance.new("ProximityPrompt")
		lockPrompt.Name = "LockPrompt"
		lockPrompt.ActionText = "Lock base (" .. Format.money(GameConfig.LockCost) .. ", " .. GameConfig.LockDurationSeconds .. "s)"
		lockPrompt.ObjectText = "Security Lock"
		lockPrompt.HoldDuration = 0
		lockPrompt.MaxActivationDistance = 8
		lockPrompt.RequiresLineOfSight = false
		lockPrompt.Parent = plot.lockPad
		lockPrompt.Triggered:Connect(function(player)
			Economy.attemptLock(player, plot)
		end)
	end

	Economy.startIncomeLoop()
end

return Economy
