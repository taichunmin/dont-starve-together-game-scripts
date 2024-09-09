local ClothingExplorerPanel = require "widgets/redux/clothingexplorerpanel"
local Image = require "widgets/image"
local Puppet = require "widgets/skinspuppet"
local Screen = require "widgets/screen"
local Subscreener = require "screens/redux/subscreener"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local SkinPresetsPopup = require "screens/redux/skinpresetspopup"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local TEMPLATES = require("widgets/redux/templates")

local WardrobeScreen = Class(Screen, function(self, user_profile, character)
	Screen._ctor(self, "WardrobeScreen")
	self.user_profile = user_profile
    self.currentcharacter = character

    self:_DoInit()

	self.default_focus = self.subscreener.menu

    ----------------------------------------------------------
	-- Prepare for viewing

    self.subscreener:OnMenuButtonSelected("base")
end)

function WardrobeScreen:_DoInit()
    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BrightMenuBackground())

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.WARDROBESCREEN.TITLE, ""))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        { x = -380, y = 170, scale = 0.75 },
        { x = -300, y = -315, scale = 0.75 },
        { x = 580, y = -315, scale = 0.75 },
    } ))

    self.doodad_count = self.root:AddChild(TEMPLATES.DoodadCounter(TheInventory:GetCurrencyAmount()))
	self.doodad_count:SetPosition(-550, 215)
	self.doodad_count:SetScale(0.4)

	self.preview_root = self.root:AddChild(Widget("preview_root"))
	self.preview_root:SetPosition(-100, -190)

	self.heroname = self.preview_root:AddChild(Image())
    self.heroname:SetScale(.28)
    self.heroname:SetPosition(0, 460)

    self.puppet_root = self.preview_root:AddChild(Widget("puppet_root"))

    self.glow = self.puppet_root:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
	self.glow:SetPosition(0, 160)
	self.glow:SetScale(2.5)
	self.glow:SetTint(1, 1, 1, .5)
	self.glow:SetClickable(false)

    self.puppet = self.puppet_root:AddChild(Puppet())
	self.puppet:AddShadow()
	self.puppet_base_offset = { 0, 50 }
	self.puppet:SetPosition(self.puppet_base_offset[1], self.puppet_base_offset[2])
	self.puppet_default_scale = 4
    self.puppet:SetScale(self.puppet_default_scale)
    self.puppet:SetClickable(false)

	self.characterquote = self.preview_root:AddChild(Text(TALKINGFONT, 28))
    self.characterquote:SetHAlign(ANCHOR_MIDDLE)
    self.characterquote:SetVAlign(ANCHOR_TOP)
	self.characterquote:SetPosition(0,-20)
    self.characterquote:SetColour(UICOLOURS.IVORY)

    self.heroportrait = self.preview_root:AddChild(Image())
    self.heroportrait:SetScale(0.70)
    self.heroportrait:SetPosition(0, 240)
	self.heroportrait:Hide()

    -- Can't load skins until above widgets exist. Can't create ClothingExplorerPanel until skins are loaded.
	self:_LoadSavedSkins()

	self.skinmodes = GetSkinModes(self.currentcharacter)
	self.view_index = 1
	self.selected_skinmode = self.skinmodes[self.view_index]

	-- Portrait view index must be 1 < ind <= #self.skinmodes+1
	self.portrait_view_index = #self.skinmodes + 1

    local reader = function(item_key)
        return table.contains(self.selected_skins, item_key)
    end
    local writer_builder = function(item_type)
        return function(item_data)
            self:_SelectSkin(item_type, item_data.item_key, item_data.is_active, item_data.is_owned)
        end
    end
    self.subscreener = Subscreener(self,
        self._MakeMenu,
        {
            -- Menu items
            base = self.root:AddChild(ClothingExplorerPanel(self, self.user_profile, "base", reader, writer_builder("base"))),
            body = self.root:AddChild(ClothingExplorerPanel(self, self.user_profile, "body", reader, writer_builder("body"))),
            hand = self.root:AddChild(ClothingExplorerPanel(self, self.user_profile, "hand", reader, writer_builder("hand"))),
            legs = self.root:AddChild(ClothingExplorerPanel(self, self.user_profile, "legs", reader, writer_builder("legs"))),
            feet = self.root:AddChild(ClothingExplorerPanel(self, self.user_profile, "feet", reader, writer_builder("feet"))),
        })

    if not TheInput:ControllerAttached() then
        self.presetsbutton = self.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "save.tex", STRINGS.UI.SKIN_PRESETS.TITLE, false, false, function()
			    self:_LoadSkinPresetsScreen()
		    end
	    ))
	    self.presetsbutton:SetPosition(-480, 212)
        self.presetsbutton:SetScale(0.77)
        self.menu:SetFocusChangeDir(MOVE_UP, self.presetsbutton)
        self.presetsbutton:SetFocusChangeDir(MOVE_DOWN, self.menu)
        self.presetsbutton:SetFocusChangeDir(MOVE_RIGHT, self.subscreener:GetActiveSubscreenFn())

		self.cyclebutton = self.root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.WARDROBESCREEN.CYCLE_VIEW, false, false, function()
				self:_CycleView()
			end
		))
		self.cyclebutton:SetPosition(-260, 270)
		self.cyclebutton:SetScale(0.77)


        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:_CloseScreen()
                end,
                STRINGS.UI.WARDROBESCREEN.ACCEPT
            ))

        self.reset_current = self.root:AddChild(TEMPLATES.StandardButton(
                function()
                    self:_LoadSavedSkins()
                end,
                STRINGS.UI.WARDROBESCREEN.RESET,
                {180,45}
            ))
        self.reset_current:SetPosition(-100, -314)
        self:_CheckDirty()
    end
end

function WardrobeScreen:_SetSkinMode(skinmode)
	self.selected_skinmode = skinmode
	self:_ApplySkins(self.preview_skins)
	self.puppet:SetScale((skinmode.scale or 1) * self.puppet_default_scale)
	if skinmode.offset ~= nil then
		self.puppet:SetPosition(self.puppet_base_offset[1] + (skinmode.offset[1] or 0), self.puppet_base_offset[2] + (skinmode.offset[2] or 0))
	else
		self.puppet:SetPosition(self.puppet_base_offset[1], self.puppet_base_offset[2])
	end
end

function WardrobeScreen:_CycleView(reset)
	--[copied from loadoutselect.lua]
	--When the cycle view button is clicked an index is incremented,
	--EXCEPT when the index is about to become the same as the portrait
	--view index, in which case the portrait is toggled on. On the next
	--interaction the index increments and the portrait is toggled off,
	--i.e. skinmodes[portrait_index] still contains skinmode data and
	--is not overridden.
	if reset then
		if self.showing_portrait then
			self:_SetShowPortrait(false)

			self.view_index = 1
			self:_SetSkinMode(self.skinmodes[self.view_index])
		end
		return
	end

	if self.view_index == self.portrait_view_index - 1 and not self.showing_portrait then
		self:_SetShowPortrait(true)
	else
		if self.showing_portrait then self:_SetShowPortrait(false) end

		self.view_index = self.view_index + 1
		if self.view_index > #self.skinmodes then
			self.view_index = 1
		end

		self:_SetSkinMode(self.skinmodes[self.view_index])
	end
end

function WardrobeScreen:_SetShowPortrait(show)
	if show then
		self.heroportrait:Show()
		self.puppet_root:Hide()
		self.showing_portrait = true
	else
		self.heroportrait:Hide()
		self.puppet_root:Show()
		self.showing_portrait = false
	end
end

function WardrobeScreen:_MakeMenu(subscreener)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())
    self.tooltip:SetPosition(-480,-213)

    self.button_base = subscreener:WardrobeButton(STRINGS.UI.WARDROBESCREEN.BASE, "base", STRINGS.UI.WARDROBESCREEN.TOOLTIP_BASE, self.tooltip)
    self.button_body = subscreener:WardrobeButton(STRINGS.UI.WARDROBESCREEN.BODY, "body", STRINGS.UI.WARDROBESCREEN.TOOLTIP_BODY, self.tooltip)
    self.button_hand = subscreener:WardrobeButton(STRINGS.UI.WARDROBESCREEN.HAND, "hand", STRINGS.UI.WARDROBESCREEN.TOOLTIP_HAND, self.tooltip)
    self.button_legs = subscreener:WardrobeButton(STRINGS.UI.WARDROBESCREEN.LEGS, "legs", STRINGS.UI.WARDROBESCREEN.TOOLTIP_LEGS, self.tooltip)
    self.button_feet = subscreener:WardrobeButton(STRINGS.UI.WARDROBESCREEN.FEET, "feet", STRINGS.UI.WARDROBESCREEN.TOOLTIP_FEET, self.tooltip)

    local menu_items = {
        {widget = self.button_feet },
        {widget = self.button_legs },
        {widget = self.button_hand },
        {widget = self.button_body },
        {widget = self.button_base },
    }

    self:_UpdateMenu(self.selected_skins)

    self.menu = self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 65, nil, nil, false))
    return self.menu
end

function WardrobeScreen:_CloseScreen()
    self:_SaveLoadout()

    TheFrontEnd:FadeBack()
end

function WardrobeScreen:_SaveLoadout()
    self.user_profile:SetSkinsForCharacter(self.currentcharacter, self.selected_skins)
end

function WardrobeScreen:_LoadSkinPresetsScreen()
    TheFrontEnd:PushScreen( SkinPresetsPopup( self.user_profile, self.currentcharacter, self.selected_skins, function(skins) self:ApplySkinPresets(skins) end ) )
end

function WardrobeScreen:ApplySkinPresets(skins)
    if skins.base == nil then
        skins.base = self.currentcharacter.."_none"
    end

    if skins.body == nil then
        skins.body = "body_default1"
    end

    if skins.hand == nil then
        skins.hand = "hand_default1"
    end

    if skins.legs == nil then
        skins.legs = "legs_default1"
    end

    if skins.feet == nil then
        skins.feet = "feet_default1"
    end

    self.selected_skins = shallowcopy(skins)
    self.preview_skins = shallowcopy(skins)

    ValidateItemsLocal(self.currentcharacter, self.selected_skins)
    ValidatePreviewItems(self.currentcharacter, self.preview_skins)

    for _,screen in pairs(self.subscreener.sub_screens) do
        screen:ClearSelection() --we need to clear the selection, so that the refresh will apply without re-selection of previously selected items overriding
    end

    self:_RefreshAfterSkinsLoad()
end

function WardrobeScreen:_LoadSavedSkins()
    self.selected_skins = self.user_profile:GetSkinsForCharacter(self.currentcharacter)
    self.preview_skins = shallowcopy(self.selected_skins)

    self:_RefreshAfterSkinsLoad()
end

function WardrobeScreen:_RefreshAfterSkinsLoad()
    -- Creating the subscreens requires skins to be loaded, so we might not have subscreener yet.
    if self.subscreener then
        for _,sub_screen in pairs(self.subscreener.sub_screens) do
            sub_screen.filter_bar.picker.last_interaction_target = nil --this is to ensure that the refresh doesn't invalidate any undo action that is being done.
            sub_screen:RefreshInventory()
        end
    end

    self:_ApplySkins(self.preview_skins)
    self:_UpdateMenu(self.selected_skins)
end

function WardrobeScreen:_CheckDirty()
    if not self.reset_current then
        return
    end

    local saved_skins = self.user_profile:GetSkinsForCharacter(self.currentcharacter)

    -- Either table may have missing entries for defaults (except base), so check all keys.
    local all_keys = ArrayUnion(table.getkeys(saved_skins), table.getkeys(self.selected_skins))
    local dirty = false
    for i,key in ipairs(all_keys) do
        if saved_skins[key] ~= self.selected_skins[key] then
            dirty = true
        end
    end

    if dirty then
        self.reset_current:Enable()
    else
        self.reset_current:Disable()
    end
end

function WardrobeScreen:_SelectSkin(item_type, item_key, is_selected, is_owned)
    local is_previewing = is_selected or not is_owned
    if is_previewing then
        --selecting the item or previewing an item
        self.preview_skins[item_type] = item_key
    end
    if is_owned and is_selected then
        self.selected_skins[item_type] = item_key
    end

    self:_ApplySkins(self.preview_skins)
    self:_UpdateMenu(self.selected_skins)
end

function WardrobeScreen:_ApplySkins(skins)
    ValidateItemsLocal(self.currentcharacter, self.selected_skins)
    ValidatePreviewItems(self.currentcharacter, skins)

    self.puppet:SetSkins(self.currentcharacter, skins.base, skins, nil, self.selected_skinmode)
	self:_SetPortrait()
    self:_CheckDirty()
end

function WardrobeScreen:_UpdateMenu(skins)
    if self.button_base then
        if skins["base"] then
            self.button_base:SetItem(skins["base"])
        else
            self.button_base:SetItem(self.currentcharacter.."_none")
        end
    end
    if self.button_body then
        if skins["body"] then
            self.button_body:SetItem(skins["body"])
        else
            self.button_body:SetItem("body_default1")
        end
    end
    if self.button_hand then
        if skins["hand"] then
            self.button_hand:SetItem(skins["hand"])
        else
            self.button_hand:SetItem("hand_default1" )
        end
    end
    if self.button_legs then
        if skins["legs"] then
            self.button_legs:SetItem(skins["legs"])
        else
            self.button_legs:SetItem("legs_default1")
        end
    end
    if self.button_feet then
        if skins["feet"] then
            self.button_feet:SetItem(skins["feet"])
        else
            self.button_feet:SetItem("feet_default1")
        end
    end
end

function WardrobeScreen:_SetPortrait()
	local herocharacter = self.currentcharacter
	local skin = self.preview_skins.base

    local found_name = SetHeroNameTexture_Gold(self.heroname, herocharacter)
    if found_name then
        self.heroname:Show()
    else
        self.heroname:Hide()
    end

    if skin then
        SetSkinnedOvalPortraitTexture(self.heroportrait, herocharacter, skin)
    else
        SetOvalPortraitTexture(self.heroportrait, herocharacter)
    end

    self.characterquote:SetMultilineTruncatedString(STRINGS.SKIN_QUOTES[skin] or STRINGS.CHARACTER_QUOTES[herocharacter] or "",
        3, --maxlines
        300, --maxwidth,
        55, --maxcharsperline,
        true, --ellipses,
        false --shrink_to_fit
    )
end

function WardrobeScreen:OnBecomeActive()
    self._base.OnBecomeActive(self)
    if self.subscreener then
        for key,sub_screen in pairs(self.subscreener.sub_screens) do
            sub_screen:RefreshInventory()
        end

        --Check if they even own this character or not, so we can prompt the user
        if not self.did_once and not IsCharacterOwned( self.currentcharacter ) then
            DisplayCharacterUnownedPopup( self.currentcharacter, self.subscreener)
        end
        self.did_once = true
    end

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end
end

function WardrobeScreen:OnBecomeInactive()
    self._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function WardrobeScreen:RefreshInventory(animateDoodad)
    self.doodad_count:SetCount(TheInventory:GetCurrencyAmount(),animateDoodad)
end

function WardrobeScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.WARDROBESCREEN.ACCEPT)
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START ) .. " " .. STRINGS.UI.WARDROBESCREEN.RESET)
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SKIN_PRESETS.TITLE)

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_3, false, false) .. " " .. STRINGS.UI.WARDROBESCREEN.CYCLE_VIEW)

	return table.concat(t, "  ")
end

function WardrobeScreen:OnControl(control, down)
	if WardrobeScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:_CloseScreen()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true

    elseif not down and control == CONTROL_MENU_START then
        self:_LoadSavedSkins()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    elseif not down and control == CONTROL_MENU_MISC_1 then
        self:_LoadSkinPresetsScreen()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
	elseif not down and control == CONTROL_MENU_MISC_3 then
		self:_CycleView()
		return true
	end
end

function WardrobeScreen:OnUpdate(dt)
    WardrobeScreen._base.OnUpdate(self, dt)

    self.puppet:EmoteUpdate(dt)
end

return WardrobeScreen
