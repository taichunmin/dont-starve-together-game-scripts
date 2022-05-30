local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wickerbottom.fsb"),
    Asset("ANIM", "anim/player_knockedout_wickerbottom.zip"),
}

local prefabs =
{
    "spellmasterybuff",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WICKERBOTTOM
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function common_postinit(inst)
    inst:AddTag("insomniac")
    inst:AddTag("bookbuilder")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_foodie")
        inst:AddTag("quagmire_shopper")
    end

    --reader (from reader component) added to pristine state for optimization
    inst:AddTag("reader")
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst:AddComponent("reader")

    if inst.components.eater ~= nil then
        inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
        inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
        inst.components.eater.spoiled_hunger = TUNING.WICKERBOTTOM_SPOILED_FOOD_HUNGER
        inst.components.eater.spoiled_health = TUNING.WICKERBOTTOM_SPOILED_FOOD_HEALTH
    end

    inst.components.foodaffinity:AddPrefabAffinity("surfnturf", TUNING.AFFINITY_15_CALORIES_LARGE)

    inst.components.health:SetMaxHealth(TUNING.WICKERBOTTOM_HEALTH)
    inst.components.hunger:SetMax(TUNING.WICKERBOTTOM_HUNGER)
    inst.components.sanity:SetMax(TUNING.WICKERBOTTOM_SANITY)

    inst.components.builder.science_bonus = 1

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wickerbottom").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/wickerbottom").master_postinit(inst)
    end
end

return MakePlayerCharacter("wickerbottom", prefabs, assets, common_postinit, master_postinit)
