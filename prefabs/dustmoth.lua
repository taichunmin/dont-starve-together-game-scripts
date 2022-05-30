local assets =
{
    Asset("ANIM", "anim/dustmoth.zip"),
}

SetSharedLootTable('dustmoth',
{
    {'smallmeat',  1.0},
})

local sounds =
{
    slide_in = "grotto/creatures/dust_moth/slide_in",
    slide_out = "grotto/creatures/dust_moth/slide_out",
    pickup = "grotto/creatures/dust_moth/mumble",
    hit = "grotto/creatures/dust_moth/hit",
    death = "grotto/creatures/dust_moth/death",
    sneeze = "grotto/creatures/dust_moth/sneeze",
    dustoff = "grotto/creatures/dust_moth/dustoff",
    mumble = "grotto/creatures/dust_moth/mumble",
    clean = "grotto/creatures/dust_moth/clean",
    eat = "grotto/creatures/dust_moth/eat",
    fall = "grotto/creatures/dust_moth/bodyfall",
    eat_slide = "grotto/creatures/dust_moth/eat_slide",
}

local CHECK_STUCK_FREQUENCY = 0.5
local STUCK_DISTANCE_THRESHOLD_SQ = 0.25*0.25

local CHARGED_BY_PREFAB = "dustmeringue"

local brain = require "brains/dustmothbrain"

local function OnAttacked(inst, data)
    inst.components.inventory:DropEverything()
end

local function OnEat(inst, data)
    if data.food ~= nil and data.food.prefab == CHARGED_BY_PREFAB then
        inst._charged = true
    end
end

local function OnFinishRepairingDen(inst, den)
    inst._charged = false
end

local function ShouldAcceptItem(inst, item)
    return not inst._charged
        and inst.components.inventory:GetItemInSlot(1) == nil
        and item:HasTag("dustmothfood")
end

local function OnRefuseItem(inst, giver, item)
    if giver ~= nil and giver:IsValid() then
        inst:PushEvent("onrefuseitem", giver)
    end
end

local function StartDustoffCooldown(inst)
    inst._find_dustables = false

    if inst._dustoff_cooldown_task ~= nil then
        inst._dustoff_cooldown_task:Cancel()
    end

    inst._dustoff_cooldown_task = inst:DoTaskInTime(TUNING.DUSTMOTH.DUSTOFF_COOLDOWN + math.random() * TUNING.DUSTMOTH.DUSTOFF_COOLDOWN_VARIANCE,
        function(inst)
            inst._find_dustables = true
        end)
end

local function PostInit(inst)
    inst._previous_position = inst:GetPosition()
end

local function CheckIsStuck(inst)
    if not inst.sg:HasStateTag("busy") then
        local delta = inst:GetPosition() - inst._previous_position
        if VecUtil_LengthSq(delta.x, delta.z) <= STUCK_DISTANCE_THRESHOLD_SQ then
            inst._time_spent_stuck = inst._time_spent_stuck + CHECK_STUCK_FREQUENCY
        else
            inst._time_spent_stuck = 0
        end

        inst._previous_position = inst:GetPosition()
    end
end

local function OnEntitySleep(inst)
    if inst._check_stuck_task ~= nil then
        inst._check_stuck_task:Cancel()
        inst._check_stuck_task = nil
    end
end

local function StartCheckStuckTask(inst)
    if not inst._check_stuck_task then
        inst._check_stuck_task = inst:DoPeriodicTask(CHECK_STUCK_FREQUENCY, CheckIsStuck, 0.25)
    end
end

local function OnEntityWake(inst)
    StartCheckStuckTask(inst)
end

local function OnSave(inst, data)
    if inst._charged then
        data.charged = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.charged ~= nil then
        inst._charged = data.charged
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.DynamicShadow:SetSize(2.8, 2.5)

    MakeCharacterPhysics(inst, 50, .75)

    inst.AnimState:SetBank("dustmoth")
    inst.AnimState:SetBuild("dustmoth")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cavedweller")
    inst:AddTag("animal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._sounds = sounds

    inst._charged = false

    inst._previous_position = Vector3(0,0,0)
    inst._time_spent_stuck = 0
    inst:DoTaskInTime(0, PostInit)
    StartCheckStuckTask(inst)
    -- inst._force_unstuck_wander = nil

    inst._find_dustables = true
    inst.StartDustoffCooldown = StartDustoffCooldown -- Called from stategraph
    -- inst._dustoff_cooldown_task = nil

    inst._last_played_search_anim_time = -TUNING.DUSTMOTH.SEARCH_ANIM_COOLDOWN * math.random()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.DUSTMOTH.WALK_SPEED

    inst:SetStateGraph("SGdustmoth")

    inst:SetBrain(brain)

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "dm_body"

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DUSTMOTH.HEALTH)
    inst.components.health:StartRegen(TUNING.DUSTMOTH.HEALTH_REGEN, 1)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.ELEMENTAL }, { FOODTYPE.ELEMENTAL })

    inst:AddComponent("sleeper")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('dustmoth')

    inst:AddComponent("knownlocations")
    inst:AddComponent("homeseeker")

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    inst:AddComponent("timer")

    MakeMediumFreezableCharacter(inst, "dm_body")
    MakeMediumBurnableCharacter(inst, "dm_body")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("oneat", OnEat)
    inst:ListenForEvent("dustmothden_repaired", OnFinishRepairingDen)

    MakeHauntablePanic(inst)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("dustmoth", fn, assets)
