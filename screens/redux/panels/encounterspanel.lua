
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local TEMPLATES = require "widgets/redux/templates"

local units_per_row = 2
local num_rows = math.ceil(19 / units_per_row)

local dialog_size_x = 830
local dialog_width = dialog_size_x + (60*2) -- nineslice sides are 60px each
local row_height = 30 * units_per_row
local row_width = dialog_width*0.9
local dialog_size_y = row_height*(num_rows + 0.25)


local EncountersPanel = Class(Widget, function(self)
    Widget._ctor(self, "EncountersPanel")

    self.player_history = PlayerHistory:GetRows()
	self.can_view_profile = not IsPS4()

	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0,0)

	self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    self.dialog:SetPosition(0, 10)

	self:DoInit()
    self.encounters_scroll_list:SetPosition(-15, 0)

    self.focus_forward = self.encounters_scroll_list
end)

local function get_character_icon(character)
    local atlas = "images/saveslot_portraits"
    if not table.contains(DST_CHARACTERLIST, character) then
        if table.contains(MODCHARACTERLIST, character) then
            atlas = atlas.."/"..character
        else
            character = #character > 0 and "mod" or "unknown"
        end
    end
    return atlas..".xml", character..".tex"
end

local function BuildCharacterPortrait(name)
    local portrait_scale = 0.25 * units_per_row
    local base = Widget(name)
    base:SetScale(portrait_scale, portrait_scale, 1)

    base.portraitbg = base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    base.portraitbg:SetClickable(false)
    base.portrait = base:AddChild(Image())
    base.portrait:SetClickable(false)

    base.SetCharacter = function(self, character)
        if character ~= nil then
            self.portrait:SetTexture(get_character_icon(character))
            self:Show()
        else
            self:Hide()
        end
    end

    return base
end

local function ecounter_widget_constructor(context, i)
	local top_y = -12

	local w = Widget("control-encounter")
	w.root = w:AddChild(Widget("encounter-hideable_root"))

	local bg = w.root:AddChild(TEMPLATES.ListItemBackground(row_width, row_height))
	bg:SetOnGainFocus(function() context.screen.encounters_scroll_list:OnWidgetFocus(w) end)

	w.widgets = w.root:AddChild(Widget("encounter-data_root"))
	w.widgets:SetPosition(-row_width/2, 0)

	local spacing = 15
	local x = spacing

    w.widgets.character = w.widgets:AddChild(BuildCharacterPortrait("character"))
	x = x + row_height/2
    w.widgets.character:SetPosition(x , 0)
	x = x + row_height/2 + spacing

	w.widgets.playername = w.widgets:AddChild(Text(HEADERFONT, 26))
	w.widgets.playername:SetColour(UICOLOURS.GOLD)
	w.widgets.playername._position = { x = x, y = 10, w = 400 }

    w.widgets.desc = w.widgets:AddChild(Text(CHATFONT, 22))
    w.widgets.desc:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	w.widgets.desc._position = { x = x, y = -13, w = 570 }

	local button_x = row_width - spacing - 20
    w.widgets.playerinfo_btn = w.widgets:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, false, false,
        function()
            if w.widgets.playerinfo_btn._netid ~= nil then
                TheNet:ViewNetProfile(w.widgets.playerinfo_btn._netid)
            end
        end,
        {
            offset_x = 0,
            offset_y = 20,
	    }))
    w.widgets.playerinfo_btn:SetPosition(button_x, 14)
    w.widgets.playerinfo_btn:SetScale(.5)
    w.widgets.playerinfo_btn:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE)

    w.widgets.delete_btn = w.widgets:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "delete.tex", STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR, false, false,
        function()
            PlayerHistory:RemoveUser(w.widgets.delete_btn._userid)

			context.screen.player_history = PlayerHistory:GetRows()
			context.screen.encounters_scroll_list:SetItemsData( context.screen.player_history )
        end,
        {
            offset_x = 0,
            offset_y = 20,
		}))
    w.widgets.delete_btn:SetPosition(button_x, -14)
    w.widgets.delete_btn:SetScale(.5)
    w.widgets.delete_btn:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR)

	if TheInput:ControllerAttached() then
		-- force an overlay so we can actually tell what's selected'
		bg:UseFocusOverlay("serverlist_listitem_hover.tex")

		-- hide the buttons since we're not mousing'
		w.widgets.delete_btn:Hide()
		w.widgets.playerinfo_btn:Hide()

		-- add help text for controller button commands
		w.GetHelpText = function()
			local controller_id = TheInput:GetControllerID()
			local t = {}
			if TheInput:ControllerAttached() then
				if context.screen.can_view_profile and w.widgets.playerinfo_btn._netid ~= nil then
					table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MAP) .. " " .. STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE)
				end

                if w.widgets.delete_btn._userid ~= nil then
                    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR)
                end
			end

			return table.concat(t, "  ")
		end

		-- add controller button handlers
		w.OnControl = function(self, control, down)
			if context.screen._base.OnControl(self, control, down) then return true end

			if TheInput:ControllerAttached() and not down then
				if control == CONTROL_MAP and context.screen.can_view_profile and w.widgets.playerinfo_btn._netid ~= nil then
					TheNet:ViewNetProfile(w.widgets.playerinfo_btn._netid)
					return true
				end

                if control == CONTROL_MENU_MISC_2 then
                    if w.widgets.delete_btn._userid ~= nil then
                        PlayerHistory:RemoveUser(w.widgets.delete_btn._userid)
                    end
					context.screen.player_history = PlayerHistory:GetRows()
					context.screen.encounters_scroll_list:SetItemsData( context.screen.player_history )
					return true
				end
			end
		end

		button_x = button_x + 20
	else
		if context.screen.can_view_profile then
			bg:SetFocusChangeDir(MOVE_RIGHT, w.widgets.playerinfo_btn)

			w.widgets.playerinfo_btn:SetFocusChangeDir(MOVE_LEFT, bg)
			w.widgets.playerinfo_btn:SetFocusChangeDir(MOVE_DOWN, w.widgets.delete_btn)

			w.widgets.delete_btn:SetFocusChangeDir(MOVE_LEFT, bg)
			w.widgets.delete_btn:SetFocusChangeDir(MOVE_UP, w.widgets.playerinfo_btn)
		else
			bg:SetFocusChangeDir(MOVE_RIGHT, w.widgets.playerinfo_btn)
			w.widgets.delete_btn:SetFocusChangeDir(MOVE_LEFT, bg)

			w.widgets.playerinfo_btn:Hide()
		end

		button_x = button_x - spacing - 20
	end

    w.widgets.playtime_label = w.widgets:AddChild(Text(CHATFONT, 22))
    w.widgets.playtime_label:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	w.widgets.playtime_label._position = { x = button_x, y = 12, w = 300 }

    w.widgets.playtime = w.widgets:AddChild(Text(CHATFONT, 22))
    w.widgets.playtime:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	w.widgets.playtime._position = { x = button_x, y = -13, w = 125 }

    local function SequenceFocusHorizontal(left, right)
        left:SetFocusChangeDir(MOVE_RIGHT, right)
        right:SetFocusChangeDir(MOVE_LEFT, left)
    end

	w.focus_forward = bg

	return w
end

local function SetTruncatedLeftJustifiedString(txt, str)
	txt:SetTruncatedString(str or "", txt._position.w, nil, true)
	local width, height = txt:GetRegionSize()
	txt:SetPosition(txt._position.x + width/2, txt._position.y)
end

local function SetTruncatedRightJustifiedString(txt, str)
	txt:SetTruncatedString(str or "", txt._position.w, nil, true)
	local width, height = txt:GetRegionSize()
	txt:SetPosition(txt._position.x - width/2, txt._position.y)
end

local function encounter_widget_update(context, w, data, index)
    if w == nil then
        return
    elseif data == nil then
        w.root:Hide()
        return
    else
        w.root:Show()

		w.widgets.character:SetCharacter(data.prefab)

		SetTruncatedLeftJustifiedString(w.widgets.playername, data.name or "")

		local data_str = data.last_seen_date ~= nil and str_date(data.last_seen_date) or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS -- todo: make this localization friendly
		local filtered_text = ApplyLocalWordFilter(data.server_name, TEXT_FILTER_CTX_SERVERNAME)
		SetTruncatedLeftJustifiedString(w.widgets.desc, subfmt(STRINGS.UI.MORGUESCREEN.ENCOUNTERS.DESC, {date = data_str, server_name = ServerPreferences:IsNameAndDescriptionHidden(data.server_name) and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or filtered_text or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS}))

		if data.time_played_with > 0 then
			w.widgets.playtime_label:Show()
			w.widgets.playtime:Show()
			SetTruncatedRightJustifiedString(w.widgets.playtime_label, STRINGS.UI.MORGUESCREEN.ENCOUNTERS.PLAYTIME_LABEL)
			SetTruncatedRightJustifiedString(w.widgets.playtime, str_play_time(math.max(data.time_played_with, 60)))
		else
			w.widgets.playtime_label:Hide()
			w.widgets.playtime:Hide()
		end

		w.widgets.playerinfo_btn._netid = data.netid
		if TheNet:IsNetIDPlatformValid(data.netid) then
			w.widgets.playerinfo_btn:Unselect()
		else
			w.widgets.playerinfo_btn:Select()
		end
		w.widgets.delete_btn._userid = data.userid
    end
end

function EncountersPanel:DoInit()
    self.encounters_scroll_list = self.root:AddChild(TEMPLATES.ScrollingGrid(
            self.player_history,
            {
                scroll_context = {
                    screen = self,
                },
                widget_width  = row_width,
                widget_height = row_height,
                num_visible_rows = num_rows,
                num_columns = 1,
                item_ctor_fn = ecounter_widget_constructor,
                apply_fn = encounter_widget_update,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60
            }))

end

return EncountersPanel







