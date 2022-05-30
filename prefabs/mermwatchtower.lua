require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/merm_guard_tower.zip"),
    Asset("MINIMAP_IMAGE", "merm_guard_tower"),
}

local prefabs =
{
    "mermguard",
    "collapse_big",
}

local function testforflag(inst)
    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKing() then
        inst.AnimState:Show("flag")
    else
        inst.AnimState:Hide("flag")
    end
end

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
        inst.AnimState:PushAnimation("idle", true)
        testforflag(inst)
    end
end

local function StartSpawning(inst)

    if not inst:HasTag("burnt") and TheWorld.components.mermkingmanager and
        TheWorld.components.mermkingmanager:HasKing() and inst.components.childspawner ~= nil then
        inst.components.childspawner:StartSpawning()
        inst.AnimState:Show("flag")
        inst.AnimState:PlayAnimation("flagup")
        inst.AnimState:PushAnimation("idle")
    end
end

local function StopSpawning(inst)
    if not inst:HasTag("burnt") and inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
        inst.AnimState:PlayAnimation("flagdown")
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

local function ToggleWinterTuning(inst, iswinter)
    if not inst.components.childspawner then
        return
    end

    if iswinter then
        inst.components.childspawner:SetRegenPeriod(TUNING.TOTAL_DAY_TIME * 6)
    else
        inst.components.childspawner:SetRegenPeriod(TUNING.TOTAL_DAY_TIME * 0.5)
    end
end

local function DescriptionFn(inst, viewer)
    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKing() then
        return GetString(viewer.prefab, "DESCRIBE", "MERMWATCHTOWER_REGULAR" )
    else
        return GetString(viewer.prefab, "DESCRIBE", "MERMWATCHTOWER_NOKING" )
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/hut/guard_place")
    testforflag(inst)
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MERMWATCHTOWER_RELEASE_TIME, TUNING.MERMWATCHTOWER_REGEN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("merm_guard_tower.png")

    inst.AnimState:SetBank("merm_guard_tower")
    inst.AnimState:SetBuild("merm_guard_tower")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:Hide("flag")

    inst:AddTag("structure")

    MakeSnowCoveredPristine(inst)

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
    inst.components.childspawner.childname = "mermguard"
    inst.components.childspawner:SetSpawnedFn(OnSpawned)
    inst.components.childspawner:SetGoHomeFn(OnGoHome)
    inst.components.childspawner:SetRegenPeriod(TUNING.MERMWATCHTOWER_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.MERMWATCHTOWER_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.MERMWATCHTOWER_MERMS)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MERMWATCHTOWER_RELEASE_TIME, TUNING.MERMWATCHTOWER_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MERMWATCHTOWER_REGEN_TIME, TUNING.MERMWATCHTOWER_ENABLED)
    if not TUNING.MERMWATCHTOWER_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = DescriptionFn

    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKing() then
        StartSpawning(inst)
    end

    MakeHauntableWork(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    MakeSnowCovered(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:ListenForEvent("onignite", onignite)
    inst:ListenForEvent("burntup", onburntup)

    inst:ListenForEvent("onmermkingcreated",   function() StartSpawning(inst) end , TheWorld)
    inst:ListenForEvent("onmermkingdestroyed", function() StopSpawning(inst)  end , TheWorld)
    inst:ListenForEvent("animover", function(inst)
            if inst.AnimState:IsCurrentAnimation("flagdown") then
                inst.AnimState:Hide("flag")
                inst.AnimState:PlayAnimation("idle")
            end
        end)

    inst:WatchWorldState("iswinter", ToggleWinterTuning)

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnPreLoad = OnPreLoad

    return inst
end

local function invalid_placement_fn(player, placer)
    if placer and placer.mouse_blocked then
        return
    end

    if player and player.components.talker then
        player.components.talker:Say(GetString(player, "ANNOUNCE_CANTBUILDHERE_WATCHTOWER"))
    end
end

return Prefab("mermwatchtower", fn, assets, prefabs),
       MakePlacer("mermwatchtower_placer", "merm_guard_tower", "merm_guard_tower", "idle", nil, nil, nil, nil, nil, nil, nil, nil, invalid_placement_fn )

