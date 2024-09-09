--deprecated, kept for backward compatibility
local function PushTempFocus(inst, target, minrange, maxrange, priority)
    inst.components.focalpoint:PushTempFocus(target, minrange, maxrange, priority)
end

local function AttachToEntity(inst, entity)
    inst.entity:SetParent(entity)
    inst.components.focalpoint:RemoveAllFocusSources()
end

local function fn()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.persists = false

    inst:ListenForEvent("playeractivated", function(world, player) AttachToEntity(inst, player.entity) end, TheWorld)
    inst:ListenForEvent("playerdeactivated", function() AttachToEntity(inst, nil) end, TheWorld)

    inst:AddComponent("focalpoint")

    --deprecated, kept for backward compatibility
    inst.PushTempFocus = PushTempFocus

    return inst
end

return Prefab("focalpoint", fn)
