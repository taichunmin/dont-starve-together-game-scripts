local assets =
{
    Asset("ANIM", "anim/deer_build.zip"),
    Asset("ANIM", "anim/deer_basic.zip"),
    Asset("ANIM", "anim/deer_action.zip"),
}

local unshackle_assets =
{
    Asset("ANIM", "anim/deer_build.zip"),
    Asset("ANIM", "anim/deer_unshackle.zip"),
}

local prefabs =
{
    "meat",
    "boneshard",
    "deer_antler",
    "deer_growantler_fx",
}

local redprefabs =
{
    "redgem",
    "meat",
    "deer_fire_circle",
    "deer_fire_charge",
    "deer_unshackle_fx",
}

local blueprefabs =
{
    "bluegem",
    "meat",
    "deer_ice_circle",
    "deer_ice_charge",
    "deer_unshackle_fx",
}

local brain = require("brains/deerbrain")
local brain_gemmed = require("brains/deergemmedbrain")

SetSharedLootTable('deer',
{
    {'meat',              1.00},
    {'meat',              0.50},
})

local function KeepTargetFn(inst, target)
    return target:IsValid() and inst:IsNear(target, TUNING.DEER_ATTACKER_REMEMBER_DIST)
end

local function ShareTargetFn(dude)
    return dude:HasTag("deer") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 12, ShareTargetFn, 3)
end

local function ValidShedAntlerTarget(inst, other)
    return inst.hasantler ~= nil and
        other ~= nil and
        other:IsValid() and
        other:HasTag("tree") and not other:HasTag("stump") and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked()
end

local function OnShedAntler(inst, other)
    if ValidShedAntlerTarget(inst, other) then
        inst.components.lootdropper:SpawnLootPrefab("deer_antler"..tostring(inst.hasantler))
        if not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("knockoffantler")
        end
        inst:SetAntlered(nil, false)

        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:WorkedBy(inst, 1)
    end
end

local function OnCollide(inst, other)
    if ValidShedAntlerTarget(inst, other) and
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 60 then

        inst:DoTaskInTime(2 * FRAMES, OnShedAntler, other)
    end
end

local function ShowAntler(inst)
    if inst.hasantler ~= nil then
        inst.AnimState:Show("swap_antler")
        inst.AnimState:OverrideSymbol("swap_antler_red", "deer_build", "swap_antler"..tostring(inst.hasantler))
    else
        inst.AnimState:Hide("swap_antler")
    end
end

local function setantlered(inst, antler, animate)
    inst.hasantler = antler
    inst.Physics:SetCollisionCallback(antler ~= nil and OnCollide or nil)

    if animate then
        inst:PushEvent("growantler")
    else
        inst:ShowAntler()
    end
end

-- c_sel():PushEvent("timerdone", {name="growantler"})
local function ontimerdone(inst, data)
    if data ~= nil then
        if data.name == "growantler" then
            setantlered(inst, math.random(3), true)
        end
    end
end

local function onqueuegrowantler(inst)
    if inst.hasantler == nil and not inst.components.timer:TimerExists("growantler") then
        inst.components.timer:StartTimer("growantler", (1 + math.random()) * TUNING.TOTAL_DAY_TIME)
    end
end

-------------------------------------------------------------------
local WALLS_ONEOF_TAGS = { "wall", "structure" }
local function OnMigrate(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local buildings = TheSim:FindEntities(x, y, z, 30, nil, nil, WALLS_ONEOF_TAGS)
    if #buildings < 10 then
        inst:Remove()
    end
end

local function StartMigrationTask(inst)
    if inst.migrationtask == nil then
        inst.migrationtask = inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME * .5 + math.random() * TUNING.SEG_TIME, OnMigrate)
    end
end

local function StopMigrationTask(inst)
    if inst.migrationtask ~= nil then
        inst.migrationtask:Cancel()
        inst.migrationtask = nil
    end
end

local function SetMigrating(inst, migrating)
    if migrating then
        if not inst.migrating then
            inst.migrating = true
            inst.OnEntitySleep = StartMigrationTask
            inst.OnEntityWake = StopMigrationTask
            if inst:IsAsleep() then
                StartMigrationTask(inst)
            end
        end
    elseif inst.migrating then
        inst.migrating = nil
        inst.OnEntitySleep = nil
        inst.OnEntityWake = nil
        StopMigrationTask(inst)
    end
end

local function ondeerherdmigration(inst)
    SetMigrating(inst, true)
end

-------------------------------------------------------------------
--Gemmed deers

local function GemmedShouldSleep(inst)
    return false
end

local function GemmedShouldWake(inst)
    return true
end

local SPELL_OVERLAP_MIN = 3
local SPELL_OVERLAP_MAX = 6
local NOSPELLOVERLAP_ONEOF_TAGS = { "deer_ice_circle", "deer_fire_circle" }
local function NoSpellOverlap(x, y, z, r)
    return #TheSim:FindEntities(x, 0, z, r or SPELL_OVERLAP_MIN, nil, nil, NOSPELLOVERLAP_ONEOF_TAGS) <= 0
end

--Hard limit target list size since casting does multiple passes it
local SPELL_MAX_TARGETS = 20
local SPELLTARGET_MUST_TAGS = { "_combat", "_health" }
local SPELLTARGET_CANT_TAGS = { "INLIMBO", "playerghost", "deergemresistance", "notarget" }
local function FindCastTargets(inst, target)
    if target ~= nil then
        --Single target for deer without keeper
        return target.components.health ~= nil
            and not (target.components.health:IsDead() or
                    target:HasTag("playerghost") or
                    target:HasTag("deergemresistance"))
            and target:IsNear(inst, TUNING.DEER_GEMMED_CAST_RANGE)
            and NoSpellOverlap(target.Transform:GetWorldPosition())
            and { target }
            or nil
    end
    --Multi-target when receiving commands from keeper
    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = {}
    local priorityindex = 1
    for i, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.DEER_GEMMED_CAST_RANGE, SPELLTARGET_MUST_TAGS, SPELLTARGET_CANT_TAGS)) do
        if not v.components.health:IsDead() then
            if v:HasTag("player") then
                table.insert(targets, priorityindex, v)
                if #targets >= SPELL_MAX_TARGETS then
                    return targets
                end
                priorityindex = priorityindex + 1
            elseif v.components.combat.target ~= nil and v.components.combat.target:HasTag("deergemresistance") then
                table.insert(targets, v)
                if #targets >= SPELL_MAX_TARGETS then
                    return targets
                end
            end
        end
    end
    return #targets > 0 and targets or nil
end

local function SpawnSpell(inst, x, z)
    local spell = SpawnPrefab(inst.castfx)
    spell.Transform:SetPosition(x, 0, z)
    spell:DoTaskInTime(inst.castduration, spell.KillFX)
    return spell
end

local function SpawnSpells(inst, targets)
    local spells = {}
    local nextpass = {}
    for i, v in ipairs(targets) do
        if v:IsValid() and v:IsNear(inst, TUNING.DEER_GEMMED_CAST_MAX_RANGE) then
            local x, y, z = v.Transform:GetWorldPosition()
            if NoSpellOverlap(x, 0, z, SPELL_OVERLAP_MAX) then
                table.insert(spells, SpawnSpell(inst, x, z))
                if #spells >= TUNING.DEER_GEMMED_MAX_SPELLS then
                    return spells
                end
            else
                table.insert(nextpass, { x = x, z = z })
            end
        end
    end
    if #nextpass <= 0 then
        return spells
    end
    for range = SPELL_OVERLAP_MAX - 1, SPELL_OVERLAP_MIN, -1 do
        local i = 1
        while i <= #nextpass do
            local v = nextpass[i]
            if NoSpellOverlap(v.x, 0, v.z, range) then
                table.insert(spells, SpawnSpell(inst, v.x, v.z))
                if #spells >= TUNING.DEER_GEMMED_MAX_SPELLS or #nextpass <= 1 then
                    return spells
                end
                table.remove(nextpass, i)
            else
                i = i + 1
            end
        end
    end
    return #spells > 0 and spells or nil
end

local function DoCast(inst, targets)
    local spells = targets ~= nil and SpawnSpells(inst, targets) or nil
    inst.components.timer:StopTimer("deercast_cd")
    inst.components.timer:StartTimer("deercast_cd", spells ~= nil and inst.castcd or TUNING.DEER_GEMMED_FIRST_CAST_CD)
    return spells
end

local function OnNewTarget(inst, data)
    if data.target ~= nil then
        inst:SetEngaged(true)
    end
end

local function IsDeadKeeper(keeper)
    return (keeper.IsUnchained == nil or keeper:IsUnchained())
        and keeper.components.health ~= nil
        and keeper.components.health:IsDead()
end

local function GemmedRetargetFn(inst)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    return keeper ~= nil
        and not IsDeadKeeper(keeper)
        and keeper.components.combat ~= nil
        and keeper.components.combat.target
        or nil
end

local function GemmedOnAttacked(inst, data)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper == nil or not IsDeadKeeper(keeper) then
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 12, ShareTargetFn, 3)
    end
end

local function SetEngaged(inst, engaged)
    --NOTE: inst.engaged is nil at instantiation, and engaged must not be nil
    if inst.engaged ~= engaged then
        inst.engaged = engaged
        inst.components.timer:StopTimer("deercast_cd")
        if engaged then
            inst.components.timer:StartTimer("deercast_cd", TUNING.DEER_GEMMED_FIRST_CAST_CD)
            inst:RemoveEventCallback("newcombattarget", OnNewTarget)
        else
            inst:ListenForEvent("newcombattarget", OnNewTarget)
        end
    end
end

local function OnGotCommander(inst, data)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper ~= data.commander then
        inst.components.entitytracker:ForgetEntity("keeper")
        inst.components.entitytracker:TrackEntity("keeper", data.commander)

        inst.components.knownlocations:RememberLocation("keeperoffset", inst:GetPosition() - data.commander:GetPosition(), false)
        inst:AddTag("notaunt")
    end
end

local function OnLostCommander(inst, data)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper == data.commander then
        inst.components.entitytracker:ForgetEntity("keeper")
        inst.components.knownlocations:ForgetLocation("keeperoffset")
        inst:RemoveTag("notaunt")
    end
end

local function GemmedOnLoadPostPass(inst)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper ~= nil and keeper.components.commander ~= nil then
        keeper.components.commander:AddSoldier(inst)
    end
end

local function OnUpdateOffset(inst, offset)
    inst.components.knownlocations:RememberLocation("keeperoffset", offset)
end

--------------------------------------------------------------------------

local function DoNothing()
end

local function DoChainIdleSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain_idle", nil, volume)
end

local function DoBellIdleSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell_idle", nil, volume)
end

local function DoChainSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain", nil, volume)
end

local function DoBellSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell", nil, volume)
end

local function SetupSounds(inst)
    if inst.gem == nil then
        inst.DoChainSound = DoNothing
        inst.DoChainIdleSound = DoNothing
        inst.DoBellSound = DoNothing
        inst.DoBellIdleSound = DoNothing
    elseif IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.DoChainSound = DoChainSound
        inst.DoChainIdleSound = DoChainIdleSound
        inst.DoBellSound = DoBellSound
        inst.DoBellIdleSound = DoBellIdleSound
    else
        inst.DoChainSound = DoChainSound
        inst.DoChainIdleSound = DoChainIdleSound
        inst.DoBellSound = DoNothing
        inst.DoBellIdleSound = DoNothing
    end
end

--------------------------------------------------------------------------

local function onsave(inst, data)
    data.hasantler = inst.hasantler
    data.migrating = inst.migrating or nil
end

local function onload(inst, data)
    if data ~= nil then
        if data.hasantler ~= nil then
            setantlered(inst, data.hasantler)
        end
        SetMigrating(inst, data.migrating)
    end
end

local function getstatus(inst)
    return inst.charged and "ANTLER" or nil
end

local function common_fn(gem)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1.75, .75)

    inst.Transform:SetSixFaced()

    MakeCharacterPhysics(inst, 100, .5)

    inst.AnimState:SetBank("deer")
    inst.AnimState:SetBuild("deer_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    if gem ~= nil then
        if gem ~= "red" then
            inst.AnimState:OverrideSymbol("swap_antler_red", "deer_build", "swap_antler_"..gem)
        end
        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
            inst.AnimState:OverrideSymbol("deer_hair", "deer_build", "deer_hair_winter")
            inst.AnimState:OverrideSymbol("swap_neck_collar", "deer_build", "swap_neck_collar_winter")
            inst.AnimState:OverrideSymbol("klaus_deer_chain", "deer_build", "klaus_deer_chain_winter")
            inst.AnimState:OverrideSymbol("deer_chest", "deer_build", "deer_chest_winter")
        end
        inst:AddTag("deergemresistance")
        inst:SetPrefabNameOverride("deer_gemmed")

        inst:AddComponent("spawnfader")
    else
        inst.AnimState:Hide("swap_antler")
        inst.AnimState:Hide("CHAIN")
        inst.AnimState:OverrideSymbol("swap_neck_collar", "deer_build", "swap_neck")

        --saltlicker (from saltlicker component) added to pristine state for optimization
        inst:AddTag("saltlicker")
    end

    ------------------------------------------

    inst:AddTag("deer")
    inst:AddTag("animal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_overridedata = {{"swap_neck_collar", "deer_build", "swap_neck" }, {"swap_antler_red", "deer_build", "swap_antler1"}}
    inst.scrapbook_hide = { "CHAIN" }
    inst.scrapbook_deps = { "meat", "deer_antler1", "deer_antler2", "deer_antler3"}
    inst.scrapbook_anim = "idle"


    inst.gem = gem

    ------------------------------------------

    inst:AddComponent("timer")
    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(gem ~= nil and TUNING.DEER_GEMMED_HEALTH or TUNING.DEER_HEALTH)
    inst.components.health.fire_damage_scale = gem == "red" and 0 or 1

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(gem ~= nil and TUNING.DEER_GEMMED_DAMAGE or TUNING.DEER_DAMAGE)
    inst.components.combat.hiteffectsymbol = "deer_torso"
    inst.components.combat:SetRange(TUNING.DEER_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.DEER_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve/creatures/together/deer/hit")
    if gem ~= nil then
        inst.components.combat:SetRetargetFunction(3, GemmedRetargetFn)
        inst:ListenForEvent("attacked", GemmedOnAttacked)
        SetEngaged(inst, false)
    else
        inst:ListenForEvent("attacked", OnAttacked)
    end

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    if gem ~= nil then
        inst.components.sleeper:SetSleepTest(GemmedShouldSleep)
        inst.components.sleeper:SetWakeTest(GemmedShouldWake)
        inst.components.sleeper.diminishingreturns = true
        inst.components.sleeper.testperiod = 1
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('deer')

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.DEER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.DEER_RUN_SPEED

    if gem ~= "red" then
        MakeMediumBurnableCharacter(inst, "deer_torso")
        inst.components.burnable:SetBurnTime(TUNING.DEER_ICE_BURN_PANIC_TIME)
    end
    if gem ~= "blue" then
        MakeMediumFreezableCharacter(inst, "deer_torso")
        inst.components.freezable:SetResistance(1)
        inst.components.freezable:SetDefaultWearOffTime(TUNING.DEER_FIRE_FREEZE_WEAR_OFF_TIME)
        --NOTE: no diminishing returns
    end
    MakeHauntablePanic(inst)

    ------------------------------------------

    SetupSounds(inst)
    inst:SetStateGraph("SGdeer")

    if gem ~= nil then
        inst:AddComponent("entitytracker")

        inst:ListenForEvent("gotcommander", OnGotCommander)
        inst:ListenForEvent("lostcommander", OnLostCommander)

        if gem == "red" then
            inst.castfx = "deer_fire_circle"
            inst.castduration = 4
            inst.castcd = TUNING.DEER_FIRE_CAST_CD
        else
            inst.castfx = "deer_ice_circle"
            inst.castduration = 6
            inst.castcd = TUNING.DEER_ICE_CAST_CD
        end

        inst.SetEngaged = SetEngaged
        inst.FindCastTargets = FindCastTargets
        inst.DoCast = DoCast
        inst.OnLoadPostPass = GemmedOnLoadPostPass
        inst.OnUpdateOffset = OnUpdateOffset

        inst:SetBrain(brain_gemmed)
    else
        inst:AddComponent("saltlicker")
        inst.components.saltlicker:SetUp(TUNING.SALTLICK_DEER_USES)

        inst:ListenForEvent("queuegrowantler", onqueuegrowantler)
        inst:ListenForEvent("timerdone", ontimerdone)
        inst:ListenForEvent("deerherdmigration", ondeerherdmigration)

        inst.ShowAntler = ShowAntler
        inst.SetAntlered = setantlered
        inst.OnSave = onsave
        inst.OnLoad = onload
        inst.OnEntitySleep = nil --WARNING: used for handling deerherdmigration!
        inst.OnEntityWake = nil  --WARNING: used for handling deerherdmigration!

        inst:SetBrain(brain)
    end

    return inst
end

local function fn()
    return common_fn()
end

local function redfn()
    return common_fn("red")
end

local function bluefn()
    return common_fn("blue")
end

local function unshackle_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("deer_unshackle")
    inst.AnimState:SetBuild("deer_build")
    inst.AnimState:PlayAnimation("unshackle_pst")
    inst.AnimState:SetFinalOffset(1)

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.AnimState:OverrideSymbol("swap_neck_collar", "deer_build", "swap_neck_collar_winter")
        inst.AnimState:OverrideSymbol("klaus_deer_chain", "deer_build", "klaus_deer_chain_winter")

        DoBellSound(inst)
    else
        inst.AnimState:Hide("puff")
    end

    DoChainSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/lock_break")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(15 * FRAMES, DoChainSound)

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst:DoTaskInTime(14 * FRAMES, DoBellSound)
        inst:DoTaskInTime(16 * FRAMES, DoBellIdleSound)
    end

    inst:DoTaskInTime(2, ErodeAway)

    return inst
end

local function growantler_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("deer_unshackle")
    inst.AnimState:SetBuild("deer_build")
    inst.AnimState:PlayAnimation("growantler_pst")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(2, ErodeAway)

    return inst
end

return Prefab("deer", fn, assets, prefabs),
    Prefab("deer_red", redfn, assets, redprefabs),
    Prefab("deer_blue", bluefn, assets, blueprefabs),
    Prefab("deer_unshackle_fx", unshackle_fn, unshackle_assets),
    Prefab("deer_growantler_fx", growantler_fn, unshackle_assets)
