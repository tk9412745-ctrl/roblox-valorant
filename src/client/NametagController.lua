-- NametagController: BillboardGui nad każdym graczem (oprócz LocalPlayer)
-- Pokazuje imię + HP bar w kolorze drużyny

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local NametagController = {}

local LocalPlayer = Players.LocalPlayer
local nameTags = {}  -- [player] = { gui, char }

local function teamColor(player)
	if not player.Team then return Color3.fromRGB(180, 180, 200) end
	if player.Team.Name == "Attackers" then return Color3.fromRGB(255, 80, 80) end
	if player.Team.Name == "Defenders" then return Color3.fromRGB(80, 120, 255) end
	return Color3.fromRGB(180, 180, 200)
end

local function createNameTag(player, character)
	local head = character:WaitForChild("Head", 5)
	if not head then return end

	local existing = head:FindFirstChild("NameTagGui")
	if existing then existing:Destroy() end

	local bg = Instance.new("BillboardGui")
	bg.Name = "NameTagGui"
	bg.Size = UDim2.fromOffset(160, 50)
	bg.StudsOffset = Vector3.new(0, 2.5, 0)
	bg.AlwaysOnTop = true
	bg.MaxDistance = 60  -- LOD: hide beyond 60 studs (performance)
	bg.LightInfluence = 0
	bg.Parent = head

	local container = Instance.new("Frame")
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = bg

	-- Player name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, 0, 0, 24)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = player.Name
	nameLbl.TextColor3 = teamColor(player)
	nameLbl.TextStrokeTransparency = 0
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 16
	nameLbl.Parent = container

	-- Agent label (smaller, below name)
	local agentLbl = Instance.new("TextLabel")
	agentLbl.Name = "AgentLabel"
	agentLbl.Size = UDim2.new(1, 0, 0, 14)
	agentLbl.Position = UDim2.fromOffset(0, 22)
	agentLbl.BackgroundTransparency = 1
	agentLbl.Text = player:GetAttribute("Agent") or ""
	agentLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	agentLbl.TextStrokeTransparency = 0.5
	agentLbl.Font = Enum.Font.Gotham
	agentLbl.TextSize = 11
	agentLbl.Parent = container

	-- HP bar
	local hpBg = Instance.new("Frame")
	hpBg.Name = "HPBg"
	hpBg.Size = UDim2.new(0.8, 0, 0, 4)
	hpBg.Position = UDim2.new(0.5, 0, 1, -6)
	hpBg.AnchorPoint = Vector2.new(0.5, 1)
	hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	hpBg.BorderSizePixel = 0
	hpBg.Parent = container

	local hpBar = Instance.new("Frame")
	hpBar.Name = "HPBar"
	hpBar.Size = UDim2.fromScale(1, 1)
	hpBar.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	hpBar.BorderSizePixel = 0
	hpBar.Parent = hpBg

	-- Update on HP changed
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.HealthChanged:Connect(function(hp)
			hpBar.Size = UDim2.fromScale(math.max(0, hp / humanoid.MaxHealth), 1)
			if hp < 30 then hpBar.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			elseif hp < 70 then hpBar.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
			else hpBar.BackgroundColor3 = Color3.fromRGB(80, 220, 120) end
		end)
	end

	-- Update on team change
	player:GetPropertyChangedSignal("Team"):Connect(function()
		nameLbl.TextColor3 = teamColor(player)
	end)

	-- Update agent label when agent changes
	player:GetAttributeChangedSignal("Agent"):Connect(function()
		agentLbl.Text = player:GetAttribute("Agent") or ""
	end)

	-- Hide for self or enemies (Valorant style: enemies not visible)
	local function refreshVisibility()
		if player == LocalPlayer then
			bg.Enabled = false
		elseif player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
			bg.Enabled = true
		else
			bg.Enabled = false  -- enemy: hidden
		end
	end
	refreshVisibility()
	player:GetPropertyChangedSignal("Team"):Connect(refreshVisibility)
	LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshVisibility)

	nameTags[player] = { gui = bg, char = character }
end

local function bindPlayer(player)
	if player == LocalPlayer then
		-- Watch for character but don't show own nametag
		player.CharacterAdded:Connect(function(char)
			-- Hide any character-attached BillboardGuis on respawn
			local head = char:WaitForChild("Head", 5)
			if head then
				local existing = head:FindFirstChild("NameTagGui")
				if existing then existing.Enabled = false end
			end
		end)
		return
	end

	if player.Character then createNameTag(player, player.Character) end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		createNameTag(player, char)
	end)
end

function NametagController.Start()
	for _, p in ipairs(Players:GetPlayers()) do
		bindPlayer(p)
	end
	Players.PlayerAdded:Connect(bindPlayer)
	Players.PlayerRemoving:Connect(function(p)
		nameTags[p] = nil
	end)
end

return NametagController
