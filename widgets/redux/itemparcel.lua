local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local image_scale = 1

local ItemParcel = Class(Widget, function(self, item_type, close_cb)
    Widget._ctor(self, "item-parcel")
	
    self.item_type = item_type
    self.close_cb = close_cb
    
    self.anim = self:AddChild( UIAnim() ) 
   	
    self.anim:GetAnimState():SetBuild("skinparcel_popup") -- use the animation file as the build, then override it
    self.anim:GetAnimState():SetBank("SWAP_PARCEL") -- top level symbol from frames_comp

    self:PlayAnim("appear", "idle_loop")
    
	local function queue_shake()
		local t = math.random() * 3 + 1.5
		self.inst:DoTaskInTime(t, function()
			if self.anim:GetAnimState():IsCurrentAnimation("idle_loop") then
				self:PlayAnim("shake"..tostring(math.random(1,3)), "idle_loop")
			end
			queue_shake()
		end)
	end
	queue_shake()

	self:SetItemRarity( GetRarityForItem( self.item_type ) )
    
    --Set Skin Swap Symbol
	self.build = GetBuildForItem( self.item_type ) 
    self.anim:GetAnimState():OverrideSkinSymbol("SWAP_ICON", self.build, "SWAP_ICON")
    
    --Setup text display
    self.item_name = self:AddChild(Text(UIFONT, 55))
    self.item_name:SetString(GetSkinName(self.item_type))
    self.item_name:SetPosition(0, -130, 0)   
	self.item_name:SetColour(GetColorForItem(self.item_type))
	self.item_name:Hide()
end)

function ItemParcel:PlayAnim(name, push2, loop_anim)
	self.anim:GetAnimState():PlayAnimation(name, false)
	if push2 then 
		self.anim:GetAnimState():PushAnimation(push2, (not loop_anim) and true or false )
	end
	if loop_anim then 
		self.anim:GetAnimState():PushAnimation(loop_anim, true)
	end
end


function ItemParcel:SetItemRarity(rarity)
	--self.rarity = rarity or "common"
	
	--HIDE AND SHOW CERTAIN LAYERS OF THE ANIM
	
	--self.frame:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", self.rarity)	
end


function ItemParcel:OnGainFocus()
	self._base.OnGainFocus(self)
	if not self.clicked then
		if self.anim then 
			self:Embiggen()
			--self.frame:GetAnimState():PlayAnimation("hover", true)
		end

		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	end
end

function ItemParcel:OnLoseFocus()
	self._base.OnLoseFocus(self)
	
	if self.anim then 
		self:Shrink()
	end
end

function ItemParcel:Embiggen()
	self.anim:SetScale(image_scale * 1.18)
end

function ItemParcel:Shrink()
	self.anim:SetScale(image_scale)
end

function ItemParcel:Open()
	self.clicked = true
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	
	self:Shrink()
	
	self:PlayAnim("open_pre", "open", "skin_loop")
	
	self.inst:DoTaskInTime(0.9, function()
		local from = self:GetPosition()
		local to = Vector3( from.x, from.y + 120, 0 )
		self:MoveTo( from, to, 0.12 )
	end)
	
	self.inst:DoTaskInTime(1.3, function()
		self.item_name:Show()
	end)

	if self.clickFn then 
		self.clickFn(self.type, self.name, self.item_id) 
	end
end

function ItemParcel:IsOpened()
	return self.anim:GetAnimState():IsCurrentAnimation("skin_loop")
end

function ItemParcel:CloseOut()
	local t = math.random() * 0.7
	self.inst:DoTaskInTime(t, function()
		self.anim:GetAnimState():PlayAnimation("skin_out")

		self.inst:DoTaskInTime(0.5, function()
			self.item_name:ScaleTo(1,0,0.5)
		end)
	end)
end

function ItemParcel:IsClosed()
	return self.anim:GetAnimState():IsCurrentAnimation("skin_out") and self.anim:GetAnimState():AnimDone()
end

function ItemParcel:OnControl(control, down)
	if control == CONTROL_ACCEPT and not down and not self.anim:GetAnimState():IsCurrentAnimation("appear") then
		if not self.clicked then
			self:Open()
			return true
		else
			if self.close_cb ~= nil then
				self.close_cb()
			end
			return true
		end
	end
end


return ItemParcel

