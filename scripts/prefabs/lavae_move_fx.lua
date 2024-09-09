local assets =
{
    Asset("ANIM", "anim/lavae_move_fx.zip"),
}

local function PlayFX(proxy, variation, scale)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("lava_trail_fx")
    inst.AnimState:SetBuild("lavae_move_fx")
    inst.AnimState:PlayAnimation("trail"..tostring(variation))
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    if proxy._colour ~= nil then
        inst.AnimState:SetMultColour(unpack(proxy._colour))
    end

    inst:ListenForEvent("animover", inst.Remove)
end

local function OnRandDirty(inst)
    if inst._complete or inst._rand:value() <= 0 then
        return
    end

    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, PlayFX, inst._rand:value(), inst._scale:value() / 7 * (inst._max_scale - inst._min_scale) + inst._min_scale)
    inst._complete = true
end

local function SetVariation(inst, rand, scale)
    inst._rand:set(rand)
    --scale range from inst._min_scale -> inst._max_scale
    inst._scale:set(math.clamp(math.floor(math.floor((scale - inst._min_scale) / (inst._max_scale - inst._min_scale) * 7 + .5)), 0, 7))
end

local function common_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst._rand = net_tinybyte(inst.GUID, "lavae_move_fx._rand", "randdirty")
    inst._scale = net_tinybyte(inst.GUID, "lavae_move_fx._scale")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst._complete = false
        inst:ListenForEvent("randdirty", OnRandDirty)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetVariation = SetVariation

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

local function lavae_fn()
    local inst = common_fn()
    inst._min_scale = .5
    inst._max_scale = 1.3
    return inst
end

local function hutch_fn()
    local inst = common_fn()
    inst._min_scale = .3
    inst._max_scale = 1.5
    inst._colour = { .6, 1, 1, 1 }
    return inst
end

return Prefab("lavae_move_fx", lavae_fn, assets),
    Prefab("hutch_move_fx", hutch_fn, assets)
