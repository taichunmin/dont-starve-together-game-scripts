local CharacterProgress = require "widgets/redux/characterprogress"
local CharacterSelect = require "widgets/redux/characterselect"
local EmojiExplorerPanel = require "widgets/redux/emojiexplorerpanel"
local EmotesExplorerPanel = require "widgets/redux/emotesexplorerpanel"
local BeardsExplorerPanel = require "widgets/redux/beardsexplorerpanel"
local GameItemExplorerPanel = require "widgets/redux/gameitemexplorerpanel"
local LoadersExplorerPanel = require "widgets/redux/loadersexplorerpanel"
local ProfileFlairExplorerPanel = require "widgets/redux/profileflairexplorerpanel"
local PopupDialogScreen = require "screens/redux/popupdialog"
local PortraitBackgroundExplorerPanel = require "widgets/redux/portraitbackgroundexplorerpanel"
local Screen = require "widgets/screen"
local Subscreener = require "screens/redux/subscreener"
local WardrobeScreen = require "screens/redux/wardrobescreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local TEMPLATES = require("widgets/redux/templates")


local CollectionScreen = Class(Screen, function(self, prev_screen, user_profile)
	Screen._ctor(self, "CollectionScreen")
    self.prev_screen = prev_screen
    self.user_profile = user_profile
	self:DoInit()

	self.default_focus = self.subscreener.menu
end)

function CollectionScreen:DoInit()
    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BrightMenuBackground())

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        { x = -380, y = 170, scale = 0.75 },
        { x = -365, y = -310, scale = 0.75 },
        { x = 480, y = -310, scale = 0.75 },
    } ))

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.COLLECTIONSCREEN.TITLE, ""))

    self.doodad_count = self.root:AddChild(TEMPLATES.DoodadCounter(TheInventory:GetCurrencyAmount()))
	self.doodad_count:SetPosition(-550, 215)
	self.doodad_count:SetScale(0.4)

    if IsSteam() or IsRail() then
        self.points_count = self.root:AddChild(TEMPLATES.KleiPointsCounter(TheInventory:GetKleiPointsAmount()))
        self.points_count:SetPosition(-480, 215)
        self.points_count:SetScale(0.4)
    end

    self.subscreener = Subscreener(self,
        self.MakeMenu,
        {
            -- Menu items
            skins               = self:_BuildCharacterSelect(),
            gameitem            = self.root:AddChild(GameItemExplorerPanel(self, self.user_profile)),
            beards              = self.root:AddChild(BeardsExplorerPanel(self, self.user_profile)),
            emotes              = self.root:AddChild(EmotesExplorerPanel(self, self.user_profile)),
            emoji               = self.root:AddChild(EmojiExplorerPanel(self, self.user_profile)),
            portraitbackgrounds = self.root:AddChild(PortraitBackgroundExplorerPanel(self, self.user_profile)),
            profileflair        = self.root:AddChild(ProfileFlairExplorerPanel(self, self.user_profile)),
            loaders             = self.root:AddChild(LoadersExplorerPanel(self, self.user_profile)),
        })


    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:_CloseScreen()
                end
            ))
    end

    ----------------------------------------------------------
	-- Prepare for viewing

    -- Ensure grid has had focus to setup initial selection.
    self.subscreener:OnMenuButtonSelected("skins")
end

function CollectionScreen:_BuildCharacterSelect()
    local function OnCharacterClick(hero)
        self.user_profile:SetLastSelectedCharacter(hero)
        self:OnSkinsButton(hero)
    end
    local function OnCharacterHighlight(hero)
    end
    local character_select = CharacterSelect(self,
        CharacterProgress,
        140,
        function(name)
            return STRINGS.CHARACTER_ABOUTME[name]
        end,
        self.user_profile:GetLastSelectedCharacter(),
        OnCharacterHighlight,
        OnCharacterClick
        )

    character_select:SetPosition(460, 100)
    return self.root:AddChild(character_select)
end

--
-- SUBSCREENS

function CollectionScreen:MakeMenu(subscreener)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())

    local button_skins   = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.SKINS,   "skins",    STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_SKINS,   self.tooltip)
    local button_gameitem= subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.GAMEITEM,"gameitem", STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_GAMEITEM,   self.tooltip)
    local button_beard   = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.BEARD,   "beards",   STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_BEARD,   self.tooltip)
    local button_emote   = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.EMOTE,   "emotes",   STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_EMOTE,   self.tooltip)
    local button_emoji   = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.EMOJI,   "emoji",    STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_EMOJI,   self.tooltip)
    local button_profileflair        = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.PROFILEFLAIR,        "profileflair",        STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_PROFILEFLAIR,        self.tooltip)
    local button_portraitbackgrounds = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.PORTRAITBACKGROUNDS, "portraitbackgrounds", STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_PORTRAITBACKGROUNDS, self.tooltip)
    local button_loaders = subscreener:MenuButton(STRINGS.UI.COLLECTIONSCREEN.LOADERS, "loaders",  STRINGS.UI.COLLECTIONSCREEN.TOOLTIP_LOADERS, self.tooltip)

    local menu_items = {
        {widget = button_loaders},
        {widget = button_profileflair},
        {widget = button_portraitbackgrounds},
        {widget = button_emoji  },
        {widget = button_emote  },
        {widget = button_beard  },
        {widget = button_gameitem  },
        {widget = button_skins  },
    }

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

function CollectionScreen:OnSkinsButton(hero)
    self:_FadeToScreen(WardrobeScreen, {hero})
end
function CollectionScreen:_FadeToScreen(screen_type, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.subscreener.menu:Disable()
    self.leaving = true

    TheFrontEnd:FadeToScreen( self, function() return screen_type(self.user_profile, unpack(data)) end, nil )
end

function CollectionScreen:OnBecomeActive()
	if not self.sorry_popup then
        local function ShowApology(message)
            local sorry_popup = PopupDialogScreen(
                STRINGS.UI.SKINSSCREEN.SORRY,
                message,
                {
                    {
                        text=STRINGS.UI.POPUPDIALOG.OK,
                        cb = function()
                            TheFrontEnd:PopScreen() -- dialog
                            TheFrontEnd:FadeBack() -- collection screen
                        end
                    }
                })
            TheFrontEnd:PushScreen(sorry_popup)
            return sorry_popup
        end
        if not TheInventory:HasSupportForOfflineSkins() and (not TheNet:IsOnlineMode() or TheFrontEnd:GetIsOfflineMode()) then
            self.sorry_popup = ShowApology(STRINGS.UI.SKINSSCREEN.OFFLINE)
            return
        elseif not TheInventory:HasDownloadedInventory() then
            self.sorry_popup = ShowApology(STRINGS.UI.COLLECTIONSCREEN.FAILED_TO_LOAD)
            return
        end
    end

    CollectionScreen._base.OnBecomeActive(self)

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end

    if self.leaving then
        -- if we left, then inventory may have changed.
        self:RefreshInventory()
    end

    if not self.shown then
        self:Show()
    end

	if self.last_focus_widget then
		self.subscreener.menu:RestoreFocusTo(self.last_focus_widget)
	end

    self.leaving = nil
end

function CollectionScreen:OnBecomeInactive()
    CollectionScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function CollectionScreen:RefreshInventory(animateDoodads)
    self.doodad_count:SetCount(TheInventory:GetCurrencyAmount(), animateDoodads)
    if IsSteam() or IsRail() then
        self.points_count:SetCount(TheInventory:GetKleiPointsAmount())
    end
    self.subscreener.sub_screens["skins"]:RefreshInventory()
end

function CollectionScreen:_CloseScreen()
	self.user_profile:SetCollectionTimestamp(GetInventoryTimestamp())
	TheFrontEnd:FadeBack()
end

function CollectionScreen:OnControl(control, down)
    if CollectionScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:_CloseScreen()
        return true
    end
end

function CollectionScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.BACK)

    return table.concat(t, "  ")
end

function CollectionScreen:OnUpdate(dt)
end


return CollectionScreen
