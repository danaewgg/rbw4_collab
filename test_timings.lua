local Stats = game:GetService("Stats")
local NetworkSettings = settings():GetService("NetworkSettings") -- I hope all exploits support this..
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local signature = "[RBW4 Timings]" -- For easier finding of stuff printed in the dev console

if not getgenv().releasingEnabled then
    getgenv().releasingEnabled = false -- A constant for enabling Auto-Release
end

getgenv().Timings = { -- 35 shots in total
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
	Icon = "rbxassetid://8569322835"
}

tab_Main:Toggle{
	Name = "Releasing Enabled",
	StartingState = getgenv().releasingEnabled,
	Description = "Auto-Release when the ShotMeter attribute has reached the shot timing's threshold",
	Callback = function(state)
	    getgenv().releasingEnabled = state
    end
}

tab_Main:TextBox{
	Name = "Backtrack [Max: 0.5]",
    Description = "Stimulates lag, therefore increasing your ping",
	Callback = function(value)
	    value = tonumber(value)

	    if value <= 0.5 then
            NetworkSettings.IncomingReplicationLag = value
        else
            GUI:Notification{
                Title = "[ERROR] Backtrack Cancelled",
                Text = "Value too high, the max is 0.5",
                Duration = 3
            }
        end
    end
}

tab_Main:Button{
	Name = "Load Timings",
	Description = "Allows you to load timings from 'workspace/TimingsToLoad.txt' ",
	Callback = function()
	    if isfile and readfile then
    	    if isfile("RBW4 Timings/TimingsToLoad.txt") then
                local data = {}
                
                for index, split in next, readfile("RBW4 Timings/TimingsToLoad.txt"):split("\n") do
                    split = string.split(split, ":")
                    
                    if split[1] and split[2] then
                        data[trim(split[1])] = tonumber(trim(split[2]))
                    end
                end
                
                getgenv().Timings = data
                
                GUI:Notification{
                	Title = "Load Timings",
                	Text = "Timings loaded successfully",
                	Duration = 3
                }
            else
                GUI:Notification{
                	Title = "[ERROR] Load Timings Cancelled",
                	Text = "Timings file not found",
                	Duration = 3
                }
    	    end
        else
        GUI:Notification{
        	Title = "[ERROR] Load Timings Cancelled",
        	Text = "Your exploit does not support isfile() and readfile()",
        	Duration = 3
        }
	    end
    end
}

tab_Main:Button{
	Name = "Save Timings",
	Description = "Save input timings to the 'workspace/RBW4 Timings' folder",
	Callback = function()
        if writefile then
            local folderName = "RBW4 Timings"
            
            local currentPing = math.round(Stats.PerformanceStats.Ping:GetValue())
            local currentDate = os.date("%Y.%m.%d")
            local currentTime = os.date("%H.%M.%S")
            
            local fileName = currentPing.." ping (at "..currentDate.." l "..currentTime.."h).txt"
            local fullPath = folderName.."/"..fileName

            makefolder(folderName)
            writefile(fullPath, "")

            for shotType, timing in next, Timings do
                appendfile(fullPath, shotType.." : "..timing.."\n")
            end

            GUI:Notification{
            	Title = "Save Timings",
            	Text = "File saved successfully",
            	Duration = 3
            }
        else
            GUI:Notification{
            	Title = "[ERROR] Save Timings Cancelled",
            	Text = "Your exploit does not support writefile()",
            	Duration = 3
            }
        end
	end
}

tab_Main:Button{
	Name = "Rejoin",
	Description = nil,
	Callback = function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining, one second...")
            task.wait()
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
    getrenv().print(signature, input)
end

function warn(input)
    getrenv().warn(signature, input)
end

local function AutoRelease(shotType)
    if not shotType then
        shotType = LocalPlayer.Character:GetAttribute("ShotType")

        if shotType == nil then
            GUI:Notification{
                Title = "[ERROR] Auto-Release Cancelled",
                Text = "ShotType is nil",
                Duration = 3
            }
            return
        end
    end

    if releasingEnabled then
        if Timings[shotType] then
            while not LocalPlayer.Character:GetAttribute("ShotMeter") or LocalPlayer.Character:GetAttribute("ShotMeter") <= Timings[shotType] do
                task.wait()
            end

            ReplicatedStorage.GameEvents.ClientAction:FireServer("Shoot", false)
        else
            GUI:Notification{
                Title = "[ERROR] Auto-Release Cancelled",
                Text = "ShotType not found in table",
                Duration = 3
            }
        end
    end
end

local function onIdled()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end

local function onCharacterAdded()
    LocalPlayer.Character:GetAttributeChangedSignal("ShotType"):Connect(function()
        local shotType = LocalPlayer.Character:GetAttribute("ShotType")

        if shotType ~= nil then
            AutoRelease(shotType)
        end
    end)
end

LocalPlayer.Idled:Connect(onIdled)
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded()
end

print("Loaded")
