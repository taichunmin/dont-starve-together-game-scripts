local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/winona.fsb"),
}

local start_inv =
{
    default =
    {
        "sewing_tape",
        "sewing_tape",
        "sewing_tape",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WINONA
end

local prefabs = FlattenTree(start_inv, true)

for k, v in pairs(start_inv) do
    for i1, v1 in ipairs(v) do
        if not table.contains(prefabs, v1) then
            table.insert(prefabs, v1)
        end
    end
end

local function common_postinit(inst)
    inst:AddTag("handyperson")
    inst:AddTag("fastbuilder")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_fasthands")
        inst:AddTag("quagmire_shopper")
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.grue:SetResistance(1)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/winona").master_postinit(inst)
    end
end

return MakePlayerCharacter("winona", prefabs, assets, common_postinit, master_postinit)
