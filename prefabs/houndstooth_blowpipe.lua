local assets =
{
    Asset("ANIM", "anim/blow_dart.zip"),
    Asset("ANIM", "anim/swap_houndstooth_blowpipe.zip"),
}

local weapon_prefabs =
{
    "houndstooth",
    "houndstooth_proj",
}

local projectile_prefabs =
{
    "hitsparks_piercing_fx",
}

----------------------------------------------------------------------------------------------------------------------------

local WEIGHTED_TAIL_FXS =
{
    ["tail_5_8"] = 1,
    ["tail_5_9"] = .5,
}

local LAUNCH_OFFSET_Y = 0.75

----------------------------------------------------------------------------------------------------------------------------

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_houndstooth_blowpipe", inst.GUID, "swap_blowdart_pipe")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_houndstooth_blowpipe", "swap_blowdart_pipe")
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function OnUnequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function OnEquipToModel(inst, owner)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

----------------------------------------------------------------------------------------------------------------------------

local function OnProjectileLaunched(inst, attacker, target)
    if inst.components.container ~= nil then
        local ammo_stack = inst.components.container:GetItemInSlot(1)
        local item = inst.components.container:RemoveItem(ammo_stack, false)

        if item ~= nil then
            item:Remove()
        end
    end
end

local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil and data ~= nil and data.item ~= nil then
        inst.components.weapon:SetProjectile("houndstooth_proj")
        inst.components.weapon:SetRange(TUNING.HOUNDSTOOTH_BLOWPIPE_ATTACK_DIST, TUNING.HOUNDSTOOTH_BLOWPIPE_ATTACK_DIST_MAX)
        inst:AddTag("blowpipe") -- For SG state.
        inst:AddTag("rangedweapon")
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then
        inst.components.weapon:SetProjectile(nil)
        inst.components.weapon:SetRange(nil)
        inst:RemoveTag("blowpipe") -- For SG state.
        inst:RemoveTag("rangedweapon")
    end
end

----------------------------------------------------------------------------------------------------------------------------

local function Projectile_CreateTailFx(inst)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation(weighted_random_choice(WEIGHTED_TAIL_FXS))
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    inst.AnimState:SetLightOverride(0.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetAddColour(1, 1, 1, 0)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function Projectile_UpdateTail(inst)
    local c = (not inst.entity:IsVisible() and 0) or 1
    local target = inst._target:value()

    -- Does not spawn the tail if it is close to the target (visual bug).
    if c > 0 and not (target ~= nil and target:IsValid() and inst:IsNear(target, 1.5)) then
        local tail = inst:CreateTailFx()
        tail.Transform:SetPosition(inst.Transform:GetWorldPosition())
        tail.Transform:SetRotation(inst.Transform:GetRotation())
        if c < 1 then
            tail.AnimState:SetTime(c * tail.AnimState:GetCurrentAnimationLength())
        end

        return tail -- Mods.
    end
end

local function Projectile_OnThrown(inst, owner, target, attacker)
    inst._target:set(target)
end

local function Projectile_SpawnImpactFx(inst, attacker, target)
    if target ~= nil and attacker ~= nil and target:IsValid() and attacker:IsValid() then
        local impactfx = SpawnPrefab("hitsparks_piercing_fx")
        impactfx:Setup(attacker, target, inst, nil, true, LAUNCH_OFFSET_Y)

        return impactfx -- Mods.
    end
end

-- NOTE(DiogoW): Using OnPreHit to be able to check health:IsDead().
local function Projectile_OnPreHit(inst, attacker, target)
    if  target ~= nil      and
        target:IsValid()   and
        attacker ~= nil    and
        attacker:IsValid() and
        (target.components.health == nil or not target.components.health:IsDead())
    then
        inst:SpawnImpactFx(attacker, target)
    end
end

----------------------------------------------------------------------------------------------------------------------------

local floater_swap_data =
{
    sym_build = "swap_houndstooth_blowpipe",
    sym_name  = "swap_blowdart_pipe",
    bank = "blow_dart",
    anim = "idle_houndstooth"
}

local function WeaponFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation("idle_houndstooth")

    --weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.5, 0.75}, true, -4, floater_swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle_houndstooth"
    inst.scrapbook_weaponrange  = TUNING.HOUNDSTOOTH_BLOWPIPE_ATTACK_DIST_MAX
    inst.scrapbook_weapondamage = TUNING.HOUNDSTOOTH_BLOWPIPE_DAMAGE
    inst.scrapbook_planardamage = TUNING.HOUNDSTOOTH_BLOWPIPE_PLANAR_DAMAGE

    inst.OnAmmoLoaded   = OnAmmoLoaded   -- Mods.
    inst.OnAmmoUnloaded = OnAmmoUnloaded -- Mods.

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.UNARMED_DAMAGE)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("houndstooth_blowpipe")

    inst:ListenForEvent("itemget",  inst.OnAmmoLoaded  )
    inst:ListenForEvent("itemlose", inst.OnAmmoUnloaded)

    MakeHauntableLaunch(inst)

    return inst
end

local function ProjectileFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.Light:SetFalloff(0.6)
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(0.4)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation("dart_houndstooth", true)

    inst.AnimState:SetLightOverride(0.2)

    inst.AnimState:SetSymbolBloom("flametail")
    inst.AnimState:SetSymbolLightOverride("flametail", 0.5)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    --weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")

    --projectile (from projectile component) added to pristine state for optimization.
    inst:AddTag("projectile")

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    if not TheNet:IsDedicated() then
        inst.CreateTailFx  = Projectile_CreateTailFx
        inst.UpdateTail    = Projectile_UpdateTail

        inst:DoPeriodicTask(0, inst.UpdateTail)
    end

    inst._target = net_entity(inst.GUID, "houndstooth_proj._target")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SpawnImpactFx = Projectile_SpawnImpactFx

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.HOUNDSTOOTH_BLOWPIPE_DAMAGE)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.HOUNDSTOOTH_BLOWPIPE_PLANAR_DAMAGE)

    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.HOUNDSTOOTH_BLOWPIPE_VS_SHADOW_BONUS)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.HOUNDSTOOTH_BLOWPIPE_PROJECTILE_SPEED)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnThrownFn(Projectile_OnThrown)
    inst.components.projectile:SetOnPreHitFn(Projectile_OnPreHit)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetLaunchOffset(Vector3(2.5, LAUNCH_OFFSET_Y, 2.5))
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile.range = 30
    inst.components.projectile.has_damage_set = true

    return inst
end

return
        Prefab("houndstooth_blowpipe", WeaponFn,     assets, weapon_prefabs    ),
        Prefab("houndstooth_proj",     ProjectileFn, assets, projectile_prefabs)