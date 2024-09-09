local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local ThreeSlice = require "widgets/threeslice"
local ControllerVoteScreen = require "screens/controllervotescreen"

--NOTE: some of these constants are copied to controllervotescreen.lua
--      (make sure to keep them in sync!)
local VOTE_ROOT_SCALE = .75
local LABEL_SCALE = .8
local BUTTON_SCALE = 1.2
local DROP_SPEED = -400
local DROP_ACCEL = 750
local UP_ACCEL = 2000
local BOUNCE_ABSORB = .25
local SETTLE_SPEED = 25

local CONTROLLER_POP_SPEED = .1
local CONTROLLER_OPEN_SCALE = .95
local CONTROLLER_OPEN_POS = Vector3(0, -56, 0)
local CONTROLLER_CLOSE_POS = Vector3(0, 0, 0)

local function empty()
end

local VoteDialog = Class(Widget, function(self, owner)
    Widget._ctor(self, "VoteDialog")

    self.owner = owner

    self.controller_mode = TheInput:ControllerAttached()
    self.controller_hint_delay = 0
    self.controllervotescreen = nil
    self.controllerselection = nil
    self.controllerscaling = 0

    self.root = self:AddChild(Widget("root"))
    self.root:SetScale(VOTE_ROOT_SCALE)

    self.dialogroot = self.root:AddChild(Widget("dialogroot"))

    self.bg = self.dialogroot:AddChild(ThreeSlice("images/ui.xml", "votewindow_top.tex", "votewindow_middle.tex", "votewindow_bottom.tex"))

    self.starter = self.dialogroot:AddChild(Text(TALKINGFONT, 35))

    self.title = self.dialogroot:AddChild(Text(BUTTONFONT, 35))
    self.title:SetColour(0, 0, 0, 1)

    self.timer = self.dialogroot:AddChild(Text(BUTTONFONT, 35))
    self.timer:SetColour(0, 0, 0, 1)

    self.instruction = self.dialogroot:AddChild(Text(TALKINGFONT, 28))
    self.instruction:SetScale(1 / VOTE_ROOT_SCALE)

    self.left_bar = self.dialogroot:AddChild(Image("images/ui.xml", "scrollbarline.tex"))
    self.left_bar:SetPosition(-75, 200)
    self.left_bar:SetTint(0, 0, 0, 1)
    self.left_bar:SetScale(1.5, 1, 1)
    self.left_bar:MoveToBack()

    self.right_bar = self.dialogroot:AddChild(Image("images/ui.xml", "scrollbarline.tex"))
    self.right_bar:SetPosition(75, 200)
    self.right_bar:SetTint(0, 0, 0, 1)
    self.right_bar:SetScale(-1.5, 1, 1)
    self.right_bar:MoveToBack()

    self.options_root = self.dialogroot:AddChild(Widget("root"))
    self.num_options = 0
    self.buttons = {}
    self.labels_desc = {}
    for i = 1, MAX_VOTE_OPTIONS do
        local desc = self.options_root:AddChild(Text(BUTTONFONT, 35))
        desc:SetColour(0, 0, 0, 1)
        desc:SetScale(LABEL_SCALE)
        desc:Hide()
        table.insert(self.labels_desc, desc)

        local closure_index = i
        local btn = self.options_root:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", "checkbox_off.tex", nil, { 1, 1 }, { 0, 0 }))
        btn:SetFont(BUTTONFONT)
        btn:SetScale(BUTTON_SCALE)
        btn:SetOnClick(function()
            if self.started and
                self.settled and
                self.owner ~= nil and
                self.owner.components.playervoter ~= nil then
                self.owner.components.playervoter:SubmitVote(closure_index)
            end
        end)
        btn:Hide()
        btn.GetHelpText = empty
        table.insert(self.buttons, btn)

        if i > 1 then
            btn:SetFocusChangeDir(MOVE_UP, self.buttons[i - 1])
            self.buttons[i - 1]:SetFocusChangeDir(MOVE_DOWN, btn)
        end
    end

    self.start_root_y_pos = 0
    self.target_root_y_pos = 0
    self.current_root_y_pos = 0
    self.current_speed = 0
    self.started = false
    self.settled = false
    self.canvote = false
    self:Hide()

    self.inst:ListenForEvent("showvotedialog", function(world, data) self:ShowDialog(data) end, TheWorld)
    self.inst:ListenForEvent("hidevotedialog", function() self:HideDialog() end, TheWorld)
    self.inst:ListenForEvent("worldvotertick", function(world, data) self:UpdateTimer(data.time) end, TheWorld)
    self.inst:ListenForEvent("votecountschanged", function(world, data) self:UpdateOptions(data) end, TheWorld)
    self.inst:ListenForEvent("playervotechanged", function(owner, data) self:UpdateSelection(data.selection, data.canvote) end, self.owner)
    self.inst:ListenForEvent("continuefrompause", function()
        self.controller_mode = TheInput:ControllerAttached()
        self:RefreshLayout()
    end, TheWorld)
end)

function VoteDialog:OnUpdate(dt)
    if self.controller_hint_delay > 0 and self.owner.HUD ~= nil and not self.owner.HUD:HasInputFocus() then
        self.controller_hint_delay = self.controller_hint_delay - dt
    end
    if self.started then
        if self.settled then
            self:RefreshController()
        else
            self.current_speed = self.current_speed - DROP_ACCEL * dt
            self.current_root_y_pos = self.current_root_y_pos + self.current_speed * dt
            if self.current_root_y_pos < self.target_root_y_pos then
                self.current_speed = -self.current_speed * BOUNCE_ABSORB
                if self.current_speed < SETTLE_SPEED then
                    self.settled = true
                    if not self.controller_mode then
                        self:StopUpdating()
                    end
                    self:RefreshController()
                end
                self.current_root_y_pos = self.target_root_y_pos
            end
            self.root:SetPosition(0, self.current_root_y_pos, 0)
        end
    elseif self.current_root_y_pos < self.start_root_y_pos then
        self.current_speed = self.current_speed + UP_ACCEL * dt
        self.current_root_y_pos = self.current_root_y_pos + self.current_speed * dt
        self.root:SetPosition(0, self.current_root_y_pos, 0)
    else
        self:StopUpdating()
        self:Hide()
    end
end

--For ease of overriding in mods
function VoteDialog:GetDisplayName(clientrecord)
    return clientrecord.name or ""
end

function VoteDialog:ShowDialog(option_data)
    if option_data == nil then
        return
    end

    self.started = true
    self.settled = false
    self.canvote = false
    self.controllerselection = nil
    self:StartUpdating()
    self:Show()

    if self:IsVisible() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_DOWN")
    end

    self:UpdateOptions(option_data, true)
    self:RefreshLayout()
    self.current_root_y_pos = self.start_root_y_pos
    self.current_speed = DROP_SPEED
    self.root:SetPosition(0, self.current_root_y_pos, 0)
    self.timer:SetString("")

    if self.owner ~= nil and self.owner.components.playervoter ~= nil then
        self:UpdateSelection(self.owner.components.playervoter:GetSelection(), self.owner.components.playervoter:CanVote())
    else
        self:UpdateSelection(nil, false)
    end
end

function VoteDialog:RefreshLayout()
    self.bg:ManualFlow(self.num_options)

    local fill_dist = self.num_options > 0 and self.num_options * self.bg.filler_size or 0

    self.start_root_y_pos = (.5 * fill_dist + self.bg.end_cap_size) * VOTE_ROOT_SCALE
    self.target_root_y_pos = (-.5 * fill_dist - self.bg.start_cap_size) * VOTE_ROOT_SCALE - 20

    self.starter:SetPosition(0, .62 * self.bg.start_cap_size + .5 * fill_dist, 0)
    self.title:SetPosition(0, .33 * self.bg.start_cap_size + .5 * fill_dist, 0)
    self.timer:SetPosition(0, -.42 * self.bg.end_cap_size - .5 * fill_dist, 0)
    self.instruction:SetPosition(0, -25 - self.bg.end_cap_size - .5 * fill_dist, 0)

    for i = 1, self.num_options do
        self.labels_desc[i]:SetPosition(-16, .5 * fill_dist - self.bg.filler_size * (i - .5) - 2, 0)
        self.buttons[i]:SetPosition(115, .5 * fill_dist - self.bg.filler_size * (i - .5) - 5, 0)
    end

    if self.controller_mode then
        self:SetControllerInstruction()
        if self.started and self.settled then
            self:StartUpdating()
        end
    elseif self.started and self.settled then
        self:StopUpdating()
    end

    self:RefreshController()
end

function VoteDialog:RefreshController()
    if self.owner.HUD == nil or
        self.owner.HUD:HasInputFocus() then
        --Give time for playercontroller to recapture targets
        self.controller_hint_delay = 2.5 * FRAMES
        self.instruction:Hide()
    elseif self.controller_mode and
        self.started and
        self.settled and
        self.canvote and
        self.controllerscaling <= 0 and
        self.controller_hint_delay <= 0 and
        self:IsVisible() and
        not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
        self.owner.components.playercontroller ~= nil and
        not (self.owner.components.playercontroller:IsEnabled() and
            self.owner.components.playercontroller:GetInspectButtonAction(self.owner.components.playercontroller:GetControllerTarget()) ~= nil) then
        self.instruction:Show()
    else
        self.instruction:Hide()
    end
end

function VoteDialog:SetControllerInstruction()
    self.instruction:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INSPECT).." "..STRINGS.UI.VOTEDIALOG.VOTE)
end

function VoteDialog:HideDialog()
    if self.started then
        self.started = false
        self.settled = false
        self.canvote = false
        self.current_speed = 0
        self:StartUpdating()
        self:RefreshController()

        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_UP")
    end
end

function VoteDialog:UpdateTimer(remaining)
    if not self.started then
        return
    end
    self.timer:SetString(remaining ~= nil and string.format(STRINGS.UI.VOTEDIALOG.TIME_REMAINING, remaining) or "")
end

function VoteDialog:UpdateOptions(option_data, norefresh)
    if not self.started then
        return
    end

    local startername = option_data.starterclient ~= nil and self:GetDisplayName(option_data.starterclient) or ""
    if startername ~= "" then
        self.starter:SetColour(unpack(option_data.starterclient.colour or { 0, 0, 0, 1 }))
        self.starter:SetTruncatedString(startername..":", 260, 40, "..:")
    else
        self.starter:SetString("")
    end

    local titlefmt = ResolveCommandStringProperty(option_data, "votetitlefmt", "")
    self.title:SetMultilineTruncatedString(string.format(titlefmt, option_data.targetclient ~= nil and self:GetDisplayName(option_data.targetclient) or ""), 2, 260, 55, true)

    local options = option_data.options
    local old_num_options = self.num_options
    self.num_options = math.min(MAX_VOTE_OPTIONS, options ~= nil and #options or 0)

    for i = 1, self.num_options do
        local option = options[i]
        local label = self.labels_desc[i]
        label:Show()
        self.buttons[i]:Show()
        if option == nil then
            label:SetString("")
        elseif option.vote_count == nil or option.vote_count <= 0 then
            label:SetTruncatedString(option.description, 260, 55, true)
        else
            local str = option.description..string.format(" (%d)", option.vote_count)
            label:SetTruncatedString(str, 260, 55, false)
            if label:GetString():len() < str:len() then
                label:SetTruncatedString(option.description, 260, 55, string.format("...(%d)", option.vote_count))
            end
        end
    end

    if old_num_options ~= self.num_options then
        for i = self.num_options + 1, old_num_options do
            self.labels_desc[i]:Hide()
            self.buttons[i]:Hide()
        end

        if not norefresh then
            --The only point of norefresh is so we don't refresh
            --twice in a row when we are called from ShowDialog.
            self:RefreshLayout()
        end
    end
end

function VoteDialog:UpdateSelection(selected_index, canvote)
    if not self.started then
        return
    end
    for i, v in ipairs(self.buttons) do
        if i == selected_index then
            v:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_disabled.tex", "checkbox_on_disabled.tex", "checkbox_on.tex")
        else
            v:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", "checkbox_off.tex")
        end
        if canvote then
            v:Enable()
        else
            v:Disable()
        end
    end
    self.canvote = canvote
    if not canvote and self.controllervotescreen ~= nil then
        self.controllervotescreen:Close()
    end
end

--Called from PlayerHud:OnControl
function VoteDialog:CheckControl(control, down)
    if self.shown and down and self.enabled and control == CONTROL_INSPECT then
        self:RefreshController()
        if self.instruction.shown then
            self:OnOpenControllerVoteScreen()
            return true
        end
    end
end

function VoteDialog:IsOpen()
    return self.started
end

function VoteDialog:IsControllerVoteScreenOpen()
    return self.controllervotescreen ~= nil
end

function VoteDialog:OnOpenControllerVoteScreen()
    if self.controllervotescreen == nil then
        self:StopUpdating()

        self.controllervotescreen = ControllerVoteScreen(self)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
        TheFrontEnd:PushScreen(self.controllervotescreen)

        self.instruction:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_CANCEL).." "..STRINGS.UI.VOTEDIALOG.CANCEL)
        self.instruction:SetScale(1 / CONTROLLER_OPEN_SCALE)
        self.instruction:Hide()

        self.controllervotescreen:ClearFocus()

        self.controllerscaling = self.controllerscaling + 1
        self.dialogroot:MoveTo(CONTROLLER_CLOSE_POS, CONTROLLER_OPEN_POS, CONTROLLER_POP_SPEED)
        self.root:ScaleTo(VOTE_ROOT_SCALE, CONTROLLER_OPEN_SCALE, CONTROLLER_POP_SPEED,
            function()
                self.controllerscaling = self.controllerscaling - 1
                if self.controllerscaling <= 0 and self.controllervotescreen ~= nil then
                    self.instruction:Show()
                    self.controllervotescreen.default_focus =
                        self.buttons[
                            self.controllerselection ~= nil and
                            self.controllerselection <= self.num_options and
                            self.controllerselection >= 1 and
                            self.controllerselection or 1
                        ]
                    self.controllervotescreen:SetDefaultFocus()
                end
            end)
    end
end

function VoteDialog:CloseControllerVoteScreen()
    if self.controllervotescreen ~= nil then
        self.controllervotescreen:Close()
    end
end

--For internal use only! Call :CloseControllerVoteScreen() instead of this one
function VoteDialog:OnCloseControllerVoteScreen(selection)
    if self:IsVisible() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
    end

    self.controllerselection = selection or self.controllerselection
    self.controllervotescreen = nil

    self.instruction:SetScale(1 / VOTE_ROOT_SCALE)
    self.instruction:Hide()

    self.controllerscaling = self.controllerscaling + 1
    self.dialogroot:MoveTo(CONTROLLER_OPEN_POS, CONTROLLER_CLOSE_POS, CONTROLLER_POP_SPEED)
    self.root:ScaleTo(CONTROLLER_OPEN_SCALE, VOTE_ROOT_SCALE, CONTROLLER_POP_SPEED,
        function()
            self.controllerscaling = self.controllerscaling - 1
        end)

    if self.controller_mode then
        self:SetControllerInstruction()
        self:StartUpdating()
    end
end

return VoteDialog
