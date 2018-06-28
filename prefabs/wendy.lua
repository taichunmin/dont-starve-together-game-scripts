local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wendy.fsb"),
}

local prefabs =
{
    "lavaarena_abigail",
}

local start_inv =
{
    default =
    {
        "abigail_flower",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WENDY
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function common_postinit(inst)
    inst:AddTag("ghostlyfriend")

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst:AddComponent("pethealthbar")
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_grillmaster")
        inst:AddTag("quagmire_shopper")
    end
end

local function OnDespawn(inst)
    if inst.abigail ~= nil then
        inst.abigail.components.lootdropper:SetLoot(nil)
        inst.abigail.components.health:SetInvincible(true)
        inst.abigail:PushEvent("death")
        --in case the state graph got interrupted somehow, just force
        --removal after the dissipate animation should've finished
        inst.abigail:DoTaskInTime(25 * FRAMES, inst.abigail.Remove)
    end
end

local function OnSave(inst, data)
    if inst.abigail ~= nil then
        data.abigail = inst.abigail:GetSaveRecord()
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.abigail ~= nil and inst.abigail == nil then
        local abigail = SpawnSaveRecord(data.abigail)
        if abigail ~= nil then
            if inst.migrationpets ~= nil then
                table.insert(inst.migrationpets, abigail)
            end
            abigail.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
            abigail:LinkToPlayer(inst)
        end
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT

    inst.abigail = nil

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wendy").master_postinit(inst, OnSave, OnLoad)
    else
        inst.abigail_flowers = {}

        inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT

        inst.OnDespawn = OnDespawn
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
    end
end

return MakePlayerCharacter("wendy", prefabs, assets, common_postinit, master_postinit)
