-- ASSETS
local wood_assets =
{
    Asset("ANIM", "anim/boat_test.zip"),
    Asset("MINIMAP_IMAGE", "boat"),
}

local grass_assets =
{
    Asset("ANIM", "anim/boat_grass.zip"),
    Asset("MINIMAP_IMAGE", "boat_grass"),
}

local ice_assets =
{
    Asset("ANIM", "anim/boat_ice.zip"),
}

local pirate_assets =
{
    Asset("ANIM", "anim/boat_pirate.zip"),
    Asset("MINIMAP_IMAGE", "boat_pirate"),
}

local ancient_assets =
{
    Asset("ANIM", "anim/boat_ancient.zip"),
    Asset("ANIM", "anim/boat_yotd.zip"),
    Asset("ANIM", "anim/boat_leak_ancient_build.zip"),
}

local otterden_assets =
{
    Asset("ANIM", "anim/boat_otterden.zip"),
    Asset("MINIMAP_IMAGE", "boat_otterden"),

    Asset("ANIM", "anim/boat_otterden_tuft.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/seafarer_boat.zip"),
    Asset("INV_IMAGE", "boat_item"),
}

local grass_item_assets =
{
    Asset("ANIM", "anim/boat_grass_item.zip"),
    Asset("INV_IMAGE", "boat_grass_item"),
}

local ancient_item_assets =
{
    Asset("ANIM", "anim/boat_ancient_kit.zip"),
}

-- PREFABS
local prefabs =
{
    "mast",
    "burnable_locator_medium",
    "steeringwheel",
    "rudder",
    "boatlip",
    "boat_water_fx",
    "boat_leak",
    "fx_boat_crackle",
    "boatfragment03",
    "boatfragment04",
    "boatfragment05",
    "fx_boat_pop",
    "boat_player_collision",
    "boat_item_collision",
    "boat_grass_player_collision",
    "boat_grass_item_collision",
    "walkingplank",
    "walkingplank_grass",
}

local grass_prefabs =
{
    "degrade_fx_grass",
    "boatlip_grass",
    "boat_grass_erode",
    "boat_grass_erode_water",
    "fx_grass_boat_fluff",
}

local ice_prefabs =
{
    "boat_ice_deploy_blocker",
    "boatlip_ice",
    "degrade_fx_ice",
}

local ancient_prefabs =
{
    "boatlip_ancient",
    "walkingplank_ancient",
    "boat_ancient_container",
}

local otterden_prefabs =
{
    "boatlip_otterden",
    "boat_otterden_erode",
    "boat_otterden_erode_water",
    "fx_grass_boat_fluff",
    "otterden",
    "boat_otterden_player_collision",
    "boat_otterden_item_collision",
}

local item_prefabs =
{
    "boat",
}

local grass_item_prefabs =
{
    "boat_grass",
}

local ancient_item_prefabs =
{
    "boat_ancient",
}

--
local sounds ={
    place = "turnoftides/common/together/boat/place",
    creak = "turnoftides/common/together/boat/creak",
    damage = "turnoftides/common/together/boat/damage",
    sink = "turnoftides/common/together/boat/sink",
    hit = "turnoftides/common/together/boat/hit",
    thunk = "turnoftides/common/together/boat/thunk",
    movement = "turnoftides/common/together/boat/movement",
}

local sounds_grass ={
    place = "monkeyisland/grass_boat/place",
    creak = nil, --"monkeyisland/grass_boat/creak",
    damage = "monkeyisland/grass_boat/damage",
    sink = "monkeyisland/grass_boat/sink",
    hit = "monkeyisland/grass_boat/hit",
    thunk = "monkeyisland/grass_boat/thunk",
    movement = "monkeyisland/grass_boat/movement",
}

local sounds_ice =
{
    place = "dontstarve_DLC001/common/iceboulder_hit",
    creak = "dontstarve_DLC001/common/iceboulder_hit",
    damage = "dontstarve_DLC001/common/iceboulder_hit",
    sink = "dontstarve_DLC001/common/iceboulder_hit",
    hit = "dontstarve_DLC001/common/iceboulder_hit",
    thunk = "dontstarve_DLC001/common/iceboulder_hit",
    movement = "dontstarve_DLC001/common/iceboulder_hit",
}

local BOAT_COLLISION_SEGMENT_COUNT = 20

local BOATBUMPER_MUST_TAGS = { "boatbumper" }

local function OnLoadPostPass(inst)
    local boatring = inst.components.boatring
    if not boatring then
        return
    end

    -- If cannons and bumpers are on a boat, we need to rotate them to account for the boat's rotation
    local x, y, z = inst.Transform:GetWorldPosition()

    -- Bumpers
    local bumpers = TheSim:FindEntities(x, y, z, boatring:GetRadius(), BOATBUMPER_MUST_TAGS)
    for _, bumper in ipairs(bumpers) do
        -- Add to boat bumper list for future reference
        table.insert(boatring.boatbumpers, bumper)

        local bumperpos = bumper:GetPosition()
        local angle = GetAngleFromBoat(inst, bumperpos.x, bumperpos.z) / DEGREES

        -- Need to further rotate the bumpers to account for the boat's rotation
        bumper.Transform:SetRotation(-angle + 90)
    end
end

local function OnSpawnNewBoatLeak(inst, data)
	if data ~= nil and data.pt ~= nil then
        data.pt.y = 0

		local leak = SpawnPrefab("boat_leak")
		leak.Transform:SetPosition(data.pt:Get())
		leak.components.boatleak.isdynamic = true
		leak.components.boatleak:SetBoat(inst)
		leak.components.boatleak:SetState(data.leak_size)

		table.insert(inst.components.hullhealth.leak_indicators_dynamic, leak)

		if inst.components.walkableplatform ~= nil then
			inst.components.walkableplatform:AddEntityToPlatform(leak)
			for player_on_platform in pairs(inst.components.walkableplatform:GetPlayersOnPlatform()) do
				if player_on_platform:IsValid() then
					player_on_platform:PushEvent("on_standing_on_new_leak")
				end
			end
		end

		if data.playsoundfx then
			inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, { intensity = 0.8 })
		end
	end
end

local function OnSpawnNewBoatLeak_Grass(inst, data)
	if data ~= nil and data.pt ~= nil then
		local leak_x, _, leak_z = data.pt:Get()

        if inst.material == "grass" then
            SpawnPrefab("fx_grass_boat_fluff").Transform:SetPosition(leak_x, 0, leak_z)
			SpawnPrefab("splash_green_small").Transform:SetPosition(leak_x, 0, leak_z)
        end

		local damage = TUNING.BOAT.GRASSBOAT_LEAK_DAMAGE[data.leak_size]
		if damage ~= nil then
	        inst.components.health:DoDelta(-damage)
		end

		if data.playsoundfx then
			inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, { intensity = 0.8 })
		end
	end
end

local function RemoveConstrainedPhysicsObj(physics_obj)
    if physics_obj:IsValid() then
        physics_obj.Physics:ConstrainTo(nil)
        physics_obj:Remove()
    end
end

local function constrain_object_to_boat(physics_obj, boat)
    if boat:IsValid() then
        physics_obj.Transform:SetPosition(boat.Transform:GetWorldPosition())
        physics_obj.Physics:ConstrainTo(boat.entity)
    end
end
local function AddConstrainedPhysicsObj(boat, physics_obj)
	physics_obj:ListenForEvent("onremove", function() RemoveConstrainedPhysicsObj(physics_obj) end, boat)

    physics_obj:DoTaskInTime(0, constrain_object_to_boat, boat)
end

local function on_start_steering(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        inst.components.reticule:CreateReticule()
    end
end

local function on_stop_steering(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        inst.lastreticuleangle = nil
        inst.components.reticule:DestroyReticule()
    end
end

local function ReticuleTargetFn(inst)
    local dir = Vector3(
        TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT),
        0,
        TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    )
	local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS

    if math.abs(dir.x) >= deadzone or math.abs(dir.z) >= deadzone then
        dir = dir:GetNormalized()

        inst.lastreticuleangle = dir
    elseif inst.lastreticuleangle ~= nil then
        dir = inst.lastreticuleangle
    else
        return nil
    end

    local Camangle = TheCamera:GetHeading()/180
    local theta = -PI *(0.5 - Camangle)
    local sintheta, costheta = math.sin(theta), math.cos(theta)

    local newx = dir.x*costheta - dir.z*sintheta
    local newz = dir.x*sintheta + dir.z*costheta

    local range = 7
    local pos = inst:GetPosition()
    pos.x = pos.x - (newx * range)
    pos.z = pos.z - (newz * range)

    return pos
end

local function EnableBoatItemCollision(inst)
    if not inst.boat_item_collision then
        inst.boat_item_collision = SpawnPrefab(inst.item_collision_prefab)
        AddConstrainedPhysicsObj(inst, inst.boat_item_collision)
    end
end

local function DisableBoatItemCollision(inst)
    if inst.boat_item_collision then
        RemoveConstrainedPhysicsObj(inst.boat_item_collision) --also :Remove()s object
        inst.boat_item_collision = nil
    end
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

local function physicssleep_stopupdating(inst)
    inst.components.walkableplatform:StopUpdating()
    inst.stopupdatingtask = nil
end
local function OnPhysicsSleep(inst)
    DisableBoatItemCollision(inst)
    inst.stopupdatingtask = inst:DoTaskInTime(1, physicssleep_stopupdating)
    inst.components.boatphysics:StopUpdating()
end

local function StopBoatPhysics(inst)
    --Boats currently need to not go to sleep because
    --constraints will cause a crash if either the target object or the source object is removed from the physics world
    inst.Physics:SetDontRemoveOnSleep(false)
end

local function StartBoatPhysics(inst)
    inst.Physics:SetDontRemoveOnSleep(true)
end

local function SpawnFragment(lp, prefix, offset_x, offset_y, offset_z, ignite)
    local fragment = SpawnPrefab(prefix)
    fragment.Transform:SetPosition(lp.x + offset_x, lp.y + offset_y, lp.z + offset_z)

    if offset_y > 0 and fragment.Physics then
        fragment.Physics:SetVel(0, -0.25, 0)
    end

    if ignite and fragment.components.burnable then
        fragment.components.burnable:Ignite()
    end

    return fragment
end

local function OnEntityReplicated(inst)
    --Use this setting because we can rotate, and we are not billboarded with discreet anim facings
    --NOTE: this setting can only be applied after entity replicated
    inst.Transform:SetInterpolateRotation(true)
end

local function create_common_pre(inst, bank, build, data)
    data = data or {}

    local radius = data.radius or TUNING.BOAT.RADIUS

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    if data.minimap_image then
        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon(data.minimap_image)
        inst.MiniMapEntity:SetPriority(-1)
    end
    inst.entity:AddNetwork()

    inst:AddTag("ignorewalkableplatforms")
	inst:AddTag("antlion_sinkhole_blocker")
	inst:AddTag("boat")
    inst:AddTag("wood")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(TUNING.BOAT.MASS)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:SetCylinder(radius, 3)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
	inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.scrapbook_anim = "idle_full"
    inst.scrapbook_inspectonseen = true

    if data.scale then
        inst.AnimState:SetScale(data.scale, data.scale, data.scale)
    end

    --
    local walkableplatform = inst:AddComponent("walkableplatform")
    walkableplatform.platform_radius = radius

    --
    local healthsyncer = inst:AddComponent("healthsyncer")
    healthsyncer.max_health = data.max_health or TUNING.BOAT.HEALTH

    --
    local waterphysics = inst:AddComponent("waterphysics")
    waterphysics.restitution = 0.75

    --
    local reticule = inst:AddComponent("reticule")
    reticule.targetfn = ReticuleTargetFn
    reticule.ispassableatallpoints = true

    --
    inst.on_start_steering = on_start_steering
    inst.on_stop_steering = on_stop_steering

    --
    inst.doplatformcamerazoom = net_bool(inst.GUID, "doplatformcamerazoom", "doplatformcamerazoomdirty")

	if not TheNet:IsDedicated() then
        inst:ListenForEvent("endsteeringreticule", function(inst2, event_data)
            if ThePlayer and ThePlayer == event_data.player then
                inst2:on_stop_steering()
            end
        end)
        inst:ListenForEvent("starsteeringreticule", function(inst2, event_data)
            if ThePlayer and ThePlayer == event_data.player then
                inst2:on_start_steering()
            end
        end)

        inst:AddComponent("boattrail")
	end

    local boatringdata = inst:AddComponent("boatringdata")
    boatringdata:SetRadius(radius)
    boatringdata:SetNumSegments(8)

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
    end

    return inst
end

local function empty_loot_function() end

local function InstantlyBreakBoat(inst)
    -- This is not for SGboat but is for safety on physics.
    if inst.components.boatphysics then
        inst.components.boatphysics:SetHalting(true)
    end
    --Keep this in sync with SGboat.
    for entity_on_platform in pairs(inst.components.walkableplatform:GetEntitiesOnPlatform()) do
        entity_on_platform:PushEvent("abandon_ship")
    end
    for player_on_platform in pairs(inst.components.walkableplatform:GetPlayersOnPlatform()) do
        player_on_platform:PushEvent("onpresink")
    end
    inst:sinkloot()
    if inst.postsinkfn then
        inst:postsinkfn()
    end
    inst:Remove()
end

local function GetSafePhysicsRadius(inst)
    return (inst.components.hull ~= nil and inst.components.hull:GetRadius() or TUNING.BOAT.RADIUS) + 0.18 -- Add a small offset for item overhangs.
end

local function IsBoatEdgeOverLand(inst, override_position_pt)
    local map = TheWorld.Map
    local radius = inst:GetSafePhysicsRadius()
    local segment_count = BOAT_COLLISION_SEGMENT_COUNT * 2
    local segment_span = TWOPI / segment_count
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

local PLANK_EDGE_OFFSET = -0.05
local function create_master_pst(inst, data)
    data = data or {}

    inst.leak_build = data.leak_build
    inst.leak_build_override = data.leak_build_override

    local radius = data.radius or TUNING.BOAT.RADIUS

    inst.Physics:SetDontRemoveOnSleep(true)
    inst.item_collision_prefab = data.item_collision_prefab
    EnableBoatItemCollision(inst)

    inst.entity:AddPhysicsWaker() --server only component
    inst.PhysicsWaker:SetTimeBetweenWakeTests(TUNING.BOAT.WAKE_TEST_TIME)

    local hull = inst:AddComponent("hull")
    hull:SetRadius(radius)

    if data.boatlip_prefab then
        hull:SetBoatLip(SpawnPrefab(data.boatlip_prefab), data.scale or 1.0)
    end

    if data.plank_prefab then
        local walking_plank = SpawnPrefab(data.plank_prefab)
        hull:AttachEntityToBoat(walking_plank, 0, radius + PLANK_EDGE_OFFSET, true)
        hull:SetPlank(walking_plank)
    end

    if not data.fireproof then
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
    inst:AddComponent("hullhealth")
    inst:AddComponent("boatphysics")
    inst:AddComponent("boatdrifter")
    inst:AddComponent("savedrotation")

    local health = inst:AddComponent("health")
    health:SetMaxHealth(data.max_health or TUNING.BOAT.HEALTH)
    health.nofadeout = true

    inst:SetStateGraph(data.stategraph or "SGboat")

    inst.StopBoatPhysics = StopBoatPhysics
    inst.StartBoatPhysics = StartBoatPhysics

    inst.OnPhysicsWake = OnPhysicsWake
    inst.OnPhysicsSleep = OnPhysicsSleep

    inst.sinkloot = empty_loot_function
    inst.InstantlyBreakBoat = InstantlyBreakBoat
    inst.GetSafePhysicsRadius = GetSafePhysicsRadius
    inst.IsBoatEdgeOverLand = IsBoatEdgeOverLand

    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function build_boat_collision_mesh(radius, height)
    local segment_count = BOAT_COLLISION_SEGMENT_COUNT
    local segment_span = TWOPI / segment_count

    local triangles = {}
    local y0 = 0
    local y1 = height

    for segement_idx = 0, segment_count do

        local angle = segement_idx * segment_span
        local angle0 = angle - segment_span / 2
        local angle1 = angle + segment_span / 2

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

local function boat_player_collision_template(radius)
    local inst = CreateEntity()

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetFriction(0)
    phys:SetDamping(5)
	phys:SetRestitution(0)
    phys:SetCollisionGroup(COLLISION.BOAT_LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.WORLD)
    phys:SetTriangleMesh(build_boat_collision_mesh(radius + 0.1, 3))

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    return inst
end

local function boat_item_collision_template(radius)
    local inst = CreateEntity()

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(1000)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.BOAT_LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:CollidesWith(COLLISION.WORLD)
    phys:SetTriangleMesh(build_boat_collision_mesh(radius + 0.2, 3))
    --Boats currently need to not go to sleep because
    --constraints will cause a crash if either the target object or the source object is removed from the physics world
    --while the above is still true, the constraint is now properly removed before despawning the object, and can be safely ignored for this object, kept for future copy/pasting.
    phys:SetDontRemoveOnSleep(true)

    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function ondeploy(inst, pt, deployer)
    local boat = SpawnPrefab(inst.deploy_product, inst.linked_skinname, inst.skin_id)
    if not boat then return end

    local boat_hull = boat.components.hull
    if boat.skinname and boat_hull and boat_hull.plank then
        local iswoodboat = boat_hull.plank.prefab == "walkingplank"
        local isgrassboat = boat_hull.plank.prefab == "walkingplank_grass"
        if iswoodboat or isgrassboat then
            local plank_skinname = boat_hull.plank.prefab .. string.sub(boat.skinname, iswoodboat and 5 or isgrassboat and 11 or 0)
            TheSim:ReskinEntity( boat_hull.plank.GUID, nil, plank_skinname, boat.skin_id )
        end
    end

    boat.Physics:SetCollides(false)
    boat.Physics:Teleport(pt.x, 0, pt.z)
    boat.Physics:SetCollides(true)

    boat.sg:GoToState("place")

    if boat_hull then
        boat_hull:OnDeployed()
    end

    inst:Remove()

    return boat
end

local function wood_fn()
    local inst = CreateEntity()

    local bank = "boat_01"
    local build = "boat_test"

    local WOOD_BOAT_DATA = {
        radius = TUNING.BOAT.RADIUS,
        max_health = TUNING.BOAT.HEALTH,
        item_collision_prefab = "boat_item_collision",
        boatlip_prefab = "boatlip",
        plank_prefab = "walkingplank",
        minimap_image = "boat.png",
    }

    inst = create_common_pre(inst, bank, build, WOOD_BOAT_DATA)

    inst.walksound = "wood"

    inst.components.walkableplatform.player_collision_prefab = "boat_player_collision"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = create_master_pst(inst, WOOD_BOAT_DATA)

	inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak)
    inst.boat_crackle = "fx_boat_crackle"

    inst.sounds = sounds

    inst.sinkloot = function()
        local ignitefragments = inst.activefires > 0
        local locus_point = inst:GetPosition()
        local num_loot = 3
        local loot_angle = PI2/num_loot
        for i = 1, num_loot do
            local r = math.sqrt(math.random())*(WOOD_BOAT_DATA.radius - 2) + 1.5
            local t = (i + 2 * math.random()) * loot_angle
            SpawnFragment(locus_point, "boards", math.cos(t) * r,  0, math.sin(t) * r, ignitefragments)
        end
    end

    inst.postsinkfn = function()
        local fx_boat_crackle = SpawnPrefab("fx_boat_pop")
        fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= 1})
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.sink)
    end

    return inst
end

local function grass_fn()
    local inst = CreateEntity()

    local bank = "boat_grass"
    local build = "boat_grass"
    local GRASS_BOAT_DATA = {
        radius = TUNING.BOAT.GRASS_BOAT.RADIUS,
        max_health = TUNING.BOAT.HEALTH,
        item_collision_prefab = "boat_grass_item_collision",
        scale = 0.75,
        boatlip_prefab = "boatlip_grass",
        plank_prefab = "walkingplank_grass",
        minimap_image = "boat_grass.png",
    }

    inst = create_common_pre(inst, bank, build, GRASS_BOAT_DATA)

    inst.leaky = true
    inst.material = "grass"

    inst.walksound = "marsh"
    inst.second_walk_sound = "tallgrass"

    inst.components.walkableplatform.player_collision_prefab = "boat_grass_player_collision"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = create_master_pst(inst, GRASS_BOAT_DATA)

	inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak_Grass)

    inst.sounds = sounds_grass

    local hullhealth = inst.components.hullhealth
    hullhealth:SetSelfDegrading(5)
    hullhealth.degradefx = "degrade_fx_grass"
    hullhealth.leakproof = true

    inst.components.repairable.repairmaterial = MATERIALS.HAY

    inst.sinkloot = function()
        local ignitefragments = inst.activefires > 0
        local locus_point = inst:GetPosition()
        local num_loot = 6
        local loot_angle = PI2/num_loot
        for i = 1, num_loot do
            local r = math.sqrt(math.random())*(GRASS_BOAT_DATA.radius-2) + 1.5
            local t = (i + 2 * math.random()) * loot_angle
            SpawnFragment(locus_point, "cutgrass", math.cos(t) * r,  0, math.sin(t) * r, ignitefragments)
        end
    end
    inst.postsinkfn = function(inst)
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local erode = SpawnPrefab("boat_grass_erode")
        erode.Transform:SetPosition(ix, iy, iz)

        local erode_water = SpawnPrefab("boat_grass_erode_water")
        erode_water.Transform:SetPosition(ix, iy, iz)
    end

    return inst
end


local function pirate_initialize(inst)
    local ents = inst.components.walkableplatform:GetEntitiesOnPlatform()

    local function oncannonremoved(cannon)
        table.removearrayvalue(inst.cannons, cannon)
    end

    for ent in pairs(ents) do
        if ent:HasTag("boatcannon") then
            table.insert(inst.cannons, ent)

            ent:ListenForEvent("onremove", oncannonremoved)
        end
    end
end

local function pirate_fn()
    local inst = CreateEntity()

    local bank = "boat_01"
    local build = "boat_pirate"
    local PIRATE_BOAT_DATA = {
        radius = TUNING.BOAT.RADIUS,
        max_health = TUNING.BOAT.HEALTH,
        item_collision_prefab = "boat_item_collision",
        scale = nil,
        boatlip_prefab = "boatlip",
        minimap_image = "boat_pirate.png",
    }

    inst = create_common_pre(inst, bank, build, PIRATE_BOAT_DATA)

    inst.walksound = "wood"

    inst.components.walkableplatform.player_collision_prefab = "boat_player_collision"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_deps = { "pirate_flag_pole", "prime_mate", "powder_monkey" }

    inst = create_master_pst(inst, PIRATE_BOAT_DATA)

    inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak)

    inst.boat_crackle = "fx_boat_crackle"
    inst.sounds = sounds

    inst.sinkloot = function()
        local ignitefragments = inst.activefires > 0
        local locus_point = inst:GetPosition()
        local num_loot = 3
        local loot_angle = PI2/num_loot
        for i = 1, num_loot do
            local r = math.sqrt(math.random())*(PIRATE_BOAT_DATA.radius-2) + 1.5
            local t = (i + 2 * math.random()) * loot_angle
            SpawnFragment(locus_point, "boards", math.cos(t) * r,  0, math.sin(t) * r, ignitefragments)
        end
    end

    inst.postsinkfn = function()
        local fx_boat_crackle = SpawnPrefab("fx_boat_pop")
        fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= 1})
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.sink)
    end
    inst.cannons = {}
    
    inst:DoTaskInTime(0, pirate_initialize)

    return inst
end

local function do_boat_container_offset(boat, container)
	if container ~= nil and container:IsValid() then
    	container.Transform:SetPosition(boat.Transform:GetWorldPosition())
    end
end

local ANCIENT_BOAT_SCALE = 1.334

local function ancient_fn()
    local inst = CreateEntity()

    local bank  = "boat_yotd"
    local build = "boat_ancient"

    local ANCIENT_BOAT_DATA = {
        radius = TUNING.BOAT.ANCIENT_BOAT.RADIUS,
        max_health = TUNING.BOAT.ANCIENT_BOAT.HEALTH,
        item_collision_prefab = "boat_item_collision",
        scale = ANCIENT_BOAT_SCALE,
        boatlip_prefab = "boatlip_ancient",
        plank_prefab = "walkingplank_ancient",
        minimap_image = "boat_ancient.png",
        leak_build_override = "boat_leak_ancient_build",
    }

    inst = create_common_pre(inst, bank, build, ANCIENT_BOAT_DATA)

    inst.walksound = "wood"

    inst.components.walkableplatform.player_collision_prefab = "boat_player_collision"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = create_master_pst(inst, ANCIENT_BOAT_DATA)

    if not POPULATING then
        inst._container = SpawnPrefab("boat_ancient_container")
        inst:DoTaskInTime(0, do_boat_container_offset, inst._container)
    end

    inst.components.hullhealth.max_health_damage = TUNING.BOAT.ANCIENT_BOAT.MAX_HULL_HEALTH_DAMAGE
    inst.components.hullhealth.small_leak_dmg = TUNING.BOAT.ANCIENT_BOAT.SMALL_LEAK_DMG_THRESHOLD
    inst.components.hullhealth.med_leak_dmg = TUNING.BOAT.ANCIENT_BOAT.MED_LEAK_DMG_THRESHOLD

    inst._fire_damage = TUNING.BOAT.ANCIENT_BOAT.FIRE_DAMAGE

	inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak)
    inst.boat_crackle = "fx_boat_crackle"

    inst.sounds = sounds

    inst.sinkloot = function()
        local ignitefragments = inst.activefires > 0
        local locus_point = inst:GetPosition()
        local num_loot = 3
        local loot_angle = PI2/num_loot
        for i = 1, num_loot do
            local r = math.sqrt(math.random())*(ANCIENT_BOAT_DATA.radius - 2) + 1.5
            local t = (i + 2 * math.random()) * loot_angle
            SpawnFragment(locus_point, "boards", math.cos(t) * r,  0, math.sin(t) * r, ignitefragments)
        end
    end

    inst.postsinkfn = function()
        local fx_boat_crackle = SpawnPrefab("fx_boat_pop")
        fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= 1})
        inst.SoundEmitter:PlaySoundWithParams(inst.sounds.sink)
    end

    return inst
end

-- OTTER DEN PLATFORM
local function OnRowed_OtterDen(inst, rower)
    local entities_on_platform = inst.components.walkableplatform:GetEntitiesOnPlatform()
    for entity_on_platform in pairs(entities_on_platform) do
        if entity_on_platform:HasTag("angry_when_rowed") then
            entity_on_platform:PushEvent("onmoved", rower)
        end
    end
end

local function otterden_comment_timeout(inst)
    inst._comment_timeout_task = nil
end
local function otterden_start_erosion(inst, amount)
    amount = amount or TUNING.BOAT_OTTERDEN_ERODE_RATE
    inst.components.hullhealth:SetSelfDegrading(amount)
    if not inst.AnimState:IsCurrentAnimation("crack") then
        local start_frame = nil
        if inst.AnimState:IsCurrentAnimation("crack_reverse") then
            local current_crack_frame = inst.AnimState:GetCurrentAnimationFrame()
            start_frame = 54 - current_crack_frame
            if start_frame < 1 then start_frame = nil end
        end
        inst.AnimState:PlayAnimation("crack")
        if start_frame then
            inst.AnimState:SetFrame(start_frame)
        end
    end
end
local function otterden_stop_erosion(inst)
    inst.components.hullhealth:SetSelfDegrading(0)
    local start_frame = nil
    if inst.AnimState:IsCurrentAnimation("crack") then
        local current_crack_frame = inst.AnimState:GetCurrentAnimationFrame()
        start_frame = 54 - current_crack_frame
        if start_frame < 1 then start_frame = nil end
    end
    inst.AnimState:PlayAnimation("crack_reverse")
    if start_frame then
        inst.AnimState:SetFrame(start_frame)
    end
    inst.AnimState:PushAnimation("idle_full")
end
local function otterden_on_update(inst, dt)
    -- If we're already missing our den, we should already be degrading,
    -- so don't waste cycles checking map tiles or anything, and
    -- don't accidentally stop doing the degrading for that.
    local den = inst.components.entitytracker:GetEntity("otterden")
    if not den then return end

    local hullhealth = inst.components.hullhealth
    local boat_tile = TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition())
    if boat_tile ~= WORLD_TILES.OCEAN_COASTAL
            and boat_tile ~= WORLD_TILES.OCEAN_COASTAL_SHORE
            and boat_tile ~= WORLD_TILES.OCEAN_WATERLOG
            and TileGroupManager:IsOceanTile(boat_tile) then
        if hullhealth.selfdegradingtime == 0 then
            otterden_start_erosion(inst)
            if inst._comment_timeout_task ~= nil then
                return
            end

            local players_on_platform = inst.components.walkableplatform:GetPlayersOnPlatform()
            if next(players_on_platform) ~= nil then
                local random_player_on_platform = GetRandomKey(players_on_platform)
                if random_player_on_platform then
                    inst._comment_timeout_task = inst:DoTaskInTime(20, otterden_comment_timeout)
                    random_player_on_platform:PushEvent("otterboaterosion_begin", "deepwater")
                end
            end
        end
    else
        if hullhealth.selfdegradingtime == TUNING.BOAT_OTTERDEN_ERODE_RATE then
            otterden_stop_erosion(inst)
        end
    end
end

local function otterden_initialize(inst)
    local entitytracker = inst.components.entitytracker
    local den = entitytracker:GetEntity("otterden")
    if not den and not inst._den_spawned then
        den = SpawnPrefab("otterden")
        den.Transform:SetPosition(inst.Transform:GetWorldPosition())
        entitytracker:TrackEntity("otterden", den)
        inst._den_spawned = true
    end
    inst:ListenForEvent("onremove", inst._on_den_removed, den)
end

local function on_dead_otterden_added(inst, den)
    if not inst.components.entitytracker:GetEntity("otterden_dead") then
        inst.components.entitytracker:TrackEntity("otterden_dead", den)
        table.insert(inst.components.hullhealth.leak_indicators_dynamic, den)
    end
end

local function otterden_onsave(inst, data)
    if inst._den_spawned then
        data.den_spawned = true
    end

    if inst.components.hullhealth.selfdegradingtime ~= 0 then
        data.erosion_rate = inst.components.hullhealth.selfdegradingtime
    end
end

local function otterden_onload(inst, data)
    if data then
        inst._den_spawned = data.den_spawned
        if data.erosion_rate then
            otterden_start_erosion(inst, data.erosion_rate)
        end
    end
end

local function otterden_onloadpostpass(inst, newents, data)
    local dead_den = inst.components.entitytracker:GetEntity("otterden_dead")
    if dead_den then
        if inst.components.hullhealth then
            table.insert(inst.components.hullhealth.leak_indicators_dynamic, dead_den)
        end
    end
end

local function CLIENT_MakeOtterdenTuft(inst, anim_index)
    anim_index = anim_index or math.random(3)

    local tuft = CreateEntity()
    tuft:AddTag("FX")
    --[[Non-networked entity]]
    tuft.persists = false
    tuft.entity:AddTransform()
    tuft.entity:AddAnimState()
    tuft.entity:SetParent(inst.entity)

    tuft.AnimState:SetBank("boat_otterden_tuft")
    tuft.AnimState:SetBuild("boat_otterden_tuft")
    tuft.AnimState:PlayAnimation("idle"..anim_index)

    return tuft
end

local function otterden_fn()
    local inst = CreateEntity()

    local bank = "boat_otterden"
    local build = "boat_otterden"
    local OTTERDEN_BOAT_DATA = {
        radius = TUNING.BOAT.OTTERDEN_BOAT.RADIUS,
        max_health = TUNING.BOAT.OTTERDEN_BOAT.HEALTH,
        item_collision_prefab = "boat_otterden_item_collision",
        boatlip_prefab = "boatlip_otterden",
        minimap_image = "boat_otterden.png",
    }

    inst = create_common_pre(inst, bank, build, OTTERDEN_BOAT_DATA)

    inst.material = "kelp"
    inst.walksound = "marsh"
    inst.second_walk_sound = "tallgrass"

    inst.components.walkableplatform.player_collision_prefab = "boat_otterden_player_collision"

    if not TheNet:IsDedicated() then
        local tuft_angle, tuft_offset
        local NUM_TUFTS = 6
        for i = 1, NUM_TUFTS do
            local tuft = CLIENT_MakeOtterdenTuft(inst)
            tuft_angle = GetRandomWithVariance((i * TWOPI/NUM_TUFTS), PI/6)
            tuft_offset = 1.0 + (OTTERDEN_BOAT_DATA.radius * 0.5) * (math.sqrt(math.random()))
            tuft.Transform:SetPosition(
                tuft_offset * math.cos(tuft_angle),
                0,
                tuft_offset * math.sin(tuft_angle)
            )
        end
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --inst.scrapbook_deps = { "otter", "otterden" }

    inst = create_master_pst(inst, OTTERDEN_BOAT_DATA)

    inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak_Grass)
    inst:ListenForEvent("rowed", OnRowed_OtterDen)

    inst.sounds = sounds_grass

    inst.components.repairable.repairmaterial = MATERIALS.KELP
    inst.components.hullhealth.leakproof = true

    -- Just start a steady regeneration on the boat, so that it can recover from being moved out to the deep ocean.
    inst.components.health:StartRegen(1, 5*TUNING.BOAT_OTTERDEN_ERODE_RATE)

    -- To track our den, especially between save/loads
    inst:AddComponent("entitytracker")

    --
    inst._check_for_tile_degrade_task = inst:DoPeriodicTask(0.5, otterden_on_update, 0.5 * (1 + math.random()))

    --
    inst.sinkloot = function()
        local ignitefragments = inst.activefires > 0
        local locus_point = inst:GetPosition()
        local num_loot = 6
        local loot_angle = PI2/num_loot
        local sqrt, random, sin, cos = math.sqrt, math.random, math.sin, math.cos
        for i = 1, num_loot do
            local r = sqrt(random())*(OTTERDEN_BOAT_DATA.radius-2) + 1.5
            local t = (i + 2 * random()) * loot_angle
            SpawnFragment(locus_point, "kelp", cos(t) * r, 0, sin(t) * r, ignitefragments)
        end
    end
    inst.postsinkfn = function(inst)
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local erode = SpawnPrefab("boat_otterden_erode")
        erode.Transform:SetPosition(ix, iy, iz)

        local erode_water = SpawnPrefab("boat_otterden_erode_water")
        erode_water.Transform:SetPosition(ix, iy, iz)
    end

    --
    inst._on_den_removed = function()
        local players_on_platform = inst.components.walkableplatform:GetPlayersOnPlatform()
        if next(players_on_platform) ~= nil then
            local random_player_on_platform = GetRandomKey(players_on_platform)
            if random_player_on_platform then
                random_player_on_platform:PushEvent("otterboaterosion_begin", "dengone")
            end
        end
    end
    inst:DoTaskInTime(0, otterden_initialize)

    --
    inst:ListenForEvent("dead_otterden_added", on_dead_otterden_added)

    --
    inst.OnSave = otterden_onsave
    inst.OnLoad = otterden_onload
    inst.OnLoadPostPass = otterden_onloadpostpass

    return inst
end

-- ICE FLOE
local function ice_floe_deploy_blocker_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    -- Prevent things from being deployed onto the ice floes. 
    inst:SetDeployExtraSpacing(TUNING.OCEAN_ICE_RADIUS + 0.1)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function ice_ondeath(inst)
	if inst:IsAsleep() then
		if not inst.sg:HasStateTag("dead") then
			for ent in pairs(inst.components.walkableplatform:GetEntitiesOnPlatform()) do
				ent:PushEvent("abandon_ship")
			end
		end
		inst.sinkloot_asleep()
		inst:Remove()
	end
end

local function ice_fn()
    local inst = CreateEntity()

    local bank = "boat_ice"
    local build = "boat_ice"
    local OCEANICE_BOAT_DATA = {
        radius = TUNING.OCEAN_ICE_RADIUS,
        max_health = TUNING.OCEAN_ICE_HEALTH,
        item_collision_prefab = "boat_ice_item_collision",
        boatlip_prefab = "boatlip_ice",
        stategraph = "SGboat_ice",
        fireproof = true,
    }

    inst = create_common_pre(inst, bank, build, OCEANICE_BOAT_DATA)

    inst:RemoveTag("wood") -- Cookie Cutters should not eat it.

    inst.material = "ice"
    inst.walksound = "ice"

    inst.components.walkableplatform.player_collision_prefab = "boat_ice_player_collision"

    local boattrail = inst.components.boattrail
    if boattrail then
        local scale = TUNING.OCEAN_ICE_RADIUS / TUNING.BOAT.RADIUS
        boattrail.scale_x = scale
        boattrail.scale_y = scale

        boattrail.radius = boattrail.radius * scale
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.GetIdleLevel = function()
        local health_percent = inst.components.health:GetPercent()
        return (health_percent > 0.66 and "1")
            or (health_percent > 0.33 and "2")
            or "3"
    end

    inst = create_master_pst(inst, OCEANICE_BOAT_DATA)

	inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak)
	inst:ListenForEvent("death", ice_ondeath)

    inst.components.hullhealth:SetSelfDegrading(1)
    inst.components.hullhealth.leakproof = true

    inst.components.repairable.repairmaterial = nil

    inst.sounds = sounds_ice
    inst.boat_crackle = "mining_ice_fx"

    inst:DoTaskInTime(FRAMES, function(i)
        local ix, iy, iz = i.Transform:GetWorldPosition()
        local deploy_blocker = SpawnPrefab("boat_ice_deploy_blocker")
        deploy_blocker.Transform:SetPosition(ix, iy, iz)
    end)

    inst.sinkloot = function()
        local ignitefragments = false --(inst.activefires > 0)
        local locus_point = inst:GetPosition()
        local num_loot = 3
        local loot_angle = PI2/num_loot
        local loot_radius = (OCEANICE_BOAT_DATA.radius/2)
        for i = 1, num_loot do
            local r = (1 + math.sqrt(math.random()))*loot_radius
            local t = (i + 2 * math.random()) * loot_angle
            SpawnFragment(locus_point, "ice", math.cos(t) * r, 0, math.sin(t) * r, ignitefragments)

            r = (1 + math.sqrt(math.random()))*loot_radius
            t = t + loot_angle * (0.3 + 0.6 * math.random())
            SpawnFragment(locus_point, "degrade_fx_ice", math.cos(t) * r, 0, math.sin(t) * r)
        end
    end
	inst.sinkloot_asleep = function()
		local num_loot = math.random(3) - 1
		if num_loot > 0 then
			local locus_point = inst:GetPosition()
			local loot_angle = PI2/num_loot
			local loot_radius = (OCEANICE_BOAT_DATA.radius/2)
			for i = 1, num_loot do
				local r = (1 + math.sqrt(math.random()))*loot_radius
				local t = (i + 2 * math.random()) * loot_angle
				SpawnFragment(locus_point, "ice", math.cos(t) * r, 0, math.sin(t) * r, false)
			end
		end
	end
    inst.postsinkfn = function(inst)
        local break_fx = SpawnPrefab("mining_ice_fx")
        break_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    inst.SpawnFragment = SpawnFragment

    return inst
end

local function ice_crabking_fn()
    local inst = ice_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    local function sinkloot()
        local ignitefragments = false --(inst.activefires > 0)
        local locus_point = inst:GetPosition()
        local num_loot = 3
        local loot_angle = TWOPI/num_loot
        local loot_radius = (inst.components.hull:GetRadius()/2)
        for i = 1, num_loot do
            local r = (1 + math.sqrt(math.random()))*loot_radius
            local t = (i + 2 * math.random()) * loot_angle
            
            r = (1 + math.sqrt(math.random()))*loot_radius
            t = t + loot_angle * (0.3 + 0.6 * math.random())
            inst.SpawnFragment(locus_point, "degrade_fx_ice", math.cos(t) * r, 0, math.sin(t) * r)
        end
    end
    
    inst.sinkloot = sinkloot
    inst.components.health:SetVal(10)

    return inst
end

-- ITEMS

function CLIENT_CanDeployBoat(inst, pt, mouseover, deployer, rotation)
    return TheWorld.Map:CanDeployBoatAtPointInWater(pt, inst, mouseover,
    {
        boat_radius = inst._boat_radius,
        boat_extra_spacing = 0.2,
        min_distance_from_land = 0.2,
    })
end

local function common_item_fn_pre(inst)
    inst._custom_candeploy_fn = CLIENT_CanDeployBoat
    inst._boat_radius = TUNING.BOAT.RADIUS

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("boatbuilder")
    inst:AddTag("usedeployspacingasoffset")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seafarer_boat")
    inst.AnimState:SetBuild("seafarer_boat")
    inst.AnimState:PlayAnimation("IDLE")

    MakeInventoryFloatable(inst, "med", 0.25, 0.83)

    return inst
end

local function common_item_fn_pst(inst)
    local deployable = inst:AddComponent("deployable")
    deployable.ondeploy = ondeploy
    deployable:SetDeploySpacing(DEPLOYSPACING.LARGE)
    deployable:SetDeployMode(DEPLOYMODE.CUSTOM)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    local fuel = inst:AddComponent("fuel")
    fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

local function item_fn()
    local inst = CreateEntity()

    inst = common_item_fn_pre(inst)

    inst.deploy_product = "boat"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = common_item_fn_pst(inst)

    return inst
end

local function grass_item_fn()
    local inst = CreateEntity()

    inst = common_item_fn_pre(inst)
    inst._boat_radius = TUNING.BOAT.GRASS_BOAT.RADIUS

    inst.AnimState:SetBank("seafarer_boat")
    inst.AnimState:SetBuild("boat_grass_item")

    inst.deploy_product = "boat_grass"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = common_item_fn_pst(inst)
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

    return inst
end

local function ancient_ondeploy(...)
    local boat = ondeploy(...)

    boat._container:Hide()
    boat._container:DoTaskInTime(.5, boat._container.OnPlaced)
end

local function ancient_item_fn()
    local inst = CreateEntity()

    inst = common_item_fn_pre(inst)

    inst.deploy_product = "boat_ancient"

    inst.AnimState:SetBank("seafarer_boat")
    inst.AnimState:SetBuild("boat_ancient_kit")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst = common_item_fn_pst(inst)

    inst.components.deployable.ondeploy = ancient_ondeploy

    return inst
end

-- COLLISIONS
local function boat_player_collision_fn()
    return boat_player_collision_template(TUNING.BOAT.RADIUS)
end

local function boat_item_collision_fn()
    return boat_item_collision_template(TUNING.BOAT.RADIUS)
end

-- Grass boat collisions
local function boat_grass_player_collision_fn()
    return boat_player_collision_template(TUNING.BOAT.GRASS_BOAT.RADIUS)
end

local function boat_grass_item_collision_fn()
    return boat_item_collision_template(TUNING.BOAT.GRASS_BOAT.RADIUS)
end

--
local function boat_ice_player_collision_fn()
    return boat_player_collision_template(TUNING.OCEAN_ICE_RADIUS)
end

local function boat_ice_item_collision_fn()
    return boat_item_collision_template(TUNING.OCEAN_ICE_RADIUS)
end

local function boat_otterden_player_collision_fn()
    return boat_player_collision_template(TUNING.BOAT.OTTERDEN_BOAT.RADIUS)
end

local function boat_otterden_item_collision_fn()
    return boat_item_collision_template(TUNING.BOAT.OTTERDEN_BOAT.RADIUS)
end

local function ancient_placer_postinit(inst)
    inst.AnimState:SetScale(ANCIENT_BOAT_SCALE, ANCIENT_BOAT_SCALE)
end

--
return Prefab("boat", wood_fn, wood_assets, prefabs),
       Prefab("boat_player_collision", boat_player_collision_fn),
       Prefab("boat_item_collision", boat_item_collision_fn),
       Prefab("boat_item", item_fn, item_assets, item_prefabs),
       MakePlacer("boat_item_placer", "boat_01", "boat_test", "idle_full", true, false, false, nil, nil, nil, ControllerPlacer_Boat_SpotFinder, 6),

       Prefab("boat_pirate", pirate_fn, pirate_assets, prefabs),

       Prefab("boat_ancient", ancient_fn, ancient_assets, ancient_prefabs),
       Prefab("boat_ancient_item", ancient_item_fn, ancient_item_assets, ancient_item_prefabs),
       MakePlacer("boat_ancient_item_placer", "boat_yotd", "boat_ancient", "idle_full", true, false, false, nil, nil, nil, ancient_placer_postinit, 6),

       Prefab("boat_otterden", otterden_fn, otterden_assets, otterden_prefabs),
       Prefab("boat_otterden_player_collision", boat_otterden_player_collision_fn),
       Prefab("boat_otterden_item_collision", boat_otterden_item_collision_fn),

       Prefab("boat_grass", grass_fn, grass_assets, grass_prefabs),
       Prefab("boat_grass_player_collision", boat_grass_player_collision_fn),
       Prefab("boat_grass_item_collision", boat_grass_item_collision_fn),

       Prefab("boat_ice", ice_fn, ice_assets, ice_prefabs),
       Prefab("boat_ice_crabking", ice_crabking_fn, ice_assets, ice_prefabs),
       Prefab("boat_ice_player_collision", boat_ice_player_collision_fn),
       Prefab("boat_ice_item_collision", boat_ice_item_collision_fn),
       Prefab("boat_ice_deploy_blocker", ice_floe_deploy_blocker_fn),

       Prefab("boat_grass_item", grass_item_fn, grass_item_assets, grass_item_prefabs),
       MakePlacer("boat_grass_item_placer", "boat_grass", "boat_grass", "idle_full", true, false, false, 0.85, nil, nil, ControllerPlacer_Boat_SpotFinder, 4.5)
