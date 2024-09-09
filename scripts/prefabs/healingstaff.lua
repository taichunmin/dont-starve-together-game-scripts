local assets =
{
    Asset("ANIM", "anim/healingstaff.zip"),
    Asset("ANIM", "anim/swap_healingstaff.zip"),
}

local assets_fx =
{
    Asset("ANIM", "anim/lavaarena_heal_projectile.zip"),
}

local prefabs =
{
    "blossom_projectile",
    "blossom_cast_fx",
    "lavaarena_healblooms",
    "reticuleaoe",
    "reticuleaoeping",
    "reticuleaoefriendlytarget",
}

local PROJECTILE_DELAY = 4 * FRAMES

--------------------------------------------------------------------------

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    --Walk a tiny distance into healing range
    for r = 6, 0, -.25 do
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

    inst.AnimState:SetBank("healingstaff")
    inst.AnimState:SetBuild("healingstaff")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("rangedweapon")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --rechargeable (from rechargeable component) added to pristine state for optimization
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 0, 1, .5, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { 0, .4, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true

    inst.projectiledelay = PROJECTILE_DELAY

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/healingstaff").healingstaff_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function castfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_heal_projectile")
    inst.AnimState:SetBuild("lavaarena_heal_projectile")
    inst.AnimState:SetFinalOffset(3)

    inst:Hide()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/healingstaff").castfx_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

return Prefab("healingstaff", fn, assets, prefabs),
    Prefab("blossom_cast_fx", castfxfn, assets_fx)
