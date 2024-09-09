local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Grid = require "widgets/grid"

local TEMPLATES = require "widgets/redux/templates"
local OnlineStatus = require "widgets/onlinestatus"
local ServerCreationScreen = require "screens/redux/servercreationscreen"
local CaveSelectScreen = require "screens/redux/caveselectscreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local Customize = require "map/customize"
local Levels = require("map/levels")

local dialog_size_x = 860
local dialog_size_y = 325

local PlaystyleSelectScreen = Class(Screen, function(self, prev_screen, slot_index)
    Screen._ctor(self, "PlaystyleSelectScreen")

	self.parent_screen = prev_screen
	self.slot_index = slot_index

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

	self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.SERVERCREATIONSCREEN.HOST_GAME))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        {x = -100, y = 255,},
        {x = 290, y = 255,},
        {x = 515, y = -255,},
    } ))

	self.onlinestatus = self.root:AddChild(OnlineStatus())

    self.detail_panel_frame_parent = self.root:AddChild(Widget("detail_frame"))
    self.detail_panel_frame_parent:SetPosition(0, 0)
    self.detail_panel_frame = self.detail_panel_frame_parent:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.detail_panel_frame:SetBackgroundTint(r,g,b,0.6)


    self.headertext = self.detail_panel_frame_parent:AddChild(Text(HEADERFONT, 30, STRINGS.UI.SERVERCREATIONSCREEN.PLAYSTYLE_TITLE))
    self.headertext:SetPosition(0, 130)
    self.headertext:SetColour(UICOLOURS.GOLD_SELECTED)

	self.style_grid = self.detail_panel_frame_parent:AddChild(self:MakeStyleGrid())
	self.style_grid:SetScale(0.65)
	self.style_grid:SetPosition(0, 0)

	if not TheInput:ControllerAttached() then
		self.cancelbutton = self.root:AddChild(TEMPLATES.BackButton(function() self:Close() end))
	end

    self.description = self.detail_panel_frame_parent:AddChild(Text(CHATFONT, 24))
    self.description:SetPosition(0, -115)
    self.description:SetColour(UICOLOURS.GOLD_SELECTED)

    self.default_focus = self.style_grid

	self.default_playstyle:Select()
end)

function PlaystyleSelectScreen:MakeStyleButton(playstyle_id)
	local w = Widget("style_"..playstyle_id)

	local playstyle_def = Levels.GetPlaystyleDef(playstyle_id) or {}

	w.settings_desc = playstyle_def.desc

    local button = w:AddChild(ImageButton("images/serverplaystyles.xml", "frame.tex", "frame_hl.tex", "frame_hl.tex", "frame_hl.tex", "frame_hl.tex"))

    button:SetImageNormalColour(UICOLOURS.GOLD_SELECTED)
    button:SetImageFocusColour(UICOLOURS.GOLD_SELECTED)
    button:SetImageDisabledColour(UICOLOURS.GOLD_SELECTED)
    button:SetImageSelectedColour(UICOLOURS.GOLD_SELECTED)
	button.AllowOnControlWhenSelected = true

    button:SetText(playstyle_def.name)
    button:SetFont(CHATFONT)
	button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
	button:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
	button:SetTextColour(UICOLOURS.GOLD_SELECTED)
    button.text:SetPosition(0, 130)
    button.text:SetSize(38)
    button.text:MoveToFront()

    button.bigicon = button:AddChild(Image(playstyle_def.image.atlas, playstyle_def.image.icon))
    button.bigicon:SetScale(0.61)
	button.bigicon:MoveToBack()

    button:SetOnClick(function()
    	if Profile:GetCavesStateRemembered() then
    		TheFrontEnd:FadeToScreen(self.parent_screen, function()
				local s = ServerCreationScreen(self.parent_screen, self.slot_index)
				s:OnNewGamePresetPicked(playstyle_def.default_preset)
				TheFrontEnd:PopScreen(self)
				return s
			end)
    	else    		
    		TheFrontEnd:PushScreen(CaveSelectScreen(self, self.slot_index, playstyle_def.default_preset, self.parent_screen ))    
    		TheFrontEnd:PopScreen(self)
			TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
    	end
    end)

	button:SetOnSelect(function()
		self:UpdateStyleInfo(w)
		w:SetScale(1.05)
	end)

	button:SetOnUnselect(function()
		w:SetScale(0.95)
	end)
	w:SetScale(0.95)

	w.button = button
	w.focus_forward = button
	return w
end

function PlaystyleSelectScreen:MakeStyleGrid()

	local root = Widget("grid_root")

	local grid = root:AddChild(Grid())
    grid:SetLooping(false, false)

	local widgets = {}
	local default_widget = nil

	for i, playstyle in ipairs(Levels.GetPlaystyles()) do
		local w = self:MakeStyleButton(playstyle)

		w.button:SetOnGainFocus(function()
			if self.selected ~= w.button then
				if self.selected == self.default_playstyle then
					self.default_playstyle:Unselect()
				end

				self.selected = w.button
				self.selected:Select()
			end
		end)

		w.button:SetOnLoseFocus(function()
			w.button:Unselect()
			if self.selected == w.button then
				self.selected = self.default_playstyle
				self.default_playstyle:Select()
			end
		end)

		table.insert(widgets, w)
	end

	local button_size = 228
	local button_space = -5

	grid:FillGrid(#widgets, button_size + button_space, 0, widgets)
	grid:SetPosition(button_size/2 - ((#widgets - 1) * button_space/2) - (#widgets/2 * button_size), 0)

    root.grid = grid
	root.focus_forward = widgets[3]
	root.default_focus = widgets[3]
	
	self.default_playstyle = widgets[3].button

	return root
end

function PlaystyleSelectScreen:UpdateStyleInfo(w)
	self.description:SetMultilineTruncatedString(w.settings_desc, 3, 700, nil, true, true)
end

function PlaystyleSelectScreen:OnBecomeActive()
    PlaystyleSelectScreen._base.OnBecomeActive(self)

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end

    self:Show()
end

function PlaystyleSelectScreen:OnBecomeInactive()
    PlaystyleSelectScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function PlaystyleSelectScreen:OnDestroy()
    self._base.OnDestroy(self)
end

function PlaystyleSelectScreen:Close()
	if TheFrontEnd:GetFadeLevel() < 1 then
		TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
	        TheFrontEnd:PopScreen()
	        TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
	    end)
	else
		TheFrontEnd:PopScreen()
	    TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
	end
end

function PlaystyleSelectScreen:OnControl(control, down)
    if PlaystyleSelectScreen._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_CANCEL then
			self:Close()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		end
	end
end

function PlaystyleSelectScreen:_DoFocusHookups()
   -- self.server_scroll_list:SetFocusChangeDir(MOVE_UP, self.savefilterbar)
end

function PlaystyleSelectScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	return table.concat(t, "  ")
end

return PlaystyleSelectScreen