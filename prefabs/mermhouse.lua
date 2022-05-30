require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/merm_house.zip"),
    Asset("ANIM", "anim/mermhouse_crafted.zip"),
    Asset("MINIMAP_IMAGE", "mermhouse_crafted"),
}

local prefabs =
{
    "merm",
    "collapse_big",

    --loot:
    "boards",
    "rocks",
    "pondfish",
}

local loot =
{
    "boards",
    "rocks",
    "pondfish",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst:RemoveComponent("childspawner")
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:ReleaseAllChildren(worker)
        end
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
    end
end

local function StartSpawning(inst)
    if not inst:HasTag("burnt") and
        not TheWorld.state.iswinter and
        inst.components.childspawner ~= nil then
        inst.components.childspawner:StartSpawning()
    end
end

local function StopSpawning(inst)
    if not inst:HasTag("burnt") and inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
    end
end

local function OnSpawned(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        if TheWorld.state.isday and
            inst.components.childspawner ~= nil and
            inst.components.childspawner:CountChildrenOutside() >= 1 and
            child.components.combat.target == nil then
            StopSpawning(inst)
        end
    end
end

local function OnGoHome(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        if inst.components.childspawner ~= nil and
            inst.components.childspawner:CountChildrenOutside() < 1 then
            StartSpawning(inst)
        end
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onignite(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
end

local function onburntup(inst)
    inst.AnimState:PlayAnimation("burnt")
end

local function OnIsDay(inst, isday)
    if isday then
        StopSpawning(inst)
    elseif not inst:HasTag("burnt") then
        if not TheWorld.state.iswinter then
            inst.components.childspawner:ReleaseAllChildren()
        end
        StartSpawning(inst)
    end
end

local HAUNT_TARGET_MUST_TAGS = { "character" }
local HAUNT_TARGET_CANT_TAGS = { "merm", "playerghost", "INLIMBO" }
local function OnHaunt(inst)
    if inst.components.childspawner == nil or
        not inst.components.childspawner:CanSpawn() or
        math.random() > TUNING.HAUNT_CHANCE_HALF then
        return false
    end

    local target = FindEntity(inst, 25, nil, HAUNT_TARGET_MUST_TAGS, HAUNT_TARGET_CANT_TAGS)
    if target == nil then
        return false
    end

    onhit(inst, target)
    return true
end

local function MakeMermHouse(name, common_postinit, master_postinit)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 1)

        inst:AddTag("structure")

        MakeSnowCoveredPristine(inst)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(2)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:AddComponent("childspawner")
        inst.components.childspawner.childname = "merm"
        inst.components.childspawner:SetSpawnedFn(OnSpawned)
        inst.components.childspawner:SetGoHomeFn(OnGoHome)

        inst.components.childspawner.emergencychildname = "merm"
        inst.components.childspawner:SetEmergencyRadius(TUNING.MERMHOUSE_EMERGENCY_RADIUS)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        inst:WatchWorldState("isday", OnIsDay)

        StartSpawning(inst)

        MakeMediumBurnable(inst, nil, nil, true)
        MakeLargePropagator(inst)
        inst:ListenForEvent("onignite", onignite)
        inst:ListenForEvent("burntup", onburntup)

        inst:AddComponent("inspectable")

        MakeSnowCovered(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload

        if master_postinit then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function mermhouse_common(inst)
    inst.MiniMapEntity:SetIcon("mermhouse.png")
    inst.AnimState:SetBank("merm_house")
    inst.AnimState:SetBuild("merm_house")
    inst.AnimState:PlayAnimation("idle")
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_REGEN_TIME)
end

local function mermhouse_master(inst)
    inst.components.lootdropper:SetLoot(loot)

    inst.components.childspawner:SetRegenPeriod(TUNING.MERMHOUSE_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.MERMHOUSE_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.MERMHOUSE_MERMS)
    inst.components.childspawner:SetMaxEmergencyChildren(TUNING.MERMHOUSE_EMERGENCY_MERMS)
    inst.components.childspawner.canemergencyspawn = TUNING.MERMHOUSE_ENABLED
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MERMHOUSE_REGEN_TIME, TUNING.MERMHOUSE_ENABLED)
    if not TUNING.MERMHOUSE_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst.OnPreLoad = OnPreLoad
end

local function mermhouse_crafted_common(inst)
    inst.MiniMapEntity:SetIcon("mermhouse_crafted.png")
    inst.AnimState:SetBank("mermhouse_crafted")
    inst.AnimState:SetBuild("mermhouse_crafted")
    inst.AnimState:PlayAnimation("idle", true)
end


local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/hut/place")
    inst.AnimState:PlayAnimation("place")
end

local function OnPreLoadCrafted(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_REGEN_TIME / 2)
end

local function mermhouse_crafted_master(inst)
    inst.components.childspawner:SetRegenPeriod(TUNING.MERMHOUSE_REGEN_TIME / 2)
    inst.components.childspawner:SetSpawnPeriod(TUNING.MERMHOUSE_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(1)
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MERMHOUSE_REGEN_TIME / 2, TUNING.MERMHOUSE_ENABLED)
    if not TUNING.MERMHOUSE_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnPreLoad = OnPreLoadCrafted
end

local function invalid_placement_fn(player, placer)
    if placer and placer.mouse_blocked then
        return
    end

    if player and player.components.talker then
        player.components.talker:Say(GetString(player, "ANNOUNCE_CANTBUILDHERE_HOUSE"))
    end
end

return MakeMermHouse("mermhouse", mermhouse_common, mermhouse_master),
       MakeMermHouse("mermhouse_crafted", mermhouse_crafted_common, mermhouse_crafted_master),
       MakePlacer("mermhouse_crafted_placer", "mermhouse_crafted", "mermhouse_crafted", "idle", nil,nil, nil, nil, nil, nil, nil, nil, invalid_placement_fn)