require("components/raindome") --load some global functions defined for this component
require("components/temperatureoverrider") --load some global functions defined for this component

local GroundTiles = require("worldtiledefs")

--require_health being true means an entity is considered "dead" if it lacks the health replica.
function IsEntityDead(inst, require_health)
	local health = inst.replica.health
	if health == nil then
        return require_health == true
    end
	return health:IsDead()
end

function IsEntityDeadOrGhost(inst, require_health)
    if inst:HasTag("playerghost") then
        return true
    end
    return IsEntityDead(inst, require_health)
end

function GetStackSize(inst)
	local stackable = inst.replica.stackable
	return stackable and stackable:StackSize() or 1
end

function HandleDugGround(dug_ground, x, y, z)
    local spawnturf = GroundTiles.turf[dug_ground] or nil
    if spawnturf ~= nil then
        local loot = SpawnPrefab("turf_"..spawnturf.name)
        if loot.components.inventoryitem ~= nil then
			loot.components.inventoryitem:InheritWorldWetnessAtXZ(x, z)
        end
        loot.Transform:SetPosition(x, y, z)
        if loot.Physics ~= nil then
            local angle = math.random() * TWOPI
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
        end
    else
        SpawnPrefab("sinkhole_spawn_fx_"..tostring(math.random(3))).Transform:SetPosition(x, y, z)
    end
end

local VIRTUALOCEAN_HASTAGS = {"virtualocean"}
local VIRTUALOCEAN_CANTTAGS = {"INLIMBO"}
function FindVirtualOceanEntity(x, y, z, r)
    local ents = TheSim:FindEntities(x, y, z, r or MAX_PHYSICS_RADIUS, VIRTUALOCEAN_HASTAGS, VIRTUALOCEAN_CANTTAGS)
    for _, ent in ipairs(ents) do
        if ent.Physics ~= nil then
            local radius = ent.Physics:GetRadius()
            local ex, ey, ez = ent.Transform:GetWorldPosition()
            local dx, dz = ex - x, ez - z
            if dx * dx + dz * dz <= radius * radius then
                return ent
            end
        end
    end

    return nil
end

--------------------------------------------------------------------------
--Tags useful for testing against combat targets that you can hit,
--but aren't really considered "alive".

NON_LIFEFORM_TARGET_TAGS =
{
	"structure",
	"wall",
	"balloon",
	"groundspike",
	"smashable",
	"veggie", --stuff like lureplants... not considered life?
}

--Shadows and Gestalts don't have souls.
--NOTE: -Adding "soulless" tag to entities is preferred over expanding this list.
--      -Gestalts should already be using "soulless" tag.
--Lifedrain (batbat) also uses this list.
SOULLESS_TARGET_TAGS = ConcatArrays(
	{
		"soulless",
		"chess",
		"shadow",
		"shadowcreature",
		"shadowminion",
		"shadowchesspiece",
	},
	NON_LIFEFORM_TARGET_TAGS
)

--------------------------------------------------------------------------
function DecayCharlieResidueAndGoOnCooldownIfItExists(inst)
    local roseinspectableuser = inst.components.roseinspectableuser
    if roseinspectableuser == nil then
        return
    end
    roseinspectableuser:ForceDecayResidue()
    roseinspectableuser:GoOnCooldown()
end
function DecayCharlieResidueIfItExists(inst)
    local roseinspectableuser = inst.components.roseinspectableuser
    if roseinspectableuser == nil then
        return
    end
    roseinspectableuser:ForceDecayResidue()
end

local function OnFuelPresentation3(inst)
    inst:ReturnToScene()
    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem:OnDropped(true, .5)
    end
end
local function OnFuelPresentation2(inst, x, z, upgraded)
    local fx = SpawnPrefab(upgraded and "shadow_puff_solid" or "shadow_puff")
    fx.Transform:SetPosition(x, 0, z)
    inst:DoTaskInTime(3 * FRAMES, OnFuelPresentation3)
end
local function OnFuelPresentation1(inst, x, z, upgraded)
    local fx = SpawnPrefab((upgraded or TheWorld:HasTag("cave")) and "charlie_snap_solid" or "charlie_snap")
    fx.Transform:SetPosition(x, 2, z)
    inst:DoTaskInTime(25 * FRAMES, OnFuelPresentation2, x, z, upgraded)
end
local function OnResidueActivated_Fuel_Internal(inst, doer, odds)
    local skilltreeupdater = doer.components.skilltreeupdater
    local upgraded = skilltreeupdater and skilltreeupdater:IsActivated("winona_charlie_2") and math.random() < odds or nil
    local fuel = SpawnPrefab(upgraded and "horrorfuel" or "nightmarefuel")
    fuel:RemoveFromScene()
    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = inst:GetPhysicsRadius(0)
    if radius > 0 then
        radius = radius + 1.5
    end
    local theta = math.random() * PI2
    x, z = x + math.cos(theta) * radius, z + math.sin(theta) * radius
    fuel.Transform:SetPosition(x, 0, z)
    fuel:DoTaskInTime(0.5, OnFuelPresentation1, x, z, upgraded)
end
local function OnResidueActivated_Fuel(inst, doer)
    OnResidueActivated_Fuel_Internal(inst, doer, TUNING.SKILLS.WINONA.ROSEGLASSES_UPGRADE_CHANCE)
end
local function OnResidueActivated_Fuel_IncreasedHorror(inst, doer)
    OnResidueActivated_Fuel_Internal(inst, doer, TUNING.SKILLS.WINONA.ROSEGLASSES_UPGRADE_CHANCE_INCREASED)
end
function MakeRoseTarget_CreateFuel(inst)
    local roseinspectable = inst:AddComponent("roseinspectable")
    roseinspectable:SetOnResidueActivated(OnResidueActivated_Fuel)
    roseinspectable:SetForcedInduceCooldownOnActivate(true)
end
function MakeRoseTarget_CreateFuel_IncreasedHorror(inst)
    local roseinspectable = inst:AddComponent("roseinspectable")
    roseinspectable:SetOnResidueActivated(OnResidueActivated_Fuel_IncreasedHorror)
    roseinspectable:SetForcedInduceCooldownOnActivate(true)
end
--------------------------------------------------------------------------
local function RosePoint_VineBridge_Check_HandleOverhangs(sx, sz, TILE_SCALE, _map) -- Internal.
    -- If a point lays on an overhang we need to adjust it so that it is not on an overhang by reflecting it over the tile border first.
    local cx, cy, cz = _map:GetTileCenterPoint(sx, 0, sz)
    local dx, dz = cx - sx, cz - sz
    local signdx, signdz = dx < 0 and -1 or 1, dz < 0 and -1 or 1
    local absdx, absdz = math.abs(dx), math.abs(dz)
    local ishorizontal = absdx > absdz
    local rsx, rsz, dirx, dirz
    if ishorizontal then
        rsx = sx + 2 * (absdx - TILE_SCALE * 0.5) * signdx
        rsz = sz
        dirx = signdx * TILE_SCALE
        dirz = 0
    else
        rsx = sx
        rsz = sz + 2 * (absdz - TILE_SCALE * 0.5) * signdz
        dirx = 0
        dirz = signdz * TILE_SCALE
    end
    if _map:IsLandTileAtPoint(rsx, 0, rsz) then
        return rsx, rsz, dirx, dirz
    end

    -- We have reflected from an overhang onto another overhang along a coastline fallback to rectangle direction.
    if not ishorizontal then -- Flip the logic so the reflection happens in the opposite direction.
        rsx = sx + 2 * (absdx - TILE_SCALE * 0.5) * signdx
        rsz = sz
        dirx = signdx * TILE_SCALE
        dirz = 0
    else
        rsx = sx
        rsz = sz + 2 * (absdz - TILE_SCALE * 0.5) * signdz
        dirx = 0
        dirz = signdz * TILE_SCALE
    end
    if _map:IsLandTileAtPoint(rsx, 0, rsz) then
        return rsx, rsz, dirx, dirz
    end

    -- We are on a corner of a tile reflect both points so we are on the solid tile first and then use non-overhang protocols.
    rsx = sx + 2 * (absdx - TILE_SCALE * 0.5) * signdx
    rsz = sz + 2 * (absdz - TILE_SCALE * 0.5) * signdz
    return rsx, rsz, nil, nil
end
local function RosePoint_VineBridge_Check_HandleGround(sx, sz, TILE_SCALE, _map) -- Internal.
    -- We are on a ground tile so we will first do a diamond direction check first and then a rectangle fallback.
    local cx, cy, cz = _map:GetTileCenterPoint(sx, 0, sz)
    local dx, dz = cx - sx, cz - sz
    local signdx, signdz = dx < 0 and -1 or 1, dz < 0 and -1 or 1
    local absdx, absdz = math.abs(dx), math.abs(dz)
    local ishorizontal = absdx > absdz
    local rsx, rsz, dirx, dirz
    if ishorizontal then
        rsx = sx + 2 * (absdx - TILE_SCALE * 0.5) * signdx
        rsz = sz
        dirx = -signdx * TILE_SCALE
        dirz = 0
    else
        rsx = sx
        rsz = sz + 2 * (absdz - TILE_SCALE * 0.5) * signdz
        dirx = 0
        dirz = -signdz * TILE_SCALE
    end
    if _map:IsOceanTileAtPoint(rsx, 0, rsz) then
        return dirx, dirz
    end

    -- Check the other adjacent diagonal path.
    if not ishorizontal then
        rsx = sx + 2 * (absdx - TILE_SCALE * 0.5) * signdx
        rsz = sz
        dirx = -signdx * TILE_SCALE
        dirz = 0
    else
        rsx = sx
        rsz = sz + 2 * (absdz - TILE_SCALE * 0.5) * signdz
        dirx = 0
        dirz = -signdz * TILE_SCALE
    end
    if _map:IsOceanTileAtPoint(rsx, 0, rsz) then
        return dirx, dirz
    end

    -- We are too far in land for tiles to be able to be chosen.
    return nil, nil
end
local function RosePoint_VineBridge_StopVinesToTile(tile)
    return TileGroupManager:IsTemporaryTile(tile) and tile ~= WORLD_TILES.FARMING_SOIL
end
local function RosePoint_VineBridge_Check(inst, pt)
    local _world = TheWorld
    if _world.ismastersim then
        local vinebridgemanager = _world.components.vinebridgemanager
        if vinebridgemanager == nil then
            return false
        end
    end

    local _map = _world.Map
    local TILE_SCALE = TILE_SCALE
    local maxlength = TUNING.SKILLS.WINONA.CHARLIE_VINEBRIDGE_LENGTH_TILES

    -- NOTES(JBK): We want the player position to not be involved for the bridge construction at all.
    -- So we will need to transform the point into a position that makes the most sense given the geometric nature of tiles.
    local sx, sy, sz = pt:Get()
    local dirx, dirz

    if _map:IsOceanTileAtPoint(sx, 0, sz) and _map:IsVisualGroundAtPoint(sx, 0, sz) then
        sx, sz, dirx, dirz = RosePoint_VineBridge_Check_HandleOverhangs(sx, sz, TILE_SCALE, _map)
    end
    
    if dirx == nil then
        if not _map:IsLandTileAtPoint(sx, 0, sz) then
            return false
        end

        dirx, dirz = RosePoint_VineBridge_Check_HandleGround(sx, sz, TILE_SCALE, _map)
    end

    if dirx == nil then
        return false
    end

    local tile = _map:GetTileAtPoint(sx, 0, sz)
    if RosePoint_VineBridge_StopVinesToTile(tile) then
        return false
    end

    -- We now have a valid direction and starting point align our tile ray trace to tile coordinates finally.
    sx, sy, sz = _map:GetTileCenterPoint(sx, 0, sz)

    -- Scan for land.
    local hitland = false
    local spots = {}
    for i = 0, maxlength do -- Intentionally 0 to max to have a + 1 for the end tile cap inclusion.
        sx, sz = sx + dirx, sz + dirz

        local pt_offseted = Point(sx, 0, sz)
        local tile_current = _map:GetTileAtPoint(sx, 0, sz)
        if TileGroupManager:IsLandTile(tile_current) then
            hitland = not RosePoint_VineBridge_StopVinesToTile(tile_current)
            break
        end

        if not _map:CanDeployDockAtPoint(pt_offseted, inst) then
            return false
        end

        table.insert(spots, pt_offseted)
    end

    if not hitland or spots[1] == nil then
        return false
    end

    spots.direction = {x = dirx, z = dirz,}

    return true, spots
end
local function RosePoint_VineBridge_Do(inst, pt, spots)
    local vinebridgemanager = TheWorld.components.vinebridgemanager
    local duration = TUNING.VINEBRIDGE_DURATION
    local breakdata = {}
    local spawndata = {
        base_time = 0.5,
        random_time = 0.0,
        direction = spots.direction,
    }
    for i, spot in ipairs(spots) do
        spawndata.base_time = 0.25 * i
        vinebridgemanager:QueueCreateVineBridgeAtPoint(spot.x, spot.y, spot.z, spawndata)
        breakdata.fxtime = duration + 0.25 * i
        breakdata.shaketime = breakdata.fxtime - 1
        breakdata.destroytime = breakdata.fxtime + 70 * FRAMES
        vinebridgemanager:QueueDestroyForVineBridgeAtPoint(spot.x, spot.y, spot.z, breakdata)
    end
    return true
end
-- NOTES(JBK): Functions and names for CLOSEINSPECTORUTIL checks.
-- The order of priority is defined by what is present in this table use the contextname to table.insert new ones.
ROSEPOINT_CONFIGURATIONS = {
    {
        contextname = "Vine Bridge",
        checkfn = RosePoint_VineBridge_Check,
        callbackfn = RosePoint_VineBridge_Do,
        --forcedcooldown = nil,
        --cooldownfn = nil,
    },
}
--------------------------------------------------------------------------
--closeinspector

CLOSEINSPECTORUTIL = {}

CLOSEINSPECTORUTIL.IsValidTarget = function(doer, target)
    if TheWorld.ismastersim then
        return not (
            (target.Physics and target.Physics:GetMass() ~= 0) or
            target.components.locomotor or
            target.components.inventoryitem or
            target:HasTag("character")
        )
    else
        return not (
            (target.Physics and target.Physics:GetMass() ~= 0) or
            target:HasTag("locomotor") or
            target.replica.inventoryitem or
            target:HasTag("character")
        )
    end
end

CLOSEINSPECTORUTIL.IsValidPos = function(doer, pos)
    local is_cooldown_rose = true
    local player_classified = doer.player_classified
    if player_classified then
        is_cooldown_rose = player_classified.roseglasses_cooldown:value()
    end
    for _, config in ipairs(ROSEPOINT_CONFIGURATIONS) do
        local will_cooldown = false
        if config.forcedcooldown ~= nil then
            will_cooldown = config.forcedcooldown
        elseif config.cooldownfn ~= nil then
            will_cooldown = config.cooldownfn(self.inst, self.point, data)
        end
        if not will_cooldown or (will_cooldown and not is_cooldown_rose) then
            if config.checkfn(doer, pos) then
                return true
            end
        end
    end

    return false
end

CLOSEINSPECTORUTIL.CanCloseInspect = function(doer, targetorpos)
	if doer == nil then
		return false
	elseif TheWorld.ismastersim then
		if not (doer.components.inventory and doer.components.inventory:EquipHasTag("closeinspector")) or
			(doer.components.rider and doer.components.rider:IsRiding())
		then
			return false
		end
	else
		local inventory = doer.replica.inventory
		if not (inventory and inventory:EquipHasTag("closeinspector")) then
			return false
		end
		local rider = doer.replica.rider
		if rider and rider:IsRiding() then
			return false
		end
	end

	if targetorpos:is_a(EntityScript) then
		return targetorpos:IsValid() and CLOSEINSPECTORUTIL.IsValidTarget(doer, targetorpos)
	end
	return CLOSEINSPECTORUTIL.IsValidPos(doer, targetorpos)
end

--------------------------------------------------------------------------
