local assets =
{
    Asset("ANIM", "anim/sapling.zip"),
    Asset("ANIM", "anim/sapling_diseased_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local moon_assets =
{
    Asset("ANIM", "anim/sapling_moon.zip"),
    Asset("ANIM", "anim/sapling_diseased_moon.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "twigs",
    "dug_sapling",
    "spoiled_food",
}

local moon_prefabs =
{
    "twigs",
    "dug_sapling_moon",
    "spoiled_food",
}

local function ontransplantfn(inst)
    inst.components.pickable:MakeEmpty()
end

local function dig_up(inst, worker)
    if inst.components.pickable ~= nil and inst.components.lootdropper ~= nil then
        local withered = inst.components.witherable ~= nil and inst.components.witherable:IsWithered()

        if inst.components.pickable:CanBePicked() then
            inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        end

        inst.components.lootdropper:SpawnLootPrefab(
            (withered and "twigs")
            or (inst._is_moon and "dug_sapling_moon")
            or "dug_sapling"
        )
    end
    inst:Remove()
end

local function onpickedfn(inst, picker)
    inst.AnimState:PlayAnimation("picked", false)
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("sway", true)
end

local function makeemptyfn(inst)
    if not POPULATING and
        (   inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered() or
            inst.AnimState:IsCurrentAnimation("idle_dead")
        ) then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("empty", false)
    else
        inst.AnimState:PlayAnimation("empty")
    end
end

local function makebarrenfn(inst, wasempty)
    if not POPULATING and
        (   inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered()
        ) then
        inst.AnimState:PlayAnimation(wasempty and "empty_to_dead" or "full_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end

local function moonconversionoverridefn(inst)
	inst._is_moon = true
	inst.AnimState:SetBank("sapling_moon")
	inst.AnimState:SetBuild("sapling_moon")

	inst.prefab = "sapling_moon"

	inst:RemoveComponent("halloweenmoonmutable")

	return inst, nil
end

local function sapling_common(inst, is_moon)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sapling.png")

    inst.AnimState:SetRayTestOnBB(true)
    local anims_name = (is_moon and "sapling_moon") or "sapling"
    inst.AnimState:SetBank(anims_name)
    inst.AnimState:SetBuild(anims_name)
    inst.AnimState:PlayAnimation("sway", true)

    inst:AddTag("plant")
    inst:AddTag("renewable")
	inst:AddTag("silviculture") -- for silviculture book

    --witherable (from witherable component) added to pristine state for optimization
    inst:AddTag("witherable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * 2)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"

    inst.components.pickable:SetUp("twigs", TUNING.SAPLING_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.ontransplantfn = ontransplantfn
    inst.components.pickable.makebarrenfn = makebarrenfn

    inst:AddComponent("witherable")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    if not GetGameModeProperty("disable_transplanting") then
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(dig_up)
        inst.components.workable:SetWorkLeft(1)
    end

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
    MakeNoGrowInWinter(inst)
    MakeHauntableIgnite(inst)
    ---------------------
    inst._is_moon = is_moon

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/sapling").master_postinit(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    sapling_common(inst, false)

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("halloweenmoonmutable")
	inst.components.halloweenmoonmutable:SetConversionOverrideFn(moonconversionoverridefn)

    return inst
end

local function moon_fn()
    local inst  = CreateEntity()

    sapling_common(inst, true)

	inst:SetPrefabNameOverride("sapling")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("sapling", fn, assets, prefabs),
        Prefab("sapling_moon", moon_fn, moon_assets, moon_prefabs)
