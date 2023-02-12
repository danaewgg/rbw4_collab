local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local releasing

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
	StartingState = false,
	Description = "Auto-Release when the ShotMeter attribute has passed the shot timing's threshold",
	Callback = function(state)
	    releasing = state    
    end
}

tab_Main:Button{
	Name = "Save timings",
	Description = "Save input timings as a .txt file which can be found in Synapse's workspace folder",
	Callback = function() 
        local currentDate = os.date("%Y.%m.%d")
        local currentTime = os.date("%H.%M.%S")
        local fileName = "Timings ("..currentDate.." l "..currentTime..").txt"
	    writefile(fileName, "")
	    
	    for key, value in next, Timings do
            appendfile(fileName, key.." : "..value.."\n")
	    end
	end
}

local tab_Timings = GUI:Tab{
	Name = "Timings",
	Icon = "rbxassetid://8569322835"
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

local function AutoRelease(shotType)
    if not shotType then
        shotType = LocalPlayer.Character:GetAttribute("ShotType")
        
        if shotType == nil then
            warn("ShotType is nil")
            return
        end
    end

    if releasing and Timings[shotType] then
        while not LocalPlayer.Character:GetAttribute("ShotMeter") or LocalPlayer.Character:GetAttribute("ShotMeter") <= Timings[shotType] do
            task.wait()
        end

        ReplicatedStorage.GameEvents.ClientAction:FireServer("Shoot", false)
    else
        print("ShotType not found in table")
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
