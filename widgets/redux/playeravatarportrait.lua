local Image = require "widgets/image"
local PlayerBadge = require "widgets/playerbadge"
local Puppet = require "widgets/skinspuppet"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local Widget = require "widgets/widget"


local PlayerAvatarPortrait = Class(Widget, function(self)
    Widget._ctor(self, "PlayerAvatarPortrait")

    self.badge = self:AddChild(PlayerBadge("", DEFAULT_PLAYER_COLOUR, false, 0))
    self.badge:Hide()

    self.puppet_root = self:AddChild(Widget("puppet_root"))

    self.frame = self.puppet_root:AddChild(Widget("frame"))
    self.frame.bg = self.frame:AddChild(Image(GetPlayerPortraitAtlasAndTex()))
    self.frame:SetScale(.45)

    self.puppet = self.puppet_root:AddChild(Puppet())
    self.puppet:SetScale(1.5)
    self.puppet:SetClickable(false)
    self.puppet:SetPosition(0, -70)
    self.puppet:AddShadow()

    self.rank = self.puppet_root:AddChild(TEMPLATES.RankBadge())
    self.rank:SetPosition(-65, 20)
    self.rank:SetScale(0.6)
    self.should_show_rank_badge = true

    self.should_show_level = IsAnyFestivalEventActive()
    
    if self:_ShouldHideRankBadge() then
        self:HideVanityItems()
	end

    self.playername = self:AddChild(Text(CHATFONT_OUTLINE, 24))
    self.playername:SetPosition(0, -120)
    self.playername:SetHAlign(ANCHOR_MIDDLE)
end)

function PlayerAvatarPortrait:AlwaysHideRankBadge()
    self.should_show_rank_badge = false
    self.rank:Hide()
end

function PlayerAvatarPortrait:_ShouldHideRankBadge()
    return not self.should_show_rank_badge or TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()
end

function PlayerAvatarPortrait:HideVanityItems()
    self.rank:Hide()
    self.frame:Hide()
end

function PlayerAvatarPortrait:SetBackground(item_key)
    self.frame.bg:SetTexture(GetPlayerPortraitAtlasAndTex(item_key))
end

function PlayerAvatarPortrait:SetRank(profileflair, rank)
    if not self.should_show_level then
        -- Don't hide level manually, pass invalid so RankBadge handles hiding.
        rank = nil
    end
    self.rank:SetRank(profileflair, rank)
	if self:_ShouldHideRankBadge() then
		self.rank:Hide()
	else
		self.rank:Show()
	end
end

function PlayerAvatarPortrait:ClearBackground()
    self.frame.bg:SetTexture(GetPlayerPortraitAtlasAndTex())
end

function PlayerAvatarPortrait:SetEmpty()
    self.badge:Set("", DEFAULT_PLAYER_COLOUR, false, 0)
    self.badge:Show()
    self.puppet_root:Hide()

    self.playername:SetColour(DEFAULT_PLAYER_COLOUR)
    self.playername:SetString(STRINGS.UI.LOBBYSCREEN.EMPTY_SLOT)
	self.lobbycharacter = nil

    self:ClearBackground()
end

function PlayerAvatarPortrait:UpdatePlayerListing(player_name, colour, prefab, base_skin, clothing, playerportrait, profileflair, rank)
    if playerportrait then
        self:SetBackground(playerportrait)
    else
        self:ClearBackground()
    end
    -- profileflair may be null if user has none selected.
    -- rank may be null/invalid outside of events.
    self:SetRank(profileflair, rank)
    if prefab == "" then
        self.badge:Set("", colour or DEFAULT_PLAYER_COLOUR, false, 0)
        self.badge:Show()
        self.puppet_root:Hide()
        self.lobbycharacter = nil
    elseif prefab == "random" then
        self.badge:Set("random", DEFAULT_PLAYER_COLOUR, false, 0)
        self.badge:Show()
        self.puppet_root:Hide()
        self.lobbycharacter = prefab
    else
        self.lobbycharacter = prefab

        self.badge:Hide()

        local skip_change_emote = true
        self.puppet:SetSkins(prefab, base_skin, clothing, skip_change_emote)
        self.puppet_root:Show()
    end

    self.playername:SetColour(colour or DEFAULT_PLAYER_COLOUR)
    self.playername:SetString(player_name)
end


-- adapters to allow PlayerAvatarPortrait to operate like a Puppet.
function PlayerAvatarPortrait:SetSkins(prefabname, base_skin, clothing_names)
    self:UpdatePlayerListing(nil, nil, prefabname, base_skin, clothing_names)
end
function PlayerAvatarPortrait:EmoteUpdate(dt)
    self.puppet:EmoteUpdate(dt)
end
-- /adapters

function PlayerAvatarPortrait:DoNotAnimate()
    self.puppet.animstate:Pause()
	self.puppet.enable_idle_emotes = false
end

return PlayerAvatarPortrait
