-- PerformanceController: runtime culling + LOD + particle limits

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local PerformanceController = {}

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CULL_DISTANCE_TRACER = 150
local CULL_DISTANCE_DECAL = 80
local CULL_DISTANCE_DROPPED = 100

local function getCameraPos()
	return camera and camera.CFrame.Position
end

-- Periodically remove distant ephemeral parts to keep render budget low
function PerformanceController.Start()
	task.spawn(function()
		while true do
			task.wait(2)
			local camPos = getCameraPos()
			if not camPos then
				task.wait(1)
			else
				for _, part in ipairs(Workspace:GetChildren()) do
					if part:IsA("BasePart") then
						-- Cull distant bullet decals (BulletHole)
						if part.Name == "" then continue end
						if part:GetAttribute("IsDecal") and (part.Position - camPos).Magnitude > CULL_DISTANCE_DECAL then
							part:Destroy()
						elseif part.Name == "DroppedWeapon" and (part.Position - camPos).Magnitude > CULL_DISTANCE_DROPPED then
							-- Don't destroy — just dim
							part.Transparency = math.min(0.7, ((part.Position - camPos).Magnitude - CULL_DISTANCE_DROPPED) / 100)
						end
					end
				end
			end
		end
	end)

	-- Limit particle count: when too many effects active, reduce particle quality
	task.spawn(function()
		while true do
			task.wait(5)
			local emitterCount = 0
			for _, descendant in ipairs(Workspace:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					emitterCount += 1
				end
			end
			if emitterCount > 50 then
				-- Lower particle quality globally
				for _, descendant in ipairs(Workspace:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						descendant.Rate = math.max(0, descendant.Rate * 0.5)
					end
				end
			end
		end
	end)
end

return PerformanceController
