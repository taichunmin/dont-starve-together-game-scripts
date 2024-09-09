local assets =
{
    Asset("ANIM", "anim/alterguardian_spike.zip"),
}

local prefabs =
{
    "alterguardian_phase2spike",
    "alterguardian_spike_breakfx",
    -- "alterguardian_spiketrail_fx", -- not a real prefab so it doesnt need to have a depenancy chain
}

local SPIKE_WALL_RADIUS = 1.1

local SPIKE_CANT_TAGS = { "DECOR", "flying", "FX", "ghost", "INLIMBO", "NOCLICK", "playerghost", "shadow" }
local SPIKE_ONEOF_TAGS = { "_health", "CHOP_workable", "DIG_workable", "HAMMER_workable", "MINE_workable" }

local function DoAttack(inst, pos)
    local hit_a_target = false

    -- Attack as a proxy of the main alter guardian, UNLESS it died and left before we went off.
    local attacker = (inst._aguard ~= nil and inst._aguard:IsValid() and inst._aguard) or inst
    local attacker_combat = attacker.components.combat

    local old_damage = attacker_combat.defaultdamage
    attacker_combat.ignorehitrange = true
    attacker_combat:SetDefaultDamage(TUNING.ALTERGUARDIAN_PHASE2_SPIKEDAMAGE)

    pos = pos or inst:GetPosition()
    local x, y, z = pos:Get()

    local nearby_potential_targets = TheSim:FindEntities(x, y, z, SPIKE_WALL_RADIUS + 1, nil, SPIKE_CANT_TAGS, SPIKE_ONEOF_TAGS)
    for _, potential_target in ipairs(nearby_potential_targets) do
        if potential_target ~= inst._aguard and potential_target:IsValid()
                and not potential_target:IsInLimbo() then

            local dsq_to_target = potential_target:GetDistanceSqToPoint(x, y, z)

            if potential_target:HasTag("smashable") and dsq_to_target < (SPIKE_WALL_RADIUS^2) then
                potential_target.components.health:Kill()

                hit_a_target = true
            elseif potential_target.components.workable ~= nil
                    and potential_target.components.workable:CanBeWorked()
                    and potential_target.components.workable.action ~= ACTIONS.NET
                    and dsq_to_target < (SPIKE_WALL_RADIUS^2) then

                if not potential_target:HasTag("moonglass") then
                    SpawnPrefab("collapse_small").Transform:SetPosition(potential_target.Transform:GetWorldPosition())
                end

                potential_target.components.workable:Destroy(inst)

                hit_a_target = true
            elseif not (potential_target.components.health ~= nil and potential_target.components.health:IsDead()) then
                local rsq = (SPIKE_WALL_RADIUS + 0.25 + potential_target:GetPhysicsRadius(.5))^2
                if dsq_to_target <= rsq and inst.components.combat:CanTarget(potential_target) then
                    attacker_combat:DoAttack(potential_target)

                    hit_a_target = true
                end
            end
        end
    end

    attacker_combat.ignorehitrange = false
    attacker_combat:SetDefaultDamage(old_damage)

    return hit_a_target
end

local function SetOwner(inst, aguard)
    inst._aguard = aguard
end

local function try_spawn_spike(inst, pos)
    local did_hit = DoAttack(inst, pos)

    if did_hit then
        local breakfx = SpawnPrefab("alterguardian_spike_breakfx")
        breakfx.Transform:SetPosition(pos:Get())
    else
        local spike = SpawnPrefab("alterguardian_phase2spike")
        spike.Transform:SetPosition(pos:Get())
    end
end

local WALL_SPIKE_COUNT = 13
local WALL_SPIKE_DELAY = 5*FRAMES
local FORWARD_OFFSET = 0.4
local function emerge(inst)
    inst.Physics:Stop()
    inst._stop_trail:push()
    inst.SoundEmitter:KillSound("earthquake")

    local ipos = inst:GetPosition()
    try_spawn_spike(inst, ipos)

    if WALL_SPIKE_COUNT > 1 then
        if inst._rotation == nil then
            inst._rotation = inst.Transform:GetRotation()
        end
        local forward_angle_rad = inst._rotation * DEGREES
        local forward = Vector3(math.cos(forward_angle_rad), 0, -math.sin(forward_angle_rad))
        local perp = Vector3(forward.z, 0, -forward.x)

        for wall_index = 2, WALL_SPIKE_COUNT do
            local step = RoundBiasedUp((wall_index-1) / 2)
            inst:DoTaskInTime(step*WALL_SPIKE_DELAY, function(inst2)
                local x_step = perp * step * (SPIKE_WALL_RADIUS + 0.25)
                local z_step = forward * step * FORWARD_OFFSET
                local spawn_point = nil
                if IsNumberEven(wall_index) then
                    spawn_point = ipos + x_step - z_step
                else
                    spawn_point = ipos - x_step - z_step
                end

                if TheWorld.Map:IsPassableAtPoint(spawn_point:Get()) then
                    try_spawn_spike(inst, spawn_point)
                end
            end)
        end
    end

    ShakeAllCameras(CAMERASHAKE.FULL, .25, 0.05, 0.075, inst, 45)

    -- Make sure the remove is safely after all spikes are spawned.
    local safezone_remove_time = RoundBiasedUp(WALL_SPIKE_COUNT / 2) + 1
    inst:DoTaskInTime(WALL_SPIKE_DELAY * safezone_remove_time, inst.Remove)
end

local TRAIL_SPEED_PERSECOND = 20 --units/second
local WATER_CHECK_RATE = FRAMES
local function check_over_water(inst)
    local ipos = inst:GetPosition()

    if inst._rotation == nil then
        inst._rotation = inst.Transform:GetRotation()
    end

    local forward_angle_rad = inst._rotation * DEGREES
    local forward = Vector3(math.cos(forward_angle_rad), 0, -math.sin(forward_angle_rad))

    local check_pos = ipos + (forward * (TRAIL_SPEED_PERSECOND * WATER_CHECK_RATE))

    -- If we would be on an impassable point next check, just do our emerge now.
    if not TheWorld.Map:IsPassableAtPoint(check_pos:Get()) then
        emerge(inst)
        if inst._watertest_task ~= nil then
            inst._watertest_task:Cancel()
            inst._watertest_task = nil
        end
    end
end

local function MakeSpikeTrailPhysics(inst)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(0.1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:SetCapsule(0.1, 1)
end

local function CLIENT_on_stop_trail(inst)
    if inst._trail_task ~= nil then
        inst._trail_task:Cancel()
        inst._trail_task = nil
    end
end

local function createtrailfx()
    local inst = CreateEntity("alterguardian_spiketrail_fx")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("FX")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("alterguardian_spike")
    inst.AnimState:SetBuild("alterguardian_spike")
    inst.AnimState:PlayAnimation("trail")
    inst.AnimState:SetFinalOffset(-1)

    inst:ListenForEvent("animover", inst.Remove)

    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    return inst
end

local function CLIENT_spawn_trail_fx(inst)
    local fx = createtrailfx()
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function spiketrailfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeSpikeTrailPhysics(inst)

    inst.AnimState:SetBank("alterguardian_spike")
    inst.AnimState:SetBuild("alterguardian_spike")
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)

    inst.Transform:SetScale(0.75, 0.75, 0.75)

    inst:AddTag("groundspike")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    inst._stop_trail = net_event(inst.GUID, "alterguardian_phase2spike._stop_trail")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("alterguardian_phase2spike._stop_trail", CLIENT_on_stop_trail)

        inst._trail_task = inst:DoPeriodicTask(4*FRAMES, CLIENT_spawn_trail_fx)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetMotorVelOverride(TRAIL_SPEED_PERSECOND, 0, 0)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ALTERGUARDIAN_PHASE2_SPIKEDAMAGE)
    inst.components.combat:SetRange(0.75)
    inst.components.combat.battlecryenabled = false

    inst.persists = false

    inst.SetOwner = SetOwner

    inst._emerge_task = inst:DoTaskInTime(0.50 + (0.50 * math.random()), emerge)
    inst._watertest_task = inst:DoPeriodicTask(WATER_CHECK_RATE, check_over_water)

    --inst._aguard = nil
    --inst._rotation = nil

    inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
    inst.SoundEmitter:SetParameter("earthquake", "intensity", .1)

    return inst
end

local function spike_break(inst)
    inst.Physics:SetActive(false)

    inst.components.workable:SetWorkable(false)

    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("spike_pst")

    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/break",nil,.25)
end

local function on_spike_mining_finished(inst, worker)
    if inst._break_task ~= nil then
        inst._break_task:Cancel()
        inst._break_task = nil
    end

    spike_break(inst)
end

local function spikefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, SPIKE_WALL_RADIUS)
    inst.Physics:SetDontRemoveOnSleep(true)

    inst.AnimState:SetBank("alterguardian_spike")
    inst.AnimState:SetBuild("alterguardian_spike")
    inst.AnimState:PlayAnimation("spike_pre")
    inst.AnimState:PushAnimation("spike_loop", true)

    inst.SoundEmitter:PlaySoundWithParams("moonstorm/creatures/boss/alterguardian2/spike",  { intensity = math.random() })

    inst:AddTag("groundspike")
    inst:AddTag("moonglass")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(on_spike_mining_finished)

    inst.persists = false

    inst._break_task = inst:DoTaskInTime(TUNING.ALTERGUARDIAN_PHASE2_SPIKE_LIFETIME, spike_break)

    return inst
end

return Prefab("alterguardian_phase2spiketrail", spiketrailfn, assets, prefabs),
        Prefab("alterguardian_phase2spike", spikefn, assets)
