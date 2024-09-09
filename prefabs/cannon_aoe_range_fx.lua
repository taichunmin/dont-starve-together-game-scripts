local assets =
{
    Asset("ANIM", "anim/cannon_aoe_range.zip"),
}

local assets_reticule =
{
    Asset("ANIM", "anim/cannon_reticule.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("cannon_aoe_range")
    inst.AnimState:SetBuild("cannon_aoe_range")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    return inst
end

local function fn_reticule()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("cannon_reticule")
    inst.AnimState:SetBuild("cannon_reticule")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    return inst
end

return Prefab("cannon_aoe_range_fx", fn, assets),
    Prefab("cannon_reticule_fx", fn_reticule, assets_reticule)
