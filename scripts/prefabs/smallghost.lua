local assets =
{
    Asset("ANIM", "anim/ghost_kid.zip"),
    Asset("ANIM", "anim/ghost_build.zip"),
    Asset("SOUND", "sound/ghost.fsb"),
}

local hotcold_fx_assets =
{
    Asset("ANIM", "anim/trinket_echoes_fx.zip"),
}

local prefabs =
{
    "ghostflower",
    "hotcold_fx",
}

local toy_types =
{
    "lost_toy_1",
    "lost_toy_2",
    "lost_toy_7",
    "lost_toy_10",
    "lost_toy_11",
    "lost_toy_14",
    "lost_toy_18",
    "lost_toy_19",
    "lost_toy_42",
    "lost_toy_43",
}
for _, v in ipairs(toy_types) do
    table.insert(prefabs, v)
end

local brain = require "brains/smallghostbrain"

local function can_talk_to_client(inst, doer)
    return doer ~= nil and doer:HasTag("ghostlyfriend")
end

local function AbleToAcceptTest(inst, item)
    return false, item.prefab == "reviver" and "GHOSTHEART" or nil
end

local MIN_FX_SIZE = 0.20
local MAX_FX_SIZE = 0.90
local MAX_HUNT_HOT_DSQ = TUNING.GHOST_HUNT.MINIMUM_HINT_DIST * TUNING.GHOST_HUNT.MINIMUM_HINT_DIST
local function hot_cold_update(inst)
    if inst._toys ~= nil and next(inst._toys) ~= nil then
        if inst._hotcold_fx == nil then
            inst._hotcold_fx = SpawnPrefab("hotcold_fx")
            inst._hotcold_fx.entity:SetParent(inst.entity)
            inst._hotcold_fx.entity:AddFollower():FollowSymbol(inst.GUID, "smallghost_hair", 0, 0.2, 0)
        end

        local leader = inst.components.follower:GetLeader()

        local closest_toy_dsq = MAX_HUNT_HOT_DSQ + 1
        for toy, _ in pairs(inst._toys) do
            closest_toy_dsq = math.min(closest_toy_dsq, (leader or inst):GetDistanceSqToInst(toy))
        end

        local percent = MIN_FX_SIZE

        if closest_toy_dsq < MAX_HUNT_HOT_DSQ then
            percent = math.clamp(1 - math.sqrt(closest_toy_dsq / MAX_HUNT_HOT_DSQ), MIN_FX_SIZE, MAX_FX_SIZE)
        else
            percent = 0
        end

        inst._hotcold_fx.AnimState:SetScale(percent, percent)
    end
end

local function unlink_from_player(inst)
    if inst._playerlink ~= nil then
        if inst._playerlink.components.leader ~= nil then
            inst._playerlink.components.leader:RemoveFollower(inst)
        end
        inst._playerlink:RemoveEventCallback("onremove", unlink_from_player, inst)
        inst._playerlink:RemoveEventCallback("onremove", inst._on_leader_removed)

        inst:RemoveEventCallback("death", inst._on_leader_death, inst._playerlink)

        inst._playerlink.questghost = nil
        inst._playerlink = nil
    end
end

local function check_for_quest_finished(inst)
    -- The toys array was initialized (i.e. a quest was started),
    -- but all of the actual targets have been removed from the list.
    -- So, our quest is over.
    if inst._toys == nil or next(inst._toys) ~= nil then
        return false
    end

    if inst._hotcold_task ~= nil then
        inst._hotcold_task:Cancel()
        inst._hotcold_task = nil
    end

    if inst._hotcold_fx ~= nil then
        inst._hotcold_fx:Remove()
    end

    unlink_from_player(inst)

    if inst._cancelled then
        inst.sg:GoToState("quest_abandoned")
    else
        inst.sg:GoToState("quest_finished")
    end

    return true
end

local function link_to_player(inst, player)
    inst.persists = false
    inst.components.knownlocations:ForgetLocation("home")
    if inst.UnlinkFromGravestone ~= nil then
        inst.UnlinkFromGravestone()
    end

    inst:RemoveComponent("playerprox")

    inst._playerlink = player

    player.questghost = inst
    player.components.leader:AddFollower(inst)
    player:ListenForEvent("onremove", unlink_from_player, inst)
    player:ListenForEvent("onremove", inst._on_leader_removed)

    inst:ListenForEvent("death", inst._on_leader_death, player)
end

local function link_to_home(inst, home)
    inst.UnlinkFromGravestone = function()
		if home:IsValid() then
			home:RemoveEventCallback("onremove", inst.UnlinkFromGravestone, inst)
			home.ghost = nil
		end
        inst.UnlinkFromGravestone = nil
    end

    home:ListenForEvent("onremove", inst.UnlinkFromGravestone, inst)

    if not inst.components.playerprox:IsPlayerClose() then
        inst:RemoveFromScene()
    end

    inst.components.knownlocations:RememberLocation("home", inst:GetPosition(), true)
end

local function can_begin_quest(inst, doer)
    return doer ~= nil and doer.components.leader ~= nil and inst.components.follower:GetLeader() == nil
end

local function on_begin_quest(inst, doer)
    if doer.questghost ~= nil and doer.questghost ~= inst then
        return false, "ONEGHOST"
    end

    -- Spawn toys if we didn't have any already.
    if inst._toys == nil then
        inst._toys = {}

        local ghost_position = inst:GetPosition()

        local toy_center_offset = FindWalkableOffset(ghost_position, math.random()*TWOPI, TUNING.GHOST_HUNT.TOY_DIST.BASE, nil, false)
        if toy_center_offset then
            ghost_position = ghost_position + toy_center_offset
        end

        local toy_count = GetRandomMinMax(TUNING.GHOST_HUNT.TOY_COUNT.MIN, TUNING.GHOST_HUNT.TOY_COUNT.MAX)
        local angle_increment = TWOPI / toy_count

        local initial_angle = math.random() * TWOPI

        -- Do a shuffle instead of random selection so that we don't get duplicates.
        local chosen_toys = shuffleArray(toy_types)

        for i = 1, toy_count do
            local toy = SpawnPrefab(chosen_toys[i])

            local toyangle = initial_angle + (i - 1) * angle_increment

            local offset = FindWalkableOffset(
                ghost_position,
                toyangle,
                GetRandomWithVariance(TUNING.GHOST_HUNT.TOY_DIST.RADIUS, TUNING.GHOST_HUNT.TOY_DIST.VARIANCE),
                nil,
                false
            )
            if offset == nil then
                toy.Transform:SetPosition(ghost_position:Get())
            else
                toy.Transform:SetPosition((ghost_position + offset):Get())
            end

            inst._toys[toy] = true

            inst:ListenForEvent("onremove", function(t)
                if inst._toys ~= nil and next(inst._toys) ~= nil and inst._toys[t] ~= nil then
                    inst._toys[t] = nil
                end
                check_for_quest_finished(inst)
            end, toy)
        end
    end

    if doer.components.talker ~= nil then
        doer.components.talker:Say(GetString(doer, "ANNOUNCE_GHOST_QUEST"))
    end

    inst:LinkToPlayer(doer)
    inst._hotcold_task = inst:DoPeriodicTask(0.25, hot_cold_update)

    inst.sg:GoToState("quest_begin")

    return true
end

local function can_abandon_quest(inst, doer)
    return doer ~= nil and doer.components.leader ~= nil and inst.components.follower:GetLeader() == doer
end

local function on_abandon_quest(inst, doer)
    unlink_from_player(inst)
    inst:ClearBufferedAction()
    inst.sg.mem.is_hinting = false
    inst.sg:GoToState("quest_abandoned")
    return true
end

local function on_player_near_fn(inst, player)
    if inst:IsInLimbo() then
        inst:ReturnToScene()

        local home_position = inst.components.knownlocations:GetLocation("home")
        if home_position ~= nil then
            inst.Transform:SetPosition(home_position.x + 0.3, home_position.y, home_position.z + 0.3)
        else
            inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
        end

        inst:DoTaskInTime(0, function(i) i.sg:GoToState("appear") end)
    end
end

local function on_smallghost_removed(inst)
    if inst._toys ~= nil and next(inst._toys) ~= nil then
        inst._cancelled = true
        for t, _ in pairs(inst._toys) do
            ErodeAway(t)
        end
    end
end

local function on_player_far_fn(inst)
    -- If we have a leader, we have to follow them! Don't limbo out!
    if inst.components.follower:GetLeader() == nil then
        inst.sg:GoToState("disappear", function(ghost)
            ghost:DoTaskInTime(0, inst.RemoveFromScene)
        end)
    end
end

local function spawn_ghostflower(tx, ty, tz, angle)
    local ghostflower = SpawnPrefab("ghostflower")
    if angle ~= nil then
        ghostflower.Transform:SetPosition(tx + math.cos(angle), ty, tz - math.sin(angle))
    else
        ghostflower.Transform:SetPosition(tx, ty, tz)
    end
    ghostflower:DelayedGrow()
end

local function pickup_toy(inst, toy)
    if inst._toys ~= nil and next(inst._toys) ~= nil and inst._toys[toy] ~= nil then
        inst._toys[toy] = nil

        local tx, ty, tz = toy.Transform:GetWorldPosition()

        spawn_ghostflower(tx, ty, tz, math.random(0, 89) * DEGREES)

        if next(inst._toys) == nil then
            spawn_ghostflower(tx, ty, tz, math.random(90, 179) * DEGREES)

            spawn_ghostflower(tx, ty, tz, math.random(180, 269) * DEGREES)

            spawn_ghostflower(tx, ty, tz, math.random(270, 359) * DEGREES)
        end

        ErodeAway(toy)
    end
end

local function sethairstyle(inst, hairstyle)
    inst._hairstyle = hairstyle or math.random(0, 3)
    if inst._hairstyle ~= 0 then
        inst.AnimState:OverrideSymbol("smallghost_hair", "ghost_kid", "smallghost_hair_"..tostring(inst._hairstyle))
    end
end

local function onsave(inst, data)
    if inst._toys ~= nil and next(inst._toys) ~= nil then
        data.toy_datas = {}
        for t, _ in pairs(inst._toys) do
            -- toy_references should be empty!!
            -- But calling out here in case that changes and someone has to find it.
            local toy_save_record, toy_references = t:GetSaveRecord()
            table.insert(data.toy_datas, toy_save_record)
        end
    elseif inst._toy_datas ~= nil then
        data.toy_datas = inst._toy_datas
    end

    data.shard_id = inst._shard_id

    data.hairstyle = inst._hairstyle
end

local function onload(inst, data, newents)
    sethairstyle(inst, data ~= nil and data.hairstyle or nil)

    if data ~= nil then
        if data.toy_datas ~= nil then
            if data.shard_id ~= nil and inst._shard_id ~= data.shard_id then
                -- If we're not in the shard we spawned in and we have toy data,
                -- we don't want to spawn the toys (we probably migrated),
                -- but we do need to track them still for when we migrate back.
                inst._toy_datas = data.toy_datas
                inst._shard_id = data.shard_id
            else
                inst._toys = {}
                for _, t in ipairs(data.toy_datas) do
                    local toy = SpawnSaveRecord(t)
                    if toy ~= nil then
                        inst._toys[toy] = true

                        inst:ListenForEvent("onremove", function(t)
                            if inst._toys ~= nil and next(inst._toys) ~= nil and inst._toys[t] ~= nil then
                                inst._toys[t] = nil
                            end
                            check_for_quest_finished(inst)
                        end, toy)
                    end
                end

                if inst._hotcold_task == nil then
                    inst._hotcold_task = inst:DoPeriodicTask(0.25, hot_cold_update)
                end
            end
        end
    end
end

local SMALL_GHOST_TRANSPARENCY = 0.6
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyGhostPhysics(inst, 0.5, 0.5)

	inst.DynamicShadow:SetSize(0.75, 0.75)

    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    inst.AnimState:SetBank("ghost_kid")
    inst.AnimState:SetBuild("ghost_kid")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("ghost")
    inst:AddTag("ghostkid")
    inst:AddTag("flying")
    inst:AddTag("girl")
    inst:AddTag("noauradamage")
    inst:AddTag("NOBLOCK")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.CanBeActivatedBy_Client = can_talk_to_client

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetBrain(brain)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.GHOST_SPEED
    inst.components.locomotor.runspeed = TUNING.GHOST_SPEED * 3
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:SetStateGraph("SGsmallghost")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")

    --Added so you can attempt to give hearts to trigger flavour text when the action fails
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)

    -- For gravestone-spawned ghosts to maintain their point (and not dissipate when they have no target)
    inst:AddComponent("knownlocations")

    inst:AddComponent("questowner")
    inst.components.questowner.CanBeginFn = can_begin_quest
    inst.components.questowner:SetOnBeginQuest(on_begin_quest)
    inst.components.questowner.CanAbandonFn = can_abandon_quest
    inst.components.questowner:SetOnAbandonQuest(on_abandon_quest)

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-600,0)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(15, 17)
    inst.components.playerprox:SetOnPlayerNear(on_player_near_fn)
    inst.components.playerprox:SetOnPlayerFar(on_player_far_fn)

    inst:ListenForEvent("onremove", on_smallghost_removed)

    --inst._playerlink = nil
    --inst._toys = nil
    --inst._toy_datas = nil

    inst._shard_id = TheShard:GetShardId()

    inst.PickupToy = pickup_toy
    inst.LinkToPlayer = link_to_player
	inst.LinkToHome = link_to_home

    inst._on_leader_removed = function(leader)
        if inst ~= nil and inst:IsValid() then
            if leader.migration ~= nil or leader:GetTimeAlive() < 0.01 then
                inst:Remove()
            else
                inst.sg:GoToState("dissipate")
            end
        end
    end
    inst._on_leader_death = function(leader)
        unlink_from_player(inst)
    end

    inst.OnSave = onsave
    inst.OnLoad = onload

    ------------------

    if not POPULATING then
        sethairstyle(inst, nil)
    end

    ------------------

    return inst
end

local function on_hotcold_fx_animover(inst)
    inst.AnimState:PlayAnimation("idle"..math.random(1, 3), true)
end

local function hotcold_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("trinket_echoes")
    inst.AnimState:SetBuild("trinket_echoes_fx")
    inst.AnimState:PlayAnimation("idle1", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", on_hotcold_fx_animover)

    return inst
end

return Prefab("hotcold_fx", hotcold_fx_fn, hotcold_fx_assets),
        Prefab("smallghost", fn, assets, prefabs)
