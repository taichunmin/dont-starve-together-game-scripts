local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")

local willow_ember_common = require("prefabs/willow_ember_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/willow.fsb"),
    Asset("ANIM", "anim/player_idles_willow.zip"),
    Asset("ANIM", "anim/willow_pyrocast.zip"),
    Asset("ANIM", "anim/willow_mount_pyrocast.zip"),
    Asset("SCRIPT", "scripts/prefabs/skilltree_willow.lua"),
}

local prefabs =
{
    "lavaarena_bernie",
    "willow_ember",
    "emberlight",
    "willow_shadow_flame",
    "willow_throw_flame",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WILLOW
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function customidleanimfn(inst)
    local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return item ~= nil and item.prefab == "bernie_inactive" and "idle_willow" or nil
end

local FIRE_TAGS = { "fire" }
local function sanityfn(inst)--, dt)
    local sanity_cap = TUNING.SANITYAURA_LARGE
    local sanity_per_ent = TUNING.SANITYAURA_TINY
    local delta = inst.components.temperature:IsFreezing() and -sanity_cap or 0
    local x, y, z = inst.Transform:GetWorldPosition()
    local max_rad = 10
    local ents = TheSim:FindEntities(x, y, z, max_rad, FIRE_TAGS)
    for i, v in ipairs(ents) do
        if v.components.burnable ~= nil and v.components.burnable:IsBurning() then
            local stack_size = v.components.stackable ~= nil and v.components.stackable.stacksize or 1
            local rad = v.components.burnable:GetLargestLightRadius() or 1
            local sz = stack_size * sanity_per_ent * math.min(max_rad, rad) / max_rad
            local distsq = inst:GetDistanceSqToInst(v) - 9
            -- shift the value so that a distance of 3 is the minimum
            delta = delta + sz / math.max(1, distsq)
            if delta > sanity_cap then
                delta = sanity_cap
                break
            end
        end
    end
    return delta
end

local function GetFuelMasterBonus(inst, item, target)

    -- The TAG "firefuellight" is used for items that are not campfires in that they won't incubate something but Willow should benefit from fueling it.
    return (target:HasTag("firefuellight") or target:HasTag("campfire") or target.prefab == "nightlight") and TUNING.WILLOW_CAMPFIRE_FUEL_MULT or 1
end

local function IsValidVictim(victim, explosive)
    return willow_ember_common.HasEmbers(victim) and (victim.components.health:IsDead() or explosive)
end

local function OnRestorEmber(victim)
    victim.noembertask = nil
end

local function OnEntityDropLoot(inst, data)
    local victim = data.inst
    if  inst.components.skilltreeupdater:IsActivated("willow_embers") and
        victim ~= nil and
        victim.noembertask == nil and
        victim:IsValid() and
        (   victim == inst or
            (   not inst.components.health:IsDead() and
                IsValidVictim(victim) and
                inst:IsNear(victim, TUNING.WILLOW_EMBERDROP_RANGE)
            )
        ) then
        --V2C: prevents multiple Willows in range from spawning multiple embers per corpse
        victim.noembertask = victim:DoTaskInTime(5, OnRestorEmber)
        willow_ember_common.SpawnEmbersAt(victim, willow_ember_common.GetNumEmbers(victim))
    end
end

local function OnEntityDeath(inst, data)
    if data.inst ~= nil then
        data.inst._embersource = data.afflicter -- Mark the victim.
        if (data.inst.components.lootdropper == nil or data.explosive) then -- NOTES(JBK): Explosive entities do not drop loot.
            OnEntityDropLoot(inst, data)
        end
    end
end

local function OnRespawnedFromGhost(inst)
    inst.components.freezable:SetResistance(3)

    if inst._onentitydroplootfn == nil then
        inst._onentitydroplootfn = function(src, data) OnEntityDropLoot(inst, data) end
        inst:ListenForEvent("entity_droploot", inst._onentitydroplootfn, TheWorld)
    end
    if inst._onentitydeathfn == nil then
        inst._onentitydeathfn = function(src, data) OnEntityDeath(inst, data) end
        inst:ListenForEvent("entity_death", inst._onentitydeathfn, TheWorld)
    end 
end

local function TryToOnRespawnedFromGhost(inst)
    if not inst.components.health:IsDead() and not inst:HasTag("playerghost") then
        OnRespawnedFromGhost(inst)
    end
end

local function OnBecameGhost(inst)
    if inst._onentitydroplootfn ~= nil then
        inst:RemoveEventCallback("entity_droploot", inst._onentitydroplootfn, TheWorld)
        inst._onentitydroplootfn = nil
    end
    if inst._onentitydeathfn ~= nil then
        inst:RemoveEventCallback("entity_death", inst._onentitydeathfn, TheWorld)
        inst._onentitydeathfn = nil
    end
end

local function common_postinit(inst)
    inst:AddTag("pyromaniac")
    inst:AddTag("expertchef")
    inst:AddTag("bernieowner")

    --For UI health meter arrows
    inst:AddTag("heatresistant") --less overheat damage

    inst.AnimState:AddOverrideBuild("willow_pyrocast")

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst:AddTag("bernie_reviver")

        inst:AddComponent("pethealthbar")
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    end
end

local function CustomCombatDamage(inst, target, weapon, multiplier, mount)
    if target.components.burnable and target.components.burnable:IsBurning() and inst:HasTag("firefrenzy") then
        return TUNING.WILLOW_FIREFRENZY_MULT
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.customidleanim = customidleanimfn

    inst.components.health:SetMaxHealth(TUNING.WILLOW_HEALTH)
    inst.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE

    inst.components.hunger:SetMax(TUNING.WILLOW_HUNGER)

    inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
    inst.components.sanity.custom_rate_fn = sanityfn
    inst.components.sanity.rate_modifier = TUNING.WILLOW_SANITY_MODIFIER

    inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_TINY
    inst.components.temperature:SetFreezingHurtRate(TUNING.WILSON_HEALTH / TUNING.WILLOW_FREEZING_KILL_TIME)
    inst.components.temperature:SetOverheatHurtRate(TUNING.WILSON_HEALTH / TUNING.WILLOW_OVERHEAT_KILL_TIME)

    inst.components.foodaffinity:AddPrefabAffinity("hotchili", TUNING.AFFINITY_15_CALORIES_LARGE)

    inst.components.combat.customdamagemultfn = CustomCombatDamage

    inst:ListenForEvent("ms_becameghost", OnBecameGhost)

    inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)
    inst:DoTaskInTime(0, TryToOnRespawnedFromGhost) -- NOTES(JBK): Player loading in with zero health will still be alive here delay a frame to get loaded values.
--    OnRespawnedFromGhost(inst)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/willow").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/willow").master_postinit(inst)
    else
        inst:AddComponent("fuelmaster")
        inst.components.fuelmaster:SetBonusFn(GetFuelMasterBonus)
    end
end

return MakePlayerCharacter("willow", prefabs, assets, common_postinit, master_postinit)
