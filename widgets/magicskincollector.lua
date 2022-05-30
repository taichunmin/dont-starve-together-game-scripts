local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/templates"

-- all delay times are in seconds
local SPEECH_TIME = 6
local IDLE_SPEECH_DELAY = 180

local MagicSkinCollector = Class(Widget, function(self)
    Widget._ctor(self, "MagicSkinCollector")

    self.root = self:AddChild(Widget("root"))

    self.innkeeper = self.root:AddChild(UIAnim())
  	self.innkeeper:GetAnimState():SetBank("skin_collector")
    self.innkeeper:GetAnimState():SetBuild("skin_collector")
    self.innkeeper:GetAnimState():PlayAnimation("idle", true)
    self.innkeeper:SetScale(-.55, .55, .55)
    self.innkeeper:SetPosition(0, -0)
    self.innkeeper:Hide()

    self.speech_bubble = self.root:AddChild(UIAnim())
    self.speech_bubble:GetAnimState():SetBank("textbox")
    self.speech_bubble:GetAnimState():SetBuild("textbox")
    self.speech_bubble:SetPosition(40, 550)
    self.speech_bubble:SetScale(-.66, .95, .66)
    self.speech_bubble:Show()

    self.text = self.root:AddChild(Text(BUTTONFONT, 35, "", WHITE))
    self.text:SetRegionSize( 250, 180)
    self.text:SetVAlign(ANCHOR_MIDDLE)
    self.text:EnableWordWrap(true)
    self.text:SetPosition(50, 550)

    self.hand = self.root:AddChild(TEMPLATES.InvisibleButton(15, 15,
			    											function() if not self.talking then
			    														self:Say(STRINGS.UI.TRADESCREEN.MAGICSKIN_COLLECTOR_SPEECH.HAND)
			    													   end
			    											end,
			   												nil ))
    self.hand:SetPosition(-75, 75)

    self.last_speech_time = 0
end)

function MagicSkinCollector:Appear()
	self.innkeeper:GetAnimState():PlayAnimation("appear", false)
	self.innkeeper:Show()
	self:StartUpdating()
end

function MagicSkinCollector:Disappear(callbackfn)
	self:QuitTalking()
	self.innkeeper:GetAnimState():PlayAnimation("disappear", false)
	self.exit_callback = callbackfn
end

function MagicSkinCollector:Snap()
	self:QuitTalking()
	self.innkeeper:GetAnimState():PlayAnimation("snap", false)
	self.innkeeper:GetAnimState():PushAnimation("idle", true)
end

function MagicSkinCollector:QuitTalking()
	--print("MagicSkinCollector QuitTalking")
	self:ClearSpeech()
	TheFrontEnd:GetSound():KillSound("skincollector")
end

function MagicSkinCollector:Say(text, rarity, name, number)
	assert(text, "Bad text string for MagicSkinCollector speech")

	local str = text
	if type(text) == "table" then
		str = GetRandomItem(text)
	end

	if rarity then
		str = string.gsub(str, "<rarity>", rarity)
	end

	if name then
		str = string.gsub(str, "<item>", name)
	end

	if number then
		str = string.gsub(str, "<number>", number)
	end

	self.last_speech_time = GetStaticTime()

	if not (self.innkeeper:GetAnimState():IsCurrentAnimation("dialog_pre") or self.innkeeper:GetAnimState():IsCurrentAnimation("dial_loop")) then
		self.innkeeper:GetAnimState():PlayAnimation("dialog_pre", false)
		self.innkeeper:GetAnimState():PushAnimation("dial_loop", true)
	end

	self.speech_bubble:Show()
	if not self.speech_bubble:GetAnimState():IsCurrentAnimation("open") then
		self.speech_bubble:GetAnimState():PlayAnimation("open", false)
	end

	self.text_string = str
	self.display_text_time = SPEECH_TIME

	self.talking = true
end

function MagicSkinCollector:ClearSpeech()
	if self.innkeeper:GetAnimState():IsCurrentAnimation("dialog_pre") or self.innkeeper:GetAnimState():IsCurrentAnimation("dial_loop") then
		self.innkeeper:GetAnimState():PlayAnimation("dialog_pst", false)
		self.speech_bubble:GetAnimState():PlayAnimation("close", false)
		TheFrontEnd:GetSound():KillSound("skincollector")
		self.sound_started = nil
		self.text:SetString("")
		self.innkeeper:GetAnimState():PushAnimation("idle", true)
		self.talking = nil
		self.text_string = nil
		self.display_text_time = 0
	end
end

function MagicSkinCollector:OnUpdate(dt)
	-- Do intro if appear animation has finished
	if not self.intro_done and
		self.innkeeper:GetAnimState():IsCurrentAnimation("appear") and
		self.innkeeper:GetAnimState():AnimDone() then
		self.innkeeper:GetAnimState():PlayAnimation("idle", true)
		self.intro_done = true
		self:Say(STRINGS.UI.TRADESCREEN.MAGICSKIN_COLLECTOR_SPEECH.START)
	elseif self.innkeeper:GetAnimState():IsCurrentAnimation("disappear") then
		if self.innkeeper:GetAnimState():AnimDone() then
			self:StopUpdating()
			if self.exit_callback then
				self.exit_callback()
			end
		end

		return
	end

	if self.intro_done and (GetStaticTime() - self.last_speech_time) > IDLE_SPEECH_DELAY then
		--print("Playing idle speech at ", GetStaticTime(), self.last_speech_time)
		-- It's been a while since the last speech. Say something random
		self:Say(STRINGS.UI.TRADESCREEN.MAGICSKIN_COLLECTOR_SPEECH.IDLE)
	end

	-- Update text
	if self.talking then
		if self.speech_bubble:GetAnimState():IsCurrentAnimation("open") and
			self.speech_bubble:GetAnimState():AnimDone() then

			self.text:SetString(self.text_string)

			if not self.sound_started then
				--print("Playing skin collector talk sound")
				TheFrontEnd:GetSound():PlaySound("dontstarve/characters/skincollector/talk_LP", "skincollector")
				self.sound_started = true
				--print("Starting sound")
			end
		end

		self.display_text_time = self.display_text_time - dt
		if self.display_text_time <= 0 then
			self:ClearSpeech()
		end
	end
end


return MagicSkinCollector