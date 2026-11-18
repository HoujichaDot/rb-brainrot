-- TsunamiService: every TsunamiIntervalSeconds a warning counts down, then a
-- giant wave sweeps the map. Any player not standing on their own plot when
-- the wave reaches them loses one brainrot.

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Remotes = require(Shared.Remotes)

local PlayerState = require(script.Parent.PlayerState)
local PlotService = require(script.Parent.PlotService)

local Tsunami = {}

local function setAttributes(state, seconds)
	Workspace:SetAttribute("TsunamiState", state)
	Workspace:SetAttribute("TsunamiSeconds", seconds)
end

-- True when the character is standing somewhere inside its own plot.
local function onOwnPlot(player, position)
	local plot = PlotService.getPlot(player)
	if plot == nil then
		return false
	end
	local dx = position.X - plot.center.X
	local dz = position.Z - plot.center.Z
	return dx * dx + dz * dz <= 28 * 28
end

local function catch(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root then
		root.AssemblyLinearVelocity = Vector3.new(math.random(-18, 18), 42, math.random(-10, 30))
	end
	local lost = PlayerState.washAway(player)
	if lost then
		Remotes.get("Notify"):FireClient(player, "TSUNAMI! The wave washed away your " .. lost .. "!", "bad")
	else
		Remotes.get("Notify"):FireClient(player, "TSUNAMI! You got soaked (nothing lost).", "info")
	end
	Remotes.get("Shake"):FireClient(player, 1.2)
	Remotes.get("Flash"):FireClient(player, Color3.fromRGB(90, 170, 255))
end

-- Build the wave, raise it from the ocean, sweep it across, fade it out.
local function sweep()
	setAttributes("sweeping", 0)
	Remotes.get("Shake"):FireAllClients(0.5)

	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(460, 44, 18)
	wave.Anchored = true
	wave.CanCollide = false
	wave.CanQuery = false
	wave.Material = Enum.Material.Neon
	wave.Color = Color3.fromRGB(70, 160, 255)
	wave.Transparency = 0.45

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(235, 248, 255))
	emitter.Rate = 30
	emitter.Speed = NumberRange.new(10, 18)
	emitter.Lifetime = NumberRange.new(0.6, 1.2)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.Size = NumberSequence.new(3)
	emitter.Parent = wave

	wave.CFrame = CFrame.new(0, -30, GameConfig.TsunamiStartZ)
	wave.Parent = Workspace

	local rise = TweenService:Create(wave, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(0, 10, GameConfig.TsunamiStartZ),
	})
	rise:Play()
	rise.Completed:Wait()

	-- sweep while checking who the wave catches
	local hit = {}
	local startZ = GameConfig.TsunamiStartZ
	local endZ = GameConfig.TsunamiEndZ
	local t0 = time()
	while true do
		local alpha = (time() - t0) / GameConfig.TsunamiSweepSeconds
		if alpha >= 1 then
			break
		end
		wave.CFrame = CFrame.new(0, 10, startZ + (endZ - startZ) * alpha)
		local waveZ = wave.CFrame.Position.Z
		for player, _ in pairs(PlayerState.all()) do
			if hit[player] == nil then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and root.Position.Y > -10 and math.abs(root.Position.Z - waveZ) <= GameConfig.TsunamiBandHalf then
					hit[player] = true
					if not onOwnPlot(player, root.Position) then
						catch(player)
					end
				end
			end
		end
		task.wait(0.05)
	end

	local fade = TweenService:Create(wave, TweenInfo.new(0.8, Enum.EasingStyle.Linear), { Transparency = 1 })
	fade:Play()
	fade.Completed:Wait()
	wave:Destroy()
end

function Tsunami.init()
	setAttributes("idle", GameConfig.TsunamiIntervalSeconds)
	task.spawn(function()
		while true do
			for remaining = GameConfig.TsunamiIntervalSeconds, 1, -1 do
				setAttributes("idle", remaining)
				task.wait(1)
			end
			for remaining = GameConfig.TsunamiWarningSeconds, 1, -1 do
				setAttributes("warning", remaining)
				task.wait(1)
			end
			sweep()
			task.wait(1)
		end
	end)
end

return Tsunami
