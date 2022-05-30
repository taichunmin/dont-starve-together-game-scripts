require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/walrus_house.zip"),
    Asset("ANIM", "anim/igloo_track.zip"),
    Asset("SOUND", "sound/pig.fsb"), -- light on/off sounds
    Asset("MINIMAP_IMAGE", "igloo"),
}

local prefabs =
{
    "walrus",
    "little_walrus",
    "icehound",
}

local NUM_HOUNDS = 2
local AGGRO_SPAWN_PARTY_RADIUS = 10

local function GetSpawnPoint(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rad = 2
    local angle = math.random() * 2 * PI
    return x + rad * math.cos(angle), y, z - rad * math.sin(angle)
end

local function GetStatus(inst)
    if not inst.data.occupied then
        return "EMPTY"
    end
end

local function UpdateLight(inst, on)
    if on then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        if not inst.data.lighton then
            inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
            inst.data.lighton = true
        end
    else
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        if inst.data.lighton then
            inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
            inst.data.lighton = false
        end
    end
end

local function SetOccupied(inst, occupied)
    local anim = inst.AnimState

    inst.data.occupied = occupied

    if occupied then

        anim:SetBank("walrus_house")
        anim:SetBuild("walrus_house")

        UpdateLight(inst, not TheWorld.state.isday)

        anim:SetOrientation(ANIM_ORIENTATION.Default)
        anim:SetLayer(LAYER_WORLD)
        anim:SetSortOrder(0)

        MakeObstaclePhysics(inst, 3)
    else
        UpdateLight(inst, false)

        anim:SetBank("igloo_track")
        anim:SetBuild("igloo_track")
        anim:PlayAnimation("idle")
        anim:SetOrientation(ANIM_ORIENTATION.OnGround)
        anim:SetLayer(LAYER_BACKGROUND)
        anim:SetSortOrder(3)

        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
    end
end

local function UpdateCampOccupied(inst)
    if inst.data.occupied then
        if not TheWorld.state.iswinter then
            for k,v in pairs(inst.data.children) do
                if k:IsValid() and not k:IsAsleep() then
                    -- don't go away while there are children alive in the world
                    return
                end
            end
            for k,v in pairs(inst.data.children) do
                k:Remove()
            end
            inst.data.children = {}
            SetOccupied(inst, false)
        end
    elseif TheWorld.state.iswinter then
        SetOccupied(inst, true)
    end
end

local function RemoveMember(inst, member)
    inst.data.children[member] = nil

    if inst:IsAsleep() then
        UpdateCampOccupied(inst)
    end
end

local function OnMemberKilled(inst, member, data)
    if inst.components.worldsettingstimer:ActiveTimerExists(member.prefab) then
        inst.components.worldsettingstimer:StopTimer(member.prefab)
    end

    inst.components.worldsettingstimer:StartTimer(member.prefab, TUNING.WALRUS_REGEN_PERIOD)

    RemoveMember(inst, member)
end

local OnMemberNewTarget -- forward declaration
local DespawnedFromHaunt
local DetachChild

local function TrackMember(inst, member)
    inst.data.children[member] = true
    inst:ListenForEvent("death", function(...) OnMemberKilled(inst, ...) end, member)
    inst:ListenForEvent("newcombattarget", function(...) OnMemberNewTarget(inst, ...) end, member)
    inst:ListenForEvent("despawnedfromhaunt", function(member, data) DespawnedFromHaunt(inst,member,data) end, member)
    inst:ListenForEvent("detachchild", function(member) DetachChild(inst, member) end, member)

    if not member.components.homeseeker then
        member:AddComponent("homeseeker")
    end
    member.components.homeseeker:SetHome(inst)
end

DetachChild = function(inst, oldchild)
    inst.data.children[oldchild] = nil

    if inst:IsAsleep() then
        UpdateCampOccupied(inst)
    end
end

DespawnedFromHaunt = function(inst, oldchild, data)
    local newchild = data.newPrefab

    inst.data.children[oldchild] = nil
    TrackMember(inst, newchild)

    if inst:IsAsleep() then
        UpdateCampOccupied(inst)
    end
end

local function SpawnMember(inst, prefab)
    local member = SpawnPrefab(prefab)

    TrackMember(inst, member)

    return member
end

local function GetMember(inst, prefab)
    for k,v in pairs(inst.data.children) do
        if k.prefab == prefab then
            return k
        end
    end
end

local function GetMembers(inst, prefab)
    local members = {}
    for k,v in pairs(inst.data.children) do
        if k.prefab == prefab then
            table.insert(members, k)
        end
    end
    return members
end

local function CanSpawn(inst, prefab)
    return TUNING.WALRUS_REGEN_ENABLED and not inst.components.worldsettingstimer:ActiveTimerExists(prefab)
end

local function OnWentHome(inst, data)
    RemoveMember(inst, data.doer)
    UpdateLight(inst, inst.data.occupied)
end

local function SpawnHuntingParty(inst, target, houndsonly)
    -- defer setting the transforms to prevent all kinds of events happening
    -- during set-up of the party
    local transformsToSet = {}
    local leader = GetMember(inst, "walrus")
    if not houndsonly and not leader and CanSpawn(inst, "walrus") then
        leader = SpawnMember(inst, "walrus")
        local x,y,z = GetSpawnPoint(inst)
        transformsToSet[#transformsToSet + 1] = {inst = leader, x=x, y=y,z=z }
    end

    local companion = GetMember(inst, "little_walrus")
    if not houndsonly and not companion and CanSpawn(inst, "little_walrus") then
        companion = SpawnMember(inst, "little_walrus")
        local x,y,z = GetSpawnPoint(inst)
        transformsToSet[#transformsToSet + 1] = {inst = companion, x=x, y=y,z=z }
    end

    if companion and leader then
        companion.components.follower:SetLeader(leader)
    end

    local existing_hounds = GetMembers(inst, "icehound")
    for i = 1,NUM_HOUNDS do

        local hound = existing_hounds[i]
        if not hound and CanSpawn(inst, "icehound") then
            hound = SpawnMember(inst, "icehound")
            hound:AddTag("pet_hound")
            local x,y,z = GetSpawnPoint(inst)
            transformsToSet[#transformsToSet + 1] = {inst = hound, x=x, y=y,z=z }
            hound.sg:GoToState("idle")
        end

        if companion and hound then
            if not hound.components.follower then
                hound:AddComponent("follower")
            end
            hound.components.follower:SetLeader(companion)
        end
    end

    if target then
        if companion then
            companion.components.combat:SuggestTarget(target)
        end
        if leader then
            leader.components.combat:SuggestTarget(target)
        end
    end

    for i,v in ipairs(transformsToSet) do
        v.inst.Transform:SetPosition(v.x, v.y, v.z)
    end
end

local function CheckSpawnHuntingParty(inst, target, houndsonly)
    if inst.data.occupied and TheWorld.state.iswinter then
        SpawnHuntingParty(inst, target, houndsonly)
        UpdateLight(inst, houndsonly) -- keep light on if hounds only, otherwise off
    end
end

-- assign value to forward declared local above
OnMemberNewTarget = function (inst, member, data)
    if member:IsNear(inst, AGGRO_SPAWN_PARTY_RADIUS) then
        CheckSpawnHuntingParty(inst, data.target, false)
    end
end

local function OnEntitySleep(inst)
    if not POPULATING then
        UpdateCampOccupied(inst)
        CheckSpawnHuntingParty(inst, nil, not TheWorld.state.isday)
    end
end

local function OnEntityWake(inst)
end

local function OnStartDay(inst)
    CheckSpawnHuntingParty(inst, nil, false)
end

local function OnIsWinter(inst)
    if inst:IsAsleep() then
        UpdateCampOccupied(inst)
        CheckSpawnHuntingParty(inst, nil, not TheWorld.state.isday)
    end
end

local function OnSave(inst, data)
    data.children = {}

    for k,v in pairs(inst.data.children) do
        table.insert(data.children, k.GUID)
    end

    if #data.children < 1 then
        data.children = nil
    end

    data.occupied = inst.data.occupied

    return data.children
end

local function OnLoad(inst, data)

    if data then
    --children loaded by OnLoadPostPass
        if data.occupied ~= nil then
            SetOccupied(inst, data.occupied)
        end

        if data.regentimeremaining then
            for k,v in pairs(data.regentimeremaining) do
                if v > 0 then
                    inst.components.worldsettingstimer:StartTimer(k, v)
                end
            end
        end
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data and data.children and #data.children > 0 then
        for k,v in pairs(data.children) do
            local child = newents[v]
            if child then
                child = child.entity
                TrackMember(inst, child)
            end
        end

    end
end

local function create()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 3)

    inst.AnimState:SetBank("walrus_house")
    inst.AnimState:SetBuild("walrus_house")

    inst.MiniMapEntity:SetIcon("igloo.png")

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(2)
    inst.Light:SetColour(180/255, 195/255, 50/255)

    --inst:AddTag("tent")
    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("worldsettingstimer")
    inst.components.worldsettingstimer:AddTimer("walrus", TUNING.WALRUS_REGEN_PERIOD, TUNING.WALRUS_REGEN_ENABLED)
    inst.components.worldsettingstimer:AddTimer("little_walrus", TUNING.WALRUS_REGEN_PERIOD, TUNING.WALRUS_REGEN_ENABLED)
    inst.components.worldsettingstimer:AddTimer("icehound", TUNING.WALRUS_REGEN_PERIOD, TUNING.WALRUS_REGEN_ENABLED)

    inst.data = { children = {} }

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:WatchWorldState("startday", OnStartDay)

    inst:ListenForEvent("onwenthome", OnWentHome)

    inst.data.lighton = not TheWorld.state.isday
    inst.Light:Enable(inst.data.lighton)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    SetOccupied(inst, TheWorld.state.iswinter)

    inst:WatchWorldState("iswinter", OnIsWinter)

    return inst
end

return Prefab("walrus_camp", create, assets, prefabs)
