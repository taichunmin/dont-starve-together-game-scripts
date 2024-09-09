local assets = {
    Asset("ANIM", "anim/whirlportal.zip"),
}

local prefabs = {
    "wave_med",
    "oceanwhirlportal_splash",
}

local CHECK_FOR_BOATS_PERIOD = 0.5

local BOAT_INTERACT_DISTANCE = 6.0
local BOAT_INTERACT_DISTANCE_LEAVE_SQ = (BOAT_INTERACT_DISTANCE + MAX_PHYSICS_RADIUS) * (BOAT_INTERACT_DISTANCE + MAX_PHYSICS_RADIUS)

local BOAT_WAKE_COUNT = 3
local BOAT_WAKE_TIME_PER = 1.5
local BOAT_WAKE_SPEED_MIN_THRESHOLD = 3.5

local BOAT_MUST_TAGS = {"boat",}

local TELEPORTBOAT_ITEM_MUST_TAGS = {"_inventoryitem",}
local TELEPORTBOAT_ITEM_CANT_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO",}
local TELEPORTBOAT_BLOCKER_CANT_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO", "_inventoryitem", "oceanwhirlportal",}

local function DoBoatWake(boat, isfirst)
    if boat.components.boatphysics == nil then
        return
    end

    local speed = boat.components.boatphysics:GetVelocity()
    if speed < BOAT_WAKE_SPEED_MIN_THRESHOLD then
        return
    end

    local boatradius = boat:GetSafePhysicsRadius() + 3 -- Add a small offset so the wave does not hit the boat it came from.

    local x, y, z = boat.Transform:GetWorldPosition()
    local velx_n, velz_n = boat.components.boatphysics:GetNormalizedVelocities()
    local direction = VecUtil_GetAngleInRads(velx_n, velz_n)
    local dir1 = direction - 7.0 * DEGREES
    local dir2 = direction + 7.0 * DEGREES
    local pos1 = Vector3(x - boatradius * math.cos(dir1), 0, z - boatradius * math.sin(dir1))
    local pos2 = Vector3(x - boatradius * math.cos(dir2), 0, z - boatradius * math.sin(dir2))
    SpawnAttackWave(pos1, -direction * RADIANS - 65.0, BOAT_WAKE_SPEED_MIN_THRESHOLD, "wave_med", 0.5, true)
    SpawnAttackWave(pos2, -direction * RADIANS + 65.0, BOAT_WAKE_SPEED_MIN_THRESHOLD, "wave_med", 0.5, true)
    if isfirst then
        -- Make it emit one out the back too.
        boatradius = boatradius - 1.5
        local pos3 = Vector3(x - boatradius * math.cos(direction), 0, z - boatradius * math.sin(direction))
        SpawnAttackWave(pos3, -direction * RADIANS - 180.0, BOAT_WAKE_SPEED_MIN_THRESHOLD, "wave_med", 0.5, true)
    end
end

local function SetExit(inst, exit)
    inst.components.entitytracker:TrackEntity("exit", exit)
end

local function ClearAvoid(boat)
    boat._avoid_whirlportals_hack = nil
end

local function CheckForBoatsTick(inst)
    -- Self check own blockers to clear.
    local selfblocker = inst.components.entitytracker:GetEntity("blocker")
    if selfblocker ~= nil then
        if inst:GetDistanceSqToInst(selfblocker) < BOAT_INTERACT_DISTANCE_LEAVE_SQ then
            return
        end
        inst.components.entitytracker:ForgetEntity("blocker")
    end

    -- Now do the normal teleport routine.
    local exit = inst.components.entitytracker:GetEntity("exit")
    if exit == nil then
        return
    end

    if exit.components.entitytracker:GetEntity("blocker") ~= nil then
        return
    end
    
    local sx, sy, sz = inst.Transform:GetWorldPosition()
    local boat
    local boats = TheSim:FindEntities(sx, sy, sz, BOAT_INTERACT_DISTANCE, BOAT_MUST_TAGS)
    for _, testboat in ipairs(boats) do
        if not testboat._avoid_whirlportals_hack then
            boat = testboat
            break
        end
    end
    if boat == nil then
        return
    end

    local boatradius = boat:GetSafePhysicsRadius()
    
    local ex, ey, ez = exit.Transform:GetWorldPosition()
    
    local velx_n, velz_n = 0, 0
    if boat.components.boatphysics then
        velx_n, velz_n = boat.components.boatphysics:GetNormalizedVelocities()
    end
    local e_pt = Vector3(ex, ey, ez)
    if boat:IsBoatEdgeOverLand(e_pt) or TheSim:FindEntities(ex, ey, ez, boatradius + MAX_PHYSICS_RADIUS, nil, TELEPORTBOAT_BLOCKER_CANT_TAGS)[1] ~= nil then
        local function ValidOffset(pt)
            if TheWorld.Map:IsPointNearHole(pt) then
                return false
            end

            if boat:IsBoatEdgeOverLand(pt) then
                return false
            end

            if TheSim:FindEntities(pt.x, pt.y, pt.z, boatradius + MAX_PHYSICS_RADIUS, nil, TELEPORTBOAT_BLOCKER_CANT_TAGS)[1] ~= nil then
                return false
            end

            return true
        end
        local angle = VecUtil_GetAngleInRads(velx_n, velz_n)
        local offset
        for i = 1, math.ceil(BOAT_INTERACT_DISTANCE * 1.5) do
            offset = FindSwimmableOffset(e_pt, angle, i, 8, false, false, ValidOffset, false)
            if offset ~= nil then
                break
            end
        end
        if offset == nil then
            -- This exit is blocked.
            return
        end
        ex, ez = ex + offset.x, ez + offset.z
    end

    inst.components.entitytracker:TrackEntity("blocker", boat)
    exit.components.entitytracker:TrackEntity("blocker", boat)

    SpawnPrefab("oceanwhirlportal_splash").Transform:SetPosition(sx, sy, sz)
    SpawnPrefab("oceanwhirlportal_splash").Transform:SetPosition(ex, ey, ez)

    local item_ents = TheSim:FindEntities(ex, ey, ez, boatradius, TELEPORTBOAT_ITEM_MUST_TAGS, TELEPORTBOAT_ITEM_CANT_TAGS)
    boat.Physics:Teleport(ex, ey, ez)
    if boat.boat_item_collision then
        -- NOTES(JBK): This must also teleport or it will fling items off of it in a comical fashion from the physics constraint it has.
        boat.boat_item_collision.Physics:Teleport(ex, ey, ez)
    end
    if boat.components.boatphysics then
        boat.components.boatphysics:ApplyForce(velx_n, velz_n, TUNING.OCEANWHIRLPORTAL_BOAT_PUSH_FORCE)
        boat._avoid_whirlportals_hack = true -- HACK(JBK): Putting a boat into one into another it will cause a loop and the player can get stuck with it find a better way!
        DoBoatWake(boat, true)
        for i = 1, BOAT_WAKE_COUNT - 1 do
            boat:DoTaskInTime(i * BOAT_WAKE_TIME_PER, DoBoatWake)
        end
        boat:DoTaskInTime(BOAT_WAKE_COUNT * BOAT_WAKE_TIME_PER, ClearAvoid)
    end
    for _, ent in ipairs(item_ents) do
        ent.components.inventoryitem:SetLanded(false, true)
    end
    exit.components.wateryprotection:SpreadProtectionAtPoint(ex, ey, ez, MAX_PHYSICS_RADIUS * 2)

    local walkableplatform = boat.components.walkableplatform
    if walkableplatform ~= nil then
        local players = walkableplatform:GetPlayersOnPlatform()
        for player, _ in pairs(players) do
            player:PushEvent("wormholetravel", WORMHOLETYPE.OCEANWHIRLPORTAL) --Event for playing local travel sound
        end
        if inst:GetDistanceSqToInst(exit) > PLAYER_CAMERA_SHOULD_SNAP_DISTANCE_SQ then
            for player, _ in pairs(players) do
                player:SnapCamera()
                player:ScreenFade(false)
                player:ScreenFade(true, 1)
            end
        end
    end
end

local function ontimerdone(inst, data)
    if data == nil then
        return
    end

    if data.name == "closewhirlportal" then
        if inst._check_for_boats_task ~= nil then
            inst._check_for_boats_task:Cancel()
            inst._check_for_boats_task = nil
        end
        inst.persists = false
        inst.AnimState:PlayAnimation("open_pst")
        inst:ListenForEvent("animqueueover", inst.Remove)
    end
end

local function OnRemoveEntity(inst)
    inst.SoundEmitter:KillSound("wave")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("whirlportal")
    inst.AnimState:SetBank("whirlportal")
    inst.AnimState:PlayAnimation("open_pre")
    inst.AnimState:PushAnimation("open_loop", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_WHIRLPORTAL)
    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    inst.MiniMapEntity:SetIcon("oceanwhirlportal.png")

    inst:AddTag("birdblocker")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("oceanwhirlportal")

    inst:SetDeployExtraSpacing(2)

    inst.highlightoverride = {0.1, 0.1, 0.3}

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "open_loop"
    inst.scrapbook_scale = 1.5
    inst.scrapbook_animoffsetx = 30
    inst.scrapbook_animoffsety = -10
    inst.scrapbook_animoffsetbgx = 80
    inst.scrapbook_animoffsetbgy = 40

    inst.SetExit = SetExit
    inst.CheckForBoatsTick = CheckForBoatsTick

    inst:AddComponent("inspectable")

    inst:AddComponent("entitytracker")

    local wateryprotection = inst:AddComponent("wateryprotection")
    wateryprotection.extinguishheatpercent = TUNING.OCEANWHIRLPORTAL_EXTINGUISH_HEAT_PERCENT
    wateryprotection.temperaturereduction = TUNING.OCEANWHIRLPORTAL_TEMP_REDUCTION
    wateryprotection.witherprotectiontime = TUNING.OCEANWHIRLPORTAL_PROTECTION_TIME
    wateryprotection.addcoldness = TUNING.OCEANWHIRLPORTAL_ADD_COLDNESS
    wateryprotection.addwetness = TUNING.OCEANWHIRLPORTAL_ADD_WETNESS
    wateryprotection.applywetnesstoitems = true

    local timer = inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    timer:StartTimer("closewhirlportal", TUNING.OCEANWHIRLPORTAL_KEEPALIVE_DURATION)

    inst._check_for_boats_task = inst:DoPeriodicTask(CHECK_FOR_BOATS_PERIOD, inst.CheckForBoatsTick, CHECK_FOR_BOATS_PERIOD * math.random())

    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/wave/LP", "wave")
    inst.SoundEmitter:SetParameter("wave", "size", 0.5)
    inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("oceanwhirlportal", fn, assets, prefabs)

-- NOTES(JBK): Search terms: "oceanwhirlpool", "whirlpool",
