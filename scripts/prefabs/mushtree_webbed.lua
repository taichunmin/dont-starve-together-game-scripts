local assets =
{
    Asset("ANIM", "anim/mushroom_tree_webbed.zip"),
    Asset("MINIMAP_IMAGE", "mushroom_tree_webbed"),
}

local prefabs =
{
    "log",
    "blue_cap",
    "charcoal",
    "ash",
    "silk",
    "mushtree_tall_webbed_burntfx",
    "acidsmoke_endless",
}

SetSharedLootTable("mushtree_tall_webbed",
{
    { "log", 1.0 },
    { "silk", 1.0 },
    { "silk", 0.3 },
    { "silk", 0.3 },
})

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

        for i = 1, 3 do
            local should_show = ((phase == 1 and i == inst._phase1_show) or (phase > 1))

            local swap_name = "swap_acidglob"..i
            if should_show then
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
    if not inst._acid_art_update_task then
        inst._acid_art_update_task = inst:DoPeriodicTask(
            TUNING.ACIDRAIN_MUSHTREE_UPDATE_TIME,
            try_acid_art_update,
            0.5 + 4.5*math.random()
        )
    end
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
    if inst._acid_art_update_task then
        inst._acid_art_update_task:Cancel()
        inst._acid_art_update_task = nil
    end
end

local function OnAcidUninfused(inst)
    local _last_acidrain_start_time = inst._last_acid_start_time or 0
    local acidrain_time_passed = (GetTime() - _last_acidrain_start_time)

    inst._acid_reset_task = inst:DoTaskInTime(acidrain_time_passed, acid_reset)
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

--
local function tree_burnt(inst)
    inst.components.lootdropper:SpawnLootPrefab("ash")
    if math.random() < .5 then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    SpawnPrefab("mushtree_tall_webbed_burntfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function inspect_tree(inst)
    return ((inst._acid_reset_task ~= nil or
            (inst.components.acidinfusible ~= nil and
            inst.components.acidinfusible:IsInfused()))
            and "ACIDCOVERED")
        or nil
end

local SPIDERDEN_TAGS = { "spiderden" }
local function workcallback(inst, worker, workleft)
    if not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")
    end

    local pos = inst:GetPosition()
    local dens = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.MUSHTREE_WEBBED_SPIDER_RADIUS, SPIDERDEN_TAGS)
    if #dens > 0 then
        local creepactivate_data = {target = worker}
        for _, den in ipairs(dens) do
            den:PushEvent("creepactivate", creepactivate_data)
        end
    end

    if workleft <= 0 then
        inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

        inst.AnimState:PlayAnimation("fall")

        inst.components.lootdropper:DropLoot(pos)
        inst:ListenForEvent("animover", inst.Remove)
    else
        inst.AnimState:PlayAnimation("chop")
        inst.AnimState:PushAnimation("idle_loop", true)
    end
end

local function onsave(inst, data)
    data.burnt = (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or nil
    if inst._last_acid_start_time then
        data.time_since_acid_infusion = GetTime() - inst._last_acid_start_time
    end
    data.acidrecoveryremaining = (inst._acid_reset_task ~= nil and GetTaskRemaining(inst._acid_reset_task)) or nil
end

local function onload(inst, data)
    if data then
        if data.burnt then
            tree_burnt(inst)
        else
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

local function burntfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("mushroom_tree_webbed")
    inst.AnimState:SetBank("mushroom_tree_webbed")
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.AnimState:SetBuild("mushroom_tree_webbed")
    inst.AnimState:SetBank("mushroom_tree_webbed")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.MiniMapEntity:SetIcon("mushroom_tree_webbed.png")

    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(.8)
    inst.Light:SetColour(111/255, 111/255, 227/255)

    inst:AddTag("shelter")
    inst:AddTag("mushtree")
    inst:AddTag("webbed")
    inst:AddTag("cavedweller")
    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.scrapbook_specialinfo = "TREE"
    inst.scrapbook_hidesymbol = {}

    for i = 1, 3 do
        inst.AnimState:HideSymbol("swap_acidglob"..i)
        table.insert(inst.scrapbook_hidesymbol, "swap_acidglob"..i)
    end

    inst._smoke_number = net_tinybyte(inst.GUID, "mushtree_tall_webbed._smoke_number", "acidphasedirty")
    if not TheNet:IsDedicated() then
        inst._acidsmokes = {}
        MakeAcidSmokeForSymbol(inst, 1)
        MakeAcidSmokeForSymbol(inst, 2)
        MakeAcidSmokeForSymbol(inst, 3)
        inst:ListenForEvent("acidphasedirty", CLIENT_OnSmokeNumberDirty)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    local color = 0.5 * (1 + math.random())
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
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("mushtree_tall_webbed")

    --
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = inspect_tree

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.CHOP)
    workable:SetWorkLeft(math.ceil(TUNING.MUSHTREE_CHOPS_TALL * .5))
    workable:SetOnWorkCallback(workcallback)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("mushtree_tall_webbed", fn, assets, prefabs),
    Prefab("mushtree_tall_webbed_burntfx", burntfxfn, assets)
