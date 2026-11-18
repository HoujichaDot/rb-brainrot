-- Client effects: the flash overlay and the camera jolt. The server asks for
-- both through Remotes, so the client stays in charge of how they feel.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Effects = {}

local flashFrame = nil
local shakeUntil = 0
local shakePower = 0

function Effects.bind(frame)
	flashFrame = frame
end

function Effects.flash(color)
	if flashFrame == nil then
		return
	end
	flashFrame.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
	flashFrame.BackgroundTransparency = 0.35
	TweenService:Create(flashFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	}):Play()
end

function Effects.shake(power)
	power = math.clamp(tonumber(power) or 1, 0, 3)
	shakePower = power
	shakeUntil = os.clock() + 0.45 + 0.35 * power
end

RunService.RenderStepped:Connect(function()
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	if os.clock() < shakeUntil then
		local t = os.clock() * 42
		humanoid.CameraOffset = Vector3.new(
			math.sin(t) * 0.4 * shakePower,
			math.cos(t * 1.4) * 0.32 * shakePower,
			0
		)
	elseif humanoid.CameraOffset.Magnitude > 0.001 then
		humanoid.CameraOffset = Vector3.zero
	end
end)

return Effects
