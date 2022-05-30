local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"

require("characterutil")

local DEFAULT_AVATAR = "avatar_unknown.tex"
local LOCKED_GREY = {0.5, 0.5, 0.5, 1}

-- Like a PlayerBadge, but outside of game (no associated player) and clickable.
local CharacterButton = Class(ImageButton, function(self, character, cbPortraitFocused, cbPortraitClicked)
    ImageButton._ctor(self)

    self.herocharacter = character

    self.ongainfocus = cbPortraitFocused
    self:SetOnClick(cbPortraitClicked)

    local CHARACTER_SELECT_ATLAS = "images/global_redux.xml"
    local CHARACTER_SELECT_BG = "char_selection.tex"
    local FOCUS_BG = "char_selection_hover.tex"
    self:SetTextures(CHARACTER_SELECT_ATLAS,
        CHARACTER_SELECT_BG,  -- normal
        FOCUS_BG,    -- focus
        CHARACTER_SELECT_BG,  -- disabled
        FOCUS_BG,    -- down
        CHARACTER_SELECT_BG)  -- selected

    self:ForceImageSize(110,110)

    self:_SetupHead()

    self.lock_img = self:AddChild(Image("images/frontend_redux.xml", "accountitem_frame_lock.tex"))
    self.lock_img:SetScale(.15,.15)
    self.lock_img:SetPosition(-20,-20)

    self:SetCharacter(self.herocharacter)
end)

function CharacterButton:_SetupHead()
    self.head_anim = self:AddChild(UIAnim())
    self.head_animstate = self.head_anim:GetAnimState()

    self.head_animstate:SetBank("wilson")
    self.head_animstate:PlayAnimation("idle_loop_ui", true)
end

function CharacterButton:SetCharacter(hero)
    self.herocharacter = hero

    if self.herocharacter == "random" or not Profile:GetAnimatedHeadsEnabled()  then
        self.head_animstate:SetTime(0)
        self.head_animstate:Pause()
    else
        self.head_animstate:SetTime(math.random()*1.5)
    end

    self.head_anim:SetScale(CHARACTER_BUTTON_SCALE[self.herocharacter] or CHARACTER_BUTTON_SCALE.default)
    self.head_anim:SetPosition(0, CHARACTER_BUTTON_OFFSET[self.herocharacter] or CHARACTER_BUTTON_OFFSET.default, 0)

    local skindata = GetSkinData(self.herocharacter.."_none")
    local base_build = self.herocharacter
    local skin_mode = "normal_skin"
    if skindata.skins ~= nil then
        base_build = skindata.skins[skin_mode]
    end
    SetSkinsOnAnim( self.head_animstate, self.herocharacter, base_build, {}, skin_mode)

    if IsCharacterOwned(hero) then
        self.image:SetTint(unpack(WHITE))
        self.head_animstate:SetMultColour(unpack(WHITE))
        self.lock_img:Hide()
    else
        self.image:SetTint(unpack(LOCKED_GREY))
        self.head_animstate:SetMultColour(unpack(LOCKED_GREY))
        self.lock_img:Show()
    end
end

function CharacterButton:RefreshInventory()
    self:SetCharacter(self.herocharacter)
end

return CharacterButton
