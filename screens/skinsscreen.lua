local Screen = require "widgets/screen"
local PopupDialogScreen = require "screens/popupdialog"
local TrueScrollList = require "widgets/truescrolllist"
local ImageButton = require "widgets/imagebutton"
local ItemImage = require "widgets/itemimage"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
--local DropDown = require "widgets/dropdown"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local Puppet = require "widgets/skinspuppet"
local CharacterLoadoutSelectScreen = require "screens/characterloadoutselectscreen"
local TradeScreen = require "screens/tradescreen"
local TEMPLATES = require "widgets/templates"
local SetPopupDialog = require "screens/setpopupdialog"

local DEBUG_MODE = BRANCH == "dev"


local NUM_ROWS = 4
local NUM_ITEMS_PER_ROW = 4
local NUM_ITEMS_PER_GRID = 16

local SkinsScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "SkinsScreen")

	self.profile = profile
	self:DoInit()

	self.applied_filters = {} -- filters that are currently applied (groups to show)
end)

function SkinsScreen:DoInit()
	TheFrontEnd:GetGraphicsOptions():DisableStencil()
	TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()

	TheInputProxy:SetCursorVisible(true)

	-- Background is a really big paper texture.
    self.panel_bg = self:AddChild(Image("images/options_bg.xml", "options_panel_bg.tex"))
    self.panel_bg:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.panel_bg:SetVAnchor(ANCHOR_MIDDLE)
    self.panel_bg:SetHAnchor(ANCHOR_MIDDLE)
    self.panel_bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.panel_bg:SetHRegPoint(ANCHOR_MIDDLE)

	-- FIXED ROOT
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)


    self.chest = self.fixed_root:AddChild(UIAnim())
    self.chest:GetAnimState():SetBuild("chest_bg")
    self.chest:GetAnimState():SetBank("chest_bg")
    self.chest:GetAnimState():PlayAnimation("idle", true)
    self.chest:SetScale(-.7, .7, .7)
    self.chest:SetPosition(100, -75)
	self.loadout_button = self.fixed_root:AddChild(ImageButton("images/skinsscreen.xml", "loadout_button_active.tex", "loadout_button_hover.tex", "loadout_button_pressed.tex", "loadout_button_pressed.tex"))
	self.loadout_button:SetOnClick(function() TheFrontEnd:PushScreen(CharacterLoadoutSelectScreen(self.profile)) end)
	self.loadout_button:SetScale(1.05)
	self.loadout_button:SetPosition(500, -250)

   	self.trade_button = self.fixed_root:AddChild(ImageButton("images/tradescreen.xml", "trade_buttonactive.tex", "trade_buttonactive_hover.tex", "trade_button_disabled.tex", "trade_button_pressed.tex"))
   	self.trade_button:SetOnClick(function()
	   								TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
									       TheFrontEnd:PushScreen(TradeScreen(self.profile))
									       TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
									    end)
   								end)
   	self.trade_button:SetScale(1.05)
   	self.trade_button:SetPosition(500, -65)


    local collection_name = self.profile:GetCollectionName() or (subfmt(STRINGS.UI.SKINSSCREEN.TITLE, {name=TheNet:GetLocalUserName()}))
    local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"<>]]
    self.title = self.fixed_root:AddChild(TextEdit(BUTTONFONT, 45, "", BLACK))
    self.title:SetPosition(-390, RESOLUTION_Y*.43)
    self.title:SetForceEdit(true)
    self.title:SetTextLengthLimit( 30 )
    self.title:SetCharacterFilter( VALID_CHARS )
    self.title:EnableWordWrap(false)
    self.title:EnableScrollEditWindow(true)
    self.title:SetTruncatedString(collection_name, 300, 30, true)
    self.title.OnTextEntered = function()
    	self.profile:SetCollectionName(self.title:GetString())
    end

    self:BuildInventoryList()
    self:UpdateInventoryList()

    self:BuildDetailsPanel()

    if not TheInput:ControllerAttached() then
    	self.exit_button = self.fixed_root:AddChild(TEMPLATES.BackButton(function() self:Quit() end))

    	self.exit_button:SetPosition(-RESOLUTION_X*.415, -RESOLUTION_Y*.505 + BACK_BUTTON_Y )
  	else
  		self.loadout_button:SetPosition(500, -240)
  	end

    self.details_panel:Hide()

	--Note(Peter): fix
	--self.default_focus = self.list_widgets[1]

	self.letterbox = self:AddChild(TEMPLATES.ForegroundLetterbox())
end


function SkinsScreen:UnselectAll()
	if self.list_widgets then
		for i = 1, #self.list_widgets do
			self.list_widgets[i]:Unselect()
		end
	end
end


local RARITY_POS_LONE = -206
local RARITY_POS_SET = -196
local SET_POS_SET = -217

-- Update the details panel when an item is clicked
function SkinsScreen:OnItemSelect(type, item_type, item_id, itemimage)
	--print( "OnItemSelect", type, item_type, item_id, itemimage )

	if type == nil or item_type == nil then
		self.details_panel:Hide()
		self.dressup_hanger:Show()
		return
	end

	self.current_item_type = item_type

	self.dressup_hanger:Hide()

	local buildfile = GetBuildForItem(item_type)

	if type == "base"  then
		self.details_panel.shadow:SetScale(.4)
	elseif type == "body" then
		self.details_panel.shadow:SetScale(.55)
	else
		if type == "item" then
			self.details_panel.shadow:SetScale(.7)
		else
			self.details_panel.shadow:SetScale(.6)
		end
	end

	self.details_panel.image:GetAnimState():OverrideSkinSymbol("SWAP_ICON", buildfile, "SWAP_ICON")

	local nameStr = GetSkinName(item_type)
	local usable_on = GetSkinUsableOnString(item_type)

	self.details_panel.name:SetTruncatedString(nameStr, 220, 50, true)
	self.details_panel.name:SetColour(unpack(GetColorForItem(item_type)))
	if usable_on ~= "" then
		self.details_panel.name.show_help = true
		self.details_panel.name:SetHoverText(usable_on, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 35, colour = {1,1,1,1}})
		self.details_panel.image:SetHoverText(usable_on, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 15, colour = {1,1,1,1}})
	else
		self.details_panel.name.show_help = nil
		self.details_panel.name:ClearHoverText()
		self.details_panel.image:ClearHoverText()
	end

    self.details_panel.description:SetMultilineTruncatedString(GetSkinDescription(item_type), 7, 180, 60, true)

	self.details_panel.rarity:SetString(GetModifiedRarityStringForItem(item_type))
	self.details_panel.rarity:SetColour(unpack(GetColorForItem(item_type)))

	self.details_panel.set_info_btn.show_help = nil

	if IsItemInCollection(item_type) then
		self.details_panel.set_title:Show()

		if TheInput:ControllerAttached() then
			self.details_panel.set_info_btn:Hide()
			self.details_panel.set_info_btn.show_help = true
		else
			self.details_panel.set_info_btn:Show()
		end

		self.details_panel.rarity:SetPosition(0, RARITY_POS_SET)

		if IsItemIsReward(item_type) then
			self.details_panel.set_title:SetString(STRINGS.SET_NAMES[item_type] .. " " .. STRINGS.UI.SKINSSCREEN.BONUS )

			self.details_panel.set_info_btn.set_item_type = item_type --save it for the click press
		else
			--deprecated old code
			--local position,total,set_item_type = GetSkinSetData(item_type)
			--self.details_panel.set_title:SetString(STRINGS.SET_NAMES[set_item_type] .. " " .. STRINGS.UI.SKINSSCREEN.SET_PROGRESS)

			--self.details_panel.set_info_btn.set_item_type = set_item_type --save it for the click press
		end
	else
		self.details_panel.set_title:Hide()
		self.details_panel.set_info_btn:Hide()

		self.details_panel.rarity:SetPosition(0, RARITY_POS_LONE)
	end

	self.details_panel:Show()
end

function SkinsScreen:BuildDetailsPanel()

    self.details_frame = self.fixed_root:AddChild(TEMPLATES.CurlyWindow(10, 450, .6, .6, 39, -25))
    self.details_frame:SetPosition(-400,0,0)

	self.details_bg = self.details_frame:AddChild(Image("images/serverbrowser.xml", "side_panel.tex"))
	self.details_bg:SetScale(.66, .72)
	self.details_bg:SetPosition(5, 8)

	self.dressup_hanger = self.details_bg:AddChild(Image("images/lobbyscreen.xml", "customization_coming_imageonwood.tex"))
	self.dressup_hanger:SetScale(1, 1)
	self.dressup_hanger:SetPosition(0, 0)

	self.details_panel = self.fixed_root:AddChild(Widget("details-widget"))
    self.details_panel:SetPosition(-400, -0, 0)

    self.details_panel.shadow = self.details_panel:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	self.details_panel.shadow:SetPosition(0, 45)
	self.details_panel.shadow:SetScale(.8)

	self.details_panel.image = self.details_panel:AddChild(UIAnim())
	self.details_panel.image:GetAnimState():SetBuild("frames_comp")
	self.details_panel.image:GetAnimState():SetBank("frames_comp")
	self.details_panel.image:GetAnimState():Hide("frame")
	self.details_panel.image:GetAnimState():Hide("NEW")
	self.details_panel.image:GetAnimState():PlayAnimation("idle_on")
	self.details_panel.image:SetPosition(0, 130)
	self.details_panel.image:SetScale(1.65)

	self.details_panel.name = self.details_panel:AddChild(Text(TALKINGFONT, 30, "name", {0, 0, 0, 1}))
	self.details_panel.name:SetPosition(1, -7)

    self.details_panel.upper_horizontal_line = self.details_panel:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.details_panel.upper_horizontal_line:SetScale(.55)
    self.details_panel.upper_horizontal_line:SetPosition(0, -25, 0)

	self.details_panel.description = self.details_panel:AddChild(Text(NEWFONT, 20, "lorem ipsum dolor sit amet", {0, 0, 0, 1}))
    self.details_panel.description:SetPosition(0, -100)

	self.details_panel.lower_horizontal_line = self.details_panel:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.details_panel.lower_horizontal_line:SetScale(.55)
    self.details_panel.lower_horizontal_line:SetPosition(0, -175, 0)


	self.details_panel.rarity = self.details_panel:AddChild(Text(TALKINGFONT, 20, "Common Item", {0, 0, 0, 1}))
	self.details_panel.rarity:SetPosition(0, RARITY_POS_SET)
	self.details_panel.set_title = self.details_panel:AddChild(Text(NEWFONT, 20, "Set Progress", {0, 0, 0, 1}))
	self.details_panel.set_title:SetPosition(0, SET_POS_SET)

	--self.details_panel.set_info_btn = self.details_panel:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "steam.tex", "", false, false, function() if data.netid ~= nil then TheNet:ViewNetProfile(data.netid) end end ))

	self.details_panel.set_info_btn = self.details_panel:AddChild(ImageButton())
	self.details_panel.set_info_btn:SetPosition(0,-250)
    self.details_panel.set_info_btn:SetScale(0.6,0.6)
    self.details_panel.set_info_btn:SetText(STRINGS.UI.SKINSSCREEN.SET_INFO)
    self.details_panel.set_info_btn:SetOnClick(
		function()
			self.set_info_screen = SetPopupDialog( self.details_panel.set_info_btn.set_item_type )
			TheFrontEnd:PushScreen(self.set_info_screen)
		end
	)
    self.details_panel.set_info_btn:Hide()
end

function SkinsScreen:BuildInventoryList()
	self.inventory_list = self.fixed_root:AddChild(Widget("container"))
	self.inventory_list:SetPosition(100, 100)

    self.inventory_list_frame = self.inventory_list:AddChild(TEMPLATES.CurlyWindow(68, 260, .6, .6, 39, -25))
    self.inventory_list_frame:SetPosition(-6,-8,0)

    self.scroll_list = self.inventory_list:AddChild( TrueScrollList(
            {screen = self},
            SkinGridListConstructor,
            UpdateSkinGrid,
			-200, -150, 400, 300,
            20
            )
        )

	self.list_widgets = self.scroll_list:GetListWidgets()
end

function SkinsScreen:UpdateInventoryList()
	self:GetSkinsList()
	self.scroll_list:SetItemsData(self.skins_list)
end


function SkinsScreen:Quit()
	--print("Setting collectiontimestamp from skinsscreen:Quit", self.timestamp)
	self.profile:SetCollectionTimestamp(self.timestamp)

	TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
        TheFrontEnd:PopScreen()
        TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
    end)
end

function SkinsScreen:OnBecomeActive()
	if not self.sorry_popup and not TheInventory:HasSupportForOfflineSkins() and (not TheNet:IsOnlineMode() or TheFrontEnd:GetIsOfflineMode()) then
		--The game is offline, don't show any inventory
		self.skins_list = {}
		self.scroll_list:SetItemsData(self.skins_list)

		--now open a popup saying "sorry"
		self.sorry_popup = PopupDialogScreen(STRINGS.UI.SKINSSCREEN.SORRY, STRINGS.UI.SKINSSCREEN.OFFLINE,
			{ {text=STRINGS.UI.POPUPDIALOG.OK, cb = function() TheFrontEnd:PopScreen() end}  })
		TheFrontEnd:PushScreen(self.sorry_popup)

	elseif not self.sorry_popup then
		SkinsScreen._base.OnBecomeActive(self)
		if self.set_info_screen == nil and self.usable_popup == nil then
			-- We don't have a saved popup, which means the game is online. Go ahead and activate it.
			if not self.no_item_popup and #self.full_skins_list == 0 then
				self.no_item_popup = PopupDialogScreen(STRINGS.UI.SKINSSCREEN.NO_ITEMS_TITLE, STRINGS.UI.SKINSSCREEN.NO_ITEMS, { {text=STRINGS.UI.POPUPDIALOG.OK, cb = function() TheFrontEnd:PopScreen() end} })
				TheFrontEnd:PushScreen(self.no_item_popup)
			end

			if self.exit_button then
	    		self.exit_button:Enable()
			end

			self.leaving = nil

			-- If we came from the tradescreen, we need to update the inventory list
    		self:UpdateInventoryList()
    		self:OnItemSelect() --empty params, to go back to the default hanger
    	end
    	self.set_info_screen = nil
    	self.usable_popup = nil
	else
		-- This triggers when the "sorry" popup closes. Just quit.
		self:Quit()
	end

end


function SkinsScreen:GetSkinsList()

    self.timestamp = 0 --legacy code unsupported
	self.skins_list = GetInventorySkinsList( true )

	-- Keep a copy so we can change the skins_list later (for filters)
	self.full_skins_list = CopySkinsList(self.skins_list)
end


local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0
local STICK_SCROLL_REPEAT_TIME = .25

function SkinsScreen:OnControl(control, down)

    if SkinsScreen._base.OnControl(self, control, down) then return true end

    if not self.no_cancel and
    	not down and control == CONTROL_CANCEL then
		self:Quit()
		return true
    end

    if  TheInput:ControllerAttached() then

    	if not down and control == CONTROL_MENU_START then
    		TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
		        TheFrontEnd:PushScreen(CharacterLoadoutSelectScreen(self.profile))
		        TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
		    end)
			return true
		elseif not down and control == CONTROL_MENU_MISC_2 then
			TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
		       TheFrontEnd:PushScreen(TradeScreen(self.profile))
		        TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
		    end)
			return true
		elseif not down and control == CONTROL_MENU_MISC_1 and self.details_panel.set_info_btn.show_help then
			self.details_panel.set_info_btn.onclick()
			return true
		elseif not down and control == CONTROL_MENU_MISC_1 and self.details_panel.name.show_help then
			local usable_on = GetSkinUsableOnString(self.current_item_type, true)
			local popup = PopupDialogScreen(STRINGS.UI.SKINSSCREEN.USABLE_INFO_TITLE, usable_on,
				{
					{text=STRINGS.UI.SKINSSCREEN.OK, cb = function()
						TheFrontEnd:PopScreen()
					end}
				})
			self.usable_popup = true
			TheFrontEnd:PushScreen(popup)

			return true
		end
    end

   	if down then
	 	if control == CONTROL_SCROLLBACK then
            self:ScrollBack(control)
            return true
        elseif control == CONTROL_SCROLLFWD then
        	self:ScrollFwd(control)
            return true
       	end
	end
end

function SkinsScreen:ScrollBack(control)
	if not self.scroll_list.repeat_time or self.scroll_list.repeat_time <= 0 then
       	self.scroll_list:Scroll(-1)
       	--if self.scroll_list.page_number ~= pageNum then
       	--	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
       	--end
        self.scroll_list.repeat_time =
            TheInput:GetControlIsMouseWheel(control)
            and MOUSE_SCROLL_REPEAT_TIME
            or (control == CONTROL_SCROLLBACK and SCROLL_REPEAT_TIME)
            or (control == CONTROL_PREVVALUE and STICK_SCROLL_REPEAT_TIME)
    end
end

function SkinsScreen:ScrollFwd(control)
	if not self.scroll_list.repeat_time or self.scroll_list.repeat_time <= 0 then
        self.scroll_list:Scroll(1)
		--if self.scroll_list.page_number ~= pageNum then
       	--	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
       	--end
        self.scroll_list.repeat_time =
            TheInput:GetControlIsMouseWheel(control)
            and MOUSE_SCROLL_REPEAT_TIME
            or (control == CONTROL_SCROLLFWD and SCROLL_REPEAT_TIME)
            or (control == CONTROL_NEXTVALUE and STICK_SCROLL_REPEAT_TIME)
    end
end

function SkinsScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if not self.no_cancel then
    	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SKINSSCREEN.BACK)
    end

   	table.insert(t, self.scroll_list:GetHelpText())

   	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.SKINSSCREEN.LOADOUT)

   	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.SKINSSCREEN.TRADE)

   	if self.details_panel.set_info_btn.show_help then
   		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SKINSSCREEN.SET_INFO)
   	end

   	if self.details_panel.name.show_help then
   		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.SKINSSCREEN.USABLE_INFO)
	end

    return table.concat(t, "  ")
end

return SkinsScreen
