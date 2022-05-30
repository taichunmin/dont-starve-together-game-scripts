local MakePlayerCharacter = require("prefabs/player_common")
local INSPIRATION_BATTLESONG_DEFS = require("prefabs/battlesongdefs")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wathgrithr.fsb"),
    Asset("ANIM", "anim/wathgrithr_sing.zip"),
    Asset("ANIM", "anim/player_idles_wathgrithr.zip"),
    Asset("ANIM", "anim/wathgrithr_mount_sing.zip"),
}

local prefabs =
{
    "wathgrithr_spirit",
    "wathgrithr_bloodlustbuff_other",
    "wathgrithr_bloodlustbuff_self",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WATHGRITHR
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local smallScale = 0.5
local medScale = 0.7
local largeScale = 1.1

local function spawnspirit(inst, x, y, z, scale)
    local fx = SpawnPrefab("wathgrithr_spirit")
    fx.Transform:SetPosition(x, y, z)
    fx.Transform:SetScale(scale, scale, scale)
end

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable") or
                victim:HasTag("companion"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function onkilled(inst, data)
    local victim = data.victim
    if IsValidVictim(victim) then
        if not victim.components.health.nofadeout and (victim:HasTag("epic") or math.random() < 0.1) then
            local time = victim.components.health.destroytime or 2
            local x, y, z = victim.Transform:GetWorldPosition()
            local scale = (victim:HasTag("smallcreature") and smallScale)
                        or (victim:HasTag("largecreature") and largeScale)
                        or medScale
            inst:DoTaskInTime(time, spawnspirit, x, y, z, scale)
        end
    end
end

local function GetInspiration(inst)
    if inst.components.singinginspiration ~= nil then
        return inst.components.singinginspiration:GetPercent()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currentinspiration:value() / TUNING.INSPIRATION_MAX
    else
        return 0
    end
end

local function GetInspirationSong(inst, slot)
    if inst.components.singinginspiration ~= nil then
        return inst.components.singinginspiration:GetActiveSong(slot)
    elseif inst.player_classified ~= nil then
		return INSPIRATION_BATTLESONG_DEFS.GetBattleSongDefFromNetID(inst.player_classified.inspirationsongs[slot] ~= nil and inst.player_classified.inspirationsongs[slot]:value() or 0)
    else
        return nil
    end
end

local function CalcAvailableSlotsForInspiration(inst, inspiration_precent)
	inspiration_precent = inspiration_precent or GetInspiration(inst)

	local slots_available = 0
	for i = #TUNING.BATTLESONG_THRESHOLDS, 1, -1 do
		if inspiration_precent > TUNING.BATTLESONG_THRESHOLDS[i] then
			slots_available = i
			break
		end
	end
	return slots_available
end

local function OnTakeDrowningDamage(inst)
    inst.components.singinginspiration:SetInspiration(0)
end

local function common_postinit(inst)
    inst:AddTag("valkyrie")
    inst:AddTag("battlesinger")

    inst:RemoveTag("usesvegetarianequipment")

    inst.AnimState:AddOverrideBuild("wathgrithr_sing")
    inst.customidleanim = "idle_wathgrithr"

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_butcher")
        inst:AddTag("quagmire_shopper")
    end

    inst.components.talker.mod_str_fn = Umlautify

	-- Didn't want to make singinginspiration a networked component
	inst.GetInspiration = GetInspiration
	inst.GetInspirationSong = GetInspirationSong
	inst.CalcAvailableSlotsForInspiration = CalcAvailableSlotsForInspiration
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.talker_path_override = "dontstarve_DLC001/characters/"

    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODTYPE.MEAT, FOODTYPE.GOODIES })
    end

    inst.components.foodaffinity:AddPrefabAffinity("turkeydinner", TUNING.AFFINITY_15_CALORIES_HUGE )

    inst.components.health:SetMaxHealth(TUNING.WATHGRITHR_HEALTH)
    inst.components.hunger:SetMax(TUNING.WATHGRITHR_HUNGER)
    inst.components.sanity:SetMax(TUNING.WATHGRITHR_SANITY)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wathgrithr").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        --event_server_data("quagmire", "prefabs/wathgrithr").master_postinit(inst)
    else

        inst:AddComponent("singinginspiration")
		inst.components.singinginspiration:SetCalcAvailableSlotsForInspirationFn(CalcAvailableSlotsForInspiration)
        inst.components.singinginspiration:SetValidVictimFn(IsValidVictim)

        inst:AddComponent("battleborn")
        inst.components.battleborn:SetBattlebornBonus(TUNING.WATHGRITHR_BATTLEBORN_BONUS)
        inst.components.battleborn:SetSanityEnabled(true)
        inst.components.battleborn:SetHealthEnabled(true)
        inst.components.battleborn:SetValidVictimFn(IsValidVictim)

        if inst.components.drownable ~= nil then
            inst.components.drownable:SetOnTakeDrowningDamageFn(OnTakeDrowningDamage)
        end

        inst.components.combat.damagemultiplier = TUNING.WATHGRITHR_DAMAGE_MULT
        inst.components.health:SetAbsorptionAmount(TUNING.WATHGRITHR_ABSORPTION)

        inst:ListenForEvent("killed", onkilled)
    end

end

return MakePlayerCharacter("wathgrithr", prefabs, assets, common_postinit, master_postinit)