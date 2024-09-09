local assets =
{
    Asset("ANIM", "anim/wurt_swampbomb.zip"),
    Asset("ANIM", "anim/swap_wurt_swampbomb.zip"),
}

local fx_assets =
{
    Asset("ANIM", "anim/wurt_swampitem_charged_fx.zip"),
}

local prefabs = {
    "wurt_swamp_terraformer",
    "wurt_terraform_projectile",

    "wurt_merm_planar",

    "wurt_terraform_cast_debuff",
    "wurt_swampitem_shadow_chargedfx",
    "wurt_swampitem_lunar_chargedfx",
}

local TERRAFORM_DEBUFF_TIMER_NAME = "buffover"

local function item_is_wurt_terraform_equipment(item)
    return item._is_wurt_terraform_equip
end

-- Client-side
local function CLIENT_BombReticuleTargetFn()
    local ground = TheWorld.Map
    local pos = Vector3()
    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = ThePlayer.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            break
        end
    end
    return pos
end

-- Casting behaviour
local MINOR_VERTICAL_OFFSET = Vector3(0, 0.5, 0)
local function CastTerraformingSpell(inst, target, position)
    if not position then return end

    local terraform_bomb = SpawnPrefab("wurt_terraform_projectile")
    terraform_bomb.Transform:SetPosition(position:Get())
    terraform_bomb._terraform_tile_type = inst._terraform_tile_type
    terraform_bomb._extra_onhit_fn = inst._extra_onhit_fn
    terraform_bomb._landed_sound = inst._landed_sound

    terraform_bomb.components.complexprojectile:Launch(position + MINOR_VERTICAL_OFFSET, inst, inst)

    inst.components.rechargeable:Discharge(TUNING.WURT_TERRAFORMING_RECHARGE_TIME)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner then
        owner:AddDebuff("wurt_terraform_cast_debuff", "wurt_terraform_cast_debuff")

        if owner.components.staffsanity then
            owner.components.staffsanity:DoCastingDelta(-TUNING.SANITY_MEDLARGE)
        elseif owner.components.sanity ~= nil then
            owner.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
        end

        -- Discharge each other terraformer currently in our inventory as well.
        -- We'll "fix up" any new ones that we pick up in the pickup function.
        local terraform_items = owner.components.inventory:FindItems(item_is_wurt_terraform_equipment)
        for _, terraform_item in pairs(terraform_items) do
            if terraform_item ~= inst then
                terraform_item.components.rechargeable:Discharge(TUNING.WURT_TERRAFORMING_RECHARGE_TIME)
            end
        end
    end
end

local function CanCastTerraformingSpell(doer, target, position)
    if doer:HasDebuff("wurt_terraform_cast_debuff") then
        return false, "TERRAFORM_TOO_SOON"
    else
        return true, nil
    end
end

-- Rechargeable
local function add_charged_fx(inst, owner)
    if not inst._charged_vfx and inst.components.equippable:IsEquipped() then
        local charged_vfx = SpawnPrefab(inst._fx_type or "wurt_swampitem_shadow_chargedfx")
        charged_vfx.entity:AddFollower()
        charged_vfx.entity:SetParent(owner.entity)
        charged_vfx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -100, 0)
        inst._charged_vfx = charged_vfx
    end
end
local function remove_charged_fx(inst)
    if inst._charged_vfx then
        inst._charged_vfx:Remove()
        inst._charged_vfx = nil
    end
end

local function OnDischarged(inst)
    inst.components.spellcaster:SetSpellFn(nil)

    remove_charged_fx(inst)
end

local function OnCharged(inst)
    inst.components.spellcaster:SetSpellFn(CastTerraformingSpell)

    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner then
        add_charged_fx(inst, owner)
    end
end

-- Equippable
local function OnEquip_CheckForChargedFX(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner then
        local owner_debuffable = owner.components.debuffable
        local cant_terraform_debuff = (owner_debuffable and owner_debuffable:GetDebuff("wurt_terraform_cast_debuff"))
        if not cant_terraform_debuff then
            add_charged_fx(inst, owner)
        end
    end
end
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", inst.swap_file, inst.swap_symbol)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    -- On Save/Load, we can't guarantee debuffable vs inventory/equippable loading, so frame delay our check
    -- to help make sure that the debuff has applied before we check for its existence.
    inst:DoTaskInTime(FRAMES, OnEquip_CheckForChargedFX)
end
local function unequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    remove_charged_fx(inst)
end

-- Inventory item
local function on_item_putininventory(inst, owner)
    if not owner then return end

    local owner_debuffable = owner.components.debuffable
    local cant_terraform_debuff = (owner_debuffable and owner_debuffable:GetDebuff("wurt_terraform_cast_debuff"))
    if not cant_terraform_debuff then return end

    local debuff_time_remaining = cant_terraform_debuff.components.timer:GetTimeLeft(TERRAFORM_DEBUFF_TIMER_NAME)
    local recharge_percent = (1 - (debuff_time_remaining / TUNING.WURT_TERRAFORMING_RECHARGE_TIME))

    -- If our debuff recharge time is less than the picked up item's percent,
    -- push the picked up item down to match. This way, we never shave time off of
    -- a recharge during a pickup, for multi-Wurt item swapping shenanigans.
    if recharge_percent < inst.components.rechargeable:GetPercent() then
        inst.components.rechargeable:SetPercent(recharge_percent)
    end
end

--
local function wurt_terraformer_fn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wurt_swampbomb")
    inst.AnimState:SetBuild("wurt_swampbomb")
    inst.AnimState:PlayAnimation(anim or "idle", true)

    local reticule = inst:AddComponent("reticule")
    reticule.targetfn = CLIENT_BombReticuleTargetFn
    reticule.ease = true

    inst.spelltype = "TERRAFORM"

    -- For optimization:
    --      rechargeable from rechargeable
    --      weapon from weapon
    inst:AddTag("rechargeable")
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.05, 0.65)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._is_wurt_terraform_equip = true

    --
    local equippable = inst:AddComponent("equippable")
    equippable:SetOnEquip(onequip)
    equippable:SetOnUnequip(unequip)

    --
    inst:AddComponent("inspectable")

    --
    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetOnPutInInventoryFn(on_item_putininventory)

    --
    local rechargeable = inst:AddComponent("rechargeable")
    rechargeable.chargetime = TUNING.WURT_TERRAFORMING_RECHARGE_TIME
    rechargeable:SetOnDischargedFn(OnDischarged)
    rechargeable:SetOnChargedFn(OnCharged)

    --
    local spellcaster = inst:AddComponent("spellcaster")
    spellcaster:SetSpellFn(CastTerraformingSpell)
    spellcaster:SetCanCastFn(CanCastTerraformingSpell)
    spellcaster.canuseonpoint = true
    spellcaster.veryquickcast = true

    local weapon = inst:AddComponent("weapon")
    weapon:SetDamage(0)

    MakeHauntableLaunch(inst)

    return inst
end

-- Shadow
local function wurt_swampbomb_shadow()
    local inst = wurt_terraformer_fn("swampitem_shadow_idle")

    if not TheWorld.ismastersim then
        return inst
    end

    -- NOTE: This is done in SGwilson
    inst.castsound = "meta4/marshify/shadow_cast_throw"

    inst.swap_file = "swap_wurt_swampbomb"
    inst.swap_symbol = "swap_shadow"

    inst._terraform_tile_type = "SHADOW"
    inst._fx_type = "wurt_swampitem_shadow_chargedfx"
    inst._landed_sound = "meta4/marshify/shadow_cast_land"

    inst.components.spellcaster:SetSpellType(SPELLTYPES.SHADOW_SWAMP_BOMB)

    return inst
end

-- Lunar
local LUNAR_AOE_MUST_TAGS = {"_combat", "_health", "merm"}
local LUNAR_AOE_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local function OnHit_Lunar(inst, attacker, target)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab("groundpoundring_fx")
    local zone_width = ((TUNING.WURT_TERRAFORMING_TILERANGE + 0.5)*TILE_SCALE)
    local zone_diagonal = math.sqrt(zone_width * zone_width + zone_width * zone_width)
    local fxscale = math.sqrt(zone_diagonal / 12)
    fx.Transform:SetScale(fxscale, fxscale, fxscale)
    fx.Transform:SetPosition(ix, 0, iz)

    local owner = attacker.components.inventoryitem:GetGrandOwner()
    if not owner:IsValid() then owner = nil end
    local pvp = TheNet:GetPVPEnabled()

    local potential_hit_entities = TheSim:FindEntities(ix, 0, iz, zone_diagonal, LUNAR_AOE_MUST_TAGS, LUNAR_AOE_CANT_TAGS)
    for _, potential_hit in ipairs(potential_hit_entities) do
        --[[if potential_hit ~= inst and (owner == nil or (potential_hit ~= owner and not owner.components.combat:IsAlly(potential_hit))) then
            potential_hit.components.combat:GetAttacked(owner, TUNING.WURT_TERRAFORMING_LUNAR_DAMAGE)
        end]]

        if (owner ~= nil and owner.components.leader:IsFollower(potential_hit)) then
            if potential_hit.DoLunarMutation then
                potential_hit = potential_hit:DoLunarMutation()
            end
            potential_hit:AddDebuff("wurt_merm_planar", "wurt_merm_planar")
        end
    end
end

local function wurt_swampbomb_lunar()
    local inst = wurt_terraformer_fn("swampitem_lunar_idle")

    if not TheWorld.ismastersim then
        return inst
    end

    -- NOTE: This is done in SGwilson
    inst.castsound = "meta4/marshify/lunar_cast_throw"

    inst.swap_file = "swap_wurt_swampbomb"
    inst.swap_symbol = "swap_lunar"

    inst._terraform_tile_type = "LUNAR"
    inst._extra_onhit_fn = OnHit_Lunar
    inst._fx_type = "wurt_swampitem_lunar_chargedfx"
    inst._landed_sound = "meta4/marshify/lunar_cast_land"

    inst.components.spellcaster:SetSpellType(SPELLTYPES.LUNAR_SWAMP_BOMB)

    return inst
end

-- Projectile
local function OnHitTerraformer(inst, attacker, target)
    local terraformer = SpawnPrefab("wurt_swamp_terraformer")
    terraformer.Transform:SetPosition(inst.Transform:GetWorldPosition())
    terraformer:SetType(inst._terraform_tile_type or "SHADOW")
    terraformer:DoTerraform()

    if inst._landed_sound then
        terraformer.SoundEmitter:PlaySound(inst._landed_sound)
    end

    if inst._extra_onhit_fn then
        inst._extra_onhit_fn(inst, attacker, target)
    end

    inst:Remove()
end

local function PlayProjectileSpawnSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_flesh_med_dull")
end

local function terraform_projectile()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetDontRemoveOnSleep(true)

    inst.AnimState:SetBank("wurt_swampbomb")
    inst.AnimState:SetBuild("wurt_swampbomb")
    inst.AnimState:PlayAnimation("blob_loop", true)

    inst:AddTag("NOCLICK")
    inst:AddTag("projectile") -- from 'complexprojectile'

    if not TheNet:IsDedicated() then
        local groundshadowhandler = inst:AddComponent("groundshadowhandler")
        groundshadowhandler:SetSize(0.8, 0.5)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    local complexprojectile = inst:AddComponent("complexprojectile")
    complexprojectile:SetGravity(-20)
    complexprojectile:SetHorizontalSpeed(0.1)
    complexprojectile:SetLaunchOffset(Vector3(0, 20, 0))
    complexprojectile:SetOnHit(OnHitTerraformer)

    inst:DoTaskInTime(0, PlayProjectileSpawnSound)

    return inst
end

-- Can't Cast Terraform debuff (to work b/w save/loads)
local function CastPrevention_OnTimerDone(inst, data)
    if data.name == TERRAFORM_DEBUFF_TIMER_NAME then
        inst.components.debuff:Stop()
    end
end
local function cant_terraform_debuff_fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    local debuff = inst:AddComponent("debuff")
    debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer(TERRAFORM_DEBUFF_TIMER_NAME, TUNING.WURT_TERRAFORMING_RECHARGE_TIME)
    inst:ListenForEvent("timerdone", CastPrevention_OnTimerDone)

    return inst
end

-- Charged FX
local function charged_fx_common(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("wurt_swampitem_charged_fx")
    inst.AnimState:SetBuild("wurt_swampitem_charged_fx")
    inst.AnimState:PlayAnimation(anim or "lunar", true)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)
    inst.AnimState:UsePointFiltering(true)

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst.persists = false

    return inst
end

local function wurt_swampitem_shadow_fx()
    return charged_fx_common("shadow")
end

local function wurt_swampitem_lunar_fx()
    local inst = charged_fx_common("lunar")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(.1)

    return inst
end

return Prefab("wurt_swampitem_shadow", wurt_swampbomb_shadow, assets, prefabs),
    Prefab("wurt_swampitem_shadow_chargedfx", wurt_swampitem_shadow_fx, fx_assets),
    Prefab("wurt_swampitem_lunar", wurt_swampbomb_lunar, assets, prefabs),
    Prefab("wurt_swampitem_lunar_chargedfx", wurt_swampitem_lunar_fx, fx_assets),
    Prefab("wurt_terraform_projectile", terraform_projectile, assets),
    Prefab("wurt_terraform_cast_debuff", cant_terraform_debuff_fn)