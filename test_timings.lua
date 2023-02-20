local Stats = game:GetService("Stats")
local NetworkSettings = settings():GetService("NetworkSettings") -- I hope all exploits support this..
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Terrain = game:GetService("Terrain")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local signature = "[RBW4 Timings]" -- For easier finding of stuff printed in the dev console

if not getgenv().backtrackValue then
    getgenv().backtrackValue = 0
end

if not getgenv().releasingEnabled then
    getgenv().releasingEnabled = false
end

if not getgenv().botEnabled then
    getgenv().botEnabled = false
end

if not (getgenv().boostFPS or getgenv().parts) then
    getgenv().boostFPS = false
    getgenv().parts = {}
end

local quickShotTimings = {
    [1] = 0.3, -- Bronze
    [2] = 0.6, -- Silver 
    [3] = 0.7, -- Gold
    [4] = 0.9, -- Diamond
}

local TextBoxes = {} -- For referencing timings later on (:Set)

getgenv().Timings = { -- 35 shot types in total
    ["Standing Shot"] 			 = 0,
    ["Off Dribble Shot"] 		 = 0,
    ["Drift Shot"] 				 = 0,
    ["Far Shot"] 				 = 0,
    Freethrow 				     = 0,
    ["Hopstep Off Dribble Shot"] = 0,
    ["Hopstep Drift Shot"] 		 = 0,
    Layup 				 	     = 0,
    ["Reverse Layup"] 			 = 0,
    ["Hopstep Layup"] 			 = 0,
    ["Eurostep Layup"] 			 = 0,
    ["Dropstep Layup"] 			 = 0,
    ["Post Layup"] 			  	 = 0,
    Floater    				     = 0,
    ["Hopstep Floater"] 		 = 0,
    ["Eurostep Floater"] 		 = 0,
    ["Close Shot"] 				 = 0,
    ["Hopstep Close Shot"] 		 = 0,
    ["Dropstep Close Shot"] 	 = 0,
    ["Post Close Shot"] 		 = 0,
    ["AlleyOop Close Shot"] 	 = 0,
    ["Standing Dunk"] 		 	 = 0,
    ["Hopstep Standing Dunk"] 	 = 0,
    ["Dropstep Standing Dunk"]   = 0,
    ["Post Standing Dunk"] 		 = 0,
    ["Driving Dunk"] 			 = 0,
    ["AlleyOop Standing Dunk"] 	 = 0,
    ["AlleyOop Driving Dunk"] 	 = 0,
    ["Post Fade"] 				 = 0,
    ["Drift Post Fade"] 		 = 0,
    ["Hopstep Post Fade"] 		 = 0,
    ["Dropstep Post Fade"] 		 = 0,
    ["Post Hook"] 				 = 0,
    ["Hopstep Post Hook"] 		 = 0,
    ["Dropstep Post Hook"] 		 = 0
}

local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local GUI = Mercury:Create{
    Name = "Home",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "test_timings.lua"
}

local tab_Main = GUI:Tab{
	Name = "Main",
	Icon = "rbxassetid://6034996695"
}

tab_Main:Toggle{
	Name = "Releasing Enabled",
	StartingState = getgenv().releasingEnabled,
	Description = "Automatically stop shooting when the shot timing's threshold has been reached",
	Callback = function(state)
	    getgenv().releasingEnabled = state
    end
}

tab_Main:Toggle{
	Name = "AI",
	StartingState = getgenv().botEnabled,
	Description = "[Work in progress] Get a bot to do the testing for you",
	Callback = function(state)
	    getgenv().botEnabled = state
    end
}

local textBox_Backtrack
textBox_Backtrack = tab_Main:TextBox{
	Name = "Backtrack",
	Placeholder = getgenv().backtrackValue,
    Description = " [Max: 0.5] Stimulates lag, therefore increasing your ping",
	Callback = function(value)
	    if tonumber(value) <= 0.5 then
	        getgenv().backtrackValue = value
            NetworkSettings.IncomingReplicationLag = value
        else
            textBox_Backtrack:Set(0)
            notify("[ERROR] Backtrack Cancelled", "Value too high, the max is 0.5")
        end
    end
}

tab_Main:Toggle{
	Name = "FPS Boost",
	StartingState = getgenv().boostFPS,
	Description = "Increase performance by hiding unnecessary parts",
	Callback = function(state)
	    if state ~= false then
	        getgenv().boostFPS = state
	        
	        -- I'll change this later, I know it's bad lol
            for _, child in next, workspace:GetChildren() do
                if child.Name:find("Ball Racks") or child.Name:find("NameUIFolder") or child.Name:find("SpawnLocation") then
                    getgenv().parts[child] = child.Parent
                    child.Parent = nil
                end
                
                if child.Name:find("_Hoop") then
                    for _, hoopDescendant in next, child:GetDescendants() do
                        if hoopDescendant.Name:find("TimerDisplay") or hoopDescendant.Name:find("Slide") or hoopDescendant.Name:find("Timer Displays") or hoopDescendant.Name:find("Timer Displays") or hoopDescendant.Name:find("Net") or hoopDescendant.Name:find("Pole") or hoopDescendant.Name:find("Box") then
                            getgenv().parts[hoopDescendant] = hoopDescendant.Parent
                            hoopDescendant.Parent = nil
                        end
                    end
                end
                
                if child.Name:find("Court") then
                    for _, courtDescendant in next, child:GetChildren() do
                        if courtDescendant.Name:find("Baseline") then
                            getgenv().parts[courtDescendant] = courtDescendant.Parent
                            courtDescendant.Parent = nil
                        end
                    end
                end
            end
            
            for _, child in next, workspace.Gym:GetChildren() do -- Prone to error if the place isn't the gym
                if not child.Name:find("Building") then
                    getgenv().parts[child] = child.Parent
                    child.Parent = nil
                else -- child.Name is Building
                    for _, buildingDescendant in next, child:GetChildren() do
                        if not buildingDescendant.Name:find("Light") then
                            getgenv().parts[buildingDescendant] = buildingDescendant.Parent
                            buildingDescendant.Parent = nil
                        end  
                    end
                end
            end
            
            for _, child in next, Terrain:GetChildren() do
                getgenv().parts[child] = child.Parent
                child.Parent = nil
            end
	    else
	        getgenv().boostFPS = state
	        
	        for part, parent in next, getgenv().parts do
	            part.Parent = parent
	            getgenv().parts[part] = nil
	        end
	    end
    end
}

tab_Main:Button{
	Name = "Import Timings",
	Description = "Allows you to load timings from 'workspace/RBW4 Timings/TimingsToLoad.txt' ",
	Callback = function()
        prompt("Import Timings", "Would you like to load in the saved timings?", {
        	yes = function()
        		if isfile and readfile then
        			if isfile("RBW4 Timings/TimingsToLoad.txt") then -- I should make this a textbox so the user can input the exact file to load
        				local data = {}
        				for _, split in next, readfile("RBW4 Timings/TimingsToLoad.txt"):split("\n") do
        					split = string.split(split, ":")
        					if split[1] and split[2] then
        						data[trim(split[1])] = tonumber(trim(split[2]))
        						TextBoxes[trim(split[1])]:Set(trim(split[2])) -- Set the timing textbox to the loaded value
        					end
        				end
        				getgenv().Timings = data
        				notify("Imported Timings", "Timings loaded successfully")
        			else
        				notify("[ERROR] Import Timings Cancelled", "Timings file not found")
        			end
        		elseif not isfile then
        			notify("[ERROR] Import Timings Cancelled", "Your exploit does not support isfile()")
        		elseif not readfile then
        			notify("[ERROR] Import Timings Cancelled", "Your exploit does not support readfile()")
        		end
        	end,
        	no = function()
        		return false
        	end
        })
    end
}

tab_Main:Button{
	Name = "Export Timings",
	Description = "Save input timings to the 'workspace/RBW4 Timings' folder",
	Callback = function()
        if writefile then
            -- Maybe customizable down the line
            local folderName = "RBW4 Timings"

            local currentPing = math.round(Stats.PerformanceStats.Ping:GetValue())
            local currentDate = os.date("%d.%m.%Y")
            local currentTime = os.date("%H.%Mh")

            local fileName = string.format("%s ping (%s at %s)", currentPing, currentDate, currentTime)
            local fileExtension = ".txt"
            local fullPath = folderName.."/"..fileName..fileExtension
            
            makefolder(folderName)
            writefile(fullPath, "")

            for shotType, timing in next, Timings do
                appendfile(fullPath, shotType.." : "..timing.."\n")
            end
            
            notify("Exported Timings", "File saved successfully")
        else
            notify("[ERROR] Export Timings Cancelled", "Your exploit does not support writefile()")
        end
	end
}

tab_Main:Button{
	Name = "Rejoin",
	Description = nil,
	Callback = function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining, one second...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
	end
}

local tab_Timings = GUI:Tab{
	Name = "Timings",
	Icon = "rbxassetid://6034996695"
}

task.defer(function()
    local array = {}
    for index, value in next, Timings do
        array[#array + 1] = {index, value}
    end

    table.sort(array, function(tableA, tableB)
        return tableA[1] < tableB[1]
    end)
    
    for index, value in next, array do
        TextBoxes[value[1]] = tab_Timings:Textbox{
            Name = value[1],
            Callback = function(number)
                Timings[value[1]] = tonumber(number)
            end
        }
    end
end)

function trim(string)
    return string:match("^%s*(.-)%s*$") or ""
end

function print(...)
    return getgenv().print(signature, ...)
end

function warn(...)
    return getgenv().warn(signature, ...)
end

function prompt(title, text, buttons)
    GUI:Prompt{
        Followup = false, -- idk what this is tbh
        Title = title or "Prompt",
        Text = text or "",
        Buttons = buttons or {
            hi = function()
                print("You ")
            end,
            no = function()
                result = false
            end
        }
    }
end

function notify(heading, description, duration)
    GUI:Notification{
    	Title = heading or "",
    	Text = description or "",
    	Duration = duration or 3
    }
end

local function DisplayShotResults()
    local shotType = LocalPlayer.Character:GetAttribute("ShotType")
    local landedShotMeter = LocalPlayer.Character:GetAttribute("LandedShotMeter")
    local currentPing = math.round(Stats.PerformanceStats.Ping:GetValue())
    
    notify("Shot Results", string.format("ShotType: %s \nLandedShotMeter: %.2f \nPing: %s", shotType, landedShotMeter, currentPing))
end

local function AutoRelease(shotType)
	if not shotType then
		shotType = LocalPlayer.Character:GetAttribute("ShotType")

		if shotType == nil then
		    notify("[ERROR] Auto-Release Cancelled", "ShotType is nil")
			return
		end
	end

	if releasingEnabled then
		if Timings[shotType] then
			local startTime = tick()
			local releaseTime = Timings[shotType]
			
			local function Shoot()
			    if (tick() - startTime) >= releaseTime then
					ReplicatedStorage.GameEvents.ClientAction:FireServer("Shoot", false)
					warn(string.format("Time taken: %.3f", tick() - startTime))
					RunService:UnbindFromRenderStep("Auto-Release")
				end
			end
			
			-- This needs testing
			if LocalPlayer.Character:GetAttribute("Streak") then
			    if shotType == "Standing Shot" or shotType == "Off Dribble Shot" or shotType == "Hopstep Off Dribble Shot" then
			        if LocalPlayer.Character:GetAttribute("StreakMeter") > 0 and LocalPlayer.Character:GetAttribute("StreakType") == "Spot-Up Shooter" then
			            releaseTime = releaseTime - 0.03 -- Spot-Up timing
			        elseif LocalPlayer.Character:GetAttribute("StreakMeter") < 0 then
			            releaseTime = releaseTime + 0.03 -- Cold timing
			        end
			    end
			end
			
			-- This needs testing
			-- if LocalPlayer.PlayerGui.GameUI.Main.Boosts:FindFirstChild("Quick Shot") then
			--     if LocalPlayer.PlayerGui.GameUI.Main.Boosts["Quick Shot"]:GetAttribute("Activated") then
			--         local quickShotTier = LocalPlayer.Character.Boosts["Quick Shot"].Value
			--         releaseTime = releaseTime - quickShotTimings[quickShotTier]
			--     end
		    -- end
 			
			RunService:BindToRenderStep("Auto-Release", 1, Shoot)
		else
		    notify("[ERROR] Auto-Release Cancelled", "ShotType not found in table")
		end
	end
end

local function onOverrideMouseIconBehavior()
    UserInputService.OverrideMouseIconBehavior = 1 -- ForceShow
end

local function onIdled() -- Anti-Idle
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end

local function onCharacterAdded()
    LocalPlayer.Character:GetAttributeChangedSignal("LandedShotMeter"):Connect(function()
        DisplayShotResults()
    end)
    
    LocalPlayer.Character:GetAttributeChangedSignal("ShotType"):Connect(function()
        local shotType = LocalPlayer.Character:GetAttribute("ShotType")

        if shotType ~= nil then
            AutoRelease(shotType)
        end
    end)
end

UserInputService:GetPropertyChangedSignal("OverrideMouseIconBehavior"):Connect(onOverrideMouseIconBehavior)
LocalPlayer.Idled:Connect(onIdled)
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded()
end

print("Loaded")
