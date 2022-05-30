require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/tent_walter.zip"),
}

local prefabs =
{
    "collapse_small",
    "portabletent_item",
}

local prefabs_item =
{
    "portabletent",
}

local function OnAnimOver(inst)
    if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("disassemble") then
        local current_uses = inst.components.finiteuses:GetUses()

        local item = ReplacePrefab(inst, "portabletent_item")
        item.components.finiteuses:SetUses(current_uses)
        item.AnimState:PlayAnimation("idle_item")
    end
end

local function ChangeToItem(inst)
    inst:RemoveComponent("sleepingbag")
    inst:RemoveComponent("portablestructure")
    inst:RemoveComponent("workable")

    inst:AddTag("NOCLICK")

    inst.AnimState:PlayAnimation("disassemble")
    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/tent/close")
    inst:ListenForEvent("animover", OnAnimOver)
end

local function OnHammered(inst)--, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst:HasTag("burnt") then
        local fx = SpawnPrefab("collapse_big")
        inst.components.lootdropper:DropLoot()
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("wood")
        inst:Remove()
    else
        ChangeToItem(inst)
    end

end

local function OnHit(inst)--, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
    end

    if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnDismantle(inst)--, doer)
    ChangeToItem(inst)
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    RemovePhysicsColliders(inst)

    if inst.components.portablestructure ~= nil then
        inst:RemoveComponent("portablestructure")
    end

end

-----------------------------------------------------------------------
--For regular tents

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function StopSleepSound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function StartSleepSound(inst, len)
    StopSleepSound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

-----------------------------------------------------------------------

local function OnIgnite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

local function OnSleep(inst, sleeper)
    sleeper:ListenForEvent("onignite", OnIgnite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        StartSleepSound(inst, inst.AnimState:GetCurrentAnimationLength())
    end
end

local function OnWake(inst, sleeper, nostatechange)
    sleeper:RemoveEventCallback("onignite", OnIgnite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("idle", true)
        StopSleepSound(inst)
    end

    inst.components.finiteuses:Use()
end

local function TemperatureTick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end
end

local function OnFinished(inst)
    if not inst:HasTag("burnt") then
        StopSleepSound(inst)
        inst.AnimState:PlayAnimation("destroy")
        inst:ListenForEvent("animover", inst.Remove)
        inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
        inst.persists = false
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    -- Set Tent icon
    inst.MiniMapEntity:SetIcon("portabletent.png")

    inst:AddTag("tent")
    inst:AddTag("portabletent")
    inst:AddTag("structure")

    inst.AnimState:SetBank("tent_walter")
    inst.AnimState:SetBuild("tent_walter")
    inst.AnimState:PlayAnimation("idle")

    inst:SetPrefabNameOverride("portabletent_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = OnSleep
    inst.components.sleepingbag.onwake = OnWake
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK
    --convert wetness delta to drying rate
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    inst.components.sleepingbag:SetTemperatureTickFn(TemperatureTick)
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK

    inst.sleep_anim = "sleep_loop"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(OnFinished)
    inst.components.finiteuses:SetMaxUses(TUNING.PORTABLE_TENT_USES)
    inst.components.finiteuses:SetUses(TUNING.PORTABLE_TENT_USES)

    MakeHauntableWork(inst)

    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    MakeMediumPropagator(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

---------------------------------------------------------------
---------------- Inventory Portable Tent  -------------------
---------------------------------------------------------------

local function OnDeploy(inst, pt, deployer)
    local tent = SpawnPrefab("portabletent")
    if tent ~= nil then
        tent.Physics:SetCollides(false)
        tent.Physics:Teleport(pt.x, 0, pt.z)
        tent.Physics:SetCollides(true)

        tent.AnimState:PlayAnimation("place")
        tent.AnimState:PushAnimation("idle", false)

        tent.SoundEmitter:PlaySound("dontstarve/characters/walter/tent/open")

        tent.components.finiteuses:SetUses(inst.components.finiteuses:GetUses())

        inst:Remove()
        PreventCharacterCollisionsWithPlacedObjects(tent)
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tent_walter")
    inst.AnimState:SetBuild("tent_walter")
    inst.AnimState:PlayAnimation("idle_item")

    inst:AddTag("portableitem")

    MakeInventoryFloatable(inst, nil, 0.05, 0.7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(OnFinished)
    inst.components.finiteuses:SetMaxUses(TUNING.PORTABLE_TENT_USES)
    inst.components.finiteuses:SetUses(TUNING.PORTABLE_TENT_USES)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    --inst.components.deployable.restrictedtag = "pinetreepioneer"
    inst.components.deployable.ondeploy = OnDeploy

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("portabletent", fn, assets, prefabs),
    MakePlacer("portabletent_item_placer", "tent_walter", "tent_walter", "idle"),
    Prefab("portabletent_item", itemfn, assets, prefabs_item)