require "prefabutil"
require("components/deployhelper")
local boatrace_common = require("prefabs/boatrace_common")
local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/boatrace_start.zip"),
    Asset("ANIM", "anim/boatrace_start_flag.zip"),
    Asset("MINIMAP_IMAGE", "boatrace_checkpoint"),

    Asset("ANIM", "anim/redpouch_yotd.zip"),

    Asset("SCRIPT", "scripts/prefabs/boatrace_common.lua"),
}

local prefabs =
{
    "boatrace_checkpoint_indicator",
    "boatrace_spectator_dragonling",
    "boatrace_start_bobber",
    "dragonboat_shadowboat",
    "redpouch_yotd",
    "boatrace_start_flag",
    "boatrace_fireworks",
}

local bobberassets =
{
    Asset("ANIM", "anim/boatrace_start_bobber.zip"),
}

local function LaunchProjectile(inst, targetpos, projectile)
    local x, y, z = inst.Transform:GetWorldPosition()

    projectile.Transform:SetPosition(x, y + 4, z)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x + (math.random()-0.5)*2
    local dz = targetpos.z - z + (math.random()-0.5)*2
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)

    local projectile_complexprojectile = projectile.components.complexprojectile
    projectile_complexprojectile:SetHorizontalSpeed(speed)
    projectile_complexprojectile:SetGravity(-25)
    projectile_complexprojectile:Launch(targetpos, inst, inst)
end

-- Workable
local function OnWorked(inst)
    if not inst.sg:HasStateTag("on") then
        inst.sg:GoToState("hit")
    end
end

local function OnWorkFinished(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

-- Building
local function automatic_checkpoint_swimmable_offset_test(test_position)
    return boatrace_common.CheckpointSpawnCheck(test_position)
end
local function do_automatic_checkpoint_spawn(inst)
    if inst._checkpoints_spawned then return end
    inst._checkpoints_spawned = true

    inst.sg:GoToState("checkpoint_throw")

    local random, sqrt = math.random, math.sqrt
    local min_radius, max_radius = TUNING.BOATRACE_AUTOMATIC_CHECKPOINT_MINRADIUS, TUNING.MAX_BOATRACE_COMPONENT_DISTANCE
    local radius_diff = (max_radius - min_radius)
    local checkpoint_count = TUNING.BOATRACE_AUTOMATIC_CHECKPOINT_COUNT
    local angle_chunk = TWOPI / checkpoint_count
    local third_angle = 0.33 * angle_chunk

    local ipos = inst:GetPosition()
    for i = 1, checkpoint_count do
        local position = nil
        for _ = 1, 3 do
            local angle = GetRandomWithVariance((i - 0.5) * angle_chunk, third_angle)
            local radius = min_radius + radius_diff * sqrt(random())
            local offset = FindSwimmableOffset(
                ipos, angle, radius,
                12, false, true,
                automatic_checkpoint_swimmable_offset_test, false
            )
            if offset then
                position = ipos + offset
                break
            end
        end

        if position then
            LaunchProjectile(inst, position, SpawnPrefab("boatrace_checkpoint_throwable_deploykit"))
        end
    end
end

local function OnBuilt(inst)
    inst.sg:GoToState("place")
    inst.components.timer:StartTimer("docheckpointsetup", 33*FRAMES)
end

--
local function getprizes(inst)
    local checkpoints = GetTableSize(inst._checkpoints)
    local prize_count_base = (TUNING.BOATRACE_AUTOMATIC_CHECKPOINT_COUNT + 1)
    if checkpoints < prize_count_base then
        return {"lucky_goldnugget"}
    elseif checkpoints < (3 * prize_count_base) then
        return {"lucky_goldnugget","lucky_goldnugget"}
    else
        return {"lucky_goldnugget","lucky_goldnugget","lucky_goldnugget"}
    end
end

local function reset_boatrace(inst)
    if inst.AnimState:IsCurrentAnimation("fuse_off")
            or inst.AnimState:IsCurrentAnimation("idle_on")
            or inst.AnimState:IsCurrentAnimation("win")
            or inst.AnimState:IsCurrentAnimation("prize") then
        inst.sg:GoToState("reset")
    elseif not inst.AnimState:IsCurrentAnimation("idle_off") then
        inst.sg:GoToState("idle_off")
    end

    inst.Light:Enable(false)
    inst.AnimState:SetLightOverride(0)

    if inst._beacons then
        local finish_data = {
            start = inst,
            winner = inst.race_places and inst.race_places[1].parent or nil,
        }
        for beacon in pairs(inst._beacons) do
            if beacon:IsValid() then
                beacon.parent.finished = nil
                beacon:PushEvent("boatrace_finish", finish_data)
                beacon.parent.yotd_beacon = nil
            end
        end
    end

    if inst._checkpoints then
        for checkpoint in pairs(inst._checkpoints) do
            checkpoint:PushEvent("boatrace_finish")
        end
    end

    inst.prizes = nil
    inst.race_places = nil
    inst.activator = nil
    inst._beacons = nil
    inst.fuse_off_frame = nil

    inst.indices = shuffleArray({1, 2, 3, 4, 5, 6, 7, 8})

    if inst.flags then
        for _, flag in ipairs(inst.flags)do
            flag.AnimState:PlayAnimation("flag_pst")
        end

        inst.flags = nil
    end

    TheWorld:PushEvent("unpausehounded", {source = inst})

    inst.components.activatable.inactive = true
end

local function testforwinpresentation(inst, beacon)
    if not inst.AnimState:IsCurrentAnimation("win") and not inst.AnimState:IsCurrentAnimation("prize") then
        local race_places_count = GetTableSize(inst.race_places)
        if #inst.flags < race_places_count and #inst.flags < 3 then
            if #inst.flags == 0 then
                inst:setflag(1,beacon._index)
            elseif #inst.flags == 1 then
                inst:setflag(2,beacon._index)
            elseif #inst.flags == 2 then
                inst:setflag(3,beacon._index)
            end
        end
    end
end

local function do_event_finish(inst)
    reset_boatrace(inst)
end

local function prizeOver(inst)

    if inst.components.activatable.inactive then
        inst.sg:GoToState("idle_off")
        return
    end

    inst.sg:GoToState("fuse_off",{fuse_off_frame=inst.fuse_off_frame})

    if GetTableSize(inst.race_places) > GetTableSize(inst.flags) then
        testforwinpresentation(inst,inst.race_places[GetTableSize(inst.flags)+1])
    end

    if not inst.AnimState:IsCurrentAnimation("win") and not inst.AnimState:IsCurrentAnimation("prize") then
        if GetTableSize(inst.race_places) >= math.min(GetTableSize(inst._beacons), 3) then
            do_event_finish(inst)
        end
    end
end


local function spawn_shadowboat(inst, eventstart_position)
    -- Try to find a spot to move the boat into
    local offset_radius = (0.4 + 0.4*math.random())* TUNING.BOATRACE_START_INCLUSION_PROXIMITY
    local valid_offset = FindSwimmableOffset(
        eventstart_position,
        TWOPI*math.random(),
        offset_radius,
        12, nil, nil, boatrace_common.BoatSpawnCheck, false
    )
    if not valid_offset then return end

    local shadow_boat = SpawnPrefab("dragonboat_shadowboat")
    shadow_boat.Transform:SetPosition((eventstart_position + valid_offset):Get())

    shadow_boat:AddTag("AIboat")

    return shadow_boat
end

local function beaconremoved(inst, beacon)
    if inst._beacons and inst._beacons[beacon] then
        if not beacon.finished then
            inst._beacons[beacon] = nil
            if GetTableSize(inst.race_places) >= math.min(GetTableSize(inst._beacons), 3) then
                inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fail")
                do_event_finish(inst)
            end
        end
    end
end

local BOATRACE_FLAG = {"boat", "walkableplatform"}
local function updateloop(inst)
    if inst._beacons then
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local boatrace_inclusion_proximity_sq = TUNING.BOATRACE_START_INCLUSION_PROXIMITY * TUNING.BOATRACE_START_INCLUSION_PROXIMITY
        for beacon in pairs(inst._beacons) do
            -- First, check if the beacon is outside of the start point's radius.
            local bx, by, bz = beacon.Transform:GetWorldPosition()
            local remove_beacon = (distsq(ix, iz, bx, bz) > boatrace_inclusion_proximity_sq)
            if not remove_beacon then
                -- If we didn't remove the beacon for being too far away,
                -- we also need to check if there's still a player on it.
                local beacon_boat = beacon.parent
                if beacon_boat and beacon_boat.components.walkableplatform then
                    if (next(beacon_boat.components.walkableplatform:GetPlayersOnPlatform()) == nil) then
                        remove_beacon = true
                    end
                end
            end

            if remove_beacon then
                table.insert(inst.indices, beacon.index)
                beacon:PushEvent("boatrace_idle_disappear")
                beacon.parent.yotd_beacon = nil
                inst._beacons[beacon] = nil
            end
        end

        if GetTableSize(inst._beacons) == 0 then
            inst._beacons = nil
        end
    end

    -- Gather valid beacons
    local eventstart_x, eventstart_y, eventstart_z = inst.Transform:GetWorldPosition()
    local nearby_boats = TheSim:FindEntities(
        eventstart_x,
        eventstart_y,
        eventstart_z,
        TUNING.BOATRACE_START_INCLUSION_PROXIMITY,
        BOATRACE_FLAG
    )

    local valid_boatrace_boats = nil
    local has_boats = false
    -- First, remove any boats that don't have a player on them (AI boats get added later)
    if #nearby_boats > 0 then
        for _, boat in pairs(nearby_boats) do
            -- "walkableplatform" is in our flag test, so our results should all have that component.
            if next(boat.components.walkableplatform:GetPlayersOnPlatform()) ~= nil then
                valid_boatrace_boats = valid_boatrace_boats or {}
                valid_boatrace_boats[boat] = true
                has_boats = true
            end
        end
    end

    -- If we still have a valid boat to play with, continue!
    if has_boats then
        if not inst._beacons then
            inst._beacons = {}
        end

        for boat in pairs(valid_boatrace_boats) do
            if not boat.yotd_beacon then
                local beacon = SpawnPrefab("boatrace_checkpoint_indicator")
                boat:AddChild(beacon)
                inst._beacons[beacon] = {}
                boat.yotd_beacon = true

                local index = table.remove(inst.indices, 1)

                beacon:ListenForEvent("onremove", function() beaconremoved(inst,beacon) end)

                beacon:PushEvent("boatrace_setindex", index)
            end
        end
    end
end

local function shadow_boat_Remove(boat)
    local fx = SpawnPrefab("shadow_puff_large_front")
    fx.Transform:SetScale(3,3,3)
    fx.Transform:SetPosition(boat.Transform:GetWorldPosition())
    local ents = boat.components.walkableplatform:GetEntitiesOnPlatform()
    for ent in pairs(ents)do
        if ent:HasTag("monkey") and ent:HasTag("racer") then
            ent:Remove()
        end
    end

    local pt = boat:GetPosition()

    boat:Remove()
    SpawnAttackWaves(pt, nil, 1, 6, nil, 3, nil, 1, true)
end

local function gathercheckpoints(inst)
    local openlist = {}
    local manager = TheWorld.components.yotd_raceprizemanager
    if manager then
        openlist = manager:GetCheckpoints()
    end

    local closedlist = {}

    while true do
        local inrange = false
        -- if nothing in open list is in range of anything in the closed list.. done.
        for chkpt in pairs(openlist) do
            --print("CHKPT",chkpt.GUID)
            local move = false
            -- test the start
            --print("DIST START",inst.GUID,chkpt:GetDistanceSqToInst(inst),TUNING.MAX_BOATRACE_COMPONENT_DISTANCE*TUNING.MAX_BOATRACE_COMPONENT_DISTANCE)
            if chkpt:GetDistanceSqToInst(inst) <= TUNING.MAX_BOATRACE_COMPONENT_DISTANCE*TUNING.MAX_BOATRACE_COMPONENT_DISTANCE then
                --print("IN RANGE OF START")
                inrange = true
                move = true
            end

            -- test the other chkpts
            if not move then
                for t_chkpt in pairs(closedlist) do
                    --print("DIST POST",t_chkpt.GUID,chkpt:GetDistanceSqToInst(inst),TUNING.MAX_BOATRACE_COMPONENT_DISTANCE*TUNING.MAX_BOATRACE_COMPONENT_DISTANCE)
                    if chkpt:GetDistanceSqToInst(t_chkpt) <= TUNING.MAX_BOATRACE_COMPONENT_DISTANCE*TUNING.MAX_BOATRACE_COMPONENT_DISTANCE then
                        --print("IN RANGE OF POST", t_chkpt.GUID)
                        inrange = true
                        move = true
                    end
                end
            end

            if move == true then
                closedlist[chkpt] = 0
                openlist[chkpt] = nil
            end
        end

        if not inrange then
            break
        end
    end

    return closedlist
end

local function do_event_start(inst)
    local beacon_count = GetTableSize(inst._beacons)

    if beacon_count > 0 then
        local eventstart_position = inst:GetPosition()
        inst.Light:Enable(true)
        inst.AnimState:SetLightOverride(0.8)

        if beacon_count < TUNING.BOATRACE_MIN_COUNT_FOR_SHADOWBOAT then
            local shadow_boat = spawn_shadowboat(inst, eventstart_position)

            if shadow_boat then
                local beacon = SpawnPrefab("boatrace_checkpoint_indicator")
                beacon:ListenForEvent("onremove", function() beaconremoved(inst,beacon) end)
                shadow_boat:AddChild(beacon)
                beacon.Transform:SetPosition(0,0,0)
                shadow_boat:ListenForEvent("boatrace_finish", function(b, data)
                    if b == data.winner then
                        local entities_on_shadow_boat = shadow_boat.components.walkableplatform:GetEntitiesOnPlatform()
                        for entity in pairs(entities_on_shadow_boat) do
                            entity:PushEvent("cheer")
                        end
                    end

                    local rand = 3*math.random()
                    shadow_boat:DoTaskInTime(3 + rand, shadow_boat_Remove)

                end, beacon)

                inst._beacons[beacon] = {}

                local index = table.remove(inst.indices, 1)

                beacon:PushEvent("boatrace_setindex", index)
            else
                inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fail")
                if inst.activator.components.talker then
                    inst.activator.components.talker:Say(GetString(inst.activator, "ANNOUNCE_YOTD_NOTENOUGHBOATS"))
                end
                reset_boatrace(inst)
                return
            end
        end

        local spectator, bx, by, bz, beacon_normal_x, beacon_normal_z
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        for beacon in pairs(inst._beacons) do
            beacon:PushEvent("boatrace_start", inst)

            bx, by, bz = beacon.Transform:GetWorldPosition()

            spectator = SpawnPrefab("boatrace_spectator_dragonling")
            beacon_normal_x, beacon_normal_z = VecUtil_NormalizeNoNaN(bx - ix, bz - iz)
            spectator.Transform:SetPosition(ix + beacon_normal_x, 15, iz + beacon_normal_z)
            spectator:PushEvent("new_boatrace_indicator", beacon)

            -- Clear our startup tracking variable, if it exists.
            if beacon.parent then
                beacon.parent.yotd_beacon = nil
            end
        end

        for checkpoint in pairs(inst._checkpoints) do
            checkpoint:PushEvent("boatrace_starttimerended")
        end

        inst.sg:GoToState("on")

        inst.components.boatrace_proximitychecker:OnStartRace()
    else
        inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fail")
        if inst.activator.components.talker then
            inst.activator.components.talker:Say(GetString(inst.activator, "ANNOUNCE_YOTD_NOBOATS"))
        end
        reset_boatrace(inst)
    end
end

local function GetCheckpoints(inst)
    return shallowcopy(inst._checkpoints)
end

local function GetBeacons(inst)
    return shallowcopy(inst._beacons)
end

-- Race activation
local function fuseonOver(inst)
    inst.components.updatelooper:RemoveOnUpdateFn(updateloop)
    do_event_start(inst)
end

local function fuseoffOver(inst)
    inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fail")
    do_event_finish(inst)
end

local function OnActivated(inst, doer)
    inst.activator = doer

    inst._checkpoints = gathercheckpoints(inst)
    inst.prizes = {}
    inst.flags = {}

    if TheWorld.components.yotd_raceprizemanager and TheWorld.components.yotd_raceprizemanager:HasPrizeAvailable() then
        table.insert(inst.prizes,{total=3})
        table.insert(inst.prizes,{total=2})
        table.insert(inst.prizes,{total=1})
    end

    if GetTableSize(inst._checkpoints) <= 0 then
        if inst.activator.components.talker then
            inst.activator.components.talker:Say(GetString(inst.activator, "ANNOUNCE_YOTD_NOCHECKPOINTS"))
        end
        reset_boatrace(inst)

        -- RESET FOR ACTIVATION
        inst.components.activatable.inactive = true

        return
    end

    for checkpoint in pairs(inst._checkpoints) do
        checkpoint:SetStartPoint(inst)
        checkpoint:PushEventInTime(1 + math.random(), "boatrace_start")
    end

    TheWorld:PushEvent("pausehounded", {source = inst})

    inst.sg:GoToState("fuse_on")

    inst.components.updatelooper:AddOnUpdateFn(updateloop)
end


local function OnCheckpointReached(inst, data)
    local beacon = data.beacon
    local checkpoint = data.checkpoint

    -- If this was one of our checkpoints, record that this beacon touched the checkpoint.
    if inst._checkpoints[checkpoint] and inst._beacons then
        inst._beacons[beacon][checkpoint] = true
    end
end


local function testforendofrace(inst)
    if GetTableSize(inst.race_places) >= math.min(GetTableSize(inst._beacons), 3) then
        do_event_finish(inst)
    end
end

local function on_ai_prize_hit(pouch, attacker, target)
    local fx = SpawnPrefab("redpouch_yotd_unwrap")
    fx.Transform:SetPosition(pouch.Transform:GetWorldPosition())
    pouch:Remove()
end

local function do_spawn_prize_pouch(inst, prize_list, pt, target_is_ai)
    local pouch = SpawnPrefab("redpouch_yotd")

    pouch.components.unwrappable:WrapItems(prize_list)

    local pouch_complexprojectile = pouch:AddComponent("complexprojectile")
    pouch_complexprojectile:SetHorizontalSpeed(15)
    pouch_complexprojectile:SetGravity(-25)
    pouch_complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))

    if target_is_ai then
        pouch_complexprojectile:SetOnHit(on_ai_prize_hit)
    end

    LaunchProjectile(inst, pt, pouch)
end

local function winOver(inst)
    if inst.winid then
        local fireworks = SpawnPrefab("boatrace_fireworks")
        inst.SoundEmitter:PlaySound("yotd2024/startingpillar/launch_fireworks")
        fireworks.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fireworks.AnimState:OverrideSymbol("fx_spark_parts_00", "boatrace_start", "fx_spark_parts_0"..inst.winid)
    end

    local prize = nil
    for i,p in ipairs(inst.prizes)do
        if not p.awarded then
            prize = i
            break
        end
    end

    if inst.prizes[prize] then
        inst.prizes[prize].awarded = true
        local target = inst.prizes[prize].target
        for _=1,inst.prizes[prize].total do
            local prize_list = getprizes(inst)

            local pt
            if type(target) == "string" then
                local theta = math.random()*TWOPI
                local radius = 6
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                pt = inst:GetPosition() + offset
            else
                pt = target:GetPosition()
            end

            local target_is_ai = (type(target) == "table" and target:HasTag("AIboat"))

            inst:DoTaskInTime(
                0.2 * math.random(),
                do_spawn_prize_pouch,
                prize_list,
                pt,
                target_is_ai
            )
        end

        if TheWorld.components.yotd_raceprizemanager then
            TheWorld.components.yotd_raceprizemanager:PrizeGiven()
        end

        inst.sg:GoToState("prize")
    else
        inst.sg:GoToState("fuse_off",{fuse_off_frame=inst.fuse_off_frame})
        testforendofrace(inst)
    end
end

local function Flag_AnimOverBehaviour(inst)
    if inst.AnimState:IsCurrentAnimation("flag_pst") then
        inst:Remove()
    end
end


local function setflag(inst, position, id)

    local flag = SpawnPrefab("boatrace_start_flag")
    flag.AnimState:OverrideSymbol("swapflag_1", "boatrace_start_flag", "swapflag_"..id)
    flag.AnimState:PlayAnimation("flag_pre",false)
    flag.AnimState:PushAnimation("flag_idle",true)
    flag.entity:SetParent(inst.entity)
    flag.Follower:FollowSymbol(inst.GUID, "flag"..position, nil, nil, nil, true)
    flag.components.highlightchild:SetOwner(inst)

    table.insert(inst.flags, flag)

    if inst.AnimState:IsCurrentAnimation("fuse_off") then
        inst.fuse_off_frame = inst.AnimState:GetCurrentAnimationFrame()
    end

    inst.AnimState:OverrideSymbol("fx_spark_parts_00", "boatrace_start", "fx_spark_parts_0"..id)

    inst.winid = id

    inst.sg:GoToState("win")    
end

local function do_set_placing(inst, beacon)
    if not beacon.finished then
        beacon.finished = true
        beacon.parent.finished = true
        if not inst.race_places then inst.race_places = {} end

        table.insert(inst.race_places,beacon)

        if #inst.race_places <= #inst.prizes and inst.prizes[#inst.race_places] then
            inst.prizes[#inst.race_places].target = beacon.parent
        end

        testforwinpresentation(inst, beacon)
    end
end

local function OnBeaconAtStartpoint(inst, beacon)
    if not beacon or
            inst.components.activatable.inactive or
            not inst._beacons or not inst._beacons[beacon] or
            not inst._checkpoints then
        return
    end

    local beacon_visited_size = GetTableSize(inst._beacons[beacon])
    if beacon_visited_size > 0 and beacon_visited_size == GetTableSize(inst._checkpoints) then
        do_set_placing(inst, beacon)
    end
end

local function OnTimerDone(inst, data)
    if not data then return end

    if data.name == "docheckpointsetup" then
        do_automatic_checkpoint_spawn(inst)
    end
end

local function OnLootPrefabSpawned(inst, data)
    if data and data.loot then
        data.loot._checkpoints_spawned = inst._checkpoints_spawned
    end
end

local function setWorkable(inst)
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnWorkCallback(OnWorked)
    workable:SetOnFinishCallback(OnWorkFinished)
end

-- Save/Load
local function OnSave(inst, data)
    if inst._checkpoints_spawned then
        data.checkpoints_spawned = true
    end

    local refs = nil
    if inst._checkpoints then
        refs = {}
        data.checkpoints = {}
        for checkpoint in pairs(inst._checkpoints) do
            table.insert(data.checkpoints, checkpoint.GUID)
            table.insert(refs, checkpoint.GUID)
        end
    end

    return refs
end

local function OnLoad(inst, data)
    if data then
        inst._checkpoints_spawned = data.checkpoints_spawned or inst._checkpoints_spawned
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data and data.checkpoints then
        inst._checkpoints = inst._checkpoints or {}
        for _, checkpoint_GUID in ipairs(data.checkpoints) do
            local checkpoint = newents[checkpoint_GUID]
            if checkpoint then
                inst._checkpoints[checkpoint.entity] = 0
                inst:ListenForEvent("onremove", function()
                    inst._checkpoints[checkpoint.entity] = nil
                end, checkpoint.entity)
            end
        end
    end
end

-- Client-side methods
local function CLIENT_CreateClientBobber(parent, do_deploy)
    local inst = CreateEntity("boatrace_start_bobber")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    parent:AddChild(inst)

    inst:AddTag("CLASSIFIED")
    inst:AddTag("DECOR")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("boatrace_start_bobber")
    inst.AnimState:SetBuild("boatrace_start_bobber")
    inst.AnimState:SetLayer(LAYER_WORLD)
    inst.AnimState:SetFinalOffset(-1)

    if do_deploy then
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("idle_loop")

        inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    else
        inst.AnimState:PlayAnimation("idle_place")
    end

    return inst
end

local function CLIENT_DeployBobber(parent, do_deploy, radius, angle)
    local bobber = CLIENT_CreateClientBobber(parent, do_deploy)
    bobber.Transform:SetPosition(radius * math.cos(angle), 0, radius * math.sin(angle))
    parent._bobbers[bobber] = true
    parent:ListenForEvent("onremove", function(b) parent._bobbers[b] = nil end, bobber)
end

local function SERVER_DeployBobber(parent, do_deploy, radius, angle)
    local bobber = SpawnPrefab("boatrace_start_bobber")
    parent:AddChild(bobber)
    bobber.Transform:SetPosition(radius * math.cos(angle), 0, radius * math.sin(angle))
    parent._bobbers[bobber] = true
    parent:ListenForEvent("onremove", function(b) parent._bobbers[b] = nil end, bobber)
end

local NUM_BOBBERS_IN_START_RING = 10
local ANGLE_PER_BOBBER = TWOPI / NUM_BOBBERS_IN_START_RING
local function CreateBobberRing(parent, deploy_fn, do_deploy)
    local radius = TUNING.BOATRACE_START_INCLUSION_PROXIMITY
    local random = math.random

    parent._bobbers = parent._bobbers or {}
    for i = 1, NUM_BOBBERS_IN_START_RING do
        local angle = i * ANGLE_PER_BOBBER
        if do_deploy then
            parent:DoTaskInTime(0.5 * random(), deploy_fn, do_deploy, radius, angle)
        else
            deploy_fn(parent, do_deploy, radius, angle)
        end
    end
end

local function CLIENT_OnInit(inst)
    boatrace_common.RegisterBoatraceStart(inst)

    if TheWorld.ismastersim then
        CreateBobberRing(inst, SERVER_DeployBobber, true)
    end
end

local DEPLOYHELPER_KEYFILTERS = {"boatrace_checkpoint"}
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.MiniMapEntity:SetIcon("boatrace_start.png")

    MakeWaterObstaclePhysics(inst, 0.4, 2, 0.75)
    inst:SetPhysicsRadiusOverride(1.75) -- To increase activation range

    inst.Physics:SetDontRemoveOnSleep(true)

    inst.AnimState:SetBank("boatrace_start")
    inst.AnimState:SetBuild("boatrace_start")
    inst.AnimState:PlayAnimation("idle_off", true)

    inst:AddTag("boatracecheckpoint")
    inst:AddTag("boatrace_proximitychecker")
    inst:AddTag("structure")

    inst.AnimState:Hide("PRIZE")
    inst.AnimState:SetLightOverride(0)

    inst.Light:SetFalloff(0.3)
    inst.Light:SetIntensity(0.85)
    inst.Light:SetRadius(5)
    inst.Light:SetColour( 180/255, 195/255, 150/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    boatrace_common.AddDeployHelper(inst, DEPLOYHELPER_KEYFILTERS)

    inst:DoTaskInTime(0, CLIENT_OnInit)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGboatrace_start")

    inst.GetCheckpoints = GetCheckpoints
    inst.GetBeacons = GetBeacons

    inst.indices = shuffleArray({1, 2, 3, 4, 5, 6, 7, 8})
    --inst._checkpoints_spawned = nil

    --
    local activatable = inst:AddComponent("activatable")
    activatable.OnActivate = OnActivated

    --
    local boatrace_proximitychecker = inst:AddComponent("boatrace_proximitychecker")
    boatrace_proximitychecker.on_found_beacon = OnBeaconAtStartpoint

    --
    inst:AddComponent("inspectable")


    inst:AddComponent("talker")

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetLoot({"boatrace_start_throwable_deploykit"})

    --
    inst:AddComponent("timer")

    --
    inst:AddComponent("updatelooper")

    --
    setWorkable(inst)

    --
    MakeHauntableWork(inst)

    --
    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("beacon_reached_checkpoint", OnCheckpointReached)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("loot_prefab_spawned", OnLootPrefabSpawned)

    --inst:ListenForEvent("animover", AnimOverBehaviour)

    local updateprize = function(world)
        if world.components.yotd_raceprizemanager then
            if world.components.yotd_raceprizemanager:HasPrizeAvailable() then
                inst.AnimState:Show("PRIZE")
            else
                inst.AnimState:Hide("PRIZE")
            end
        end
    end
    inst:ListenForEvent("yotd_ratraceprizechange", updateprize, TheWorld)

    updateprize(TheWorld)

    --
    inst.fuseonOver = fuseonOver
    inst.fuseoffOver = fuseoffOver
    inst.winOver = winOver
    inst.prizeOver = prizeOver

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.setWorkable = setWorkable
    inst.testforwinpresentation = testforwinpresentation
    inst.setflag = setflag

    return inst
end

-- Server-side bobber
local function bobberfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("dockjammer")
    inst:AddTag("NOCLICK")

    inst:SetPhysicsRadiusOverride(0.5)

    inst.AnimState:SetBank("boatrace_start_bobber")
    inst.AnimState:SetBuild("boatrace_start_bobber")
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_loop")
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

--
-- NOTE: the boatrace_start prefab has this tag as well, so we DO pick up other start points too.
local CHECKPOINT_MUST_TAGS = {"boatracecheckpoint"}
local function CLIENT_IsNearCheckpoint(ix, iy, iz)
    return #(TheSim:FindEntities(ix, iy, iz, TUNING.BOATRACE_START_INCLUSION_PROXIMITY, CHECKPOINT_MUST_TAGS)) > 0
end

local function on_deploy_product(deploy_product, inst)
    deploy_product._checkpoints_spawned = inst._checkpoints_spawned
end

local function CLIENT_UpdateReticuleStartRing(inst)
    local bobbers = inst._bobbers
    if not bobbers or not next(bobbers) then
        return
    end

    local Map = TheWorld.Map
    local bobber_x, bobber_y, bobber_z
    for bobber in pairs(bobbers) do
        bobber_x, bobber_y, bobber_z = bobber.Transform:GetWorldPosition()
        if not Map:IsOceanAtPoint(bobber_x, bobber_y, bobber_z, true) then
            return false
        end
    end

    return true
end

local function kit_onsave(inst, data)
    data.checkpoints_spawned = inst._checkpoints_spawned
end
local function kit_onload(inst, data)
    inst._checkpoints_spawned = (data and data.checkpoints_spawned) or inst._checkpoints_spawned
end

local THROWABLE_KIT_DATA = {
    bank = "boatrace_start",
    anim = "kit_ground",
    prefab_to_deploy = "boatrace_start",

    product_fn = on_deploy_product,
    deployfailed_fn = on_deploy_product,

	extradeploytest = function(inst, thrower, pos)
        local radius = TUNING.BOATRACE_START_INCLUSION_PROXIMITY
        local Map = TheWorld.Map
        local angle, tx, tz
        for i = 1, NUM_BOBBERS_IN_START_RING do
            angle = i * ANGLE_PER_BOBBER
            tx, tz = radius * math.cos(angle), radius * math.sin(angle)

			if not Map:IsOceanAtPoint(pos.x + tx, 0, pos.z + tz, true) then
                return false
            end
        end
		return not CLIENT_IsNearCheckpoint(pos:Get())
    end,

    primary_postinit = function(inst)
        inst.OnSave = kit_onsave
        inst.OnLoad = kit_onload
    end,

    placer_postinit = function(placer_inst)
        placer_inst:DoTaskInTime(0, CreateBobberRing, CLIENT_DeployBobber, false)
    end,
}
local ThrowableKit, ThrowableKitPlacer = boatrace_common.MakeThrowableBoatRaceKitPrefabs(THROWABLE_KIT_DATA)

local function flagfn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("boatrace_start")
    inst.AnimState:SetBuild("boatrace_start")
    inst.AnimState:PlayAnimation("flag_idle", true)

    inst:AddComponent("highlightchild")

    inst:ListenForEvent("animover", Flag_AnimOverBehaviour)

    inst.persists = false

    return inst
end

local function fireworksfn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("boatrace_start")
    inst.AnimState:SetBuild("boatrace_start")
    inst.AnimState:PlayAnimation("fireworks")

    inst:AddComponent("highlightchild")

    inst:ListenForEvent("animover", function() inst:Remove() end)

    inst.persists = false

    return inst
end

return Prefab("boatrace_start", fn, assets, prefabs),
    ThrowableKit,
    ThrowableKitPlacer,
    Prefab("boatrace_start_bobber", bobberfn, bobberassets),
    Prefab("boatrace_start_flag", flagfn, assets),
    Prefab("boatrace_fireworks", fireworksfn, assets)