local assets =
{
    Asset("ANIM", "anim/squid.zip"),
    Asset("ANIM", "anim/squid_water.zip"),
    Asset("ANIM", "anim/squid_build.zip"),
}

local inkassets =
{
    Asset("ANIM","anim/squid_inked.zip"),
}

local prefabs =
{
    "lightbulb",
    "squidherd",
    "wake_small",
    "squideyelight",
    "inksplat",
    "squid_ink_player_fx",
}

local brain = require("brains/squidbrain")
local easing = require("easing")

local sounds =
{
    attack = "hookline/creatures/squid/attack",
    bite = "hookline/creatures/squid/gobble",
    taunt = "hookline/creatures/squid/taunt",
    death = "hookline/creatures/squid/death",
    sleep = "hookline/creatures/squid/sleep",
    hurt = "hookline/creatures/squid/hit",
    gobble = "hookline/creatures/squid/gobble",
    spit = "hookline/creatures/squid/spit",
    swim = "turnoftides/common/together/water/swim/medium",
}

SetSharedLootTable('squid',
{
    {'monstermeat', 1.00},
    {'lightbulb', 1.00},
})

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30

--Called from stategraph
local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("inksplat")
    projectile.Transform:SetPosition(x, y, z)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    --local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)
    local speed = easing.linear(rangesq, 15, 1, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-35)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    -- this will always return false at the momnent, until we decide how they should naturally sleep.
    return false
        and not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning())
        and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function retargetfn(inst)

    return nil
end

local function KeepTarget(inst, target)
    return inst:IsNear(target, TUNING.SQUID_TARGET_KEEP)
end


local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("squid"))
                and data.attacker ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("squid"))
                and data.target ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, 5)
end

local function OnReelingIn(inst, doer)
    if inst:HasTag("partiallyhooked") then
        -- now fully hooked!
        inst:RemoveTag("partiallyhooked")
        inst.components.oceanfishable.queue_struggling = true
        inst.components.oceanfishable.struggling = true
    end
end

local function geteatchance(inst,target)
    return 0.3
end

local function OnEntitySleep(inst)
end

local function OnSave(inst, data)

end

local function OnLoad(inst, data)

end

local function fncommon()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetSixFaced()

    inst:AddTag("scarytooceanprey")
    inst:AddTag("monster")
    inst:AddTag("squid")
    inst:AddTag("herdmember")
    inst:AddTag("likewateroffducksback")

    inst.AnimState:SetBank("squiderp")
    inst.AnimState:SetBuild("squid_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("spawnfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.SQUID_RUNSPEED
    inst.components.locomotor.walkspeed = TUNING.SQUID_WALKSPEED
    inst.components.locomotor.skipHoldWhenFarFromHome = true

    inst:SetStateGraph("SGsquid")

	inst:AddComponent("embarker")
	inst.components.embarker.embark_speed = inst.components.locomotor.runspeed

    inst.components.locomotor:SetAllowPlatformHopping(true)

	inst:AddComponent("amphibiouscreature")
	inst.components.amphibiouscreature:SetBanks("squiderp", "squiderp_water")
    inst.components.amphibiouscreature:SetEnterWaterFn(
        function(inst)
            inst.hop_distance = inst.components.locomotor.hop_distance
            inst.components.locomotor.hop_distance = 4
            inst.DynamicShadow:Enable(false)
        end)
    inst.components.amphibiouscreature:SetExitWaterFn(
        function(inst)
            if inst.hop_distance then
                inst.components.locomotor.hop_distance = inst.hop_distance
            end
            inst.DynamicShadow:Enable(true)
        end)

	inst.components.locomotor.pathcaps = { allowocean = true }


    inst:SetBrain(brain)

    inst:AddComponent("follower")
    inst:AddComponent("entitytracker")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SQUID_HEALTH)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SQUID_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SQUID_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound(inst.sounds.hurt)
    inst.components.combat:SetRange(TUNING.SQUID_TARGET_RANGE, TUNING.SQUID_ATTACK_RANGE)
    inst.components.combat:EnableAreaDamage(true)
    inst.components.combat:SetAreaDamage(TUNING.SQUID_ATTACK_RANGE, 1, function(ent, inst)
        if not ent:HasTag("squid") then
            return true
        else
            if ent:IsValid() then
                ent.SoundEmitter:PlaySound("hookline/creatures/squid/slap")
                local x,y,z = ent.Transform:GetWorldPosition()
                local angle = inst:GetAngleToPoint(x,y,z)
                ent.Transform:SetRotation(angle)
                ent.sg:GoToState("fling")
            end
        end
    end)

    inst.components.combat.battlecryenabled = false

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('squid')

    inst:AddComponent("inspectable")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst:AddComponent("knownlocations")

    inst:AddComponent("timer")

    inst:AddComponent("herdmember")
    inst.components.herdmember:Enable(true)
    inst.components.herdmember.herdprefab = "squidherd"

    inst:AddComponent("oceanfishable")
    inst.components.oceanfishable.onreelinginfn = OnReelingIn
    inst.components.oceanfishable.max_run_speed = TUNING.SQUID_RUNSPEED
    inst.components.oceanfishable:StrugglingSetup(nil, TUNING.SQUID_RUNSPEED, TUNING.SQUID_FISHABLE_STAMINA)
	inst.components.oceanfishable.catch_distance = -1

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, "squid_body")
    MakeMediumBurnableCharacter(inst, "squid_body")

    inst.OnEntitySleep = OnEntitySleep

    inst.LaunchProjectile = LaunchProjectile
    inst.geteatchance = geteatchance

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    inst.eyeglow = SpawnPrefab("squideyelight")
    inst.eyeglow.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
    inst.eyeglow.entity:AddFollower()
    inst.eyeglow.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)

    return inst
end

local function squideyelightfn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.Light:SetRadius(TUNING.SQUID_LIGHT_UP_RADIUS)
    inst.Light:SetIntensity(TUNING.SQUID_LIGHT_UP_INTENSITY)
    inst.Light:SetFalloff(TUNING.SQUID_LIGHT_UP_FALLOFF)
    inst.Light:SetColour(200 / 255, 150 / 255, 50 / 255)
    inst.Light:Enable(true)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fader")

    return inst
end

local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)
    inst.Follower:FollowSymbol(target.GUID, "headbase", 0,0,0)
    --OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
end

local function OnDetached(inst)
    inst.AnimState:PlayAnimation("ink_pst")
    inst:ListenForEvent("animover", function()
        --inst.components.debuff:Stop()
        inst:Remove()
    end)
end

local function inkfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("squid_ink_follow")
    inst.AnimState:SetBuild("squid_inked")
    inst.AnimState:PlayAnimation("ink_pre")
    inst.AnimState:PushAnimation("ink_loop")
    inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)

    return inst
end

return Prefab("squid", fncommon, assets, prefabs),
       Prefab("squid_ink_player_fx", inkfn, inkassets),
       Prefab("squideyelight", squideyelightfn)
