local assets =
{
    Asset("ANIM", "anim/bee_queen_hive.zip"),
}

local base_prefabs =
{
    "beequeenhivegrown",
}

local prefabs =
{
    "beequeen",
    "honey",
    "honeycomb",
    "honey_splash",
}

local PHYS_RAD_LRG = 1.9
local PHYS_RAD_MED = 1.5
local PHYS_RAD_SML = .9

local function CreatePhysicsEntity(rad)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddPhysics()
    inst.Physics:SetMass(999999)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCapsule(rad, 2)

    inst:DoTaskInTime(0, inst.Remove)

    return inst
end

local function OnPhysRadDirty(inst)
    if inst.physrad:value() >= 1 and inst.physrad:value() <= 3 then
        CreatePhysicsEntity(
            (inst.physrad:value() >= 3 and PHYS_RAD_LRG) or
            (inst.physrad:value() == 2 and PHYS_RAD_MED) or
            PHYS_RAD_SML
        ).Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function OnCleanupPhysTask(inst)
    inst.phystask = nil
    inst.physrad:set_local(0)
end

local function PushPhysRad(inst, rad)
    if inst.phystask ~= nil then
        inst.phystask:Cancel()
        inst.physrad:set_local(0)
    end
    inst.phystask = inst:DoTaskInTime(.5, OnCleanupPhysTask)
    inst.physrad:set(rad)
    OnPhysRadDirty(inst)
end

-------------------------------------------------------------------

local function OnHoneyTask(inst, honeylevel)
    inst._honeytask = nil
    honeylevel = math.clamp(honeylevel, 0, 3)
    for i = 0, 3 do
        if i == honeylevel then
            inst.AnimState:Show("honey"..tostring(i))
        else
            inst.AnimState:Hide("honey"..tostring(i))
        end
    end
end

local function SetHoneyLevel(inst, honeylevel, delay)
    if inst._honeytask ~= nil then
        inst._honeytask:Cancel()
    end

    if delay ~= nil then
        OnHoneyTask(inst, honeylevel - 1)
        inst._honeytask = inst:DoTaskInTime(delay, OnHoneyTask, honeylevel)
    else
        inst._honeytask = nil
        OnHoneyTask(inst, honeylevel)
    end
end

local function StopHiveGrowthTimer(inst)
    inst.components.timer:StopTimer("hivegrowth1")
    inst.components.timer:StopTimer("hivegrowth2")
    inst.components.timer:StopTimer("hivegrowth")
    inst.components.timer:StopTimer("shorthivegrowth")
    inst.components.timer:StopTimer("firsthivegrowth")
    inst.AnimState:PlayAnimation("hole_idle")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    SetHoneyLevel(inst, 0)
    inst.queenkilled = false
end

local function StartHiveGrowthTimer(inst)
    if inst.queenkilled then
        StopHiveGrowthTimer(inst)
        inst.components.timer:StartTimer("hivegrowth1", TUNING.BEEQUEEN_RESPAWN_TIME / 3)
    else
        StopHiveGrowthTimer(inst)
        inst.components.timer:StartTimer("shorthivegrowth", 10)
    end
end

local function OnQueenRemoved(queen)
    if queen.hivebase ~= nil then
        local otherqueen = queen.hivebase.components.entitytracker:GetEntity("queen")
        if (otherqueen == nil or otherqueen == queen) and
            queen.hivebase.components.entitytracker:GetEntity("hive") == nil then
            StartHiveGrowthTimer(queen.hivebase)
        end
    end
end

local function DoSpawnQueen(inst, worker, x1, y1, z1)
    local x, y, z = inst.Transform:GetWorldPosition()
    local hivebase = inst.hivebase
    inst:Remove()

    local queen = SpawnPrefab("beequeen")
    queen.Transform:SetPosition(x, y, z)
    queen:ForceFacePoint(x1, y1, z1)

    if worker:IsValid() and
        worker.components.health ~= nil and
        not worker.components.health:IsDead() and
        not worker:HasTag("playerghost") then
        queen.components.combat:SetTarget(worker)
    end

    queen.sg:GoToState("emerge")
    if hivebase ~= nil then
        queen.hivebase = hivebase
        StopHiveGrowthTimer(hivebase)
        hivebase.components.entitytracker:TrackEntity("queen", queen)
        hivebase:ListenForEvent("onremove", OnQueenRemoved, queen)
    end
end

local function CalcHoneyLevel(workleft)
    return math.clamp(3 + math.ceil((workleft - TUNING.BEEQUEEN_SPAWN_MAX_WORK) * .5), 0, 3)
end

local function RefreshHoneyState(inst)
    SetHoneyLevel(inst, CalcHoneyLevel(inst.components.workable.workleft))
end

local function OnWorked(inst, worker, workleft)
    if not inst.components.workable.workable then
        return
    end

    inst.components.timer:StopTimer("hiveregen")

    if workleft < 1 then
        inst.components.workable:SetWorkLeft(TUNING.BEEQUEEN_SPAWN_WORK_THRESHOLD > 0 and 1 or 0)
    end

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_hit")
    inst.AnimState:PlayAnimation("large_hit")
    SpawnPrefab("honey_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())

    if worker ~= nil and worker:IsValid() and
        worker.components.health ~= nil and not worker.components.health:IsDead() and
        worker:HasTag("player") and not worker:HasTag("playerghost") then

        if TUNING.BEEQUEEN_SPAWN_WORK_THRESHOLD > 0 then
            local spawnchance = workleft < TUNING.BEEQUEEN_SPAWN_WORK_THRESHOLD and math.min(.8, 1 - workleft / TUNING.BEEQUEEN_SPAWN_WORK_THRESHOLD) or 0
            if math.random() < spawnchance then
                inst.components.workable:SetWorkable(false)
                SetHoneyLevel(inst, 0)
                local x, y, z = worker.Transform:GetWorldPosition()
                inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), DoSpawnQueen, worker, x, y, z)
                return
            end
        end

        local lootscale = workleft / TUNING.BEEQUEEN_SPAWN_MAX_WORK
        local rnd = lootscale > 0 and math.random() / lootscale or 1
        local loot =
            (rnd < .01 and "honeycomb") or
            (rnd < .5 and "honey") or
            nil

        if loot ~= nil then
            LaunchAt(SpawnPrefab(loot), inst, worker, 1, 3.5, 1)
        end
    end

    inst.AnimState:PushAnimation("large", false)
    RefreshHoneyState(inst)

    inst.components.timer:StartTimer("hiveregen", 4 * TUNING.SEG_TIME)
end

local function OnHiveRegenTimer(inst, data)
    if data.name == "hiveregen" and
        inst.components.workable.workable and
        inst.components.workable.workleft < TUNING.BEEQUEEN_SPAWN_MAX_WORK then
        local oldhoneylevel = CalcHoneyLevel(inst.components.workable.workleft)
        inst.components.workable:SetWorkLeft(inst.components.workable.workleft + 1)
        local newhoneylevel = CalcHoneyLevel(inst.components.workable.workleft)
        if inst.components.workable.workleft < TUNING.BEEQUEEN_SPAWN_MAX_WORK then
            inst.components.timer:StartTimer("hiveregen", TUNING.SEG_TIME)
        end
        if oldhoneylevel ~= newhoneylevel and not inst:IsAsleep() then
            inst.AnimState:PlayAnimation("transition")
            inst.AnimState:PushAnimation("large", false)
            SetHoneyLevel(inst, newhoneylevel, 10 * FRAMES)
        else
            SetHoneyLevel(inst, newhoneylevel)
        end
    end
end

local function EnableBase(inst, enable)
    inst.Physics:SetCapsule(PHYS_RAD_SML, 2)
    inst.Physics:SetActive(enable)
    inst.MiniMapEntity:SetEnabled(enable)
    inst.AnimState:PlayAnimation("hole_idle")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    SetHoneyLevel(inst, 0)
    if enable then
        inst:Show()
    else
        inst:Hide()
    end
end

local function OnHiveRemoved(hive)
    if hive.hivebase ~= nil then
        local otherhive = hive.hivebase.components.entitytracker:GetEntity("hive")
        if otherhive == nil or otherhive == hive then
            EnableBase(hive.hivebase, true)

            if hive.hivebase.components.entitytracker:GetEntity("queen") == nil then
                StartHiveGrowthTimer(hive.hivebase)
            end
        end
    end
end

local function OnHiveShortGrowAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("grow_hole_to_small") then
        inst.Physics:SetCapsule(PHYS_RAD_MED, 2)
        PushPhysRad(inst, 2)
        inst.AnimState:PlayAnimation("grow_small_to_medium")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
        return
    elseif inst.AnimState:IsCurrentAnimation("grow_small_to_medium") then
        inst.Physics:SetCapsule(PHYS_RAD_LRG, 2)
        PushPhysRad(inst, 3)
        inst.AnimState:PlayAnimation("grow_medium_to_large")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
        return
    elseif inst.AnimState:IsCurrentAnimation("grow_medium_to_large") then
        inst.AnimState:PlayAnimation("large")
    end
    inst.components.workable:SetWorkable(true)
    inst:RemoveEventCallback("animover", OnHiveShortGrowAnimOver)
end

local function OnHiveLongGrowAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("grow_hole_to_small") then
        inst.Physics:SetCapsule(PHYS_RAD_MED, 2)
        PushPhysRad(inst, 2)
        inst.AnimState:PlayAnimation("grow_small_to_medium")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
        SetHoneyLevel(inst, 2, 4 * FRAMES)
        return
    elseif inst.AnimState:IsCurrentAnimation("grow_small_to_medium") then
        inst.Physics:SetCapsule(PHYS_RAD_LRG, 2)
        PushPhysRad(inst, 3)
        inst.AnimState:PlayAnimation("grow_medium_to_large")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
        SetHoneyLevel(inst, 3, 7 * FRAMES)
        return
    elseif inst.AnimState:IsCurrentAnimation("grow_medium_to_large") then
        inst.AnimState:PlayAnimation("large")
        SetHoneyLevel(inst, 3)
    end
    inst.components.workable:SetWorkable(true)
    inst:RemoveEventCallback("animover", OnHiveLongGrowAnimOver)
end

local function OnHiveGrowthTimer(inst, data)
    if data.name == "hivegrowth" or
        data.name == "shorthivegrowth" or
        data.name == "firsthivegrowth" then

        EnableBase(inst, false)

        local hive = SpawnPrefab("beequeenhivegrown")
        hive.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if inst:IsAsleep() then
            PushPhysRad(hive, 3)
            if data.name == "shorthivegrowth" then
                hive.components.workable:SetWorkLeft(1)
                hive.components.timer:StartTimer("hiveregen", 8 * TUNING.SEG_TIME)
                SetHoneyLevel(hive, 0)
            end
        else
            if data.name == "hivegrowth" then
                hive.AnimState:PlayAnimation("grow_medium_to_large")
                hive:ListenForEvent("animover", OnHiveLongGrowAnimOver)
                PushPhysRad(hive, 3)
                SetHoneyLevel(hive, 3, 7 * FRAMES)
            elseif data.name == "shorthivegrowth" then
                hive.Physics:SetCapsule(PHYS_RAD_SML, 2)
                hive.AnimState:PlayAnimation("grow_hole_to_small")
                hive:ListenForEvent("animover", OnHiveShortGrowAnimOver)
                hive.components.workable:SetWorkLeft(1)
                hive.components.timer:StartTimer("hiveregen", 8 * TUNING.SEG_TIME)
                SetHoneyLevel(hive, 0)
            else--if data.name == "firsthivegrowth" then
                hive.Physics:SetCapsule(PHYS_RAD_SML, 2)
                hive.AnimState:PlayAnimation("grow_hole_to_small")
                hive:ListenForEvent("animover", OnHiveLongGrowAnimOver)
                SetHoneyLevel(hive, 1)
            end
            hive.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
            hive.components.workable:SetWorkable(false)
        end

        hive.hivebase = inst
        inst.components.entitytracker:TrackEntity("hive", hive)
        inst:ListenForEvent("onremove", OnHiveRemoved, hive)
    elseif data.name == "hivegrowth1" then
        if inst:IsAsleep() then
            inst.AnimState:PlayAnimation("small")
        else
            inst.AnimState:PlayAnimation("grow_hole_to_small")
            inst.AnimState:PushAnimation("small", false)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
        end
        inst.AnimState:SetLayer(LAYER_WORLD)
        inst.AnimState:SetSortOrder(0)
        SetHoneyLevel(inst, 1)
        inst.components.timer:StartTimer("hivegrowth2", TUNING.BEEQUEEN_RESPAWN_TIME / 3)
    elseif data.name == "hivegrowth2" then
        if inst:IsAsleep() then
            inst.AnimState:PlayAnimation("medium")
            SetHoneyLevel(inst, 2)
        else
            inst.AnimState:PlayAnimation("grow_small_to_medium")
            inst.AnimState:PushAnimation("medium", false)
            SetHoneyLevel(inst, 2, 4 * FRAMES)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hive_grow")
        end
        inst.AnimState:SetLayer(LAYER_WORLD)
        inst.AnimState:SetSortOrder(0)
        inst.Physics:SetCapsule(PHYS_RAD_MED, 2)
        PushPhysRad(inst, 2)
        inst.components.timer:StartTimer("hivegrowth", TUNING.BEEQUEEN_RESPAWN_TIME / 3)
    end
end

local function OnBaseLoadPostPass(inst, newents, data)
    local hive = inst.components.entitytracker:GetEntity("hive")
    if hive ~= nil then
        hive.hivebase = inst
        StopHiveGrowthTimer(inst)
        EnableBase(inst, false)
        inst:ListenForEvent("onremove", OnHiveRemoved, hive)
    end

    local queen = inst.components.entitytracker:GetEntity("queen")
    if queen ~= nil then
        queen.hivebase = inst
        StopHiveGrowthTimer(inst)
        inst:ListenForEvent("onremove", OnQueenRemoved, queen)
    end
end

local function OnBaseLoad(inst, data)
    if data ~= nil and data.queenkilled then
        StopHiveGrowthTimer(inst)
        inst.queenkilled = true
        StartHiveGrowthTimer(inst)
    end

    if inst.components.timer:TimerExists("hivegrowth") then
        inst.AnimState:PlayAnimation("medium")
        inst.AnimState:SetLayer(LAYER_WORLD)
        inst.AnimState:SetSortOrder(0)
        inst.Physics:SetCapsule(PHYS_RAD_MED, 2)
        SetHoneyLevel(inst, 2)
    elseif inst.components.timer:TimerExists("hivegrowth2") then
        inst.AnimState:PlayAnimation("small")
        inst.AnimState:SetLayer(LAYER_WORLD)
        inst.AnimState:SetSortOrder(0)
        SetHoneyLevel(inst, 1)
    elseif inst.components.timer:TimerExists("hivegrowth1")
        or inst.components.timer:TimerExists("shorthivegrowth") then
        --don't need cuz pristine state
        --inst.AnimState:PlayAnimation("hole_idle")
        --inst.AnimState:SetLayer(LAYER_BACKGROUND)
        --inst.AnimState:SetSortOrder(3)
        --SetHoneyLevel(inst, 0)
    else
        return
    end
    inst.components.timer:StopTimer("firsthivegrowth")
end

local function OnBaseSave(inst, data)
    data.queenkilled = inst.queenkilled or nil
end

local function BaseGetStatus(inst)
    return not inst.AnimState:IsCurrentAnimation("hole_idle") and "GROWING" or nil
end

local function BaseDisplayNameFn(inst)
    return (not inst:IsValid() or inst.AnimState:IsCurrentAnimation("hole_idle")) and STRINGS.NAMES.BEEQUEENHIVE or STRINGS.NAMES.BEEQUEENHIVEGROWING
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, PHYS_RAD_LRG)

    inst:AddTag("event_trigger")
    inst:AddTag("antlion_sinkhole_blocker")

    inst.AnimState:SetBank("bee_queen_hive")
    inst.AnimState:SetBuild("bee_queen_hive")
    inst.AnimState:PlayAnimation("large")
    inst.AnimState:Hide("honey0")
    inst.AnimState:Hide("honey1")
    inst.AnimState:Hide("honey2")

    inst.Transform:SetScale(1.4, 1.4, 1.4)

    inst.scrapbook_anim ="large"
    inst.scrapbook_specialinfo ="BEEQUEENHIVE"

    inst.MiniMapEntity:SetIcon("beequeenhivegrown.png")

    inst.physrad = net_tinybyte(inst.GUID, "beequeenhivegrown.physrad", "physraddirty")

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(200)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("physraddirty", OnPhysRadDirty)

        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnHiveRegenTimer)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetMaxWork(TUNING.BEEQUEEN_SPAWN_MAX_WORK)
    inst.components.workable:SetWorkLeft(TUNING.BEEQUEEN_SPAWN_MAX_WORK)
    inst.components.workable.savestate = true

    MakeHauntableWork(inst)

    inst.OnLoad = RefreshHoneyState

    return inst
end

local function base_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    --MakeObstaclePhysics(inst, 1)
    ----------------------------------------------------
    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    --inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCapsule(PHYS_RAD_SML, 2)
    ----------------------------------------------------

    inst.AnimState:SetBank("bee_queen_hive")
    inst.AnimState:SetBuild("bee_queen_hive")
    inst.AnimState:PlayAnimation("hole_idle")
    inst.AnimState:Hide("honey1")
    inst.AnimState:Hide("honey2")
    inst.AnimState:Hide("honey3")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.scrapbook_proxy ="beequeenhivegrown"

    inst.Transform:SetScale(1.4, 1.4, 1.4)

    inst.MiniMapEntity:SetIcon("beequeenhive.png")

    inst.displaynamefn = BaseDisplayNameFn

    inst.physrad = net_tinybyte(inst.GUID, "beequeenhive.physrad", "physraddirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("physraddirty", OnPhysRadDirty)

        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = BaseGetStatus

    inst:AddComponent("timer")
    inst.queenkilled = false
    inst.components.timer:StartTimer("firsthivegrowth", 10)
    inst:ListenForEvent("timerdone", OnHiveGrowthTimer)

    inst:AddComponent("entitytracker")

    inst.OnLoadPostPass = OnBaseLoadPostPass
    inst.OnLoad = OnBaseLoad
    inst.OnSave = OnBaseSave

    return inst
end

return Prefab("beequeenhive", base_fn, assets, base_prefabs),
    Prefab("beequeenhivegrown", fn, assets, prefabs)
