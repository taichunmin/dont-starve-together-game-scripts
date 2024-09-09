local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_mount_wes.zip"),
    Asset("ANIM", "anim/player_mount_wes_2.zip"),
    Asset("ANIM", "anim/player_mime.zip"),
    Asset("ANIM", "anim/player_mime2.zip"),
	Asset("ANIM", "anim/player_sit_mime.zip"),
    Asset("ANIM", "anim/player_idles_wes.zip"),
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WES
end

local prefabs = FlattenTree(start_inv, true)

local function common_postinit(inst)
    inst:AddTag("mime")
    inst:AddTag("balloonomancer")

    inst.AnimState:AddOverrideBuild("player_idles_wes")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_cheapskate")
    end
end

local function master_postinit(inst)
	inst.customidlestate = "wes_funnyidle"

    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	if inst.components.houndedtarget == nil then
		inst:AddComponent("houndedtarget")
	end
	inst.components.houndedtarget.target_weight_mult:SetModifier(inst, TUNING.WES_HOUND_TARGET_MULT, "misfortune")
	inst.components.houndedtarget.hound_thief = true

    inst.components.health:SetMaxHealth(TUNING.WES_HEALTH)
    inst.components.hunger:SetMax(TUNING.WES_HUNGER)
    inst.components.sanity:SetMax(TUNING.WES_SANITY)

    inst.components.foodaffinity:AddPrefabAffinity("freshfruitcrepes", TUNING.AFFINITY_15_CALORIES_SUPERHUGE)

	-- clothing is less effective
	inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY
	inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_TINY

	inst.components.grogginess.decayrate = TUNING.WES_GROGGINESS_DECAY_RATE

    inst.components.playerlightningtarget:SetHitChance(TUNING.WES_LIGHTNING_TARGET_CHANCE)

	inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)

	if inst.components.efficientuser == nil then
		inst:AddComponent("efficientuser")
	end
	inst.components.efficientuser:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.efficientuser:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.efficientuser:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.efficientuser:AddMultiplier(ACTIONS.ATTACK, TUNING.WES_DAMAGE_MULT, inst)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wes").master_postinit(inst)
    else
        inst.components.combat.damagemultiplier = TUNING.WES_DAMAGE_MULT
    end
end

return MakePlayerCharacter("wes", prefabs, assets, common_postinit, master_postinit, prefabs)
