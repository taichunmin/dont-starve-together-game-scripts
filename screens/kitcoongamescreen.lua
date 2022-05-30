local Screen = require "widgets/screen"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"
local NEW_TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"

local KitcoonPuppet = require "widgets/kitcoonpuppet"
local KitcoonPoop = require "widgets/kitcoonpoop"
local KitcoonFood = require "widgets/kitcoonfood"
local KitcoonPouch = require "widgets/kitcoonpouch"


--------------------------------------------------------------------------------------------------------------------------------------------
-- Class KitcoonGameScreen
--------------------------------------------------------------------------------------------------------------------------------------------
local KitcoonGameScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "KitcoonGameScreen")

	self.profile = profile
	self.pressed = {}

	self:SetupUI()
	self:UpdateInterface()
end)

function KitcoonGameScreen:SetupUI()
	self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	
    --self.panel_bg = self.fixed_root:AddChild(TEMPLATES.NoPortalBackground())
	self.bg_anim = self.fixed_root:AddChild(UIAnim())
	self.bg_anim:SetScale(0.667)
    --self.bg_anim:SetFacing(FACING_DOWNRIGHT)
    local bg_as = self.bg_anim:GetAnimState()
    bg_as:SetBank("kitcoon_bg")
    bg_as:SetBuild("kitcoon_bg")
    bg_as:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    bg_as:UseColourCube(true)
    bg_as:SetUILightParams(2.0, 4.0, 4.0, 20.0)
    bg_as:PlayAnimation("idle", true)

    self.pouch = self.fixed_root:AddChild(KitcoonPouch())
	self.pouch:SetPosition(160, -120)

    self.kit_puppet = self.fixed_root:AddChild(KitcoonPuppet( self.profile, true, nil, 1 ))
	self.kit_puppet:SetPosition(0, -45)
	self.kit_puppet:Enable()
	
	self.pouch:SetKit(self.kit_puppet)

    self.food = self.fixed_root:AddChild(KitcoonFood( self.kit_puppet ))
	self.food:SetPosition(-180, -50)


	local num_poops = self.profile:GetKitPoops()
	self.poops = {}
	for i=1,num_poops do
		local p = self.fixed_root:AddChild(KitcoonPoop( self.kit_puppet, self, self.profile ))
		table.insert( self.poops, p )
		local x = math.random( -250, 230 )
		local y = math.random( -330, -80 )
		p:SetPosition( x, y )
	end

    if not TheInput:ControllerAttached() then
    	self.exit_button = self.fixed_root:AddChild(TEMPLATES.BackButton(function() self:Quit() end)) 
    	self.exit_button:SetPosition(-RESOLUTION_X*.415, -RESOLUTION_Y*.505 + BACK_BUTTON_Y )
    	self.exit_button:Enable()
  	end
	
	self.letterbox = self:AddChild(TEMPLATES.ForegroundLetterbox())
	
	self.age_txt = self.fixed_root:AddChild( Text( TALKINGFONT, 30 ) )
	self.age_txt:SetHAlign(ANCHOR_LEFT)
    self.age_txt:SetVAlign(ANCHOR_TOP)
	self.age_txt:SetRegionSize(800, 100)
	self.age_txt:SetPosition( -219, 290, 0 )
	self.age_txt:Hide()

	self.default_focus = self.age_txt --for clearing the focus on the last screen

	local show_abandoned = self.profile:GetKitAbandonedMessage()
	if show_abandoned then
        staticScheduler:ExecuteInTime( 0, function(inst) 
			local title = subfmt( STRINGS.UI.TRADESCREEN.KITCOON_GAME.ABANDONED_TITLE, {name = self.profile:GetKitName()} )
			local body = subfmt( STRINGS.UI.TRADESCREEN.KITCOON_GAME.ABANDONED_BODY, {name = self.profile:GetKitName()} )
			local ack = PopupDialogScreen( title, body, { {text=STRINGS.UI.TRADESCREEN.KITCOON_GAME.OKAY, cb = function() TheFrontEnd:PopScreen() end} })
			TheFrontEnd:PushScreen(ack)
			self.profile:SetKitAbandonedMessage( false )
		end )
	end
end


function KitcoonGameScreen:RemovePoop(poop)
	table.removearrayvalue( self.poops, poop )
end


function KitcoonGameScreen:OnUpdate(dt)
	KitcoonGameScreen._base.OnUpdate(self, dt)
	
	self:UpdateInterface()
end

function KitcoonGameScreen:UpdateInterface()
	if not (self.inst:IsValid()) then
        return
	end
	
	local build = self.profile:GetKitBuild()
    if build == "" then
		self.age_txt:Hide()
	else
		self.age_txt:Show()

		if Profile:GetKitIsHibernating() then
			self.age_txt:SetString( subfmt(STRINGS.UI.TRADESCREEN.KITCOON_GAME.HIBERNATING, { name = self.profile:GetKitName() } ) )
		else
			local birth_time = self.profile:GetKitBirthTime()	
			local days_since = math.floor( os.difftime(os.time(), birth_time) / (60 * 60 * 24) )
			self.age_txt:SetString( subfmt(STRINGS.UI.TRADESCREEN.KITCOON_GAME.NAME_AGE, { name = self.profile:GetKitName(), age = tostring(days_since) } ) )
		end
	end
end

function KitcoonGameScreen:Quit()
	TheFrontEnd:FadeBack(nil, nil, function()
		self.kit_puppet:LeaveGameScreen()
	end)
end

function KitcoonGameScreen:OnBecomeActive()
	KitcoonGameScreen._base.OnBecomeActive(self)
end


function KitcoonGameScreen:IsKitActive()

end

function KitcoonGameScreen:OnControl(control, down)
    if KitcoonGameScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then 
		self:Quit()
		return true 
	end
	
	if down and TheInput:ControllerAttached() then
		
		if Profile:GetKitIsHibernating() then
			if control == CONTROL_OPEN_INVENTORY then
				--wake
				self.pouch:onclick()
				return true
			end
		else
			if control == CONTROL_ACCEPT then
				--play
				self.kit_puppet:onclick()
				return true
			elseif control == CONTROL_MENU_MISC_2 then
				--feed
				self.food:onclick()
				return true
			elseif control == CONTROL_OPEN_INVENTORY then
				--go to sleep
				self.pouch:onclick()
				return true
			end
		end
			
		if control == CONTROL_MENU_MISC_1 and #self.poops > 0 then
			--clear poop
			local p = GetRandomItem(self.poops)
			p:onclick()
			return true
		end
	end
end

function KitcoonGameScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
	
	local build = self.profile:GetKitBuild()
    if build == "" then
		--name
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.TRADESCREEN.KITCOON_GAME.PICKUP_NAMETAG)
	else
		if Profile:GetKitIsHibernating() then
			local wake = subfmt(STRINGS.UI.TRADESCREEN.KITCOON_GAME.WAKE, { name = self.profile:GetKitName() } )
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY) .. " " .. wake)
		else
			if not self.kit_puppet.animstate:IsCurrentAnimation("sleep_loop") then
				--feed
				local feed = subfmt(STRINGS.UI.TRADESCREEN.KITCOON_GAME.FEED, { name = self.profile:GetKitName() } )
				table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. feed)

				--play
				local play = subfmt(STRINGS.UI.TRADESCREEN.KITCOON_GAME.PLAY_WITH, { name = self.profile:GetKitName() } )
				table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. play)
			end
			
			local hibernate = subfmt(STRINGS.UI.TRADESCREEN.KITCOON_GAME.HIBERNATE, { name = self.profile:GetKitName() } )
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY) .. " " .. hibernate)
		end

		if #self.poops > 0 then
			--clear poop
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.TRADESCREEN.KITCOON_GAME.CLEAR_POOP)
		end
	end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SKINSSCREEN.BACK)
    
    return table.concat(t, "  ")
end

return KitcoonGameScreen
