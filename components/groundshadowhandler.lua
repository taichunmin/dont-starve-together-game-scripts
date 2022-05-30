local function groundshadowprefabfn()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst:AddTag("FX")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddDynamicShadow()

    return inst
end

local GroundShadowHandler = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)

    self.ground_shadow = groundshadowprefabfn()
end)

function GroundShadowHandler:OnRemoveEntity()
    if self.ground_shadow ~= nil then
        self.ground_shadow:Remove()
        self.ground_shadow = nil
    end
end

GroundShadowHandler.OnRemoveFromEntity = GroundShadowHandler.OnRemoveEntity

function GroundShadowHandler:SetSize(width, height)
    self.original_width = width
    self.original_height = height
    self.ground_shadow.DynamicShadow:SetSize(width, height)
end

local MAX_LERP_HEIGHT = 4
local MIN_SCALE = 0.3
local MAX_SCALE = 1.0
function GroundShadowHandler:OnUpdate(dt)
    if self.ground_shadow ~= nil and self.inst:IsValid() then
        local pos_x, pos_y, pos_z = self.inst.Transform:GetWorldPosition()

        local scale = Lerp(MAX_SCALE, MIN_SCALE, math.min(math.max(pos_y - 2, 1) / MAX_LERP_HEIGHT, 1))

        self.ground_shadow.Transform:SetPosition(pos_x, 0, pos_z)
        self.ground_shadow.DynamicShadow:SetSize(self.original_width * scale, self.original_height * scale)
    end
end

return GroundShadowHandler
