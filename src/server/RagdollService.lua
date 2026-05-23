-- RagdollService: death effects (ragdoll, gun drop, blood pool)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local RagdollService = {}

local function ragdollCharacter(character)
	-- Make body parts collidable and weighted to collapse
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = true
			part.Massless = false
		end
	end

	-- Replace Motor6Ds with BallSocketConstraints for ragdoll
	for _, joint in ipairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint")
			local a0 = Instance.new("Attachment")
			local a1 = Instance.new("Attachment")
			a0.CFrame = joint.C0
			a1.CFrame = joint.C1
			a0.Parent = joint.Part0
			a1.Parent = joint.Part1
			socket.Attachment0 = a0
			socket.Attachment1 = a1
			socket.LimitsEnabled = true
			socket.UpperAngle = 90
			socket.Parent = joint.Part0
			joint:Destroy()
		end
	end

	-- Apply downward velocity to torso
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.new(
			(math.random() - 0.5) * 10,
			-5,
			(math.random() - 0.5) * 10
		)
	end
end

local function spawnBloodPool(position)
	local pool = Instance.new("Part")
	pool.Name = "BloodPool"
	pool.Anchored = true
	pool.CanCollide = false
	pool.Shape = Enum.PartType.Cylinder
	pool.Size = Vector3.new(0.1, 4, 4)
	pool.CFrame = CFrame.new(position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	pool.Color = Color3.fromRGB(120, 20, 20)
	pool.Material = Enum.Material.SmoothPlastic
	pool.Transparency = 0.3
	pool.Parent = Workspace
	-- Grow over 1s
	local TweenService = game:GetService("TweenService")
	pool.Size = Vector3.new(0.1, 1, 1)
	TweenService:Create(pool, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
		Size = Vector3.new(0.1, 5, 5),
	}):Play()

	Debris:AddItem(pool, 15)
end

local function dropWeapon(position, color)
	local gun = Instance.new("Part")
	gun.Name = "DroppedWeapon"
	gun.Size = Vector3.new(0.3, 0.5, 1.5)
	gun.Position = position + Vector3.new(0, 1, 0)
	gun.Color = color or Color3.fromRGB(40, 40, 50)
	gun.Material = Enum.Material.SmoothPlastic
	gun.CanCollide = true
	gun.Massless = false
	gun.Parent = Workspace
	-- Random tumble
	gun.AssemblyAngularVelocity = Vector3.new(
		math.random(-5, 5),
		math.random(-5, 5),
		math.random(-5, 5)
	)
	gun.AssemblyLinearVelocity = Vector3.new(
		(math.random() - 0.5) * 10,
		2,
		(math.random() - 0.5) * 10
	)
	Debris:AddItem(gun, 10)
end

local function handleDeath(character)
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Spawn effects
	spawnBloodPool(hrp.Position)
	dropWeapon(hrp.Position, Color3.fromRGB(40, 40, 50))

	-- Ragdoll
	ragdollCharacter(character)

	-- Auto-cleanup after 10s
	Debris:AddItem(character, 10)
end

local function bindCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	humanoid.BreakJointsOnDeath = false  -- we handle manually
	humanoid.Died:Connect(function()
		handleDeath(character)
	end)
end

function RagdollService.Start()
	-- Real players
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(bindCharacter)
		if player.Character then bindCharacter(player.Character) end
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterAdded:Connect(bindCharacter)
		if player.Character then bindCharacter(player.Character) end
	end

	-- Bots (in Workspace.Bots folder)
	task.spawn(function()
		while true do
			local botsFolder = Workspace:FindFirstChild("Bots")
			if botsFolder then
				for _, bot in ipairs(botsFolder:GetChildren()) do
					if bot:GetAttribute("Bot") and not bot:GetAttribute("DeathBound") then
						bot:SetAttribute("DeathBound", true)
						bindCharacter(bot)
					end
				end
			end
			task.wait(1)
		end
	end)
end

return RagdollService
