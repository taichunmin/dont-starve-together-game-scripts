local driftwood_tall_assets =
{
    Asset("ANIM", "anim/driftwood_tall.zip"),
    Asset("MINIMAP_IMAGE", "driftwood_small1"),
}

local driftwood_small1_assets =
{
    Asset("ANIM", "anim/driftwood_small1.zip"),
    Asset("MINIMAP_IMAGE", "driftwood_small1"),
}

local driftwood_small2_assets =
{
    Asset("ANIM", "anim/driftwood_small2.zip"),
    Asset("MINIMAP_IMAGE", "driftwood_small1"),
}

local prefabs =
{
    "driftwood_log",
    "twigs",
    "charcoal",
}

SetSharedLootTable( 'driftwood_tree',
{
    {'twigs',           1.0},
    {'twigs',           1.0},
    {'driftwood_log',   1.0},
    {'driftwood_log',   1.0},
    {'driftwood_log',   1.0},
    {'driftwood_log',   1.0},
})

SetSharedLootTable( 'driftwood_small',
{
    {'twigs',           1.0},
    {'driftwood_log',   1.0},
    {'driftwood_log',   1.0},
})

local function on_chop(inst, chopper, remaining_chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("turnoftides/common/together/driftwood/chop")
    end

    if remaining_chops > 0 then
        inst.AnimState:PlayAnimation("chop")
    end
end

local function dig_up_driftwood_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("driftwood_log")
    inst:Remove()
end

local function make_stump(inst, is_burnt)
    inst:RemoveComponent("workable")
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    if not is_burnt then
        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableIgnite(inst)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(dig_up_driftwood_stump)
        inst.components.workable:SetWorkLeft(1)
    end
    RemovePhysicsColliders(inst)
    inst:AddTag("stump")
end

local function on_chopped_down(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/appear_wood")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble",nil,.4)

    if inst.is_large then
        -- The tall driftwood tree has a different falling animations depending on its position
        -- relative to the character chopping it down. Also affects loot spawn location.
        local pt = inst:GetPosition()
        local theirpos = chopper:GetPosition()
        local he_right = (theirpos - pt):Dot(TheCamera:GetRightVec()) > 0
        if he_right then
            inst.AnimState:PlayAnimation("fallleft")
            inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
        else
            inst.AnimState:PlayAnimation("fallright")
            inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
        end
        inst.AnimState:PushAnimation("stump", false)
        make_stump(inst, false)
    else
        -- Small trees just crumble and die.
        inst.AnimState:PlayAnimation("fall")
        inst.components.lootdropper:DropLoot()
        inst:ListenForEvent("animover", inst.Remove)

        RemovePhysicsColliders(inst)
    end
end

local function on_chopped_down_burnt(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")

    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end

    inst.AnimState:PlayAnimation("chop_burnt")

    if not inst.is_large then
        make_stump(inst, true)
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:DropLoot()
end

local function on_burnt(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    MakeHauntableWork(inst)

    inst.components.lootdropper:SetChanceLootTable(nil)
    inst.components.lootdropper:SetLoot({"charcoal"})

    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(on_chopped_down_burnt)
    inst.AnimState:PlayAnimation("burnt")
    inst:AddTag("burnt")
end

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst:HasTag("stump") and "CHOPPED")
        or (inst.components.burnable ~= nil and
            inst.components.burnable:IsBurning() and
            "BURNING")
        or nil
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    if inst:HasTag("stump") then
        data.stump = true
    end
end

local function onload(inst, data)
    if data == nil then
        return
    end

    if data.stump then
        local is_burnt = data.burnt or inst:HasTag("burnt")

        make_stump(inst, is_burnt)

        inst.AnimState:PlayAnimation("stump", false)
        if is_burnt then
            DefaultBurntFn(inst)
        end
    elseif data.burnt and not inst:HasTag("burnt") then
        -- Make the appropriate driftwood burnt function, then immediately call it on the instance we're loading.
        on_burnt(inst)
    end
end

local function fn(type_name, is_large)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- Seems kind of counterintuitive, but the 'large' trees are taller, and have a smaller (tree-like) radius.
    local physics_size = is_large and .25 or 1
    MakeObstaclePhysics(inst, is_large and .25 or 1)

    -- All driftwood trees are sharing a single minimap icon, since they're functionally the same.
    inst.MiniMapEntity:SetIcon("driftwood_small1.png")
    inst.MiniMapEntity:SetPriority(-1)

    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.AnimState:SetBank("driftwood_"..type_name)
    inst.AnimState:SetBuild("driftwood_"..type_name)

    inst.AnimState:PlayAnimation("idle")

    inst:SetPrefabNameOverride("DRIFTWOOD_TREE")

    MakeSnowCoveredPristine(inst)

    if not is_large then
        inst.scrapbook_proxy = "driftwood_small1"
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst.is_large = is_large

    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnBurntFn(on_burnt)
    MakeMediumPropagator(inst)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable(is_large and "driftwood_tree" or "driftwood_small")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)

    -- Enable the two types of driftwood to be tuned separately.
    local work_amount = is_large and TUNING.DRIFTWOOD_TREE_CHOPS or TUNING.DRIFTWOOD_SMALL_CHOPS
    inst.components.workable:SetWorkLeft(work_amount)

    inst.components.workable:SetOnWorkCallback(on_chop)
    inst.components.workable:SetOnFinishCallback(on_chopped_down)

    MakeHauntableWorkAndIgnite(inst)

    local color = 0.7 + math.random() * 0.3
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable.nameoverride = "DRIFTWOOD_TREE"

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeSnowCovered(inst)

	return inst
end

local function driftwood_tall()
    return fn("tall", true)
end

local function driftwood_small1()
    return fn("small1")
end

local function driftwood_small2()
    return fn("small2")
end

return Prefab("driftwood_tall", driftwood_tall, driftwood_tall_assets, prefabs),
    Prefab("driftwood_small1", driftwood_small1, driftwood_small1_assets, prefabs),
    Prefab("driftwood_small2", driftwood_small2, driftwood_small2_assets, prefabs)
