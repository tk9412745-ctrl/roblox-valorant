-- WeaponDropService: drop weapon (Q) + pickup (Touched)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local WeaponDatabase = require(ReplicatedStorage.Shared.WeaponDatabase)

local WeaponDropService = {}
local combat  -- set via Init

function WeaponDropService.Init(deps)
	combat = deps.combat
end

local pickupCooldown = {}  -- [player] = tick of last pickup

local function spawnDroppedWeapon(weaponName, position, droppedBy)
	local w = WeaponDatabase[weaponName]
	if not w then return end

	local gun = Instance.new("Part")
	gun.Name = "DroppedWeapon"
	gun.Size = Vector3.new(0.5, 0.5, 1.5)
	gun.Position = position + Vector3.new(0, 2, 0)
	gun.Color = Color3.fromRGB(40, 40, 50)
	gun.Material = Enum.Material.Metal
	gun.CanCollide = true
	gun:SetAttribute("DroppedWeapon", weaponName)
	gun:SetAttribute("DroppedBy", droppedBy and droppedBy.UserId or 0)
	gun.Parent = Workspace

	-- Floating BillboardGui showing weapon name
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.fromOffset(150, 30)
	bg.StudsOffset = Vector3.new(0, 1.5, 0)
	bg.AlwaysOnTop = true
	bg.Parent = gun

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = weaponName
	lbl.TextColor3 = Color3.fromRGB(255, 220, 80)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg

	-- Slight tumble
	gun.AssemblyAngularVelocity = Vector3.new(
		math.random(-3, 3),
		math.random(-3, 3),
		math.random(-3, 3)
	)

	-- Auto-cleanup after 30s
	Debris:AddItem(gun, 30)

	-- Pickup on touch
	gun.Touched:Connect(function(hit)
		local model = hit:FindFirstAncestorWhichIsA("Model")
		if not model then return end
		local player = Players:GetPlayerFromCharacter(model)
		if not player then return end
		-- Cooldown
		if pickupCooldown[player] and (tick() - pickupCooldown[player]) < 1 then return end
		pickupCooldown[player] = tick()

		if combat and combat.SetWeapon then
			combat.SetWeapon(player, weaponName)
		end
		Remotes.PickupWeapon:FireClient(player, weaponName)
		gun:Destroy()
	end)
end

function WeaponDropService.Start()
	Remotes.DropWeapon.OnServerEvent:Connect(function(player)
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- Get current weapon (from CombatService internal state — we need an accessor)
		-- For MVP, use attribute set by client
		local currentWeapon = player:GetAttribute("CurrentWeapon") or "Vandal"

		spawnDroppedWeapon(currentWeapon, hrp.Position + hrp.CFrame.LookVector * 3, player)

		-- Reset to Classic
		if combat and combat.SetWeapon then
			combat.SetWeapon(player, "Classic")
		end
	end)

	Players.PlayerRemoving:Connect(function(p)
		pickupCooldown[p] = nil
	end)
end

return WeaponDropService
