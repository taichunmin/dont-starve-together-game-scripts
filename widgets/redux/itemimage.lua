local AccountItemFrame = require "widgets/redux/accountitemframe"
local Button = require "widgets/button"
local Text = require "widgets/text"
local Image = require "widgets/image"


-- Expects to be used in a ScrollingList. Call SetItem to populate with data.
local ItemImage = Class(Button, function(self, user_profile, screen)
    Button._ctor(self)

    self.user_profile = user_profile
    self.screen = screen
    self.image_scale = .6

    self.frame = self:AddChild(AccountItemFrame())
    self.frame:MoveToBack()
    self.frame:GetAnimState():SetRayTestOnBB(true);
    self.frame:SetScale(self.image_scale)

    self.owned_count = self.frame:AddChild(Text(CHATFONT_OUTLINE, 40, nil, UICOLOURS.WHITE))
    self.owned_count:SetPosition(-8, -40)
    self.owned_count:SetRegionSize(80, 43)
    self.owned_count:SetHAlign(ANCHOR_LEFT)

    self.warning = false
    self.warn_marker = self.frame:AddChild(Image("images/ui.xml", "yellow_exclamation.tex"))
    self.warn_marker:SetPosition(-40, 35)
end)

function ItemImage:PlayUnlock()
    self.frame:PlayUnlock()
end

function ItemImage:PlaySpecialAnimation(name, pushdefault)
	self.frame:GetAnimState():PlayAnimation(name, false)
	if pushdefault then
		self.frame:GetAnimState():PushAnimation("icon", true)
	end
end

function ItemImage:PlayDefaultAnim()
	self.frame:GetAnimState():PlayAnimation("icon", true)
end

function ItemImage:SetItem(type, name, item_id, timestamp)
	self.warn_marker:Hide()

	-- Display an empty frame if there's no data
	if not type and not name then
		self:ClearFrame()
		return
	end


	if type ~= "" and type ~= "base" and name == "" then
		name = type.."_default1"
	end

    --~ assert(type and type ~= "") -- ingame items don't have types!!!
    assert(name and name ~= "")
    -- item_id is the account-unique identifier for an item (an account may
    -- have two of the same item and one could be on sale on the marketplace
    -- and the other available for sale). ItemImage doesn't necessarily
    -- represent an owned item or a single item.
    --~ assert(item_id and item_id ~= "")

	self.type = type
	self.name = name
	self.item_id = item_id

	self.rarity = GetRarityForItem( name )

    self.frame:SetItem(name)

	local collection_timestamp = self.user_profile and self.user_profile:GetCollectionTimestamp() or timestamp
    local is_new = timestamp and (timestamp > 0) and (timestamp > collection_timestamp)
    --~ print(is_new and "new" or "old", name, "Timestamp is ", timestamp, collection_timestamp)
    self.frame:SetAge(is_new)
end

function ItemImage:ClearFrame()
	self.frame:SetBlank()
	self.type = nil
    self.name = "empty"
	self.rarity = "common"
end

function ItemImage:Mark(value)
	self.warning = value

	if self.warning then
		self.warn_marker:Show()
	else
		self.warn_marker:Hide()
	end
end

function ItemImage:OnGainFocus()
	self._base.OnGainFocus(self)

    self:_GainFocus_Internal()
end

function ItemImage:_GainFocus_Internal()
	if self:IsEnabled() then
        self:MoveToFront()
		self:Embiggen()
	end
end

function ItemImage:OnLoseFocus()
	self._base.OnLoseFocus(self)

    self:Shrink()
end

function ItemImage:OnEnable()
	self._base.OnEnable(self)
    if self.focus then
        self:OnGainFocus()
    else
        self:OnLoseFocus()
    end
end

function ItemImage:OnDisable()
	self._base.OnDisable(self)
	self:OnLoseFocus()
end


function ItemImage:Embiggen()
	self.frame:SetScale(self.image_scale * 1.18)
end

function ItemImage:Shrink()
	self.frame:SetScale(self.image_scale)
end

function ItemImage:ScaleToSize(side)
    -- All flash for ItemImage has the same dimensions: 192x192
	local side0 = 192
    side0 = side0 * 0.7 -- 1080 -> 720 conversion
    side0 = side0 - 11  -- reduce to actual size (don't know why math is wrong)
	local scale = side / side0
	self.frame:SetScale(scale, scale, 1)
    self.image_scale = scale
end

function ItemImage:SetInteractionState(is_active, is_owned, is_interaction_target, is_unlockable, is_dlc_owned)
    self.frame:SetActivityState(is_active, is_owned, is_unlockable, is_dlc_owned)
    if is_interaction_target then
        self.frame:SetStyle_Highlight()
    else
        self.frame:SetStyle_Normal()
    end
end

local function GetCountText(count)
    if count <= 1 then
        return ""
    elseif count > 8 then
        return "x9+"
    else
        return "x".. tostring(count)
    end
end

function ItemImage:ApplyDataToWidget(context, widget_data, data_index)
    local list_widget = self
    local screen = context.screen
	if widget_data then
		list_widget:SetItem(GetTypeForItem(widget_data.item_key), widget_data.item_key, widget_data.item_id, widget_data.acquire_timestamp)

        list_widget.owned_count:SetString(GetCountText(widget_data.owned_count))

        list_widget.frame:SetWeavable( IsUserCommerceAllowedOnItemType( widget_data.item_key ) )

		list_widget:Show()

		if screen and screen.show_hover_text then
			local rarity_str = GetModifiedRarityStringForItem(widget_data.item_key)
			local hover_text = rarity_str .. "\n" .. GetSkinName(widget_data.item_key)
			list_widget:SetHoverText( hover_text, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 60, colour = {1,1,1,1}})
			if list_widget.focus then --make sure we force the hover text to appear on the default focused item
				list_widget:_GainFocus_Internal()
			end
		end
	else
		list_widget:SetItem(nil, nil, nil)
        list_widget.owned_count:SetString("")

		if list_widget.focus then --maintain focus on the widget
			list_widget:_GainFocus_Internal()
		end
		if screen and screen.show_hover_text then
			list_widget:ClearHoverText()
		end
	end
end

return ItemImage

