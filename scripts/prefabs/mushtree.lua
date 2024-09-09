--[[
    Prefabs for 3 different mushtrees
--]]

local TREESTATES =
{
    BLOOMING = "bloom",
    NORMAL = "normal",
}

local function tree_burnt(inst)
    inst.components.lootdropper:SpawnLootPrefab("ash")
    if math.random() < 0.5 then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    local burnt_prefab = inst.prefab..(inst.treestate == TREESTATES.BLOOMING and "_bloom_burntfx" or "_burntfx")
    SpawnPrefab(burnt_prefab).Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function stump_burnt(inst)
    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function dig_up_stump(inst)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

-- Acid functions
local NUM_ACID_PHASES = 2
local function MakeAcidSmokeForSymbol(inst, symbol_index)
    local acidsmoke = SpawnPrefab("acidsmoke_endless")
    acidsmoke.entity:AddFollower()
    acidsmoke.Follower:FollowSymbol(inst.GUID, "swap_acidglob"..symbol_index)
    inst._acidsmokes[acidsmoke] = symbol_index
    acidsmoke:ListenForEvent("onremove", function(i)
        i._acidsmokes[acidsmoke] = nil
        acidsmoke:Remove()
    end, inst)
    acidsmoke:Hide()
end

local function get_acid_perish_time(inst)
    if inst._acid_reset_task then
        return GetTaskRemaining(inst._acid_reset_task)
    end

    local last_acid_start_time = inst._last_acid_start_time
        or (inst._acid_initialize_task ~= nil and GetTaskTime(inst._acid_initialize_task))

    return (last_acid_start_time and (GetTime() - last_acid_start_time))
        or 0
end

local function try_acid_art_update(inst)
    local acid_perish_time = get_acid_perish_time(inst)
    local phase = (inst._is_stump and 0)
        or math.clamp(math.ceil(acid_perish_time / TUNING.ACIDRAIN_MUSHTREE_PHASE_TIME), 0, NUM_ACID_PHASES)

    -- Netvars don't need these checks, but we don't want to do extra work/C++ calls
    -- unless we need to later, so we might as well check both now
    local smokeenablednum = inst._smoke_number:value()
    local phase_changed = (smokeenablednum == 0 and phase ~= 0)
        or (smokeenablednum == 4 and phase ~= 2)
        or ((smokeenablednum > 0 and smokeenablednum < 4) and phase ~= 1)
    inst._phase1_show = (inst._phase1_show or math.random(1,3))
    if phase_changed then
        if phase == 0 then
            inst._smoke_number:set(0)
        elseif phase == 2 then
            inst._smoke_number:set(4)
        else
            inst._smoke_number:set(inst._phase1_show)
        end
    end

    local is_bloom = (inst.treestate == TREESTATES.BLOOMING)
    local bloom_changed = (inst._bloomed:value() ~= is_bloom)
    if bloom_changed then
        inst._bloomed:set(is_bloom)
    end

    if phase_changed or bloom_changed then
        for i = 1, 3 do
            local should_show = ((phase == 1 and i == inst._phase1_show) or (phase > 1))

            local swap_name = "swap_acidglob"..i
            if not is_bloom and should_show then
                inst.AnimState:ShowSymbol(swap_name)
            else
                inst.AnimState:HideSymbol(swap_name)
            end

            swap_name = "swap_acidglob_bloom"..i
            if is_bloom and should_show then
                inst.AnimState:ShowSymbol(swap_name)
            else
                inst.AnimState:HideSymbol(swap_name)
            end
        end

        if inst.AnimState:IsCurrentAnimation("idle_loop") then
            inst.AnimState:PlayAnimation("chop")
            inst.AnimState:PushAnimation("idle_loop", true)
        end
    end
end

local function acid_initialize(inst)
    inst._acid_initialize_task = nil
    if inst._acid_reset_task then
        inst._acid_reset_task:Cancel()
        inst._acid_reset_task = nil
    end

    inst._last_acid_start_time = GetTime()
    if not inst.components.timer:TimerExists("acidvisualsupdate") then
        inst.components.timer:StartTimer("acidvisualsupdate", 0.5 + 4.5*math.random())
    end

    inst.components.periodicspawner:SetDensityInRange(
        TUNING.MUSHSPORE_MAX_DENSITY_RAD,
        TUNING.MUSHSPORE_MAX_DENSITY * 1.5
    )
    inst.components.periodicspawner:SetRandomTimes(30, 30, false)
end

local function OnAcidInfused(inst)
    inst._acid_initialize_task = inst:DoTaskInTime(FRAMES * (1 + 19 * math.random()), acid_initialize)
end

local function acid_reset(inst)
    inst._acid_reset_task = nil
    if inst._acid_initialize_task then
        inst._acid_initialize_task:Cancel()
        inst._acid_initialize_task = nil
    end

    -- Reset this so that we're not tracking into future acid rains
    -- while having rainimmunity, or anything like that.
    inst._last_acid_start_time = nil
    try_acid_art_update(inst)
    inst.components.timer:StopTimer("acidvisualsupdate")

    inst.components.periodicspawner:SetDensityInRange(
        TUNING.MUSHSPORE_MAX_DENSITY_RAD,
        TUNING.MUSHSPORE_MAX_DENSITY
    )
    inst.components.periodicspawner:SetRandomTimes(40, 60, false)
end

local function OnAcidUninfused(inst)
    local _last_acidrain_start_time = inst._last_acid_start_time or 0
    local acidrain_time_passed = (GetTime() - _last_acidrain_start_time)

    inst._acid_reset_task = inst:DoTaskInTime(acidrain_time_passed, acid_reset)
end

local function acidcovered_on_loot_prefab_spawned(inst, event_data)
    local loot = event_data.loot
    if not loot or not loot.components.perishable then return end

    local acid_perish_time = get_acid_perish_time(inst)
    if acid_perish_time <= 0 then return end

    local perish_multiplier = TUNING.ACIDRAIN_DAMAGE_TIME * TUNING.ACIDRAIN_PERISHABLE_ROT_PERCENT
    local final_multiplier = math.clamp(acid_perish_time * perish_multiplier, 0, 1)
    local unsafe_percent = (1 - TUNING.ACIDRAIN_PERISHLOOT_BASESAFEPERCENT)
    local new_percentage = 1 - (unsafe_percent * final_multiplier)
    loot.components.perishable:SetPercent(new_percentage)
end

--
local function inspect_tree(inst)
    return (inst:HasTag("stump") and "CHOPPED")
        or (inst.treestate == TREESTATES.BLOOMING and "BLOOM")
        or ((inst._acid_reset_task ~= nil or
            (inst.components.acidinfusible ~= nil and
            inst.components.acidinfusible:IsInfused()))
            and "ACIDCOVERED")
        or nil
end

local function onspawnfn(inst, spawn)
    inst.AnimState:PlayAnimation("cough")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_spore_fart")
    local pos = inst:GetPosition()
    spawn.components.knownlocations:RememberLocation("home", pos)
    local radius = spawn:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
    local offset = FindWalkableOffset(pos, math.random() * TWOPI, radius, 8)
    if offset ~= nil then
        spawn.Physics:Teleport(pos.x + offset.x, 0, pos.z + offset.z)
    else
        spawn.Transform:SetPosition(pos.x, 0, pos.z)
    end
end

local REMOVABLE =
{
    ["log"] = true,
    ["blue_cap"] = true,
    ["red_cap"] = true,
    ["green_cap"] = true,
    ["charcoal"] = true,
}

local DECAYREMOVE_MUST_TAGS = { "_inventoryitem" }
local DECAYREMOVE_CANT_TAGS = { "INLIMBO", "fire" }
local function ontimerdone(inst, data)
    if data.name == "decay" then
        local x, y, z = inst.Transform:GetWorldPosition()
        if inst:IsAsleep() then
            -- before we disappear, clean up any crap left on the ground
            -- too many objects is as bad for server health as too few!
            local leftone = false
            local decay_remove_entities = TheSim:FindEntities(x, y, z, 6, DECAYREMOVE_MUST_TAGS, DECAYREMOVE_CANT_TAGS)
            for _, decay_remove_entity in ipairs(decay_remove_entities) do
                if REMOVABLE[decay_remove_entity.prefab] then
                    if leftone then
                        decay_remove_entity:Remove()
                    else
                        leftone = true
                    end
                end
            end
        else
            SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
        end
        inst:Remove()
    elseif data.name == "acidvisualsupdate" then
        try_acid_art_update(inst)
        inst.components.timer:StartTimer("acidvisualsupdate", TUNING.ACIDRAIN_MUSHTREE_UPDATE_TIME)
    end
end

local function DoGrowNextStage(inst)
    if not inst:HasTag("stump") then
        inst.components.growable:SetStage(inst.components.growable:GetNextStage())
    end
end

local function DoGrow(inst, tostage, targetscale)
    if tostage == 2 then
        inst.AnimState:PlayAnimation("change")
        inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_grow_1")
    elseif tostage == 3 then
        inst.AnimState:PlayAnimation("change")
        inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_grow_2")
    elseif tostage == 1 then
        inst.AnimState:PlayAnimation("shrink")
        inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_shrink")
    end
    inst.AnimState:PushAnimation("idle_loop", true)
    inst:DoTaskInTime(14 * FRAMES, DoGrowNextStage)
end

local growth_stages =
{
    {
        name = "short",
        time = function(inst)
            return GetRandomWithVariance(
                TUNING.EVERGREEN_GROW_TIME[1].base,
                TUNING.EVERGREEN_GROW_TIME[1].random
            )
        end,
        fn = function(inst)
            inst.Transform:SetScale(.9, .9, .9)
        end,
        growfn = function(inst)
            DoGrow(inst, 1, 0.9)
        end,
    },
    {
        name = "normal",
        time = function(inst)
            return GetRandomWithVariance(
                TUNING.EVERGREEN_GROW_TIME[2].base,
                TUNING.EVERGREEN_GROW_TIME[2].random
            )
        end,
        fn = function(inst)
            inst.Transform:SetScale(1, 1, 1)
        end,
        growfn = function(inst)
            DoGrow(inst, 2, 1.0)
        end,
    },
    {
        name = "tall",
        time = function(inst)
            return GetRandomWithVariance(
                TUNING.EVERGREEN_GROW_TIME[3].base,
                TUNING.EVERGREEN_GROW_TIME[3].random
            )
        end,
        fn = function(inst)
            inst.Transform:SetScale(1.1, 1.1, 1.1)
        end,
        growfn = function(inst)
            DoGrow(inst, 3, 1.1)
        end,
    },
}

local tree_data =
{
    small =
    { --Green
        bank = "mushroom_tree_small",
        build = "mushroom_tree_small",
        season = SEASONS.SPRING,
        bloom_build = "mushroom_tree_small_bloom",
        spore = "spore_small",
        icon = "mushroom_tree_small.png",
        loot = { "log", "green_cap" },
        work = TUNING.MUSHTREE_CHOPS_SMALL,
        lightradius = 1,
        lightcolour = { 146/255, 225/255, 146/255 },
    },
    medium =
    { --Red
        bank = "mushroom_tree_med",
        build = "mushroom_tree_med",
        season = SEASONS.SUMMER,
        bloom_build = "mushroom_tree_med_bloom",
        spore = "spore_medium",
        icon = "mushroom_tree_med.png",
        loot = { "log", "red_cap" },
        work = TUNING.MUSHTREE_CHOPS_MEDIUM,
        lightradius = 1.25,
        lightcolour = { 197/255, 126/255, 126/255 },
    },
    tall =
    { --Blue
        bank = "mushroom_tree",
        build = "mushroom_tree_tall",
        season = SEASONS.WINTER,
        bloom_build = "mushroom_tree_tall_bloom",
        spore = "spore_tall",
        icon = "mushroom_tree.png",
        loot = { "log", "log", "blue_cap" },
        work = TUNING.MUSHTREE_CHOPS_TALL,
        lightradius = 1.5,
        lightcolour = { 111/255, 111/255, 227/255 },
        webbable = true,
    },
}

local function onsave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or nil
    data.stump = inst:HasTag("stump") or nil
    data.treestate = inst.treestate
    if inst._last_acid_start_time then
        data.time_since_acid_infusion = GetTime() - inst._last_acid_start_time
    end
    data.acidrecoveryremaining = (inst._acid_reset_task ~= nil and GetTaskRemaining(inst._acid_reset_task)) or nil
end

local function CustomOnHaunt(inst)--, haunter)
    if not inst:HasTag("stump") and math.random() < TUNING.HAUNT_CHANCE_HALF then
        inst.components.growable:DoGrowth()
        return true
    end
    return false
end

--V2C: Not using an fx proxy because this was originally meant to be an
--     animated death state of the original entity so it would probably
--     look more consistent this way.
--     BTW this was done so that the burnt state can immediately remove
--     the original entity rather than creating edge case bugs while it
--     was still interactable during the crumbling animation.
local function makeburntfx(name, data, bloom)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBuild(bloom and data.bloom_build or data.build)
        inst.AnimState:SetBank(data.bank)
        inst.AnimState:PlayAnimation("chop_burnt")

        inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")

        inst:AddTag("FX")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        -- In case we're off screen and animation is asleep
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

        return inst
    end
end

local function StartSpores(inst)
    if not inst._sporetime then
        inst._sporetime = -1
        if not inst:IsAsleep() then
            inst.components.periodicspawner:Start()
        end
    end
end

local function StopSpores(inst)
    inst._sporetime = nil
    inst.components.periodicspawner:Stop()
end

local function onentitysleep(inst)
    if inst._sporetime then
        inst._sporetime = inst.components.periodicspawner.target_time or -1
    end
    inst.components.periodicspawner:Stop()
end

local function onentitywake(inst)
    if not inst._sporetime then
        return
    end

    inst.components.periodicspawner:Start()
    if inst._sporetime < 0 then
        local update_time_base = (inst.components.periodicspawner.target_time - GetTime())
        inst.components.periodicspawner:LongUpdate(math.random() * update_time_base)
    else
        local target_time = inst.components.periodicspawner.target_time
        if inst._sporetime < target_time then
            if inst._sporetime <= GetTime() then
                inst.components.periodicspawner:ForceNextSpawn()
            else
                inst.components.periodicspawner:LongUpdate(target_time - inst._sporetime)
            end
        end
        inst._sporetime = -1
    end
end

local function swapbuild(inst, treestate, build)
    inst._changetask = nil
    if not inst:HasTag("stump") then
        inst.AnimState:SetBuild(build)
        inst.treestate = treestate
        try_acid_art_update(inst)
        if treestate == TREESTATES.BLOOMING then
            StartSpores(inst)
        else
            StopSpores(inst)
        end
    end
end

local function forcespore(inst)
    if inst._sporetime ~= nil
            and inst.treestate == TREESTATES.BLOOMING
            and not (inst:IsAsleep() or inst:HasTag("burnt")) then
        inst.components.periodicspawner:ForceNextSpawn()
    end
end

local function startchange(inst, treestate, build, soundname)
    if inst:HasTag("stump") then
        inst._changetask = nil
    else
        inst.AnimState:PlayAnimation("change")
        inst.AnimState:PushAnimation("idle_loop", true)
        inst.SoundEmitter:PlaySound(soundname)
        inst._changetask = inst:DoTaskInTime(14 * FRAMES, swapbuild, treestate, build)
        if treestate == TREESTATES.BLOOMING then
            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), forcespore)
        end
    end
end

local function workcallback(inst, worker, workleft)
    if not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")
    end
    if workleft > 0 then
        inst.AnimState:PlayAnimation("chop")
        inst.AnimState:PushAnimation("idle_loop", true)
    end
    --V2C: different anims are played in workfinishcallback if workleft <= 0
end

local function CLIENT_OnSmokeNumberDirty(inst)
    if not inst._acidsmokes then return end

    local smoke_number = inst._smoke_number:value()
    for smoke_instance, symbol_index in pairs(inst._acidsmokes) do
        if smoke_number == 0 then
            smoke_instance:DoCustomHide()
        elseif smoke_number == 4 or smoke_number == symbol_index then
            smoke_instance:DoCustomShow()
        else
            smoke_instance:DoCustomHide()
        end
    end
end

local function CLIENT_OnBloomedDirty(inst)
    if not inst._acidsmokes then return end

    local bloomed = inst._bloomed:value()
    for smoke, symbol_index in pairs(inst._acidsmokes) do
        if bloomed then
            smoke.Follower:FollowSymbol(inst.GUID, "swap_acidglob_bloom"..symbol_index)
        else
            smoke.Follower:FollowSymbol(inst.GUID, "swap_acidglob"..symbol_index)
        end
    end
end

local function maketree(name, data, state)
    local function bloom_tree(inst, instant)
        if inst._changetask ~= nil then
            inst._changetask:Cancel()
        end
        if instant then
            swapbuild(inst, TREESTATES.BLOOMING, data.bloom_build)
        else
            inst._changetask = inst:DoTaskInTime(
                math.random() * 3 * TUNING.SEG_TIME,
                startchange,
                TREESTATES.BLOOMING,
                data.bloom_build,
                "dontstarve/cave/mushtree_tall_grow_3"
            )
        end
    end

    local function normal_tree(inst, instant)
        if inst._changetask ~= nil then
            inst._changetask:Cancel()
        end
        if instant then
            swapbuild(inst, TREESTATES.NORMAL, data.build)
        else
            inst._changetask = inst:DoTaskInTime(
                math.random() * 3 * TUNING.SEG_TIME,
                startchange,
                TREESTATES.NORMAL,
                data.build,
                "dontstarve/cave/mushtree_tall_shrink"
            )
        end
    end

    local function onisinseason(inst, isinseason)
        if isinseason then
            if inst.treestate ~= TREESTATES.BLOOMING then
                bloom_tree(inst, false)
            elseif inst._changetask ~= nil then
                inst._changetask:Cancel()
                inst._changetask = nil
            end
        elseif inst.treestate ~= TREESTATES.NORMAL then
            normal_tree(inst, false)
        elseif inst._changetask ~= nil then
            inst._changetask:Cancel()
            inst._changetask = nil
        end
    end

    local function makestump(inst)
        if inst:HasTag("stump") then
            return
        end

        if inst._changetask ~= nil then
            inst._changetask:Cancel()
            inst._changetask = nil
        end
        inst.components.timer:StopTimer("acidvisualsupdate")

        inst._is_stump = true

        RemovePhysicsColliders(inst)
        inst:AddTag("stump")
        inst:RemoveTag("shelter")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("burnable")
        MakeSmallPropagator(inst)
        MakeSmallBurnable(inst)
        inst.components.burnable:SetOnBurntFn(stump_burnt)
        inst.components.growable:StopGrowing()
        StopSpores(inst)

        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnWorkCallback(nil)
        inst.components.workable:SetOnFinishCallback(dig_up_stump)
        inst.components.workable:SetWorkLeft(1)
        inst.AnimState:PlayAnimation("idle_stump")

        inst.MiniMapEntity:SetIcon("mushroom_tree_stump.png")

        inst.Light:Enable(false)

        inst:StopWatchingWorldState("is"..data.season, onisinseason)

        if not inst.components.timer:TimerExists("decay") then
            inst.components.timer:StartTimer("decay",
                GetRandomWithVariance(
                    TUNING.MUSHTREE_REGROWTH.DEAD_DECAY_TIME,
                    TUNING.MUSHTREE_REGROWTH.DEAD_DECAY_TIME * 0.5
                )
            )
        end

        acid_reset(inst)
        inst:RemoveComponent("acidinfusible")
    end

    local function workfinishcallback(inst)--, worker)
        inst.components.lootdropper:DropLoot(inst:GetPosition())
        makestump(inst)
        inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

        inst.AnimState:PlayAnimation("fall")
        inst.AnimState:PushAnimation("idle_stump")
    end

    local function onload(inst, loaddata)
        if loaddata ~= nil then
            if loaddata.burnt then
                if loaddata.stump then
                    stump_burnt(inst)
                else
                    tree_burnt(inst)
                end
            elseif loaddata.stump then
                makestump(inst)
            else
                if loaddata.treestate == TREESTATES.NORMAL then
                    normal_tree(inst, true)
                    if TheWorld.state.season == data.season then
                        bloom_tree(inst, false)
                    end
                elseif loaddata.treestate == TREESTATES.BLOOMING then
                    bloom_tree(inst, true)
                    if TheWorld.state.season ~= data.season then
                        normal_tree(inst, false)
                    end
                end

                if data.acidrecoveryremaining then
                    acid_initialize(inst)
                    inst._acid_reset_task = inst:DoTaskInTime(data.acidrecoveryremaining, acid_reset)
                end
                if data.time_since_acid_infusion then
                    inst._last_acid_start_time = -data.time_since_acid_infusion
                end
            end
        end
    end

    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .25)

        inst.AnimState:SetBuild(data.build)
        inst.AnimState:SetBank(data.bank)
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.scrapbook_anim = "idle_loop"

        inst.MiniMapEntity:SetIcon(data.icon)

        inst.Light:SetFalloff(.5)
        inst.Light:SetIntensity(.8)
        inst.Light:SetRadius(data.lightradius)
        inst.Light:SetColour(unpack(data.lightcolour))

        inst:AddTag("shelter")
        inst:AddTag("mushtree")
        inst:AddTag("cavedweller")
        inst:AddTag("plant")
        inst:AddTag("tree")

        if data.webbable then
            inst:AddTag("webbable")
        end

        inst.scrapbook_specialinfo = "TREE"
        inst.scrapbook_deps = { "charcoal", data.spore }
        inst.scrapbook_hidesymbol = {}

        for i = 1, 3 do
            inst.AnimState:HideSymbol("swap_acidglob"..i)
            inst.AnimState:HideSymbol("swap_acidglob_bloom"..i)

            table.insert(inst.scrapbook_hidesymbol, "swap_acidglob"..i)
            table.insert(inst.scrapbook_hidesymbol, "swap_acidglob_bloom"..i)
        end

        inst._smoke_number = net_tinybyte(inst.GUID, "mushtree_"..name.."._smoke_number", "acidphasedirty")
        inst._bloomed = net_bool(inst.GUID, "mushtree_"..name.."._bloomed", "bloomeddirty")
        if not TheNet:IsDedicated() then
            inst._acidsmokes = {}
            MakeAcidSmokeForSymbol(inst, 1)
            MakeAcidSmokeForSymbol(inst, 2)
            MakeAcidSmokeForSymbol(inst, 3)
            inst:ListenForEvent("acidphasedirty", CLIENT_OnSmokeNumberDirty)
            inst:ListenForEvent("bloomeddirty", CLIENT_OnBloomedDirty)
            CLIENT_OnBloomedDirty(inst)
        end

        inst:SetPrefabName(name)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        local color = .5 + math.random() * .5
        inst.AnimState:SetMultColour(color, color, color, 1)
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

        MakeMediumPropagator(inst)
        local burnable = MakeLargeBurnable(inst)
        burnable:SetFXLevel(5)
        burnable:SetOnBurntFn(tree_burnt)

        --
        local acidinfusible = inst:AddComponent("acidinfusible")
        acidinfusible:SetFXLevel()
        acidinfusible:SetOnInfuseFn(OnAcidInfused)
        acidinfusible:SetOnUninfuseFn(OnAcidUninfused)

        --
        local growable = inst:AddComponent("growable")
        growable.stages = growth_stages
        growable:SetStage(math.random(3))
        growable.loopstages = true
        growable.growonly = true
        growable.magicgrowable = true
        growable:StartGrowing()

        --
        local inspectable = inst:AddComponent("inspectable")
        inspectable.getstatus = inspect_tree

        --
        local lootdropper = inst:AddComponent("lootdropper")
        lootdropper:SetLoot(data.loot)

        --
        local periodicspawner = inst:AddComponent("periodicspawner")
        periodicspawner:SetPrefab(data.spore)
        periodicspawner:SetOnSpawnFn(onspawnfn)
        periodicspawner:SetDensityInRange(TUNING.MUSHSPORE_MAX_DENSITY_RAD, TUNING.MUSHSPORE_MAX_DENSITY)
        StopSpores(inst)

        --
        local plantregrowth = inst:AddComponent("plantregrowth")
        plantregrowth:SetRegrowthRate(TUNING.MUSHTREE_REGROWTH.OFFSPRING_TIME)
        plantregrowth:SetProduct(name)
        plantregrowth:SetSearchTag("mushtree")

        --
        local simplemagicgrower = inst:AddComponent("simplemagicgrower")
        simplemagicgrower:SetLastStage(#inst.components.growable.stages-1)

        --
        inst:AddComponent("timer")

        --
        local workable = inst:AddComponent("workable")
        workable:SetWorkAction(ACTIONS.CHOP)
        workable:SetWorkLeft(data.work)
        workable:SetOnWorkCallback(workcallback)
        workable:SetOnFinishCallback(workfinishcallback)

        --
        MakeHauntableIgnite(inst)
        AddHauntableCustomReaction(inst, CustomOnHaunt)

        --
        inst:ListenForEvent("loot_prefab_spawned", acidcovered_on_loot_prefab_spawned)
        inst:ListenForEvent("timerdone", ontimerdone)

        --
        inst.treestate = TREESTATES.NORMAL
        inst._webbable = data.webbable

        inst._Bloom = bloom_tree
        inst._Normal = normal_tree

        inst.OnEntitySleep = onentitysleep
        inst.OnEntityWake = onentitywake
        inst.OnSave = onsave
        inst.OnLoad = onload

        if state == "stump" then
            makestump(inst)
        else
            inst:WatchWorldState("is"..data.season, onisinseason)
            if TheWorld.state.season == data.season then
                if inst.treestate ~= TREESTATES.BLOOMING then
                    bloom_tree(inst, true)
                end
            elseif inst.treestate ~= TREESTATES.NORMAL then
                normal_tree(inst, true)
            end
        end

        return inst
    end
end

local treeprefabs = {}
function treeset(name, data, build, bloombuild)
    local buildasset = Asset("ANIM", build)
    local bloombuildasset = Asset("ANIM", bloombuild)
    local assets =
    {
        buildasset,
        bloombuildasset,
        Asset("MINIMAP_IMAGE", data.icon),
        Asset("MINIMAP_IMAGE", "mushroom_tree_stump"),
    }

    local prefabs =
    {
        "log",
        "blue_cap",
        "green_cap",
        "red_cap",
        "charcoal",
        "ash",
        data.spore,
        name.."_stump",
        name.."_burntfx",
        name.."_bloom_burntfx",
        "small_puff",
        "acidsmoke_endless",
    }

    table.insert(treeprefabs, Prefab(name, maketree(name, data), assets, prefabs))
    table.insert(treeprefabs, Prefab(name.."_stump", maketree(name, data, "stump"), assets, prefabs))
    table.insert(treeprefabs, Prefab(name.."_burntfx", makeburntfx(name, data, false), { buildasset }))
    table.insert(treeprefabs, Prefab(name.."_bloom_burntfx", makeburntfx(name, data, true), { bloombuildasset }))
end

treeset("mushtree_tall", tree_data.tall, "anim/mushroom_tree_tall.zip", "anim/mushroom_tree_tall_bloom.zip")
treeset("mushtree_medium", tree_data.medium, "anim/mushroom_tree_med.zip", "anim/mushroom_tree_med_bloom.zip")
treeset("mushtree_small", tree_data.small, "anim/mushroom_tree_small.zip", "anim/mushroom_tree_small_bloom.zip")

return unpack(treeprefabs)
