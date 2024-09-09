require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/antlion_build.zip"),
    Asset("ANIM", "anim/antlion_basic.zip"),
    Asset("ANIM", "anim/antlion_action.zip"),
    Asset("ANIM", "anim/sand_splash_fx.zip"),
}

local prefabs =
{
    "antlion_sinkhole",
    "townportal_blueprint",
    "townportaltalisman",
    "sandspike",
    "sandblock",
    "antlionhat",

    --loot
    "meat",
    "rocks",
    "trinket_1",
    "trinket_3",
    "trinket_8",
    "trinket_9",
    "antliontrinket",
	"chesspiece_antlion_sketch",

	"turf_cotl_gold",
	"turf_cotl_brick",
	"cotl_tabernacle_level1",
}

SetSharedLootTable('antlion',
{
    {'townportal_blueprint',    1.00},
	{'chesspiece_antlion_sketch', 1.00},
    {"antlionhat_blueprint", 1.00},

    {'townportaltalisman',  1.00},
    {'townportaltalisman',  1.00},
    {'townportaltalisman',  1.00},
    {'townportaltalisman',  1.00},
    {'townportaltalisman',  1.00},
    {'townportaltalisman',  1.00},
    {'townportaltalisman',  0.50},
    {'townportaltalisman',  0.50},

    {'meat',                1.00},
    {'meat',                1.00},
    {'meat',                1.00},
    {'meat',                1.00},

    {'rocks',               1.00},
    {'rocks',               1.00},
    {'rocks',               0.50},
    {'rocks',               0.50},
})

local ANTLION_RAGE_TIMER = "rage"

--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer == nil then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "antlion" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
        inst._playingmusic = false
    end
end

local function OnIsFightingDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if not inst._isfighting:value() then
            if inst._musictask ~= nil then
                inst._musictask:Cancel()
                inst._musictask = nil
            end
            inst._playingmusic = false
        elseif inst._musictask == nil then
            inst._musictask = inst:DoPeriodicTask(1, PushMusic)
            PushMusic(inst)
        end
    end
end

local function SetFighting(inst, fighting)
    if inst._isfighting:value() ~= fighting then
        inst._isfighting:set(fighting)
        OnIsFightingDirty(inst)
    end
end

--------------------------------------------------------------------------

local function Despawn(inst)
    if inst.persists then
        inst.persists = false
        if inst:IsAsleep() then
            inst:Remove()
        else
            inst.components.sinkholespawner:StopSinkholes()
            inst:PushEvent("antlion_leaveworld")
        end
    end
end

local function AcceptTest(inst, item)
    return (not (inst:HasRewardToGive() or inst.sg.mem.wantstofightdata ~= nil))
		and (item.components.tradable.rocktribute ~= nil)
        and (item.components.tradable.rocktribute > 0)
end

local function OnGivenItem(inst, giver, item)
    if item.currentTempRange ~= nil then
        -- NOTES(JBK): currentTempRange is only on heatrock and now dumbbell_heat no need to check prefab here.
        local trigger =
            (item.currentTempRange <= 1 and "freeze") or
            (item.currentTempRange >= 4 and "burn") or
            nil
        if trigger ~= nil then
            inst:PushEvent("onacceptfighttribute", { tributer = giver, trigger = trigger })
            return
        end
    end

    inst.tributer = giver
    inst.pendingrewarditem =
        (item.prefab == "antliontrinket" and {"townportal_blueprint", "antlionhat_blueprint"}) or
		(item.prefab == "cotl_trinket" and {"turf_cotl_brick_blueprint", "turf_cotl_gold_blueprint", "cotl_tabernacle_level1_blueprint"}) or
        (item.components.tradable.goldvalue > 0 and "townportaltalisman") or
        nil

    local rage_calming = item.components.tradable.rocktribute * TUNING.ANTLION_TRIBUTE_TO_RAGE_TIME
    inst.maxragetime = math.min(inst.maxragetime + rage_calming, TUNING.ANTLION_RAGE_TIME_MAX)

    local timeleft = inst.components.worldsettingstimer:GetTimeLeft(ANTLION_RAGE_TIMER)
    if timeleft ~= nil then
        timeleft = math.min(timeleft + rage_calming, TUNING.ANTLION_RAGE_TIME_MAX)
        inst.components.worldsettingstimer:SetTimeLeft(ANTLION_RAGE_TIMER, timeleft)
        inst.components.worldsettingstimer:ResumeTimer(ANTLION_RAGE_TIMER)
    else
        inst.components.worldsettingstimer:StartTimer(ANTLION_RAGE_TIMER, inst.maxragetime)
    end
    inst.components.sinkholespawner:StopSinkholes()

    inst:PushEvent("onaccepttribute", { tributepercent = (timeleft or 0) / TUNING.ANTLION_RAGE_TIME_MAX })

    if giver ~= nil and giver.components.talker ~= nil and GetTime() - (inst.timesincelasttalker or -TUNING.ANTLION_TRIBUTER_TALKER_TIME) > TUNING.ANTLION_TRIBUTER_TALKER_TIME then
        inst.timesincelasttalker = GetTime()
        giver.components.talker:Say(GetString(giver, "ANNOUNCE_ANTLION_TRIBUTE"))
    end
end

local function OnRefuseItem(inst, giver, item)
    inst:PushEvent("onrefusetribute")
end

local function ontimerdone(inst, data)
    if data.name == ANTLION_RAGE_TIMER then
        inst.components.sinkholespawner:StartSinkholes()

        inst.maxragetime = math.max(inst.maxragetime * TUNING.ANTLION_RAGE_TIME_FAILURE_SCALE, TUNING.ANTLION_RAGE_TIME_MIN)
        inst.components.worldsettingstimer:StartTimer(ANTLION_RAGE_TIMER, inst.maxragetime)
    end
end

local function HasRewardToGive(inst)
    return inst.pendingrewarditem ~= nil
end

local function GiveReward(inst)
	if inst.pendingrewarditem ~= nil then
		if type(inst.pendingrewarditem) == "table" then
			for _, item in ipairs(inst.pendingrewarditem) do
			    LaunchAt(SpawnPrefab(item), inst, (inst.tributer ~= nil and inst.tributer:IsValid()) and inst.tributer or nil, 1, 2, 1)
			end
		else
		    LaunchAt(SpawnPrefab(inst.pendingrewarditem), inst, (inst.tributer ~= nil and inst.tributer:IsValid()) and inst.tributer or nil, 1, 2, 1)
		end
	end
    inst.pendingrewarditem = nil
    inst.tributer = nil
end

local function GetRageLevel(inst)
    local ragetimepercent = (inst.components.worldsettingstimer:GetTimeLeft(ANTLION_RAGE_TIMER) or 0) / TUNING.ANTLION_RAGE_TIME_MAX
    return (ragetimepercent <= TUNING.ANTLION_RAGE_TIME_UNHAPPY_PERCENT and 3) or
           (ragetimepercent <= TUNING.ANTLION_RAGE_TIME_HAPPY_PERCENT and 2) or
           1
end

local function getstatus(inst)
    if inst.components.combat ~= nil then
        return "UNHAPPY"
    end
    local level = GetRageLevel(inst)
    return (level == 1 and "VERYHAPPY") or
           (level == 3 and "UNHAPPY") or
           nil
end

local function OnInit(inst)
    inst.inittask = nil
    inst.onsandstormchanged = function(src, data)
        if data.stormtype == STORM_TYPES.SANDSTORM and not data.setting then
            Despawn(inst)
        end
    end
    inst:ListenForEvent("ms_stormchanged", inst.onsandstormchanged, TheWorld)
    if not (TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive()) then
        Despawn(inst)
    end
end

--------------------------------------------------------------------------

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

--------------------------------------------------------------------------

local brain = require("brains/antlionbrain")

local function RetargetFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local newplayer--[[, distsq]] = FindClosestPlayerInRange(x, y, z, TUNING.ANTLION_CAST_RANGE, true)
    return newplayer, true
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and inst:IsNear(target, TUNING.ANTLION_CAST_RANGE)
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil and data.attacker:IsNear(inst, TUNING.ANTLION_CAST_RANGE) then
        local target = inst.components.combat.target
        if not (target ~= nil and
                target:IsNear(inst, TUNING.ANTLION_CAST_RANGE) and
                target.components.combat:IsRecentTarget(inst) and
                (target.components.combat.laststartattacktime or 0) + 3 >= GetTime()) then
            inst.components.combat:SetTarget(data.attacker)
        end
    end
end

local function DoHealTick(inst)
    inst.components.health:DoDelta(TUNING.ANTLION_EAT_HEALING)
    if not inst.components.health:IsHurt() then
        inst.sleeptask:Cancel()
        inst.sleeptask = inst:DoTaskInTime(10, inst.StopCombat)
    end
end

local function OnEntitySleep(inst)
    if inst.sleeptask == nil then
        inst.sleeptask =
            inst.components.health:IsHurt() and
            inst:DoPeriodicTask(2, DoHealTick) or
            inst:DoTaskInTime(5, inst.StopCombat)
    end
end

local function OnEntityWake(inst)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end
end

local function StartCombat(inst, target, trigger)
    SetFighting(inst, true)

    if inst.persists and inst.components.combat == nil then
        if inst.inittask ~= nil then
            inst.inittask:Cancel()
            inst.inittask = nil
        else
            inst:RemoveEventCallback("ms_stormchanged", inst.onsandstormchanged, TheWorld)
            inst.onsandstormchanged = nil
        end

        inst:AddComponent("combat")
        inst.components.combat:SetAttackPeriod(TUNING.ANTLION_MAX_ATTACK_PERIOD)
        inst.components.combat:SetRange(TUNING.ANTLION_CAST_RANGE)
        inst.components.combat:SetRetargetFunction(3, RetargetFn)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        inst.components.combat.hiteffectsymbol = "body"

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.ANTLION_HEALTH)
        inst.components.health.nofadeout = true

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

        MakeLargeBurnableCharacter(inst, "body")

        inst:SetStateGraph("SGantlion_angry")

        --After loading, replacing an empty brain with a new
        --one doesn't automatically restart itself properly.
        inst:StopBrain()
        inst:SetBrain(brain)
        inst:RestartBrain()

        inst:AddTag("scarytoprey")
        inst:AddTag("hostile")

        inst.components.trader:Disable()
        inst.components.worldsettingstimer:PauseTimer(ANTLION_RAGE_TIMER)
        inst.components.sinkholespawner:StopSinkholes()

        inst:ListenForEvent("attacked", OnAttacked)

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
        if inst:IsAsleep() then
            OnEntitySleep(inst)
        end

        if target ~= nil then
            if inst.components.combat:CanTarget(target) and inst:IsNear(target, TUNING.ANTLION_CAST_RANGE) then
                inst.components.combat:SetTarget(target)
            end
            if trigger == "freeze" then
                inst.components.freezable:AddColdness(inst.components.freezable:ResolveResistance(), 3)
            else
                if trigger == "burn" then
                    inst.components.burnable:Ignite()
                end
                inst.components.combat:BattleCry()
            end
        end
    end
end

local function StopCombat(inst)
    SetFighting(inst, false)

    if inst.persists and inst.components.combat ~= nil then
        OnEntityWake(inst)
        inst.OnEntityWake = nil
        inst.OnEntitySleep = nil

        inst:RemoveEventCallback("attacked", OnAttacked)

        inst.components.worldsettingstimer:StopTimer("wall_cd")

        local prevragetime = inst.components.worldsettingstimer:GetTimeLeft(ANTLION_RAGE_TIMER)
        inst.maxragetime = TUNING.ANTLION_RAGE_TIME_MIN
        inst.components.worldsettingstimer:StopTimer(ANTLION_RAGE_TIMER)
        inst.components.worldsettingstimer:StartTimer(ANTLION_RAGE_TIMER, math.min(prevragetime, inst.maxragetime))

        inst.components.trader:Enable()

        inst:RemoveTag("hostile")
        inst:RemoveTag("scarytoprey")

        inst:SetBrain(nil)
        inst:SetStateGraph("SGantlion")

        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("sanityaura")
        inst:RemoveComponent("health")
        inst:RemoveComponent("combat")

        OnInit(inst)

        if inst.persists and not inst:IsAsleep() then
            inst.sg:GoToState("refusetribute")
        end
    end
end

local function OnPreLoad(inst, data)--, newents)
    if data.health ~= nil then
        StartCombat(inst)
    end

    WorldSettings_Timer_PreLoad(inst, data, ANTLION_RAGE_TIMER, TUNING.ANTLION_RAGE_TIME_MAX)
    WorldSettings_Timer_PreLoad_Fix(inst, data, ANTLION_RAGE_TIMER, 1)
end

local function OnLoad(inst)
    inst.components.worldsettingstimer:StopTimer("wall_cd")
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("antlion")
    inst.AnimState:SetBuild("antlion_build")
    inst.AnimState:OverrideSymbol("sand_splash", "sand_splash_fx", "sand_splash")
    inst.AnimState:PlayAnimation("idle", true)

    inst.MiniMapEntity:SetIcon("antlion.png")
    inst.MiniMapEntity:SetPriority(1)

    MakeObstaclePhysics(inst, 1.5)

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("antlion")
    inst:AddTag("largecreature")
    inst:AddTag("antlion_sinkhole_blocker")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    --Sneak these into pristine state for optimization
    inst:AddTag("__health")
    inst:AddTag("__combat")

    inst._isfighting = net_bool(inst.GUID, "antlion._isfighting", "isfightingdirty")
    inst._playingmusic = false
    inst._musictask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("isfightingdirty", OnIsFightingDirty)

        return inst
    end

    inst.scrapbook_maxhealth  = TUNING.ANTLION_HEALTH
    inst.scrapbook_sanityaura = -TUNING.SANITYAURA_MED

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("__health")
    inst:RemoveTag("__combat")

    inst:PrereplicateComponent("health")
    inst:PrereplicateComponent("combat")

    inst.maxragetime = TUNING.ANTLION_RAGE_TIME_INITIAL

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGivenItem
    inst.components.trader.onrefuse = OnRefuseItem

    inst:AddComponent("worldsettingstimer")
    inst:ListenForEvent("timerdone", ontimerdone)
    inst.components.worldsettingstimer:AddTimer("wall_cd", TUNING.ANTLION_WALL_CD, true)
    inst.components.worldsettingstimer:AddTimer(ANTLION_RAGE_TIMER, TUNING.ANTLION_RAGE_TIME_MAX, TUNING.ANTLION_TRIBUTE)
    inst.components.worldsettingstimer:StartTimer(ANTLION_RAGE_TIMER, TUNING.ANTLION_RAGE_TIME_INITIAL)

    inst:AddComponent("sinkholespawner")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("antlion")
    inst.components.lootdropper:AddRandomLoot("trinket_1", 2)
    inst.components.lootdropper:AddRandomLoot("trinket_3", 2)
    inst.components.lootdropper:AddRandomLoot("trinket_8", 2)
    inst.components.lootdropper:AddRandomLoot("trinket_9", 2)
    inst.components.lootdropper:AddRandomLoot("antliontrinket", 1)
    inst.components.lootdropper.numrandomloot = 2

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper.diminishingreturns = true

    MakeHugeFreezableCharacter(inst, "body")
    inst.components.freezable.diminishingreturns = true

    inst.GiveReward = GiveReward
    inst.HasRewardToGive = HasRewardToGive
    inst.GetRageLevel = GetRageLevel

    inst.StartCombat = StartCombat
    inst.StopCombat = StopCombat
    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad

    inst:SetStateGraph("SGantlion")

    inst.inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab("antlion", fn, assets, prefabs)
