local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local signature = "[RBW4 Timings]" -- For easier finding of printed stuff in the dev console

if not getgenv().releasingEnabled then
    getgenv().releasingEnabled = false -- A constant for enabling Auto-Release
end

local Timings = {
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

tab_Main:Button{
	Name = "Save Timings",
	Description = "Save input timings as a .txt file which can be found in your exploit's workspace folder",
	Callback = function()
        if writefile then
            local currentPing = math.round(Stats.PerformanceStats.Ping:GetValue())
            local currentDate = os.date("%Y.%m.%d")
            local currentTime = os.date("%H.%M.%S")

            local fileName = "RBW4 Timings l "..currentPing.." ping ("..currentDate.." l "..currentTime..").txt"
            writefile(fileName, "")

            for shotType, timing in next, Timings do
                appendfile(fileName, shotType.." : "..timing.."\n")
            end

            GUI:Notification{
            	Title = "Save Timings",
            	Text = "File saved successfully.",
            	Duration = 2
            }
        else
            GUI:Notification{
            	Title = "Save Timings",
            	Text = "Exploit doesn't support writefile(), stopping...",
            	Duration = 2
            }
        end
	end
}

tab_Main:Button{
	Name = "Rejoin",
	Description = nil,
	Callback = function()
        LocalPlayer:Kick("\nRejoining, one second...")
		task.wait()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
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
                Title = "Auto-Release",
                Text = "ShotType is nil, returning...",
                Duration = 2
            }
            return
        end
    end

    if releasingEnabled and Timings[shotType] then
        while not LocalPlayer.Character:GetAttribute("ShotMeter") or LocalPlayer.Character:GetAttribute("ShotMeter") <= Timings[shotType] do
            task.wait()
        end

        ReplicatedStorage.GameEvents.ClientAction:FireServer("Shoot", false)
    else
        GUI:Notification{
            Title = "Auto-Release",
            Text = "ShotType not found in table",
            Duration = 2
        }
    end
end

local function onCharacterAdded()
    LocalPlayer.Character:GetAttributeChangedSignal("ShotType"):Connect(function()
        local shotType = LocalPlayer.Character:GetAttribute("ShotType")

        if shotType ~= nil then
            AutoRelease(shotType)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded()
end

print("Loaded")
