local Screen = require "widgets/screen"
local MiniGameTile = require "widgets/minigametile"
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

----------------------------------
--GAME STATES
----------------------------------
local GS_GAME_BEGINNING = 0
local GS_TILES_DROPPING = 1
local GS_TRANSITION = 2
local GS_TILE_SELECT_1 = 3
local GS_TILE_SELECT_2 = 4
local GS_GAME_OVER = 5


local TARGET_NUMBER = 100
local TILE_RAND_LIMIT = 20
local EGG_TIMER = 60

local NUM_ROWS = 4
local NUM_COLUMNS = 4
local SPACING = 80
local TILE_SCALE = 1

local DROP_TIME = 0.20
local DROP_WAIT = 0.25

local REPORT_ACCEPTED = "ACCEPTED"
local REPORT_ALREADY_COMPLETED = "ALREADY_REDEEMED"
local REPORT_FAILED_TO_CONTACT = "FAILED_TO_CONTACT"

local SCORE_VERSION = "A"



local function XYtoIndex(x,y)
	return (y * NUM_COLUMNS) + x
end
local function IndexToXY(index)
	local y_click = math.floor(index/NUM_COLUMNS)
	local x_click = index - (y_click * NUM_COLUMNS)
	return x_click, y_click
end

local function GameGridConstructor(screen, parent)
	local widgets = {}

	local x_offset = (NUM_COLUMNS/2) * SPACING + SPACING/2
	local y_offset = (NUM_ROWS/2) * SPACING + SPACING/2

	for y = 1,NUM_ROWS do
		for x = 1,NUM_COLUMNS do
			local index = XYtoIndex( x-1, y-1 )

			local tile = parent:AddChild(MiniGameTile( screen, index ))
			tile:SetScale(TILE_SCALE)
			tile.clickFn = function(index)
				local x_click, y_click = IndexToXY(index)
				screen:OnTileClick(x_click, y_click)
			end

			tile:SetPosition( x * SPACING - x_offset, y * SPACING - y_offset, 0)
			widgets[index] = tile

			if x > 1 then
				tile:SetFocusChangeDir(MOVE_LEFT, widgets[index-1])
				widgets[index-1]:SetFocusChangeDir(MOVE_RIGHT, tile)
			end
			if y > 1 then
				tile:SetFocusChangeDir(MOVE_DOWN, widgets[index-NUM_COLUMNS])
				widgets[index-NUM_COLUMNS]:SetFocusChangeDir(MOVE_UP, tile)
			end
		end
	end

	return widgets
end

local MoverGameTile = function(screen)
	local widg = MiniGameTile(screen, 0, true)
	widg:Hide()
	widg:SetScale(TILE_SCALE)
	widg.Move = function(tile_num, src_pos, dest_pos, drop_time, callbackfn)
		widg:ClearTile()
		widg:SetTileNumber(tile_num)
		widg:Show()
		widg:MoveTo(src_pos, dest_pos, drop_time,
			function()
				widg:Hide()
				if callbackfn then
					callbackfn()
				end
			end)
	end
	return widg
end

local ExplodeFX = Class(Widget, function(self, pos, scale)
    Widget._ctor(self, "ExplodeFX")

	self:SetPosition(pos)
	self:SetScale(scale*0.17)

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("explode")
    self.anim:GetAnimState():SetBuild("explode")
    self.anim:GetAnimState():PlayAnimation("small")
end)


local RobinFX = Class(Widget, function(self, pos, fn)
    Widget._ctor(self, "RobinFX")

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("crow")
    self.anim:GetAnimState():SetBuild("robin_build")
    self.anim:GetAnimState():PushAnimation("takeoff_diagonal_loop", true)
	self.anim:SetScale(TILE_SCALE)

	local dest_pos = {}

	local lr = math.random()
	if lr > 0.5 then
		lr = 1
	else
		lr = -1
	end

	pos.y = pos.y - 40.0

	local x = math.random() * 1000 - 300
	local y = math.random() * 1000 - 300
	dest_pos.x = pos.x + (lr * (700 + x))
	dest_pos.y = pos.y + 900 + y
	dest_pos.z = pos.z
    self.inst.components.uianim:MoveTo(pos, dest_pos, 2.5, function() fn(self) end )

	local scale = 0.28
	self:SetScale(scale*lr, scale, 1)

	self.inst.components.uianim.OnWallUpdate = function(self, dt)
		if self.pos_t then
			self.pos_t = self.pos_t + dt
			if self.pos_t < self.pos_duration then
				local valx = easing.inSine( self.pos_t, self.pos_start.x, self.pos_dest.x - self.pos_start.x, self.pos_duration)
				local valy = easing.inSine( self.pos_t, self.pos_start.y, self.pos_dest.y - self.pos_start.y, self.pos_duration)
				local valz = easing.inSine( self.pos_t, self.pos_start.z, self.pos_dest.z - self.pos_start.z, self.pos_duration)
				self.inst.UITransform:SetPosition(valx, valy, valz)
			else
				local valx = self.pos_dest.x
				local valy = self.pos_dest.y
				local valz = self.pos_dest.z
				self.inst.UITransform:SetPosition(valx, valy, valz)

				self.pos_t = nil
				if self.pos_whendone then
					self.pos_whendone()
					self.pos_whendone = nil
				end
			end
		end

		if not self.scale_t and not self.pos_t and not self.tint_t then
			self.inst:StopWallUpdatingComponent(self)
		end
	end

end)






--------------------------------------------------------------------------------------------------------------------------------------------
-- Class RedbirdGameScreen
--------------------------------------------------------------------------------------------------------------------------------------------
local RedbirdGameScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "RedbirdGameScreen")

	self.profile = profile

	--The rest of the game state is in embeded in the self.game_grid
	self.score = 0
	self.game_state = GS_GAME_BEGINNING
	self.egg_timer = EGG_TIMER

	self:SetupUI()
	self:UpdateInterface()
end)

local LEFT_COLUMN_POS_SCALE = 0.35
local RIGHT_COLUMN_POS_SCALE = 0.35
function RedbirdGameScreen:SetupUI()

	-- FIXED ROOT
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.panel_bg = self.fixed_root:AddChild(TEMPLATES.NoPortalBackground())
	self.menu_bg = self.fixed_root:AddChild(TEMPLATES.LeftGradient())

	self:SetupMachine()

	self.game_grid_root = self.fixed_root:AddChild(Widget("game_grid"))
	self.game_grid_root:SetScale(0.7)
	self.game_grid_root:SetPosition(0, 15)
	self.game_grid = GameGridConstructor(self, self.game_grid_root, false)


	self.score_root = self.fixed_root:AddChild(Widget("score_root"))
	self.score_root:SetPosition(-RESOLUTION_X*LEFT_COLUMN_POS_SCALE, -100)
	self.high_score_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.high_score_text:SetPosition(0, 40)
	self.score_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.egg_timer_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.egg_timer_text:SetPosition(0, 125)

	self.egg_timer_bar = self.score_root:AddChild(UIAnim())
	self.egg_timer_bar:SetPosition( 0, 80 )
    self.egg_timer_bar:GetAnimState():SetBank("skin_progressbar")
    self.egg_timer_bar:GetAnimState():SetBuild("skin_progressbar")
    self.egg_timer_bar:GetAnimState():PlayAnimation("fill_progress", true)
	self.egg_timer_bar:GetAnimState():HideSymbol("block")


    if not TheInput:ControllerAttached() then
    	self.exit_button = self.fixed_root:AddChild(TEMPLATES.BackButton(function() self:Quit() end))
    	self.exit_button:SetPosition(-RESOLUTION_X*.415, -RESOLUTION_Y*.505 + BACK_BUTTON_Y )
    	self.exit_button:Enable()
  	end

	self.scissor_root = self.game_grid_root:AddChild(Widget("scissor"))
	self.scissor_root:SetScissor(-300, -350, 600, 660)

	self.unused_movers = {}
	self.unused_hidden_movers = {}
	self.all_movers = {}
	for y = 1,NUM_ROWS do
		for x = 1,NUM_COLUMNS do
			local mover = MoverGameTile( self )
			self.scissor_root:AddChild(mover)
			self:AddUnusedMoverTile( mover )
			table.insert( self.all_movers, mover )
		end
	end


	self.innkeeper = self.fixed_root:AddChild(SkinCollector( 0, true, STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.START ))
	self.innkeeper:SetPosition(410, -400)
	self.innkeeper:Appear()

	--self:InitGameBoard()

	self.letterbox = self:AddChild(TEMPLATES.ForegroundLetterbox())


	self.default_focus = self.game_grid[XYtoIndex( 1, 1 )]
end

local show_help_fn = function()
	local help_popup = PopupDialogScreen( STRINGS.UI.TRADESCREEN.REDBIRD_GAME.HELP_TITLE, STRINGS.UI.TRADESCREEN.REDBIRD_GAME.HELP_BODY,
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

function RedbirdGameScreen:SetupMachine()

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

function RedbirdGameScreen:PlayMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PlayAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PlayAnimation(name, loop)
end

function RedbirdGameScreen:PushMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PushAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PushAnimation(name, loop)
end



function RedbirdGameScreen:InitGameBoard()
	if self.game_state ~= GS_TILES_DROPPING then
		self.score = 0
		self.egg_timer = EGG_TIMER

		for _,tile in pairs(self.game_grid) do
			tile:ClearTile()
			tile:ShowTile()
		end
		self:FillEmptyTiles( true )
		staticScheduler:ExecuteInTime(DROP_WAIT, function()
			self.game_state = GS_TILE_SELECT_1
		end)
		self:UpdateInterface()
	end
end


function RedbirdGameScreen:ClearExplodedFlags()
	for _,tile in pairs(self.game_grid) do
		tile.exploded = false
	end
end


function RedbirdGameScreen:ExplodeTile( explode_delay, tile, is_bird, is_rotten )
	tile.exploded = true
	staticScheduler:ExecuteInTime(explode_delay, function()
		tile:ClearTile()
		if is_bird then
			if is_rotten then
				TheFrontEnd:GetSound():PlaySound("dontstarve/birds/chirp_robin")

				tile:SetTileTypeUnHidden("oddment_egg_rotten")
			else
				TheFrontEnd:GetSound():PlaySound("dontstarve/birds/takeoff_robin")

				local robin = self.game_grid_root:AddChild( RobinFX( tile:GetPosition(), function(widg) widg:Kill() end ) )
				robin:MoveToFront()

				tile:SetTileTypeUnHidden("oddment_egg")
			end
		else
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/creditpage_flip")
			local explode_widg = ExplodeFX( tile:GetWorldPosition(), self.fixed_root:GetScale().x )
			staticScheduler:ExecuteInTime(1, function() explode_widg:Kill() end)
		end
		self:UpdateInterface()
	end)
end



function RedbirdGameScreen:WaitForClearingToFinish(t)
	self:ClearExplodedFlags()
	staticScheduler:ExecuteInTime(t, function()
		self:DropTiles()
		self:FillEmptyTiles()

		self:UpdateInterface()

		staticScheduler:ExecuteInTime(DROP_WAIT, function()
			self.game_state = GS_TILE_SELECT_1
			self:CheckGameOverCondition()
			if self.queued_click ~= nil then
				self:OnTileClick( self.queued_click.x, self.queued_click.y )
				self.queued_click = nil
			end
			self:UpdateInterface()
		end)
	end)
end


function RedbirdGameScreen:AddUnusedMoverTile(tile)
	table.insert( self.unused_movers, tile )
end
function RedbirdGameScreen:GetMoverTile()
	local mover = self.unused_movers[#self.unused_movers]
	self.unused_movers[#self.unused_movers] = nil
	return mover
end

function RedbirdGameScreen:DropTiles()
	self.game_state = GS_TILES_DROPPING
	for x = 0,NUM_COLUMNS-1 do
		for y = 0,NUM_ROWS-1 do
			local index = XYtoIndex( x, y )
			if self.game_grid[index]:IsClear() then
				local swap_index = -1
				for up_y = y+1,NUM_ROWS-1 do
					local drop_index = XYtoIndex( x, up_y )
					if not self.game_grid[drop_index]:IsClear() then
						swap_index = drop_index
						break
					end
				end
				if swap_index ~= -1 then
					--self.number or self.tile_type
					local num = self.game_grid[swap_index].number
					local tile_type = self.game_grid[swap_index].tile_type
					self.game_grid[swap_index]:ClearTile()

					if num ~= nil then
						self.game_grid[index].number = num --this keeps it hidden but occupied until SetTileNumber is called below

						local dropping_tile = self:GetMoverTile()
						dropping_tile.Move( num,
											self.game_grid[swap_index]:GetPosition(),
											self.game_grid[index]:GetPosition(),
											DROP_TIME, function()
							self.game_grid[index]:SetTileNumber(num)
							self:AddUnusedMoverTile(dropping_tile)
						end)
					else
						--gotta be an egg of some sort
						self.game_grid[index]:SetTileTypeHidden( tile_type )

						local dropping_tile = self:GetMoverTile()
						dropping_tile.Move( nil,
											self.game_grid[swap_index]:GetPosition(),
											self.game_grid[index]:GetPosition(),
											DROP_TIME, function()
							self.game_grid[index]:UnhideTileType()
							self:AddUnusedMoverTile(dropping_tile)
						end)
						dropping_tile:SetTileTypeUnHidden( tile_type )
					end
				end
			end
		end
	end
end

function RedbirdGameScreen:FillEmptyTiles( allow_dupes )
	self.game_state	= GS_TILES_DROPPING
	for x = 0,NUM_COLUMNS-1 do
		local steps = 2
		for y = 0,NUM_ROWS-1 do
			local index = XYtoIndex( x, y )
			if self.game_grid[index]:IsClear() then
				local start_pos = self.game_grid[XYtoIndex( x, NUM_ROWS-1 )]:GetPosition()
				start_pos.y = start_pos.y + SPACING * steps
				steps = steps + 1

				local number = math.random(TILE_RAND_LIMIT)

				self.game_grid[index].number = number --this keeps it hidden but occupied until SetTileNumber is called below

				local filling_tile = self:GetMoverTile()
				filling_tile.Move( number,
									start_pos,
									self.game_grid[index]:GetPosition(),
									DROP_TIME, function()
					self.game_grid[index]:SetTileNumber(number)
					self:AddUnusedMoverTile(filling_tile)
				end)
			end
		end
	end
end

function RedbirdGameScreen:OnTileClick(x, y)
	if self.game_state == GS_TILE_SELECT_1 then
		if self.game_grid[ XYtoIndex(x, y) ].number then
			self.game_state = GS_TILE_SELECT_2

			self.selected_tile = self.game_grid[ XYtoIndex(x, y) ]
			self.selected_tile:HighlightTileNum()
		else
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
		end
	elseif self.game_state == GS_TILE_SELECT_2 then
		local second_tile = self.game_grid[ XYtoIndex(x, y) ]

		local sel_x, sel_y = IndexToXY(self.selected_tile.index)

		if (
				((sel_x - 1) == x and y == sel_y) or
				((sel_x + 1) == x and y == sel_y) or
				(sel_x  == x and y == (sel_y - 1)) or
				(sel_x == x and y == (sel_y + 1)) or
				(sel_x == x and y == sel_y)
			) and
			second_tile.number then

			if self.selected_tile ~= second_tile then
				if self.selected_tile.number + second_tile.number == TARGET_NUMBER then
					local is_rotten = self.egg_timer <= 0

					local points = 0
					if is_rotten then
						points = 250
					else
						points = 1000 + math.ceil(self.egg_timer * 25 )
					end

					if is_rotten then
						self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.EGG_COMPLETE_ROTTEN )
					else
						local phrase = GetRandomItem(STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.EGG_COMPLETE)
						self.innkeeper:Say( subfmt(phrase, { points = points } ) )
					end
					self.score = self.score + points

					self.selected_tile:UnhighlightTileNum()
					self:ExplodeTile(0, self.selected_tile)
					second_tile:SetTileNumber(self.selected_tile.number + second_tile.number)
					self.selected_tile = nil
					self:ExplodeTile(0, second_tile, true, is_rotten )

					self.egg_timer = EGG_TIMER
					self.game_state = GS_TRANSITION
					self:WaitForClearingToFinish(0.2)
				elseif self.selected_tile.number + second_tile.number < TARGET_NUMBER then
					self.score = self.score + self.selected_tile.number + second_tile.number

					self.selected_tile:UnhighlightTileNum()
					self:ExplodeTile(0, self.selected_tile)
					second_tile:SetTileNumber(self.selected_tile.number + second_tile.number)
					self.selected_tile = nil

					self.game_state = GS_TRANSITION
					self:WaitForClearingToFinish(0.2)
				else
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
					self.game_state = GS_TILE_SELECT_1
					self.selected_tile:UnhighlightTileNum()
					self.selected_tile = nil
				end

				if self.score > self.profile:GetRedbirdGameHighScore(SCORE_VERSION) then
					self.profile:SetRedbirdGameHighScore(self.score, SCORE_VERSION)
				end
			else
				--clicked self, unselect the first tile
				self.game_state = GS_TILE_SELECT_1
				self.selected_tile:UnhighlightTileNum()
				self.selected_tile = nil
			end
		else
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
			self.game_state = GS_TILE_SELECT_1
			self.selected_tile:UnhighlightTileNum()
			self.selected_tile = nil
		end
	else
		self.queued_click = { x = x, y = y }
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



function RedbirdGameScreen:OnUpdate(dt)
	if self.game_state ~= GS_GAME_OVER and self.game_state ~= GS_GAME_BEGINNING then
		self.egg_timer = self.egg_timer - dt
	end
	--[[if self.egg_timer <= 0 then
		--make existing eggs rotten
		for _,tile in pairs(self.game_grid) do
			if tile.tile_type == "oddment_egg" then
				tile:SetTileTypeUnHidden("oddment_egg_rotten")
			end
		end
	end]]

	self:UpdateInterface()
end





function RedbirdGameScreen:TileHasMove(x, y)
	if self.game_grid[ XYtoIndex(x, y) ].tile_type ~= "" then
		return false
	end

	local num = self.game_grid[ XYtoIndex(x, y) ].number
	return self:CanAddTo( x + 1, y, num ) or
		self:CanAddTo( x - 1, y, num ) or
		self:CanAddTo( x, y + 1, num ) or
		self:CanAddTo( x, y - 1, num )
end

function RedbirdGameScreen:IsValidPosition(x, y)
	if y >= NUM_ROWS then
		return false
	end
	if y < 0 then
		return false
	end
	if x < 0 then
		return false
	end
	if x >= NUM_COLUMNS then
		return false
	end
	return true
end

function RedbirdGameScreen:CanAddTo( x, y, num )
	if not self:IsValidPosition( x, y ) then
		return false
	end

	local tile = self.game_grid[ XYtoIndex(x, y) ]
	if tile.tile_type ~= "" then
		return false
	end

	if tile.number + num > 100 then
		return false
	end

	return true
end


function RedbirdGameScreen:CheckGameOverCondition()
	local eggs_completed = 0
	local rotten_eggs_completed = 0

	local game_over = true
	for x = 0,NUM_COLUMNS-1 do
		for y = 0,NUM_ROWS-1 do
			if self:TileHasMove(x,y) then
				game_over = false
			end
			if self.game_grid[ XYtoIndex(x, y) ].tile_type == "oddment_egg" then
				eggs_completed = eggs_completed + 1
			end

			if self.game_grid[ XYtoIndex(x, y) ].tile_type == "oddment_egg_rotten" then
				rotten_eggs_completed = rotten_eggs_completed + 1
			end
		end
	end

	if game_over then
		self.game_state = GS_GAME_OVER

		Stats.PushMetricsEvent("RedbirdGameOver", TheNet:GetUserID(), { match_xp = self.score, level = eggs_completed }, "is_only_local_users_data")

		--THE GAME IS OVER! REPORT IT TO THE SERVER AND GET THE ITEM
		local over_title = STRINGS.UI.TRADESCREEN.REDBIRD_GAME.GAME_OVER_POPUP_TITLE
		local over_body = ""
		if eggs_completed == 1 then
			over_body = subfmt( STRINGS.UI.TRADESCREEN.REDBIRD_GAME.GAME_OVER_POPUP_BODY_SINGULAR, { score = self.score, eggs = eggs_completed } )
		else
			over_body = subfmt( STRINGS.UI.TRADESCREEN.REDBIRD_GAME.GAME_OVER_POPUP_BODY, { score = self.score, eggs = eggs_completed } )
		end

		if eggs_completed >= 6 or rotten_eggs_completed > 0 then
			local waiting_popup = GenericWaitingPopup("ReportRedbirdGame", STRINGS.UI.TRADESCREEN.REDBIRD_GAME.REPORTING, nil, true )
			TheFrontEnd:PushScreen(waiting_popup)

			TheItems:ReportRedbirdGame(self.score, eggs_completed, rotten_eggs_completed, function(status, item_type)
				self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
					print("Redbird game ended and reported:", status, item_type)
					waiting_popup:Close()

					if status == REPORT_ACCEPTED then
						local game_over_popup = PopupDialogScreen( over_title, over_body,
							{
								{
									text = STRINGS.UI.TRADESCREEN.REDBIRD_GAME.OPEN_GIFT,
									cb = function()
										TheFrontEnd:PopScreen()
										local items = {}
										table.insert(items, {item=item_type, item_id=0, gifttype="DEFAULT", message=STRINGS.UI.TRADESCREEN.REDBIRD_GAME.THANKS})

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
						print("unknown report redbird game status", status )
					end
				end )
			end)
		else
			game_over_display( over_title, over_body )
		end

		if eggs_completed >= 12 then
			self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.GAME_OVER_REDBIRD )
		elseif eggs_completed >= 6 then
			self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.GAME_OVER_EGG )
		elseif rotten_eggs_completed > 0 then
			self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.GAME_OVER_ROTTEN )
		else
			self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_REDBIRD.GAME_OVER )
		end
	end
end

function RedbirdGameScreen:UpdateInterface()
	if not (self.inst:IsValid()) then
        return
	end

	if self.game_state == GS_GAME_OVER or self.game_state == GS_GAME_BEGINNING then
		self.startbutton:Enable()
		self.resetbutton:Disable()
	else
		self.startbutton:Disable()
		self.resetbutton:Enable()
	end

	if self.game_state == GS_GAME_OVER then
		self.egg_timer_text:SetString( STRINGS.UI.TRADESCREEN.REDBIRD_GAME.EGG_TIMER_OVER )

		self.egg_timer_bar:Hide()
	else
		if self.egg_timer > 0 then
			self.egg_timer_text:SetString( STRINGS.UI.TRADESCREEN.REDBIRD_GAME.EGG_TIMER )
			self.egg_timer_bar:GetAnimState():SetPercent("fill_progress", math.ceil(self.egg_timer)/EGG_TIMER )
		else
			self.egg_timer_text:SetString(STRINGS.UI.TRADESCREEN.REDBIRD_GAME.EGG_TIMER_SPOILED)
			self.egg_timer_bar:GetAnimState():SetPercent("fill_progress", 0)
		end

		self.egg_timer_bar:Show()
	end

	self.high_score_text:SetString(STRINGS.UI.TRADESCREEN.REDBIRD_GAME.HIGH_SCORE .. tostring(self.profile:GetRedbirdGameHighScore(SCORE_VERSION)))
	self.score_text:SetString(STRINGS.UI.TRADESCREEN.REDBIRD_GAME.GAME_SCORE .. tostring(self.score))
end


function RedbirdGameScreen:Quit()
	self.innkeeper:ClearSpeech()
	if self.joystick then
		self.joystick:Stop()
	end
	TheFrontEnd:FadeBack(nil, nil, function()
        for _,mover in pairs( self.all_movers ) do
			mover:Kill()
		end
	end)
end

function RedbirdGameScreen:OnBecomeActive()
	RedbirdGameScreen._base.OnBecomeActive(self)
end

function RedbirdGameScreen:OnControl(control, down)
    if RedbirdGameScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
		self:Quit()
		return true
	end

	if down then
		if control == CONTROL_MENU_MISC_1 or control == CONTROL_PAUSE then
			self:InitGameBoard()
			return true
		elseif control == CONTROL_INSPECT then
			show_help_fn()
			return true
		end
	end
end


function RedbirdGameScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if self.resetbutton:IsEnabled() then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.TRADESCREEN.RESET)
	end

	if self.startbutton:IsEnabled() then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.TRADESCREEN.START)
	end

	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.TRADESCREEN.REDBIRD_GAME.HELP)

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SKINSSCREEN.BACK)

    return table.concat(t, "  ")
end

return RedbirdGameScreen
