local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local DEFAULT_ATLAS = "images/avatars.xml"
local DEFAULT_AVATAR = "avatar_unknown.tex"

local PlayerBadge = Class(Widget, function(self, prefab, colour, ishost, userflags)
    Widget._ctor(self, "PlayerBadge")
    self.isFE = false
    self:SetClickable(false)

    self.root = self:AddChild(Widget("root"))

    self.icon = self.root:AddChild(Widget("target"))
    self.icon:SetScale(.8)

    self.userflags = 0 --we need a default for GetBG to not crash
    self.headbg = self.icon:AddChild(Image(DEFAULT_ATLAS, self:GetBG()))
    self:_SetupHeads()

	self.loading_icon = self.icon:AddChild(Image(DEFAULT_ATLAS, "loading_indicator.tex"))
	self.loading_icon:Hide()

    self.headframe = self.icon:AddChild(Image(DEFAULT_ATLAS, "avatar_frame_white.tex"))

    self:Set(prefab, colour, ishost, userflags)
end)

function PlayerBadge:_SetupHeads()
    self.head = self.icon:AddChild(Image( DEFAULT_ATLAS, DEFAULT_AVATAR ))

    self.head_anim = self.icon:AddChild(UIAnim())
    self.head_animstate = self.head_anim:GetAnimState()

	self.head_anim:SetFacing(FACING_DOWN)

    self.head_animstate:Hide("ARM_carry")
    self.head_animstate:Hide("HAIR_HAT")
	self.head_animstate:Hide("HEAD_HAT")
	self.head_animstate:Hide("HEAD_HAT_NOHELM")
	self.head_animstate:Hide("HEAD_HAT_HELM")

    self.head_anim:Hide()
end

function PlayerBadge:Set(prefab, colour, ishost, userflags, base_skin)
    self.headframe:SetTint(unpack(colour))

    local dirty = false

    if self.ishost ~= ishost then
        self.ishost = ishost
        dirty = true
    end

    if self.base_skin ~= base_skin then
        self.base_skin = base_skin
        dirty = true
    end

    if self.prefabname ~= prefab then
        if table.contains(DST_CHARACTERLIST, prefab) then
            self.prefabname = prefab
            self.is_mod_character = false
        elseif table.contains(MODCHARACTERLIST, prefab) then
            self.prefabname = prefab
            self.is_mod_character = true
        elseif prefab == "random" then
            self.prefabname = "random"
            self.is_mod_character = false
        else
            self.prefabname = ""
            self.is_mod_character = (prefab ~= nil and #prefab > 0)
        end
        dirty = true
    end
    if self.userflags ~= userflags then
        self.userflags = userflags
        dirty = true
    end
    if dirty then
        self.headbg:SetTexture(DEFAULT_ATLAS, self:GetBG())

        if self:UseAvatarImage() then
            self.head:Show()
            self.head_anim:Hide()

            self.head:SetTexture( DEFAULT_ATLAS, self:GetAvatarImage())
        else
            self.head:Hide()
            self.head_anim:Show()

            local bank, animation, skin_mode, scale, y_offset = GetPlayerBadgeData( prefab, self:IsGhost(), self:IsCharacterState1(), self:IsCharacterState2(), self:IsCharacterState3() )

            self.head_animstate:SetBank(bank)
            self.head_animstate:PlayAnimation(animation, true)
            if Profile:GetAnimatedHeadsEnabled() then
                self.head_animstate:SetTime(math.random()*1.5)
            else
                self.head_animstate:SetTime(0)
                self.head_animstate:Pause()
            end
            self.head_anim:SetScale(scale)
            self.head_anim:SetPosition(0,y_offset, 0)

            local skindata = GetSkinData(base_skin or self.prefabname.."_none")
            local base_build = self.prefabname
            if skindata.skins ~= nil then
                base_build = skindata.skins[skin_mode]
            end
            SetSkinsOnAnim( self.head_animstate, self.prefabname, base_build, {}, nil, skin_mode)
        end
    end

	if self:IsLoading() then
		if not self.loading_icon.shown then
			self.loading_icon:Show()
			local function dorotate() self.loading_icon:RotateTo(0, -360, 1, dorotate) end
			self.loading_icon:CancelRotateTo()
			dorotate()
            self.head:SetTint(0,0,0,1)
            self.head_animstate:SetMultColour(0,0,0,1)
		end
	else
		if self.loading_icon.shown then
			self.loading_icon:Hide()
			self.loading_icon:CancelRotateTo()
			self.head:SetTint(1,1,1,1)
            self.head_animstate:SetMultColour(1,1,1,1)
		end
	end
end

function PlayerBadge:IsGhost()
    return checkbit(self.userflags, USERFLAGS.IS_GHOST)
end

function PlayerBadge:IsAFK()
    return checkbit(self.userflags, USERFLAGS.IS_AFK)
end

function PlayerBadge:IsCharacterState1()
    return checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_1)
end

function PlayerBadge:IsCharacterState2()
    return checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_2)
end

function PlayerBadge:IsCharacterState3()
    return checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_3)
end

function PlayerBadge:IsLoading()
    return checkbit(self.userflags, USERFLAGS.IS_LOADING)
end

function PlayerBadge:GetBG()
    return (self.ishost and self.prefabname == "" and not TheNet:GetServerIsClientHosted() and "avatar_bg.tex")
        or (self:IsAFK() and "avatar_bg.tex")
        or (self:IsGhost() and "avatar_ghost_bg.tex")
        or "avatar_bg.tex"
end

function PlayerBadge:UseAvatarImage()
    return self:IsAFK() or self.prefabname == "" or (self.ishost and not TheNet:GetServerIsClientHosted())
end


--[[function PlayerBadge:GetAvatarAtlas()
    if self.is_mod_character and not (self.prefabname == "" or self:IsAFK()) then
        local location = MOD_AVATAR_LOCATIONS["Default"]
        if MOD_AVATAR_LOCATIONS[self.prefabname] ~= nil then
            location = MOD_AVATAR_LOCATIONS[self.prefabname]
        end

        local starting = self:IsGhost() and "avatar_ghost_" or "avatar_"
        local ending =
            (self:IsCharacterState1() and "_1" or "")..
            (self:IsCharacterState2() and "_2" or "")..
            (self:IsCharacterState3() and "_3" or "")

        return location..starting..self.prefabname..ending..".xml"
    end
    return DEFAULT_ATLAS
end]]

function PlayerBadge:GetAvatarImage()
    if self.ishost and self.prefabname == "" and not TheNet:GetServerIsClientHosted() then
        return "avatar_server.tex"
    elseif self.prefabname == "" then
        return self.is_mod_character and "avatar_mod.tex" or "avatar_unknown.tex"
    elseif self:IsAFK() then
        return "avatar_afk.tex"
    end

    return DEFAULT_AVATAR

    --[[local starting = self:IsGhost() and "avatar_ghost_" or "avatar_"
    local ending =
        (self:IsCharacterState1() and "_1" or "")..
        (self:IsCharacterState2() and "_2" or "")..
        (self:IsCharacterState3() and "_3" or "")

    return self.prefabname ~= ""
        and (starting..self.prefabname..ending..".tex")
        or (starting.."unknown.tex")]]
end

return PlayerBadge
