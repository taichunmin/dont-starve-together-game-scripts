local assets =
{
    Asset("ANIM", "anim/bat_basic.zip"),
    Asset("SOUND", "sound/bat.fsb"),
}

local prefabs =
{
    "guano",
    "batwing",
    "teamleader",
}

local brain = require "brains/batbrain"

SetSharedLootTable("bat",
{
    {"batwing",    0.25},
    {"guano",      0.15},
    {"monstermeat",0.10},
})
SetSharedLootTable("bat_acidinfused",
{
    {"batwing",    0.5},
    {"guano",      0.3},
    {"monstermeat",0.2},
    {"nitre",      0.2},
})

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function MakeTeam(inst, attacker)
    local leader = SpawnPrefab("teamleader")
    leader.components.teamleader:SetUp(attacker, inst)
    leader.components.teamleader:BroadcastDistress(inst)
end

local RETARGET_CANT_TAGS = {"bat"}
local RETARGET_ONEOF_TAGS = {"character", "monster"}
local function Retarget(inst)
    local ta = inst.components.teamattacker

    local newtarget = FindEntity(inst, TUNING.BAT_TARGET_DIST, function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        nil,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS
    )

    if newtarget and not ta.inteam and not ta:SearchForTeam() then
        MakeTeam(inst, newtarget)
    end

    if ta.inteam and not ta.teamleader:CanAttack() then
        return newtarget
    end
end

local function KeepTarget(inst, target)
    return (inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack())
        or inst.components.teamattacker.orders == ORDERS.ATTACK
end

local function IsBat(dude)
	return dude:HasTag("bat")
end

local function OnAttacked(inst, data)
	local attacker = data and data.attacker or nil
	if attacker == nil then
		return
	end

    if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
        MakeTeam(inst, data.attacker)
    elseif inst.components.teamattacker.teamleader then
        inst.components.teamattacker.teamleader:BroadcastDistress(inst)   --Ask for  help!
    end

    if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
        inst.components.combat:SetTarget(attacker)
		inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsBat, MAX_TARGET_SHARES)
    end
end

local function OnSleepGoHome(inst)
    inst._hometask = nil
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home ~= nil and home:IsValid() and home.components.childspawner ~= nil then
        home.components.childspawner:GoHome(inst)
    end
end

local function OnIsDay(inst, isday)
    if isday then
        if inst._hometask == nil then
            inst._hometask = inst:DoTaskInTime(10 + math.random(), OnSleepGoHome)
        end
    elseif inst._hometask ~= nil then
        inst._hometask:Cancel()
        inst._hometask = nil
    end
end

local function StopWatchingDay(inst)
    inst:StopWatchingWorldState("isday", OnIsDay)
    if inst._hometask ~= nil then
        inst._hometask:Cancel()
        inst._hometask = nil
    end
end

local function StartWatchingDay(inst)
    inst:WatchWorldState("isday", OnIsDay)
    OnIsDay(inst, TheWorld.state.isday)
end

local function OnEntitySleep(inst)
    inst:ListenForEvent("enterlimbo", StopWatchingDay)
    inst:ListenForEvent("exitlimbo", StartWatchingDay)
    if not inst:IsInLimbo() then
        StartWatchingDay(inst)
    end
end

local function OnEntityWake(inst)
    inst:RemoveEventCallback("enterlimbo", StopWatchingDay)
    inst:RemoveEventCallback("exitlimbo", StartWatchingDay)
    if not inst:IsInLimbo() then
        StopWatchingDay(inst)
    end
end

local function OnPreLoad(inst, data)
	local x, y, z = inst.Transform:GetWorldPosition()
	if y > 0 then
		inst.Transform:SetPosition(x, 0, z)
	end
end

local function BatSleepTest(inst, ...)
    if inst.components.acidinfusible ~= nil and inst.components.acidinfusible:IsInfused() then
        return false
    end
    return NocturnalSleepTest(inst, ...)
end

local function OnInfuse(inst)
    inst.AnimState:SetSymbolAddColour("bat_eye", .2, .5, 0, 0)
    inst.AnimState:SetSymbolLightOverride("bat_eye", .5)

    inst.components.lootdropper:SetChanceLootTable("bat_acidinfused")

    inst.components.combat:SetRetargetFunction(1, Retarget)

    inst.components.eater:SetCanEatNitre(true)

    if inst.components.thief == nil then
        inst:AddComponent("thief")
    end
end

local function OnUninfuse(inst)
    inst.AnimState:SetSymbolAddColour("bat_eye", 0, 0, 0, 0)
    inst.AnimState:SetSymbolLightOverride("bat_eye", 0)

    inst.components.lootdropper:SetChanceLootTable("bat")

    inst.components.combat:SetRetargetFunction(3, Retarget)

    inst.components.eater:SetCanEatNitre(false)

    if inst.components.thief ~= nil then
        inst:RemoveComponent("thief")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeGhostPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(1.5, .75)

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(.75, .75, .75)

    inst.AnimState:SetBank("bat")
    inst.AnimState:SetBuild("bat_basic")

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("bat")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_scale = 0.75

    local locomotor = inst:AddComponent("locomotor")
    locomotor:EnableGroundSpeedMultiplier(false)
    locomotor:SetTriggersCreep(false)
    locomotor.walkspeed = TUNING.BAT_WALK_SPEED
    locomotor.pathcaps = { allowocean = true }

    inst:SetStateGraph("SGbat")
    inst:SetBrain(brain)

    local eater = inst:AddComponent("eater")
    eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    eater:SetStrongStomach(true)

    local sleeper = inst:AddComponent("sleeper")
    sleeper:SetResistance(3)
    sleeper.sleeptestfn = BatSleepTest
    sleeper.waketestfn = NocturnalWakeTest

    local combat = inst:AddComponent("combat")
    combat.hiteffectsymbol = "bat_body"
    combat:SetDefaultDamage(TUNING.BAT_DAMAGE)
    combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)
    combat:SetRange(TUNING.BAT_ATTACK_DIST)
    combat:SetRetargetFunction(3, Retarget)
    combat:SetKeepTargetFunction(KeepTarget)

    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.BAT_HEALTH)

    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("bat")

    inst:AddComponent("inventory")

    local periodicspawner = inst:AddComponent("periodicspawner")
    periodicspawner:SetPrefab("guano")
    periodicspawner:SetRandomTimes(120,240)
    periodicspawner:SetDensityInRange(30, 2)
    periodicspawner:SetMinimumSpacing(8)
    periodicspawner:Start()

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    MakeMediumBurnableCharacter(inst, "bat_body")
    MakeMediumFreezableCharacter(inst, "bat_body")

    local teamattacker = inst:AddComponent("teamattacker")
    teamattacker.team_type = "bat"

    inst:ListenForEvent("attacked", OnAttacked)

    local acidinfusible = inst:AddComponent("acidinfusible")
    acidinfusible:SetFXLevel(3)
    acidinfusible:SetDamageMultiplier(TUNING.ACIDRAIN_BAT_DAMAGE_MULT)
    acidinfusible:SetSpeedMultiplier(TUNING.ACIDRAIN_BAT_SPEED_MULT)
    acidinfusible:SetOnInfuseFn(OnInfuse)
    acidinfusible:SetOnUninfuseFn(OnUninfuse)

    MakeHauntablePanic(inst)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("bat", fn, assets, prefabs)
