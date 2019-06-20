local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/webber.fsb"),
    Asset("ANIM", "anim/beard_silk.zip"),
}

local prefabs =
{
    "silk",
    "webber_spider_minion",
}

local start_inv =
{
    default =
    {
        "spidereggsack",
        "monstermeat",
        "monstermeat",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WEBBER
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function common_postinit(inst)
    inst:AddTag("spiderwhisperer")
    inst:AddTag("playermonster")
    inst:AddTag("monster")
    inst:AddTag("dualsoul")
    inst:AddTag(UPGRADETYPES.SPIDER.."_upgradeuser")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("fastpicker")
        inst:AddTag("quagmire_farmhand")
        inst:AddTag("quagmire_shopper")
    end

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")
end

--tune the beard economy...
local BEARD_DAYS = { 3, 6, 9 }
local BEARD_BITS = { 1, 3, 6 }

local function OnResetBeard(inst)
    inst.AnimState:ClearOverrideSymbol("beard")
end

local function OnGrowShortBeard(inst)
    inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_short")
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowMediumBeard(inst)
    inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_medium")
    inst.components.beard.bits = BEARD_BITS[2]
end

local function OnGrowLongBeard(inst)
    inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_long")
    inst.components.beard.bits = BEARD_BITS[3]
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.talker_path_override = "dontstarve_DLC001/characters/"

    if inst.components.eater ~= nil then
        inst.components.eater.strongstomach = true
    end

    inst.components.health:SetMaxHealth(TUNING.WEBBER_HEALTH)
    inst.components.hunger:SetMax(TUNING.WEBBER_HUNGER)
    inst.components.sanity:SetMax(TUNING.WEBBER_SANITY)

    inst:AddComponent("beard")
    inst.components.beard.insulation_factor = TUNING.WEBBER_BEARD_INSULATION_FACTOR
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard.prize = "silk"
    inst.components.beard:AddCallback(BEARD_DAYS[1], OnGrowShortBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[2], OnGrowMediumBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[3], OnGrowLongBeard)

    inst.components.locomotor:SetTriggersCreep(false)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/webber").master_postinit(inst)
    end
end

return MakePlayerCharacter("webber", prefabs, assets, common_postinit, master_postinit)
