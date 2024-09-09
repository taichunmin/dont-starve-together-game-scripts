local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Button = require "widgets/button"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local NineSlice = require "widgets/nineslice"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local AnimButton = require "widgets/animbutton"
local ItemImage = require "widgets/itemimage"


local smoke_offset = -20

local TEMPLATES = nil
TEMPLATES = {

    ----------------
    ----------------
    -- Static background comp --
    ----------------
    ----------------

    NoPortalBackground = function()
        local bg = Widget("background")

        bg.bgplate = bg:AddChild(TEMPLATES.BackgroundPlate())
        bg.fgplate = bg:AddChild(TEMPLATES.ForegroundPlate())
        bg.trees = bg:AddChild(TEMPLATES.ForegroundTrees())

        bg:SetCanFadeAlpha(false)

        return bg
    end,

    ----------------
    ----------------
    -- BACKGROUND --
    ----------------
    ----------------

    -- A static, full screen background image
    -- To be added as a child of the screen itself.
    --[[Background = function()
        local bg = Image("images/bg_color.xml", "bg.tex")
        TintBackground(bg)
        bg:SetVRegPoint(ANCHOR_MIDDLE)
        bg:SetHRegPoint(ANCHOR_MIDDLE)
        bg:SetVAnchor(ANCHOR_MIDDLE)
        bg:SetHAnchor(ANCHOR_MIDDLE)
        bg:SetScaleMode(SCALEMODE_FILLSCREEN)

        bg:SetCanFadeAlpha(false)

        return bg
    end,]]

    -- A dynamic background scene with an animated portal and smoke/mist
    -- To be added as a child of the screen itself.
    AnimatedPortalBackground = function()
        local bg = Widget("background")

        bg.plate = bg:AddChild(TEMPLATES.BackgroundPlate())

        bg.anim_root = bg:AddChild(Widget("anim_root"))
        bg.anim_root:SetVAnchor(ANCHOR_MIDDLE)
        bg.anim_root:SetHAnchor(ANCHOR_MIDDLE)
        bg.anim_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        if not InGamePlay() then
            if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                bg.EnableSmoke = function() end
            else
                bg.anim_root.smoke = bg.anim_root:AddChild(TEMPLATES.BackgroundSmoke())

                bg.EnableSmoke = function(bg, enable)
                    if enable then
                        bg.anim_root.smoke:Show()
                    else
                        bg.anim_root.smoke:Hide()
                    end
                end

                if TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode() then
                    bg:EnableSmoke(false)
                end
            end
        end

        bg.anim_root.portal = bg.anim_root:AddChild(TEMPLATES.BackgroundPortal())

        bg:SetCanFadeAlpha(false)

        return bg
    end,

    -- A component of the AnimatedPortalBackground
    BackgroundPlate = function()
        local root = Widget("bg_plate_root")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local plate = root:AddChild(Image("images/bg_animated_portal.xml", "bg_plate.tex"))
        plate:SetVRegPoint(ANCHOR_MIDDLE)
        plate:SetHRegPoint(ANCHOR_MIDDLE)

        local w = plate:GetSize()
        plate:SetScale(RESOLUTION_X / w)

        return root
    end,

    -- A component of the AnimatedPortalBackground
    BackgroundSmoke = function()
        local smoke = UIAnim()
        smoke:GetAnimState():SetBuild("portal_scene_steamfxbg")
        smoke:GetAnimState():SetBank("cloudsfx_BG")
        smoke:GetAnimState():PlayAnimation("idle_bg", true)
        smoke:SetScale(.7)
        smoke:SetPosition(0,-500)
        smoke:GetAnimState():SetMultColour(FRONTEND_SMOKE_COLOUR[1], FRONTEND_SMOKE_COLOUR[2], FRONTEND_SMOKE_COLOUR[3], 1)

        return smoke
    end,

    -- A component of the AnimatedPortalBackground
    BackgroundPortal = function()
        local portal = UIAnim()
        portal:GetAnimState():SetBuild("portal_scene2")
        portal:GetAnimState():SetBank("portal_scene")
        portal:GetAnimState():PlayAnimation("portal_idle", false)
        portal:GetAnimState():SetMultColour(unpack(FRONTEND_PORTAL_COLOUR))
        portal:SetScale(.4)

        return portal
    end,

    BackgroundSpiral = function()
        local bg = Image("images/bg_spiral.xml", "bg_spiral.tex")
        bg:SetVRegPoint(ANCHOR_MIDDLE)
        bg:SetHRegPoint(ANCHOR_MIDDLE)
        bg:SetVAnchor(ANCHOR_MIDDLE)
        bg:SetHAnchor(ANCHOR_MIDDLE)
        bg:SetScaleMode(SCALEMODE_FILLSCREEN)
        bg:SetTint(unpack(FRONTEND_PORTAL_COLOUR))

        return bg
    end,

    BackgroundVignette = function()
        local vig = Image("images/bg_vignette.xml", "vignette.tex")
        vig:SetVRegPoint(ANCHOR_MIDDLE)
        vig:SetHRegPoint(ANCHOR_MIDDLE)
        vig:SetVAnchor(ANCHOR_MIDDLE)
        vig:SetHAnchor(ANCHOR_MIDDLE)
        vig:SetScaleMode(SCALEMODE_FILLSCREEN)

        return vig
    end,

    BackgroundTint = function(a, rgb)
        local bg = Image("images/global.xml", "square.tex")
        bg:SetVRegPoint(ANCHOR_MIDDLE)
        bg:SetHRegPoint(ANCHOR_MIDDLE)
        bg:SetVAnchor(ANCHOR_MIDDLE)
        bg:SetHAnchor(ANCHOR_MIDDLE)
        bg:SetScaleMode(SCALEMODE_FILLSCREEN)

		a = a ~= nil and a or 0.75
		rgb = rgb ~= nil and rgb or {0, 0, 0 }

		bg:SetTint(rgb[1], rgb[2], rgb[3], a)

        return bg
    end,

    -------------------------------
    -------------------------------
    -- LEFT/RIGHT SIDE GRADIENTS --
    -------------------------------
    -------------------------------

    -- To be added as a child of the root
    LeftGradient = function()
        local root = Widget("left_gradient_root")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local grad = root:AddChild(Image("images/frontend.xml", "sidemenu_bg.tex"))
        grad:SetVRegPoint(ANCHOR_MIDDLE)
        grad:SetHRegPoint(ANCHOR_LEFT)
        grad:SetPosition(-.5 * RESOLUTION_X, 0)

        return root
    end,

    -- To be added as a child of the root
    RightGradient = function()
        local root = Widget("left_gradient_root")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local grad = root:AddChild(Image("images/frontend.xml", "sidemenu_bg.tex"))
        grad:SetVRegPoint(ANCHOR_MIDDLE)
        grad:SetHRegPoint(ANCHOR_LEFT)
        grad:SetPosition(.5 * RESOLUTION_X, 0)
		grad:SetScale(-1)

        return root
    end,

    ----------------
    ----------------
    -- FOREGROUND --
    ----------------
    ----------------

    -- A dynamic background scene with an animated portal and smoke/mist (and a hook for character placement)
    -- To be added as a child of the screen itself AFTER adding AnimatedPortalBackground.
    AnimatedPortalForeground = function()
        local fg = Widget("foreground")

        if IsSpecialEventActive(SPECIAL_EVENTS.YOTG) and not InGamePlay() then
            fg.perds_back = fg:AddChild(TEMPLATES.ForegroundPerdBack())
            fg.perds_back:SetCanFadeAlpha(false)
        end

        fg.plate = fg:AddChild(TEMPLATES.ForegroundPlate())

        if not InGamePlay() then
            fg.smoke_inside = fg:AddChild(TEMPLATES.ForegroundSmokeInside())
            fg.smoke_west = fg:AddChild(TEMPLATES.ForegroundSmokeWest())
            fg.smoke_east = fg:AddChild(TEMPLATES.ForegroundSmokeEast())
        end

        -- A root widget for placing characters (or anything else you want to place "in" the scene) at the appropriate depth if desired
        fg.character_root = fg:AddChild(Widget("character_root"))
        fg.character_root:SetVAnchor(ANCHOR_MIDDLE)
        fg.character_root:SetHAnchor(ANCHOR_MIDDLE)
        fg.character_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        fg.character_root:Hide()

        if not InGamePlay() then
            fg.smoke_south = fg:AddChild(TEMPLATES.ForegroundSmokeSouth())

            fg.EnableSmoke = function(fg, enable)
                if enable then
                    fg.smoke_inside:Show()
                    fg.smoke_west:Show()
                    fg.smoke_east:Show()
                    fg.smoke_south:Show()
                else
                    fg.smoke_inside:Hide()
                    fg.smoke_west:Hide()
                    fg.smoke_east:Hide()
                    fg.smoke_south:Hide()
                end
                if fg.snowfall ~= nil then
                    fg.snowfall:EnableSnowfall(enable)
                end
            end

            if TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode() then
                fg:EnableSmoke(false)
            end

            if IsSpecialEventActive(SPECIAL_EVENTS.YOTG) then
                fg.perds = fg:AddChild(TEMPLATES.ForegroundPerdFront(fg.perds_back))
                fg.perds:SetCanFadeAlpha(false)
            end
        end

        fg.trees = fg:AddChild(TEMPLATES.ForegroundTrees())
        fg.letterbox = fg:AddChild(TEMPLATES.ForegroundLetterbox())

        fg:SetCanFadeAlpha(false)

        return fg
    end,

    -- A component of the AnimatedPortalForeground
    ForegroundPlate = function()
        local root = Widget("fg_plate_root")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local plate = root:AddChild(Image("images/fg_animated_portal.xml", "fg_plate.tex"))
        plate:SetVRegPoint(ANCHOR_BOTTOM)
        plate:SetHRegPoint(ANCHOR_MIDDLE)
        plate:SetPosition(0, -.5 * RESOLUTION_Y)

        local w = plate:GetSize()
        plate:SetScale(RESOLUTION_X / w)

        return root
    end,

    -- A component of the AnimatedPortalForeground
    ForegroundSmokeWest = function()
        local smoke = UIAnim()
        smoke:GetAnimState():SetBuild("cloud_build")
        smoke:GetAnimState():SetBank("cloudsfx_OL_west")
        smoke:GetAnimState():PlayAnimation("steamfxwest_loop", true)
        smoke:SetScale(.7)
        smoke:SetVAnchor(ANCHOR_MIDDLE)
        smoke:SetHAnchor(ANCHOR_MIDDLE)
        smoke:SetPosition(0,smoke_offset)
        smoke:GetAnimState():SetMultColour(unpack(FRONTEND_SMOKE_COLOUR))

        return smoke
    end,

    -- A component of the AnimatedPortalForeground
    ForegroundSmokeEast = function()
        local smoke = UIAnim()
        smoke:GetAnimState():SetBuild("cloud_build")
        smoke:GetAnimState():SetBank("cloudsfx_OL_east")
        smoke:GetAnimState():PlayAnimation("steamfxeast_loop", true)
        smoke:SetScale(.7)
        smoke:SetVAnchor(ANCHOR_MIDDLE)
        smoke:SetHAnchor(ANCHOR_MIDDLE)
        smoke:SetPosition(0,smoke_offset)
        smoke:GetAnimState():SetMultColour(unpack(FRONTEND_SMOKE_COLOUR))

        return smoke
    end,

    -- A component of the AnimatedPortalForeground
    ForegroundSmokeSouth = function()
        local smoke = UIAnim()
        smoke:GetAnimState():SetBuild("cloud_build")
        smoke:GetAnimState():SetBank("cloudsfx_OL_south")
        smoke:GetAnimState():PlayAnimation("steamfxsouth_loop", true)
        smoke:SetScale(.7)
        smoke:SetVAnchor(ANCHOR_MIDDLE)
        smoke:SetHAnchor(ANCHOR_MIDDLE)
        smoke:SetPosition(0,smoke_offset)
        smoke:GetAnimState():SetMultColour(unpack(FRONTEND_SMOKE_COLOUR))

        return smoke
    end,

    -- A component of the AnimatedPortalForeground
    ForegroundSmokeInside = function()
        local smoke = UIAnim()
        smoke:GetAnimState():SetBuild("portal_scene2_inside")
        smoke:GetAnimState():SetBank("cloudsfx_insideportal")
        smoke:GetAnimState():PlayAnimation("insideportal_idle", true)
        smoke:SetScale(.7)

        return smoke
    end,

    -- A component of the AnimatedPortalForeground
    ForegroundTrees = function()
        local root = Widget("fg_trees_root")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local trees = root:AddChild(Image("images/fg_trees.xml", "trees.tex"))
        trees:SetVRegPoint(ANCHOR_MIDDLE)
        trees:SetHRegPoint(ANCHOR_MIDDLE)
        --V2C: Tint and dirt baked into trees layer now
        --trees:SetTint(unpack(FRONTEND_TREE_COLOUR))
        trees:SetClickable(false)

        local w = trees:GetSize()
        trees:SetScale(RESOLUTION_X / w)

        return root
    end,

    ForegroundLetterbox = function()
        local root = Widget("fg_letterbox_root")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local _scrnw, _scrnh
        local aspect = RESOLUTION_X / RESOLUTION_Y
        local maxw = RESOLUTION_X * MAX_FE_SCALE
        local maxh = RESOLUTION_Y * MAX_FE_SCALE

        root.OnUpdate = function()
            local scrnw, scrnh = TheSim:GetScreenSize()
            if _scrnw == scrnw and _scrnh == scrnh then
                return
            end

            _scrnw = scrnw
            _scrnh = scrnh

            local scrnaspect = scrnw / scrnh
            local hbars = scrnw > maxw or scrnaspect > aspect
            local vbars = scrnh > maxh or scrnaspect < aspect

            if hbars then
                if root.left == nil then
                    root.left = root:AddChild(Image("images/global.xml", "square.tex"))
                    root.left:SetTint(0, 0, 0, 1)
                    root.left:SetVRegPoint(ANCHOR_MIDDLE)
                    root.left:SetHRegPoint(ANCHOR_RIGHT)
                    root.left:SetPosition(-.5 * RESOLUTION_X, 0)
                end
                if root.right == nil then
                    root.right = root:AddChild(Image("images/global.xml", "square.tex"))
                    root.right:SetTint(0, 0, 0, 1)
                    root.right:SetVRegPoint(ANCHOR_MIDDLE)
                    root.right:SetHRegPoint(ANCHOR_LEFT)
                    root.right:SetPosition(.5 * RESOLUTION_X, 0)
                end
            else
                if root.left ~= nil then
                    root.left:Kill()
                    root.left = nil
                end
                if root.right ~= nil then
                    root.right:Kill()
                    root.right = nil
                end
            end
            if vbars then
                if root.top == nil then
                    root.top = root:AddChild(Image("images/global.xml", "square.tex"))
                    root.top:SetTint(0, 0, 0, 1)
                    root.top:SetVRegPoint(ANCHOR_BOTTOM)
                    root.top:SetHRegPoint(ANCHOR_MIDDLE)
                    root.top:SetPosition(0, .5 * RESOLUTION_Y)
                end
                if root.bottom == nil then
                    root.bottom = root:AddChild(Image("images/global.xml", "square.tex"))
                    root.bottom:SetTint(0, 0, 0, 1)
                    root.bottom:SetVRegPoint(ANCHOR_TOP)
                    root.bottom:SetHRegPoint(ANCHOR_MIDDLE)
                    root.bottom:SetPosition(0, -.5 * RESOLUTION_Y)
                end
            else
                if root.top ~= nil then
                    root.top:Kill()
                    root.top = nil
                end
                if root.bottom ~= nil then
                    root.bottom:Kill()
                    root.bottom = nil
                end
            end

            if hbars and vbars then
                local w, h = root.left:GetSize()
                local scalex = (scrnw - maxw) / (maxw * 2) * RESOLUTION_X / w
                local scaley = scrnh / maxh * RESOLUTION_Y / h
                root.left:SetScale(scalex, scaley)
                root.right:SetScale(scalex, scaley)
                scalex = RESOLUTION_X / w
                scaley = (scrnh - maxh) / (maxh * 2) * RESOLUTION_Y / h
                root.top:SetScale(scalex, scaley)
                root.bottom:SetScale(scalex, scaley)
            elseif hbars then
                local w, h = root.left:GetSize()
                local scalex = (scrnw / (scrnh * aspect) - 1) * .5 * RESOLUTION_X / w
                local scaley = RESOLUTION_Y / h
                root.left:SetScale(scalex, scaley)
                root.right:SetScale(scalex, scaley)
            elseif vbars then
                local w, h = root.top:GetSize()
                local scalex = RESOLUTION_X / w
                local scaley = (scrnh * aspect / scrnw - 1) * .5 * RESOLUTION_Y / h
                root.top:SetScale(scalex, scaley)
                root.bottom:SetScale(scalex, scaley)
            end
        end

        root:StartUpdating()
        root:OnUpdate()

        return root
    end,

    -------------
    -------------
    -- FE Perd --
    -------------
    -------------
    -- Main menu perd for event
    ForegroundPerdFront = function(back)
        local root = Widget("fg_perd_front")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        local perd = root:AddChild(UIAnim())
        perd:GetAnimState():SetBuild("frontend_perd")
        perd:GetAnimState():SetBank("frontend_perd")
        perd:GetAnimState():Hide("back")
        perd:GetAnimState():PlayAnimation("empty")

        --V2C: Source anim was done on a 1820 x 1024 stage
        perd:SetScale(RESOLUTION_Y / 1024)

        local spawntask = nil
        local runtask = nil
        local anims = { 2, 3, 4 }

        local function DoRunSound(_, period, remaining)
            TheFrontEnd:GetSound():PlaySound("dontstarve/creatures/perd/run")
            runtask = remaining > 1 and perd.inst:DoTaskInTime(period, DoRunSound, period, remaining - 1) or nil
        end

        local function OnSpawnPerd()
            local anim = #anims > 3 and table.remove(anims, math.random(2)) or 1
            table.insert(anims, anim)
            if runtask ~= nil then
                runtask:Cancel()
                runtask = nil
            end
            if anim == 1 then
                perd:GetAnimState():PlayAnimation("perd1_fe")
                TheFrontEnd:GetSound():PlaySound("dontstarve/creatures/perd/gobble")
            elseif anim == 2 then
                back.perd:GetAnimState():PlayAnimation("perd2_fe")
                DoRunSound(nil, 16 * FRAMES, 5)
            elseif anim == 3 then
                back.perd:GetAnimState():PlayAnimation("perd3_fe")
                TheFrontEnd:GetSound():PlaySound("dontstarve/creatures/perd/scream")
            else
                perd:GetAnimState():PlayAnimation("perd4_fe")
                back.perd:GetAnimState():PlayAnimation("perd4_fe")
                DoRunSound(nil, 16 * FRAMES, 4)
            end
            spawntask = perd.inst:DoTaskInTime(4.5 + math.random() * 1.5, OnSpawnPerd)
        end

        root.StartPerds = function()
            if spawntask == nil then
                spawntask = perd.inst:DoTaskInTime(4, OnSpawnPerd)
                root:Show()
                back:Show()
            end
        end

        root.StopPerds = function()
            if spawntask ~= nil then
                spawntask:Cancel()
                spawntask = nil
                perd:GetAnimState():PlayAnimation("empty")
                back.perd:GetAnimState():PlayAnimation("empty")
                root:Hide()
                back:Hide()
            end
            if runtask ~= nil then
                runtask:Cancel()
                runtask = nil
            end
        end

        root:Hide()
        back:Hide()

        return root
    end,

    ForegroundPerdBack = function()
        local root = Widget("fg_perd_back")
        root:SetVAnchor(ANCHOR_MIDDLE)
        root:SetHAnchor(ANCHOR_MIDDLE)
        root:SetScaleMode(SCALEMODE_PROPORTIONAL)

        root.perd = root:AddChild(UIAnim())
        root.perd:GetAnimState():SetBuild("frontend_perd")
        root.perd:GetAnimState():SetBank("frontend_perd")
        root.perd:GetAnimState():Hide("front")
        root.perd:GetAnimState():PlayAnimation("empty")

        --V2C: Source anim was done on a 1820 x 1024 stage
        root.perd:SetScale(RESOLUTION_Y / 1024)

        return root
    end,

    -------------------
    -------------------
    -- PANELS/FRAMES --
    -------------------
    -------------------

    -- Ornate black frame, no fill (nine-slice)
    CurlyWindow = function(sizeX, sizeY, scaleX, scaleY, topCrownOffset, bottomCrownOffset, xOffset)
        local w = NineSlice("images/fepanels.xml",
                "TopLeft.tex", "TopCenter.tex", "TopRight.tex",
                "MiddleLeft.tex", "CenterMiddle.tex", "MiddleRight.tex",
                "BottomLeft.tex", "BottomCenter.tex", "BottomRight.tex")
        w:AddCrown("TopCap.tex", ANCHOR_MIDDLE, ANCHOR_TOP, xOffset or 0, topCrownOffset or 68)
        w:AddCrown("BottomCap.tex", ANCHOR_MIDDLE, ANCHOR_BOTTOM, xOffset or 0, bottomCrownOffset or -42)
        w:SetSize(sizeX or 200, sizeY or 200)
        w:SetScale(scaleX or 1, scaleY or 1)
        return w
    end,

    -- Ornate black frame with paper texture fill (nine-slice)
    -- To be added as a child of the root
    CenterPanel = function(frame_x_scale, frame_y_scale, skipPos, x_size, y_size, topCrownOffset, bottomCrownOffset, bg_x_scale, bg_y_scale, bg_x_pos, bg_y_pos )
    	frame_x_scale = frame_x_scale or 1
    	frame_y_scale = frame_y_scale or 1
        local panel = Widget("panel")

        panel.frame = panel:AddChild(NineSlice("images/fepanels.xml",
                "TopLeft.tex", "TopCenter.tex", "TopRight.tex",
                "MiddleLeft.tex", "CenterMiddle.tex", "MiddleRight.tex",
                "BottomLeft.tex", "BottomCenter.tex", "BottomRight.tex"))
        panel.frame:AddCrown("TopCap.tex", ANCHOR_MIDDLE, ANCHOR_TOP, 0, topCrownOffset or 68)
        panel.frame:AddCrown("BottomCap.tex", ANCHOR_MIDDLE, ANCHOR_BOTTOM, 0, bottomCrownOffset or -42)
        panel.frame:SetSize( x_size or 520, y_size or 475)
        panel.frame:SetScale(frame_x_scale or 1, frame_y_scale or 1)
        panel.frame:SetPosition(0, 0)

		panel.bg = panel.frame:AddChild(Image("images/options_bg.xml", "options_panel_bg.tex"))
		panel.bg:SetPosition( bg_x_pos or 9, bg_y_pos or 13)
        panel.bg:SetScale(bg_x_scale or .725, bg_y_scale or .69)

        if not skipPos then
            panel:SetPosition(37,-10)
        end

		return panel
    end,

    -- Ornate black frame with paper texture fill
    -- The old version that didn't use the 9-slice
    CenterPanelOld = function(x_scale, y_scale, skipPos)
    	local xScale = x_scale or .67
    	local yScale = y_scale or .65
        local panel = Widget("panel")

    	panel.frame = panel:AddChild(Image( "images/options_bg.xml", "options_panel_bg_frame.tex" ))
		panel.frame:SetScale( xScale, yScale )
		panel.frame:SetPosition(0, 0)

        xScale = x_scale or .69
        yScale = y_scale or .65
		panel.bg = panel:AddChild(Image("images/options_bg.xml", "options_panel_bg.tex"))
		panel.bg:SetPosition(0, 0)
        panel.bg:SetScale(xScale, yScale)

        if not skipPos then
            panel:SetPosition(25,-10)
        end

		return panel
    end,


    ----------------
    ----------------
    -- NAVIGATION --
    ----------------
    ----------------

    -- Makes the background for holding NavBarButtons and puts a screen title above it
    -- To be added as a child of the root. Heights: "short" (2 buttons), "medium" (3 buttons), "tall" (5 buttons).
    NavBarWithScreenTitle = function(title, height)
        local nav_bar = Widget("nav_bar")
        nav_bar:SetPosition(-RESOLUTION_X*.415, RESOLUTION_Y*.27)

        if not height or height == "short" then
            nav_bar.bg = nav_bar:AddChild(Image("images/frontend.xml", "nav_bg_short.tex"))
            nav_bar.bg:SetScale(.65, .7)
        elseif height == "medium" then
        	nav_bar.bg = nav_bar:AddChild(Image("images/frontend.xml", "nav_bg_short.tex"))
            nav_bar.bg:SetScale(.65, 1)
        elseif height == "tall" then
            nav_bar.bg = nav_bar:AddChild(Image("images/frontend.xml", "nav_bg_med.tex"))
            nav_bar.bg:SetScale(.65, .475)
            nav_bar.bg:SetPosition(0, -RESOLUTION_Y*.145)
        end

        if title then
            nav_bar.title = nav_bar:AddChild(Text(TITLEFONT, 45, title or ""))
            nav_bar.title:SetRegionSize(200, 50)
            nav_bar.title:SetHAlign(ANCHOR_LEFT)
            nav_bar.title:SetPosition(40,100)
        end

        return nav_bar
    end,

    -- To be added as a child of the Nav Bar. Approximate spacing in Y for these buttons is 45-50.
    NavBarButton = function(yPos, buttonText, onclick, truncate)
        local btn = Button()
        btn:SetPosition(10, yPos)

        btn:SetFont(NEWFONT)
        btn:SetDisabledFont(NEWFONT)
        btn:SetTextSize(35)

        if truncate then
            btn:SetText("")
            btn.text:SetTruncatedString(buttonText, 140, 28, true)
        else
            btn:SetText(buttonText)
        end
        btn.text:SetRegionSize(140, 40)
        btn.text:SetHAlign(ANCHOR_LEFT)

        btn:SetTextColour(unpack(GOLD))
        btn:SetTextFocusColour(unpack(GOLD))
        btn:SetTextSelectedColour(0, 0, 0, 1)

        btn.active_page_image = btn:AddChild(Image("images/frontend.xml", "nav_selected2.tex"))
        btn.active_page_image:SetPosition(-7, -6)
        btn.active_page_image:SetScale(.56, .65)
        btn.active_page_image:SetClickable(false)
        btn.active_page_image:MoveToBack()
        btn.active_page_image:Hide()

        btn.focus_image = btn:AddChild(Image("images/frontend.xml", "nav_cursor.tex"))
        btn.focus_image:SetScale(.65)
        btn.focus_image:SetPosition(-85,0)
        btn.focus_image:SetClickable(false)
        btn.focus_image:Hide()

        btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
        local w,h = btn.text:GetRegionSize()
        btn.bg:ScaleToSize(200, h+15)

        btn:SetOnGainFocus(function()
            btn.focus_image:Show()
        end)
        btn:SetOnLoseFocus(function()
            btn.focus_image:Hide()
        end)

        btn:SetOnSelect(function()
            btn.active_page_image:Show()
        end)
        btn:SetOnUnSelect(function()
            btn.active_page_image:Hide()
        end)

        btn:SetOnClick(onclick)

        return btn
    end,

    ----------------
    ----------------
    -- TAB BUTTON --
    ----------------
    ----------------
    -- To be added as a child of the panel with tabs.
    TabButton = function(xPos, yPos, buttonText, onclick, tabSize)
        local btn
        if not tabSize or tabSize == "large" then
            btn = ImageButton("images/frontend.xml", "tab1_button.tex", "tab1_button_highlight.tex", "tab1_selected.tex", nil, nil, {1,1}, {0,0})
        elseif tabSize == "small" then
            btn = ImageButton("images/frontend.xml", "tab2_button.tex", "tab2_button_highlight.tex", "tab2_selected.tex", nil, nil, {1,1}, {0,0})
        end
        btn:SetPosition(xPos, yPos)

        btn.image:SetScale(.73)
        btn.scale_on_focus = false

        btn:SetText(buttonText)
        btn:SetFont(NEWFONT_OUTLINE)
        btn:SetDisabledFont(NEWFONT_SMALL)
        btn:SetTextColour(unpack(GOLD))
        btn:SetTextFocusColour(unpack(GOLD))
        btn:SetTextDisabledColour(0,0,0,1)
        btn:SetTextSize(30)
        btn.text:SetPosition(2,7)

        btn:SetOnClick(onclick)

        return btn
    end,

    -----------------
    -----------------
    -- BACK BUTTON --
    -----------------
    -----------------
    -- To be added as a child of the root. onclick should be whatever cancel/back fn is appropriate for your screen.
    BackButton = function(onclick, txt, txt_offset, shadow_offset, scale)
        local btn = ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil, nil, nil, {1,1}, {0,0})
        btn:SetPosition(-RESOLUTION_X*.4 - 10, -RESOLUTION_Y*.5 + BACK_BUTTON_Y)

        btn.scale = scale or 1

        btn.image:SetPosition(-63, 0)
        btn.image:SetScale(.7)

        btn:SetText(txt or STRINGS.UI.SERVERLISTINGSCREEN.BACK, true, { shadow_offset and shadow_offset.x or 2, shadow_offset and shadow_offset.y or -1})
        if txt_offset then
            local textPos = btn.text:GetPosition()
        	btn.text:SetPosition(textPos.x + txt_offset.x, textPos.y + txt_offset.y)
            local textShadowPos = btn.text_shadow:GetPosition()
        	btn.text_shadow:SetPosition(textShadowPos.x + txt_offset.x, textShadowPos.y + txt_offset.y)
        end
        btn:SetTextColour(unpack(GOLD))
        btn:SetTextFocusColour(unpack(PORTAL_TEXT_COLOUR))
        btn:SetFont(NEWFONT_OUTLINE)
        btn:SetDisabledFont(NEWFONT_OUTLINE)
        btn:SetTextDisabledColour(unpack(GOLD))

        btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
        local w,h = btn.text:GetRegionSize()
        btn.bg:ScaleToSize(w+50, h+15)
        if txt_offset then
            btn.bg:SetPosition(txt_offset.x, txt_offset.y)
        end

        btn:SetOnGainFocus(function()
            btn:SetScale(btn.scale + .05)
        end)
        btn:SetOnLoseFocus(function()
            btn:SetScale(btn.scale)
        end)

        btn:SetOnClick(onclick)

        btn:SetScale(btn.scale)

        return btn
    end,

    -------------------------
    -------------------------
    -- SERVER DETAIL IMAGE --
    -------------------------
    -------------------------
    ServerDetailIcon = function(iconAtlas, iconTexture, bgColor, hoverText, textinfo, imgOffset, scaleX, scaleY)
        local icon = Widget("detail_icon")
        icon.bg = icon:AddChild(Image("images/servericons.xml", bgColor and "bg_"..bgColor..".tex" or "bg_burnt.tex"))
        icon.bg:SetScale(.09)
        icon.img = icon:AddChild(Image(iconAtlas, iconTexture))
        icon.img:SetScale(scaleX or .075, scaleY or .075)
        icon.img:SetPosition(imgOffset and imgOffset[1] or -1, imgOffset and imgOffset[2] or 0)

        if hoverText and hoverText ~= "" then
            if not textinfo then textinfo = {} end
            icon:SetHoverText(hoverText, { font = textinfo.font or NEWFONT_OUTLINE, offset_x = 1, offset_y = 28, colour = textinfo.colour or {1,1,1,1}, bg = textinfo.bg })
        end

        return icon
    end,

    -----------------
    -----------------
    -- INVISIBLE BUTTON --
    -----------------
    -----------------

    InvisibleButton = function(width, height, onclick, onfocus)
    	local btn = ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", "blank.tex", "blank.tex", {width,height}, {0,0})
    	btn:SetFocusScale(width, height)
    	btn:SetNormalScale(width, height)
        btn:SetOnClick(onclick)

        btn.ongainfocus = onfocus

        return btn
    end,

    -----------------
    -----------------
    -- ICON BUTTON --
    -----------------
    -----------------
    -- For making a square button that has a custom icon on it and has a text label
    -- Text label offset can be specified, as well as whether or not it always shows
    IconButton = function(iconAtlas, iconTexture, labelText, sideLabel, alwaysShowLabel, onclick, textinfo, defaultTexture)
        local btn = ImageButton("images/frontend.xml", "button_square.tex", "button_square_halfshadow.tex", "button_square_disabled.tex", "button_square_halfshadow.tex", "button_square_disabled.tex", {1,1}, {0,0})
        btn.image:SetScale(.7)

        btn.icon = btn:AddChild(Image(iconAtlas, iconTexture, defaultTexture))
        btn.icon:SetPosition(-5,4)
        btn.icon:SetScale(.16)
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
            btn:SetHoverText(labelText, { font = textinfo.font or NEWFONT_OUTLINE, offset_x = textinfo.offset_x or -4, offset_y = textinfo.offset_y or 45, colour = textinfo.colour or {1,1,1,1}, bg = textinfo.bg })
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
    end,

 	------------
    ------------
    -- BUTTON --
    ------------
    ------------
    -- To be used anywhere you need a button.
    Button = function (text, cb)
	    local btn = ImageButton()
	    btn.image:SetScale(.7)
	    btn:SetFont(NEWFONT)
	    btn:SetDisabledFont(NEWFONT)

	    btn:SetText(text)
	    btn:SetOnClick(cb)

	    return btn
	end,


	------------
    ------------
    -- SmallBUTTON --
    ------------
    ------------
    -- A button with configurable size. It defaults to smaller than Button.
    SmallButton = function (text, fontsize, scale, cb)
	    local btn = ImageButton()
	    btn.image:SetScale(scale or .5)
	    btn:SetFont(NEWFONT)
	    btn:SetTextSize(fontsize or 26)
	    btn:SetDisabledFont(NEWFONT)

	    btn:SetText(text)
	    btn:SetOnClick(cb)

	    return btn
	end,

	------------
    ------------
    -- AnimTextButton --
    ------------
    ------------
    -- A button that uses an animation file and has text on top of the image.
    AnimTextButton = function (animname, states, scale, cb, text, size)

    	local button = AnimButton(animname, states)
    	button:SetScale(scale)
    	button:SetOnClick(cb)

   		button:SetFont(NEWFONT_OUTLINE)
    	button:SetTextSize(size or 24)
    	button:SetText(text)
    	button:SetTextColour(1, 1, 1, 1)
    	button:SetTextSelectedColour(1, 1, 1, 1)
    	button:SetTextFocusColour(1, 1, 1, 1)

   		return button
    end,


	------------
    ------------
    -- TextMenuItem --
    ------------
    ------------
    -- Text with a background beind it. For use in right click menus and similar.
	TextMenuItem = function(text, onClickFn)
		local item = Widget("item")

		item.text = item:AddChild(Text(NEWFONT, 24, text, WHITE))

		item.bg = item:AddChild(Image("images/frontend.xml", "scribble_black.tex"))
        item.bg:SetPosition(0, 0)
        local w, h = item.text:GetRegionSize()
        item.bg:SetTint(1,1,1,.8)
        item.bg:SetSize(w*1.3, h*1.8)
        item.bg:MoveToBack()
        item.bg:SetClickable(true)

    	item.OnControl = function(control, down)
    		if down and onClickFn then
    			onClickFn()
    		end
    	end

    	item.GetSize = function()
    		return item.bg:GetSize()
    	end


    	return item
	end,


	-----------------
    -----------------
    -- ModListItem --
    -----------------
    -----------------
    -- A widget that displays info about a mod. To be used in scroll lists etc.
	ModListItem = function (modname, modinfo, modstatus, isenabled)

		local opt = Widget("option")
		-- opt:SetScale(.9,.95)
        opt.clickoffset = Vector3(0,-3,0)

		opt.white_bg = opt:AddChild(Image("images/ui.xml", "single_option_bg_large.tex"))
		opt.white_bg:SetScale(.63, .9)

        opt.state_bg = opt:AddChild(Image("images/ui.xml", "single_option_bg_large_gold.tex"))
        opt.state_bg:SetScale(.63, .9)
        opt.state_bg:Hide()

		opt.checkbox = opt:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {0,0}))
		opt.checkbox:SetPosition(140, -22, 0)

		opt.image = opt:AddChild(Image("images/ui.xml", "portrait_bg.tex"))
		--opt.image:SetScale(imscale,imscale,imscale)
		opt.image:SetPosition(-120,0,0)
		if modinfo and modinfo.icon_atlas and modinfo.icon then
			opt.image:SetTexture(modinfo.icon_atlas, modinfo.icon)
		end
		opt.image:SetSize(70,70)

        opt.out_of_date_image = opt:AddChild(Image("images/frontend.xml", "circle_red.tex"))
        opt.out_of_date_image:SetScale(.65)
        opt.out_of_date_image:SetPosition(65, -22)
        opt.out_of_date_image:SetClickable(false)
        opt.out_of_date_image.icon = opt.out_of_date_image:AddChild(Image("images/button_icons.xml", "update.tex"))
        opt.out_of_date_image.icon:SetPosition(-1,0)
        opt.out_of_date_image.icon:SetScale(.15)
        opt.out_of_date_image:Hide()

        opt.configurable_image = opt:AddChild(Image("images/button_icons.xml", "configure_mod.tex"))
        opt.configurable_image:SetScale(.1)
        opt.configurable_image:SetPosition(100, -20)
        opt.configurable_image:SetClickable(false)
        opt.configurable_image:Hide()

        opt.name = opt:AddChild(Text(NEWFONT, 30))
        local nameStr = (modinfo and modinfo.name) and modinfo.name or modname
        opt.name:SetTruncatedString(nameStr, 235, 51, true)
        local w, h = opt.name:GetRegionSize()
        opt.name:SetPosition(w * .5 - 75, 17, 0)
        opt.name:SetVAlign(ANCHOR_MIDDLE)
        opt.name:SetColour(0,0,0,1)

		opt.status = opt:AddChild(Text(BODYTEXTFONT, 23))
		opt.status:SetVAlign(ANCHOR_MIDDLE)
		opt.status:SetHAlign(ANCHOR_LEFT)
		opt.status:SetString(modname)

		if modstatus == "WORKING_NORMALLY" then
            opt.status:SetColour(59/255,  222/255, 99/255,1)
			opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WORKING_NORMALLY)
		elseif modstatus == "DISABLED_ERROR" then
			opt.status:SetColour(242/255, 99/255, 99/255, 1)--0.9,0.3,0.3,1)
			opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_ERROR)
		elseif modstatus == "DISABLED_MANUAL" then
			opt.status:SetColour(.6,.6,.6,1)
			opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_MANUAL)
		end
		opt.status:SetPosition(25, -20, 0)
		opt.status:SetRegionSize( 200, 50 )

		if isenabled then
			opt.image:SetTint(1,1,1,1)
			opt.checkbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {0,0})
		else
			opt.image:SetTint(1.0,0.5,0.5,1)
			opt.checkbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {0,0})
		end

		return opt
	end,

	-------------------
    -------------------
    -- ModDLListItem --
    -------------------
    -------------------
    -- A widget that displays a mod that is currently being downloaded.
	ModDLListItem = function (modname)
		local opt = Widget("option")
		opt:SetScale(.9,.9)

		opt.white_bg = opt:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
		opt.white_bg:SetScale(.7, 2.1)

		opt.name = opt:AddChild(Text(NEWFONT, 35))
		opt.name:SetVAlign(ANCHOR_MIDDLE)
		opt.name:SetHAlign(ANCHOR_MIDDLE)
		opt.name:SetString("Downloading:\n" .. modname)
		opt.name:SetColour(0,0,0,1)
		opt.name:SetRegionSize( 330, 100 )

		return opt
	end,


    -------------------
    -------------------
    -- Label Textbox --
    -------------------
    -------------------
    -- Text box with a label beside it
    LabelTextbox = function(labeltext, fieldtext, width_label, width_field, height, spacing, font, font_size, horiz_offset)
        local textbox_font_ratio = 0.8
        local offset = horiz_offset or 0
        local total_width = width_label + width_field + spacing
        local wdg = Widget("labeltextbox")
        wdg.label = wdg:AddChild(Text(font or NEWFONT, font_size or 25))
        wdg.label:SetString(labeltext)
        wdg.label:SetHAlign(ANCHOR_RIGHT)
        wdg.label:SetRegionSize(width_label,height)
        wdg.label:SetPosition((-total_width/2)+(width_label/2)+offset,0)
        wdg.label:SetColour(0,0,0,1)
        wdg.textbox_bg = wdg:AddChild( Image("images/textboxes.xml", "textbox2_grey.tex") )
        wdg.textbox_bg:SetPosition((total_width/2)-(width_field/2)+offset, 0)
        wdg.textbox_bg:ScaleToSize(width_field, height)
        wdg.textbox = wdg:AddChild(TextEdit( font or NEWFONT, (font_size or 25)*textbox_font_ratio, fieldtext, {0,0,0,1} ) )
        wdg.textbox:SetForceEdit(true)
        wdg.textbox:SetPosition((total_width/2)-(width_field/2)+offset, 0)
        wdg.textbox:SetRegionSize(width_field-30, height) -- this needs to be slightly narrower than the BG because we don't have margins
        wdg.textbox:SetHAlign(ANCHOR_LEFT)
        wdg.textbox:SetFocusedImage( wdg.textbox_bg, "images/textboxes.xml", "textbox2_grey.tex", "textbox2_gold.tex", "textbox2_gold_greyfill.tex" )

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
        global("TheWidget")
        TheWidget = wdg

        return wdg
    end,

    -------------------
    -------------------
    -- Label Spinner --
    -------------------
    -------------------
    -- Spinner with a label beside it
    LabelSpinner = function(labeltext, spinnerdata, width_label, width_spinner, height, spacing, font, font_size, horiz_offset)
        local offset = horiz_offset or 0
        local total_width = width_label + width_spinner + spacing
        local wdg = Widget("labelspinner")
        wdg.label = wdg:AddChild( Text(font or NEWFONT, font_size or 25, labeltext) )
        wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
        wdg.label:SetRegionSize( width_label, height )
        wdg.label:SetHAlign( ANCHOR_RIGHT )
        wdg.label:SetColour(0,0,0,1)
        wdg.spinner = wdg:AddChild(Spinner(spinnerdata, width_spinner, height, {font = font or NEWFONT, size = font_size or 25}, nil, nil, nil, true, nil, nil, 1, 1))
        wdg.spinner:SetPosition((total_width/2)-(width_spinner/2) + offset, 0)
        wdg.spinner:SetTextColour(0,0,0,1)

        wdg.focus_forward = wdg.spinner

        return wdg
    end,

    ------------------
    ------------------
    -- Label Button --
    ------------------
    ------------------
    -- Button with a label beside it
    LabelButton = function(labeltext, buttontext, width_label, width_button, height, spacing, font, font_size, horiz_offset)
        local offset = horiz_offset or 0
        local total_width = width_label + width_button + spacing
        local wdg = Widget("labelbutton")
        wdg.label = wdg:AddChild( Text(font or NEWFONT, font_size or 25, labeltext) )
        wdg.label:SetPosition( (-total_width/2)+(width_label/2) + offset, 0 )
        wdg.label:SetRegionSize( width_label, height )
        wdg.label:SetHAlign( ANCHOR_RIGHT )
        wdg.label:SetColour(0,0,0,1)
        wdg.button = wdg:AddChild(ImageButton("images/ui.xml", "in-window_button_sm_idle.tex", "in-window_button_sm_hl.tex", "in-window_button_sm_disabled.tex", "in-window_button_sm_hl_noshadow.tex", "in-window_button_sm_disabled.tex", {1, 1}, {0, 0}))
        wdg.button.text:SetFont(font or NEWFONT)
        wdg.button.text:SetSize(font_size or 25)
        wdg.button:SetText(buttontext)
        wdg.button.text:SetPosition(2,2)
        wdg.button.text:SetColour(0,0,0,1)
        wdg.button:ForceImageSize( width_button, height )
        wdg.button:SetPosition((total_width/2)-(width_button/2) + offset, 0)

        wdg.focus_forward = wdg.button

        return wdg
    end,

    ----------------------
    ----------------------
    -- Moving Item --
    -----------------------
    -----------------------
    -- An item image for the inventory screens that moves
    MovingItem = function(name, slot_index, src_pos, dest_pos, start_scale, end_scale)

        local widg = UIAnim()

        widg.name = name

		widg.target_slot_index = slot_index

        widg:GetAnimState():SetBuild("frames_comp") -- use the animation file as the build, then override it
        widg:GetAnimState():SetBank("frames_comp") -- top level symbol from frames_comp

        local rarity = GetRarityForItem(name)

        widg:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(name), "SWAP_ICON")
        widg:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(rarity))

        widg:GetAnimState():PlayAnimation("idle_on", true)
        widg:GetAnimState():Hide("NEW")

        widg:Hide()

        --print("SETTING UP MOVING ITEM ", name, src_pos, dest_pos, debugstack())
        local move_time = 0.3 -- .3 is the time used for moving items into inventory in game
        widg.Move = function(callbackfn)
                        widg.moving = true
                        widg:SetScale(start_scale or 1)
                        widg:Show()
                        widg:ScaleTo(start_scale or 1, end_scale or 1, move_time)
                        widg:MoveTo(src_pos, dest_pos, move_time,
                        function()
                            widg:Kill()

                            if callbackfn then
                                callbackfn()
                            end
                        end)
                    end
        return widg
    end,


    ----------------------
    ----------------------
    -- ItemImageText --
    -----------------------
    -----------------------
    -- An item image with text to the right of it.
    ItemImageText = function(type, name, iconScale, font, textsize, string, colour, textwidth, image_offset)
        textwidth = textwidth or 50

        local widg = Widget("ImageText")

        widg.icon = widg:AddChild(ItemImage(nil, type, name, nil, nil, nil))
        widg.icon:SetScale(iconScale)
        widg.icon:Disable() -- shouldn't be clickable
        widg.icon:SetPosition(0, 0)

        widg.check = widg.icon:AddChild(Image("images/ui.xml", "checkmark.tex"))
        widg.check:SetScale(.33)
        widg.check:SetPosition(-75, 0)
        widg.check:Hide()


        widg.text = widg:AddChild(Text(font or BUTTONFONT, textsize or 35,
                                        string or "", colour or BLACK))

        widg.text:SetRegionSize(textwidth, 40)

        local text_offset = image_offset or 20
        widg.text:SetPosition(text_offset + .5*textwidth, -2)
        widg.text:SetHAlign( ANCHOR_LEFT )


        widg.SetChecked = function(self, value)
            if value then
                self.check:Show()
            else
                self.check:Hide()
            end
        end

        return widg
    end,

    --------------
    --------------
    -- Snowfall --
    --------------
    --------------
    -- Main menu snowfall
    Snowfall = function(fade_y_threshold, snowflake_chance, max_snowball_size, max_snowflake_size)
		-- defaults
		snowflake_chance = snowflake_chance or 0.5
		max_snowball_size = max_snowball_size or 5
		max_snowflake_size = max_snowflake_size or 20

        local num_wintersnow = 4
        local num_specialsnow = 5
        local padding = max_snowflake_size * .5
        local remove_y_threshold = -RESOLUTION_Y - padding
        local superprettycounter = math.random(20, 30)
        local snowflake_pool = {}

        local function OnUpdateSnowflake(snowflake, dt)
            local pos = snowflake:GetPosition()
            if pos.y > remove_y_threshold then
                if pos.y < fade_y_threshold then
                    snowflake.alpha = snowflake.alpha - .022
                    if snowflake.alpha <= 0 then
                        snowflake:Recycle()
                        return
                    end
                    snowflake:SetTint(1, 1, 1, snowflake.alpha)
                end
                snowflake.xt = snowflake.xt + dt
                pos.x = snowflake.x0 + math.sin(snowflake.xt * snowflake.xtspeed) * snowflake.xdist + snowflake.xwindspeed * snowflake.xt
                if pos.x < -.5 * (RESOLUTION_X + max_snowflake_size) then
                    pos.x = pos.x + RESOLUTION_X + max_snowflake_size
                end
                snowflake:UpdatePosition(pos.x, pos.y - snowflake.speed)
                if snowflake.rotspeed ~= 0 then
                    snowflake.rot = snowflake.rot + snowflake.rotspeed
                    snowflake:SetRotation(snowflake.rot)
                end
            else
                snowflake:Recycle()
            end
        end

        local function RecycleSnowflake(snowflake)
            if not snowflake.recycled then
                table.insert(snowflake_pool, snowflake)
                snowflake.recycled = true
                snowflake:Hide()
                snowflake:StopUpdating()
            end
        end

        local function CreateSnowFlake(x, y)
            local snowflake = #snowflake_pool > 0 and table.remove(snowflake_pool) or Image()
            local ispretty = math.random() < .1
            if not ispretty then
                snowflake:SetTexture("images/frontscreen.xml", "snow.tex")
            elseif superprettycounter > 1 then
                superprettycounter = superprettycounter - 1
                snowflake:SetTexture("images/frontscreen.xml", "wintersnow"..tostring(math.random(num_wintersnow))..".tex")
            else
                superprettycounter = math.random(20, 30)
                snowflake:SetTexture("images/frontscreen.xml", "specialsnow"..tostring(math.random(num_specialsnow))..".tex")
            end

            snowflake.size = math.random()
            snowflake.size = (1 + snowflake.size * snowflake.size) * (ispretty and max_snowflake_size or max_snowball_size)
            snowflake.alpha = .4 + math.random() * .7
            snowflake.speed = math.random()
            snowflake.speed = .5 + snowflake.speed * snowflake.speed * 1.5
            snowflake.rot = 0
            snowflake.rotspeed = ispretty and (.5 + math.random() * .5) * (math.random() < .5 and 1 or -1) or 0
            snowflake.xtspeed = .5 + math.random()
            snowflake.xt = math.random() * snowflake.xtspeed
            snowflake.xdist = math.random()
            snowflake.xdist = snowflake.xdist * snowflake.xdist * 50
            snowflake.xwindspeed = -50 - 20 * math.random()
            snowflake.x0 = x

            if snowflake.recycled then
                snowflake.recycled = false
                snowflake:Show()
            else
                snowflake.OnUpdate = OnUpdateSnowflake
                snowflake.Recycle = RecycleSnowflake
                snowflake:SetClickable(false)
            end

            snowflake:SetPosition(x, y)
            snowflake:SetSize(snowflake.size, snowflake.size)
            snowflake:SetTint(1, 1, 1, snowflake.alpha)
            snowflake:StartUpdating()

            return snowflake
        end

        local widg = Widget("Snowfall")
        widg.OnUpdate = function(widg)
            if math.random() < snowflake_chance then
                widg:AddChild(CreateSnowFlake((math.random() - .5) * (RESOLUTION_X + max_snowflake_size), padding))
            end
        end
        widg.EnableSnowfall = function(widg, enable)
            widg._disabled = not enable
            if not enable then
                widg:StopUpdating()
                widg:KillAllChildren()
            elseif widg._started then
                widg:StartUpdating()
                for k, v in pairs(widg.children) do
                    if not v.recycled then
                        v:StartUpdating()
                    end
                end
            end
        end
        widg.StartSnowfall = function(widg)
            widg._started = true
            if not widg._disabled then
                widg:StartUpdating()
                for k, v in pairs(widg.children) do
                    if not v.recycled then
                        v:StartUpdating()
                    end
                end
            end
        end
        widg.StopSnowfall = function(widg)
            widg._started = false
            widg:StopUpdating()
            for k, v in pairs(widg.children) do
                v:StopUpdating()
            end
        end

        if TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode() then
            widg:EnableSnowfall(false)
        end

        return widg
    end,

}

return TEMPLATES
