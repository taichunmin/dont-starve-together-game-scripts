local assets =
{
    Asset("ANIM", "anim/boat_test.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/seafarer_boat.zip"),
    Asset("INV_IMAGE", "boat_item"),
}

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
    "walkingplank",
}

local item_prefabs =
{
    "boat",
}

local function OnRepaired(inst)    
    --inst.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
end

local function BoatCam_IsEnabledFn()
	return Profile:IsBoatCameraEnabled()
end

local function BoatCam_ActiveFn(params, parent, best_dist_sq)
	local state = params.updater.state
    local tpos = params.target:GetPosition()
	state.last_platform_x, state.last_platform_z = tpos.x, tpos.z

	local pan_gain, heading_gain, distance_gain = TheCamera:GetGains()
	TheCamera:SetGains(1.5, heading_gain, distance_gain)
end

local function BoatCam_UpdateFn(dt, params, parent, best_dist_sq)
    local tpos = params.target:GetPosition()

	local state = params.updater.state
    local platform_x, platform_y, platform_z = tpos:Get()

    local velocity_x = dt == 0 and 0 or ((platform_x - state.last_platform_x) / dt)
	local velocity_z = dt == 0 and 0 or ((platform_z - state.last_platform_z) / dt)
    local velocity_normalized_x, velocity_normalized_z = 0, 0
    local velocity = 0        
    local min_velocity = 0.4
    local velocity_sq = velocity_x * velocity_x + velocity_z * velocity_z

    if velocity_sq >= min_velocity * min_velocity then
        velocity = math.sqrt(velocity_sq)
        velocity_normalized_x = velocity_x / velocity
        velocity_normalized_z = velocity_z / velocity
        velocity = math.max(velocity - min_velocity, 0)
    end

    local look_ahead_max_dist = 5
    local look_ahead_max_velocity = 3
    local look_ahead_percentage = math.min(math.max(velocity / look_ahead_max_velocity, 0), 1)
    local look_ahead_amount = look_ahead_max_dist * look_ahead_percentage

    --Average target_camera_offset to get rid of some of the noise.
    state.target_camera_offset.x = (state.target_camera_offset.x + velocity_normalized_x * look_ahead_amount) / 2
    state.target_camera_offset.z = (state.target_camera_offset.z + velocity_normalized_z * look_ahead_amount) / 2        

    state.last_platform_x, state.last_platform_z = platform_x, platform_z

    local camera_offset_lerp_speed = 0.25
    state.camera_offset.x, state.camera_offset.z = VecUtil_Lerp(state.camera_offset.x, state.camera_offset.z, state.target_camera_offset.x, state.target_camera_offset.z, dt * camera_offset_lerp_speed)

    TheCamera:SetOffset(state.camera_offset + (tpos - parent:GetPosition()))

    local pan_gain, heading_gain, distance_gain = TheCamera:GetGains()
    local pan_lerp_speed = 0.75
    pan_gain = Lerp(pan_gain, state.target_pan_gain, dt * pan_lerp_speed)        

    TheCamera:SetGains(pan_gain, heading_gain, distance_gain)    
end

local function StartBoatCamera(inst)
	local camera_settings =
	{
		state = {
			target_camera_offset = Vector3(0,1.5,0),
			camera_offset = Vector3(0,1.5,0),
			last_platform_x = 0, last_platform_z = 0,
			target_pan_gain = 4,
		},
		UpdateFn = BoatCam_UpdateFn,
		ActiveFn = BoatCam_ActiveFn,
		IsEnabled = BoatCam_IsEnabledFn,
	}

	TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, math.huge, math.huge, -1, camera_settings)
end

local function OnObjGotOnPlatform(inst, obj)    
    if obj == ThePlayer and inst.StartBoatCamera ~= nil then
		inst:StartBoatCamera()
	end
end

local function OnObjGotOffPlatform(inst, obj) 
    if obj == ThePlayer then
		TheFocalPoint.components.focalpoint:StopFocusSource(inst)
	end
end

local function RemoveConstrainedPhysicsObj(physics_obj)
    if physics_obj:IsValid() then
        physics_obj.Physics:ConstrainTo(nil)
        physics_obj:Remove()
    end
end

local function AddConstrainedPhysicsObj(boat, physics_obj)
	physics_obj:ListenForEvent("onremove", function() RemoveConstrainedPhysicsObj(physics_obj) end, boat)

    physics_obj:DoTaskInTime(0, function()
		if boat:IsValid() then
			physics_obj.Transform:SetPosition(boat.Transform:GetWorldPosition())
   			physics_obj.Physics:ConstrainTo(boat.entity)
		end
	end)
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

    local range = 7
    local pos = Vector3(inst.Transform:GetWorldPosition())   

    local dir = Vector3()
    dir.x = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
    dir.y = 0
    dir.z = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    local deadzone = .3    

    if math.abs(dir.x) >= deadzone or math.abs(dir.z) >= deadzone then    
        dir = dir:GetNormalized()             

        inst.lastreticuleangle = dir
    else
        if inst.lastreticuleangle then
            dir = inst.lastreticuleangle
        else 
            return nil
        end
    end

    local Camangle = TheCamera:GetHeading()/180        
    local theta = -PI *(0.5 - Camangle)

    local newx = dir.x * math.cos(theta) - dir.z *math.sin(theta)
    local newz = dir.x * math.sin(theta) + dir.z *math.cos(theta)

    pos.x = pos.x - (newx * range) 
    pos.z = pos.z - (newz * range) 

    return pos
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("boat.png")
    inst.entity:AddNetwork()

    inst:AddTag("ignorewalkableplatforms")

    local radius = 4
    local max_health = TUNING.BOAT.HEALTH

    local phys = inst.entity:AddPhysics()
    phys:SetMass(TUNING.BOAT.MASS)
    phys:SetFriction(0)
    phys:SetDamping(5)    
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)    
    phys:CollidesWith(COLLISION.OBSTACLES)   
    phys:SetCylinder(radius, 3) 
    --Boats currently need to not go to sleep because
    --constraints will cause a crash if either the target object or the source object is removed from the physics world    
    phys:SetDontRemoveOnSleep(true)           

    inst.AnimState:SetBank("boat_01")
    inst.AnimState:SetBuild("boat_test")
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
	inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst:AddComponent("walkableplatform")
    inst.components.walkableplatform.radius = radius

    inst:AddComponent("healthsyncer")    

    inst.components.healthsyncer.max_health = max_health

	AddConstrainedPhysicsObj(inst, SpawnPrefab("boat_item_collision")) -- hack until physics constraints are networked

    inst:AddComponent("waterphysics")
    inst.components.waterphysics.restitution = 1.75    

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ispassableatallpoints = true
    inst.on_start_steering = on_start_steering
    inst.on_stop_steering = on_stop_steering

	if not TheNet:IsDedicated() then
		-- dedicated server doesnt need to handle camera settings
		inst.StartBoatCamera = StartBoatCamera
		inst:ListenForEvent("obj_got_on_platform", OnObjGotOnPlatform)
		inst:ListenForEvent("obj_got_off_platform", OnObjGotOffPlatform)

        inst:ListenForEvent("endsteeringreticule", function(inst,data)  if ThePlayer and ThePlayer == data.player then inst:on_stop_steering() end end)
        inst:ListenForEvent("starsteeringreticule", function(inst,data) if ThePlayer and ThePlayer == data.player then inst:on_start_steering() end end)

        inst:AddComponent("boattrail")
	end

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("hull")
    inst.components.hull:SetRadius(radius)
    inst.components.hull:SetBoatLip(SpawnPrefab('boatlip'))
	inst.components.hull:AttachEntityToBoat(SpawnPrefab("boat_player_collision"), 0, 0)

    local walking_plank = SpawnPrefab("walkingplank")
    local edge_offset = -0.05
    inst.components.hull:AttachEntityToBoat(walking_plank, 0, radius + edge_offset, true)
    inst.components.hull:SetPlank(walking_plank)

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.WOOD
    inst.components.repairable.onrepaired = OnRepaired

    inst:AddComponent("hullhealth")
    inst:AddComponent("boatphysics")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(max_health)
    inst.components.health.nofadeout = true
	
	inst.activefires = 0

	local burnable_locator = SpawnPrefab('burnable_locator_medium')
	burnable_locator.boat = inst
	inst.components.hull:AttachEntityToBoat(burnable_locator, 0, 0, true)

	burnable_locator = SpawnPrefab('burnable_locator_medium')
	burnable_locator.boat = inst
	inst.components.hull:AttachEntityToBoat(burnable_locator, 2.5, 0, true)

	burnable_locator = SpawnPrefab('burnable_locator_medium')
	burnable_locator.boat = inst
	inst.components.hull:AttachEntityToBoat(burnable_locator, -2.5, 0, true)

	burnable_locator = SpawnPrefab('burnable_locator_medium')
	burnable_locator.boat = inst
	inst.components.hull:AttachEntityToBoat(burnable_locator, 0, 2.5, true)

	burnable_locator = SpawnPrefab('burnable_locator_medium')
	burnable_locator.boat = inst
	inst.components.hull:AttachEntityToBoat(burnable_locator, 0, -2.5, true)
	
    inst:SetStateGraph("SGboat")

    return inst
end

local function build_boat_collision_mesh(radius, height)
    local segment_count = 20
    local segment_span = math.pi * 2 / segment_count

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

local PLAYER_COLLISION_MESH = build_boat_collision_mesh(4.1, 3)
local ITEM_COLLISION_MESH = build_boat_collision_mesh(4.2, 3)

local function boat_player_collision_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.WORLD)
    phys:SetTriangleMesh(PLAYER_COLLISION_MESH)    

    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    return inst
end

local function boat_item_collision_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(1000)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:CollidesWith(COLLISION.WORLD)
    phys:SetTriangleMesh(ITEM_COLLISION_MESH)
    --Boats currently need to not go to sleep because
    --constraints will cause a crash if either the target object or the source object is removed from the physics world
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
    local boat = SpawnPrefab("boat")
    if boat ~= nil then
        boat.Physics:SetCollides(false)
        boat.Physics:Teleport(pt.x, 0, pt.z)
        boat.Physics:SetCollides(true)

        boat.sg:GoToState("place")
		
		boat.components.hull:OnDeployed()

        inst:Remove()
    end
end

local function item_fn()
    local inst = CreateEntity()

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

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LARGE)
    inst.components.deployable:SetDeployMode(DEPLOYMODE.WATER)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("boat", fn, assets, prefabs),
       Prefab("boat_player_collision", boat_player_collision_fn),
       Prefab("boat_item_collision", boat_item_collision_fn),
       Prefab("boat_item", item_fn, item_assets, item_prefabs),
       MakePlacer("boat_item_placer", "boat_01", "boat_test", "idle_full", true, false, false, nil, nil, nil, nil, 6)

