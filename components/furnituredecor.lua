local function onenabled(self, enabled)
    if enabled then
        self.inst:AddTag("furnituredecor")
    else
        self.inst:RemoveTag("furnituredecor")
    end
end

local FurnitureDecor = Class(function(self, inst)
    self.inst = inst

    self.enabled = true
    self.decor_animation = "idle"

    --self.onputonfurniture = nil

    -- NOTE: Recommended to add to pristine state, for optimization.
    self.inst:AddTag("furnituredecor")
end,
nil,
{
    enabled = onenabled,
})

function FurnitureDecor:OnRemoveFromEntity()
    self.inst:RemoveTag("furnituredecor")
end

function FurnitureDecor:SetEnabled(enabled)
    if self.enabled ~= enabled then
        self.enabled = enabled
    end
end

function FurnitureDecor:PutOnFurniture(furniture)
    if self.onputonfurniture then
        self.onputonfurniture(self.inst, furniture)
    end
end

return FurnitureDecor