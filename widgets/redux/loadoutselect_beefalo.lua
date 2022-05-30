local Text = require "widgets/text"
local Image = require "widgets/image"
local Puppet = require "widgets/skinspuppet_beefalo"
local Widget = require "widgets/widget"
local ClothingExplorerPanel = require "widgets/redux/clothingexplorerpanel"
local Subscreener = require "screens/redux/subscreener"
local BeefaloSkinPresetsPopup = require "screens/redux/beefaloskinpresetspopup"

local BEEFALO_COSTUMES = require("yotb_costumes")

local TEMPLATES = require "widgets/redux/templates"

require("characterutil")
require("util")
require("networking")
require("stringutil")

local LoadoutSelect_beefalo = Class(Widget, function(self, user_profile, character, initial_skins, filter, owner_player)
    Widget._ctor(self, "LoadoutSelect_beefalo")
    self.owner_player = owner_player
    self.user_profile = user_profile
    self.filter = filter
    self.currentcharacter_inst = character
    self.currentcharacter = character.prefab

    self.initial_skins = initial_skins

    self.loadout_root = self:AddChild(Widget("LoadoutRoot"))

    --title
    self.beefname = self.loadout_root:AddChild(Text(UIFONT, 50))
    self.beefname:SetPosition(-35,210)
    self.beefname:SetString(character.replica.named._name:value())
    self.beefname:SetColour(1,1,1,1)

    self.puppet_root = self:AddChild(Widget("puppet_root"))
    self.puppet_root:SetPosition(-35, -80)

    self.glow = self.puppet_root:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
    self.glow:SetPosition(-20, 20)
    self.glow:SetScale(2.5)
    self.glow:SetTint(1, 1, 1, .5)
    self.glow:SetClickable(false)

    self.puppet = self.puppet_root:AddChild(Puppet())
    self.puppet:AddShadow()
	self.puppet_base_offset = { -20, -60 }
	self.puppet:SetPosition(self.puppet_base_offset[1], self.puppet_base_offset[2])
	self.puppet_default_scale = 4.5
    self.puppet:SetScale(self.puppet_default_scale)
    self.puppet:SetClickable(false)

    self:_LoadSavedSkins()

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

        filter_options.ignore_survivor = true

        filter_options.yotb_filter = self.filter

        local explorer_panels = {
            beef_body = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "beef_body", reader, writer_builder("beef_body"), filter_options)),
            beef_horn = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "beef_horn", reader, writer_builder("beef_horn"), filter_options)),
            beef_head = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "beef_head", reader, writer_builder("beef_head"), filter_options)),
            beef_feet = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "beef_feet", reader, writer_builder("beef_feet"), filter_options)),
            beef_tail = self.loadout_root:AddChild(ClothingExplorerPanel(self, self.user_profile, "beef_tail", reader, writer_builder("beef_tail"), filter_options)),
        }

        self.subscreener = Subscreener(self, self._MakeMenu, explorer_panels)

        self.subscreener.menu:SetPosition(379, 315)


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
end)


function LoadoutSelect_beefalo:SetDefaultMenuOption()
    if self.subscreener then
        self.subscreener:OnMenuButtonSelected("beef_body")
    end
end

function LoadoutSelect_beefalo:_CycleView(reset)
end

function LoadoutSelect_beefalo:_MakeMenu(subscreener)
    self.button_beef_body = subscreener:WardrobeButtonMinimal("beef_body")
    self.button_beef_horn = subscreener:WardrobeButtonMinimal("beef_horn")
    self.button_beef_head = subscreener:WardrobeButtonMinimal("beef_head")
    self.button_beef_feet = subscreener:WardrobeButtonMinimal("beef_feet")
    self.button_beef_tail = subscreener:WardrobeButtonMinimal("beef_tail")

    local menu_items = nil
    menu_items =
    {
        {widget = self.button_beef_body },
        {widget = self.button_beef_horn },
        {widget = self.button_beef_head },
        {widget = self.button_beef_feet },
        {widget = self.button_beef_tail },
    }
    self:_UpdateMenu(self.selected_skins)
    self.menu = self.loadout_root:AddChild(TEMPLATES.StandardMenu(menu_items, 65, true))
    return self.menu
end

function LoadoutSelect_beefalo:_SaveLoadout()
    if TheNet:IsOnlineMode() then
        self.user_profile:SetSkinsForCharacter(self.currentcharacter, self.selected_skins)
    end
end

function LoadoutSelect_beefalo:_LoadSkinPresetsScreen()
	local scr = BeefaloSkinPresetsPopup( self.user_profile, self.currentcharacter, self.selected_skins, function(skins) self:ApplySkinPresets(skins) end )
	scr.owned_by_wardrobe = true
    TheFrontEnd:PushScreen( scr )
end

function LoadoutSelect_beefalo:ApplySkinPresets(skins)
    if skins.base == nil then
        if table.contains(DST_CHARACTERLIST, self.currentcharacter) then --no base option for mod characters
            skins.base = self.currentcharacter.."_none"
        end
    end

    if skins.beef_body == nil then
        skins.beef_body = "beef_body_default1"
    end

    if skins.beef_horn == nil then
        skins.beef_horn = "beef_horn_default1"
    end

    if skins.beef_head == nil then
        skins.beef_head = "beef_legs_default1"
    end

    if skins.beef_feet == nil then
        skins.beef_feet = "beef_feet_default1"
    end

    if skins.beef_tail == nil then
        skins.beef_tail = "beef_tail_default1"
    end

    ValidateItemsLocal(self.currentcharacter, skins)
    ValidatePreviewItems(self.currentcharacter, skins, self.filter)

    self.preview_skins = shallowcopy(skins)

    local selected_skins = {}

    for slot, skin in pairs(skins)do
        if self:YOTB_event_check(skin) then
           selected_skins[slot] = skin
        end
    end

    self.selected_skins = selected_skins

    for _,screen in pairs(self.subscreener.sub_screens) do
        screen:ClearSelection() --we need to clear the selection, so that the refresh will apply without re-selection of previously selected items overriding
    end

    local base_skin = self.currentcharacter_inst:GetBaseSkin()

    self:_RefreshAfterSkinsLoad()
end

function LoadoutSelect_beefalo:_LoadSavedSkins()
    if TheNet:IsOnlineMode() then
        self.selected_skins = self.user_profile:GetSkinsForCharacter(self.currentcharacter)
    else
        self.selected_skins = { base = self.currentcharacter.."_none" }
    end
    self.preview_skins = shallowcopy(self.initial_skins)
    self.selected_skins = shallowcopy(self.initial_skins)

    self:_RefreshAfterSkinsLoad()
end

function LoadoutSelect_beefalo:_RefreshAfterSkinsLoad()
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

function LoadoutSelect_beefalo:_SelectSkin(item_type, item_key, is_selected, is_owned)
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

function LoadoutSelect_beefalo:_ApplySkins(skins, skip_change_emote)

    self.preview_skins = shallowcopy(skins)

    ValidateItemsLocal(self.currentcharacter, self.selected_skins)
    ValidatePreviewItems(self.currentcharacter, skins, self.filter)

    local base_skin = self.currentcharacter_inst:GetBaseSkin()

	self.puppet:SetSkins(self.currentcharacter, base_skin, skins, skip_change_emote)
end

function LoadoutSelect_beefalo:_UpdateMenu(skins)
    if self.button_base then
        if skins["base"] then
            self.button_base:SetItem(skins["base"])
        else
            self.button_base:SetItem(self.currentcharacter.."_none")
        end
    end
    if self.button_beef_body then
        if skins["beef_body"] then
            self.button_beef_body:SetItem(skins["beef_body"])
        else
            self.button_beef_body:SetItem("beef_body_default1")
        end
    end
    if self.button_beef_horn then
        if skins["beef_horn"] then
            self.button_beef_horn:SetItem(skins["beef_horn"])
        else
            self.button_beef_horn:SetItem("beef_horn_default1" )
        end
    end
    if self.button_beef_head then
        if skins["beef_head"] then
            self.button_beef_head:SetItem(skins["beef_head"])
        else
            self.button_beef_head:SetItem("beef_head_default1")
        end
    end
    if self.button_beef_feet then
        if skins["beef_feet"] then
            self.button_beef_feet:SetItem(skins["beef_feet"])
        else
            self.button_beef_feet:SetItem("beef_feet_default1")
        end
    end
    if self.button_beef_tail then
        if skins["beef_tail"] then
            self.button_beef_tail:SetItem(skins["beef_tail"])
        else
            self.button_beef_tail:SetItem("beef_tail_default1")
        end
    end
end

function LoadoutSelect_beefalo:OnControl(control, down)
    if LoadoutSelect_beefalo._base.OnControl(self, control, down) then return true end

    if not down then
        --[[
        if control == CONTROL_MENU_MISC_3 then
            self:_CycleView()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        else
            ]]
        if control == CONTROL_MENU_MISC_1 and TheNet:IsOnlineMode() then
            self:_LoadSkinPresetsScreen()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
	end

    return false
end

function LoadoutSelect_beefalo:RefreshInventory(animateDoodad)
    self.doodad_count:SetCount(TheInventory:GetCurrencyAmount(),animateDoodad)
end

function LoadoutSelect_beefalo:GetHelpText()
    if TheNet:IsOnlineMode() then
		local controller_id = TheInput:GetControllerID()
		local t = {}

--        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_3) .. " " .. STRINGS.UI.WARDROBESCREEN.CYCLE_VIEW)

        if TheNet:IsOnlineMode() then
		    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SKIN_PRESETS.TITLE)
        end

		return table.concat(t, "  ")
	else
		return ""
	end
end

function LoadoutSelect_beefalo:OnUpdate(dt)
    if self.puppet then
        --self.puppet:EmoteUpdate(dt)
    end
end


function LoadoutSelect_beefalo:YOTB_event_check(skin)
    if not IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
        return true
    end
    for i,set in pairs(BEEFALO_COSTUMES.costumes)do
        for t,setskin in ipairs(set.skins) do
            if setskin == skin then
                if checkbit(self.owner_player.yotb_skins_sets:value(), YOTB_COSTUMES[i]) then
                    return true
                else
                    return false
                end
            end
        end
    end
end

return LoadoutSelect_beefalo
