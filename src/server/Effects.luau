-- Effects: tiny one-shot particle bursts for server-side feedback.
-- Built-in particle textures only, nothing uploaded.

local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Effects = {}

local holderFolder = nil

local function folder()
	if holderFolder == nil or holderFolder.Parent == nil then
		local f = Instance.new("Folder")
		f.Name = "EffectBursts"
		f.Parent = Workspace
		holderFolder = f
	end
	return holderFolder
end

function Effects.burst(position, color, count, size)
	local holder = Instance.new("Part")
	holder.Name = "Burst"
	holder.Size = Vector3.new(0.5, 0.5, 0.5)
	holder.Transparency = 1
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.CFrame = CFrame.new(position)

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.Rate = 0
	emitter.Enabled = false
	emitter.Speed = NumberRange.new(7, 13)
	emitter.Lifetime = NumberRange.new(0.35, 0.85)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(size or 0.7)
	emitter.LightEmission = 0.8
	emitter.Parent = holder

	holder.Parent = folder()
	emitter:Emit(count or 16)
	Debris:AddItem(holder, 2.5)
end

return Effects
