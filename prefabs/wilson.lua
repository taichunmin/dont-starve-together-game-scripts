local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/beard.zip"),
}

local prefabs =
{
    "beardhair",
}

local start_inv =
{
    default =
    {
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WILSON
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function common_postinit(inst)
    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_foodie")
        inst:AddTag("quagmire_potmaster")
        inst:AddTag("quagmire_shopper")
    end

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")
end

local function OnResetBeard(inst)
    inst.AnimState:ClearOverrideSymbol("beard")
end

--tune the beard economy...
local BEARD_DAYS = { 4, 8, 16 }
local BEARD_BITS = { 1, 3,  9 }

local function OnGrowShortBeard(inst)
    inst.AnimState:OverrideSymbol("beard", "beard", "beard_short")
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowMediumBeard(inst)
    inst.AnimState:OverrideSymbol("beard", "beard", "beard_medium")
    inst.components.beard.bits = BEARD_BITS[2]
end

local function OnGrowLongBeard(inst)
    inst.AnimState:OverrideSymbol("beard", "beard", "beard_long")
    inst.components.beard.bits = BEARD_BITS[3]
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst:AddComponent("beard")
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard.prize = "beardhair"
    inst.components.beard:AddCallback(BEARD_DAYS[1], OnGrowShortBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[2], OnGrowMediumBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[3], OnGrowLongBeard)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wilson").master_postinit(inst)
    end
end

return MakePlayerCharacter("wilson", prefabs, assets, common_postinit, master_postinit)
