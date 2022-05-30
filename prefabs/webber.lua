local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/webber_spiderwhistle.zip"),
    Asset("ANIM", "anim/player_spider_repellent.zip"),
    Asset("ANIM", "anim/webber_mount_spiderwhistle.zip"),
    Asset("ANIM", "anim/player_mount_spider_repellent.zip"),
    Asset("ANIM", "anim/player_idles_webber.zip"),
    Asset("SOUND", "sound/webber.fsb"),
    Asset("ANIM", "anim/beard_silk.zip"),
}

local prefabs =
{
    "silk",
    "webber_spider_minion",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WEBBER
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function CLIENT_Webber_HostileTest(inst, target)
    return (target:HasTag("hostile") or target:HasTag("pig") or target:HasTag("catcoon"))
        and (not target:HasTag("spiderden"))
        and (not target:HasTag("spider") or target:HasTag("spiderqueen"))
end

local function common_postinit(inst)
    inst:AddTag("spiderwhisperer")
    inst:AddTag("playermonster")
    inst:AddTag("monster")
    inst:AddTag("dualsoul")
    inst:AddTag(UPGRADETYPES.SPIDER.."_upgradeuser")

    inst.customidleanim = "idle_webber"
    inst.AnimState:AddOverrideBuild("player_idles_webber")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("fastpicker")
        inst:AddTag("quagmire_farmhand")
        inst:AddTag("quagmire_shopper")
    end

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")

    inst.AnimState:AddOverrideBuild("webber_spiderwhistle")
    inst.AnimState:AddOverrideBuild("player_spider_repellent")

    inst.HostileTest = CLIENT_Webber_HostileTest
end

--tune the beard economy...
local BEARD_DAYS = { 3, 6, 9 }
local BEARD_BITS = { 1, 3, 6 }

local function OnResetBeard(inst)
    inst.AnimState:ClearOverrideSymbol("beard")
end

local function OnGrowShortBeard(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_short")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beardsilk_short" )
    end
    inst.components.beard.bits = BEARD_BITS[1]
end

local function OnGrowMediumBeard(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_medium")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beardsilk_medium" )
    end
    inst.components.beard.bits = BEARD_BITS[2]
end

local function OnGrowLongBeard(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_long")
    else
        inst.AnimState:OverrideSkinSymbol("beard", skinname, "beardsilk_long" )
    end
    inst.components.beard.bits = BEARD_BITS[3]
end

local function ReleaseSpiderFollowers(inst)
    for follower, v in pairs(inst.components.leader.followers) do
        if follower:HasTag("spider") and follower.defensive then
            follower.defensive = false
            follower.no_targeting = false
        end
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.talker_path_override = "dontstarve_DLC001/characters/"

    if inst.components.eater ~= nil then
        inst.components.eater:SetStrongStomach(true)
        inst.components.eater:SetCanEatRawMeat(true)
    end

    inst.components.foodaffinity:AddPrefabAffinity("icecream", TUNING.AFFINITY_15_CALORIES_MED)

    inst.components.health:SetMaxHealth(TUNING.WEBBER_HEALTH)
    inst.components.hunger:SetMax(TUNING.WEBBER_HUNGER)
    inst.components.sanity:SetMax(TUNING.WEBBER_SANITY)

    inst:AddComponent("beard")
    inst.components.beard.insulation_factor = TUNING.WEBBER_BEARD_INSULATION_FACTOR
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard.prize = "silk"
    inst.components.beard.is_skinnable = true
    inst.components.beard:AddCallback(BEARD_DAYS[1], OnGrowShortBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[2], OnGrowMediumBeard)
    inst.components.beard:AddCallback(BEARD_DAYS[3], OnGrowLongBeard)

    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.fasteroncreep = true
    --inst.components.locomotor:SetFasterOnCreep(true)

    inst:ListenForEvent("attacked",      ReleaseSpiderFollowers)
    inst:ListenForEvent("onattackother", ReleaseSpiderFollowers)
    inst:ListenForEvent("death",         ReleaseSpiderFollowers)
    inst:ListenForEvent("onremove",      ReleaseSpiderFollowers)


    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/webber").master_postinit(inst)
    end
end

return MakePlayerCharacter("webber", prefabs, assets, common_postinit, master_postinit)
