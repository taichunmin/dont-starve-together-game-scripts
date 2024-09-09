
local TODRAW_MUST_TAGS = { "_inventoryitem" }
local TODRAW_CANT_TAGS = { "INLIMBO", "notdrawable" }
function FindEntityToDraw(target, tool)
    if target ~= nil then
        local x, y, z = target.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, 1.5, TODRAW_MUST_TAGS, TODRAW_CANT_TAGS)) do
            if v ~= target and v ~= tool and v.entity:IsVisible() then
                return v
            end
        end
    end
end

local DrawingTool = Class(function(self, inst)
    self.inst = inst

    self.ondrawfn = nil
end)

function DrawingTool:SetOnDrawFn(fn)
    self.ondrawfn = fn
end

function DrawingTool:GetImageToDraw(target)
    local ent = FindEntityToDraw(target, self.inst)
    if ent == nil then
        return
    end

    local atlas, bgimage, bgatlas
    local image = FunctionOrValue(ent.drawimageoverride, ent, target) or (#(ent.components.inventoryitem.imagename or "") > 0 and ent.components.inventoryitem.imagename) or ent.prefab or nil
    if image ~= nil then
        atlas = FunctionOrValue(ent.drawatlasoverride, ent, target) or (#(ent.components.inventoryitem.atlasname or "") > 0 and ent.components.inventoryitem.atlasname) or nil
        if ent.inv_image_bg ~= nil and ent.inv_image_bg.image ~= nil and ent.inv_image_bg.image:len() > 4 and ent.inv_image_bg.image:sub(-4):lower() == ".tex" then
            bgimage = ent.inv_image_bg.image:sub(1, -5)
            bgatlas = ent.inv_image_bg.atlas ~= GetInventoryItemAtlas(ent.inv_image_bg.image) and ent.inv_image_bg.atlas or nil
        end
    end
    return image, ent, atlas, bgimage, bgatlas
end

function DrawingTool:Draw(target, image, src, atlas, bgimage, bgatlas)
    if target ~= nil and target.components.drawable ~= nil then
        target.components.drawable:OnDrawn(image, src, atlas, bgimage, bgatlas)
        if self.ondrawfn ~= nil then
            self.ondrawfn(self.inst, target, image, src, atlas, bgimage, bgatlas)
        end
    end
end

return DrawingTool
