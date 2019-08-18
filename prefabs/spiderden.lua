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
	Asset("MINIMAP_IMAGE", "spiderden"), --shared with spiderden2 and 3
}

local ANIM_DATA =
{
    SMALL =
    {
        hit = "cocoon_small_hit",
        idle = "cocoon_small",
        init = "grow_sac_to_small",
        freeze = "frozen_small",
        thaw = "frozen_loop_pst_small",
    },

    MEDIUM =
    {
        hit = "cocoon_medium_hit",
        idle = "cocoon_medium",
        init = "grow_small_to_medium",
        freeze = "frozen_medium",
        thaw = "frozen_loop_pst_medium",
    },

    LARGE =
    {
        hit = "cocoon_large_hit",
        idle = "cocoon_large",
        init = "grow_medium_to_large",
        freeze = "frozen_large",
        thaw = "frozen_loop_pst_large",
    },
}

local LOOT_DATA =
{
    SMALL = { "silk", "silk" },
    MEDIUM = { "silk", "silk", "silk", "silk" },
    LARGE = { "silk", "silk", "silk", "silk", "silk", "silk", "spidereggsack" },
}

local function SetStage(inst, stage)
    if stage <= 3 and inst.components.childspawner ~= nil then -- if childspawner doesn't exist, then this den is burning down
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_grow")
        inst.components.childspawner:SetMaxChildren(math.floor(SpringCombatMod(TUNING.SPIDERDEN_SPIDERS[stage])))
        inst.components.childspawner:SetMaxEmergencyChildren(TUNING.SPIDERDEN_EMERGENCY_WARRIORS[stage])
        inst.components.childspawner:SetEmergencyRadius(TUNING.SPIDERDEN_EMERGENCY_RADIUS[stage])
        inst.components.health:SetMaxHealth(TUNING.SPIDERDEN_HEALTH[stage])

        inst.AnimState:PlayAnimation(inst.anims.init)
        inst.AnimState:PushAnimation(inst.anims.idle, true)
    end

    inst.components.upgradeable:SetStage(stage)
    inst.data.stage = stage -- track here, as growable component may go away
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

    local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(my_x, my_z) == nil then
        inst.GroundCreepEntity:SetRadius(5)
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
    
    local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(my_x, my_z) == nil then
        inst.GroundCreepEntity:SetRadius(9)
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

    local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(my_x, my_z) == nil then
        inst.GroundCreepEntity:SetRadius(9)
    end
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

local function AttemptMakeQueen(inst)
    if inst.components.growable == nil then
        --failsafe in case we still got here after we are burning
        return
    end

    if inst.data.stage == nil or inst.data.stage ~= 3 then
        -- we got here directly (probably by loading), so reconfigure to the level 3 state.
        SetLarge(inst)
    end

    if not inst:IsNearPlayer(30) then
        inst.components.growable:StartGrowing(60 + math.random(60))
        return
    end

    local check_range = 60
    local cap = 4
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, check_range, nil, nil, { "spiderden", "spiderqueen" })
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
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
        if inst.components.childspawner ~= nil then
            local max_release_per_stage = { 2, 4, 6 }
            local num_to_release = math.min(max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)
            local num_warriors = math.min(num_to_release, TUNING.SPIDERDEN_WARRIORS[inst.data.stage])
            num_to_release = math.floor(SpringCombatMod(num_to_release))
            num_warriors = math.floor(SpringCombatMod(num_warriors))
            num_warriors = num_warriors - inst.components.childspawner:CountChildrenOutside(IsDefender)
            for k = 1, num_to_release do
                inst.components.childspawner.childname = k <= num_warriors and "spider_warrior" or "spider"
                local spider = inst.components.childspawner:SpawnChild()
                if spider ~= nil and attacker ~= nil and spider.components.combat ~= nil then
                    spider.components.combat:SetTarget(attacker)
                    spider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
                end
            end
            inst.components.childspawner.childname = "spider"

            local emergencyspider = inst.components.childspawner:TrySpawnEmergencyChild()
            if emergencyspider ~= nil then
                emergencyspider.components.combat:SetTarget(attacker)
                emergencyspider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
            end
        end
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

local function OnIgnite(inst)
    if inst.components.childspawner ~= nil then
        SpawnDefenders(inst)
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
    return TUNING.SPIDERDEN_GROW_TIME[3] * (1 + math.random())
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

local function OnUpgrade(inst)
   inst.AnimState:PlayAnimation(inst.anims.hit)
   inst.AnimState:PushAnimation(inst.anims.idle)
end

local growth_stages =
{
    { name = "small",   time = GetSmallGrowTime,    fn = SetSmall           },
    { name = "med",     time = GetMedGrowTime,      fn = SetMedium          },
    { name = "large",   time = GetLargeGrowTime,    fn = SetLarge           },
    { name = "queen",                               fn = AttemptMakeQueen   },
}

local function CanTarget(guy)
    return not guy.components.health:IsDead()
end

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local target = FindEntity(
            inst,
            25,
            CanTarget,
            { "_combat", "_health", "character" }, --see entityreplica.lua
            { "player", "spider", "INLIMBO" }
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

        inst.MiniMapEntity:SetIcon("spiderden.png")

        inst.AnimState:SetBank("spider_cocoon")
        inst.AnimState:SetBuild("spider_cocoon")
        inst.AnimState:PlayAnimation("cocoon_small", true)

        inst:AddTag("cavedweller")
        inst:AddTag("structure")
        inst:AddTag("chewable") -- by werebeaver
        inst:AddTag("hostile")
        inst:AddTag("spiderden")
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
        inst.components.childspawner.allowboats = true

        inst.components.childspawner.emergencychildname = "spider_warrior"
        inst.components.childspawner.emergencychildrenperplayer = 1

        inst.components.childspawner:SetSpawnedFn(onspawnspider)
        --inst.components.childspawner:SetMaxChildren(TUNING.SPIDERDEN_SPIDERS[stage])
        --inst.components.childspawner:ScheduleNextSpawn(0)
        inst:ListenForEvent("creepactivate", SpawnInvestigators)

        ---------------------
        inst:AddComponent("lootdropper")
        ---------------------

        ---------------------
        MakeMediumBurnable(inst)
        inst.components.burnable:SetOnIgniteFn(OnIgnite)
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
        inst.components.combat:SetOnHit(SpawnDefenders)
        inst:ListenForEvent("death", OnKilled)

        --------------------

        inst:AddComponent("upgradeable")
        inst.components.upgradeable.upgradetype = UPGRADETYPES.SPIDER
        inst.components.upgradeable.onupgradefn = OnUpgrade
        inst.components.upgradeable.onstageadvancefn = OnStageAdvance

        ---------------------
        MakeMediumPropagator(inst)

        ---------------------
        inst:AddComponent("growable")
        inst.components.growable.springgrowth = true
        inst.components.growable.stages = growth_stages                      

        inst:DoTaskInTime(0,
            function() 
                local x,y,z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil then
                    local growable = inst.components.growable
                    if growable ~= nil then
                        local default_stage = 1
                        if growable:GetStage() == default_stage then                                 
                            growable:SetStage(den_level)
                        end
                        growable:StopGrowing()
                    end
                else
                    local growable = inst.components.growable
                    if growable ~= nil then   
                        local default_stage = 1
                        if growable:GetStage() == default_stage then         
                            growable:SetStage(den_level)          
                        end
                        growable:StartGrowing()
                    end
                end
            end)

        ---------------------

        --inst:AddComponent( "spawner" )
        --inst.components.spawner:Configure( "resident", max, initial, rate )
        --inst.spawn_weight = global_spawn_weight

        inst:AddComponent("inspectable")

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_MEDIUM
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        MakeSnowCovered(inst)

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
        return inst
    end
end

return Prefab("spiderden", MakeSpiderDenFn(1), assets, prefabs),
    Prefab("spiderden_2", MakeSpiderDenFn(2), assets, prefabs),
    Prefab("spiderden_3", MakeSpiderDenFn(3), assets, prefabs)
