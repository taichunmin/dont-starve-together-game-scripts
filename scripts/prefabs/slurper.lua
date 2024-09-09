local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/slurper_basic.zip"),
    Asset("ANIM", "anim/hat_slurper.zip"),
    Asset("SOUND", "sound/slurper.fsb"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "slurper_pelt",
    "slurperlight",
    "slurper_ruinsrespawner_inst",
}

local brain = require "brains/slurperbrain"

SetSharedLootTable('slurper',
{
    {'lightbulb',    1.0},
    {'lightbulb',    1.0},
    {'slurper_pelt', 0.5},
})

------------------------------------------------------------------------------
local light_params =
{
    low =
    {
        radius = 1,
        intensity = .5,
        falloff = .7,
    },
    high =
    {
        radius = 3,
        intensity = .8,
        falloff = .4,
    },
}

local MAX_LIGHT_FRAME = math.floor(2 / FRAMES + .5)

local function OnUpdateLight(inst, dframes)
    local done
    if inst._lightlevel:value() then
        local frame = inst._lightframe:value() + dframes
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    local k = inst._lightframe:value() / MAX_LIGHT_FRAME
    local k1 = 1 - k
    inst.Light:SetRadius(light_params.high.radius * k + light_params.low.radius * k1)
    inst.Light:SetIntensity(light_params.high.intensity * k + light_params.low.intensity * k1)
    inst.Light:SetFalloff(light_params.high.falloff * k + light_params.low.falloff * k1)

    if done then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

------------------------------------------------------------------------------
local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function CanHatTarget(inst, target)
    if target == nil or
        target.components.inventory == nil or
        not (target.components.inventory.isopen or
            target:HasTag("pig") or
            target:HasTag("manrabbit") or
            target:HasTag("equipmentmodel") or
            (inst._loading and target:HasTag("player"))) then
        --NOTE: open inventory implies player, so we can skip "player" tag check
        --      closed inventory on player means they shouldn't be able to equip
        --      EXCEPT during load, because player inventory opens after 1 frame
        return false
    end
    local hat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    return hat == nil or hat.prefab ~= inst.prefab
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "slurper" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function Retarget(inst)
    --Find us a tasty target with a hunger component and the ability to equip hats.
    --Otherwise just find a target that can equip hats.

    --Too far, don't find a target
    local homePos = inst.components.knownlocations:GetLocation("home")
    if homePos ~= nil and inst:GetDistanceSqToPoint(homePos) > 30 * 30 then
        return
    end

    return
        FindEntity(inst, 15, function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS)
end

local function KeepTarget(inst, target)
    --If you've chased too far, go home.
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos == nil or inst:GetDistanceSqToPoint(homePos) < 30 * 30
end

local function slurphunger(inst, owner)
    if owner.components.hunger ~= nil then
        if owner.components.hunger.current > 0 then
            owner.components.hunger:DoDelta(-3)
        end
    elseif owner.components.health ~= nil then
        owner.components.health:DoDelta(-5, false, "slurper")
    end
end

local function setcansleep(inst)
    inst.cansleep = true
end

local function OnEquip(inst, owner)
    --Start feeding!

    if not CanHatTarget(inst, owner) then
        owner.components.inventory:Unequip(EQUIPSLOTS.HEAD)
        return
    end

    inst._light.Light:Enable(true)
    inst._light._lightlevel:set(true)
    inst._light._lightframe:set(inst._light._lightframe:value())
    OnLightDirty(inst._light)

    inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/attach")

    owner.AnimState:OverrideSymbol("swap_hat", "hat_slurper", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
		owner.AnimState:Show("HEAD_HAT_NOHELM")
		owner.AnimState:Hide("HEAD_HAT_HELM")

        inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/headslurp", "slurp_loop")
    else
        inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/headslurp_creatures", "slurp_loop")
    end

    inst.shouldburp = true
    inst.cansleep = false

    inst.onattach(owner)

    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoPeriodicTask(2, slurphunger, nil, owner)
end

local function OnUnequip(inst, owner)
    inst._light.Light:Enable(true)
    inst._light._lightlevel:set(false)
    inst._light._lightframe:set(inst._light._lightframe:value())
    OnLightDirty(inst._light)

    inst._light.SoundEmitter:PlaySound("dontstarve/creatures/slurper/dettach")

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
		owner.AnimState:Hide("HEAD_HAT_NOHELM")
		owner.AnimState:Hide("HEAD_HAT_HELM")
    end
    inst._light.SoundEmitter:KillSound("slurp_loop")

    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())

    inst.ondetach(owner)

    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(10, setcansleep)
end

local function unequip_myself(owner, inst)
    if inst ~= nil and inst:IsValid() and owner.components.inventory and owner.components.inventory:IsItemEquipped(inst) then
        owner.components.inventory:DropItem(inst, true, true)
    end
end

local function BasicAwakeCheck(inst)
    return not inst.cansleep
        or (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
        or (inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner ~= nil)
end

local function SleepTest(inst)
    if BasicAwakeCheck(inst) then
        return false
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos) < 25--5 * 5
end

local function WakeTest(inst)
    if BasicAwakeCheck(inst) then
        return true
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos) >= 25--5 * 5
end

local function OnInit(inst)
    inst._loading = nil
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function OnLoad(inst)
    inst._loading = true
end

local function OnLoadPostPass(inst)
    inst._loading = nil
end

local function OnRemoveEntity(inst)
    inst._light:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.25)

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 10, 0.5)

    inst.AnimState:SetBank("slurper")
    inst.AnimState:SetBuild("slurper_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("cavedweller")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("slurper")
    inst:AddTag("mufflehat")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._light = SpawnPrefab("slurperlight")
    inst._light.entity:SetParent(inst.entity)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquip(OnEquip)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier(1)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = TUNING.SLURPER_WALKSPEED

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.SLURPER_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SLURPER_ATTACK_DIST)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.SLURPER_DAMAGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SLURPER_HEALTH)
    inst.components.health.canmurder = false

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('slurper')
    -- inst:AddComponent("eater")
    -- inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    -- inst.components.eater:SetOnEatFn(oneat)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(SleepTest)
    inst.components.sleeper:SetWakeTest(WakeTest)
    --inst.components.sleeper:SetNocturnal(true)

    inst:AddComponent("knownlocations")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    MakeMediumBurnableCharacter(inst)
    MakeMediumFreezableCharacter(inst)

    MakeHauntablePanic(inst)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGslurper")

    inst.HatTest = CanHatTarget

    inst.cansleep = true

    inst:DoTaskInTime(0, OnInit)

    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnRemoveEntity = OnRemoveEntity

    inst._owner = nil
    inst.onattach = function(owner)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
        end
        inst:ListenForEvent("onremove", inst.ondetach, owner)
        inst._light.entity:SetParent(owner.entity)
        inst._owner = owner

        if owner:HasTag("equipmentmodel") then
            owner:DoTaskInTime(TUNING.SLURPER_MANNEQUINTIME, unequip_myself, inst)
        end
    end
    inst.ondetach = function()
        if inst._owner ~= nil then
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            inst._light.entity:SetParent(inst.entity)
            inst._owner = nil
        end
    end

    return inst
end

local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(light_params.low.radius)
    inst.Light:SetIntensity(light_params.low.intensity)
    inst.Light:SetFalloff(light_params.low.falloff)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst._lightframe = net_smallbyte(inst.GUID, "slurperlight._lightframe", "lightdirty")
    inst._lightlevel = net_bool(inst.GUID, "slurperlight._lightlevel", "lightdirty")
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.persists = false

    return inst
end

local function onruinsrespawn(inst, respawner)
	if not respawner:IsAsleep() then
		SpawnPrefab("slurper_respawn").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst.sg:GoToState("ruinsrespawn")
	end
end

return Prefab("slurper", fn, assets, prefabs),
    Prefab("slurperlight", lightfn),
    RuinsRespawner.Inst("slurper", onruinsrespawn), RuinsRespawner.WorldGen("slurper", onruinsrespawn)
