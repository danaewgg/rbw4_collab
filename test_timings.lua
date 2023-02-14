local Stats = game:GetService("Stats")
local NetworkSettings = settings():GetService("NetworkSettings") -- I hope all exploits support this..
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local signature = "[RBW4 Timings]" -- For easier finding of stuff printed in the dev console

if not getgenv().releasingEnabled then
    getgenv().releasingEnabled = false -- A constant for enabling Auto-Release
end

if not getgenv().botEnabled then
    getgenv().botEnabled = false -- A constant for enabling the AI
end

if not (getgenv().boostFPS or getgenv().parts) then
    getgenv().boostFPS = false -- A constant for enabling the FPS boost toggle
    getgenv().parts = {}
end

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

tab_Main:TextBox{
	Name = "Backtrack",
    Description = " [Max: 0.5] Stimulates lag, therefore increasing your ping",
	Callback = function(value)
	    value = tonumber(value)

	    if value <= 0.5 then
            NetworkSettings.IncomingReplicationLag = value
        else
            Notify("[ERROR] Backtrack Cancelled", "Value too high, the max is 0.5")
        end
    end
}

tab_Main:Toggle{
	Name = "FPS Boost",
	StartingState = getgenv().boostFPS,
	Description = "Increase performance by hiding unnecessary",
	Callback = function(state)
	    if state ~= false then
	        getgenv().boostFPS = state
	        
            for _, child in next, workspace:GetChildren() do
                if child.Name:find("Ball Racks") then
                    getgenv().parts[child] = child.Parent
                    child.Parent = nil
                end
                
                if child.Name:find("_Hoop") then
                    for _, descendant in next, child:GetDescendants() do
			            -- I'll change this later, I know it's bad lol
                        if descendant.Name:find("TimerDisplay") or descendant.Name:find("Slide") or descendant.Name:find("Timer Displays") or descendant.Name:find("Timer Displays") or descendant.Name:find("Net") or descendant.Name:find("Pole") then
                            getgenv().parts[descendant] = descendant.Parent
                            descendant.Parent = nil
                        end
                    end
                end
            end
            
            for _, child in next, workspace.Gym.Building:GetChildren() do -- Prone to error if the place isn't the gym
                if not child.Name:find("Light") then
                    getgenv().parts[child] = child.Parent
                    child.Parent = nil
                end
            end
            
            for _, child in next, Lighting:GetChildren() do
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
	    if isfile and readfile then
    	    if isfile("RBW4 Timings/TimingsToLoad.txt") then
                local data = {}

                for _, split in next, readfile("RBW4 Timings/TimingsToLoad.txt"):split("\n") do
                    split = string.split(split, ":")

                    if split[1] and split[2] then
                        data[trim(split[1])] = tonumber(trim(split[2]))
                    end
                end

                getgenv().Timings = data

                Notify("Imported Timings", "Timings loaded successfully")
            else
                Notify("[ERROR] Import Timings Cancelled", "Timings file not found")
    	    end
        elseif not isfile then
            Notify("[ERROR] Import Timings Cancelled", "Your exploit does not support isfile()")
        elseif not readfile then
            Notify("[ERROR] Import Timings Cancelled", "Your exploit does not support readfile()")
	    end
    end
}

tab_Main:Button{
	Name = "Export Timings",
	Description = "Save input timings to the 'workspace/RBW4 Timings' folder",
	Callback = function()
        if writefile then
            local folderName = "RBW4 Timings"

            local currentPing = math.round(Stats.PerformanceStats.Ping:GetValue())
            local currentDate = os.date("%d.%m.%Y")
            local currentTime = os.date("%H.%Mh")

            local fileName = currentPing.." ping ("..currentDate.." at "..currentTime..").txt"
            local fileExtension = ".txt" -- Maybe customizable down the line
            local fullPath = folderName.."/"..fileName..fileExtension
            
            makefolder(folderName)
            writefile(fullPath, "")

            for shotType, timing in next, Timings do
                appendfile(fullPath, shotType.." : "..timing.."\n")
            end
            
            Notify("Exported Timings", "File saved successfully")
        else
            Notify("[ERROR] Export Timings Cancelled", "Your exploit does not support writefile()")
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
    for key, value in next, Timings do
        tab_Timings:Textbox{
            Name = key,
            Callback = function(value)
                Timings[key] = tonumber(value)
            end
        }
    end
end)

function trim(string)
    return string:match("^%s*(.-)%s*$") or ""
end

function print(input)
    if typeof(input) ~= "table" then
        return getrenv().print(signature, input)
    else 
        return getrenv().print(signature, unpack(input))
    end
end

function warn(input)
    if typeof(input) ~= "table" then
        return getrenv().warn(signature, input)
    else 
        return getrenv().warn(signature, unpack(input))
    end
end

function Notify(heading, description, duration)
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
    
    Notify("Shot Results", string.format("ShotType: %s \nLandedShotMeter: %.2f \nPing: %s", shotType, landedShotMeter, currentPing))
end

local function AutoRelease(shotType)
	if not shotType then
		shotType = LocalPlayer.Character:GetAttribute("ShotType")

		if shotType == nil then
		    Notify("[ERROR] Auto-Release Cancelled", "ShotType is nil")
			return
		end
	end

	if releasingEnabled then
		if Timings[shotType] then -- Hopefully I do a standing shot and streak/quick shot check soon
			local startTime = tick()
			local releaseTime = Timings[shotType]
			
			local function Shoot()
			    if (tick() - startTime) >= releaseTime then
					ReplicatedStorage.GameEvents.ClientAction:FireServer("Shoot", false)
					-- warn(string.format("Time taken: %s", tostring(tick() - startTime)))
					RunService:UnbindFromRenderStep("Auto-Release")
				end
			end
			
			RunService:BindToRenderStep("Auto-Release", 1, Shoot)
		else
		    Notify("[ERROR] Auto-Release Cancelled", "ShotType not found in table")
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
    LocalPlayer.Character:GetAttributeChangedSignal("ShootInput"):Connect(function()
        local shootInput = LocalPlayer.Character:GetAttribute("ShootInput")
        local shooting = LocalPlayer.Character:GetAttribute("Shooting")

        if not shootInput and shooting ~= false then
            LocalPlayer.Character:GetAttributeChangedSignal("LandedShotMeter"):Wait()
            DisplayShotResults()
        end
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
