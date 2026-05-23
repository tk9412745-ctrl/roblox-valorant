local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local function getOrCreate(name, className)
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		if RunService:IsServer() then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = ReplicatedStorage
		else
			folder = ReplicatedStorage:WaitForChild("Remotes")
		end
	end

	local remote = folder:FindFirstChild(name)
	if not remote then
		if RunService:IsServer() then
			remote = Instance.new(className)
			remote.Name = name
			remote.Parent = folder
		else
			remote = folder:WaitForChild(name)
		end
	end
	return remote
end

-- Combat
Remotes.FireWeapon = getOrCreate("FireWeapon", "RemoteEvent")
Remotes.WeaponFired = getOrCreate("WeaponFired", "RemoteEvent")
Remotes.Reload = getOrCreate("Reload", "RemoteEvent")
Remotes.UpdateAmmo = getOrCreate("UpdateAmmo", "RemoteEvent")
Remotes.HitMarker = getOrCreate("HitMarker", "RemoteEvent")
Remotes.SetADS = getOrCreate("SetADS", "RemoteEvent")

-- Round / Match
Remotes.RoundPhaseChanged = getOrCreate("RoundPhaseChanged", "RemoteEvent")
Remotes.UpdateRoundTimer = getOrCreate("UpdateRoundTimer", "RemoteEvent")
Remotes.UpdateScore = getOrCreate("UpdateScore", "RemoteEvent")
Remotes.RoundEnded = getOrCreate("RoundEnded", "RemoteEvent")
Remotes.MatchEnded = getOrCreate("MatchEnded", "RemoteEvent")
Remotes.HalftimeStarted = getOrCreate("HalftimeStarted", "RemoteEvent")

-- Economy
Remotes.UpdateCredits = getOrCreate("UpdateCredits", "RemoteEvent")
Remotes.UpdateUltPoints = getOrCreate("UpdateUltPoints", "RemoteEvent")
Remotes.RequestBuy = getOrCreate("RequestBuy", "RemoteEvent")  -- client → server
Remotes.BuyResult = getOrCreate("BuyResult", "RemoteEvent")

-- Spike
Remotes.SpikeStateChanged = getOrCreate("SpikeStateChanged", "RemoteEvent")
Remotes.RequestPlant = getOrCreate("RequestPlant", "RemoteEvent")  -- key held E near plant area
Remotes.RequestDefuse = getOrCreate("RequestDefuse", "RemoteEvent")
Remotes.CancelInteract = getOrCreate("CancelInteract", "RemoteEvent")
Remotes.InteractProgress = getOrCreate("InteractProgress", "RemoteEvent")  -- shows progress bar

-- Abilities (Sprint 6)
Remotes.UseAbility = getOrCreate("UseAbility", "RemoteEvent")  -- client → server, ability key
Remotes.AbilityFired = getOrCreate("AbilityFired", "RemoteEvent")
Remotes.UpdateAbilityState = getOrCreate("UpdateAbilityState", "RemoteEvent")

-- Skins / Equipment (Sprint 7)
Remotes.EquipSkin = getOrCreate("EquipSkin", "RemoteEvent")
Remotes.SkinEquipped = getOrCreate("SkinEquipped", "RemoteEvent")

-- Visual / killfeed (Sprint 13)
Remotes.KillFeed = getOrCreate("KillFeed", "RemoteEvent")
Remotes.PlaySound = getOrCreate("PlaySound", "RemoteEvent")

-- Stats / scoreboard (Sprint 17)
Remotes.UpdateMatchStats = getOrCreate("UpdateMatchStats", "RemoteEvent")

-- Agent select (Sprint 18)
Remotes.ShowAgentSelect = getOrCreate("ShowAgentSelect", "RemoteEvent")
Remotes.AgentSelected = getOrCreate("AgentSelected", "RemoteEvent")

-- Settings (Sprint 20)
Remotes.SaveSettings = getOrCreate("SaveSettings", "RemoteEvent")
Remotes.LoadSettings = getOrCreate("LoadSettings", "RemoteEvent")

-- Lobby / countdown (Sprint 21)
Remotes.MatchCountdown = getOrCreate("MatchCountdown", "RemoteEvent")
Remotes.LobbyState = getOrCreate("LobbyState", "RemoteEvent")

-- Inventory (Sprint 29)
Remotes.RequestInventory = getOrCreate("RequestInventory", "RemoteEvent")
Remotes.UpdateInventory = getOrCreate("UpdateInventory", "RemoteEvent")

-- Ping system (Sprint 30)
Remotes.SendPing = getOrCreate("SendPing", "RemoteEvent")
Remotes.PingReceived = getOrCreate("PingReceived", "RemoteEvent")

-- Map vote (Sprint 32)
Remotes.MapVoteStart = getOrCreate("MapVoteStart", "RemoteEvent")
Remotes.MapVoteCast = getOrCreate("MapVoteCast", "RemoteEvent")
Remotes.MapVoteUpdate = getOrCreate("MapVoteUpdate", "RemoteEvent")

-- Movement mode (Sprint 35)
Remotes.SetMovementMode = getOrCreate("SetMovementMode", "RemoteEvent")

-- Achievements (Sprint 37)
Remotes.AchievementUnlocked = getOrCreate("AchievementUnlocked", "RemoteEvent")

-- Daily challenges (Sprint 38)
Remotes.UpdateChallenges = getOrCreate("UpdateChallenges", "RemoteEvent")
Remotes.ChallengeCompleted = getOrCreate("ChallengeCompleted", "RemoteEvent")

-- Leaderboards (Sprint 41)
Remotes.RequestLeaderboard = getOrCreate("RequestLeaderboard", "RemoteEvent")
Remotes.UpdateLeaderboard = getOrCreate("UpdateLeaderboard", "RemoteEvent")

-- Combat report (Sprint 36)
Remotes.RoundReport = getOrCreate("RoundReport", "RemoteEvent")

-- Battle Pass claim (Sprint 58)
Remotes.ClaimBPReward = getOrCreate("ClaimBPReward", "RemoteEvent")
Remotes.BPRewardClaimed = getOrCreate("BPRewardClaimed", "RemoteEvent")

-- Damage direction (Sprint 61)
Remotes.TookDamage = getOrCreate("TookDamage", "RemoteEvent")  -- server → client z source position

-- Drop weapon (Sprint 62)
Remotes.DropWeapon = getOrCreate("DropWeapon", "RemoteEvent")
Remotes.PickupWeapon = getOrCreate("PickupWeapon", "RemoteEvent")

-- Chat (Sprint 71)
Remotes.SendChat = getOrCreate("SendChat", "RemoteEvent")
Remotes.ChatReceived = getOrCreate("ChatReceived", "RemoteEvent")

-- Weapon slots (Sprint 78)
Remotes.SwitchSlot = getOrCreate("SwitchSlot", "RemoteEvent")

return Remotes
