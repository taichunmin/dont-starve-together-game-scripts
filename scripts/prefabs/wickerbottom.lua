local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wickerbottom.fsb"),
    Asset("ANIM", "anim/player_knockedout_wickerbottom.zip"),
    Asset("ANIM", "anim/swap_books.zip"),
    Asset("ANIM", "anim/player_idles_wickerbottom.zip"),
}

local prefabs =
{
    "spellmasterybuff",
	"book_fx",
	"book_fx_mount",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WICKERBOTTOM
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function customidleanimfn(inst)
    return inst.AnimState:CompareSymbolBuilds("hand", "hand_wickerbottom") and "idle_wickerbottom" or nil
end

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


local SHADOWCREATURE_MUST_TAGS = { "shadowcreature", "_combat", "locomotor" }
local SHADOWCREATURE_CANT_TAGS = { "INLIMBO", "notaunt" }
local function OnReadFn(inst, book)
    if inst.components.sanity:IsInsane() then
        
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 16, SHADOWCREATURE_MUST_TAGS, SHADOWCREATURE_CANT_TAGS)

        if #ents < TUNING.BOOK_MAX_SHADOWCREATURES then
            TheWorld.components.shadowcreaturespawner:SpawnShadowCreature(inst)
        end
    end
end

local function KnockOutTest(inst)
    return false
end

local function OnRespawnedFromGhost(inst)
    inst.components.grogginess:SetKnockOutTest(KnockOutTest)
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.customidleanim = customidleanimfn

    inst:AddComponent("reader")
    inst.components.reader:SetOnReadFn(OnReadFn)

    if inst.components.eater ~= nil then
        inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
        inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH

        inst.components.eater:SetRefusesSpoiledFood(true)
    end

    inst.components.foodaffinity:AddPrefabAffinity("surfnturf", TUNING.AFFINITY_15_CALORIES_LARGE)

    inst.components.health:SetMaxHealth(TUNING.WICKERBOTTOM_HEALTH)
    inst.components.hunger:SetMax(TUNING.WICKERBOTTOM_HUNGER)
    inst.components.sanity:SetMax(TUNING.WICKERBOTTOM_SANITY)

    inst.components.builder.science_bonus = 1

    inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)
    OnRespawnedFromGhost(inst)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wickerbottom").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/wickerbottom").master_postinit(inst)
    end
end

return MakePlayerCharacter("wickerbottom", prefabs, assets, common_postinit, master_postinit)
