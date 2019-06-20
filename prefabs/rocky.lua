local assets =
{
    Asset("ANIM", "anim/rocky.zip"),
    Asset("SOUND", "sound/rocklobster.fsb"),
}

local prefabs =
{
    "rocks",
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
    return inst.components.sleeper:GetTimeAwake() > TUNING.TOTAL_DAY_TIME * 2
end

local function ShouldWake(inst)
    return inst.components.sleeper:GetTimeAsleep() > TUNING.TOTAL_DAY_TIME * .5
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 20, function(dude) return dude.prefab == inst.prefab end, 2)
end

local function grow(inst, dt)
    if inst.components.scaler.scale < TUNING.ROCKY_MAX_SCALE then
        local new_scale = math.min(inst.components.scaler.scale + TUNING.ROCKY_GROW_RATE * dt, TUNING.ROCKY_MAX_SCALE)
        inst.components.scaler:SetScale(new_scale)
    elseif inst.growtask ~= nil then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
end

local function applyscale(inst, scale)
    inst.components.combat:SetDefaultDamage(TUNING.ROCKY_DAMAGE * scale)
    local percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(TUNING.ROCKY_HEALTH * scale)
    inst.components.health:SetPercent(percent)
    --MakeCharacterPhysics(inst, 200 * scale, scale)
    inst.components.locomotor.walkspeed = TUNING.ROCKY_WALK_SPEED / scale
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
			if giver.components.minigame_participator == nil then
	            giver:PushEvent("makefriend")
		        giver.components.leader:AddFollower(inst)
			end
            inst.components.follower:AddLoyaltyTime(
                giver:HasTag("polite")
                and TUNING.ROCKY_LOYALTY + TUNING.ROCKY_POLITENESS_LOYALTY_BONUS
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
    if data ~= nil and data.colour ~= nil then
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
        if inst.growtask ~= nil then
            inst.growtask:Cancel()
            local dt = 60 + math.random() * 10
            inst.growtask = inst:DoPeriodicTask(dt, grow, nil, dt)
        end
        return true
    end
    return false
end

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

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRange(4)
    inst.components.combat:SetDefaultDamage(100)

    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember.herdprefab = "rockyherd"
    inst:AddComponent("inventory")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME

    inst:AddComponent("scaler")
    inst.components.scaler.OnApplyScale = applyscale

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ROCKY_HEALTH)

    inst:AddComponent("inspectable")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.ELEMENTAL }, { FOODTYPE.ELEMENTAL })

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = TUNING.ROCKY_WALK_SPEED

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, true, false, true)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGrocky")

    inst:ListenForEvent("attacked", OnAttacked)

    local start_scale = GetRandomMinMax(TUNING.ROCKY_MIN_SCALE, TUNING.ROCKY_MAX_SCALE)
    inst.components.scaler:SetScale(start_scale)
    local dt = 60 + math.random() * 10
    inst.growtask = inst:DoPeriodicTask(dt, grow, nil, dt)
    inst.components.scaler:SetScale(TUNING.ROCKY_MIN_SCALE)

    inst.OnLongUpdate = grow

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("rocky", fn, assets, prefabs)
