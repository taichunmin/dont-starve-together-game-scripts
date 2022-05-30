local assets =
{
    Asset("ANIM", "anim/tree_marsh.zip"),
    Asset("MINIMAP_IMAGE", "marshtree"),
    Asset("MINIMAP_IMAGE", "marshtree_stump"),
    Asset("MINIMAP_IMAGE", "marshtree_burnt"),
}

local prefabs =
{
    "log",
    "twigs",
    "charcoal",
}

SetSharedLootTable( 'marsh_tree',
{
    {'twigs',  1.0},
    {'log',    0.2},
})

local function sway(inst)
    inst.AnimState:PushAnimation("sway"..math.random(4).."_loop", true)
end

local function chop_tree(inst, chopper, chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation("chop")
    sway(inst)
end

local function set_stump(inst)
    inst:RemoveComponent("workable")
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    if not inst:HasTag("burnt") then
        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableIgnite(inst)
    end
    RemovePhysicsColliders(inst)
    inst:AddTag("stump")
    inst.MiniMapEntity:SetIcon("marshtree_stump.png")
end

local function dig_up_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

local function chop_down_tree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation("fall")
    inst.AnimState:PushAnimation("stump", false)
    set_stump(inst)
    inst.components.lootdropper:DropLoot()

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
end

local function chop_down_burnt_tree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation("burnt_chop")
    set_stump(inst)
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:DropLoot()
end

local function OnBurnt(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    MakeHauntableWork(inst)

    inst.components.lootdropper:SetLoot({"charcoal"})

    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
    inst.AnimState:PlayAnimation("burnt_idle", true)
    inst:AddTag("burnt")
    inst.MiniMapEntity:SetIcon("marshtree_burnt.png")
end

local function inspect_tree(inst)
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
    if data ~= nil then
        if data.stump then
            set_stump(inst)
            inst.AnimState:PlayAnimation("stump", false)
            if data.burnt or inst:HasTag("burnt") then
                DefaultBurntFn(inst)
            else
                inst:AddComponent("workable")
                inst.components.workable:SetWorkAction(ACTIONS.DIG)
                inst.components.workable:SetOnFinishCallback(dig_up_stump)
                inst.components.workable:SetWorkLeft(1)
            end
        elseif data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.MiniMapEntity:SetIcon("marshtree.png")
    inst.MiniMapEntity:SetPriority(-1)

    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.AnimState:SetBuild("tree_marsh")
    inst.AnimState:SetBank("marsh_tree")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeSmallPropagator(inst)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('marsh_tree')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(10)
    inst.components.workable:SetOnWorkCallback(chop_tree)
    inst.components.workable:SetOnFinishCallback(chop_down_tree)

    MakeHauntableWorkAndIgnite(inst)

    local color = 0.5 + math.random() * 0.5
    inst.AnimState:SetMultColour(color, color, color, 1)
    sway(inst)
    inst.AnimState:SetTime(math.random()*2)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_tree

    inst.OnSave = onsave
    inst.OnLoad = onload
    MakeSnowCovered(inst)

    return inst
end

return Prefab("marsh_tree", fn, assets)
