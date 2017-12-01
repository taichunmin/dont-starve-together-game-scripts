local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/crafting_table.zip"),
    Asset("MINIMAP_IMAGE", "tab_crafting_table"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "tentacle_pillar_arm",
    "armormarble",
    "armor_sanity",
    "armorsnurtleshell",
    "resurrectionstatue",
    "icestaff",
    "firestaff",
    "telestaff",
    "thulecite",
    "orangestaff",
    "greenstaff",
    "yellowstaff",
    "amulet",
    "blueamulet",
    "purpleamulet",
    "orangeamulet",
    "greenamulet",
    "yellowamulet",
    "redgem",
    "bluegem",
    "orangegem",
    "greengem",
    "purplegem",
    "stafflight",
    "monkey",
    "bat",
    "spider_hider",
    "spider_spitter",
    "gears",
    "crawlingnightmare",
    "nightmarebeak",
    "collapse_small",
    "collapse_big",
    "ancient_altar_broken_ruinsrespawner_inst",
    "ancient_altar_ruinsrespawner_inst",
}

for k = 1, NUM_TRINKETS do
    table.insert(prefabs, "trinket_"..tostring(k))
end

SetSharedLootTable("ancient_altar",
{
    {'thulecite',       1.00},
    {'thulecite',       1.00},
    {'nightmarefuel',   0.50},
    {'trinket_6',       0.50},
    {'rocks',           0.50},
})

local spawns =
{
    armormarble         = 0.5,
    armor_sanity        = 0.5,
    armorsnurtleshell   = 0.5,
    resurrectionstatue  = 1,
    icestaff            = 1,
    firestaff           = 1,
    telestaff           = 1,
    thulecite           = 1,
    orangestaff         = 1,
    greenstaff          = 1,
    yellowstaff         = 1,
    amulet              = 1,
    blueamulet          = 1,
    purpleamulet        = 1,
    orangeamulet        = 1,
    greenamulet         = 1,
    yellowamulet        = 1,
    redgem              = 5,
    bluegem             = 5,
    orangegem           = 5,
    greengem            = 5,
    purplegem           = 5,
    --health_plus         = 10,
    --health_minus        = 10,
    stafflight          = 15,
    monkey              = 100,
    bat                 = 100,
    spider_hider        = 100,
    spider_spitter      = 100,
    trinket             = 100,
    gears               = 100,
    crawlingnightmare   = 110,
    nightmarebeak       = 110,
}

local actions =
{
    tentacle_pillar_arm = { amt = 6, var = 1, sanity = -TUNING.SANITY_TINY, radius = 3 },
    monkey              = { amt = 3, var = 1, },
    bat                 = { amt = 5, },
    trinket             = { amt = 4, },
    spider_hider        = { amt = 2, },
    spider_spitter      = { amt = 2, },
    stafflight          = { amt = 1, },
}

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

    if inst._islighton:value() then
        inst.Light:SetRadius(3 * k)
    else
        inst.Light:SetRadius(3 * (1 - k))
    end

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._islighton:value() or frame < inst._lightmaxframe)
        if not inst._islighton:value() then
            inst.SoundEmitter:KillSound("idlesound")
        end
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    inst._lightmaxframe = inst._islighton:value() and MAX_LIGHT_ON_FRAME or MAX_LIGHT_OFF_FRAME
    OnUpdateLight(inst, 0)
end

local function PlayerSpawnCritter(player, critter, pos)
    TheWorld:PushEvent("ms_sendlightningstrike", pos)
    SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
    local spawn = SpawnPrefab(critter)
    if spawn ~= nil then
        spawn.Transform:SetPosition(pos:Get())
        if spawn.components.combat ~= nil then
            spawn.components.combat:SetTarget(player)
        end
    end
end

local function SpawnCritter(critter, pos, player)
    player:DoTaskInTime(GetRandomWithVariance(1, 0.8), PlayerSpawnCritter, critter, pos)
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function DoRandomThing(inst, pos, count, target)
    count = count or 1
    pos = pos or inst:GetPosition()

    for doit = 1, count do
        local item = weighted_random_choice(spawns)

        local doaction = actions[item]

        local amt = doaction ~= nil and doaction.amt or 1
        local sanity = doaction ~= nil and doaction.sanity or 0
        local health = doaction ~= nil and doaction.health or 0
        local func = doaction ~= nil and doaction.callback or nil
        local radius = doaction ~= nil and doaction.radius or 4

        local player = target

        if doaction ~= nil and doaction.var ~= nil then
            amt = math.max(0, GetRandomWithVariance(amt, doaction.var))
        end

        if amt == 0 and func ~= nil then
            func(inst, item, doaction)
        end

        for i = 1, amt do
            local offset = FindWalkableOffset(pos, math.random() * 2 * PI, radius , 8, true, false, NoHoles) -- try to avoid walls
            if offset ~= nil then
                if func ~= nil then
                    func(inst, item, doaction)
                else
                    offset.x = offset.x + pos.x
                    offset.z = offset.z + pos.z
                    if item == "trinket" then
                        local prefab = PickRandomTrinket()
                        if prefab ~= nil then
                            SpawnCritter(prefab, offset, player)
                        end
                    else
                        SpawnCritter(item, offset, player)
                    end
                end
            end
        end
    end
end

local function common_fn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.8, 1.2)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("tab_crafting_table.png")

    inst.AnimState:SetBank("crafting_table")
    inst.AnimState:SetBuild("crafting_table")
    inst.AnimState:PlayAnimation(anim)

    inst.Light:Enable(false)
    inst.Light:SetRadius(0)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:EnableClientModulation(true)

    inst:AddTag("altar")
    inst:AddTag("structure")
    inst:AddTag("stone")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    inst:SetPrefabNameOverride("ancient_altar")

    inst._lightframe = net_smallbyte(inst.GUID, "ancient_altar._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "ancient_altar._islighton", "lightdirty")
    inst._lightmaxframe = MAX_LIGHT_OFF_FRAME
    inst._lightframe:set(inst._lightmaxframe)
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst._activecount = 0

    inst:AddComponent("inspectable")

    inst:AddComponent("prototyper")

    inst:AddComponent("workable")

    MakeHauntableWork(inst)

    return inst
end

local function complete_onturnon(inst)
    if inst.AnimState:IsCurrentAnimation("proximity_loop") then
        --NOTE: push again even if already playing, in case an idle was also pushed
        inst.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PlayAnimation("proximity_loop", true)
    end
    if not inst.SoundEmitter:PlayingSound("idlesound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_LP", "idlesound")
    end
    if not inst._islighton:value() then
        inst._islighton:set(true)
        inst._lightframe:set(math.floor((1 - inst._lightframe:value() / MAX_LIGHT_OFF_FRAME) * MAX_LIGHT_ON_FRAME + .5))
        OnLightDirty(inst)
    end
end

local function complete_onturnoff(inst)
    inst.AnimState:PushAnimation("idle_full")
    if inst._islighton:value() then
        inst._islighton:set(false)
        inst._lightframe:set(math.floor((1 - inst._lightframe:value() / MAX_LIGHT_ON_FRAME) * MAX_LIGHT_OFF_FRAME + .5))
        OnLightDirty(inst)
    end
end

local function complete_doonact(inst)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl3_ding")
end

local function complete_onactivate(inst)
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("proximity_loop", true)

    inst._activecount = inst._activecount + 1

    if not inst.SoundEmitter:PlayingSound("sound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
    end

    inst:DoTaskInTime(1.5, complete_doonact)
end

local function complete_onhammered(inst, worker)
    local pos = inst:GetPosition()
    local broken = SpawnPrefab("ancient_altar_broken")
    broken.Transform:SetPosition(pos:Get())
    broken.components.workable:SetWorkLeft(TUNING.ANCIENT_ALTAR_BROKEN_WORK)
    TheWorld:PushEvent("ms_sendlightningstrike", pos)
    SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
    DoRandomThing(inst, pos, nil, worker)
    inst:PushEvent("onprefabswaped", {newobj = broken})
    inst:Remove()
end

local function complete_fn()
    local inst = common_fn("idle_full")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.ANCIENTALTAR_HIGH

    inst.components.prototyper.onturnon = complete_onturnon
    inst.components.prototyper.onturnoff = complete_onturnoff
    inst.components.prototyper.onactivate = complete_onactivate

    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.ANCIENT_ALTAR_COMPLETE_WORK)
    inst.components.workable:SetMaxWork(TUNING.ANCIENT_ALTAR_COMPLETE_WORK)
    inst.components.workable:SetOnFinishCallback(complete_onhammered)

    return inst
end

local function broken_onturnon(inst)
    if not inst.SoundEmitter:PlayingSound("idlesound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_LP", "idlesound")
    end
    if not inst._islighton:value() then
        inst._islighton:set(true)
        inst._lightframe:set(math.floor((1 - inst._lightframe:value() / MAX_LIGHT_OFF_FRAME) * MAX_LIGHT_ON_FRAME + .5))
        OnLightDirty(inst)
    end
end

local function broken_onturnoff(inst)
    if inst._islighton:value() then
        inst._islighton:set(false)
        inst._lightframe:set(math.floor((1 - inst._lightframe:value() / MAX_LIGHT_ON_FRAME) * MAX_LIGHT_OFF_FRAME + .5))
        OnLightDirty(inst)
    end
end

local function broken_doonact(inst)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl3_ding")
    SpawnPrefab("sanity_lower").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function broken_onactivate(inst)
    inst.AnimState:PlayAnimation("hit_broken")
    inst.AnimState:PushAnimation("idle_broken")

    inst._activecount = inst._activecount + 1

    if not inst.SoundEmitter:PlayingSound("sound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
    end

    inst:DoTaskInTime(1.5, broken_doonact)
end

local function broken_onrepaired(inst, doer, repair_item)
    if inst.components.workable.workleft < inst.components.workable.maxwork then
        inst.AnimState:PlayAnimation("hit_broken")
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_repair")
    else
        local pos = inst:GetPosition()
        local altar = SpawnPrefab("ancient_altar")
        altar.Transform:SetPosition(pos:Get())
        altar.SoundEmitter:PlaySound("dontstarve/common/ancienttable_activate")
        SpawnPrefab("collapse_big").Transform:SetPosition(pos:Get())
        TheWorld:PushEvent("ms_sendlightningstrike", pos)
        inst:PushEvent("onprefabswaped", {newobj = altar})
        inst:Remove()
    end
end

local function broken_onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()

    local pos = inst:GetPosition()
    TheWorld:PushEvent("ms_sendlightningstrike", pos)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(pos:Get())
    fx:SetMaterial("stone")
    --##TODO: Random magic thing here.
    DoRandomThing(inst, pos, nil, worker)

    inst:Remove()
end

local function broken_onworked(inst, worker, workleft)
    inst.AnimState:PlayAnimation("hit_broken")
    --##TODO: Random magic thing here.
    local pos = inst:GetPosition()
    DoRandomThing(inst, pos, nil, worker)
end

local function broken_fn()
    local inst = common_fn("idle_broken")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.THULECITE
    inst.components.repairable.onrepaired = broken_onrepaired

    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.ANCIENTALTAR_LOW

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("ancient_altar")

    inst.components.prototyper.onturnon = broken_onturnon
    inst.components.prototyper.onturnoff = broken_onturnoff
    inst.components.prototyper.onactivate = broken_onactivate

    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetMaxWork(TUNING.ANCIENT_ALTAR_BROKEN_WORK+1) -- the last point repairs it to a full altar
    inst.components.workable:SetOnFinishCallback(broken_onhammered)
    inst.components.workable:SetOnWorkCallback(broken_onworked)
    inst.components.workable.savestate = true

    return inst
end

local function onruinsrespawn(inst, respawner)
    if not respawner:IsAsleep() then
        inst.AnimState:PlayAnimation("spawn")
        inst.AnimState:PushAnimation("idle_full", false)

        local fx = SpawnPrefab("collapse_big")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("stone")
    end
end

local function onruinsrespawn_broken(inst, respawner)
    if not respawner:IsAsleep() then
        inst.AnimState:PlayAnimation("spawn_broken")
        inst.AnimState:PushAnimation("idle_broken", false)

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("stone")
        fx.Transform:SetScale(1.5, 1.5, 1.5)
    end
end

local ruinsrespawnerdata =
{
    listenforprefabsawp = true,
}

return Prefab("ancient_altar", complete_fn, assets, prefabs),
    Prefab("ancient_altar_broken", broken_fn, assets, prefabs),
    RuinsRespawner.Inst("ancient_altar", onruinsrespawn, ruinsrespawnerdata), RuinsRespawner.WorldGen("ancient_altar", onruinsrespawn, ruinsrespawnerdata),
    RuinsRespawner.Inst("ancient_altar_broken", onruinsrespawn_broken, ruinsrespawnerdata), RuinsRespawner.WorldGen("ancient_altar_broken", onruinsrespawn_broken, ruinsrespawnerdata)
