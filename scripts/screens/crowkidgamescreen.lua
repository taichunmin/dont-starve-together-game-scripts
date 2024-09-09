local Screen = require "widgets/screen"
local MazeGameTile = require "widgets/mazegametile"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/templates"
local NEW_TEMPLATES = require "widgets/redux/templates"
local MouseTracker = require "widgets/mousetracker"
local SkinCollector = require "widgets/skincollector"
local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local ThankYouPopup = require "screens/thankyoupopup"
local PopupDialogScreen = require "screens/redux/popupdialog"
local easing = require "easing"
local Stats = require("stats")
local Puppet = require "widgets/skinspuppet"

----------------------------------
--GAME STATES
----------------------------------
local GS_WAITING = 0
local GS_MOVING = 1
local GS_PICKUP = 2



local TILE_NONE = "none"
local TILE_HAY = "wall_hay_item"

local GAME_NUM_ROWS = 51
local GAME_NUM_COLUMNS = 51

local VIEW_NUM_ROWS = 13
local VIEW_NUM_COLUMNS = 11
local SPACING = 50
local TILE_SCALE = 1.3

local BG_RATIO = 6
local BG_ROWS = 5
local BG_COLUMNS = 4
local BG_SPACING = SPACING * BG_RATIO
local BG_SCALE = 1.18


local MOVING_TIME = 0.2

local REPORT_ACCEPTED = "ACCEPTED"
local REPORT_ALREADY_COMPLETED = "ALREADY_REDEEMED"
local REPORT_FAILED_TO_CONTACT = "FAILED_TO_CONTACT"

local SCORE_VERSION = "A"


--------------------------------------------------------------------------------------------------------------------------------------------
-- Class CrowKidGameScreen
--------------------------------------------------------------------------------------------------------------------------------------------
local CrowKidGameScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "CrowKidGameScreen")

	self.profile = profile
	self.pressed = {}

	self:SetupUI()
	self:InitGameBoard()
	self:UpdateInterface()
end)

local LEFT_COLUMN_POS_SCALE = 0.35
local RIGHT_COLUMN_POS_SCALE = 0.35
function CrowKidGameScreen:SetupUI()
	
	-- FIXED ROOT
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
  
    self.panel_bg = self.fixed_root:AddChild(TEMPLATES.NoPortalBackground())
	self.menu_bg = self.fixed_root:AddChild(TEMPLATES.LeftGradient())
	
	self:SetupMachine()

	self.scissor_root = self.fixed_root:AddChild(Widget("scissor"))
	self.scissor_root:SetScissor(-187, -207, 378, 441)

	self.view_bg_root = self.scissor_root:AddChild(Widget("view_bg_root"))
	self:ConstructBGGrid()

	self.view_grid_root = self.scissor_root:AddChild(Widget("view_grid_root"))
	self:ConstructGameGrid()

	self.puppet = self.fixed_root:AddChild(Puppet())
    self.puppet:SetScale(0.7)
    self.puppet:SetClickable(false)   
	local character = self.profile:GetLastSelectedCharacter() 
    self.puppet:SetSkins(character, character.."_none", {}, true, "normal_skin")
	self.puppet:SetPosition(0, -15)
	self.puppet:AddShadow()

	self.score_root = self.fixed_root:AddChild(Widget("score_root"))
	self.score_root:SetPosition(-RESOLUTION_X*LEFT_COLUMN_POS_SCALE, -10)
	self.score_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.steps_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.steps_text:SetPosition(0, -40)

    if not TheInput:ControllerAttached() then 
    	self.exit_button = self.fixed_root:AddChild(TEMPLATES.BackButton(function() self:Quit() end)) 
    	self.exit_button:SetPosition(-RESOLUTION_X*.415, -RESOLUTION_Y*.505 + BACK_BUTTON_Y )
    	self.exit_button:Enable()
  	end
	
	self.innkeeper = self.fixed_root:AddChild(SkinCollector( 0, true, STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROWKID.START )) 
	self.innkeeper:SetPosition(410, -400)
	self.innkeeper:Appear()


	self.letterbox = self:AddChild(TEMPLATES.ForegroundLetterbox())


	self.default_focus = self.score_root
end

local show_help_fn = function()
	local help_popup = PopupDialogScreen( STRINGS.UI.TRADESCREEN.CROWKID_GAME.HELP_TITLE, STRINGS.UI.TRADESCREEN.CROWKID_GAME.HELP_BODY,
		{
			{
				text = STRINGS.UI.TRADESCREEN.OK,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		},
		nil,
		"bigger"
	)
	TheFrontEnd:PushScreen(help_popup)
end

function CrowKidGameScreen:SetupMachine()

	-- Hanging sign
	self.sign_bg = self.fixed_root:AddChild(Image("images/tradescreen.xml", "hanging_sign_brackets.tex"))
	self.sign_bg:SetScale(.65, .65, .65)
	self.sign_bg:SetPosition(-438, 40)
	self.sign_bg:SetClickable(false)


	local machine_scale = 0.59

	-- Add the claw machine
	self.claw_machine_bg = self.fixed_root:AddChild(UIAnim())
	self.claw_machine_bg:GetAnimState():SetBuild("swapshoppe_bg")
	self.claw_machine_bg:GetAnimState():SetBank("shop_bg")
	self.claw_machine_bg:SetScale(machine_scale)
	self.claw_machine_bg:SetPosition(0, 65)

  

	self.claw_machine = self.fixed_root:AddChild(UIAnim())
	self.claw_machine:GetAnimState():SetBuild("swapshoppe")
	self.claw_machine:GetAnimState():SetBank("shop")
	self.claw_machine:SetScale(machine_scale)
	self.claw_machine:SetPosition(0, 65)

  
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
	if not TheInput:ControllerAttached() then
		self.joystick = self.claw_machine:AddChild(MouseTracker("joystick", function() self.innkeeper:Say(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.JOYSTICK) end))
		self.joystick:SetPosition(5, -550)
	end

  

  
	-- the buttons aren't used on console but don't hide them since they're part of the decor and they add the 
	-- button prompts to the help bar; hide the text only so players don't try to navigate to them
	local reset_button_text = STRINGS.UI.TRADESCREEN.RESET
	local trade_button_text = STRINGS.UI.TRADESCREEN.START

	local pretty_button_y = -540
	if TheInput:ControllerAttached() then
		pretty_button_y = -525
	end

	-- reset button bg
	self.resetbutton = self.claw_machine:AddChild(TEMPLATES.AnimTextButton("button", 
												{idle = "idle_red", over = "up_red", disabled = "down_red"},
												1, 
												function() 
													self:InitGameBoard()
												end,
												reset_button_text, 
												30))
	self.resetbutton:SetPosition(-200, pretty_button_y)

	-- trade button bg
	
	self.startbutton = self.claw_machine:AddChild(TEMPLATES.AnimTextButton("button", 
												{idle = "idle_green", over = "up_green", disabled = "down_green"},
												1, 
												function() 
													self:InitGameBoard()
												end,
												trade_button_text, 
												30))
	self.startbutton:SetPosition(208, pretty_button_y)



    if not TheInput:ControllerAttached() then 
		self.info_button = self.claw_machine:AddChild(NEW_TEMPLATES.StandardButton(
				show_help_fn,
				STRINGS.UI.PURCHASEPACKSCREEN.INFO_BTN, --reuse
				{100, 100}
			)
		)
		self.info_button:SetPosition(300, -648)
	end
end

function CrowKidGameScreen:PlayMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PlayAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PlayAnimation(name, loop)
end

function CrowKidGameScreen:PushMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PushAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PushAnimation(name, loop)
end

function CrowKidGameScreen:ConstructBGGrid()
	self.bg_grid = {}
		
	local x_offset = (BG_COLUMNS/2) * BG_SPACING + BG_SPACING/2
	local y_offset = (BG_ROWS/2) * BG_SPACING + BG_SPACING/2
	
	for x = 0,BG_COLUMNS-1 do
		self.bg_grid[x] = {}
		for y = 0,BG_ROWS-1 do			
			local tile = self.view_bg_root:AddChild(Image("images/maze.xml", "grass_1.tex"))
			tile:SetScale(BG_SCALE)
			tile:SetPosition( (x + 1) * BG_SPACING - x_offset, (BG_COLUMNS - y) * BG_SPACING - y_offset, 0)
			self.bg_grid[x][y] = tile
		end	
	end
end


function CrowKidGameScreen:ConstructGameGrid()
	self.view_grid = {}
		
	local x_offset = (VIEW_NUM_COLUMNS/2) * SPACING + SPACING/2
	local y_offset = (VIEW_NUM_ROWS/2) * SPACING + SPACING/2
	
	for x = 0,VIEW_NUM_COLUMNS-1 do
		self.view_grid[x] = {}
		for y = 0,VIEW_NUM_ROWS-1 do			
			local tile = self.view_grid_root:AddChild(MazeGameTile())
			tile:SetScale(TILE_SCALE)
			tile:SetPosition( (x + 1) * SPACING - x_offset, (VIEW_NUM_COLUMNS - y + 2) * SPACING - y_offset, 0)
			self.view_grid[x][y] = tile
		end	
	end
end

function CrowKidGameScreen:CutHayMaze(x, y)
	local r = math.random(0, 3) --pick a random direction to go
	
	self.game_board[x][y] = TILE_NONE --clear starting tile

	local dirs = {
		{ dx =  1,  dy =  0 },
		{ dx = -1,  dy =  0 },
		{ dx =  0,  dy =  1 },
		{ dx =  0,  dy = -1 },
	}
	while #dirs > 0 do
		local dir = PickSome( 1, dirs )[1] --pick a random direction
		local next_x = x + dir.dx
		local next_y = y + dir.dy
		local nextnext_x = next_x + dir.dx
		local nextnext_y = next_y + dir.dy
		--if next two squares are hay, we can cut through
		if self.game_board[next_x][next_y] == TILE_HAY and self.game_board[nextnext_x][nextnext_y] == TILE_HAY then
			self.game_board[next_x][next_y] = TILE_NONE
			self:CutHayMaze(nextnext_x, nextnext_y)
		end
	end
end

 
function CrowKidGameScreen:InitGameBoard()
	self.reported_25 = false
	self.reported_50 = false
	self.reported_75 = false
	self.reported_100 = false
	self.score = 0
	self.steps_taken = 0

	self.foot_step_time = 0

	self.move_offset_x = 0
	self.move_offset_y = 0
	self.bg_offset_x = 0
	self.bg_offset_y = 0

	self.game_board = {}
	for x = 0,GAME_NUM_COLUMNS-1 do
		self.game_board[x] = {}
		for y = 0,GAME_NUM_ROWS-1 do
			if x == 0 or y == 0 or x == (GAME_NUM_COLUMNS-1) or y == (GAME_NUM_ROWS-1) then
				self.game_board[x][y] = TILE_NONE
			else
				self.game_board[x][y] = TILE_HAY
			end
		end
	end

	math.randomseed(os.time())
	self:CutHayMaze(2, 2)
	
	--make holes
	local count = 60
	while count > 0 do
		local x = math.random(3, GAME_NUM_COLUMNS-3)
		local y = math.random(3, GAME_NUM_ROWS-3)
		if self.game_board[x][y] == TILE_HAY then
			if (self.game_board[x-1][y] == TILE_HAY and self.game_board[x+1][y] == TILE_HAY and self.game_board[x][y-1] == TILE_NONE and self.game_board[x][y+1] == TILE_NONE)
			or (self.game_board[x][y-1] == TILE_HAY and self.game_board[x][y+1] == TILE_HAY and self.game_board[x-1][y] == TILE_NONE and self.game_board[x+1][y] == TILE_NONE) then

				self.game_board[x][y] = TILE_NONE
				count = count - 1
			end
		end	
	end
	--remove single islands
	for x = 3,GAME_NUM_COLUMNS-3 do
		for y = 3,GAME_NUM_ROWS-3 do
			if self.game_board[x][y] == TILE_HAY
				and self.game_board[x-1][y] == TILE_NONE
				and self.game_board[x+1][y] == TILE_NONE
				and self.game_board[x][y-1] == TILE_NONE
				and self.game_board[x][y+1] == TILE_NONE then
					self.game_board[x][y] = TILE_NONE
			end
		end
	end
	
	--add prizes
	local count = 100
	local junk = { "carnival_gametoken", "carnival_prizeticket", "carnival_seedpacket"}
	while count > 0 do
		local x = math.random(3, GAME_NUM_COLUMNS-3)
		local y = math.random(3, GAME_NUM_ROWS-3)
		if self.game_board[x][y] == TILE_NONE then
			self.game_board[x][y] = GetRandomItem(junk)
			count = count - 1
		end	
	end

	--find an open starting position
	self.pos_x = 1
	self.pos_y = 1
	while self:GetGameTile( self.pos_x, self.pos_y ) ~= TILE_NONE do
		self.pos_x = math.random(5, GAME_NUM_COLUMNS-6)
		self.pos_y = math.random(5, GAME_NUM_ROWS-6)
	end


	self.game_state = GS_WAITING

	self:UpdateInterface()
end


function CrowKidGameScreen:GetGameTile( x, y )
	if x < 0 or x >= GAME_NUM_COLUMNS or y < 0 or y >= GAME_NUM_ROWS then
		return TILE_NONE
	end

	return self.game_board[x][y]
end


function CrowKidGameScreen:OnMovement( direction )
	if self.game_state == GS_WAITING then
		local new_x = self.pos_x
		local new_y = self.pos_y

		if self.puppet.anim:GetAnimState():IsCurrentAnimation("idle_loop") or self.puppet.anim:GetAnimState():IsCurrentAnimation("run_pst") or self.puppet.anim:GetAnimState():IsCurrentAnimation("pickup_pst") then
			self.puppet.anim:GetAnimState():PlayAnimation("run_pre")
			self.puppet.anim:GetAnimState():PushAnimation("run_loop", true)
		end
		if direction == CONTROL_FOCUS_UP then
			self.puppet.anim:SetFacing(FACING_UP)
			new_y = self.pos_y - 1
		elseif direction == CONTROL_FOCUS_DOWN then
			self.puppet.anim:SetFacing(FACING_DOWN)
			new_y = self.pos_y + 1
		elseif direction == CONTROL_FOCUS_LEFT then
			self.puppet.anim:SetFacing(FACING_LEFT)
			new_x = self.pos_x - 1
		elseif direction == CONTROL_FOCUS_RIGHT then
			self.puppet.anim:SetFacing(FACING_RIGHT)
			new_x = self.pos_x + 1
		end 

		if self:GetGameTile( new_x, new_y ) ~= TILE_HAY then
			self.game_state = GS_MOVING
			self.moving_to_x = new_x
			self.moving_to_y = new_y
			self.moving_time = MOVING_TIME
		end
	else
		self.queued_direction = direction
	end
end


local function game_over_display( over_title, over_body )
	local game_over_popup = PopupDialogScreen( over_title, over_body,
		{
			{
				text = STRINGS.UI.TRADESCREEN.OK,
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		}
	)
	TheFrontEnd:PushScreen(game_over_popup)
end

function CrowKidGameScreen:OnUpdate(dt)
	CrowKidGameScreen._base.OnUpdate(self, dt)

	--Handle mouse input
	if TheSim:GetMouseButtonState(MOUSEBUTTON_LEFT) then
		local win_x, win_y = TheSim:GetWindowSize()
		local x = TheFrontEnd.lastx
		local y = TheFrontEnd.lasty

		local x_norm = x/win_x
		local y_norm = y/win_y
		--Note(Peter): this is a digusting hack to check for mouse clicks starting only inside the game area
		if self.last_mouse_control ~= nil or (x_norm > 0.353 and x_norm < 0.649 and y_norm > 0.21 and y_norm < 0.825) then

			local x_delta = x - win_x/2
			local x_abs = math.abs(x_delta)

			local y_delta = y - win_y/2
			local y_abs = math.abs(y_delta)
			
			local mouse_control = nil
			if x_abs > y_abs then
				--left right
				if x_delta > 0 then
					mouse_control = CONTROL_FOCUS_RIGHT
				else
					mouse_control = CONTROL_FOCUS_LEFT
				end
			else
				--up down
				if y_delta > 0 then
					mouse_control = CONTROL_FOCUS_UP
				else
					mouse_control = CONTROL_FOCUS_DOWN
				end
			end

			if self.last_mouse_control ~= mouse_control then
				self:OnControl(mouse_control, true)
			end
			self.last_mouse_control = mouse_control
		end
	else
		if self.last_mouse_control ~= nil then
			self.last_mouse_control = nil
			self.pressed = {}
		end
	end


	if self.game_state == GS_MOVING then
		self.moving_time = self.moving_time - dt

		self.foot_step_time = self.foot_step_time + dt
		local foot_time = 0.25
		if self.foot_step_time > foot_time then
			self.foot_step_time = self.foot_step_time - foot_time
			TheFrontEnd:GetSound():PlaySound("dontstarve/movement/run_dirt", "", 0.9 )
		end

		if self.moving_time > 0 then
			local t = 1 - (self.moving_time / MOVING_TIME)

			self.move_offset_x = -Lerp( 0, (self.moving_to_x - self.pos_x) * SPACING, t )
			self.move_offset_y = Lerp( 0, (self.moving_to_y - self.pos_y) * SPACING, t )
		else
			--completed movement
			self.steps_taken = self.steps_taken + 1

			self.pos_x = self.moving_to_x
			self.pos_y = self.moving_to_y

			self.move_offset_x = 0
			self.move_offset_y = 0

			if self:GetGameTile( self.pos_x, self.pos_y ) ~= TILE_NONE then
				--we found something!
				self.game_state = GS_PICKUP

				self.score = self.score + 1
				self.game_board[self.pos_x][self.pos_y] = TILE_NONE
				
				self.puppet.anim:GetAnimState():PlayAnimation("pickup")
                self.puppet.anim:GetAnimState():PushAnimation("pickup_pst", false)

				staticScheduler:ExecuteInTime(0.35, function()
					self.game_state = GS_WAITING
					self:DoQueuedMovement()
				end)

				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/collect_resource")
			else
				--nothing here, keep running
				self.game_state = GS_WAITING

				self:DoQueuedMovement()
			end
		end
	elseif self.game_state == GS_WAITING then
		self.foot_step_time = 0.1 --preload the step timer, to get sound on a quick step

		if not self.puppet.anim:GetAnimState():IsCurrentAnimation("idle_loop") and not self.puppet.anim:GetAnimState():IsCurrentAnimation("run_pst") then
			if self.puppet.anim:GetAnimState():IsCurrentAnimation("run_loop") then
				self.puppet.anim:GetAnimState():PlayAnimation("run_pst")
			end
			self.puppet.anim:GetAnimState():PushAnimation("idle_loop", true)
		end
	end

	
	self.bg_offset_x = -BG_SPACING * (self.pos_x % BG_RATIO) / BG_RATIO + self.move_offset_x
	self.bg_offset_y = BG_SPACING * (self.pos_y % BG_RATIO) / BG_RATIO + self.move_offset_y

	self:UpdateInterface()
end


function CrowKidGameScreen:UpdateInterface()
	if not (self.inst:IsValid()) then
        return
	end
	
	self.view_bg_root:SetPosition(self.bg_offset_x, self.bg_offset_y)
	self.view_grid_root:SetPosition(self.move_offset_x, self.move_offset_y)

	for x = 0,VIEW_NUM_COLUMNS-1 do
		for y = 0,VIEW_NUM_ROWS-1 do
			local x_off = math.floor(VIEW_NUM_COLUMNS/2)
			local y_off = math.floor(VIEW_NUM_ROWS/2)

			self.view_grid[x][y]:SetTileType( self:GetGameTile( x - x_off + self.pos_x, y - y_off + self.pos_y ) )
		end
	end

	local game_over = (not self.reported_25 and self.score == 25) or (not self.reported_100 and self.score == 100)
	if game_over then
		local over_body = ""		
		local keeper_speak = ""

		if self.score == 25 then
			self.reported_25 = true
			over_body = subfmt( STRINGS.UI.TRADESCREEN.CROWKID_GAME.GAME_OVER_POPUP_BODY_25, { score = self.score } )
			keeper_speak = STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROWKID.GAME_OVER_25
		end
		if self.score == 100 then
			self.reported_100 = true
			over_body = subfmt( STRINGS.UI.TRADESCREEN.CROWKID_GAME.GAME_OVER_POPUP_BODY_100, { score = self.score } )
			keeper_speak = STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROWKID.GAME_OVER_100
		end

		Stats.PushMetricsEvent("CrowKidGameOver", TheNet:GetUserID(), { match_xp = self.score }, "is_only_local_users_data")

		--THE GAME IS OVER! REPORT IT TO THE SERVER AND GET THE ITEM
		local over_title = STRINGS.UI.TRADESCREEN.CROWKID_GAME.GAME_OVER_POPUP_TITLE
		
		local waiting_popup = GenericWaitingPopup("ReportCrowKidGame", STRINGS.UI.TRADESCREEN.CROWKID_GAME.REPORTING, nil, true )
		TheFrontEnd:PushScreen(waiting_popup)			

		TheItems:ReportCrowKidGame(self.score, self.steps_taken, function(status, item_type)
			self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
				print("CrowKid game ended and reported:", status, item_type)
				waiting_popup:Close()

				if status == REPORT_ACCEPTED then
					local game_over_popup = PopupDialogScreen( over_title, over_body,
						{
							{
								text = STRINGS.UI.TRADESCREEN.CROWKID_GAME.OPEN_GIFT,
								cb = function()
									TheFrontEnd:PopScreen()
									local items = {}
									table.insert(items, {item=item_type, item_id=0, gifttype="DEFAULT", message=STRINGS.UI.TRADESCREEN.CROWKID_GAME.THANKS})
									
									local thankyou_popup = ThankYouPopup(items)
									TheFrontEnd:PushScreen(thankyou_popup)
								end
							}
						}
					)
					TheFrontEnd:PushScreen(game_over_popup)
					
				elseif status == REPORT_ALREADY_COMPLETED or status == REPORT_FAILED_TO_CONTACT then
					--todo. Optimize this, by recording it, so we don't report again?
					--don't care about errors for now
					game_over_display( over_title, over_body )
				else
					print("unknown report snowbird game status", status )
				end
				
				self.keeper_speak = keeper_speak
			end )
		end)
	end

	if not self.reported_50 and self.score == 50 then
		self.reported_50 = true
		self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROWKID.MORE )
	end
	if not self.reported_75 and self.score == 75 then
		self.reported_75 = true
		self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROWKID.MORE )
	end

	if self.reported_100 then
		self.startbutton:Enable()	
	else
		self.startbutton:Disable()
	end
	self.resetbutton:Enable()
			
	self.score_text:SetString(STRINGS.UI.TRADESCREEN.CROWKID_GAME.GAME_SCORE .. tostring(self.score))
	self.steps_text:SetString(STRINGS.UI.TRADESCREEN.CROWKID_GAME.STEPS .. tostring(self.steps_taken))
end



function CrowKidGameScreen:Quit()
	self.innkeeper:ClearSpeech()
	if self.joystick then
		self.joystick:Stop()
	end
	TheFrontEnd:FadeBack(nil, nil, function()
		--nothing to do here
	end)
end

function CrowKidGameScreen:OnBecomeActive()
	CrowKidGameScreen._base.OnBecomeActive(self)
	
	self.pressed = {}

	if self.keeper_speak ~= nil then
		self.innkeeper:Say( self.keeper_speak )
		self.keeper_speak = nil
	end
end


function CrowKidGameScreen:DoQueuedMovement()
	if self.queued_direction ~= nil or #self.pressed > 0 then
		local last_pressed = self.pressed[#self.pressed]
		self:OnMovement( self.queued_direction or last_pressed )
		self.queued_direction = nil
	end
end

function CrowKidGameScreen:OnControl(control, down)

	--allow for d-pad + wasd controls
	if control == CONTROL_MOVE_UP then control = CONTROL_FOCUS_UP end
	if control == CONTROL_MOVE_DOWN then control = CONTROL_FOCUS_DOWN end
	if control == CONTROL_MOVE_LEFT then control = CONTROL_FOCUS_LEFT end
	if control == CONTROL_MOVE_RIGHT then control = CONTROL_FOCUS_RIGHT end

	if not down then
		local last_pressed = self.pressed[#self.pressed]
		table.removearrayvalue( self.pressed, control )
		
		--check if the last pressed changed
		if self.pressed[#self.pressed] ~= last_pressed then
			self:OnMovement( self.pressed[#self.pressed] )
		end
	end
	if down and (control == CONTROL_FOCUS_UP or control == CONTROL_FOCUS_DOWN or control == CONTROL_FOCUS_LEFT or control == CONTROL_FOCUS_RIGHT) then	
		table.insert( self.pressed, control )

		self:OnMovement(control)
	end

    if CrowKidGameScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then 
		self:Quit()
		return true 
	end
	
	if down then
		if control == CONTROL_MENU_MISC_1 or control == CONTROL_MENU_START then
			self:InitGameBoard()
			return true
		elseif control == CONTROL_MENU_MISC_2 then
			show_help_fn()
			return true
		end
	end
end


function CrowKidGameScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
	
	if self.resetbutton:IsEnabled() then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.TRADESCREEN.RESET)
	end

	if self.startbutton:IsEnabled() then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.TRADESCREEN.START)
	end

	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.TRADESCREEN.CROWKID_GAME.HELP)
	
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SKINSSCREEN.BACK)
    
    return table.concat(t, "  ")
end

return CrowKidGameScreen
