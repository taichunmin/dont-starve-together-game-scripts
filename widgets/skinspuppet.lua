local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

require "components/skinner"

local emotes_to_choose = { "emoteXL_waving1", "emoteXL_waving2", "emoteXL_waving3" }
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

local SkinsPuppet = Class(Widget, function(self)
    Widget._ctor(self, "puppet")

	--[[
		Puppet formerly used to swap between corner_dude (now deprecated)
		and wilson anim banks for idle/emote animations. Structure is still
		there to support separate banks for emotes and idle anims, but there
		is probably no real need for it anymore. Idle anims for special
		skin modes are taken care of anyway.
	]]

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

	self.anim:SetFacing(FACING_DOWN)

    self.animstate:Hide("ARM_carry")
    self.animstate:Hide("head_hat")
    self.animstate:Hide("HAIR_HAT")

    self.anim:SetScale(.25)
    
    self.last_skins = { prefabname = "", base_skin = "", body = "", hand = "", legs = "", feet = "" }
    
    self.enable_idle_emotes = true
    self.time_to_idle_emote = emote_max_time
    self.time_to_change_emote = -1
    self.queued_change_slot = ""

	self.play_non_idle_emotes = true
end)

function SkinsPuppet:AddShadow()
    self.shadow = self:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	self.shadow:SetPosition(0,-2)
	self.shadow:SetScale(.2)
	self.shadow:MoveToBack()
end

function SkinsPuppet:DoEmote(emote, loop, force)
	if force or self.animstate:IsCurrentAnimation("idle_loop") then
		self.animstate:SetBank("wilson")
        if type(emote) == "table" then
			self.animstate:PlayAnimation(emote[1])
			for i=2,#emote do
				self.animstate:PushAnimation(emote[i], loop)
			end
			self.looping = loop
		else
			self.animstate:PlayAnimation(emote)
			self.looping = false
		end
    end
end

function SkinsPuppet:DoIdleEmote()
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
    self.time_to_idle_emote = math.random(emote_min_time, emote_max_time)
end

function SkinsPuppet:EmoteUpdate(dt)
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

		self.animstate:PlayAnimation(self.current_idle_anim, true)
	end
end
    
function SkinsPuppet:SetCharacter(character)
	self.animstate:SetBuild(character)
end

function SkinsPuppet:SetSkins(prefabname, base_item, clothing_names, skip_change_emote, skinmode)
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

	if skinmode == nil then
		skinmode = GetSkinModes(prefabname)[1]
	end

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
	SetSkinsOnAnim( self.animstate, prefabname, base_build, clothing_names, skinmode.type)


	local previousbank = self.currentanimbank
	self.currentanimbank = skinmode.anim_bank or "wilson"
	if self.currentanimbank ~= previousbank then
		self.animstate:SetBank(self.currentanimbank)

		self.current_idle_anim = skinmode.idle_anim or "idle_loop"
		self.animstate:PlayAnimation(self.current_idle_anim, true)
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


return SkinsPuppet
