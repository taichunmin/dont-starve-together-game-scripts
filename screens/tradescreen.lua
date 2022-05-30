local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local UIAnimButton = require "widgets/uianimbutton"
local Text = require "widgets/text"
local SkinCollector = require "widgets/skincollector"
local Image = require "widgets/image"
local ItemSelector = require "widgets/itemselector"
local ItemImage = require "widgets/itemimage"
local ImagePopupDialogScreen = require "screens/imagepopupdialog"
local PopupDialogScreen = require "screens/redux/popupdialog"
local WoodenSignPopup = require "screens/redux/woodensignpopup"
local MouseTracker = require "widgets/mousetracker"
local RecipeList = require "widgets/recipelist"
local easing = require "easing"
local CrowGameScreen = require "screens/crowgamescreen"
local SnowbirdGameScreen = require "screens/snowbirdgamescreen"
local RedbirdGameScreen = require "screens/redbirdgamescreen"
local CrowKidGameScreen = require "screens/crowkidgamescreen"
local KitcoonGameScreen = require "screens/kitcoongamescreen"
local BirdInteractScreen = require "screens/redux/birdinteractscreen"

require("skinsfiltersutils")
require("skinstradeutils")

-- Constant values
local MAX_TRADE_ITEMS = 9
local TRANSITION_ANIM = "large"
local DEBUG_MODE = BRANCH == "dev"

local IS_OPEN_FOR_BUSINESS = true

local function FindFirstEmptySlot(selections, num_items)
	local first = nil
	for i=1,num_items do
		if selections[i] == nil then
			first = i
			break
		end
	end
	return first
end

local function FindLastFullSlot(selections, num_items)
	local last = nil
	for i=num_items,1,-1 do
		if selections[i] ~= nil then
			last = i
			break
		end
	end
	return last
end

local function CountItemsInTable(item, table)
	local count = 0
	for k,v in pairs(table) do
		if v.item == item then
			count = count + 1
		end
	end

	return count
end

local ItemEndMove = function(owner, i)
	owner.moving_items_list[i] = nil
	--print("Item ", i, " finished moving")
	if next(owner.moving_items_list) == nil then
		--print("All items finished moving, clearing moving items list")
		owner.popup:EnableInput()
	end

	owner:RefreshUIState()
end

local ItemsInUse = function( selected_items, moving_items_list )
	local items_in_use = {}
	for i,item in pairs( selected_items ) do
		items_in_use[i] = item
	end
	if moving_items_list then
		for _,moving_item in pairs( moving_items_list ) do
			assert( items_in_use[moving_item.target_slot_index] == nil )
			items_in_use[moving_item.target_slot_index] = moving_item.item
		end
	end
	return items_in_use
end

local TradeScreen = Class(Screen, function(self, prev_screen, profile)
	Screen._ctor(self, "TradeScreen")

	--print("Is offline?", TheNet:IsOnlineMode() or "nil", TheFrontEnd:GetIsOfflineMode() or "nil")

    -- DISABLE SPECIAL RECIPES
	-- self.recipes = TheItems:GetRecipes()

	self.profile = profile
	self:DoInit()
	self.prevScreen = prev_screen
end)

function TradeScreen:DoInit()
	TheFrontEnd:GetGraphicsOptions():DisableStencil()
	TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()

	TheInputProxy:SetCursorVisible(true)

	-- FIXED ROOT
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.panel_bg = self.fixed_root:AddChild(TEMPLATES.old.NoPortalBackground())
    self.menu_bg = self.fixed_root:AddChild(TEMPLATES.old.LeftGradient())

    if not TheInput:ControllerAttached() then
    	self.exit_button = self.fixed_root:AddChild(TEMPLATES.old.BackButton(function() self:Quit() end))

    	self.exit_button:SetPosition(-RESOLUTION_X*.415, -RESOLUTION_Y*.505 + BACK_BUTTON_Y )
  	end

	if IsNotConsole() and PLATFORM ~= "WIN32_RAIL" then
  		self.market_button = self.fixed_root:AddChild(TEMPLATES.old.IconButton("images/button_icons.xml", "steam.tex", "", false, false,
    												function() VisitURL("https://steamcommunity.com/market/search?appid=322330") end
    											))
  		self.market_button:SetPosition(RESOLUTION_X*.45, -RESOLUTION_Y*.505 + BACK_BUTTON_Y)
  	end

	self.current_num_trade_items = 9
	self.frames_height_adjustment = 0

  	self:DoInitInventoryAndMachine()
 	-- DISABLE SPECIAL RECIPES
    -- self:DoInitSpecials()
	self:DoInitState()

	self.warning_timeout = 0

	self.default_focus = self.popup.list_widgets[1]


	self:RefreshUIState()

    -- Skin collector
    self.innkeeper = self.fixed_root:AddChild(SkinCollector( self.popup:GetNumFilteredItems() )) --this needs to happen after RefreshUIState was called so that we have the filtered list
    self.innkeeper:SetPosition(410, -390)
    if IS_OPEN_FOR_BUSINESS then
        self.innkeeper:Appear()
    else
        self.innkeeper:Hide()
	end

	self.crow_anim = self.fixed_root:AddChild(UIAnimButton("crow", "crow_build", "idle", "caw" ))
	self.crow_anim:SetLoop("idle", true)
	self.crow_anim:SetLoop("caw", true)
	self.crow_anim.animstate:SetTime(math.random())
	self.crow_anim.animstate:SetDeltaTimeMultiplier(0.7 + 0.3*math.random())
	self.crow_anim:SetPosition(-130, -220)
	self.crow_anim:SetScale(0.5)
	self.crow_anim:SetOnClick( function()
		if not self.quitting then
			TheFrontEnd:GetSound():PlaySound("dontstarve/birds/takeoff_crow")
			TheFrontEnd:FadeToScreen( self, function() return CrowGameScreen(self.profile) end, nil )
			self.innkeeper:Sleep()
		end
	end )

	self.redbird_anim = self.fixed_root:AddChild(UIAnimButton("crow", "robin_build", "idle", "caw" ))
	self.redbird_anim:SetLoop("idle", true)
	self.redbird_anim:SetLoop("caw", true)
	self.redbird_anim.animstate:SetTime(math.random())
	self.redbird_anim.animstate:SetDeltaTimeMultiplier(0.7 + 0.3*math.random())
	self.redbird_anim:SetPosition(130, -220)
	self.redbird_anim:SetScale(0.5)
	self.redbird_anim:SetOnClick( function()
		if not self.quitting then
			TheFrontEnd:GetSound():PlaySound("dontstarve/birds/takeoff_crow")
			TheFrontEnd:FadeToScreen( self, function() return RedbirdGameScreen(self.profile) end, nil )
			self.innkeeper:Sleep()
		end
	end )

	self.snowbird_anim = self.fixed_root:AddChild(UIAnimButton("crow", "robin_winter_build", "idle", "caw" ))
	self.snowbird_anim:SetLoop("idle", true)
	self.snowbird_anim:SetLoop("caw", true)
	self.snowbird_anim.animstate:SetTime(math.random())
	self.snowbird_anim.animstate:SetDeltaTimeMultiplier(0.7 + 0.3*math.random())
	self.snowbird_anim:SetPosition(-540, 218)
	self.snowbird_anim:SetScale(0.5)
	self.snowbird_anim:SetOnClick( function()
		if not self.quitting then
			TheFrontEnd:GetSound():PlaySound("dontstarve/birds/takeoff_junco")
			TheFrontEnd:FadeToScreen( self, function() return SnowbirdGameScreen(self.profile) end, nil )
			self.innkeeper:Sleep()
		end
	end )

	self.crowkid_anim = self.fixed_root:AddChild(UIAnimButton("crow_kids", "crow_kids", "idle", "taunt" ))
	self.crowkid_anim:SetLoop("idle", true)
	self.crowkid_anim:SetLoop("taunt", true)
	self.crowkid_anim.animstate:SetTime(math.random())
	self.crowkid_anim.animstate:SetDeltaTimeMultiplier(0.7 + 0.3*math.random())	
	self.crowkid_anim:SetPosition(-360, -340)
	self.crowkid_anim:SetScale(0.5)
	self.crowkid_anim:SetOnClick( function()
		if not self.quitting then
			TheFrontEnd:GetSound():PlaySound("summerevent/characters/crowkid/neutral")
			TheFrontEnd:FadeToScreen( self, function() return CrowKidGameScreen(self.profile) end, nil )
			self.innkeeper:Sleep()
		end
	end )
	
	self.kitcoon_anim = self.fixed_root:AddChild(UIAnimButton("kitcoon_nametag", "kitcoon_nametag", "idle", "idle" ))
	self.kitcoon_anim:SetLoop("idle", true)
	self.kitcoon_anim:SetPosition(220, 292)
	self.kitcoon_anim:SetScale(0.5)
	self.kitcoon_anim:SetOnClick( function()
		if not self.quitting then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/collect_resource")
			TheFrontEnd:FadeToScreen( self, function() return KitcoonGameScreen(self.profile) end, nil )
			self.innkeeper:Sleep()
		end
	end )
	
    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())
end

function TradeScreen:DoInitInventoryAndMachine()

  	-- Hanging sign
    self.sign_bg = self.fixed_root:AddChild(Image("images/tradescreen.xml", "hanging_sign_brackets.tex"))
    self.sign_bg:SetScale(.65, .65, .65)
    self.sign_bg:SetPosition(-438, 40)
    self.sign_bg:SetClickable(false)

	-- Item Selector
	self.popup = self.fixed_root:AddChild(ItemSelector(self.fixed_root, self, self.profile))
	self.popup:SetPosition(-435, -100)

	local machine_scale = 0.62

  	-- Add the claw machine
  	self.claw_machine_bg = self.fixed_root:AddChild(UIAnim())
  	self.claw_machine_bg:GetAnimState():SetBuild("swapshoppe_bg")
    self.claw_machine_bg:GetAnimState():SetBank("shop_bg")
    self.claw_machine_bg:SetScale(machine_scale)
    self.claw_machine_bg:SetPosition(0, 65)

-- DISABLE SPECIAL RECIPES
--[[
	--Specials recipe list
	self.specials_list = self.fixed_root:AddChild(RecipeList(
		function(data)
			if self.specials_mode then
				self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.SPECIALRECIPE, data.rarity, nil, data.number)
				self.sold_out = data.sold_out
				self:Reset()
			end
		end)
	)
	self.specials_list:SetData( self.recipes )
	self.specials_list:SetHintStrings(STRINGS.UI.TRADESCREEN.PREV, STRINGS.UI.TRADESCREEN.NEXT)
	self.specials_list:Hide()
--]]


	--Machine tiles: frames_container is in the root so that we can order all the layers correctly and the hover text (while still allowing the specials_list to not be scaled)
	self.frames_container = self.fixed_root:AddChild(Widget("frames_container"))
    self.frames_container:SetScale(machine_scale*1.75)
    self.frames_container:SetPosition(5, 0)
	self.frames_single = {}
	for i=1,MAX_TRADE_ITEMS do
		self.frames_single[i] = self.frames_container:AddChild(ItemImage(self, nil, nil, 0, 0, function() self:RemoveSelectedItem(i) end ))
		self.frames_single[i]:DisableSelecting()
	end
	self:ResetFrameTiles()

	--Special recipe sold out sign
    self.sold_out_sign = self.fixed_root:AddChild(Image("images/tradescreen.xml", "sold_out_sign.tex"))
    self.sold_out_sign:SetPosition(5, 0, 0)
    self.sold_out_sign:SetScale(.8)
    self.sold_out_sign.text = self.sold_out_sign:AddChild(Text(NEWFONT_OUTLINE, 70, STRINGS.UI.TRADESCREEN.SOLD_OUT, GOLD))
    self.sold_out_sign.text:SetRotation(-16)
    self.sold_out_sign.text:SetPosition(0, -35)
   	self.sold_out_sign:Hide()

  	self.claw_machine = self.fixed_root:AddChild(UIAnim())
  	self.claw_machine:GetAnimState():SetBuild("swapshoppe")
    self.claw_machine:GetAnimState():SetBank("shop")
    self.claw_machine:SetScale(machine_scale)
    self.claw_machine:SetPosition(0, 65)

	-- DISABLE SPECIAL RECIPES
	--[[self.special_lightfx = self.claw_machine:AddChild(UIAnim())
	self.special_lightfx:GetAnimState():SetBuild("swapshoppe_special_lightfx")
	self.special_lightfx:GetAnimState():SetBank("shop_lights")
	--self.special_lightfx:GetAnimState():PlayAnimation("turn_on")
	self.special_lightfx:GetAnimState():PlayAnimation("flicker_loop", true)]]


	self:PlayMachineAnim("idle_empty", true)

    -- Title (Trade Inn sign)
	if PLATFORM == "WIN32_RAIL" then
		self.title = self.fixed_root:AddChild(Image("images/tradescreen_overflow.xml", "TradeInnSign_cn.tex"))
	else
		self.title = self.fixed_root:AddChild(Image("images/tradescreen_overflow.xml", "TradeInnSign.tex"))
	end
  	self.title:SetScale(.66)
  	self.title:SetPosition(0, 305)

  	-- joystick
    self.joystick = self.claw_machine:AddChild(MouseTracker("joystick", function() self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.JOYSTICK) end))

    local jx = 5
    local jy = -550
    self.joystick:SetPosition(jx, jy)


    self.item_name = self.fixed_root:AddChild(Text(UIFONT, 45))
    self.item_name:SetHAlign(ANCHOR_MIDDLE)
    self.item_name:SetPosition(0, 165, 0)
    self.item_name:SetColour(1, 1, 1, 1)
	self.item_name:Hide()


	-- the buttons aren't used on console but don't hide them since they're part of the decor and they add the
	-- button prompts to the help bar; hide the text only so players don't try to navigate to them
	local reset_button_text = STRINGS.UI.TRADESCREEN.RESET
	local trade_button_text = STRINGS.UI.TRADESCREEN.TRADE

    -- reset button bg
    self.resetbtn = self.claw_machine:AddChild(TEMPLATES.old.AnimTextButton("button",
    											{idle = "idle_red", over = "up_red", disabled = "down_red"},
    											IsConsole() and 1 or {x=1.0, y=1, z=1},
    											function()
    												self:Reset()
    											end,
    											reset_button_text,
    											30))
    self.resetbtn:SetPosition(-200, -540)

    -- trade button bg
    self.tradebtn = self.claw_machine:AddChild(TEMPLATES.old.AnimTextButton("button",
    											{idle = "idle_green", over = "up_green", disabled = "down_green"},
    											1,
    											function()
    												self:Trade()
    											end,
    											trade_button_text,
    											30))
    self.tradebtn:SetPosition(208, -540)

    self.selected_items = {}
	self.last_added_item_index = nil

	self.moving_items_list = {}
end

-- DISABLE SPECIAL RECIPES
--[[function TradeScreen:DoInitSpecials()

	self.specials_button = self.fixed_root:AddChild(UIAnimButton("button_special", "button_weeklyspecial",
											nil, "hover", "pressed", "pressed", nil ))
	-- Looping anims must be inialized to nil and then set separately:
	self.specials_button:SetIdleAnim("flicker2_loop", true)
	self.specials_button:SetSelectedAnim("flicker2_loop", true)
	self.specials_button:SetOnClick( function()
		self:ToggleSpecialsMode()
	end)

	self.specials_button:SetFont(TALKINGFONT)
	self.specials_button:SetDisabledFont(TALKINGFONT)
	self.specials_button:SetTextSize(50)
	self.specials_button:SetText(STRINGS.UI.TRADESCREEN.SPECIALS)
	self.specials_button:SetTextColour(WHITE)
	self.specials_button:SetTextFocusColour(WHITE)
	self.specials_button:SetTextDisabledColour(WHITE)
	self.specials_button:SetTextSelectedColour(WHITE)
	self.specials_button.text:MoveToFront()

	self.specials_button:SetScale(.5)
	self.specials_button:SetPosition(-455, -205, 0)

	self.specials_title = self.claw_machine:AddChild(Text(TALKINGFONT, 55, STRINGS.UI.TRADESCREEN.SPECIALS_TITLE, WHITE))
	self.specials_title:SetPosition(25, 373)
	self.specials_title:Hide()

	self.specials_transitionFx = self.fixed_root:AddChild(UIAnim())
	self.specials_transitionFx:GetAnimState():SetBuild("swapshoppe_special_transitionfx")
	self.specials_transitionFx:GetAnimState():SetBank("transitionfx")
	self.specials_transitionFx:SetPosition(0, -325)
	self.specials_transitionFx:SetScale(.9, 1.1, 1)
	self.specials_transitionFx:Hide()
end]]

function TradeScreen:DoInitState()
	self.machine_in_use = false		-- the machine is currently in-use, we use this to disable things and ignore input
	self.flush_items = false		-- the flush anim is programmatic so must run its own update
	self.accept_waiting = false		-- there is an item waiting to be accepted
	self.specials_mode = false		-- the machine is in special recipes mode, which changes the display + number of items in the machine
	self.sold_out = false 			-- display a recipe that is currently sold out, so all tiles are disabled
	self.transitioning = false		-- the machine is transitioning from one mode to another
end

--[[function TradeScreen:DoFocusHookups()
	for i=1,MAX_TRADE_ITEMS do
		if i+1 <= MAX_TRADE_ITEMS and math.fmod(i, 3) ~= 0 then
			self.frames_single[i]:SetFocusChangeDir(MOVE_RIGHT, self.frames_single[i+1])
		end

		if i-1 > 0 and math.fmod(i, 3) ~= 1 then
			self.frames_single[i]:SetFocusChangeDir(MOVE_LEFT, self.frames_single[i-1])
		end

		if i-3 > 0 then
			self.frames_single[i]:SetFocusChangeDir(MOVE_UP, self.frames_single[i-3])
		end

		if i+3 <= MAX_TRADE_ITEMS then
			self.frames_single[i]:SetFocusChangeDir(MOVE_DOWN, self.frames_single[i+3])
		end
	end
end]]

function TradeScreen:ToggleSpecialsMode()
	self.innkeeper:Snap()
	self.transitioning = true
	self:RefreshUIState()

	self.snap_sound = self.inst:DoTaskInTime(18*FRAMES, function()
		TheFrontEnd:GetSound():PlaySound("dontstarve/characters/skincollector/snap", "skincollector_snap")

		if not self.specials_mode then
			TheFrontEnd:GetSound():PlaySound("dontstarve/music/shop_specials_open", "tradescreentransition")
		else
			TheFrontEnd:GetSound():PlaySound("dontstarve/music/shop_specials_closed", "tradescreentransition")
		end
	end)

	-- This is delayed until partway through the snap anim.
	self.snap_task = self.inst:DoTaskInTime(28*FRAMES, function()
		self.specials_transitionFx:Show()
		self.specials_transitionFx:GetAnimState():PlayAnimation(TRANSITION_ANIM)

		TheFrontEnd:GetSound():PlaySound("dontstarve/characters/skincollector/magicpoof", "poof")

		self.transitioning = false

		if not self.specials_mode then
			-- Update button
			self.specials_button:SetText(STRINGS.UI.TRADESCREEN.NOSPECIALS)
			self.specials_button:SetIdleAnim("flicker_loop", true)
			self.specials_button:SetSelectedAnim("flicker_loop", true)

			-- Update state
       		self.specials_mode = true

			self.current_num_trade_items = 6
			self.frames_height_adjustment = -100

			self.talk_task = self.inst:DoTaskInTime(20*FRAMES, function() self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.SPECIALS) end)

       	else
       		-- Update button
       		self.specials_button:SetText(STRINGS.UI.TRADESCREEN.SPECIALS)
       		self.specials_button:SetIdleAnim("flicker2_loop", true)
       		self.specials_button:SetSelectedAnim("flicker2_loop", true)

       		-- Update state
       		self.specials_mode = false
       		self.sold_out = false

			self.current_num_trade_items = MAX_TRADE_ITEMS
			self.frames_height_adjustment = 0
       	end

		self:Reset() -- clear the current selections

		-- Update UI
       	self:RefreshUIState()
    end)
end

function TradeScreen:PlayMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PlayAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PlayAnimation(name, loop)
end
function TradeScreen:PushMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PushAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PushAnimation(name, loop)
end

function TradeScreen:CancelPendingMoves()
	for k,v in pairs(self.moving_items_list) do
		v:Kill()
	end
	self.moving_items_list = {}
end

function TradeScreen:Reset()

	self.item_name:Hide()

	self.joystick:Stop()


	self.item_name_displayed = nil

	if self.innkekeper then
		self.innkeeper:ClearSpeech()
	end

	TheFrontEnd:GetSound():KillSound("idle_sound")

	-- Kill sound tasks just in case something gets out of sequence somehow
	if self.skin_in_task then
		self.skin_in_task:Cancel()
		self.skin_in_task = nil
	end

	if self.idle_sound_task then
		self.idle_sound_task:Cancel()
		self.idle_sound_task = nil
	end

	if self.claw_machine:GetAnimState():IsCurrentAnimation("skin_in") or
		self.claw_machine:GetAnimState():IsCurrentAnimation("idle_skin") then

		self:PlayMachineAnim("skin_off", false)
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/skin_off")

		self.reset_started = true
	else
		if not self.claw_machine:GetAnimState():IsCurrentAnimation("skin_off") then --if we're playing "skin_off", we'll reset in OnUpdate
			self:FinishReset(true)
		end
	end
end

function TradeScreen:FinishReset(move_items)
	self.claw_machine:GetAnimState():OverrideSkinSymbol("SWAP_ICON", "shoppe_frames", "")
	self.claw_machine:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", "")
	self:PlayMachineAnim("idle_empty", true)

	if move_items then
		self:CancelPendingMoves()

		for i=1,MAX_TRADE_ITEMS do
			if self.frames_single[i].name then
				self.moving_items_list[i] = TEMPLATES.old.MovingItem( self.frames_single[i].name,
														i,
														self.frames_single[i]:GetWorldPosition(),
														self.popup.scroll_list.position_marker:GetWorldPosition(),
														.65 * self.fixed_root:GetScale().x,
														.5 * self.fixed_root:GetScale().x )
				self.moving_items_list[i].Move(function() ItemEndMove(self, i) end)
			end
		end
	end

	self:ResetFrameTiles()

	if self.joystick.started_ever then
		self.joystick:Start()
	end

	-- Clear all clothing data
	self.selected_items = {}

	self.reset_started = false
	self.machine_in_use = false
	self.accept_waiting = false

	self.popup.scroll_list:ResetScroll()

	self.last_added_item_index = nil

	self:RefreshUIState()
end

function TradeScreen:EnableMachineTiles()
	for i=1,MAX_TRADE_ITEMS do
		if i <= self.current_num_trade_items then
			self.frames_single[i]:Show()
			self.frames_single[i]:Enable()
		else
			self.frames_single[i]:Disable()
			self.frames_single[i]:Hide()
		end
	end
end


function TradeScreen:DisableMachineTiles()
	for i=1,MAX_TRADE_ITEMS do
		self.frames_single[i]:Disable()
	end
end

function TradeScreen:OnBecomeActive()
    TradeScreen._base.OnBecomeActive(self)

	if self.do_nothing_on_activate then
		self.do_nothing_on_activate = false
		return
	end

	--print("**** Activate TradeScreen ****", self.specials_mode)

    if not IS_OPEN_FOR_BUSINESS then
        -- Don't get stuck in a popup showing loop.
        if not self.outtolunch_popup then
            self.outtolunch_popup = WoodenSignPopup(
                nil,
                STRINGS.UI.TRADESCREEN.TEMPORARILY_CLOSED_BODY,
                {
                    {
                        text=STRINGS.UI.TRADESCREEN.OK,
                        cb = function()
                            TheFrontEnd:PopScreen() -- close popup
                            -- close trade screen (not using Quit because we
                            -- haven't started anything and don't want the
                            -- delay).
                            TheFrontEnd:FadeBack()
                            self.quitting = true
                        end
                    }
                })
            TheFrontEnd:PushScreen(self.outtolunch_popup)
        end
        -- Always exit since we're about to quit anyway.
        return
    end

	--Note(Peter): check if the joystick will get into a weird state when the trade confirmation popup is pushed and then popped.
	if self.joystick.started_ever then
		self.joystick:Start()
	end

	self.item_name:Hide()

	self:RefreshUIState()

	if self.innkeeper then
		self.innkeeper:Wake()
	end
end

local function widget_already_processed(name, widget_list)
	for i=1,#widget_list do
		if widget_list[i].name == name then
			return true
		end
	end

	return false
end

function TradeScreen:Trade(done_warning)

	if not done_warning then
		local items_in_use = ItemsInUse( self.selected_items, self.moving_items_list )

		local warn_table = {}
		for i=1,self.current_num_trade_items do
			local numCopiesInUse = CountItemsInTable(self.frames_single[i].name, items_in_use)
			if not widget_already_processed(self.frames_single[i].name, warn_table) and ((self.popup:NumItemsLikeThis(self.frames_single[i].name) - numCopiesInUse) <= 0) then
				local widg = Widget("item"..i)

				widg.name = self.frames_single[i].name

		        widg.frame = widg:AddChild(UIAnim())
		        widg.frame:GetAnimState():SetBuild("frames_comp") -- use the animation file as the build, then override it
		        widg.frame:GetAnimState():SetBank("frames_comp") -- top level symbol from frames_comp

		        local rarity = GetRarityForItem(self.frames_single[i].name)

		        widg.frame:GetAnimState():OverrideSkinSymbol("SWAP_ICON",  GetBuildForItem(self.frames_single[i].name), "SWAP_ICON")
		        widg.frame:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(rarity))

		        widg.frame:GetAnimState():PlayAnimation("idle_on", true)
		        widg.frame:GetAnimState():Hide("NEW")

		        widg:SetScale(.5)
				table.insert(warn_table, widg)
			end
		end

		if next(warn_table) then
			local str = #warn_table > 1 and STRINGS.UI.TRADESCREEN.WARNING or STRINGS.UI.TRADESCREEN.WARNING_SINGLE
			self.warning_popup = ImagePopupDialogScreen(STRINGS.UI.TRADESCREEN.CHECK,
					warn_table,
					60, -- widget width
					5, -- spacing between widgets
					str,
					{ {text=STRINGS.UI.TRADESCREEN.OK, cb = function() TheFrontEnd:PopScreen()
																	self:Trade(true)
															end, controller_control=CONTROL_ACCEPT} ,
					  {text=STRINGS.UI.TRADESCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end, controller_control=CONTROL_CANCEL }
					})
				TheFrontEnd:PushScreen(self.warning_popup)
			return
		end
	end

	self.machine_in_use = true

	self:PlayMachineAnim("claw_in", false)
	self.joystick:Stop()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/claw_in")

	self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.TRADE)

	--hide all the hover text
	for i=1,MAX_TRADE_ITEMS do
		self.frames_single[i]:ClearHoverText()
	end


	-- TODO: stop hard-coding the rarity to the next one up. We should really read it out of the recipes file.
	local rarity = GetRarityForItem(self.frames_single[1].name)
	self.expected_rarity = GetNextRarity(rarity)


	self.queued_item = nil
	local items_array = {}
	local swap_name = ""

	if false then --DEBUG TESTING
		self.queued_item = "backpack_camping_orange_carrot"
	else
		if not self.specials_mode then
			local recipe_name = GetBasicRecipeMatch(self.selected_items)
			swap_name = TRADE_RECIPES[recipe_name].name

			for i=1,self.current_num_trade_items do
				table.insert(items_array, self.selected_items[i].item_id)
			end
		else
			swap_name = self.specials_list:GetRecipeName()
			local recipe_index = self.specials_list:GetRecipeIndex()

			--sort the items based on the recipe requirement
			local recipe_index = self.specials_list:GetRecipeIndex()
			local special_recipe = self.recipes[recipe_index]

			local selection_item_used = {}
			for _,restriction in pairs(special_recipe.Restrictions) do
				for index=1,self.current_num_trade_items do
					if not selection_item_used[index] then
						local matches = does_item_match_restriction( restriction, self.selected_items[index] )
						if matches then
							selection_item_used[index] = true
							table.insert(items_array, self.selected_items[index].item_id)
							break
						end
					end
				end
			end
		end

		TheItems:SwapItems(swap_name,
			items_array,
			function(success, msg, item_type) print("Item swap completed", success, msg, item_type)
				if success then
					self.queued_item = item_type
				else
					local server_error = PopupDialogScreen(STRINGS.UI.TRADESCREEN.SERVER_ERROR_TITLE, STRINGS.UI.TRADESCREEN.SERVER_ERROR_BODY,
						{
							{text=STRINGS.UI.TRADESCREEN.OK, cb =
								function()
									print("ERROR: Failed to contact the item server.", msg )
									SimReset()
								end}
						}
					)
					TheFrontEnd:PushScreen( server_error )
				end
			end
		)
	end


	self:RefreshUIState()
end

function TradeScreen:FinishTrade()
	if self.queued_item ~= nil then
		self:GiveItem(self.queued_item)
		self.queued_item = nil

		self.selected_items = {}
	end
end

function TradeScreen:GiveItem(item)
	local name = GetBuildForItem(item)

	-- Need to store a reference to this so we can start it moving when the player clicks
	self.moving_gift_item = TEMPLATES.old.MovingItem(name, self.current_num_trade_items, self.claw_machine_bg:GetWorldPosition(),
											self.popup.scroll_list.position_marker:GetWorldPosition(), 1 * self.fixed_root:GetScale().x, .5 * self.fixed_root:GetScale().x)

	table.insert(self.moving_items_list, self.moving_gift_item)

	self.gift_name = item

	self.claw_machine:GetAnimState():OverrideSkinSymbol("SWAP_ICON", name, "SWAP_ICON")
	self.claw_machine:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(GetRarityForItem(item)))
	self:PlayMachineAnim("skin_in", false)
	self:PushMachineAnim("idle_skin", true)

	-- Delay 16 frames as specified by Dany
	self.skin_in_task = self.inst:DoTaskInTime(16*FRAMES,
		function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/skin_in")
		end
	)

	-- Play this one when the skin first appears (30 frames into skin_in)
	self.idle_sound_task = self.inst:DoTaskInTime(30*FRAMES,
		function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/skin_idle", "idle_sound")
			self:DisplayItemName(self.gift_name)
			AwardFrontendAchievement("trade_inn")
		end
	)

	self.joystick:Stop()
end

function TradeScreen:DisplayItemName(gift)
	assert(not self.item_name_displayed)
	self.item_name_displayed = true

	local name_string = GetSkinName(gift)
	self.item_name:SetTruncatedString(name_string, 330, 35, true)
	self.item_name:SetColour(GetColorForItem(gift))
	self.item_name:Show()

	local str = STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.RESULT
	local rarity = GetRarityForItem(gift)
	if rarity ~= self.expected_rarity then
		str = STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.RESULT_LUCKY
	end

	self.innkeeper:Say(str, nil, name_string)

	self.expected_rarity = false
	self.accept_waiting = true
end

function TradeScreen:Quit()
	self.joystick:Stop()

	if self.skin_in_task then
		self.skin_in_task:Cancel()
		self.skin_in_task = nil
	end

	if self.idle_sound_task then
		self.idle_sound_task:Cancel()
		self.idle_sound_task = nil
	end

	if self.snap_task then
		self.snap_task:Cancel()
		self.snap_task = nil
	end

	if self.snap_sound then
		self.snap_sound:Cancel()
		self.snap_sound = nil
	end

	if self.talk_task then
		self.talk_task:Cancel()
		self.talk_task = nil
	end

	self.innkeeper:Disappear(function()
		TheFrontEnd:GetSound():KillSound("idle_sound")
	end)

	-- kill all moving stuff
	for k,v in pairs(self.moving_items_list) do
		v:Kill()
	end

	-- kill fx
	if self.special_lightfx then
		self.special_lightfx:Kill()
	end

	-- Time the fade to start right as he gets off screen.
	-- (disappear anim is 45 frames long)
	self.inst:DoTaskInTime(15*FRAMES, function()
        TheFrontEnd:FadeBack()
	end)

	self.quitting = true

	self:RefreshUIState()
end

-- RemoveSelectedItem is called when the player clicks on an item in the machine.
function TradeScreen:RemoveSelectedItem(number)
	--print( "TradeScreen:RemoveSelectedItem", number )
	if self.machine_in_use then
		return
	end

	if self.frames_single[number].name then -- only do the move if there's actually an item there
		local start_scale = .65
		if self.frames_single[number].focus then
			start_scale = .78
		end
		local moving_item = TEMPLATES.old.MovingItem(self.frames_single[number].name,
													number,
													self.frames_single[number]:GetWorldPosition(),
													self.popup.scroll_list.position_marker:GetWorldPosition(),
													start_scale * self.fixed_root:GetScale().x, .5 * self.fixed_root:GetScale().x)

		local idx = #self.moving_items_list + 1
		moving_item.Move(function() ItemEndMove(self, idx) end)

		--take the item out of the selected_items list and store it in the moving items list
		moving_item.item = self.selected_items[number]
		self.selected_items[number] = nil

		table.insert(self.moving_items_list, moving_item)

		self.last_added_item_index = nil
		self.frames_single[number]:SetItem(nil, nil, nil)

		self:RefreshUIState()
	end
end

function TradeScreen:GetLastAddedItem()
	return self.last_added_item_index
end

-- AddSelectedItem is called from the ItemSelector when an item in the inventory list is clicked.
function TradeScreen:StartAddSelectedItem(item, start_pos)

	if not self.selected_items then
		self.selected_items = {}
	end

	local items_in_use = ItemsInUse( self.selected_items, self.moving_items_list )

	local empty_slot = FindFirstEmptySlot(items_in_use, self.current_num_trade_items)
	if item and item.item and empty_slot ~= nil then -- we don't add an item unless there's an empty slot

		local slot = self.frames_single[empty_slot]
		--print("Slot position is ", slot:GetPosition(), slot:GetWorldPosition())

		local moving_item = TEMPLATES.old.MovingItem(item.item, empty_slot,
												start_pos,
												slot:GetWorldPosition(),
												.56 *  self.fixed_root:GetScale().x,
												.65 *  self.fixed_root:GetScale().x)

		local idx = #self.moving_items_list + 1
		moving_item.Move(function() ItemEndMove(self, idx) self:AddSelectedItem(item) end ) -- start the item moving toward the empty slot
		moving_item.item = item
		table.insert(self.moving_items_list, moving_item)

		items_in_use = ItemsInUse( self.selected_items, self.moving_items_list ) --update the items in use now that we've started moving one

		item.target_index = empty_slot
		local numCopiesInUse = CountItemsInTable(item.item, items_in_use)
		item.count = self.popup:NumItemsLikeThis(item.item)-numCopiesInUse
		if item.count == 0 then
			item.last_item_warning = true
		end

		self.last_added_item_index = item

		self:RefreshUIState() -- rebuild list without this item
	end
end

-- This is called once the item reaches the empty slot
function TradeScreen:AddSelectedItem(item)
	if item and item.item and item.target_index then
		local rarity = GetRarityForItem(item.item)

		self.selected_items[item.target_index] = item
		self.frames_single[item.target_index]:SetItem( item.type, item.item, 0) --Swap item

		if item.count == 0 then
			if self.warning_timeout <= 0 then
				self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.WARNING )
				self.warning_timeout = 8 --don't warn more than once per 8 seconds.
			end

		elseif self:IsTradeAllowed() then
			self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.TRADEAVAIL )
		else
			local number_selected = 0
			for k,v in pairs(self.selected_items) do
				if v then
					number_selected = number_selected + 1
				end
			end

			if number_selected == 1 then
				if not self.specials_mode then
					self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.ADDMORE, STRINGS.UI.RARITY[rarity])
				else
					self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.ADDMORESPECIALS, STRINGS.UI.RARITY[rarity])
				end
			end
		end

		self:RefreshUIState()
	end
end


-- Returns true or false. If true, also returns the specific trade rule that will apply.
-- Assumes that there is only one input type per rule, and that input only specifies rarity and number.
function TradeScreen:IsTradeAllowed()
	local count = GetNumberSelectedItems(self.selected_items)

	if self.specials_mode then
		local RECIPE_SIZE = 6
		if count == RECIPE_SIZE then
			local recipe_index = self.specials_list:GetRecipeIndex()
			local special_recipe = self.recipes[recipe_index]
			--dumptable(special_recipe.Restrictions)
			--dumptable(self.selected_items)
			assert(#special_recipe.Restrictions == RECIPE_SIZE)

			local selection_item_used = {} --need all 6 slots to be set to true for this recipe to be matched
			for res_id,restriction in pairs(special_recipe.Restrictions) do
				for index=1,RECIPE_SIZE do
					if not selection_item_used[index] then
						local matches = does_item_match_restriction( restriction, self.selected_items[index] )
						if matches then
							selection_item_used[index] = true
							break
						end
					end
				end
			end

			--if the recipe was matched, all items will be consumed
			local matching_recipe = true
			for i=1,RECIPE_SIZE do
				if not selection_item_used[i] then
					matching_recipe = false
					break
				end
			end

			return matching_recipe
		end
	else
		--regular recipe
		if count == 9 then
			return true
		end
	end

	return false
end


-- Redisplay the entire UI
function TradeScreen:RefreshUIState()
	--print("~~~~~~~~~~~~~~TradeScreen:RefreshUIState")
	local items_in_use = ItemsInUse( self.selected_items, self.moving_items_list )
	local filters = nil
	if self.specials_mode then
		local recipe_index = self.specials_list:GetRecipeIndex()
		filters = GetSpecialFilters(self.recipes[recipe_index], items_in_use)
	else
		local recipe_name = GetBasicRecipeMatch(items_in_use)
		filters = GetBasicFilters(recipe_name)
	end
	self.popup:UpdateData(items_in_use, filters)

	if not self.machine_in_use and self:IsTradeAllowed() then
		self.tradebtn:Enable()
	else
		self.tradebtn:Disable()
	end

	if self.machine_in_use or next(self.selected_items) == nil then -- No items selected.
		self.resetbtn:Disable()
		self:DisableMachineTiles()
	else
		self.resetbtn:Enable()
		self:EnableMachineTiles()
	end

	-- DISABLE SPECIAL RECIPES
	--[[if self.specials_mode then
		self:ShowSpecials()
	else
		self:HideSpecials()
	end]]

	if self.machine_in_use or self.sold_out or self.transitioning or self.quitting then
		self.popup:DisableInput()
	else
		self.popup:EnableInput()
	end

   	if self.sold_out then
	   	self.sold_out_sign:Show()
	else
	   	self.sold_out_sign:Hide()
	end


	-- DISABLE SPECIAL RECIPES
	--[[if self.machine_in_use or self.transitioning or self.quitting then
		self.specials_button:Disable()
	else
		self.specials_button:Enable()
	end]]

	if self.exit_button ~= nil then
		if self.quitting or self.machine_in_use then
			self.exit_button:Disable()
		else
			self.exit_button:Enable()
		end
	end


	self:RefreshMachineTilesState() -- Do this at the end so that self.popup will be already updated.
end

-- DISABLE SPECIAL RECIPES
--[[function TradeScreen:ShowSpecials()
	--print("**** Setting up specials mode")
	if not self.machine_in_use then
		self.specials_list:Show()
		self.specials_list:UpdateSelectedIngredients(self.selected_items)
	else
		self.specials_list:Hide()
	end
	self.special_lightfx:Show()

	self.claw_machine:GetAnimState():AddOverrideBuild("swapshoppe_special_build")

	self.title:Hide()
	self.specials_title:Show()
end

function TradeScreen:HideSpecials()
	--print("**** Hiding specials ")
	self.specials_list:Hide()
	self.special_lightfx:Hide()

	self.claw_machine:GetAnimState():ClearOverrideBuild("swapshoppe_special_build")

	self.title:Show()
	self.specials_title:Hide()
end]]

function TradeScreen:RefreshMachineTilesState()

	local items_in_use = ItemsInUse( self.selected_items, self.moving_items_list )

	--check the count of items in the selector and remove any last item warning flags
	for i=1,MAX_TRADE_ITEMS do
		local item = self.selected_items[i]
		if item ~= nil and item.last_item_warning then
			local count = self.popup:NumItemsLikeThis(item.item)
			local numCopiesInUse = CountItemsInTable(item.item, items_in_use)
			if (count - numCopiesInUse) > 0 then
				item.last_item_warning = nil
			else
				--also remove any duplicate last_item_warning
				for _,other_item in pairs(self.selected_items) do
					if other_item.item == item.item then
						other_item.last_item_warning = nil
					end
				end
				item.last_item_warning = true --keep the marker on ourself
			end
		end
	end

	for i=1,MAX_TRADE_ITEMS do
		local item = self.selected_items[i]
		if not self.machine_in_use and item ~= nil then
			local rarity = GetRarityForItem(item.item)
			local hover_text = STRINGS.UI.RARITY[rarity] .. "\n" .. GetSkinName(item.item)

			local y_offset = 50
			if item.last_item_warning then
				hover_text =  hover_text .. "\n" .. STRINGS.UI.TRADESCREEN.EQUIPPED
				y_offset = 60
			end
			self.frames_single[i]:Mark(item.last_item_warning)
			self.frames_single[i]:SetHoverText( hover_text, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = y_offset, colour = {1,1,1,1}})
		else
			self.frames_single[i]:ClearHoverText()
			self.frames_single[i]:Mark(false)
		end
	end
end

local FLUSH_TIME_SPREAD = .8

function TradeScreen:StartFlushTiles()
	--print("Playing disappear and flush")
	self.flush_items = true
	self.flush_time = 0
	self.flush_tiles_rot_rand = {}
	self.flush_tiles_t = {}
	self.flush_pos_x = {}
	self.flush_pos_y = {}
	for i=1,self.current_num_trade_items do
		table.insert( self.flush_tiles_rot_rand, math.random()*(100) )

		table.insert( self.flush_pos_x, math.random() * 15 )
		table.insert( self.flush_pos_y, math.random() * 15 )
	end

	local rand_time_offset = 0.07
	if self.current_num_trade_items == 9 then
		local remap_tiles = { 3, 2, 1, 4, 0, 8, 5, 6, 7 }
		for i=1,self.current_num_trade_items do
			self.flush_tiles_t[i] = 0 - FLUSH_TIME_SPREAD * (remap_tiles[i]/self.current_num_trade_items) + math.random() * rand_time_offset
		end
	elseif self.current_num_trade_items == 6 then
		local remap_tiles = { 2, 1, 0, 3, 4, 5 }
		for i=1,self.current_num_trade_items do
			self.flush_tiles_t[i] = 0 - FLUSH_TIME_SPREAD * (remap_tiles[i]/self.current_num_trade_items) + math.random() * rand_time_offset
		end
	else
		print("Error: Figure out a new layout for tiles!!!")
	end

	self:PlayMachineAnim("flush", false)
	self:PushMachineAnim("spiral_loop", true)

	-- used for timing SFX
	self.flush_sound_stage = 1
end

function TradeScreen:FlushTilesUpdate(dt)
	if self.flush_items then
		self.flush_time = self.flush_time + dt

		if self.flush_sound_stage == 1 and self.flush_time >= (2*FRAMES) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/flush")
			self.flush_sound_stage = 2
		elseif self.flush_sound_stage == 2 and self.flush_time >= (6*FRAMES) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/flush_flick")
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/swapshoppe/flush_spin")
			self.flush_sound_stage = nil
		end


		--Handle the programatic animation of the tiles flushing
		local START_OFFSET = 10 * FRAMES
		if self.flush_time > START_OFFSET then
			local FLUSH_TIME = 1.8
			local CONTAINER_ROT = 500

			local ft = self.flush_time - START_OFFSET

			for i=1,self.current_num_trade_items do
				self.flush_tiles_t[i] = self.flush_tiles_t[i] + dt
				local clamp_t = math.clamp( self.flush_tiles_t[i], 0, FLUSH_TIME - FLUSH_TIME_SPREAD )
				local r = Remap( clamp_t, 0, FLUSH_TIME - FLUSH_TIME_SPREAD, 120, 0)

				local x = math.sin(2.5 * PI * self.flush_tiles_t[i])
				local y = math.cos(2.5 * PI * self.flush_tiles_t[i])

				x = Lerp( self.frames_positions[i].x, r * x + self.flush_pos_x[i], math.clamp( ft * 3, 0, 1) )
				y = Lerp( self.frames_positions[i].y, r * y + self.flush_pos_y[i], math.clamp( ft * 3, 0, 1) )

				self.frames_single[i]:SetPosition( x, y, 0)

				local tile_scale = easing.inQuad( clamp_t, 1, -1, FLUSH_TIME - FLUSH_TIME_SPREAD)
				self.frames_single[i]:SetScale(tile_scale)
				if self.flush_tiles_t[i] > (FLUSH_TIME - FLUSH_TIME_SPREAD) then
					self.frames_single[i]:Hide()
				end

				local tile_rot = easing.outQuad(ft, 0, self.flush_tiles_rot_rand[i], FLUSH_TIME)
				self.frames_single[i]:SetRotation(tile_rot)
			end

			if ft > FLUSH_TIME then
				for i=1,self.current_num_trade_items do
					self.frames_single[i]:Hide()
				end
				self.flush_items = false
			end
		end
	end
end


function TradeScreen:ResetFrameTiles()
	self.frames_positions = {}
	for x = 1,3 do
		for y = 0,2 do
			local index = x + y*3
			self.frames_positions[index] = { x = (x-2) * 90, y = (y-1) * -90 + self.frames_height_adjustment, z = 0}
		end
	end

	for i=1,MAX_TRADE_ITEMS do
		if i <= self.current_num_trade_items then
			self.frames_single[i]:Show()
		else
			self.frames_single[i]:Hide()
		end
		self.frames_single[i].inst.components.uianim.pos_t = nil --to stop any MoveTo in progress
		self.frames_single[i]:SetPosition( self.frames_positions[i].x, self.frames_positions[i].y, 0)
		self.frames_single[i]:SetScale( 1 )
		self.frames_single[i]:SetRotation( 0 )
		self.frames_single[i]:SetItem( nil, nil, nil )
	end
end



function TradeScreen:OnUpdate(dt)

	if TheFrontEnd:GetIsOfflineMode() then
		if not self.quitting and TheFrontEnd:GetActiveScreen() == self then
			self:Quit()
		end
		return
	end

	if self.reset_started and self.claw_machine:GetAnimState():IsCurrentAnimation("skin_off") and self.claw_machine:GetAnimState():AnimDone() then
		-- Wait for the skin out anim to finish and then animate the item over to the inventory
		if self.moving_gift_item and not self.moving_gift_item.moving then
			local idx = #self.moving_items_list
			--print("Skin_off is finished, ", self.moving_gift_item or "nil", idx or "nil")
	       	self.moving_gift_item.Move(function() ItemEndMove(self, idx) self:FinishReset() end)

	       	self:PlayMachineAnim("idle_empty", true)
	    end

	elseif self.claw_machine:GetAnimState():IsCurrentAnimation("claw_in") and self.claw_machine:GetAnimState():AnimDone() then
		self:StartFlushTiles()

	elseif self.claw_machine:GetAnimState():IsCurrentAnimation("spiral_loop") then
		self:FinishTrade()
	end

	-- DISABLE SPECIAL RECIPES
	--[[if self.specials_transitionFx:GetAnimState():IsCurrentAnimation(TRANSITION_ANIM) and self.specials_transitionFx:GetAnimState():AnimDone() then
		self.specials_transitionFx:Hide()
	end]]

	self:FlushTilesUpdate(dt)

	if self.warning_timeout and self.warning_timeout > 0 then
		self.warning_timeout = self.warning_timeout - dt
	end

	return true
end



local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0
local STICK_SCROLL_REPEAT_TIME = .25
local reset_control = CONTROL_MAP
if IsConsole() then
	reset_control = CONTROL_MENU_MISC_2
end

function TradeScreen:OnControl(control, down)
	if self.quitting then
		return
	end

    if TradeScreen._base.OnControl(self, control, down) then return true end

    if not down then
    	if control == CONTROL_CANCEL and not self.quitting and not self.machine_in_use then
			self:Quit()
			return true
		end
	end

    if  TheInput:ControllerAttached() then
	    if not down then
	    	if control == reset_control then
				if self.resetbtn:IsEnabled() then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
					self:Reset()
				end
				return true
			elseif control == CONTROL_PAUSE then -- menu button / start button
				if self:IsTradeAllowed() then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
					self:Trade()
				end
				if self.accept_waiting then
					self:Reset()
				end
				return true
			elseif control == CONTROL_INSPECT then -- Y button
				if IsNotConsole() and PLATFORM ~= "WIN32_RAIL" then
					VisitURL("https://steamcommunity.com/market/search?appid=322330")
					return true
				end
			elseif control == CONTROL_MENU_MISC_1 then -- X button
				local slot_to_remove = FindLastFullSlot(self.selected_items, self.current_num_trade_items)
				-- Don't do this if the tile is disabled for any reason (will happen during transitions, quitting, etc.)
				if slot_to_remove ~= nil and self.frames_single[slot_to_remove]:IsEnabled() then
					self:RemoveSelectedItem(slot_to_remove)
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				end
			end
	    end
	end

	if down then
	 	if control == CONTROL_PREVVALUE and self.specials_mode then  -- r-stick left
	    	self.specials_list:OnControl(control, down)
			return true
		elseif control == CONTROL_NEXTVALUE and self.specials_mode then -- r-stick right
			self.specials_list:OnControl(control, down)
			return true
		elseif control == CONTROL_SCROLLBACK then
            self:ScrollBack(control)
            return true
        elseif control == CONTROL_SCROLLFWD then
        	self:ScrollFwd(control)
            return true
       	elseif control == CONTROL_ACCEPT and self.accept_waiting then
       		self:Reset()
		elseif control == CONTROL_OPEN_INVENTORY then -- right trigger
			self.do_nothing_on_activate = true
			local bird_interact = nil
			bird_interact = BirdInteractScreen(
				{
					{ text=STRINGS.UI.TRADESCREEN.CROW_GAME.HELP_TITLE, cb = function() TheFrontEnd:PopScreen(bird_interact) self.crow_anim.onclick() end },
					{ text=STRINGS.UI.TRADESCREEN.SNOW_GAME.HELP_TITLE, cb = function() TheFrontEnd:PopScreen(bird_interact) self.snowbird_anim.onclick() end },
					{ text=STRINGS.UI.TRADESCREEN.REDBIRD_GAME.HELP_TITLE, cb = function() TheFrontEnd:PopScreen(bird_interact) self.redbird_anim.onclick() end },
					{ text=STRINGS.UI.TRADESCREEN.CROWKID_GAME.HELP_TITLE, cb = function() TheFrontEnd:PopScreen(bird_interact) self.crowkid_anim.onclick() end },
					{ text=STRINGS.UI.TRADESCREEN.KITCOON_GAME.HELP_TITLE, cb = function() TheFrontEnd:PopScreen(bird_interact) self.kitcoon_anim.onclick() end },
				}
			)
			TheFrontEnd:PushScreen(bird_interact)
		end
	end
end

function TradeScreen:ScrollBack(control)
	local scroll_list = self.popup.scroll_list
	if not scroll_list.repeat_time or scroll_list.repeat_time <= 0 then
       	scroll_list:Scroll(-1)
       	--if self.scroll_list.page_number ~= pageNum then
       	--	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
       	--end
        scroll_list.repeat_time =
            TheInput:GetControlIsMouseWheel(control)
            and MOUSE_SCROLL_REPEAT_TIME
            or (control == CONTROL_SCROLLBACK and SCROLL_REPEAT_TIME)
            or (control == CONTROL_PREVVALUE and STICK_SCROLL_REPEAT_TIME)
    end
end

function TradeScreen:ScrollFwd(control)
	local scroll_list = self.popup.scroll_list
	if not scroll_list.repeat_time or scroll_list.repeat_time <= 0 then
        scroll_list:Scroll(1)
		--if self.scroll_list.page_number ~= pageNum then
       	--	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
       	--end
        scroll_list.repeat_time =
            TheInput:GetControlIsMouseWheel(control)
            and MOUSE_SCROLL_REPEAT_TIME
            or (control == CONTROL_SCROLLFWD and SCROLL_REPEAT_TIME)
            or (control == CONTROL_NEXTVALUE and STICK_SCROLL_REPEAT_TIME)
    end
end

function TradeScreen:GetHelpText()

    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.TRADESCREEN.BACK)


	if not self.machine_in_use and not self.transitioning then

		-- DISABLE SPECIAL RECIPES
       	--[[if self.specials_mode then
	    	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY) .. " " .. STRINGS.UI.TRADESCREEN.NOSPECIALS )

	    	-- This uses too much space. Just use the hints on the spinner instead.
	    	--table.insert(t, self.specials_list:GetHelpText())
	    else
	    	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY) .. " " .. STRINGS.UI.TRADESCREEN.SPECIALS )
	    end]]

		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY) .. " " .. STRINGS.UI.TRADESCREEN.BIRDS )

		if self.resetbtn:IsEnabled() then
			table.insert(t,  TheInput:GetLocalizedControl(controller_id, reset_control) .. " " .. STRINGS.UI.TRADESCREEN.RESET)
		end

	    if self.tradebtn:IsEnabled() then
	   		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.TRADESCREEN.TRADE)
	   	end
	end

	if self.accept_waiting then
   		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.TRADESCREEN.ACCEPT)
    end

    if not self.machine_in_use and not self.transitioning then
	    local slot_to_remove = FindLastFullSlot(self.selected_items, self.current_num_trade_items)
		if slot_to_remove ~= nil then
	   		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.TRADESCREEN.REMOVE_ITEM)
	   	end

	   	-- Selecting an item doesn't do anything if the machine is full, so drop the hint text
	   	if not self.tradebtn:IsEnabled() and not self.accept_waiting then
	   		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.TRADESCREEN.SELECT)
	   	end
    end

	-- DISABLE SPECIAL RECIPES
	--[[
    if self.specials_mode then
    	local str = self.specials_list:GetHelpText()
    	table.insert(t, str)
    end]]
	if not IsRail() and IsNotConsole() then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.TRADESCREEN.MARKET)
	end

    return table.concat(t, "  ")
end


return TradeScreen
