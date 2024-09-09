-- Wraps accountitem_frame anim so we can add new layers and they'll be
-- properly hidden and new behaviors will be consistently applied.
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"

--require("skinsutils")


local AccountItemFrame = Class(UIAnim, function(self)
    UIAnim._ctor(self)

    self.age_text = self:AddChild(Text(BODYTEXTFONT, 20, STRINGS.UI.SKINSSCREEN.NEW))
    self.age_text.inst.UITransform:SetRotation(43)
    self.age_text:SetPosition(41, 34)
    self.age_text:SetColour(WHITE)

    self:GetAnimState():SetBuild("accountitem_frame") -- use the animation file as the build, then override it
    self:GetAnimState():SetBank("accountitem_frame") -- top level symbol from accountitem_frame
    self:_HideExtraLayers() -- only show these layers when requested.
end)

function AccountItemFrame:SetItem(item_key)
    assert(type(item_key) == "string", "Need a key suitable for indexing into item tables like MISC_ITEMS.")
    -- When changing the build, the other layers are probably incorrect.
    self:_HideExtraLayers()
    self:_SetBuild(GetBuildForItem(item_key))
    self:_SetRarity(GetRarityForItem(item_key))
    self:_SetEventIcon(item_key)
end

function AccountItemFrame:_SetBuild(build)
    self:GetAnimState():OverrideSkinSymbol("SWAP_ICON", build, "SWAP_ICON")
end

function AccountItemFrame:_SetRarity(rarity)
    self:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(rarity))
end

function AccountItemFrame:_SetEventIcon(item_key)
    local event_icon = GetEventIconForItem(item_key)
    if event_icon ~= nil then
        self:GetAnimState():Show(event_icon)
    end
end

function AccountItemFrame:SetWeavable(weavable)
    if weavable then
        self:GetAnimState():Show("IC_WEAVE")
    else
        self:GetAnimState():Hide("IC_WEAVE")
    end
end

function AccountItemFrame:SetBlank()
    self:GetAnimState():ClearAllOverrideSymbols()
    -- Reset the stuff that just got cleared to an empty frame state
    self:GetAnimState():SetBuild("accountitem_frame")
    self:GetAnimState():PlayAnimation("icon", true)
    self:_HideExtraLayers()
end

function AccountItemFrame:HideFrame()
    self:GetAnimState():Hide("frame")
	self:GetAnimState():Hide("SWAP_frameBG")
end

function AccountItemFrame:_HideExtraLayers()
    self:GetAnimState():Hide("TINT")
    self:GetAnimState():Hide("LOCK")
    self:GetAnimState():Hide("NEW")
    self.age_text:Hide()
    self:GetAnimState():Hide("SELECT")
    self:GetAnimState():Hide("FOCUS")
    self:GetAnimState():Hide("IC_WEAVE")
    for k,_ in pairs(EVENT_ICONS) do
		self:GetAnimState():Hide(k)
    end
    self:GetAnimState():Hide("DLC")
end

function AccountItemFrame:SetLocked()
    self:GetAnimState():Show("TINT")
    self:GetAnimState():Show("LOCK")
end

function AccountItemFrame:SetUnowned()
    self:GetAnimState():Show("TINT")
end

function AccountItemFrame:PlayUnlock()
    -- The unlock animation contains its own lock so we don't need this one.
    self:GetAnimState():Hide("LOCK")

    self.inst:DoTaskInTime(.50, function()
        self:GetAnimState():Hide("TINT")
    end)

    self:GetAnimState():PlayAnimation("unlock", false)
    self:GetAnimState():PushAnimation("icon", true)
end

function AccountItemFrame:SetActivityState(is_active, is_owned, is_unlockable, is_dlc_owned)
    if is_owned then
        if is_active then
            self:GetAnimState():Show("SELECT")
        else
            self:GetAnimState():Hide("SELECT")
        end
    else
        if is_unlockable then
            self:SetLocked()
        else
            self:SetUnowned()
        end
    end

    if is_dlc_owned then
        self:GetAnimState():Show("DLC")
    else
        self:GetAnimState():Hide("DLC")
    end

end

function AccountItemFrame:SetAge(is_new)
    if is_new then
        self:GetAnimState():Show("NEW")
        self.age_text:Show()
    end
    self:GetAnimState():PlayAnimation("icon", true)
end

function AccountItemFrame:SetStyle_Highlight()
    self:GetAnimState():PlayAnimation("hover", true)
end

function AccountItemFrame:SetStyle_Normal()
    self:GetAnimState():PlayAnimation("icon", true)
end

--Special case functions for lobby screen menu items
function AccountItemFrame:ShowFocus(f)
    if f then
        self:GetAnimState():Show("FOCUS")
    else
        self:GetAnimState():Hide("FOCUS")
    end
end
function AccountItemFrame:ShowSelect(s)
    if s then
        self:SetStyle_Highlight()
    else
        self:SetStyle_Normal()
    end
end

return AccountItemFrame
