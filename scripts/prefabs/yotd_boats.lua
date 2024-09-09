require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/boat_yotd.zip"),
    Asset("MINIMAP_IMAGE", "boat_yotd"),
}

local pack_assets =
{
    Asset("ANIM", "anim/dragonboat_race_pack.zip"),
    Asset("INV_IMAGE", "dragonboat_pack"),
}

local item_assets =
{
    Asset("ANIM", "anim/boat_yotd_kit.zip"),
    Asset("ANIM", "anim/seafarer_boat.zip"),
    Asset("INV_IMAGE", "boat_yotd_item"),
}

local prefabs =
{
    "dragonboat_item_collision",
    "dragonboat_player_collision",

    "walkingplank_yotd",
}

local shadowboat_prefabs =
{
    "boatrace_primemate",

    "dragonboat_shadowboat_deploy_blocker",

    "walkingplank_yotd",
}

local item_prefabs =
{
    "dragonboat_body",
}

local pack_prefabs =
{
    "dragonboat_body",
    "mast_yotd",
    "yotd_anchor",
    "yotd_oar",
    "yotd_steeringwheel",
    "boat_bumper_yotd",
}

local sounds = {
    place = "turnoftides/common/together/boat/place",
    creak = "turnoftides/common/together/boat/creak",
    damage = "turnoftides/common/together/boat/damage",
    sink = "turnoftides/common/together/boat/sink",
    hit = "turnoftides/common/together/boat/hit",
    thunk = "turnoftides/common/together/boat/thunk",
    movement = "turnoftides/common/together/boat/movement",
}

-- Common (client-side) functions

local RETICULE_RANGE = 7
local function ReticuleTargetFn(inst)
    local direction = Vector3(
        TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT),
        0,
        TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    )
    local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS

    if math.abs(direction.x) >= deadzone or math.abs(direction.z) > deadzone then
        direction:Normalize()
        inst.lastreticuleangle = direction
    else
        if inst.lastreticuleangle then
            direction = inst.lastreticuleangle
        else
            return nil
        end
    end

    local camera_angle = TheCamera:GetHeading() / 180

    local theta = PI * (camera_angle - 0.5)
    local costheta, sintheta = math.cos(theta), math.sin(theta)
    local new_position_offset_vector = Vector3(
        (direction.x * costheta) - (direction.z * sintheta),
        0,
        (direction.x * sintheta) + (direction.z * costheta)
    )

    return inst:GetPosition() - (new_position_offset_vector * RETICULE_RANGE)
end

local function start_steering_reticule(inst, event_data)
    if ThePlayer and ThePlayer == event_data.player then
        local ThePlayer_playercontroller = ThePlayer.components.playercontroller
        if ThePlayer_playercontroller and ThePlayer_playercontroller.isclientcontrollerattached then
            inst.components.reticule:CreateReticule()
        end
    end
end

local function end_steering_reticule(inst, event_data)
    if ThePlayer and ThePlayer == event_data.player then
        local ThePlayer_playercontroller = ThePlayer.components.playercontroller
        if ThePlayer_playercontroller and ThePlayer_playercontroller.isclientcontrollerattached then
            inst.lastreticuleangle = nil
            inst.components.reticule:DestroyReticule()
        end
    end
end

local function OnEntityReplicated(inst)
    --Use this setting because we can rotate, and we are not billboarded with discreet anim facings
    --NOTE: this setting can only be applied after entity replicated
    inst.Transform:SetInterpolateRotation(true)
end

local function dragonboat_common(inst, boat_data)
    boat_data = boat_data or {}

    local radius = boat_data.radius or TUNING.DRAGON_BOAT_RADIUS

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("boat_yotd.png")
    inst.MiniMapEntity:SetPriority(-1)
    inst.entity:AddNetwork()

    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("boat")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("wood")

    local Physics = inst.entity:AddPhysics()
    Physics:SetMass(TUNING.BOAT.MASS)
    Physics:SetFriction(0)
    Physics:SetDamping(5)
    Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    Physics:ClearCollisionMask()
    Physics:CollidesWith(COLLISION.WORLD)
    Physics:CollidesWith(COLLISION.OBSTACLES)
    Physics:SetCylinder(radius, 3)
    Physics:SetDontRemoveOnSleep(true)

    inst.AnimState:SetBank(boat_data.bank)
    inst.AnimState:SetBuild(boat_data.build)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.scrapbook_anim = "idle_full"
    inst.scrapbook_inspectonseen = true

    if boat_data.scale then
        inst.AnimState:SetScale(boat_data.scale, boat_data.scale, boat_data.scale)
    end

    --
    local walkableplatform = inst:AddComponent("walkableplatform")
    walkableplatform.platform_radius = radius
    walkableplatform.player_collision_prefab = "dragonboat_player_collision"

    --
    local healthsyncer = inst:AddComponent("healthsyncer")
    healthsyncer.max_health = boat_data.max_health or TUNING.BOAT.HEALTH

    --
    local waterphysics = inst:AddComponent("waterphysics")
    waterphysics.restitution = 0.75

    --
    local reticule = inst:AddComponent("reticule")
    reticule.targetfn = ReticuleTargetFn
    reticule.ispassableatallpoints = true

    --
    inst.doplatformcamerazoom = net_bool(inst.GUID, "doplatformcamerazoom", "doplatformcamerazoomdirty")

    inst.walksound = "wood"

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("endsteeringreticule", end_steering_reticule)
        inst:ListenForEvent("starsteeringreticule", start_steering_reticule)

        inst:AddComponent("boattrail")
    end

    local boatringdata = inst:AddComponent("boatringdata")
    boatringdata:SetRadius(radius)
    boatringdata:SetNumSegments(4)

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
    end

    return inst
end

-- Server-side functions -------------------------------------------------------------------------------------
local function RemoveConstrainedPhysicsObject(physics_object)
    if physics_object:IsValid() then
        physics_object.Physics:ConstrainTo(nil)
        physics_object:Remove()
    end
end

local function constrain_boat_item_collision(inst, boat_item_collision)
    boat_item_collision.Transform:SetPosition(inst.Transform:GetWorldPosition())
    boat_item_collision.Physics:ConstrainTo(inst.entity)
end

local function EnableBoatItemCollision(inst)
    if inst.boat_item_collision then return end

    inst.boat_item_collision = SpawnPrefab("dragonboat_item_collision")
    inst.boat_item_collision:ListenForEvent("onremove",
        function() RemoveConstrainedPhysicsObject(inst.boat_item_collision) end,
        inst
    )
    inst:DoTaskInTime(0, constrain_boat_item_collision, inst.boat_item_collision)
end

local function DisableBoatItemCollision(inst)
    if inst.boat_item_collision then
        RemoveConstrainedPhysicsObject(inst.boat_item_collision)
        inst.boat_item_collision = nil
    end
end

local function StartBoatPhysics(inst)
    inst.Physics:SetDontRemoveOnSleep(true)
end

local function StopBoatPhysics(inst)
    inst.Physics:SetDontRemoveOnSleep(false)
end

local function stop_updating_callback(inst)
    inst.components.walkableplatform:StopUpdating()
    inst.stopupdatingtask = nil
end
local function OnPhysicsSleep(inst)
    DisableBoatItemCollision(inst)
    inst.stopupdatingtask = inst:DoTaskInTime(1, stop_updating_callback)
    inst.components.boatphysics:StopUpdating()
end

local function OnPhysicsWake(inst)
    EnableBoatItemCollision(inst)
    if inst.stopupdatingtask then
        inst.stopupdatingtask:Cancel()
        inst.stopupdatingtask = nil
    else
        inst.components.walkableplatform:StartUpdating()
    end
    inst.components.boatphysics:StartUpdating()
end

--
local BOATBUMPER_MUST_TAGS = { "boatbumper" }
local function OnLoadPostPass(inst)
    local boatring = inst.components.boatring
    if not boatring then
        return
    end

    -- If cannons and bumpers are on a boat, we need to rotate them to account for the boat's rotation
    local x, y, z = inst:GetPosition():Get()

    -- Bumpers
    local bumpers = TheSim:FindEntities(x, y, z, boatring:GetRadius(), BOATBUMPER_MUST_TAGS)
    for _, bumper in ipairs(bumpers) do
        -- Add to boat bumper list for future reference
        table.insert(boatring.boatbumpers, bumper)

        local bumperx, bumpery, bumperz = bumper.Transform:GetWorldPosition()
        local angle = GetAngleFromBoat(inst, bumperx, bumperz) * RADIANS

        if angle then
            -- Need to further rotate the bumpers to account for the boat's rotation
            bumper.Transform:SetRotation(90 - angle)
        end
    end
end

local PLANK_OFFSET = 0.05
local function empty_loot_function() end

local function OnSpawnNewBoatLeak(inst, data)
    if data == nil or data.pt == nil then return end

    data.pt.y = 0

    local leak = SpawnPrefab("boat_leak")
    leak.Transform:SetPosition(data.pt:Get())
    leak.components.boatleak.isdynamic = true
    leak.components.boatleak:SetBoat(inst)
    leak.components.boatleak:SetState(data.leak_size)

    table.insert(inst.components.hullhealth.leak_indicators_dynamic, leak)

    if inst.components.walkableplatform then
        inst.components.walkableplatform:AddEntityToPlatform(leak)
        for player in pairs(inst.components.walkableplatform:GetPlayersOnPlatform()) do
            if player:IsValid() then
                player:PushEvent("on_standing_on_new_leak")
            end
        end
    end

    if data.playsoundfx then
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, { intensity = 0.8 })
    end
end

local function InstantlyBreakBoat(inst)
    -- This is not for SGboat but is for safety on physics.
    if inst.components.boatphysics then
        inst.components.boatphysics:SetHalting(true)
    end

    -- Keep this in sync with SGboat. Make sure that everybody gets the abandon_ship
    -- message before they get the onpresink message
    for k in pairs(inst.components.walkableplatform:GetEntitiesOnPlatform()) do
        k:PushEvent("abandon_ship")
    end
    for k in pairs(inst.components.walkableplatform:GetPlayersOnPlatform()) do
        k:PushEvent("onpresink")
    end

    inst:sinkloot()
    if inst.postsinkfn then
        inst:postsinkfn()
    end

    inst:Remove()
end

local function GetSafePhysicsRadius(inst)
    return (inst.components.hull and inst.components.hull:GetRadius() or TUNING.DRAGON_BOAT_RADIUS)
        + 0.18 -- Add a small offset for item overhangs.
end
local BOAT_COLLISION_SEGMENT_COUNT = 20
local function IsBoatEdgeOverLand(inst, override_position_pt)
    local map = TheWorld.Map
    local radius = inst:GetSafePhysicsRadius()
    local segment_count = BOAT_COLLISION_SEGMENT_COUNT * 2
    local segment_span = math.pi * 2 / segment_count
    local x, y, z
    if override_position_pt then
        x, y, z = override_position_pt:Get()
    else
        x, y, z = inst.Transform:GetWorldPosition()
    end
    for segement_idx = 0, segment_count do
        local angle = segement_idx * segment_span

        local angle0 = angle - segment_span / 2
        local x0 = math.cos(angle0) * radius
        local z0 = math.sin(angle0) * radius
        if not map:IsOceanTileAtPoint(x + x0, 0, z + z0) or map:IsVisualGroundAtPoint(x + x0, 0, z + z0) then
            return true
        end

        local angle1 = angle + segment_span / 2
        local x1 = math.cos(angle1) * radius
        local z1 = math.sin(angle1) * radius
        if not map:IsOceanTileAtPoint(x + x1, 0, z + z1) or map:IsVisualGroundAtPoint(x + x1, 0, z + z1) then
            return true
        end
    end

    return false
end

local function dragonboat_server(inst, boat_data)
    boat_data = boat_data or {}

    local radius = boat_data.radius or TUNING.DRAGON_BOAT_RADIUS

    inst.sounds = sounds
    inst.boat_crackle = "fx_boat_crackle"

	inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak)

    inst.Physics:SetDontRemoveOnSleep(true)
    inst.item_collision_prefab = boat_data.item_collision_prefab
    EnableBoatItemCollision(inst)

    inst.entity:AddPhysicsWaker() --server only component
    inst.PhysicsWaker:SetTimeBetweenWakeTests(TUNING.BOAT.WAKE_TEST_TIME)

    local hull = inst:AddComponent("hull")
    hull:SetRadius(radius)

    if boat_data.boatlip_prefab then
        hull:SetBoatLip(SpawnPrefab(boat_data.boatlip_prefab), boat_data.scale or 1.0)
    end

    if boat_data.plank_prefab then
        local walking_plank = SpawnPrefab(boat_data.plank_prefab)
        local plank_angle, plank_radius = 0.75*PI, radius + PLANK_OFFSET
        hull:AttachEntityToBoat(
            walking_plank,
            plank_radius * math.cos(plank_angle),
            plank_radius * math.sin(plank_angle),
            true
        )
        walking_plank.Transform:SetRotation(-45)
        hull:SetPlank(walking_plank)
    end

    if not boat_data.fireproof then
        inst.activefires = 0

        local burnable_locator = SpawnPrefab("burnable_locator_medium")
        burnable_locator.boat = inst
        hull:AttachEntityToBoat(burnable_locator, 0, 0, true)

        burnable_locator = SpawnPrefab("burnable_locator_medium")
        burnable_locator.boat = inst
        hull:AttachEntityToBoat(burnable_locator, 2.5, 0, true)

        burnable_locator = SpawnPrefab("burnable_locator_medium")
        burnable_locator.boat = inst
        hull:AttachEntityToBoat(burnable_locator, -2.5, 0, true)

        burnable_locator = SpawnPrefab("burnable_locator_medium")
        burnable_locator.boat = inst
        hull:AttachEntityToBoat(burnable_locator, 0, 2.5, true)

        burnable_locator = SpawnPrefab("burnable_locator_medium")
        burnable_locator.boat = inst
        hull:AttachEntityToBoat(burnable_locator, 0, -2.5, true)
    end

    --
    local repairable = inst:AddComponent("repairable")
    repairable.repairmaterial = MATERIALS.WOOD

    --
    inst:AddComponent("boatring")

    --
    local hullhealth = inst:AddComponent("hullhealth")
    hullhealth.leak_radius = 0.6 * TUNING.DRAGON_BOAT_RADIUS
    hullhealth.leak_radius_variance = 0.3 * TUNING.DRAGON_BOAT_RADIUS

    --
    inst:AddComponent("boatphysics")
    inst:AddComponent("boatdrifter")
    inst:AddComponent("savedrotation")

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(boat_data.max_health or TUNING.BOAT.HEALTH)
    health.nofadeout = true

    --
    inst:SetStateGraph(boat_data.stategraph or "SGboat")

    inst.StartBoatPhysics = StartBoatPhysics
    inst.StopBoatPhysics = StopBoatPhysics

    inst.OnPhysicsWake = OnPhysicsWake
    inst.OnPhysicsSleep = OnPhysicsSleep

    inst.sinkloot = empty_loot_function
    inst.InstantlyBreakBoat = InstantlyBreakBoat
    inst.GetSafePhysicsRadius = GetSafePhysicsRadius
    inst.IsBoatEdgeOverLand = IsBoatEdgeOverLand

    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function spawn_boat_pack_pieces(inst)
    local random, sqrt, sin, cos = math.random, math.sqrt, math.sin, math.cos

    local body_position = inst:GetPosition()

    local mast = SpawnPrefab("mast_yotd")
    mast.Transform:SetPosition(body_position:Get())
    mast:PushEvent("onbuilt")

    local object_angle = TWOPI * random()
    -- Trying to aim at 20-80% of the boat radius. Away from the middle, and a bit away from the edge.
    local object_distance = (0.20 + 0.65 * sqrt(random())) * TUNING.DRAGON_BOAT_RADIUS
    local anchor = SpawnPrefab("yotd_anchor")
    anchor.Transform:SetPosition(
        body_position.x + object_distance * cos(object_angle),
        0,
        body_position.z + object_distance * sin(object_angle)
    )
    anchor:PushEvent("onbuilt")

    object_angle = object_angle + PI * GetRandomWithVariance(1, 0.25)
    object_distance = (0.20 + 0.65 * sqrt(random())) * TUNING.DRAGON_BOAT_RADIUS
    local steeringwheel = SpawnPrefab("yotd_steeringwheel")
    steeringwheel.Transform:SetPosition(
        body_position.x + object_distance * cos(object_angle),
        0,
        body_position.z + object_distance * sin(object_angle)
    )
    steeringwheel:PushEvent("onbuilt")

    local offset_for_oar = PI * GetRandomWithVariance(0.5, 0.1)
    object_angle = object_angle + (random() > 0.5 and offset_for_oar or -offset_for_oar)
    object_distance = (0.20 + 0.65 * sqrt(random())) * TUNING.DRAGON_BOAT_RADIUS
    local oar = SpawnPrefab("yotd_oar")
    oar.Transform:SetPosition(
        body_position.x + object_distance * cos(object_angle),
        0,
        body_position.z + object_distance * sin(object_angle)
    )
end

local function OnBodyLoad(inst, data)
    if inst._spawn_boat_pieces_task then
        inst._spawn_boat_pieces_task:Cancel()
        inst._spawn_boat_pieces_task = nil
    end
end

local function body_fn()
    local data =
    {
        bank = "boat_yotd",
        build = "boat_yotd",
        boatlip_prefab = "boatlip_yotd",
        plank_prefab = "walkingplank_yotd",
    }

    local inst = dragonboat_common(CreateEntity(), data)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = dragonboat_server(inst, data)

    inst.OnLoad = OnBodyLoad

    return inst
end

-- AI Shadowboat definition
local function spawn_ai_captain(inst, position)
    local team_captain = SpawnPrefab("boatrace_primemate")
    team_captain.Transform:SetPosition(position:Get())
    local crewmember = team_captain:AddComponent("crewmember")
    crewmember.max_target_dsq = (TUNING.BOATRACE_DEFAULT_PROXIMITY * TUNING.BOATRACE_DEFAULT_PROXIMITY) - 1.0
    inst.components.boatracecrew:AddMember(team_captain, true)
end

local function spawn_shadowboat_pieces(inst)
    local body_position = inst:GetPosition()
    local angle = TWOPI * math.random()
    local deploy_offset = Vector3(math.cos(angle), 0, math.sin(angle)):GetNormalized() * TUNING.DRAGON_BOAT_RADIUS * 0.2

    spawn_ai_captain(inst, (body_position + deploy_offset))

    SpawnPrefab("dragonboat_shadowboat_deploy_blocker").Transform:SetPosition(body_position:Get())
end

local function OnShadowboatLoad(inst, data)
    if inst._spawn_shadowboat_pieces_task then
        inst._spawn_shadowboat_pieces_task:Cancel()
        inst._spawn_shadowboat_pieces_task = nil
    end
end

local function shadowboat_fn()
    local data =
    {
        bank = "boat_yotd",
        build = "boat_yotd",
        boatlip_prefab = "boatlip_yotd",
        plank_prefab = "walkingplank_yotd",
    }

    local inst = dragonboat_common(CreateEntity(), data)

	inst:AddComponent("platformhopdelay")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst = dragonboat_server(inst, data)

    inst:AddComponent("boatracecrew")

    inst._spawn_shadowboat_pieces_task = inst:DoTaskInTime(0.5, spawn_shadowboat_pieces)

    inst.OnLoad = OnShadowboatLoad

    return inst
end

-- Item functions

local EXTRA_SPACING = 0.2
local function CLIENT_CanDeployDragonBoat(inst, pt, mouseover, deployer, rotation)
    return TheWorld.Map:CanDeployBoatAtPointInWater(pt, inst, mouseover,
    {
        boat_radius = TUNING.DRAGON_BOAT_RADIUS + EXTRA_SPACING,
        boat_extra_spacing = EXTRA_SPACING,
        min_distance_from_land = EXTRA_SPACING,
    })
end

local function on_dragonboat_kit_deployed(inst, pt, deployer)
    local boat = SpawnPrefab(inst.deploy_product, inst.linked_skinname, inst.skin_id)
    if not boat then return end

    local boat_hull = boat.components.hull
    if boat.skinname and boat_hull and boat_hull.plank then
        if boat_hull.plank.prefab == "walkingplank_yotd" then
            local plank_skinname = "walkingplank_yotd" .. string.sub(boat.skinname, 5)
            TheSim:ReskinEntity( boat_hull.plank.GUID, nil, plank_skinname, boat.skin_id )
        end
    end

    boat.Physics:SetCollides(false)
    boat.Physics:Teleport(pt.x, 0, pt.z)
    boat.Physics:SetCollides(true)

    if boat.sg then boat.sg:GoToState("place") end

    boat.components.hull:OnDeployed()

    if inst.is_pack then
        boat._spawn_boat_pieces_task = boat:DoTaskInTime(1.0, spawn_boat_pack_pieces)
    end

    inst:Remove()
end

local function item_base_fn(data)
    local inst = CreateEntity()

    inst._custom_candeploy_fn = CLIENT_CanDeployDragonBoat
    inst._boat_radius = TUNING.DRAGON_BOAT_RADIUS
    inst.deploy_product = "dragonboat_body"

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("boatbuilder")
    inst:AddTag("usedeployspacingasoffset")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.bank)--"seafarer_boat")
    inst.AnimState:SetBuild(data.build or data.bank)--"boat_yotd_kit")
    inst.AnimState:PlayAnimation("IDLE")

    MakeInventoryFloatable(inst, "med", 0.25, 0.83)

    if data.common_positinit then
        data.common_positinit(inst)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    local deployable = inst:AddComponent("deployable")
    deployable.ondeploy = on_dragonboat_kit_deployed
    deployable:SetDeploySpacing(DEPLOYSPACING.LARGE)
    deployable:SetDeployMode(DEPLOYMODE.CUSTOM)

    --
    local fuel = inst:AddComponent("fuel")
    fuel.fuelvalue = TUNING.LARGE_FUEL

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("inventoryitem")
    if data.itemimagename then
        inst.components.inventoryitem:ChangeImageName(data.itemimagename)
    end

    --
    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)
    MakeHauntableLaunch(inst)

    --
    if data.server_postinit then
        data.server_postinit(inst)
    end

    return inst
end

-- Dragonboat kit
local DRAGONBOAT_KIT_DATA = {
    bank = "seafarer_boat",
    build = "boat_yotd_kit",
    itemimagename = "boat_yotd_item",
}
local function item_fn()
    return item_base_fn(DRAGONBOAT_KIT_DATA)
end

-- Dragonboat pack, with a boat and other things in it.
local DRAGONBOAT_PACK_DATA = {
    bank = "dragonboat_race_pack",
    build = "dragonboat_race_pack",
    itemimagename = "dragonboat_pack",
}
local function pack_fn()
    local inst = item_base_fn(DRAGONBOAT_PACK_DATA)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.is_pack = true

    return inst
end

-- Boat-To-Players collision
local COLLISION_SEGMENT_COUNT = 20
local SEGMENT_SPAN = TWOPI/COLLISION_SEGMENT_COUNT
local function build_boat_collision_mesh(radius, height)
    local triangles = {}
    local y0 = 0
    local y1 = height

    for segement_idx = 0, COLLISION_SEGMENT_COUNT do

        local angle = segement_idx * SEGMENT_SPAN
        local angle0 = angle - SEGMENT_SPAN / 2
        local angle1 = angle + SEGMENT_SPAN / 2

        local x0 = math.cos(angle0) * radius
        local z0 = math.sin(angle0) * radius

        local x1 = math.cos(angle1) * radius
        local z1 = math.sin(angle1) * radius

        table.insert(triangles, x0)
        table.insert(triangles, y0)
        table.insert(triangles, z0)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y1)
        table.insert(triangles, z1)
    end

    return triangles
end

local function dragonboat_player_collision_fn()
    local inst = CreateEntity()

    local radius = TUNING.DRAGON_BOAT_RADIUS

    inst.entity:AddTransform()

    local physics = inst.entity:AddPhysics()
    physics:SetMass(0)
    physics:SetFriction(0)
    physics:SetDamping(5)
    physics:SetCollisionGroup(COLLISION.BOAT_LIMITS)
    physics:ClearCollisionMask()
    physics:CollidesWith(COLLISION.CHARACTERS)
    physics:CollidesWith(COLLISION.WORLD)
    physics:SetTriangleMesh(build_boat_collision_mesh(radius + 0.1, 3))
    physics:SetDontRemoveOnSleep(true)

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

-- Boat-To-Items collision
local function dragonboat_item_collision_fn()
    local inst = CreateEntity()

    local radius = TUNING.DRAGON_BOAT_RADIUS

    inst.entity:AddTransform()

    local physics = inst.entity:AddPhysics()
    physics:SetMass(1000)
    physics:SetFriction(0)
    physics:SetDamping(5)
    physics:SetCollisionGroup(COLLISION.BOAT_LIMITS)
    physics:ClearCollisionMask()
    physics:CollidesWith(COLLISION.ITEMS)
    physics:CollidesWith(COLLISION.FLYERS)
    physics:CollidesWith(COLLISION.WORLD)
    physics:SetTriangleMesh(build_boat_collision_mesh(radius + 0.2, 3))

    -- Boats currently need to not go to sleep because constraints will cause a crash
    -- if either the target object or the source object is removed from the physics world.
    -- (While the above is still true, the constraint is now properly removed before despawning the object,
    -- and can be safely ignored for this object. This comment is kept for future copy/pasting)

    physics:SetDontRemoveOnSleep(true)

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

-- Deploy blocker for AI boats
local function shadowboat_deploy_blocker_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:SetDeployExtraSpacing(TUNING.DRAGON_BOAT_RADIUS + 0.1)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

--
return Prefab("dragonboat_body", body_fn, assets, prefabs),
    Prefab("dragonboat_kit", item_fn, item_assets, item_prefabs),
    MakePlacer("dragonboat_kit_placer", "boat_yotd", "boat_yotd", "idle_full", true, false, false, nil, nil, nil, ControllerPlacer_Boat_SpotFinder, 6),

    Prefab("dragonboat_pack", pack_fn, pack_assets, pack_prefabs),
    MakePlacer("dragonboat_pack_placer", "boat_yotd", "boat_yotd", "idle_full", true, false, false, nil, nil, nil, ControllerPlacer_Boat_SpotFinder, 6),

    Prefab("dragonboat_shadowboat", shadowboat_fn, assets, shadowboat_prefabs),
    Prefab("dragonboat_shadowboat_deploy_blocker", shadowboat_deploy_blocker_fn),

    Prefab("dragonboat_player_collision", dragonboat_player_collision_fn),
    Prefab("dragonboat_item_collision", dragonboat_item_collision_fn)
