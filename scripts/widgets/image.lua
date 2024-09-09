local Widget = require "widgets/widget"

Image = Class(Widget, function(self, atlas, tex, default_tex)
    Widget._ctor(self, "Image")

    self.inst.entity:AddImageWidget()

    assert( ( atlas == nil and tex == nil ) or ( atlas ~= nil and tex ~= nil ) )

    self.tint = {1,1,1,1}

    if atlas and tex then
		self:SetTexture(atlas, tex, default_tex)
    end
end)

function Image:__tostring()
	return string.format("%s - %s:%s", self.name, self.atlas or "", self.texture or "")
end

function Image:DebugDraw_AddSection(dbui, panel)
    Image._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("Image")
    dbui.Indent() do
        -- Clearly show the bounds of blank and other hard-to-see
        -- images. (Great for debugging buttons.)
        local show_region = self.region_preview ~= nil
        local changed, show = dbui.Checkbox("white out image region", show_region)
        if changed then
            if show then
                self.region_preview = self:AddChild(Image("images/ui.xml", "white.tex"))
                self.region_preview:SetSize(self:GetSize())
            else
                self.region_preview:Kill()
                self.region_preview = nil
            end
        end

        -- SetTexture doesn't gracefully fail on bad input, so don't allow editing
        -- (we'd call SetTexture for every keystroke).
        local function image_from_atlastexture(label, atlastexture)
            dbui.SetNextTreeNodeOpen(true, dbui.constant.SetCond.Appearing)
            if dbui.TreeNode(label ..": ".. tostring(atlastexture)) then
                if atlastexture then
                    local parts = atlastexture:split()
                    if #parts == 2 then
                        dbui.AtlasImage(parts[1], parts[2], self:GetSize())
                    end
                end
                dbui.TreePop()
            end
        end
        -- Building a string to parse it is ugly, but not uglier than handling two
        -- input types. Must pass empty text for nil so AtlasImage isn't called on
        -- invalid data!
        image_from_atlastexture("atlas:texture", string.format("%s:%s", self.atlas or "", self.texture or ""))
        image_from_atlastexture("mouse over texture", self.mouseovertex)
        image_from_atlastexture("disabled texture", self.disabledtex)

        local changed, r,g,b,a = dbui.ColorEdit4("tint", unpack(self.tint))
        if changed then
            self:SetTint(r, g, b, a)
        end
        local w,h = self:GetSize()
        changed, w,h = dbui.DragFloat3("size", w,h,0, 1,1,1000)
        if changed then
            self:SetSize(w,h)
            if self.region_preview then
                self.region_preview:SetSize(self:GetSize())
            end
        end
    end
    dbui.Unindent()
end

function Image:SetAlphaRange(min, max)
	self.inst.ImageWidget:SetAlphaRange(min, max)
end

-- NOTE: the default_tex parameter is handled, but using
-- it will produce a bunch of warnings in the log.
function Image:SetTexture(atlas, tex, default_tex)
    assert( atlas ~= nil )
    assert( tex ~= nil )

	self.atlas = type(atlas) == "string" and resolvefilepath(atlas) or atlas
	self.texture = tex
	--print(atlas, tex)
    self.inst.ImageWidget:SetTexture(self.atlas, self.texture, default_tex)

	-- changing the texture may have changed our metrics
	self.inst.UITransform:UpdateTransform()
end

function Image:SetMouseOverTexture(atlas, tex)
	self.atlas = type(atlas) == "string" and resolvefilepath(atlas) or atlas
	self.mouseovertex = tex
end

function Image:SetDisabledTexture(atlas, tex)
	self.atlas = type(atlas) == "string" and resolvefilepath(atlas) or atlas
	self.disabledtex = tex
end

function Image:SetSize(w,h)
    if type(w) == "number" then
        self.inst.ImageWidget:SetSize(w,h)
    else
        self.inst.ImageWidget:SetSize(w[1],w[2])
    end
end

function Image:GetSize()
    local w, h = self.inst.ImageWidget:GetSize()
    return w, h
end

function Image:GetScaledSize()
    local w, h = self.inst.ImageWidget:GetSize()
    local w1, h1 = self:GetLooseScale()
    local w2, h2 = self:GetParent():GetLooseScale()
    return w*w1*w2, h*h1*h2
end

function Image:ScaleToSize(w, h)
	local w0, h0 = self.inst.ImageWidget:GetSize()
	local scalex = w / w0
	local scaley = h / h0
	self:SetScale(scalex, scaley, 1)
end

function Image:ScaleToSizeIgnoreParent(w, h)
    local w0, h0 = self.inst.ImageWidget:GetSize()
    local w1, h1 = self:GetParent():GetLooseScale()
	local scalex = w / w0
    local scaley = h / h0
    self:SetScale(scalex/w1, scaley/h1, 1)
end

function Image:SetTint(r,g,b,a)
    self.inst.ImageWidget:SetTint(r,g,b,a)
    self.tint = {r, g, b, a}
end

function Image:SetFadeAlpha(a, skipChildren)
	if not self.can_fade_alpha then return end

    self.inst.ImageWidget:SetTint(self.tint[1], self.tint[2], self.tint[3], self.tint[4] * a)
    Widget.SetFadeAlpha( self, a, skipChildren )
end

function Image:SetVRegPoint(anchor)
    self.inst.ImageWidget:SetVAnchor(anchor)
end

function Image:SetHRegPoint(anchor)
    self.inst.ImageWidget:SetHAnchor(anchor)
end

function Image:OnMouseOver()
	--print("Image:OnMouseOver", self)
	if self.enabled and self.mouseovertex then
		self.inst.ImageWidget:SetTexture(self.atlas, self.mouseovertex)
	end
	Widget.OnMouseOver( self )
end

function Image:OnMouseOut()
	--print("Image:OnMouseOut", self)
	if self.enabled and self.mouseovertex then
		self.inst.ImageWidget:SetTexture(self.atlas, self.texture)
	end
	Widget.OnMouseOut( self )
end

function Image:OnEnable()
    if self.mouse_over_self then
		self:OnMouseOver()
	else
		self.inst.ImageWidget:SetTexture(self.atlas, self.texture)
	end
end

function Image:OnDisable()
	self.inst.ImageWidget:SetTexture(self.atlas, self.disabledtex)
end

function Image:SetEffect(filename)
    self.inst.ImageWidget:SetEffect(filename)

    if filename == "shaders/ui_cc.ksh" then
        --hack for faked ambient lighting influence (common_postinit, quagmire.lua)
        --might need to get the colour from the gamemode???
        --If we're going to use the ui_cc shader again, we'll have to have a more sane implementation for setting the ambient lighting influence
        self.inst.ImageWidget:SetEffectParams( 0.784, 0.784, 0.784, 1)
    end
end

function Image:SetEffectParams(param1, param2, param3, param4)
	self.inst.ImageWidget:SetEffectParams(param1, param2, param3, param4)
end

function Image:SetEffectParams2(param1, param2, param3, param4)
    self.inst.ImageWidget:SetEffectParams2(param1, param2, param3, param4)
end

function Image:EnableEffectParams(enabled)
	self.inst.ImageWidget:EnableEffectParams(enabled)
end

function Image:EnableEffectParams2(enabled)
    self.inst.ImageWidget:EnableEffectParams2(enabled)
end

function Image:SetUVScale(xScale, yScale)
	self.inst.ImageWidget:SetUVScale(xScale, yScale)
end

function Image:SetUVMode(uvmode)
    self.inst.ImageWidget:SetUVMode(uvmode)
end

function Image:SetBlendMode(mode)
	self.inst.ImageWidget:SetBlendMode(mode)
end

function Image:SetRadiusForRayTraces(radius)
    self.inst.ImageWidget:SetRadiusForRayTraces(radius)
end

return Image
