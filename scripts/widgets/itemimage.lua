local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local image_scale = .6

local ItemImage = Class(Widget, function(self, screen, type, name, item_id, timestamp, clickFn)
    Widget._ctor(self, "item-image")

    self.screen = screen
    self.type = type
    self.name = name
    self.item_id = item_id
    self.clickFn = clickFn

    self.frame = self:AddChild(UIAnim())
    self.frame:GetAnimState():SetBuild("frames_comp") -- use the animation file as the build, then override it
    self.frame:GetAnimState():SetBank("frames_comp") -- top level symbol from frames_comp

    self.new_tag = self.frame:AddChild(Text(BODYTEXTFONT, 20, STRINGS.UI.SKINSSCREEN.NEW))
    self.new_tag.inst.UITransform:SetRotation(43)
    self.new_tag:SetPosition(41, 34)
    self.new_tag:SetColour(WHITE)

	self.frame:GetAnimState():PlayAnimation("idle_on", true)

    local collection_timestamp = self.screen and self.screen.profile:GetCollectionTimestamp() or timestamp
   	if not timestamp or (timestamp > collection_timestamp) then
    	self.new_tag:Show()
    	self.frame:GetAnimState():Show("NEW")
    else
    	self.new_tag:Hide()
    	self.frame:GetAnimState():Hide("NEW")
    end
    self.frame:SetScale(image_scale)

    self.warning = false

    self.warn_marker = self.frame:AddChild(Image("images/ui.xml", "yellow_exclamation.tex"))
    self.warn_marker:SetPosition(-40, 35)
    self.warn_marker:Hide()

    self:SetItem(type, name, item_id)
end)

function ItemImage:PlaySpecialAnimation(name, pushdefault)
	self.frame:GetAnimState():PlayAnimation(name, false)
	if pushdefault then
		self.frame:GetAnimState():PushAnimation("idle_on", true)
	end
end

function ItemImage:PlayDefaultAnim()
	self.frame:GetAnimState():PlayAnimation("idle_on", true)
end

function ItemImage:DisableSelecting()
	self.disable_selecting = true
end

function ItemImage:SetItem(type, name, item_id, timestamp)

	self.warn_marker:Hide()

	self.frame:GetAnimState():PlayAnimation("idle_on", true)

	-- Display an empty frame if there's no data
	if not type and not name then
		self.frame:GetAnimState():ClearAllOverrideSymbols()
		self.type = nil
		self.name = nil
		self.rarity = "common"
		self.new_tag:Hide()
		self.frame:GetAnimState():Hide("NEW")

		-- Reset the stuff that just got cleared to an empty frame state
		self.frame:GetAnimState():SetBuild("frames_comp")
		self.frame:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(self.rarity))
		return
	end

	if type ~= "" and type ~= "base" and name == "" then
		name = type.."_default1"
	end

	self.type = type
	self.name = name
	self.item_id = item_id
	self.rarity = GetRarityForItem( name )

	local buildname = GetBuildForItem(self.name)

	if self.frame and name and name ~= "" then
		self.frame:GetAnimState():OverrideSkinSymbol("SWAP_ICON", buildname, "SWAP_ICON")
		self.frame:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(self.rarity))
	end

	local collection_timestamp = self.screen and self.screen.profile:GetCollectionTimestamp() or timestamp
   	if timestamp and (timestamp > collection_timestamp) then
    	self.new_tag:Show()
    	self.frame:GetAnimState():Show("NEW")
    else
    	self.new_tag:Hide()
    	self.frame:GetAnimState():Hide("NEW")
    end
end

function ItemImage:ClearFrame()
	self.frame:GetAnimState():ClearAllOverrideSymbols()
	self.type = nil
	self.name = nil
	self.rarity = "common"
	self.new_tag:Hide()
	self.frame:GetAnimState():Hide("NEW")

	-- Reset the stuff that just got cleared to an empty frame state
	self.frame:GetAnimState():SetBuild("frames_comp")
	self.frame:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(self.rarity))
	self.frame:GetAnimState():PlayAnimation("idle_on", true)
	return
end

function ItemImage:SetItemRarity(rarity)
	self.rarity = rarity or "common"
	self.frame:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(self.rarity))
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
	self._base:OnGainFocus()

	if self.frame and self:IsEnabled() then
		self:Embiggen()
		self.frame:GetAnimState():PlayAnimation("hover", true)
	end

	if self.screen and self.screen.SetFocusColumn ~= nil then
		self.screen:SetFocusColumn(self)
	end
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
end

function ItemImage:OnLoseFocus()
	self._base:OnLoseFocus()

	if self.frame and not self.clicked then
		self:Shrink()
	end

	self:PlayDefaultAnim()
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
	self.frame:SetScale(image_scale * 1.18)
end

function ItemImage:Shrink()
	self.frame:SetScale(image_scale)
end

-- Toggle clicked/unclicked
function ItemImage:OnControl(control, down)
	if control == CONTROL_ACCEPT then
        if not self.clicked then
			if self:IsEnabled() then
        		if not down then
        			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

        			if not self.disable_selecting then
        				if self.screen then
        					self.screen:UnselectAll()
        				end
        				self:Select()
        			end

        			if self.clickFn then
		       			self.clickFn(self.type, self.name, self.item_id)
		       		end
        		end

				return true
			end
        end
	end
end

function ItemImage:Select()
	self:Embiggen()
	self.clicked = true
end

function ItemImage:Unselect()
	self:Shrink()
    self.clicked = false
end

return ItemImage

