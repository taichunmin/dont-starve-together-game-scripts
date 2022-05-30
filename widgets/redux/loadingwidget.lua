local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ShadowedText = require "widgets/redux/shadowedtext"
local TEMPLATES = require "widgets/redux/templates"

local TIP_CYCLE_DELAY = 0.5

require("prefabs/event_deps")
local legacy_images = LOADING_IMAGES[WORLD_SPECIAL_EVENT] or LOADING_IMAGES[SPECIAL_EVENTS.NONE]

local function GetRandomIndex(session_random_index, maxval)
    if session_random_index and 0 < session_random_index and session_random_index <= maxval then
        -- The list of images may have changed in content or size from our
        -- initial run. Only use session value if it fits.
        return session_random_index
    elseif maxval > 0 then
        return math.random(maxval)
    else
        -- Store an invalid index if we don't have table entries to index into.
        -- We never have loading_screen_keys on startup because we haven't yet
        -- loaded the profile.
        return session_random_index
    end
end

local LoadingWidget = Class(Widget, function(self, session_random_index)
    Widget._ctor(self, "LoadingWidget")

    self.global_widget = true

    local image_keys = Settings.loading_screen_keys or {}

    self.forceShowNextFrame = false
    self.is_enabled = false
    self.image_random = GetRandomIndex(session_random_index, #image_keys)
    self:Hide()

    -- classic
    self.root_classic = self:AddChild(Widget("classic_root"))
    self.root_classic:Hide()
    self.vig = self.root_classic:AddChild(TEMPLATES.old.BackgroundVignette())

    self.selected_key = image_keys[self.image_random or -1]
    if self.selected_key then
        self.bg = self:AddChild(TEMPLATES.LoaderBackground(self.selected_key))
    else
        -- Initial startup or user didn't select any backgrounds. Use the
        -- legacy style.
        local random_idx = -(self.image_random or 0)
        local selected_key = legacy_images[random_idx]
        if selected_key == nil then
            random_idx = math.random(#legacy_images)
            selected_key = legacy_images[random_idx]
            self.image_random = -random_idx
            self.selected_key = random_idx
        end
        if selected_key.spiral then
            self.bg = self:AddChild(TEMPLATES.old.BackgroundSpiral())
        end
        self.legacy_fg = self.root_classic:AddChild(Image(selected_key.atlas, selected_key.tex))
        self.legacy_fg:SetScaleMode(SCALEMODE_FILLSCREEN)
        self.legacy_fg:SetVAnchor(ANCHOR_MIDDLE)
        self.legacy_fg:SetHAnchor(ANCHOR_MIDDLE)
    end
    -- Ensure bg is behind our roots.
    if self.bg ~= nil then
        self.bg:MoveToBack()
    end

    -- common
    local loadingtipsoption = Profile:GetLoadingTipsOption()
    if loadingtipsoption ~= LOADING_SCREEN_TIP_OPTIONS.NONE then
        -- Loading tip BG
        self.loading_tip_root = self:AddChild(Widget("loading_tips_root"))
        self.loading_tip_root:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

        self.loading_tip_bg_left = self.loading_tip_root:AddChild(Image("images/loading_screen.xml", "frame_outer.tex"))
        self.loading_tip_bg_left:SetSize(RESOLUTION_X * 0.08, RESOLUTION_Y * 0.35)
        self.loading_tip_bg_left:SetPosition(RESOLUTION_X * 0.04, RESOLUTION_Y * 0.175)
        self.loading_tip_bg_left:SetTint(1,1,1,0.5)

        self.loading_tip_bg = self.loading_tip_root:AddChild(Image("images/loading_screen.xml", "frame_inner.tex"))
        self.loading_tip_bg:ScaleToSize(RESOLUTION_X * 0.84, RESOLUTION_Y * 0.35)
        self.loading_tip_bg:SetPosition(RESOLUTION_X * 0.5, RESOLUTION_Y * 0.175)
        self.loading_tip_bg:SetTint(1,1,1,0.5)

        self.loading_tip_bg_right = self.loading_tip_root:AddChild(Image("images/loading_screen.xml", "frame_outer.tex"))
        self.loading_tip_bg_right:SetSize(RESOLUTION_X * 0.08, RESOLUTION_Y * 0.35)
        self.loading_tip_bg_right:SetPosition(RESOLUTION_X * 0.96, RESOLUTION_Y * 0.175)
        self.loading_tip_bg_right:SetScale(-1, 1)
        self.loading_tip_bg_right:SetTint(1,1,1,0.5)

        -- Loading tip text icon (texture gets assigned in SetEnabled())
        self.loading_tip_icon = self:AddChild(Image("images/global.xml", "square.tex"))
        self.loading_tip_icon:SetScale(0.5, 0.5)
        self.loading_tip_icon:SetPosition(RESOLUTION_X * 0.05 , RESOLUTION_Y * 0.1)

        -- Loading tip text
        self.loading_tip_text = self:AddChild(ShadowedText(CHATFONT_OUTLINE, 25))
        self.loading_tip_text:SetRegionSize(RESOLUTION_X * 0.6, 120)
        self.loading_tip_text:SetPosition(RESOLUTION_X * 0.4, RESOLUTION_Y * 0.1)
        self.loading_tip_text:SetHAlign(ANCHOR_LEFT)
        self.loading_tip_text:SetVAlign(ANCHOR_MIDDLE)
        self.loading_tip_text:EnableWordWrap(true)
        self.tipcycledelay = TIP_CYCLE_DELAY
    end

    -- Loading text
    self.loading_widget = self:AddChild(ShadowedText(HEADERFONT, 35))

    if loadingtipsoption ~= LOADING_SCREEN_TIP_OPTIONS.NONE then
        self.loading_widget:SetPosition(170, RESOLUTION_Y - 40)
    else
        self.loading_widget:SetPosition(170, 60)
    end
    self.loading_widget:SetRegionSize(250, 44)
    self.loading_widget:SetHAlign(ANCHOR_LEFT)
    self.loading_widget:SetVAlign(ANCHOR_BOTTOM)
    self.loading_widget:SetString(STRINGS.UI.NOTIFICATION.LOADING)

    self.cached_string  = ""
    self.elipse_state = 0
    self.cached_fade_level = 0
    self.step_time = GetStaticTime()
end)

function LoadingWidget:RepickImage()
    if self.image_random ~= nil then
        if self.legacy_fg ~= nil then
            if self.image_random < 0 and #legacy_images > 1 then
                local random_idx = -math.random(#legacy_images - 1)
                self.image_random = random_idx == self.image_random and -#legacy_images or random_idx
                local selected_key = legacy_images[-self.image_random]
                self.legacy_fg:SetTexture(selected_key.atlas, selected_key.tex)
                self.selected_key = random_idx
            end
        elseif self.image_random > 0 and Settings.loading_screen_keys ~= nil and #Settings.loading_screen_keys > 1 then
            local random_idx = math.random(#Settings.loading_screen_keys - 1)
            self.image_random = random_idx == self.image_random and #Settings.loading_screen_keys or random_idx
            self.selected_key = Settings.loading_screen_keys[self.image_random]
            self.bg:SetTexture(GetLoaderAtlasAndTex(self.selected_key))
        end
    end
end

function LoadingWidget:ShowNextFrame()
    self.forceShowNextFrame = true
end

function LoadingWidget:SetEnabled(enabled)
    if enabled then
        if not self.is_enabled then
            self.is_enabled = true
            self.root_classic:Show()
            self:Show()
            self:StartUpdating()

            -- Refresh loading tip
            if self.loading_tip_text ~= nil and self.loading_tip_icon ~= nil then
                local loadingtip = TheLoadingTips:PickLoadingTip(self.selected_key)
                if loadingtip then
                    self.loading_tip_text:SetString(loadingtip.text)
                    self.loading_tip_icon:SetTexture(loadingtip.atlas, loadingtip.icon)

                    -- Add tip to the recently shown tips list
                    TheLoadingTips:RegisterShownLoadingTip(loadingtip)
                else
                    if self.loading_tip_text and self.loading_tip_text:GetString() == nil then
                        self.loading_tip_root:Hide()
                        self.loading_tip_text:Hide()
                        self.loading_tip_icon:Hide()
                    end
                end
            end
        end
    elseif self.is_enabled then
        self.is_enabled = false
        self:Hide()
        self:StopUpdating()
        self:RepickImage()
    end
end

function LoadingWidget:KeepAlive(auto_increment)
    if self.is_enabled then
        if TheFrontEnd and auto_increment == false then
            self.cached_fade_level = TheFrontEnd:GetFadeLevel()
        else
            self.cached_fade_level = 1.0
        end

        local fade_sq = self.cached_fade_level * self.cached_fade_level
        self.loading_widget:SetColour(243/255, 244/255, 243/255, fade_sq)

        if self.loading_tip_text ~= nil then
            self.loading_tip_text:SetColour(243/255, 244/255, 243/255, fade_sq)
        end

        if self.loading_tip_bg ~= nil then
            self.loading_tip_bg:SetTint(1, 1, 1, 0.5 * fade_sq)
            self.loading_tip_bg_left:SetTint(1, 1, 1, 0.5 * fade_sq)
            self.loading_tip_bg_right:SetTint(1, 1, 1, 0.5 * fade_sq)
        end

        if self.loading_tip_icon ~= nil then
            self.loading_tip_icon:SetTint(1, 1, 1, fade_sq)
        end

        if self.bg ~= nil then
            self.bg:SetTint(FRONTEND_PORTAL_COLOUR[1], FRONTEND_PORTAL_COLOUR[2], FRONTEND_PORTAL_COLOUR[3], fade_sq)
        end
        if self.legacy_fg ~= nil then
            self.legacy_fg:SetTint(1, 1, 1, fade_sq)
        end
        self.vig:SetTint(1, 1, 1, fade_sq)

        local time = GetStaticTime()
        local time_delta = time - self.step_time
        local NEXT_STATE = 1.0
        if time_delta > NEXT_STATE or auto_increment then
            if self.elipse_state == 0 then
                self.loading_widget:SetString(STRINGS.UI.NOTIFICATION.LOADING..".")
                self.elipse_state = self.elipse_state + 1
            elseif self.elipse_state == 1 then
                self.loading_widget:SetString(STRINGS.UI.NOTIFICATION.LOADING.."..")
                self.elipse_state = self.elipse_state + 1
            else
                self.loading_widget:SetString(STRINGS.UI.NOTIFICATION.LOADING.."...")
                self.elipse_state = 0
            end
            self.step_time = time
        end

        if self.cached_fade_level < 0.01 then
            self:SetEnabled(false)
        end
    end
end

local fontindex = 1
local fonts = {
    HEADERFONT, NEWFONT_OUTLINE, CHATFONT_OUTLINE, BODYTEXTFONT,FALLBACK_FONT_FULL,
}

function LoadingWidget:OnUpdate(dt)
    self:KeepAlive(self.forceShowNextFrame)
    self.forceShowNextFrame = false

    -- Debug stuff for testing tip layouts
    if BRANCH == "dev" and Profile:GetLoadingTipsOption() ~= LOADING_SCREEN_TIP_OPTIONS.NONE then

        self.tipcycledelay = self.tipcycledelay - dt

        -- Cycle through tips
        if self.tipcycledelay <= 0 and (TheInput:IsControlPressed(CONTROL_PRIMARY) or TheInput:IsControlPressed(CONTROL_ACTION)) then
        --if self.tipcycledelay <= 0 then
            local loadingtip = TheLoadingTips:PickLoadingTip(self.selected_key)
            if loadingtip then
                self.loading_tip_text:SetString(loadingtip.text)
                self.loading_tip_icon:SetTexture(loadingtip.atlas, loadingtip.icon)
                TheLoadingTips:RegisterShownLoadingTip(loadingtip)
            end

            self.tipcycledelay = TIP_CYCLE_DELAY
        end

        -- DebugKeys are disabled at this point, so check manually
        if TheInput:IsKeyDown(KEY_SEMICOLON) then
            TheFrontEnd:SetFadeLevel(0)
        end

        if self.tipcycledelay ~= nil and self.tipcycledelay <= 0 then
            -- Tip text fonts
            if TheInput:IsKeyDown(KEY_K) then
                fontindex = fontindex < #fonts and fontindex + 1 or 1
                print("Setting tip font to: " .. fonts[fontindex])
                self.loading_tip_text:SetFont(fonts[fontindex])
                self.tipcycledelay = TIP_CYCLE_DELAY
            end

            -- Tip text size
            if TheInput:IsKeyDown(KEY_EQUALS) then
                local newsize = self.loading_tip_text.text:GetSize() + 5
                print("Setting tip text size to: " .. newsize)
                self.loading_tip_text:SetSize(newsize)
                self.tipcycledelay = TIP_CYCLE_DELAY
            elseif TheInput:IsKeyDown(KEY_MINUS) then
                local newsize = self.loading_tip_text.text:GetSize() - 5
                print("Setting tip text size to: " .. newsize)
                self.loading_tip_text:SetSize(newsize)
                self.tipcycledelay = TIP_CYCLE_DELAY
            end

            -- Toggle tip BG on/off
            if TheInput:IsKeyDown(KEY_J) then
                if self.loading_tip_bg.shown then
                    self.loading_tip_bg:Hide()
                    self.loading_tip_bg_left:Hide()
                    self.loading_tip_bg_right:Hide()
                else
                    self.loading_tip_bg:Show()
                    self.loading_tip_bg_left:Show()
                    self.loading_tip_bg_right:Show()
                end
                self.tipcycledelay = TIP_CYCLE_DELAY
            end

            -- Change BG
            if TheInput:IsKeyDown(KEY_H) then
                self:RepickImage()
                print("Setting BG to: " .. self.selected_key)
                self.tipcycledelay = TIP_CYCLE_DELAY
            end
        end
    end
end

return LoadingWidget
