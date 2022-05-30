local assets =
{
    Asset("ANIM", "anim/bee_guard.zip"),
    Asset("ANIM", "anim/bee_guard_build.zip"),
    Asset("ANIM", "anim/bee_guard_puffy_build.zip"),
}

local prefabs =
{
    "bee_poof_big",
    "bee_poof_small",
    "stinger",
}

--------------------------------------------------------------------------

local brain = require("brains/beeguardbrain")

--------------------------------------------------------------------------

local normalsounds =
{
    attack = "dontstarve/bee/killerbee_attack",
    --attack = "dontstarve/creatures/together/bee_queen/beeguard/attack",
    buzz = "dontstarve/bee/bee_fly_LP",
    hit = "dontstarve/creatures/together/bee_queen/beeguard/hurt",
    death = "dontstarve/creatures/together/bee_queen/beeguard/death",
}

local poofysounds =
{
    attack = "dontstarve/bee/killerbee_attack",
    --attack = "dontstarve/creatures/together/bee_queen/beeguard/attack",
    buzz = "dontstarve/bee/killerbee_fly_LP",
    hit = "dontstarve/creatures/together/bee_queen/beeguard/hurt",
    death = "dontstarve/creatures/together/bee_queen/beeguard/death",
}

local function EnableBuzz(inst, enable)
    if enable then
        if not inst.buzzing then
            inst.buzzing = true
            if not inst:IsAsleep() then
                inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
            end
        end
    elseif inst.buzzing then
        inst.buzzing = false
        inst.SoundEmitter:KillSound("buzz")
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end

    if inst.buzzing then
        inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    end
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
    end
    inst._sleeptask = not inst.components.health:IsDead() and inst:DoTaskInTime(10, inst.Remove) or nil

    inst.SoundEmitter:KillSound("buzz")
end

--------------------------------------------------------------------------

local function CheckFocusTarget(inst)
    if inst._focustarget ~= nil and (
            not inst._focustarget:IsValid() or
            (inst._focustarget.components.health ~= nil and inst._focustarget.components.health:IsDead()) or
            inst._focustarget:HasTag("playerghost")
        ) then
        inst._focustarget = nil
        inst:RemoveTag("notaunt")
    end
    return inst._focustarget
end

local function RetargetFn(inst)
    local focustarget = CheckFocusTarget(inst)
    if focustarget ~= nil then
        return focustarget, not inst.components.combat:TargetIs(focustarget)
    end
    local player, distsq = inst:GetNearestPlayer()
    return distsq ~= nil and distsq < 225 and player or nil
end

local function KeepTargetFn(inst, target)
    local focustarget = CheckFocusTarget(inst)
    return (focustarget ~= nil and
            inst.components.combat:TargetIs(focustarget))
        or (inst.components.combat:CanTarget(target) and
            inst:IsNear(target, 40))
end

local function bonus_damage_via_allergy(inst, target, damage, weapon)
    return (target:HasTag("allergictobees") and TUNING.BEE_ALLERGY_EXTRADAMAGE) or 0
end

local function CanShareTarget(dude)
    return dude:HasTag("bee") and not (dude:IsInLimbo() or dude.components.health:IsDead() or dude:HasTag("epic"))
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(CheckFocusTarget(inst) or data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 20, CanShareTarget, 6)
end

local function OnAttackOther(inst, data)
    if data.target ~= nil and data.target.components.inventory ~= nil then
        for k, eslot in pairs(EQUIPSLOTS) do
            local equip = data.target.components.inventory:GetEquippedItem(eslot)
            if equip ~= nil and equip.components.armor ~= nil and equip.components.armor.tags ~= nil then
                for i, tag in ipairs(equip.components.armor.tags) do
                    if tag == "bee" then
                        inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.OFTEN)
                        return
                    end
                end
            end
        end
    end
    inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.ALWAYS)
end

--------------------------------------------------------------------------

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

--------------------------------------------------------------------------

local function OnLoadPostPass(inst)
    local queen = inst.components.entitytracker:GetEntity("queen")
    if queen ~= nil and queen.components.commander ~= nil then
        queen.components.commander:AddSoldier(inst)
    end
end

local function OnSpawnedGuard(inst, queen)
    inst.sg:GoToState("spawnin", queen)
    if queen.components.commander ~= nil then
        queen.components.commander:AddSoldier(inst)
    end
end

--------------------------------------------------------------------------

local function FocusTarget(inst, target)
    inst._focustarget = target
    inst:AddTag("notaunt")

    if target ~= nil then
        if inst.components.locomotor.walkspeed ~= TUNING.BEEGUARD_DASH_SPEED then
            inst.AnimState:SetBuild("bee_guard_puffy_build")
            inst.components.locomotor.walkspeed = TUNING.BEEGUARD_DASH_SPEED
            inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_PUFFY_DAMAGE)
            inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_PUFFY_ATTACK_PERIOD)
            inst.sounds = poofysounds
            if inst.SoundEmitter:PlayingSound("buzz") then
                inst.SoundEmitter:KillSound("buzz")
                inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
            end
            SpawnPrefab("bee_poof_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
        inst.components.combat:SetTarget(target)
    elseif inst.components.locomotor.walkspeed ~= TUNING.BEEGUARD_SPEED then
        inst.AnimState:SetBuild("bee_guard_build")
        inst.components.locomotor.walkspeed = TUNING.BEEGUARD_SPEED
        inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_PUFFY_DAMAGE)
        inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_PUFFY_ATTACK_PERIOD)
        inst.sounds = normalsounds
        if inst.SoundEmitter:PlayingSound("buzz") then
            inst.SoundEmitter:KillSound("buzz")
            inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
        end
        SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function OnGotCommander(inst, data)
    local queen = inst.components.entitytracker:GetEntity("queen")
    if queen ~= data.commander then
        inst.components.entitytracker:ForgetEntity("queen")
        inst.components.entitytracker:TrackEntity("queen", data.commander)

        local angle = -inst.Transform:GetRotation() * DEGREES
        inst.components.knownlocations:RememberLocation("queenoffset", Vector3(TUNING.BEEGUARD_GUARD_RANGE * math.cos(angle), 0, TUNING.BEEGUARD_GUARD_RANGE * math.sin(angle)), false)
    end
end

local function OnLostCommander(inst, data)
    local queen = inst.components.entitytracker:GetEntity("queen")
    if queen == data.commander then
        inst.components.entitytracker:ForgetEntity("queen")
        inst.components.knownlocations:ForgetLocation("queenoffset")
        FocusTarget(inst, nil)
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(1.4, 1.4, 1.4)

    inst.DynamicShadow:SetSize(1.2, .75)

    MakeFlyingCharacterPhysics(inst, 1.5, .75)

    inst.AnimState:SetBank("bee_guard")
    inst.AnimState:SetBuild("bee_guard_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("insect")
    inst:AddTag("bee")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddChanceLoot("stinger", 0.01)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper.diminishingreturns = true

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.BEEGUARD_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEGUARD_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_ATTACK_PERIOD)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.BEEGUARD_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(2, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.battlecryenabled = false
    inst.components.combat.hiteffectsymbol = "mane"
    inst.components.combat.bonusdamagefn = bonus_damage_via_allergy

    inst:AddComponent("entitytracker")
    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "mane")
    MakeSmallFreezableCharacter(inst, "mane")
    inst.components.freezable:SetResistance(2)
    inst.components.freezable.diminishingreturns = true

    inst:SetStateGraph("SGbeeguard")
    inst:SetBrain(brain)

    MakeHauntablePanic(inst)

    inst.hit_recovery = 1

    inst:ListenForEvent("gotcommander", OnGotCommander)
    inst:ListenForEvent("lostcommander", OnLostCommander)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    inst.buzzing = true
    inst.sounds = normalsounds
    inst.EnableBuzz = EnableBuzz
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnSpawnedGuard = OnSpawnedGuard

    inst._focustarget = nil
    inst.FocusTarget = FocusTarget

    return inst
end

return Prefab("beeguard", fn, assets, prefabs)
