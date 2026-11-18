-- PlotService: owns the four ring plots. It claims a free plot for a joining
-- player, tracks which of the six slots hold a brainrot, runs the 60s shield
-- lock (with a live countdown sign) and hides steal prompts while locked.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)

local PlotService = {}

local plots = {}
local lockLoopStarted = false

local function remaining(plot)
	return math.max(0, (plot.lockedUntil or 0) - time())
end

function PlotService.isLocked(plot)
	return plot ~= nil and remaining(plot) > 0
end

function PlotService.updateNameSign(plot)
	if plot == nil or plot.nameSign == nil then
		return
	end
	local ownerName = plot.ownerPlayer and plot.ownerPlayer.DisplayName or "VACANT"
	plot.nameSign.Text = string.format("PLOT %d\n%s", plot.index, ownerName)
	plot.nameSign.TextColor3 = plot.ownerPlayer and Color3.fromRGB(235, 240, 255) or Color3.fromRGB(150, 160, 190)
end

function PlotService.updateLockSign(plot)
	if plot == nil or plot.lockSign == nil then
		return
	end
	local seconds = remaining(plot)
	if seconds > 0 then
		plot.lockSign.Text = string.format("SHIELD %ds", math.ceil(seconds))
		plot.lockSign.TextColor3 = Color3.fromRGB(255, 205, 80)
	else
		plot.lockSign.Text = "SHIELD: OFF"
		plot.lockSign.TextColor3 = Color3.fromRGB(80, 220, 255)
	end
end

-- Hide every steal prompt on a locked plot; bring them back on unlock.
function PlotService.refreshPrompts(plot)
	if plot == nil then
		return
	end
	local locked = PlotService.isLocked(plot)
	for _, slot in ipairs(plot.slots) do
		local record = slot.record
		if record and record.stealPrompt then
			record.stealPrompt.Enabled = not locked
		end
	end
end

function PlotService.init(world)
	plots = world.plots
	for _, plot in ipairs(plots) do
		plot.lockedUntil = 0
		PlotService.updateNameSign(plot)
		PlotService.updateLockSign(plot)
	end
end

-- One cheap loop for every countdown and the unlock transition.
function PlotService.startLockLoop()
	if lockLoopStarted then
		return
	end
	lockLoopStarted = true
	task.spawn(function()
		while true do
			for _, plot in ipairs(plots) do
				local wasLocked = (plot.lockedUntil or 0) > 0
				if wasLocked then
					if PlotService.isLocked(plot) then
						PlotService.updateLockSign(plot)
					else
						plot.lockedUntil = 0
						PlotService.updateLockSign(plot)
						PlotService.refreshPrompts(plot)
					end
				end
			end
			task.wait(0.5)
		end
	end)
end

function PlotService.claim(player, state)
	for _, plot in ipairs(plots) do
		if plot.ownerPlayer == nil then
			plot.ownerPlayer = player
			plot.lockedUntil = 0
			state.plot = plot
			PlotService.updateNameSign(plot)
			PlotService.updateLockSign(plot)
			return plot
		end
	end
	return nil
end

function PlotService.release(player)
	for _, plot in ipairs(plots) do
		if plot.ownerPlayer == player then
			for _, slot in ipairs(plot.slots) do
				slot.record = nil
			end
			plot.ownerPlayer = nil
			plot.lockedUntil = 0
			PlotService.updateNameSign(plot)
			PlotService.updateLockSign(plot)
			return
		end
	end
end

function PlotService.getPlot(player)
	for _, plot in ipairs(plots) do
		if plot.ownerPlayer == player then
			return plot
		end
	end
	return nil
end

function PlotService.lock(plot)
	if plot == nil then
		return
	end
	plot.lockedUntil = time() + GameConfig.LockDurationSeconds
	PlotService.updateLockSign(plot)
	PlotService.refreshPrompts(plot)
end

function PlotService.firstFreeSlot(plot)
	if plot == nil then
		return nil
	end
	for _, slot in ipairs(plot.slots) do
		if slot.record == nil then
			return slot
		end
	end
	return nil
end

function PlotService.occupy(slot, record)
	if slot then
		slot.record = record
	end
end

function PlotService.vacate(slot)
	if slot then
		slot.record = nil
	end
end

return PlotService
