-- FallDamageService: applies fall damage based on fall distance (Valorant-style)
-- Fall >10 studs = damage, >40 studs = death

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local FallDamageService = {}

local THRESHOLD_DAMAGE = 10  -- studs
local THRESHOLD_DEATH = 40   -- studs
local DAMAGE_PER_STUD = 3    -- linear above threshold

local fallStart = {}  -- [player] = Y position when started falling

local function processCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	local lastFloorY = hrp.Position.Y
	local wasAirborne = false

	-- Tick fall tracking
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not character.Parent or humanoid.Health <= 0 then
			if conn then conn:Disconnect() end
			return
		end

		local isAirborne = humanoid.FloorMaterial == Enum.Material.Air or not humanoid.FloorMaterial

		if isAirborne then
			-- Starting fall — track peak Y
			if not wasAirborne then
				fallStart[player] = hrp.Position.Y
			end
			-- Update peak
			if fallStart[player] and hrp.Position.Y > fallStart[player] then
				fallStart[player] = hrp.Position.Y
			end
		else
			-- Landed — check fall distance
			if wasAirborne and fallStart[player] then
				local fallDist = fallStart[player] - hrp.Position.Y
				if fallDist > THRESHOLD_DEATH then
					humanoid.Health = 0
				elseif fallDist > THRESHOLD_DAMAGE then
					local damage = (fallDist - THRESHOLD_DAMAGE) * DAMAGE_PER_STUD
					humanoid:TakeDamage(damage)
				end
				fallStart[player] = nil
			end
		end
		wasAirborne = isAirborne
	end)
end

function FallDamageService.Start()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then processCharacter(player, player.Character) end
		player.CharacterAdded:Connect(function(char) processCharacter(player, char) end)
	end
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char) processCharacter(player, char) end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		fallStart[player] = nil
	end)
end

return FallDamageService
