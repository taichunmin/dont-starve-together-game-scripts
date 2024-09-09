local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local Menu = require "widgets/menu"
local PopupDialogScreen = require "screens/redux/popupdialog"
local InputDialogScreen = require "screens/redux/inputdialog"

local window_width = 300

local ManageServerSlotScreen = Class(Screen, function(self, slot, ondeletefn, refreshfn)
    assert(ondeletefn, "PresetPopupScreen requires a ondeletefn")
    assert(refreshfn, "PresetPopupScreen requires a refreshfn")

    Screen._ctor(self, "ManageServerSlotScreen")

    self.slot = slot
    self.ondeletefn = ondeletefn
    self.refreshfn = refreshfn

    local buttons = {
        { text=STRINGS.UI.SERVERCREATIONSCREEN.DELETE_SLOT, cb = function() self.ondeletefn(self.slot) end },
        { text=STRINGS.UI.SERVERCREATIONSCREEN.CLONE,       cb = function() self:OnCloneButton() end },
    }

    if IsSteam() then
        local is_cloud = self.slot > CLOUD_SAVES_SAVE_OFFSET
        table.insert(buttons, 1, {
            text = is_cloud and STRINGS.UI.SERVERCREATIONSCREEN.CONVERTCLOUDTOLOCAL or STRINGS.UI.SERVERCREATIONSCREEN.CONVERTLOCALTOCLOUD,
            cb = function() self:OnConvertButton() end
        })
    end

    if not IsLinux() and not IsSteamDeck() then
        table.insert(buttons, 1, {text=STRINGS.UI.SERVERCREATIONSCREEN.OPENSAVEFOLDER, cb = function() self:OnOpenFolderButton() end})
    end

    local window_height = 350
    if #buttons == 3 then
        window_height = 290
    elseif #buttons == 2 then
        window_height = 230
    end

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BackgroundTint(0.7))

    self.dialog_bg = self.root:AddChild(TEMPLATES.PlainBackground())
    local dialog_width = window_width + 72
    local dialog_height = window_height + 4
    self.dialog_bg:SetScissor(-dialog_width/2, -dialog_height/2, dialog_width, dialog_height)

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(window_width, window_height))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.dialog:SetBackgroundTint(r,g,b, 0.6) --need high opacity because of text behind

    if not TheInput:ControllerAttached() then
        self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:OnCancel() end))
    end

    self.title = self.root:AddChild(Text(CHATFONT, 35))
    self.title:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetString(STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_SLOT)
    self.title:SetPosition(0, (window_height / 2) - 25)

    self.horizontal_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.horizontal_line:SetPosition(0,window_height/2 - 48)
    self.horizontal_line:SetSize(dialog_width, 5)

    local cluster_folder = self.slot > CLOUD_SAVES_SAVE_OFFSET and TheSim:GetFolderForCloudSaveSlot(self.slot) or "Cluster_"..self.slot
    local manage_text = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_TEXT, {folder = cluster_folder})

    self.text = self.root:AddChild(Text(CHATFONT, 18))
    self.text:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetString(manage_text)
    self.text:SetPosition(0, (window_height / 2) - 75)

    self.button_menu = self.root:AddChild(Menu(buttons, 60, false, "carny_xlong", nil, 21))
    self.button_menu:SetPosition(0, -(window_height/2) + 45)

    self.default_focus = self.button_menu
end)

function ManageServerSlotScreen:OnCloneButton()
    local name_clone_screen
    name_clone_screen = InputDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.NAME_DUPLICATE_SLOT,
        {
            {
                text = STRINGS.UI.SERVERCREATIONSCREEN.CLONE,
                cb = function()
                    TheFrontEnd:PopScreen()
                    self:OnNameEntered(name_clone_screen:GetActualString())
                end
            },
            {
                text = STRINGS.UI.SERVERCREATIONSCREEN.CANCEL,
                cb = function()
                    TheFrontEnd:PopScreen()
                end
            }
        },
    true)
    local serverdata = ShardSaveGameIndex:GetSlotServerData(self.slot)
    name_clone_screen:OverrideText(subfmt(STRINGS.UI.SERVERCREATIONSCREEN.COPY_OF_SLOT_NAME, {worldname = serverdata.name}))

    name_clone_screen.edit_text.OnTextEntered = function()
        if name_clone_screen:GetActualString() ~= "" then
            TheFrontEnd:PopScreen()
            self:OnNameEntered(name_clone_screen:GetActualString())
        else
            name_clone_screen.edit_text:SetEditing(true)
        end
    end
    TheFrontEnd:PushScreen(name_clone_screen)
    name_clone_screen.edit_text:SetForceEdit(true)
    name_clone_screen.edit_text:OnControl(CONTROL_ACCEPT, false)
end

function ManageServerSlotScreen:OnNameEntered(name)
    local new_slot = ShardSaveGameIndex:GetNextNewSlot()
    local success = TheSim:DuplicateSlot(
        self.slot,
        new_slot,
        Profile:GetUseZipFileForNormalSaves()
    )
    if success then
        --refresh so the new slot is properly loaded
        self.refreshfn()
        local serverdata = ShardSaveGameIndex:GetSlotServerData(new_slot)
        serverdata.name = name
        ShardSaveGameIndex:SetSlotServerData(new_slot, serverdata)
        ShardSaveGameIndex:Save()
    else
        local ok = {{text=STRINGS.UI.SERVERCREATIONSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }}
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.FAILED_COPYORCONVERT_TITLE, STRINGS.UI.SERVERCREATIONSCREEN.FAILED_COPY_DIALOG, ok ) )
    end
    self.refreshfn(true)
end

function ManageServerSlotScreen:OnConvertButton()
    local slot = TheSim:ConvertSlotToCloudOrLocal(
        self.slot,
        ShardSaveGameIndex:GetNextNewSlot(self.slot > CLOUD_SAVES_SAVE_OFFSET and "local" or "cloud"),
        Profile:GetUseZipFileForNormalSaves()
    )
    if slot == -1 then
        local ok = {{text=STRINGS.UI.SERVERCREATIONSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end }}
        local failed_convert_dialog = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.FAILED_CONVERT_DIALOG_FMT, {type = self.slot > CLOUD_SAVES_SAVE_OFFSET and STRINGS.UI.SERVERCREATIONSCREEN.CONVERT_LOCAL or STRINGS.UI.SERVERCREATIONSCREEN.CONVERT_CLOUD})
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.SERVERCREATIONSCREEN.FAILED_COPYORCONVERT_TITLE, failed_convert_dialog, ok ) )
    else
        self:_Close()
        --push an identical screen with the new slot.
        TheFrontEnd:PushScreen(ManageServerSlotScreen(slot, self.ondeletefn, self.refreshfn))
    end
    self.refreshfn()
end

function ManageServerSlotScreen:OnOpenFolderButton()
    if type(self.slot) == "number" and self.slot > 0 then
        if (IsSteam() or IsRail()) and not IsLinux() then
            TheSim:OpenSaveFolder(self.slot)
        end
    end
end

function ManageServerSlotScreen:OnCancel()
    self:_Close()
end

function ManageServerSlotScreen:OnControl(control, down)
    if ManageServerSlotScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_CANCEL then
            self:OnCancel()
            return true
        end
    end
end

function ManageServerSlotScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)

	return table.concat(t, "  ")
end

function ManageServerSlotScreen:_Close()
    TheFrontEnd:PopScreen()
end

return ManageServerSlotScreen