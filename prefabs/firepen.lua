local assets =
{
    Asset("ANIM", "anim/firepen.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "firepen", "swap_firepen")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnAttack(inst, attacker, target)
    attacker.SoundEmitter:PlaySound(inst.skin_sound or "wickerbottom_rework/firepen/impact")

    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    elseif target.components.burnable ~= nil and not target.components.burnable:IsBurning() then    
        if target.components.freezable ~= nil and target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()
        elseif target.components.fueled == nil
            or (target.components.fueled.fueltype ~= FUELTYPE.BURNABLE and
                target.components.fueled.secondaryfueltype ~= FUELTYPE.BURNABLE) then
            --does not take burnable fuel, so just burn it
            if target.components.burnable.canlight or target.components.combat ~= nil then
                target.components.burnable:Ignite(true)
            end
        elseif target.components.fueled.accepting then
            --takes burnable fuel, so fuel it
            local fuel = SpawnPrefab("cutgrass")
            if fuel ~= nil then
                if fuel.components.fuel ~= nil and
                    fuel.components.fuel.fueltype == FUELTYPE.BURNABLE then
                    target.components.fueled:TakeFuelItem(fuel)
                else
                    fuel:Remove()
                end
            end
        end
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(-1) --Does this break ice staff?
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()
        end
    end

    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
end

local function projectilelaunched(inst, attacker, target, proj)
    if attacker:HasTag("controlled_burner") then
        proj:AddTag("controlled_burner")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("firepen")
    inst.AnimState:SetBuild("firepen")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("rangedweapon")
    inst:AddTag("rangedlighter")
    inst:AddTag("firepen")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med", 0.05, { .9, 0.5, .9 })

    inst.scrapbook_specialinfo = "REDSTAFF"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.floater:SetBankSwapOnFloat(true, -3, { sym_build = "firepen", sym_name = "swap_firepen" })

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(TUNING.FIREPEN_MAXUSES)
    inst.components.finiteuses:SetUses(1)
    inst.components.finiteuses:SetDoesNotStartFull(true)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(OnAttack)
    inst.components.weapon:SetProjectile("fire_projectile")
    inst.components.weapon:SetOnProjectileLaunched(projectilelaunched)

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("firepen", fn, assets)
