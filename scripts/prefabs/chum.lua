local assets =
{
    Asset("ANIM", "anim/swap_chum_pouch.zip"),
    Asset("ANIM", "anim/chum_pouch.zip"),
}

local prefabs =
{
    "chum_aoe",
    "reticule",
    "reticuleaoe",
    "reticuleaoeping",

    "splash_green",
}

local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

local function OnHit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()

    if not TheWorld.Map:IsOceanAtPoint(x, y, z) then
        SpawnPrefab("chum").Transform:SetPosition(x, y, z)
    else
        SpawnPrefab("splash_green").Transform:SetPosition(x, y, z)
        SpawnPrefab("chum_aoe").Transform:SetPosition(x, y, z)
    end

    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_chum_pouch", "swap_chum_pouch")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
    inst.Physics:SetCapsule(.2, .2)
end

local function ReticuleTargetFn()
    local pos = Vector3()
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = ThePlayer.entity:LocalToWorldSpace(r, 0, 0)
        if TheWorld.Map:IsOceanAtPoint(pos.x, pos.y, pos.z, false) then
            return pos
        end
    end
    return pos
end

local function OnAddProjectile(inst)
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHit)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("chum_pouch")
    inst.AnimState:SetBuild("chum_pouch")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetDeltaTimeMultiplier(.75)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst:AddTag("allow_action_on_impassable")

    MakeInventoryFloatable(inst, "small", 0.1, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("oceanthrowable")
    inst.components.oceanthrowable:SetOnAddProjectileFn(OnAddProjectile)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.UNARMED_DAMAGE)

    inst:AddComponent("forcecompostable")
    inst.components.forcecompostable.green = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("chum", fn, assets, prefabs)
