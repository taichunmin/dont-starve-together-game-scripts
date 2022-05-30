local assets =
{
    Asset("ANIM", "anim/boat_water_fx2.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()

    local anim = inst.entity:AddAnimState()
    anim:SetBank("boat_water_fx")
    anim:SetBuild("boat_water_fx2")
    anim:PlayAnimation("idle_loop_1")
    anim:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.BOAT_TRAIL)
    anim:SetOrientation(ANIM_ORIENTATION.OnGround)
    anim:SetLayer(LAYER_BELOW_GROUND)
    anim:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    inst:AddComponent("boattrailmover")

    inst:ListenForEvent("animover", inst.Remove)
	inst:DoTaskInTime(80 * FRAMES, inst.Remove)

    return inst
end

return Prefab("boat_water_fx", fn, assets)
