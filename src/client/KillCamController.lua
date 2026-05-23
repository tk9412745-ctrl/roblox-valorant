-- KillCamController: client-side death cam
-- On player death, transition camera to scriptable, focus on last damage source

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local KillCamController = {}

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local killCamActive = false
local killCamConnection

local function findFocusTarget()
	-- Find nearest other player (likely killer) — simplified MVP
	local closest = nil
	local closestDist = math.huge
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
			if ohrp then
				local d = (ohrp.Position - hrp.Position).Magnitude
				if d < closestDist and d > 5 then
					closest = ohrp
					closestDist = d
				end
			end
		end
	end
	return closest
end

local function startKillCam()
	if killCamActive then return end
	killCamActive = true

	local target = findFocusTarget()
	camera.CameraType = Enum.CameraType.Scriptable

	local startCFrame = camera.CFrame
	killCamConnection = RunService.RenderStepped:Connect(function(dt)
		if not killCamActive then return end
		if target and target.Parent then
			local lookAt = target.Position + Vector3.new(0, 1.5, 0)
			local camPos = lookAt - target.CFrame.LookVector * 12 + Vector3.new(0, 3, 0)
			camera.CFrame = CFrame.lookAt(camPos, lookAt)
		else
			-- No target found: hover above last death position
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 8, 0), hrp.Position)
			end
		end
	end)
end

local function endKillCam()
	if not killCamActive then return end
	killCamActive = false
	if killCamConnection then
		killCamConnection:Disconnect()
		killCamConnection = nil
	end
	camera.CameraType = Enum.CameraType.Custom
end

function KillCamController.Start()
	local function bindToCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			startKillCam()
		end)
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		endKillCam()
		bindToCharacter(character)
	end)
	if LocalPlayer.Character then
		bindToCharacter(LocalPlayer.Character)
	end
end

return KillCamController
