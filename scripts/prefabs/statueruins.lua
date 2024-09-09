
local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/statue_ruins_small.zip"),
    Asset("ANIM", "anim/statue_ruins_small_gem.zip"),
    Asset("ANIM", "anim/statue_ruins.zip"),
    Asset("ANIM", "anim/statue_ruins_gem.zip"),
    Asset("MINIMAP_IMAGE", "statue_ruins"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "marble",
    "greengem",
    "redgem",
    "bluegem",
    "yellowgem",
    "orangegem",
    "purplegem",
    "nightmarefuel",
    "collapse_small",
    "thulecite",
    "statue_transition",
    "statue_transition_2",
	"ruins_statue_head",
	"ruins_statue_head_nogem",
	"ruins_statue_mage",
	"ruins_statue_mage_nogem",
}

local scrapbook_removedeps =
{
    "marble",
    "ruins_statue_head",
	"ruins_statue_head_nogem",
	"ruins_statue_mage",
	"ruins_statue_mage_nogem",
}

local gemlist =
{
    "greengem",
    "redgem",
    "bluegem",
    "yellowgem",
    "orangegem",
    "purplegem",
}

SetSharedLootTable('statue_ruins_no_gem',
{
    {'thulecite',     1.00},
    {'nightmarefuel', 1.00},
    {'thulecite',     0.05},
})

local MAX_LIGHT_ON_FRAME = 15
local MAX_LIGHT_OFF_FRAME = 30

local function OnUpdateLight(inst, dframes)
    local frame = inst._lightframe:value() + dframes
    if frame >= inst._lightmaxframe then
        inst._lightframe:set_local(inst._lightmaxframe)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
        inst._lightframe:set_local(frame)
    end

    local k = frame / inst._lightmaxframe
    inst.Light:SetRadius(inst._lightradius1:value() * k + inst._lightradius0:value() * (1 - k))

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._lightradius1:value() > 0 or frame < inst._lightmaxframe)
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    inst._lightmaxframe = inst._lightradius1:value() > 0 and MAX_LIGHT_ON_FRAME or MAX_LIGHT_OFF_FRAME
    OnUpdateLight(inst, 0)
end

local function DoFx(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("statue_transition_2")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 2, 1)
    end
    fx = SpawnPrefab("statue_transition")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 1.5, 1)
    end
end

local function fade_to(inst, rad, instant)
    rad = rad or 0
    if inst._lightradius1:value() ~= rad then
        local k = inst._lightframe:value() / inst._lightmaxframe
        local radius = inst._lightradius1:value() * k + inst._lightradius0:value() * (1 - k)
        local minradius0 = math.min(inst._lightradius0:value(), inst._lightradius1:value())
        local maxradius0 = math.max(inst._lightradius0:value(), inst._lightradius1:value())
        if radius > rad then
            inst._lightradius0:set(radius > minradius0 and maxradius0 or minradius0)
        else
            inst._lightradius0:set(radius < maxradius0 and minradius0 or maxradius0)
        end
        local maxframe = rad > 0 and MAX_LIGHT_ON_FRAME or MAX_LIGHT_OFF_FRAME
        inst._lightradius1:set(rad)
        inst._lightframe:set(
            instant and
            (rad > 0 and MAX_LIGHT_ON_FRAME or MAX_LIGHT_OFF_FRAME) or
            math.max(0, math.floor((radius - inst._lightradius0:value()) / (rad - inst._lightradius0:value()) * maxframe + .5))
        )
        OnLightDirty(inst)
    end
end

local function ShowWorkState(inst, worker, workleft)
    --NOTE: worker is nil when called from ShowPhaseState
    inst.AnimState:PlayAnimation(
        (   (workleft < TUNING.MARBLEPILLAR_MINE / 3 and "hit_low") or
            (workleft < TUNING.MARBLEPILLAR_MINE * 2 / 3 and "hit_med") or
            "idle_full"
        )..(inst._suffix or ""),
        true
    )
end

local function OnWorkFinished(inst)--, worker)
    inst.components.lootdropper:DropLoot(inst:GetPosition())

    local fx = SpawnAt("collapse_small", inst)
    fx:SetMaterial("rock")

    if TheWorld.state.isnightmarewild and math.random() <= .3 then
        SpawnAt(math.random() < .5 and "nightmarebeak" or "crawlingnightmare", inst)
    end

    inst:Remove()
end

local function ShowPhaseState(inst, phase, instant)
    inst._phasetask = nil

    if phase == "wild" then
        fade_to(inst, 4, instant)

        if inst._suffix == nil then
            inst._suffix = "_night"
            if not instant then
                DoFx(inst)
            end
        end

        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    else
        fade_to(inst, (phase == "warn" or phase == "dawn") and 2 or 0, instant)

        if inst._suffix ~= nil then
            inst._suffix = nil
            if not instant then
                DoFx(inst)
            end
        end

        inst.AnimState:ClearBloomEffectHandle()
    end

    ShowWorkState(inst, nil, inst.components.workable.workleft)
end

local function OnNightmarePhaseChanged(inst, phase, instant)
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
    end
    if instant or inst:IsAsleep() then
        ShowPhaseState(inst, phase, true)
    else
        inst._phasetask = inst:DoTaskInTime(math.random() * 2, ShowPhaseState, phase)
    end
end

local function SetGemmed(inst, gem)
    inst.gemmed = gem
    inst.AnimState:OverrideSymbol("swap_gem", inst.small and "statue_ruins_small_gem" or "statue_ruins_gem", gem)
    inst.components.lootdropper:SetLoot({ "thulecite", gem })
    inst.components.lootdropper:AddChanceLoot("thulecite", .05)
end

local function OnEntitySleep(inst)
    if inst.small then
        inst.SoundEmitter:KillSound("hoverloop")
    end
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
        ShowPhaseState(inst, TheWorld.state.nightmarephase, true)
    end
end

local function OnEntityWake(inst)
    if --[[inst.small and]] not inst.SoundEmitter:PlayingSound("hoverloop") then
        inst.SoundEmitter:PlaySound("dontstarve/common/floating_statue_hum", "hoverloop")
    end
end

local function onsave(inst, data)
    data.gem = inst.gemmed
end

local function onload(inst, data)
    if data ~= nil and data.gem ~= nil then
        SetGemmed(inst, data.gem)
    end
end

local function commonfn(small)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    if small then
        inst.AnimState:SetBank("statue_ruins_small")
        inst.AnimState:SetBuild("statue_ruins_small")
    else
        inst.AnimState:SetBank("statue_ruins")
        inst.AnimState:SetBuild("statue_ruins")
    end
    inst.scrapbook_anim ="idle_full"

    inst.MiniMapEntity:SetIcon("statue_ruins.png")

    inst:AddTag("cavedweller")
    inst:AddTag("structure")
    inst:AddTag("statue")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.9)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst._lightframe = net_smallbyte(inst.GUID, "ruins_statue._lightframe", "lightdirty")
    inst._lightradius0 = net_tinybyte(inst.GUID, "ruins_statue._lightradius0", "lightdirty")
    inst._lightradius1 = net_tinybyte(inst.GUID, "ruins_statue._lightradius1", "lightdirty")
    inst._lightmaxframe = MAX_LIGHT_OFF_FRAME
    inst._lightframe:set(inst._lightmaxframe)
    inst._lighttask = nil

    inst:SetPrefabNameOverride("ancient_statue")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.scrapbook_removedeps = scrapbook_removedeps


    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(ShowWorkState)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("lootdropper")

    inst:WatchWorldState("nightmarephase", OnNightmarePhaseChanged)
    OnNightmarePhaseChanged(inst, TheWorld.state.nightmarephase, true)

    MakeHauntableWork(inst)
    MakeRoseTarget_CreateFuel_IncreasedHorror(inst)

    if small then
        inst.small = true
        inst.OnEntityWake = OnEntityWake
    end
    inst.OnEntitySleep = OnEntitySleep
    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

local function gem(small)
    local inst = commonfn(small)

    if not TheWorld.ismastersim then
        return inst
    end

    SetGemmed(inst, GetRandomItem(gemlist), small)

    return inst
end

local function nogem(small)
    local inst = commonfn(small)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable('statue_ruins_no_gem')

    return inst
end


local function onruinsrespawn(inst, respawner)
	if not respawner:IsAsleep() then
		local fx = SpawnPrefab("statue_transition")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

return Prefab("ruins_statue_head", function() return gem(true) end, assets, prefabs),
    Prefab("ruins_statue_head_nogem", function() return nogem(true) end, assets, prefabs),
    Prefab("ruins_statue_mage", function() return gem() end, assets, prefabs),
    Prefab("ruins_statue_mage_nogem", function() return nogem() end, assets, prefabs),
    RuinsRespawner.Inst("ruins_statue_head", onruinsrespawn), RuinsRespawner.WorldGen("ruins_statue_head", onruinsrespawn),
    RuinsRespawner.Inst("ruins_statue_head_nogem", onruinsrespawn), RuinsRespawner.WorldGen("ruins_statue_head_nogem", onruinsrespawn),
    RuinsRespawner.Inst("ruins_statue_mage", onruinsrespawn), RuinsRespawner.WorldGen("ruins_statue_mage", onruinsrespawn),
    RuinsRespawner.Inst("ruins_statue_mage_nogem", onruinsrespawn), RuinsRespawner.WorldGen("ruins_statue_mage_nogem", onruinsrespawn)
