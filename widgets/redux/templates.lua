local AccountItemFrame = require "widgets/redux/accountitemframe"
local Button = require "widgets/button"
local Grid = require "widgets/grid"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local NineSlice = require "widgets/nineslice"
local NumericSpinner = require "widgets/numericspinner"
local Spinner = require "widgets/spinner"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local TrueScrollList = require "widgets/truescrolllist"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local xputil = require "wxputils"

require("constants")
require("skinsutils")

local TEMPLATES = {}

TEMPLATES.old = require("widgets/templates")

----------------
----------------
--   SCREEN   --
----------------
----------------

function TEMPLATES.ScreenRoot(name)
    local root = Widget(name or "root")
    root:SetVAnchor(ANCHOR_MIDDLE)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    return root
end

----------------
----------------
-- BACKGROUND --
----------------
----------------

local function MakeStretchedFullscreenBackground(bg)
    bg:SetVRegPoint(ANCHOR_MIDDLE)
    bg:SetHRegPoint(ANCHOR_MIDDLE)
    bg:SetVAnchor(ANCHOR_MIDDLE)
    bg:SetHAnchor(ANCHOR_MIDDLE)
    bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    return bg
end

function TEMPLATES.LoaderBackground(item_key)
    -- This doesn't work like the other backgrounds with alpha and
    -- letterboxing. It's a full window size and stretched like the old
    -- loaders.
    local bg = MakeStretchedFullscreenBackground(Image(GetLoaderAtlasAndTex(item_key)))
    bg:SetTint(unpack(FRONTEND_PORTAL_COLOUR))
    return bg
end

local function ReduxBackground(variation)
    local bg = Widget("background")
    bg.bgplate = bg:AddChild(TEMPLATES._CreateBackgroundPlate(Image("images/bg_redux_".. variation ..".xml", variation ..".tex")))
    bg:SetCanFadeAlpha(false)
    return bg
end


-- All of these backgrounds may require letterboxing to ensure non 16:9 ratios don't reveal
-- what's behind. Mostly necessary in-game to hide the game world, but the
-- frontend sometimes has elements that extend off the edge of the screen.

function TEMPLATES.PlainBackground()
    -- This is the plainest one.
    return TEMPLATES.BrightMenuBackground()
end

function TEMPLATES.BoarriorBackground()
    return ReduxBackground("labg")
end

function TEMPLATES.BrightMenuBackground()
    return ReduxBackground("dark_right")
end

function TEMPLATES.LeftSideBarBackground()
	local bg = ReduxBackground("dark_right")
	
	local sidebar_root = bg:AddChild(Widget("sidebar_root"))
    sidebar_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    sidebar_root:SetVAnchor(ANCHOR_MIDDLE)
    sidebar_root:SetHAnchor(ANCHOR_MIDDLE)
	
	local sidebar = sidebar_root:AddChild(Image("images/bg_redux_dark_sidebar.xml", "dark_sidebar.tex"))
    sidebar:SetCanFadeAlpha(false)
    sidebar:SetVRegPoint(ANCHOR_MIDDLE)
    sidebar:SetHRegPoint(ANCHOR_RIGHT)
    sidebar:SetPosition(-300, 0)
    sidebar:SetScale(.68, 1)

    return bg
end

function TEMPLATES._CreateBackgroundPlate(image)
    local root = Widget("bg_plate_root")
    root:SetVAnchor(ANCHOR_MIDDLE)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    local plate = root:AddChild(image)
    plate:SetVRegPoint(ANCHOR_MIDDLE)
    plate:SetHRegPoint(ANCHOR_MIDDLE)

    local w = plate:GetSize()
    plate:SetScale(RESOLUTION_X / w)

	root.image = image
	
    return root
end

function TEMPLATES.BackgroundTint(a, rgb)
    return TEMPLATES.old.BackgroundTint(a, rgb)
end

function TEMPLATES.BoarriorAnim(args)
    local anim = UIAnim()
    anim:GetAnimState():SetBuild("main_menu1")
    anim:GetAnimState():SetBank("main_menu1")
    anim:SetScale(0.6)
    anim:SetPosition(-190, -300)
    anim.PlayOnLoop = function()
        anim:GetAnimState():PlayAnimation("idle", true)
    end
    anim:PlayOnLoop()
    return anim
end


----------------
----------------
--   MENUS    --
----------------
----------------

local rcol = RESOLUTION_X/2 -170
local lcol = -RESOLUTION_X/2 +200

local titleX = lcol+65
local titleY = 310
local menuX = lcol-5
local menuY = -130
local leftSideBarEdge = -290

-- A title for the current screen.
--
-- Drawn in the top left corner. Can have a subtitle that is drawn below it.
function TEMPLATES.ScreenTitle(title_text, subtitle_text)
    local title = Text(HEADERFONT, 28, title_text or "")
    title:SetColour(UICOLOURS.GOLD_SELECTED)
    title:SetRegionSize(400, 50)
    title:SetHAlign(ANCHOR_LEFT)

    local root = title
    if subtitle_text then
        root = Widget("title root")
        root:AddChild(title)

        -- subtitle accessed with self.title.small
        root.small = root:AddChild(Text(CHATFONT, 28, subtitle_text))
        root.small:SetColour(UICOLOURS.GREY)
        root.small:SetPosition(0, -35)
        root.small:SetRegionSize(400, 50)
        root.small:SetHAlign(ANCHOR_LEFT)
    end

    root:SetPosition(titleX, titleY)

    -- Don't call Text methods on the return value! Use self.title.big or
    -- self.title.small to ensure code works with subtitles.
    root.big = title

    return root
end

-- A title to be used with LeftSideBarBackground.
function TEMPLATES.ScreenTitle_BesideLeftSideBar(title_text, subtitle_text)
    local title = TEMPLATES.ScreenTitle(title_text, subtitle_text)
    title:SetPosition(leftSideBarEdge + 200, 310)
    return title
end

-- The standard menu.
--
-- Drawn on the left size and aligned to the bottom of the screen.
function TEMPLATES.StandardMenu(menuitems, offset, horizontal, style, wrap)
    local menu = Menu(menuitems, offset, horizontal, style, wrap)
    menu:SetPosition(menuX, menuY)
    return menu
end


-- A screen tooltip.
--
-- For explaining the purpose of the highlighted menu.
function TEMPLATES.ScreenTooltip()
    local tooltip = Text(NEWFONT, 25)
    tooltip:SetVAlign(ANCHOR_TOP)
    tooltip:SetHAlign(ANCHOR_LEFT)
    tooltip:SetRegionSize(200,100)
    tooltip:EnableWordWrap(true)
    local tooltipX = menuX -25
    local tooltipY = -(RESOLUTION_Y*.5)+157
    tooltip:SetPosition(tooltipX, tooltipY, 0)
    return tooltip
end


-- A standard menu button.
--
-- Assumes the button's parent is a Menu.
-- Put a bunch of these into a StandardMenu.
function TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget)
    local btn = Button()
    btn:SetFont(HEADERFONT)
    btn:SetDisabledFont(HEADERFONT)
    btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    btn:SetTextFocusColour(1, 1, 1, 1)
    btn:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
    btn:SetText(text, true)
    btn.text:SetRegionSize(250,40)
    btn.text:SetHAlign(ANCHOR_LEFT)
    btn.text_shadow:SetRegionSize(250,40)
    btn.text_shadow:SetHAlign(ANCHOR_LEFT)
    btn:SetTextSize(25)

    btn.image = btn:AddChild(Image("images/frontend_redux.xml", "menu_selection.tex"))
    btn.image:MoveToBack()
    btn.image:SetScale(.6)
    btn.image:SetPosition(-10,1)
    btn.image:SetClickable(false)
    btn.image:Hide()

    btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
    local w,h = btn.text:GetRegionSize()
    btn.bg:ScaleToSize(250, h+15)
    btn.bg:SetPosition(-10,1)

    btn.ongainfocus = function(is_enabled)
        btn.image:Show()
        tooltip_widget:SetString(tooltip_text)
    end

    btn.onlosefocus = function()
        btn.image:Hide()
        if not btn.parent.focus then
            tooltip_widget:SetString("")
        end
    end
    btn:SetOnClick(onclick)

    return btn
end

function TEMPLATES.WardrobeButton(text, onclick, tooltip_text, tooltip_widget)
    local btn = TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget)
        
    btn.image:SetTexture("images/frontend_redux.xml", "menu_wardrobe_selection.tex")
    
    btn:SetTextSize(22)
    btn.text:SetPosition(20,10)
    btn.text:SetRegionSize(205,24)
    
    btn.icon = btn:AddChild( AccountItemFrame() )
    btn.icon:SetStyle_Normal()
    btn.icon:SetScale(0.4)
    btn.icon:SetPosition(-114,2)
    
    btn.item_name = btn:AddChild( Text(NEWFONT, 20) )
    btn.item_name:SetHAlign(ANCHOR_LEFT)
    btn.item_name:SetRegionSize(205,24)
    btn.item_name:SetPosition(20,-10)
    
    btn.SetItem = function(self,item_id)
        self.icon:SetItem(item_id)
        self.item_name:SetString(item_id and GetSkinName(item_id) or "")
        self.item_name:SetColour(UICOLOURS.GREY)
        self.item_name:SetColour(GetColorForItem(item_id))
    end
    
    btn.onselect = function()
        btn.item_name:Show()
        btn.text:SetPosition(20,10)
    end
    
    btn.onunselect = function()
        btn.item_name:Hide()
        btn.text:SetPosition(20,0)
    end
    
    return btn
end

-- To be added as a child of the root. onclick should be whatever cancel/back
-- fn is appropriate for your screen.
function TEMPLATES.BackButton(onclick, txt, shadow_offset, scale)
    local btn = ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil, nil, nil, {1,1}, {0,0})
    btn.scale = scale or 1
    btn.image:SetScale(.7)

    btn:SetTextColour(UICOLOURS.GOLD)
    btn:SetTextFocusColour(PORTAL_TEXT_COLOUR)
    btn:SetFont(NEWFONT_OUTLINE)
    btn:SetDisabledFont(NEWFONT_OUTLINE)
    btn:SetTextDisabledColour(UICOLOURS.GOLD)

    -- Make a clickable area and scale to actual text size.
    btn.bg = btn.text:AddChild(Image("images/ui.xml", "blank.tex"))

	-- Override the SetText function so that the text, drop shadow, and mouse region (bg) can be positioned correctly
	local _oldsettext = btn.SetText
	btn.SetText = function(btn_inst, msg, dropShadow, dropShadowOffset)
		_oldsettext(btn_inst, msg, dropShadow, dropShadowOffset)

		local w,h = btn.text:GetRegionSize()
		btn.bg:ScaleToSize(w+50, h+15)
		
		local function ConfigureText(text_widget, x, offset)
			-- Make text region large and fixed position so it aligns against image.
			-- Offset to align region to image.
			text_widget:SetPosition(x + offset.x, offset.y)
			text_widget:SetHAlign(ANCHOR_LEFT)
		end
		-- Align text so left of region is against image.
		local text_x = w / 2 + 30
		ConfigureText(btn.text, text_x, {x=0,y=0})
		ConfigureText(btn.text_shadow, text_x, shadow_offset or {x=2,y=-1})
	end

    btn:SetText(txt or STRINGS.UI.SERVERLISTINGSCREEN.BACK, true)


    btn:SetOnGainFocus(function()
        btn:SetScale(btn.scale + .05)
    end)
    btn:SetOnLoseFocus(function()
        btn:SetScale(btn.scale)
    end)

    btn:SetOnClick(onclick)

    btn:SetScale(btn.scale)

    -- TODO(dbriscoe): Once new ui is rolled out everywhere, update BACK_BUTTON_X/Y.
    btn:SetPosition(-RESOLUTION_X*.4 - 60, -RESOLUTION_Y*.5 + BACK_BUTTON_Y - 10)
    return btn
end


-- A button for LeftSideBarBackground.
function TEMPLATES.BackButton_BesideLeftSidebar(onclick, txt, shadow_offset, scale)
    local btn = TEMPLATES.BackButton(onclick, txt, shadow_offset, scale or 0.8)
    -- BackButton is offset by 100 from plain text because of the image and we
    -- want to push a bit more left.
    btn:SetPosition(leftSideBarEdge + 15, -310)
    return btn
end

function TEMPLATES.StandardButton(onclick, txt, size)
    local prefix = "button_carny_long"
    if size and #size == 2 and size[1] / size[2] > 4 then
        -- Longer texture will look better at this aspect ratio.
        prefix = "button_carny_xlong"
    end
    local btn = ImageButton("images/global_redux.xml",
        prefix.."_normal.tex",
        prefix.."_hover.tex",
        prefix.."_disabled.tex",
        prefix.."_down.tex")
    btn:SetOnClick(onclick)
    btn:SetText(txt)
    btn:SetFont(CHATFONT)
    btn:SetDisabledFont(CHATFONT)
    if size then
        btn:ForceImageSize(unpack(size))
        btn:SetTextSize(math.ceil(size[2]*.45))
    end
    return btn
end


-- Standard-style button with a custom icon and a text label on the button.
-- Text label offset can be specified, as well as whether or not it always shows.
function TEMPLATES.IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
    local btn = TEMPLATES.StandardButton(onclick)
    btn:ForceImageSize(100,50)

    btn.icon = btn:AddChild(Image(iconAtlas, iconTexture, defaultTexture))
    btn.icon:SetPosition(0,2)
    btn.icon:SetScale(0.13)
    btn.icon:SetClickable(false)

    btn.highlight = btn:AddChild(Image("images/frontend.xml", "button_square_highlight.tex"))
    btn.highlight:SetScale(.7)
    btn.highlight:SetClickable(false)
    btn.highlight:Hide()

    if not textinfo then
        textinfo = {}
    end

    if sideLabel then
        btn.label = btn:AddChild(Text(textinfo.font or NEWFONT, textinfo.size or 25, labelText, textinfo.colour or {0,0,0,1}))
        btn.label:SetRegionSize(150,70)
        btn.label:EnableWordWrap(true)
        btn.label:SetHAlign(ANCHOR_RIGHT)
        btn.label:SetPosition(-115, 7)
    elseif alwaysShowLabel then
        btn:SetTextSize(25)
        btn:SetText(labelText, true)
        btn.text:SetPosition(-3, -34)
        btn.text_shadow:SetPosition(-5, -36)
        btn:SetFont(textinfo.font or NEWFONT)
        btn:SetTextColour(textinfo.colour or { unpack(GOLD) })
        btn:SetTextFocusColour(textinfo.focus_colour or { unpack(GOLD) })
    else
        btn:SetHoverText(labelText, { font = textinfo.font or NEWFONT_OUTLINE, size = textinfo.size or 22, offset_x = textinfo.offset_x or -4, offset_y = textinfo.offset_y or 45, colour = textinfo.colour or {1,1,1,1}, bg = textinfo.bg })
    end

    btn:SetOnClick(onclick)

    btn:SetOnGainFocus(function()
        if btn:IsEnabled() and not btn:IsSelected() and TheFrontEnd:GetFadeLevel() <= 0 then
            btn.highlight:Show()
        end
    end)
    btn:SetOnLoseFocus(function()
        btn.highlight:Hide()
    end)

    return btn
end

function TEMPLATES.DoodadCounter(number_of_doodads)
    local doodad = Widget("DoodadCounter")
    doodad.image = doodad:AddChild(UIAnim())
    doodad.image:GetAnimState():SetBank("spool")
    doodad.image:GetAnimState():SetBuild("spool")
    doodad.image:GetAnimState():PlayAnimation("idle", true)

	doodad.doodad_count = doodad:AddChild(Text(CHATFONT_OUTLINE, 35, nil, UICOLOURS.WHITE))
    doodad.doodad_count:SetPosition(-10, -60)
    doodad.doodad_count:SetRegionSize(120, 43)
    doodad.doodad_count:SetHAlign(ANCHOR_LEFT)

    doodad._CountFn = function(self)
        if self.num_display_doodads ~= self.num_doodads then
            local step = (self.num_doodads - self.num_display_doodads)/24
            
            if self.num_doodads > self.num_display_doodads then
                step = math.ceil(step)
            else
                step = math.floor(step)
            end

            self.num_display_doodads = self.num_display_doodads + step

            self.inst:DoTaskInTime(FRAMES, function() 
                self:_CountFn()
            end)
        end

        self.doodad_count:SetString("x"..self.num_display_doodads)
    end

    doodad.SetCount = function(self, new_count, animateDoodad)
        local should_skip = self.num_doodads == nil or not animateDoodad
        self.num_display_doodads = self.num_doodads
        self.num_doodads = new_count
        if not should_skip then
            doodad.image:GetAnimState():PlayAnimation("use")
            doodad.image:GetAnimState():PushAnimation("idle", true)
            self:_CountFn()
        else
            self.num_display_doodads = new_count
            self.num_doodads = new_count
            self.doodad_count:SetString("x"..new_count)
        end
    end

    doodad:SetCount(number_of_doodads)

    return doodad
end

-- Unlabelled text entry box
--
-- height and following arguments are optional.
function TEMPLATES.StandardSingleLineTextEntry(fieldtext, width_field, height, font, font_size)
    height = height or 40
    local textbox_font_ratio = 0.8
    local wdg = Widget("singleline textentry")
    wdg.textbox_bg = wdg:AddChild( Image("images/global_redux.xml", "textbox3_gold_normal.tex") )
    wdg.textbox_bg:ScaleToSize(width_field, height)
    wdg.textbox = wdg:AddChild(TextEdit( font or CHATFONT, (font_size or 25)*textbox_font_ratio, fieldtext, UICOLOURS.BLACK ) )
    wdg.textbox:SetForceEdit(true)
    wdg.textbox:SetRegionSize(width_field-30, height) -- this needs to be slightly narrower than the BG because we don't have margins
    wdg.textbox:SetHAlign(ANCHOR_LEFT)
    wdg.textbox:SetFocusedImage( wdg.textbox_bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )

    wdg.OnGainFocus = function(self)
        Widget.OnGainFocus(self)
        self.textbox:OnGainFocus()
    end
    wdg.OnLoseFocus = function(self)
        Widget.OnLoseFocus(self)
        self.textbox:OnLoseFocus()
    end
    wdg.GetHelpText = function(self)
        local controller_id = TheInput:GetControllerID()
        local t = {}
        if not self.textbox.editing and not self.textbox.focus then
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. STRINGS.UI.HELP.CHANGE_TEXT)   
        end
        return table.concat(t, "  ")
    end
    return wdg
end

-- Text box with a label beside it
--
-- font and following arguments are optional.
function TEMPLATES.LabelTextbox(labeltext, fieldtext, width_label, width_field, height, spacing, font, font_size, horiz_offset)
    local offset = horiz_offset or 0
    local total_width = width_label + width_field + spacing
    local wdg = TEMPLATES.StandardSingleLineTextEntry(fieldtext, width_field, height, font, font_size)
    wdg.label = wdg:AddChild(Text(font or CHATFONT, font_size or 25))
    wdg.label:SetString(labeltext)
    wdg.label:SetHAlign(ANCHOR_RIGHT)
    wdg.label:SetRegionSize(width_label,height)
    wdg.label:SetPosition((-total_width/2)+(width_label/2)+offset,0)
    wdg.label:SetColour(UICOLOURS.GOLD)
    -- Reposition relative to label
    wdg.textbox_bg:SetPosition((total_width/2)-(width_field/2)+offset, 0)
    wdg.textbox:SetPosition((total_width/2)-(width_field/2)+offset, 0)
    return wdg
end

-- Spinner with a label beside it
function TEMPLATES.LabelSpinner(labeltext, spinnerdata, width_label, width_spinner, height, spacing, font, font_size, horiz_offset)
    width_label = width_label or 220
    width_spinner = width_spinner or 150
    height = height or 40
    spacing = spacing or -50
    font = font or CHATFONT
    font_size = font_size or 25

    local offset = horiz_offset or 0
    local total_width = width_label + width_spinner + spacing
    local wdg = Widget("labelspinner")
    wdg.label = wdg:AddChild( Text(font, font_size, labeltext) )
    wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
    wdg.label:SetRegionSize( width_label, height )
    wdg.label:SetHAlign( ANCHOR_RIGHT )
    wdg.label:SetColour(UICOLOURS.GOLD)
    wdg.spinner = wdg:AddChild(TEMPLATES.StandardSpinner(spinnerdata, width_spinner, height, font, font_size))
    wdg.spinner:SetPosition((total_width/2)-(width_spinner/2) + offset, 0)

    wdg.focus_forward = wdg.spinner

    return wdg
end

-- Spinner of numbers with a label beside it
function TEMPLATES.LabelNumericSpinner(labeltext, min, max, width_label, width_spinner, height, spacing, font, font_size, horiz_offset)
    width_label = width_label or 220
    width_spinner = width_spinner or 150
    height = height or 40
    spacing = spacing or -50
    font = font or CHATFONT
    font_size = font_size or 25

    local offset = horiz_offset or 0
    local total_width = width_label + width_spinner + spacing
    local wdg = Widget("labelspinner")
    wdg.label = wdg:AddChild( Text(font, font_size, labeltext) )
    wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
    wdg.label:SetRegionSize( width_label, height )
    wdg.label:SetHAlign( ANCHOR_RIGHT )
    wdg.label:SetColour(UICOLOURS.GOLD)
    local atlas = "images/global_redux.xml"
    local lean = true
    wdg.spinner = wdg:AddChild(NumericSpinner(min, max, width_spinner, height, {font = font, size = font_size}, atlas, nil, nil, lean))
    wdg.spinner:SetPosition((total_width/2)-(width_spinner/2) + offset, 0)
    wdg.spinner:SetTextColour(UICOLOURS.GOLD)

    wdg.focus_forward = wdg.spinner

    return wdg
end

-- Text button with a label beside it
function TEMPLATES.LabelButton(labeltext, buttontext, width_label, width_button, height, spacing, font, font_size, horiz_offset)
    local wdg = TEMPLATES.old.LabelButton(labeltext, buttontext, width_label, width_button, height, spacing, font, font_size, horiz_offset)
    wdg.label:SetColour(UICOLOURS.GOLD)
    wdg.button.text:SetColour(UICOLOURS.GOLD)
    return wdg
end


-- Spinner
function TEMPLATES.StandardSpinner(spinnerdata, width_spinner, height, font, font_size)
    local atlas = "images/global_redux.xml"
    local lean = true
    local wdg = Spinner(spinnerdata, width_spinner, height, {font = font or CHATFONT, size = font_size or 25}, nil, atlas, nil, lean)
    wdg:SetTextColour(UICOLOURS.GOLD)
    return wdg
end

function TEMPLATES.CharacterSpinner(onchanged_fn, puppet, user_profile)
    local hero_data = {}
    for i,hero in ipairs(GetActiveCharacterList()) do
        table.insert(hero_data, {
                text = STRINGS.CHARACTER_NAMES[hero] or "",
                colour = nil,
                image = nil,
                data = hero, -- This data is what we'll receive in our callbacks.
            })
    end

    local heroselector = TEMPLATES.StandardSpinner(hero_data, 300)
    heroselector:SetOnChangedFn(function(selected_name, old)
        if puppet and user_profile then
            local base_skin = user_profile:GetBaseForCharacter(selected_name)
            local clothing = user_profile:GetSkinsForCharacter(selected_name, base_skin)
            local skip_change_emote = true
            puppet:SetSkins(selected_name, base_skin, clothing, skip_change_emote)
            user_profile:SetLastSelectedCharacter(selected_name)
        end
        onchanged_fn(selected_name, old)
    end)

    heroselector.LoadLastSelectedFromProfile = function()
        local old = heroselector:GetSelectedIndex()
        local hero = user_profile:GetLastSelectedCharacter()
        if old ~= hero then
            heroselector:SetSelected(hero)
            -- Must manually call changed after modifying.
            heroselector:Changed(old)
        end
    end

    -- Run this code even when we don't have a last selected character to
    -- ensure skins are properly loaded.
    heroselector:LoadLastSelectedFromProfile()

    return heroselector
end

function TEMPLATES.RankBadge()
    local rank = Widget("rank badge")

    rank.bg = rank:AddChild(Image())
    rank.bg:SetScale(0.8)

    rank.flair = rank:AddChild(Image(GetProfileFlairAtlasAndTex()))
    rank.flair:SetScale(.55)
    rank.flair:SetPosition(0, 31)
    rank.num = rank:AddChild(Text(CHATFONT_OUTLINE, 30))
    rank.num:SetPosition(2, -8) -- text drawing is centred on right edge of glyph, but we need to be centred

    rank.SetFestivalBackground = function(self, festival_key)
        festival_key = festival_key or "none"
        rank.bg:SetTexture("images/profileflair.xml", "playericon_bg_".. festival_key ..".tex", "playericon_bg_none.tex")
    end
    -- Assume current event.
    rank:SetFestivalBackground(IsAnyFestivalEventActive() and WORLD_FESTIVAL_EVENT or nil)

    rank.SetRank = function(self, profileflair, rank_value)
        rank.flair:SetTexture(GetProfileFlairAtlasAndTex(profileflair))
        local is_rank_valid = rank_value and rank_value >= 0
        if is_rank_valid then
            rank.num:SetString(tostring(rank_value + 1)) -- because we want to show 1 based levels, not -
            rank.num:SetColour(UICOLOURS.WHITE)
            -- May have updated with valid rank after retrieving from server.
            rank.num:Show()
        else
            -- For invalid ranks, just don't show the number.
            -- Outside of events, we still want to show the profileflair.
            rank.num:Hide()
        end
    end

    return rank
end

-- A festival-themed badge with a number.
-- We don't expect to display this for "none".
function TEMPLATES.FestivalNumberBadge(festival_key)
    festival_key = festival_key or WORLD_FESTIVAL_EVENT
    local badge = Image("images/profileflair.xml", "playerlevel_bg_".. festival_key ..".tex")
    badge.num = badge:AddChild(Text(CHATFONT_OUTLINE, 40))
	badge.num:SetColour(UICOLOURS.WHITE)
	badge.num:SetPosition(2, 10)
    badge.SetRank = function(self, rank_value)
        badge.num:SetString(tostring(rank_value + 1)) -- because we want to show 1-based levels
    end
    return badge
end

function TEMPLATES.UserProgress(onclick)
    local progress = Widget("UserProgress")

    progress.name = progress:AddChild(Text(CHATFONT, 26, TheNet:GetLocalUserName()))
    progress.name:SetHAlign(ANCHOR_RIGHT)
    progress.name:SetRegionSize(400, 34)
    progress.name:SetPosition(-103,-20)

    progress.bar = progress:AddChild(UIAnim())
    progress.bar:GetAnimState():SetBank("player_progressbar_small")
    progress.bar:GetAnimState():SetBuild("player_progressbar_small")
    progress.bar:GetAnimState():PlayAnimation("fill_progress", true)
    progress.bar:GetAnimState():SetPercent("fill_progress", 0)
    progress.bar:SetPosition(30, -45)
    --progress.bar:SetScale(0.8)
	
    progress.rank = progress:AddChild(TEMPLATES.RankBadge())
    progress.rank:SetPosition(135,-45)

    -- Put clear button in front.
    progress.btn = progress:AddChild(ImageButton("images/ui.xml", "blank.tex"))
    progress.btn.scale_on_focus = false
    progress.btn.move_on_click = false
    progress.btn:ForceImageSize(200,100)
    progress.btn:SetPosition(60,-30)
    progress.btn:SetOnClick(onclick)

    progress.UpdateProgress = function(self)
        self.rank:SetRank(GetMostRecentlySelectedItem(Profile, "profileflair"), TheInventory:GetWXPLevel())
        self.bar:GetAnimState():SetPercent("fill_progress", xputil.GetLevelPercentage())
    end

    -- Progress can change within the frontend (buying items or opening mystery
    -- boxes), so screens should call this in their OnBecomeActive.
    progress:UpdateProgress()

    -- Standard position under root.
    progress:SetPosition(430,310)

    return progress
end

function TEMPLATES.LargeScissorProgressBar(name)
	local bar = Widget(name or "LargeScissorProgressBar")

    local frame = bar:AddChild(Image("images/global_redux.xml", "progressbar_wxplarge_frame.tex"))
    frame:SetPosition(-2, 0)
   
    local fill = bar:AddChild(Image("images/global_redux.xml", "progressbar_wxplarge_fill.tex"))
	local width, hieght = fill:GetSize()
    fill:SetScissor(-width*.5,-hieght*.5, math.max(0, width), math.max(0, hieght))
	bar.SetPercent = function(self, percent)
	    fill:SetScissor(-width*.5,-hieght*.5, math.max(0, width * percent), math.max(0, hieght))
	end

	return bar	
end

function TEMPLATES.WxpBar()
    local wxpbar = Widget("Experience")

    wxpbar.rank = wxpbar:AddChild(TEMPLATES.RankBadge())
    wxpbar.rank:SetPosition(-344, -35)
    wxpbar.rank:SetScale(1)
    wxpbar.rank:Show()

    wxpbar.nextrank = wxpbar:AddChild(TEMPLATES.FestivalNumberBadge())
    wxpbar.nextrank:SetPosition(345, -15)
    wxpbar.nextrank:SetScale(1)
    wxpbar.nextrank.num:SetSize(30)
    
    local bar = wxpbar:AddChild(TEMPLATES.LargeScissorProgressBar())
    bar:SetPosition(0, 0)
    
    local font_size = 25

	local xp_cur_title = wxpbar:AddChild(Text(HEADERFONT, 16, STRINGS.UI.WXPLOBBYPANEL.WXP_CURRENT_XP, UICOLOURS.HIGHLIGHT_GOLD))
	xp_cur_title:SetPosition(-190, -33)
	xp_cur_title:SetHAlign(ANCHOR_LEFT)
	xp_cur_title:SetRegionSize(200, font_size + 5)

	local xp_next_title = wxpbar:AddChild(Text(HEADERFONT, 16, STRINGS.UI.WXPLOBBYPANEL.WXP_NEXT_LEVEL_XP, UICOLOURS.HIGHLIGHT_GOLD))
	xp_next_title:SetPosition(195, -33)
	xp_next_title:SetHAlign(ANCHOR_RIGHT)
	xp_next_title:SetRegionSize(200, font_size + 5)


	wxpbar.nextlevelxp_text = wxpbar:AddChild(Text(HEADERFONT, font_size, "", UICOLOURS.GOLD_SELECTED))
	wxpbar.nextlevelxp_text:SetPosition(195, -55)
	wxpbar.nextlevelxp_text:SetHAlign(ANCHOR_RIGHT)
	wxpbar.nextlevelxp_text:SetRegionSize(200, font_size + 5)


	local xp_earn = wxpbar:AddChild(Text(HEADERFONT, font_size, nil, UICOLOURS.GOLD_SELECTED))
	xp_earn:SetPosition(-190, -55)
	xp_earn:SetRegionSize(200, font_size + 5)
	xp_earn:SetHAlign(ANCHOR_LEFT)

    wxpbar.UpdateExperience = function(w_self, wxp, max_xwp)
        bar:SetPercent(math.clamp(wxp/math.max(1, max_xwp), 0, 1))
        xp_earn:SetString(tostring(math.floor(wxp)))
    end
    wxpbar.UpdateExperienceForLocalUser = function(w_self,profileflair)
        bar:SetPercent(xputil.GetLevelPercentage())
        xp_earn:SetString(xputil.BuildProgressString())

        local level = TheItems:GetLevelForWXP(TheInventory:GetWXP())
        local level_start_xp = TheItems:GetWXPForLevel(level)
        local next_level_xp = TheItems:GetWXPForLevel(level + 1)
        w_self:SetRank(level, next_level_xp - level_start_xp, profileflair)
    end

    wxpbar.SetRank = function(w_self, rank, next_level_xp, profileflair)
        w_self.rank:SetRank(profileflair, rank)
        w_self.nextrank:SetRank(rank + 1)
        w_self.nextlevelxp_text:SetString(next_level_xp) 
    end
    
    return wxpbar
end

function TEMPLATES.ItemImageText(item_type, item_key, max_width)
    local iconScale = 1
    local font = UIFONT
    local textsize = 30
    local label = item_key and GetSkinName(item_key) or ""
    local colour = UICOLOURS.WHITE
    local textwidth = max_width or 300
    local image_offset = 50
    local w = TEMPLATES.old.ItemImageText(item_type, item_key, iconScale, font, textsize, label, colour, textwidth, image_offset)
    w.text:SetRegionSize(textwidth, 70)
    w.text:EnableWordWrap(true)
    w.SetItem = function(self, item_type_, item_key_, item_id, timestamp)
        w.icon:SetItem(item_type_, item_key_, item_id, timestamp)
        w.text:SetString(item_key_ and GetSkinName(item_key_) or "")
    end
    return w
end

function TEMPLATES.ItemImageVerticalText(item_type, item_key, max_width)
    local w = TEMPLATES.ItemImageText(item_type, item_key, max_width)
    w.text:SetHAlign(ANCHOR_MIDDLE)
    w.text:SetPosition(0,-80)
    return w
end

-------------------
-------------------
-- PANELS/FRAMES --
-------------------
-------------------

-- Ornate black dialog with gold border (nine-slice)
-- title (optional) is anchored to top.
-- buttons (optional) are anchored to bottom.
function TEMPLATES.CurlyWindow(sizeX, sizeY, title_text, bottom_buttons, button_spacing, body_text)
    local w = NineSlice("images/dialogcurly_9slice.xml")
    local top = w:AddCrown("crown-top-fg.tex", ANCHOR_MIDDLE, ANCHOR_TOP, 0, 68)
    local top_bg = w:AddCrown("crown-top.tex", ANCHOR_MIDDLE, ANCHOR_TOP, 0, 44)
    top_bg:MoveToBack()

    -- Background overlaps behind and foreground overlaps in front.
    local bottom = w:AddCrown("crown-bottom-fg.tex", ANCHOR_MIDDLE, ANCHOR_BOTTOM, 0, -14)
    bottom:MoveToFront()

    -- Ensure we're within the bounds of looking good and fitting on screen.
    sizeX = math.clamp(sizeX or 200, 190, 1000)
    sizeY = math.clamp(sizeY or 200, 90, 500)
    w:SetSize(sizeX, sizeY)
    w:SetScale(0.7, 0.7)

    if title_text then
        w.title = top:AddChild(Text(HEADERFONT, 40, title_text, UICOLOURS.GOLD_SELECTED))
        w.title:SetPosition(0, -50)
        w.title:SetRegionSize(600, 50)
        w.title:SetHAlign(ANCHOR_MIDDLE)
        if JapaneseOnPS4() then
            w.title:SetSize(40)
        end
    end

    if bottom_buttons then
        -- If plain text widgets are passed in, then Menu will use this style.
        -- Otherwise, the style is ignored. Use appropriate style for the
        -- amount of space for buttons. Different styles require different
        -- spacing.
        local style = "carny_long"
        if button_spacing == nil then
            -- 1,2,3,4 buttons can be big at 210,420,630,840 widths.
            local space_per_button = sizeX / #bottom_buttons
            local has_space_for_big_buttons = space_per_button > 209
            if has_space_for_big_buttons then
                style = "carny_xlong"
                button_spacing = 320
            else
                button_spacing = 230
            end
        end
        local button_height = 50
        local button_area_width = button_spacing / 2 * #bottom_buttons
        local is_tight_bottom_fit = button_area_width > sizeX * 2/3
        if is_tight_bottom_fit then
            button_height = 60
        end

        -- Does text need to be smaller than 30 for JapaneseOnPS4()?
        w.actions = bottom:AddChild(Menu(bottom_buttons, button_spacing, true, style, nil, 30))
        w.actions:SetPosition(-(button_spacing*(#bottom_buttons-1))/2, button_height) 

        w.focus_forward = w.actions
    end

    if body_text then
        w.body = w:AddChild(Text(CHATFONT, 28, body_text, UICOLOURS.WHITE))
        w.body:EnableWordWrap(true)
        w.body:SetPosition(0, 20)
        local height_reduction = 0
        if bottom_buttons then
            height_reduction = 30
        end
        w.body:SetRegionSize(sizeX, sizeY - height_reduction)
        w.body:SetVAlign(ANCHOR_MIDDLE)
    end

    return w
end

-- Grey-bounded dialog with grey border (nine-slice)
-- title (optional) is anchored to top.
-- buttons (optional) are anchored to bottom.
-- Almost exact copy of CurlyWindow.
function TEMPLATES.RectangleWindow(sizeX, sizeY, title_text, bottom_buttons, button_spacing, body_text)
    local w = NineSlice("images/dialogrect_9slice.xml")
    w.top = w:AddCrown("crown_top_fg.tex", ANCHOR_MIDDLE, ANCHOR_TOP, 0, 4)

    -- Background overlaps behind and foreground overlaps in front.
    w.bottom = w:AddCrown("crown_bottom_fg.tex", ANCHOR_MIDDLE, ANCHOR_BOTTOM, 0, -4)
    w.bottom:MoveToFront()

    -- Ensure we're within the bounds of looking good and fitting on screen.
    sizeX = math.clamp(sizeX or 200, 90, 1000)
    sizeY = math.clamp(sizeY or 200, 50, 500)
    w:SetSize(sizeX, sizeY)
    w:SetScale(0.7, 0.7)

    if title_text then
        w.title = w.top:AddChild(Text(HEADERFONT, 40, title_text, UICOLOURS.GOLD_SELECTED))
        w.title:SetPosition(0, -50)
        w.title:SetRegionSize(600, 50)
        w.title:SetHAlign(ANCHOR_MIDDLE)
        if JapaneseOnPS4() then
            w.title:SetSize(40)
        end
    end

    if bottom_buttons then
        -- If plain text widgets are passed in, then Menu will use this style.
        -- Otherwise, the style is ignored. Use appropriate style for the
        -- amount of space for buttons. Different styles require different
        -- spacing.
        local style = "carny_long"
        if button_spacing == nil then
            -- 1,2,3,4 buttons can be big at 210,420,630,840 widths.
            local space_per_button = sizeX / #bottom_buttons
            local has_space_for_big_buttons = space_per_button > 209
            if has_space_for_big_buttons then
                style = "carny_xlong"
                button_spacing = 320
            else
                button_spacing = 230
            end
        end
        local button_height = 50
        local button_area_width = button_spacing / 2 * #bottom_buttons
        local is_tight_bottom_fit = button_area_width > sizeX * 2/3
        if is_tight_bottom_fit then
            button_height = 60
        end

        -- Does text need to be smaller than 30 for JapaneseOnPS4()?
        w.actions = w.bottom:AddChild(Menu(bottom_buttons, button_spacing, true, style, nil, 30))
        w.actions:SetPosition(-(button_spacing*(#bottom_buttons-1))/2, button_height) 

        w.focus_forward = w.actions
    end

    if body_text then
        w.body = w:AddChild(Text(CHATFONT, 28, body_text, UICOLOURS.WHITE))
        w.body:EnableWordWrap(true)
        w.body:SetPosition(0, -20)
        local height_reduction = 0
        if bottom_buttons then
            height_reduction = 30
        end
        w.body:SetRegionSize(sizeX, sizeY - height_reduction)
        w.body:SetVAlign(ANCHOR_MIDDLE)
    end

    w.SetBackgroundTint = function(self, r,g,b,a)
        for i=4,5 do
            self.elements[i]:SetTint(r,g,b,a)
        end
        self.mid_center:SetTint(r,g,b,a)
    end

    return w
end

function TEMPLATES.ScrollingGrid(items, opts)
    local peek_height = opts.widget_height * 0.25 -- how much of row to see at the bottom.
    if opts.peek_percent then
        -- Caller can force a peek height if they will add items to the list or
        -- have hidden empty widgets.
        peek_height = opts.widget_height * opts.peek_percent
    end
    local function ScrollWidgetsCtor(context, parent, scroll_list)
        local NUM_ROWS = opts.num_visible_rows + 2

        local widgets = {}
        for y = 1,NUM_ROWS do
            for x = 1,opts.num_columns do
                local index = ((y-1) * opts.num_columns) + x
                table.insert(widgets, parent:AddChild(opts.item_ctor_fn(context, index)))
            end
        end

        parent.grid = parent:AddChild(Grid())
        parent.grid:FillGrid(opts.num_columns, opts.widget_width, opts.widget_height, widgets)
        -- Centre grid position so scroll widget is more easily positioned and
        -- scissor automatically calculated.
        parent.grid:SetPosition(-opts.widget_width * (opts.num_columns-1)/2, opts.widget_height * (opts.num_visible_rows-1)/2 + peek_height/2)
        -- Give grid focus so it can pass on to contained widgets. It sets up
        -- focus movement directions.
        parent.focus_forward = parent.grid

        -- end_offset helps ensure last item can scroll into view. It's a
        -- percent of a row height. 0.75 seems to prevent the next (empty) row
        -- from being visible.
        local end_offset = 0.75
        return widgets, opts.num_columns, opts.widget_height, opts.num_visible_rows, end_offset
    end

    local scissor_pad = opts.scissor_pad or 0
    local scissor_width  = opts.scissor_width or opts.widget_width  * opts.num_columns      + scissor_pad
    local scissor_height = opts.scissor_height or opts.widget_height * opts.num_visible_rows + scissor_pad + peek_height
    local scissor_x = -scissor_width/2
    local scissor_y = -scissor_height/2
    local scroller = TrueScrollList(
        opts.scroll_context,
        ScrollWidgetsCtor,
        opts.apply_fn,
        scissor_x,
        scissor_y,
        scissor_width,
        scissor_height,
        opts.scrollbar_offset,
        opts.scrollbar_height_offset
        )
    scroller:SetItemsData(items)
    scroller.GetScrollRegionSize = function(self)
        return scissor_width, scissor_height
    end
    return scroller
end

-----------------
-----------------
--   LAYOUT    --
-----------------
-----------------

-- A column for positioning objects on the left side of the screen.
--
-- Honestly, not good for much.
function TEMPLATES.LeftColumn()
    local col = Widget("left column")
	col:SetPosition(lcol, 0)
    return col
end

-- A column for positioning objects on the right side of the screen.
--
-- Good for message of the day or other additional informational items.
function TEMPLATES.RightColumn()
    local col = Widget("right column")
	col:SetPosition(rcol, 0)
    return col
end


--Just has the letter boxing for now.
function TEMPLATES.ReduxForeground()
    local fg = Widget("foreground")

    fg.letterbox = fg:AddChild(TEMPLATES.old.ForegroundLetterbox())
    fg:SetCanFadeAlpha(false)

    return fg
end




return TEMPLATES
