-- WeaponSlotController: 1/2/3 keys to switch primary/secondary/melee weapon

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local WeaponSlotController = {}

local KEY_TO_SLOT = {
	[Enum.KeyCode.One] = "primary",
	[Enum.KeyCode.Two] = "secondary",
	[Enum.KeyCode.Three] = "melee",
}

function WeaponSlotController.Start()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		local slot = KEY_TO_SLOT[input.KeyCode]
		if slot then
			Remotes.SwitchSlot:FireServer(slot)
		end
	end)
end

return WeaponSlotController
