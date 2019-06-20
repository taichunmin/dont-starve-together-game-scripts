local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

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

    -- Put the face in front of the button.
    self.face = self:AddChild(Image())
    
    self.lock_img = self:AddChild(Image("images/frontend_redux.xml", "accountitem_frame_lock.tex"))
    self.lock_img:SetScale(.15,.15)
    self.lock_img:SetPosition(-20,-20)

    self:SetCharacter(self.herocharacter)
end)

function CharacterButton:SetCharacter(hero)
    self.herocharacter = hero
    local atlas, texture = GetCharacterAvatarTextureLocation(hero)
    self.face:SetTexture(atlas, texture, DEFAULT_AVATAR)

    if IsCharacterOwned(hero) then
        self.image:SetTint(unpack(WHITE))
        self.face:SetTint(unpack(WHITE))
        self.lock_img:Hide()
    else
        self.image:SetTint(unpack(LOCKED_GREY))
        self.face:SetTint(unpack(LOCKED_GREY))
        self.lock_img:Show()
    end
end

function CharacterButton:RefreshInventory()
    self:SetCharacter(self.herocharacter)
end

return CharacterButton
