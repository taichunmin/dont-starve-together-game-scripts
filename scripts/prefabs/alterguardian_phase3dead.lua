local assets =
{
    Asset("ANIM", "anim/alterguardian_spawn_death.zip"),
}

local orb_prefabs =
{
    "alterguardian_phase3dead",
    "wagstaff_npc_pstboss",
}

local dead_prefabs =
{
    "alterguardianhat",
    "collapse_big",
    "moon_altar_crown",
    "moon_altar_glass",
    "moon_altar_icon",
    "moon_altar_idol",
    "moon_altar_seed",
    "moon_altar_ward",
    "moonglass",
    "moonrocknugget",
    "moonrockseed",
}

SetSharedLootTable("alterguardian_phase3dead",
{
    {"alterguardianhat",    1.00},
    {"moonglass",           1.00},
    {"moonglass",           1.00},
    {"moonglass",           1.00},
    {"moonglass",           1.00},
    {"moonglass",           0.66},
    {"moonglass",           0.66},
    {"moonglass",           0.66},
    {"moonglass",           0.33},
    {"moonglass",           0.33},
    {"moonglass",           0.33},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      0.66},
    {"moonrocknugget",      0.66},
    {"moonrocknugget",      0.66},
    {"moonrocknugget",      0.66},
})

local function orb_replacewithdead(inst)
    local dead_phase = SpawnPrefab("alterguardian_phase3dead")
    dead_phase.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function set_lightvalues(inst, val)
    inst.Light:SetIntensity(0.60 + (0.30 * val * val))
    inst.Light:SetRadius(5 * val)
    inst.Light:SetFalloff(0.85)
end

local INITIAL_LIGHT_VALUE = 0.65

-- Go from the starting light value to 0 over 9 frames (from phase3_death_pst anim)
local LIGHT_RATE = INITIAL_LIGHT_VALUE / (9*FRAMES)
local function pst_lightupdate(inst)
    inst._pst_frame = (inst._pst_frame ~= nil and inst._pst_frame + 1) or 1

    local new_lightvalue = math.max(0, 0.65 - (inst._pst_frame * LIGHT_RATE))
    set_lightvalues(inst, new_lightvalue)

    if new_lightvalue < 0.001 and inst._light_task ~= nil then
        inst._light_task:Cancel()
        inst._light_task = nil
    end
end

local function orb_gotopst(inst)
    if not inst._pststarted then
        -- Start the pst, then replace ourselves when it finishes.
        inst.AnimState:PlayAnimation("phase3_death_pst")
        inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/death_pst")

        inst._light_task = inst:DoPeriodicTask(0, pst_lightupdate)

        inst:ListenForEvent("animover", orb_replacewithdead)

        inst._pststarted = true

        TheWorld:PushEvent("ms_stopthemoonstorms")
    end
end

local function orb_onsave(inst, data)
    data.pststarted = inst._pststarted
end

local function orb_onload(inst, data)
    if data ~= nil then
        -- If we saved during the pst animation,
        -- just replay that sequence from the start.
        if data.pststarted then
            orb_gotopst(inst)
        end
    end
end

local ERODEIN =
{
    time = 3.5,
    erodein = true,
    remove = false,
}
local function start_wag_sequence(inst)
	TheWorld:PushEvent("ms_despawn_wagstaff_npc_pstboss")

    local ipos = inst:GetPosition()

    local offset = FindWalkableOffset(ipos, TWOPI*math.random(), 2.5)
    if offset then
        ipos = ipos + offset
    end

    local wagstaff = SpawnPrefab("wagstaff_npc_pstboss")
    wagstaff.Transform:SetPosition(ipos:Get())
    wagstaff:PushEvent("doerode", ERODEIN)
    wagstaff:PushEvent("spawndevice", ERODEIN)
    wagstaff:DoTaskInTime(ERODEIN.time - 5*FRAMES, function(w)
        w:PushEvent("startwork", inst)
    end)
end

local function orbfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    set_lightvalues(inst, INITIAL_LIGHT_VALUE)
    inst.Light:SetColour(0.01, 0.35, 1)

    MakeObstaclePhysics(inst, 2)

    inst.AnimState:SetBank("alterguardian_spawn_death")
    inst.AnimState:SetBuild("alterguardian_spawn_death")
    inst.AnimState:PlayAnimation("phase3_death_loop", true)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:ListenForEvent("orbtaken", orb_gotopst)

    inst:DoTaskInTime(5, start_wag_sequence)

    --inst._pststarted = nil

    inst.OnSave = orb_onsave
    inst.OnLoad = orb_onload

    return inst
end

local ALTAR_PIECES =
{
    "moon_altar_crown",
    "moon_altar_glass",
    "moon_altar_icon",
    "moon_altar_idol",
    "moon_altar_seed",
    "moon_altar_ward",
}

local PIECEBLOCKER_CANT = {"INLIMBO", "FX", "DECOR", "NOCLICK", "flying", "ghost", "playerghost"}
local function altarpiece_spawn_checkfn(v)
    local ents = TheSim:FindEntities(v.x, v.y, v.z, 1.5, nil, PIECEBLOCKER_CANT)
    return #ents == 0
end

local function dead_onwork(inst, worker, workleft)
    if workleft > 0 then
        inst.AnimState:PlayAnimation("phase3_death_hit")
        inst.AnimState:PushAnimation("phase3_death_idle", true)
    else
        local ipos = inst:GetPosition()
        inst.components.lootdropper:DropLoot(ipos)

        SpawnPrefab("rock_break_fx").Transform:SetPosition(ipos:Get())
        SpawnPrefab("collapse_big").Transform:SetPosition(ipos:Get())

        -- Try to respawn the altar pieces in a circle around the boss,
        -- close enough to hide inside of the collapse_big fx.
        local angle_inc = 360 / #ALTAR_PIECES
        for i, piece_name in ipairs(ALTAR_PIECES) do
            local offset = FindWalkableOffset(ipos, i*angle_inc, 2.5, nil, true, false, altarpiece_spawn_checkfn)
                or FindWalkableOffset(ipos, i*angle_inc, 5.0, nil, true, false, altarpiece_spawn_checkfn)

            local position = (offset ~= nil and ipos + offset) or ipos
            SpawnPrefab(piece_name).Transform:SetPosition(position:Get())
        end

        local upgraded_seed = SpawnPrefab("moonrockseed")
        upgraded_seed:DoUpgrade()
        upgraded_seed.Transform:SetPosition(ipos:Get())

        inst:Remove()
    end
end

local function deadfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2)

    inst.AnimState:SetBank("alterguardian_spawn_death")
    inst.AnimState:SetBuild("alterguardian_spawn_death")
    inst.AnimState:PlayAnimation("phase3_death_idle", true)

    inst:AddTag("boulder")
    inst:AddTag("moonglass")

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_proxy = "alterguardian_phase1"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:SetOnWorkCallback(dead_onwork)
    inst.components.workable.savestate = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("alterguardian_phase3dead")
    inst.components.lootdropper.min_speed = 3.0
    inst.components.lootdropper.max_speed = 4.5

    MakeSnowCovered(inst)

    MakeHauntableWork(inst)

    return inst
end

return Prefab("alterguardian_phase3deadorb", orbfn, assets, orb_prefabs),
        Prefab("alterguardian_phase3dead", deadfn, assets, dead_prefabs)
