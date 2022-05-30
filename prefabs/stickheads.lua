local pig_assets =
{
    Asset("ANIM", "anim/pig_head.zip"),
}

local merm_assets =
{
    Asset("ANIM", "anim/merm_head.zip"),
}

local pig_prefabs =
{
    "flies",
    "pigskin",
    "twigs",
    "collapse_small",
}

local merm_prefabs =
{
    "flies",
    "spoiled_food",
    "twigs",
    "collapse_small",
}

local function OnFinish(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    if TheWorld.state.isfullmoon then
        inst.components.lootdropper:SpawnLootPrefab("nightmarefuel")
    end
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function OnWorked(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation(inst.awake and "idle_awake" or "idle_asleep")
    end
end

local function OnFullMoon(inst, isfullmoon)
    if not inst:HasTag("burnt") then
        if isfullmoon then
            if not inst.awake then
                inst.awake = true
                inst.AnimState:PlayAnimation("wake")
                inst.AnimState:PushAnimation("idle_awake", false)
            end
        elseif inst.awake then
            inst.awake = nil
            inst.AnimState:PlayAnimation("sleep")
            inst.AnimState:PushAnimation("idle_asleep", false)
        end
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnFinishHaunt(inst)
    if inst.awake and not (TheWorld.state.isfullmoon or inst:HasTag("burnt")) then
        inst.awake = nil
        inst.AnimState:PlayAnimation("sleep")
        inst.AnimState:PushAnimation("idle_asleep", false)
    end
end

local function OnHaunt(inst, haunter)
    --#HAUNTFIX
    --if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL and
        --inst.components.workable ~= nil and
        --inst.components.workable:CanBeWorked() then
        --inst.components.workable:WorkedBy(haunter, 1)
        --inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        --return true
    --else
    if not (inst.awake or inst:HasTag("burnt")) then
        inst.awake = true
        inst.AnimState:PlayAnimation("wake")
        inst.AnimState:PushAnimation("idle_awake")
        inst:DoTaskInTime(4, OnFinishHaunt)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
        return true
    end
    return false
end

local function create_common(bankandbuild)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
    inst:AddTag("beaverchewable")  -- for werebeaver

    inst.AnimState:SetBank(bankandbuild)
    inst.AnimState:SetBuild(bankandbuild)
    inst.AnimState:PlayAnimation("idle_asleep")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst.flies = inst:SpawnChild("flies")
    inst.awake = nil

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable.onfinish = OnFinish

    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:WatchWorldState("isfullmoon", OnFullMoon)
    OnFullMoon(inst, TheWorld.state.isfullmoon)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    return inst
end

local function create_pighead()
    local inst = create_common("pig_head")

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.components.lootdropper:SetLoot({"pigskin", "pigskin", "twigs", "twigs"})

    return inst
end

local function create_mermhead()
    local inst = create_common("merm_head")

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.components.lootdropper:SetLoot({"spoiled_food", "spoiled_food", "twigs", "twigs"})

    return inst
end

return Prefab("pighead", create_pighead, pig_assets, pig_prefabs),
    Prefab("mermhead", create_mermhead, merm_assets, merm_prefabs)
