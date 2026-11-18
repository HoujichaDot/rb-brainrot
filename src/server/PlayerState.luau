-- PlayerState: the one place holding per-player progression state — cash,
-- earned totals, rebirths, plot and the list of placed brainrots — plus the
-- lifecycle helpers that spawn, move and destroy them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)

local Factory = require(script.Parent.BrainrotFactory)
local PlotService = require(script.Parent.PlotService)
local Effects = require(script.Parent.Effects)

local PlayerState = {}

local states = {}

local function ensureValue(container, name)
	local existing = container:FindFirstChild(name)
	if existing and existing:IsA("IntValue") then
		return existing
	end
	local value = Instance.new("IntValue")
	value.Name = name
	value.Parent = container
	return value
end

local function ensureLeaderstats(player)
	local stats = player:FindFirstChild("leaderstats")
	if stats == nil then
		stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		stats.Parent = player
	end
	ensureValue(stats, "Cash")
	ensureValue(stats, "Rebirths")
end

function PlayerState.get(player)
	return states[player]
end

function PlayerState.all()
	return states
end

function PlayerState.create(player)
	local existing = states[player]
	if existing then
		return existing
	end
	local state = {
		player = player,
		cash = GameConfig.StartingCash,
		earnedThisLife = 0,
		lifetimeEarned = 0,
		rebirths = 0,
		plot = nil,
		brainrots = {},
	}
	states[player] = state
	ensureLeaderstats(player)
	PlayerState.sync(player)
	return state
end

function PlayerState.remove(player)
	states[player] = nil
end

-- A record's income multiplier from its mutation.
function PlayerState.mutationMultiplier(record)
	if record.mutation == "Rainbow" then
		return GameConfig.RainbowMultiplier
	end
	if record.mutation == "Gold" then
		return GameConfig.GoldMultiplier
	end
	return 1
end

-- Total $/s a player earns from everything placed on their plot.
function PlayerState.incomeOf(state)
	if state.plot == nil then
		return 0
	end
	local total = 0
	for _, record in ipairs(state.brainrots) do
		if record.state == "placed" or record.state == "flying" then
			total = total + record.income * PlayerState.mutationMultiplier(record)
		end
	end
	return total * GameConfig.rebirthMultiplier(state.rebirths)
end

-- Push the whole state into replicated Attributes and leaderstats.
function PlayerState.sync(player)
	local state = states[player]
	if state == nil then
		return
	end
	player:SetAttribute("Cash", math.floor(state.cash))
	player:SetAttribute("IncomePerSecond", PlayerState.incomeOf(state))
	player:SetAttribute("Rebirths", state.rebirths)
	player:SetAttribute("EarnedThisLife", math.floor(state.earnedThisLife))
	player:SetAttribute("RebirthNeed", GameConfig.rebirthCost(state.rebirths))
	player:SetAttribute("BrainrotCount", #state.brainrots)
	player:SetAttribute("PlotIndex", state.plot and state.plot.index or 0)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local cash = stats:FindFirstChild("Cash")
		if cash then
			cash.Value = math.floor(state.cash)
		end
		local rebirths = stats:FindFirstChild("Rebirths")
		if rebirths then
			rebirths.Value = state.rebirths
		end
	end
end

function PlayerState.addEarned(player, amount)
	local state = states[player]
	if state == nil then
		return
	end
	state.cash = state.cash + amount
	state.earnedThisLife = state.earnedThisLife + amount
	state.lifetimeEarned = state.lifetimeEarned + amount
	PlayerState.sync(player)
end

function PlayerState.setCash(player, amount)
	local state = states[player]
	if state == nil then
		return false
	end
	state.cash = amount
	PlayerState.sync(player)
	return true
end

function PlayerState.spend(player, amount)
	local state = states[player]
	if state == nil or state.cash < amount then
		return false
	end
	state.cash = state.cash - amount
	PlayerState.sync(player)
	return true
end

function PlayerState.addBrainrot(state, record)
	table.insert(state.brainrots, record)
end

function PlayerState.removeBrainrot(state, record)
	for i, other in ipairs(state.brainrots) do
		if other == record then
			table.remove(state.brainrots, i)
			return true
		end
	end
	return false
end

-- Register a freshly built model as a placed brainrot of a player.
function PlayerState.register(player, record)
	local state = states[player]
	if state == nil then
		return false
	end
	record.owner = player
	record.ownerUserId = player.UserId
	record.plot = state.plot
	PlotService.occupy(record.slot, record)
	table.insert(state.brainrots, record)
	record.model:SetAttribute("OwnerId", player.UserId)
	if record.stealPrompt then
		record.stealPrompt.ObjectText = record.entry.name .. " (" .. player.DisplayName .. ")"
	end
	PlayerState.sync(player)
	return true
end

-- Destroy a placed brainrot (poof included) and clean every reference to it.
function PlayerState.destroyBrainrot(record, poofColor)
	if record.destroyed then
		return
	end
	record.destroyed = true
	local state = record.owner and states[record.owner] or nil
	if state then
		PlayerState.removeBrainrot(state, record)
	end
	if record.slot then
		PlotService.vacate(record.slot)
		record.slot = nil
	end
	if poofColor then
		Effects.burst(record.root.Position + Vector3.new(0, 2, 0), poofColor, 20)
	end
	record.stop()
	record.model:Destroy()
	if state then
		PlayerState.sync(state.player)
	end
end

-- The tsunami takes one random brainrot; returns its name or nil.
function PlayerState.washAway(player)
	local state = states[player]
	if state == nil or #state.brainrots == 0 then
		return nil
	end
	local pick = state.brainrots[math.random(#state.brainrots)]
	local name = pick.entry.name
	PlayerState.destroyBrainrot(pick, Color3.fromRGB(90, 170, 255))
	return name
end

return PlayerState
