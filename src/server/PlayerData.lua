-- PlayerData: persistent storage per player
-- PRODUCTION NOTE: replace with ProfileService (madstudioroblox/ProfileService on GitHub)
-- for session-locking and atomic write guarantees. This is a simplified MVP version.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local PlayerData = {}

local DATASTORE_NAME = "ValorantPlayerData_v1"
local SAVE_INTERVAL = 60  -- seconds

local store
if not RunService:IsStudio() then
	-- DataStore works only in published games
	store = DataStoreService:GetDataStore(DATASTORE_NAME)
end

local DEFAULT_PROFILE = {
	Robux_Spent = 0,         -- tracked for analytics (not actual Robux)
	Coins = 0,               -- soft currency (out-of-match)
	MMR = 800,               -- Silver 1 starting (Sprint 27)
	MatchHistory = {},       -- Last 20 matches (Sprint 28)
	Settings = {},           -- crosshair etc (Sprint 20)
	Friends = {},            -- list of UserIds (Sprint 66)
	LoginStreak = {           -- daily login bonus (Sprint 69)
		count = 0,
		lastLogin = 0,
	},
	Level = 1,                -- account level (Sprint 77)
	LevelXP = 0,
	Owned_Skins = {},        -- [skinId] = { level = 1, variant = 1, kills = 0 }
	Equipped = {             -- [weaponName] = skinId
		Vandal = "default_vandal",
		Phantom = "default_phantom",
		Ghost = "default_ghost",
		Sheriff = "default_sheriff",
		Operator = "default_operator",
	},
	Battle_Pass = {
		Season = 1,
		XP = 0,
		Tier = 0,
		Premium_Owned = false,
		Claimed_Rewards = {},
	},
	Inventory_Slots = 50,
	First_Login = 0,
	Last_Login = 0,
	Cases_Opened = 0,
	Consecutive_Cases_No_Legendary = 0,
	Stats = {
		MatchesPlayed = 0,
		MatchesWon = 0,
		Kills = 0,
		Deaths = 0,
		HeadshotKills = 0,
		WinStreak = 0,
		BestWinStreak = 0,
		Plants = 0,
		Defuses = 0,
		AgentKills = {},  -- [agentName] = kill count
	},
}

-- In-memory cache
local profiles = {}
local saveLocks = {}  -- prevent concurrent saves for same player

local function deepCopy(t)
	if type(t) ~= "table" then return t end
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = deepCopy(v)
	end
	return copy
end

local function mergeDefaults(profile, defaults)
	for k, v in pairs(defaults) do
		if profile[k] == nil then
			profile[k] = deepCopy(v)
		elseif type(v) == "table" and type(profile[k]) == "table" then
			mergeDefaults(profile[k], v)
		end
	end
end

local function loadProfile(userId)
	if not store then
		-- Studio mode: just return default
		local p = deepCopy(DEFAULT_PROFILE)
		p.First_Login = os.time()
		p.Last_Login = os.time()
		return p
	end

	local success, data = pcall(function()
		return store:GetAsync("u_" .. userId)
	end)

	local profile
	if success and data then
		profile = data
		mergeDefaults(profile, DEFAULT_PROFILE)
	else
		profile = deepCopy(DEFAULT_PROFILE)
		profile.First_Login = os.time()
	end
	profile.Last_Login = os.time()
	return profile
end

local function saveProfile(userId, profile)
	if not store then return end
	if saveLocks[userId] then return end
	saveLocks[userId] = true

	local success, err = pcall(function()
		store:UpdateAsync("u_" .. userId, function(old)
			return profile
		end)
	end)

	saveLocks[userId] = nil
	if not success then
		warn("[PlayerData] Save failed for user " .. userId .. ": " .. tostring(err))
	end
end

function PlayerData.Get(player)
	return profiles[player.UserId]
end

function PlayerData.WaitForProfile(player, timeoutSec)
	local timeout = timeoutSec or 5
	local start = tick()
	while not profiles[player.UserId] do
		if tick() - start > timeout then return nil end
		task.wait(0.1)
	end
	return profiles[player.UserId]
end

function PlayerData.GrantSkin(player, skinId)
	local profile = profiles[player.UserId]
	if not profile then return false end
	if not profile.Owned_Skins[skinId] then
		profile.Owned_Skins[skinId] = { level = 1, variant = 1, kills = 0 }
	end
	return true
end

function PlayerData.OwnsSkin(player, skinId)
	local profile = profiles[player.UserId]
	if not profile then return false end
	return profile.Owned_Skins[skinId] ~= nil
end

function PlayerData.SetEquipped(player, weaponName, skinId)
	local profile = profiles[player.UserId]
	if not profile then return false end
	profile.Equipped[weaponName] = skinId
	return true
end

function PlayerData.GetEquipped(player, weaponName)
	local profile = profiles[player.UserId]
	if not profile then return nil end
	return profile.Equipped[weaponName]
end

function PlayerData.AddCoins(player, amount)
	local profile = profiles[player.UserId]
	if not profile then return false end
	profile.Coins = (profile.Coins or 0) + amount
	return true
end

function PlayerData.SpendCoins(player, amount)
	local profile = profiles[player.UserId]
	if not profile then return false end
	if (profile.Coins or 0) < amount then return false end
	profile.Coins -= amount
	return true
end

function PlayerData.GetCoins(player)
	local profile = profiles[player.UserId]
	if not profile then return 0 end
	return profile.Coins or 0
end

function PlayerData.RecordStat(player, key, amount)
	local profile = profiles[player.UserId]
	if not profile then return end
	profile.Stats[key] = (profile.Stats[key] or 0) + (amount or 1)
end

function PlayerData.Start()
	Players.PlayerAdded:Connect(function(player)
		local profile = loadProfile(player.UserId)
		profiles[player.UserId] = profile
		-- Grant default skins as owned
		for _, skinId in pairs(profile.Equipped) do
			if not profile.Owned_Skins[skinId] then
				profile.Owned_Skins[skinId] = { level = 1, variant = 1, kills = 0 }
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		if profiles[player.UserId] then
			saveProfile(player.UserId, profiles[player.UserId])
			profiles[player.UserId] = nil
		end
	end)

	-- Auto-save loop
	task.spawn(function()
		while true do
			task.wait(SAVE_INTERVAL)
			for userId, profile in pairs(profiles) do
				saveProfile(userId, profile)
			end
		end
	end)

	-- Save all on server shutdown
	game:BindToClose(function()
		for userId, profile in pairs(profiles) do
			saveProfile(userId, profile)
		end
	end)
end

return PlayerData
