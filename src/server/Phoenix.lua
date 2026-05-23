-- Phoenix: fire wall + flash + molotov + respawn ultimate
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Phoenix = {}

Phoenix.signatureKey = "E"  -- Hot Hands
Phoenix.signatureMaxCharges = 1

Phoenix.abilityCosts = {
	C = 200,  -- Blaze (wall)
	Q = 250,  -- Curveball (flash)
}

-- Run It Back markers: [player] = { position, expireAt, restoreData }
local runItBackMarkers = {}

-- ============================================================
-- C: Blaze (curved fire wall, dmg enemies + heal Phoenix)
-- ============================================================
local function blaze(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookDir = hrp.CFrame.LookVector
	local wallStart = hrp.Position + lookDir * 5

	-- Straight wall (curving is complex; simplify for MVP)
	local wall = Instance.new("Part")
	wall.Name = "PhoenixBlaze"
	wall.Size = Vector3.new(20, 8, 1)
	wall.CFrame = CFrame.new(wallStart + lookDir * 10, wallStart + lookDir * 11)
	wall.Anchored = true
	wall.CanCollide = false
	wall.Material = Enum.Material.Neon
	wall.Color = Color3.fromRGB(255, 100, 30)
	wall.Transparency = 0.3
	wall.Parent = Workspace

	-- Fire particles
	local fire = Instance.new("Fire")
	fire.Heat = 25
	fire.Size = 20
	fire.Color = Color3.fromRGB(255, 120, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 50, 0)
	fire.Parent = wall

	-- Damage enemies + heal Phoenix every 0.5s
	task.spawn(function()
		local ticks = 16  -- 8s duration
		for _ = 1, ticks do
			if not wall.Parent then break end
			for _, p in ipairs(Players:GetPlayers()) do
				local pchar = p.Character
				if pchar and pchar:FindFirstChild("HumanoidRootPart") then
					local pos = pchar.HumanoidRootPart.Position
					local dist = (pos - wall.Position).Magnitude
					if dist < 12 then
						local hum = pchar:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							if p == player then
								hum.Health = math.min(hum.MaxHealth, hum.Health + 6.25)
							elseif p.Team ~= player.Team then
								hum:TakeDamage(15)
							end
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(wall, 8)
	Remotes.AbilityFired:FireAllClients(player, "Phoenix", "Blaze", wallStart)
	return true
end

-- ============================================================
-- Q: Curveball (flash)
-- ============================================================
local function curveball(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Spawn flash particle at predicted curve endpoint
	local lookDir = hrp.CFrame.LookVector
	local flashPos = hrp.Position + lookDir * 30 + hrp.CFrame.RightVector * 8 + Vector3.new(0, 3, 0)

	local flash = Instance.new("Part")
	flash.Name = "PhoenixFlash"
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(2, 2, 2)
	flash.Position = flashPos
	flash.Anchored = true
	flash.CanCollide = false
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(255, 255, 200)
	flash.Parent = Workspace

	-- Flash all enemies looking at this position
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Team ~= player.Team then
			local pchar = p.Character
			if pchar and pchar:FindFirstChild("HumanoidRootPart") then
				local toFlash = (flashPos - pchar.HumanoidRootPart.Position)
				if toFlash.Magnitude < 40 then
					local pLook = pchar.HumanoidRootPart.CFrame.LookVector
					if toFlash.Unit:Dot(pLook) > 0.6 then
						-- Client should show flash overlay; we just notify
						Remotes.AbilityFired:FireClient(p, "Phoenix", "Flashed", 1.5)
					end
				end
			end
		end
	end

	Debris:AddItem(flash, 0.3)
	Remotes.AbilityFired:FireAllClients(player, "Phoenix", "Curveball", flashPos)
	return true
end

-- ============================================================
-- E: Hot Hands (signature, molotov AOE)
-- ============================================================
local function hotHands(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookDir = hrp.CFrame.LookVector
	local landPos = hrp.Position + lookDir * 25 + Vector3.new(0, -2, 0)

	local fire = Instance.new("Part")
	fire.Name = "PhoenixHotHands"
	fire.Shape = Enum.PartType.Cylinder
	fire.Size = Vector3.new(1, 15, 15)
	fire.CFrame = CFrame.new(landPos) * CFrame.Angles(0, 0, math.rad(90))
	fire.Anchored = true
	fire.CanCollide = false
	fire.Material = Enum.Material.Neon
	fire.Color = Color3.fromRGB(255, 80, 20)
	fire.Transparency = 0.4
	fire.Parent = Workspace

	local fireEffect = Instance.new("Fire")
	fireEffect.Heat = 25
	fireEffect.Size = 25
	fireEffect.Color = Color3.fromRGB(255, 100, 0)
	fireEffect.Parent = fire

	-- DOT 60 dmg/s for 4s (Hot Hands real value)
	task.spawn(function()
		local ticks = 8  -- 4s duration
		for _ = 1, ticks do
			if not fire.Parent then break end
			for _, p in ipairs(Players:GetPlayers()) do
				local pchar = p.Character
				if pchar and pchar:FindFirstChild("HumanoidRootPart") then
					local pos = pchar.HumanoidRootPart.Position
					local dist = (pos - landPos).Magnitude
					if dist < 7.5 then
						local hum = pchar:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							if p == player then
								hum.Health = math.min(hum.MaxHealth, hum.Health + 12.5)  -- heal self
							elseif p.Team ~= player.Team then
								hum:TakeDamage(30)
							end
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(fire, 4)
	Remotes.AbilityFired:FireAllClients(player, "Phoenix", "HotHands", landPos)
	return true
end

-- ============================================================
-- X: Run It Back (mark position, respawn at marker on death or 10s)
-- ============================================================
local function runItBack(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end

	local markerPos = hrp.Position
	local startTime = tick()
	runItBackMarkers[player] = {
		position = markerPos,
		expireAt = startTime + 10,
		startHP = humanoid.Health,
		started = true,
	}

	-- Visual marker
	local marker = Instance.new("Part")
	marker.Name = "RunItBackMarker"
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(2, 2, 2)
	marker.Position = markerPos + Vector3.new(0, 1, 0)
	marker.Anchored = true
	marker.CanCollide = false
	marker.Material = Enum.Material.Neon
	marker.Color = Color3.fromRGB(255, 150, 50)
	marker.Transparency = 0.3
	marker.Parent = Workspace
	Debris:AddItem(marker, 10)

	-- Watch for death or timer
	task.spawn(function()
		local conn
		local doRespawn = function()
			if not runItBackMarkers[player] then return end
			local m = runItBackMarkers[player]
			runItBackMarkers[player] = nil
			player:LoadCharacter()
			task.wait(0.3)
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(m.position + Vector3.new(0, 3, 0))
				local newHum = player.Character:FindFirstChildOfClass("Humanoid")
				if newHum then newHum.Health = newHum.MaxHealth end
			end
			if conn then conn:Disconnect() end
		end

		-- Death listener
		conn = humanoid.Died:Connect(doRespawn)

		-- Timer
		task.wait(10)
		if runItBackMarkers[player] then
			doRespawn()
		end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Phoenix", "RunItBack", markerPos)
	return true
end

-- ============================================================
-- Dispatcher
-- ============================================================
function Phoenix.executeAbility(player, key)
	if key == "C" then return blaze(player) end
	if key == "Q" then return curveball(player) end
	if key == "E" then return hotHands(player) end
	if key == "X" then return runItBack(player) end
	return false
end

return Phoenix
