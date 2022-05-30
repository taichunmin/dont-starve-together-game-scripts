local assets =
{
    Asset("ANIM", "anim/tentacle_pillar.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs =
{
    "tentacle_pillar_arm",
    "tentacle_pillar_hole",

    --loot
    "tentaclespike",
    "tentaclespots",
    "turf_marsh",
    "rocks",
}

SetSharedLootTable("tentacle_pillar",
{
    { 'tentaclespike' , 0.50 },
    { 'turf_marsh'    , 0.25 },
    { 'tentaclespots' , 0.40 },
    { 'rocks'         , 1.00 },
})

-- Kill off the arms in the garden, optionally just those further than the given distance from any players
local function KillArms(inst, instant, fartherThan)
    if fartherThan == nil then
        for arm, _ in pairs(inst.arms) do
            if instant then
                arm:Remove()
            else
                inst._onstoptrackingarm(arm)
                arm:PushEvent("full_retreat")
            end
        end
    else
        for arm, v in pairs(inst.arms) do
            if not (arm:IsNear(inst, 4) or arm:IsNearPlayer(fartherThan, true)) then
                inst._onstoptrackingarm(arm)
                arm:PushEvent("full_retreat")
            end
        end
    end
end

local function StartTrackingArm(inst, arm)
    inst.arms[arm] = true
    inst.numArms = inst.numArms + 1
    inst:ListenForEvent("onremove", inst._onstoptrackingarm, arm)
    inst:ListenForEvent("death", inst._onstoptrackingarm, arm)
end

local FINDARMS_MUST_TAGS = { "tentacle_pillar" }
local function SpawnArms(inst, attacker)
    if inst.numArms >= TUNING.TENTACLE_PILLAR_ARMS_TOTAL - 3 then
        --despawn tentacles away from players
        KillArms(inst, false, 6)
        inst.spawnLocal = true
        return
    elseif inst.numArms >= TUNING.TENTACLE_PILLAR_ARMS_TOTAL then
        return
    end

    --spawn tentacles to spring the trap
    local pt = inst:GetPosition()
    local pillarLoc = pt
    local minRadius = 3
    local ringdelta = 1.5
    local rings = 3
    local steps = math.floor(TUNING.TENTACLE_PILLAR_ARMS / rings + 0.5)
    if attacker ~= nil and inst.spawnLocal then
        pt = attacker:GetPosition()
        minRadius = 1
        ringdelta = 1
        rings = 3
        steps = 4
        inst.spawnLocal = nil
    end

    -- Walk the circle trying to find a valid spawn point
    local map = TheWorld.Map
    for r = 1, rings do
        local theta = GetRandomWithVariance(0, PI / 2)
        for i = 1, steps do
            local radius = GetRandomWithVariance(ringdelta, ringdelta / 3) + minRadius
            local x = pt.x + radius * math.cos(theta)
            local z = pt.z - radius * math.sin(theta)
            local pillars = TheSim:FindEntities(x, 0, z, 3.5, FINDARMS_MUST_TAGS)
            if #pillars > 0 then
                pillarLoc = pillars[1]:GetPosition()
            end
            if map:IsAboveGroundAtPoint(x, 0, z) and
                distsq(x, z, pillarLoc.x, pillarLoc.z) > 8 and
                not map:IsPointNearHole(Vector3(x, 0, z)) then
                local arm = SpawnPrefab("tentacle_pillar_arm")
                StartTrackingArm(inst, arm)
                arm.Transform:SetPosition(x, 0, z)
                if inst.numArms >= TUNING.TENTACLE_PILLAR_ARMS_TOTAL then
                    return
                end
            end
            theta = theta - 2 * PI / steps
        end
        minRadius = minRadius + ringdelta
    end
end

local function OnFar(inst)
    for arm, _ in pairs(inst.arms) do
        arm:Retract()
    end
end

local function OnHit(inst, attacker, damage)
    if attacker.components.combat ~= nil and not attacker:HasTag("player") and math.random() < .5 then
        -- Followers should stop hitting the pillar
        attacker.components.combat:SetTarget(nil)
    end
    if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hurt_VO")
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)

        if attacker:HasTag("player") then
            attacker:ShakeCamera(CAMERASHAKE.SIDE, .5, .05, .2)
        end
        SpawnArms(inst, attacker)
    end
end

local function OnEmergeOver(inst)
    inst:RemoveEventCallback("animover", OnEmergeOver)
    inst:RemoveTag("notarget")
    inst.components.health:SetInvincible(false)

    inst.AnimState:PlayAnimation("idle", true)
end

local function OnEmerge(inst)
    if not inst.components.health:IsDead() then
        inst:AddTag("notarget")
        inst.components.health:SetInvincible(true)

        inst.AnimState:PlayAnimation("emerge")

        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_emerge")

        ShakeAllCameras(CAMERASHAKE.FULL, 5, .05, .2, inst, 40)

        inst:ListenForEvent("animover", OnEmergeOver)
    end
end

local function DoRetract(inst)
    if not inst.components.health:IsDead() then
        inst:RemoveEventCallback("animover", OnEmergeOver)
        inst.components.health:SetInvincible(false)
        inst.components.health:Kill()
    end
end

local function SwapToHole(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local other = inst.components.teleporter.targetTeleporter

    inst:Remove()

    inst = SpawnPrefab("tentacle_pillar_hole")
    inst.Transform:SetPosition(x, y, z)

    if other ~= nil then
        inst.components.teleporter:Target(other)
        other.components.teleporter:Target(inst)
        if other.prefab == "tentacle_pillar" then
            inst.components.teleporter:SetEnabled(false)
            inst.components.trader:Disable()
            DoRetract(other)
        else
            other.components.teleporter:SetEnabled(true)
            other.components.trader:Enable()
        end
    else
        inst.components.teleporter:SetEnabled(false)
        inst.components.trader:Disable()
    end
end

local function OnDeath(inst)
    KillArms(inst, false)

    local x, y, z = inst.Transform:GetWorldPosition()
    inst.components.lootdropper:DropLoot(Vector3(x, 20, z))

    if inst:IsAsleep() then
        SwapToHole(inst)
    else
        inst.AnimState:PlayAnimation("retract")

        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_die")
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_die_VO")

        ShakeAllCameras(CAMERASHAKE.FULL, 5, .05, .2, inst, 40)

        inst:ListenForEvent("animover", SwapToHole)
        inst:ListenForEvent("entitysleep", SwapToHole)
    end

    local other = inst.components.teleporter.targetTeleporter
    if other ~= nil and other.prefab == "tentacle_pillar" then
        DoRetract(other)
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_idle_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
    KillArms(inst, true)
    inst.spawnLocal = nil
end

--NOTE: This can also be called directly from tentacle_pillar_hole:OnLoadPostPass
local function OnLoadPostPass(inst)
    local other = inst.components.teleporter.targetTeleporter
    if other ~= nil and
        other.prefab == "tentacle_pillar_hole" and
        other.components.teleporter.targetTeleporter == inst then
        DoRetract(inst)
    end
end

local function CustomOnHaunt(inst, haunter)
    if math.random() < TUNING.HAUNT_CHANCE_RARE and
        not (inst.components.health:IsDead() or
            inst:HasTag("notarget")) then
        DoRetract(inst)
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2, 24)

    -- HACK: this should really be in the c side checking the maximum size of the anim or the _current_ size of the anim instead
    -- of frame 0
    inst.entity:SetAABB(60, 20)

    inst:AddTag("cavedweller")
    inst:AddTag("tentacle_pillar")
    inst:AddTag("wet")

    inst.MiniMapEntity:SetIcon("tentacle_pillar.png")

    inst.AnimState:SetBank("tentaclepillar")
    inst.AnimState:SetBuild("tentacle_pillar")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_PILLAR_HEALTH)
    inst.components.health.nofadeout = true
    inst:ListenForEvent("death", OnDeath)

    -------------------
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 30)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
    inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)

    -------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('tentacle_pillar')

    --------------------
    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(OnHit)

    --------------------
    inst:AddComponent("inspectable")

    --------------------
    inst:AddComponent("teleporter")
    inst.components.teleporter:SetEnabled(false)

    --------------------

    AddHauntableCustomReaction(inst, CustomOnHaunt)

    inst.OnEmerge = OnEmerge
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnLoadPostPass = OnLoadPostPass

    inst.numArms = 0
    inst.arms = {}
    inst._onstoptrackingarm = function(arm)
        if inst.arms[arm] then
            inst.arms[arm] = nil
            inst.numArms = inst.numArms - 1
        end
    end

    return inst
end

return Prefab("tentacle_pillar", fn, assets, prefabs)
