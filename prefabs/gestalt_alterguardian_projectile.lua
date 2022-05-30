require "prefabutil"

local gestalt_assets =
{
    Asset("ANIM", "anim/brightmare_gestalt.zip"),
}
local gestalt_prefabs =
{
    "gestalt_head",
}

local guard_assets =
{
    Asset("ANIM", "anim/brightmare_gestalt_evolved.zip"),
}
local guard_prefabs =
{
    "gestalt_guard_head",
}

local function SetTargetPosition(inst, target_pos)
    inst._target_pos = target_pos
end

local function Client_CalcSanityForTransparency(inst, observer)
    if observer ~= nil and observer.replica.sanity ~= nil then
        local observer_sanity = observer.replica.sanity:GetPercentWithPenalty()
        local x = (observer_sanity - TUNING.GESTALT_MIN_SANITY_TO_SPAWN) / (1 - TUNING.GESTALT_MIN_SANITY_TO_SPAWN)

        return math.min(0.4*x*x*x + 0.3, 0.75)
    else
        return 0.3
    end
end

local function SetHeadAlpha(inst, alpha)
    if inst.blobhead ~= nil and inst.blobhead:IsValid() then
        inst.blobhead.AnimState:SetMultColour(alpha, alpha, alpha, alpha)
    end
end

local function stop_motion(inst)
    if inst._attack_task ~= nil then
        inst._attack_task:Cancel()
        inst._attack_task = nil
    end

    inst.AnimState:PlayAnimation("mutate")
    inst.Physics:SetMotorVelOverride(2, 0, 0)
end

local function attack_behaviour(inst, target)
    if inst.components.combat ~= nil then
        if inst.components.combat:CanTarget(target) then
            inst.components.combat:DoAttack(target)

            return true
        else
            return false
        end
    else
        if target.components.sanity ~= nil then
            target.components.sanity:DoDelta(TUNING.GESTALT_ATTACK_DAMAGE_SANITY)
        end

        if target.components.grogginess ~= nil and not target.sg:HasStateTag("knockout") then
            target.components.grogginess:AddGrogginess(TUNING.GESTALT_ATTACK_DAMAGE_GROGGINESS, TUNING.GESTALT_ATTACK_DAMAGE_KO_TIME)
            if target.components.grogginess.knockoutduration == 0 then
                target:PushEvent("attacked", {attacker = inst, damage = 0})
            end
        elseif target.components.sleeper ~= nil and not target.sg:HasStateTag("sleeping") then
            target.components.sleeper:AddSleepiness(TUNING.GESTALT_ATTACK_DAMAGE_GROGGINESS, TUNING.GESTALT_ATTACK_DAMAGE_KO_TIME)
            if not target.components.sleeper:IsAsleep() then
                target:PushEvent("attacked", {attacker = inst, damage = 0})
            end
        else
            target:PushEvent("attacked", {attacker = inst, damage = 0})
        end

        return true
    end
end

local function try_attack(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local target = inst:find_attack_victim()

    if target == nil then
        return
    else
        -- Attack the target.
        if attack_behaviour(inst, target) then
            -- If our attack succeeded, go straight to our stop state instead of waiting.
            if inst._stop_task ~= nil then
                inst._stop_task:Cancel()
                inst._stop_task = nil
            end
            stop_motion(inst)
        end
    end
end

local function start_motion(inst)
    inst.Physics:SetMotorVelOverride(inst.attack_speed, 0, 0)
    inst._attack_task = inst:DoPeriodicTask(2*FRAMES, try_attack)
end

local function on_anim_over(inst)
    if inst.AnimState:IsCurrentAnimation("emerge") then
        if inst._target_pos ~= nil then
            inst:ForceFacePoint(inst._target_pos:Get())
        else
            inst.Transform:SetRotation(math.random() * 360)
        end
        inst.AnimState:PlayAnimation("attack")

        inst:DoTaskInTime(15*FRAMES, start_motion)
        inst._stop_task = inst:DoTaskInTime(25*FRAMES, stop_motion)

    elseif inst.AnimState:IsCurrentAnimation("mutate") then
        inst:Remove()
    end
end

local DEFAULT_FINDVICTIM_MUST = {"_health"}
local DEFAULT_FINDVICTIM_CANT =
{
    "brightmareboss",
    "brightmare",
    "DECOR",
    "epic",
    "FX",
    "ghost",
    "INLIMBO",
    "playerghost",
}
local DEFAULT_FINDVICTIM_RANGE = math.sqrt(TUNING.GESTALT_ATTACK_HIT_RANGE_SQ)
local function default_find_attack_victim(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local target = nil

    local rangesq = TUNING.GESTALT_ATTACK_HIT_RANGE_SQ
    local potential_targets = TheSim:FindEntities(
        x, y, z, DEFAULT_FINDVICTIM_RANGE,
        DEFAULT_FINDVICTIM_MUST, DEFAULT_FINDVICTIM_CANT, nil
    )

    for _, v in ipairs(potential_targets) do
        if not v.components.health:IsDead()
                and v.entity:IsVisible()
                and (v.sg == nil or
                    not (v.sg:HasStateTag("knockout") or
                        v.sg:HasStateTag("sleeping") or
                        v.sg:HasStateTag("bedroll") or
                        v.sg:HasStateTag("tent") or
                        v.sg:HasStateTag("waking"))
                    ) then
            local dsq = v:GetDistanceSqToPoint(x, y, z)
            if dsq < rangesq then
                rangesq = dsq
                target = v
            end
        end
    end

    return target
end

local function on_entity_sleep(inst)
    if not POPULATING then
        inst._esleep_remove_task = inst:DoTaskInTime(3, inst.Remove)
    end
end

local function on_entity_wake(inst)
    if inst._esleep_remove_task ~= nil then
        inst._esleep_remove_task:Cancel()
        inst._esleep_remove_task = nil
    end
end

local function commonfn(buildbank, headdata, tags, common_postinit, master_postinit, no_aura)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- Custom physics settings
    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.GROUND)
    phys:SetCapsule(0.5, 1)

    inst:AddTag("brightmare")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    if tags ~= nil then
        for _, tag in ipairs(tags) do
            inst:AddTag(tag)
        end
    end

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild(buildbank)
    inst.AnimState:SetBank(buildbank)
    inst.AnimState:PlayAnimation("emerge")

	local colour_mult = TUNING.GESTALT_COMBAT_TRANSPERENCY
	inst.AnimState:SetMultColour(colour_mult, colour_mult, colour_mult, colour_mult)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    if not TheNet:IsDedicated() then
        inst.blobhead = SpawnPrefab(headdata.name)
        inst.blobhead.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
        inst.blobhead.Follower:FollowSymbol(inst.GUID, headdata.followsymbol, 0, 0, 0)

        inst.blobhead.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        inst.highlightchildren = { inst.blobhead }

        inst:AddComponent("transparentonsanity")
        inst.components.transparentonsanity.most_alpha = .8
        inst.components.transparentonsanity.osc_amp = .05
        inst.components.transparentonsanity.osc_speed = 5.25 + math.random() * 0.5
        inst.components.transparentonsanity.calc_percent_fn = Client_CalcSanityForTransparency
        inst.components.transparentonsanity.onalphachangedfn = SetHeadAlpha
        inst.components.transparentonsanity:OnUpdate(0)
    end

    if common_postinit ~= nil then
        common_postinit(inst)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SetTargetPosition = SetTargetPosition

    -- May be re-assigned in child fns.
    inst.attack_speed = TUNING.ALTERGUARDIAN_PROJECTILE_SPEED
    inst.find_attack_victim = default_find_attack_victim

	if not no_aura then
		inst:AddComponent("sanityaura")
		inst.components.sanityaura.aura = TUNING.SANITYAURA_MED
	end

    inst:ListenForEvent("animover", on_anim_over)

    inst.OnEntitySleep = on_entity_sleep
    inst.OnEntityWake = on_entity_wake

    if master_postinit ~= nil then
        master_postinit(inst)
    end

    return inst
end

----------- gestalt_alterguardian_projectile -----------
local GESTALT_HEADDATA =
{
    name = "gestalt_head",
    followsymbol = "head_fx",
}
local GESTALT_TAGS = { "brightmare_gestalt" }

local function gestaltfn()
    local inst = commonfn("brightmare_gestalt", GESTALT_HEADDATA, GESTALT_TAGS)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

----------- smallguard_alterguardian_projectile -----------
local GUARD_HEADDATA =
{
    name = "gestalt_guard_head",
    followsymbol = "brightmare_gestalt_head_evolved",
}
local GUARD_TAGS = { "brightmare_guard", "crazy", "extinguisher" }

local SMALLGUARD_SCALE = 0.75
local function smallguard_common_postinit(inst)
    inst.Transform:SetScale(SMALLGUARD_SCALE, SMALLGUARD_SCALE, SMALLGUARD_SCALE)

    if not TheNet:IsDedicated() then
        if inst.blobhead ~= nil then
            inst.blobhead.Transform:SetScale(SMALLGUARD_SCALE, SMALLGUARD_SCALE, SMALLGUARD_SCALE)
        end
    end
end

local SMALLGUARD_DAMAGE = 0.75 * TUNING.GESTALTGUARD_DAMAGE
local function smallguardfn()
    local inst = commonfn("brightmare_gestalt_evolved", GUARD_HEADDATA, GUARD_TAGS, smallguard_common_postinit)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.attack_speed = TUNING.ALTERGUARDIAN_PROJECTILE_SPEED / SMALLGUARD_SCALE

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(SMALLGUARD_DAMAGE)
    inst.components.combat:SetRange(TUNING.GESTALTGUARD_ATTACK_RANGE)

    return inst
end

----------- alterguardianhat_projectile -----------
local HATGUARD_COMBAT_MUSHAVE_TAGS = { "_combat", "_health" }
local HATGUARD_COMBAT_CANTHAVE_TAGS = { "INLIMBO", "structure", "wall" }

local function hatguard_find_attack_victim(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 0.75, HATGUARD_COMBAT_MUSHAVE_TAGS, HATGUARD_COMBAT_CANTHAVE_TAGS)
	for _, target in ipairs(ents) do
		if (target.components.health ~= nil and not target.components.health:IsDead())
			and (target.components.combat ~= nil and not inst.components.combat:TargetHasFriendlyLeader(target) and inst.components.combat:CanTarget(target)) then
			return target
		end
	end
end

local HATGUARD_SCALE = 0.4
local function hatguard_common_postinit(inst)
    inst.Transform:SetScale(HATGUARD_SCALE, HATGUARD_SCALE, HATGUARD_SCALE)

    if not TheNet:IsDedicated() then
        if inst.blobhead ~= nil then
            inst.blobhead.Transform:SetScale(HATGUARD_SCALE, HATGUARD_SCALE, HATGUARD_SCALE)
        end
    end
end

local function hatguardfn()
    local inst = commonfn("brightmare_gestalt_evolved", GUARD_HEADDATA, GUARD_TAGS, hatguard_common_postinit, nil, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.attack_speed = TUNING.ALTERGUARDIAN_PROJECTILE_SPEED / HATGUARD_SCALE
    inst.find_attack_victim = hatguard_find_attack_victim

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ALTERGUARDIANHAT_GESTALT_DAMAGE)
    inst.components.combat:SetRange(TUNING.GESTALTGUARD_ATTACK_RANGE)

	inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

    return inst
end

----------- largeguard_alterguardian_projectile -----------
--[[ Defined above, repeated for posterity.
local GUARD_HEADDATA =
{
    name = "gestalt_guard_head",
    followsymbol = "brightmare_gestalt_head_evolved",
}
local GUARD_TAGS = { "brightmare_guard", "crazy", "extinguisher" }
]]

local function largeguardfn()
    local inst = commonfn("brightmare_gestalt_evolved", GUARD_HEADDATA, GUARD_TAGS)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.attack_speed = TUNING.ALTERGUARDIAN_PROJECTILE_SPEED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.GESTALTGUARD_DAMAGE)
    inst.components.combat:SetRange(TUNING.GESTALTGUARD_ATTACK_RANGE)

    return inst
end


return Prefab("gestalt_alterguardian_projectile", gestaltfn, gestalt_assets, gestalt_prefabs),
        Prefab("smallguard_alterguardian_projectile", smallguardfn, guard_assets, guard_prefabs),
        Prefab("alterguardianhat_projectile", hatguardfn, guard_assets, guard_prefabs),
        Prefab("largeguard_alterguardian_projectile", largeguardfn, guard_assets, guard_prefabs)
