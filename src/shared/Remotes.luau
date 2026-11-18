-- Remotes: one owner for the RemoteEvents and the notification helper. The
-- server creates every event it can fire; the client waits for the folder.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local EVENT_NAMES = {
	"Notify", -- (message, kind)
	"Shake", -- (amount)
	"Flash", -- (color)
	"RebirthRequest", -- client -> server
}

local folder = nil
local cache = {}

local function getFolder()
	if folder then
		return folder
	end
	if RunService:IsServer() then
		folder = ReplicatedStorage:FindFirstChild("BrainrotRemotes")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "BrainrotRemotes"
			folder.Parent = ReplicatedStorage
		end
	else
		folder = ReplicatedStorage:WaitForChild("BrainrotRemotes", 30)
	end
	return folder
end

local function makeEvent(name)
	local parent = getFolder()
	if not parent then
		return nil
	end
	if RunService:IsServer() then
		local existing = parent:FindFirstChild(name)
		if existing then
			return existing
		end
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = parent
		return remote
	end
	return parent:WaitForChild(name, 30)
end

function Remotes.get(name)
	if cache[name] then
		return cache[name]
	end
	local remote = makeEvent(name)
	cache[name] = remote
	return remote
end

Remotes.event = Remotes.get

function Remotes.initServer()
	for _, name in ipairs(EVENT_NAMES) do
		Remotes.get(name)
	end
end

function Remotes.notify(player, message, kind)
	local remote = Remotes.get("Notify")
	if remote then
		remote:FireClient(player, message, kind or "info")
	end
end

function Remotes.notifyAll(message, kind)
	local remote = Remotes.get("Notify")
	if remote then
		remote:FireAllClients(message, kind or "info")
	end
end

if RunService:IsServer() then
	Remotes.initServer()
end

return Remotes
