local function oncandraw(self, candraw)
    if candraw then
        self.inst:AddTag("drawable")
    else
        self.inst:RemoveTag("drawable")
    end
end

local Drawable = Class(function(self, inst)
    self.inst = inst

    self.candraw = true
    self.imagename = nil
    self.atlasname = nil
    self.bgimagename = nil
    self.bgatlasname = nil
    self.ondrawnfn = nil

    --V2C: Recommended to explicitly add tags to prefab pristine state
    --On construciton, "drawable" tag is added by default
end,
nil,
{
    candraw = oncandraw,
})

function Drawable:OnRemoveFromEntity()
    self.inst:RemoveTag("drawable")
end

function Drawable:SetCanDraw(candraw)
    self.candraw = candraw
end

function Drawable:CanDraw()
    return self.candraw
end

function Drawable:SetOnDrawnFn(fn)
    self.ondrawnfn = fn
end

function Drawable:OnDrawn(imagename, imagesource, atlasname, bgimagename, bgatlasname)
    if imagename == "" then
        imagename = nil
    end
    if atlasname == "" then
        atlasname = nil
    end
    if bgimagename == "" then
        bgimagename = nil
    end
    if bgatlasname == "" then
        bgatlasname = nil
    end
    if self.imagename ~= imagename or self.atlasname ~= atlasname or self.bgimagename ~= bgimagename or self.bgatlasname ~= bgatlasname then
        self.imagename = imagename
        self.atlasname = atlasname
        self.bgimagename = bgimagename
        self.bgatlasname = bgatlasname
        if self.ondrawnfn ~= nil then
            self.ondrawnfn(self.inst, imagename, imagesource, atlasname, bgimagename, bgatlasname)
        end
    end
end

function Drawable:GetImage()
    return self.imagename
end

function Drawable:GetAtlas()
    return self.atlasname
end

function Drawable:GetBGImage()
    return self.bgimagename
end

function Drawable:GetBGAtlas()
    return self.bgatlasname
end

function Drawable:OnSave()
    return self.imagename ~= nil and {
            image = self.imagename,
            atlas = self.atlasname,
            bgimage = self.bgimagename,
            bgatlas = self.bgatlasname,
        } or nil
end

function Drawable:OnLoad(data)
    if data.image ~= nil then
        self:OnDrawn(data.image, nil, data.atlas, data.bgimage, data.bgatlas)
    end
end

return Drawable
