-- InventoryController: I key opens inventory screen z owned skins + rotating preview + match history

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local SkinDatabase = require(ReplicatedStorage.Shared:WaitForChild("SkinDatabase"))
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local InventoryController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local menuOpen = false
local currentWeapon = "Vandal"
local inventory = { ownedSkins = {}, equipped = {}, matchHistory = {} }
local previewViewport
local previewModel  -- rotating skin model
local previewRotation = 0

-- Forward declarations
local refreshWeaponList, refreshSkinGrid, refreshHistory

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "InventoryMenu"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	backdrop.BackgroundTransparency = 0.05
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	-- Title + close button
	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 30)
	title.Size = UDim2.fromOffset(400, 50)
	title.BackgroundTransparency = 1
	title.Text = "INVENTORY"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 32
	title.Parent = backdrop

	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -40, 0, 30)
	closeBtn.Size = UDim2.fromOffset(120, 40)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	closeBtn.Text = "CLOSE (I)"
	closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = backdrop
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 6)
	cbCorner.Parent = closeBtn
	closeBtn.Activated:Connect(function()
		menuOpen = false
		gui.Enabled = false
	end)

	-- Left: weapon selector
	local weaponList = Instance.new("ScrollingFrame")
	weaponList.Name = "WeaponList"
	weaponList.Position = UDim2.fromOffset(40, 100)
	weaponList.Size = UDim2.fromOffset(220, 500)
	weaponList.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	weaponList.BackgroundTransparency = 0.2
	weaponList.BorderSizePixel = 0
	weaponList.CanvasSize = UDim2.fromScale(0, 0)
	weaponList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	weaponList.ScrollBarThickness = 6
	weaponList.Parent = backdrop
	local wlCorner = Instance.new("UICorner")
	wlCorner.CornerRadius = UDim.new(0, 8)
	wlCorner.Parent = weaponList

	local wlLayout = Instance.new("UIListLayout")
	wlLayout.Padding = UDim.new(0, 4)
	wlLayout.Parent = weaponList
	local wlPad = Instance.new("UIPadding")
	wlPad.PaddingTop = UDim.new(0, 8)
	wlPad.PaddingLeft = UDim.new(0, 8)
	wlPad.PaddingRight = UDim.new(0, 8)
	wlPad.Parent = weaponList

	-- Center: skin grid + preview
	local skinGrid = Instance.new("ScrollingFrame")
	skinGrid.Name = "SkinGrid"
	skinGrid.Position = UDim2.fromOffset(280, 100)
	skinGrid.Size = UDim2.fromOffset(550, 500)
	skinGrid.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	skinGrid.BackgroundTransparency = 0.2
	skinGrid.BorderSizePixel = 0
	skinGrid.CanvasSize = UDim2.fromScale(0, 0)
	skinGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	skinGrid.ScrollBarThickness = 6
	skinGrid.Parent = backdrop
	local sgCorner = Instance.new("UICorner")
	sgCorner.CornerRadius = UDim.new(0, 8)
	sgCorner.Parent = skinGrid

	local sgLayout = Instance.new("UIGridLayout")
	sgLayout.CellSize = UDim2.fromOffset(160, 100)
	sgLayout.CellPadding = UDim2.fromOffset(8, 8)
	sgLayout.Parent = skinGrid
	local sgPad = Instance.new("UIPadding")
	sgPad.PaddingTop = UDim.new(0, 8)
	sgPad.PaddingLeft = UDim.new(0, 8)
	sgPad.Parent = skinGrid

	-- Right: preview + match history
	local previewPanel = Instance.new("Frame")
	previewPanel.Position = UDim2.fromOffset(850, 100)
	previewPanel.Size = UDim2.fromOffset(380, 240)
	previewPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	previewPanel.BorderSizePixel = 0
	previewPanel.Parent = backdrop
	local pvCorner = Instance.new("UICorner")
	pvCorner.CornerRadius = UDim.new(0, 8)
	pvCorner.Parent = previewPanel

	previewViewport = Instance.new("ViewportFrame")
	previewViewport.Name = "Viewport"
	previewViewport.AnchorPoint = Vector2.new(0.5, 0.5)
	previewViewport.Position = UDim2.fromScale(0.5, 0.5)
	previewViewport.Size = UDim2.fromOffset(360, 220)
	previewViewport.BackgroundTransparency = 1
	previewViewport.Parent = previewPanel

	local vpCam = Instance.new("Camera")
	vpCam.Parent = previewViewport
	previewViewport.CurrentCamera = vpCam

	-- Match history below preview
	local historyPanel = Instance.new("ScrollingFrame")
	historyPanel.Name = "HistoryPanel"
	historyPanel.Position = UDim2.fromOffset(850, 360)
	historyPanel.Size = UDim2.fromOffset(380, 240)
	historyPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	historyPanel.BackgroundTransparency = 0.2
	historyPanel.BorderSizePixel = 0
	historyPanel.CanvasSize = UDim2.fromScale(0, 0)
	historyPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
	historyPanel.ScrollBarThickness = 4
	historyPanel.Parent = backdrop
	local hpCorner = Instance.new("UICorner")
	hpCorner.CornerRadius = UDim.new(0, 8)
	hpCorner.Parent = historyPanel

	local hLayout = Instance.new("UIListLayout")
	hLayout.Padding = UDim.new(0, 4)
	hLayout.Parent = historyPanel

	local historyTitle = Instance.new("TextLabel")
	historyTitle.Size = UDim2.new(1, 0, 0, 24)
	historyTitle.BackgroundTransparency = 1
	historyTitle.Text = "MATCH HISTORY"
	historyTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
	historyTitle.Font = Enum.Font.GothamBold
	historyTitle.TextSize = 12
	historyTitle.LayoutOrder = -1
	historyTitle.Parent = historyPanel

	-- Player rank badge
	local rankBadge = Instance.new("TextLabel")
	rankBadge.Name = "RankBadge"
	rankBadge.AnchorPoint = Vector2.new(0, 0)
	rankBadge.Position = UDim2.fromOffset(40, 30)
	rankBadge.Size = UDim2.fromOffset(180, 40)
	rankBadge.BackgroundTransparency = 1
	rankBadge.Text = LocalPlayer.Name .. " — " .. (LocalPlayer:GetAttribute("Rank") or "Silver 1")
	rankBadge.TextColor3 = Color3.fromRGB(220, 220, 240)
	rankBadge.Font = Enum.Font.GothamBold
	rankBadge.TextSize = 18
	rankBadge.TextXAlignment = Enum.TextXAlignment.Left
	rankBadge.Parent = backdrop
end

function refreshWeaponList()
	if not gui then return end
	local list = gui:FindFirstChild("WeaponList", true)
	if not list then return end
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, wName in ipairs({ "Vandal", "Phantom", "Ghost", "Sheriff", "Operator", "Spectre", "Bulldog", "Guardian" }) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -16, 0, 36)
		btn.BackgroundColor3 = wName == currentWeapon and Color3.fromRGB(60, 60, 90) or Color3.fromRGB(40, 40, 55)
		btn.BorderSizePixel = 0
		btn.Text = "  " .. wName
		btn.TextColor3 = Color3.fromRGB(240, 240, 240)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.Parent = list
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 4)
		bCorner.Parent = btn
		btn.Activated:Connect(function()
			currentWeapon = wName
			refreshWeaponList()
			refreshSkinGrid()
		end)
	end
end

function refreshSkinGrid()
	if not gui then return end
	local grid = gui:FindFirstChild("SkinGrid", true)
	if not grid then return end
	for _, child in ipairs(grid:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local weaponSkins = SkinDatabase.GetForWeapon(currentWeapon)
	for _, skin in ipairs(weaponSkins) do
		local owned = inventory.ownedSkins[skin.Id] ~= nil
		local equipped = inventory.equipped[currentWeapon] == skin.Id

		local card = Instance.new("TextButton")
		card.BackgroundColor3 = equipped and Color3.fromRGB(60, 100, 80)
			or (owned and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(25, 25, 35))
		card.BorderSizePixel = 0
		card.Text = ""
		card.AutoButtonColor = false
		card.Parent = grid
		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 6)
		cCorner.Parent = card

		-- Tier color bar
		local tierBar = Instance.new("Frame")
		tierBar.Size = UDim2.new(1, 0, 0, 4)
		tierBar.BackgroundColor3 = ({
			Color3.fromRGB(150, 150, 170),
			Color3.fromRGB(100, 200, 255),
			Color3.fromRGB(180, 80, 240),
			Color3.fromRGB(255, 180, 60),
			Color3.fromRGB(255, 80, 60),
		})[skin.Tier] or Color3.fromRGB(150, 150, 170)
		tierBar.BorderSizePixel = 0
		tierBar.Parent = card

		-- Name
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, -10, 0, 40)
		nameLbl.Position = UDim2.fromOffset(5, 10)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = skin.DisplayName or skin.Id
		nameLbl.TextColor3 = owned and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(100, 100, 120)
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 12
		nameLbl.TextWrapped = true
		nameLbl.Parent = card

		-- Status
		local statusLbl = Instance.new("TextLabel")
		statusLbl.AnchorPoint = Vector2.new(0, 1)
		statusLbl.Position = UDim2.new(0, 5, 1, -5)
		statusLbl.Size = UDim2.new(1, -10, 0, 20)
		statusLbl.BackgroundTransparency = 1
		statusLbl.Text = equipped and "✓ EQUIPPED" or (owned and "OWNED" or "LOCKED")
		statusLbl.TextColor3 = equipped and Color3.fromRGB(80, 220, 120)
			or (owned and Color3.fromRGB(220, 200, 80) or Color3.fromRGB(120, 120, 130))
		statusLbl.Font = Enum.Font.GothamBold
		statusLbl.TextSize = 10
		statusLbl.TextXAlignment = Enum.TextXAlignment.Left
		statusLbl.Parent = card

		if owned and not equipped then
			card.Activated:Connect(function()
				Remotes.EquipSkin:FireServer(currentWeapon, skin.Id)
				inventory.equipped[currentWeapon] = skin.Id
				refreshSkinGrid()
			end)
		end

		-- Click to preview (even if locked)
		card.MouseEnter:Connect(function()
			InventoryController.SetPreviewSkin(skin)
		end)
	end
end

function InventoryController.SetPreviewSkin(skin)
	if not previewViewport then return end
	if previewModel then previewModel:Destroy() end

	previewModel = Instance.new("Model")
	previewModel.Name = "PreviewSkin"

	-- Simple gun shape colored by skin
	local gun = Instance.new("Part")
	gun.Size = Vector3.new(0.3, 0.5, 1.6)
	gun.Color = skin.Color or Color3.fromRGB(50, 50, 60)
	gun.Material = skin.Material or Enum.Material.SmoothPlastic
	gun.Anchored = true
	gun.CanCollide = false
	gun.Parent = previewModel

	local grip = Instance.new("Part")
	grip.Size = Vector3.new(0.3, 0.75, 0.5)
	grip.CFrame = gun.CFrame * CFrame.new(0, -0.4, 0.3)
	grip.Color = Color3.fromRGB(20, 20, 25)
	grip.Material = Enum.Material.SmoothPlastic
	grip.Anchored = true
	grip.CanCollide = false
	grip.Parent = previewModel

	previewModel.Parent = previewViewport
	previewRotation = 0
end

function refreshHistory()
	if not gui then return end
	local panel = gui:FindFirstChild("HistoryPanel", true)
	if not panel then return end
	for _, child in ipairs(panel:GetChildren()) do
		if child:IsA("TextLabel") and child.Name ~= "" and child.LayoutOrder ~= -1 then
			child:Destroy()
		end
	end

	for i, match in ipairs(inventory.matchHistory or {}) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -10, 0, 30)
		lbl.BackgroundColor3 = match.won and Color3.fromRGB(30, 60, 40) or Color3.fromRGB(60, 30, 30)
		lbl.BackgroundTransparency = 0.3
		lbl.BorderSizePixel = 0
		lbl.Text = string.format("  %s | %s | %d/%d/%d | ACS %d",
			match.won and "W" or "L",
			match.agent or "?",
			match.kills, match.deaths, match.assists,
			match.acs
		)
		lbl.TextColor3 = Color3.fromRGB(220, 220, 240)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.LayoutOrder = i
		lbl.Parent = panel
		local lCorner = Instance.new("UICorner")
		lCorner.CornerRadius = UDim.new(0, 4)
		lCorner.Parent = lbl
	end
end

function InventoryController.Open()
	if not gui then buildGui() end
	gui.Enabled = true
	menuOpen = true
	Remotes.RequestInventory:FireServer()
	refreshWeaponList()
	refreshSkinGrid()
	refreshHistory()
end

function InventoryController.Close()
	if gui then gui.Enabled = false end
	menuOpen = false
end

function InventoryController.Start()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.I then
			if menuOpen then InventoryController.Close() else InventoryController.Open() end
		end
	end)

	Remotes.UpdateInventory.OnClientEvent:Connect(function(data)
		if data then
			inventory = data
			if menuOpen then
				refreshSkinGrid()
				refreshHistory()
			end
		end
	end)

	-- Rotate preview model
	RunService.RenderStepped:Connect(function(dt)
		if previewModel and previewViewport then
			previewRotation += dt * 0.8
			local cam = previewViewport.CurrentCamera
			if cam then
				cam.CFrame = CFrame.new(
					Vector3.new(math.cos(previewRotation) * 4, 1, math.sin(previewRotation) * 4),
					Vector3.new(0, 0, 0)
				)
			end
		end
	end)
end

return InventoryController
