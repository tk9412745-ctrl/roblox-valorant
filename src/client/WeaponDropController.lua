-- WeaponDropController: Q key to drop weapon

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local WeaponDropController = {}

local LocalPlayer = Players.LocalPlayer

function WeaponDropController.Start()
	-- Q key conflicts with abilities. Use G+Q (G modifier) or Y dla drop instead
	-- Actually Q is abilities, G is ping (Push). Let's use Y for drop weapon
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Y then
			Remotes.DropWeapon:FireServer()
		end
	end)

	-- Track current weapon via attribute (set on pickup or buy)
	Remotes.PickupWeapon.OnClientEvent:Connect(function(weaponName)
		LocalPlayer:SetAttribute("CurrentWeapon", weaponName)
	end)
	Remotes.BuyResult.OnClientEvent:Connect(function(success, message)
		if success and message and message:find("^Bought ") then
			local weapon = message:gsub("^Bought ", "")
			LocalPlayer:SetAttribute("CurrentWeapon", weapon)
		end
	end)
end

return WeaponDropController
