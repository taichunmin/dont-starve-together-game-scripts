local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local image_scale = .6

local MiniGameTile = Class(Widget, function(self, screen, index, mover)
    Widget._ctor(self, "MiniGameTile")

    self.screen = screen
    self.index = index
	self.exploded = false

    self.tile = self:AddChild(UIAnim())
    self.tile:GetAnimState():SetBuild("minigametile")
    self.tile:GetAnimState():SetBank("minigametile")
	self.tile:GetAnimState():PlayAnimation("on", true)
	self.view_state = "on"
	if mover then
		self.tile:GetAnimState():Hide("frame")
		self.tile:GetAnimState():Hide("frameBG")
		self.tile:Disable()
	end

    self.tile:SetScale(image_scale)

	self.tile_num = self:AddChild(Text(CHATFONT_OUTLINE, 35))
	self.tile_num:SetPosition(2,-4)

    self:ClearTile()
end)

function MiniGameTile:IsClear()
	return self.number == nil and self.tile_type == ""
end

function MiniGameTile:ClearTile()
	self.tile_type = ""
	self.tile:GetAnimState():ClearAllOverrideSymbols()
	self.tile:GetAnimState():PlayAnimation("on", true)
	self.view_state = "on"
	self:SetTileNumber(nil)
	self:UnhighlightTileNum()
end

function MiniGameTile:SetTileNumber(num)
	self.number = num
	if num == nil then
		self.tile_num:SetString("")
	else
		self.tile_num:SetString(tostring(self.number))
	end
end

function MiniGameTile:HighlightTileNum()
	self.tile:GetAnimState():SetMultColour(0.6,0.9,0.6,1)
	self.tile_num:SetColour(0,1,0,1)
end

function MiniGameTile:UnhighlightTileNum()
	self.tile:GetAnimState():SetMultColour(1,1,1,1)
	self.tile_num:SetColour(1,1,1,1)
end

function MiniGameTile:SetTileTypeUnHidden(tile_type)
	self.tile_type = tile_type
	self:UnhideTileType()
end

function MiniGameTile:SetTileTypeHidden(tile_type)
	self.tile_type = tile_type
	self.tile:GetAnimState():ClearAllOverrideSymbols()
end

function MiniGameTile:UnhideTileType()
	self.tile:GetAnimState():OverrideSkinSymbol("SWAP_ICON", self.tile_type, "SWAP_ICON")
end

function MiniGameTile:ForceHideTile()
	self.tile:GetAnimState():PushAnimation("off", true)
	self.view_state = "off"
end

function MiniGameTile:HideTile()
	if self.view_state == "on" then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/feed")

		self.tile:GetAnimState():PlayAnimation("anim_off")
		self.tile:GetAnimState():PushAnimation("off", true)
		self.view_state = "off"
	end
end

function MiniGameTile:ShowTile()
	if self.view_state == "off" then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/feed")

		self.tile:GetAnimState():PlayAnimation("anim_on")
		self.tile:GetAnimState():PushAnimation("on", true)
		self.view_state = "on"
	end
end


function MiniGameTile:OnGainFocus()
	self._base:OnGainFocus()

	if self.tile and self:IsEnabled() then
		self:Embiggen()
		self.tile:GetAnimState():PushAnimation(self.view_state.."_hover", true)
	end
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
end

function MiniGameTile:OnLoseFocus()
	self._base:OnLoseFocus()

	if self.tile and not self.clicked then
		self:Shrink()
	end
	self.tile:GetAnimState():PushAnimation(self.view_state, true)
end

function MiniGameTile:OnEnable()
	self._base.OnEnable(self)
    if self.focus then
        self:OnGainFocus()
    else
        self:OnLoseFocus()
    end
end

function MiniGameTile:OnDisable()
	self._base.OnDisable(self)
	self:OnLoseFocus()
end


function MiniGameTile:Embiggen()
	self.tile:SetScale(image_scale * 1.10)
end

function MiniGameTile:Shrink()
	self.tile:SetScale(image_scale)
end

-- Toggle clicked/unclicked
function MiniGameTile:OnControl(control, down)
	if control == CONTROL_ACCEPT then
        if not self.clicked then
			if self:IsEnabled() then
        		if not down then
        			if self.clickFn then
		       			self.clickFn(self.index)
		       		end
        		end

				return true
			end
        end
	end
end

function MiniGameTile:Select()
	self:Embiggen()
	self.clicked = true
end

function MiniGameTile:Unselect()
	self:Shrink()
    self.clicked = false
end

return MiniGameTile

