local assets =
{
    Asset("ANIM", "anim/yotr_fightring.zip"),
    Asset("MINIMAP_IMAGE", "yotr_fightring"),
}

local prefabs =
{
    "goldnugget",
    "lucky_goldnugget",
    "pillowfight_confetti_fx",
    "rabbit_confetti_fx",
    "yotr_fightring_bell",
    "yotr_fightring_torch",
}

local WAITING_FIGHTERS_NAMEPREFIX = "waitingfighter"
local WAITING_FIGHTERS_COUNT = 8 -- NOTE: This also happens to be the number of torches placed.
local PER_FIGHTER_ANGLE = TWOPI / WAITING_FIGHTERS_COUNT
local MINIGAME_TIMEOUT_TIME = 2 * TUNING.SEG_TIME
local MINIGAME_INTRO_TIME = 4
local RING_SIZE = TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS
local RING_SIZESQ = RING_SIZE * RING_SIZE
local WAIT_DISTANCE = RING_SIZE - 0.75
local PILLOWFIGHT_UPDATE_RATE = 2*FRAMES
local REACTTEST_UPDATE_RATE = 6
local HALF_REACTTEST_TIME = 0.50*REACTTEST_UPDATE_RATE
local QUARTER_REACTTEST_TIME = 0.25*REACTTEST_UPDATE_RATE

local RING_PLACEMENT_MAXRADIUS = RING_SIZE + 0.5
local RING_PLACEMENT_TESTCOUNT = 12
local RING_PLACEMENT_TESTANGLE = TWOPI / RING_PLACEMENT_TESTCOUNT
local RING_PLACEMENT_TESTIGNORETAGS = {"smallcreature", "character", "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "walkableplatform", "walkableperipheral"}
local function CanDeployFightRingAtPoint(inst, pt)
    if not TheWorld.Map:IsAboveGroundAtPoint(pt.x, pt.y, pt.z)
            or not TheWorld.Map:IsDeployPointClear2(pt, inst, RING_SIZE, nil, nil, nil, RING_PLACEMENT_TESTIGNORETAGS) then
        return false
    end

    for i = 1, RING_PLACEMENT_TESTCOUNT do
        if not TheWorld.Map:IsAboveGroundAtPoint(
                    pt.x + RING_PLACEMENT_MAXRADIUS * math.cos(i*RING_PLACEMENT_TESTANGLE),
                    0,
                    pt.z - RING_PLACEMENT_MAXRADIUS * math.sin(i*RING_PLACEMENT_TESTANGLE),
                    false
                ) then
            return false
        end
    end

    return true
end

local function set_bell_position(bell, x, z)
    x = x or 0
    z = z or 0
    bell.Transform:SetPosition(
        x + math.cos(3/4*PI) * (0.5+RING_SIZE),
        0,
        z - math.sin(3/4*PI) * (0.5+RING_SIZE)
    )
end

----------------------------------------------------------------------------------------
local function add_fightring_competitor(inst, competitor)
    inst._fightring_competitors = inst._fightring_competitors or {}
    inst._fightring_competitors[competitor] = true

    inst.components.minigame:AddParticipator(competitor, true)

    inst:ListenForEvent("onremove", inst._fightring_competitor_onremove, competitor)
    inst:ListenForEvent("attacked", inst._fightring_competitor_onattacked, competitor)
    inst:ListenForEvent("blocked", inst._fightring_competitor_onblocked, competitor)
end

local function remove_fightring_competitor(inst, competitor)
    inst:RemoveEventCallback("onremove", inst._fightring_competitor_onremove, competitor)
    inst:RemoveEventCallback("attacked", inst._fightring_competitor_onattacked, competitor)
    inst:RemoveEventCallback("blocked", inst._fightring_competitor_onblocked, competitor)

    inst._fightring_competitors[competitor] = nil
end

local function get_fightring_competitors(inst)
    return inst._fightring_competitors or {}
end

----------------------------------------------------------------------------------------
local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, inst._camerafocus_dist_min, inst._camerafocus_dist_max, 0)
    else
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function EnableCameraFocus(inst, enable)
    if enable ~= inst._camerafocus:value() then
        inst._camerafocus:set(enable)
        if not TheNet:IsDedicated() then
            OnCameraFocusDirty(inst)
        end
    end
end

----------------------------------------------------------------------------------------
local GAMEBLOCK_CANT_OBJECTS = {"INLIMBO"}

-- NOTE: Torch fires do not have the "fire" tag...
local GAMEBLOCK_ONEOF_OBJECTS = {"fire", "wall", "structure", "minigameitem", "CHOP_workable", "HAMMER_workable", "MINE_workable"}
local function IsArenaClearForMinigame(fightring)
    local x, y, z = fightring.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, RING_SIZE, nil, GAMEBLOCK_CANT_OBJECTS, GAMEBLOCK_ONEOF_OBJECTS)
    return #ents < 1
end

----------------------------------------------------------------------------------------
local function test_for_ringout(inst)
    local competitors = get_fightring_competitors(inst)
    local number_of_legal_competitors = 0
    local competitor_went_out = false

    -- Check how many of our competitors are still legal (not out of the ring yet).
    local ringx, ringy, ringz = inst.Transform:GetWorldPosition()
    for competitor, is_legal in pairs(competitors) do
        if is_legal then
            local competitorx, competitory, competitorz = competitor.Transform:GetWorldPosition()
            if (distsq(competitorx, competitorz, ringx, ringz) > RING_SIZESQ) then
                -- The competitor is no longer legal.
                competitors[competitor] = false

                competitor_went_out = true

                competitor:PushEvent("pillowfight_ringout")

                local wentout_fx = SpawnPrefab("pillowfight_confetti_fx")
                wentout_fx.Transform:SetPosition(competitorx, 0, competitorz)
            else
                number_of_legal_competitors = number_of_legal_competitors + 1
            end
        end
    end

    if number_of_legal_competitors < 2 then
        inst:_EndMinigame()
    elseif competitor_went_out then
        -- If somebody went out, try to make everybody retarget.
        -- We could go looking for specifically the people targetting a character
        -- that ringed out, but this is a bit more chaotic.
        for competitor, is_legal in pairs(competitors) do
            if is_legal then
                competitor.components.combat:TryRetarget()
            end
        end
    end

    -- EndMinigame will kill this looping task.
    -- If we didn't end the minigame, we continue iterating!
end

local function try_react(competitor)
    competitor:PushEvent("cheer", {text=STRINGS.COZY_RABBIT_GETTOKEN})
end

local function test_for_reactions(inst)
    local competitors = get_fightring_competitors(inst)
    for competitor, is_legal in pairs(competitors) do
        if not is_legal then
            -- Pick a random time in the 1/4 to 3/4 range to react in.
            local react_delay = QUARTER_REACTTEST_TIME + math.random() * HALF_REACTTEST_TIME
            competitor:DoTaskInTime(react_delay, try_react)
        end
    end
end

----------------------------------------------------------------------------------------
local function torch_enable_eventpush(torch, arena)
    torch:PushEvent("turnon")
    if arena and arena.SoundEmitter then
        arena.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
    end
end

local function torch_gosmall_eventpush(torch, arena)
    torch:PushEvent("gosmall")
    if arena and arena.SoundEmitter then
        arena.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
    end
end

local function torch_disable_eventpush(torch, arena)
    torch:PushEvent("turnoff")
    if arena and arena.SoundEmitter then
        arena.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
    end
end

----------------------------------------------------------------------------------------
local function IsCompetitorCompeting(inst, competitor)
    return get_fightring_competitors(inst)[competitor]
end

local function FlagCheating(inst)
    inst._cheating_occurred = true
end

----------------------------------------------------------------------------------------
local function GoToDeactivateMinigame(inst)
    local competitors = get_fightring_competitors(inst)
    for competitor in pairs(competitors) do
        competitor:PushEvent("pillowfight_deactivated")

        remove_fightring_competitor(inst, competitor)
    end

    for d = 1, WAITING_FIGHTERS_COUNT do
        local torch = inst._torches[d]
        if torch then
            torch_disable_eventpush(torch)
            if torch._enable_event then
                torch._enable_event:Cancel()
                torch._enable_event = nil
            end
            if torch._gosmall_event then
                torch._gosmall_event:Cancel()
                torch._gosmall_event = nil
            end
        end
    end

    inst.components.minigame:Deactivate()
end

local WON_DATA = {won = true}
local function push_endofpillowfight(inst, won)
    inst:PushEvent("pillowfight_ended", (won and WON_DATA) or nil)
end

local function do_confetti(inst)
    local confetti_x, confetti_y, confetti_z
    if inst._bell then
        inst._bell:PushEvent("pillowfight_playhit")
        confetti_x, confetti_y, confetti_z = inst._bell.Transform:GetWorldPosition()
        confetti_x = confetti_x + 1.2
        confetti_z = confetti_z + 0.5
    else
        confetti_x, confetti_y, confetti_z = inst.Transform:GetWorldPosition()
        confetti_x = confetti_x - 0.5
        confetti_z = confetti_z - 2.5
    end

    local end_of_game_fx = SpawnPrefab("rabbit_confetti_fx")
    end_of_game_fx.Transform:SetPosition(confetti_x, 0, confetti_z)
end

local function EndMinigame(inst, gamefailed)
    if inst._out_of_ring_test then
        inst._out_of_ring_test:Cancel()
        inst._out_of_ring_test = nil
    end

    if inst._reacting_bunnies_test then
        inst._reacting_bunnies_test:Cancel()
        inst._reacting_bunnies_test = nil
    end

    local num_npc_prizes = 0
    local some_npc_loser, player_winner = nil, nil
    local competitors = get_fightring_competitors(inst)
    for competitor, is_legal in pairs(competitors) do
        if not is_legal and not competitor.isplayer then
            local competitor_inventory = competitor.components.inventory
            if competitor_inventory then
                local competitor_body_item = competitor_inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                num_npc_prizes = num_npc_prizes + ((competitor_body_item and competitor_body_item._prize_value) or 0)

                local competitor_hand_item = competitor_inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                num_npc_prizes = num_npc_prizes + ((competitor_hand_item and competitor_hand_item._prize_value) or 0)
            else
                num_npc_prizes = num_npc_prizes + 1
            end

            some_npc_loser = competitor
        elseif is_legal and competitor.isplayer then
            -- Just try to find a player that didn't lose to drop off a prize for.
            player_winner = competitor
        end
        competitor:DoTaskInTime(math.random(0, 5)*FRAMES, push_endofpillowfight, is_legal)
    end

    if not inst._cheating_occurred then
        if num_npc_prizes > 0 and some_npc_loser and player_winner then
            some_npc_loser:PushEvent("setupprizes", {
                type = inst._minigame_prizeitem,
                count = math.clamp(math.ceil(num_npc_prizes), 1, TUNING.PILLOWFIGHT_PRIZE_CAP),
                winner = player_winner,
            })
        end

        if not gamefailed then
            -- Don't shoot out the confetti if we didn't really play the game properly.
            inst:DoTaskInTime(0.5 + math.random(), do_confetti)
        end
    end
    inst._cheating_occurred = nil

    --inst.SoundEmitter:PlaySound("yotr_2023/common/arena_round_end_bell")
    inst.components.minigame:SetIsOutro()

    inst:DoTaskInTime(3, GoToDeactivateMinigame)
end

----------------------------------------------------------------------------------------
local function OnArenaNotClearMessage(inst)
    for index = 1, WAITING_FIGHTERS_COUNT do
        local potential_fighter = inst.components.entitytracker:GetEntity(WAITING_FIGHTERS_NAMEPREFIX..index)
        if potential_fighter then
            potential_fighter:PushEvent("disappoint", {text=STRINGS.COZY_RABBIT_ARENANOTEMPTY})
        end
    end
end

----------------------------------------------------------------------------------------
local function collect_minigame_fighters(inst)
    for index = 1, WAITING_FIGHTERS_COUNT do
        local potential_fighter = inst.components.entitytracker:GetEntity(WAITING_FIGHTERS_NAMEPREFIX..index)
        if potential_fighter then
            local doer_hand_equip = (potential_fighter.components.inventory
                and potential_fighter.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
                or nil
            if doer_hand_equip and doer_hand_equip:HasTag("pillow") then
                add_fightring_competitor(inst, potential_fighter)
                inst.components.entitytracker:ForgetEntity(WAITING_FIGHTERS_NAMEPREFIX..index)
            end
        end
    end

    -- We just put everyone into the game, so reset the wait index.
    inst._npc_wait_index = 1

    for _, player in ipairs(AllPlayers) do
        if player:GetDistanceSqToInst(inst) < RING_SIZESQ then
            add_fightring_competitor(inst, player)
        end
    end

    return get_fightring_competitors(inst)
end

local function SetGameToPlaying(inst)
    inst._out_of_ring_test = inst:DoPeriodicTask(PILLOWFIGHT_UPDATE_RATE, test_for_ringout)
    inst._reacting_bunnies_test = inst:DoPeriodicTask(REACTTEST_UPDATE_RATE, test_for_reactions)

    inst.components.minigame:SetIsPlaying()
end

local function StartMinigame(inst)
    if not IsArenaClearForMinigame(inst) then
        OnArenaNotClearMessage(inst)
        inst:_EndMinigame(true)
        return
    end

    local competitors = collect_minigame_fighters(inst)
    local num_competitors = GetTableSize(competitors)
    if num_competitors < 2 then
        inst:_EndMinigame(true)
        return
    end

    for competitor in pairs(competitors) do
        competitor:PushEvent("pillowfight_startgame", inst)
    end

    inst:DoTaskInTime(3, SetGameToPlaying)
end

----------------------------------------------------------------------------------------
local function OnActivateMinigame(inst)
    inst.components.minigame:SetIsIntro()
    if inst._camerafocus_dist_min then
        EnableCameraFocus(inst, true)
    end
    TheWorld:PushEvent("pausehounded", {source = inst})
    inst:SetPillowFightActive(true)
end

local function OnDeactivateMinigame(inst)
    TheWorld:PushEvent("unpausehounded", {source = inst})
    inst:SetPillowFightActive(false)

    if inst._bell then
        inst._bell:FinishGame()
    end

    if inst._minigame_timeout_task then
        inst._minigame_timeout_task:Cancel()
        inst._minigame_timeout_task = nil
    end

    if inst._start_minigame_task then
        inst._start_minigame_task:Cancel()
        inst._start_minigame_task = nil
    end

    EnableCameraFocus(inst, false)
end

----------------------------------------------------------------------------------------
local function OnRingActivated(inst, doer)
    if not inst._start_minigame_task then
        inst._minigame_starttime = GetTime()
        inst._minigame_prizeitem = IsSpecialEventActive(SPECIAL_EVENTS.YOTR) and "lucky_goldnugget" or "goldnugget"
        if inst._minigame_timeout_task then
            inst._minigame_timeout_task:Cancel()
        end
        inst._minigame_timeout_task = inst:DoTaskInTime(MINIGAME_TIMEOUT_TIME, inst._EndMinigame)
        inst._start_minigame_task = inst:DoTaskInTime(MINIGAME_INTRO_TIME, inst._StartMinigame)

        inst.components.minigame:Activate()
        inst.components.minigame:RecordExcitement()

        for d = 1, WAITING_FIGHTERS_COUNT do
            local torch = inst._torches[d]
            if torch then
                torch._enable_event = torch:DoTaskInTime(d*(MINIGAME_INTRO_TIME / WAITING_FIGHTERS_COUNT), torch_enable_eventpush, inst)
                torch._gosmall_event = torch:DoTaskInTime(MINIGAME_INTRO_TIME + (d * (MINIGAME_TIMEOUT_TIME - MINIGAME_INTRO_TIME) / WAITING_FIGHTERS_COUNT), torch_gosmall_eventpush, inst)
                --inst.SoundEmitter:PlaySound("yotr_2023/common/arena_round_end_bell")
            end
        end
    end

    return true
end

local function AddFighterToWaitQueue(inst, fighter)
    local current_index = inst._npc_wait_index
    inst._npc_wait_index = (inst._npc_wait_index == WAITING_FIGHTERS_COUNT and 1) or inst._npc_wait_index + 1

    local fighter_entitytracker_name = WAITING_FIGHTERS_NAMEPREFIX..current_index

    local fighter_at_index = inst.components.entitytracker:GetEntity(fighter_entitytracker_name)
    if fighter_at_index then
        fighter_at_index:PushEvent("pillowfight_deactivated")
    end

    inst.components.entitytracker:TrackEntity(fighter_entitytracker_name, fighter)

    return current_index
end

local function OnFighterArrived(inst, fighter_data)
    local fighter = (fighter_data and fighter_data.fighter) or nil
    if not fighter then return end

    local new_fighter_index = AddFighterToWaitQueue(inst, fighter)

    -- Have the fighters stand between the torches while waiting.
    local wait_angle = (new_fighter_index + 0.5) * PER_FIGHTER_ANGLE
    local arena_position = inst:GetPosition()

    if not fighter_data.already_teleported then
        local teleport_position = arena_position + Vector3(WAIT_DISTANCE/2 * math.cos(wait_angle), 0, -WAIT_DISTANCE/2 * math.sin(wait_angle))
        fighter.Physics:Teleport(teleport_position:Get())
    end

    local wait_position = arena_position + Vector3(WAIT_DISTANCE * math.cos(wait_angle), 0, -WAIT_DISTANCE * math.sin(wait_angle))
    fighter:PushEvent("pillowfight_arrivedatarena", wait_position)
end

----------------------------------------------------------------------------------------
local function RegisterWithWorld(inst)
    if not TheWorld.yotr_fightrings then
        TheWorld.yotr_fightrings = {}
    end
    TheWorld.yotr_fightrings[inst] = true
    inst:ListenForEvent("onremove", function()
        if TheWorld.yotr_fightrings then
            TheWorld.yotr_fightrings[inst] = nil
        end
    end)
end

----------------------------------------------------------------------------------------
local function onringsave(inst, data)
    data.wait_index = inst._npc_wait_index
end

local function onringload(inst, data)
    if data then
        inst._npc_wait_index = data.wait_index or inst._npc_wait_index
    end
end

-- Mid-Pillow Fight Background Music ---------------------------------------------------
local function UpdateGameMusic(inst)
    if ThePlayer and ThePlayer:IsNear(inst, TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS + 1.0) then
        ThePlayer:PushEvent("playpillowfightmusic")
    end
end

local function OnMusicPlayingDirty(inst)
    -- Dedicated servers don't need to trigger music
    if TheNet:IsDedicated() then
        return
    end

    if not inst._pillowfightactive:value() then
        if inst._musictask then
            inst._musictask:Cancel()
            inst._musictask = nil
        end
    elseif not inst._musictask then
        inst._musictask = inst:DoPeriodicTask(1, UpdateGameMusic)
        UpdateGameMusic(inst)
    end
end

local function SetPillowFightActive(inst, music_playing)
    if inst._pillowfightactive:value() ~= music_playing then
        inst._pillowfightactive:set(music_playing)
        OnMusicPlayingDirty(inst)
    end
end

----------------------------------------------------------------------------------------
local function make_torch_unplaced(inst, index, spawn_distance, x, z)
    local torch = SpawnPrefab("yotr_fightring_torch")
    local spawn_angle = index * PER_FIGHTER_ANGLE
    torch.Transform:SetPosition(
        x + spawn_distance * math.cos(spawn_angle),
        0,
        z - spawn_distance * math.sin(spawn_angle)
    )
    table.insert(inst._torches, torch)

    if inst.was_placed then
        torch:PushEvent("onplaced")
    end
end

local function make_torch_placed(inst, index, spawn_distance, x, z)
    inst:DoTaskInTime((2 + 2*index)*FRAMES, make_torch_unplaced, index, spawn_distance, x, z)
end

local function SetUpAuxiliaryObjects(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    inst._torches = {}
    local TORCH_SPAWN_DISTANCE = RING_SIZE - 0.40
    local make_torch_fn = (inst.was_placed and make_torch_placed) or make_torch_unplaced
    for i = 1, WAITING_FIGHTERS_COUNT do
        make_torch_fn(inst, i, TORCH_SPAWN_DISTANCE, ix, iz)
    end

    inst._bell = SpawnPrefab("yotr_fightring_bell")
    set_bell_position(inst._bell, ix, iz)
    inst._bell:SetParentRing(inst)
    if inst.was_placed then
        inst._bell:PushEvent("onplaced", inst)
    end
end

local function OnRingPlaced(inst)
    inst.was_placed = true

    inst.AnimState:PlayAnimation("spawn_ring")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("yotr_2023/common/arena_place")
end

local function OnRingRemoved(inst)
    if inst._torches then
        local num_torches = #inst._torches
        for torch_index = num_torches, 1, -1 do
            inst._torches[torch_index]:Remove()
        end
    end

    if inst._bell then
        inst._bell:Remove()
    end

    for index = 1, WAITING_FIGHTERS_COUNT do
        local potential_fighter = inst.components.entitytracker:GetEntity(WAITING_FIGHTERS_NAMEPREFIX..index)
        if potential_fighter then
            potential_fighter:PushEvent("pillowfight_deactivated")
        end
    end
end

local function push_cheating(competitor)
    competitor:PushEvent("cheating")
end

local function ringfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("yotr_fightring.png")

    inst.AnimState:SetBank("yotr_fightring")
    inst.AnimState:SetBuild("yotr_fightring")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("birdblocker")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("yotr_arena")

    inst._camerafocus = net_bool(inst.GUID, "yotr_fightring._camerafocus", "camerafocusdirty")
	inst._camerafocus_dist_min = TUNING.BUNNY_RING_CAMERA_FOCUS_MIN
	inst._camerafocus_dist_max = TUNING.BUNNY_RING_CAMERA_FOCUS_MAX

    inst.highlightchildren = {}

    inst._pillowfightactive = net_bool(inst.GUID, "yotr_fightring._musicplaying", "musicplayingdirty")
    --inst._musictask = nil

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)
        inst:ListenForEvent("musicplayingdirty", OnMusicPlayingDirty)

        return inst
    end

    ---------------------------------------------------------
    --inst._minigame_starttime = nil
    --inst._minigame_prizeitem = nil
    inst._npc_wait_index = 1

    ---------------------------------------------------------
    inst:DoTaskInTime(0, SetUpAuxiliaryObjects)

    ---------------------------------------------------------
    local minigame = inst:AddComponent("minigame")
    minigame.gametype = "bunnyman_pillowfighting"
    minigame:SetOnActivatedFn(OnActivateMinigame)
    minigame:SetOnDeactivatedFn(OnDeactivateMinigame)
    minigame.spectator_dist = TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS + 20
    minigame.participator_dist = 0

    ---------------------------------------------------------
    inst:AddComponent("entitytracker")

    ---------------------------------------------------------
    inst:ListenForEvent("pillowfight_fighterarrived", OnFighterArrived)
    inst:ListenForEvent("pillowfight_arenanotclear", OnArenaNotClearMessage)
    inst:ListenForEvent("onplaced", OnRingPlaced)
    inst:ListenForEvent("onremove", OnRingRemoved)

    ---------------------------------------------------------
    inst._fightring_competitor_onremove = function(removed_competitor)
        inst._fightring_competitors[removed_competitor] = nil
    end

    inst._fightring_competitor_onattacked = function(attacked_competitor, data)
        if data
            and ((data.attacker and not inst:IsCompeting(data.attacker))
                or not data.weapon
                or not data.weapon:HasTag("pillow")) then

            local cheater_is_competing = (data.attacker and inst:IsCompeting(data.attacker))
            local competitors = get_fightring_competitors(inst)
            for competitor in pairs(competitors) do
                if competitor ~= data.attacker then
                    competitor:DoTaskInTime(math.random(5, 20)*FRAMES, push_cheating)
                end

                -- If our cheater is still in the game, set all NPCs to target the cheater.
                if not competitor.isplayer and cheater_is_competing then
                    competitor.components.combat:SetTarget(data.attacker)
                end
            end

            inst:FlagCheating()
        end
    end

    inst._fightring_competitor_onblocked = function(attacked_competitor, data)
        if data and data.attacker and not inst:IsCompeting(data.attacker) then
            local competitors = get_fightring_competitors(inst)
            for competitor in pairs(competitors) do
                competitor:DoTaskInTime(math.random(5, 20)*FRAMES, push_cheating)
            end

            inst:FlagCheating()
        end
    end

    ---------------------------------------------------------
    inst.IsCompeting = IsCompetitorCompeting
    inst.FlagCheating = FlagCheating
    inst.SetPillowFightActive = SetPillowFightActive
    inst._StartMinigame = StartMinigame
    inst._EndMinigame = EndMinigame

    RegisterWithWorld(inst)

    ---------------------------------------------------------
    inst.OnRingActivated = OnRingActivated
    inst.OnSave = onringsave
    inst.OnLoad = onringload

    return inst
end

--------------------------------------------------------------------------------------------------------
local kitassets =
{
    Asset("ANIM", "anim/yotr_fightring.zip"),
    Asset("INV_IMAGE", "yotr_fightring_kit"),
}

local kitprefabs =
{
    "yotr_fightring",
}

local function on_kit_deployed(inst, position, deployer)
    local fightring = SpawnPrefab("yotr_fightring")
    if fightring then
        fightring.Transform:SetPosition(position.x, 0, position.z)
        fightring:PushEvent("onplaced")

        inst:Remove()
    end
end

--------------------------------------------------------------------
local function CLIENT_CanDeployFightRing(inst, pt, mouseover, deployer, rotation)
    return CanDeployFightRingAtPoint(inst, pt)
end

local function kitfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("usedeployspacingasoffset")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yotr_fightring")
    inst.AnimState:SetBuild("yotr_fightring")
    inst.AnimState:PlayAnimation("item")

    MakeInventoryFloatable(inst, "med", 0.25, 0.83)

    -- So we can set a spacing higher than the default list of constants.
    inst._custom_candeploy_fn = CLIENT_CanDeployFightRing

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------------------------------------------
    local deployable = inst:AddComponent("deployable")
    deployable.ondeploy = on_kit_deployed
    deployable:SetDeployMode(DEPLOYMODE.CUSTOM)

    ---------------------------------------------------------
    inst:AddComponent("inspectable")

    ---------------------------------------------------------
    inst:AddComponent("inventoryitem")

    ---------------------------------------------------------
    local fuel = inst:AddComponent("fuel")
    fuel.fuelvalue = TUNING.LARGE_FUEL

    ---------------------------------------------------------
    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)

    ---------------------------------------------------------
    MakeHauntableLaunch(inst)

    return inst
end

--------------------------------------------------------------------------------------------------------
-- Fight Pit Torches
--------------------------------------------------------------------------------------------------------
local torchprefabs =
{
    "torchfire",
    "torchfire_yotrpillowfight",
}

local function torch_onplaced(inst)
    inst.AnimState:PlayAnimation("spawn_torch")
    inst.AnimState:PushAnimation("torch", false)
end

local function torch_turnon(inst)
    if not inst._fire then
        inst._fire = SpawnPrefab("torchfire_yotrpillowfight")
        inst._fire.entity:SetParent(inst.entity)

        inst._fire.entity:AddFollower()
        inst._fire.Follower:FollowSymbol(inst.GUID, "wick", 0, -50, 0)
        inst._fire:AttachLightTo(inst)
    end
end

local function torch_gosmall(inst)
    if inst._fire then
        inst._fire:Remove()
        inst._fire = nil
    end

    inst._fire = SpawnPrefab("torchfire")
    inst._fire.entity:SetParent(inst.entity)

    inst._fire.entity:AddFollower()
    inst._fire.Follower:FollowSymbol(inst.GUID, "wick", 0, -50, 0)
    inst._fire:AttachLightTo(inst)
end

local function torch_turnoff(inst)
    if inst._fire then
        inst._fire:Remove()
        inst._fire = nil
    end
end

local function torchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("yotr_fightring")
    inst.AnimState:SetBuild("yotr_fightring")
    inst.AnimState:PlayAnimation("torch")
    inst.AnimState:SetFinalOffset(2)

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --inst._fire = nil

    inst:ListenForEvent("onplaced", torch_onplaced)
    inst:ListenForEvent("turnon", torch_turnon)
    inst:ListenForEvent("gosmall", torch_gosmall)
    inst:ListenForEvent("turnoff", torch_turnoff)

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------------------------------------
-- Fight bell
--------------------------------------------------------------------------------------------------------
local bellassets = {
    Asset("ANIM", "anim/yotr_fightring_bell.zip"),
}

local function GetStatus(inst)
    return (inst._parent_ring and inst._parent_ring._minigame_timeout_task and "PLAYING")
        or nil
end

local function bell_onplaced(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("yotr_2023/common/bell_place")
    inst.AnimState:PushAnimation("idle", false)
end

local function OnBellActivated(inst, doer)
    if not doer then
        inst.components.activatable.inactive = true
        return false
    end

    local doer_hand_equip = (doer.components.inventory and doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
        or nil
    if not doer_hand_equip or not doer_hand_equip:HasTag("pillow") then
        inst.components.activatable.inactive = true
        return false, "PILLOWFIGHT_NO_HANDPILLOW"
    end

    if inst._parent_ring then
        if not IsArenaClearForMinigame(inst._parent_ring) then
            inst._parent_ring:PushEvent("pillowfight_arenanotclear")
            inst.components.activatable.inactive = true
            return false
        end

        inst._parent_ring:OnRingActivated(doer)
    end

    inst.AnimState:PlayAnimation("ring")
    inst.SoundEmitter:PlaySound("yotr_2023/common/arena_round_end_bell")
    inst.AnimState:PushAnimation("idle", false)
    inst.components.workable:SetWorkable(false)
end

local function bell_play_hit(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
end

local function on_bell_worked(inst, worker, numworks)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
end

local function on_bell_work_finished(inst, worker)
    if inst._parent_ring then
        local dropx, dropy, dropz = inst._parent_ring.Transform:GetWorldPosition()
        local fx = SpawnPrefab("collapse_big")
        fx:SetMaterial("wood")
        fx.Transform:SetPosition(dropx, 0, dropz)

        inst.components.lootdropper:DropLoot(Vector3(dropx, dropy, dropz))

        -- The fightring's onremove listener should clean us up as well.
        inst._parent_ring:Remove()
    else
        local dropx, dropy, dropz = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("collapse_small")
        fx:SetMaterial("wood")
        fx.Transform:SetPosition(dropx, dropy, dropz)

        inst.components.lootdropper:DropLoot(Vector3(dropx, dropy, dropz))

        inst:Remove()
    end
end

local function bell_finishgame(inst)
    inst.AnimState:PlayAnimation("ring")
    inst.SoundEmitter:PlaySound("yotr_2023/common/arena_round_end_bell")
    inst.AnimState:PushAnimation("idle", false)
    inst.components.workable:SetWorkable(true)
    inst.components.activatable.inactive = true
end

local function bell_setparentring(inst, ring)
    if not ring then return end

    inst._parent_ring = ring
    inst:ListenForEvent("onremove", inst._on_parent_ring_removed, ring)
end

local BELL_LOOTDROPPER_LOOT = {"yotr_fightring_kit"}
local function bellfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("yotr_fightring_bell")
    inst.AnimState:SetBuild("yotr_fightring_bell")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(2)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------------------------------------------
    local activatable = inst:AddComponent("activatable")
    activatable.OnActivate = OnBellActivated

    ---------------------------------------------------------
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = GetStatus

    ---------------------------------------------------------
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(4)
    workable:SetOnWorkCallback(on_bell_worked)
    workable:SetOnFinishCallback(on_bell_work_finished)

    ---------------------------------------------------------
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetLoot(BELL_LOOTDROPPER_LOOT)

    ---------------------------------------------------------
    inst:ListenForEvent("onplaced", bell_onplaced)
    inst:ListenForEvent("pillowfight_playhit", bell_play_hit)

    ---------------------------------------------------------
    inst._on_parent_ring_removed = function(ring) inst._parent_ring = nil end

    ---------------------------------------------------------
    inst.FinishGame = bell_finishgame
    inst.SetParentRing = bell_setparentring

    ---------------------------------------------------------
    inst.persists = false

    return inst
end

--------------------------------------------------------------------------------------------------------
-- Placer presentation functions
--------------------------------------------------------------------------------------------------------
local function CreatePlacerTorch(parent)
    local inst = CreateEntity("yotr_fightring_placertorch")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.entity:SetParent(parent.entity)

    inst:AddTag("FX")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("yotr_fightring")
    inst.AnimState:SetBuild("yotr_fightring")
    inst.AnimState:PlayAnimation("torch")
    inst.AnimState:SetFinalOffset(2)

    if parent.components.placer ~= nil then
        parent.components.placer:LinkEntity(inst)
    end

    return inst
end

local function CreatePlacerBell(parent)
    local inst = CreateEntity("yotr_fightring_placerbell")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.entity:SetParent(parent.entity)

    inst:AddTag("FX")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("yotr_fightring_bell")
    inst.AnimState:SetBuild("yotr_fightring_bell")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(2)

    if parent.components.placer ~= nil then
        parent.components.placer:LinkEntity(inst)
    end

    return inst
end

local function create_placer_presentation(parentinst)
    local TORCH_SPAWN_DISTANCE = RING_SIZE - 0.40
    for i = 1, WAITING_FIGHTERS_COUNT do
        local torch = CreatePlacerTorch(parentinst)
        if torch then
            local spawn_angle = i * PER_FIGHTER_ANGLE
            torch.Transform:SetPosition(TORCH_SPAWN_DISTANCE * math.cos(spawn_angle), 0, -TORCH_SPAWN_DISTANCE * math.sin(spawn_angle))
        end
    end

    set_bell_position(CreatePlacerBell(parentinst))
end

local function ring_placer_testfn(inst)
    local placer_pos = inst:GetPosition()
    return CanDeployFightRingAtPoint(inst, placer_pos), false
end

local function ring_placer_postinit(parentinst)
    if not TheNet:IsDedicated() then
        parentinst:DoTaskInTime(0, create_placer_presentation)
    end

    parentinst.AnimState:SetLayer(LAYER_BACKGROUND)

    parentinst.components.placer.override_testfn = ring_placer_testfn
end

return Prefab("yotr_fightring", ringfn, assets, prefabs),
    Prefab("yotr_fightring_kit", kitfn, kitassets, kitprefabs),
    Prefab("yotr_fightring_torch", torchfn, assets, torchprefabs),
    Prefab("yotr_fightring_bell", bellfn, bellassets),
    MakePlacer("yotr_fightring_kit_placer", "yotr_fightring", "yotr_fightring", "idle", true, false, false, nil, nil, nil, ring_placer_postinit, 6)
