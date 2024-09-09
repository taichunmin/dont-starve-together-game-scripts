local brain = require("brains/ticoonbrain")

local assets =
{
	Asset("ANIM", "anim/ticoon_build.zip"),
	Asset("ANIM", "anim/catcoon_basic.zip"),
	Asset("ANIM", "anim/catcoon_actions.zip"),
	Asset("ANIM", "anim/catcoon_ticoon.zip"),
}

local prefabs = 
{
    'meat',
    'lucky_goldnugget',
    'coontail',
}

SetSharedLootTable('ticoon',
{
    {'meat',				0.50},
    {'coontail',			0.05},
})

local diet = { FOODGROUP.OMNI }

local TRACKING_LEADER_LEASH_DIST = 14

local function OnAttacked(inst, data)
	if data ~= nil and data.attacker ~= nil then
		if inst.components.follower.leader == data.attacker then
			inst.components.follower:StopFollowing()
			inst.components.questowner:AbandonQuest()
		end

		inst.components.combat:SetTarget(data.attacker)
	end
end

local function KeepTargetFn(inst, target)
   return target ~= nil
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
end

local function on_lost_leader(inst)
	if inst.persists then
		if inst.components.follower.cached_player_leader_userid == nil then
			inst.components.questowner:AbandonQuest()
		else
			if inst.lost_leader_removal ~= nil then
				inst.lost_leader_removal:Cancel()
			end

			inst.lost_leader_removal = inst:DoTaskInTime(120, function() 		-- allow enough time for the clients to reconnect
				if inst.components.follower.leader == nil then 
					inst.components.questowner:AbandonQuest()
				end
			end)
		end
	end
end

local function hidingspot_onremove(inst, hidingspot, data)
	-- if the ticoon has a leader, then then kitcoon was found before the ticoon arrived on the scene

	inst.status_str = "SUCCESS"

	local leader = inst.components.follower.leader
	if leader ~= nil then
		if (data == nil or data.finder ~= leader) then
			inst.status_str = "LOST_TRACK"

			if leader.components.talker ~= nil then
				leader.components.talker:Say(GetString(leader, "ANNOUNCE_TICOON_LOST_KITCOON"))
			end
		end
		inst.components.follower:StopFollowing()
	end

	inst.components.entitytracker:ForgetEntity("tracking") 

    inst:ClearBufferedAction()
	inst.components.locomotor:StopMoving()
	inst.persists = false
	inst:PushEvent("ticoon_kitcoonfound")
end

local function TrackNewKitcoonForPlayer(inst, player)
	if player == nil or player.components.leader == nil then
		return false
	end

	local hidingspots = {}
	TheWorld:PushEvent("ms_collecthiddenkitcoons", {hidingspots = hidingspots})

	player.components.leader:AddFollower(inst)

	if #hidingspots > 0 then
		inst.status_str = "TRACKING"

		local hidingspot = GetClosest(inst, hidingspots)

		inst.components.entitytracker:TrackEntity("tracking", hidingspot) 
		inst:ListenForEvent("onremove", inst.hidingspot_onremove, hidingspot)
		inst:ListenForEvent("onhidingspotremoved", inst.hidingspot_onremove, hidingspot)
		
		inst.sg:GoToState("searching", {msg = "ANNOUNCE_TICOON_START_TRACKING"})
	else
		inst.status_str = "NOTHING_TO_TRACK"
		inst.sg:GoToState("searching", {msg = "ANNOUNCE_TICOON_NOTHING_TO_TRACK"})
	end

	return true
end

local function quest_CanBeActivatedBy_Client(inst, doer)
	if not inst:HasTag("questcomplete") then
		return inst.replica.follower ~= nil and inst.replica.follower:GetLeader() == doer
	end
end

local function can_begin_quest(inst, doer)
	-- players cannot start the quest through an action, only when it is spawned
	return false
end

local function on_begin_quest(inst, player)
	return TrackNewKitcoonForPlayer(inst, player)
end

local function can_abandon_quest(inst, doer)
    return doer ~= nil and doer.components.leader ~= nil and inst.components.follower:GetLeader() == doer
end

local function on_abandon_quest(inst)
	inst.status_str = "ABANDONED"
	inst.persists = false

	local tracking_target = inst.components.entitytracker:GetEntity("tracking") 
	if tracking_target ~= nil then
		inst:RemoveEventCallback("onremove", inst.hidingspot_onremove, tracking_target)
		inst:RemoveEventCallback("onhidingspotremoved", inst.hidingspot_onremove, tracking_target)
		inst.components.entitytracker:ForgetEntity("tracking") 
	end

	local leader = inst.components.follower.leader
	if leader ~= nil then
		if leader.components.talker ~= nil then
			leader.components.talker:Say(GetString(leader, (inst.components.health ~= nil and inst.components.health:IsDead()) and "ANNOUNCE_TICOON_DEAD" or "ANNOUNCE_TICOON_ABANDONED"))
		end
		inst.components.follower:StopFollowing()
	end

    inst:ClearBufferedAction()

	inst:PushEvent("ticoon_abandoned")

    return true
end

local function on_complete_quest(inst)
	inst.status_str = "NEARBY"

	local leader = inst.components.follower.leader
	if leader ~= nil then
		if leader.components.talker ~= nil then
			leader.components.talker:Say(GetString(leader, "ANNOUNCE_TICOON_NEAR_KITCOON"))
		end
		inst.components.follower:StopFollowing()
	end

end

-------------------------------------------------------------------------------
local function IsLeaderSleeping(inst)
    return inst.components.follower.leader and inst.components.follower.leader:HasTag("sleeping")
end

local function ShouldWakeUp(inst)
    return StandardWakeChecks(inst) or not IsLeaderSleeping(inst) or not inst.components.follower:IsNearLeader(TRACKING_LEADER_LEASH_DIST)
end

local function ShouldSleep(inst)
    return StandardSleepChecks(inst) and IsLeaderSleeping(inst) and inst.components.follower:IsNearLeader(TRACKING_LEADER_LEASH_DIST)
end

-------------------------------------------------------------------------------

local function GetStatus(inst, viewer)
	return (inst.status_str == "TRACKING" and inst.components.follower.leader ~= viewer) and "TRACKING_NOT_MINE" or inst.status_str
end

local function OnEntitySleep(inst)
	if inst.persists == false then
		inst:Remove()
	end
end

local function OnSave(inst, data)
	data.status_str = inst.status_str
end

local function OnLoad(inst, data)
	if data ~= nil then
		inst.status_str = data.status_str
	end
end

local function OnLoadPostPass(inst, newents, data)
	local tracking_target = inst.components.entitytracker:GetEntity("tracking") 
	if tracking_target ~= nil then
		inst:ListenForEvent("onremove", inst.hidingspot_onremove, tracking_target)
		inst:ListenForEvent("onhidingspotremoved", inst.hidingspot_onremove, tracking_target)
	end

	if inst.components.follower.cached_player_leader_userid ~= nil then
		inst.lost_leader_removal = inst:DoTaskInTime(120, function() 											-- allow enough time for the clients to reconnect on a rollback
			inst.lost_leader_removal = nil
			if inst.components.follower.cached_player_leader_userid ~= nil then 
				inst.components.questowner:AbandonQuest()
			end
		end)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(2, 0.75)
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 1, 0.5)

	inst.AnimState:SetBank("catcoon")
	inst.AnimState:SetBuild("ticoon_build")
	inst.AnimState:PlayAnimation("idle_loop")

	inst:AddTag("smallcreature")
	inst:AddTag("companion")
	inst:AddTag("animal")
	inst:AddTag("ticoon")
    inst:AddTag("NOBLOCK")
	inst:AddTag("handfed")

	inst.Transform:SetScale(1.1, 1.1, 1.1)

	inst.CanBeActivatedBy_Client = quest_CanBeActivatedBy_Client

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.hidingspot_onremove = function(hider, data) hidingspot_onremove(inst, hider, data) end

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.TICOON_LIFE)

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.TICOON_DAMAGE)
	inst.components.combat:SetRange(TUNING.CATCOON_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.CATCOON_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/catcoon/hurt")
    inst:ListenForEvent("attacked", OnAttacked)

	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ticoon')

	inst:AddComponent("entitytracker")

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
	inst.components.follower.keepleaderduringminigame = true
	inst:ListenForEvent("stopleashing", on_lost_leader)

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.TICOON_SPEED

    inst:AddComponent("questowner")
    inst.components.questowner.CanBeginFn = can_begin_quest
    inst.components.questowner:SetOnBeginQuest(on_begin_quest)
    inst.components.questowner.CanAbandonFn = can_abandon_quest
    inst.components.questowner:SetOnAbandonQuest(on_abandon_quest)
    inst.components.questowner:SetOnCompleteQuest(on_complete_quest)
	
    inst:AddComponent("eater")
    inst.components.eater:SetDiet(diet, diet)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(5)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    -- boat hopping
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
	inst.components.embarker.embark_speed = TUNING.TICOON_EMBARK_SPEED
    inst:AddComponent("drownable")

	inst.OnEntitySleep = OnEntitySleep

	MakeSmallBurnableCharacter(inst, "catcoon_torso", Vector3(1,0,1))
	MakeSmallFreezableCharacter(inst)

	inst:SetBrain(brain)
	inst:SetStateGraph("SGticoon")

	MakeHauntablePanic(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass

	return inst
end


-------------------------------------------------------------------------------
local function builder_onbuilt(inst, builder)
    local pt = builder:GetPosition()
    local offset = FindWalkableOffset(pt, math.random() * TWOPI, 2, 6, true)
    if offset ~= nil then
        pt.x = pt.x + offset.x
        pt.z = pt.z + offset.z
    end

    local ticoon = SpawnPrefab("ticoon")
	ticoon.Transform:SetPosition(pt.x, pt.y, pt.z)

	ticoon.components.questowner:BeginQuest(builder)

    inst:Remove()
end

local function builder_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    inst.persists = false

    --Auto-remove if not spawned by builder
    inst:DoTaskInTime(0, inst.Remove)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnBuiltFn = builder_onbuilt

    return inst
end

return Prefab("ticoon", fn, assets, prefabs),
	Prefab("ticoon_builder", builder_fn, nil, {"ticoon"})
