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
    if not TheWorld.state.iswinter and inst.components.childspawner ~= nil and not inst:HasTag("burnt") then
        inst.components.childspawner:StartSpawning()
    end
end

local function StopSpawning(inst)
    if inst.components.childspawner ~= nil and not inst:HasTag("burnt") then
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
    if target then
        onhit(inst, target)
        return true
    else
        return false
    end
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

        local workable = inst:AddComponent("workable")
        workable:SetWorkAction(ACTIONS.HAMMER)
        workable:SetWorkLeft(2)
        workable:SetOnFinishCallback(onhammered)
        workable:SetOnWorkCallback(onhit)

        local childspawner = inst:AddComponent("childspawner")
        childspawner.childname = "merm"
        childspawner:SetSpawnedFn(OnSpawned)
        childspawner:SetGoHomeFn(OnGoHome)        

        childspawner.emergencychildname = "merm"
        childspawner:SetEmergencyRadius(TUNING.MERMHOUSE_EMERGENCY_RADIUS)

        --childspawner.calculateregenratefn = calcregenrate

        local hauntable = inst:AddComponent("hauntable")
        hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
        hauntable:SetOnHauntFn(OnHaunt)

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

    local childspawner = inst.components.childspawner
    childspawner:SetRegenPeriod(TUNING.MERMHOUSE_REGEN_TIME)
    childspawner:SetSpawnPeriod(TUNING.MERMHOUSE_RELEASE_TIME)
    childspawner:SetMaxChildren(TUNING.MERMHOUSE_MERMS)
    childspawner:SetMaxEmergencyChildren(TUNING.MERMHOUSE_EMERGENCY_MERMS)
    childspawner.canemergencyspawn = TUNING.MERMHOUSE_ENABLED
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MERMHOUSE_REGEN_TIME, TUNING.MERMHOUSE_ENABLED)
    if not TUNING.MERMHOUSE_ENABLED then
        childspawner.childreninside = 0
    end

    inst.OnPreLoad = OnPreLoad
end

local function mermhouse_crafted_common(inst)
    inst.MiniMapEntity:SetIcon("mermhouse_crafted.png")
    inst.AnimState:SetBank("mermhouse_crafted")
    inst.AnimState:SetBuild("mermhouse_crafted")
    inst.AnimState:PlayAnimation("idle", true)

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("offering_pot")
        inst.components.deployhelper:AddRecipeFilter("offering_pot_upgraded")
        --inst.components.deployhelper:AddRecipeFilter("merm_toolshed")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
        inst.components.deployhelper.onstarthelper = OnStartHelper
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/hut/place")
    inst.AnimState:PlayAnimation("place")
end

local function OnPreLoadCrafted(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_REGEN_TIME / 2)
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

    timer:SetMaxTime("ChildSpawner_RegenPeriod", TUNING.MERMHOUSE_REGEN_TIME / 2 * mult)
    spawner:SetRegenPeriod(TUNING.MERMHOUSE_REGEN_TIME / 2 * mult)
end

---------------------------------------------------------------------------------------------

local function mermhouse_crafted_master(inst)
    local childspawner = inst.components.childspawner
    childspawner:SetRegenPeriod(TUNING.MERMHOUSE_REGEN_TIME / 2)
    childspawner:SetSpawnPeriod(TUNING.MERMHOUSE_RELEASE_TIME)
    childspawner:SetMaxChildren(1)
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MERMHOUSE_RELEASE_TIME, TUNING.MERMHOUSE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MERMHOUSE_REGEN_TIME / 2, TUNING.MERMHOUSE_ENABLED)
    if not TUNING.MERMHOUSE_ENABLED then
        childspawner.childreninside = 0
    end

    inst.UpdateSpawningTime = UpdateSpawningTime
    inst.kelpofferings = {}

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("ms_updateofferingpotstate", function(_, data) inst:UpdateSpawningTime(data) end, TheWorld)

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
       MakePlacer("mermhouse_placer", "merm_house", "merm_house", "idle", nil,nil, nil, nil, nil, nil, nil, nil, invalid_placement_fn),
       MakeMermHouse("mermhouse_crafted", mermhouse_crafted_common, mermhouse_crafted_master),
       MakePlacer("mermhouse_crafted_placer", "mermhouse_crafted", "mermhouse_crafted", "idle", nil,nil, nil, nil, nil, nil, nil, nil, invalid_placement_fn)