local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/winona.fsb"),
    Asset("ANIM", "anim/player_idles_winona.zip"),
	Asset("ANIM", "anim/winona_remotecast.zip"),
	Asset("ANIM", "anim/player_mount_winona_remotecast.zip"),
	Asset("ANIM", "anim/winona_death.zip"),
	Asset("ANIM", "anim/winona_teleport.zip"),
	Asset("ANIM", "anim/winona_mount_teleport.zip"),
    Asset("SCRIPT", "scripts/prefabs/skilltree_winona.lua"),
	Asset("ANIM", "anim/roseglasses_minimap_indicator.zip"), -- From roseinspectableuser component.
}

local prefabs = {
    "inspectaclesbox", -- NOTES(JBK): From inspectaclesparticipant component.
	"inspectaclesbox2",
	"charlieresidue", -- From roseinspectableuser component.
	"flower_rose",
	"rose_petals_fx",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WINONA
end

prefabs = FlattenTree({prefabs, start_inv}, true)

local function GetPointSpecialActions(inst, pos, useitem, right, usereticulepos)
	if right then
		if useitem == nil then
			local inventory = inst.replica.inventory
			if inventory ~= nil then
				useitem = inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			end
		end
		if useitem and
			useitem.prefab == "roseglasseshat" and
			useitem:HasTag("closeinspector")
		then
			--match ReticuleTargetFn
			if usereticulepos then
				local pos2 = Vector3()
				for r = 2.5, 1, -.25 do
					pos2.x, pos2.y, pos2.z = inst.entity:LocalToWorldSpace(r, 0, 0)
					if CLOSEINSPECTORUTIL.IsValidPos(inst, pos2) then
						return { ACTIONS.LOOKAT }, pos2
					end
				end
			end

			--default
			if CLOSEINSPECTORUTIL.IsValidPos(inst, pos) then
				return { ACTIONS.LOOKAT }
			end
		end
	end
	return {}
end

local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	for r = 2.5, 1, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if CLOSEINSPECTORUTIL.IsValidPos(player, pos) then
			return pos
		end
	end
	pos.x, pos.y, pos.z = player.Transform:GetWorldPosition()
	return pos
end

local function OnSetOwner(inst)
	if inst.components.playeractionpicker then
		inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
	end
end

local function CheckCatapultSkillChanged(inst, skill)
	if skill == "winona_catapult_speed_1" or
		skill == "winona_catapult_speed_2" or
		skill == "winona_catapult_speed_3" or
		skill == "winona_catapult_aoe_1" or
		skill == "winona_catapult_aoe_2" or
		skill == "winona_catapult_aoe_3"
	then
		TheWorld:PushEvent("winona_catapultskillchanged", inst)
		return true
	end
end

local function CheckSpotlightSkillChanged(inst, skill)
	if skill == "winona_spotlight_heated" or
		skill == "winona_spotlight_ranged"
	then
		TheWorld:PushEvent("winona_spotlightskillchanged", inst)
		return true
	end
end

local function CheckBatterySkillChanged(inst, skill)
	if skill == "winona_battery_idledrain" or
		skill == "winona_battery_efficiency_1" or
		skill == "winona_battery_efficiency_2" or
		skill == "winona_battery_efficiency_3"
	then
		TheWorld:PushEvent("winona_batteryskillchanged", inst)
		return true
	end
end

local function OnActivateSkill(inst, data)
	if data then
		local changed =
			CheckCatapultSkillChanged(inst, data.skill) or
			CheckSpotlightSkillChanged(inst, data.skill) or
			CheckBatterySkillChanged(inst, data.skill)
	end
end

local function OnDeactivateSkill(inst, data)
	if data then
		if CheckCatapultSkillChanged(inst, data.skill) or
			CheckSpotlightSkillChanged(inst, data.skill) or
			CheckBatterySkillChanged(inst, data.skill)
		then
			--do nothing
		elseif data.skill == "winona_wagstaff_2" then
			inst.components.builder:RemoveRecipe("winona_teleport_pad")
			inst.components.builder:RemoveRecipe("winona_telebrella")
		elseif data.skill == "winona_wagstaff_1" then
			inst.components.builder:RemoveRecipe("winona_storage_robot")
		end
	end
end

local function OnSkillTreeInitialized(inst)
	local skilltreeupdater = inst.components.skilltreeupdater
	if not (skilltreeupdater and skilltreeupdater:IsActivated("winona_wagstaff_2")) then
		inst.components.builder:RemoveRecipe("winona_teleport_pad")
		inst.components.builder:RemoveRecipe("winona_telebrella")
	elseif not (skilltreeupdater and skilltreeupdater:IsActivated("winona_wagstaff_1")) then
		inst.components.builder:RemoveRecipe("winona_storage_robot")
	end

	TheWorld:PushEvent("winona_catapultskillchanged", inst)
	TheWorld:PushEvent("winona_spotlightskillchanged", inst)
	TheWorld:PushEvent("winona_batteryskillchanged", inst)
end

local function OnSave(inst, data)
	data.charlie_vinesave = inst.charlie_vinesave
end

local function OnPreLoad(inst, data, ents)
	inst.charlie_vinesave = data.charlie_vinesave or inst.charlie_vinesave
end

local function OnLoad(inst, data, ents)
	if not inst.components.health:IsDead() then
		inst.charlie_vinesave = nil
	end
end

local function common_postinit(inst)
    inst:AddTag("handyperson")
	inst:AddTag("basicengineer") --tag for non-portable machines so we can forget these when we unlock portable recipes
    inst:AddTag("fastbuilder")
    inst:AddTag("hungrybuilder")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_fasthands")
        inst:AddTag("quagmire_shopper")
    end

    inst:AddComponent("inspectaclesparticipant")

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.ease = true

	inst:ListenForEvent("setowner", OnSetOwner)
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
    else
        inst:AddComponent("roseinspectableuser")

		inst:ListenForEvent("onactivateskill_server", OnActivateSkill)
		inst:ListenForEvent("ondeactivateskill_server", OnDeactivateSkill)
		inst:ListenForEvent("ms_skilltreeinitialized", OnSkillTreeInitialized)

		inst.OnSave = OnSave
		inst.OnPreLoad = OnPreLoad
		inst.OnLoad = OnLoad
    end
end

return MakePlayerCharacter("winona", prefabs, assets, common_postinit, master_postinit)
