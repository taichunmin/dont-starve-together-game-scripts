local assets =
{
    Asset("ANIM", "anim/hammer_mjolnir.zip"),
    Asset("ANIM", "anim/swap_hammer_mjolnir.zip"),
}

local assets_crackle =
{
    Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),
}

local prefabs =
{
    "hammer_mjolnir_crackle",
    "hammer_mjolnir_cracklehit",
    "reticuleaoe",
    "reticuleaoeping",
    "reticuleaoehostiletarget",
    "weaponsparks",
    "sunderarmordebuff",
}

local prefabs_crackle =
{
    "hammer_mjolnir_cracklebase",
}

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
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
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hammer_mjolnir")
    inst.AnimState:SetBuild("hammer_mjolnir")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --aoeweapon_leap (from aoeweapon_leap component) added to pristine state for optimization
    inst:AddTag("aoeweapon_leap")

    --rechargeable (from rechargeable component) added to pristine state for optimization
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/hammer_mjolnir").hammer_postinit(inst)

    return inst
end

local function cracklefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_hit")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/hammer_mjolnir").crackle_postinit(inst)

    return inst
end

local function cracklebasefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_projection")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.5, 1.5)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function MakeCrackleHit(name, withsound)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        if withsound then
            inst.entity:AddSoundEmitter()
        end
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
        inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
        inst.AnimState:PlayAnimation("crackle_loop")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)
        inst.AnimState:SetScale(1.5, 1.5)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/hammer_mjolnir").cracklehit_postinit(inst)

        return inst
    end

    return Prefab(name, fn, assets_crackle)
end

return Prefab("hammer_mjolnir", fn, assets, prefabs),
    Prefab("hammer_mjolnir_crackle", cracklefn, assets_crackle, prefabs_crackle),
    Prefab("hammer_mjolnir_cracklebase", cracklebasefn, assets_crackle),
    MakeCrackleHit("hammer_mjolnir_cracklehit", false),
    MakeCrackleHit("cracklehitfx", true)
