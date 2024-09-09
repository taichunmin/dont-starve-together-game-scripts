--------------------------------------------------------------------------
--[[ sharkboimanager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)
local _world = TheWorld
local _map = _world.Map

assert(_world.ismastersim, "sharkboimanager should not exist on client")

--self.updatenetvarstask = nil
local function UpdateNetvars(inst)
    if self.updatenetvarstask ~= nil then -- Let this function repeat entry safe.
        self.updatenetvarstask:Cancel()
        self.updatenetvarstask = nil
    end

    if _world.net == nil or _world.net.components.sharkboimanagerhelper == nil then
        self.updatenetvarstask = inst:DoTaskInTime(0, UpdateNetvars) -- Reschedule.
        return
    end
    local sharkboimanagerhelper = _world.net.components.sharkboimanagerhelper
    if self.arena == nil then
        sharkboimanagerhelper.arena_origin_x:set(0)
        sharkboimanagerhelper.arena_origin_z:set(0)
        sharkboimanagerhelper.arena_radius:set(0)
        return
    end
    sharkboimanagerhelper.arena_origin_x:set(self.arena.origin.x)
    sharkboimanagerhelper.arena_origin_z:set(self.arena.origin.z)
    sharkboimanagerhelper.arena_radius:set(self.arena.radius)
end

self.inst = inst
--self.arena = nil
self.fishingplayertasks = {} -- Temp data do not save.
self.defaultfishprefab = "oceanfish_medium_2"

-- NOTES(JBK): If these ARENA_SIZE variables change make sure TUNING.SHARKBOI_DEAGGRO_DIST is adjusted as well to compensate for when this component does not exist.
self.MAX_ARENA_SIZE = 6 * TILE_SCALE -- This is less than GOOD_ARENA_SQUARE_SIZE where this constant is the max.
self.MAX_ARENA_SIZE_RADIUS_BIAS = -0.5 -- Offset for checking radials, in tile units.
self.MIN_ARENA_SIZE = 2.5 * TILE_SCALE

self.STATES = {
    UNDEFINED = 0, -- If the game loads this in it will go to CLEANUP to make the arena start going away.
    CREATINGARENA = 1,
    CREATEDARENA = 2,
    BOSSSPAWNED = 3,
    BOSSFIGHTING = 4,
    CLEANUP = 5,
}
function self:GetArenaStateString()
    if self.arena == nil then
        return "UNDEFINED"
    end

    for statename, stateid in pairs(self.STATES) do
        if self.arena.state == stateid then
            return statename
        end
    end

    return "UNDEFINED"
end


local function Sort_SmallestRadiusFirst(a, b)
    if a.r ~= b.r then
        return a.r < b.r
    end

    if a.dx ~= b.dx then
        return a.dx < b.dx
    end

    return a.dz < b.dz
end
function self:CreateTileOffsetCache(r) -- This is used for quickly iterating over all potential arena tiles.
    -- NOTES(JBK): This could be optimized to be more efficient than a circle allow pass in a square and then a sort.
    local cache = {}
    local scale = TILE_SCALE
    r = math.floor(r / scale)
    local rsq = (r + self.MAX_ARENA_SIZE_RADIUS_BIAS) * (r + self.MAX_ARENA_SIZE_RADIUS_BIAS)
    for dx = -r, r do
        for dz = -r, r do
            local testrsq = dx * dx + dz * dz
            if testrsq <= rsq then
                table.insert(cache, {dx = dx * scale, dz = dz * scale, r = math.sqrt(testrsq) * scale,})
            end
        end
    end
    table.sort(cache, Sort_SmallestRadiusFirst)
    return cache
end
self.TILEOFFSET_CACHE = self:CreateTileOffsetCache(self.MAX_ARENA_SIZE)

function self:ForEachTileInBetween(min_radius, max_radius, fn)
    local x, y, z = self.arena.origin.x, self.arena.origin.y, self.arena.origin.z
    for _, v in ipairs(self.TILEOFFSET_CACHE) do
        if v.r >= min_radius then
            if v.r > max_radius then
                return -- No other tile will be bigger because of the sorting.
            end

            fn(self, x + v.dx, y, z + v.dz)
        end
    end
end

function self:FindWalkableOffsetInArena(sharkboi)
    if self.arena == nil then
        return nil
    end

    if sharkboi and self.arena.sharkbois[sharkboi] == nil then
        return nil
    end

    local offset
    for i = math.floor(self.arena.radius), 1, -TILE_SCALE do
        offset = FindWalkableOffset(self.arena.origin, math.random() * TWOPI, i, 16, false, false)
        if offset then
            break
        end
    end

    return offset ~= nil and (self.arena.origin + offset) or self.arena.origin
end

function self:GetDesiredArenaRadius()
    if self.arena.pauseshrink_hack then -- HACK(JBK): This.
        return self.arena.radius
    end

    local state = self.arena.state
    if state == self.STATES.BOSSFIGHTING then
        return math.max(self.arena.radius - TUNING.SHARKBOI_ARENA_SHRINK_DISTANCE, self.MIN_ARENA_SIZE)
    elseif state == self.STATES.CLEANUP then
        return math.max(self.arena.radius - TUNING.SHARKBOI_ARENA_SHRINK_DISTANCE, 0)
    elseif state == self.STATES.CREATINGARENA then
        return _world.state.iswinter and self.MAX_ARENA_SIZE or self.MIN_ARENA_SIZE
    end

    if self.arena.desiredradius then
        if self.arena.desiredradius < self.arena.radius then
            return math.max(self.arena.radius - TUNING.SHARKBOI_ARENA_SHRINK_DISTANCE, self.arena.desiredradius)
        else
            return math.min(self.arena.radius + TUNING.SHARKBOI_ARENA_SHRINK_DISTANCE, self.arena.desiredradius)
        end
    end

    return self.arena.radius or _world.state.iswinter and self.MAX_ARENA_SIZE or self.MIN_ARENA_SIZE
end

local function hack_allow_shrinking()
    self._hack_task = nil
    self.arena.pauseshrink_hack = nil
end
function self:PauseArenaShrinking_Hack()
    if self._hack_task ~= nil then
        self._hack_task:Cancel()
        self._hack_task = nil
    end
    self.arena.pauseshrink_hack = true
    self._hack_task = self.inst:DoTaskInTime(85*FRAMES, hack_allow_shrinking)
end

function self:IsPointInArena(x, y, z)
    if self.arena == nil then
        return false
    end

    local dx, dz = x - self.arena.origin.x, z - self.arena.origin.z
    local dsq = dx * dx + dz * dz
    local r = math.ceil(self.arena.radius / TILE_SCALE) * TILE_SCALE * SQRT2
    return dsq < r * r and _map:IsVisualGroundAtPoint(x, y, z)
end

function self:SetArenaState(state)
    local oldstate = self.arena.state
    assert(oldstate < state) -- Only allow state values to go up and must change.
    self.arena.state = state

    if oldstate == self.STATES.UNDEFINED then
        -- From a load meaning this should only hook up things needed.
        if state == self.STATES.CREATINGARENA then
            -- There has been a delay due to a save/load cycle in the one frame so finish the arena creation now.
            self:SetArenaState(self.STATES.CREATEDARENA)
        end
    else
        -- From a gameplay meaning this should activate creation of things.
        if state == self.STATES.CREATEDARENA then
            self:ArenaFinishCreating()
        elseif state == self.STATES.BOSSSPAWNED then
            self:SpawnBoss()
        end
    end

    -- Both meaning this can happen from load or gameplay.
    if state == self.STATES.BOSSFIGHTING then
        if self.arena.fishinghole then -- Delete the fishing hole.
            local x, _, z = self.arena.fishinghole.Transform:GetWorldPosition()
            SpawnPrefab("splash_green_large").Transform:SetPosition(x, 0, z)
            self.arena.fishinghole:Remove() -- Automatically nils.
        end
        self:StartShrinking()
    elseif state == self.STATES.CLEANUP then
        self:StopShrinking()
        self:StartCleanup()
    end
end
local function SetArenaState_Bridge(inst, state)
    self:SetArenaState(state)
end

function self:SetDesiredArenaRadius(radius)
    self.arena.radius = math.clamp(radius or self:GetDesiredArenaRadius(), 0, self.MAX_ARENA_SIZE)
    UpdateNetvars(_world)
end

function self:StopShrinking()
    if self.shrinkingtask ~= nil then
        self.shrinkingtask:Cancel()
        self.shrinkingtask = nil
    end
end

function self:DoShrink()
    if self.arena.pauseshrink_hack then
        return
    end

    local newradius = self:GetDesiredArenaRadius()
    if newradius < self.arena.radius then
        self:ForEachTileInBetween(newradius, self.arena.radius, self.DestroyIceTileAtPoint)
        self:SetDesiredArenaRadius(newradius)
    else
        self:StopShrinking()
    end
end

local function DoShrink_Bridge(inst)
    self:DoShrink()
end

function self:StartShrinking()
    self:StopShrinking()
    self.shrinkingtask = self.inst:DoPeriodicTask(TUNING.SHARKBOI_ARENA_SHRINK_TICK_TIME, DoShrink_Bridge)
end

function self:StopCleanup()
    if self.cleanuptask ~= nil then
        self.cleanuptask:Cancel()
        self.cleanuptask = nil
    end
end

function self:DoCleanup()
    local newradius = self:GetDesiredArenaRadius()
    if newradius < self.arena.radius then
        self:ForEachTileInBetween(newradius, self.arena.radius, self.DestroyIceTileAtPoint)
        self:SetDesiredArenaRadius(newradius)
        _world:PushEvent("ms_cleanupticksharkboiarena")
    else
        self:ForceCleanup()
    end
end

local function DoCleanup_Bridge(inst)
    self:DoCleanup()
end

function self:StartCleanup()
    self:StopCleanup()
    self.shrinkingtask = self.inst:DoPeriodicTask(TUNING.SHARKBOI_ARENA_SHRINK_TICK_TIME, DoCleanup_Bridge)
end

local function TryToMakeArenaBig_Bridge(inst)
    self:TryToMakeArenaBig()
end

local BOAT_MUST_TAGS = {"boat",}
function self:TryToMakeArenaBig()
    if self.arena == nil then
        return
    end

    local state = self.arena.state
    local cangrow = state == self.STATES.CREATEDARENA or state == self.STATES.BOSSSPAWNED
    if not cangrow then
        return
    end

    if self.arena.radius >= self.MAX_ARENA_SIZE then
        return
    end

    local x, y, z = self.arena.origin.x, self.arena.origin.y, self.arena.origin.z
    local r = self.arena.radius + PLAYER_CAMERA_SEE_DISTANCE
    if IsAnyPlayerInRange(x, y, z, r) then
        -- Schedule timer to retry.
        self.inst:DoTaskInTime(5, TryToMakeArenaBig_Bridge)
        return
    end
    
    -- Spawn ice.
    self:ForEachTileInBetween(self.arena.radius, self.MAX_ARENA_SIZE, self.CreateIceTileAtPoint)

    -- Break boats.
    local boats = TheSim:FindEntities(x, y, z, self.MAX_ARENA_SIZE + 2 * SQRT2, BOAT_MUST_TAGS) -- + 2 * SQRT2 for edge padding on tile corners.
    for _, boat in ipairs(boats) do
        local bx, by, bz = boat.Transform:GetWorldPosition()

        if boat:IsBoatEdgeOverLand() then
            boat:InstantlyBreakBoat()
        end
    end

    -- Spawn entities.
    -- FIXME(JBK): Tile physics do not update on creation these decorations will be colliding on spawn and need a delay.
    self:ForEachTileInBetween(self.arena.radius, self.MAX_ARENA_SIZE, self.CreateEntityDecorationsAtPoint)
    self:SetDesiredArenaRadius(self.MAX_ARENA_SIZE)
end

function self:TryToMakeArenaSmall()
    local state = self.arena.state
    if state == self.STATES.CREATEDARENA or state == self.STATES.BOSSSPAWNED then
        self.arena.desiredradius = self.MIN_ARENA_SIZE
        self:StartShrinking()
    end
end

self.OnCooldownEnd = function(world)
    self.arena.cooldowntask = nil
    self:ForceCleanup()
    self.arena = nil
    UpdateNetvars(_world)
    self:FindAndPlaceOceanArenaOverTime()
end

function self:CooldownArena()
    if self.arena.cooldowntask ~= nil then
        self.arena.cooldowntask:Cancel()
        self.arena.cooldowntask = nil
    end
    self.arena.cooldowntask = self.inst:DoTaskInTime(TUNING.SHARKBOI_ARENA_COOLDOWN_DAYS, self.OnCooldownEnd)
end

function self:ForceCleanup()
    -- Stop periodic timers.
    self:StopShrinking()
    self:StopCleanup()

    -- Break any ice remaining.
    self:ForEachTileInBetween(0, self.MAX_ARENA_SIZE, self.DestroyIceTileAtPoint)

    -- Delete entities.
    if self.arena.fishinghole then
        self.arena.fishinghole:Remove() -- Automatically nils.
    end
    if self.arena.sharkbois then
        for sharkboi, _ in pairs(self.arena.sharkbois) do
            sharkboi:Remove() -- Automatically nils.
        end
    end

    _world:PushEvent("ms_cleanedupsharkboiarena")
end

function self:GetFishPrefab()
    if self.arena == nil then
        return self.defaultfishprefab
    end

    local schoolspawner = _world.components.schoolspawner
    if schoolspawner == nil then
        return self.defaultfishprefab
    end

    local fishprefab = schoolspawner:GetFishPrefabAtPoint(self.arena.origin)
    if fishprefab == nil then
        return self.defaultfishprefab
    end

    return fishprefab
end

function self:StopPlayerFishingTick(inst)
    if self.fishingplayertasks[inst] ~= nil then
        self.fishingplayertasks[inst]:Cancel()
        self.fishingplayertasks[inst] = nil
    end
end

self.PUNT_MUST_TAGS = {"_combat"}
self.PUNT_CANT_TAGS = {"INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "epic"}
function self:SpawnBoss()
    -- Catch any fish on player lines before removing the fishinghole.
    local fishingplayers = {} -- Copy for safe table iteration.
    for player, _ in pairs(self.fishingplayertasks) do
        table.insert(fishingplayers, player)
    end
    for _, player in ipairs(fishingplayers) do
        local rod = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if rod ~= nil and rod.components.oceanfishingrod ~= nil then
            local target = rod.components.oceanfishingrod.target
            if target ~= nil and target:HasTag("oceanfishing_catchable") and not target:HasTag("fishinghook") then
                rod.components.oceanfishingrod:CatchFish()
            end
        end
    end

    -- Get the fishing fishinghole position but do not remove it we may get more sharkbois.
    local x, y, z
    if self.arena.fishinghole ~= nil then
        x, y, z = self.arena.fishinghole.Transform:GetWorldPosition()
        -- Retain the fishing hole now.
		-- sharkboi spawn state will handle moving away from the hole
    else
        x, y, z = self.arena.origin.x, self.arena.origin.y, self.arena.origin.z
    end

    -- Spawn sparkboi.
    local sharkboi = self:CreateSharkBoi(x, y, z)
    self.arena.sharkbois = self.arena.sharkbois or {}
    self.arena.sharkbois[sharkboi] = true
	sharkboi:TrackFishingHole(self.arena.fishinghole)

    self:StartEventListeners()

    -- Knockback nearby things.
    local topunt = TheSim:FindEntities(x, y, z, TUNING.ICEFISHING_HOLE_PUNT_DETECT_RADIUS, self.PUNT_MUST_TAGS, self.PUNT_CANT_TAGS)
    for _, puntme in ipairs(topunt) do
        if puntme.components.health == nil or not puntme.components.health:IsDead() then
            puntme:PushEvent("knockback", {knocker = sharkboi, radius = TUNING.ICEFISHING_HOLE_PUNT_PUSH_RADIUS * (math.random() * 0.5 + 0.5),})
        end
    end
end

self.OnPlayerFishCaught = function(inst, data)
    --print("OnPlayerFishCaught", inst)
    self.OnPlayerStopFishing(inst) -- Stop listeners and cleanup fish.
    if self.arena == nil then
        return
    end

    self.arena.caughtfish = self.arena.caughtfish + 1
    if (self.arena.caughtfish % TUNING.ICEFISHING_HOLE_FISH_NEEDED_TO_SPAWN) == 0 then
        if TUNING.SPAWN_SHARKBOI then
            if self.arena.state == self.STATES.CREATEDARENA then
                self:SetArenaState(self.STATES.BOSSSPAWNED) -- Spawns a boss by default.
            elseif self.arena.state == self.STATES.BOSSSPAWNED then
                -- Spawn another one.
                -- FIXME(JBK): Allow spawning of more when this is finished. [FIXMESHARKBOI]
                --self:SpawnBoss()
            end
        end
    end
end
self.OnPlayerFishingTick = function(inst)
    --print("OnPlayerFishingTick", inst)
    if self.arena == nil or self.arena.fishinghole == nil then
        return
    end

    -- FIXME(JBK): Remove self.arena.state == self.STATES.BOSSSPAWNED when this is finished. [FIXMESHARKBOI]
    local oddsoverride = nil
    if not TUNING.SPAWN_SHARKBOI or self.arena.state == self.STATES.BOSSSPAWNED then
        oddsoverride = TUNING.ICEFISHING_HOLE_ODDS_TO_HOOK_FISH / 4
    end

    if math.random() < (oddsoverride or TUNING.ICEFISHING_HOLE_ODDS_TO_HOOK_FISH) then
        local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil
        local target = rod ~= nil and rod.components.oceanfishingrod.target or nil
        if rod ~= nil and target ~= nil and target:HasTag("fishinghook") then
            local x, y, z = self.arena.fishinghole.Transform:GetWorldPosition()

            local fish = SpawnPrefab(self:GetFishPrefab())
            fish.Transform:SetPosition(x, y, z)
            fish.AnimState:SetSortOrder(0)
            fish.AnimState:SetLayer(LAYER_WORLD)
            fish.components.oceanfishable:SetRod(rod)
            fish:RemoveTag("partiallyhooked")
            fish.components.oceanfishable:ResetStruggling()

            local fx = SpawnPrefab("ocean_splash_med" .. math.random(1, 2))
            fx.Transform:SetPosition(x, y, z)
        end
    end
end
self.OnRemove_FishingHole = function(inst, data)
    self.arena.fishinghole = nil
end
self.OnPondStartFishing = function(inst, data)
    -- inst == virtualoceanent
    if data == nil or data.fisher == nil then
        return
    end
    --print("OnPondStartFishing", data.fisher)
    self:StopPlayerFishingTick(data.fisher)
    self.fishingplayertasks[data.fisher] = data.fisher:DoPeriodicTask(TUNING.ICEFISHING_HOLE_TIME_PER_HOOK_CHANCE, self.OnPlayerFishingTick)
    data.fisher:ListenForEvent("oceanfishing_stoppedfishing", self.OnPlayerStopFishing)
    data.fisher:ListenForEvent("fishcaught", self.OnPlayerFishCaught)
end
self.OnPlayerStopFishing = function(inst, data)
    -- inst == player
    --print("OnPlayerStopFishing", inst)
    self:StopPlayerFishingTick(inst)

    inst:RemoveEventCallback("oceanfishing_stoppedfishing", self.OnPlayerStopFishing)
    inst:RemoveEventCallback("fishcaught", self.OnPlayerFishCaught)
end


self.OnAttacked_SharkBoi = function(inst, data)
    if data == nil or data.attacker == nil then
        return
    end

    local is_player_hitting = data.attacker:HasTag("player") or data.attacker.components.follower ~= nil and data.attacker.components.follower:GetLeader() ~= nil and data.attacker.components.follower:GetLeader():HasTag("player")
    if is_player_hitting then
        if self.arena.state == self.STATES.BOSSSPAWNED then
            self:SetArenaState(self.STATES.BOSSFIGHTING)
            for sharkboi, _ in pairs(self.arena.sharkbois) do -- Call in the thunder.
                if sharkboi ~= inst then
                    sharkboi:StartAggro()
                    sharkboi.components.combat:SuggestTarget(data.attacker)
                end
            end
        end
    end
end
self.OnRemove_SharkBoi = function(inst, data)
    self.arena.sharkbois[inst] = nil
    if next(self.arena.sharkbois) == nil then
        self.arena.sharkbois = nil
        self:SetArenaState(self.STATES.CLEANUP)
        self:CooldownArena()
    end
end

function self:StartEventListeners()
    if self.arena.sharkbois then
        for sharkboi, _ in pairs(self.arena.sharkbois) do
            if not sharkboi._sbm_listening then
                sharkboi._sbm_listening = true
                sharkboi:ListenForEvent("attacked", self.OnAttacked_SharkBoi)
                sharkboi:ListenForEvent("onremove", self.OnRemove_SharkBoi)
            end
        end
    end
    if self.arena.fishinghole and not self.arena.fishinghole._sbm_listening then
        self.arena.fishinghole._sbm_listening = true
        self.arena.fishinghole:ListenForEvent("onremove", self.OnRemove_FishingHole)
        self.arena.fishinghole:ListenForEvent("startfishinginvirtualocean", self.OnPondStartFishing)
    end
end

function self:CreateSharkBoi(x, y, z)
    local sharkboi = SpawnPrefab("sharkboi")
    sharkboi.Transform:SetPosition(x, y, z)
	sharkboi.sg:GoToState("spawn")

    return sharkboi
end

function self:CreateFishingHole(x, y, z)
    local fishinghole = SpawnPrefab("icefishing_hole")
    fishinghole.Transform:SetPosition(x, y, z)

    return fishinghole
end

function self:CreateEntityDecorationsAtPoint(x, y, z)
    -- Function stub for mods.

    --[[for i = 1, 3 do
        if math.random() < 0.1 then
            local rad = math.random() * TILE_SCALE -- Not * 0.5 to give both overlap and potentially put ice in the ocean.
            local theta = math.random() * PI2
            local ex, ez = x + rad * math.cos(theta), z + rad * math.sin(theta)
            local dx, dz = ex - self.arena.origin.x, ez - self.arena.origin.z
            if dx * dx + dz * dz > 9 then -- 3 * 3 = 9 to stay away from center of arena.
                local ice = SpawnPrefab("ice")
                ice.Transform:SetPosition(ex, y, ez)
            end
        end
    end]]


        -- NOTES(DiogoW): Unimplemented, for now.
    --[[
        if math.random() < 0.1 then
        local dx, dz = x - self.arena.origin.x, z - self.arena.origin.z

        local dist_origin = dx * dx + dz * dz

        if dist_origin > 9 then -- 3 * 3 = 9 to stay away from center of arena.
            local fishbone = SpawnPrefab("fishbone_shadow")
            fishbone.Transform:SetPosition(x, 0, z)
        end
    end
    ]]

end

function self:ArenaFinishCreating()
    self:ForEachTileInBetween(0, self.arena.radius, self.CreateEntityDecorationsAtPoint)

    local x, y, z = self.arena.origin.x, self.arena.origin.y, self.arena.origin.z
    self.arena.fishinghole = self:CreateFishingHole(x, y, z)

    -- NOTES(JBK): This is about 80 entities generated.
    for r = TILE_SCALE, self.MAX_ARENA_SIZE * 4, TILE_SCALE * 2 do
        for i = 1, math.max(r * 0.15, 2) do
            local theta = math.random() * PI2
            local rad = r + math.random() * TILE_SCALE
            local ex, ez = x + rad * math.cos(theta), z + rad * math.sin(theta)
            if TheSim:FindEntities(ex, y, ez, MAX_PHYSICS_RADIUS)[1] == nil then
                local ice = SpawnPrefab("sharkboi_ice_hazard")
                ice.Transform:SetPosition(ex, y, ez)
                if r < self.MAX_ARENA_SIZE * 2 then
                    ice:SetStage("tall")
                elseif r < self.MAX_ARENA_SIZE * 3 then
                    ice:SetStage("medium")
                else
                    ice:SetStage("short")
                end
            end
        end
    end

    -- Initialize event listeners hookups and other post processing.
    self:StartEventListeners()
    _world:PushEvent("ms_spawnedsharkboiarena", self.arena)
end

function self:CreateIceTileAtPoint(x, y, z)
    _world.components.oceanicemanager:CreateIceAtPoint(x, y, z)
end

function self:DestroyIceTileAtPoint(x, y, z)
    _world.components.oceanicemanager:QueueDestroyForIceAtPoint(x, y, z)
end

function self:PlaceOceanArenaAtPosition(x, y, z)
    if self.arena ~= nil then
        return false
    end

    self.arena = {
        state = self.STATES.CREATINGARENA,
        origin = Vector3(x, y, z),
        caughtfish = 0,
    }
    self:SetDesiredArenaRadius(self:GetDesiredArenaRadius())

    -- Ice first for a platform to stand on.
    self:ForEachTileInBetween(0, self.arena.radius, self.CreateIceTileAtPoint)

    -- Entities that stand on the ice should be spawned in after self.STATES.CREATEDARENA.
    _world:DoTaskInTime(0, SetArenaState_Bridge, self.STATES.CREATEDARENA)

    return true
end




self.SortByClosestToWorldOrigin = function(a, b)
    local asq = a.x * a.x + a.y * a.y + a.z * a.z
    local bsq = b.x * b.x + b.y * b.y + b.z * b.z
    if asq == bsq then
        return tostring(a) < tostring(b) -- NOTES(JBK): Force a determined sorting based off of table pointers.
    end

    return asq < bsq
end

local TILEDEPTH_LOOKUP = TUNING.ANCHOR_DEPTH_TIMES -- FIXME(JBK): Relying on an arbitrary tuning table for winch instead of having a number value for depths in the tiledefs themselves.
self.SortByOceanDepth_DeepestFirst = function(a, b)
    local adepth = GetOceanDepthAtPosition(a.x, a.y, a.z)
    local bdepth = GetOceanDepthAtPosition(b.x, b.y, b.z)
    if adepth == bdepth or adepth == nil or bdepth == nil then
        return self.SortByClosestToWorldOrigin(a, b) -- Fallback.
    end

    return TILEDEPTH_LOOKUP[adepth] > TILEDEPTH_LOOKUP[bdepth]
end

self.CustomAllowTest_OceanArena = function(_map, x, y, z)
    return true
end

function self:TryToPlaceOceanArena()
    local points, count = _map:GetGoodOceanArenaPoints()
    if count < 1 then
        return false
    end

    table.sort(points, self.SortByOceanDepth_DeepestFirst)
    local x, y, z = _map:FindBestSpawningPointForOceanArena(self.CustomAllowTest_OceanArena, true, points)
    if not x then
        return false
    end

    x, y, z = _map:GetTileCenterPoint(x, y, z)
    return self:PlaceOceanArenaAtPosition(x, y, z)
end

function self:StopFindAndPlaceOceanArenaOverTime()
    if self.findoceanarenatask ~= nil then
        self.findoceanarenatask:Cancel()
        self.findoceanarenatask = nil
    end
end

local function FindAndPlaceOceanArenaOverTime_Bridge(inst)
    self:FindAndPlaceOceanArenaOverTime()
end

function self:FindAndPlaceOceanArenaOverTime()
    self:StopFindAndPlaceOceanArenaOverTime()
    if self.arena ~= nil then
        return
    end

    local _, count = _map:GetGoodOceanArenaPoints()
    if count == 0 then
        if _map._GoodOceanArenaPoints_Task == nil then
            _map:StartFindingGoodOceanArenaPoints(self.TEMP_DEBUG_RATE)
        end
        self.findoceanarenatask = self.inst:DoTaskInTime(self.TEMP_DEBUG_RATE and 0 or 5, FindAndPlaceOceanArenaOverTime_Bridge)
        return
    end

    self:TryToPlaceOceanArena()
end

function self:LongUpdate(dt)
    if self.arena ~= nil then
        if self.arena.cooldowntask ~= nil then
            local remaining = GetTaskRemaining(self.arena.cooldowntask)
            self.arena.cooldowntask:Cancel()
            self.arena.cooldowntask = nil
            local scheduledtime = math.max(remaining - dt, 0)
            self.arena.cooldowntask = self.inst:DoTaskInTime(scheduledtime, self.OnCooldownEnd)
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    if self.arena == nil then
        return nil
    end

    local data = {
        origin = {x = self.arena.origin.x, y = self.arena.origin.y, z = self.arena.origin.z,},
        caughtfish = self.arena.caughtfish,
        state = self:GetArenaStateString(),
        radius = self.arena.radius,
    }
    if self.arena.cooldowntask then
        data.cooldown = GetTaskRemaining(self.arena.cooldowntask)
    end

    local ents = {}
    if self.arena.sharkbois then
        data.sharkbois = {}
        for sharkboi, _ in pairs(self.arena.sharkbois) do
            table.insert(data.sharkbois, sharkboi.GUID)
            table.insert(ents, sharkboi.GUID)
        end
    end
    if self.arena.fishinghole then
        data.fishinghole = self.arena.fishinghole.GUID
        table.insert(ents, self.arena.fishinghole.GUID)
    end

    return data, ents
end

function self:OnLoad(data)
    if data == nil then
        return
    end

    self:StopFindAndPlaceOceanArenaOverTime()

    self.arena = {
        origin = Vector3(data.origin.x, data.origin.y, data.origin.z),
        caughtfish = data.caughtfish or 0,
        state = self.STATES.UNDEFINED,
    }
    self:SetDesiredArenaRadius(data.radius)
    self:SetArenaState(self.STATES[data.state] or self.STATES.UNDEFINED)
    if self.arena.state == self.STATES.UNDEFINED then
        -- We do not know what state the arena is in schedule a full clear and do not start timers or anything else.
        self:SetArenaState(self.STATES.CLEANUP)
        return
    end

    if data.cooldown then
        self.arena.cooldowntask = self.inst:DoTaskInTime(data.cooldown, self.OnCooldownEnd)
    end
    
    self.OnSeasonChange(self, _world.state.season)
end

local LOADFIX_CANT_TAGS = {"FX"}
function self:LoadPostPass(newents, savedata)
    if self.arena == nil then
        return
    end

    if newents[savedata.fishinghole] then
        self.arena.fishinghole = newents[savedata.fishinghole].entity
    end

    if newents[savedata.sharkboi] then -- NOTES(JBK): Deprecated field when there was only ever one sharkboi use sharkbois as a table.
        self.arena.sharkbois = {
            [newents[savedata.sharkboi].entity] = true,
        }
        if self.arena.state == self.STATES.BOSSSPAWNED and self.arena.fishinghole == nil then
            -- NOTES(JBK): The boss was spawned in this save meaning that there are no fishing holes left and the boss has not been engaged yet.
            -- We need to make a new fishing hole now.
            -- A problem to solve is that things might now be in this location so we need to move things that are spawned in away from this area.
            -- Players will automatically get punted from the icefishing_hole prefab.
            local x, y, z = self.arena.origin.x, self.arena.origin.y, self.arena.origin.z
            local loadfix_radius = 4 -- Not a perfect radius but good enough to add clearance for most things the player can self clean up things if they need back to the pond.
            local ents = TheSim:FindEntities(x, y, z, loadfix_radius, nil, LOADFIX_CANT_TAGS)
            for _, ent in ipairs(ents) do
                if ent.Transform then
                    local ex, ey, ez = ent.Transform:GetWorldPosition()
                    local dx, dz = ex - x, ez - z
                    local dist = math.sqrt(dx * dx + dz * dz)
                    if dist == 0 then
                        dist = 1
                        dx = 1
                    else
                        dx, dz = loadfix_radius * dx / dist, loadfix_radius * dz / dist
                    end
                    ent.Transform:SetPosition(x + dx, y, z + dz)
                end
            end
            self.arena.fishinghole = self:CreateFishingHole(x, y, z)
        end
    end
    if savedata.sharkbois then
        self.arena.sharkbois = {}
        for _, sharkboiguid in ipairs(savedata.sharkbois) do
            if newents[sharkboiguid] then
				local sharkboi = newents[sharkboiguid].entity
				self.arena.sharkbois[sharkboi] = true
				sharkboi:TrackFishingHole(self.arena.fishinghole)
            end
        end
    end

    self:StartEventListeners()
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    if self.arena == nil then
        return string.format("No Arena. FindTick: %.1f", GetTaskRemaining(self.findoceanarenatask))
    end

    return string.format("State: %s, Sharkbois: %s, FishingHole: %s, Fish: %d, Cooldown: %.1f, Radius: %.1f, DesiredRadius: %.1f",
        self:GetArenaStateString(),
        tostring(self.arena.sharkbois and table.count(self.arena.sharkbois) or "N/A"),
        tostring(self.arena.fishinghole or "N/A"),
        self.arena.caughtfish,
        GetTaskRemaining(self.arena.cooldowntask),
        self.arena.radius,
        self.arena.desiredradius or -1)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

self.InitializeSharkBoiManager = function(_, data)
    self:FindAndPlaceOceanArenaOverTime()
end
inst:ListenForEvent("worldmapsetsize", self.InitializeSharkBoiManager, _world)

self.OnSeasonChange = function(_, season)
    if self.arena == nil then
        return
    end

    if season == "winter" then
        self:TryToMakeArenaBig()
    else
        self:TryToMakeArenaSmall()
    end
end
self:WatchWorldState("season", self.OnSeasonChange)


--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)