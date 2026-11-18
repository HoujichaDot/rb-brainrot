-- StealService: the hold-to-steal ProximityPrompt on every placed brainrot,
-- with lock checks, a grace period after each steal and a cash-out fallback
-- when the thief's base is full.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Remotes = require(Shared.Remotes)
local Format = require(Shared.Format)

local PlayerState = require(script.Parent.PlayerState)
local PlotService = require(script.Parent.PlotService)
local Factory = require(script.Parent.BrainrotFactory)
local Effects = require(script.Parent.Effects)

local StealService = {}

local function notify(player, text, kind)
	Remotes.get("Notify"):FireClient(player, text, kind or "info")
end

-- Put a steal prompt on a placed brainrot.
function StealService.attach(record)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "StealPrompt"
	prompt.ActionText = "Steal (" .. GameConfig.StealHoldSeconds .. "s)"
	prompt.ObjectText = record.entry.name .. (record.owner and (" (" .. record.owner.DisplayName .. ")") or "")
	prompt.HoldDuration = GameConfig.StealHoldSeconds
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.Parent = record.root
	record.stealPrompt = prompt
	prompt.Enabled = not PlotService.isLocked(record.plot)

	-- warn the victim the moment someone starts a hold
	prompt.PromptButtonHoldBegan:Connect(function(holder)
		if holder == record.owner or record.state ~= "placed" then
			return
		end
		local victim = record.owner
		if victim then
			notify(victim, holder.DisplayName .. " is stealing your " .. record.entry.name .. "!", "bad")
		end
	end)

	prompt.Triggered:Connect(function(thief)
		StealService.onSteal(thief, record)
	end)
end

function StealService.onSteal(thief, record)
	if record.state ~= "placed" then
		return
	end
	if record.owner == thief then
		notify(thief, "That one is already yours!", "info")
		return
	end
	if time() < (record.graceUntil or 0) then
		notify(thief, "That brainrot just changed hands - give it a moment.", "info")
		return
	end
	if record.plot and PlotService.isLocked(record.plot) then
		notify(thief, "That base is locked!", "bad")
		return
	end
	local thiefState = PlayerState.get(thief)
	if thiefState == nil then
		return
	end
	local victim = record.owner

	-- detach from the victim immediately
	record.state = "flying"
	record.stealPrompt.Enabled = false
	if victim then
		local victimState = PlayerState.get(victim)
		if victimState then
			PlayerState.removeBrainrot(victimState, record)
			PlayerState.sync(victim)
		end
	end
	if record.slot then
		PlotService.vacate(record.slot)
		record.slot = nil
	end
	local startPos = record.root.Position
	Effects.burst(startPos + Vector3.new(0, 2, 0), Color3.fromRGB(255, 170, 60), 14)

	local slot = thiefState.plot and PlotService.firstFreeSlot(thiefState.plot) or nil
	if slot == nil then
		-- no room on the thief's base: the steal pays out cash instead
		local payout = math.floor(record.income * PlayerState.mutationMultiplier(record) * GameConfig.StealCashOutSeconds)
		local name = record.entry.name
		PlayerState.destroyBrainrot(record)
		PlayerState.addEarned(thief, payout)
		notify(thief, "Your base is full - " .. name .. " sold for " .. Format.money(payout) .. "!", "good")
	else
		-- carry it through the air to the thief's plot
		record.owner = thief
		record.plot = thiefState.plot
		record.slot = slot
		record.model:SetAttribute("OwnerId", thief.UserId)
		Factory.flyTo(record, slot.anchor, 1.0, function()
			local liveState = PlayerState.get(thief)
			if liveState == nil then
				PlayerState.destroyBrainrot(record)
				return
			end
			record.state = "placed"
			PlotService.occupy(slot, record)
			PlayerState.addBrainrot(liveState, record)
			record.stealPrompt.ObjectText = record.entry.name .. " (" .. thief.DisplayName .. ")"
			record.stealPrompt.Enabled = not PlotService.isLocked(record.plot)
			record.graceUntil = time() + GameConfig.StealGraceSeconds
			PlayerState.sync(thief)
		end)
		notify(thief, "You stole " .. record.entry.name .. "!", "steal")
	end

	if victim then
		notify(victim, thief.DisplayName .. " stole your " .. record.entry.name .. "!", "bad")
	end
end

return StealService
