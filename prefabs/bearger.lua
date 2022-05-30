local assets =
{
    Asset("ANIM", "anim/bearger_build.zip"),
    Asset("ANIM", "anim/bearger_basic.zip"),
    Asset("ANIM", "anim/bearger_actions.zip"),
    Asset("ANIM", "anim/bearger_yule.zip"),
    Asset("SOUND", "sound/bearger.fsb"),
}

local prefabs =
{
    "groundpound_fx",
    "groundpoundring_fx",
    "bearger_fur",
    "furtuft",
    "meat",
    "chesspiece_bearger_sketch",
    "collapse_small",
}

local brain = require("brains/beargerbrain")

SetSharedLootTable( 'bearger',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'bearger_fur',      1.00},
    {'chesspiece_bearger_sketch', 1.00},
})

local TARGET_DIST = 7.5

local function CalcSanityAura(inst, observer)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_HUGE or -TUNING.SANITYAURA_LARGE
end

local function HoneyedItem(item)
    return item:HasTag("honeyed")
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_INV_MUST_TAGS = { "_combat", "_inventory" }
local RETARGET_CANT_TAGS = { "prey", "smallcreature", "INLIMBO" }

local function RetargetFn(inst)
    return not inst.components.sleeper:IsAsleep()
        and (   FindEntity(
                    inst,
                    TARGET_DIST,
                    function(guy)
                        return guy.components.combat.target == inst
                            and inst.components.combat:CanTarget(guy)
                    end,
                    RETARGET_MUST_TAGS, --see entityreplica.lua
                    RETARGET_CANT_TAGS
                ) or
                (   inst.last_eat_time ~= nil and
                    GetTime() - inst.last_eat_time > TUNING.BEARGER_DISGRUNTLE_TIME and
                    FindEntity(
                        inst,
                        TARGET_DIST * 5,
                        function(guy)
                            return guy.components.inventory:FindItem(HoneyedItem) ~= nil
                                and inst.components.combat:CanTarget(guy)
                        end,
                        RETARGET_INV_MUST_TAGS, --see entityreplica.lua
                        RETARGET_CANT_TAGS
                    )
                )
            )
        or nil
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnSave(inst, data)
    data.seenbase = inst.seenbase or nil-- from brain
    data.cangroundpound = inst.cangroundpound
    data.num_food_cherrypicked = inst.num_food_cherrypicked
    data.num_good_food_eaten = inst.num_good_food_eaten
    data.killedplayer = inst.killedplayer
    data.shouldgoaway = inst.shouldgoaway
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.seenbase = data.seenbase or nil-- for brain
        inst.cangroundpound = data.cangroundpound
        inst.num_food_cherrypicked = data.num_food_cherrypicked or 0
        inst.num_good_food_eaten = data.num_good_food_eaten or 0
        inst.killedplayer = data.killedplayer or false
        inst.shouldgoaway = data.shouldgoaway or false
    end
end

local function IsHibernationSeason(season)
    return season == "winter" or season == "spring"
end

local function OnSeasonChange(inst, season)
    if IsHibernationSeason(season) then
        inst:AddTag("hibernation")
    else
        inst:RemoveTag("hibernation")
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function OnDestroyOther(inst, other)
    if other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        if other.components.lootdropper ~= nil and (other:HasTag("tree") or other:HasTag("boulder")) then
            other.components.lootdropper:SetLoot({})
        end
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    end
end

local function OnCollide(inst, other)
    if other ~= nil and
        other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.NET and
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 and
        not inst.recentlycharged[other] then
        inst:DoTaskInTime(2 * FRAMES, OnDestroyOther, other)
    end
end

local WORKABLES_CANT_TAGS = { "insect", "INLIMBO" }
local WORKABLES_ONEOF_TAGS = { "CHOP_workable", "DIG_workable", "HAMMER_workable", "MINE_workable" }
local function WorkEntities(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local heading_angle = inst.Transform:GetRotation() * DEGREES
    local x1, z1 = math.cos(heading_angle), -math.sin(heading_angle)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, 5, nil, WORKABLES_CANT_TAGS, WORKABLES_ONEOF_TAGS)) do
        local x2, y2, z2 = v.Transform:GetWorldPosition()
        local dx, dz = x2 - x, z2 - z
        local len = math.sqrt(dx * dx + dz * dz)
        --Normalized, then Dot product
        if len <= 0 or x1 * dx / len + z1 * dz / len > .3 then
            v.components.workable:Destroy(inst)
        end
    end
end

local function LaunchItem(inst, target, item)
    if item.Physics ~= nil and item.Physics:IsActive() then
        local x, y, z = item.Transform:GetWorldPosition()
        item.Physics:Teleport(x, .1, z)

        x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local angle = math.atan2(z1 - z, x1 - x) + (math.random() * 20 - 10) * DEGREES
        local speed = 5 + math.random() * 2
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
    end
end

local function OnGroundPound(inst)
    if math.random() < .2 then
        inst.components.shedder:DoMultiShed(3, false) -- can't drop too many, or it'll be really easy to farm for thick furs
    end
end

local function OnHitOther(inst, data)
    if data.target ~= nil and data.target.components.inventory ~= nil and not data.target:HasTag("stronggrip") then
        local item = data.target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil then
            data.target.components.inventory:DropItem(item)
            LaunchItem(inst, data.target, item)
        end
    end
end

local function ontimerdone(inst, data)
    if data.name == "GroundPound" then
        inst.cangroundpound = true
    elseif data.name == "Yawn" and inst:HasTag("hibernation") then
        inst.canyawn = true
    end
end

local function ShouldSleep(inst)
    -- don't fall asleep if we have a target, we were either chasing it, or it woke us up
    -- don't fall asleep while on fire
    if not (inst.components.combat:HasTarget() or
            inst.components.health.takingfiredamage) and
        IsHibernationSeason(TheWorld.state.season) then
        --Start hibernating
        inst.components.shedder:StopShedding()
        inst:AddTag("hibernation")
        inst:AddTag("asleep")
        inst.AnimState:OverrideSymbol("bearger_head", IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "bearger_yule" or "bearger_build", "bearger_head_groggy")
        return true
    end
    return false
end

local function ShouldWake(inst)
    if not IsHibernationSeason(TheWorld.state.season) then
        inst.components.shedder:StartShedding(TUNING.BEARGER_SHED_INTERVAL)
        inst:RemoveTag("hibernation")
        inst:RemoveTag("asleep")
        inst.AnimState:ClearOverrideSymbol("bearger_head")
        return true
    end
    return false
end

local function OnDroppedTarget(inst, data)
    if data.target ~= nil then
        inst:RemoveEventCallback("dropitem", inst._OnTargetDropItem, data.target)
    end
    inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
end

local function OnCombatTarget(inst, data)
    --Listen for dropping of items... if it's food, maybe forgive your target?
    if data.oldtarget ~= nil then
        inst:RemoveEventCallback("dropitem", inst._OnTargetDropItem, data.oldtarget)
    end
    if data.target ~= nil then
        inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
        inst.components.locomotor.walkspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
        inst:ListenForEvent("dropitem", inst._OnTargetDropItem, data.target)
    else
        inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
    end
end

local function SetStandState(inst, state)
    --"quad" or "bi" state
    inst.StandState = string.lower(state)
end

local function IsStandState(inst, state)
    return inst.StandState == string.lower(state)
end

local function OnDead(inst)
    AwardRadialAchievement("bearger_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
    inst.components.shedder:StopShedding()
    TheWorld:PushEvent("beargerkilled", inst)
end

local function OnRemove(inst)
    TheWorld:PushEvent("beargerremoved", inst)
end

local function OnPlayerAction(inst, player, data)
    if data.action == nil or inst.components.sleeper:IsAsleep() then
        return -- don't react to things when asleep
    end

    local selfAction = inst:GetBufferedAction()
    if selfAction == nil or selfAction.target ~= data.action.target then
        --You're not doing anything, or not doing the same thing as the player
        return
    end

    -- We got a problem bud. (targeting the same thing for action)
    inst.num_food_cherrypicked = inst.num_food_cherrypicked + 1
    if inst.num_food_cherrypicked < TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO then
        inst.sg:GoToState("targetstolen")
    else
        inst.num_food_cherrypicked = TUNING.BEARGER_STOLEN_TARGETS_FOR_AGRO - 1
        inst.components.combat:SuggestTarget(player)
    end
end

--[[ PLAYER TRACKING ]]

local function OnPlayerJoined(inst, player)
    for i, v in ipairs(inst._activeplayers) do
        if v == player then
            return
        end
    end

    inst:ListenForEvent("performaction", inst._OnPlayerAction, player)
    table.insert(inst._activeplayers, player)
end

local function OnPlayerLeft(inst, player)
    for i, v in ipairs(inst._activeplayers) do
        if v == player then
            inst:RemoveEventCallback("performaction", inst._OnPlayerAction, player)
            table.remove(inst._activeplayers, i)
            return
        end
    end
end

--[[ END PLAYER TRACKING ]]

local function OnWakeUp(inst)
    inst.homelocation = inst:GetPosition()
end

local function OnKilledOther(inst, data)
    if data ~= nil and data.victim ~= nil then
        if data.victim:HasTag("player") then
            inst.killedplayer = true
        end
        if data.victim == inst.components.combat.target then
            inst:RemoveEventCallback("dropitem", inst._OnTargetDropItem, data.victim)
            inst.components.combat.target = nil
            inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(6, 3.5)

    MakeGiantCharacterPhysics(inst, 1000, 1.5)

    inst.AnimState:SetBank("bearger")
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "bearger_yule" or "bearger_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    ------------------------------------------

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("bearger")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(OnCollide)

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEARGER_HEALTH)
    inst.components.health.destroytime = 5

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BEARGER_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.BEARGER_MELEE_RANGE)
    inst.components.combat:SetAreaDamage(6, 0.8)
    inst.components.combat.hiteffectsymbol = "bearger_body"
    inst.components.combat:SetAttackPeriod(TUNING.BEARGER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")

    ------------------------------------------

    inst:AddComponent("explosiveresist")

    ------------------------------------------

    inst:AddComponent("shedder")
    inst.components.shedder.shedItemPrefab = "furtuft"
    inst.components.shedder.shedHeight = 6.5
    inst.components.shedder:StartShedding(TUNING.BEARGER_SHED_INTERVAL)

    ------------------------------------------

    inst.shouldgoaway = false
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst:ListenForEvent("onwakeup", OnWakeUp)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("bearger")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("thief")
    inst:AddComponent("inventory")
    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 2
    inst.components.groundpounder.platformPushingRings = 2
    inst.components.groundpounder.numRings = 3
    inst.components.groundpounder.groundpoundFn = OnGroundPound
    inst:AddComponent("timer")
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.BEARGER }, { FOODGROUP.BEARGER })
    inst.components.eater.eatwholestack = true

    ------------------------------------------

    inst:WatchWorldState("season", OnSeasonChange)
    OnSeasonChange(inst, TheWorld.state.season)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)

    ------------------------------------------

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "bearger_body")

    SetStandState(inst, "quad")--SetStandState(inst, "BI")
    inst.SetStandState = SetStandState
    inst.IsStandState = IsStandState
    inst.seenbase = false
    inst.WorkEntities = WorkEntities
    inst.cangroundpound = false
    inst.killedplayer = false

    inst.num_good_food_eaten = 0
    inst.num_food_cherrypicked = 0

    inst:DoTaskInTime(0, OnWakeUp)

    inst._OnTargetDropItem = function(target, data)
        if inst.components.eater:CanEat(data.item) then
            --print("Bearger saw dropped food, losing target")
            inst.components.combat:SetTarget(nil)
        end
    end

    inst:ListenForEvent("killed", OnKilledOther)
    inst:ListenForEvent("newcombattarget", OnCombatTarget)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    inst.seenbase = nil -- for brain

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
    inst.components.locomotor:SetShouldRun(true)

    inst:SetStateGraph("SGbearger")
    inst:SetBrain(brain)

    --[[ PLAYER TRACKING ]]

    inst._activeplayers = {}
    inst._OnPlayerAction = function(player, data) OnPlayerAction(inst, player, data) end
    inst:ListenForEvent("ms_playerjoined", function(src, player) OnPlayerJoined(inst, player) end, TheWorld)
    inst:ListenForEvent("ms_playerleft", function(src, player) OnPlayerLeft(inst, player) end, TheWorld)

    for i, v in ipairs(AllPlayers) do
        OnPlayerJoined(inst, v)
    end

    --[[ END PLAYER TRACKING ]]

    return inst
end

return Prefab("bearger", fn, assets, prefabs)
