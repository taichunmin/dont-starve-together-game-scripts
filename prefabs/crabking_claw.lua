local brain = require "brains/crabkingclawbrain"

local assets =
{
    Asset("ANIM", "anim/crab_king_claw.zip"),
    Asset("ANIM", "anim/crab_king_claw_build.zip"),
}

local prefabs =
{
    "crabking_claw_shadow",
}

local shadow_assets =
{
    Asset("ANIM", "anim/crab_king_claw.zip"),
    Asset("ANIM", "anim/crab_king_claw_shadow_build.zip"),
}

local shadow_prefabs =
{

}

local function releaseclamp(inst, immediate)
	if inst.boat then
		if inst.boat.components.boatphysics ~= nil then
			inst.boat.components.boatphysics:RemoveBoatDrag(inst)
		end

        if inst._releaseclamp then
            inst:RemoveEventCallback("onremove", inst._releaseclamp, inst.boat)
            inst._releaseclamp = nil
        end
    end
    inst.boat = nil
    inst:PushEvent("releaseclamp", {immediate = immediate} )

    if inst.clamptask then
        inst.clamptask:Cancel()
        inst.clamptask = nil
    end
end

local function crunchboat(inst,boat)
    inst:PushEvent("clamp_attack",boat)
    if inst.clamptask then
        inst.clamptask:Cancel()
        inst.clamptask = nil
    end
    inst.clamptask = inst:DoTaskInTime(math.random()+3,function() inst.crunchboat(inst,inst.boat) end)
end

local CLAMPDAMAGE_CANT_TAGS = {"flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO"}
local function clamp(inst)
    if inst.boat and not inst.boat.components.health:IsDead() then
        inst.boat.components.health:DoDelta(-TUNING.CRABKING_CLAW_BOATDAMAGE)
        ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.5, inst.boat, inst.boat:GetPhysicsRadius(4))
        local pos = Vector3(inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 3, nil, CLAMPDAMAGE_CANT_TAGS)

        for i, v in pairs(ents)do
            if v ~= inst and v:IsValid() and not v:IsInLimbo() then
                if      v.components.workable ~= nil and
                        v.components.workable:CanBeWorked() and
                        v.components.workable.action ~= ACTIONS.NET then
                    v.components.workable:Destroy(inst)
                end
                if      v.components.health ~= nil and
                        not v.components.health:IsDead() and
                        inst.components.combat:CanTarget(v) then
                    inst.components.combat:DoAttack(v)
                end
            end
        end

		ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.5, inst.boat, inst.boat:GetPhysicsRadius(4))

		if inst.boat.components.boatphysics ~= nil then
			inst.boat.components.boatphysics:AddBoatDrag(inst)
        end
        inst._releaseclamp = function() inst:releaseclamp() end
        inst:ListenForEvent("onremove", inst._releaseclamp, inst.boat)
        inst.clamptask = inst:DoTaskInTime(math.random()+3,function() inst.crunchboat(inst,inst.boat) end)
    end
end

local function teleport_override_fn(inst)
    local pt = inst.components.knownlocations ~= nil and inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()
    local offset = FindSwimmableOffset(pt, math.random() * 2 * PI, 3, 8, true, false) or
					FindSwimmableOffset(pt, math.random() * 2 * PI, 8, 8, true, false)
    if offset ~= nil then
		pt = pt + offset
    end

	return pt
end

local function OnTeleported(inst)
	inst:releaseclamp(true)
end

local function OnRemove(inst)
    if inst.shadow then
        inst.shadow:Remove()
    end
    inst.releaseclamp(inst)
end

local function OnDead(inst)
    if inst.shadow then
        inst.shadow:Remove()
    end
    inst.releaseclamp(inst)
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

    MakeCharacterPhysics(inst, 1000, 0.1)
    inst.Transform:SetSixFaced()

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("hostile")
    inst:AddTag("crabking_claw")
	inst:AddTag("soulless")

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
    inst.components.health:SetMaxHealth(TUNING.CRABKING_CLAW_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.CRABKING_CLAW_PLAYER_DAMAGE)
    inst.components.combat:SetRange(0)
    inst.components.combat.hiteffectsymbol = "claw_parts_shoulder"
    inst.components.combat:SetAttackPeriod(0)

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

    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("entitywake", OnEntityWake)

    inst.releaseclamp = releaseclamp
    inst.clamp = clamp
    inst.crunchboat = crunchboat

    MakeLargeBurnableCharacter(inst, "claw_parts_forearm")
    MakeHugeFreezableCharacter(inst, "claw_parts_forearm")

	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)
	inst:ListenForEvent("teleported", OnTeleported)

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

return Prefab("crabking_claw",        fn, assets, prefabs),
       Prefab("crabking_claw_shadow", shadowfn, shadow_assets, shadow_prefabs)

