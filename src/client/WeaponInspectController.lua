-- WeaponInspectController: T key shows viewmodel up-close + rotating + stats overlay

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local WeaponInspectController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local gui
local inspecting = false
local rotation = 0
local statsLbl

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "WeaponInspect"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	-- Stats overlay (bottom of screen)
	local statsFrame = Instance.new("Frame")
	statsFrame.AnchorPoint = Vector2.new(0.5, 1)
	statsFrame.Position = UDim2.new(0.5, 0, 1, -100)
	statsFrame.Size = UDim2.fromOffset(500, 180)
	statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	statsFrame.BackgroundTransparency = 0.2
	statsFrame.BorderSizePixel = 0
	statsFrame.Parent = gui
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 8)
	sCorner.Parent = statsFrame

	statsLbl = Instance.new("TextLabel")
	statsLbl.Name = "Stats"
	statsLbl.Size = UDim2.fromScale(1, 1)
	statsLbl.BackgroundTransparency = 1
	statsLbl.Text = ""
	statsLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
	statsLbl.Font = Enum.Font.GothamBold
	statsLbl.TextSize = 16
	statsLbl.TextWrapped = true
	statsLbl.RichText = true
	statsLbl.Parent = statsFrame
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 20)
	pad.PaddingRight = UDim.new(0, 20)
	pad.PaddingTop = UDim.new(0, 10)
	pad.Parent = statsFrame

	-- Hint
	local hint = Instance.new("TextLabel")
	hint.AnchorPoint = Vector2.new(0.5, 0)
	hint.Position = UDim2.new(0.5, 0, 0, 100)
	hint.Size = UDim2.fromOffset(400, 30)
	hint.BackgroundTransparency = 1
	hint.Text = "[T] Release to stop inspecting"
	hint.TextColor3 = Color3.fromRGB(180, 180, 200)
	hint.Font = Enum.Font.GothamBold
	hint.TextSize = 14
	hint.Parent = gui
end

local function getCurrentWeaponName()
	-- Get from WeaponController
	local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
	if PlayerScripts then
		local wc = PlayerScripts:FindFirstChild("WeaponController")
		if wc then
			local ok, module = pcall(require, wc)
			if ok and module and module.GetCurrentWeapon then
				return module.GetCurrentWeapon()
			end
		end
	end
	return "Vandal"
end

local function updateStats(weaponName)
	if not statsLbl then return end
	local w = WeaponDatabase[weaponName]
	if not w then return end

	local lines = {
		string.format("<b><font size=\"24\">%s</font></b>", w.DisplayName or weaponName),
		string.format("<font color=\"#ffdd66\">%s</font>", w.Category or "Unknown"),
		"",
	}
	if w.Price then table.insert(lines, string.format("Cost: <font color=\"#ffdd66\">%d cr</font>", w.Price)) end
	if w.FireRate then table.insert(lines, string.format("Fire Rate: %.2f rps", w.FireRate)) end
	if w.MagazineSize then table.insert(lines, string.format("Magazine: %d / %d", w.MagazineSize, w.ReserveAmmo or 0)) end
	if w.ReloadTime then table.insert(lines, string.format("Reload: %.1f s", w.ReloadTime)) end
	if w.Damage and w.Damage[1] then
		local d = w.Damage[1]
		table.insert(lines, string.format("Damage: <font color=\"#ff8888\">H %d</font> / B %d / L %d", d.Head or 0, d.Body or 0, d.Leg or 0))
	end
	if w.WallPen then table.insert(lines, "Wall Pen: " .. w.WallPen) end
	statsLbl.Text = table.concat(lines, "\n")
end

local function startInspect()
	if inspecting then return end
	inspecting = true
	gui.Enabled = true
	rotation = 0
	local weaponName = getCurrentWeaponName()
	updateStats(weaponName)
end

local function stopInspect()
	inspecting = false
	if gui then gui.Enabled = false end
end

local function tick(dt)
	if not inspecting then return end
	rotation += dt * 0.6  -- spin slowly

	-- Find viewmodel + apply inspect transform
	local vm = camera:FindFirstChild("Viewmodel")
	if not vm then return end
	local gunPart = vm:FindFirstChild("Gun")
	if not gunPart then return end

	-- Move gun to "inspect" position (centered, rotating)
	local baseCFrame = camera.CFrame * CFrame.new(0, -0.2, -1.8)
	gunPart.CFrame = baseCFrame * CFrame.Angles(0, rotation, math.rad(15))
	-- Reposition other parts relative
	for _, child in ipairs(vm:GetChildren()) do
		if child:IsA("BasePart") and child ~= gunPart then
			local offset = child:GetAttribute("Offset")
			if offset then
				child.CFrame = gunPart.CFrame * CFrame.new(offset)
			end
		end
	end
end

function WeaponInspectController.Start()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.T then
			startInspect()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.T then
			stopInspect()
		end
	end)

	RunService.RenderStepped:Connect(tick)
end

return WeaponInspectController
