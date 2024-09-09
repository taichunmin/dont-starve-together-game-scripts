local Image = require "widgets/image"
local Button = require "widgets/button"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

require "components/skinner"

local emotes_to_choose = { "emoteXL_waving1", "emoteXL_waving2", "emoteXL_waving3" }
local player_emotes_to_choose = {
	wilson = "idle_wilson",
	walter = "idle_walter",
	wathgrithr = "idle_wathgrithr",
	warly = "idle_warly",
	wendy = "idle_wendy",
	willow = "idle_willow",
	winona = "idle_winona",
	woodie = "idle_woodie",
	wormwood = "idle_wormwood",
	wortox = "idle_wortox",
	wurt = "idle_wurt",
	wes = "idle_wes",
	webber = "idle_webber",
	wanda = "idle_wanda",
	wolfgang = { wimpy_skin = "idle_wolfgang_skinny", normal_skin = "idle_wolfgang", mighty_skin = "idle_wolfgang_mighty" },
    wx78 = "idle_wx",
	wonkey = "idle_wonkey",
	wickerbottom = "idle_wickerbottom",
	waxwell = function() return math.random() < .7 and "idle_waxwell" or "idle2_waxwell" end, -- Keep odds in sync with SGwilson!
}

local emote_min_time = 6
local emote_max_time = 12

local change_delay_time = .5
local change_emotes =
{
	base = { "emote_hat" },
	body = { "emote_strikepose" },
	hand = { "emote_hands" },
	legs = { "emote_pants" },
	feet = { "emote_feet" },
}

local SkinsPuppet = Class(Button, function(self, emote_min_time, emote_max_time)
    Button._ctor(self)

	--[[
		Puppet formerly used to swap between corner_dude (now deprecated)
		and wilson anim banks for idle/emote animations. Structure is still
		there to support separate banks for emotes and idle anims, but there
		is probably no real need for it anymore. Idle anims for special
		skin modes are taken care of anyway.
	]]
	self.emote_min_time = emote_min_time
	self.emote_max_time = emote_max_time

    self.anim = self:AddChild(UIAnim())
    self.animstate = self.anim:GetAnimState()
    self.animstate:SetBank("wilson")
	self.currentanimbank = "wilson"
	self.current_idle_anim = "idle_loop"
	self.default_build = "wilson"
	self.animstate:SetBuild(self.default_build)
	--
    self.animstate:AddOverrideBuild("player_emote_extra")
    self.animstate:PlayAnimation(self.current_idle_anim, true)
	self.animstate:SetTime(math.random()*1.5)

	self.anim:SetFacing(FACING_DOWN)

    self.animstate:Hide("ARM_carry")
    self.animstate:Hide("HAIR_HAT")
	self.animstate:Hide("HEAD_HAT")
	self.animstate:Hide("HEAD_HAT_NOHELM")
	self.animstate:Hide("HEAD_HAT_HELM")

    self.anim:SetScale(.25)

    self.last_skins = { prefabname = "", base_skin = "", body = "", hand = "", legs = "", feet = "" }

    self.enable_idle_emotes = true
    self:_ResetIdleEmoteTimer()
    self.time_to_change_emote = -1
    self.queued_change_slot = ""

	self.play_non_idle_emotes = true
	self.add_change_emote_for_idle = false
	self.sitting = false
end)

function SkinsPuppet:AddShadow()
    self.shadow = self:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	self.shadow:SetPosition(0,-2)
	self.shadow:SetScale(.2)
	self.shadow:MoveToBack()
end

function SkinsPuppet:DoEmote(emote, loop, force, do_push)
	if not self.sitting and (force or self.animstate:IsCurrentAnimation("idle_loop")) then
		self.animstate:SetBank("wilson")
        if type(emote) == "table" then
			self.animstate:PlayAnimation(emote[1])
			for i=2,#emote do
				self.animstate:PushAnimation(emote[i], loop)
			end
			self.looping = loop
		else
			if do_push then
				self.animstate:PushAnimation(emote)
			else
				self.animstate:PlayAnimation(emote)
			end
			self.looping = false
		end
    end
end

function SkinsPuppet:Sit()
	self.sitting = true
	self.animstate:PlayAnimation("emote_loop_sit2", true)
	self.animstate:SetTime(math.random()*1.5)
	self.animstate:SetMultColour(.6, .6, .6, 1)
end


function SkinsPuppet:DoIdleEmote()
	if self.add_change_emote_for_idle then
		local r = math.random()
		if r > 0.8 then
			self.queued_change_slot = GetRandomKey(change_emotes) --Hack to queue up a change emote
			self:DoChangeEmote()
			return
		end
	end
	if player_emotes_to_choose[self.prefabname] then
		local r = math.random()
		if r > 0.3 then
			if self.prefabname == "wendy" then
				self.override_build = "player_idles_wendy"
				self.animstate:AddOverrideBuild(self.override_build)
			elseif self.prefabname == "warly" then
				self.override_build = "player_idles_warly"
				self.animstate:AddOverrideBuild(self.override_build)

			elseif self.prefabname == "willow" then
				local skin_build = Profile:GetLastUsedSkinForItem("bernie_inactive")
				if skin_build ~= nil and skin_build ~= "bernie_inactive" then
					self.animstate:OverrideItemSkinSymbol("swap_object", skin_build, "swap_bernie", 0, "bernie_build")
					self.animstate:OverrideItemSkinSymbol("swap_object_bernie", skin_build, "swap_bernie_idle_willow", 0, "bernie_build")
				else
					self.animstate:OverrideSymbol("swap_object", "bernie_build", "swap_bernie")
					self.animstate:OverrideSymbol("swap_object_bernie", "bernie_build", "swap_bernie_idle_willow")
				end
				self.animstate:Show("ARM_carry")
				self.animstate:Hide("ARM_normal")

				self.animstate:PlayAnimation("item_out")
				self.item_equip = true

			elseif self.prefabname == "woodie" then
				self.animstate:OverrideSymbol("swap_object", "swap_lucy_axe", "swap_lucy_axe")

				self.animstate:Show("ARM_carry")
				self.animstate:Hide("ARM_normal")

				self.animstate:PlayAnimation("item_out")
				self.item_equip = true
			elseif self.prefabname == "wes" then
				self.override_build = "player_idles_wes"
				self.animstate:AddOverrideBuild(self.override_build)
			elseif self.prefabname == "webber" then
				self.override_build = "player_idles_webber"
				self.animstate:AddOverrideBuild(self.override_build)
			elseif self.prefabname == "wanda" then
				self.override_build = "player_idles_wanda"
				self.animstate:AddOverrideBuild(self.override_build)
			elseif self.prefabname == "waxwell" then
				self.override_build = "player_idles_waxwell"
				self.animstate:AddOverrideBuild(self.override_build)
			elseif self.prefabname == "wonkey" then
				-- Do no special handling.
			end

			if self.prefabname == "wormwood" and not self.animstate:CompareSymbolBuilds("hand", "hand_idle_wormwood") then
				--don't do player anim
			elseif self.prefabname == "wickerbottom" and not self.animstate:CompareSymbolBuilds("hand", "hand_wickerbottom") then
				--don't do player anim
			else
				local emote_anim = nil
				if self.prefabname == "wolfgang" then
					local skin_mode = ""
					if self.current_skinmode then
						skin_mode = self.current_skinmode.type or "normal_skin"
					end
					emote_anim = player_emotes_to_choose["wolfgang"][skin_mode]
				else
					emote_anim = player_emotes_to_choose[self.prefabname]
				end

				if type(emote_anim) == "function" then
					emote_anim = emote_anim()
				end

				self:DoEmote( emote_anim, false, true, self.item_equip)
				if self.item_equip then
					self.animstate:PushAnimation("item_in")
					self.animstate:PushAnimation("idle_loop", true) --fix for frame pop before the next play happens
				end

				return
			end
		end
	end

    local r = math.random(1,#emotes_to_choose)
    self:DoEmote(emotes_to_choose[r])
end

function SkinsPuppet:DoChangeEmote()
	if self.queued_change_slot ~= "" then --queued_change_slot is empty when we first load up the puppet and the dressuppanel is initializing
		local r = math.random( 1, #change_emotes[self.queued_change_slot] )
		self:DoEmote( change_emotes[self.queued_change_slot][r] )
		self.queued_change_slot = "" --clear it out now so that we can get a new one
	end
end

function SkinsPuppet:_ResetIdleEmoteTimer()
    self.time_to_idle_emote = math.random(self.emote_min_time or emote_min_time, self.emote_max_time or emote_max_time)
end

function SkinsPuppet:RemoveEquipped()
	self.item_equip = false
	self.animstate:Hide("ARM_carry")
	self.animstate:Show("ARM_normal")
end

function SkinsPuppet:EmoteUpdate(dt)
	if self.sitting then
		return
	end

	if self.item_equip and self.animstate:IsCurrentAnimation("item_in") then
		self:RemoveEquipped()
	end

	if self.time_to_idle_emote > 0 then
		self.time_to_idle_emote = self.time_to_idle_emote - dt
	elseif self.enable_idle_emotes then
		if self.animstate:AnimDone() then
			self:_ResetIdleEmoteTimer()
			if self.play_non_idle_emotes then self:DoIdleEmote() end
		end
	end

	if self.time_to_change_emote > 0 then
		self.time_to_change_emote = self.time_to_change_emote - dt
		if self.time_to_change_emote <= 0 then
			if self.animstate:IsCurrentAnimation("idle_loop") then
				-- reset the idle emote as well when starting the change emote
				self:_ResetIdleEmoteTimer()
				if self.play_non_idle_emotes then self:DoChangeEmote() end
			else
				self.time_to_change_emote = 0.25 --ensure that we wait a little bit before trying to start the change emote, so that it doesn't play back to back with
			end
		end
	end

	if not self.looping and self.animstate:AnimDone() then
		if self.play_non_idle_emotes then
			self.animstate:SetBank(self.currentanimbank)
		end

		if self.override_build then
			self.animstate:ClearOverrideBuild( self.override_build )
		end
		self.animstate:PlayAnimation(self.current_idle_anim, true)
	end
end

function SkinsPuppet:SetCharacter(character)
	self.animstate:SetBuild(character)
end

function SkinsPuppet:SetSkins(prefabname, base_item, clothing_names, skip_change_emote, skinmode, monkey_curse)
	--[[
		For mod character support, skinmode should be a table in the format of:

		{
			type = "ghost_skin"
			build = "wilson",
			anim_bank = "ghost"
			idle_anim = "idle_loop",
			play_emotes = false,
			scale = 0.5,
			offset = { 0, -25 }
		}
	]]

	self.sitting = false
	self.animstate:SetMultColour(1, 1, 1, 1)

	local force_to_idle = self.prefabname ~= prefabname
	self.prefabname = prefabname

	if skinmode == nil then
		skinmode = GetSkinModes(prefabname)[1]
	end
	self.current_skinmode = skinmode

	local base_build = prefabname
	base_item = base_item or (prefabname .."_none")

	local skindata = GetSkinData(base_item)
	local skindata_skins = skindata.skins
	if skindata_skins ~= nil then
		base_build = skindata_skins[skinmode.type or "normal_skin"]
	end

	if skinmode.type == "ghost_skin" then
		if not IsPrefabSkinned(prefabname) then
			base_build = "ghost_" .. prefabname .. "_build"
		end
	end
	SetSkinsOnAnim( self.animstate, prefabname, base_build, clothing_names, monkey_curse, skinmode.type)


	local previousbank = self.currentanimbank
	self.currentanimbank = skinmode.anim_bank or "wilson"
	if force_to_idle or self.currentanimbank ~= previousbank then
		self.animstate:SetBank(self.currentanimbank)

		self.current_idle_anim = skinmode.idle_anim or "idle_loop"
		self.animstate:PlayAnimation(self.current_idle_anim, true)
		self.animstate:SetTime(math.random()*1.5)
		self:RemoveEquipped()
	end

	self.play_non_idle_emotes = skinmode.play_emotes



	if not skip_change_emote then
        --the logic here checking queued_change_slot and time_to_change_emote is to ensure we get the last thing to change (when dealing with multiple changes on one frame caused by the UI refreshing)
		if self.play_non_idle_emotes and (self.queued_change_slot == "" or self.time_to_change_emote < change_delay_time ) then
			if self.last_skins.prefabname ~= prefabname or self.last_skins.base_skin ~= base_build then
				self.queued_change_slot = "base"
			end
			if self.last_skins.body ~= clothing_names.body then
				self.queued_change_slot = "body"
			end
			if self.last_skins.hand ~= clothing_names.hand then
				self.queued_change_slot = "hand"
			end
			if self.last_skins.legs ~= clothing_names.legs then
				self.queued_change_slot = "legs"
			end
			if self.last_skins.feet ~= clothing_names.feet then
				self.queued_change_slot = "feet"
			end
		end
		self.time_to_change_emote = change_delay_time
	else
		self.queued_change_slot = ""
	end

	if prefabname == "scarecrow" then
        self.animstate:SetBank("scarecrow")
		if self.scarecrow_pose == nil then
			self.scarecrow_pose = string.format( "pose%s", tostring(math.random( 1, 7 )))
		end
		self.animstate:PlayAnimation( self.scarecrow_pose, true )
	end

	self.last_skins.prefabname = prefabname
	self.last_skins.base_skin = base_build
	self.last_skins.body = clothing_names.body
	self.last_skins.hand = clothing_names.hand
	self.last_skins.legs = clothing_names.legs
	self.last_skins.feet = clothing_names.feet
end

local beards =
{
	wilson =
	{
		"beard_short",
		"beard_medium",
		"beard_long"
	},
	webber =
	{
		"beardsilk_short",
		"beardsilk_medium",
		"beardsilk_long"
	}
}

local beard_file =
{
	wilson = "beard",
	webber = "beard_silk"
}

function SkinsPuppet:SetBeardLength(length)
	self.beard_length = length
	self:SetBeard( self.beard )
end

function SkinsPuppet:SetBeard(beard)
	self.beard = beard
	if self.beard_length ~= nil then
		if beard == nil or beard == "beard_default1" then
			self.animstate:OverrideSymbol("beard", beard_file[self.character or "wilson"], beards[self.character or "wilson"][self.beard_length])
		else
			self.character = beard:sub(1,string.find(beard, "_")-1)
			self.animstate:OverrideSkinSymbol("beard", beard, beards[self.character][self.beard_length])
		end
	end
end

function SkinsPuppet:OnGainFocus()
	self._base.OnGainFocus(self)

	--Only gets called if SetClickable(true) which is the default
	if self.enable_idle_emotes then
		if self.animstate:IsCurrentAnimation("idle_loop") then
			self:_ResetIdleEmoteTimer()
			self:DoIdleEmote()
		end
	end
end

return SkinsPuppet
