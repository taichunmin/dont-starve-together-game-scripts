local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_mount_wes.zip"),
    Asset("ANIM", "anim/player_mime.zip"),
}

local start_inv =
{
    default =
    {
        "balloons_empty",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WES
end

local prefabs = FlattenTree(start_inv, true)

local function common_postinit(inst)
    inst:AddTag("mime")
    inst:AddTag("balloonomancer")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_cheapskate")
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH * .75)
    inst.components.hunger:SetMax(TUNING.WILSON_HUNGER * .75)
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * 1.25)
    inst.components.sanity:SetMax(TUNING.WILSON_SANITY * .75)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wes").master_postinit(inst)
    else
        inst.components.combat.damagemultiplier = TUNING.WES_DAMAGE_MULT
    end
end

return MakePlayerCharacter("wes", prefabs, assets, common_postinit, master_postinit, prefabs)
