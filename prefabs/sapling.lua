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
    "disease_puff",
    "diseaseflies",
    "spoiled_food",
}

local moon_prefabs =
{
    "twigs",
    "dug_sapling_moon",
    "disease_puff",
    "diseaseflies",
    "spoiled_food",
}

local function SpawnDiseasePuff(inst)
    SpawnPrefab("disease_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function SetDiseaseBuild(inst)
    inst.AnimState:SetBuild((inst._is_moon and "sapling_diseased_moon") or "sapling_diseased_build")
end

local function ondiseasedfn(inst)
    inst.components.pickable:ChangeProduct("spoiled_food")
    if POPULATING then
        SetDiseaseBuild(inst)
    else
        if inst.components.pickable:CanBePicked() then
            inst.AnimState:PlayAnimation("transform")
            inst.AnimState:PushAnimation("sway", true)
        elseif inst.components.witherable ~= nil
            and inst.components.witherable:IsWithered()
            or inst.components.pickable:IsBarren() then
            inst.AnimState:PlayAnimation("transform_dead")
            inst.AnimState:PushAnimation("idle_dead", false)
        else
            inst.AnimState:PlayAnimation("transform_empty")
            inst.AnimState:PushAnimation("empty", false)
        end
        inst:DoTaskInTime(6 * FRAMES, SpawnDiseasePuff)
        inst:DoTaskInTime(10 * FRAMES, SetDiseaseBuild)
    end
end

local function makediseaseable(inst)
    if inst.components.diseaseable == nil then
        inst:AddComponent("diseaseable")
        inst.components.diseaseable:SetDiseasedFn(ondiseasedfn)
    end
end

local function ontransplantfn(inst)
    inst.components.pickable:MakeEmpty()
    makediseaseable(inst)
    inst.components.diseaseable:RestartNearbySpread()
end

local function dig_up(inst, worker)
    if inst.components.pickable ~= nil and inst.components.lootdropper ~= nil then
        local withered = inst.components.witherable ~= nil and inst.components.witherable:IsWithered()
        local diseased = inst.components.diseaseable ~= nil and inst.components.diseaseable:IsDiseased()

        if diseased then
            SpawnDiseasePuff(inst)
        elseif inst.components.diseaseable ~= nil and inst.components.diseaseable:IsBecomingDiseased() then
            SpawnDiseasePuff(inst)
            if worker ~= nil then
                worker:PushEvent("digdiseasing")
            end
        end

        if inst.components.pickable:CanBePicked() then
            inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        end

        inst.components.lootdropper:SpawnLootPrefab(
            ((withered or diseased) and "twigs")
            or (inst._is_moon and "dug_sapling_moon")
            or "dug_sapling"
        )
    end
    inst:Remove()
end

local function onpickedfn(inst, picker)
    inst.AnimState:PlayAnimation("picked", false)
    if inst.components.diseaseable ~= nil then
        if inst.components.diseaseable:IsDiseased() then
            SpawnDiseasePuff(inst)
        elseif inst.components.diseaseable:IsBecomingDiseased() then
            SpawnDiseasePuff(inst)
            if picker ~= nil then
                picker:PushEvent("pickdiseasing")
            end
        end
    end
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

local function OnPreLoad(inst, data)
    if data ~= nil and (data.pickable ~= nil and data.pickable.transplanted or data.diseaseable ~= nil) then
        makediseaseable(inst)
    end
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

    inst.OnPreLoad = OnPreLoad
    inst.MakeDiseaseable = makediseaseable
    inst._is_moon = is_moon

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/sapling").master_postinit(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    sapling_common(inst, false)

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
