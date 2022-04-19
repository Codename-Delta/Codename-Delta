-- set to false if you dont want tips
-- put this first and then script / loadstring
getgenv().tips = true

local Prefix = ":"
local BotVersion = "Codename Delta - v0.2.2-dev1"
local Blacklist = {}
local Players = {}
local LPlr = game:GetService("Players").LocalPlayer
local mode = 2

function LChat(msg) --local chat
	game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {Text = "[Codename Delta]: "..msg;Color = Color3.fromRGB(77, 166, 255)})	
end
function Chat(msg)
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg,"All")
end

local function GetTip(tip)
	if tip == 1 then
		Chat("TIP: Use "..Prefix.."help to view the list of commands.")
	elseif tip == 2 then
		Chat("TIP: Use "..Prefix.."goto (plr) to see what the advanced pathfinding can do!")
	elseif tip == 3 then
		Chat("TIP: The "..Prefix.."jump command can make the bot double jump if said while jumping!")
	elseif tip == 4 then
		Chat("TIP: The "..Prefix.."say command can do lots of spaces at once, try doing '"..Prefix.."say te     st'.")
	elseif tip == 5 then
		Chat("TIP: Codename Delta is available on GitHub, do "..Prefix.."source for more info!")
	elseif tip == 6 then
		Chat("TIP: "..Prefix.."pages will show how many pages are in help, and you can use them by doing "..Prefix.."help (page).")
	elseif tip == 7 then
		Chat("TIP: When bot has been tripped using "..Prefix.."trip, you can do "..Prefix.."jump to untrip it.")
	elseif tip == 8 then
		Chat("TIP: When you use "..Prefix.."prefix, it changes the prefix of the command!")
	elseif tip == 9 then
		Chat("TIP: You can help test the bot by doing "..Prefix.."help testing, it has commands to test the bot's features!")
	elseif tip == 69420 then --funny easter egg
		Chat("TIP: stop acting sussy")
	else
		Chat("ERROR: Tip does not exist.")
	end
end

function IsBot(plr)
    if plr.Name == LPlr.Name or plr.Name == "CodenameDelta" then
        return true
    else
        Chat("ERROR: This is a bot only command.")
        return false
    end
end

-- holy shit this function is so big
-- please clean this up later 
-- the if statements just make my eyes bleed
local function Chatted(msg,plr)
	if string.sub(msg,1,1) == Prefix and mode > 0 and not table.find(Blacklist,plr.Name) then
		if string.lower(string.sub(msg,2,5)) == "help" then
			-- to add more pages add extra 'elseif string.sub(msg, 7, #msg) == "page number/name here"' and it should work
			if string.sub(msg, 7, #msg) == "1"  or string.sub(msg, 6, #msg) == "" then
				Chat("Prefix: "..Prefix.."  Page: 1  Commands: help (page), about, source, version, pages, jump, trip, prefix (new), say (text), goto (plr)")
			elseif string.sub(msg, 7, #msg) == "2" then
				Chat("Prefix: "..Prefix.."  Page: 2  Commands: bringbot")
			elseif string.sub(msg, 7, #msg) == "bot-only" then
				Chat("Prefix: "..Prefix.."  Page: bot-only  Commands: stop, blacklist (plr), unblacklist (plr), reset, invincible")
			elseif string.sub(msg, 7, #msg) == "testing" then
				Chat("Prefix: "..Prefix.."  Page: testing  Commands: tip (num)")
			else
				Chat("ERROR: Page not found.")
			end
		elseif string.lower(string.sub(msg,2,8)) == "version" then
			Chat("Version: "..BotVersion)
		elseif string.lower(string.sub(msg,2,7)) == "source" then
			Chat("The source is available on GitHub, just search Codename-Delta on it and click on the lua repository!")
		elseif string.lower(string.sub(msg,2,7)) == "pages" then
			Chat("Pages: 1-2. Special Pages: bot-only, testing. How to use: Do "..Prefix.."help (page)")
		elseif string.lower(string.sub(msg,2,6)) == "about" then
			Chat("Codename Delta is a advanced bot that can respond at instantaneous speeds (if ping isn't very high) and do complex pathfinding calculations!")
		elseif string.lower(string.sub(msg,2,5)) == "jump" then
			local oldjumppower = LPlr.Character.Humanoid.JumpPower * 0.5 * 2 --save old jump power
			if oldjumppower < 50 then
				LPlr.Character.Humanoid.JumpPower = 50
			end
			LPlr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			task.wait()
			LPlr.Character.Humanoid.JumpPower = oldjumppower
		elseif string.lower(string.sub(msg,2,7)) == "prefix" then
			if string.len(string.lower(string.sub(msg,9,#msg))) > 1 then
				Chat("ERROR: Invalid prefix, prefix remains as "..Prefix)
			elseif string.lower(string.sub(msg,9,9)) == "" then
				Chat("ERROR: No prefix specified, prefix remains as "..Prefix)
			else
				Prefix = string.lower(string.sub(msg,9,9))
				Chat("Prefix successfully changed to "..Prefix)
			end
            if plr.Name == LPlr.Name then
                LChat("Trying to change your bot prefix, but it also changes another bot in the server? Do '!!prefix' if so.")
            end
		elseif string.lower(string.sub(msg,2,4)) == "say" then
			Chat(string.sub(msg,6,#msg).." - Said by "..plr.Name)
		elseif string.lower(string.sub(msg,2,5)) == "trip" then
			LPlr.Character.Humanoid.Sit = true
		elseif string.lower(string.sub(msg,2,5)) == "goto" then
			if string.sub(msg,7,#msg) == LPlr.Name then
				Chat("ERROR: Going to bot is forbidden")
			elseif game.Players:FindFirstChild(string.sub(msg,7,#msg)) then
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
			if IsBot(plr) then
				Chat("Bot has been turned off.")
                LChat("Hope you enjoyed using this bot!")
				mode = 0
			end
		elseif string.lower(string.sub(msg,2,10)) == "blacklist" then
			if IsBot(plr) then
				local blacklisting = string.split(msg," ")[2]
				if game.Players:FindFirstChild(blacklisting) then
					table.insert(Blacklist,blacklisting)
					Chat(blacklisting.." is now blacklisted.")
				else
					Chat("ERROR: Player does not exist")
				end
			end
		elseif string.lower(string.sub(msg,2,12)) == "unblacklist" then
			if IsBot(plr) then
				local blacklisting = string.split(msg," ")[2]
				if table.find(Blacklist,blacklisting) then
					table.remove(Blacklist,table.find(Blacklist,blacklisting))
					Chat(blacklisting.." is no longer blacklisted.")
                elseif blacklisting == "all" then
					table.clear(Blacklist)
					Chat("Blacklist has been reset")
                else
					Chat("ERROR: Player is not blacklisted")
				end
			end
		elseif string.lower(string.sub(msg,2,6)) == "reset" then
			if IsBot(plr) then
				LPlr.Character.Humanoid.Health = 0
                pcall(function()LPlr.Character:BreakJoints()end)
			end
		elseif string.lower(string.sub(msg,2,11)) == "invincible" then
			if IsBot(plr) then --NOTE: you cannot be damaged unless you have bad network ownership (credits to Alpha-404 for script)
				loadsting(game:HttpGet("https://raw.githubusercontent.com/Alpha-404/NC-REANIM-V2/main/V2.5.lua"))() 
			end
        elseif string.lower(string.sub(msg,2,5)) == "lock" then
            if IsBot(plr) then
                if mode == 2 then
                    mode = 1
                    Chat("Commands are now locked to bot user.")
                elseif mode == 1 then
                    mode = 2
                    Chat("Commands have been unlocked.")
                end
            end
		elseif string.lower(string.sub(msg,2,4)) == "tip" then
			GetTip(tonumber(string.sub(msg,6,#msg)))
		elseif string.lower(string.sub(msg,2,9)) == "bringbot" then
			LPlr.Character:SetPrimaryPartCFrame(plr.Character.HumanoidRootPart.CFrame)
		end
    	elseif string.lower(string.sub(msg,1,8)) == "!!prefix" then
        	if IsBot(plr) then
                if string.len(string.lower(string.sub(msg,10,#msg))) > 1 then
				    Chat("ERROR: Invalid prefix, prefix remains as "..Prefix)
			    elseif string.lower(string.sub(msg,10,10)) == "" then
				    Chat("ERROR: Prefix not specified, prefix remains as "..Prefix)
			    else
				    Prefix = string.lower(string.sub(msg,10,10))
				    Chat("Prefix successfully changed to "..Prefix)
                end
			end
        end
	end	
end
local function Tips()
	while mode > 0 and getgenv().tips do
		wait(math.random(55,115))
		local tip = math.random(1,9)
		if mode == 2 then GetTip(tip) end
	end
end

LChat("Thank you for executing Codename Delta, the bot will start soon.")
task.wait(3)

LPlr.Character.Humanoid.Health = 0
pcall(function()LPlr.Character:BreakJoints()end)
Chat("Welcome to "..BotVersion.."! Type "..Prefix.."help for a list of basic commands.")
coroutine.wrap(Tips)

while true do
	for _, player in pairs(game.Players:GetChildren()) do
		if not table.find(Blacklist,player.Name) and not table.find(Players,player.Name) then
			table.insert(Players,player.Name)
			player.Chatted:Connect(function(msg)
				if mode == 2 or (mode == 1 and player.Name == LPlr.Name) then Chatted(msg,player) end
			end)
      game.Players.ChildRemoved:Connect(function(plr)
        if plr.Name == player.Name then table.remove(Players,table.find(Players,plr.Name)) end
      end)
		end
	end
	task.wait()
end
