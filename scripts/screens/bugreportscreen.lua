require "util"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TextEdit = require "widgets/textedit"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"

local BugReportScreen = Class(Screen, function(self)
    Screen._ctor(self, "BugReportScreen")

    local fontsize = 30

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.95)

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0, 0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    local panel_bg_frame = self.root:AddChild(TEMPLATES.CenterPanel(
        1, 1, true, nil, nil, nil, nil, nil, nil, nil, nil
    ))

    local panel_frame = panel_bg_frame:AddChild(Image("images/options.xml", "panel_frame.tex"))
    panel_frame:SetPosition(8, -5)
    panel_frame:SetScale(0.69, 0.75)

    self.title  = panel_bg_frame:AddChild(Text(BUTTONFONT,
                                               fontsize,
                                               STRINGS.UI.BUGREPORTSCREEN.DESCRIPTION_LABEL,
                                               {0, 0, 0, 1}))
    self.title:SetPosition(-110, 250)
    self.title:SetRegionSize(600, 60)
    self.title:SetHAlign(ANCHOR_LEFT)

    self.description_text = self.root:AddChild(TextEdit(DEFAULTFONT, fontsize, ""))

    self.description_text:EnableWordWrap(true)
    self.description_text:EnableScrollEditWindow(false)
    self.description_text:EnableWhitespaceWrap(true)
    self.description_text:EnableRegionSizeLimit(true)
    self.description_text:SetForceEdit(true)
    self.description_text:SetAllowNewline(true)

    self.description_text.edit_text_color = {1, 1, 1, 1}
    self.description_text.idle_text_color = {1, 1, 1, 1}
    self.description_text:SetEditCursorColour(1, 1, 1, 1)
    self.description_text:SetPosition(0, 0, 0)
    self.description_text:SetRegionSize(780, 425)
    self.description_text:SetHAlign(ANCHOR_LEFT)
    self.description_text:SetVAlign(ANCHOR_TOP)
    self.description_text:SetPassControlToScreen(CONTROL_CANCEL, true)
    self.description_text:SetHelpTextEdit("")
    self.description_text:SetString("")

    self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(
        function()
            TheFrontEnd:PopScreen(self)
        end))

    self.submit_button = self.root:AddChild(ImageButton())
    self.submit_button.image:SetScale(0.7)
    self.submit_button:SetText(STRINGS.UI.BUGREPORTSCREEN.SUBMIT)
    self.submit_button:SetFont(NEWFONT)
    self.submit_button:SetDisabledFont(NEWFONT)

    self.submit_button:SetPosition(350, -RESOLUTION_Y * 0.41)

    self.submit_button:SetOnClick(function() self:FileBugReport() end)
end)

function BugReportScreen:OnBecomeActive()
    BugReportScreen._base.OnBecomeActive(self)

    self.description_text:SetFocus()
    self.description_text:SetEditing(true)
end

function BugReportScreen:FileBugReport()

    local title = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_SUCCESS_TITLE
    local message = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_SUCCESS_TEXT

    local success = TheSim:FileBugReport(self.description_text:GetString())

    if not success then
        title = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_FAILURE_TITLE
        message = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_FAILURE_TEXT
    end

    local result_dialog = PopupDialogScreen(
        title, message,
        {
            {text=STRINGS.UI.POPUPDIALOG.OK, cb = function()
                TheFrontEnd:PopScreen()
                if success then
                    TheFrontEnd:PopScreen()
                end
            end},
        }
    )

    TheFrontEnd:PushScreen(result_dialog)
end

return BugReportScreen
