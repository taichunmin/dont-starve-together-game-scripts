local assets =
{
    Asset("ANIM", "anim/float_fx.zip"),
}

local prefabs =
{
}


local function common_fn(is_front)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.persists = false

    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")
    inst:AddTag("ignorewalkableplatforms")
    inst.AnimState:SetBuild("float_fx")
    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    if is_front then
        inst.AnimState:SetBank("float_front")
        inst.AnimState:PlayAnimation("idle_front_small", true)
    else
        inst.AnimState:SetBank("float_back")
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:PlayAnimation("idle_back_small", true)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function front_fn()
    return common_fn(true)
end

local function back_fn()
    return common_fn(false)
end

return Prefab("float_fx_front", front_fn, assets, prefabs),
       Prefab("float_fx_back", back_fn, assets, prefabs)
