local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/templates"

local UserCommands = require "usercommands"

local REFRESH_INTERVAL = 0.5

local MIN_HEIGHT = 20
local TITLE_HEIGHT = 46
local SUBTITLE_HEIGHT = 22
local BUTTON_HEIGHT = 30
local CANCEL_OFFSET = 16

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

    --throw up the background
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(-90, 270, 0.75, 0.75, 50, -31))
    self.bg:SetPosition(-5,-7)
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.bg.fill:SetSize(246, 345)
    self.bg.fill:SetPosition(1, 4)

    --title
    self.title = self.proot:AddChild(Text(UIFONT, 34))
    --self.title:SetRegionSize(226, 38)
    --self.title:SetColour(0,0,0,1)
    self.subtitle = self.proot:AddChild(Text(NEWFONT_OUTLINE_SMALL, 16))
    --self.subtitle:SetColour(0,0,0,1)
    if self.targetuserid ~= nil then
        local client = TheNet:GetClientTableForUser(self.targetuserid)
        self.title:SetTruncatedString(client ~= nil and client.name or "", 226, 50, true)
        self.subtitle:SetString(STRINGS.UI.COMMANDSSCREEN.USERSUBTITLE)
    else
        self.title:SetTruncatedString(STRINGS.UI.COMMANDSSCREEN.SERVERTITLE, 226, 50, true)
        self.subtitle:SetString(STRINGS.UI.COMMANDSSCREEN.SERVERSUBTITLE)
    end

    self:UpdateActions()

    local height = MIN_HEIGHT + SUBTITLE_HEIGHT + TITLE_HEIGHT
    local max_height = MIN_HEIGHT + SUBTITLE_HEIGHT + TITLE_HEIGHT
    local list_height = 0

    self.buttons = {}
    for i,action in ipairs(self.actions) do
        local text =
            (action.exectype == COMMAND_RESULT.VOTE or action.exectype == COMMAND_RESULT.DENY) and
            string.format(STRINGS.UI.COMMANDSSCREEN.VOTEFMT, action.prettyname) or
            action.prettyname
        local button = self:AddChild(ImageButton("images/frontend.xml", "button_xlong.tex", "button_xlong_halfshadow.tex", "button_xlong_disabled.tex", "button_xlong_halfshadow.tex", "button_xlong_disabled.tex"))
        button:SetFont(NEWFONT)
        button.text:SetColour(0,0,0,1)
        button:SetTextSize(40)
        button:SetScale(0.5)
        button.text:SetTruncatedString(text, 350, 58, true)
        button:SetText(button.text:GetString())
        --Max out the region size for triggering the hover text
        button.text:SetRegionSize(370, 48)

        button:SetOnClick(function() TheFrontEnd:PopScreen() self:RunAction(action.commandname) end)

        button.commandname = action.commandname

        table.insert(self.buttons, button)

        list_height = list_height + BUTTON_HEIGHT
    end

    local shown_buttons = 7
    local max_list_height = BUTTON_HEIGHT * shown_buttons
    list_height = math.min(list_height, max_list_height)

    height = height + list_height
    max_height = max_height + max_list_height

    self.scroll_list = self.proot:AddChild(ScrollableList(self.buttons, 210, list_height, BUTTON_HEIGHT, 0, nil, nil, #self.buttons > shown_buttons and 95 or 105, nil, nil, 8))
    self.default_focus = self.scroll_list

    if not TheInput:ControllerAttached() then
        self.cancelbutton = self.proot:AddChild(ImageButton("images/frontend.xml" ,"button_xlong.tex", "button_xlong_halfshadow.tex", "button_xlong_disabled.tex", "button_xlong_halfshadow.tex", "button_xlong_disabled.tex"))
        self.cancelbutton:SetFont(NEWFONT)
        self.cancelbutton.text:SetColour(0,0,0,1)
        self.cancelbutton:SetTextSize(40)
        self.cancelbutton:SetText(STRINGS.UI.COMMANDSSCREEN.CANCEL)
        self.cancelbutton:SetScale(0.5)
        self.cancelbutton:SetOnClick(function() TheFrontEnd:PopScreen() end)
        height = height + BUTTON_HEIGHT + CANCEL_OFFSET
        max_height = max_height + BUTTON_HEIGHT + CANCEL_OFFSET
    end

    local top = (height/2 + max_height/2)/2
    self.subtitle:SetPosition(0, top - SUBTITLE_HEIGHT/2, 0)
    top = top - SUBTITLE_HEIGHT
    self.title:SetPosition(0, top - TITLE_HEIGHT/2, 0)
    top = top - TITLE_HEIGHT

    self.scroll_list:SetPosition(#self.buttons > shown_buttons and -5 or 0, top - (list_height/2))
    top = top - list_height
    if self.cancelbutton then
        local bottom = (-max_height/2)+BUTTON_HEIGHT
        self.cancelbutton:SetPosition(#self.buttons > shown_buttons and -15 or 0, bottom, 0) -- note: max_height, not max_top, to push it downwards
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

    table.sort(self.actions, function(a,b) return a.prettyname < b.prettyname end)
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
                if TheInput:ControllerAttached() then
                    button:Disable()
                else
                    button:Select()
                end
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
                if TheInput:ControllerAttached() then
                    button:Disable()
                else
                    button:Select()
                end
            else
                button:ClearHoverText()
                if TheInput:ControllerAttached() then
                    button:Enable()
					-- this is the first active widget we've come across so set it as focus
                    if nil == self.force_focus_button then
                        self.force_focus_button = button
                        force_focus = true
                    end
                else
                    button:Unselect()
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
