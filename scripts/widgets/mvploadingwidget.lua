local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local LobbyChatQueue = require "widgets/lobbychatqueue"
local PlayerBadge = require "widgets/playerbadge"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/redux/templates"

local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"

--------------------------------------------------------------------------
--
--

local MVPLoadingWidget = Class(Widget, function(self)
    Widget._ctor(self, "MVPLoadingWidget")

    self.list_root = self:AddChild(Widget("list_root"))

	self.mvp_widgets = {}
	self.total_width = 0
    self.current_eventid = string.upper(TheNet:GetServerGameMode())

	self:SetClickable(false)
end)

local function UpdatePlayerListing(widget, data)
    local empty = data == nil or next(data) == nil

    widget.userid = not empty and data.user.userid or nil
    widget.performance = not empty and data.user.performance or nil

    if empty then
		widget.badge:Hide()
        widget.puppet:Hide()
    else
        local prefab = data.user.lobbycharacter or data.user.prefab or ""
        if prefab == "" then
			widget.badge:Set(prefab, DEFAULT_PLAYER_COLOUR, false, 0)
			widget.badge:Show()
			widget.puppet:Hide()
		else
			widget.badge:Hide()
			widget.puppet:SetSkins(prefab, data.user.base, data.user, true)
			widget.puppet:SetBackground(data.user.portrait)
			widget.puppet:Show()
		end
    end

    widget.playername:SetColour(unpack(not empty and data.user.colour or DEFAULT_PLAYER_COLOUR))
    widget.playername:SetTruncatedString((not empty) and data.user.name or "", 200, nil, "...")

    widget.fake_rand = not empty and data.user.colour ~= nil and (data.user.colour[1] + data.user.colour[2] + data.user.colour[3]) / 3 or .5
end

function MVPLoadingWidget:PopulateData()
	local mvp_cards = Settings.match_results.mvp_cards or TheFrontEnd.match_results.mvp_cards

	self.list_root:KillAllChildren()
	self.mvp_widgets = {}

	local card_anims = {{"emoteXL_waving1", 0.5}, {"emote_loop_sit4", 0.5}, {"emoteXL_loop_dance0", 0.5}, {"emoteXL_happycheer", 0.5}, {"emote_loop_sit1", 0.5}, {"emote_strikepose", 0.25}}

	if mvp_cards ~= nil and #mvp_cards > 0 then
		-- build the required widgets
		for _, data in ipairs(mvp_cards) do
			local widget = self.list_root:AddChild(Widget("playerwidget"))

			local backing = widget:AddChild(Image("images/global_redux.xml", "mvp_panel.tex"))
			backing:SetPosition(0, 30)
			backing:SetScale(0.85, 1)

			widget.badge = widget:AddChild(PlayerBadge("", DEFAULT_PLAYER_COLOUR, false, 0))

			widget.puppet = widget:AddChild(PlayerAvatarPortrait())
			widget.puppet:SetScale(1.25)
			widget.puppet:SetPosition(0, 140)
			widget.puppet:SetClickable(false)
			widget.puppet:AlwaysHideRankBadge() -- no space and mine is shown on XP bar
			local random_anim = math.floor((data.beststat[2] or 0) % #card_anims) + 1
			widget.puppet.puppet.animstate:SetBank("wilson")
			widget.puppet.puppet.animstate:SetPercent(card_anims[random_anim][1], card_anims[random_anim][2])
			table.remove(card_anims, random_anim)
			widget.puppet:DoNotAnimate()

			widget.playername = widget:AddChild(Text(TITLEFONT, 45))
			widget.playername:SetPosition(2, -38)
			widget.playername:SetHAlign(ANCHOR_LEFT)

			local line = widget:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
			line:SetScale(.8, .9)
			line:SetPosition(0, -67)
			local c = .6
			line:SetTint(UICOLOURS.GOLD[1]*c, UICOLOURS.GOLD[2]*c, UICOLOURS.GOLD[3]*c, UICOLOURS.GOLD[4])

			widget.title = widget:AddChild(Text(TITLEFONT, 40, STRINGS.UI.MVP_LOADING_WIDGET[self.current_eventid].TITLES[data.participation and "none" or data.beststat[1]], UICOLOURS.GOLD))
			widget.title:SetPosition(0, -98)

			widget.score = widget:AddChild(Text(CHATFONT, 45, tostring(data.beststat[2] or STRINGS.UI.MVP_LOADING_WIDGET[self.current_eventid].NO_STAT_VALUE), UICOLOURS.EGGSHELL))
			widget.score:SetPosition(0, -146)

			widget.description = widget:AddChild(Text(CHATFONT, 30, STRINGS.UI.MVP_LOADING_WIDGET[self.current_eventid].DESCRIPTIONS[data.beststat[1] or "none"], UICOLOURS.EGGSHELL))
			widget.description:SetPosition(0, -203)
			widget.description:SetRegionSize( 200, 66 )
			widget.description:SetVAlign(ANCHOR_TOP)
			widget.description:EnableWordWrap(true)

			UpdatePlayerListing(widget, data)

			table.insert(self.mvp_widgets, widget)
		end


		-- position the widgets
		local space = 255
		local offset = space * ((#self.mvp_widgets-1)/2)
		local y_offset = 25
		local rot_spacing = 4
		local rot_offset = rot_spacing * ((#self.mvp_widgets-1)/2)
		for i, widget in ipairs(self.mvp_widgets) do
			local x = (space * (i-1)) - offset
			local y = (widget.fake_rand * y_offset + y_offset) * (i%2==0 and 1 or -1)
			widget:SetPosition(x,y)
			widget:SetRotation((rot_spacing * (i-1)) - rot_offset + (widget.fake_rand * 2.5 - 1.25))
		end
	end
end

function MVPLoadingWidget:SetAlpha(a)
end

return MVPLoadingWidget
