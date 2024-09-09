local assets =
{
    Asset("ANIM", "anim/moonglass_bigwaterfall.zip"),
}

local prefabs =
{
    "halloween_moonpuff",
}

SetSharedLootTable("smallfalls",
{
    {'moonglass', 1.0},
    {'moonglass', 0.5},
})

local function set_full(inst)
    inst:SetPhysicsRadiusOverride(2.5)
    inst:RemoveTag("NOCLICK")

    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)

    local reset_fx = SpawnPrefab("halloween_moonpuff")
    reset_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    if inst._type ~= nil then
        inst.AnimState:PlayAnimation("water_small"..inst._type, true)
    end
end

local function OnCaveFullMoon(inst, fullmoon)
    -- Assume we only ran this function if we're mined out.
    if TUNING.GROTTO_MOONGLASS_REGROW_CHANCE > math.random() then
        set_full(inst)
        inst:StopWatchingWorldState("iscavefullmoon", OnCaveFullMoon)
    end
end

local function set_fully_mined(inst)
    inst:SetPhysicsRadiusOverride(nil)
    inst:AddTag("NOCLICK")

    if inst._type ~= nil then
        inst.AnimState:PlayAnimation("water_small"..inst._type.."_mined", true)
    end

    inst:WatchWorldState("iscavefullmoon", OnCaveFullMoon)
end

local function on_mined(inst, worker, workleft)
    if workleft <= 0 then
        local glass_pos = inst:GetPosition()

        SpawnPrefab("rock_break_fx").Transform:SetPosition(glass_pos:Get())

        if worker ~= nil then
            local worker_pos = worker:GetPosition()

            inst.components.lootdropper:DropLoot(worker_pos)
        else
            inst.components.lootdropper:DropLoot(glass_pos)
        end

        set_fully_mined(inst)
    end
end

local function workableload(inst, data)
    if data.workleft <= 0 then
        set_fully_mined(inst)
    end
end

local function falls1()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("moonglass_bigwaterfall")
    inst.AnimState:SetBank("moonglass_bigwaterfall")
    inst.AnimState:PlayAnimation("water_small1", true)
    inst.AnimState:SetLightOverride(0.1)

    inst.no_wet_prefix = true

	inst:SetDeploySmartRadius(1.5)

    inst:SetPhysicsRadiusOverride(2.5)

    inst:AddTag("moonglass")

    inst:SetPrefabNameOverride("moonglass_rock")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._type = 1

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("workable")
    inst.components.workable.savestate = true
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:SetOnWorkCallback(on_mined)
    inst.components.workable:SetOnLoadFn(workableload)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("moonglass_prop")
    inst.components.lootdropper.max_speed = 1.2
    inst.components.lootdropper.min_speed = 0.3

    return inst
end

local function falls2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("moonglass_bigwaterfall")
    inst.AnimState:SetBank("moonglass_bigwaterfall")
    inst.AnimState:PlayAnimation("water_small2", true)
    inst.AnimState:SetLightOverride(0.1)

    inst.no_wet_prefix = true

	inst:SetDeploySmartRadius(1)

    inst:SetPhysicsRadiusOverride(2.5)

    inst:AddTag("moonglass")

    inst:SetPrefabNameOverride("moonglass_rock")

    inst.scrapbook_proxy = "grotto_pool_small"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._type = 2

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("workable")
    inst.components.workable.savestate = true
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:SetOnWorkCallback(on_mined)
    inst.components.workable:SetOnLoadFn(workableload)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("moonglass_prop")
    inst.components.lootdropper.max_speed = 1.2
    inst.components.lootdropper.min_speed = 0.3

    return inst
end

return Prefab("grotto_waterfall_small1", falls1, assets),
        Prefab("grotto_waterfall_small2", falls2, assets)
