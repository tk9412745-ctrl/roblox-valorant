local Players = game:GetService("Players")

local SpawnService = {}

function SpawnService.Start()
	Players.RespawnTime = 3

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.MaxHealth = 100
			humanoid.Health = 100
			humanoid.WalkSpeed = 16
			humanoid.JumpHeight = 7.5
			humanoid.AutoRotate = true
		end)
	end)
end

return SpawnService
