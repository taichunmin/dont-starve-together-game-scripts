require "prefabutil"

local assets_robin =
{
    Asset("ANIM", "anim/mutated_robin.zip"),
    Asset("ANIM", "anim/bird_mutant_spitter_build.zip"),
}

local assets_crow =
{
    Asset("ANIM", "anim/mutated_crow.zip"),
    Asset("ANIM", "anim/bird_mutant_build.zip"),
}

local prefabs =
{
	"bilesplat",
}

SetSharedLootTable( 'bird_mutant',
{
    {'spoiled_food',       1.00},
})

local brain = require "brains/bird_mutant_brain"
local easing = require("easing")

----------------------------------------------------------

local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("bilesplat")
    projectile.Transform:SetPosition(x, y, z)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    --local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)
    local speed = easing.linear(rangesq, 15, 1, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-35)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    projectile.shooter = inst
end

local function IsNearInvadeTarget(inst, dist)
    local target = inst.components.entitytracker:GetEntity("swarmTarget")
    return target == nil or inst:IsNear(target, dist)
end

local RETARGET_MUST_TAGS = { "_combat" }
local INVADER_RETARGET_CANT_TAGS = { "playerghost", "INLIMBO"}
local function Retarget(inst)
    return IsNearInvadeTarget(inst, TUNING.MUTANT_BIRD_AGGRO_DIST)
    --[[
        and FindEntity(
                inst,
                TUNING.MUTANT_BIRD_TARGET_DIST,
                function(guy)
                    local can = inst.components.combat:CanTarget(guy)
                    if guy:HasTag("player") or (guy.components.follower and guy.components.follower:GetLeader() and guy.components.follower:GetLeader():HasTag("player")) then
                        return can
                    end
                end,
                RETARGET_MUST_TAGS,
                INVADER_RETARGET_CANT_TAGS
            )
            ]]

        and FindEntity(
                inst,
                TUNING.MUTANT_BIRD_TARGET_DIST,
                function(guy)
                    local can = inst.components.combat:CanTarget(guy)
                    if guy == inst.components.entitytracker:GetEntity("swarmTarget") then
                        return can
                    end
                    if guy:HasTag("player") or (guy.components.follower and guy.components.follower:GetLeader() and guy.components.follower:GetLeader():HasTag("player")) then
                        return can
                    end
                end,
                RETARGET_MUST_TAGS,
                INVADER_RETARGET_CANT_TAGS
            )

        or nil
end

local function KeepTargetFn(inst, target)
    return IsNearInvadeTarget(inst, TUNING.MUTANT_BIRD_RETURN_DIST)
        and inst.components.combat:CanTarget(target)
end

----------------------------------------------------------

local function OnNewCombatTarget(inst, data)
	if inst.components.inspectable == nil then
		inst:AddComponent("inspectable")
		inst:AddTag("scarytoprey")
	end
end

local function OnNoCombatTarget(inst)
	inst.components.combat:RestartCooldown()
	inst:RemoveComponent("inspectable")
	inst:RemoveTag("scarytoprey")
end

local function OnTrapped(inst, data)
    if data and data.trapper and data.trapper.settrapsymbols then
        data.trapper.settrapsymbols(inst.trappedbuild)
    end
end

local function OnPutInInventory(inst)
    --Otherwise sleeper won't work if we're in a busy state
    inst.sg:GoToState("idle")
end

local function OnDropped(inst)
    inst.sg:GoToState("stunned")
end

local function commonPreMain(inst)

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.entity:AddDynamicShadow()

    inst.sounds =
    {
        flyin = "dontstarve/birds/flyin",
        chirp = "moonstorm/creatures/mutated_crow/chirp",
        takeoff = "moonstorm/creatures/mutated_crow/take_off",
        attack = "moonstorm/creatures/mutated_crow/attack",
    }

    --Initialize physics
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:SetMass(1)
    inst.Physics:SetSphere(1)

	inst:AddTag("bird_mutant")
	inst:AddTag("NOBLOCK")
	inst:AddTag("soulless") -- no wortox souls
	inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("scarytoprey")
    inst:AddTag("canbetrapped")
    inst:AddTag("bird")
    inst:AddTag("lunar_aligned")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("crow_build")
    inst.AnimState:SetBank("crow")
    inst.AnimState:PlayAnimation("idle", true)

    inst.DynamicShadow:SetSize(1, .75)
    inst.DynamicShadow:Enable(false)

	return inst
end


local function commonPostMain(inst)
    inst:AddComponent("occupier")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.SEEDS }, { FOODTYPE.SEEDS })

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(2)
	inst.components.sleeper.sleeptestfn = nil -- they don't sleep at night or day

    inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.MUTANT_BIRD_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.MUTANT_BIRD_WALK_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
    inst.components.locomotor:SetTriggersCreep(true)

	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MUTANT_BIRD_HEALTH)
    inst.components.health.murdersound = "dontstarve/wilson/hit_animal"

    inst:AddComponent("entitytracker")

    inst:AddComponent("timer")

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.MUTANT_BIRD_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.MUTANT_BIRD_ATTACK_COOLDOWN)
	inst.components.combat:SetRange(TUNING.MUTANT_BIRD_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
	inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
	inst:ListenForEvent("droppedtarget", OnNoCombatTarget)
	inst:ListenForEvent("losttarget", OnNoCombatTarget)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    inst:ListenForEvent("ontrapped", OnTrapped)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('bird_mutant')

	inst:AddComponent("knownlocations")
    MakeHauntablePanic(inst)
    MakeFeedableSmallLivestock(inst, TUNING.BIRD_PERISH_TIME, OnPutInInventory, OnDropped)

    inst:SetStateGraph("SGbird_mutant")
    inst:SetBrain(brain)

    return inst
end

local function runnerfn()
	local inst = CreateEntity()

	inst = commonPreMain(inst)

    inst.AnimState:SetBuild("bird_mutant_build")
    inst.AnimState:SetBank("mutated_crow")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.trappedbuild = "bird_mutant_build"

    MakeSmallBurnableCharacter(inst, "mooncrow_body")
    MakeTinyFreezableCharacter(inst, "mooncrow_body")

    inst = commonPostMain(inst)

	return inst
end

local function spitterfn()
	local inst = CreateEntity()
	inst = commonPreMain(inst)
    inst.AnimState:SetBuild("bird_mutant_spitter_build")
    inst.AnimState:SetBank("mutated_robin")

    inst.sounds =
    {
        flyin = "dontstarve/birds/flyin",
        chirp = "moonstorm/creatures/mutated_robin/chirp",
        takeoff = "moonstorm/creatures/mutated_robin/take_off",
        attack = "moonstorm/creatures/mutated_robin/attack",
        spit_pre = "moonstorm/creatures/mutated_robin/bile_shoot_spin_pre",
    }

	inst:AddTag("bird_mutant_spitter")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.trappedbuild = "bird_mutant_spitter_build"

    MakeSmallBurnableCharacter(inst, "robin_body")
    MakeTinyFreezableCharacter(inst, "robin_body")

	inst = commonPostMain(inst)
	inst.LaunchProjectile = LaunchProjectile

	return inst
end

return Prefab("bird_mutant", runnerfn, assets_crow, prefabs),
       Prefab("bird_mutant_spitter", spitterfn, assets_robin, prefabs)
