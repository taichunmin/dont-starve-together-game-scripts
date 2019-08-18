local assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
    Asset("INV_IMAGE", "carrat"),
}

local planted_assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
}

local prefabs =
{
    "plantmeat",
    "plantmeat_cooked",
    "carrot_seeds",
    "carrat_planted",
}

local planted_prefabs =
{
    "carrat",
}

local carratsounds =
{
    idle = "turnoftides/creatures/together/carrat/idle",
    hit = "turnoftides/creatures/together/carrat/hit",
    sleep = "turnoftides/creatures/together/carrat/sleep",
    death = "turnoftides/creatures/together/carrat/death",
    emerge = "turnoftides/creatures/together/carrat/emerge",
    submerge = "turnoftides/creatures/together/carrat/submerge",
    eat = "turnoftides/creatures/together/carrat/eat",
    stunned = "turnoftides/creatures/together/carrat/stunned",
}

SetSharedLootTable("carrat",
{
    {"plantmeat",       1.00},
    {"carrot_seeds",    0.33},
})

local brain = require("brains/carratbrain")

local function on_cooked_fn(inst, cooker, chef)
    inst.SoundEmitter:PlaySound(inst.sounds.hit)
end

local function on_dropped(inst)
    inst.sg:GoToState("stunned")
end

local function on_burnt(inst)
    inst.components.lootdropper:DropLoot()

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .75)
    inst.DynamicShadow:Enable(false)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("carrat")
    inst.AnimState:SetBuild("carrat_basic")
    inst.AnimState:PlayAnimation("planted")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = carratsounds -- sounds must be assigned before the stategraph

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.CARRAT.WALK_SPEED

    inst:SetStateGraph("SGcarrat")
    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater.strongstomach = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "plantmeat_cooked"
    inst.components.cookable:SetOnCookedFn(on_cooked_fn)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CARRAT.HEALTH)
    inst.components.health.murdersound = inst.sounds.death

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("carrat")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "carrat_body"

    -- Mostly copying MakeSmallBurnableCharacter, EXCEPT for the symbol following,
    -- because it looks bad paired with the burning of the planted prefab.
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))

    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false

    MakeTinyFreezableCharacter(inst, "carrat_body")

    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    inst:AddComponent("tradable")

    MakeHauntablePanic(inst)

    MakeFeedableSmallLivestock(inst, TUNING.CARRAT.PERISH_TIME, nil, on_dropped)

    return inst
end

local function on_picked(inst)
    local carrat = SpawnPrefab("carrat")
    carrat.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function on_ignite(inst)
    local carrat = SpawnPrefab("carrat")
    carrat.Transform:SetPosition(inst.Transform:GetWorldPosition())
    carrat.components.burnable:Ignite()

    -- Not sure why, but this needs to be delayed a frame or else the propagator will
    -- continue to try to update. Probably because it'd be stopped and started in the same frame otherwise.
    inst:DoTaskInTime(0, function(ignited_inst) ignited_inst:Remove() end)
end

local function dig_up(inst, digger)
    local carrat = SpawnPrefab("carrat")
    carrat.Transform:SetPosition(inst.Transform:GetWorldPosition())
    carrat.sg:GoToState("dug_up")

    inst:Remove()
end

local function play_planted_special_idle(inst)
    inst.AnimState:PlayAnimation("planted_ruffle")
end

local function play_first_planted_special_idle(inst)
    inst.AnimState:PlayAnimation("planted_ruffle")
    inst:DoPeriodicTask(TUNING.CARRAT.PLANTED_RUFFLE_TIME, play_planted_special_idle)
end

local function planted_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("carrat")
    inst.AnimState:SetBuild("carrat_basic")
    inst.AnimState:PlayAnimation("planted")
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "CARROT_PLANTED"

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable.onpickedfn = on_picked
    inst.components.pickable.canbepicked = true

    MakeSmallBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(on_ignite)
    inst.components.burnable:SetOnBurntFn(nil)

    MakeSmallPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    inst:DoTaskInTime(math.random(TUNING.CARRAT.PLANTED_RUFFLE_TIME), play_first_planted_special_idle)

    return inst
end

return Prefab("carrat", fn, assets, prefabs),
        Prefab("carrat_planted", planted_fn, planted_assets, planted_prefabs)
