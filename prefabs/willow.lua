local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/willow.fsb"),
    Asset("ANIM", "anim/player_idles_willow.zip"),
}

local prefabs =
{
    "lavaarena_bernie",
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
    local delta = inst.components.temperature:IsFreezing() and -TUNING.SANITYAURA_LARGE or 0
    local x, y, z = inst.Transform:GetWorldPosition()
    local max_rad = 10
    local ents = TheSim:FindEntities(x, y, z, max_rad, FIRE_TAGS)
    for i, v in ipairs(ents) do
        if v.components.burnable ~= nil and v.components.burnable:IsBurning() then
            local rad = v.components.burnable:GetLargestLightRadius() or 1
            local sz = TUNING.SANITYAURA_TINY * math.min(max_rad, rad) / max_rad
            local distsq = inst:GetDistanceSqToInst(v) - 9
            -- shift the value so that a distance of 3 is the minimum
            delta = delta + sz / math.max(1, distsq)
        end
    end
    return delta
end

local function GetFuelMasterBonus(inst, item, target)

    -- The TAG "firefuellight" is used for items that are not campfires in that they won't incubate something but Willow should benefit from fueling it.
    return (target:HasTag("firefuellight") or target:HasTag("campfire") or target.prefab == "nightlight") and TUNING.WILLOW_CAMPFIRE_FUEL_MULT or 1
end

local function OnRespawnedFromGhost(inst)
    inst.components.freezable:SetResistance(3)
end

local function common_postinit(inst)
    inst:AddTag("pyromaniac")
    inst:AddTag("expertchef")
    inst:AddTag("bernieowner")

    --For UI health meter arrows
    inst:AddTag("heatresistant") --less overheat damage

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst:AddTag("bernie_reviver")

        inst:AddComponent("pethealthbar")
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
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

    inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)
    OnRespawnedFromGhost(inst)

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
