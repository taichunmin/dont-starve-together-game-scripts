local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/winona.fsb"),
    Asset("ANIM", "anim/player_idles_winona.zip"),
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WINONA
end

local prefabs = FlattenTree(start_inv, true)

local function common_postinit(inst)
    inst:AddTag("handyperson")
    inst:AddTag("fastbuilder")
    inst:AddTag("hungrybuilder")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_fasthands")
        inst:AddTag("quagmire_shopper")
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.health:SetMaxHealth(TUNING.WENDY_HEALTH)
    inst.components.hunger:SetMax(TUNING.WENDY_HUNGER)
    inst.components.sanity:SetMax(TUNING.WENDY_SANITY)

    inst.components.foodaffinity:AddPrefabAffinity("vegstinger", TUNING.AFFINITY_15_CALORIES_MED)

    inst.customidleanim = "idle_winona"

    inst.components.grue:SetResistance(1)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/winona").master_postinit(inst)
    end
end

return MakePlayerCharacter("winona", prefabs, assets, common_postinit, master_postinit)
