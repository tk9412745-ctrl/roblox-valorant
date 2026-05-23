local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local FPSCamera = {}

local function hideBodyParts(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			-- LockFirstPerson auto-hides Head, but arms/torso can clip the camera
			if part.Name ~= "HumanoidRootPart" then
				part.LocalTransparencyModifier = 1
			end
		elseif part:IsA("Decal") then
			part.Transparency = 1
		end
	end
end

local function setupCharacter(character)
	character:WaitForChild("Humanoid")
	-- New parts may stream in (clothing, accessories) — hide them too
	character.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") and desc.Name ~= "HumanoidRootPart" then
			desc.LocalTransparencyModifier = 1
		end
	end)
	hideBodyParts(character)
end

function FPSCamera.Start()
	LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

	LocalPlayer.CharacterAdded:Connect(setupCharacter)
	if LocalPlayer.Character then
		setupCharacter(LocalPlayer.Character)
	end
end

function FPSCamera.GetLookVector()
	return workspace.CurrentCamera.CFrame.LookVector
end

function FPSCamera.GetCameraPosition()
	return workspace.CurrentCamera.CFrame.Position
end

return FPSCamera
