
local MakePlayerCharacter = require("prefabs/player_common")
local WandaAgeBadge = require("widgets/wandaagebadge")
local easing = require("easing")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ATLAS", "images/hud_wanda.xml"),
    Asset("IMAGE", "images/hud_wanda.tex"),

    Asset("ANIM", "anim/status_oldage.zip"),
    Asset("ANIM", "anim/wanda_basics.zip"),
    Asset("ANIM", "anim/wanda_mount_basics.zip"),
    Asset("ANIM", "anim/wanda_attack.zip"),
    Asset("ANIM", "anim/wanda_casting.zip"),
    Asset("ANIM", "anim/wanda_casting2.zip"),
    Asset("ANIM", "anim/wanda_mount_casting2.zip"),
    Asset("ANIM", "anim/player_idles_wanda.zip"),
}

local prefabs =
{
	"oldager_become_younger_front_fx",
	"oldager_become_younger_back_fx",
	"oldager_become_older_fx",
	"oldager_become_younger_front_fx_mount",
	"oldager_become_younger_back_fx_mount",
	"oldager_become_older_fx_mount",
    
	"wanda_attack_pocketwatch_old_fx",
	"wanda_attack_pocketwatch_normal_fx",
	"wanda_attack_shadowweapon_old_fx",
	"wanda_attack_shadowweapon_normal_fx",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WANDA
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function PlayAgingFx(inst, fx_name)
	if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
		fx_name = fx_name .. "_mount"
	end

	local fx = SpawnPrefab(fx_name)
	fx.entity:SetParent(inst.entity)
end

local function UpdateSkinMode(inst, mode, delay)
	if inst.queued_skinmode_task ~= nil then
		inst.updateskinmodetask:Cancel()
		inst.updateskinmodetask = nil
	end

	if delay then
		if inst.queued_skinmode ~= nil then
		    inst.components.skinner:SetSkinMode(inst.queued_skinmode, "wilson")
		end
		inst.queued_skinmode = mode
		inst.updateskinmodetask = inst:DoTaskInTime(FRAMES * 15, UpdateSkinMode, mode)
	else
	    inst.components.skinner:SetSkinMode(mode, "wilson")
		inst.queued_skinmode = nil
	end
end

local function becomeold(inst, silent)
    if inst.age_state == "old" then
        return
    end

	inst.overrideskinmode = "old_skin"
	if not inst.sg:HasStateTag("ghostbuild") then
		UpdateSkinMode(inst, "old_skin", not silent)
	end

    if not silent then
        inst.sg:PushEvent("becomeolder_wanda")
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_WANDA_NORMALTOOLD"))
        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition")
		PlayAgingFx(inst, "oldager_become_older_fx")
    end

	inst.components.positionalwarp:SetWarpBackDist(TUNING.WANDA_WARP_DIST_OLD)

    inst.talksoundoverride = "wanda2/characters/wanda/talk_old_LP"
    --inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_small"
    inst.age_state = "old"

    inst:AddTag("slowbuilder")
	inst.components.inventory.noheavylifting = true
    inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WANDA_OLD_HAMMER_EFFECTIVENESS, inst)
    inst.components.staffsanity:SetMultiplier(TUNING.WANDA_STAFFSANITY_OLD)
end

local function becomenormal(inst, silent)
    if inst.age_state == "normal" then
        return
    end

	inst.overrideskinmode = "normal_skin"
	if not inst.sg:HasStateTag("ghostbuild") then
		UpdateSkinMode(inst, "normal_skin", not silent)
	end

    if not silent then
        if inst.age_state == "young" then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_WANDA_YOUNGTONORMAL"))
            inst.sg:PushEvent("becomeolder_wanda")
            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition")
			PlayAgingFx(inst, "oldager_become_older_fx")
        elseif inst.age_state == "old" then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_WANDA_OLDTONORMAL"))
            inst.sg:PushEvent("becomeyounger_wanda")
            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
			PlayAgingFx(inst, "oldager_become_younger_front_fx")
			PlayAgingFx(inst, "oldager_become_younger_back_fx")
        end
    end

	inst.components.positionalwarp:SetWarpBackDist(TUNING.WANDA_WARP_DIST_NORMAL)

    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil
    inst.age_state = "normal"

    inst:RemoveTag("slowbuilder")
	inst.components.inventory.noheavylifting = false
    inst.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
    inst.components.staffsanity:SetMultiplier(TUNING.WANDA_STAFFSANITY_NORMAL)
end

local function becomeyoung(inst, silent)
    if inst.age_state == "young" then
        return
    end

	inst.overrideskinmode = "young_skin"
	if not inst.sg:HasStateTag("ghostbuild") then
		UpdateSkinMode(inst, "young_skin", not silent)
	end

    if not silent then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_WANDA_NORMALTOYOUNG"))
        inst.sg:PushEvent("becomeyounger_wanda")
        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
		PlayAgingFx(inst, "oldager_become_younger_front_fx")
		PlayAgingFx(inst, "oldager_become_younger_back_fx")
    end

	inst.components.positionalwarp:SetWarpBackDist(TUNING.WANDA_WARP_DIST_YOUNG)

    inst.talksoundoverride = "wanda2/characters/wanda/talk_young_LP"
    --inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_large"
    inst.age_state = "young"
    
    inst:RemoveTag("slowbuilder")
	inst.components.inventory.noheavylifting = false
    inst.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
    inst.components.staffsanity:SetMultiplier(TUNING.WANDA_STAFFSANITY_YOUNG)
end


local function onhealthchange(inst, data, forcesilent)
    if inst.sg:HasStateTag("nomorph") or
        inst:HasTag("playerghost") or
        inst.components.health:IsDead() then
        return
    end

    local silent = inst.sg:HasStateTag("silentmorph") or not inst.entity:IsVisible() or forcesilent
	local health = inst.components.health ~= nil and inst.components.health:GetPercent() or 0

    if inst.age_state == "old" then
        if health > TUNING.WANDA_AGE_THRESHOLD_OLD then
            if silent and health >= TUNING.WANDA_AGE_THRESHOLD_YOUNG then
                becomeyoung(inst, true)
            else
                becomenormal(inst, silent)
            end
        end
    elseif inst.age_state == "young" then
        if health < TUNING.WANDA_AGE_THRESHOLD_YOUNG then
            if silent and health <= TUNING.WANDA_AGE_THRESHOLD_OLD then
                becomeold(inst, true)
            else
                becomenormal(inst, silent)
            end
        end
    elseif health <= TUNING.WANDA_AGE_THRESHOLD_OLD then
        becomeold(inst, silent)
    elseif health >= TUNING.WANDA_AGE_THRESHOLD_YOUNG then
        becomeyoung(inst, silent)
    else
        becomenormal(inst, silent)
    end
end

local function GetEquippableDapperness(owner, equippable)
    local dapperness = equippable:GetDapperness(owner, owner.components.sanity.no_moisture_penalty)
    if equippable.inst:HasTag("shadow_item") then
        if owner.age_state == "old" then
            return dapperness * TUNING.WANDA_SHADOW_RESISTANCE_OLD
        elseif owner.age_state == "normal" then
            return dapperness * TUNING.WANDA_SHADOW_RESISTANCE_NORMAL
        end
        return dapperness * TUNING.WANDA_SHADOW_RESISTANCE_YOUNG
    end

    return dapperness
end

--------------------------------------------------------------------------

local function onnewstate(inst)
    if inst._wasnomorph ~= inst.sg:HasStateTag("nomorph") then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            onhealthchange(inst)
        end
    end
end

local function onbecamehuman(inst, data, isloading)
	inst.age_state = nil
	onhealthchange(inst, nil, true)

    inst:ListenForEvent("healthdelta", onhealthchange)
    inst:ListenForEvent("newstate", onnewstate)

	inst.components.health.canheal = false
	inst._no_healing = true

	if inst.components.positionalwarp ~= nil then
		if not isloading then
			inst.components.positionalwarp:Reset()
		end
		if inst.components.inventory:HasItemWithTag("pocketwatch_warp", 1) then
			inst.components.positionalwarp:EnableMarker(true)
		end
	end

end

local function onbecameghost(inst, data)
	inst._wasnomorph = nil
    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil

	inst.age_state = "old"

    inst:RemoveEventCallback("healthdelta", onhealthchange)
    inst:RemoveEventCallback("newstate", onnewstate)

	if inst.components.positionalwarp ~= nil then
		inst.components.positionalwarp:EnableMarker(false)
	end
end

--------------------------------------------------------------------------

local function redirect_to_oldager(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
	return inst.components.oldager ~= nil and inst.components.oldager:OnTakeDamage(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
end


--------------------------------------------------------------------------
local function CustomCombatDamage(inst, target, weapon, multiplier, mount)
    if mount == nil then
        if weapon ~= nil and weapon:HasTag("shadow_item") then
			return inst.age_state == "old" and TUNING.WANDA_SHADOW_DAMAGE_OLD
					or inst.age_state == "normal" and TUNING.WANDA_SHADOW_DAMAGE_NORMAL
					or TUNING.WANDA_SHADOW_DAMAGE_YOUNG
		else
			return inst.age_state == "old" and TUNING.WANDA_REGULAR_DAMAGE_OLD
					or inst.age_state == "normal" and TUNING.WANDA_REGULAR_DAMAGE_NORMAL
					or TUNING.WANDA_REGULAR_DAMAGE_YOUNG
        end
    end

    return 1
end

local function ShadowWeaponFx(inst, target, damage, stimuli, weapon, damageresolved)
    if weapon ~= nil and target ~= nil and target:IsValid() and weapon:IsValid() and weapon:HasTag("shadow_item") then
		local fx_prefab = inst.age_state == "old" and (weapon:HasTag("pocketwatch") and "wanda_attack_pocketwatch_old_fx" or "wanda_attack_shadowweapon_old_fx")
				or inst.age_state == "normal" and (weapon:HasTag("pocketwatch") and "wanda_attack_pocketwatch_normal_fx" or "wanda_attack_shadowweapon_normal_fx")
				or nil

		if fx_prefab ~= nil then
			local fx = SpawnPrefab(fx_prefab)

			local x, y, z = target.Transform:GetWorldPosition()
			local radius = target:GetPhysicsRadius(.5)
			local angle = (inst.Transform:GetRotation() - 90) * DEGREES
			fx.Transform:SetPosition(x + math.sin(angle) * radius, 0, z + math.cos(angle) * radius)
		end
	end
end

--------------------------------------------------------------------------
local function OnGetItem(inst, data)
    local item = data ~= nil and data.item or nil

    if item ~= nil and item:HasTag("pocketwatch") then
        item.components.inventoryitem.keepondeath = item.prefab ~= "pocketwatch_revive" -- drop the revive watch so she can haunt it
        item.components.inventoryitem.keepondrown = true
        item:AddTag("nosteal") -- pocket watches in her inventory are attached to her outfit (see art)
    end
end

local function OnLoseItem(inst, data)
    local item = data ~= nil and (data.prev_item or data.item)
    if item and item:IsValid() and item:HasTag("pocketwatch") then
		item.components.inventoryitem.keepondeath = false
		item.components.inventoryitem.keepondrown = false
		item:RemoveTag("nosteal")
    end
end

local function on_show_warp_marker(inst)
	inst.components.positionalwarp:EnableMarker(true)
end

local function on_hide_warp_marker(inst)
	inst.components.positionalwarp:EnableMarker(false)
end

local function DelayedWarpBackTalker(inst)
	-- if the player starts moving right away then we can skip this
	if inst.sg == nil or inst.sg:HasStateTag("idle") then 
		inst.components.talker:Say(GetString(inst, "ANNOUNCE_POCKETWATCH_RECALL"))
	end 
end

local function OnWarpBack(inst, data)
	if inst.components.positionalwarp ~= nil then
		if data ~= nil and data.reset_warp then
			inst.components.positionalwarp:Reset()
			inst:DoTaskInTime(15 * FRAMES, DelayedWarpBackTalker) 
		else
			inst.components.positionalwarp:GetHistoryPosition(true)
		end
	end
end

--------------------------------------------------------------------------

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    elseif inst:HasTag("corpse") then
        onbecameghost(inst, { corpse = true })
    else
        onbecamehuman(inst, nil, true)
    end
end

local function OnNewSpawn(inst)
	onload(inst)
end

--------------------------------------------------------------------------

local function common_postinit(inst)
	inst:AddTag("clockmaker")
	inst:AddTag("pocketwatchcaster")
	inst:AddTag("health_as_oldage")

    inst.AnimState:AddOverrideBuild("player_idles_wanda")
    inst.AnimState:AddOverrideBuild("wanda_basics")
    inst.AnimState:AddOverrideBuild("wanda_attack")

    if TheNet:GetServerGameMode() == "lavaarena" then
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    else
		if not TheNet:IsDedicated() then
			inst.CreateHealthBadge = WandaAgeBadge
		end
	end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.customidleanim = "idle_wanda"
    inst.talker_path_override = "wanda2/characters/"

	inst:AddComponent("oldager")
	inst.components.oldager:AddValidHealingCause("pocketwatch_heal")
	inst.components.oldager:AddValidHealingCause("debug_key")

	inst:AddComponent("positionalwarp")
	inst:DoTaskInTime(0, function() inst.components.positionalwarp:SetMarker("pocketwatch_warp_marker") end)

    inst:AddComponent("staffsanity")

	inst._no_healing = true
	inst.deathanimoverride = "death_wanda"

    inst.components.foodaffinity:AddPrefabAffinity("taffy", TUNING.AFFINITY_15_CALORIES_MED)

	inst.components.health:SetMaxHealth(TUNING.WANDA_OLDAGER)
    inst.components.health:SetPercent(0.70, true)
    inst.components.health.redirect = redirect_to_oldager
	inst.components.health.canheal = false
	inst.components.health.disable_penalty = true
    inst.resurrect_multiplier = TUNING.OLDAGE_HEALTH_SCALE
	
	inst:ListenForEvent("show_warp_marker", on_show_warp_marker)
	inst:ListenForEvent("hide_warp_marker", on_hide_warp_marker)
    
	inst:ListenForEvent("itemget", OnGetItem)
    inst:ListenForEvent("equip", OnGetItem)
    inst:ListenForEvent("itemlose", OnLoseItem)
    inst:ListenForEvent("unequip", OnLoseItem)

    inst:ListenForEvent("onwarpback", OnWarpBack)
	
	inst.components.hunger:SetMax(TUNING.WANDA_HUNGER)
	inst.components.sanity:SetMax(TUNING.WANDA_SANITY)
    inst.components.sanity.get_equippable_dappernessfn = GetEquippableDapperness

    inst.components.combat.customdamagemultfn = CustomCombatDamage
	inst.components.combat.onhitotherfn = ShadowWeaponFx

	inst.skeleton_prefab = nil

    if TheNet:GetServerGameMode() == "lavaarena" then
	
    else
		inst.OnLoad = onload
		inst.OnNewSpawn = OnNewSpawn
	end

end

return MakePlayerCharacter("wanda", prefabs, assets, common_postinit, master_postinit)
