local AccountItemFrame = require "widgets/redux/accountitemframe"
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
local Button = require "widgets/button"
local Widget = require "widgets/widget"

require("constants")
--require("skinsutils")
require("stringutil")

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

function TEMPLATES.QuagmireAnim()
    local anims = { "quagmire_menu_bg", "quagmire_menu_mid", "quagmire_menu"}
    local root = Widget("root")
    for _,anim in ipairs(anims) do
        local a = root:AddChild(UIAnim())
        a:GetAnimState():SetBuild(anim)
        a:GetAnimState():SetBank(anim)
        a:SetScale(0.67)
        a:SetPosition(0, 0)
        if anim == "quagmire_menu_bg" then
            local darken = 0.3
            a:GetAnimState():SetMultColour( darken, darken, darken, 1)
        end
        a:GetAnimState():PlayAnimation("idle", true)
    end
    return root
end

function TEMPLATES.BoarriorAnim()
    local anim = UIAnim()
    anim:GetAnimState():SetBuild("main_menu1")
    anim:GetAnimState():SetBank("main_menu1")
    anim:SetScale(0.6)
    anim:SetPosition(-190, -300)
    anim:GetAnimState():PlayAnimation("idle", true)
    return anim
end

function TEMPLATES.ClayWargBackground()
    local anim_bg = UIAnim()
    anim_bg:GetAnimState():SetBuild("dst_menu_yotv")
    anim_bg:GetAnimState():SetBank("dst_menu")
    anim_bg:SetScale(0.7)
    anim_bg:SetPosition(-20, 0)
    anim_bg:GetAnimState():PlayAnimation("ground")
    anim_bg.fadet = 0
    anim_bg.OnUpdate = function(self, dt)
        self.fadet = self.fadet + dt
        if self.fadet > 96 * FRAMES then
            self.fadet = self.fadet - 96 * FRAMES
        end
        local a = (math.cos(self.fadet * PI / (48 * FRAMES) - PI * .3) + 3) / 4
        self:GetAnimState():SetMultColour(a, a, a, 1)
    end
    anim_bg:StartUpdating()
    return anim_bg
end

function TEMPLATES.ClayWargAnim()
    local anim = UIAnim()
    anim:GetAnimState():SetBuild("dst_menu_yotv")
    anim:GetAnimState():SetBank("dst_menu")
    anim:SetScale(0.7)
    anim:SetPosition(-20, 0)
    anim:GetAnimState():PlayAnimation("loop", true)
    return anim
end

----------------
----------------
--  VERSION   --
----------------
----------------
function TEMPLATES.GetBuildString()
	local version_str = BRANCH == "dev" and "Internal"
						or BRANCH == "staging" and "Preview"
						or STRINGS.UI.MAINSCREEN.DST_UPDATENAME

	return version_str.." v"..APP_VERSION.." ("..(APP_ARCHITECTURE == "x32" and "32-bit" or APP_ARCHITECTURE == "x64" and "64-bit" or "??-bit")..")"
end

function TEMPLATES.AddBuildString(parent_widget, config)
	config = config or {}
    local version = parent_widget:AddChild(Text(config.font or BODYTEXTFONT, config.size or 21))
    version:SetPosition( config.x or 0, config.y or 0 )
	if config.colour then
	    version:SetColour(unpack(config.colour))
	else
	    version:SetColour(config.r or .8, config.g or .8, config.b or .8, config.a or 1)
	end
	if config.align ~= nil then
	    version:SetHAlign(config.align)
	end
	if config.w ~= nil and config.h ~= nil then
		version:SetRegionSize(config.w, config.h)
	end
    version:SetString(TEMPLATES.GetBuildString())
	return version
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
    -- Menus should start from the top as far as users are concerned.
    menu.reverse = true
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
function TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget, style, text_size)
	local image_scale = {0.6, 0.6}
	local image_offset = {-10,1}
	local text_region_width = 250
	local text_offset_x = 0
	if style then
		if "wide" == style then
			image_scale = {0.75, 0.6}
			image_offset = {15,1}
			text_region_width = 300
			text_offset_x = 25
		end
	end

    local btn = ImageButton(
        "images/global_redux.xml",
        "blank.tex", -- never used, hidden
        nil,
        nil,
        nil,
        "menu_selected.tex",
        image_scale,
        image_offset)
    btn.scale_on_focus = false
    btn:UseFocusOverlay("menu_focus.tex")
    btn:SetImageNormalColour(1,1,1,0) -- we don't want anything shown for normal.
    btn:SetImageFocusColour(1,1,1,0) -- use focus overlay instead.
    btn:SetImageSelectedColour(1,1,1,1)
    btn:SetFont(HEADERFONT)
    btn:SetDisabledFont(HEADERFONT)
    btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    btn:SetTextFocusColour(UICOLOURS.WHITE)
    btn:SetTextSelectedColour(UICOLOURS.GOLD_FOCUS)
    btn:SetText(text, true)
    btn.text:SetRegionSize(text_region_width,40)
	btn.text:SetPosition(text_offset_x,0)
    btn.text:SetHAlign(ANCHOR_LEFT)
    btn.text_shadow:SetRegionSize(text_region_width,40)
	btn.text_shadow:SetPosition(text_offset_x,0)
    btn.text_shadow:SetHAlign(ANCHOR_LEFT)
    btn:SetTextSize(text_size or 25)

    btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
    local w,h = btn.text:GetRegionSize()
    btn.bg:ScaleToSize(text_region_width, h+15)
    btn.bg:SetPosition(-10 + text_offset_x,1)

    btn.ongainfocus = function(is_enabled)
        if tooltip_widget ~= nil then
            tooltip_widget:SetString(tooltip_text)
        end
    end

    btn.onlosefocus = function()
        if btn.parent and not btn.parent.focus and tooltip_widget ~= nil then
            tooltip_widget:SetString("")
        end
    end
    btn:SetOnClick(onclick)

    return btn
end

function TEMPLATES.TwoLineMenuButton(text, onclick, tooltip_text, tooltip_widget)
    local btn = TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget)
    btn:SetTextures(
        "images/frontend_redux.xml",
        "menu_wardrobe_selection.tex", -- never used, hidden
        nil,
        nil,
        nil,
        "menu_wardrobe_selection.tex",
        {0.6},
        {-10,1})

    btn:UseFocusOverlay("menu_wardrobe_focus.tex")
    btn:SetTextSize(22)
    btn.text:SetPosition(20,10)
    btn.text:SetRegionSize(205,24)
    -- We're messing with the shadow and not maintaining it, so kill it.
    btn.text_shadow:Kill()

    btn.secondary_text = btn:AddChild( Text(NEWFONT, 20) )
    btn.secondary_text:SetHAlign(ANCHOR_LEFT)
    btn.secondary_text:SetRegionSize(205,24)
    btn.secondary_text:SetPosition(20,-10)

    btn.onselect = function()
        btn.secondary_text:Show()
        btn.text:SetPosition(20,10)
    end

    btn.onunselect = function()
        btn.secondary_text:Hide()
        btn.text:SetPosition(20,0)
    end

    btn.SetSecondaryText = function(self, second_text)
        self.secondary_text:SetString(second_text or "")
    end

    return btn
end

function TEMPLATES.WardrobeButton(text, onclick, tooltip_text, tooltip_widget)
    local btn = TEMPLATES.TwoLineMenuButton(text, onclick, tooltip_text, tooltip_widget)
    btn.icon = btn:AddChild( AccountItemFrame() )
    btn.icon:SetStyle_Normal()
    btn.icon:SetScale(0.4)
    btn.icon:SetPosition(-114,2)

    btn.SetItem = function(self,item_id)
        self.icon:SetItem(item_id)
        self:SetSecondaryText(item_id and GetSkinName(item_id) or "")
        self.secondary_text:SetColour(UICOLOURS.GREY)
        self.secondary_text:SetColour(GetColorForItem(item_id))
    end

    return btn
end

function TEMPLATES.WardrobeButtonMinimal(onclick)
    local btn = ImageButton(
        "images/global_redux.xml",
        "blank.tex", -- never used, hidden
        nil,
        nil,
        nil,
        "blank.tex",
        {0.6},
        {-10,1})
    btn.scale_on_focus = false
    btn:SetImageNormalColour(1,1,1,0) -- we don't want anything shown for normal.
    btn:SetImageFocusColour(1,1,1,0) -- use focus overlay instead.
    btn:SetImageSelectedColour(1,1,1,1)

    btn.ongainfocus = function(is_enabled)
        btn.icon:ShowFocus(true)
    end
    btn.onlosefocus = function()
        btn.icon:ShowFocus(false)
    end
    btn.onselect = function()
        btn.icon:ShowSelect(true)
    end
    btn.onunselect = function()
        btn.icon:ShowSelect(false)
    end
    btn:SetOnClick(onclick)

    btn.icon = btn:AddChild( AccountItemFrame() )
    btn.icon:SetStyle_Normal()
    btn.icon:SetScale(0.4)
    btn.icon:SetPosition(-114,2)

    btn.SetItem = function(self,item_id)
        self.icon:SetItem(item_id)
    end

    return btn
end
function TEMPLATES.PortraitIconMenuButton(text, onclick, tooltip_text, tooltip_widget)
    local btn = TEMPLATES.TwoLineMenuButton(text, onclick, tooltip_text, tooltip_widget)

    btn.title_portrait_bg = btn:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    btn.title_portrait_bg:SetScale(.45)
    btn.title_portrait_bg:SetPosition(-112,1)

    btn.title_portrait = btn.title_portrait_bg:AddChild(Image())

    local DEFAULT_ATLAS = "images/saveslot_portraits.xml"
    local DEFAULT_AVATAR = "unknown.tex"

    btn.SetCharacter = function(self, character_atlas, character)
        if character_atlas and character then
            self.title_portrait:SetTexture(character_atlas, character..".tex")
        else
            self.title_portrait:SetTexture(DEFAULT_ATLAS, DEFAULT_AVATAR)
        end
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

    btn:SetPosition(-572, -310)
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

-- Common button.
-- icon_data allows a square button that's sized relative to label. Doesn't
-- behave well with changing button labels.
function TEMPLATES.StandardButton(onclick, txt, size, icon_data)
    local prefix = "button_carny_long"
    if size and #size == 2 then
        local ratio = size[1] / size[2]
        if ratio > 4 then
            -- Longer texture will look better at this aspect ratio.
            prefix = "button_carny_xlong"
        elseif ratio < 1.1 then
            -- The closest we have to a tall button.
            prefix = "button_carny_square"
        end
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
    if icon_data then
        local width = btn.text.size
        btn.icon = btn.text:AddChild(Image(unpack(icon_data)))
        btn.icon:ScaleToSize(width, width)
        local icon_x = 1
        if btn.text:GetString():len() > 0 then
            local offset = width/2
            local padding = 5
            icon_x = -btn.text:GetRegionSize()/2 - offset - padding
            btn.text:SetPosition(offset,0)
        else
            -- If there's no text, btn.text is probably hidden. Parent to button
            -- instead. Placing icon relative to text is much easier as a child
            -- of text, so only parent to button if there's no text to align
            -- against.
            btn.icon = btn:AddChild(btn.icon)
        end
        btn.icon:SetPosition(icon_x,0)
    end
    return btn
end

-- Standard-style square button with a custom icon on the button.
-- Text label is not intended to be on the button! (It's beside, below, or hovertext.)
-- Text label offset can be specified, as well as whether or not it always shows.
-- For buttons containing both icon and text, see StandardButton's icon_data.
function TEMPLATES.IconButton(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
    local btn = TEMPLATES.StandardButton(onclick, nil, {70,70}, {iconAtlas, iconTexture})

    if not textinfo then
        textinfo = {}
    end

    if sideLabel then
        -- A label to the left of the button.
        btn.label = btn:AddChild(Text(textinfo.font or NEWFONT, textinfo.size or 25, labelText, textinfo.colour or UICOLOURS.GOLD_CLICKABLE))
        btn.label:SetRegionSize(150,70)
        btn.label:EnableWordWrap(true)
        btn.label:SetHAlign(ANCHOR_RIGHT)
        btn.label:SetPosition(-115, 2)

    elseif alwaysShowLabel then
        -- A label below the button.
        btn:SetTextSize(25)
        btn:SetText(labelText, true)
        btn.text:SetPosition(1, -38)
        btn.text_shadow:SetPosition(-1, -40)
        btn:SetFont(textinfo.font or NEWFONT)
        btn:SetTextColour(textinfo.colour or UICOLOURS.GOLD_CLICKABLE)
        btn:SetTextFocusColour(textinfo.focus_colour or UICOLOURS.GOLD_FOCUS)

    else
        -- Only show hovertext.
        btn:SetHoverText(labelText, {
                font = textinfo.font or NEWFONT_OUTLINE,
                offset_x = textinfo.offset_x or 2,
                offset_y = textinfo.offset_y or -45,
                colour = textinfo.colour or UICOLOURS.WHITE,
                bg = textinfo.bg
            })
    end

    return btn
end

function TEMPLATES.StandardCheckbox(onclick, size, init_checked, helptext, hovertext_info)
	local checkbox = ImageButton()
    checkbox:ForceImageSize(size, size)
	checkbox.scale_on_focus = false
    checkbox.move_on_click = false

	local function SetChecked(checked)
        if checked then
            checkbox:SetTextures("images/global_redux.xml", "checkbox_normal_check.tex", "checkbox_focus_check.tex", "checkbox_normal.tex", nil, nil, {1,1}, {0,0})
        else
            checkbox:SetTextures("images/global_redux.xml", "checkbox_normal.tex", "checkbox_focus.tex", "checkbox_normal_check.tex", nil, nil, {1,1}, {0,0})
        end
	end
	SetChecked(init_checked)

	checkbox:SetOnClick(function()
		local checked = onclick()
		SetChecked(checked)
	end)

	if helptext ~= nil then
		checkbox:SetHelpTextMessage(helptext)
	end

        -- Only show hovertext.
	if hovertext_info ~= nil then
        checkbox:SetHoverText(hovertext_info.text, {
                font = hovertext_info.font or NEWFONT_OUTLINE,
                offset_x = hovertext_info.offset_x or 2,
                offset_y = hovertext_info.offset_y or -45,
                colour = hovertext_info.colour or UICOLOURS.WHITE,
                bg = hovertext_info.bg
            })
    end

    return checkbox
end

function TEMPLATES.ServerDetailIcon(iconAtlas, iconTexture, bgColor, hoverText, textinfo, imgOffset, scaleX, scaleY)
    imgOffset = imgOffset or {0,0}

    local icon = Widget("detail_icon")
    icon.bg = icon:AddChild(Image("images/servericons.xml", bgColor and "bg_"..bgColor..".tex" or "bg_burnt.tex"))
    icon.bg:SetScale(.09)
    icon.img = icon:AddChild(Image(iconAtlas, iconTexture))
    icon.img:SetScale(scaleX or .075, scaleY or .075)
    icon.img:SetPosition(unpack(imgOffset))

    if hoverText and hoverText ~= "" then
        textinfo = textinfo or {}
        icon:SetHoverText(
            hoverText,
            {
                font = textinfo.font or NEWFONT_OUTLINE,
                offset_x = 2, -- for some reason, this looks more centred
                offset_y = -28,
                colour = textinfo.colour or {1,1,1,1},
                bg = textinfo.bg
            })
    end

    return icon
end

local normal_list_item_bg_tint = { 1,1,1,0.5 }
local function GetListItemPrefix(row_width, row_height)
    local prefix = "listitem_thick" -- 320 / 90 = 3.6
    local ratio = row_width / row_height
    if ratio > 6 then
        -- Longer texture will look better at this aspect ratio.
        prefix = "serverlist_listitem" -- 1220.0 / 50 = 24.4
    end
    return prefix
end

-- A list item backing that shows focus.
--
-- May want to call OnWidgetFocus if using with TrueScrollList or
-- ScrollingGrid:
--   row:SetOnGainFocus(function() self.scroll_list:OnWidgetFocus(row) end)
function TEMPLATES.ListItemBackground(row_width, row_height, onclick_fn)
    local prefix = GetListItemPrefix(row_width, row_height)
    local focus_list_item_bg_tint  = { 1,1,1,0.7 }

    local row = ImageButton("images/frontend_redux.xml",
        prefix .."_normal.tex", -- normal
        nil, -- focus
        nil,
        nil,
        prefix .."_selected.tex" -- selected
        )
    row:ForceImageSize(row_width,row_height)
    row:SetImageNormalColour(  unpack(normal_list_item_bg_tint))
    row:SetImageFocusColour(   unpack(focus_list_item_bg_tint))
    row:SetImageSelectedColour(unpack(normal_list_item_bg_tint))
    row:SetImageDisabledColour(unpack(normal_list_item_bg_tint))
    row.scale_on_focus = false
    row.move_on_click = false

    if onclick_fn then
        row:SetOnClick(onclick_fn)
        -- FocusOverlay caused incorrect scaling on morgue screen, but it
        -- wasn't clickable. Related?
        row:UseFocusOverlay(prefix .."_hover.tex")
    else
        row:SetHelpTextMessage("") -- doesn't respond to clicks
    end
    return row
end

-- For list items that contain a single focusable widget.
--
-- Instead of a button that changes colour (or has a hover border) when the
-- list item is focused, just set a similar-looking background.
function TEMPLATES.ListItemBackground_Static(row_width, row_height)
    local prefix = GetListItemPrefix(row_width, row_height)
    local row = Image("images/frontend_redux.xml",
        prefix .."_normal.tex"
        )
    row:SetSize(row_width,row_height)
    row:SetTint(unpack(normal_list_item_bg_tint))
    return row
end

-- A widget that displays info about a mod. To be used in scroll lists etc.
function TEMPLATES.ModListItem(onclick_btn, onclick_checkbox, onclick_setfavorite)
    local opt = Widget("option")

    local item_width,item_height = 340, 90
    opt.backing = opt:AddChild(TEMPLATES.ListItemBackground(item_width,item_height,onclick_btn))
    opt.backing.move_on_click = true

    opt.Select = function(_)
        opt.name:SetColour(UICOLOURS.GOLD_SELECTED)
        opt.backing:Select()
    end

    opt.Unselect = function(_)
        opt.name:SetColour(UICOLOURS.GOLD_CLICKABLE)
        opt.backing:Unselect()
    end

    opt.checkbox = opt.backing:AddChild(ImageButton())
    opt.checkbox:SetPosition(140, -22, 0)
    opt.checkbox:SetOnClick(onclick_checkbox)
    opt.checkbox:SetHelpTextMessage("") -- button nested in a button doesn't need extra helptext

    opt.setfavorite = opt.backing:AddChild(ImageButton())
    opt.setfavorite:SetPosition(100, -22, 0)
    opt.setfavorite:SetOnClick(onclick_setfavorite)
    opt.setfavorite:SetHelpTextMessage("") -- button nested in a button doesn't need extra helptext
    opt.setfavorite.scale_on_focus = false

    opt.image = opt.backing:AddChild(Image())
    opt.image:SetPosition(-120,0,0)
    opt.image:SetClickable(false)

    opt.out_of_date_image = opt.backing:AddChild(Image("images/frontend.xml", "circle_red.tex"))
    opt.out_of_date_image:SetScale(.65)
    opt.out_of_date_image:SetPosition(25, -22)
    opt.out_of_date_image:SetClickable(false)
    opt.out_of_date_image.icon = opt.out_of_date_image:AddChild(Image("images/button_icons.xml", "update.tex"))
    opt.out_of_date_image.icon:SetPosition(-1,0)
    opt.out_of_date_image.icon:SetScale(.15)
    opt.out_of_date_image:Hide()

    opt.configurable_image = opt.backing:AddChild(Image("images/button_icons.xml", "configure_mod.tex"))
    opt.configurable_image:SetScale(.1)
    opt.configurable_image:SetPosition(60, -20)
    opt.configurable_image:SetClickable(false)
    opt.configurable_image:Hide()

    opt.name = opt.backing:AddChild(Text(CHATFONT, 26))
    opt.name:SetVAlign(ANCHOR_MIDDLE)

    opt.status = opt.backing:AddChild(Text(BODYTEXTFONT, 23))
    opt.status:SetVAlign(ANCHOR_MIDDLE)
    opt.status:SetHAlign(ANCHOR_LEFT)

    opt.SetModStatus = function(_, modstatus)
        if modstatus == "WORKING_NORMALLY" then
            opt.status:SetColour(59/255, 222/255, 99/255, 1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WORKING_NORMALLY)
        elseif modstatus == "DISABLED_ERROR" then
            opt.status:SetColour(242/255, 99/255, 99/255, 1)--0.9,0.3,0.3,1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_ERROR)
        elseif modstatus == "DISABLED_MANUAL" then
            opt.status:SetColour(.6,.6,.6,1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_MANUAL)
        else
            -- We should probably never hit this line.
            --opt.status:SetString(modname)
        end
    end

    opt.status:SetPosition(25, -20, 0)
    opt.status:SetRegionSize( 200, 50 )

    opt.SetModReadOnly = function(_, should_be_readonly)
        if should_be_readonly then
            -- We still allow configuration! We just don't want to show
            -- enable/disable options or state.
            opt.image_disabled_tint = UICOLOURS.WHITE
            opt.checkbox:Hide()
            opt.status:Hide()
        else
            opt.image_disabled_tint = {1.0,0.5,0.5,1} -- reddish
            opt.checkbox:Show()
            opt.status:Show()
        end
    end

    opt.SetModConfigurable = function(_, should_enable)
        if should_enable then
            opt.configurable_image:Show()
        else
            opt.configurable_image:Hide()
        end
    end

    opt.SetModEnabled = function(_, should_enable)
        if should_enable then
            opt.image:SetTint(unpack(UICOLOURS.WHITE))
            opt.checkbox:SetTextures("images/global_redux.xml", "checkbox_normal_check.tex", "checkbox_focus_check.tex", "checkbox_normal.tex", nil, nil, {1,1}, {0,0})
        else
            opt.image:SetTint(unpack(opt.image_disabled_tint))
            opt.checkbox:SetTextures("images/global_redux.xml", "checkbox_normal.tex", "checkbox_focus.tex", "checkbox_normal_check.tex", nil, nil, {1,1}, {0,0})
        end
    end

    opt.SetModFavorited = function(_, should_favorite)
        if should_favorite then
            opt.setfavorite:SetTextures("images/global_redux.xml", "star_checked.tex", nil, "star_uncheck.tex", nil, nil, {0.75,0.75}, {0, 0})
        else
            opt.setfavorite:SetTextures("images/global_redux.xml", "star_uncheck.tex", nil, "star_checked.tex", nil, nil, {0.75,0.75}, {0, 0})
        end
    end

    opt.SetMod = function(_, modname, modinfo, modstatus, isenabled, isfavorited)
        if modinfo and modinfo.icon_atlas and modinfo.icon then
            opt.image:SetTexture(modinfo.icon_atlas, modinfo.icon)
        else
            opt.image:SetTexture("images/ui.xml", "portrait_bg.tex")
        end
        -- SetTexture clobbers our previously set size.
        opt.image:SetSize(70,70)

        local nameStr = (modinfo and modinfo.name) and modinfo.name or modname
        opt.name:SetTruncatedString(nameStr, 235, 51, true)
        -- I think this is manually left-aligning (since SetRegionSize doesn't
        -- work with SetTruncatedString).
        local w, h = opt.name:GetRegionSize()
        opt.name:SetPosition(w * .5 - 75, 17, 0)

        opt:SetModStatus(modstatus)
        opt:SetModEnabled(isenabled)
        opt:SetModFavorited(isfavorited)
    end

    opt:SetModReadOnly(false) -- sets up some initial values
    opt:Unselect()

    opt.focus_forward = opt.backing

    return opt
end

-- A widget that displays a mod that is currently being downloaded.
function TEMPLATES.ModListItem_Downloading()
    local opt = Widget("option")

    local item_width,item_height = 340, 90
    opt.backing = opt:AddChild(TEMPLATES.ListItemBackground(item_width,item_height))

    opt.name = opt:AddChild(Text(CHATFONT, 30))
    opt.name:SetVAlign(ANCHOR_MIDDLE)
    opt.name:SetHAlign(ANCHOR_MIDDLE)
    opt.name:SetColour(UICOLOURS.GOLD)
    opt.name:SetRegionSize(item_width,item_height)

    opt.SetMod = function(_, mod)
        opt.name:SetString(subfmt(STRINGS.UI.MODSSCREEN.DOWNLOADINGMOD, {name = mod.fancy_name}))
    end

    opt.Select = function(_)
    end

    opt.Unselect = function(_)
    end

    return opt
end

function TEMPLATES.DoodadCounter(number_of_doodads)
    local doodad = Widget("DoodadCounter")
    doodad.image = doodad:AddChild(UIAnim())
    doodad.image:GetAnimState():SetBank("spool")
    doodad.image:GetAnimState():SetBuild("spool")
    doodad.image:GetAnimState():PlayAnimation("idle", true)

	doodad.doodad_count = doodad:AddChild(Text(CHATFONT_OUTLINE, 35, nil, UICOLOURS.WHITE))
    doodad.doodad_count:SetPosition(0, -60)
    doodad.doodad_count:SetRegionSize(120, 43)
    doodad.doodad_count:SetHAlign(ANCHOR_MIDDLE)

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

function TEMPLATES.KleiPointsCounter(number_of_points)
    local points = Button("KleiPointsCounter")
    points.image = points:AddChild(UIAnim())
    points.image:GetAnimState():SetBank("kleipoints")
    points.image:GetAnimState():SetBuild("kleipoints")
    points.image:GetAnimState():PlayAnimation("idle", true)

	points.points_count = points:AddChild(Text(CHATFONT_OUTLINE, 35, nil, UICOLOURS.WHITE))
    points.points_count:SetPosition(0, -60)
    points.points_count:SetRegionSize(120, 43)
    points.points_count:SetHAlign(ANCHOR_MIDDLE)

    points.SetCount = function(self, new_count)
        self.points_count:SetString("x"..new_count)
        if new_count == 0 then
            self:Hide()
        else
            self:Show()
        end
    end

    points:SetCount(number_of_points)

    points:SetOnClick(
        function()
            TheFrontEnd:GetAccountManager():VisitAccountPage("rewards")
        end
    )

    return points
end

function TEMPLATES.BoltCounter(number_of_bolts)
    local bolt = Widget("BoltCounter")
    bolt.image = bolt:AddChild(UIAnim())
    bolt.image:GetAnimState():SetBank("cloth")
    bolt.image:GetAnimState():SetBuild("bolt_of_cloth")
    bolt.image:GetAnimState():PlayAnimation("idle", true)
    bolt.image:SetScale(1.3)

	bolt.bolt_count = bolt:AddChild(Text(CHATFONT_OUTLINE, 35, nil, UICOLOURS.WHITE))
    bolt.bolt_count:SetPosition(0, -60)
    bolt.bolt_count:SetRegionSize(200, 43)
    bolt.bolt_count:SetHAlign(ANCHOR_MIDDLE)

    bolt._CountFn = function(self)
        if self.num_display_bolts ~= self.num_bolts then
            local step = (self.num_bolts - self.num_display_bolts)/24

            if self.num_bolts > self.num_display_bolts then
                step = math.ceil(step)
            else
                step = math.floor(step)
            end

            self.num_display_bolts = self.num_display_bolts + step

            self.inst:DoTaskInTime(FRAMES, function()
                self:_CountFn()
            end)
        end

        self.bolt_count:SetString("x"..self.num_display_bolts)
    end

    bolt.SetCount = function(self, new_count, animatebolt)
        local should_skip = self.num_bolts == nil or not animatebolt
        self.num_display_bolts = self.num_bolts
        self.num_bolts = new_count
        if not should_skip then
            bolt.image:GetAnimState():PlayAnimation("use")
            bolt.image:GetAnimState():PushAnimation("idle", true)
            self:_CountFn()
        else
            self.num_display_bolts = new_count
            self.num_bolts = new_count
            self.bolt_count:SetString("x"..new_count)
        end
    end

    bolt:SetCount(number_of_bolts)

    return bolt
end

-- Unlabelled text entry box
--
-- height and following arguments are optional.
function TEMPLATES.StandardSingleLineTextEntry(fieldtext, width_field, height, font, font_size, prompt_text)
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

    if prompt_text then
        wdg.textbox:SetTextPrompt(prompt_text, UICOLOURS.GREY)
    end

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
function TEMPLATES.LabelSpinner(labeltext, spinnerdata, width_label, width_spinner, height, spacing, font, font_size, horiz_offset, onchanged_fn, colour, tooltip_text)
    width_label = width_label or 220
    width_spinner = width_spinner or 150
    height = height or 40
    spacing = spacing or 5
    font = font or CHATFONT
    font_size = font_size or 25

    local offset = horiz_offset or 0
    local total_width = width_label + width_spinner + spacing
    local wdg = Widget("labelspinner")
    wdg.label = wdg:AddChild( Text(font, font_size, labeltext) )
    wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
    wdg.label:SetRegionSize( width_label, height )
    wdg.label:SetHAlign( ANCHOR_RIGHT )
    wdg.label:SetColour(colour or UICOLOURS.GOLD)
    wdg.spinner = wdg:AddChild(TEMPLATES.StandardSpinner(spinnerdata, width_spinner, height, font, font_size, onchanged_fn, colour))
    wdg.spinner:SetPosition((total_width/2)-(width_spinner/2) + offset, 0)

    wdg.focus_forward = wdg.spinner

    wdg.tooltip_text = tooltip_text

    return wdg
end

-- Spinner of numbers with a label beside it
function TEMPLATES.LabelNumericSpinner(labeltext, min, max, width_label, width_spinner, height, spacing, font, font_size, horiz_offset, tooltip_text)
    width_label = width_label or 220
    width_spinner = width_spinner or 150
    height = height or 40
    spacing = spacing or -50 -- why negative?
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
    wdg.spinner = wdg:AddChild(TEMPLATES.StandardNumericSpinner(min, max, width_spinner, height, font, font_size))
    wdg.spinner:SetPosition((total_width/2)-(width_spinner/2) + offset, 0)
    wdg.spinner:SetTextColour(UICOLOURS.GOLD)

    wdg.focus_forward = wdg.spinner

    wdg.tooltip_text = tooltip_text

    return wdg
end

-- Text button with a label beside it
function TEMPLATES.LabelButton(onclick, labeltext, buttontext, width_label, width_button, height, spacing, font, font_size, horiz_offset)
    local offset = horiz_offset or 0
    local total_width = width_label + width_button + spacing
    local wdg = Widget("labelbutton")
    wdg.label = wdg:AddChild( Text(font or NEWFONT, font_size or 25, labeltext) )
    wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
    wdg.label:SetRegionSize( width_label, height )
    wdg.label:SetHAlign( ANCHOR_RIGHT )
    wdg.label:SetColour(UICOLOURS.GOLD)
    wdg.button = wdg:AddChild(TEMPLATES.StandardButton(nil, buttontext, {width_button, height}))
    wdg.button:SetPosition((total_width/2)-(width_button/2) + offset, 0)
    wdg.button:SetOnClick(onclick)

    wdg.focus_forward = wdg.button

    return wdg
end

-- checkbox button with a label beside it
function TEMPLATES.OptionsLabelCheckbox(onclick, labeltext, checked, width_label, width_button, height, checkbox_size, spacing, font, font_size, horiz_offset, tooltip_text)
    local offset = horiz_offset or 0
    local total_width = width_label + width_button + spacing
    local wdg = Widget("labelbutton")
    wdg.label = wdg:AddChild( Text(font or NEWFONT, font_size or 25, labeltext) )
    wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
    wdg.label:SetRegionSize( width_label, height )
    wdg.label:SetHAlign( ANCHOR_RIGHT )
    wdg.label:SetColour(UICOLOURS.GOLD)
    wdg.button = wdg:AddChild(TEMPLATES.StandardCheckbox(onclick, checkbox_size, checked))
    wdg.button:SetPosition((total_width/2)-(width_button/2) + offset, 0)

    wdg.focus_forward = wdg.button

    wdg.tooltip_text = tooltip_text

    return wdg
end

function TEMPLATES.LabelCheckbox(onclick, checked, text)
    local checkbox = ImageButton()
	checkbox._text_offset = 20
    checkbox:SetTextColour(UICOLOURS.GOLD)
    checkbox:SetTextFocusColour(UICOLOURS.HIGHLIGHT_GOLD)
    checkbox:SetFont(CHATFONT_OUTLINE)
    checkbox:SetDisabledFont(CHATFONT_OUTLINE)
    checkbox:SetTextDisabledColour(UICOLOURS.GOLD)
    checkbox:SetText(text)
    checkbox:SetTextSize(25)
    checkbox.text:SetHAlign(ANCHOR_LEFT)

	local text_width = checkbox.text:GetRegionSize()
    checkbox.text:SetPosition(checkbox._text_offset + text_width/2, 0)

    checkbox.clickoffset = Vector3(0,0,0)

    checkbox.checked = checked
    checkbox:SetOnClick(function() onclick(checkbox) end)

	checkbox.Refresh = function(self)
		if self.checked then
			self:SetTextures("images/global_redux.xml", "checkbox_normal_check.tex", "checkbox_focus_check.tex", "checkbox_normal_check.tex", nil, nil, {1,1}, {0,0})
		else
			self:SetTextures("images/global_redux.xml", "checkbox_normal.tex", "checkbox_focus.tex", "checkbox_normal.tex", nil, nil, {1,1}, {0,0})
		end
	end

	checkbox:Refresh()
	return checkbox
end

-- Spinner
function TEMPLATES.StandardSpinner(spinnerdata, width_spinner, height, font, font_size, onchanged_fn, colour)
    local atlas = "images/global_redux.xml"
    local lean = true
    local wdg = Spinner(spinnerdata, width_spinner, height, {font = font or CHATFONT, size = font_size or 25}, nil, atlas, nil, lean)
    wdg:SetTextColour(colour or UICOLOURS.GOLD)
	wdg:SetOnChangedFn(onchanged_fn)
    return wdg
end

-- Spinner
function TEMPLATES.StandardNumericSpinner(min, max, width_spinner, height, font, font_size)
    local atlas = "images/global_redux.xml"
    local lean = true
    local wdg = NumericSpinner(min, max, width_spinner, height, {font = font or CHATFONT, size = font_size or 25}, atlas, nil, nil, lean)
    wdg:SetTextColour(UICOLOURS.GOLD)
    return wdg
end

function TEMPLATES.CharacterSpinner(onchanged_fn, puppet, user_profile)
    local hero_data = {}
    for i,hero in ipairs(GetFEVisibleCharacterList()) do
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
            local clothing = user_profile:GetSkinsForCharacter(selected_name)
            local skip_change_emote = true
            puppet:SetSkins(selected_name, clothing.base, clothing, skip_change_emote)
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

function TEMPLATES.ChatFlairBadge()
    local flair = Widget("chat flair badge")

    flair.bg = flair:AddChild(Image())
    flair.bg:SetScale(0.8)

    flair.flair_img = flair:AddChild(Image(GetProfileFlairAtlasAndTex()))
    flair.flair_img:SetScale(.55)
    flair.flair_img:SetPosition(0, 31)

    flair.SetFestivalBackground = function(self, festival_key)
        festival_key = festival_key or "none"
        self.bg:SetTexture("images/profileflair.xml", "playericon_bg_".. festival_key ..".tex", "playericon_bg_none.tex")
    end
    -- Assume current event.
    flair:SetFestivalBackground(IsAnyFestivalEventActive() and WORLD_FESTIVAL_EVENT or nil)
    flair:Hide()
    flair:SetClickable(false)

    --Setup custom widget functions
    flair.SetFlair = function(self, profileflair)
        self.profileflair = profileflair

        if self.profileflair then
            local profileflair = self.profileflair
            if profileflair == "default" then
                profileflair = nil
            end
            self.flair_img:SetTexture(GetProfileFlairAtlasAndTex(profileflair))
        end
    end

    flair.GetFlair = function(self)
        return self.profileflair
    end

    flair.SetAlpha = function(self, a)
        if a > 0.01 and self.profileflair then
            self:Show()
            self.bg:SetTint(1,1,1, a)
            self.flair_img:SetTint(1,1,1, a)
        else
            self:Hide()
        end
    end

    flair:SetScale(0.5)

    flair.GetSize = function(self)
        return self.flair_img:GetScaledSize()
    end

    return flair
end

function TEMPLATES.ChatterMessageBadge()
    local flair = Widget("ChatterMessage Badge")

    flair.bg = flair:AddChild(Image())
    flair.bg:SetScale(0.8)

    flair.flair_img = flair:AddChild(Image("images/npcchatflairs.xml", "npcchatflair_none.tex"))
    flair.flair_img:SetScale(.55)
    flair.flair_img:SetPosition(0, 31)

    flair:Hide()
    flair:SetClickable(false)

    --Setup custom widget functions
    flair.SetFlair = function(self, chatflair)
        self.profileflair = chatflair

        if self.profileflair then
            local attempt_texture = ((not chatflair or chatflair == "default") and "npcchatflair_none.tex")
                or chatflair..".tex"
            self.flair_img:SetTexture("images/npcchatflairs.xml", attempt_texture, "npcchatflair_none.tex")
        end
    end

    flair.GetFlair = function(self)
        return self.profileflair
    end

    flair.SetBGIcon = function(self, bg_icon)
        self.bg_icon = bg_icon
        if self.bg_icon then
            if bg_icon == "default" then
                bg_icon = "playericon_bg_none"
            end
            self.bg:SetTexture("images/profileflair.xml", bg_icon .. ".tex", "playericon_bg_none.tex")
        end
    end

    flair.GetBGIcon = function(self)
        return self.bg_icon
    end

    flair.SetAlpha = function(self, a)
        if a > 0.01 and self.profileflair then
            self:Show()
            self.bg:SetTint(1,1,1, a)
            self.flair_img:SetTint(1,1,1, a)
        else
            self:Hide()
        end
    end

    flair:SetScale(0.5)

    flair.GetSize = function(self)
        return self.flair_img:GetScaledSize()
    end

    return flair
end

function TEMPLATES.AnnouncementBadge()
    local announcement = Widget("chat announcement badge")

    announcement.bg = announcement:AddChild(Image("images/button_icons.xml", "circle.tex"))
    announcement.bg:SetScale(1.35)
    announcement.bg:SetPosition(0,27)

    announcement.announcement_img = announcement:AddChild(Image("images/button_icons.xml", "announcement.tex"))
    announcement.announcement_img:SetScale(1.35)
    announcement.announcement_img:SetPosition(0, 31)

    announcement:Hide()
    announcement:SetClickable(false)

    --Setup custom widget functions
    announcement.SetAnnouncement = function(self, announcement)
        self.announcement = announcement

        if announcement then
            local icon_info = ANNOUNCEMENT_ICONS[announcement]
            self.announcement_img:SetTexture(icon_info.atlas or "images/button_icons.xml", icon_info.texture or "announcement.tex")
        end
    end

    announcement.GetAnnouncement = function(self)
        return self.announcement
    end

    announcement.SetAlpha = function(self, a)
        if a > 0.01 and self.announcement then
            self:Show()
            self.bg:SetTint(1,1,1, a)
            self.announcement_img:SetTint(1,1,1, a)
        else
            self:Hide()
        end
    end

    announcement:SetScale(0.5)

    announcement.GetSize = function(self)
        return self.announcement_img:GetScaledSize()
    end

    return announcement
end

function TEMPLATES.SystemMessageBadge()
    local systemmessage = Widget("chat system message badge")

    systemmessage.bg = systemmessage:AddChild(Image("images/servericons.xml", "bg_brown.tex"))
    systemmessage.bg:SetScale(0.22)
    systemmessage.bg:SetPosition(0,31)

    systemmessage.systemmessage_img = systemmessage:AddChild(Image("images/servericons.xml", "dedicated.tex"))
    systemmessage.systemmessage_img:SetScale(0.19)
    systemmessage.systemmessage_img:SetPosition(0, 31)

    systemmessage:Hide()
    systemmessage:SetClickable(false)

    systemmessage.SetAlpha = function(self, a)
        if a > 0.01 then
            self:Show()
            self.bg:SetTint(1,1,1, a)
            self.systemmessage_img:SetTint(1,1,1, a)
        else
            self:Hide()
        end
    end

    systemmessage:SetScale(0.5)

    systemmessage.GetSize = function(self)
        return self.systemmessage_img:GetScaledSize()
    end

    return systemmessage
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

    rank.SetRank = function(self, profileflair, rank_value, hide_hover_text)
        if not IsAnyFestivalEventActive() then
            rank_value = nil
        end

        if not hide_hover_text and IsItemId(profileflair) then
            rank.flair:SetHoverText( GetSkinName(profileflair), { font = UIFONT, offset_x = 0, offset_y = 40, colour = GetColorForItem(profileflair) } )
        else
            rank.flair:ClearHoverText()
        end
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
        self.rank:SetRank(GetMostRecentlySelectedItem(Profile, "profileflair"), wxputils.GetActiveLevel())
        self.bar:GetAnimState():SetPercent("fill_progress", wxputils.GetLevelPercentage())
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
        bar:SetPercent(wxputils.GetLevelPercentage())
        xp_earn:SetString(wxputils.BuildProgressString())

        local level = wxputils.GetActiveLevel()
        local level_start_xp, next_level_xp = wxputils.GetWXPForLevel(level)
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
    sizeX = math.clamp(sizeX or 200, 90, 1190)
    sizeY = math.clamp(sizeY or 200, 50, 620)
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
        local button_height = -30 -- cover bottom crown

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

    w.HideBackground = function(self)
        for i=4,5 do
            self.elements[i]:Hide()
        end
        self.mid_center:Hide()
    end

    w.InsertWidget = function(self, widget)
		w:AddChild(widget)
		for i=1,3 do
            self.elements[i]:MoveToFront()
        end
        for i=6,8 do
            self.elements[i]:MoveToFront()
        end
        w.bottom:MoveToFront()
		return widget
    end

    -- Default to our standard brown.
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    w:SetBackgroundTint(r,g,b,0.6)

    return w
end

-- Build controller input functions from buttons passed to Menu (or
-- CurlyWindow, etc). Screens can call these functions to support the button
-- inputs from anywhere.
-- Each element in buttons should contain:
-- {
--      text = string,
--      cb = function,
--      controller_control = number,
-- }
-- Avoid CONTROL_ACCEPT unless you're hiding the buttons (since the focused
-- button takes that input).
function TEMPLATES.ControllerFunctionsFromButtons(buttons)
    if not buttons or IsTableEmpty(buttons) then
        return function() return false end, function() return "" end
    end

    local has_controls_specified = false
    for i,v in ipairs(buttons) do
        if v.controller_control then
            has_controls_specified = true
            break
        end
    end
    if not has_controls_specified then
        -- If there are multiple options, assume the far right one is cancel.
        -- If there's only one option, it's likely to have the focus so don't
        -- create two inputs for the same option.
        local last_button = buttons[#buttons]
        if #buttons > 1 and last_button then
            last_button.controller_control = CONTROL_CANCEL
        end
    end

    local function OnControl(control, down)
        if down then
            return false
        -- Hitting Esc fires both Pause and Cancel, so we can only handle pause
        -- when coming from gamepads.
        elseif control ~= CONTROL_MENU_START or TheInput:ControllerAttached() then
            for i,v in ipairs(buttons) do
                if control == v.controller_control then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                    v.cb()
                    return true
                end
            end
        end

        return false
    end
    local function GetHelpText()
        local controller_id = TheInput:GetControllerID()
        local t = {}

        for i,v in ipairs(buttons) do
            if v.controller_control then
                table.insert(t, TheInput:GetLocalizedControl(controller_id, v.controller_control) .. " " .. v.text)
            end
        end
        return table.concat(t, "  ")
    end

    return OnControl, GetHelpText
end

function TEMPLATES.ScrollingGrid(items, opts)
    local peek_height = opts.peek_height or (opts.widget_height * 0.25) -- how much of row to see at the bottom.
    if opts.peek_percent then
        -- Caller can force a peek height if they will add items to the list or
        -- have hidden empty widgets.
        peek_height = opts.widget_height * opts.peek_percent
    elseif not opts.force_peek and #items < math.floor(opts.num_visible_rows) * opts.num_columns then
        -- No peek if we won't scroll.
        -- This won't work if we later update the items in the grid. Would be
        -- nice if TrueScrollList could handle this but I think we'd need to
        -- update the scissor region or change the show widget threshold?
        peek_height = 0
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

        -- Higher up widgets are further to front so their hover text can
        -- appear over the widget beneath them.
        for i,w in ipairs(widgets) do
            w:MoveToBack()
        end

        -- end_offset helps ensure last item can scroll into view. It's a
        -- percent of a row height. 1 ensures that scrolling to the bottom puts
        -- a fully-displayed widget at the top. 0.75 prevents the next (empty)
        -- row from being visible.
        local end_offset = opts.end_offset or 0.75
        if opts.allow_bottom_empty_row then
            end_offset = 1
        end
        return widgets, opts.num_columns, opts.widget_height, opts.num_visible_rows, end_offset
    end

    local scissor_pad = opts.scissor_pad or 0
    local scissor_width  = opts.widget_width  * opts.num_columns      + scissor_pad
    local scissor_height = opts.widget_height * opts.num_visible_rows + peek_height
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
        opts.scrollbar_height_offset,
		opts.scroll_per_click
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

-- for making static health/hunger/sanity for using in the lobby
function TEMPLATES.MakeUIStatusBadge(_status_name, c)
	local status = Widget(_status_name.."_status")

	status.status_icon = status:AddChild(Image())
	status.status_icon:SetTexture("images/global_redux.xml", "status_".._status_name..".tex")
	status.status_icon:SetScale(.55)

	status.status_image = status:AddChild(Image("images/global_redux.xml", "value_gold.tex"))
	status.status_image:SetScale(.66)
	status.status_image:SetPosition(0, -33)

	status.status_value = status:AddChild(Text(HEADERFONT, 20, "", UICOLOURS.BLACK))
	status.status_value:SetPosition(0, -34)

	status.ChangeCharacter = function(self, character)
		local status_name = TUNING.CHARACTER_DETAILS_OVERRIDE[character.."_".._status_name] or _status_name

		status.status_icon:SetTexture("images/global_redux.xml", "status_"..status_name..".tex")

		local v = tostring(TUNING[string.upper(character.."_"..status_name)] or STRINGS.CHARACTER_DETAILS.STAT_UNKNOW)
		status.status_value:SetString(v)
	end

	if c ~= nil then
		status:ChangeCharacter(c)
	end

	return status
end

function TEMPLATES.MakeStartingInventoryWidget(c, left_align)
	local root = Widget("starting_inv_root")

    local title = root:AddChild(Text(HEADERFONT, 25, STRINGS.CHARACTER_DETAILS.STARTING_ITEMS_TITLE, UICOLOURS.GOLD_UNIMPORTANT))
    local title_w, title_h = title:GetRegionSize()
	title:SetPosition(left_align and title_w/2 or 0, -title_h/2)
	title:SetHAlign(left_align and ANCHOR_LEFT or ANCHOR_MIDDLE)

	root._invitems = root:AddChild(Widget("items_root"))

	root.ChangeCharacter = function(self, character)
		character = string.upper(character)
		self._invitems:KillAllChildren()

		local inv_item_list = GetUniquePotentialCharacterStartingInventoryItems(character, false)
		if inv_item_list[1] ~= nil then

			local scale = 0.85
			local spacing = 5
			local slot_width, total_width, x

			for i, item in ipairs(inv_item_list) do
				local slot = root._invitems:AddChild(Image("images/hud.xml", "inv_slot.tex"))

				local override_item_image = TUNING.STARTING_ITEM_IMAGE_OVERRIDE[item]
                local atlas = override_item_image ~= nil and override_item_image.atlas or GetInventoryItemAtlas(item..".tex", true)
                if atlas ~= nil then
				    local image = override_item_image ~= nil and override_item_image.image or (item..".tex")
                    slot:AddChild(Image(atlas, image)):SetScale(0.9)
                end
				slot:SetScale(scale)
				if slot_width == nil then
					slot_width = 68 * scale
					total_width = (slot_width * #inv_item_list + spacing * (#inv_item_list - 1))
					x = left_align and (slot_width/2) or (-total_width/2 + slot_width/2)
				end
				slot:SetPosition(x, -(title_h + spacing + slot_width/2))

				x = x + slot_width + spacing
			end
		else
			-- no gear
			local label = root._invitems:AddChild(Text(HEADERFONT, 21, STRINGS.CHARACTER_DETAILS.STARTING_ITEMS_NONE, UICOLOURS.GREY))
		    local w = label:GetRegionSize()
			label:SetPosition(left_align and (title_w/2 - (title_w/2 - w/2)) or 1, -35)
			label:SetHAlign(left_align and ANCHOR_LEFT or ANCHOR_MIDDLE)
		end
	end

	if c ~= nil then
		root:ChangeCharacter(c)
	end

	return root
end

return TEMPLATES
