
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"

local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local AchievementsPopup = require "screens/redux/achievementspopup"
local CreditsScreen = require "screens/creditsscreen"
local MovieDialog = require "screens/moviedialog"
local PopupDialogScreen = require "screens/popupdialog"

local TEMPLATES = require "widgets/redux/templates"

local HistoryOfTravelsPanel = Class(Widget, function(self, parent_screen)
    Widget._ctor(self, "CinematicsPanel")

	self.parent_screen = parent_screen

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0, 0)

    self.death = self.root:AddChild(self:_BuildMostCommonDeaths())
	self.death:SetPosition(-200, 200)

    self.friends = self.root:AddChild(self:_BuildMostCommonFriends())
	self.friends:SetPosition(200, 200)

    self.festival_history = self.root:AddChild(self:_BuildFestivalHistory())
	self.festival_history:SetPosition(0, -20)


    self.focus_forward = self.festivals_badges[1]
	self:_DoFocusHookups()
end)

function HistoryOfTravelsPanel:_DoFocusHookups()
    if self.festivals_badges ~= nil then
        for i,_ in pairs(self.festivals_badges) do
            self.festivals_badges[i]:SetFocusChangeDir(MOVE_UP, self.festivals_badges[i-1])
            self.festivals_badges[i]:SetFocusChangeDir(MOVE_LEFT, self.menu)
            self.festivals_badges[i]:SetFocusChangeDir(MOVE_DOWN, self.festivals_badges[i+1])
        end
    end
end

function HistoryOfTravelsPanel:_BuildMostCommonDeaths()
    local death_root = self.root:AddChild(Widget("death_root"))

	local death_label = death_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.MOST_COMMON_DEATH, UICOLOURS.GOLD_SELECTED))
    death_label:SetPosition(0,0)

	local death_divider_top = death_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    death_divider_top:SetScale(0.5)
    death_divider_top:SetPosition(0, -15)

    local total_deaths = 0
    local cause_of_death = {}
    local morgue = Morgue:GetRows()
    for i,data in ipairs(morgue) do
        if data and data.character and data.days_survived and data.location and data.killed_by and (data.world or data.server) then
            local killed_by = GetKilledByFromMorgueRow(data)
            local prev_deaths = cause_of_death[killed_by] or 0
            cause_of_death[killed_by] = prev_deaths + 1
            total_deaths = total_deaths + 1
        end
    end

    local causes = table.getkeys(cause_of_death)
	if #causes > 0 then
		table.sort(causes, function(a,b)
			local a_deaths = cause_of_death[a] or 0
			local b_deaths = cause_of_death[b] or 0
			return a_deaths > b_deaths
		end)

		if #causes > 4 then
			local base = 0
			for i = 1, 3 do
				base = base + cause_of_death[ causes[i] ]
			end

			cause_of_death[ STRINGS.UI.COMPENDIUM.CAUSEOFDEATH_OTHER ] = total_deaths - base
			causes[4] = STRINGS.UI.COMPENDIUM.CAUSEOFDEATH_OTHER
		end

		local label_root = death_root:AddChild(Widget("labels"))

		local label_w = 0
		for i = 1, math.min(#causes, 4) do
			local y = -15-(i * 30)
			local txt = label_root:AddChild(Text(CHATFONT, 25, "", UICOLOURS.GREY))
			txt:SetHAlign(ANCHOR_LEFT)

			txt:SetTruncatedString(causes[i], 220, nil, true)

			local w, h = txt:GetRegionSize()
			txt:SetPosition(w/2, y)
			label_w = math.max(label_w, w)
		end

		local percent_root = death_root:AddChild(Widget("percents"))
		local percent_w = 0
		for i = 1, math.min(#causes, 4) do
			local y = -15-(i * 30)
			local percent = string.format("%0.1f%%", cause_of_death[ causes[i] ] / total_deaths * 100)
			local txt = percent_root:AddChild(Text(CHATFONT, 25, percent, UICOLOURS.GREY))
			txt:SetHAlign(ANCHOR_RIGHT)

			local w, h = txt:GetRegionSize()
			txt:SetPosition(-w/2, y)
			percent_w = math.max(percent_w, w)
		end

		local spacing = 20
		local totalwidth = label_w + percent_w + spacing
		label_root:SetPosition(-totalwidth/2, 0)
		percent_root:SetPosition(totalwidth/2, 0)
	else
		local txt = death_root:AddChild(Text(CHATFONT, 24, STRINGS.UI.PLAYERSUMMARYSCREEN.NO_DEATHS, UICOLOURS.GREY))
		txt:SetPosition(0, -45)
	end


    return death_root
end

function HistoryOfTravelsPanel:_BuildMostCommonFriends()
    local friend_root = self.root:AddChild(Widget("friend_root"))

	local friend_label = friend_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.MOST_COMMON_FRIENDS, UICOLOURS.GOLD_SELECTED))
    friend_label:SetPosition(0, 0)

	local friend_divider_top = friend_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    friend_divider_top:SetScale(0.5)
    friend_divider_top:SetPosition(0, -15)

	local friends = PlayerHistory:GetRowsMostTime()
    if friends ~= nil and #friends > 0 then
		for i = 1, math.min(4, #friends) do
			local txt = friend_root:AddChild(Text(CHATFONT, 30, "", UICOLOURS.GREY))
			txt:SetTruncatedString(friends[i].name, 300, nil, true)
			txt:SetPosition(0, -15-(i * 30))
		end
    else
		local txt = friend_root:AddChild(Text(CHATFONT, 24, STRINGS.UI.PLAYERSUMMARYSCREEN.NO_FRIENDS, UICOLOURS.GREY))
		txt:SetPosition(0, -45)
    end

    return friend_root
end

local function PushWaitingPopup()
    local event_wait_popup = GenericWaitingPopup("ItemServerContactPopup", STRINGS.UI.ITEM_SERVER.CONNECT, nil, false)
    TheFrontEnd:PushScreen(event_wait_popup)
    return event_wait_popup
end

function HistoryOfTravelsPanel:_BuildFestivalHistoryButton(festival_key, season)
    local function onclick()
        local event_wait_popup = PushWaitingPopup()
        wxputils.GetEventStatus(festival_key, season, function(success)
            self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                event_wait_popup:Close()

                if success then
                    local screen = AchievementsPopup(self.prev_screen, festival_key, season)
                    TheFrontEnd:PushScreen(screen)
                else
                    local ok_scr = PopupDialogScreen( STRINGS.UI.PLAYERSUMMARYSCREEN.FESTIVAL_HISTORY, STRINGS.UI.ITEM_SERVER.FAILED_DEFAULT,
					{
						{text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function()
							TheFrontEnd:PopScreen()
						end },
					})
                    TheFrontEnd:PushScreen(ok_scr)
                end
            end, self)
        end)
    end

    local festival_title = STRINGS.UI.FESTIVALEVENTSCREEN.TITLE[string.upper(festival_key) .. (season > 1 and tostring(season) or "")]
	local w = TEMPLATES.StandardButton(onclick, festival_title, {225,40})

    return w
end

function HistoryOfTravelsPanel:_BuildFestivalHistory()
    local festivals_root = self.root:AddChild(Widget("festivals_root"))

    self.festivals_label = festivals_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.FESTIVAL_HISTORY, UICOLOURS.GOLD_SELECTED))
    self.festivals_label:SetPosition(0, 0)
    self.festivals_divider_top = festivals_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    self.festivals_divider_top:SetScale(0.5)
    self.festivals_divider_top:SetPosition(0, -15)

    self.festivals_badges = {}
	for i, eventinfo in ipairs(PREVIOUS_FESTIVAL_EVENTS_ORDER) do
        table.insert(self.festivals_badges, festivals_root:AddChild(self:_BuildFestivalHistoryButton(eventinfo.id, eventinfo.season)))
        self.festivals_badges[#self.festivals_badges]:SetPosition(0, -10 - i*40)
	end

    return festivals_root
end


return HistoryOfTravelsPanel
