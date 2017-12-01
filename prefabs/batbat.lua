local assets =
{
	Asset("ANIM", "anim/batbat.zip"),
	Asset("ANIM", "anim/swap_batbat.zip"),    
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_batbat", "swap_batbat")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onattack(inst, owner, target)
    if owner.components.health and owner.components.health:GetPercent() < 1 and not target:HasTag("wall") then
        owner.components.health:DoDelta(TUNING.BATBAT_DRAIN,false,"batbat")
        owner.components.sanity:DoDelta(-TUNING.BATBAT_DRAIN * 0.5)
    end
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.AnimState:SetBank("batbat")
    inst.AnimState:SetBuild("batbat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("dull")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE)
    inst.components.weapon.onattack = onattack

    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BATBAT_USES)
    inst.components.finiteuses:SetUses(TUNING.BATBAT_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("batbat", fn, assets)