local assets =
{
    Asset("ANIM", "anim/blow_dart.zip"),
    Asset("ANIM", "anim/swap_blowdart.zip"),
    Asset("ANIM", "anim/swap_blowdart_pipe.zip"),
}

local prefabs =
{
    "impact",
}

local prefabs_yellow =
{
    "impact",
    "electrichitsparks",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart", "swap_blowdart")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil and target.components.combat then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil and attacker:IsValid() then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
    end
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.components.inventoryitem.pushlandedevents = false
end

local function common(anim, tags, removephysicscolliders)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

    inst:AddTag("blowdart")
    inst:AddTag("sharp")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if removephysicscolliders then
        RemovePhysicsColliders(inst)
    end

    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.5, 0.75})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    -------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    MakeHauntableLaunch(inst)

    return inst
end

-------------------------------------------------------------------------------
-- Sleep Dart
-------------------------------------------------------------------------------
local function sleepthrown(inst)
    inst.AnimState:PlayAnimation("dart_purple")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function sleepattack(inst, attacker, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

	if target.SoundEmitter ~= nil then
	    target.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_impact_sleep")
	end

    if target.components.sleeper ~= nil then
        target.components.sleeper:AddSleepiness(1, 15, inst)
    elseif target.components.grogginess ~= nil then
        target.components.grogginess:AddGrogginess(1, 15)
    end

    if target.components.combat ~= nil and not target:HasTag("player") then
        target.components.combat:SuggestTarget(attacker)
    end
    target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
end

local function sleep()
    local inst = common("idle_purple", { "tranquilizer" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.weapon:SetOnAttack(sleepattack)
    inst.components.projectile:SetOnThrownFn(sleepthrown)

    local swap_data = {sym_build = "swap_blowdart", bank = "blow_dart", anim = "idle_purple"}
    inst.components.floater:SetBankSwapOnFloat(true, -4, swap_data)

    return inst
end

-------------------------------------------------------------------------------
-- Fire Dart
-------------------------------------------------------------------------------
local function firethrown(inst)
    inst.AnimState:PlayAnimation("dart_red")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function fireattack(inst, attacker, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

	if target.SoundEmitter ~= nil then
	    target.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_impact_fire")
	end

    target:PushEvent("attacked", {attacker = attacker, damage = 0})
    -- NOTES(JBK): Valid check in case the event removed the target.
    if target:IsValid() then
        if target.components.burnable then
            target.components.burnable:Ignite(nil, attacker)
        end
        if target.components.freezable then
            target.components.freezable:Unfreeze()
        end
        if target.components.health then
            target.components.health:DoFireDamage(0, attacker)
        end
        if target.components.combat then
            target.components.combat:SuggestTarget(attacker)
        end
    end
end

local function fire()
    local inst = common("idle_red", { "firedart" })

    inst.scrapbook_specialinfo = "REDSTAFF"

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.weapon:SetOnAttack(fireattack)
    inst.components.projectile:SetOnThrownFn(firethrown)

    local swap_data = {sym_build = "swap_blowdart", bank = "blow_dart", anim = "idle_red"}
    inst.components.floater:SetBankSwapOnFloat(true, -4, swap_data)

    return inst
end

-------------------------------------------------------------------------------
-- Pipe Dart (Damage)
-------------------------------------------------------------------------------
local function pipeequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart_pipe", "swap_blowdart_pipe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function pipethrown(inst)
    inst.AnimState:PlayAnimation("dart_pipe")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function pipe()
    local inst = common("idle_pipe")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(pipeequip)
    inst.components.weapon:SetDamage(TUNING.PIPE_DART_DAMAGE)
    inst.components.projectile:SetOnThrownFn(pipethrown)

    local swap_data = {sym_build = "swap_blowdart_pipe", bank = "blow_dart", anim = "idle_pipe"}
    inst.components.floater:SetBankSwapOnFloat(true, -4, swap_data)

    return inst
end

-------------------------------------------------------------------------------
-- Yellow Dart (Electric Damage)
-------------------------------------------------------------------------------

local function yellowthrown(inst)
    inst.AnimState:PlayAnimation("dart_yellow")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function yellowattack(inst, attacker, target)
    --target could be killed or removed in combat damage phase
    if target:IsValid() then
        SpawnPrefab("electrichitsparks"):AlignToTarget(target, inst)
    end
end

local function yellow()
    local inst = common("idle_yellow")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.weapon:SetOnAttack(yellowattack)
    inst.components.weapon:SetDamage(TUNING.YELLOW_DART_DAMAGE)
    inst.components.weapon:SetElectric()
    inst.components.projectile:SetOnThrownFn(yellowthrown)

    local swap_data = {sym_build = "swap_blowdart", bank = "blow_dart", anim = "idle_yellow"}
    inst.components.floater:SetBankSwapOnFloat(true, -4, swap_data)

    return inst
end


-------------------------------------------------------------------------------
-- Walrus blowdart - use by walrus creature, not player
-------------------------------------------------------------------------------
local function walrus()
    local inst = common("idle_pipe", { "NOCLICK" }, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.components.projectile:SetOnThrownFn(pipethrown)
    inst.components.projectile:SetRange(TUNING.WALRUS_DART_RANGE)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    --Increase hitdist (default=1) to account for launch offset height
    --math.sqrt(1 * 1 + 2 * 2)
    inst.components.projectile:SetHitDist(math.sqrt(5))

    local swap_data = {sym_build = "swap_blowdart_pipe", bank = "blow_dart", anim = "idle_pipe"}
    inst.components.floater:SetBankSwapOnFloat(true, -4, swap_data)

    return inst
end

-------------------------------------------------------------------------------
return Prefab("blowdart_sleep", sleep, assets, prefabs),
       Prefab("blowdart_fire", fire, assets, prefabs),
       Prefab("blowdart_pipe", pipe, assets, prefabs),
       Prefab("blowdart_yellow", yellow, assets, prefabs_yellow),
       Prefab("blowdart_walrus", walrus, assets, prefabs)
