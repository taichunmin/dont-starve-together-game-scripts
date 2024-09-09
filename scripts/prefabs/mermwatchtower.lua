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
    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKingAnywhere() then
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
    if TheWorld.components.mermkingmanager
            and TheWorld.components.mermkingmanager:HasKingAnywhere()
            and inst.components.childspawner ~= nil
            and not inst:HasTag("burnt") then
        inst.components.childspawner:StartSpawning()
        inst.AnimState:Show("flag")
        inst.AnimState:PlayAnimation("flagup")
        inst.AnimState:PushAnimation("idle")
    end
end

local function StopSpawning(inst)
    if inst.components.childspawner ~= nil and not inst:HasTag("burnt") then
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
    local childspawner = inst.components.childspawner
    if childspawner then
        childspawner:SetRegenPeriod(
            (iswinter and TUNING.MERMWATCHTOWER_REGEN_TIME * 12)
            or TUNING.MERMWATCHTOWER_REGEN_TIME
        )
    end
end

local function DescriptionFn(inst, viewer)
    local mermkingmanager = TheWorld.components.mermkingmanager
    local string_modifier = (mermkingmanager ~= nil and mermkingmanager:HasKingAnywhere() and "MERMWATCHTOWER_REGULAR")
        or "MERMWATCHTOWER_NOKING"
    return GetString(viewer.prefab, "DESCRIBE", string_modifier)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/hut/guard_place")
    testforflag(inst)
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MERMWATCHTOWER_RELEASE_TIME, TUNING.MERMWATCHTOWER_REGEN_TIME)
end

local function watchtower_on_animover(inst)
    if inst.AnimState:IsCurrentAnimation("flagdown") then
        inst.AnimState:Hide("flag")
        inst.AnimState:PlayAnimation("idle")
    end
end

---------------------------------------------------------------
-- PLACER EFFECTS
local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)

    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    elseif helperinst:IsNear(helperinst.placerinst, TUNING.WURT_OFFERING_POT_RANGE) then
        helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
    else
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    end

end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")


    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    inst.AnimState:Hide("outer")

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        inst.helper = CreatePlacerRing()
        inst.helper.entity:SetParent(inst.entity)

        inst.helper:AddComponent("updatelooper")
        inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
        inst.helper.placerinst = placerinst
        OnUpdatePlacerHelper(inst.helper)

    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnStartHelper(inst)--, recipename, placerinst)
    if inst.AnimState:IsCurrentAnimation("place") then
        inst.components.deployhelper:StopHelper()
    end
end

---------------------------------------------------------------------------------------------

local MAX_COUNT = 6 -- Max num slots of a offering_pot, this shouldn't be static...

local function UpdateSpawningTime(inst, data)
    if data.inst == nil or
        not data.inst:IsValid() or
        data.inst:GetDistanceSqToInst(inst) > TUNING.WURT_OFFERING_POT_RANGE * TUNING.WURT_OFFERING_POT_RANGE
    then
        return
    end

    local timer   = inst.components.worldsettingstimer
    local spawner = inst.components.childspawner

    if timer == nil or spawner == nil then
        return
    end

    inst.kelpofferings[data.inst.GUID] =  data.count and data.count > 0 and data.count or nil

    local topcount = 0

    for _, count in pairs(inst.kelpofferings) do
        if count > topcount then
            topcount = count
        end
    end

    local mult = Remap(topcount, 0, MAX_COUNT, 1, TUNING.WURT_MAX_OFFERING_REGEN_MULT)

    timer:SetMaxTime("ChildSpawner_RegenPeriod", TUNING.MERMWATCHTOWER_REGEN_TIME * mult)
    spawner:SetRegenPeriod(TUNING.MERMWATCHTOWER_REGEN_TIME * mult)
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

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("offering_pot")
        inst.components.deployhelper:AddRecipeFilter("offering_pot_upgraded")
         --inst.components.deployhelper:AddRecipeFilter("merm_armory")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
        inst.components.deployhelper.onstarthelper = OnStartHelper
    end

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_speechname = "mermwatchtower_regular"

    inst:AddComponent("lootdropper")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(2)
    workable:SetOnFinishCallback(onhammered)
    workable:SetOnWorkCallback(onhit)

    local childspawner = inst:AddComponent("childspawner")
    childspawner.childname = "mermguard"
    childspawner:SetSpawnedFn(OnSpawned)
    childspawner:SetGoHomeFn(OnGoHome)
    childspawner:SetRegenPeriod(TUNING.MERMWATCHTOWER_REGEN_TIME)
    childspawner:SetSpawnPeriod(TUNING.MERMWATCHTOWER_RELEASE_TIME)
    childspawner:SetMaxChildren(TUNING.MERMWATCHTOWER_MERMS)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MERMWATCHTOWER_RELEASE_TIME, TUNING.MERMWATCHTOWER_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MERMWATCHTOWER_REGEN_TIME, TUNING.MERMWATCHTOWER_ENABLED)
    if not TUNING.MERMWATCHTOWER_ENABLED then
        childspawner.childreninside = 0
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = DescriptionFn

    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKingAnywhere() then
        StartSpawning(inst)
    end

    MakeHauntableWork(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    MakeSnowCovered(inst)

    inst.UpdateSpawningTime = UpdateSpawningTime
    inst.kelpofferings = {}
    inst:ListenForEvent("ms_updateofferingpotstate", function(_, data) inst:UpdateSpawningTime(data) end, TheWorld)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:ListenForEvent("onignite", onignite)
    inst:ListenForEvent("burntup", onburntup)

    inst:ListenForEvent("onmermkingcreated_anywhere",   function() StartSpawning(inst) end, TheWorld)
    inst:ListenForEvent("onmermkingdestroyed_anywhere", function() StopSpawning(inst)  end, TheWorld)
    inst:ListenForEvent("animover", watchtower_on_animover)

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

