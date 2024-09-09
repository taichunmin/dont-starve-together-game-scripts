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
local GS_TILES_CLEARING = 0
local GS_TILES_DROPPING = 1
local GS_TILE_SELECT_REG = 2
local GS_TILE_SELECT_CLEAR = 3
local GS_TILE_SELECT_SLICE = 4
local GS_TILE_SELECT_BOMB = 5
local GS_TILE_SELECT_ARROW = 6
local GS_TILE_SELECT_BAIT = 7
local GS_GAME_OVER = 8

local POWERUPS = {
	{ powerup = "cane", 		game_state = GS_TILE_SELECT_CLEAR, image = "cane"      },
	{ powerup = "shovel", 		game_state = GS_TILE_SELECT_SLICE, image = "shovel"    },
	{ powerup = "gunpowder", 	game_state = GS_TILE_SELECT_BOMB,  image = "gunpowder" },
	{ powerup = "spear", 		game_state = GS_TILE_SELECT_ARROW, image = "spear"     },
	{ powerup = "seeds", 		game_state = GS_TILE_SELECT_BAIT,  image = "seeds"     },
}





local TILE_UP = 0
local TILE_DOWN = 1
local TILE_LEFT = 2
local TILE_RIGHT = 3

local CROW_TILE = "oddment_crow"

local TILE_TYPES = {"oddment_chevron_wrapper",
					"oddment_dotted_wrapper",
					"oddment_flower_wrapper",
					"oddment_foil_wrapper",
					"oddment_paper_wrapper",
					"oddment_striped_wrapper",
					"oddment_bluestriped_wrapper",
					CROW_TILE}



local NUM_ROWS = 7
local NUM_COLUMNS = 5
local SPACING = 75
local TILE_SCALE = 1
local PWUP_BUTTON_SCALE = 1.2
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--TODO(Peter)
--Make it so the drop wait can be less than the drop_time
--Make the data always be real, don't wait for the mover callback to set it in the tile grid, (lol ew)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DROP_TIME = 0.20
local DROP_WAIT = 0.25
local EXPLODE_TIME_DELAY = 0.07

local REPORT_CROW_ACCEPTED = "ACCEPTED"
local REPORT_CROW_ALREADY_COMPLETED = "ALREADY_REDEEMED"
local REPORT_CROW_FAILED_TO_CONTACT = "FAILED_TO_CONTACT"

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

			local crowtile = parent:AddChild(MiniGameTile( screen, index ))
			crowtile.clickFn = function(index)
				local x_click, y_click = IndexToXY(index)
				screen:OnTileClick(x_click, y_click)
			end

			crowtile:SetPosition( x * SPACING - x_offset, y * SPACING - y_offset, 0)
			widgets[index] = crowtile

			if x > 1 then
				crowtile:SetFocusChangeDir(MOVE_LEFT, widgets[index-1])
				widgets[index-1]:SetFocusChangeDir(MOVE_RIGHT, crowtile)
			end
			if y > 1 then
				crowtile:SetFocusChangeDir(MOVE_DOWN, widgets[index-NUM_COLUMNS])
				widgets[index-NUM_COLUMNS]:SetFocusChangeDir(MOVE_UP, crowtile)
			end
		end
	end

	return widgets
end

local MoverGameTile = function(screen)
	local widg = MiniGameTile(screen, 0, true)
	widg:Hide()
	widg:SetScale(TILE_SCALE)
	widg.Move = function(tile_type, src_pos, dest_pos, drop_time, callbackfn)
		widg:SetTileTypeUnHidden(tile_type)
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


local CrowFX = Class(Widget, function(self, pos, fn)
    Widget._ctor(self, "CrowFX")

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("crow")
    self.anim:GetAnimState():SetBuild("crow_build")
    self.anim:GetAnimState():PushAnimation("takeoff_diagonal_loop", true)

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
-- Class CrowGameScreen
--------------------------------------------------------------------------------------------------------------------------------------------
local CrowGameScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "CrowGameScreen")

	self.profile = profile

	--The rest of the game state is in embeded in the self.game_grid
	self.score = 0
	self.move_score = 0
	self.moves = 0
	self.crows_cleared = 0
	self.tiles_cleared = 0
	self.game_state = GS_GAME_OVER

    self:GetPowerupData()
	self:SetupUI()
	self:UpdateInterface()
end)

local LEFT_COLUMN_POS_SCALE = 0.35
local RIGHT_COLUMN_POS_SCALE = 0.35
function CrowGameScreen:SetupUI()

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
	self.score_root:SetPosition(-RESOLUTION_X*LEFT_COLUMN_POS_SCALE, -33)
	self.high_score_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.high_score_text:SetPosition(0, 40)
	self.score_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.move_score_text = self.score_root:AddChild(Text(TALKINGFONT, 24, "", {1, 1, 1, 1}))
	self.move_score_text:SetPosition(0, -40)

    if not TheInput:ControllerAttached() then
    	self.exit_button = self.fixed_root:AddChild(TEMPLATES.BackButton(function() self:Quit() end))
    	self.exit_button:SetPosition(-RESOLUTION_X*.415, -RESOLUTION_Y*.505 + BACK_BUTTON_Y )
    	self.exit_button:Enable()
  	end

	self.scissor_root = self.game_grid_root:AddChild(Widget("scissor"))
	self.scissor_root:SetScissor(-300, -350, 600, 660)

	self.unused_movers = {}
	self.all_movers = {}
	for y = 1,NUM_ROWS do
		for x = 1,NUM_COLUMNS do
			local mover = MoverGameTile( self )
			self.scissor_root:AddChild(mover)

			self:AddUnusedMoverTile( mover )
			table.insert( self.all_movers, mover )
		end
	end

	self.game_grid_root:SetFocusChangeDir(MOVE_DOWN, self.pwup_root)
	self.pwup_root:SetFocusChangeDir(MOVE_UP, self.game_grid[XYtoIndex( 2, 0 )])

	-- Skin collector
	self.innkeeper = self.fixed_root:AddChild(SkinCollector( 0, true, STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROW.START ))
	self.innkeeper:SetPosition(410, -400)
	self.innkeeper:Appear()

	self:InitGameBoard()

	self.letterbox = self:AddChild(TEMPLATES.ForegroundLetterbox())


	self.default_focus = self.game_grid[XYtoIndex( 2, 3 )]
end

local show_help_fn = function()
	local help_popup = PopupDialogScreen( STRINGS.UI.TRADESCREEN.CROW_GAME.HELP_TITLE, STRINGS.UI.TRADESCREEN.CROW_GAME.HELP_BODY,
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

function CrowGameScreen:SetupMachine()

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


	self.pwup_root = self.claw_machine:AddChild(Widget("pwup_root"))
	if TheInput:ControllerAttached() then
		self.pwup_root:SetPosition(0, -610)
	else
		self.pwup_root:SetPosition(0, -650)
	end
	self.pwup_button = {}
	self.pwup_txt = {}
	for order,data in ipairs(POWERUPS) do
		self:AddPowerupUI( order-1, data )
	end


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

function CrowGameScreen:PlayMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PlayAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PlayAnimation(name, loop)
end

function CrowGameScreen:PushMachineAnim( name, loop )
	self.claw_machine:GetAnimState():PushAnimation(name, loop)
	self.claw_machine_bg:GetAnimState():PushAnimation(name, loop)
end


function CrowGameScreen:AddPowerupUI( order, data )
	local spacing = 90
	local x_pos = order * spacing - (2 * spacing)

	self.pwup_button[data.powerup] = self.pwup_root:AddChild(NEW_TEMPLATES.IconButton("images/tradescreen_overflow.xml", data.image..".tex", STRINGS.UI.TRADESCREEN.CROW_GAME.POWERUP_NAME[data.powerup], false, false, function()
		self:PowerupBtn(data.powerup)
	end, {offset_y = 45}))

	self.pwup_button[data.powerup]:SetPosition(x_pos, 0)
	self.pwup_button[data.powerup]:SetScale(PWUP_BUTTON_SCALE)

	self.pwup_txt[data.powerup] = self.pwup_button[data.powerup]:AddChild(Text(TALKINGFONT, 26, "", {1, 1, 1, 1}))
	self.pwup_txt[data.powerup]:SetPosition(-10, 2)
end

function CrowGameScreen:InitGameBoard()
	if self.game_state ~= GS_TILES_DROPPING then
		self.score = 0
		self.move_score = 0
		self.moves = 0
		self.crows_cleared = 0
		self.tiles_cleared = 0
		for _,data in pairs(POWERUPS) do
			self.num_powerup[data.powerup] = self.num_powerup_default[data.powerup]
		end

		for _,tile in pairs(self.game_grid) do
			tile:ClearTile()
		end
		self:FillEmptyTiles()
		staticScheduler:ExecuteInTime(DROP_WAIT, function()
			self.game_state = GS_TILE_SELECT_REG
			self:UpdateInterface()
		end)
		self:UpdateInterface()
	end
end

function CrowGameScreen:CalcMoveScore()
	self.move_score = self.tiles_cleared * self.tiles_cleared * 5 * (self.crows_cleared + 1) + self.crows_cleared * 25
end

function CrowGameScreen:GetMoveScore()
	return self.move_score
end

function getPowerUpData(pwup)
	for _,data in ipairs(POWERUPS) do
		if pwup == data.powerup then
			return data
		end
	end
end

function CrowGameScreen:PowerupBtn(pwup)
	if self.game_state == GS_TILE_SELECT_REG and self.num_powerup[pwup] > 0 then
		self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROW.POWERUP_SELECTED[pwup] )
		self.game_state = getPowerUpData(pwup).game_state
		self.num_powerup[pwup] = self.num_powerup[pwup] - 1
		self:UpdateInterface()
	elseif self.game_state == getPowerUpData(pwup).game_state then
		self.innkeeper:ClearSpeech()
		self.game_state = GS_TILE_SELECT_REG
		self.num_powerup[pwup] = self.num_powerup[pwup] + 1
		self:UpdateInterface()
	end
end

function sign(x) return x > 0 and 1 or x < 0 and -1 or 0 end

function CrowGameScreen:OnTileClick(x, y)
	self.innkeeper:ClearSpeech()
	if self.game_state == GS_TILE_SELECT_REG then
		--check if any neighbours are matching
		if self:TileHasMove(x,y) then
			self.game_state = GS_TILES_CLEARING

			self.crows_cleared = 0
			self.tiles_cleared = 0
			self:UpdateInterface()

			local explode_delay = self:ClearTilesNoRec(x, y)

			self:WaitForClearingToFinish(explode_delay)
		end
	elseif self.game_state == GS_TILE_SELECT_CLEAR then
		if self.game_grid[ XYtoIndex(x, y) ].tile_type ~= CROW_TILE then
			self.game_state = GS_TILES_CLEARING

			self.crows_cleared = 0
			self.tiles_cleared = 0
			self:UpdateInterface()

			local clearing_tile_type = self.game_grid[ XYtoIndex(x, y) ].tile_type

			local explode_delay = 0
			for grid_x = 0,NUM_COLUMNS-1 do
				for grid_y = 0,NUM_ROWS-1 do
					if self.game_grid[XYtoIndex( grid_x, grid_y )].tile_type == clearing_tile_type then
						local delay = (math.abs(grid_x-x) + math.abs(grid_y-y)) * EXPLODE_TIME_DELAY
						self:ExplodeTile(delay, grid_x, grid_y)
						explode_delay = math.max(explode_delay, delay)
					end
				end
			end

			self:WaitForClearingToFinish(explode_delay+EXPLODE_TIME_DELAY) --need a slight addition so that the clearing tiles finish before we start dropping
		end
	elseif self.game_state == GS_TILE_SELECT_SLICE then
		self.game_state = GS_TILES_CLEARING

		self.crows_cleared = 0
		self.tiles_cleared = 0
		self:UpdateInterface()

		local explode_delay = 0
		for grid_x = 0,NUM_COLUMNS-1 do
			local delay = math.abs(grid_x-x) * EXPLODE_TIME_DELAY
			self:ExplodeTile(delay, grid_x, y)
			explode_delay = math.max(explode_delay, delay)
		end

		self:WaitForClearingToFinish(explode_delay+EXPLODE_TIME_DELAY)

	elseif self.game_state == GS_TILE_SELECT_BOMB then
		self.game_state = GS_TILES_CLEARING

		self.crows_cleared = 0
		self.tiles_cleared = 0
		self:UpdateInterface()

		if self:IsValidPosition(x-1, y+1) then self:ExplodeTile(6*EXPLODE_TIME_DELAY, x-1, y+1) end
		if self:IsValidPosition(x+0, y+1) then self:ExplodeTile(7*EXPLODE_TIME_DELAY, x+0, y+1) end
		if self:IsValidPosition(x+1, y+1) then self:ExplodeTile(8*EXPLODE_TIME_DELAY, x+1, y+1) end

		if self:IsValidPosition(x-1, y+0) then self:ExplodeTile(5*EXPLODE_TIME_DELAY, x-1, y+0) end
		if self:IsValidPosition(x+0, y+0) then self:ExplodeTile(0*EXPLODE_TIME_DELAY, x+0, y+0) end
		if self:IsValidPosition(x+1, y+0) then self:ExplodeTile(1*EXPLODE_TIME_DELAY, x+1, y+0) end

		if self:IsValidPosition(x-1, y-1) then self:ExplodeTile(4*EXPLODE_TIME_DELAY, x-1, y-1) end
		if self:IsValidPosition(x+0, y-1) then self:ExplodeTile(3*EXPLODE_TIME_DELAY, x+0, y-1) end
		if self:IsValidPosition(x+1, y-1) then self:ExplodeTile(2*EXPLODE_TIME_DELAY, x+1, y-1) end

		self:WaitForClearingToFinish(9*EXPLODE_TIME_DELAY) --need a slight addition so that the clearing tiles finish before we start dropping
	elseif self.game_state == GS_TILE_SELECT_ARROW then
		self.game_state = GS_TILES_CLEARING

		self.crows_cleared = 0
		self.tiles_cleared = 0
		self:UpdateInterface()

		self:ExplodeTile(0, x, y)

		self:WaitForClearingToFinish(EXPLODE_TIME_DELAY) --need a slight addition so that the clearing tiles finish before we start dropping
	elseif self.game_state == GS_TILE_SELECT_BAIT then
		self.game_state = GS_TILES_CLEARING

		self.crows_cleared = 0
		self.tiles_cleared = 0
		self:UpdateInterface()

		--place crow at bait point, so there's atleast 1 crow
		self.game_grid[XYtoIndex(x,y)]:SetTileTypeUnHidden( CROW_TILE )
		self.game_grid[XYtoIndex(x,y)].crow_walked = true
		self.game_grid[XYtoIndex(x,y)].final_crow_pos = true

		for tile_index,tile in pairs(self.game_grid) do
			tile.start_index = tile_index
		end

		local check_crows = true
		while check_crows do
			check_crows = false
			for start_index,tile in pairs(self.game_grid) do
				if tile.tile_type == CROW_TILE and not tile.final_crow_pos then
					--tile.crow_walked = true
					check_crows = true

					--now walk crows to bait point, xy, stopping when we hit a walked crow
					local crow_x, crow_y = IndexToXY(start_index)
					local walking = true
					while walking do
						local current_index = XYtoIndex( crow_x, crow_y )

						--find biggest axis away
						local x_dist = math.abs(x - crow_x)
						local y_dist = math.abs(y - crow_y)
						--What if the desired axis is blocked, but we can move closer on the other axis?
						if x_dist > y_dist then
							--move on x
							crow_x = crow_x + sign(x - crow_x)
						else
							--move on y
							crow_y = crow_y + sign(y - crow_y)
						end

						local next_index = XYtoIndex( crow_x, crow_y )

						if self.game_grid[next_index].final_crow_pos then
							self.game_grid[current_index].final_crow_pos = true
							walking = false
						else
							--swap tiles
							local tmp_type = self.game_grid[next_index].tile_type
							self.game_grid[next_index].tile_type = self.game_grid[current_index].tile_type
							self.game_grid[current_index].tile_type = tmp_type

							local tmp_index = self.game_grid[next_index].start_index
							self.game_grid[next_index].start_index = self.game_grid[current_index].start_index
							self.game_grid[current_index].start_index = tmp_index
						end
					end
				end
			end
		end

		for tile_index,tile in pairs(self.game_grid) do
			if tile_index ~= tile.start_index then
				local start_index = tile.start_index

				tile:SetTileTypeHidden(tile.tile_type)

				local mover = self:GetMoverTile()
				mover.Move(tile.tile_type,
									self.game_grid[start_index]:GetPosition(),
									self.game_grid[tile_index]:GetPosition(),
									DROP_TIME, function()
					self.game_grid[tile_index]:UnhideTileType()
					self:AddUnusedMoverTile(mover)
				end)
			end
		end

		self:WaitForClearingToFinish(DROP_TIME+EXPLODE_TIME_DELAY) --need a slight addition so that the clearing tiles finish before we start dropping
	else
		self.queued_click = { x = x, y = y }
	end
end

function CrowGameScreen:ClearExplodedFlags()
	for _,tile in pairs(self.game_grid) do
		tile.exploded = false
		tile.reserved = false
		tile.new_index = nil
		tile.start_index = nil
		tile.final_crow_pos = nil
	end
end

function CrowGameScreen:IsValidPosition(x, y)
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

function CrowGameScreen:TileHasMove(x, y)
	return self.game_grid[ XYtoIndex(x, y) ].tile_type ~= CROW_TILE and
		(self:DoesNeighbourMatch( x, y, TILE_UP ) or
		self:DoesNeighbourMatch( x, y, TILE_DOWN ) or
		self:DoesNeighbourMatch( x, y, TILE_LEFT ) or
		self:DoesNeighbourMatch( x, y, TILE_RIGHT ))
end

function CrowGameScreen:DoesNeighbourMatch( x, y, direction, clearing_tile_type )
	--Verify against the extents of the gameboard
	local new_x = x
	local new_y = y
	if direction == TILE_UP then
		if y+1 >= NUM_ROWS then
			return false
		end
		new_y = y + 1
	elseif direction == TILE_DOWN then
		if y-1 < 0 then
			return false
		end
		new_y = y - 1
	elseif direction == TILE_LEFT then
		if x-1 < 0 then
			return false
		end
		new_x = x - 1
	elseif direction == TILE_RIGHT then
		if x+1 >= NUM_COLUMNS then
			return false
		end
		new_x = x + 1
	else
		assert( false, "Bad neighbour direction" )
	end

	if clearing_tile_type ~= nil then
		local this_tile = self.game_grid[ XYtoIndex(x, y) ]
		local neighbour_tile = self.game_grid[ XYtoIndex(new_x, new_y) ]
		if neighbour_tile.exploded then
			if this_tile.tile_type == clearing_tile_type or this_tile.tile_type == CROW_TILE then
				return true
			end
		end
		return false
	else
		return self.game_grid[ XYtoIndex(x, y) ].tile_type == self.game_grid[ XYtoIndex(new_x, new_y) ].tile_type
	end
end

function CrowGameScreen:ExplodeTile( explode_delay, x, y )
	self.game_grid[ XYtoIndex(x, y) ].exploded = true
	staticScheduler:ExecuteInTime(explode_delay, function()
		if self.game_grid[ XYtoIndex(x,y) ].tile_type == CROW_TILE then
			self.crows_cleared = self.crows_cleared + 1
			self.game_grid[ XYtoIndex(x,y) ]:ClearTile()
			TheFrontEnd:GetSound():PlaySound("dontstarve/birds/takeoff_crow")

			local crow = self.game_grid_root:AddChild( CrowFX( self.game_grid[XYtoIndex(x,y)]:GetPosition(), function(widg) widg:Kill() end ) )
			crow:MoveToFront()
		else
			self.tiles_cleared = self.tiles_cleared + 1
			self.game_grid[ XYtoIndex(x,y) ]:ClearTile()

			local explode_widg = ExplodeFX( self.game_grid[XYtoIndex(x,y)]:GetWorldPosition(), self.fixed_root:GetScale().x )
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/creditpage_flip")

			staticScheduler:ExecuteInTime(1, function() explode_widg:Kill() end)
		end
		self:UpdateInterface()
	end)
end

function CrowGameScreen:ClearTilesNoRec( start_x, start_y )
	self:ExplodeTile(0, start_x, start_y)
	local tile_type = self.game_grid[ XYtoIndex(start_x, start_y) ].tile_type

	local explode_delay = EXPLODE_TIME_DELAY
	local new_explode = true
	while new_explode do
		new_explode = false
		for x = 0,NUM_COLUMNS-1 do
			for y = 0,NUM_ROWS-1 do
				if not self.game_grid[XYtoIndex( x, y )].exploded then
					if self:DoesNeighbourMatch( x, y, TILE_UP, tile_type ) or
					self:DoesNeighbourMatch( x, y, TILE_DOWN, tile_type ) or
					self:DoesNeighbourMatch( x, y, TILE_LEFT, tile_type ) or
					self:DoesNeighbourMatch( x, y, TILE_RIGHT, tile_type ) then
						self.game_grid[XYtoIndex( x, y )].pending_explode = true
					end
				end
			end
		end
		--second loop, so that setting an explode flag on a tile, does trigger an explode on the next row/column
		for x = 0,NUM_COLUMNS-1 do
			for y = 0,NUM_ROWS-1 do
				if self.game_grid[XYtoIndex( x, y )].pending_explode then
					self.game_grid[XYtoIndex( x, y )].pending_explode = nil
					self:ExplodeTile(explode_delay, x, y)
					new_explode = true
				end
			end
		end
		explode_delay = explode_delay + EXPLODE_TIME_DELAY
	end
	return explode_delay
end



function CrowGameScreen:WaitForClearingToFinish(t)
	self:ClearExplodedFlags()
	staticScheduler:ExecuteInTime(t, function()
		self:CalcMoveScore()
		self.score = self.score + self:GetMoveScore()
		if self.score > self.profile:GetCrowGameHighScore(SCORE_VERSION) then
			self.profile:SetCrowGameHighScore(self.score, SCORE_VERSION)
		end
		self.moves = self.moves + 1
		self:GrantBonusPowerups()
		self:DropTiles()
		self:FillEmptyTiles()

		self:UpdateInterface()

		staticScheduler:ExecuteInTime(DROP_WAIT, function()
			self.game_state = GS_TILE_SELECT_REG
			if self.queued_click ~= nil then
				self:OnTileClick( self.queued_click.x, self.queued_click.y )
				self.queued_click = nil
			end
			self:UpdateInterface()
		end)
	end)
end


function CrowGameScreen:AddUnusedMoverTile(tile)
	table.insert( self.unused_movers, tile )
end
function CrowGameScreen:GetMoverTile()
	local mover = self.unused_movers[#self.unused_movers]
	self.unused_movers[#self.unused_movers] = nil
	return mover
end

function CrowGameScreen:DropTiles()
	self.game_state = GS_TILES_DROPPING
	for x = 0,NUM_COLUMNS-1 do
		for y = 0,NUM_ROWS-1 do
			local index = XYtoIndex( x, y )
			if self.game_grid[index].tile_type == "" then
				local swap_index = -1
				for up_y = y+1,NUM_ROWS-1 do
					local drop_index = XYtoIndex( x, up_y )
					if self.game_grid[drop_index].tile_type ~= "" then
						swap_index = drop_index
						break
					end
				end
				if swap_index ~= -1 then
					local dropping_tile_type = self.game_grid[swap_index].tile_type

					self.game_grid[swap_index]:ClearTile()
					self.game_grid[index]:SetTileTypeHidden( dropping_tile_type )

					local dropping_tile = self:GetMoverTile()
					dropping_tile.Move(dropping_tile_type,
										self.game_grid[swap_index]:GetPosition(),
										self.game_grid[index]:GetPosition(),
										DROP_TIME, function()
						self.game_grid[index]:UnhideTileType()
						self:AddUnusedMoverTile(dropping_tile)
					end)
				end
			end
		end
	end
end

function CrowGameScreen:FillEmptyTiles()
	self.game_state	= GS_TILES_DROPPING
	for x = 0,NUM_COLUMNS-1 do
		local steps = 2
		for y = 0,NUM_ROWS-1 do
			local index = XYtoIndex( x, y )
			if self.game_grid[index].tile_type == "" then
				local start_pos = self.game_grid[XYtoIndex( x, NUM_ROWS-1 )]:GetPosition()
				start_pos.y = start_pos.y + SPACING * steps
				steps = steps + 1

				local new_tile_type = TILE_TYPES[math.random(#TILE_TYPES)]
				self.game_grid[index]:SetTileTypeHidden( new_tile_type )

				local filling_tile = self:GetMoverTile()
				filling_tile.Move(new_tile_type,
									start_pos,
									self.game_grid[index]:GetPosition(),
									DROP_TIME, function()
					self.game_grid[index]:UnhideTileType()
					self:AddUnusedMoverTile(filling_tile)
				end)
			end
		end
	end
end

function CrowGameScreen:GrantBonusPowerups()
	if (self.tiles_cleared + self.crows_cleared) >= 10 then

		local powerup_data = GetRandomItem(POWERUPS)
		local pup = powerup_data.powerup
		self.num_powerup[pup] = self.num_powerup[pup] + 1

		local str = subfmt( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROW.CLEARED_LOTS, { tiles_cleared = self.tiles_cleared + self.crows_cleared, powerup = STRINGS.UI.TRADESCREEN.CROW_GAME.POWERUP_NAME[pup] } )
		self.innkeeper:Say( str )

	elseif self.crows_cleared >= 5 then
		self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROW.CLEARED_CROW_LOTS )
	end
end


function CrowGameScreen:UpdateInterface()
	if not (self.inst:IsValid()) then
        return
    end

	if self.game_state == GS_TILE_SELECT_REG then
		local game_over = true
		for powerup,_ in pairs(self.pwup_button) do
			if self.num_powerup[powerup] > 0 then
				game_over = false
			end
		end
		local has_board_move = false
		for x = 0,NUM_COLUMNS-1 do
			for y = 0,NUM_ROWS-1 do
				if self:TileHasMove(x,y) then
					has_board_move = true
					game_over = false
					break
				end
			end
		end
		if game_over then
			self.game_state = GS_GAME_OVER

			Stats.PushMetricsEvent("CrowGameOver", TheNet:GetUserID(), { level = self.moves, match_xp = self.score }, "is_only_local_users_data")

			--THE GAME IS OVER! REPORT IT TO THE SERVER AND GET THE ITEM
			local waiting_popup = GenericWaitingPopup("ReportCrowGame", STRINGS.UI.TRADESCREEN.CROW_GAME.REPORTING, nil, true )
			TheFrontEnd:PushScreen(waiting_popup)

			TheItems:ReportCrowGame(self.score, self.moves, function(status, item_type)
				self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
					print("Crow game ended and reported:", status, item_type)
					waiting_popup:Close()

					local over_title = STRINGS.UI.TRADESCREEN.CROW_GAME.GAME_OVER_POPUP_TITLE
					local over_body = subfmt( STRINGS.UI.TRADESCREEN.CROW_GAME.GAME_OVER_POPUP_BODY, { score = self.score, moves = self.moves } )
					if status == REPORT_CROW_ACCEPTED then
						local game_over_popup = PopupDialogScreen( over_title, over_body,
							{
								{
									text = STRINGS.UI.TRADESCREEN.CROW_GAME.OPEN_GIFT,
									cb = function()
										TheFrontEnd:PopScreen()
										local items = {}
										table.insert(items, {item=item_type, item_id=0, gifttype="DEFAULT", message=STRINGS.UI.TRADESCREEN.CROW_GAME.THANKS})

										local thankyou_popup = ThankYouPopup(items)
										TheFrontEnd:PushScreen(thankyou_popup)
									end
								}
							}
						)
						TheFrontEnd:PushScreen(game_over_popup)

					elseif status == REPORT_CROW_ALREADY_COMPLETED or status == REPORT_CROW_FAILED_TO_CONTACT then
						--todo. Optimize this, by recording it, so we don't report again?
						--don't care about errors for now
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
					else
						print("unknown report crow game status", status )
					end
				end )
			end)

			self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROW.GAME_OVER )
		else
			if not has_board_move then
				self.innkeeper:Say( STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH_CROW.USE_POWERUP )
			end
		end
	end

	if self.game_state == GS_GAME_OVER then
		self.startbutton:Enable()
		self.resetbutton:Disable()
	else
		self.startbutton:Disable()
		self.resetbutton:Enable()
	end

	local forward_to_first = true
	local last_active_pwup = ""
	for powerup,_ in pairs(self.pwup_button) do
		self.pwup_txt[powerup]:SetString( tostring(self.num_powerup[powerup]) )

		if self.num_powerup[powerup] > 0 and self.game_state == GS_TILE_SELECT_REG or self.game_state == getPowerUpData(powerup).game_state then
			if self.game_state == getPowerUpData(powerup).game_state then
				self.pwup_button[powerup]:SetScale(PWUP_BUTTON_SCALE*1.4)
			else
				self.pwup_button[powerup]:SetScale(PWUP_BUTTON_SCALE)
			end
			self.pwup_button[powerup]:Enable()
		else
			self.pwup_button[powerup]:Disable()
			self.pwup_button[powerup]:SetScale(PWUP_BUTTON_SCALE)
		end
	end

	--fixup powerup focus changing
	for _,data in ipairs(POWERUPS) do
		local powerup = data.powerup

		if self.pwup_button[powerup]:IsEnabled() then
			if forward_to_first then
				self.pwup_root.focus_forward = self.pwup_button[powerup]
				forward_to_first = false
			end

			if last_active_pwup ~= "" then
				self.pwup_button[last_active_pwup]:SetFocusChangeDir(MOVE_RIGHT, self.pwup_button[powerup])
				self.pwup_button[powerup]:SetFocusChangeDir(MOVE_LEFT, self.pwup_button[last_active_pwup])
			end
			last_active_pwup = powerup
		end
	end


	self.high_score_text:SetString(STRINGS.UI.TRADESCREEN.CROW_GAME.HIGH_SCORE .. tostring(self.profile:GetCrowGameHighScore(SCORE_VERSION)))
	self.score_text:SetString(STRINGS.UI.TRADESCREEN.CROW_GAME.GAME_SCORE .. tostring(self.score))
	self.move_score_text:SetString(STRINGS.UI.TRADESCREEN.CROW_GAME.MOVE_SCORE .. tostring(self:GetMoveScore()))
end





function CrowGameScreen:Quit()
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

function CrowGameScreen:OnBecomeActive()
	CrowGameScreen._base.OnBecomeActive(self)
end


function CrowGameScreen:GetPowerupData()
	self.num_powerup = {}
	self.num_powerup_default = {}

	for _,data in pairs(POWERUPS) do
		self.num_powerup[data.powerup] = 0
		self.num_powerup_default[data.powerup] = 3
	end
end


function CrowGameScreen:OnControl(control, down)
    if CrowGameScreen._base.OnControl(self, control, down) then return true end
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


function CrowGameScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if self.resetbutton:IsEnabled() then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. " " .. STRINGS.UI.TRADESCREEN.RESET)
	end

	if self.startbutton:IsEnabled() then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.TRADESCREEN.START)
	end

	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.TRADESCREEN.CROW_GAME.HELP)

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SKINSSCREEN.BACK)

    return table.concat(t, "  ")
end

return CrowGameScreen
