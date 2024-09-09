local brain = require "brains/crabkingclawbrain"

local assets =
{
    Asset("ANIM", "anim/crab_king_claw.zip"),
    Asset("ANIM", "anim/crab_king_claw_actions.zip"),
    Asset("ANIM", "anim/crab_king_claw_build.zip"),
}

local prefabs =
{
    "crabking_claw_shadow",
	"crabking_claw_swipe_fx",
}

local shadow_assets =
{
    Asset("ANIM", "anim/crab_king_claw.zip"),
    Asset("ANIM", "anim/crab_king_claw_shadow_build.zip"),
}

local swipe_assets =
{
	Asset("ANIM", "anim/crabking_claw_swipe_fx.zip"),
}

local function teleport_override_fn(inst)
    local pt = inst.components.knownlocations ~= nil and inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()
    local offset = FindSwimmableOffset(pt, math.random() * TWOPI, 3, 8, true, false) or
					FindSwimmableOffset(pt, math.random() * TWOPI, 8, 8, true, false)
    if offset ~= nil then
		pt = pt + offset
    end

	return pt
end

local function OnRemove(inst)
    if inst.shadow then
        inst.shadow:Remove()
    end
end

local function OnDead(inst)
    if inst.shadow then
        inst.shadow:Remove()
    end
end

local MAX_CHASEAWAY_DIST_SQ = 30*30
local function KeepTarget(inst, target)
    local pos = Vector3(target.Transform:GetWorldPosition())
    local keep = inst.components.combat:CanTarget(target) --and  TheWorld.Map:IsOceanAtPoint(pos.x, 0, pos.z, true)
            and target:GetDistanceSqToPoint(inst.Transform:GetWorldPosition()) < MAX_CHASEAWAY_DIST_SQ
    return keep
end

local TARGET_DIST = TUNING.CRABKING_ATTACK_TARGETRANGE
local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "playerghost", "crabking_ally"}
local RETARGET_ONEOF_TAGS = { "character", "monster"}
local function Retarget(inst)
    local gx, gy, gz = inst.Transform:GetWorldPosition()
    local potential_targets = TheSim:FindEntities(
        gx, gy, gz, TARGET_DIST,
        RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS
    )

    local newtarget = nil
    for _, target in ipairs(potential_targets)do
        local pos =  Vector3(target.Transform:GetWorldPosition())
        if target ~= inst and target.entity:IsVisible()
                and inst.components.combat:CanTarget(target)
                and TheWorld.Map:IsOceanAtPoint(pos.x, 0, pos.z, true) then
            newtarget = target
            break
        end
    end

    if newtarget ~= nil and newtarget ~= inst.components.combat.target then
        return newtarget, true
    else
        return nil
    end
end

local function OnSave(inst, data)
    local ents = {}

    if inst.crabking then
        data.crabking = inst.crabking.GUID
        table.insert(ents, inst.crabking.GUID)
    end

    return ents
end

local function OnLoadPostPass(inst, newents, data)
    if data.crabking then
        inst.crabking =  newents[data.crabking].entity
    end
end

SetSharedLootTable( 'crabking_claw',
{
    {'meat',                                1.00},
})

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, 0.7)
    inst.Transform:SetSixFaced()

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("hostile")
    inst:AddTag("crabking_claw")
    inst:AddTag("crabking_ally")
	inst:AddTag("soulless")
    inst:AddTag("lunar_aligned")

    local s  = 0.7
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBank("crab_claw")
    inst.AnimState:SetBuild("crab_king_claw_build")

    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
	end

	inst:AddComponent("boatdrag")
	inst.components.boatdrag.drag = TUNING.CRABKING_ANCHOR_DRAG
	inst.components.boatdrag.forcedampening = 1
	inst.components.boatdrag.max_velocity_mod = TUNING.CRABKING_MAX_VELOCITY_MOD
    inst.components.boatdrag.sailforcemodifier = 0

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.CRABKING_CLAW_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.CRABKING_CLAW_RUN_SPEED

    ------------------------------------------

    inst:SetStateGraph("SGcrabkingclaw")

    ------------------

    inst:AddComponent("health")
    inst.components.health.save_maxhealth = true
    inst.components.health:SetMaxHealth(TUNING.CRABKING_CLAW_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.CRABKING_CLAW_PLAYER_DAMAGE)
    inst.components.combat.hiteffectsymbol = "claw_parts_shoulder"
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRange(TUNING.CRABKING_CLAW_ATTACKRANGE)    

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('crabking_claw')

    ------------------------------------------

    inst:AddComponent("inspectable")

    ------------------------------------------

    inst:AddComponent("timer")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:AddComponent("entitytracker")

    ------------------------------------------

    inst:SetBrain(brain)

    inst.OnSave = OnSave
    inst.OnLoadPostPass = OnLoadPostPass

    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("entitywake", OnEntityWake)

    MakeLargeBurnableCharacter(inst, "claw_parts_forearm")
    MakeHugeFreezableCharacter(inst, "claw_parts_forearm")

	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    inst.shadow = inst:SpawnChild("crabking_claw_shadow")

    return inst
end

local function shadowfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("notarget")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.persists = false

    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)

    --local s  = 0.7
    --sinst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBank("crab_claw")
    inst.AnimState:SetBuild("crab_king_claw_shadow_build")

    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function swipefn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	--inst.Transform:SetEightFaced()

	inst.AnimState:SetBank("crabking_claw_swipe_fx")
	inst.AnimState:SetBuild("crabking_claw_swipe_fx")
	inst.AnimState:PlayAnimation("atk1")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	local s  = 1 / 0.7
	inst.AnimState:SetScale(s, s)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("crabking_claw",        fn, assets, prefabs),
       Prefab("crabking_claw_shadow", shadowfn, shadow_assets),
       Prefab("crabking_claw_swipe_fx", swipefn, swipe_assets)
