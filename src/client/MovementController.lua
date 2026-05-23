-- MovementController: crouch (Ctrl) + walk (Shift) modes
-- Crouch: -0.17° spread bonus, slower move (~7), lower camera
-- Walk: slower move (~10), silent footsteps
-- Run: default (16)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local MovementController = {}

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local SPEED_RUN = 16
local SPEED_WALK = 10
local SPEED_CROUCH = 7

local currentMode = "Run"  -- "Run", "Walk", "Crouch"
local crouchHeld = false
local walkHeld = false

local function applyMode()
	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local newMode = "Run"
	if crouchHeld then
		newMode = "Crouch"
	elseif walkHeld then
		newMode = "Walk"
	end

	if newMode == currentMode then return end
	currentMode = newMode

	if newMode == "Crouch" then
		humanoid.WalkSpeed = SPEED_CROUCH
		humanoid.HipHeight = 0  -- lower body
		humanoid.CameraOffset = Vector3.new(0, -1.5, 0)  -- camera lower
	elseif newMode == "Walk" then
		humanoid.WalkSpeed = SPEED_WALK
		humanoid.HipHeight = 2
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
	else
		humanoid.WalkSpeed = SPEED_RUN
		humanoid.HipHeight = 2
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end

	-- Notify server
	Remotes.SetMovementMode:FireServer(newMode)
end

function MovementController.GetMode()
	return currentMode
end

function MovementController.Start()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			crouchHeld = true
			applyMode()
		elseif input.KeyCode == Enum.KeyCode.LeftShift then
			walkHeld = true
			applyMode()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			crouchHeld = false
			applyMode()
		elseif input.KeyCode == Enum.KeyCode.LeftShift then
			walkHeld = false
			applyMode()
		end
	end)

	-- Reset on respawn
	LocalPlayer.CharacterAdded:Connect(function()
		crouchHeld = false
		walkHeld = false
		currentMode = "Run"
		task.wait(0.3)
		applyMode()
	end)
end

return MovementController
