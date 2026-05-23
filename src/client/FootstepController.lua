-- FootstepController: footstep audio based on movement + surface material
-- Walking (Shift) = silent, Crouch (Ctrl) = silent, Running = audible

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local FootstepController = {}

local LocalPlayer = Players.LocalPlayer

local FOOTSTEP_SOUNDS = {
	[Enum.Material.Concrete] = "rbxasset://sounds/electronicpingshort.wav",
	[Enum.Material.WoodPlanks] = "rbxasset://sounds/button.wav",
	[Enum.Material.Wood] = "rbxasset://sounds/button.wav",
	[Enum.Material.Metal] = "rbxasset://sounds/clickfast.wav",
	[Enum.Material.Grass] = "rbxasset://sounds/short bell sound.wav",
	[Enum.Material.Brick] = "rbxasset://sounds/electronicpingshort.wav",
	Default = "rbxasset://sounds/electronicpingshort.wav",
}

local STEP_INTERVAL_RUN = 0.4
local STEP_INTERVAL_WALK = 0.7

local lastStepTime = 0
local wasAirborne = false

local function getStepSound(material)
	return FOOTSTEP_SOUNDS[material] or FOOTSTEP_SOUNDS.Default
end

local function playStep(position, material, volume)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position
	part.Parent = Workspace

	local sound = Instance.new("Sound")
	sound.SoundId = getStepSound(material)
	sound.Volume = volume or 0.2
	sound.RollOffMaxDistance = 60
	sound.RollOffMinDistance = 5
	sound.Parent = part
	sound:Play()
	Debris:AddItem(part, 1)
end

function FootstepController.Start()
	task.spawn(function()
		while true do
			local now = time()
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if humanoid and hrp then
					local moveSpeed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
					local floorMaterial = humanoid.FloorMaterial
					local isAirborne = floorMaterial == Enum.Material.Air or not floorMaterial

					-- Landing sound
					if not isAirborne and wasAirborne then
						playStep(hrp.Position - Vector3.new(0, 3, 0), floorMaterial or Enum.Material.Concrete, 0.4)
					end
					wasAirborne = isAirborne

					-- Determine mode from WalkSpeed
					local mode = "Run"
					if humanoid.WalkSpeed <= 8 then mode = "Crouch"
					elseif humanoid.WalkSpeed <= 12 then mode = "Walk" end

					if not isAirborne and moveSpeed > 5 then
						local interval = (mode == "Walk" or mode == "Crouch") and STEP_INTERVAL_WALK or STEP_INTERVAL_RUN
						if now - lastStepTime > interval then
							local volume = mode == "Run" and 0.3 or 0.06
							if volume > 0.08 then
								playStep(hrp.Position - Vector3.new(0, 3, 0), floorMaterial or Enum.Material.Concrete, volume)
							end
							lastStepTime = now
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end

return FootstepController
