local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_idles_wonkey.zip"),
    Asset("SOUND", "sound/webber.fsb"),
}

local prefabs =
{
    "monkey_cursed_pre_fx",
    "monkey_cursed_pst_fx",
    "monkey_deform_pre_fx",
    "monkey_deform_pst_fx",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WONKEY
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function common_postinit(inst)
    inst:AddTag("wonkey")
    inst:AddTag("monkey")
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.foodaffinity:AddPrefabAffinity("cave_banana", TUNING.AFFINITY_15_CALORIES_SMALL)

    inst.customidleanim = "idle_wonkey"
    inst.talker_path_override = "monkeyisland/characters/"

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WONKEY_WALK_SPEED_PENALTY

    inst.components.health:SetMaxHealth(TUNING.WONKEY_HEALTH)
    inst.components.hunger:SetMax(TUNING.WONKEY_HUNGER)
    inst.components.sanity:SetMax(TUNING.WONKEY_SANITY)
end

return MakePlayerCharacter("wonkey", prefabs, assets, common_postinit, master_postinit)
