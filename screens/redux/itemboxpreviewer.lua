local Grid = require "widgets/grid"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local NineSlice = require "widgets/nineslice"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

require "skinsutils"


local bg_frame_w = 675
local bg_frame_w_offset = 30
local bg_frame_h_offset = 30
local bg_frame_initial_y = 220
local item_grid_initial_x = 80
local COLUMN_WIDTH = 160
local COLUMN_HEIGHT = 150

local ANIM_TIMING = {
    open      = { pause_for_server = (139-110) * FRAMES },
    skin_next = { icon_hidden      = (255-234) * FRAMES },
}

local RARITY_SOUND = {
    Common          = "dontstarve/HUD/Together_HUD/collectionscreen/music/1_lootbox_common",
    Classy          = "dontstarve/HUD/Together_HUD/collectionscreen/music/2_lootbox_classy",
    Spiffy          = "dontstarve/HUD/Together_HUD/collectionscreen/music/3_lootbox_spiffy",
    Distinguished   = "dontstarve/HUD/Together_HUD/collectionscreen/music/4_lootbox_distinguished",
    Elegant         = "dontstarve/HUD/Together_HUD/collectionscreen/music/5_lootbox_elegant",
}


local TRANSITION_DURATION = 0.3

local PP_ON_TINT = {r=.6,g=.6,b=.6,a=1}
local PP_OFF_TINT = {r=1,g=1,b=1,a=0}

local ItemBoxPreviewer = Class(Screen, function(self, items_to_display)
    Screen._ctor(self, "ItemBoxPreviewer")

    self.items_to_display = items_to_display

    self.center_root = self:AddChild(TEMPLATES.ScreenRoot())
    self.fg = self:AddChild(TEMPLATES.ReduxForeground())

    self.bg = self.center_root:AddChild(TEMPLATES.PlainBackground()) -- match MysteryBoxScreen so it looks like a fade
    self.bg.bgplate.image:SetTint(1,1,1,0)--maybe we should move this into TintTo
    self.bg.bgplate.image:TintTo(PP_OFF_TINT, PP_ON_TINT, TRANSITION_DURATION, function() self:_OpenItemBox() end )

    self.proot = self.center_root:AddChild(Widget("ROOT_P"))
    self.proot:SetPosition( 0, -100, 0 )

    self.bundle_root = self.proot:AddChild(Widget("bundle_root"))

    -- Add fancy nineslice
    --self.frame = self.bundle_root:AddChild(Image("images/fepanels_redux_shop_panel.xml", "shop_panel.tex"))
    self.frame = self.bundle_root:AddChild(NineSlice("images/dialogcurly_9slice.xml"))
    local top = self.frame:AddCrown("crown-top-fg.tex", ANCHOR_MIDDLE, ANCHOR_TOP, 0, 68)
    local top_bg = self.frame:AddCrown("crown-top.tex", ANCHOR_MIDDLE, ANCHOR_TOP, 0, 44)
    top_bg:MoveToBack()
    -- Background overlaps behind and foreground overlaps in front.
    local bottom = self.frame:AddCrown("crown-bottom-fg.tex", ANCHOR_MIDDLE, ANCHOR_BOTTOM, 0, -14)
    bottom:MoveToFront()
    self.frame:SetSize(bg_frame_w,400+bg_frame_h_offset)
    self.frame:SetScale(0.7, 0.7)
    self.frame:SetPosition(0,bg_frame_initial_y)
    self.frame:Hide()

    self.opened_item_display = self.bundle_root:AddChild(Grid())
    self.opened_item_display:SetPosition(item_grid_initial_x,210)
    self.opened_item_display:Hide()


    -- Actual animation
    self.bundle_bg = self.bundle_root:AddChild(UIAnim())
    self.bundle_bg:SetScale(.7)
    self.bundle_bg:SetPosition(0, 83)
    self.bundle_bg:GetAnimState():SetBuild("box_shared_spiral")
    self.bundle_bg:GetAnimState():SetBank("box_shared_spiral")
 

    if self.allow_cancel and not TheInput:ControllerAttached() then
        self.back_button = self.center_root:AddChild(TEMPLATES.BackButton(
                function() self:_Close() end
            ))
    end

    self:AddChild(TEMPLATES.ReduxForeground())
    self:EvaluateButtons()
end)

function ItemBoxPreviewer:OnUpdate(dt)

end

-- Enables or disables arrows according to our current item
function ItemBoxPreviewer:EvaluateButtons()
    if self.back_button then
        self.back_button:Show()
    end
end

function ItemBoxPreviewer:_OpenItemBox()
    local columns = 3

    if self.bolts_source ~= nil then
        --self.bundle:GetAnimState():OverrideSkinSymbol("SWAP_ICON", "box_bolt", self.bolts_source)
    else
        local item_types = self.items_to_display

        local item_images = {}
        for i,item_key in ipairs(item_types) do
            local item_type = GetTypeForItem(item_key)
            local item_widget = TEMPLATES.ItemImageVerticalText(item_type, item_key, 150)
            table.insert(item_images, item_widget)
        end
        
        columns, self.resize_root, self.resize_root_small, self.resize_root_small_higher = GetBoxPopupLayoutDetails( #item_types )

        self.opened_item_display:FillGrid(columns, COLUMN_WIDTH, COLUMN_HEIGHT, item_images)
    end

    if self.bolts_source ~= nil then
        --no review for currency
        self:_Close()
    else
        if self.resize_root then
            self.bundle_root:SetPosition(0,90)
            self.bundle_root:SetScale(0.9,0.9)
        end
        if self.resize_root_small then
            self.bundle_root:SetPosition(0,150)
            self.bundle_root:SetScale(0.7,0.7)
        end
        if self.resize_root_small_higher then
            self.bundle_root:SetPosition(0,185)
            self.bundle_root:SetScale(0.7,0.7)
        end

        -- update the background size
        local rows = math.ceil(#self.items_to_display/columns)
        self.frame:SetSize(columns * COLUMN_WIDTH + bg_frame_w_offset, rows * COLUMN_HEIGHT + bg_frame_h_offset)
        self.frame:SetPosition(0,bg_frame_initial_y - rows*COLUMN_HEIGHT/2)

        self.opened_item_display:SetPosition(item_grid_initial_x-(columns*COLUMN_WIDTH/2),210)

        self.frame:Show()
        self.opened_item_display:Show()
    end
end


function ItemBoxPreviewer:_Close()
    if not self.closing then
        self.closing = true

        self.bundle_root:Hide()
        
        self.bg.bgplate.image:TintTo(PP_ON_TINT, PP_OFF_TINT, TRANSITION_DURATION, function()
            TheFrontEnd:PopScreen(self)
            if self.completed_cb ~= nil then
                self.completed_cb()
            end
        end)
    end
end


function ItemBoxPreviewer:OnControl(control, down)
    if ItemBoxPreviewer._base.OnControl(self,control, down) then
        return true
    end

    return self:_Close()
end

function ItemBoxPreviewer:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.ITEM_SCREEN.BACK)

    return table.concat(t, "  ")
end

return ItemBoxPreviewer
