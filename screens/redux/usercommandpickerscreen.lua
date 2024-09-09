local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/redux/templates"

local UserCommands = require "usercommands"

local REFRESH_INTERVAL = 0.5

local MIN_HEIGHT = 20
local TITLE_HEIGHT = 46
local SUBTITLE_HEIGHT = 22
local BUTTON_HEIGHT = 36
local CANCEL_OFFSET = 20

local DESC_FONT_SIZE = 22
local DESC_MAX_LINES = 3
local DESC_MAX_HEIGHT = DESC_FONT_SIZE * (DESC_MAX_LINES +  1)

local UserCommandPickerScreen = Class(Screen, function(self, owner, targetuserid, onclosefn)
    Screen._ctor(self, "UserCommandPickerScreen")
    self.owner = owner
    self.targetuserid = targetuserid
    self.onclosefn = onclosefn

    self.time_to_refresh = 0

    --darken everything behind the dialog
    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0,0,0,0) -- invisible, but clickable!
    self.black:SetOnClick(function() TheFrontEnd:PopScreen() end)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)


    local bg_root = self.proot:AddChild(Widget("bg_root"))
    bg_root:SetScale(.8, .8)

	local command_desc_text = self.proot:AddChild(Text(CHATFONT, DESC_FONT_SIZE, "", UICOLOURS.WHITE))

    self:UpdateActions()

    local height = MIN_HEIGHT + SUBTITLE_HEIGHT + TITLE_HEIGHT
    local max_height = MIN_HEIGHT + SUBTITLE_HEIGHT + TITLE_HEIGHT + BUTTON_HEIGHT + CANCEL_OFFSET + DESC_MAX_HEIGHT
    local list_height = 0
	local spacing = 5

	--self.actions = JoinArrays(self.actions, JoinArrays(self.actions, self.actions))

    self.buttons = {}
    for i,action in ipairs(self.actions) do
        local text =
            (action.exectype == COMMAND_RESULT.VOTE or action.exectype == COMMAND_RESULT.DENY) and
            string.format(STRINGS.UI.COMMANDSSCREEN.VOTEFMT, action.prettyname) or
            action.prettyname

        local button = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_xlong_normal.tex", "button_carny_xlong_hover.tex", "button_carny_xlong_disabled.tex", "button_carny_xlong_down.tex"))
        button.image:SetScale(1, 1.1)
        button:SetFont(CHATFONT)
        button.text:SetColour(0,0,0,1)
        button:SetTextSize(40)
        button:SetScale(0.5)
        button.text:SetTruncatedString(text, 350, 58, true)
        button:SetText(button.text:GetString())
        --Max out the region size for triggering the hover text
        button.text:SetRegionSize(370, 48)

        button:SetOnClick(function() TheFrontEnd:PopScreen() self:RunAction(action.commandname) end)
		button.ongainfocus = function(is_enabled)
			command_desc_text._command = action.commandname
			command_desc_text:SetMultilineTruncatedString(action.desc or "", DESC_MAX_LINES, 250)
		end
		button.onlosefocus = function(is_enabled)
			if command_desc_text._command == action.commandname then
				command_desc_text:SetString("")
				command_desc_text._command = nil
			end
		end

        button.commandname = action.commandname

        table.insert(self.buttons, button)

        list_height = list_height + BUTTON_HEIGHT + spacing
    end

    local shown_buttons = 5
    local max_list_height = (BUTTON_HEIGHT + spacing) * math.min(shown_buttons, #self.buttons)
    list_height = math.min(list_height, max_list_height)

    height = height + list_height
    max_height = max_height + max_list_height

	local x_offset = #self.buttons > shown_buttons and 15 or 0

    self.scroll_list = self.proot:AddChild(ScrollableList(self.buttons, 210, list_height, BUTTON_HEIGHT + spacing, 0, nil, nil, 105 - x_offset, nil, nil, 0, nil, .9, "GOLD"))
    self.default_focus = self.scroll_list

	local subtitle = self.targetuserid ~= nil and STRINGS.UI.COMMANDSSCREEN.USERSUBTITLE or STRINGS.UI.COMMANDSSCREEN.SERVERSUBTITLE
    self.bg = bg_root:AddChild(TEMPLATES.CurlyWindow(275, max_height, subtitle, nil, nil, STRINGS.UI.COMMANDSSCREEN.SERVERTITLE))
    self.bg:SetPosition(0, -10)
    self.bg.body:SetVAlign(ANCHOR_TOP)
    self.bg.body:SetSize(30)

    if self.targetuserid ~= nil then
	    self.bg.body:Hide()

        local client = TheNet:GetClientTableForUser(self.targetuserid)
        local body = self.bg.title.parent:AddChild(Text(CHATFONT, 45, "", UICOLOURS.WHITE))
        local pos = self.bg.title:GetLocalPosition() + Vector3(0, -45, 0)
        body:SetTruncatedString(client ~= nil and client.name or "", 226, 50, true)
	    body:SetPosition(pos)
    end

    if not TheInput:ControllerAttached() then
        self.cancelbutton = self.proot:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
        self.cancelbutton.image:SetScale(.8)
        self.cancelbutton:SetFont(CHATFONT)
        self.cancelbutton.text:SetColour(0,0,0,1)
        self.cancelbutton:SetTextSize(40)
        self.cancelbutton:SetText(STRINGS.UI.COMMANDSSCREEN.CANCEL)
        self.cancelbutton:SetScale(0.5)
        self.cancelbutton:SetOnClick(function() TheFrontEnd:PopScreen() end)
        height = height + BUTTON_HEIGHT + CANCEL_OFFSET
    end

    local top = (height/2 + max_height/2)/2
    --self.subtitle:SetPosition(0, top - SUBTITLE_HEIGHT/2, 0)
    top = top - SUBTITLE_HEIGHT
    --self.title:SetPosition(0, top - TITLE_HEIGHT/2, 0)
    top = top - TITLE_HEIGHT

    self.scroll_list:SetPosition(x_offset, top - (list_height/2))
    top = top - list_height

	command_desc_text:SetPosition(0, top - DESC_MAX_HEIGHT/2)

    if self.cancelbutton then
        local bottom = (-max_height/2)+BUTTON_HEIGHT
        self.cancelbutton:SetPosition(0, bottom) -- note: max_height, not max_top, to push it downwards
        top = top - CANCEL_OFFSET - BUTTON_HEIGHT
    end

    self.force_focus_button = nil
    self:RefreshButtons()
end)

function UserCommandPickerScreen:OnDestroy()
    if self.onclosefn ~= nil then
        self.onclosefn()
    end
    self._base.OnDestroy(self)
end

function UserCommandPickerScreen:UpdateActions()
    if self.targetuserid ~= nil then
        self.actions = UserCommands.GetUserActions(self.owner, self.targetuserid)
    else
        self.actions = UserCommands.GetServerActions(self.owner)
    end

    for i=#self.actions,1,-1 do
        if self.actions[i].commandname == "kick" or self.actions[i].commandname == "ban" then
            table.remove(self.actions, i)
        end
    end
    table.sort(self.actions, function(a,b) return (a.menusort or 100) < (b.menusort or 100) or (a.menusort == b.menusort and a.prettyname < b.prettyname) end)
end

function UserCommandPickerScreen:OnControl(control, down)
    if UserCommandPickerScreen._base.OnControl(self,control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen()
        return true
    end
end

function UserCommandPickerScreen:RefreshButtons()
    local worldvoter = TheWorld.net ~= nil and TheWorld.net.components.worldvoter or nil
    local playervoter = self.owner.components.playervoter

	-- we only want to force the focus to be set the first time we find an active widget, not on every refresh
    local force_focus = false
    for i,button in ipairs(self.buttons) do
        local action = nil
        for i,act in ipairs(self.actions) do
            if act.commandname == button.commandname then
                action = act
                break
            end
        end

        if action ~= nil then
            if action.exectype == COMMAND_RESULT.DISABLED then
                --we know canstart is false, but we want the reason
                local canstart, reason = UserCommands.CanUserStartCommand(action.commandname, self.owner, self.targetuserid)
                button:SetHoverText(reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.COMMANDCANNOTSTART[reason] or "")
                button:Select()
            elseif action.exectype == COMMAND_RESULT.DENY then
                if worldvoter == nil or playervoter == nil or not worldvoter:IsEnabled() then
                    --technically we should never get here (expected COMMAND_RESULT.INVALID)
                elseif worldvoter:IsVoteActive() then
                    button:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VOTEACTIVEHOVER)
                elseif playervoter:IsSquelched() then
                    button:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VOTESQUELCHEDHOVER)
                else
                    --we know canstart is false, but we want the reason
                    local canstart, reason = UserCommands.CanUserStartVote(action.commandname, self.owner, self.targetuserid)
                    button:SetHoverText(reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.VOTECANNOTSTART[reason] or "")
                end
                button:Select()
            else
                button:ClearHoverText()
                if TheInput:ControllerAttached() then
					-- this is the first active widget we've come across so set it as focus
                    if nil == self.force_focus_button then
                        self.force_focus_button = button
                        force_focus = true
                    end
                else
                    --button:Unselect()
                end
            end
        end
    end

	-- force the focus if necessary
    if force_focus and nil ~= self.force_focus_button then
        self.force_focus_button:SetFocus()
    end
end

function UserCommandPickerScreen:RunAction(name)
    if name == "toggle_servername" then
		ServerPreferences:ToggleNameAndDescriptionFilter()
		return
	end

	if self.actions == nil then
        return
    end

    local action = nil
    for i,act in ipairs(self.actions) do
        if act.commandname == name then
            action = act
            break
        end
    end

    if action ~= nil then
        UserCommands.RunUserCommand(action.commandname, self.targetuserid and {user=self.targetuserid} or {}, self.owner, false)
    end
end

function UserCommandPickerScreen:OnUpdate(dt)
    if TheFrontEnd:GetFadeLevel() > 0 then
        TheFrontEnd:PopScreen(self)
        return
    elseif self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
        return
    end

    self.time_to_refresh = REFRESH_INTERVAL
    self:UpdateActions()
    if #self.actions > 0 then
        self:RefreshButtons()
    else
        TheFrontEnd:PopScreen(self)
    end
end

function UserCommandPickerScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return UserCommandPickerScreen
