local assets =
{
    Asset("ANIM", "anim/rocky.zip"),
    Asset("SOUND", "sound/rocklobster.fsb"),
}

local prefabs =
{
    "rocks",
    "meat",
    "flint",
}

local brain = require "brains/rockybrain"

local colours =
{
    { 1, 1, 1, 1 },
    --{ 174/255, 158/255, 151/255, 1 },
    { 167/255, 180/255, 180/255, 1 },
    { 159/255, 163/255, 146/255, 1 },
}

local function ShouldSleep(inst)
    return inst.components.sleeper:GetTimeAwake() > (TUNING.TOTAL_DAY_TIME * 2)
end

local function ShouldWake(inst)
    return inst.components.sleeper:GetTimeAsleep() > (TUNING.TOTAL_DAY_TIME * .5)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)

    inst._target_sharing_test = inst._target_sharing_test or function(dude)
        return dude.prefab == inst.prefab
    end
    inst.components.combat:ShareTarget(data.attacker, 20, inst._target_sharing_test, 2)
end

local function grow(inst, dt)
    if inst.components.scaler.scale < TUNING.ROCKY_MAX_SCALE then
        local new_scale = math.min(
            inst.components.scaler.scale + TUNING.ROCKY_GROW_RATE * dt,
            TUNING.ROCKY_MAX_SCALE
        )
        inst.components.scaler:SetScale(new_scale)

        return true
    else
        return false
    end
end

local function on_size_update(inst, dt)
    if not inst.components.rainimmunity and TheWorld.state.isacidraining then
        if inst.components.scaler.scale > TUNING.ROCKY_MIN_SCALE then
            local new_scale = math.max(
                inst.components.scaler.scale - TUNING.ROCKY_ACIDRAIN_SHRINK_RATE * dt,
                TUNING.ROCKY_MIN_SCALE
            )
            inst.components.scaler:SetScale(new_scale)
        elseif inst.sizeupdatetask then
            inst.sizeupdatetask:Cancel()
            inst.sizeupdatetask = nil
        end
    else
        local grew = grow(inst, 500)
        if not grew and inst.sizeupdatetask then
            inst.sizeupdatetask:Cancel()
            inst.sizeupdatetask = nil
        end
    end
end

local function applyscale(inst, scale)
    inst.components.combat:SetDefaultDamage(TUNING.ROCKY_DAMAGE * scale)

    inst.components.locomotor.walkspeed = TUNING.ROCKY_WALK_SPEED / scale

    local percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(TUNING.ROCKY_HEALTH * scale)
    inst.components.health:SetPercent(percent)
end

local function OnGrowthStateDirty(inst)
    if not inst.sizeupdatetask then
        -- If acid rain starts or stops, queue up a check for whether
        -- we should start growing or shrinking again.
        local dt = 60 + math.random() * 10
        inst.sizeupdatetask = inst:DoPeriodicTask(dt, on_size_update, nil, dt)
    end
end

local function ShouldAcceptItem(inst, item)
    return item.components.edible ~= nil and item.components.edible.foodtype == FOODTYPE.ELEMENTAL
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.edible ~= nil and
            item.components.edible.foodtype == FOODTYPE.ELEMENTAL and
            item.components.inventoryitem ~= nil and
            (   --make sure it didn't drop due to pockets full
                item.components.inventoryitem:GetGrandOwner() == inst or
                --could be merged into a stack
                (   not item:IsValid() and
                    inst.components.inventory:FindItem(function(obj)
                        return obj.prefab == item.prefab
                            and obj.components.stackable ~= nil
                            and obj.components.stackable:IsStack()
                    end) ~= nil)
            ) then
        if inst.components.combat:TargetIs(giver) then
            inst.components.combat:SetTarget(nil)
        elseif giver.components.leader ~= nil then
			if not giver.components.minigame_participator then
	            giver:PushEvent("makefriend")
		        giver.components.leader:AddFollower(inst)
			end
            inst.components.follower:AddLoyaltyTime(
                (giver:HasTag("polite")
                and TUNING.ROCKY_LOYALTY + TUNING.ROCKY_POLITENESS_LOYALTY_BONUS)
                or TUNING.ROCKY_LOYALTY
            )
            inst.sg:GoToState("rocklick")
        end
    end

    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnRefuseItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    inst:PushEvent("refuseitem")
end

local loot = { "rocks", "rocks", "meat", "flint", "flint" }

local function onsave(inst, data)
    data.colour = inst.colour_idx
end

local function onload(inst, data)
    if not data then return end

    if data.colour ~= nil then
        local colour = colours[data.colour]
        if colour ~= nil then
            inst.colour_idx = data.colour
            inst.AnimState:SetMultColour(unpack(colour))
        end
    end
end

local function CustomOnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
        grow(inst, 500)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
        if inst.sizeupdatetask then
            inst.sizeupdatetask:Cancel()
            inst.sizeupdatetask = nil
            OnGrowthStateDirty(inst)
        end
        return true
    else
        return false
    end
end

local EATER_FOODTYPES = { FOODTYPE.ELEMENTAL }
local PATHCAPS = { ignorecreep = false }
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 200, 1)

    inst.Transform:SetFourFaced()

    inst:AddTag("rocky")
    inst:AddTag("character")
    inst:AddTag("animal")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    --herdmember (from herdmember component) added to pristine state for optimization
    inst:AddTag("herdmember")

    inst.AnimState:SetBank("rocky")
    inst.AnimState:SetBuild("rocky")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.DynamicShadow:SetSize(1.75, 1.75)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.colour_idx = math.random(#colours)
    inst.AnimState:SetMultColour(unpack(colours[inst.colour_idx]))

    --
    local acidinfusible = inst:AddComponent("acidinfusible")
    acidinfusible:SetFXLevel(3)
    acidinfusible:SetOnInfuseFn(OnGrowthStateDirty)
    acidinfusible:SetOnUninfuseFn(OnGrowthStateDirty)

    --
    local combat = inst:AddComponent("combat")
    combat:SetAttackPeriod(3)
    combat:SetRange(4)
    combat:SetDefaultDamage(100)

    --
    local eater = inst:AddComponent("eater")
    eater:SetDiet(EATER_FOODTYPES, EATER_FOODTYPES)

    --
    local follower = inst:AddComponent("follower")
    follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.ROCKY_HEALTH)

    --
    local herdmember = inst:AddComponent("herdmember")
    herdmember.herdprefab = "rockyherd"

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("inventory")

    --
    inst:AddComponent("knownlocations")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor:SetSlowMultiplier( 1 )
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = PATHCAPS
    locomotor.walkspeed = TUNING.ROCKY_WALK_SPEED

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetLoot(loot)

    --
    local scaler = inst:AddComponent("scaler")
    scaler.OnApplyScale = applyscale

    --
    local sleeper = inst:AddComponent("sleeper")
    sleeper:SetResistance(3)
    sleeper:SetWakeTest(ShouldWake)
    sleeper:SetSleepTest(ShouldSleep)

    --
    local trader = inst:AddComponent("trader")
    trader:SetAcceptTest(ShouldAcceptItem)
    trader.onaccept = OnGetItemFromPlayer
    trader.onrefuse = OnRefuseItem
    trader.deleteitemonaccept = false

    --
    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, true, false, true)

    --
    inst:SetBrain(brain)
    inst:SetStateGraph("SGrocky")

    --
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("gainrainimmunity", OnGrowthStateDirty)
    inst:ListenForEvent("loserainimmunity", OnGrowthStateDirty)

    --
    OnGrowthStateDirty(inst)
    scaler:SetScale(TUNING.ROCKY_MIN_SCALE)

    --
    inst.OnLongUpdate = on_size_update

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("rocky", fn, assets, prefabs)
