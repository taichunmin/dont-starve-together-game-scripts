local assets =
{
    Asset("ANIM", "anim/barnacle_burr.zip"),
    Asset("ANIM", "anim/swap_barnacle_burr.zip"),

    Asset("INV_IMAGE", "waterplant_bomb"),
}

local projectile_assets =
{
    Asset("ANIM", "anim/barnacle_burr.zip"),
}

local prefabs =
{
    "splash_sink",
    "reticule",
    "reticuleaoe",
    "reticuleaoeping",
    "waterplant_burr_burst",
}

local projectile_prefabs =
{
    "splash_sink",
    "waterplant_burr_burst",
}

local BOMB_MUSTHAVE_TAGS = { "_combat" }
local function do_bomb(inst, thrower, target, no_hit_tags, damage, break_boats)
    local bx, by, bz = inst.Transform:GetWorldPosition()

    -- Find anything nearby that we might want to interact with
    local entities = TheSim:FindEntities(bx, by, bz, TUNING.WATERPLANT.ATTACK_AOE * 1.5, BOMB_MUSTHAVE_TAGS, no_hit_tags)

    -- If we have a thrower with a combat component, we need to do some manipulation to become a proper combat target.
    if thrower ~= nil and thrower.components.combat ~= nil and thrower:IsValid() then
        thrower.components.combat.ignorehitrange = true
    else
        thrower = nil
    end

    local hit_a_target = false
    for i, v in ipairs(entities) do
        if v:IsValid() and v.entity:IsVisible() and inst.components.combat:CanTarget(v) then
            hit_a_target = true

            if thrower ~= nil and v.components.combat.target == nil then
                v.components.combat:GetAttacked(thrower, damage, inst)
            else
                inst.components.combat:DoAttack(v)
            end

            if not v.components.health:IsDead() and v:HasTag("stunnedbybomb") then
                v:PushEvent("stunbomb")
            end
        end
    end

    if thrower ~= nil then
        thrower.components.combat.ignorehitrange = false
    end

    -- If we DIDN'T hit a target, but DID land on a boat, put a leak in the boat!
    if break_boats and not hit_a_target then
        local platform = TheWorld.Map:GetPlatformAtPoint(bx, bz)
        if platform ~= nil then
            local dsq_to_boat = platform:GetDistanceSqToPoint(bx, by, bz)
            if dsq_to_boat < TUNING.GOOD_LEAKSPAWN_PLATFORM_RADIUS then
                platform:PushEvent("spawnnewboatleak", {pt = Vector3(bx, by, bz), leak_size = "small_leak", playsoundfx = true})
            end
        end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_barnacle_burr", "swap_barnacle_burr")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function set_thrown_physics(inst)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:SetCapsule(0.2, 0.2)
end

local function on_inventory_thrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop", true)

    set_thrown_physics(inst)
end

local NO_TAGS_PLAYER =  { "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion", "player" }
local NO_TAGS_PVP =     { "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion" }
local function on_inventory_hit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()

    if not TheWorld.Map:IsPassableAtPoint(x, y, z) then
        SpawnPrefab("splash_sink").Transform:SetPosition(x, y, z)
    end

    SpawnPrefab("waterplant_burr_burst").Transform:SetPosition(x, y, z)

    if TheNet:GetPVPEnabled() then
        do_bomb(inst, attacker, target, NO_TAGS_PVP, TUNING.WATERPLANT.ITEM_DAMAGE, true)
    else
        do_bomb(inst, attacker, target, NO_TAGS_PLAYER, TUNING.WATERPLANT.ITEM_DAMAGE)
    end

    inst:Remove()
end

local function reticule_target_fn()
    local ground = TheWorld.Map
    local pos = Vector3()

    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = ThePlayer.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function projectile_keeptarget(inst)
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

    MakeInventoryPhysics(inst)

    inst:AddTag("noattack")

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    inst.AnimState:SetBank("barnacle_burr")
    inst.AnimState:SetBuild("barnacle_burr")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetDeltaTimeMultiplier(.75)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = reticule_target_fn
    inst.components.reticule.ease = true

    MakeInventoryFloatable(inst, "small", 0.1, 0.8)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(on_inventory_thrown)
    inst.components.complexprojectile:SetOnHit(on_inventory_hit)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.WATERPLANT.ITEM_DAMAGE)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WATERPLANT.ITEM_DAMAGE)
    inst.components.combat:SetRange(TUNING.WATERPLANT.ATTACK_AOE)
    inst.components.combat:SetKeepTargetFunction(projectile_keeptarget)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

local function onthrown(inst)
    inst.AnimState:PlayAnimation("spin_loop", true)
end

local NO_TAGS_WATERPLANT = { "waterplant", "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion" }
local function onhit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()

    if not TheWorld.Map:IsPassableAtPoint(x, y, z) then
        SpawnPrefab("splash_sink").Transform:SetPosition(x, y, z)
    end

    SpawnPrefab("waterplant_burr_burst").Transform:SetPosition(x, y, z)

    do_bomb(inst, attacker, target, NO_TAGS_WATERPLANT, TUNING.WATERPLANT.DAMAGE, true)

    inst:Remove()
end

local PROJECTILE_LAUNCH_OFFSET = Vector3(1.0, 8.0, 0)

local function projectile_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    set_thrown_physics(inst)
    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")
    inst:AddTag("noattack")

    -- Pristine state optimization tags
    inst:AddTag("projectile")   -- complexprojectile

    inst.AnimState:SetBank("barnacle_burr")
    inst.AnimState:SetBuild("barnacle_burr")
    inst.AnimState:PlayAnimation("idle")

    inst:SetPrefabNameOverride("waterplant") --for death announce

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- Projectiles don't need to survive save/loads
    inst.persists = false

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(25)
    inst.components.complexprojectile:SetGravity(-90)
    inst.components.complexprojectile:SetLaunchOffset(PROJECTILE_LAUNCH_OFFSET)
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(onhit)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WATERPLANT.DAMAGE)
    inst.components.combat:SetRange(TUNING.WATERPLANT.ATTACK_AOE)
    inst.components.combat:SetKeepTargetFunction(projectile_keeptarget)

    return inst
end

return Prefab("waterplant_bomb", fn, assets, prefabs),
        Prefab("waterplant_projectile", projectile_fn, projectile_assets, projectile_prefabs)
