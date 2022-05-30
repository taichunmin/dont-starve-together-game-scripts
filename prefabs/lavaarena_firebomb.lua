local assets =
{
    Asset("ANIM", "anim/lavaarena_firebomb.zip"),
    Asset("ANIM", "anim/swap_lavaarena_firebomb.zip"),
}

local assets_fx =
{
    Asset("ANIM", "anim/lavaarena_firebomb.zip"),
}

local assets_sparks =
{
    Asset("ANIM", "anim/sparks_molotov.zip"),
}

local prefabs =
{
    "lavaarena_firebomb_projectile",
    "lavaarena_firebomb_proc_fx",
    "lavaarena_firebomb_sparks",
    "reticuleaoesmall",
    "reticuleaoesmallping",
    "reticuleaoesmallhostiletarget",
}

local prefabs_projectile =
{
    "lavaarena_firebomb_explosion",
    "firehit",
}

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --2 is the aoe range
    for r = 5, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lavaarena_firebomb")
    inst.AnimState:SetBuild("lavaarena_firebomb")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("throw_line")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --rechargeable (from rechargeable component) added to pristine state for optimization
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoesmall"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoesmallping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_firebomb").firebomb_postinit(inst)

    return inst
end

local function CreateProjectileAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("lavaarena_firebomb")
    inst.AnimState:SetBuild("lavaarena_firebomb")
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    return inst
end

local function OnDirectionDirty(inst)
    inst.animent.Transform:SetRotation(inst.direction:value())
end

local function projectilefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(.2, .2)

    inst:AddTag("NOCLICK")

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.direction = net_float(inst.GUID, "lavaarena_firebomb_projectile.direction", "directiondirty")

    --Dedicated server does not need to spawn the local animation
    if not TheNet:IsDedicated() then
        inst.animent = CreateProjectileAnim()
        inst.animent.entity:SetParent(inst.entity)

        if not TheWorld.ismastersim then
            inst:ListenForEvent("directiondirty", OnDirectionDirty)
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_firebomb").projectile_postinit(inst)

    return inst
end

local function explosionfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_firebomb")
    inst.AnimState:SetBuild("lavaarena_firebomb")
    inst.AnimState:PlayAnimation("used")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_firebomb").explosion_postinit(inst)

    return inst
end

local function procfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_firebomb")
    inst.AnimState:SetBuild("lavaarena_firebomb")
    inst.AnimState:PlayAnimation("hitfx")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_firebomb").procfx_postinit(inst)

    return inst
end

local function SetSparkLevel(inst, level)
    inst.AnimState:PlayAnimation(tostring(math.clamp(level, 1, 3)), true)
end

local function sparksfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sparks_molotov")
    inst.AnimState:SetBuild("sparks_molotov")
    inst.AnimState:PlayAnimation("1", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.SetSparkLevel = SetSparkLevel

    return inst
end

return Prefab("lavaarena_firebomb", fn, assets, prefabs),
    Prefab("lavaarena_firebomb_projectile", projectilefn, assets_fx, prefabs_projectile),
    Prefab("lavaarena_firebomb_explosion", explosionfn, assets_fx),
    Prefab("lavaarena_firebomb_proc_fx", procfxfn, assets_fx),
    Prefab("lavaarena_firebomb_sparks", sparksfn, assets_sparks)
