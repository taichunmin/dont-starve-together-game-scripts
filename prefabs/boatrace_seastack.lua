local boatrace_common = require("prefabs/boatrace_common")

local assets =
{
    Asset("ANIM", "anim/boatrace_seastack.zip"),
    Asset("ANIM", "anim/boatrace_seastack_monkey.zip"),
    Asset("MINIMAP_IMAGE", "boatrace_seastack"),
}

local prefabs =
{
    "rock_break_fx",
    "redpouch_yotd_unwrap",
}

local HIT_SOUND = "terraria1/skins/hammush" -- TODO better sound for this maybe?

--
local function OnWorkFinished(inst)
    local pt = inst:GetPosition()

    inst:SetPhysicsRadiusOverride(nil)

    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot(pt)
    end

    local fx = SpawnPrefab("balloon_pop_body")
    fx.Transform:SetPosition(pt:Get())

    inst:Remove()
end

local function OnWork(inst, worker, workleft)
    inst.SoundEmitter:PlaySound(HIT_SOUND)

    if workleft <= 0 then
        OnWorkFinished(inst)
    end
end

local function ShouldKeepTarget(_) return false end

local function OnHitByAttack(inst, attacker, damage, specialdamage)
    if inst.components.workable then
        local work_done = math.max(1, math.floor(damage / TUNING.BOATRACE_SEASTACK_DAMAGE_TO_WORK))
        inst.components.workable:WorkedBy(attacker, work_done)
    end
end

local function OnCollide(inst, data)
    inst.SoundEmitter:PlaySound(HIT_SOUND)
end

local function OnBuilt(inst, _)
    inst.AnimState:PlayAnimation("1_emerge")
    inst.AnimState:PushAnimation("1_idle", true)
    inst.SoundEmitter:PlaySound("yotc_2020/gym/start/place")
end

local function OnPhysicsWake(inst)
    inst.components.boatphysics:StartUpdating()
end

local function OnPhysicsSleep(inst)
    inst.components.boatphysics:StopUpdating()
end

local function CLIENT_ResolveFloater(inst)
    inst.components.floater:OnLandedServer()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("boatrace_seastack.png")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(TUNING.BOAT.MASS)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:SetCylinder(0.70, 2)

    local waterphysics = inst:AddComponent("waterphysics")
    waterphysics.restitution = 1.0 + TUNING.BOATRACE_SEASTACK_EXTRA_RESTITUTION

    inst:AddTag("blocker")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("noauradamage")
    inst:AddTag("seastack")

    inst.AnimState:SetBank("boatrace_seastack")
    inst.AnimState:SetBuild("boatrace_seastack")
    inst.AnimState:PlayAnimation("1_idle", true)

    local floater = MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    floater.bob_percent = 0
    local float_delay_framecount = 1 + (POPULATING and 4*math.random() or 0)
    inst:DoTaskInTime(float_delay_framecount*FRAMES, CLIENT_ResolveFloater)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst:AddComponent("boatphysics")

    --
    local combat = inst:AddComponent("combat")
    combat:SetKeepTargetFunction(ShouldKeepTarget)
    combat:SetOnHit(OnHitByAttack)

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(1)
    health:SetAbsorptionAmount(1)
    health.fire_damage_scale = 0
    health.canheal = false
    health.nofadeout = true

    --
    inst:AddComponent("inspectable")

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetLoot({"boatrace_seastack_throwable_deploykit"})
    lootdropper.max_speed = 2
    lootdropper.min_speed = 0.3
    lootdropper.y_speed = 14
    lootdropper.y_speed_variance = 4
    lootdropper.spawn_loot_inside_prefab = true

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnWorkCallback(OnWork)
    workable.savestate = true

    --
    MakeHauntableWork(inst)

    --
    inst:ListenForEvent("on_collide", OnCollide)
    inst:ListenForEvent("onbuilt", OnBuilt)

    --
    inst.OnPhysicsWake = OnPhysicsWake
    inst.OnPhysicsSleep = OnPhysicsSleep

    return inst
end

local function monkeyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("boatrace_seastack.png")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(TUNING.BOAT.MASS)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:SetCylinder(0.70, 2)

    local waterphysics = inst:AddComponent("waterphysics")
    waterphysics.restitution = 1.0 + TUNING.BOATRACE_SEASTACK_EXTRA_RESTITUTION

    inst:AddTag("blocker")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("noauradamage")
    inst:AddTag("seastack")

    inst.AnimState:SetBank("boatrace_seastack")
    inst.AnimState:SetBuild("boatrace_seastack_monkey")
    inst.AnimState:PlayAnimation("1_idle", true)

    local floater = MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    floater.bob_percent = 0
    local float_delay_framecount = 1 + (POPULATING and 4*math.random() or 0)
    inst:DoTaskInTime(float_delay_framecount*FRAMES, CLIENT_ResolveFloater)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst:AddComponent("boatphysics")

    --
    local combat = inst:AddComponent("combat")
    combat:SetKeepTargetFunction(ShouldKeepTarget)
    combat:SetOnHit(OnHitByAttack)

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(1)
    health:SetAbsorptionAmount(1)
    health.fire_damage_scale = 0
    health.canheal = false
    health.nofadeout = true

    --
    inst:AddComponent("inspectable")

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnWorkCallback(OnWork)
    workable.savestate = true

    --
    MakeHauntableWork(inst)

    --
    inst:ListenForEvent("on_collide", OnCollide)
    inst:ListenForEvent("onbuilt", OnBuilt)

    --
    inst.OnPhysicsWake = OnPhysicsWake
    inst.OnPhysicsSleep = OnPhysicsSleep

    --
    inst.persists = false

    return inst
end

--
local function player_kit_validityfn(inst, doer, pos)
	return TheWorld.Map:IsOceanAtPoint(pos.x, pos.y, pos.z, false)
end

local THROWABLE_KIT_DATA = {
    bank = "boatrace_seastack",
    build = "boatrace_seastack",
    anim = "kit_ground",
    prefab_to_deploy = "boatrace_seastack",

    extradeploytest = player_kit_validityfn,
}
local ThrowableKit, ThrowableKitPlacer = boatrace_common.MakeThrowableBoatRaceKitPrefabs(THROWABLE_KIT_DATA)

local MONKEY_KIT_DATA = {
    bank = "boatrace_seastack",
    build = "boatrace_seastack_monkey",
    anim = "kit_ground",
    tags = {"nosteal"},
    prefab_to_deploy = "boatrace_seastack_monkey",
    product_fn = function(product, inst)
        product._spawner = inst._spawner
        product.DoDisappear = function()
            local px, py, pz = product.Transform:GetWorldPosition()
            product:Remove()
            SpawnPrefab("redpouch_yotd_unwrap").Transform:SetPosition(px, py, pz)
        end
        if product._spawner then
            -- If our spawner IS still around when we land, set up an onremove listener to disappear when they do.
            product:ListenForEvent("onremove", product.DoDisappear, product._spawner)
        else
            -- If our spawner went away while we were in the air, just do our disappear now.
            product.DoDisappear()
        end
    end,
    deployfailed_fn = function(kit, inst)
        local kx, ky, kz = kit.Transform:GetWorldPosition()
        kit:Remove()
        SpawnPrefab("redpouch_yotd_unwrap").Transform:SetPosition(kx, ky, kz)
    end,
}
local MonkeyThrowableKit, MonkeyThrowableKitPlacer = boatrace_common.MakeThrowableBoatRaceKitPrefabs(MONKEY_KIT_DATA)

return Prefab("boatrace_seastack", fn, assets, prefabs),
    ThrowableKit,
    ThrowableKitPlacer,

    Prefab("boatrace_seastack_monkey", monkeyfn, assets, prefabs),
    MonkeyThrowableKit,
    MonkeyThrowableKitPlacer