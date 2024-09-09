local assets =
{
    Asset("ANIM", "anim/perd_basic.zip"),
    Asset("ANIM", "anim/perd.zip"),
    Asset("SOUND", "sound/perd.fsb"),
}

local prefabs =
{
    "drumstick",
    "redpouch",
}

local brain = require "brains/perdbrain"

local loot =
{
    "drumstick",
    "drumstick",
}

local function ShouldWake()
    --always wake up if we're asleep
    return true
end

local function OnSave(inst, data)
    if inst.components.homeseeker ~= nil and inst.components.homeseeker.home ~= nil then
        data.home = inst.components.homeseeker.home.GUID
        return { data.home }
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data ~= nil and data.home ~= nil then
        local home = newents[data.home]
        if home ~= nil and inst.components.homeseeker ~= nil then
            inst.components.homeseeker:SetHome(home.entity)
        end
    end
end

--------------------------------------------------------------------------
--[[ For special event ]]
--------------------------------------------------------------------------

local PERD_TAGS = { "perd" }
local function OnAttacked(inst)
    local tochain = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 14, PERD_TAGS)) do
        if v.seekshrine then
            v.seekshrine = nil
            inst:RemoveEventCallback("attacked", OnAttacked)
            if v ~= inst then
                table.insert(tochain, v)
            end
        end
    end
    for i, v in ipairs(tochain) do
        OnAttacked(v)
    end
end

local function OnEat(inst, food)
    --eat off the ground, not picked berries
    if food.components.inventoryitem ~= nil and
        not food.components.inventoryitem:IsHeld() and
        not inst.components.timer:TimerExists("offeringcooldown") then
        inst.sg.statemem.dropoffering = true
        if not inst.seekshrine then
            inst.seekshrine = true
            inst:ListenForEvent("attacked", OnAttacked)
        end
    end
end

local function lootsetfn(lootdropper)
    if not lootdropper.inst.components.timer:TimerExists("offeringcooldown") then
        lootdropper:AddChanceLoot("redpouch", .1)
    end
end

local function DropOffering(inst)
    if not inst.components.timer:TimerExists("offeringcooldown") then
        inst.components.timer:StartTimer("offeringcooldown", TUNING.TOTAL_DAY_TIME)
        LaunchAt(SpawnPrefab("redpouch"), inst, inst:GetNearestPlayer(true) or inst:GetNearestPlayer(), .5, 1, .5)
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("perd")
    inst.AnimState:SetBuild("perd")
    inst.AnimState:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("berrythief")
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTG) then
        inst:AddTag("perd")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.PERD_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PERD_WALK_SPEED

    inst:SetStateGraph("SGperd")

    inst:AddComponent("homeseeker")
    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    inst.components.eater:SetCanEatRaw()

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"

    inst.components.health:SetMaxHealth(TUNING.PERD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PERD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PERD_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    MakeHauntablePanic(inst)

    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    inst.OnSave = OnSave
    inst.OnLoadPostPass = OnLoadPostPass

    if IsSpecialEventActive(SPECIAL_EVENTS.YOTG) then
        inst:AddComponent("timer")

        inst.components.eater:SetOnEatFn(OnEat)
        inst.components.lootdropper:SetLootSetupFn(lootsetfn)

        inst.DropOffering = DropOffering

        inst.seekshrine = true
        inst:ListenForEvent("attacked", OnAttacked)
    end

    return inst
end

return Prefab("perd", fn, assets, prefabs)
