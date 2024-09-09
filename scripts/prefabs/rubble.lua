local assets =
{
    Asset("ANIM", "anim/ruins_rubble.zip"),
}

local prefabs =
{
    "rocks",
    "thulecite",
    "cutstone",
    "trinket_6",
    "gears",
    "nightmarefuel",
    "greengem",
    "orangegem",
    "yellowgem",
    "collapse_small",
}

local function workcallback(inst, worker, workleft)
    if workleft <= 0 then
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("rock")
        inst.components.lootdropper:DropLoot()
        inst:Remove()
    else
        inst.AnimState:PlayAnimation(
            (workleft < TUNING.ROCKS_MINE / 3 and "low") or
            (workleft < TUNING.ROCKS_MINE * 2 / 3 and "med") or
            "full"
        )
    end
end

local function common_fn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("rubble")
    inst.AnimState:SetBuild("ruins_rubble")
    inst.AnimState:PlayAnimation(anim)

    inst:AddTag("cavedweller")

    --inst.MiniMapEntity:SetIcon("rock.png")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = anim

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"rocks"})
    inst.components.lootdropper.numrandomloot = 1
    inst.components.lootdropper:AddRandomLoot("rocks"         , 0.99)
    inst.components.lootdropper:AddRandomLoot("cutstone"      , 0.10)
    inst.components.lootdropper:AddRandomLoot("trinket_6"     , 0.10) -- frayed wires
    inst.components.lootdropper:AddRandomLoot("gears"         , 0.01)
    inst.components.lootdropper:AddRandomLoot("greengem"      , 0.01)
    inst.components.lootdropper:AddRandomLoot("yellowgem"     , 0.01)
    inst.components.lootdropper:AddRandomLoot("orangegem"     , 0.01)
    inst.components.lootdropper:AddRandomLoot("nightmarefuel" , 0.01)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)

    inst.components.workable:SetOnWorkCallback(workcallback)

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "rubble"

    MakeHauntableWork(inst)

    return inst
end

local function rubble_fn()
    local inst = common_fn("full")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)

    return inst
end

local function rubble_med_fn()
    local inst = common_fn("med")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:WorkedBy(inst, TUNING.ROCKS_MINE * 0.34)

    return inst
end

local function rubble_low_fn()
    local inst = common_fn("low")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:WorkedBy(inst, TUNING.ROCKS_MINE * 0.67)

    return inst
end

return Prefab("rubble", rubble_fn, assets, prefabs),
    Prefab("rubble_med", rubble_med_fn, assets, prefabs),
    Prefab("rubble_low", rubble_low_fn, assets, prefabs)
