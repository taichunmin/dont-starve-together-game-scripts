require "util"
require "strings"
require "constants"

local ImageButton = require "widgets/imagebutton"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"

local CreditsScreen = require "screens/creditsscreen"
local MovieDialog = require "screens/moviedialog"

local TEMPLATES = require "widgets/redux/templates"

local CinematicsPanel = Class(Widget, function(self, parent_screen)
    Widget._ctor(self, "CinematicsPanel")

	self.parent_screen = parent_screen

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0,0)

    local scale = 0.6
    local button_width = 432 * scale
    local button_height = 90 * scale

--    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(830, 500))
    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(400, 300))
    self.dialog:SetPosition(0, 5)

    self.title_root = self.root:AddChild(Widget("title_root"))
    self.title_root:SetPosition(0, 110)

    local title = self.title_root:AddChild(Text(HEADERFONT, 26))
    title:SetRegionSize(200, 70)
    title:SetString(STRINGS.UI.OPTIONS.CINEMATICS)
    title:SetColour(UICOLOURS.GOLD_SELECTED)

    local titleunderline = self.title_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    titleunderline:SetScale(0.4, 0.5)
    titleunderline:SetPosition(0, -20)

    self.buttons = {}

	local function OnMovieDone()
		TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
		TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 0)
		TheFrontEnd:Fade(FADE_IN, 1)
		self.parent_screen:Show()
	end

	table.insert(self.buttons, TEMPLATES.StandardButton(function()
			TheFrontEnd:GetSound():KillSound("FEMusic")
			if self.debug_menu then self.debug_menu:Disable() end
			TheFrontEnd:FadeToScreen( self.parent_screen, function() return MovieDialog("movies/intro.ogv", OnMovieDone) end, nil )
		end,
		STRINGS.UI.OPTIONS.INTRO_MOVIE, {button_width, button_height})
	)
	table.insert(self.buttons, TEMPLATES.StandardButton(function()
			TheFrontEnd:GetSound():KillSound("FEMusic")
			if self.debug_menu then self.debug_menu:Disable() end
			TheFrontEnd:FadeToScreen( self.parent_screen, function() return CreditsScreen() end, nil )
		end,
		STRINGS.UI.OPTIONS.CREDITS, {button_width, button_height})
	)

	if IsSteam() then
		table.insert(self.buttons, TEMPLATES.StandardButton(function() VisitURL("https://www.youtube.com/channel/UCzbYAkDCuQYdZ_fKz9MLrWA") end, STRINGS.UI.OPTIONS.VIDEO_CHANNEL, {button_width, button_height}))
	end

    self.grid = self.title_root:AddChild(Grid())
    self.grid:SetPosition(0, -75)

    self.grid:FillGrid(1, button_width, button_height, self.buttons)

    self.focus_forward = self.grid
end)

return CinematicsPanel
