local Ping = CreateFrame("Frame")
local Options = {}
local Defaults = {
	channel = "Master",
	whisper = true,
	bnet = true
}

function Ping:ToChannel(number)
	if number == 1 then return "Master" end
	if number == 2 then return "Music" end
	if number == 3 then return "EFX" end
	if number == 4 then return "Ambience" end
	if number == 5 then return "Dialog" end
end

function Ping:ToNumber(channel)
	if channel == "Master" then return 1 end
	if channel == "Music" then return 2 end
	if channel == "EFX" then return 3 end
	if channel == "Ambience" then return 4 end
	if channel == "Dialog" then return 5 end
end

function Ping:CreateSettingsWindow()
	-- Adds the main Category
	local pingOptions, pingLayout = Settings.RegisterVerticalLayoutCategory("Ping Message")
	pingOptions.ID = "PingMessage"
	Settings.RegisterAddOnCategory(pingOptions)
	
	do
		local variable = "pingWhisper"
		local label = "Whisper"
		local tooltip = "Plays the Ping sound when you receive a whisper"
		local defaultValue = Options.whisper
		local setting = Settings.RegisterAddOnSetting(pingOptions, label, variable, type(defaultValue), defaultValue)
		local initializer = Settings.CreateCheckbox(pingOptions	, setting, tooltip)
		Settings.SetOnValueChangedCallback(variable, function()
			Options.whisper = setting:GetValue()
		end) 
	end

	do
		local variable = "pingBNet"
		local label = "Battle.net Whisper"
		local tooltip = "Plays the Ping sound when you receive a whisper from Battle.net"
		local defaultValue = Options.whisper
		local setting = Settings.RegisterAddOnSetting(pingOptions, label, variable, type(defaultValue), defaultValue)
		local initializer = Settings.CreateCheckbox(pingOptions	, setting, tooltip)
		Settings.SetOnValueChangedCallback(variable, function()
			Options.bnet = setting:GetValue()
		end) 
	end
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer()
			container:Add(1, "Master", "Plays the whisper in the Master channel")
			container:Add(2, "Music", "Plays the whisper in the Music channel")
			container:Add(3, "Effects", "Plays the whisper in the Effects channel")
			container:Add(4, "Ambience","Plays the whisper in the Ambience channel")
			container:Add(5, "Dialog", "Plays the whisper in the Dialog channel")
			return container:GetData();
		end
	local variable = "soundChannel"
	local defaultValue = Ping:ToNumber(Options.channel)
	local label = "Sound Channel"
	local setting = Settings.RegisterAddOnSetting(pingOptions, label, variable, type(defaultValue), defaultValue);
	Settings.CreateDropdown(pingOptions, setting, GetOptions);
	Settings.SetOnValueChangedCallback(variable, function()
		local newValue = setting:GetValue()
		Options.channel = Ping:ToChannel(newValue)
	end) 
	end
end

function Ping:ADDON_LOADED(event, addOnName)
	if event == "ADDON_LOADED" and (addOnName == "PingMessage") then
		Options = PingWhisperOptions
		if not Options then
			Options = Defaults
			PingWhisperOptions = Defaults
		end
        Ping:CreateSettingsWindow()
    end
end

function Ping:PLAYER_LOGOUT(event, addOnName)
	PingWhisperOptions = Options
end

function Ping:OnEvent(event, ...)
	if event == "CHAT_MSG_WHISPER" and Options.whisper then
		PlaySoundFile("Interface\\AddOns\\PingMessage\\Assets\\Ping.ogg", "Master")
	elseif event == "CHAT_MSG_BN_WHISPER" and Options.bnet then
		PlaySoundFile("Interface\\AddOns\\PingMessage\\Assets\\Ping.ogg", "Master")
	elseif not (event == "CHAT_MSG_BN_WHISPER") and not (event == "CHAT_MSG_WHISPER") then
		self[event](self, event, ...)
	end
end

Ping:RegisterEvent("CHAT_MSG_BN_WHISPER")
Ping:RegisterEvent("CHAT_MSG_WHISPER")
Ping:RegisterEvent("ADDON_LOADED")
Ping:SetScript("OnEvent", Ping.OnEvent)

