local assets =
{
    Asset("ANIM", "anim/lunar_rift_portal.zip"),
    Asset("ANIM", "anim/lunar_rift_portal_small.zip"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal1"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal2"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal3"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal4"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal_max"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal_max1"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal_max2"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal_max3"),
    Asset("MINIMAP_IMAGE", "lunarrift_portal_max4"),
}

local prefabs =
{
    "lunar_grazer",
    "lunarrift_crystal_big",
    "lunarrift_crystal_small",
    "lunarrift_portal_shadow",
    "rift_terraformer",
}


---------------------------------------------------------------------------------

local STAGEUP_TIME = 3

local MIN_CRYSTAL_DISTANCE = 3.0
local MAX_CRYSTAL_DISTANCE_BY_STAGE = {0.0, 6.5, 22.5}
local MAX_CRYSTAL_RING_COUNT_BY_STAGE = {0, 1, 3}
local CRYSTALS_PER_RING = 4
local HALFPI = PI/2
local TILE_WIDTH_BY_STAGE = {0, 3, 6}
local TERRAFORM_DELAY = TUNING.RIFT_LUNAR1_STAGEUP_BASE_TIME / 3

local SHADOW_SCALE_BY_STAGE = {0.4, 0.8, 1.2}
local LIGHT_SCALE_BY_STAGE_CONSTANT = 0.7

local GRAZER_SPAWNS_BY_STAGE = {1, 2, 3}

local AMBIENT_SOUND_LOOP_NAME = "lunarrift_portal_ambience"
local AMBIENT_SOUND_PARAM_NAME = "param00"
local AMBIENT_SOUND_STAGE_TO_INTENSITY = {0.2, 0.5, 0.8}

--------------------------------------------------------------------------------
local function make_terraformer_proxy(inst, ix, iy, iz)
    local terraformer = SpawnPrefab("rift_terraformer")
    terraformer.Transform:SetPosition(ix, iy, iz)
    inst:ListenForEvent("onremove", function(_)
        inst._terraformer = nil
    end, terraformer)

    return terraformer
end

local function do_portal_tiles(inst, portal_position, stage)
    local ix, iy, iz
    if portal_position then
        ix, iy, iz = portal_position.x, portal_position.y, portal_position.z
    else
        ix, iy, iz = inst.Transform:GetWorldPosition()
    end

    local _map = TheWorld.Map
    local portal_tile_x, portal_tile_y = _map:GetTileCoordsAtPoint(ix, iy, iz)

    stage = stage or inst._stage

    inst._terraformer = inst._terraformer or make_terraformer_proxy(inst, ix, iy, iz)

    -- If we're at stage 1, we need to handle offset 0,0 (the loop condition excludes it below)
    if stage == 1 then
        inst._terraformer:AddTerraformTask(portal_tile_x, portal_tile_y, 0)
    end

    local current_count = TILE_WIDTH_BY_STAGE[stage]
    local previous_count = (TILE_WIDTH_BY_STAGE[stage - 1] or 0) + 1

    for index = previous_count, current_count do
        local horizontal_offset, vertical_offset = index, 0
        local vertical_mod = 1
        local base_time_delay = (index - previous_count)
        while horizontal_offset > -index do
            -- We do the tile replacement symmetrically, so we can just flip our offsets
            -- while iterating to hit both sides of the portal together.
            inst._terraformer:AddTerraformTask(
                portal_tile_x + horizontal_offset,
                portal_tile_y + vertical_offset,
                (base_time_delay + 0.3 + 0.3*math.random()) * TERRAFORM_DELAY,
                {horizontal_offset, vertical_offset}
            )
            inst._terraformer:AddTerraformTask(
                portal_tile_x - horizontal_offset,
                portal_tile_y - vertical_offset,
                (base_time_delay + 0.3 + 0.3*math.random()) * TERRAFORM_DELAY,
                {-horizontal_offset, -vertical_offset}
            )

            -- The vertical offset needs to reverse when it reaches max distance,
            -- but the horizontal offset can just keep trucking until it reaches
            -- the maximum negative distance.
            horizontal_offset = horizontal_offset - 1
            vertical_offset = vertical_offset + vertical_mod
            if vertical_offset == index then
                vertical_mod = -1
            end
        end
    end
end

--------------------------------------------------------------------------------
local function track_crystal(inst, crystal)
    inst._crystals[crystal] = true

    inst:ListenForEvent("onremove", inst._on_crystal_removed, crystal)
end

local CRYSTAL_TAGS = {"crystal"}
local CRYSTAL_TEST_RADIUS = 2.5
local function do_crystal_spawn(inst, prefab, portal_position, offset_angle, offset_size, time)
    local offset = FindWalkableOffset(portal_position, offset_angle, offset_size, nil, true)
    if offset then
        local px, py, pz = (portal_position + offset):Get()
        local too_close_crystals = TheSim:FindEntities(px, py, pz, CRYSTAL_TEST_RADIUS, CRYSTAL_TAGS)
        if #too_close_crystals > 0 then
            return false
        end

        local crystal = SpawnPrefab(prefab)
        crystal.Transform:SetPosition(px, py, pz)
        crystal:ForceFacePoint(portal_position:Get())
        crystal:PushEvent("docrystalspawnin", time or 0)

        inst:TrackCrystal(crystal)

        return true
    end

    return false
end

local function try_spawn_crystals(inst, portal_position, stage)
    portal_position = portal_position or inst:GetPosition()
    stage = stage or inst._stage

    local num_crystals = GetTableSize(inst._crystals)
    local max_crystals = MAX_CRYSTAL_RING_COUNT_BY_STAGE[stage] * CRYSTALS_PER_RING
    if (max_crystals - num_crystals) >= CRYSTALS_PER_RING then
        local offset = MIN_CRYSTAL_DISTANCE + math.sqrt(math.random())*(MAX_CRYSTAL_DISTANCE_BY_STAGE[stage] - MIN_CRYSTAL_DISTANCE)
        local previous_max_crystal_distance = MAX_CRYSTAL_DISTANCE_BY_STAGE[stage - 1] or 0
        local time_delay = math.max(0, ((offset - previous_max_crystal_distance) / TILE_SCALE) * TERRAFORM_DELAY)

        local angle = (math.random(8) * PI) / 4

        for _ = 1, CRYSTALS_PER_RING do
            if do_crystal_spawn(inst, "lunarrift_crystal_big", portal_position, angle, offset, time_delay + (2*math.random())) then
                num_crystals = num_crystals + 1
            end
            angle = angle + HALFPI
        end
    end

    inst.components.timer:StopTimer("try_crystals")
    inst.components.timer:StartTimer("try_crystals", TUNING.RIFT_LUNAR1_TRY_CRYSTALS_BASE_TIME + math.random() * TUNING.RIFT_LUNAR1_TRY_CRYSTALS_RANDOM_TIME)
end

--------------------------------------------------------------------------------
local GRAZER_CRYSTAL_MIN_DISTANCE = 1.0
local GRAZER_CRYSTAL_MIN_DSQ = (GRAZER_CRYSTAL_MIN_DISTANCE * GRAZER_CRYSTAL_MIN_DISTANCE) + 0.01
local function spawn_grazer(inst, x, z, delay)
    if inst._crystals and next(inst._crystals) then
        for crystal in pairs(inst._crystals) do
            if crystal:GetDistanceSqToPoint(x, 0, z) < GRAZER_CRYSTAL_MIN_DSQ then
                local offset = FindWalkableOffset(
                    Vector3(x, 0, z),
                    TWOPI*math.random(),
                    GRAZER_CRYSTAL_MIN_DISTANCE + 0.01,
                    nil, nil, true, nil, false, false
                )
                if offset then
                    x = x + offset.x
                    z = z + offset.z
                end
                break
            end
        end
    end

    local grazer = SpawnPrefab("lunar_grazer")
    grazer.Transform:SetPosition(x, 0, z)   -- NOTE: It's important to set this transform first.
    grazer:OnSpawnedBy(inst, delay)
end

local function try_spawn_grazers(inst, portal_position, stage)
    stage = stage or inst._stage
    local number_of_grazers = GRAZER_SPAWNS_BY_STAGE[stage]
    if number_of_grazers < 1 then
        return
    end

    portal_position = portal_position or inst:GetPosition()
    local px, py, pz = portal_position:Get()

    local _map = TheWorld.Map
    local portal_tile_x, portal_tile_y = _map:GetTileCoordsAtPoint(px, py, pz)

    local spawn_tile_xs, spawn_tile_ys = {portal_tile_x}, {portal_tile_y}
    for index = 1, stage do
        local horizontal_offset, vertical_offset, vertical_mod = index, 0, 1
        while horizontal_offset > -index do
            local tx, ty = (portal_tile_x + horizontal_offset), (portal_tile_y + vertical_offset)
            if _map:GetTile(tx, ty) == WORLD_TILES.RIFT_MOON then
                table.insert(spawn_tile_xs, tx)
                table.insert(spawn_tile_ys, ty)
            end

            tx, ty = (portal_tile_x - horizontal_offset), (portal_tile_y - vertical_offset)
            if _map:GetTile(tx, ty) == WORLD_TILES.RIFT_MOON then
                table.insert(spawn_tile_xs, tx)
                table.insert(spawn_tile_ys, ty)
            end

            -- The vertical offset needs to reverse when it reaches max distance,
            -- but the horizontal offset can just keep trucking until it reaches
            -- the maximum negative distance.
            horizontal_offset = horizontal_offset - 1
            vertical_offset = vertical_offset + vertical_mod
            if vertical_offset == index then
                vertical_mod = -1
            end
        end
    end

    local random, sqrt = math.random, math.sqrt
    local spawn_location_count = #spawn_tile_xs
    if spawn_location_count < number_of_grazers then
        local max_spawn_width = MAX_CRYSTAL_DISTANCE_BY_STAGE[stage]
        while number_of_grazers > 0 do
            local spawn_width = MIN_CRYSTAL_DISTANCE + sqrt(random()) * (max_spawn_width - MIN_CRYSTAL_DISTANCE)
            local spawn_angle = PI2*random()

            local sx = px + spawn_width * math.cos(spawn_angle)
            local sz = pz + spawn_width * math.sin(spawn_angle)
            spawn_grazer(inst, sx, sz, 1 + 10*random())

            number_of_grazers = number_of_grazers - 1
        end
    else
        local terraformer = inst._terraformer
        while number_of_grazers > 0 do
            local random_index = random(spawn_location_count)
            local spawn_tilex, spawn_tiley = spawn_tile_xs[random_index], spawn_tile_ys[random_index]
            local spawn_x, _, spawn_z = _map:GetTileCenterPoint(spawn_tilex, spawn_tiley)

            local spawn_time = 0
            if terraformer then
                spawn_time = terraformer:TaskTimeForTile(spawn_tilex, spawn_tiley)
            end
            spawn_grazer(inst,
                GetRandomWithVariance(spawn_x, 1.2),
                GetRandomWithVariance(spawn_z, 1.2),
                spawn_time + 1 + 4*random()
            )

            number_of_grazers = number_of_grazers - 1
        end
    end
end

--------------------------------------------------------------------------------
local function setmaxminimapstatus(inst)
    inst.MiniMapEntity:SetIcon("lunarrift_portal_max.png")
    inst.icon_max = true
end

--------------------------------------------------------------------------------
local function do_stage_up(inst)
    if inst._stage < TUNING.RIFT_LUNAR1_MAXSTAGE then
        local next_stage = inst._stage + 1
        inst._stage = next_stage

        inst.AnimState:PlayAnimation("stage_"..next_stage.."_appear")
        inst.AnimState:PushAnimation("stage_"..next_stage.."_loop", true)

        inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, AMBIENT_SOUND_STAGE_TO_INTENSITY[next_stage])
        inst.SoundEmitter:PlaySound("rifts/portal/rift_explode")

        if inst.shadow then
            local new_scale = SHADOW_SCALE_BY_STAGE[next_stage]
            inst.shadow.AnimState:SetScale(new_scale, new_scale)
            inst.shadow.AnimState:PlayAnimation("shadow_appear")
            inst.shadow.AnimState:PushAnimation("shadow", true)
        end
        inst.Light:SetRadius(LIGHT_SCALE_BY_STAGE_CONSTANT * inst._stage)

        if next_stage < TUNING.RIFT_LUNAR1_MAXSTAGE then
            if not inst.components.timer:TimerExists("trynextstage") then
                inst.components.timer:StartTimer("trynextstage", TUNING.RIFT_LUNAR1_STAGEUP_BASE_TIME + TUNING.RIFT_LUNAR1_STAGEUP_RANDOM_TIME * math.random())
            end
        else
            inst.components.timer:StopTimer("trynextstage")
        end

        inst.components.groundpounder.numRings = next_stage*2
        inst.components.groundpounder:GroundPound()

        local portal_position = inst:GetPosition()
        try_spawn_crystals(inst, portal_position, next_stage)
        do_portal_tiles(inst, portal_position, next_stage)
        try_spawn_grazers(inst, portal_position, next_stage)

        if next_stage == TUNING.RIFT_LUNAR1_MAXSTAGE then
            setmaxminimapstatus(inst)
            TheWorld:PushEvent("ms_lunarrift_maxsize", inst)
        end
    else
        inst.AnimState:PlayAnimation("stage_"..inst._stage.."_loop", true)
    end
end

local function try_stage_up(inst, force_finish_terraforming)
    if inst._stage < TUNING.RIFT_LUNAR1_MAXSTAGE then
        inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, 0.0)
        inst.SoundEmitter:PlaySound("rifts/portal/rift_explode_buildup")

        inst.AnimState:PlayAnimation("stage_"..inst._stage.."_disappear")
        if inst.shadow then
            inst.shadow.AnimState:PlayAnimation("shadow_disappear")
        end

        inst.components.timer:StopTimer("do_stageup")
        inst.components.timer:StartTimer("do_stageup", STAGEUP_TIME)

        if force_finish_terraforming then
            inst.components.timer:StopTimer("do_forcefinishterraforming")
            inst.components.timer:StartTimer("do_forcefinishterraforming", STAGEUP_TIME + FRAMES)
        end
    end
end

--------------------------------------------------------------------------------
local function OnPortalGroundPound(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.5, 0.025, 1.0, inst, 30)
end

--------------------------------------------------------------------------------
local function on_timer_done(inst, data)
    -- If we're in the process of phasing out, don't fire any timers.
    if inst._finished then
        return
    end

    if data.name == "initialize" then
        local portal_position = inst:GetPosition()
        do_portal_tiles(inst, portal_position, inst._stage)
        try_spawn_grazers(inst, portal_position, inst._stage)
    elseif data.name == "trynextstage" then
        inst:TryStageUp()
    elseif data.name == "do_stageup" then
        do_stage_up(inst)
    elseif data.name == "do_forcefinishterraforming" then
        inst:ForceFinishTerraforming(inst)
    elseif data.name == "try_crystals" then
        try_spawn_crystals(inst)
    end
end

--------------------------------------------------------------------------------
local function on_portal_removed(inst)
    local _map = TheWorld.Map
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local portal_tile_x, portal_tile_y = _map:GetTileCoordsAtPoint(ix, iy, iz)

    if inst._terraformer ~= nil then
        inst._terraformer:OnParentRemoved()
        if inst._terraformer.components.timer then
            inst._terraformer.components.timer:StopTimer("remove")
        end
    end

    inst._terraformer = inst._terraformer or make_terraformer_proxy(inst, ix, iy, iz)
    inst._terraformer:AddTerraformTask(portal_tile_x, portal_tile_y, 0, {0, 0}, true)

    local maxdelay = 0
    local current_portal_radius = TILE_WIDTH_BY_STAGE[inst._stage]
    for index = 1, current_portal_radius do
        local horizontal_offset, vertical_offset = index, 0
        local vertical_mod = 1
        local base_time_delay = (current_portal_radius - index - 1)

        while horizontal_offset > -index do
            local delay = (base_time_delay + 0.5*math.random()) * 2.0
            maxdelay = math.max(maxdelay, delay)
            inst._terraformer:AddTerraformTask(
                portal_tile_x + horizontal_offset,
                portal_tile_y + vertical_offset,
                delay,
                {horizontal_offset, vertical_offset},
                true
            )
            delay = (base_time_delay + 0.5*math.random()) * 2.0
            maxdelay = math.max(maxdelay, delay)
            inst._terraformer:AddTerraformTask(
                portal_tile_x - horizontal_offset,
                portal_tile_y - vertical_offset,
                delay,
                {horizontal_offset, vertical_offset},
                true
            )

            horizontal_offset = horizontal_offset - 1
            vertical_offset = vertical_offset + vertical_mod
            if vertical_offset == index then
                vertical_mod = -1
            end
        end
    end

    maxdelay = maxdelay + 0.1
    if inst._terraformer.components.timer then
        inst._terraformer.components.timer:StartTimer("remove", maxdelay)
    end

    if inst._crystals then
        for crystal in pairs(inst._crystals) do
            crystal.components.timer:StartTimer("do_deterraform_cleanup", (current_portal_radius - 0.5) * 2.0)
        end
    end

    TheWorld:PushEvent("ms_lunarportal_removed",inst)
end

local function on_rift_finished(inst)
    if inst:IsAsleep() then
        inst:Remove() -- Remove immediately if there is no one around to see it.
    else
        inst.AnimState:PlayAnimation("stage_3_disappear")
        inst.SoundEmitter:PlaySound("rifts/portal/portal_disappear")
        if inst.shadow then
            inst.shadow.AnimState:PlayAnimation("shadow_disappear")
        end
        inst:ListenForEvent("animover", inst.Remove)
        inst:DoTaskInTime(10, inst.Remove) -- Fallback in case the animation does not finish for any reason make the portal go away.
    end

    inst._finished = true
end

--------------------------------------------------------------------------------
local GRAZER_MUST_TAGS = {"lunar_aligned", "NOCLICK"} -- Hiding/pre-spawn grazers have NOCLICK
local function portal_forcefinishterraforming(inst)
    if inst._terraformer then
        inst._terraformer:PushEvent("forcefinishterraforming")
    end

    if inst._crystals and next(inst._crystals) then
        for crystal in pairs(inst._crystals) do
            crystal:PushEvent("docrystalspawnin", 0)
        end
    end

    local terraformed_distance = TILE_WIDTH_BY_STAGE[inst._stage] * TILE_SCALE
    local px, py, pz = inst.Transform:GetWorldPosition()
    local pre_spawn_grazers = TheSim:FindEntities(px, py, pz, terraformed_distance, GRAZER_MUST_TAGS)
    for _, grazer in ipairs(pre_spawn_grazers) do
        grazer.sg:GoToState("spawndelay", 1 + 4*math.random())
    end
end

--------------------------------------------------------------------------------
local function on_portal_sleep(inst)
    inst.SoundEmitter:KillSound(AMBIENT_SOUND_LOOP_NAME)
end

local function on_portal_wake(inst)
    inst.SoundEmitter:PlaySound("rifts/portal/rift_portal_allstage", AMBIENT_SOUND_LOOP_NAME)
    inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, AMBIENT_SOUND_STAGE_TO_INTENSITY[inst._stage])
end

--------------------------------------------------------------------------------
local function on_portal_save(inst, data)
    data.stage = inst._stage

    -- We can't just flag with persists = false, because we need to fire the onremove listener to clean up the area.
    data.finished = inst._finished

    local entity_guids

    -- Save our crystals's GUIDs so we can rebuild our crystal reference table,
    -- and re-setup our onwork and onremove callbacks post-load.
    if GetTableSize(inst._crystals) > 0 then
        entity_guids = entity_guids or {}
        data.crystals = {}
        for crystal, valid in pairs(inst._crystals) do
            if valid then
                table.insert(entity_guids, crystal.GUID)
                table.insert(data.crystals, crystal.GUID)
            end
        end
    end

    if inst._terraformer then
        entity_guids = entity_guids or {}
        data.terraformer_guid = inst._terraformer.GUID
        table.insert(entity_guids, data.terraformer_guid)
    end

    return entity_guids
end

local function on_portal_load(inst, data)
    if data then
        inst._stage = data.stage or inst._stage
        if inst._stage >= TUNING.RIFT_LUNAR1_MAXSTAGE then
            inst.components.timer:StopTimer("trynextstage")
        end

        -- Re-load our presentation state
        if inst.shadow then
            local new_scale = SHADOW_SCALE_BY_STAGE[inst._stage]
            inst.shadow.AnimState:SetScale(new_scale, new_scale)
        end
        inst.Light:SetRadius(LIGHT_SCALE_BY_STAGE_CONSTANT * inst._stage)

        if data.finished then
            inst:DoTaskInTime(0, on_rift_finished) -- NOTES(JBK): Delay a frame so the rift can be added into the pool in time for riftspawner component.
        else
            inst.AnimState:PlayAnimation("stage_"..inst._stage.."_loop", true)
        end
    end
end

local function on_portal_load_postpass(inst, newents, data)
    if data then
        local crystals = data.crystals
        if crystals and #crystals > 0 then
            for _, crystalGUID in ipairs(crystals) do
                local crystal_data = newents[crystalGUID]
                if crystal_data then
                    inst:TrackCrystal(crystal_data.entity)
                end
            end
        end

        local terraformerGUID = data.terraformer_guid
        if terraformerGUID then
            local terraformer_entdata = newents[terraformerGUID]
            if terraformer_entdata then
                inst._terraformer = terraformer_entdata.entity
            end
        end
    end

    -- If we're loading anything, stop our timer
    inst.components.timer:StopTimer("initialize")
    inst.SoundEmitter:KillSound(AMBIENT_SOUND_LOOP_NAME)
    if not inst:IsAsleep() then
        inst.SoundEmitter:PlaySound("rifts/portal/rift_portal_allstage", AMBIENT_SOUND_LOOP_NAME)
        inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, AMBIENT_SOUND_STAGE_TO_INTENSITY[inst._stage])
    end

    if inst._stage == TUNING.RIFT_LUNAR1_MAXSTAGE then
        setmaxminimapstatus(inst)
        TheWorld:PushEvent("ms_lunarrift_maxsize", inst)
    end
end


local function do_marker_minimap_swap(inst)
    inst.marker_index = inst.marker_index == nil and 0 or ((inst.marker_index + 1) % 4)
    
    local max = ""
    if inst.icon_max then
        max = "_max"
    end

    local marker_image = "lunarrift_portal"..max..(inst.marker_index +1)..".png"  --_max

    --inst.MiniMapEntity:SetIcon(marker_image)
    inst.icon.MiniMapEntity:SetIcon(marker_image)
end

local function show_minimap(inst)
    -- Create a global map icon so the minimap icon is visible to other players as well.
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon:TrackEntity(inst)
    inst.icon.MiniMapEntity:SetPriority(21)

    inst:DoPeriodicTask(TUNING.STORM_SWAP_TIME, do_marker_minimap_swap)
end


--------------------------------------------------------------------------------
local function portalfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("lunarrift_portal.png")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetPriority(22)

    inst.AnimState:SetBank ("lunar_rift_portal")
    inst.AnimState:SetBuild("lunar_rift_portal")
    inst.AnimState:AddOverrideBuild("lunar_rift_portal_small")
    inst.AnimState:PlayAnimation("stage_1_appear")
    inst.AnimState:PushAnimation("stage_1_loop", true)

    inst.scrapbook_anim = "stage_3_loop"
    inst.scrapbook_nodamage = true
    inst.scrapbook_specialinfo = "LUNARRIFTPORTAL"

    inst.AnimState:SetLightOverride(1)

    inst.Light:SetIntensity(0.7)
    inst.Light:SetRadius(LIGHT_SCALE_BY_STAGE_CONSTANT)
    inst.Light:SetFalloff(0.8)
    inst.Light:SetColour(119/255, 255/255, 255/255)
    inst.Light:Enable(true)

    inst:AddTag("birdblocker")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("notarget")
    inst:AddTag("NOBLOCK")
    inst:AddTag("scarytoprey")
    inst:AddTag("lunarrift_portal")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- Set up proxy shadow
    inst.shadow = SpawnPrefab("lunarrift_portal_shadow")
    inst.shadow.entity:SetParent(inst.entity)
    inst.shadow.Transform:SetPosition(0,0,0)
    local initial_shadow_scale = SHADOW_SCALE_BY_STAGE[1]
    inst.shadow.AnimState:SetScale(initial_shadow_scale, initial_shadow_scale)

    ----------------------------------------------------------
    inst._stage = 1
    inst._crystals = {}

    ----------------------------------------------------------
    inst.TryStageUp = try_stage_up
    inst.TrackCrystal = track_crystal
    inst.ForceFinishTerraforming = portal_forcefinishterraforming

    ----------------------------------------------------------
    inst._on_crystal_removed = function(crystal)
        inst._crystals[crystal] = nil
    end

    ----------------------------------------------------------
    local combat = inst:AddComponent("combat")
    combat:SetDefaultDamage(TUNING.RIFT_LUNAR1_GROUNDPOUND_DAMAGE)
    combat.playerdamagepercent = 0.5    

    ----------------------------------------------------------
    local groundpounder = inst:AddComponent("groundpounder")
    table.insert(groundpounder.noTags, "lunar_aligned")
	groundpounder:UseRingMode()
    groundpounder.damageRings = 6
    groundpounder.destructionRings = 0
    groundpounder.platformPushingRings = 6
    groundpounder.inventoryPushingRings = 6
    groundpounder.numRings = 1
    groundpounder.groundpoundFn = OnPortalGroundPound

    ----------------------------------------------------------
    inst:AddComponent("inspectable")

    ----------------------------------------------------------
    local timer = inst:AddComponent("timer")
    timer:StartTimer("initialize", 0)
    timer:StartTimer("trynextstage", TUNING.RIFT_LUNAR1_STAGEUP_BASE_TIME + TUNING.RIFT_LUNAR1_STAGEUP_RANDOM_TIME * math.random())

    ----------------------------------------------------------
    inst:ListenForEvent("timerdone", on_timer_done)
    inst:ListenForEvent("onremove", on_portal_removed)
    inst:ListenForEvent("finish_rift", on_rift_finished)

    ----------------------------------------------------------
    inst.OnEntitySleep = on_portal_sleep
    inst.OnEntityWake = on_portal_wake
    inst.OnSave = on_portal_save
    inst.OnLoad = on_portal_load
    inst.OnLoadPostPass = on_portal_load_postpass

    inst:DoTaskInTime(0, show_minimap)

    return inst
end

--------------------------------------------------------------------------------
local function portal_shadow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    local anim_state = inst.AnimState
    anim_state:SetBank ("lunar_rift_portal")
    anim_state:SetBuild("lunar_rift_portal")
    anim_state:AddOverrideBuild("lunar_rift_portal_small")
    anim_state:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    anim_state:SetLayer(LAYER_BACKGROUND)
    anim_state:PlayAnimation("shadow_appear")
    anim_state:PushAnimation("shadow", true)

    inst.Transform:SetRotation(90)

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismasersim then
        return inst
    end

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------------

local rift_portal_defs = require("prefabs/rift_portal_defs")
local RIFTPORTAL_FNS = rift_portal_defs.RIFTPORTAL_FNS
local RIFTPORTAL_CONST = rift_portal_defs.RIFTPORTAL_CONST
rift_portal_defs = nil

RIFTPORTAL_FNS.CreateRiftPortalDefinition("lunarrift_portal", {
    CustomAllowTest = function(_map, x, y, z)
        return _map:FindVisualNodeAtPoint(x, y, z, "not_mainland") == nil -- Only mainland.
    end,
    Affinity = RIFTPORTAL_CONST.AFFINITY.LUNAR,
})

return Prefab("lunarrift_portal", portalfn, assets, prefabs),
    Prefab("lunarrift_portal_shadow", portal_shadow_fn, assets)