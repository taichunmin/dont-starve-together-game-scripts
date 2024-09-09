local assets =
{
    Asset("ANIM", "anim/stagehand.zip"),
    Asset("ANIM", "anim/stagehand_sts.zip"),
}

local armassets =
{
    Asset("ANIM", "anim/stagehand_sts_arm.zip"),
}

local prefabs = {
    "stageusher_attackarm",
    "stageusher_attackhand",
}

--------------------------------------------------------------------------------
local brain = require("brains/stageusherbrain")

--------------------------------------------------------------------------------
local function usher_onworked(inst, worker)
    inst.components.combat:SuggestTarget(worker)
end

local function usher_onfinishedworking(inst, worker)
    inst.components.combat:GiveUp()
end

--------------------------------------------------------------------------------
local function usher_keep_target(inst, target)
    return inst.components.combat:CanTarget(target)
        and inst:IsNear(target, 2*TUNING.STAGEUSHER_ATTACK_RANGE)
end

local function usher_should_aggro(inst, target)
    -- Ignore attempts to set our combat target if we're on fire. Helps get around
    -- things like the firestaff, which offensively set the combat target if you have
    -- a combat component.
    return (inst.components.burnable == nil or not inst.components.burnable:IsBurning())
end

--------------------------------------------------------------------------------
local function SetPhysicsState(inst, set_to_standing)
    local is_blocker = inst:HasTag("blocker")
    if set_to_standing then
        if is_blocker then
            inst:RemoveTag("blocker")
            inst:RemoveTag("notarget")
            inst.Physics:SetMass(100)
            inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end
    else
        if not is_blocker then
            inst:AddTag("blocker")
            inst:AddTag("notarget")
            inst.Physics:SetMass(0)
            inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.ITEMS)
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.GIANTS)
        end
    end
end

--------------------------------------------------------------------------------
local function StartAttackingTarget(inst, target)
    if target == nil or not target:IsValid() then
        return false
    end

    local ipos = inst:GetPosition()
    local tpos = target:GetPosition()
    local unit_target_vec = (tpos - ipos):GetNormalized()

    local attack_hand = SpawnPrefab("stageusher_attackhand")
    attack_hand.Transform:SetPosition((ipos + unit_target_vec*0.5):Get())
    attack_hand:SetOwner(inst)
    attack_hand:SetCreepTarget(target)

    if inst._on_hand_removed == nil then
        inst._on_hand_removed = function(hand) inst:PushEvent("handfinished") end
    end
    inst:ListenForEvent("onremove", inst._on_hand_removed, attack_hand)

    return true
end

--------------------------------------------------------------------------------
local function IsStanding(inst)
    return inst._is_standing
end

local function ChangeStanding(inst, new_standing)
    new_standing = new_standing or not inst._is_standing
    if new_standing and not inst._is_standing then
        inst._is_standing = true
        inst.components.combat.canattack = true
        SetPhysicsState(inst, inst._is_standing)
    elseif not new_standing and inst._is_standing then
        inst._is_standing = false
        inst.components.combat.canattack = false
        SetPhysicsState(inst, inst._is_standing)

        -- Reset our work and health when we sit down.
        inst.components.workable:SetWorkLeft(TUNING.STAGEHAND_HITS_TO_GIVEUP)
        inst.components.health:SetPercent(1)
    end
end

--------------------------------------------------------------------------------
local function GetStatus(inst)
    return (IsStanding(inst) and "STANDING") or "SITTING"
end

--------------------------------------------------------------------------------
local function on_giveup_timer_done(inst)
	inst._giveup_timer = nil
	if inst.components.combat:HasTarget() then
		inst.components.combat:GiveUp()
	end
end

local function restart_giveup_timer(inst)
	if inst._giveup_timer ~= nil then
		inst._giveup_timer:Cancel()
	end
	inst._giveup_timer = inst:DoTaskInTime(TUNING.STAGEUSHER_GIVEUP_TIME, on_giveup_timer_done)
end

local function on_new_combat_target(inst)
    inst:PushEvent("standup")
	restart_giveup_timer(inst)
end

local function on_dropped_target(inst)
	if inst._giveup_timer ~= nil then
		inst._giveup_timer:Cancel()
		inst._giveup_timer = nil
	end
end

local function on_attacked(inst)
	if inst.components.health.currenthealth > inst.components.health.minhealth then
		restart_giveup_timer(inst)
	end
end

--------------------------------------------------------------------------------
local function OnSave(inst, data)
    data.is_standing = inst:IsStanding()
end

local function OnLoad(inst, data)
    if data ~= nil then
        -- We load into the sitting state, so we only need to swap
        -- when we saved as standing.
        if data.is_standing then
            ChangeStanding(inst, true)
        end
    end
end

--------------------------------------------------------------------------------=
local USHER_PATHCAPS = { ignorecreep = true }
local FIRE_OFFSET = Vector3(0, 0, 0)
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2.5, 1.5)

    inst.Transform:SetFourFaced()

    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    SetPhysicsState(inst, false)
    inst.Physics:SetCapsule(0.5, 1.0)

    inst.AnimState:SetBank("stagehand")
    inst.AnimState:SetBuild("stagehand_sts")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("dark_spew", "stagehand", "dark_spew")
    inst.AnimState:OverrideSymbol("fx", "stagehand", "fx")
    inst.AnimState:OverrideSymbol("stagehand_fingers", "stagehand", "stagehand_fingers")

    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("notarget")
    inst:AddTag("notraptrigger")
    inst:AddTag("stageusher")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_hidehealth = true

    ----------------------------------------------------------------------------
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("campfirefire", FIRE_OFFSET, "swap_fire")

    ----------------------------------------------------------------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4.0
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = USHER_PATHCAPS

    ----------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    ----------------------------------------------------------------------------
    inst:AddComponent("knownlocations")

    ----------------------------------------------------------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.STAGEHAND_HITS_TO_GIVEUP)
    inst.components.workable:SetOnWorkCallback(usher_onworked)
    inst.components.workable:SetOnFinishCallback(usher_onfinishedworking)

    ----------------------------------------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STAGEUSHER_GIVEUP_HEALTH)
    inst.components.health:SetMinHealth(1)

    ----------------------------------------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.STAGEUSHER_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STAGEUSHER_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.STAGEUSHER_ATTACK_RANGE)
    inst.components.combat:SetKeepTargetFunction(usher_keep_target)
    inst.components.combat:SetShouldAggroFn(usher_should_aggro)
    --inst.components.combat.playerdamagepercent = maybe
    inst.components.combat.ignorehitrange = true
    inst.components.combat.canattack = false

    ----------------------------------------------------------------------------
    inst._is_standing = false
    inst.IsStanding = IsStanding
    inst.ChangeStanding = ChangeStanding

    ----------------------------------------------------------------------------
    inst.StartAttackingTarget = StartAttackingTarget

    ----------------------------------------------------------------------------
    inst:ListenForEvent("newcombattarget", on_new_combat_target)
	inst:ListenForEvent("droppedtarget", on_dropped_target)
	inst:ListenForEvent("attacked", on_attacked)

    ----------------------------------------------------------------------------
    inst:SetStateGraph("SGstageusher")
    inst:SetBrain(brain)

    ----------------------------------------------------------------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

------------------------------------------------------------------------------------------------------------------------
local NUM_ARM_LOOPS = 3
local function create_shadow_arm(inst, ipos, tpos)
    local arm = SpawnPrefab("stageusher_attackarm")
    arm.Transform:SetPosition(ipos:Get())
    arm:FacePoint(tpos:Get())

    inst._arm_anim = (inst._arm_anim or 0) + 1
    if inst._arm_anim > NUM_ARM_LOOPS then
        inst._arm_anim = 1
    end
    arm.AnimState:PlayAnimation("arm_loop"..tostring(inst._arm_anim), true)

    arm.components.stretcher:SetStretchTarget(inst)
    arm:ListenForEvent("onremove", function() arm:Remove() end, inst)

    if inst._arms == nil then
        inst._arms = {}
    end
    table.insert(inst._arms, arm)

    return arm
end

--------------------------------------------------------------------------------
local on_reached_destination = nil

--------------------------------------------------------------------------------
local function new_creep(inst, ipos, tpos)
    inst:FacePoint(tpos:Get())
    inst:DoTaskInTime(TUNING.STAGEUSHER_ATTACK_STEPTIME, on_reached_destination)
end

local function start_new_creep(inst)
    if inst._target == nil then
        return false
    end

    --------------------------------
    if inst._arms ~= nil then
        inst._arms[#inst._arms].components.stretcher:SetStretchTarget(nil)
    end

    --------------------------------
    local ipos = inst:GetPosition()
    local tpos = inst._target:GetPosition()

    create_shadow_arm(inst, ipos, tpos)
    new_creep(inst, ipos, tpos)

    return true
end

--------------------------------------------------------------------------------
local function on_grab_anim_over(inst)
    inst:RemoveEventCallback("animover", on_grab_anim_over)

    -- Play some animations to indicate we're going away.
    if inst._arms ~= nil then
        for _, arm in ipairs(inst._arms) do
            arm.AnimState:PlayAnimation("arm_scare"..tostring(math.random(1,4)))
        end
    end
    inst.AnimState:PlayAnimation("hand_scare")

    inst.SoundEmitter:KillSound("creeping")
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_snuff")

    inst:ListenForEvent("animover", inst.Remove)
end

local function hand_dissipate(inst)
    if inst._is_dissipating then
        return
    else
        inst._is_dissipating = true
    end

    -- Stop the hand from moving any more while it plays its fadeout.
    inst.Physics:Stop()

    if inst.components.updatelooper ~= nil then
        inst:RemoveComponent("updatelooper")
    end

    inst.AnimState:PlayAnimation("grab")
    inst:ListenForEvent("animover", on_grab_anim_over)
end

on_reached_destination = function(inst)
    local creep_succeeded = false
    inst._destination_steps = (inst._destination_steps or TUNING.STAGEUSHER_ATTACK_STEPS) - 1
    if inst._destination_steps > 0 then
        creep_succeeded = start_new_creep(inst)
    end

    if not creep_succeeded then
        hand_dissipate(inst)
    end
end

--------------------------------------------------------------------------------
local function SetOwner(inst, owner)
    inst._owner = owner
    inst:ListenForEvent("onremove", inst._on_owner_removed, owner)
end

--------------------------------------------------------------------------------
local ARM_ATTACK_TEST_RATE = 4*FRAMES
local ARM_TARGETS_MUST = {"_combat"}

-- If we're targetting a player, we can hit players. If not, we can't.
local ARM_TARGETS_CANT = {"NOCLICK", "DECOR", "FX", "NOTARGET", "flying", "ghost", "playerghost", "stageusher"}
local ARM_TARGETS_CANT_WITHPLAYER = {"NOCLICK", "DECOR", "FX", "NOTARGET", "flying", "ghost", "playerghost", "stageusher", "player"}
local function test_for_damage_targets(inst, dt)
    inst._attack_time = inst._attack_time + dt
    if inst._attack_time < ARM_ATTACK_TEST_RATE then
        return
    else
        inst._attack_time = inst._attack_time - ARM_ATTACK_TEST_RATE
    end

    if inst._target == nil then
        return
    end

    inst._last_hits = inst._last_hits or {}
    local current_time = GetTime()

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local potential_hits = TheSim:FindEntities(
        ix, iy, iz,
        TUNING.STAGEUSHER_ATTACK_DAMAGERADIUS,
        ARM_TARGETS_MUST,
        (inst._target:HasTag("player") and ARM_TARGETS_CANT) or ARM_TARGETS_CANT_WITHPLAYER
    )
    for _, potential_hit in ipairs(potential_hits) do
        local last_hit_time = inst._last_hits[potential_hit]
        if last_hit_time == nil or (last_hit_time + TUNING.STAGEUSHER_ATTACK_STEPTIME) < current_time then
            inst._last_hits[potential_hit] = current_time

            if inst._owner ~= nil then
                -- NOTE: we are assuming that our owner has combat.ignorehitrange set already
                inst._owner.components.combat:DoAttack(potential_hit)
            else
                potential_hit.components.combat:GetAttacked(inst, TUNING.STAGEUSHER_ATTACK_DAMAGE)
            end
        end
    end
end

local function SetCreepTarget(inst, target)
    inst._target = target
    inst:ListenForEvent("onremove", inst._on_target_removed, target)

    ---------------------------------------
    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(test_for_damage_targets)

    ---------------------------------------
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_creep", "creeping")

    ---------------------------------------
    -- We don't want the hand to slow down, so we just set the physics velocity once,
    -- and let it run straight until the end.
    inst.Physics:SetMotorVel(TUNING.STAGEUSHER_ATTACK_SPEED, 0, 0)

    ---------------------------------------
    local ipos = inst:GetPosition()
    local tpos = target:GetPosition()

    create_shadow_arm(inst, ipos, tpos)
    new_creep(inst, ipos, tpos)
end

--------------------------------------------------------------------------------
local HAND_PATHCAPS = { ignorecreep = true }
local function handfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)
    RemovePhysicsColliders(inst)

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("NOCLICK")
    inst:AddTag("shadowhand")

    inst.AnimState:SetBank("stagehand_sts_arm")
    inst.AnimState:SetBuild("stagehand_sts_arm")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:PlayAnimation("hand_in")
    inst.AnimState:PushAnimation("hand_in_loop", true)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    ------------------------------
    inst._on_owner_removed = function(owner)
        inst:Remove()
    end
    inst._on_target_removed = function(target)
        inst._target = nil
        if inst.components.updatelooper ~= nil then
            inst:RemoveComponent("updatelooper")
        end
    end

    ------------------------------
    inst._attack_time = 0
    --inst._target = nil
    inst.SetOwner = SetOwner
    inst.SetCreepTarget = SetCreepTarget

    inst.persists = false

    return inst
end

------------------------------------------------------------------------------------------------------------------------
local function armfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.AnimState:SetBank("stagehand_sts_arm")
    inst.AnimState:SetBuild("stagehand_sts_arm")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------
    inst:AddComponent("stretcher")
    inst.components.stretcher:SetRestingLength(2.5)
    inst.components.stretcher:SetWidthRatio(0.1)

    ------------------------------
    inst.persists = false

    return inst
end

return Prefab("stageusher", fn, assets, prefabs),
    Prefab("stageusher_attackhand", handfn, armassets),
    Prefab("stageusher_attackarm", armfn, armassets)
