local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local TeamService = {}

local attackersTeam, defendersTeam

local function ensureTeams()
	if not attackersTeam then
		attackersTeam = Teams:FindFirstChild(GameConfig.TEAM_ATTACKERS)
		if not attackersTeam then
			attackersTeam = Instance.new("Team")
			attackersTeam.Name = GameConfig.TEAM_ATTACKERS
			attackersTeam.TeamColor = BrickColor.new("Bright red")
			attackersTeam.AutoAssignable = false
			attackersTeam.Parent = Teams
		end
	end
	if not defendersTeam then
		defendersTeam = Teams:FindFirstChild(GameConfig.TEAM_DEFENDERS)
		if not defendersTeam then
			defendersTeam = Instance.new("Team")
			defendersTeam.Name = GameConfig.TEAM_DEFENDERS
			defendersTeam.TeamColor = BrickColor.new("Bright blue")
			defendersTeam.AutoAssignable = false
			defendersTeam.Parent = Teams
		end
	end
end

function TeamService.AssignPlayer(player)
	ensureTeams()
	-- Balance: assign to smaller team
	if #attackersTeam:GetPlayers() <= #defendersTeam:GetPlayers() then
		player.Team = attackersTeam
	else
		player.Team = defendersTeam
	end
end

function TeamService.GetTeam(player)
	if not player.Team then return nil end
	if player.Team.Name == GameConfig.TEAM_ATTACKERS then return "Attackers" end
	if player.Team.Name == GameConfig.TEAM_DEFENDERS then return "Defenders" end
	return nil
end

function TeamService.GetAttackers()
	ensureTeams()
	return attackersTeam:GetPlayers()
end

function TeamService.GetDefenders()
	ensureTeams()
	return defendersTeam:GetPlayers()
end

function TeamService.SameTeam(p1, p2)
	return p1.Team == p2.Team
end

function TeamService.SwapSides()
	ensureTeams()
	local attackers = attackersTeam:GetPlayers()
	local defenders = defendersTeam:GetPlayers()
	for _, p in ipairs(attackers) do
		p.Team = defendersTeam
	end
	for _, p in ipairs(defenders) do
		p.Team = attackersTeam
	end
end

function TeamService.Start()
	ensureTeams()
	Players.PlayerAdded:Connect(function(player)
		task.wait(0.5)
		if not player.Team then
			TeamService.AssignPlayer(player)
		end
	end)
end

return TeamService
