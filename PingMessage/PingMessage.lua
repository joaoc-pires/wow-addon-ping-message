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
	if number == 3 then return "SFX" end
	if number == 4 then return "Ambience" end
	if number == 5 then return "Dialog" end
end

function Ping:ToNumber(channel)
	-- Backwards-compatibility: earlier versions used "EFX"
	if channel == "EFX" then channel = "SFX" end

	if channel == "Master" then return 1 end
	if channel == "Music" then return 2 end
	if channel == "SFX" then return 3 end
	if channel == "Ambience" then return 4 end
	if channel == "Dialog" then return 5 end
end

function Ping:CreateSettingsWindow()
	-- Adds the main Category
	local pingOptions, pingLayout = Settings.RegisterVerticalLayoutCategory("Ping Message")
	pingOptions.ID = "PingMessage"
	Settings.RegisterAddOnCategory(pingOptions)

	-- Whisper checkbox
	do
		local variable = "pingWhisper"
		local variableKey = "whisper"
		local label = "Whisper"
		local tooltip = "Plays the Ping sound when you receive a whisper"
		local defaultValue = Defaults.whisper

		local setting = Settings.RegisterAddOnSetting(
			pingOptions,
			variable,
			variableKey,
			Options,
			type(defaultValue),
			label,
			defaultValue
		)

		Settings.CreateCheckbox(pingOptions, setting, tooltip)
		Settings.SetOnValueChangedCallback(variable, function()
			Options[variableKey] = setting:GetValue()
		end)
	end

	-- Battle.net whisper checkbox
	do
		local variable = "pingBNet"
		local variableKey = "bnet"
		local label = "Battle.net Whisper"
		local tooltip = "Plays the Ping sound when you receive a whisper from Battle.net"
		local defaultValue = Defaults.bnet

		local setting = Settings.RegisterAddOnSetting(
			pingOptions,
			variable,
			variableKey,
			Options,
			type(defaultValue),
			label,
			defaultValue
		)

		Settings.CreateCheckbox(pingOptions, setting, tooltip)
		Settings.SetOnValueChangedCallback(variable, function()
			Options[variableKey] = setting:GetValue()
		end)
	end

	-- Sound channel dropdown (store string values, not numbers)
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer()
			container:Add("Master", "Master", "Plays the ping in the Master channel")
			container:Add("Music", "Music", "Plays the ping in the Music channel")
			container:Add("SFX", "Effects", "Plays the ping in the Effects channel")
			container:Add("Ambience", "Ambience", "Plays the ping in the Ambience channel")
			container:Add("Dialog", "Dialog", "Plays the ping in the Dialog channel")
			return container:GetData()
		end

		local variable = "soundChannel"
		local variableKey = "channel"
		local label = "Sound Channel"

		local defaultValue = Defaults.channel
		if Options.channel ~= nil then
			-- If older saved vars stored "EFX", normalize to "SFX"
			if Options.channel == "EFX" then
				Options.channel = "SFX"
			end
			-- If older experimentation stored a number, convert it to a string
			if type(Options.channel) == "number" then
				Options.channel = Ping:ToChannel(Options.channel) or Defaults.channel
			end
			defaultValue = Options.channel
		end

		local setting = Settings.RegisterAddOnSetting(
			pingOptions,
			variable,
			variableKey,
			Options,
			type(defaultValue),
			label,
			defaultValue
		)

		Settings.CreateDropdown(pingOptions, setting, GetOptions, nil)
		Settings.SetOnValueChangedCallback(variable, function()
			Options[variableKey] = setting:GetValue()
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

		-- Normalize saved variables across versions
		if Options.channel == nil then
			Options.channel = Defaults.channel
		end
		if Options.channel == "EFX" then
			Options.channel = "SFX"
		end
		if type(Options.channel) == "number" then
			Options.channel = Ping:ToChannel(Options.channel) or Defaults.channel
		end

		Ping:CreateSettingsWindow()
	end
end


function Ping:PLAYER_LOGOUT(event, addOnName)
	PingWhisperOptions = Options
end

function Ping:OnEvent(event, ...)
	-- Configured channel is stored as a string (Master/Music/SFX/Ambience/Dialog)
	local channel = (Options and Options.channel) or (Defaults and Defaults.channel) or "Master"

	-- Backwards-compatibility for older saved vars.
	if channel == "EFX" then channel = "SFX" end
	if type(channel) == "number" then
		channel = Ping:ToChannel(channel) or "Master"
	end

	if event == "CHAT_MSG_WHISPER" and Options.whisper then
		PlaySoundFile("Interface\\AddOns\\PingMessage\\Assets\\Ping.ogg", channel)
	elseif event == "CHAT_MSG_BN_WHISPER" and Options.bnet then
		PlaySoundFile("Interface\\AddOns\\PingMessage\\Assets\\Ping.ogg", channel)
	elseif not (event == "CHAT_MSG_BN_WHISPER") and not (event == "CHAT_MSG_WHISPER") then
		self[event](self, event, ...)
	end
end

Ping:RegisterEvent("CHAT_MSG_BN_WHISPER")
Ping:RegisterEvent("CHAT_MSG_WHISPER")
Ping:RegisterEvent("ADDON_LOADED")
Ping:SetScript("OnEvent", Ping.OnEvent)

