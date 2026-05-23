-- KAY/O: FRAG/ment + FLASH/drive + ZERO/point + NULL/cmd
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local KAYO = {}

KAYO.signatureKey = "E"  -- ZERO/point (free, recharges on kill)
KAYO.signatureMaxCharges = 1
KAYO.abilityCosts = {
	C = 200,  -- FRAG/ment
	Q = 250,  -- FLASH/drive (×2 charges)
}

local suppressedPlayers = {}  -- [player] = expire time

function KAYO.IsSuppressed(player)
	return suppressedPlayers[player] and tick() < suppressedPlayers[player]
end

-- ============================================================
-- C: FRAG/ment (sticky pulsing AOE)
-- ============================================================
local function fragment(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local landPos = hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, -2, 0)

	local explosive = Instance.new("Part")
	explosive.Name = "KAYOFragment"
	explosive.Size = Vector3.new(0.8, 0.8, 0.8)
	explosive.Position = landPos + Vector3.new(0, 0.5, 0)
	explosive.Anchored = true
	explosive.Color = Color3.fromRGB(255, 100, 50)
	explosive.Material = Enum.Material.Neon
	explosive.Parent = Workspace

	-- Pulse 4 times, 0.5s apart
	task.spawn(function()
		for _ = 1, 4 do
			if not explosive.Parent then break end
			-- Visual pulse
			local pulse = Instance.new("Part")
			pulse.Shape = Enum.PartType.Ball
			pulse.Size = Vector3.new(12, 12, 12)
			pulse.Position = explosive.Position
			pulse.Anchored = true
			pulse.CanCollide = false
			pulse.Color = Color3.fromRGB(255, 80, 30)
			pulse.Material = Enum.Material.Neon
			pulse.Transparency = 0.6
			pulse.Parent = Workspace
			Debris:AddItem(pulse, 0.3)

			-- Damage players in radius
			for _, otherPlayer in ipairs(Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Team ~= player.Team and otherPlayer.Character then
					local oHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
					if oHRP and (oHRP.Position - landPos).Magnitude < 6 then
						local hum = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum:TakeDamage(60) end
					end
				end
			end
			task.wait(0.5)
		end
		if explosive.Parent then explosive:Destroy() end
	end)

	Remotes.AbilityFired:FireAllClients(player, "KAYO", "FRAGment", landPos)
	return true
end

-- ============================================================
-- Q: FLASH/drive (flash projectile)
-- ============================================================
local function flashdrive(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local landPos = hrp.Position + hrp.CFrame.LookVector * 30 + Vector3.new(0, 3, 0)

	-- Flash all enemies looking at land position
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Team ~= player.Team and otherPlayer.Character then
			local oHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if oHRP then
				local toFlash = (landPos - oHRP.Position)
				if toFlash.Magnitude < 40 then
					local lookVec = oHRP.CFrame.LookVector
					if toFlash.Unit:Dot(lookVec) > 0.5 then
						Remotes.AbilityFired:FireClient(otherPlayer, "KAYO", "Flashed", 1.8)
					end
				end
			end
		end
	end

	-- Visual flash burst
	local flash = Instance.new("Part")
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(3, 3, 3)
	flash.Position = landPos
	flash.Anchored = true
	flash.CanCollide = false
	flash.Color = Color3.fromRGB(255, 255, 200)
	flash.Material = Enum.Material.Neon
	flash.Parent = Workspace
	Debris:AddItem(flash, 0.3)

	Remotes.AbilityFired:FireAllClients(player, "KAYO", "FLASHdrive", landPos)
	return true
end

-- ============================================================
-- E: ZERO/point (suppression blade)
-- ============================================================
local function zeropoint(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Direct raycast forward — first enemy hit gets suppressed
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { char }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = Workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), hrp.CFrame.LookVector * 60, params)

	-- Visual blade tracer
	local from = hrp.Position + Vector3.new(0, 1, 0)
	local to = result and result.Position or (from + hrp.CFrame.LookVector * 60)
	local blade = Instance.new("Part")
	blade.Size = Vector3.new(0.3, 0.3, (to - from).Magnitude)
	blade.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -((to - from).Magnitude) / 2)
	blade.Anchored = true
	blade.CanCollide = false
	blade.Color = Color3.fromRGB(100, 200, 255)
	blade.Material = Enum.Material.Neon
	blade.Parent = Workspace
	Debris:AddItem(blade, 0.4)

	if result then
		local hitChar = result.Instance:FindFirstAncestorWhichIsA("Model")
		if hitChar then
			local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
			if hitPlayer and hitPlayer.Team ~= player.Team then
				suppressedPlayers[hitPlayer] = tick() + 8
				-- Visual: pulse the player
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(100, 200, 255)
				highlight.OutlineColor = Color3.fromRGB(100, 200, 255)
				highlight.FillTransparency = 0.3
				highlight.Parent = hitChar
				Debris:AddItem(highlight, 8)
				-- Set attribute so other ability checks can see
				hitPlayer:SetAttribute("Suppressed", true)
				task.delay(8, function()
					if hitPlayer then hitPlayer:SetAttribute("Suppressed", false) end
				end)
			end
		end
	end

	Remotes.AbilityFired:FireAllClients(player, "KAYO", "ZEROpoint", from)
	return true
end

-- ============================================================
-- X: NULL/cmd (area suppression + KAY/O can be revived)
-- ============================================================
local function nullcmd(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local center = hrp.Position

	-- Suppress all enemies in 40 stud radius for 12s
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Team ~= player.Team and otherPlayer.Character then
			local oHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if oHRP and (oHRP.Position - center).Magnitude < 40 then
				suppressedPlayers[otherPlayer] = tick() + 12
				otherPlayer:SetAttribute("Suppressed", true)
				task.delay(12, function()
					if otherPlayer then otherPlayer:SetAttribute("Suppressed", false) end
				end)
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(100, 200, 255)
				highlight.FillTransparency = 0.4
				highlight.Parent = otherPlayer.Character
				Debris:AddItem(highlight, 12)
			end
		end
	end

	-- KAY/O fire rate buff for 12s
	player:SetAttribute("KAYOUlt", true)
	task.delay(12, function()
		if player then player:SetAttribute("KAYOUlt", false) end
	end)

	-- Visual: large blue dome
	local dome = Instance.new("Part")
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(80, 80, 80)
	dome.Position = center
	dome.Anchored = true
	dome.CanCollide = false
	dome.Color = Color3.fromRGB(100, 200, 255)
	dome.Material = Enum.Material.Neon
	dome.Transparency = 0.85
	dome.Parent = Workspace
	Debris:AddItem(dome, 12)

	Remotes.AbilityFired:FireAllClients(player, "KAYO", "NULLcmd", center)
	return true
end

function KAYO.executeAbility(player, key)
	if key == "C" then return fragment(player) end
	if key == "Q" then return flashdrive(player) end
	if key == "E" then return zeropoint(player) end
	if key == "X" then return nullcmd(player) end
	return false
end

return KAYO
