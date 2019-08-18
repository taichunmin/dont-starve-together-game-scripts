require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/bee_box.zip"),
}

local prefabs =
{
    "bee",
    "honey",
    "honeycomb",
    "collapse_small",
}

FLOWER_TEST_RADIUS = 30

local levels =
{
    { amount=6, idle="honey3", hit="hit_honey3" },
    { amount=3, idle="honey2", hit="hit_honey2" },
    { amount=1, idle="honey1", hit="hit_honey1" },
    { amount=0, idle="bees_loop", hit="hit_idle" },
}

local function Stop(inst)
    if inst.components.harvestable ~= nil and inst.components.harvestable.growtime ~= nil then
        inst.components.harvestable:StopGrowing()
    end
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
    end
end

local function Start(inst)
    if inst.components.harvestable ~= nil and inst.components.harvestable.growtime ~= nil
        and FindEntity(inst, FLOWER_TEST_RADIUS, nil, {"flower"}) ~= nil then
        inst.components.harvestable:StartGrowing()
    end
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StartSpawning()
    end
end

local function OnIsCaveDay(inst, isday)
    if not isday then
        Stop(inst)
    elseif not (TheWorld.state.iswinter or inst:HasTag("burnt"))
        and inst.LightWatcher:IsInLight() then
        Start(inst)
    end
end

local function OnEnterLight(inst)
    if not (TheWorld.state.iswinter or inst:HasTag("burnt"))
        and TheWorld.state.iscaveday then
        Start(inst)
    end
end

local function OnEnterDark(inst)
    Stop(inst)
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.SoundEmitter:KillSound("loop")
    if inst.components.harvestable ~= nil then
        inst.components.harvestable:Harvest()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle, false)
    end
end

local function setlevel(inst, level)
    if not inst:HasTag("burnt") then
        if inst.anims == nil then
            inst.anims = { idle = level.idle, hit = level.hit }
        else
            inst.anims.idle = level.idle
            inst.anims.hit = level.hit
        end
        inst.AnimState:PlayAnimation(inst.anims.idle)
    end
end

local function updatelevel(inst)
    if not inst:HasTag("burnt") then
        for k, v in pairs(levels) do
            if inst.components.harvestable.produce >= v.amount then
                setlevel(inst, v)
                break
            end
        end
    end
end

local function onharvest(inst, picker, produce)
    --print(inst, "onharvest")
    if not inst:HasTag("burnt") then
		if produce == levels[1].amount then
			AwardPlayerAchievement("honey_harvester", picker)
		end
        updatelevel(inst)
        if inst.components.childspawner ~= nil and not TheWorld.state.iswinter then
            inst.components.childspawner:ReleaseAllChildren(picker)
        end
    end
end

local function onchildgoinghome(inst, data)
    if not inst:HasTag("burnt") and
        data.child ~= nil and
        data.child.components.pollinator ~= nil and
        data.child.components.pollinator:HasCollectedEnough() and
        inst.components.harvestable ~= nil then
        inst.components.harvestable:Grow()
    end
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onsleep(inst)
    if not inst:HasTag("burnt") and inst.components.harvestable ~= nil
        and FindEntity(inst, FLOWER_TEST_RADIUS, nil, {"flower"}) ~= nil then
        inst.components.harvestable:SetGrowTime(TUNING.BEEBOX_HONEY_TIME)
        inst.components.harvestable:StartGrowing()
    end
end

local function stopsleep(inst)
    if not inst:HasTag("burnt") and inst.components.harvestable ~= nil then
        inst.components.harvestable:SetGrowTime(nil)
        inst.components.harvestable:StopGrowing()
    end
end

local function OnLoad(inst, data)
    --print(inst, "OnLoad")
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
        updatelevel(inst)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/bee_box_craft")
end

local function onignite(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
        inst.components.childspawner:StopSpawning()
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/bee_box_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function GetStatus(inst)
    return inst.components.harvestable ~= nil
        and (   (inst.components.harvestable.produce >= inst.components.harvestable.maxproduce and "READY") or
                (inst.components.harvestable:CanBeHarvested() and "SOMEHONEY") or
                ((inst.components.childspawner == nil or inst.components.childspawner:NumChildren() <= 0) and "NOHONEY")
            )
        or nil
end

local function SeasonalSpawnChanges(inst, season)
    if inst.components.childspawner then
        if season == SEASONS.SPRING then
            inst.components.childspawner:SetRegenPeriod(TUNING.BEEBOX_REGEN_TIME / TUNING.SPRING_COMBAT_MOD)
            inst.components.childspawner:SetSpawnPeriod(TUNING.BEEBOX_RELEASE_TIME / TUNING.SPRING_COMBAT_MOD)
            inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES * TUNING.SPRING_COMBAT_MOD)
        else
            inst.components.childspawner:SetRegenPeriod(TUNING.BEEBOX_REGEN_TIME)
            inst.components.childspawner:SetSpawnPeriod(TUNING.BEEBOX_RELEASE_TIME)
            inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("beebox.png")

    inst.AnimState:SetBank("bee_box")
    inst.AnimState:SetBuild("bee_box")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("playerowned")
    inst:AddTag("beebox")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------  

    inst:AddComponent("harvestable")
    inst.components.harvestable:SetUp("honey", 6, nil, onharvest, updatelevel)
    inst:ListenForEvent("childgoinghome", onchildgoinghome)
    -------------------

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "bee"
    inst.components.childspawner.allowwater = true
    SeasonalSpawnChanges(inst, TheWorld.state.season)
    inst:WatchWorldState("season", SeasonalSpawnChanges)

    if TheWorld.state.isday and not TheWorld.state.iswinter then
        inst.components.childspawner:StartSpawning()
    end

    inst:WatchWorldState("iscaveday", OnIsCaveDay)
    inst:ListenForEvent("enterlight", OnEnterLight)
    inst:ListenForEvent("enterdark", OnEnterDark)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("entitysleep", onsleep)
    inst:ListenForEvent("entitywake", stopsleep)

    updatelevel(inst)

    MakeHauntableWork(inst)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    inst:ListenForEvent("onignite", onignite)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("beebox", fn, assets, prefabs),
    MakePlacer("beebox_placer", "bee_box", "bee_box", "idle")
