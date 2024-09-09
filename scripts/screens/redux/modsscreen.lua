local ModsTab = require "widgets/redux/modstab"
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/redux/templates"
local OnlineStatus = require "widgets/onlinestatus"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

-- numbers copied from ServerCreationScreen
local dialog_size_x = 830
local dialog_size_y = 555

local bottom_button_y = -310

local ModsScreen = Class(Screen, function(self, prev_screen)
    Screen._ctor(self, "ModsScreen")

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.dirty = false

    self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.MODSSCREEN.MODTITLE, ""))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        { x = 290, y = 284, scale = 0.75 },
        { x = 490, y = 284, scale = 0.75 },
        { x = -25,  y = 284, scale = 0.75 },
        { x = 125,   y = 284, scale = 0.75 },
    } ))

    self.optionspanel = self.root:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    self.optionspanel:SetPosition(140, 0)

    local settings = {
        is_configuring_server = false,
        details_width = 505,
        are_servermods_readonly = true,
    }
    self.mods_page = self.optionspanel:InsertWidget(ModsTab(self, settings))

    self.applybutton = self.optionspanel:AddChild(TEMPLATES.StandardButton(function() self:Apply() end, STRINGS.UI.MODSSCREEN.APPLY))
    self.applybutton:SetScale(.7)
    self.applybutton:SetPosition(335, bottom_button_y)

    self.onlinestatus = self.root:AddChild(OnlineStatus())
    self.cancelbutton = self.root:AddChild(TEMPLATES.BackButton(function() self:Cancel() end))

    self.default_focus = self.mods_page
    self:DoFocusHookups()
end)

function ModsScreen:OnControl(control, down)
    if ModsScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_CANCEL then
            self:Cancel()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        elseif TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
            -- Hitting Esc fires both Pause and Cancel, so we can only handle
            -- pause when coming from gamepads.
            if control == CONTROL_MENU_START and TheInput:ControllerAttached() then
                self:Apply()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                return true
            elseif control == CONTROL_MENU_BACK then
                self.mods_page:CleanAllButton()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                return true
            elseif control == CONTROL_MENU_MISC_2 then
                self.mods_page:UpdateAllButton()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                return true
            end
        end
    end
end

function ModsScreen:BuildModsMenu(menu_items, subscreener)
    -- Clarify what you can do from this screen with subtitles.
    subscreener.titles.client = STRINGS.UI.MODSSCREEN.CLIENTMODS
    subscreener.titles.server = STRINGS.UI.MODSSCREEN.SERVERMODS_TITLE_READONLY

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

function ModsScreen:RepositionModsButtonMenu(allmodsmenu, selectedmodmenu)
    allmodsmenu:SetPosition(-420, bottom_button_y - 13)
    selectedmodmenu:SetPosition(270, -250)

    if TheInput:ControllerAttached() then
        allmodsmenu:Hide()
    end
end

function ModsScreen:ShowWorkshopDownloadingNotification()
	if self.workshop_indicator ~= nil then
		return
	end

	self.workshop_indicator = self.mods_page:AddChild(Widget("workshop_indicator"))
    self.workshop_indicator:SetPosition(390, 250)

	local text = self.workshop_indicator:AddChild(Text(BODYTEXTFONT, 18, STRINGS.UI.MODSSCREEN.DOWNLOADING_MODS, UICOLOURS.GOLD_UNIMPORTANT))
    text:SetPosition(0, -27)

	local image = self.workshop_indicator:AddChild(Image("images/avatars.xml", "loading_indicator.tex"))
	local function dorotate() image:RotateTo(0, -360, .75, dorotate) end
	dorotate()
	image:SetTint(unpack(UICOLOURS.GOLD_UNIMPORTANT))
end

function ModsScreen:RemoveWorkshopDownloadingNotification()
	if self.workshop_indicator ~= nil then
		self.workshop_indicator:Kill()
		self.workshop_indicator = nil
	end
end

function ModsScreen:DirtyFromMods(_)
    self:MakeDirty()
end

function ModsScreen:MakeDirty()
    self.dirty = true
end

function ModsScreen:MakeClean()
    self.dirty = false
end

function ModsScreen:IsDirty()
    return self.dirty
end

function ModsScreen:Cancel()
    if self:IsDirty() then
        TheFrontEnd:PushScreen(
            PopupDialogScreen( STRINGS.UI.MODSSCREEN.CANCEL_TITLE, STRINGS.UI.MODSSCREEN.CANCEL_BODY,
                {
                    {
                        text = STRINGS.UI.MODSSCREEN.OK,
                        cb = function()
                            TheFrontEnd:PopScreen() -- popup
                            self:MakeClean()
                            self:Cancel()
                        end
                    },

                    {
                        text = STRINGS.UI.MODSSCREEN.CANCEL,
                        cb = function()
                            TheFrontEnd:PopScreen()
                        end
                    }
                }
                )
            )
    else

        TheFrontEnd:FadeBack(function()
            -- Call mods_page:Cancel() in fade complete callback or we get
            -- crashes.
            self.mods_page:Cancel()
        end)
    end
end

function ModsScreen:Apply()
    -- Apply will restart the sim!
    self.mods_page:Apply(true)
end

function ModsScreen:OnDestroy()
    self.mods_page:OnDestroy()

    self._base.OnDestroy(self)
end

function ModsScreen:OnBecomeActive()
    ModsScreen._base.OnBecomeActive(self)

    self.mods_page:OnBecomeActive()

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end
end

function ModsScreen:OnBecomeInactive()
    ModsScreen._base.OnBecomeInactive(self)

    self.mods_page:OnBecomeInactive()

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function ModsScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_BACK) .. " " .. STRINGS.UI.MODSSCREEN.CLEANALL)

    if self.mods_page.updateallenabled then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.MODSSCREEN.UPDATEALL)
    end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.MODSSCREEN.APPLY)

    return table.concat(t, "  ")
end

function ModsScreen:DoFocusHookups()
    self.mods_page:SetFocusChangeDir(MOVE_DOWN, self.applybutton)
    self.mods_page:SetFocusChangeDir(MOVE_RIGHT, self.applybutton)
    self.mods_page:SetFocusChangeDir(MOVE_LEFT, self.cancelbutton)
    self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.mods_page)

    self.applybutton:SetFocusChangeDir(MOVE_RIGHT, self.mods_page)
    self.applybutton:SetFocusChangeDir(MOVE_LEFT, self.mods_page)
    self.applybutton:SetFocusChangeDir(MOVE_UP, self.mods_page)

    if TheInput:ControllerAttached() then
        if self.applybutton then self.applybutton:Hide() end
        if self.cancelbutton then self.cancelbutton:Hide() end
    end
end

return ModsScreen
