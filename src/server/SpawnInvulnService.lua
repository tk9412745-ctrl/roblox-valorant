-- SpawnInvulnService: 3s invulnerability after respawn + visual outline

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local SpawnInvulnService = {}

local INVULN_DURATION = 3

local function applyInvuln(character)
	if not character then return end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	character:SetAttribute("SpawnInvuln", true)

	-- Visual outline
	local highlight = Instance.new("Highlight")
	highlight.Name = "SpawnInvulnIndicator"
	highlight.FillColor = Color3.fromRGB(80, 200, 255)
	highlight.OutlineColor = Color3.fromRGB(80, 200, 255)
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0
	highlight.Parent = character

	-- Pulsing
	local TweenService = game:GetService("TweenService")
	local pulseTween = TweenService:Create(highlight, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		FillTransparency = 0.4,
	})
	pulseTween:Play()

	task.delay(INVULN_DURATION, function()
		character:SetAttribute("SpawnInvuln", false)
		if highlight.Parent then highlight:Destroy() end
	end)
end

function SpawnInvulnService.IsInvuln(character)
	return character and character:GetAttribute("SpawnInvuln") == true
end

function SpawnInvulnService.Start()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			task.wait(0.3)
			applyInvuln(char)
		end)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterAdded:Connect(function(char)
			task.wait(0.3)
			applyInvuln(char)
		end)
		if player.Character then applyInvuln(player.Character) end
	end
end

return SpawnInvulnService
