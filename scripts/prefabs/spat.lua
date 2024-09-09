local assets =
{
    Asset("ANIM", "anim/spat_basic.zip"),
    Asset("ANIM", "anim/spat_actions.zip"),
    Asset("ANIM", "anim/spat_build.zip"),
    Asset("ANIM", "anim/spat_phlegm.zip"),
    Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
    "meat",
    "poop",
    "steelwool",
    "phlegm",
    "spat_bomb",
}

local projectile_assets =
{
    Asset("ANIM", "anim/spat_bomb.zip"),
}

local projectile_prefabs =
{
    "spat_splat_fx",
    "spat_splash_fx_full",
    "spat_splash_fx_med",
    "spat_splash_fx_low",
    "spat_splash_fx_melted",
}

local brain = require("brains/spatbrain")

SetSharedLootTable( 'spat',
{
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'steelwool',       1.00},
    {'steelwool',       1.00},
    {'steelwool',       0.50},
    {'phlegm',          1.00},
    {'phlegm',          0.50},
})

local sounds =
{
    walk = "dontstarve/creatures/spat/walk",
    grunt = "dontstarve/creatures/spat/grunt",
    yell = "dontstarve/creatures/spat/yell",
    hit = "dontstarve/creatures/spat/hurt",
    death = "dontstarve/creatures/spat/death",
    curious = "dontstarve/creatures/spat/curious",
    sleep = "dontstarve/creatures/spat/sleep",
    angry = "dontstarve/creatures/spat/angry",
    spit = "dontstarve/creatures/spat/spit",
    spit_hit = "dontstarve/creatures/spat/spit_hit",
}

local RETARGET_ONEOF_TAGS = {"player", "monster"}
local function Retarget(inst)
	return not inst:IsInLimbo() and FindEntity(
        inst,
        TUNING.SPAT_TARGET_DIST,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        nil,
        nil,
        RETARGET_ONEOF_TAGS
	) or nil
end

local function KeepTarget(inst, target)
	return not inst:IsInLimbo() and target:IsNear(inst, TUNING.SPAT_CHASE_DIST)
end

local function OnAttacked(inst, data)
    local target = inst.components.combat.target
    if target ~= nil and target.components.pinnable ~= nil and target.components.pinnable:IsStuck() then
        -- if we've goo'd someone, stay attacking them!
        return
    end

    inst.components.combat:SetTarget(data.attacker)
end

local function EquipWeapons(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local snotbomb = CreateEntity()
        snotbomb.name = "Snotbomb"
        --[[Non-networked entity]]
        snotbomb.entity:AddTransform()
        snotbomb:AddComponent("weapon")
        snotbomb.components.weapon:SetDamage(TUNING.SPAT_PHLEGM_DAMAGE)
        snotbomb.components.weapon:SetRange(TUNING.SPAT_PHLEGM_ATTACKRANGE)
        snotbomb.components.weapon:SetProjectile("spat_bomb")
        snotbomb:AddComponent("inventoryitem")
        snotbomb.persists = false
        snotbomb.components.inventoryitem:SetOnDroppedFn(snotbomb.Remove)
        snotbomb:AddComponent("equippable")
        snotbomb:AddTag("snotbomb")
        snotbomb:AddTag("nosteal")

        inst.components.inventory:GiveItem(snotbomb)
        inst.weaponitems.snotbomb = snotbomb

        local meleeweapon = CreateEntity()
        meleeweapon.name = "Snaut Bash"
        --[[Non-networked entity]]
        meleeweapon.entity:AddTransform()
        meleeweapon:AddComponent("weapon")
        meleeweapon.components.weapon:SetDamage(TUNING.SPAT_MELEE_DAMAGE)
        meleeweapon.components.weapon:SetRange(TUNING.SPAT_MELEE_ATTACKRANGE)
        meleeweapon:AddComponent("inventoryitem")
        meleeweapon.persists = false
        meleeweapon.components.inventoryitem:SetOnDroppedFn(meleeweapon.Remove)
        meleeweapon:AddComponent("equippable")
        meleeweapon:AddTag("meleeweapon")
        meleeweapon:AddTag("nosteal")

        inst.components.inventory:GiveItem(meleeweapon)
        inst.weaponitems.meleeweapon = meleeweapon
    end
end

local function CustomOnHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

local function OnForceSleep(inst)
    if inst.components.sleeper ~= nil then
        inst.components.sleeper:AddSleepiness(10 + 3 * math.random(), TUNING.PANFLUTE_SLEEPTIME)
    end
end

local function OnVisibleFn(inst)
	inst.sg:GoToState("spawn_shake")
end

local function WillUnhideFn(inst)
    local player, distsq = inst:GetNearestPlayer(true)
    if player and distsq < 225 then -- 15 * 15
        return player
    end

    return nil
end

local function OnUnhideFn(inst, player)
    if inst.components.periodicspawner ~= nil then
        inst.components.periodicspawner:SafeStart()
    end
    if inst.components.combat ~= nil then
        -- NOTES(JBK): ReturnToScene can activate a brain and cause the warg to target something else clear it by force now.
        inst.components.combat:DropTarget()
        inst.components.combat:SuggestTarget(player)
    end
end

local function OnHideFn(inst)
    if inst.components.periodicspawner ~= nil then
        inst.components.periodicspawner:Stop()
    end
end

local function PropCreationFn(inst)
    local corpse = SpawnPrefab("koalefantcorpse_prop")
    if TheWorld.state.iswinter then
        corpse:SetAltBuild()
    end
    corpse.Transform:SetPosition(inst.Transform:GetWorldPosition())

    return corpse
end

local function OnSpawnedForHunt(inst, data)
    if data == nil then
        return
    end

    -- NOTES(JBK): This came from a hunt investigation so let us make it a bit more special.

    -- First spawn meats from a fake koalefant.
    SimulateKoalefantDrops(inst)

    -- Then check if this is spring loaded.
    if data.action == HUNT_ACTIONS.PROP then
        -- Took too long, make it an ambush!
        if inst.components.prophider ~= nil then
            inst.components.prophider:HideWithProp()
        end
    elseif data.action == HUNT_ACTIONS.SLEEP or data.action == HUNT_ACTIONS.SUCCESS then
        inst:DoTaskInTime(0, OnForceSleep) -- NOTES(JBK): Delay a frame for initialization to complete.
    else
        -- FIXME(JBK): Unhandled state.
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("spat")
    inst.AnimState:SetBuild("spat_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.scrapbook_damage = TUNING.SPAT_MELEE_DAMAGE

    inst:AddTag("spat")
    inst:AddTag("animal")
    inst:AddTag("largecreature")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    local combat = inst:AddComponent("combat")
    combat.hiteffectsymbol = "spat_body"
    combat:SetRetargetFunction(1, Retarget)
    combat:SetKeepTargetFunction(KeepTarget)
    combat:SetAttackPeriod(3)
    combat:SetHurtSound(sounds.hit)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SPAT_HEALTH)

    inst:AddComponent("inventory")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('spat')

    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked)

    local periodicspawner = inst:AddComponent("periodicspawner")
    periodicspawner:SetPrefab("poop")
    periodicspawner:SetRandomTimes(40, 60)
    periodicspawner:SetDensityInRange(20, 2)
    periodicspawner:SetMinimumSpacing(8)
    periodicspawner:Start()

    MakeLargeBurnableCharacter(inst, "spat_body")
    MakeLargeFreezableCharacter(inst, "spat_body")

    local locomotor = inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    locomotor.walkspeed = 1.5
    locomotor.runspeed = 7

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, true, false, true)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGspat")

    inst.weaponitems = {}
    EquipWeapons(inst)

    local prophider = inst:AddComponent("prophider")
    prophider:SetPropCreationFn(PropCreationFn)
    prophider:SetOnVisibleFn(OnVisibleFn)
    prophider:SetWillUnhideFn(WillUnhideFn)
    prophider:SetOnUnhideFn(OnUnhideFn)
    prophider:SetOnHideFn(OnHideFn)

    inst:ListenForEvent("spawnedforhunt", OnSpawnedForHunt)

    return inst
end

local function doprojectilehit(inst, attacker, other)
    inst.SoundEmitter:PlaySound(sounds.spit_hit)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("spat_splat_fx").Transform:SetPosition(x, 0, z)

    if attacker ~= nil and not attacker:IsValid() then
        attacker = nil
    end

    -- stick whatever got actually hit by the projectile
    -- otherwise stick our target, if he was in splash radius
    if other == nil and attacker ~= nil then
        other = attacker.components.combat.target
        if other ~= nil and not (other:IsValid() and other:IsNear(inst, TUNING.SPAT_PHLEGM_RADIUS)) then
            other = nil
        end
    end

    if other ~= nil and other:IsValid() then
        if attacker ~= nil then
            attacker.components.combat:DoAttack(other, inst.components.complexprojectile.owningweapon, inst)
        end
        if other.components.pinnable ~= nil then
            other.components.pinnable:Stick()
        end
    end

    return other
end

local function OnProjectileHit(inst, attacker, other)
    doprojectilehit(inst, attacker, other)
    inst:Remove()
end

local function oncollide(inst, other)
    -- If there is a physics collision, try to do some damage to that thing.
    -- This is so you can't hide forever behind walls etc.

    local attacker = inst.components.complexprojectile.attacker
    if other ~= doprojectilehit(inst, attacker) and
        other ~= nil and
        other:IsValid() and
        other.components.combat ~= nil then
        if attacker ~= nil and attacker:IsValid() then
            attacker.components.combat:DoAttack(other, inst.components.complexprojectile.owningweapon, inst)
        end
        if other.components.pinnable ~= nil then
            other.components.pinnable:Stick()
        end
    end

    inst:Remove()
end

local function projectilefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:SetCapsule(0.02, 0.02)

    inst.AnimState:SetBank("spat_bomb")
    inst.AnimState:SetBuild("spat_bomb")
    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(oncollide)

    inst.persists = false

    inst:AddComponent("locomotor")
    local complexprojectile = inst:AddComponent("complexprojectile")
    complexprojectile:SetOnHit(OnProjectileHit)
    complexprojectile:SetHorizontalSpeed(30)
    complexprojectile:SetLaunchOffset(Vector3(3, 2, 0))
    complexprojectile.usehigharc = false

    return inst
end

return Prefab("spat", fn, assets, prefabs),
    Prefab("spat_bomb", projectilefn, projectile_assets, projectile_prefabs)
