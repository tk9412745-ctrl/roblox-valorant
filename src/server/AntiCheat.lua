-- AntiCheat: honeypot remotes + rate limit tracking
-- Honeypot = fake unsecured RemoteEvent that has no legit game purpose
-- Any client firing it = exploit attempt → auto-kick or log

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AntiCheat = {}

-- Honeypot RemoteEvents (clients should NEVER fire these)
local honeypotNames = {
	"AdminGiveItem",
	"GrantAllSkins",
	"InfiniteCredits",
	"GodMode",
	"NoclipToggle",
}

local violations = {}  -- [player] = count
local VIOLATION_THRESHOLD = 1  -- kick on first violation (these remotes have NO legit use)

local function logViolation(player, remoteName)
	violations[player] = (violations[player] or 0) + 1
	warn("[AntiCheat] " .. player.Name .. " fired honeypot '" .. remoteName .. "' (violations: " .. violations[player] .. ")")
	if violations[player] >= VIOLATION_THRESHOLD then
		-- In production: kick player. For dev: just log.
		-- player:Kick("Exploit detected")
		warn("[AntiCheat] Would kick " .. player.Name)
	end
end

-- Rate limit tracking (per-remote, per-player)
local rateLimits = {}  -- [remoteName][player] = {count, windowStart}
local RATE_WINDOW = 1  -- second
local DEFAULT_MAX_PER_WINDOW = 30

function AntiCheat.CheckRateLimit(remoteName, player, maxPerWindow)
	maxPerWindow = maxPerWindow or DEFAULT_MAX_PER_WINDOW
	rateLimits[remoteName] = rateLimits[remoteName] or {}
	local state = rateLimits[remoteName][player]
	local now = tick()

	if not state or (now - state.windowStart) >= RATE_WINDOW then
		rateLimits[remoteName][player] = { count = 1, windowStart = now }
		return true
	end

	state.count += 1
	if state.count > maxPerWindow then
		warn("[AntiCheat] " .. player.Name .. " exceeded rate limit on " .. remoteName)
		return false
	end
	return true
end

function AntiCheat.GetViolations(player)
	return violations[player] or 0
end

function AntiCheat.Start()
	-- Create honeypot remotes
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end

	for _, name in ipairs(honeypotNames) do
		if not folder:FindFirstChild(name) then
			local honeypot = Instance.new("RemoteEvent")
			honeypot.Name = name
			honeypot.Parent = folder
			honeypot.OnServerEvent:Connect(function(player, ...)
				logViolation(player, name)
			end)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		violations[player] = nil
		for _, perRemote in pairs(rateLimits) do
			perRemote[player] = nil
		end
	end)
end

return AntiCheat
