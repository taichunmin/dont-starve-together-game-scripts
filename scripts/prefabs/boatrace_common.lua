require("components/deployhelper") -- TriggerDeployHelpers lives here

-- Encapsulated Boatrace/TheWorld interactions
-- (seemed too minimal for a component, but could be moved to that)
local function RegisterBoatraceStart(startpoint)
    if not TheWorld then return end

    TheWorld._boatrace_starts = TheWorld._boatrace_starts or {}
    TheWorld._boatrace_starts[startpoint] = true
    TheWorld:ListenForEvent("onremove", function()
        TheWorld._boatrace_starts[startpoint] = nil
    end, startpoint)
end

--
local PLACER_SCALE = 1.38
local ARROW_PLACER_SCALE = 2.2
local ARROW_PLACER_SCALE_SQUARED = ARROW_PLACER_SCALE * ARROW_PLACER_SCALE
local ARROW_MAX_SCALE = (TUNING.MAX_BOATRACE_COMPONENT_DISTANCE / ARROW_PLACER_SCALE_SQUARED)

--************************************************************************ Deploy Helper arrow definition
local function CreateDeployHelperArrow()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("reticuleline2")
    inst.AnimState:SetBuild("reticuleline2")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0.0, 0.2, 0.5, 0.0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(0, 0)

    return inst
end

--
local function dsq_compare(c1, c2)
    return c1.dsq < c2.dsq
end

local DEPLOYHELPER_MAX_DISTANCE_SQUARED = (TUNING.MAX_BOATRACE_COMPONENT_DISTANCE * TUNING.MAX_BOATRACE_COMPONENT_DISTANCE) + 0.001
local function find_nearest_boatrace_start(source_position)
    if not TheWorld._boatrace_starts then return nil end

    local helper_x, helper_y, helper_z = source_position:Get()
    local boatrace_start_x, boatrace_start_y, boatrace_start_z, helper_to_component_dsq
    local boatrace_starts_by_dsq_table = {}
    for boatrace_start in pairs(TheWorld._boatrace_starts) do
        boatrace_start_x, boatrace_start_y, boatrace_start_z = boatrace_start.Transform:GetWorldPosition()
        helper_to_component_dsq = ((boatrace_start_x - helper_x) * (boatrace_start_x - helper_x))
            + ((boatrace_start_y - helper_y) * (boatrace_start_y - helper_y))
            + ((boatrace_start_z - helper_z) * (boatrace_start_z - helper_z))
        if helper_to_component_dsq > 0 and helper_to_component_dsq < DEPLOYHELPER_MAX_DISTANCE_SQUARED then
            table.insert(boatrace_starts_by_dsq_table, {dsq = helper_to_component_dsq, component = boatrace_start})
        end
    end

    table.sort(boatrace_starts_by_dsq_table, dsq_compare)
    return (#boatrace_starts_by_dsq_table > 0 and boatrace_starts_by_dsq_table[1]) or nil
end

--******************** Checkpoint deploy helper
local function DeployHelperArrow_OnUpdate(helperinst)
    if not helperinst.placerinst or not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(DeployHelperArrow_OnUpdate)
        helperinst.AnimState:SetAddColour(0,0,0,0)
        helperinst.AnimState:SetScale(0,0)
    else
        local hx, hy, hz = helperinst.Transform:GetWorldPosition()
        local px, py, pz = helperinst.placerinst.Transform:GetWorldPosition()
        local dsq_to_placer = distsq(hx, hz, px, pz)
        local distance_to_placer = math.sqrt(dsq_to_placer)
        local scale = distance_to_placer / ARROW_PLACER_SCALE_SQUARED
        if scale > ARROW_MAX_SCALE then
            helperinst.AnimState:SetAddColour(0,0,0,0)
            helperinst.AnimState:SetScale(0,0)
        else
            local num_steps = math.floor(distance_to_placer / TILE_SCALE)
            local Map = TheWorld.Map
            local placement_blocked = false
            if num_steps > 0 then
                local placer_to_helper_normal = Vector3(hx - px, 0, hz - pz) / distance_to_placer
                local test_x, test_z
                for i = 0, num_steps-1 do
                    test_x = px + placer_to_helper_normal.x * i * TILE_SCALE
                    test_z = pz + placer_to_helper_normal.z * i * TILE_SCALE
                    if not Map:IsOceanAtPoint(test_x, 0, test_z, true) then
                        placement_blocked = true
                        break
                    end
                end
            end

            helperinst.AnimState:SetScale(scale, 1.0)
            if placement_blocked then
                helperinst.AnimState:SetAddColour(0.9,0.2,0.2,0)
            else
                helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetMultColour())
            end
        end
        helperinst:ForceFacePoint(helperinst.placerinst.Transform:GetWorldPosition())
    end
end

local function OnEnableHelper(inst, enabled, _, placerinst)
    if enabled then
        if not inst.helper and not inst:HasTag("burnt") then
            inst.helper = CreateDeployHelperArrow()
            inst.helper.parent = inst
            inst.helper.entity:SetParent(inst.entity)
            if placerinst then
                local updatelooper = inst.helper:AddComponent("updatelooper")
                inst.helper.placerinst = placerinst
                updatelooper:AddOnUpdateFn(DeployHelperArrow_OnUpdate)
                DeployHelperArrow_OnUpdate(inst.helper)
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnStartHelper(inst, _, placerinst)
    local helper = inst.helper
    if not helper then return end

    if helper.placerinst ~= nil and helper.placerinst ~= placerinst then
        helper:Remove()
        inst.helper = nil
        inst.components.deployhelper:StopHelper()
    elseif placerinst ~= nil and not TheWorld.Map:IsOceanAtPoint(placerinst.Transform:GetWorldPosition()) then
        helper:Hide()
    else
        helper:Show()
    end
end

local function AddDeployHelper(inst, keyfilters)
    if TheNet:IsDedicated() then return end

    local deployhelper = inst:AddComponent("deployhelper")
    for _, key in pairs(keyfilters) do
        deployhelper:AddKeyFilter(key)
    end
    deployhelper.onenablehelper = OnEnableHelper
    deployhelper.onstarthelper = OnStartHelper
end

--******************** Throwable kit archetype definition
local function OnDeployKitThrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("kit_throw", true)

    local Physics = inst.Physics
    Physics:SetMass(1)
    Physics:SetFriction(0)
    Physics:SetDamping(0)
    Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    Physics:ClearCollisionMask()
    Physics:SetCollisionMask(COLLISION.GROUND)
    Physics:SetCapsule(0.2, 0.2)
end

local DEPLOY_IGNORE_TAGS = { "DECOR", "FX", "INLIMBO", "NOBLOCK", "player" }
local DEPLOYKIT_LAUNCH_OFFSET = Vector3(0.25, 1.00, 0.00)
local function CreateReticuleRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("winona_spotlight_placement")
    inst.AnimState:SetBuild("winona_spotlight_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    return inst
end

local KIT_FLOAT_DATA = {size="small", y_offset=0.1, scale=0.8}
local KIT_BURNABLE_DATA = {fuelvalue=TUNING.MED_FUEL}
local function MakeThrowableBoatRaceKitPrefabs(data)
    data = data or {}
    local product = data.prefab_to_deploy
    local kit_name = data.name or product.."_throwable_deploykit"
    local deploy_radius = data.deploy_radius or 0.5

    local asset_file_name = data.build or data.bank
    local assets =
    {
        Asset("ANIM", "anim/"..asset_file_name..".zip"),
        Asset("ANIM", "anim/reticuleline2.zip"),
        Asset("ANIM", "anim/winona_battery_placement.zip"),

        Asset("SCRIPT", "scripts/prefabs/boatrace_common.lua"),
    }

    local function ThrowableKit_CommonPostInit(inst)
        inst:AddTag("projectile")

		inst.CanTossInWorld = data.extradeploytest

        if data.common_postinit then
            data.common_postinit(inst)
        end
    end

    local function OnDeployKitLanded(inst, attacker, _)
        local x, y, z = inst.Transform:GetWorldPosition()
        local _map = TheWorld.Map

        if not TheWorld.Map:IsValidTileAtPoint(x, y, z) then
            -- This would happen automatically in the inventoryitem component,
            -- except that it's delayed by a frame, so we need to explicitly call it
            -- to avoid spawning an extra item.
            SinkEntity(inst)
            return
        end

        local deployed_successfully = _map:IsOceanAtPoint(x, y, z)
            and not FindEntity(inst, deploy_radius, nil, nil, DEPLOY_IGNORE_TAGS)
			and (not data.extradeploytest or data.extradeploytest(inst, attacker, inst:GetPosition()))

        if deployed_successfully then
            SpawnPrefab("splash_green").Transform:SetPosition(x, y, z)

            local product_instance = SpawnPrefab(product)
            product_instance.Transform:SetPosition(x, y, z)
            product_instance:PushEvent("onbuilt", {builder = attacker, pos = Vector3(x, y, z)})
            if data.product_fn then
                data.product_fn(product_instance, inst)
            end
        else
            -- If we failed to deploy, just respawn ourselves
            -- instead of trying to undo the OnThrown function.
            local kit = SpawnPrefab(inst.prefab)
            kit.Transform:SetPosition(x, y, z)
            kit.components.inventoryitem:SetLanded(true, false)
            if data.deployfailed_fn then
                data.deployfailed_fn(kit, inst)
            end
        end

        inst:Remove()
    end

    local function ThrowableKit_PrimaryPostInit(inst)
        local complexprojectile = inst:AddComponent("complexprojectile")
        complexprojectile:SetHorizontalSpeed(TUNING.BOATRACE_THROWABLE_DEPLOY_LAUNCHSPEED)
        complexprojectile:SetGravity(TUNING.BOATRACE_THROWABLE_DEPLOY_GRAVITY)
        complexprojectile:SetLaunchOffset(DEPLOYKIT_LAUNCH_OFFSET)
        complexprojectile:SetOnLaunch(OnDeployKitThrown)
        complexprojectile:SetOnHit(OnDeployKitLanded)

        if data.primary_postinit then
            data.primary_postinit(inst)
        end
    end

    local kit_prefab_definition = MakeDeployableKitItem(
        kit_name, product, data.bank,
        asset_file_name, data.anim or "idle",
        assets, KIT_FLOAT_DATA, data.tags,
        KIT_BURNABLE_DATA,
        {
            deploymode = DEPLOYMODE.WATER,
            deployspacing = DEPLOYSPACING.LESS,
            deploytoss_symbol_override = {build = asset_file_name, symbol = "swap_object"},
            common_postinit = ThrowableKit_CommonPostInit,
            master_postinit = ThrowableKit_PrimaryPostInit,
        }
    )

    -----
    local function PostInit_AddReticuleRing(inst)
        local reticule_ring = CreateReticuleRing()

        local reticule_ring_scale = PLACER_SCALE * (data.reticule_ring_scale or 1.0)
        reticule_ring.AnimState:SetScale(reticule_ring_scale, reticule_ring_scale)

        inst:AddChild(reticule_ring)
    end

    local function placer_onupdatetransform(inst)
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        TriggerDeployHelpers(ix, iy, iz, 64, product, inst)
    end

	local placer_override_testfn = data.extradeploytest and function(inst)
		local pos = inst:GetPosition()
		if inst.components.placer.testfn then
			local can_build, mouse_blocked = inst.components.placer.testfn(pos, inst:GetRotation())
			if not can_build then
				return false, mouse_blocked
			end
		end
		return data.extradeploytest(inst, ThePlayer, inst:GetPosition()), false
	end or nil

    local function placer_postinit(inst)
		inst.components.placer.override_testfn = placer_override_testfn
        inst.components.placer.onupdatetransform = placer_onupdatetransform

        inst.deployhelper_key = product

        if data.do_reticule_ring then
            PostInit_AddReticuleRing(inst)
        end

        if data.placer_postinit then
            data.placer_postinit(inst)
        end
    end

    local placer_prefab_definition = MakePlacer(
        kit_name.."_placer", data.bank, asset_file_name, "placer",
        nil, nil, nil, nil, nil, nil,
        placer_postinit, 6.5
    )

    return kit_prefab_definition, placer_prefab_definition
end

local SHADOWBOATSPAWN_NUMCHECKS = 6
local function BoatSpawnCheck(pos, radius, allow_boats)
    radius = radius or TUNING.DRAGON_BOAT_RADIUS
    local sin, cos = math.sin, math.cos
    local px, py, pz = pos:Get()
    local angle_per_check = TWOPI/SHADOWBOATSPAWN_NUMCHECKS
    local angle

    for i = 1, SHADOWBOATSPAWN_NUMCHECKS do
        angle = i * angle_per_check
        local x, z = px + radius * cos(angle), pz + radius * sin(angle)

        if not TheWorld.Map:IsOceanAtPoint(x, py, z, allow_boats or false) then
            return false
        end
    end
    return true
end

local function CheckpointSpawnCheck(pos)
    local can_fit_boats = BoatSpawnCheck(pos, (2 * TUNING.DRAGON_BOAT_RADIUS) + 0.5, true)
    if not can_fit_boats then return false end

    local boatrace_start_distance_sq = TUNING.BOATRACE_START_INCLUSION_PROXIMITY * TUNING.BOATRACE_START_INCLUSION_PROXIMITY
    if TheWorld._boatrace_starts then
        -- Fail if we're too close to one of the boatrace start points.
        for boatrace_start in pairs(TheWorld._boatrace_starts) do
            if distsq(pos, boatrace_start:GetPosition()) < boatrace_start_distance_sq then
                return false
            end
        end
    end

    return true
end

--
return
{
    RegisterBoatraceStart = RegisterBoatraceStart,

    AddDeployHelper = AddDeployHelper,

    NearestBoatRaceStart = find_nearest_boatrace_start,

    MakeThrowableBoatRaceKitPrefabs = MakeThrowableBoatRaceKitPrefabs,

    BoatSpawnCheck = BoatSpawnCheck,
    CheckpointSpawnCheck = CheckpointSpawnCheck,
}