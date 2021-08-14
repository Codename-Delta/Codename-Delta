local Prefix = ":"
local BotVersion = "Codename Delta - v0.2.0-dev1"
local Blacklist = {}
local Players = {}
function Chat(msg)
	game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg,"All")
end
local on = true

local function Chatted(msg,plr)
	if string.sub(msg,1,1) == Prefix and on == true and not table.find(Blacklist,plr.Name) then
		if string.lower(string.sub(msg,2,5)) == "help" then
			Chat("Prefix: "..Prefix.." Commands: help, about, version, jump, trip, prefix (new), say (text), goto (plr)")
		elseif string.lower(string.sub(msg,2,8)) == "version" then
			Chat("Version: "..BotVersion)
		elseif string.lower(string.sub(msg,2,6)) == "about" then
			Chat("Codename Delta is a advanced bot that can respond at instantaneous speeds (if ping isn't very high) and do complex pathfinding calculations!")
		elseif string.lower(string.sub(msg,2,5)) == "jump" then
			if game.Players.LocalPlayer.Character.Humanoid.JumpPower < 50 then
				game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
			end
			game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		elseif string.lower(string.sub(msg,2,7)) == "prefix" then
			if string.len(string.lower(string.sub(msg,9,#msg))) > 1 or string.lower(string.sub(msg,9,9)) == "!" then
				Chat("ERROR: Invalid Prefix.")
			elseif string.lower(string.sub(msg,9,9)) == "" then
				Chat("Current Prefix: "..Prefix)
			else
				Prefix = string.lower(string.sub(msg,9,9))
				Chat("Prefix changed to "..Prefix)
			end
		elseif string.lower(string.sub(msg,2,4)) == "say" then
			Chat(string.sub(msg,6,#msg).." - Said by "..plr.Name)
		elseif string.lower(string.sub(msg,2,5)) == "trip" then
			game.Players.LocalPlayer.Character.Humanoid.Sit = true
		elseif string.lower(string.sub(msg,2,5)) == "goto" then
			if game.Players:FindFirstChild(string.sub(msg,7,#msg)) then
				if game.Players.LocalPlayer.Character.Humanoid.JumpPower < 50 then
					game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
				end
				local goto = game.Workspace[string.sub(msg,7,#msg)]
				local head = game.Players.LocalPlayer.Character.HumanoidRootPart
				local human = game.Players.LocalPlayer.Character.Humanoid
				local goalPosition = goto.HumanoidRootPart.Position

				local path = game:GetService("PathfindingService"):CreatePath()
				path:ComputeAsync(head.Position, goalPosition)
				local waypoints = path:GetWaypoints()
				local _jump
				if path.Status == Enum.PathStatus.Success then
					local pathfinished = false
					local function Jump()
						if game.Players.LocalPlayer.Character.Humanoid.FloorMaterial ~= "" and pathfinished == false and game.Players.LocalPlayer.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
							game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
						end
					end
					_jump = game.Players.LocalPlayer.Character.HumanoidRootPart.Touched:Connect(Jump)
					for _, waypoint in pairs(waypoints) do
						human:MoveTo(waypoint.Position)
						human.MoveToFinished:Wait()
					end

					pathfinished = true
					_jump:Disconnect()
				else
					Chat("ERROR: Cannot calculate path.")
				end
				local off = false
				local exit = game.Players.LocalPlayer.Character.Humanoid.StateChanged:Connect(function(a,b)
					if a == Enum.HumanoidStateType.Running and b == Enum.HumanoidStateType.None then
						_jump:Disconnect()
						off = true
					end
				end)
				exit:Disconnect()
			else
				Chat("ERROR: Player not found.")
			end
		elseif string.lower(string.sub(msg,2,5)) == "stop" then
			if plr.Name == game.Players.LocalPlayer.Name then
				Chat("Bot has been turned off.")
				on = false
			end
		end
	end
end

local function Tips()
	while on == true do
		wait(math.random(45,75))
		local tip = math.random(1,4)
		if tip == 1 then
			Chat("TIP: Use "..Prefix.."help to view the list of commands.")
		elseif tip == 2 then
			Chat("TIP: Use "..Prefix.."goto (plr) to see the advanced pathfinding this bot has!")
		elseif tip == 3 then
			Chat("TIP: The "..Prefix.."jump command can sometimes make the bot double jump if inputted correctly!")
		elseif tip == 4 then
			Chat("TIP: The "..Prefix.."say command can do lots of spaces at once, try doing '"..Prefix.."say te     st'")
		end
	end
end

wait(1)
Chat("Welcome to "..BotVersion.."! Type "..Prefix.."help for a list of commands.")
spawn(Tips)
while on == true do
	for i, player in pairs(game.Players:GetChildren()) do
		if not table.find(Blacklist,player.Name) and not table.find(Players,player.Name) then
			table.insert(Players,player.Name)
			player.Chatted:Connect(function(msg)
				Chatted(msg,player)
			end)
		end
	end
	wait(1)
end
