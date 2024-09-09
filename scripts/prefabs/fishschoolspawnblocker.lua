
local function ontimerdone(inst)
	inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because schoolspawner use FindEntities on "fishschoolspawnblocker" tag
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst:AddTag("fishschoolspawnblocker")

	inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    inst.components.timer:StartTimer("remove", TUNING.SCHOOL_SPAWNER_BLOCKER_LIFETIME)

    return inst
end

return Prefab("fishschoolspawnblocker", fn)
