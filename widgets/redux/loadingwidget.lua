local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ShadowedText = require "widgets/redux/shadowedtext"
local TEMPLATES = require "widgets/redux/templates"

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

    local image_keys = Settings.loading_screen_keys or {}

    self.forceShowNextFrame = false
    self.is_enabled = false
    self.image_random = GetRandomIndex(session_random_index, #image_keys)
    self:Hide()

    -- classic
    self.root_classic = self:AddChild(Widget("classic_root"))
    self.root_classic:Hide()
    self.vig = self.root_classic:AddChild(TEMPLATES.old.BackgroundVignette())

    local selected_key = image_keys[self.image_random or -1]
    if selected_key then
        self.bg = self:AddChild(TEMPLATES.LoaderBackground(selected_key))
    else
        -- Initial startup or user didn't select any backgrounds. Use the
        -- legacy style.
        local random_idx = -(self.image_random or 0)
        selected_key = legacy_images[random_idx]
        if selected_key == nil then
            random_idx = math.random(#legacy_images)
            selected_key = legacy_images[random_idx]
            self.image_random = -random_idx
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

    self.loading_widget = self:AddChild(ShadowedText(HEADERFONT, 35))
    self.loading_widget:SetPosition(115, 60)
    self.loading_widget:SetRegionSize(130, 44)
    self.loading_widget:SetHAlign(ANCHOR_LEFT)
    self.loading_widget:SetVAlign(ANCHOR_BOTTOM)
    self.loading_widget:SetString(STRINGS.UI.NOTIFICATION.LOADING)

    self.cached_string  = ""
    self.elipse_state = 0
    self.cached_fade_level = 0
    self.step_time = GetTime()
end)

function LoadingWidget:RepickImage()
    if self.image_random ~= nil then
        if self.legacy_fg ~= nil then
            if self.image_random < 0 and #legacy_images > 1 then
                local random_idx = -math.random(#legacy_images - 1)
                self.image_random = random_idx == self.image_random and -#legacy_images or random_idx
                local selected_key = legacy_images[-self.image_random]
                self.legacy_fg:SetTexture(selected_key.atlas, selected_key.tex)
            end
        elseif self.image_random > 0 and Settings.loading_screen_keys ~= nil and #Settings.loading_screen_keys > 1 then
            local random_idx = math.random(#Settings.loading_screen_keys - 1)
            self.image_random = random_idx == self.image_random and #Settings.loading_screen_keys or random_idx
            self.bg:SetTexture(GetLoaderAtlasAndTex(Settings.loading_screen_keys[self.image_random]))
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

        if self.bg ~= nil then
            self.bg:SetTint(FRONTEND_PORTAL_COLOUR[1], FRONTEND_PORTAL_COLOUR[2], FRONTEND_PORTAL_COLOUR[3], fade_sq)
        end
        if self.legacy_fg ~= nil then
            self.legacy_fg:SetTint(1, 1, 1, fade_sq)
        end
        self.vig:SetTint(1, 1, 1, fade_sq)

        local time = GetTime()
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

        if .01 > self.cached_fade_level then
            self:SetEnabled(false)
        end
    end
end

function LoadingWidget:OnUpdate()
    self:KeepAlive(self.forceShowNextFrame)
    self.forceShowNextFrame = false
end

return LoadingWidget
