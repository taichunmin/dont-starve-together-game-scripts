local assets =
{
    Asset("ANIM", "anim/eye_shield.zip"),
    Asset("ANIM", "anim/swap_eye_shield.zip"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("lantern_overlay", skin_build, "swap_shield", inst.GUID, "swap_eye_shield")        
    else
        owner.AnimState:OverrideSymbol("lantern_overlay", "swap_eye_shield", "swap_shield")
    end
    owner.AnimState:HideSymbol("swap_object")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:Show("LANTERN_OVERLAY")

    owner:ListenForEvent("onattackother", inst._weaponused_callback)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner:RemoveEventCallback("onattackother", inst._weaponused_callback)

    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")
    owner.AnimState:ShowSymbol("swap_object")
end

local function oneatfn(inst, food)
    local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
    local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
    inst.components.armor:Repair(health + hunger)

    if not inst.inlimbo then
        inst.AnimState:PlayAnimation("eat")
        inst.AnimState:PushAnimation("idle", true)

        inst.SoundEmitter:PlaySound("terraria1/eye_shield/eat")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("eye_shield")
    inst.AnimState:SetBuild("eye_shield")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("handfed")
    inst:AddTag("fedbyall")
    inst:AddTag("toolpunch")

    -- for eater
    inst:AddTag("eatsrawmeat")
    inst:AddTag("strongstomach")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

    MakeInventoryFloatable(inst, nil, 0.2, {1.1, 0.6, 1.1})

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._weaponused_callback = function(_, data)
        if data.weapon ~= nil and data.weapon == inst then
            inst.components.armor:TakeDamage(TUNING.SHIELDOFTERROR_USEDAMAGE)
        end
    end

    inst:AddComponent("eater")
    inst.components.eater:SetOnEatFn(oneatfn)
    inst.components.eater:SetAbsorptionModifiers(4.0, 1.75, 0)
    inst.components.eater:SetCanEatRawMeat(true)
    inst.components.eater:SetStrongStomach(true)
    inst.components.eater:SetCanEatHorrible(true)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SHIELDOFTERROR_DAMAGE)

    -------

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.SHIELDOFTERROR_ARMOR, TUNING.SHIELDOFTERROR_ABSORPTION)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.SHIELDOFTERROR_SHADOW_LEVEL)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("shieldofterror", fn, assets)