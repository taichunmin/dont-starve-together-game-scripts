local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local image_scale = .6

local MazeGameTile = Class(Widget, function(self, screen)
    Widget._ctor(self, "MazeGameTile")
	
    --self.tile = self:AddChild(UIAnim())
    --self.tile:GetAnimState():SetBuild("minigametile")
    --self.tile:GetAnimState():SetBank("minigametile")
	--self.tile:GetAnimState():PlayAnimation("on", true)
	
	self.tile = self:AddChild(Image("images/global.xml", "square.tex"))
	
	self.tile:SetScale(image_scale)
end)

--[[function MazeGameTile:IsClear()
	return self.tile_type == ""
end]]

function MazeGameTile:SetTileType(tile_type)
	self.tile_type = tile_type

	if tile_type == "none" then
		self.tile:Hide()
	else
		local tex = tile_type .. ".tex"
		self.tile:SetTexture( GetInventoryItemAtlas(tex), tex )
		self.tile:Show()
	end
	--self.tile:GetAnimState():ClearAllOverrideSymbols()
	--self.tile:GetAnimState():OverrideSkinSymbol("SWAP_ICON", self.tile_type, "SWAP_ICON")
end

--[[function MazeGameTile:OnGainFocus()
	self._base:OnGainFocus()

	if self.tile and self:IsEnabled() then 
		self:Embiggen()
		self.tile:GetAnimState():PushAnimation(self.view_state.."_hover", true)
	end
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
end

function MazeGameTile:OnLoseFocus()
	self._base:OnLoseFocus()

	if self.tile and not self.clicked then 
		self:Shrink()
	end
	self.tile:GetAnimState():PushAnimation(self.view_state, true)
end]]

--[[function MazeGameTile:OnEnable()
	self._base.OnEnable(self)
    if self.focus then
        self:OnGainFocus()
    else
        self:OnLoseFocus()
    end
end

function MazeGameTile:OnDisable()
	self._base.OnDisable(self)
	self:OnLoseFocus()
end]]


--[[function MazeGameTile:Embiggen()
	self.tile:SetScale(image_scale * 1.10)
end

function MazeGameTile:Shrink()
	self.tile:SetScale(image_scale)
end]]

-- Toggle clicked/unclicked
--[[function MazeGameTile:OnControl(control, down)
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
end]]

--[[function MazeGameTile:Select()
	self:Embiggen()
	self.clicked = true
end

function MazeGameTile:Unselect()
	self:Shrink()
    self.clicked = false
end]]

return MazeGameTile

