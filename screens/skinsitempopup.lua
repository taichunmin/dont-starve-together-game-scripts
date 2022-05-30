local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local UIAnim = require "widgets/uianim"
local Puppet = require "widgets/skinspuppet"
local TEMPLATES = require "widgets/templates"

local SkinsItemPopUp = Class(Screen, function(self, item_type, player_name, player_colour)
    Screen._ctor(self, "SkinsItemPopUp")

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    -- Root, duh.
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- Curly window frame
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(235, 425, 1, 1))
    self.frame:SetPosition(-7.5, -15, 0)

    --Background
    self.bg = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetScale(.9,.65,.9)

    --Player's name, colored accordingly
    self.player_label = self.proot:AddChild(Text(TALKINGFONT, 55))--Text(BUTTONFONT, 55))
    self.player_label:SetTruncatedString(player_name, 400, 25, true)

    self.player_label:SetColour(player_colour)

    --title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 55))
    --self.title:SetPosition(50, 185, 0)
    self.title:SetString(STRINGS.UI.ITEM_SCREEN.NORMAL_POPUP_TITLE)
    self.title:SetColour(0,0,0,1)

    local w1, h1 = self.player_label:GetRegionSize()
    local w2, h2 = self.title:GetRegionSize()
    self.player_label:SetPosition(-(w2/2), 185, 0)
    self.title:SetPosition(w1/2, 185, 0)

    --Item name
    self.skin_name = self.proot:AddChild(Text(TALKINGFONT, 40))
    self.skin_name:SetPosition(-100, 85, 0)
    self.skin_name:SetString("ITEM_NAME")
    self.skin_name:EnableWordWrap(true)
    self.skin_name:SetRegionSize(300, 200)
    self.skin_name:SetColour(0,0,0,1)

    self.upper_horizontal_line = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.upper_horizontal_line:SetScale(1, .55, .55)
    self.upper_horizontal_line:SetPosition(-100, 60, 0)

    -- Item Description
    self.skin_description = self.proot:AddChild(Text(BUTTONFONT, 35))
    self.skin_description:SetPosition(-100, -45, 0)
    self.skin_description:SetString("ITEM_DESCRIPTION")
    self.skin_description:EnableWordWrap(true)
    self.skin_description:SetRegionSize(300, 200)
    self.skin_description:SetColour(0,0,0,1)

    self.lower_horizontal_line = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.lower_horizontal_line:SetScale(1, .55, .55)

    w1, h1 = self.skin_description:GetRegionSize()
    local pos = self.skin_description:GetPosition()
    self.lower_horizontal_line:SetPosition(-100, pos.y-(h1/2), 0)

    self.rarity_label = self.proot:AddChild(Text(TALKINGFONT, 35))
    self.rarity_label:SetPosition(-100, pos.y-(h1/2)-35, 0)
    --self.rarity_label:Hide()

    self.spawn_portal = self.proot:AddChild(UIAnim())
    self.spawn_portal:GetAnimState():SetBuild("skingift_popup")
    self.spawn_portal:GetAnimState():SetBank("gift_popup")
    self.spawn_portal:GetAnimState():PlayAnimation("activate", true)
    self.spawn_portal:SetScale(.4)
    self.spawn_portal:SetPosition(185, 0, 0)

    --creates the menu itself
    local button_w = 200
    local space_between = 20
    local spacing = button_w + space_between
    --local spacing = 160
    local buttons = {{text = STRINGS.UI.ITEM_SCREEN.OK_BUTTON, cb = function() TheFrontEnd:PopScreen(self) end}}
    self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
    self.menu:SetPosition(-7.5, -285, 0)

    self.item_type = item_type
    self:SetItemDisplay()

    self.default_focus = self.menu
end)

function SkinsItemPopUp:OnControl(control, down)
    if SkinsItemPopUp._base.OnControl(self,control, down) then
        return true
    end
end

-- Sets the item display info before revealing it
function SkinsItemPopUp:SetItemDisplay()

    local item_type = string.lower(self.item_type)
    local item_name = GetSkinName(item_type)
    local item_description = GetSkinDescription(item_type)

    -- Fallback for development, just in case the name or description doesn't yet exist.
    -- This can be removed before shipping
    if item_name == nil then
        item_name = item_type
    end

    if item_description == nil then
        item_description = "Description for " .. item_name
    end

    self.skin_name:SetString(item_name)
    self.skin_description:SetString(item_description)

	self.spawn_portal:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(item_type), "SWAP_ICON")

    self.skin_name:SetColour(GetColorForItem(item_type))
    self.rarity_label:SetColour(GetColorForItem(item_type))
    self.rarity_label:SetString(GetModifiedRarityStringForItem(item_type))

    self.spawn_portal:GetAnimState():PlayAnimation("skin_loop", true)

end

return SkinsItemPopUp