local easing = require("easing")
local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_wolfgang.zip"),
    Asset("ANIM", "anim/player_mount_wolfgang.zip"),
    Asset("ANIM", "anim/player_wolfgang_dumbbell.zip"),
    
    Asset("ANIM", "anim/player_idles_wolfgang.zip"),
    Asset("ANIM", "anim/player_idles_wolfgang_skinny.zip"),
    Asset("ANIM", "anim/player_idles_wolfgang_mighty.zip"),

    Asset("SOUND", "sound/wolfgang.fsb"),
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WOLFGANG
end

local prefabs =
{
    "wolfgang_mighty_fx",
}
prefabs = FlattenTree({ prefabs, start_inv }, true)

local function GetThreatCount(inst)
    local monster_count = 0
    local epic_count = 0

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.WOLFGANG_SANITY_RANGE, nil, { "bedazzled", "INLIMBO", "FX", "NOCLICK", "DECOR" }, { "monster", "epic" })

    for k, v in pairs(ents) do
        if v:HasTag("epic") then
            epic_count = epic_count + 1
        elseif v:HasTag("monster") then
            monster_count = monster_count + 1
        end
    end

    return monster_count, epic_count
end

local function CheckForPlayers(inst)
    local monster_count, epic_count = GetThreatCount(inst)
    
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TUNING.WOLFGANG_SANITY_RANGE, true)
    
    local player_count = #players
    player_count = player_count - 1 -- Subtract Wolfgang himself
    
    local PVP_enabled = TheNet:GetPVPEnabled()

    local follower_count = inst.components.leader:CountFollowers()
    if not PVP_enabled then
        for k, v in pairs(players) do
            if v ~= inst then
                follower_count = follower_count + v.components.leader:CountFollowers()
            end
        end
    end

    local sanity_rate = math.min(2, math.max(TUNING.WOLFGANG_SANITY_DRAIN, TUNING.WOLFGANG_SANITY_DRAIN + ((epic_count * 3) + monster_count - player_count - follower_count) * TUNING.WOLFGANG_SANITY_PER_MONSTER))
    inst.components.sanity.neg_aura_mult = sanity_rate

    if follower_count > 0 or player_count > 0 then
        inst.components.sanity.night_drain_mult = TUNING.WOLFGANG_SANITY_NIGHT_DRAIN_SMALL
    else
        inst.components.sanity.night_drain_mult = TUNING.WOLFGANG_SANITY_NIGHT_DRAIN
    end
end


local function StartPlayerCheck(inst)
    if inst.playercheck_task ~= nil then
        inst.playercheck_task:Cancel()
        inst.playercheck_task = nil
    end

    inst.playercheck_task = inst:DoPeriodicTask(2, CheckForPlayers)
end

local function onbecamehuman(inst, data)
    inst.components.mightiness:Resume()
    inst.components.mightiness:SetPercent(0.5, true, true)

    StartPlayerCheck(inst)
end

local function onbecameghost(inst, data)
    inst.components.mightiness:Pause()

    if inst.playercheck_task ~= nil then
        inst.playercheck_task:Cancel()
        inst.playercheck_task = nil
    end
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    elseif inst:HasTag("corpse") then
        onbecameghost(inst, { corpse = true })
    else
        StartPlayerCheck(inst)
    end
end

local function OnEquip(inst, data)
    local item = data ~= nil and data.item or nil
    if item and item:HasTag("heavy") then
        inst.components.mightiness:Pause()
    end
end

local function OnUnequip(inst, data)
    local item = data ~= nil and data.item or nil
    if item and item:HasTag("heavy") then
        inst.components.mightiness:Resume()
    end
end

local function OnDoingWork(inst, data)
    if data ~= nil and data.target ~= nil then
		local workable = data.target.components.workable
		if workable ~= nil then
			if inst.components.mightiness:IsMighty() then
				if workable.workleft > 0 and math.random() >= TUNING.MIGHTY_WORK_CHANCE then
					workable.workleft = 0
				end
			end

			local work_action = workable:GetWorkAction() 
			if work_action ~= nil then
				local gains = TUNING.WOLFGANG_MIGHTINESS_WORK_GAIN[work_action.id]
				if gains ~= nil then
					inst.components.mightiness:DoDelta(gains)	
				end
			end
		end
    end
end

local function OnTilling(inst)
	inst.components.mightiness:DoDelta(TUNING.WOLFGANG_MIGHTINESS_WORK_GAIN.TILL)	
end

local function OnRowing(inst)
	inst.components.mightiness:DoDelta(TUNING.WOLFGANG_MIGHTINESS_WORK_GAIN.ROW)	
end

local function OnSailBoost(inst)
	inst.components.mightiness:DoDelta(TUNING.WOLFGANG_MIGHTINESS_WORK_GAIN.LOWER_SAIL_BOOST)	
end

local function OnTerraform(inst)
	inst.components.mightiness:DoDelta(TUNING.WOLFGANG_MIGHTINESS_WORK_GAIN.TERRAFORM)	
end

local function OnHitOther(inst, data)
	local target = data.target
	if target ~= nil and data.weapon == nil or data.weapon.components.inventoryitem:IsHeldBy(inst) then
		local delta = target:HasTag("epic") and TUNING.WOLFGANG_MIGHTINESS_ATTACK_GAIN_GIANT
					or target:HasTag("smallcreature") and TUNING.WOLFGANG_MIGHTINESS_ATTACK_GAIN_SMALLCREATURE
					or TUNING.WOLFGANG_MIGHTINESS_ATTACK_GAIN_DEFAULT

		inst.components.mightiness:DoDelta(delta)	

		--print("OnHitOther", data.target, data.weapon, delta, data.weapon == nil or data.weapon.components.inventoryitem:IsHeldBy(inst))
	end
end


--------------------------------------------------------------------------

local BASE_PHYSICS_RADIUS = .5
local AVATAR_SCALE = 1.5

local function lavaarena_onisavatardirty(inst)
    inst:SetPhysicsRadiusOverride(inst._isavatar:value() and AVATAR_SCALE * BASE_PHYSICS_RADIUS or BASE_PHYSICS_RADIUS)
end

local function GetMightiness(inst)
    if inst.components.mightiness ~= nil then
        return inst.components.mightiness:GetPercent()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currentmightiness:value() / TUNING.MIGHTINESS_MAX
    else
        return 0
    end
end

local function GetMightinessRateScale(inst)
    if inst.components.mightiness ~= nil then
        return inst.components.mightiness:GetRateScale()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.mightinessratescale:value()
    else
        return RATE_SCALE.NEUTRAL
    end
end

local function GetCurrentMightinessState(inst)
    if inst.components.mightiness ~= nil then
        return inst.components.mightiness:GetState()
    else
        local value = inst.player_classified.currentmightiness:value()

        if value >= TUNING.MIGHTY_THRESHOLD then
            return "mighty"
        elseif value >= TUNING.WIMPY_THRESHOLD then
            return "normal"
        else
            return "wimpy"
        end
    end
end

------------------------------------------------

local function bell_SetPercent(inst, val)
    val = val or inst.bell_percent

    if inst.bell ~= nil then
        inst.bell.AnimState:SetPercent("meter_move", val)
    end

    inst.bell_percent = val
end

local function updatebell(inst, dt)

    if inst.bell_forward and inst.bell_percent >= 1 then
        inst.bell_forward = false
    elseif not inst.bell_forward and inst.bell_percent <= 0 then
        inst.bell_forward = true
    end

    local playsound = nil
    local oldpercent = inst.bell_percent

    if inst.bell_forward then
        inst.bell_SetPercent(inst, inst.bell_percent + (dt * inst.bell_speed))
        if (oldpercent < 1 and inst.bell_percent >= 1 ) then
            playsound = true
        end
    else
        inst.bell_SetPercent(inst, inst.bell_percent - (dt * inst.bell_speed))
        if (oldpercent > 0 and inst.bell_percent <= 0) then
            playsound = true
        end
    end

    if playsound then
        inst.SoundEmitter:PlaySound("wolfgang2/common/gym/rhythm")
    end
end

local function Startbell(inst)
    if inst == ThePlayer then  
        if not inst.updateset then
            inst.components.updatelooper:AddOnUpdateFn(updatebell)
            inst.updateset = true
        end
    end
end

local function ResetBell(inst)
    inst.bell_forward = true
    inst.bell_SetPercent(inst, 0)
end

local function Stopbell(inst)
    inst.components.updatelooper:RemoveOnUpdateFn(updatebell)
    inst.updateset = nil

    inst:ResetBell()
end

local function Pausebell(inst)
    inst.components.updatelooper:RemoveOnUpdateFn(updatebell)
    inst.updateset = nil
end

local function onliftgym(inst,data)
    if data.result == "fail" then
        inst:Pausebell()        
    end
end

local function CalcLiftAction(inst)
    local busy = inst:HasTag("busy")

    local percent = inst.bell_percent
    local level  = inst.player_classified.inmightygym:value() + 1

    local success_min = TUNING["BELL_SUCCESS_MIN_"..level]
    local success_max = TUNING["BELL_SUCCESS_MAX_"..level]

    local success_mid_min = TUNING["BELL_MID_SUCCESS_MIN_"..level]
    local success_mid_max = TUNING["BELL_MID_SUCCESS_MAX_"..level]

    if not busy and success_min and percent >= success_min and percent <= success_max then
        return ACTIONS.LIFT_GYM_SUCCEED_PERFECT
    elseif not busy and percent >= success_mid_min and percent <= success_mid_max then
        return ACTIONS.LIFT_GYM_SUCCEED
    else
        return ACTIONS.LIFT_GYM_FAIL
    end
end

local function LeftClickPicker(inst, target, position)
    if inst:HasTag("ingym") then
        if inst ~= ThePlayer then
            if CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_SUCCEED_PERFECT or CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_SUCCEED or CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_FAIL then
                return inst.components.playeractionpicker:SortActionList({ CLIENT_REQUESTED_ACTION })
            end
        else
            return inst.components.playeractionpicker:SortActionList({ CalcLiftAction(inst) }, position)
        end
    end
    return {}
end

local function RightClickPicker(inst, target, position)
    if inst:HasTag("ingym") then
        return inst.components.playeractionpicker:SortActionList({ ACTIONS.LEAVE_GYM }, inst:GetPosition())
    end
    return {}
end

local function PointSpecialActions(inst, pos, useitem, right)
	if inst.components.playercontroller:IsEnabled() then
		if right then
			return { ACTIONS.LEAVE_GYM }

		else
			if inst ~= ThePlayer then
				if CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_SUCCEED_PERFECT or CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_SUCCEED or CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_FAIL then
					return { CLIENT_REQUESTED_ACTION }
				end
			else
				return { CalcLiftAction(inst) }
			end
		end
	end

	return {}
end

local function actionbuttonoverride(inst, force_target)
	if inst ~= ThePlayer then
		if CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_SUCCEED_PERFECT or CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_SUCCEED or CLIENT_REQUESTED_ACTION == ACTIONS.LIFT_GYM_FAIL then
			return BufferedAction(inst, nil, CLIENT_REQUESTED_ACTION, nil, inst:GetPosition())
		end
	else
		return BufferedAction(inst, nil, CalcLiftAction(inst), nil, inst:GetPosition())
	end
end

local function OnGymCheck(inst, data)
    if data.ingym > 1 then
        if not inst.bell and not TheNet:IsDedicated() then
            inst.bell = SpawnPrefab("mighty_gym_bell")
            inst:AddChild(inst.bell)
            inst.AnimState:Hide("bell")
        end

        inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
        inst.components.playeractionpicker.rightclickoverride = RightClickPicker
        inst.components.playeractionpicker.pointspecialactionsfn = PointSpecialActions
        inst.components.playercontroller.actionbuttonoverride = actionbuttonoverride
		
    else
        inst:Stopbell()
        if inst.bell then
            inst.bell:Remove()
            inst.bell = nil  
            inst.AnimState:Show("bell")
        end

        inst.components.playeractionpicker.leftclickoverride = nil
        inst.components.playeractionpicker.rightclickoverride = nil
        inst.components.playeractionpicker.pointspecialactionsfn = nil
		inst.components.playercontroller.actionbuttonoverride = nil
    end
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("strongman")

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst._isavatar = net_bool(inst.GUID, "wolfgang._isavatar", "isavatardirty")

        if not TheWorld.ismastersim then
            inst:ListenForEvent("isavatardirty", lavaarena_onisavatardirty)
        end

        lavaarena_onisavatardirty(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_ovenmaster")
        inst:AddTag("quagmire_shopper")
    end


    inst.GetMightiness = GetMightiness
    inst.GetMightinessRateScale = GetMightinessRateScale
    inst.GetCurrentMightinessState = GetCurrentMightinessState
    

    inst.bell_percent = 0
    inst.bell_forward = true
    inst.bell_speed = 0.9 

    if not inst.components.updatelooper then
        inst:AddComponent("updatelooper")
    end
    inst.bell_SetPercent = bell_SetPercent
    inst.updatebell = updatebell
    inst.Startbell = Startbell
    inst.Stopbell = Stopbell
    inst.Pausebell = Pausebell
    inst.ResetBell = ResetBell

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("lift_gym", onliftgym)
    end

    inst:ListenForEvent("inmightygym", OnGymCheck)
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.strength = "normal"
    inst._wasnomorph = nil
    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil

    inst.customidleanim = "idle_wolfgang"

    inst.components.hunger:SetMax(TUNING.WOLFGANG_HUNGER)

    inst.components.foodaffinity:AddPrefabAffinity("potato_cooked", TUNING.AFFINITY_15_CALORIES_MED)

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst.OnIsAvatarDirty = lavaarena_onisavatardirty
        event_server_data("lavaarena", "prefabs/wolfgang").master_postinit(inst)
    else
        inst.components.health:SetMaxHealth(TUNING.WOLFGANG_HEALTH_NORMAL)

		inst.components.sanity:SetMax(TUNING.WOLFGANG_SANITY)
        inst.components.sanity.night_drain_mult = TUNING.WOLFGANG_SANITY_DRAIN
        inst.components.sanity.neg_aura_mult = TUNING.WOLFGANG_SANITY_DRAIN

        inst:AddComponent("mightiness")
        inst:AddComponent("dumbbelllifter")
        inst:AddComponent("strongman")
        inst:AddComponent("expertsailor")

        if inst.components.efficientuser == nil then
            inst:AddComponent("efficientuser")
        end

        inst:ListenForEvent("equip",   OnEquip)
        inst:ListenForEvent("unequip", OnUnequip)
        
        inst:ListenForEvent("working", OnDoingWork)
		inst:ListenForEvent("tilling", OnTilling)
		inst:ListenForEvent("rowing", OnRowing)
		inst:ListenForEvent("on_lower_sail_boost", OnSailBoost)
		inst:ListenForEvent("onterraform", OnTerraform)
	    inst:ListenForEvent("onhitother", OnHitOther)


        inst.OnLoad = onload
        inst.OnNewSpawn = onload
        
    end
end

return MakePlayerCharacter("wolfgang", prefabs, assets, common_postinit, master_postinit)