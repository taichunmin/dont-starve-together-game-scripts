local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/templates"

-- all delay times are in seconds
local SPEECH_TIME = 9
local IDLE_SPEECH_DELAY = 180

local SkinCollector = Class(Widget, function(self, num_items, mini_game, start_text, is_birthday)
    Widget._ctor(self, "SkinCollector")

	self.mini_game = mini_game
	self.start_text = start_text

	self.root = self:AddChild(Widget("root"))

    self.innkeeper = self.root:AddChild(UIAnim())
  	self.innkeeper:GetAnimState():SetBank("skin_collector")
    self.innkeeper:GetAnimState():SetBuild("skin_collector")
    self.innkeeper:GetAnimState():PlayAnimation("idle", true)
	if not is_birthday then
		self.innkeeper:GetAnimState():Hide("max_head_hat")
		self.innkeeper:GetAnimState():Hide("max_torso_sash")
	end
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
			    														self:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.HAND)
			    													   end
			    											end,
			   												nil ))
    self.hand:SetPosition(-75, 75)

    self.last_speech_time = 0
    self.num_items = num_items
end)

function SkinCollector:Appear()
	self.innkeeper:GetAnimState():PlayAnimation("appear", false)
	self.innkeeper:Show()
	self:StartUpdating()
end

function SkinCollector:Disappear(callbackfn)
	self:QuitTalking()
	self.innkeeper:GetAnimState():PlayAnimation("disappear", false)
	self.exit_callback = callbackfn
end

function SkinCollector:Snap()
	self:QuitTalking()
	self.innkeeper:GetAnimState():PlayAnimation("snap", false)
	self.innkeeper:GetAnimState():PushAnimation("idle", true)
end

function SkinCollector:QuitTalking()
	self:ClearSpeech()
	TheFrontEnd:GetSound():KillSound("skincollector")
end

function SkinCollector:Say(text, rarity, name, number)
	assert(text, "Bad text string for SkinCollector speech")

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

function SkinCollector:ClearSpeech()
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

function SkinCollector:Sleep()
	self.sleeped = true
	self:ClearSpeech()

end

function SkinCollector:Wake()
	self.sleeped = false
end


function SkinCollector:OnUpdate(dt)
	if self.sleeped then
		return
	end

	-- Do intro if appear animation has finished
	if not self.intro_done and
		self.innkeeper:GetAnimState():IsCurrentAnimation("appear") and
		self.innkeeper:GetAnimState():AnimDone() then
		self.innkeeper:GetAnimState():PlayAnimation("idle", true)
		self.intro_done = true

		if self.mini_game then
			self:Say(self.start_text)
		elseif self.num_items > 0 then
			self:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.START)
		else
			self:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.START_EMPTY)
		end
	elseif self.innkeeper:GetAnimState():IsCurrentAnimation("disappear") then
		if self.innkeeper:GetAnimState():AnimDone() then
			self:StopUpdating()
			if self.exit_callback then
				self.exit_callback()
			end
		end

		return
	end

	if not self.crow_game then
		if self.intro_done and (GetStaticTime() - self.last_speech_time) > IDLE_SPEECH_DELAY then
			-- It's been a while since the last speech. Say something random
			self:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.IDLE)
		end
	end

	-- Update text
	if self.talking then
		if self.speech_bubble:GetAnimState():IsCurrentAnimation("open") and
			self.speech_bubble:GetAnimState():AnimDone() then

			self.text:SetString(self.text_string)

			if not self.sound_started then
				TheFrontEnd:GetSound():PlaySound("dontstarve/characters/skincollector/talk_LP", "skincollector")
				self.sound_started = true
			end
		end

		self.display_text_time = self.display_text_time - dt
		if self.display_text_time <= 0 then
			self:ClearSpeech()
		end
	end
end


return SkinCollector