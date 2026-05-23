-- FriendService: per-player friend list, chat commands

local Players = game:GetService("Players")

local FriendService = {}
local PlayerData

function FriendService.Init(deps)
	PlayerData = deps.playerData
end

local function addFriend(player, friendName)
	local target = Players:FindFirstChild(friendName)
	if not target then return false, "Player not found" end
	if target == player then return false, "Cannot add yourself" end

	local profile = PlayerData.Get(player)
	if not profile then return false, "No profile" end
	profile.Friends = profile.Friends or {}

	-- Already friends?
	for _, id in ipairs(profile.Friends) do
		if id == target.UserId then return false, "Already friends" end
	end

	-- Cap at 50
	if #profile.Friends >= 50 then return false, "Friend list full" end

	table.insert(profile.Friends, target.UserId)
	return true
end

local function removeFriend(player, friendName)
	local target = Players:FindFirstChild(friendName)
	if not target then
		-- Allow remove by UserId lookup too
		return false, "Player not online"
	end

	local profile = PlayerData.Get(player)
	if not profile or not profile.Friends then return false end

	for i, id in ipairs(profile.Friends) do
		if id == target.UserId then
			table.remove(profile.Friends, i)
			return true
		end
	end
	return false, "Not in friend list"
end

function FriendService.GetFriendList(player)
	local profile = PlayerData.Get(player)
	if not profile then return {} end
	return profile.Friends or {}
end

function FriendService.IsFriend(player, otherUserId)
	local list = FriendService.GetFriendList(player)
	for _, id in ipairs(list) do
		if id == otherUserId then return true end
	end
	return false
end

function FriendService.Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(msg)
			if msg:sub(1, 11) == "/addfriend " then
				local name = msg:sub(12)
				local ok, err = addFriend(player, name)
				player:SetAttribute("FriendMessage", ok and ("Added " .. name) or (err or "Failed"))
			elseif msg:sub(1, 14) == "/removefriend " then
				local name = msg:sub(15)
				local ok, err = removeFriend(player, name)
				player:SetAttribute("FriendMessage", ok and ("Removed " .. name) or (err or "Failed"))
			elseif msg == "/friends" then
				local list = FriendService.GetFriendList(player)
				player:SetAttribute("FriendMessage", "Friends count: " .. #list)
			end
		end)
	end)
end

return FriendService
