local Widget = require "widgets/widget"
local Image = require "widgets/image"

-- NOTES(JBK): These constants are from MiniMapRenderer ZOOM_CLAMP_MIN and ZOOM_CLAMP_MAX
local ZOOM_CLAMP_MIN = 1
local ZOOM_CLAMP_MAX = 20

local MapWidget = Class(Widget, function(self, mapscreen)
    Widget._ctor(self, "MapWidget") -- NOTES(JBK): Do not change this unless you also change MiniMap's "MapWidget"! Modders use a different name for your widget or take into account texture size changes.
	self.owner = ThePlayer

    self.mapscreen = mapscreen

    self.bg = self:AddChild(Image("images/hud.xml", "map.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.bg.inst.ImageWidget:SetBlendMode( BLENDMODE.Premultiplied )

	self.centerreticle = self.bg:AddChild(Image("images/hud.xml", "cursor02.tex"))

    self.minimap = TheWorld.minimap.MiniMap

    self.img = self:AddChild(Image())
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img.inst.ImageWidget:SetBlendMode( BLENDMODE.Additive )

	self.lastpos = nil
	self.minimap:ResetOffset()
	self:StartUpdating()

end)

function MapWidget:WorldPosToMapPos(x,y,z)
    return self.minimap:WorldPosToMapPos(x,y,z)
end

function MapWidget:MapPosToWorldPos(x,y,z)
    return self.minimap:MapPosToWorldPos(x,y,z)
end

function MapWidget:SetTextureHandle(handle)
	self.img.inst.ImageWidget:SetTextureHandle( handle )
end

function MapWidget:OnZoomIn(negativedelta)
	if self.shown and self.minimap:GetZoom() > ZOOM_CLAMP_MIN then
		self.minimap:Zoom(negativedelta or -0.1)
		return true
	end
	return false
end

function MapWidget:OnZoomOut(positivedelta)
	if self.shown and self.minimap:GetZoom() < ZOOM_CLAMP_MAX then
		self.minimap:Zoom(positivedelta or 0.1)
		return true
	end
	return false
end

function MapWidget:GetZoom()
	return self.minimap:GetZoom()
end

function MapWidget:UpdateTexture()
	local handle = self.minimap:GetTextureHandle()
	self:SetTextureHandle( handle )
end

function MapWidget:UpdateMapscreenDecorations()
    if self.mapscreen and self.mapscreen.decorationdata then
        self.mapscreen.decorationdata.dirty = true
    end
end

function MapWidget:OnUpdate(dt)

	if not self.shown then return end

	if TheInput:IsControlPressed(CONTROL_PRIMARY) then
		local pos = TheInput:GetScreenPosition()
		if self.lastpos then
			-- NOTES(JBK): The magic constant 9 comes from the scaler in MiniMapRenderer ZOOM_MODIFIER.
			local scale = 2 / 9
			local dx = scale * ( pos.x - self.lastpos.x )
			local dy = scale * ( pos.y - self.lastpos.y )
			self.minimap:Offset( dx, dy )
            self:UpdateMapscreenDecorations()
		end

		self.lastpos = pos
	else
		self.lastpos = nil
	end
end

function MapWidget:Offset(dx,dy)
	self.minimap:Offset(dx,dy)
    self:UpdateMapscreenDecorations()
end


function MapWidget:OnShow()
	self.minimap:ResetOffset()
end

function MapWidget:OnHide()
	self.lastpos = nil
end
return MapWidget
