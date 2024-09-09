local snowball_assets =
{
    Asset("ANIM", "anim/firefighter_projectile.zip"),
}

local snowball_prefabs =
{
    "splash_snow_fx",
}

local waterballoon_assets =
{
    Asset("ANIM", "anim/waterballoon.zip"),
    Asset("ANIM", "anim/swap_waterballoon.zip"),
}

local waterballoon_prefabs =
{
    "waterballoon_splash",
    "reticule",
}

local ink_assets =
{
    Asset("ANIM", "anim/squid_watershoot.zip"),
}

local ink_prefabs =
{
    "ink_splash",
    "ink_puddle_land",
    "ink_puddle_water",
}

local waterstreak_assets =
{
    Asset("ANIM", "anim/waterstreak.zip"),
}

local waterstreak_prefabs =
{
    "waterstreak_burst",
}


local bile_assets =
{
    Asset("ANIM", "anim/bird_bileshoot.zip"),
}

local bile_prefabs =
{
    "bile_splash",
    "bile_puddle_land",
    "bile_puddle_water",
}

local function OnHitBile(inst, attacker, target)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("bile_splash").Transform:SetPosition(ix, iy, iz)
    if inst:IsOnOcean() then
        SpawnPrefab("bile_puddle_water").Transform:SetPosition(ix, iy, iz)
    else
        SpawnPrefab("bile_puddle_land").Transform:SetPosition(ix, iy, iz)
    end

    local ents = TheSim:FindEntities(ix, iy, iz, 2)
    for i,ent in ipairs(ents) do
        if ent.components.combat and not ent:HasTag("INLIMBO") and not ent:HasTag("playerghost") then
            ent.components.combat:GetAttacked(inst.shooter or inst, TUNING.MUTANT_BIRD_SPLASH_DAMAGE)
        end
    end
    inst:Remove()
end


local function OnHitInk(inst, attacker, target)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("ink_splash").Transform:SetPosition(ix, iy, iz)
    if inst:IsOnOcean() then
        SpawnPrefab("ink_puddle_water").Transform:SetPosition(ix, iy, iz)
    else
        SpawnPrefab("ink_puddle_land").Transform:SetPosition(ix, iy, iz)
    end
    local ents = TheSim:FindEntities(ix, iy, iz, 1)
    for _, ent in ipairs(ents) do
        if ent.components.inkable then
            ent.components.inkable:Ink()
        end
    end

    inst:Remove()
end

local function OnHitSnow(inst, attacker, target)
    SpawnPrefab("splash_snow_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.wateryprotection:SpreadProtection(inst)
    inst:Remove()
end

local function OnHitWater(inst, attacker, target)
    SpawnPrefab("waterballoon_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.wateryprotection:SpreadProtection(inst)
    inst:Remove()
end

local function common_fn(bank, build, anim, tag, isinventoryitem)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    if isinventoryitem then
        MakeInventoryPhysics(inst)
    else
        inst.entity:AddPhysics()
        inst.Physics:SetMass(1)
        inst.Physics:SetFriction(0)
        inst.Physics:SetDamping(0)
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:SetCapsule(0.2, 0.2)
        inst.Physics:SetDontRemoveOnSleep(true) -- so the object can land and put out the fire, also an optimization due to how this moves through the world
    end

    if tag ~= nil then
        inst:AddTag(tag)
    end

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)

    if type(anim) ~= "table" then
        inst.AnimState:PlayAnimation(anim, true)
    elseif #anim == 1 then
        inst.AnimState:PlayAnimation(anim[1], true)
    else
        for i, a in ipairs(anim) do
            if i == 1 then
                inst.AnimState:PlayAnimation(a, false)
            elseif i ~= #anim then
                inst.AnimState:PushAnimation(a, false)
            else
                inst.AnimState:PushAnimation(a, true)
            end
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("wateryprotection")

    inst:AddComponent("complexprojectile")

    return inst
end

local function snowball_fn()
    local inst = common_fn("firefighter_projectile", "firefighter_projectile", "spin_loop", "NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnHitSnow)

    inst.components.wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.FIRESUPPRESSOR_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.FIRESUPPRESSOR_PROTECTION_TIME
    inst.components.wateryprotection.addcoldness = TUNING.FIRESUPPRESSOR_ADD_COLDNESS
    inst.components.wateryprotection:AddIgnoreTag("player")

    return inst
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_waterballoon", "swap_waterballoon")
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

    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function onuseaswatersource(inst)
    if inst.components.stackable:IsStack() then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end

local function waterballoon_fn()
    --weapon (from weapon component) added to pristine state for optimization
    local inst = common_fn("waterballoon", "waterballoon", "idle", "weapon", true)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    MakeInventoryFloatable(inst, "med", 0.05, 0.65)

    -- From watersource component
    inst:AddTag("watersource")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHitWater)

    inst.components.wateryprotection.extinguishheatpercent = TUNING.WATERBALLOON_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.WATERBALLOON_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.WATERBALLOON_PROTECTION_TIME
    inst.components.wateryprotection.addwetness = TUNING.WATERBALLOON_ADD_WETNESS

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("watersource")
    inst.components.watersource.onusefn = onuseaswatersource
    inst.components.watersource.override_fill_uses = 1

    MakeHauntableLaunch(inst)

    return inst
end

local function ink_fn()
    local inst = common_fn("squid_watershoot", "squid_watershoot", "spin_loop", "NOCLICK")

    inst.AnimState:PlayAnimation("spin_pre",false)
    inst.AnimState:PlayAnimation("spin_loop",true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnHitInk)

    inst.components.wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.FIRESUPPRESSOR_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.FIRESUPPRESSOR_PROTECTION_TIME
    inst.components.wateryprotection.addcoldness = TUNING.FIRESUPPRESSOR_ADD_COLDNESS
    inst.components.wateryprotection:AddIgnoreTag("player")

    return inst
end

local function OnHitWaterstreak(inst, attacker, target)
    local hpx, hpy, hpz = inst.Transform:GetWorldPosition()

    SpawnPrefab("waterstreak_burst").Transform:SetPosition(hpx, hpy, hpz)

    if not TheWorld.Map:IsPassableAtPoint(hpx, hpy, hpz) then
        SpawnPrefab("ocean_splash_small2").Transform:SetPosition(hpx, hpy, hpz)
    end

    inst.components.wateryprotection:SpreadProtection(inst, TUNING.WATERSTREAK_AOE_DIST)
    inst:Remove()
end

local WATERSTREAK_ANIMS = {"pre", "loop"}
local function waterstreak_fn()
    local inst = common_fn("waterstreak", "waterstreak", WATERSTREAK_ANIMS, "NOCLICK")

    inst.Transform:SetSixFaced()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.components.complexprojectile:SetOnHit(OnHitWaterstreak)

    inst.components.wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.addwetness = TUNING.WATERBALLOON_ADD_WETNESS
    inst.components.wateryprotection:AddIgnoreTag("player")

    return inst
end

local function bile_fn()
    local inst = common_fn("bird_bileshoot", "bird_bileshoot", "spin_loop", "NOCLICK")

    inst.AnimState:PlayAnimation("spin_pre",false)
    inst.AnimState:PlayAnimation("spin_loop",true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnHitBile)

    inst.components.wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.FIRESUPPRESSOR_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.FIRESUPPRESSOR_PROTECTION_TIME
    inst.components.wateryprotection.addcoldness = TUNING.FIRESUPPRESSOR_ADD_COLDNESS
    inst.components.wateryprotection:AddIgnoreTag("player")

    return inst
end

return Prefab("snowball", snowball_fn, snowball_assets, snowball_prefabs),
    Prefab("waterballoon", waterballoon_fn, waterballoon_assets, waterballoon_prefabs),
    Prefab("inksplat", ink_fn, ink_assets, ink_prefabs),
    Prefab("bilesplat", bile_fn, bile_assets, bile_prefabs),
    Prefab("waterstreak_projectile", waterstreak_fn, waterstreak_assets, waterstreak_prefabs)
