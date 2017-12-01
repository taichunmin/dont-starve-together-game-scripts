require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/acorn.zip"),
}

local prefabs =
{
    "acorn_sapling",
    "acorn_cooked",
    "spoiled_food",
    "winter_deciduoustree",
}

local function plant(inst, growtime)
    local sapling = SpawnPrefab("acorn_sapling")
    sapling:StartGrowing()
    sapling.Transform:SetPosition(inst.Transform:GetWorldPosition())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst:Remove()
end

local function domonsterstop(ent)
    ent.monster_stop_task = nil
    ent:StopMonster()
end

local function ondeploy(inst, pt)
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get())
    local timeToGrow = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
    plant(inst, timeToGrow)

    -- Pacify a nearby monster tree
    local ent = FindEntity(inst, TUNING.DECID_MONSTER_ACORN_CHILL_RADIUS, nil, {"birchnut", "monster"}, {"stump", "burnt", "FX", "NOCLICK","DECOR","INLIMBO"})
    if ent ~= nil then
        if ent.monster_start_task ~= nil then
            ent.monster_start_task:Cancel()
            ent.monster_start_task = nil
        end
        if ent.monster and
            ent.monster_stop_task == nil and
            not (ent.components.burnable ~= nil and ent.components.burnable:IsBurning()) and
            not (ent:HasTag("stump") or ent:HasTag("burnt")) then
            ent.monster_stop_task = ent:DoTaskInTime(math.random(0, 3), domonsterstop)
        end
    end
end

local function OnLoad(inst, data)
    if data and data.growtime then
        plant(inst, data.growtime)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("acorn")
    inst.AnimState:SetBuild("acorn")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("icebox_valid")
    inst:AddTag("cattoy")
    inst:AddTag("show_spoilage")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("cookable")
    inst.components.cookable.product = "acorn_cooked"

    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.foodtype = FOODTYPE.RAW

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy = ondeploy

    inst:AddComponent("winter_treeseed")
    inst.components.winter_treeseed:SetTree("winter_deciduoustree")

    MakeHauntableLaunchAndIgnite(inst)

    inst.OnLoad = OnLoad

    return inst
end

local function cooked()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("acorn")
    inst.AnimState:SetBuild("acorn")
    inst.AnimState:PlayAnimation("cooked")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.foodtype = "SEEDS"

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("acorn", fn, assets, prefabs),
       Prefab("acorn_cooked", cooked, assets),
       MakePlacer("acorn_placer", "acorn", "acorn", "idle_planted")
