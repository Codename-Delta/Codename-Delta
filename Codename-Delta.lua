-- set to false if you dont want tips
-- put this first and then script / loadstring
getgenv().tips = true

local Prefix = ":"
local BotVersion = "Codename Delta - v0.2.0-dev4"
local Blacklist = {}
local Players = {}
local LPlr = game:GetService("Players").LocalPlayer

function Chat(msg)
	game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg,"All")
end
local on = true

local function GetTip(tip)
	if tip == 1 then
		Chat("TIP: Use "..Prefix.."help to view the list of commands.")
	elseif tip == 2 then
		Chat("TIP: Use "..Prefix.."goto (plr) to see the advanced pathfinding this bot has!")
	elseif tip == 3 then
		Chat("TIP: The "..Prefix.."jump command can sometimes make the bot double jump if inputted correctly!")
	elseif tip == 4 then
		Chat("TIP: The "..Prefix.."say command can do lots of spaces at once, try doing '"..Prefix.."say te     st'")
	elseif tip == 5 then
		Chat("TIP: Codename-Delta will get updated lots on GitHub, do "..Prefix.."source for more info!")
	elseif tip == 6 then
		Chat("TIP: "..Prefix.."pages will show how many pages are in help, and you can use them by doing "..Prefix.."help (page)")
	elseif tip == 7 then
		Chat("TIP: When bot has been tripped using "..Prefix.."trip, you can do "..Prefix.."jump to get it back up.")
	else
		Chat("ERROR: Tip does not exist.")
	end
end

local function Chatted(msg,plr)
	if string.sub(msg,1,1) == Prefix and on == true and not table.find(Blacklist,plr.Name) then
		if string.lower(string.sub(msg,2,5)) == "help" then
			-- to add more pages add extra elseifs
			-- string.sub(msg, 7, #msg) == "page number here" should work
			if string.sub(msg, 7, #msg) == "1"  or string.sub(msg, 6, #msg) == "" then
				Chat("Prefix: "..Prefix.."  Page: 1  Commands: help (page), about, source, version, pages, jump, trip, prefix (new), say (text), goto (plr)")
			elseif string.sub(msg, 7, #msg) == "bot-only" then
				Chat("Prefix: "..Prefix.."  Page: bot-only  Commands: stop, blacklist (plr), unblacklist (plr)")
			elseif string.sub(msg, 7, #msg) == "testing" then
				Chat("Prefix: "..Prefix.."  Page: testing  Commands: tip (num), bringbot")
			else
				Chat("ERROR: Page not found.")
			end
		elseif string.lower(string.sub(msg,2,8)) == "version" then
			Chat("Version: "..BotVersion)
		elseif string.lower(string.sub(msg,2,7)) == "source" then
			Chat("The source is available on GitHub, just search Codename-Delta on it to find the bot!")
		elseif string.lower(string.sub(msg,2,7)) == "pages" then
			Chat("Pages: 1. Special Pages: bot-only, testing")
		elseif string.lower(string.sub(msg,2,6)) == "about" then
			Chat("Codename Delta is a advanced bot that can respond at instantaneous speeds (if ping isn't very high) and do complex pathfinding calculations!")
		elseif string.lower(string.sub(msg,2,5)) == "jump" then
			if LPlr.Character.Humanoid.JumpPower < 50 then
				LPlr.Character.Humanoid.JumpPower = 50
			end
			LPlr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		elseif string.lower(string.sub(msg,2,7)) == "prefix" then
			if string.len(string.lower(string.sub(msg,9,#msg))) > 1 then
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
			LPlr.Character.Humanoid.Sit = true
		elseif string.lower(string.sub(msg,2,5)) == "goto" then
			if game.Players:FindFirstChild(string.sub(msg,7,#msg)) then
				if LPlr.Character.Humanoid.JumpPower < 50 then
					LPlr.Character.Humanoid.JumpPower = 50
				end
				local goto = game.Workspace[string.sub(msg,7,#msg)]
				local head = LPlr.Character.HumanoidRootPart
				local human = LPlr.Character.Humanoid
				local goalPosition = goto.HumanoidRootPart.Position

				local path = game:GetService("PathfindingService"):CreatePath()
				path:ComputeAsync(head.Position, goalPosition)
				local waypoints = path:GetWaypoints()
				local _jump
				if path.Status == Enum.PathStatus.Success then
					local pathfinished = false
					local function Jump()
						if LPlr.Character.Humanoid.FloorMaterial ~= "" and pathfinished == false and LPlr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
							LPlr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
						end
					end
					_jump = LPlr.Character.HumanoidRootPart.Touched:Connect(Jump)
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
				local exit = LPlr.Character.Humanoid.StateChanged:Connect(function(a,b)
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
			if plr.Name == LPlr.Name then
				Chat("Bot has been turned off.")
				on = false
			end
		elseif string.lower(string.sub(msg,2,10)) == "blacklist" then
			if plr.Name == LPlr.Name then
				local blacklisting = string.split(msg," ")[2]
				if game.Players:FindFirstChild(blacklisting) then
					table.insert(Blacklist,blacklisting)
					Chat(blacklisting.." is now blacklisted.")
				else
					Chat("Player does not exist")
				end
			end
		elseif string.lower(string.sub(msg,2,12)) == "unblacklist" then
			if plr.Name == LPlr.Name then
				local blacklisting = string.split(msg," ")[2]
				if table.find(Blacklist,blacklisting) then
					table.remove(Blacklist,blacklisting)
					Chat(blacklisting.." is no longer blacklisted.")
				else
					Chat("Player is not blacklisted")
				end
			end
		elseif string.lower(string.sub(msg,2,4)) == "tip" then
			GetTip(tonumber(string.sub(msg,6,#msg)))
		elseif string.lower(string.sub(msg,2,9)) == "bringbot" then
			if plr.Name ~= LPlr.Name then
				LPlr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
			end
		end	
	end	
end

local function Tips()
	while on == true and getgenv().tips do
		wait(math.random(55,115))
		local tip = math.random(1,7)
		if on == true then
			GetTip(tip)
		end
	end
end

wait(1)
LPlr.Character.Humanoid.Health = 0
Chat("Welcome to "..BotVersion.."! Type "..Prefix.."help for a list of commands.")
spawn(Tips)
while true do
	for _, player in pairs(game.Players:GetChildren()) do
		if not table.find(Blacklist,player.Name) and not table.find(Players,player.Name) then
			table.insert(Players,player.Name)
			player.Chatted:Connect(function(msg)
				if on == true then
					Chatted(msg,player)
				end
			end)
		end
	end
	for _, player in pairs(Players) do
		if not table.find(game.Players:GetChildren(),player) then
			table.remove(Players,player)
		end
	end
	wait(0.1)
end
