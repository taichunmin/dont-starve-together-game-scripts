require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/pig_torch.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "pigtorch_flame",
    "pigtorch_fuel",
    "pigguard",
    "collapse_small",

    --loot
    "log",
    "poop",
}

local loot =
{
    "log",
    "log",
    "log",
    "poop",
}

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst,worker)
    if inst.components.spawner.child ~= nil and inst.components.spawner.child.components.combat ~= nil then
        inst.components.spawner.child.components.combat:SuggestTarget(worker)
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function onextinguish(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function onupdatefueledraining(inst)
	inst.components.fueled.rate =
		inst.components.rainimmunity == nil and
		1 + TUNING.PIGTORCH_RAIN_RATE * TheWorld.state.precipitationrate or
		1
end

local function onisraining(inst, israining)
    if inst.components.fueled ~= nil then
        if israining then
            inst.components.fueled:SetUpdateFn(onupdatefueledraining)
            onupdatefueledraining(inst)
        else
            inst.components.fueled:SetUpdateFn()
            inst.components.fueled.rate = 1
        end
    end
end

local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
    else
        if not inst.components.burnable:IsBurning() then
            inst.components.burnable:Ignite()
        end

        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())
    end
end

local function OnVacate(inst)
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnHaunt(inst)
    inst.components.fueled:TakeFuelItem(SpawnPrefab("pigtorch_fuel"))
    inst.components.spawner:ReleaseChild()
    return true
end

local function OnPreLoad(inst, data)
    WorldSettings_Spawner_PreLoad(inst, data, TUNING.PIGHOUSE_SPAWN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.33)

    inst.AnimState:SetBank("pigtorch")
    inst.AnimState:SetBuild("pig_torch")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")

    --MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX("pigtorch_flame", Vector3(-5, 40, 0), "fire_marker")
    inst:ListenForEvent("onextinguish", onextinguish) --in case of creepy hands

    inst:AddComponent("fueled")
    inst.components.fueled.accepting = true
    inst.components.fueled.maxfuel = TUNING.PIGTORCH_FUEL_MAX
    inst.components.fueled:SetSections(3)
    inst.components.fueled.fueltype = FUELTYPE.PIGTORCH
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.PIGTORCH_FUEL_MAX)

    inst:WatchWorldState("israining", onisraining)
    onisraining(inst, TheWorld.state.israining)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("spawner")
    WorldSettings_Spawner_SpawnDelay(inst, TUNING.PIGHOUSE_SPAWN_TIME, TUNING.PIGHOUSE_ENABLED)
    inst.components.spawner:Configure("pigguard", TUNING.PIGHOUSE_SPAWN_TIME)
    inst.components.spawner:SetOnlySpawnOffscreen(true)
    inst.components.spawner:SetOnVacateFn(OnVacate)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    --MakeSnowCovered(inst)

    inst.OnPreLoad = OnPreLoad

    return inst
end

local function pigtorch_fuel()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.PIGTORCH_FUEL_MAX
    inst.components.fuel.fueltype = FUELTYPE.PIGTORCH
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(inst.Remove)

    return inst
end

return Prefab("pigtorch", fn, assets, prefabs),
    Prefab("pigtorch_fuel", pigtorch_fuel)
