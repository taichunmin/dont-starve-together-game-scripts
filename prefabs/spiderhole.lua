local assets =
{
    Asset("ANIM", "anim/spider_mound.zip"),
	Asset("MINIMAP_IMAGE", "cavespider_den"),
}

local prefabs =
{
    "spider_hider",
    "spider_spitter",

    --loot
    "rocks",
    "silk",
    "spidergland",
    "silk",
    "fossil_piece",

    --fx
    "rock_break_fx",
}

SetSharedLootTable('spider_hole',
{
    {'rocks',       1.00},
    {'rocks',       1.00},
    {'silk',        1.00},
    {'fossil_piece',1.00},
    {'fossil_piece',0.50},
    {'spidergland', 0.25},
    {'silk',        0.50},
})

local function ReturnChildren(inst)
    if inst.components.childspawner ~= nil then
        for k, child in pairs(inst.components.childspawner.childrenoutside) do
            if child.components.homeseeker ~= nil then
                child.components.homeseeker:GoHome()
            end
            child:PushEvent("gohome")
        end
    end
end

local function rock_onworked(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
        inst.components.lootdropper:DropLoot(pos)
        inst:Remove()
    else
        inst.AnimState:PlayAnimation(workleft <= TUNING.SPILAGMITE_ROCK * 0.5 and "low" or "med")
    end
end

local function GoToBrokenState(inst)
    --Remove myself, spawn a rock version in my place.
    SpawnPrefab("spiderhole_rock").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function IsInvestigator(child)
    return child.components.knownlocations:GetLocation("investigate") ~= nil
end

local function SpawnInvestigators(inst, data)
    if not inst.components.health:IsDead() and inst.components.childspawner ~= nil then
        local num_to_release = math.min(2, inst.components.childspawner.childreninside)
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

local function spawner_onworked(inst, worker, workleft)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren(worker)
    end
end

local function commonfn(anim, minimap_icon, tag, hascreep)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    if hascreep then
        inst.entity:AddGroundCreepEntity()
        inst.GroundCreepEntity:SetRadius(5)
    end

    MakeObstaclePhysics(inst, 2)

    inst.AnimState:SetBank("spider_mound")
    inst.AnimState:SetBuild("spider_mound")
    inst.AnimState:PlayAnimation(anim)

    if minimap_icon ~= nil then
        inst.MiniMapEntity:SetIcon(minimap_icon)
    end

    inst:AddTag("cavedweller")
    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")

    return inst
end

local function CanTarget(guy)
    return not guy.components.health:IsDead()
end

local function CustomOnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local target = FindEntity(
            inst,
            25,
            CanTarget,
            { "_combat", "_health" }, --see entityreplica.lua
            { "playerghost", "spider", "INLIMBO" }
        )
        if target ~= nil then
            spawner_onworked(inst, target)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
    end
end

local function spawnerfn()
    local inst = commonfn("full", "cavespider_den.png", "spiderden", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")

    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SPILAGMITE_SPAWNER)
    inst.components.workable:SetOnWorkCallback(spawner_onworked)
    inst.components.workable:SetOnFinishCallback(GoToBrokenState)

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(120)
    inst.components.childspawner:SetSpawnPeriod(240)
    inst.components.childspawner:SetMaxChildren(math.random(2, 3))
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "spider_hider"
    inst.components.childspawner:SetRareChild("spider_spitter", 0.33)
    inst.components.childspawner.emergencychildname = "spider_spitter"
    inst.components.childspawner.emergencychildrenperplayer = 1
    inst.components.childspawner:StartSpawning()

    inst:ListenForEvent("creepactivate", SpawnInvestigators)
    inst:ListenForEvent("startquake", function() ReturnChildren(inst) end, TheWorld)

    MakeHauntableWork(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, false)

    return inst
end

local function rockfn()
    local inst = commonfn("med")

    inst:SetPrefabNameOverride("spiderhole")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetOnWorkCallback(rock_onworked)
    inst.components.workable:SetWorkLeft(TUNING.SPILAGMITE_ROCK)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('spider_hole')

    MakeHauntableWork(inst)

    return inst
end

return Prefab("spiderhole", spawnerfn, assets, prefabs),
    Prefab("spiderhole_rock", rockfn, assets, prefabs)
