--Create ClapTrap!
ClapTrap = CreateFrame("Frame")

--Load up with variables.
ClapTrap.player = GetUnitName("player")
ClapTrap.lang = GetDefaultLanguage("player")
ClapTrap.interval = 5
ClapTrap.last = 0

ClapTrap.variables = {
	--Interval to learn new responses.
	learnInterval = 5,
	--These are used for the ping pong.
	letterbank = {"b", "d", "f", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "x", "y", "z"},
	--Greets when people say a key word next to your name.
	--TODO: Allow these to be customized.
	greets = {
		"Hello, %s.",
		"How the fuck are you, %s?!?!",
		"WHAT THE FUCK DO YOU WANT %s????",
		"SHUT THE FUCK UP, %s.",
		"I DON'T APPRECIATE GREETINGS %s, YOU MOTHERFUCKER.",
		"PROTIP: I DON'T GIVE A SHIT ABOUT YOUR OPINIONS %s."
	},
	--TODO: Allow this to be customized.
	response = "WHAT?"
}

--Default values for saved variables.
ClapTrap.defaults = {
	global = {
		randomstatement = {
			count = 0,
			quotes = {
				'HI'
			}
		}
	},
	character = {
		learn = true,
		respond = false,
		pingpong = false,
		greeting = true,
		chats = {
			CUSTOM = true,
			PARTY = true,
			GUILD = true,
			RAID = true,
			BATTLEGROUND = true,
			WHISPER = true
		}
	}
}

do
	local msg, author, lang, cnamefull, target, flags, zid, cnum, cname, lineid, guid, destination, fragments

	---------------------------------------------------------------------------------
	-- function RandomResponse()
	--
	-- This function is called when the user attempts to greet the bot or simply says
	-- the name of the player using the addon. This makes it a little more
	-- interesting!
	---------------------------------------------------------------------------------
	function ClapTrap:RandomResponse()
		if not ctdbc.greeting then return false end

		local nameFound = false
		local greetFound = false
		for _, v in ipairs(fragments) do
			v = strlower(v)
			if v == strlower(self.player) then
				nameFound = true
			elseif v == 'hi' or v == 'hello' or v == 'sup' then
				greetFound = true
			end
		end

		if nameFound and greetFound then
			self:SendMessage(format(self.variables.greets[random(#self.variables.greets)], author))
			return true
		elseif strlower(msg) == strlower(self.player) then
			self:SendMessage(self.variables.response)
			return true
		end

		return false
	end

	---------------------------------------------------------------------------------
	-- function LearnPhrase()
	--
	-- This function is called when we want the bot to learn a new statement. The
	-- likelyhood that the phrase is learned is also controlled within this function.
	-- All quotes are stored within the global vars so the phrases are consistent
	-- between characters.
	---------------------------------------------------------------------------------
	function ClapTrap:LearnPhrase()
		if not ctdbc.learn or strlen(msg) < 2 then return false end

		--Increment the counter for learning the phrase.
		ctdb.randomstatement.count = ctdb.randomstatement.count + 1

		--Reset the counter and store if we have met the target.
		if ctdb.randomstatement.count == self.variables.learnInterval then
			ctdb.randomstatement.count = 0
			--Do not duplicate entries.
			if not tContains(ctdb.randomstatement.quotes, msg) then
				tinsert(ctdb.randomstatement.quotes, msg)
			end
			return true
		end
		return false
	end

	---------------------------------------------------------------------------------
	-- function RandomStatement()
	--
	-- When people say things in all caps, it is usually something that can be used
	-- in a funny context later. We can remedy that by saying something that we have
	-- collected in the memory bank for the addon and spit it back at them if their
	-- phrase is in all caps!
	---------------------------------------------------------------------------------
	function ClapTrap:RandomStatement()
		if not ctdbc.respond then return false end
		local message = ctdb.randomstatement.quotes[random(#ctdb.randomstatement.quotes)]
		self:SendMessage(message)
		return true
	end

	---------------------------------------------------------------------------------
	-- function PingPong()
	--
	-- PingPong is a popular bot feature in IRC. When a person says "ping" or "pong",
	-- or any similar word that ends in ing, ong, or ang the bot replies with a
	-- randomly generated word of similar nature. It is selected by finding the
	-- length of each word, and if it is 4 then check to see if the suffix is
	-- compatible with pingpong. After picking out the suffix, append a random letter
	-- to it and output the message.
	---------------------------------------------------------------------------------
	function ClapTrap:PingPong()
		if not ctdbc.pingpong then return false end
		local ppfound = false
		local pp = ""
		if strlen(msg) == 4 then
			pp = strsub(msg, 2)
			if pp == "ing" or pp == "ong" or pp == "ang" then
				ppfound = true
			end
		end

		--If we have found ping pong then send the message.
		if ppfound then
			local send = self.variables.letterbank[random(#self.variables.letterbank)]..pp
			self:SendMessage(send)
			return true
		end

		return false
	end

	---------------------------------------------------------------------------------
	-- function SendMessage()
	--
	-- This function is called when we are trying to send a message. Depending on the
	-- source of the message we will need to process it differently, hence the reason
	-- this function exists in the first place. For the time being trade chat is
	-- filtered out, as there is a limitation on what you can send.
	---------------------------------------------------------------------------------
	function ClapTrap:SendMessage(message)
		if zid == 2 then return
		elseif destination == "CHANNEL" then
			SendChatMessage(message, destination, self.lang, cnum)
		elseif destination == "WHISPER" then
			SendChatMessage(message, destination, self.lang, author)
		else
			SendChatMessage(message, destination, self.lang)
		end
	end

	---------------------------------------------------------------------------------
	-- EVENT HANDLER
	---------------------------------------------------------------------------------
	ClapTrap:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then 
			if ... == "ClapTrap" then
				ctdb = ctdb or self.defaults.global
				ctdbc = ctdbc or self.defaults.character
				--For debugging the options panel
				--self.options:LoadAll():Show()
			end
			return
		end

		----
		--PREPARATION
		----
		msg, author, lang, cnamefull, target, flags, zid, cnum, cname, lineid, guid = ...
		if author == self.player then return end

		--Filtering channels based on the user prefs.
		destination = strsub(event, 10)
		if destination == "CHANNEL" and not ctdbc.chats[destination] then return end
		
		--Split the message up.
		fragments = {strsplit(" .!?,:;()[]", msg)}

		----
		--GENERAL STATEMENTS
		----
		if self:RandomResponse() then return end

		----
		--ALL CAPS STATEMENTS
		----
		if strupper(msg) == msg and strfind(msg, "%a") then
			self:LearnPhrase()
			if self:RandomStatement() then return end
		end

		self:PingPong()
	end)
end

--Register events.
ClapTrap:RegisterEvent("ADDON_LOADED")
ClapTrap:RegisterEvent("CHAT_MSG_CHANNEL")
ClapTrap:RegisterEvent("CHAT_MSG_PARTY")
ClapTrap:RegisterEvent("CHAT_MSG_GUILD")
ClapTrap:RegisterEvent("CHAT_MSG_RAID")
ClapTrap:RegisterEvent("CHAT_MSG_WHISPER")
ClapTrap:RegisterEvent("CHAT_MSG_BATTLEGROUND")

--Slash command handler.
SlashCmdList['CLAPTRAP'] = function(args)
	ClapTrap.options:LoadAll():Show()
	ClapTrap.options:Show()
	--print("|cff00ff00ClapTrap Commands")
	--print("Type |cff00ff00/ct or /claptrap <command>|cffffffff to use the commands below!")
	--print("|cff00ff00on|cffffffff - Turn ClapTrap on")
	--print("|cff00ff00off|cffffffff - Turn ClapTrap off")
	--print("|cff00ff00config|cffffffff - Bring up configuration options")
end

SLASH_CLAPTRAP1 = '/ct'
SLASH_CLAPTRAP2 = '/claptrap'