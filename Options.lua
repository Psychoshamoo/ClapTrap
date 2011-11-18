--Create the options frame and associate it with ClapTrap.
local f = CreateFrame("Frame", "ClapTrapOptionsFrame", UIParent)
f.loaded = false
ClapTrap.options = f

do
	local function makeCheckBox(name, text, tooltip, state, handler)
		cb = CreateFrame("CheckButton", "ClapTrapOptionsFrame"..name.."CheckButton", f, "InterfaceOptionsCheckButtonTemplate")
		_G[cb:GetName().."Text"]:SetText(text)
		cb:SetScript("OnClick", function(self)
			handler(not not self:GetChecked())
		end)
		cb.tooltipText = tooltip
		cb:SetChecked(state)
		return cb
	end

	function f:LoadAll()
		if self.loaded then return self end

		-----------------------------------------
		-- REGULAR CONFIG OPTIONS
		-----------------------------------------
		h = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		h:SetText("ClapTrap Config")
		h:SetPoint("CENTER", self, "TOP", 0, -20)

		--Config checkbox for learning mode.
		learn_cb = makeCheckBox("Learning",
			"Learning mode",
			"Learning mode allows ClapTrap to learn random phrases when they are typed in all caps.",
			ctdbc.learn,
			function(v) ctdbc.learn = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -40)

		--Config checkbox for respond mode.
		respond_cb = makeCheckBox("Response",
			"Respond to caps",
			"This allows ClapTrap to respond to statements in all caps with phrases it has learned over time.",
			ctdbc.respond,
			function(v) ctdbc.respond = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -65)

		--Config checkbox for pingpong mode.
		pingpong_cb = makeCheckBox("PingPong",
			"Ping pong mode",
			"This allows ClapTrap to respond to statements like ping or pong with things like ding or dong.",
			ctdbc.pingpong,
			function(v) ctdbc.pingpong = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -90)

		--Config checkbox for pingpong mode.
		greeting_cb = makeCheckBox("Greeting",
			"Greeting mode",
			"If somebody tries to greet you, then you will respond accordingly. If they just say only your name, then you will respond accordingly.",
			ctdbc.greeting,
			function(v) ctdbc.greeting = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -115)

		-----------------------------------------
		-- CHAT OPTIONS
		-----------------------------------------
		h = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		h:SetText("Chat Channels")
		h:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -150)

		--Custom channels
		channel_cb = makeCheckBox("Channel",
			"Custom channels",
			"ClapTrap will respond/learn from all custom channels.",
			ctdbc.chats.CUSTOM,
			function(v) ctdbc.chats.CUSTOM = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -170)

		--Party chat
		party_cb = makeCheckBox("Party",
			"Party chat",
			"ClapTrap will respond/learn from party chat.",
			ctdbc.chats.PARTY,
			function(v) ctdbc.chats.PARTY = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -195)

		--Guild chat
		guild_cb = makeCheckBox("Guild",
			"Guild chat",
			"ClapTrap will respond/learn from guild chat.",
			ctdbc.chats.GUILD,
			function(v) ctdbc.chats.GUILD = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -220)

		--Raid chat
		raid_cb = makeCheckBox("Raid",
			"Raid chat",
			"ClapTrap will respond/learn from raid chat.",
			ctdbc.chats.RAID,
			function(v) ctdbc.chats.RAID = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -245)

		--Battleground chat
		bg_cb = makeCheckBox("Battleground",
			"Battleground chat",
			"ClapTrap will respond/learn from battleground chat.",
			ctdbc.chats.BATTLEGROUND,
			function(v) ctdbc.chats.BATTLEGROUND = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -270)

		--Whispers
		whispers_cb = makeCheckBox("Whisper",
			"Whispers",
			"ClapTrap will respond/learn from whispers.",
			ctdbc.chats.WHISPER,
			function(v) ctdbc.chats.WHISPER = v end
		):SetPoint("TOPLEFT", self, "TOPLEFT", 10, -295)

		-----------------------------------------
		-- CLOSE BUTTON
		-----------------------------------------
		cb = CreateFrame("Button", "ClapTrapOptionsFrameCloseButton", self, "UIPanelButtonTemplate2")
		cb:SetText("Close")
		cb:SetWidth(70)
		cb:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -7, 7)
		cb:SetScript("OnClick", function() self:Hide() end)

		--Set to a loaded state.
		self.loaded = true
		return self
	end
end

do
	--Set up/decorate the frame.
	local backdrop = {
		bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false,
		tileSize = 32,
		edgeSize = 16,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	f:SetPoint("CENTER", UIParent)
	f:EnableMouse(true)
	f:SetWidth(200)
	f:SetHeight(370)
	f:SetBackdrop(backdrop)
	f:Hide()
end