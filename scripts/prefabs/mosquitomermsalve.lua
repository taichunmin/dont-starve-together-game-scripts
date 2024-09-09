local assets =
{
    Asset("ANIM", "anim/mosquitomermsalve.zip"),
}

local prefabs =
{
    "merm_healthregenbuff",
}

----------------------------------------------------------------------------------------------------------------------------------------------

local function CanHeal(inst, target, doer)
    if not (target:HasTag("merm") and not target:HasTag("mermdisguise")) then
        return false, "NOT_MERM"
    end

    return true -- Merms and Wurt!
end

local function OnHeal(inst, target, doer)
    if target.components.health == nil then
        return
    end

    local delta = target:HasTag("player") and (TUNING.HEALING_MEDSMALL * 2) or TUNING.HEALING_SUPERHUGE 

    -- NOTES(JBK): Tag healerbuffs can make this heal function be invoked but we do not want to apply health to things that can not be healed.
    if target.components.health.canheal then
        target.components.health:DoDelta(delta, false, inst.prefab)
    end

    if doer ~= nil and
        doer.components.skilltreeupdater ~= nil and
        doer.components.skilltreeupdater:IsActivated("wurt_mosquito_craft_3")
    then
        target:AddDebuff("merm_healthregenbuff", "merm_healthregenbuff")
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mosquitomermsalve")
    inst.AnimState:SetBuild("mosquitomermsalve")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(0)
    inst.components.healer:SetOnHealFn(OnHeal)
    inst.components.healer:SetCanHealFn(CanHeal)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mosquitomermsalve", fn, assets, prefabs)
