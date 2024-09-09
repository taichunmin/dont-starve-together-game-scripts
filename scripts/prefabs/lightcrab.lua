local assets =
{
    Asset("ANIM", "anim/lightcrab.zip"),
}

local prefabs =
{
    "fishmeat_small",
    "lightbulb",
    "slurtle_shellpieces",
}

local brain = require("brains/lightcrabbrain")

local function OnDropped(inst)
    inst.sg:GoToState("stunned")
end

local function OnCookedFn(inst)
    if inst.components.health then
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/death")
    end
end

local function ShouldWake(inst)
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    local phys = MakeCharacterPhysics(inst, 20, 0.5)
    phys:SetCapsule(0.25, 0.5)

    inst.DynamicShadow:SetSize(0.8, 0.5)

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("lightcrab")
    inst.AnimState:SetBuild("lightcrab")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(0.25)

    inst.Light:SetRadius(1)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetColour(125/255, 125/255, 125/255)
    inst.Light:Enable(true)

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")
    inst:AddTag("stunnedbybomb")
    inst:AddTag("lightbattery")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor.walkspeed = TUNING.LIGHTCRAB_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.LIGHTCRAB_RUN_SPEED
    inst:SetStateGraph("SGlightcrab")

    inst:SetBrain(brain)

    inst:AddComponent("eater")
	inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "fishmeat_small_cooked"
    inst.components.cookable:SetOnCookedFn(OnCookedFn)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LIGHTCRAB_HEALTH)
    inst.components.health.murdersound = "monkeyisland/lightcrab/hit"
    inst.incineratesound = "monkeyisland/lightcrab/death"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.numrandomloot = 1
	inst.components.lootdropper:AddRandomLoot("fishmeat_small", .25)
	inst.components.lootdropper:AddRandomLoot("lightbulb", .25)			-- since we do not have a "small lightbulb", a low chance will have to suffice
	inst.components.lootdropper:AddRandomLoot("slurtle_shellpieces", .5)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"

    MakeSmallBurnableCharacter(inst, "body")
    MakeTinyFreezableCharacter(inst, "body")

    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
	inst.components.sleeper:SetSleepTest(nil)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    MakeHauntablePanic(inst)

    MakeFeedableSmallLivestock(inst, TUNING.LIGHTCRAB_PERISH_TIME, nil, OnDropped)

    return inst
end

return Prefab("lightcrab", fn, assets, prefabs)
