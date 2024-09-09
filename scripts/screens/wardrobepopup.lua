local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local DressupPanel = require "widgets/dressuppanel"
local TEMPLATES = require "widgets/templates"

local SCREEN_OFFSET = -.285 * RESOLUTION_X

local WardrobePopupScreen = Class(Screen, function(self, owner_player, profile, recent_item_types, recent_item_ids)
	Screen._ctor(self, "WardrobePopupScreen")

    self.owner_player = owner_player
	self.profile = profile

    --V2C: @liz
    -- recent_item_types and recent_item_ids are both tables of
    -- items that were just opened in the gift item popup.
    --
    -- Both params are nil if we did not come from GiftItemPopup.
    --
    -- They should be both in the same order, so recent_item_types[1]
    -- corresponds to recent_item_ids[1].
    -- (This is the exact same data that is passed into GiftItemPopup.)
    --
    -- Currently, it is safe to assume there will only be 1 item.
    --
    -- recent_item_ids is probably useless if we're only showing one
    -- of each item type in the spinners, and you should just match
    -- by recent_item_types[1].

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.root = self.proot:AddChild(Widget("root"))
    self.root:SetPosition(-RESOLUTION_X/2, -RESOLUTION_Y/2, 0)

    self.heroportrait = self.proot:AddChild(Image())
    self.heroportrait:SetScale(.75)
    self.heroportrait:SetPosition(-185, 30)

    self.dressup = self.proot:AddChild(DressupPanel(self, profile, TheNet:GetClientTableForUser(self.owner_player.userid), function() self:SetPortrait() end, recent_item_types, recent_item_ids))
    self.dressup:SetCurrentCharacter(self.owner_player.prefab)

    self:SetPortrait()


    local offline = not TheInventory:HasSupportForOfflineSkins() and not TheNet:IsOnlineMode()

    local buttons = {}
    if offline then
    	buttons = {{text = STRINGS.UI.POPUPDIALOG.OK, cb = function() self:Close() end}}
    else
    	buttons = {{text = STRINGS.UI.WARDROBE_POPUP.CANCEL, cb = function() self:Cancel() end},
                     {text = STRINGS.UI.WARDROBE_POPUP.RESET, cb = function() self:Reset() end},
                     {text = STRINGS.UI.WARDROBE_POPUP.SET, cb = function() self:Close() end},
                  }
    end

    local spacing = 225
    self.menu = self.proot:AddChild(Menu(buttons, spacing, true))

    if offline then
        self.dressup:SetPosition(0, 30)
		self.menu:SetPosition(0, -280, 0)
    else
        self.dressup:SetPosition(140, 30)
        self.menu:SetPosition(-230, -280, 0)
    end

	self.default_focus = self.menu

	self.dressup:ReverseFocus()
	self.menu.reverse = true

    TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)

    self:DoFocusHookups()
end)

function WardrobePopupScreen:OnDestroy()
    self._base.OnDestroy(self)
end

function WardrobePopupScreen:OnBecomeActive()
    self._base.OnBecomeActive(self)
    if TheInput:ControllerAttached() then
        self.default_focus:SetFocus()
    end
end

function WardrobePopupScreen:DoFocusHookups()
	self.menu:SetFocusChangeDir(MOVE_UP, self.dressup)
    self.dressup:SetFocusChangeDir(MOVE_DOWN, self.menu)
end

function WardrobePopupScreen:OnControl(control, down)
    if WardrobePopupScreen._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        self:Cancel()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end

	if down then
	 	if control == CONTROL_PREVVALUE then  -- r-stick left
	    	self.dressup:ScrollBack(control)
			return true
		elseif control == CONTROL_NEXTVALUE then -- r-stick right
			self.dressup:ScrollFwd(control)
			return true
		elseif control == CONTROL_SCROLLBACK then
            self.dressup:ScrollBack(control)
            return true
        elseif control == CONTROL_SCROLLFWD then
        	self.dressup:ScrollFwd(control)
            return true
        end
	end
end

function WardrobePopupScreen:Cancel()
	self:Reset()
	self:Close()
end

function WardrobePopupScreen:Reset()
	self.dressup:Reset()
	self:SetPortrait()
end

function WardrobePopupScreen:Close()
	-- Gets the current skin names (and sets them as the character default)
	local skins = self.dressup:GetSkinsForGameStart()

    local data = {}
    if TheInventory:HasSupportForOfflineSkins() or TheNet:IsOnlineMode() then
		data = skins
    end

    POPUPS.WARDROBE:Close(self.owner_player, data.base, data.body, data.hand, data.legs, data.feet)

    self.dressup:OnClose()
    TheFrontEnd:PopScreen(self)
end

function WardrobePopupScreen:SetPortrait()
    if TheInventory:HasSupportForOfflineSkins() or TheNet:IsOnlineMode() then
        local herocharacter = self.dressup.currentcharacter
        local portrait_name = GetPortraitNameForItem(self.dressup:GetBaseSkin())


        if portrait_name and portrait_name ~= "" then
            self.heroportrait:SetTexture("bigportraits/"..portrait_name..".xml", portrait_name.."_oval.tex", herocharacter.."_none.tex")
        else
            if softresolvefilepath("bigportraits/"..herocharacter.."_none.xml") then
                self.heroportrait:SetTexture("bigportraits/"..herocharacter.."_none.xml", herocharacter.."_none_oval.tex")
            else
                -- mod characters
                self.heroportrait:SetTexture("bigportraits/"..herocharacter..".xml", herocharacter..".tex")
            end
        end
    end
end

function WardrobePopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	return table.concat(t, "  ")

end

return WardrobePopupScreen