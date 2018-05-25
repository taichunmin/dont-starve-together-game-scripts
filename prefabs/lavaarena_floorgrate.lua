local assets =
{
    Asset("ANIM", "anim/lavaarena_floorgrate.zip"),
}

local prefabs =
{
    "ember_short_fx",
}

local function CreateLavaEntity()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    --[[Non-networked entity]]

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBuild("lavaarena_floorgrate")
    inst.AnimState:SetBank("lavaarena_floorgrate")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetDeltaTimeMultiplier(.8)

    inst.AnimState:Hide("bars_top")
    inst.AnimState:Hide("bars bottom")
    inst.AnimState:Hide("floor")

    inst.persists = false
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    return inst
end

local function SpawnEmber(inst)
    SpawnPrefab("ember_short_fx").entity:SetParent(inst.entity)
end

local function OnLavaSpeedDirty(inst)
    if inst.lava ~= nil then
        inst.lava.AnimState:SetDeltaTimeMultiplier(inst._lavaspeed:value() * .4 / 7 + .8)
    end
end

local function lavaarena_floorgratefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("lavaarena_floorgrate")
    inst.AnimState:SetBank("lavaarena_floorgrate")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(1)

    inst.Transform:SetScale(.95, .95, .95)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("NOCLICK")

    inst.AnimState:Hide("Layer 25") -- lava effect

    inst._lavaspeed = net_tinybyte(inst.GUID, "lavaarena_floorgrate._lavaspeed", "lavaspeeddirty")

    if not TheNet:IsDedicated() then
        inst.lava = CreateLavaEntity()
        inst.lava.entity:SetParent(inst.entity)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lavaspeeddirty", OnLavaSpeedDirty)

        return inst
    end

    inst._lavaspeed:set(math.random(0, 7))
    OnLavaSpeedDirty(inst)

    inst:DoPeriodicTask(21.1 + math.random() * 9, SpawnEmber, math.random() * 30)

    return inst
end

return Prefab("lavaarena_floorgrate", lavaarena_floorgratefn, assets, prefabs)
