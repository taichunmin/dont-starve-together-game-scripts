local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Grid = require "widgets/grid"

local TEMPLATES = require "widgets/redux/templates"
local OnlineStatus = require "widgets/onlinestatus"
local ServerCreationScreen = require "screens/redux/servercreationscreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local Customize = require "map/customize"
local Levels = require("map/levels")

local caveoptions = {"caves","nocaves"}

local CAVESTRING = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[string.upper(SERVER_LEVEL_LOCATIONS[2])]

local caveoptiondetails = {
	["caves"] =   { 
					desc = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_DESC_CAVE, {server=CAVESTRING} ),  -- STRINGS.LOCATIONTABNAME[string.upper(CONSTANTS.SERVER_LEVEL_LOCATIONS[2])]
					name= subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_NAME_CAVE, {server=CAVESTRING} ),
					image={
							atlas="images/serverplaystyles.xml", 
							icon="caves.tex", 
							name=subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_NAME_CAVE, {server=CAVESTRING} ),
						},
					caves = true,
				},
	["nocaves"] = { 
					desc = subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_DESC_NOCAVE,{server=CAVESTRING}),
					name= subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_NAME_NOCAVE,{server=CAVESTRING}),
					image={
							atlas="images/serverplaystyles.xml", 
							icon="nocaves.tex", 
							name= subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_NAME_NOCAVE,{server=CAVESTRING}),
						},
					caves = false,
				}
}

--formatstring(inst,sstr,target)

local dialog_size_x = 860
local dialog_size_y = 325 + 65

local bump = 35

local CaveSelectScreen = Class(Screen, function(self, prev_screen, slot_index, preset, parent_Screen)
    Screen._ctor(self, "CaveSelectScreen")

	self.parent_screen = parent_Screen -- prev_screen
	self.slot_index = slot_index
	self.preset = preset

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


    self.headertext = self.detail_panel_frame_parent:AddChild(Text(HEADERFONT, 30, subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_TITLE,{server=CAVESTRING}) ))
    self.headertext:SetPosition(0, 130 + bump)
    self.headertext:SetColour(UICOLOURS.GOLD_SELECTED)

	self.style_grid = self.detail_panel_frame_parent:AddChild(self:MakeStyleGrid())
	self.style_grid:SetScale(0.65)
	self.style_grid:SetPosition(0,0 +bump)

	if not TheInput:ControllerAttached() then
		self.cancelbutton = self.root:AddChild(TEMPLATES.BackButton(function() self:Close() end))
	end

    self.description = self.detail_panel_frame_parent:AddChild(Text(CHATFONT, 24))
    self.description:SetPosition(0, -120 +bump)
    self.description:SetColour(UICOLOURS.GOLD_SELECTED)


    self.remember = self.detail_panel_frame_parent:AddChild(TEMPLATES.LabelCheckbox(
                function(w)  
                	w.checked = not w.checked                                     
                    w:Refresh()
                end,
                false, --Profile:GetAutoCavesEnabled()
                STRINGS.UI.SERVERCREATIONSCREEN.REMEMBERCOICE) )--string.format(STRINGS.UI.SANDBOXMENU.AUTOADDLEVEL, tabname)))
    self.remember:SetPosition(-100,-180 +bump)



	if TheInput:ControllerAttached() then
    	self.style_grid:SetFocusChangeDir(MOVE_DOWN, self.remember)
    	self.remember:SetFocusChangeDir(MOVE_UP, self.style_grid)
    	self.remember:SetOnGainFocus(function()
    		self:UpdateStyleInfo("")
    	end)
	end
    
    self.default_focus = self.style_grid

	self.default_playstyle:Select()
end)

function CaveSelectScreen:MakeStyleButton(playstyle_id)
	local w = Widget("style_"..playstyle_id)

	local cave_def = caveoptiondetails[playstyle_id] or {}

	w.settings_desc = cave_def.desc

    local button = w:AddChild(ImageButton("images/serverplaystyles.xml", "frame.tex", "frame_hl.tex", "frame_hl.tex", "frame_hl.tex", "frame_hl.tex"))

    button:SetImageNormalColour(UICOLOURS.GOLD_SELECTED)
    button:SetImageFocusColour(UICOLOURS.GOLD_SELECTED)
    button:SetImageDisabledColour(UICOLOURS.GOLD_SELECTED)
    button:SetImageSelectedColour(UICOLOURS.GOLD_SELECTED)
	button.AllowOnControlWhenSelected = true

    button:SetText(cave_def.name)
    button:SetFont(CHATFONT)
	button:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
	button:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
	button:SetTextColour(UICOLOURS.GOLD_SELECTED)
    button.text:SetPosition(0, 130)
    button.text:SetSize(38)
    button.text:MoveToFront()

    button.bigicon = button:AddChild(Image(cave_def.image.atlas, cave_def.image.icon))
    button.bigicon:SetScale(0.61)
	button.bigicon:MoveToBack()

    button:SetOnClick(function()
		TheFrontEnd:FadeToScreen(self.parent_screen, function()
			local s = ServerCreationScreen(self.parent_screen, self.slot_index)
			s:OnNewGamePresetPicked(self.preset)
			s:SetSecondaryLevel(cave_def.caves)
			TheFrontEnd:PopScreen(self)
			if self.remember.checked then

				Profile:SetCavesStateRemembered()
				if cave_def.caves then				
            		Profile:SetAutoCavesEnabled(self.remember.checked)
            		Profile:Save()            		
            	end
        	end

			return s
		end)
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

function CaveSelectScreen:MakeStyleGrid()
	local root = Widget("grid_root")

	local grid = root:AddChild(Grid())
    grid:SetLooping(false, false)

	local widgets = {}
	local default_widget = nil

	for i, caveoption in ipairs(caveoptions) do
		local w = self:MakeStyleButton(caveoption)

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
			self.selected = nil
		end)

		table.insert(widgets, w)
	end

	local button_size = 228
	local button_space = -5

	grid:FillGrid(#widgets, button_size + button_space, 0, widgets)
	grid:SetPosition(button_size/2 - ((#widgets - 1) * button_space/2) - (#widgets/2 * button_size), 0)

    root.grid = grid
	root.focus_forward = widgets[1]
	root.default_focus = widgets[1]
	
	self.default_playstyle = widgets[1].button

	return root
end

function CaveSelectScreen:UpdateStyleInfo(w)
	self.description:SetMultilineTruncatedString(w.settings_desc, 3, 700, nil, true, true)
end

function CaveSelectScreen:OnBecomeActive()
    CaveSelectScreen._base.OnBecomeActive(self)

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end

    self:Show()
end

function CaveSelectScreen:OnBecomeInactive()
    CaveSelectScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function CaveSelectScreen:OnDestroy()
    self._base.OnDestroy(self)
end

function CaveSelectScreen:Close()
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

function CaveSelectScreen:OnControl(control, down)
    if CaveSelectScreen._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_CANCEL then
			self:Close()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		end
	end

end

function CaveSelectScreen:_DoFocusHookups()
   -- self.server_scroll_list:SetFocusChangeDir(MOVE_UP, self.savefilterbar)
end

function CaveSelectScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	return table.concat(t, "  ")
end

return CaveSelectScreen