local Text = require "widgets/text"
local Image = require "widgets/image"
local Puppet = require "widgets/skinspuppet"
local Widget = require "widgets/widget"
local ClothingExplorerPanel = require "widgets/redux/clothingexplorerpanel"
local Subscreener = require "screens/redux/subscreener"
local SkinPresetsPopup = require "screens/redux/skinpresetspopup"

local TEMPLATES = require "widgets/redux/templates"

require("characterutil")
require("util")
require("networking")
require("stringutil")

local LoadoutSelect_nonplayer = Class(Widget, function(self, user_profile, character, initial_skintype)
    Widget._ctor(self, "LoadoutSelect")
    self.user_profile = user_profile

    self.currentcharacter = character

    self.show_puppet = self.currentcharacter ~= "random"
    self.have_base_option = table.contains(DST_CHARACTERLIST, self.currentcharacter)


    self.loadout_root = self:AddChild(Widget("LoadoutRoot"))

    self.heroname = self.loadout_root:AddChild(Image())
    self.heroname:SetScale(.3)
    self.heroname:SetPosition(-35,240)


    self.puppet_root = self:AddChild(Widget("puppet_root"))
    self.puppet_root:SetPosition(-35, -30)

    self.glow = self.puppet_root:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
    self.glow:SetPosition(0, -50)
    self.glow:SetScale(2.5)
    self.glow:SetTint(1, 1, 1, .5)
    self.glow:SetClickable(false)

    self.puppet = self.puppet_root:AddChild(Puppet())
    self.puppet:AddShadow()
	self.puppet_base_offset = { 0, -160 }
	self.puppet:SetPosition(self.puppet_base_offset[1], self.puppet_base_offset[2])
	self.puppet_default_scale = 4.5
    self.puppet:SetScale(self.puppet_default_scale)
    self.puppet:SetClickable(false)


    self:_LoadSavedSkins()


	if IsPrefabSkinned(self.currentcharacter) then
		self.skinmodes = GetSkinModes(self.currentcharacter)
    else
        self.skinmodes = {}
        table.insert(self.skinmodes, GetSkinModes("default")[1])
    end

    if MODCHARACTERMODES[self.currentcharacter] ~= nil then
        --Mod characters with modes set!
        self.skinmodes = {}
        table.insert(self.skinmodes, GetSkinModes("default")[1])

        for _,v in pairs(MODCHARACTERMODES[self.currentcharacter]) do
            table.insert(self.skinmodes,
                {
                    type = v.type,
                    anim_bank = v.anim_bank,
                    idle_anim = v.idle_anim,
                    play_emotes = v.play_emotes,
                    scale = v.scale,
                    offset = v.offset,
                }
            )
        end
    end


	self.view_index = 1
	self.selected_skinmode = self.skinmodes[self.view_index]

	-- Portrait view index must be 1 < ind <= #self.skinmodes+1
	self.portrait_view_index = #self.skinmodes + 1

	if initial_skintype ~= nil and initial_skintype ~= "normal_skin" then
		for i,v in ipairs(self.skinmodes) do
			if v.type == initial_skintype then
				self.view_index = i
				self:_SetSkinMode(v)
				break
			end
		end
	end


    if not TheNet:IsOnlineMode() then
		self.bg_group = self.loadout_root:AddChild(Widget("bg_group"))
        self.bg_group:SetPosition(370, 10)

        self.frame = self.bg_group:AddChild(Widget("offline frame"))
        self.frame:SetScale(.7)

        self.frame.top = self.frame:AddChild(Image("images/global_redux.xml", "player_list_banner.tex"))
        self.frame.top:SetPosition(0, 150)

        self.frame.bottom = self.frame:AddChild(Image("images/global_redux.xml", "player_list_banner.tex"))
        self.frame.bottom:SetScale(-1)
        self.frame.bottom:SetPosition(0, -150)

		local text1 = self.bg_group:AddChild(Text(CHATFONT, 30, STRINGS.UI.LOBBYSCREEN.CUSTOMIZE))
		text1:SetPosition(0,20)
		text1:SetHAlign(ANCHOR_MIDDLE)
		text1:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

		local text2 = self.bg_group:AddChild(Text(CHATFONT, 30, STRINGS.UI.LOBBYSCREEN.OFFLINE))
		text2:SetPosition(0,-20)
		text2:SetHAlign(ANCHOR_MIDDLE)
		text2:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    else
        self.doodad_count = self:AddChild(TEMPLATES.DoodadCounter(TheInventory:GetCurrencyAmount()))
	    self.doodad_count:SetPosition(580, 320)
	    self.doodad_count:SetScale(0.35)

        local reader = function(item_key)
            return table.contains(self.selected_skins, item_key)
        end
        local writer_builder = function(item_type)
            return function(item_data)
                self:_SelectSkin(item_type, item_data.item_key, item_data.is_active, item_data.is_owned)
            end
        end

        local filter_options = {}
        filter_options.ignore_hero = not self.have_base_option
        local explorer_panels = {
            body = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "body", reader, writer_builder("body"), filter_options)),
            hand = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "hand", reader, writer_builder("hand"), filter_options)),
            legs = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "legs", reader, writer_builder("legs"), filter_options)),
            feet = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "feet", reader, writer_builder("feet"), filter_options)),
        }
        if self.have_base_option then
            explorer_panels.base = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "base", reader, writer_builder("base")))
        end

        self.subscreener = Subscreener(self, self._MakeMenu, explorer_panels)
        if self.have_base_option then
            self.subscreener.menu:SetPosition(375, 315)
        else
            self.subscreener.menu:SetPosition(409, 315)
        end

        for k,screen in pairs(self.subscreener.sub_screens) do
            screen:SetScale(0.85)
            screen:SetPosition(130, -10)
        end

        self.subscreener:SetPostMenuSelectionAction( function(selection)
            if selection ~= "base" then
                self:_CycleView(true)
            end
        end )

        self.divider_top = self.loadout_root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
        self.divider_top:SetScale(0.53, 0.5)
        self.divider_top:SetPosition(405, 282)

        local active_sub = self.subscreener:GetActiveSubscreenFn()
        self.focus_forward = active_sub
    end

    if not TheInput:ControllerAttached() then
        if self.show_puppet then
            self.portraitbutton = self.loadout_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.WARDROBESCREEN.CYCLE_VIEW, false, false, function()
			        self:_CycleView()
		        end
	        ))
	        self.portraitbutton:SetPosition(-260, 270)
            self.portraitbutton:SetScale(0.77)

            if TheNet:IsOnlineMode() then
                self.presetsbutton = self.loadout_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "save.tex", STRINGS.UI.SKIN_PRESETS.TITLE, false, false, function()
			            self:_LoadSkinPresetsScreen()
		            end
	            ))
	            self.presetsbutton:SetPosition(200, 315)
                self.presetsbutton:SetScale(0.77)

                self.menu:SetFocusChangeDir(MOVE_LEFT, self.presetsbutton)
                self.presetsbutton:SetFocusChangeDir(MOVE_RIGHT, self.menu)
                self.presetsbutton:SetFocusChangeDir(MOVE_DOWN, self.subscreener:GetActiveSubscreenFn())
            end
        end
	end
end)

function LoadoutSelect_nonplayer:_SetSkinMode(skinmode)
	self.selected_skinmode = skinmode
	self:_ApplySkins(self.preview_skins, true)
	self.puppet:SetScale((skinmode.scale or 1) * self.puppet_default_scale)
	if skinmode.offset ~= nil then
		self.puppet:SetPosition(self.puppet_base_offset[1] + (skinmode.offset[1] or 0), self.puppet_base_offset[2] + (skinmode.offset[2] or 0))
	else
		self.puppet:SetPosition(self.puppet_base_offset[1], self.puppet_base_offset[2])
	end
end

function LoadoutSelect_nonplayer:SetDefaultMenuOption()
    if self.subscreener then
        if self.have_base_option then
            self.subscreener:OnMenuButtonSelected("base")
        else
            self.subscreener:OnMenuButtonSelected("body")
        end
    end
end

function LoadoutSelect_nonplayer:_CycleView(reset)
	--[[
		When the cycle view button is clicked an index is incremented,
		EXCEPT when the index is about to become the same as the portrait
		view index, in which case the portrait is toggled on. On the next
		interaction the index increments and the portrait is toggled off,
		i.e. skinmodes[portrait_index] still contains skinmode data and
		is not overridden.
	]]

	self.view_index = self.view_index + 1
	if self.view_index > #self.skinmodes then
		self.view_index = 1
	end

	self:_SetSkinMode(self.skinmodes[self.view_index])

end

function LoadoutSelect_nonplayer:_SetShowPortrait(show)
	if show then
		self.puppet_root:Hide()
		self.showing_portrait = true
	else
		self.puppet_root:Show()
		self.showing_portrait = false
	end
end

function LoadoutSelect_nonplayer:_MakeMenu(subscreener)
    self.button_body = subscreener:WardrobeButtonMinimal("body")
    self.button_hand = subscreener:WardrobeButtonMinimal("hand")
    self.button_legs = subscreener:WardrobeButtonMinimal("legs")
    self.button_feet = subscreener:WardrobeButtonMinimal("feet")

    local menu_items = nil
    if self.have_base_option then
        self.button_base = subscreener:WardrobeButtonMinimal("base")
        menu_items =
        {
            {widget = self.button_base },
            {widget = self.button_body },
            {widget = self.button_hand },
            {widget = self.button_legs },
            {widget = self.button_feet },
        }
    else
        menu_items =
        {
            {widget = self.button_body },
            {widget = self.button_hand },
            {widget = self.button_legs },
            {widget = self.button_feet },
        }
    end

    self:_UpdateMenu(self.selected_skins)
    self.menu = self.loadout_root:AddChild(TEMPLATES.StandardMenu(menu_items, 65, true))
    return self.menu
end


function LoadoutSelect_nonplayer:_SaveLoadout()
    if TheNet:IsOnlineMode() then
        self.user_profile:SetSkinsForCharacter(self.currentcharacter, self.selected_skins)
    end
end

function LoadoutSelect_nonplayer:_LoadSkinPresetsScreen()
	local scr = SkinPresetsPopup( self.user_profile, self.currentcharacter, self.selected_skins, function(skins) self:ApplySkinPresets(skins) end )
	scr.owned_by_wardrobe = true
    TheFrontEnd:PushScreen( scr )
end

function LoadoutSelect_nonplayer:ApplySkinPresets(skins)
    if skins.base == nil then
        if table.contains(DST_CHARACTERLIST, self.currentcharacter) then --no base option for mod characters
            skins.base = self.currentcharacter.."_none"
        end
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

function LoadoutSelect_nonplayer:_LoadSavedSkins()
    if TheNet:IsOnlineMode() then
        self.selected_skins = self.user_profile:GetSkinsForCharacter(self.currentcharacter)
    else
        self.selected_skins = { base = self.currentcharacter.."_none" }
    end
    self.preview_skins = shallowcopy(self.selected_skins)

    self:_RefreshAfterSkinsLoad()
end

function LoadoutSelect_nonplayer:_RefreshAfterSkinsLoad()
    -- Creating the subscreens requires skins to be loaded, so we might not have subscreener yet.
    if self.subscreener then
        for key,item in pairs(self.preview_skins) do
            if self.subscreener.sub_screens[key] ~= nil then
                self.subscreener.sub_screens[key]:RefreshInventory()
            end
        end
    end
    self:_ApplySkins(self.preview_skins, false)
    self:_UpdateMenu(self.selected_skins)
end

function LoadoutSelect_nonplayer:_SelectSkin(item_type, item_key, is_selected, is_owned)
    if item_type ~= "base" then
        self:_CycleView(true)
    end

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

function LoadoutSelect_nonplayer:_ApplySkins(skins, skip_change_emote)
    ValidateItemsLocal(self.currentcharacter, self.selected_skins)
    ValidatePreviewItems(self.currentcharacter, skins)

    if self.show_puppet then
		self.puppet:SetSkins(self.currentcharacter, skins.base, skins, skip_change_emote, self.selected_skinmode)
    end
end

function LoadoutSelect_nonplayer:_UpdateMenu(skins)
    if self.button_base then
        if skins["base"] then
            self.button_base:SetItem(skins["base"])
        else
            self.button_base:SetItem(self.currentcharacter.."_none")
        end
    end
    if self.button_body then
        if skins["beeef_body"] then
            self.button_body:SetItem(skins["beef_body"])
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

function LoadoutSelect_nonplayer:OnControl(control, down)
    if LoadoutSelect._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_MENU_MISC_3 then
            if self.show_puppet then
                self:_CycleView()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                return true
            end
        elseif control == CONTROL_MENU_MISC_1 and TheNet:IsOnlineMode() then
            self:_LoadSkinPresetsScreen()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
	end

    return false
end

function LoadoutSelect_nonplayer:RefreshInventory(animateDoodad)
    self.doodad_count:SetCount(TheInventory:GetCurrencyAmount(),animateDoodad)
end

function LoadoutSelect_nonplayer:GetHelpText()
    if TheNet:IsOnlineMode() then
		local controller_id = TheInput:GetControllerID()
		local t = {}

        if self.show_puppet then
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_3) .. " " .. STRINGS.UI.WARDROBESCREEN.CYCLE_VIEW)
        end
        if TheNet:IsOnlineMode() then
		    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SKIN_PRESETS.TITLE)
        end

		return table.concat(t, "  ")
	else
		return ""
	end
end

function LoadoutSelect_nonplayer:OnUpdate(dt)
    if self.puppet then
        self.puppet:EmoteUpdate(dt)
    end
end

return LoadoutSelect_nonplayer
