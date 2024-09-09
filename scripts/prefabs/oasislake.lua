local assets =
{
    Asset("ANIM", "anim/oasis_tile.zip"),
    Asset("ANIM", "anim/splash.zip"),
    Asset("MINIMAP_IMAGE", "oasis"),
}

local prefabs =
{
    "pondfish",
    "wetpouch",
}

local WATER_RADIUS = 3.8

local NUM_BUGS = 3
local BUG_OFFSET = 1.4
local BUG_RANDOM_RANGE = .5
local function SpawnOasisBugs(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, BUG_OFFSET + BUG_RANDOM_RANGE + 0.1)
    local bug_pts = {}
    for k,ent in ipairs(ents) do
        if ent.prefab == "fireflies" then
            table.insert(bug_pts, ent:GetPosition())
        end
    end

    local pos = inst:GetPosition()
    local offset = nil
    for i = #bug_pts + 1, NUM_BUGS do
        if i == 1 then
            offset = Vector3(BUG_OFFSET, 0, 0)
        elseif i == 2 then
            local dir = bug_pts[1] - pos
            local theta = 0.33 * TWOPI
            local ca, sa = math.cos(theta), math.sin(theta)
            offset = Vector3(ca*dir.x - sa*dir.y, 0, sa*dir.x + ca*dir.y):Normalize() * BUG_OFFSET
        elseif i == 3 then
            offset = Vector3(0,0,0)
            for _,pt in ipairs(bug_pts) do
                offset = offset + (pt - pos)
            end
            offset = offset:Normalize() * BUG_OFFSET
            offset.x = -offset.x
            offset.z = -offset.z
        end

        local bug = SpawnPrefab("fireflies")
        bug.Transform:SetPosition((pos + offset + Vector3(math.random()*BUG_RANDOM_RANGE, 0, math.random()*BUG_RANDOM_RANGE)):Get())
        table.insert(bug_pts, bug:GetPosition())
    end
end

local MAX_SUCCULENTS = 18
local SUCCULENT_RANGE = 15
local SUCCULENT_RANGE_MIN = WATER_RADIUS + 0.5
local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }
local SUCCULENT_TAGS = { "succulent" }

local function SpawnSucculents(inst)
    local pt = inst:GetPosition()

    local function noentcheckfn(offset)
        return #TheSim:FindEntities(offset.x, offset.y, offset.z, 2, nil, NOTENTCHECK_CANT_TAGS) == 0
    end

    local succulents_to_spawn = MAX_SUCCULENTS - #TheSim:FindEntities(pt.x, pt.y, pt.z, SUCCULENT_RANGE, SUCCULENT_TAGS)
    for i = 1, succulents_to_spawn do
        local offset = FindWalkableOffset(pt, math.random() * TWOPI, GetRandomMinMax(SUCCULENT_RANGE_MIN, SUCCULENT_RANGE), 10, false, true, noentcheckfn)
        if offset ~= nil then
            local plant = SpawnPrefab("succulent_plant")
            plant.Transform:SetPosition((pt + offset):Get())
            plant.AnimState:PlayAnimation("place")
            plant.AnimState:PushAnimation("idle", false)
        end
    end
end

local function OnIsWetChanged(inst, iswet, skipanim)
    if iswet then
        if not inst.isdamp then
            inst.isdamp = true
            if skipanim or inst.driedup then
                inst.AnimState:PlayAnimation("wet")
            else
                inst.AnimState:PlayAnimation("dry_pre")
                inst.AnimState:PushAnimation("wet", false)
            end
        end
    elseif inst.driedup then
        if inst.isdamp then
            inst.isdamp = false
            inst.AnimState:PlayAnimation("dry_idle")
        end
    elseif skipanim then
        inst.AnimState:PlayAnimation("dry_idle")
    else
        inst.AnimState:PlayAnimation("dry_pre")
        inst.AnimState:PushAnimation("dry_idle", false)
    end
end

local function OnIsWet(inst, iswet)
    OnIsWetChanged(inst, iswet, false)
end

local function HasPhysics(obj)
    return obj.Physics ~= nil
end

local BLOCKERS_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost", "ghost", "flying", "structure" }
local function TryFillLake(inst, skipanim, OnSandstormChanged)
    if FindEntity(inst, WATER_RADIUS, HasPhysics, nil, BLOCKERS_TAGS) ~= nil then
        --Something is on top of us, reschedule filling up...
        inst.filltask = inst:DoTaskInTime(5, TryFillLake, skipanim, OnSandstormChanged)
        return
    end

    inst.filltask = nil
    inst.isdamp = false
    inst.driedup = false

    inst:StopWatchingWorldState("iswet", OnIsWet)

    if skipanim then
        inst.AnimState:PlayAnimation("idle", true)
    else
        inst.AnimState:PlayAnimation("dry_pst")
        inst.AnimState:PushAnimation("idle", true)
    end

    inst.components.fishable:Unfreeze()

    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)

    inst.components.watersource.available = true
    inst:RemoveTag("NOCLICK")
end

local function OnSandstormChanged(inst, active, skipanim)
    if inst.filltask ~= nil then
        inst.filltask:Cancel()
        inst.filltask = nil
    end
    if active then
        if inst.driedup then
            TryFillLake(inst, skipanim, OnSandstormChanged)
        end
        if inst.regrowth then
            inst.regrowth = false
            SpawnOasisBugs(inst)
            SpawnSucculents(inst)
        end
    elseif not inst.driedup then
        inst:WatchWorldState("iswet", OnIsWet)
        OnIsWetChanged(inst, TheWorld.state.iswet, skipanim)

        inst.driedup = true
        inst.regrowth = true

        inst.components.fishable:Freeze()

        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)

        inst.components.watersource.available = false
        inst:AddTag("NOCLICK")
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:ListenForEvent("ms_stormchanged", function(src, data)
            if data.stormtype == STORM_TYPES.SANDSTORM then
                OnSandstormChanged(inst, data.setting)
            end
        end, TheWorld)
    OnSandstormChanged(inst, TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive(), true)
end

local function OnSave(inst, data)
    if not inst.regrowth then
        data.regrowth = false
    end
end

local function OnLoad(inst, data)
    inst.regrowth = data == nil or data.regrowth ~= false
end

local function GetFish(inst)
    return math.random() < 0.6 and "wetpouch" or "pondfish"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.Transform:SetRotation(45)

    MakeObstaclePhysics(inst, 6)
	--inst:SetPhysicsRadiusOverride(3)

    inst.AnimState:SetBuild("oasis_tile")
    inst.AnimState:SetBank("oasis_tile")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

    inst.MiniMapEntity:SetIcon("oasis.png")

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("birdblocker")
    inst:AddTag("antlion_sinkhole_blocker")
	inst:AddTag("allow_casting")

    inst.no_wet_prefix = true
	inst:SetDeploySmartRadius(WATER_RADIUS)

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(320)
    end

    inst.scrapbook_inspectonseen = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("fishable")
    inst.components.fishable.maxfish = TUNING.OASISLAKE_MAX_FISH
    inst.components.fishable:SetRespawnTime(TUNING.OASISLAKE_FISH_RESPAWN_TIME)
    inst.components.fishable:SetGetFishFn(GetFish)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("oasis")
    inst.components.oasis.radius = TUNING.SANDSTORM_OASIS_RADIUS

    inst:AddComponent("watersource")



    inst.isdamp = false
    inst.driedup = false
    inst.regrowth = false

    TheWorld:PushEvent("ms_registeroasis", inst)
    inst.task = inst:DoTaskInTime(0, OnInit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("oasislake", fn, assets, prefabs)
