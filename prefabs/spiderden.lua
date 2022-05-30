require("worldsettingsutil")

local prefabs =
{
    "spider",
    "spider_warrior",
    "silk",
    "spidereggsack",
    "spiderqueen",
}

local assets =
{
    Asset("ANIM", "anim/spider_cocoon.zip"),
    Asset("SOUND", "sound/spider.fsb"),
	Asset("MINIMAP_IMAGE", "spiderden_1"),
    Asset("MINIMAP_IMAGE", "spiderden_2"),
    Asset("MINIMAP_IMAGE", "spiderden_3"),
    Asset("MINIMAP_IMAGE", "spiderden_bedazzled"),
}

local ANIM_DATA =
{
    SMALL =
    {
        hit = "cocoon_small_hit",
        hit_combat = "cocoon_small_hit_combat",
        idle = "cocoon_small",
        init = "grow_sac_to_small",
        freeze = "frozen_small",
        thaw = "frozen_loop_pst_small",
        bedazzle = "cocoon_small_bedazzled",
        bedazzle_drop_timing = 15,
    },

    MEDIUM =
    {
        hit = "cocoon_medium_hit",
        hit_combat = "cocoon_medium_hit_combat",
        idle = "cocoon_medium",
        init = "grow_small_to_medium",
        freeze = "frozen_medium",
        thaw = "frozen_loop_pst_medium",
        bedazzle = "cocoon_medium_bedazzled",
        bedazzle_drop_timing = 20,
    },

    LARGE =
    {
        hit = "cocoon_large_hit",
        hit_combat = "cocoon_large_hit_combat",
        idle = "cocoon_large",
        init = "grow_medium_to_large",
        freeze = "frozen_large",
        thaw = "frozen_loop_pst_large",
        bedazzle = "cocoon_large_bedazzled",
        bedazzle_drop_timing = 22,
    },
}

local LOOT_DATA =
{
    SMALL = { "silk", "silk" },
    MEDIUM = { "silk", "silk", "silk", "silk" },
    LARGE = { "silk", "silk", "silk", "silk", "silk", "silk", "spidereggsack" },
}

local function PlaySleepLoopSoundTask(inst, stopfn)
    -- inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

local function temperaturetick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end
end

local function onwake(inst, sleeper, nostatechange)
    inst.AnimState:PlayAnimation("cocoon_enter")
    inst.AnimState:PushAnimation(inst.anims.idle, true)
    inst.SoundEmitter:PlaySound("webber2/common/spiderden/out")
    stopsleepsound(inst)
end

local function onsleep(inst, sleeper)
    inst.AnimState:PlayAnimation("cocoon_enter")
    inst.AnimState:PushAnimation("cocoon_sleep_loop", true)
    inst.SoundEmitter:PlaySound("webber2/common/spiderden/in")
    startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
end

local function AddSleepingBag(inst)
    
    if inst.components.sleepingbag == nil then
        inst:AddComponent("sleepingbag")
    end

    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 1.5
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK * 1.5
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    
    inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)

    inst:AddTag("tent")
end

local function SetStage(inst, stage, skip_anim)
    if stage <= 3 and inst.components.childspawner ~= nil then -- if childspawner doesn't exist, then this den is burning down
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_grow")
        inst.components.childspawner:SetMaxChildren(math.floor(SpringCombatMod(TUNING.SPIDERDEN_SPIDERS[stage])))
        inst.components.childspawner:SetMaxEmergencyChildren(TUNING.SPIDERDEN_EMERGENCY_WARRIORS[stage])
        inst.components.childspawner:SetEmergencyRadius(TUNING.SPIDERDEN_EMERGENCY_RADIUS[stage])
        inst.components.health:SetMaxHealth(TUNING.SPIDERDEN_HEALTH[stage])

        inst.MiniMapEntity:SetIcon("spiderden_" .. tostring(stage) .. ".png")

        if not skip_anim then
            inst.AnimState:PlayAnimation(inst.anims.init)
            inst.AnimState:PushAnimation(inst.anims.idle, true)
        end
    end

    inst.components.upgradeable:SetStage(stage)
    inst.data.stage = stage -- track here, as growable component may go away

    if POPULATING then
        if not inst.loadtask then
            inst.loadtask = inst:DoTaskInTime(0, function()
                if inst:GetCurrentPlatform() == nil then
                    inst.GroundCreepEntity:SetRadius(TUNING.SPIDERDEN_CREEP_RADIUS[inst.data.stage])
                end
                inst.loadtask = nil
            end)
        end
    else
        if inst:GetCurrentPlatform() == nil then
            inst.GroundCreepEntity:SetRadius(TUNING.SPIDERDEN_CREEP_RADIUS[inst.data.stage])
        end
    end
end

local function SetSmall(inst)
    inst.anims = ANIM_DATA.SMALL
    SetStage(inst, 1)
    inst.components.lootdropper:SetLoot(LOOT_DATA.SMALL)

    if inst.components.burnable ~= nil then
        inst.components.burnable:SetFXLevel(3)
        inst.components.burnable:SetBurnTime(20)
    end

    if inst.components.freezable ~= nil then
        inst.components.freezable:SetShatterFXLevel(3)
        inst.components.freezable:SetResistance(2)
    end
end

local function SetMedium(inst)
    inst.anims = ANIM_DATA.MEDIUM
    SetStage(inst, 2)
    inst.components.lootdropper:SetLoot(LOOT_DATA.MEDIUM)

    if inst.components.burnable ~= nil then
        inst.components.burnable:SetFXLevel(3)
        inst.components.burnable:SetBurnTime(20)
    end

    if inst.components.freezable ~= nil then
        inst.components.freezable:SetShatterFXLevel(4)
        inst.components.freezable:SetResistance(3)
    end
end

local function SetLarge(inst)
    inst.anims = ANIM_DATA.LARGE
    SetStage(inst, 3)
    inst.components.lootdropper:SetLoot(LOOT_DATA.LARGE)

    if inst.components.burnable ~= nil then
        inst.components.burnable:SetFXLevel(4)
        inst.components.burnable:SetBurnTime(30)
    end

    if inst.components.freezable ~= nil then
        inst.components.freezable:SetShatterFXLevel(5)
        inst.components.freezable:SetResistance(4)
    end

    AddSleepingBag(inst)
end

local function PlayLegBurstSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/legburst")
end

local function SpawnQueen(inst, should_duplicate)
    local map = TheWorld.Map
    local x, y, z = inst.Transform:GetWorldPosition()
    local offs = FindValidPositionByFan(math.random() * 2 * PI, 1.25, 5, function(offset)
        local x1 = x + offset.x
        local z1 = z + offset.z
        return map:IsPassableAtPoint(x1, 0, z1)
            and not map:IsPointNearHole(Vector3(x1, 0, z1))
    end)

    if offs ~= nil then
        x = x + offs.x
        z = z + offs.z
    end

    local queen = SpawnPrefab("spiderqueen")
    queen.Transform:SetPosition(x, 0, z)
    queen.sg:GoToState("birth")

    if not should_duplicate then
        inst:Remove()
    end
end

local DENCHECK_ONEOF_TAGS = { "spiderden", "spiderqueen" }
local function AttemptMakeQueen(inst)
    if inst.components.growable == nil then
        --failsafe in case we still got here after we are burning
        return
    end

    if not TUNING.SPAWN_SPIDERQUEEN then
        SetLarge(inst)
        return
    end

    if inst.data.stage == nil or inst.data.stage ~= 3 then
        -- we got here directly (probably by loading), so reconfigure to the level 3 state.
        SetLarge(inst)
    end

    if inst:HasTag("bedazzled") then
        return
    end

    if inst.components.sleepingbag and inst.components.sleepingbag:InUse() then
        return
    end

    if not inst:IsNearPlayer(30) then
        inst.components.growable:StartGrowing(60 + math.random(60))
        return
    end

    local check_range = TUNING.SPIDERDEN_QUEEN_RANGE_CHECK
    local cap = TUNING.SPIDERDEN_QUEEN_CAP
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, check_range, nil, nil, DENCHECK_ONEOF_TAGS)
    local num_dens = #ents

    inst.components.growable:SetStage(1)

    inst.AnimState:PlayAnimation("cocoon_large_burst")
    inst.AnimState:PushAnimation("cocoon_large_burst_pst")
    inst.AnimState:PushAnimation("cocoon_small", true)

    PlayLegBurstSound(inst)
    inst:DoTaskInTime(5 * FRAMES, PlayLegBurstSound)
    inst:DoTaskInTime(15 * FRAMES, PlayLegBurstSound)
    inst:DoTaskInTime(35 * FRAMES, SpawnQueen, num_dens < cap)

    inst.components.growable:StartGrowing(60)
    return true
end

local function onspawnspider(inst, spider)
    spider.sg:GoToState("taunt")
    if inst:HasTag("bedazzled") then
        inst.components.bedazzlement:PacifySpiders()
    end
end

local function OnKilled(inst)
    inst.AnimState:PlayAnimation("cocoon_dead")
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
    RemovePhysicsColliders(inst)

    inst.SoundEmitter:KillSound("loop")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_destroy")
    inst.components.lootdropper:DropLoot(inst:GetPosition())
end

local function IsDefender(child)
    return child.prefab == "spider_warrior"
end

local function SpawnDefenders(inst, attacker)
    if not inst.components.health:IsDead() then
        
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")
        inst.AnimState:PlayAnimation(inst.anims.hit_combat)
        inst.AnimState:PushAnimation(inst.anims.idle)
        
        if inst.components.childspawner ~= nil then
            local max_release_per_stage = { 2, 4, 6 }
            local num_to_release = math.min(max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)
            local num_warriors = math.min(num_to_release, TUNING.SPIDERDEN_WARRIORS[inst.data.stage])
            
            num_to_release = math.floor(SpringCombatMod(num_to_release))
            num_warriors = math.floor(SpringCombatMod(num_warriors))
            num_warriors = num_warriors - inst.components.childspawner:CountChildrenOutside(IsDefender)
            
            for k = 1, num_to_release do
                inst.components.childspawner.childname = 
                            (TUNING.SPAWN_SPIDER_WARRIORS and k <= num_warriors and not inst:HasTag("bedazzled")) and 
                            "spider_warrior" or "spider"

                local spider = inst.components.childspawner:SpawnChild()
                if spider ~= nil and attacker ~= nil and spider.components.combat ~= nil then
                    spider.components.combat:SetTarget(attacker)
                    spider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
                end
            end

            inst.components.childspawner.childname = "spider"
            if not inst:HasTag("bedazzled") then
            local emergencyspider = inst.components.childspawner:TrySpawnEmergencyChild()
            if emergencyspider ~= nil then
                emergencyspider.components.combat:SetTarget(attacker)
                emergencyspider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
            end
        end
    end
    end
end

local function OnHit(inst, attacker)
    SpawnDefenders(inst, attacker)
    if inst.components.sleepingbag then
        inst.components.sleepingbag:DoWakeUp()
    end

    if inst:HasTag("bedazzled") then
        -- DANY
        --inst.SoundEmitter:PlaySound("BEDAZZLE STOP SOUND")
        inst:DoTaskInTime(inst.anims.bedazzle_drop_timing * FRAMES, function() inst.components.bedazzlement:Stop() end)
    end
end

local function IsInvestigator(child)
    return child.components.knownlocations:GetLocation("investigate") ~= nil
end

local function SpawnInvestigators(inst, data)
    if not inst.components.health:IsDead() and not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then
        
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
        
        if inst.components.childspawner ~= nil then
            local max_release_per_stage = { 1, 2, 3 }
            local num_to_release = math.min(max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)
            num_to_release = math.floor(SpringCombatMod(num_to_release))
            
            local num_investigators = inst.components.childspawner:CountChildrenOutside(IsInvestigator)
            num_to_release = num_to_release - num_investigators
            
            local targetpos = data ~= nil and data.target ~= nil and data.target:GetPosition() or nil
            
            for k = 1, num_to_release do
                local spider = inst.components.childspawner:SpawnChild()
                if spider ~= nil and targetpos ~= nil then
                    spider.components.knownlocations:RememberLocation("investigate", targetpos)
                end
            end

            if inst:HasTag("bedazzled") then
                inst.components.bedazzlement:PacifySpiders()
            end
        end
    end
end

local function SummonChildren(inst, data)
    if not inst.components.health:IsDead() and not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then
        
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
        
        if inst.components.childspawner ~= nil then
            
            local children_released = inst.components.childspawner:ReleaseAllChildren()

            if children_released then
                for i,v in ipairs(children_released) do
                    v:AddDebuff("spider_summoned_buff", "spider_summoned_buff")
                end
            end

            if inst:HasTag("bedazzled") then
                inst.components.bedazzlement:PacifySpiders()
            end
        end
    end
end

local function StartSpawning(inst)
    if inst.components.childspawner ~= nil and
        not (inst.components.freezable ~= nil and
            inst.components.freezable:IsFrozen()) and
        not TheWorld.state.iscaveday then
        inst.components.childspawner:StartSpawning()
    end
end

local function StopSpawning(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
    end
end

local function OnExtinguish(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spidernest_LP", "loop")
end

local function OnIgnite(inst)
    if inst.components.childspawner ~= nil then
        SpawnDefenders(inst)
    end

    if inst.components.sleepingbag then
        inst.components.sleepingbag:DoWakeUp()
    end

    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnFreeze(inst)
    --print(inst, "OnFreeze")
    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
    inst.AnimState:PlayAnimation(inst.anims.freeze, true)
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

    StopSpawning(inst)

    if inst.components.sleepingbag then
        inst.components.sleepingbag:DoWakeUp()
    end

    if inst.components.growable ~= nil then
        inst.components.growable:Pause()
    end
end

local function OnThaw(inst)
    --print(inst, "OnThaw")
    inst.AnimState:PlayAnimation(inst.anims.thaw, true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function OnUnFreeze(inst)
    --print(inst, "OnUnFreeze")
    inst.AnimState:PlayAnimation(inst.anims.idle, true)
    inst.SoundEmitter:KillSound("thawing")
    inst.AnimState:ClearOverrideSymbol("swap_frozen")

    StartSpawning(inst)

    if inst.components.growable ~= nil then
        inst.components.growable:Resume()
    end
end

local function GetSmallGrowTime(inst)
    return TUNING.SPIDERDEN_GROW_TIME[1] * (1 + math.random())
end

local function GetMedGrowTime(inst)
    return TUNING.SPIDERDEN_GROW_TIME[2] * (1 + math.random())
end

local function GetLargeGrowTime(inst)
    return TUNING.SPIDERDEN_GROW_TIME_QUEEN * (1 + math.random())
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spidernest_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnIsCaveDay(inst, iscaveday)
    if iscaveday then
        StopSpawning(inst)
    else
        StartSpawning(inst)
    end
end

local function OnInit(inst)
    inst:WatchWorldState("iscaveday", OnIsCaveDay)
    OnIsCaveDay(inst, TheWorld.state.iscaveday)
end

local function OnStageAdvance(inst)
   inst.components.growable:DoGrowth()
   return true
end

local function OnUpgrade(inst, upgrade_doer)
   inst.AnimState:PlayAnimation(inst.anims.hit)
   inst.AnimState:PushAnimation(inst.anims.idle)
   inst.SoundEmitter:PlaySound("webber2/common/spiderden_upgrade")

end

local function CanUpgrade(inst)
    if inst:HasTag("bedazzled") and not inst.shaving then
        return false, "BEDAZZLED"
    end

    return true
end

local growth_stages =
{
    { name = "small",   time = GetSmallGrowTime,    fn = SetSmall         },
    { name = "med",     time = GetMedGrowTime,      fn = SetMedium        },
    { name = "large",   time = GetLargeGrowTime,    fn = SetLarge,        multiplier = TUNING.SPIDERDEN_GROW_TIME_QUEEN * 2},
    { name = "queen",                               fn = AttemptMakeQueen },
}

local function CanTarget(guy)
    return not guy.components.health:IsDead()
end

local TARGET_MUST_TAGS = { "_combat", "_health", "character" }
local TARGET_CANT_TAGS = { "player", "spider", "INLIMBO" }
local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local target = FindEntity(
            inst,
            25,
            CanTarget,
            TARGET_MUST_TAGS, --see entityreplica.lua
            TARGET_CANT_TAGS
        )
        if target ~= nil then
            SpawnDefenders(inst, target)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
    end

    if inst.data.stage == 3 and
        math.random() <= TUNING.HAUNT_CHANCE_RARE and
        AttemptMakeQueen(inst) then
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
        return true
    end

    return false
end

local function OnLoadPostPass(inst)
    if inst:GetCurrentPlatform() then
        if inst.components.growable then
            inst.components.growable:StopGrowing()
        end
        if inst.components.childspawner then
            inst.components.childspawner:StopRegen()
        end
    else
        if inst.components.childspawner then
            inst.components.childspawner:StartRegen()
        end
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SPIDERDEN_RELEASE_TIME, TUNING.SPIDERDEN_REGEN_TIME)
end

local function CanShave(inst, shaver, shaving_implement)
    return shaver:HasTag("spiderwhisperer") and not inst.components.health:IsDead() and 
           not inst.components.burnable:IsBurning() and not inst.components.freezable:IsFrozen()
end

local function OnShaved(inst, shaver, shaving_implement)

    local stage = inst.data.stage

    if stage == 1 then
        -- Should we release all children instead?
        SpawnDefenders(inst, shaver)
        --inst.components.childspawner:ReleaseAllChildren()
        inst.components.health:Kill()
    else
        inst.shaving = true
        local downgraded_stage = stage - 1

        if downgraded_stage < 3 and inst.components.sleepingbag then
            inst.components.sleepingbag:DoWakeUp()
            inst:RemoveComponent("sleepingbag")
            inst:RemoveTag("tent")
        end

        inst.components.growable:SetStage(downgraded_stage)
        SetStage(inst, downgraded_stage, true)
        inst.components.upgradeable.numupgrades = 0

        local anim = downgraded_stage == 2 and "shave_large_to_medium" or "shave_medium_to_small"
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:PushAnimation(inst.anims.idle, true)
            inst.SoundEmitter:PlaySound("webber2/common/spiderden/downgrade")
        if inst:HasTag("bedazzled") then
            inst:DoTaskInTime(15 * FRAMES, function() inst.components.bedazzlement:Stop() end)
        end
    end
end

local function OnGoHome(inst, child)
    -- Drops the hat before it goes home if it has any
    local hat = child.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if hat ~= nil then
        child.components.inventory:DropItem(hat)
    end
end

local function MakeSpiderDenFn(den_level)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddGroundCreepEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .5)

        inst.MiniMapEntity:SetIcon("spiderden_" .. tostring(den_level) .. ".png")

        inst.AnimState:SetBank("spider_cocoon")
        inst.AnimState:SetBuild("spider_cocoon")
        inst.AnimState:PlayAnimation("cocoon_small", true)
        inst.AnimState:HideSymbol("bedazzled_flare")

        inst:AddTag("cavedweller")
        inst:AddTag("structure")
        inst:AddTag("beaverchewable") -- by werebeaver
        inst:AddTag("hostile")
        inst:AddTag("spiderden")
        inst:AddTag("bedazzleable")
        inst:AddTag("hive")

        MakeSnowCoveredPristine(inst)

        inst:SetPrefabName("spiderden")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.data = {}

        -------------------
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(200)

        -------------------
        inst:AddComponent("childspawner")
        inst.components.childspawner.childname = "spider"
        inst.components.childspawner:SetRegenPeriod(TUNING.SPIDERDEN_REGEN_TIME)
        inst.components.childspawner:SetSpawnPeriod(TUNING.SPIDERDEN_RELEASE_TIME)
        inst.components.childspawner:SetGoHomeFn(OnGoHome)

        WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SPIDERDEN_RELEASE_TIME, TUNING.SPIDERDEN_ENABLED)
        WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SPIDERDEN_REGEN_TIME, TUNING.SPIDERDEN_ENABLED)
        if not TUNING.SPIDERDEN_ENABLED then
            inst.components.childspawner.childreninside = 0
        end

        inst.components.childspawner.allowboats = true

        inst.components.childspawner.emergencychildname = TUNING.SPAWN_SPIDER_WARRIORS and "spider_warrior" or "spider"
        inst.components.childspawner.emergencychildrenperplayer = 1
        inst.components.childspawner.canemergencyspawn = TUNING.SPIDERDEN_ENABLED

        inst.components.childspawner:SetSpawnedFn(onspawnspider)
        --inst.components.childspawner:SetMaxChildren(TUNING.SPIDERDEN_SPIDERS[stage])
        --inst.components.childspawner:ScheduleNextSpawn(0)
        inst:ListenForEvent("creepactivate", SpawnInvestigators)
        inst.SummonChildren = SummonChildren

        ---------------------
        inst:AddComponent("lootdropper")
        ---------------------

        ---------------------
        MakeMediumBurnable(inst)
        inst.components.burnable:SetOnIgniteFn(OnIgnite)
        inst.components.burnable:SetOnExtinguishFn(OnExtinguish)
        -------------------

        ---------------------
        MakeMediumFreezableCharacter(inst)
        inst:ListenForEvent("freeze", OnFreeze)
        inst:ListenForEvent("onthaw", OnThaw)
        inst:ListenForEvent("unfreeze", OnUnFreeze)
        -------------------

        inst:DoTaskInTime(0, OnInit)

        -------------------

        inst:AddComponent("combat")
        inst.components.combat:SetOnHit(OnHit)
        inst:ListenForEvent("death", OnKilled)

        --------------------

        inst:AddComponent("upgradeable")
        inst.components.upgradeable.upgradetype = UPGRADETYPES.SPIDER
        inst.components.upgradeable.onupgradefn = OnUpgrade
        inst.components.upgradeable.onstageadvancefn = OnStageAdvance
        inst.components.upgradeable:SetCanUpgradeFn(CanUpgrade)

        ---------------------
        MakeMediumPropagator(inst)

        ---------------------
        inst:AddComponent("growable")
        inst.components.growable.springgrowth = true
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(den_level)
        inst.components.growable:StartGrowing()

        ---------------------

        --inst:AddComponent( "spawner" )
        --inst.components.spawner:Configure( "resident", max, initial, rate )
        --inst.spawn_weight = global_spawn_weight

        inst:AddComponent("inspectable")

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_MEDIUM
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        MakeSnowCovered(inst)

        inst:AddComponent("shaveable")
        inst.components.shaveable:SetPrize("silk", 1)
        inst.components.shaveable.can_shave_test = CanShave
        inst.components.shaveable.on_shaved = OnShaved

        inst:AddComponent("bedazzlement")

        inst:DoTaskInTime(0, function()
            if inst.components.growable:GetStage() >= 3 then
                AddSleepingBag(inst)
            end
        end)

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
		inst.OnLoadPostPass = OnLoadPostPass
        inst.OnPreLoad = OnPreLoad

		if not POPULATING then
			inst:DoTaskInTime(0, OnLoadPostPass)
		end

        return inst
    end
end

return Prefab("spiderden", MakeSpiderDenFn(1), assets, prefabs),
    Prefab("spiderden_2", MakeSpiderDenFn(2), assets, prefabs),
       Prefab("spiderden_3", MakeSpiderDenFn(3), assets, prefabs)