require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/butterfly_basic.zip"),
}

local prefabs =
{
    "butterflywings",
    "butter",
    "planted_flower",
}

local brain = require "brains/butterflybrain"

local function OnDropped(inst)
    inst.sg:GoToState("idle")
    if inst.butterflyspawner ~= nil then
        inst.butterflyspawner:StartTracking(inst)
    end
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.components.stackable ~= nil then
        while inst.components.stackable:StackSize() > 1 do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
        end
    end
end

local function OnPickedUp(inst)
    if inst.butterflyspawner ~= nil then
        inst.butterflyspawner:StopTracking(inst)
    end
end

local function OnWorked(inst, worker)
    if worker.components.inventory ~= nil then
        if inst.butterflyspawner ~= nil then
            inst.butterflyspawner:StopTracking(inst)
        end
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
        worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
    end
end

local function CanDeploy(inst)
    return true
end

local function OnDeploy(inst, pt, deployer)
    local flower = SpawnPrefab("planted_flower")
    if flower then
        flower:PushEvent("growfrombutterfly")
        flower.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        AwardPlayerAchievement("growfrombutterfly", deployer)
        TheWorld:PushEvent("CHEVO_growfrombutterfly",{target=flower,doer=deployer})
        if deployer and deployer.SoundEmitter then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function OnMutate(inst, transformed_inst)
	if transformed_inst ~= nil then
		transformed_inst.sg:GoToState("idle")
	end
end

local function fn()
    local inst = CreateEntity()

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
    MakeTinyFlyingCharacterPhysics(inst, 1, .5)

    inst:AddTag("butterfly")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")
    inst:AddTag("wildfireprotected")
    inst:AddTag("deployedplant")

    --pollinator (from pollinator component) added to pristine state for optimization
    inst:AddTag("pollinator")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBuild("butterfly_basic")
    inst.AnimState:SetBank("butterfly")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst.DynamicShadow:SetSize(.8, .5)

    MakeInventoryFloatable(inst)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst:SetStateGraph("SGbutterfly")

    ---------------------
    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.pushlandedevents = false

    ------------------
    inst:AddComponent("pollinator")

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)

    ------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "butterfly_body"

    ------------------
    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "butterfly_body")
    MakeTinyFreezableCharacter(inst, "butterfly_body")

    ------------------
    inst:AddComponent("inspectable")

    ------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("butter", 0.1)
    inst.components.lootdropper:AddRandomLoot("butterflywings", 5)
    inst.components.lootdropper.numrandomloot = 1

    ------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    ------------------
    inst:AddComponent("tradable")

    ------------------
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)

    MakeHauntablePanicAndIgnite(inst)

    inst:SetBrain(brain)

    inst.butterflyspawner = TheWorld.components.butterflyspawner
    if inst.butterflyspawner ~= nil then
        inst.components.inventoryitem:SetOnPickupFn(inst.butterflyspawner.StopTrackingFn)
        inst:ListenForEvent("onremove", inst.butterflyspawner.StopTrackingFn)
        inst.butterflyspawner:StartTracking(inst)
    end

    MakeFeedableSmallLivestock(inst, TUNING.BUTTERFLY_PERISH_TIME, OnPickedUp, OnDropped)

	inst:AddComponent("halloweenmoonmutable")
	inst.components.halloweenmoonmutable:SetPrefabMutated("moonbutterfly")
	inst.components.halloweenmoonmutable:SetOnMutateFn(OnMutate)
	inst.components.halloweenmoonmutable.push_attacked_on_new_inst = false

    return inst
end

return Prefab("butterfly", fn, assets, prefabs),
    MakePlacer("butterfly_placer", "flowers", "flowers", "f1")
