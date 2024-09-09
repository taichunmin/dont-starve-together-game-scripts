local Image = require "widgets/image"
local Button = require "widgets/button"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

require "components/skinner_beefalo"

local SkinsPuppet = Class(Button, function(self)
    Button._ctor(self)

    self.anim = self:AddChild(UIAnim())
    self.animstate = self.anim:GetAnimState()
    self.animstate:SetBank("beefalo")
	self.currentanimbank = "beefalo"
	self.current_idle_anim = "idle_loop"
	self.animstate:PlayAnimation(self.current_idle_anim, true)
	self.default_build = "beefalo_build"
	self.animstate:SetBuild(self.default_build)

	self.anim:SetFacing(FACING_DOWN)

    self.animstate:Hide("HEAT")

    self.anim:SetScale(.1)

    self.last_skins = { prefabname = "", base_skin = "", beef_body = "", beef_horn = "", beef_feet = "", beef_tail = "", beef_head = "" }
end)

function SkinsPuppet:AddShadow()
    self.shadow = self:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	self.shadow:SetPosition(0,-2)
	self.shadow:SetScale(.2)
	self.shadow:MoveToBack()
end

function SkinsPuppet:SetSkins(prefabname, base_item, clothing_names, skip_change_emote)

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

	self.animstate:SetMultColour(1, 1, 1, 1)

	local force_to_idle = self.prefabname ~= prefabname
	self.prefabname = prefabname

	local base_build = prefabname
	base_build = base_item or (prefabname .."_none")

	self.default_build = base_build
	self.animstate:SetBuild(self.default_build)

	SetBeefaloSkinsOnAnim( self.animstate, clothing_names )

	local previousbank = self.currentanimbank
	self.currentanimbank = "beefalo"

	self.last_skins.prefabname = prefabname
	self.last_skins.base_skin = base_build
	self.last_skins.beef_body = clothing_names.beef_body
	self.last_skins.beef_horn = clothing_names.beef_horn
	self.last_skins.beef_head = clothing_names.beef_head
	self.last_skins.beef_feet = clothing_names.beef_feet
	self.last_skins.beef_tail = clothing_names.beef_tail
end

return SkinsPuppet
