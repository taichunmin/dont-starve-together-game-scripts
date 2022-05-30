local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local UIAnim = require "widgets/uianim"
local Puppet = require "widgets/skinspuppet"

local SCREEN_OFFSET = -.22 * RESOLUTION_X

local function AnimateOpeningText(self)
    if not self.spawn_portal:GetAnimState():IsCurrentAnimation("skin_loop") then
        local current_title = self.title:GetString()

        if current_title == STRINGS.UI.ITEM_SCREEN.RECEIVED then
            return
        end

        --print (string.find(current_title, "..."))
        if not string.find(current_title, "%. %. %.") then
            current_title = ". " .. current_title .. " ."
        else
            current_title = ". " .. STRINGS.UI.ITEM_SCREEN.OPENING .. " ."
        end
        self.title:SetString(current_title)
        self.inst:DoTaskInTime(1, function() AnimateOpeningText(self) end)
    end
end

local GiftItemPopUp = Class(Screen, function(self, owner, item_types, item_ids)
    Screen._ctor(self, "GiftItemPopUp")

    self.owner = owner

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,45,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.root = self.proot:AddChild(Widget("fixed_root"))

    -- Fancy reveal FX
    local spawn_portal_scale = .8
    self.spawn_portal = self.root:AddChild(UIAnim())
    self.spawn_portal:GetAnimState():SetBuild("skingift_popup") -- file name
    self.spawn_portal:GetAnimState():SetBank("gift_popup") -- top level symbol
    self.spawn_portal:SetScale(spawn_portal_scale)

    local title_height = 152

    --title
    self.title = self.proot:AddChild(Text(UIFONT, 42))
    self.title:SetPosition(0, title_height - 15, 0)
    self.title:SetString(STRINGS.UI.ITEM_SCREEN.OPENING)
    self.title:SetColour(1,1,1,1)
    self.inst:DoTaskInTime(0.5, function() AnimateOpeningText(self) end)

    -- banner
    self.banner = self.proot:AddChild(Image("images/giftpopup.xml", "banner.tex"))
    self.banner:SetPosition(0, -200, 0)
    self.banner:SetScale(0.8)
    self.name_text = self.banner:AddChild(Text(UIFONT, 55))
    self.name_text:SetHAlign(ANCHOR_MIDDLE)
    self.name_text:SetPosition(0, -10, 0)
    self.name_text:SetColour(1, 1, 1, 1)

    self.banner:Hide()

    self.anims = self.openanims
    self.item_types = item_types
    self.item_ids = item_ids --optional unless we're in game
    self.revealed_items = {}
    self.current_item = 1
    self:RevealItem(self.current_item)

    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation_spin")

    TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)

    SetAutopaused(true)
end)

function GiftItemPopUp:OnDestroy()
    SetAutopaused(false)
    TheCamera:PopScreenHOffset(self)
    TheFrontEnd:GetSound():KillSound("gift_idle")
    self._base.OnDestroy(self)
end

function GiftItemPopUp:ApplySkin()
    --Hack for holding offset when transitioning from giftitempopup to wardrobepopup
    TheCamera:PushScreenHOffset(self.owner.HUD, SCREEN_OFFSET)
    self.owner.HUD:SetRecentGifts(self.item_types, self.item_ids)

    TheFrontEnd:PopScreen(self)
    POPUPS.GIFTITEM:Close(self.owner, true)
end

function GiftItemPopUp:ShowMenu()
    self.show_menu = true

    if not TheInput:ControllerAttached() then
        --creates the buttons
        local button_w = 200
        local space_between = 40
        local spacing = button_w + space_between
        local buttons = {{text = STRINGS.UI.ITEM_SCREEN.USE_LATER, cb = function() self:OnClose() end},
                         {text = STRINGS.UI.ITEM_SCREEN.USE_NOW, cb = function() self:ApplySkin() end}
                        }
        self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
        self.menu:SetPosition(25-(spacing*(#buttons-1))/2, -290, 0)
        self.menu:SetScale(0.8)
        self.menu:Show()
        self.menu:SetFocus()

        if self.disable_use_now then
            self.menu:DisableItem(2)
        end

        self.default_focus = self.menu
    end
end

function GiftItemPopUp:OnClose()
    TheFrontEnd:GetSound():KillSound("gift_idle")
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation_skinout")
    --self.spawn_portal:GetAnimState():PlayAnimation("put_away")
    self.spawn_portal:GetAnimState():PlayAnimation("skin_out")
    if self.menu then
        self.menu:Kill()
    end
    self.show_menu = false
end

function GiftItemPopUp:OnUpdate(dt)
    if self.spawn_portal:GetAnimState():IsCurrentAnimation("skin_loop") then
        if self.reveal_skin then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_recieves_gift_idle", "gift_idle")
            self.reveal_skin = false
        end
    elseif self.spawn_portal:GetAnimState():IsCurrentAnimation("open") then
        if self.open_box then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation")
            self.open_box = nil
        end
    elseif self.spawn_portal:GetAnimState():IsCurrentAnimation("skin_out") and self.spawn_portal:GetAnimState():AnimDone() then
        TheFrontEnd:PopScreen(self)
        POPUPS.GIFTITEM:Close(self.owner)
    end
end

-- Handles the presentation stuff
-- The index stuff comes from when the popup was supposed to support multiple items
-- Decided to keep it like that for now in case it changes again in the future
function GiftItemPopUp:RevealItem(idx)
    local item_name = self.item_types[idx]
    if item_name == nil then
        return
    end

    self.revealed_items[idx] = true
    self.reveal_skin = true
    --local name = GetRandomItem({"body_polo_blue_denim", "hand_drivergloves_brown_sepia", "body_sweatervest_green_forest", "body_buttons_teal_jade", "hand_longgloves_black_scribble"}) -- Test data items that work with SWAP_ICON

    item_name = string.gsub(item_name, "swap_", "")

    local skin_data = GetSkinData(item_name)
    self.disable_use_now = true
    if IsClothingItem( item_name ) or (skin_data and skin_data.type == "base" and string.find( item_name, self.owner.prefab ) ~= nil ) then
        self.disable_use_now = false
    end
    self.spawn_portal:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(item_name), "SWAP_ICON")

    self.spawn_portal:GetAnimState():PlayAnimation("activate") -- Box comes in
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation_spin")

    self.open_box = true
    self.spawn_portal:GetAnimState():PushAnimation("open") -- Opening box
    self.spawn_portal:GetAnimState():PushAnimation("skin_loop") -- Floating shirt

    self.inst:DoTaskInTime(175 * FRAMES, function()
        self.banner:Show()
        self:ShowMenu()
        self.title:SetString(STRINGS.UI.ITEM_SCREEN.RECEIVED)

        local item_id = self.item_ids[idx]
        if item_id ~= nil then
            TheInventory:SetItemOpened(item_id)
        end
    end)

    local name_string = GetSkinName(item_name)
    self.name_text:SetTruncatedString(name_string, 500, 35, true)

    self.name_text:SetColour(GetColorForItem(item_name))
    self.item_name = item_name
end

function GiftItemPopUp:OnControl(control, down)
    if GiftItemPopUp._base.OnControl(self, control, down) then return true end

    if TheInput:ControllerAttached() and self.show_menu then
        if not down and control == CONTROL_CANCEL then
            self:OnClose()
            return true
        elseif not down and not self.disable_use_now and control == CONTROL_PAUSE then
            self:ApplySkin()
            return true
        end
    end
end

function GiftItemPopUp:GetHelpText()
    if self.show_menu then
        local controller_id = TheInput:GetControllerID()
        local t = {}

        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.ITEM_SCREEN.USE_LATER)

        if not self.disable_use_now then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.ITEM_SCREEN.USE_NOW)
        end

        return table.concat(t, "  ")
    end
end

return GiftItemPopUp
