local Image = require "widgets/image"
local Widget = require "widgets/widget"

local DEFAULT_ATLAS = "images/avatars.xml"
local DEFAULT_AVATAR = "avatar_unknown.tex"

local PlayerBadge = Class(Widget, function(self, prefab, colour, ishost, userflags)
    Widget._ctor(self, "PlayerBadge")
    self.isFE = false
    self:SetClickable(false)

    self.root = self:AddChild(Widget("root"))
    -- self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.icon = self.root:AddChild(Widget("target"))
    self.icon:SetScale(.8)

    if table.contains(DST_CHARACTERLIST, prefab) then
        self.prefabname = prefab
        self.is_mod_character = false
    elseif table.contains(MODCHARACTERLIST, prefab) then
        self.prefabname = prefab
        self.is_mod_character = true
    else
        self.prefabname = ""
        self.is_mod_character = (prefab ~= nil and #prefab > 0)
    end

    self.ishost = ishost
    self.userflags = userflags

    self.headbg = self.icon:AddChild(Image(DEFAULT_ATLAS, self:GetBG()))
    self.head = self.icon:AddChild(Image( self:GetAvatarAtlas(), self:GetAvatar(), DEFAULT_AVATAR ))

	self.loading_icon = self.icon:AddChild(Image(DEFAULT_ATLAS, "loading_indicator.tex"))
	self.loading_icon:Hide()

    self.headframe = self.icon:AddChild(Image(DEFAULT_ATLAS, "avatar_frame_white.tex"))
    self.headframe:SetTint(unpack(colour))
end)

function PlayerBadge:Set(prefab, colour, ishost, userflags)
    self.headframe:SetTint(unpack(colour))

    local dirty = false

    if self.ishost ~= ishost then
        self.ishost = ishost
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
        self.head:SetTexture(self:GetAvatarAtlas(), self:GetAvatar(), DEFAULT_AVATAR)
    end

	if self:IsLoading() then
		if not self.loading_icon.shown then
			self.loading_icon:Show()
			local function dorotate() self.loading_icon:RotateTo(0, -360, 1, dorotate) end
			self.loading_icon:CancelRotateTo()
			dorotate()
			self.head:SetTint(0,0,0,1)
		end
	else
		if self.loading_icon.shown then
			self.loading_icon:Hide()
			self.loading_icon:CancelRotateTo()
			self.head:SetTint(1,1,1,1)
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

function PlayerBadge:GetAvatarAtlas()
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
end

function PlayerBadge:GetAvatar()
    if self.ishost and self.prefabname == "" and not TheNet:GetServerIsClientHosted() then
        return "avatar_server.tex"
    elseif self.prefabname == "" then
        return self.is_mod_character and "avatar_mod.tex" or "avatar_unknown.tex"
    elseif self:IsAFK() then
        return "avatar_afk.tex"
    end

    local starting = self:IsGhost() and "avatar_ghost_" or "avatar_"
    local ending =
        (self:IsCharacterState1() and "_1" or "")..
        (self:IsCharacterState2() and "_2" or "")..
        (self:IsCharacterState3() and "_3" or "")

    return self.prefabname ~= ""
        and (starting..self.prefabname..ending..".tex")
        or (starting.."unknown.tex")
end

return PlayerBadge
