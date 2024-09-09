local assets =
{
    Asset("ANIM", "anim/toadstool_actions.zip"),
    Asset("ANIM", "anim/toadstool_build.zip"),
    Asset("ANIM", "anim/toadstool_dark_build.zip"),
    Asset("MINIMAP_IMAGE", "toadstool_hole"),
    Asset("MINIMAP_IMAGE", "toadstool_cap_dark"),
}

local assets_absorbfx =
{
    Asset("ANIM", "anim/toadstool_actions.zip"),
    Asset("ANIM", "anim/toadstool_build.zip"),
}

local assets_releasefx =
{
    Asset("ANIM", "anim/canary.zip"),
    Asset("ANIM", "anim/canary_build.zip"),
}

local prefabs =
{
    "toadstool",
    "toadstool_dark",
    "toadstool_cap_absorbfx",
    "toadstool_cap_releasefx",
}

local function OnRemoveFXEntity(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent:IsValid() then
        parent.AnimState:OverrideMultColour(1, 1, 1, 1)
    end
end

local function OnFXUpdate(inst, parent)
    local k = 1 - inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
    k = 1 - k * k
    parent.AnimState:OverrideMultColour(k, k, k, 1)
end

local function OnFXEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        parent.AnimState:OverrideMultColour(0, 0, 0, 1)
        inst:DoPeriodicTask(0, OnFXUpdate, nil, parent)
    end
end

local function setnormal(inst, instant)
    inst.components.timer:StopTimer("darktimer")
    if inst._dark:value() then
        inst._dark:set(false)
        if not instant then
            local fx = SpawnPrefab("toadstool_cap_releasefx")
            fx.entity:SetParent(inst.entity)
            if not TheNet:IsDedicated() then
                OnFXEntityReplicated(fx)
            end
        end
        inst.AnimState:SetBuild("toadstool_build")
        if inst._state:value() > 0 then
            inst.MiniMapEntity:SetIcon("toadstool_cap.png")
        end
    end
end

local function setdark(inst, duration, instant)
    if not inst._dark:value() then
        inst._dark:set(true)
        inst.AnimState:SetBuild("toadstool_dark_build")
        if inst._state:value() > 0 then
            inst.MiniMapEntity:SetIcon("toadstool_cap_dark.png")
        end
    end
    if not instant then
        local fx = SpawnPrefab("toadstool_cap_absorbfx")
        fx.entity:SetParent(inst.entity)
        if not TheNet:IsDedicated() then
            OnFXEntityReplicated(fx)
        end
    end
    local darktime = inst.components.timer:GetTimeLeft("darktimer")
    if darktime == nil then
        inst.components.timer:StartTimer("darktimer", duration)
    elseif darktime < duration then
        inst.components.timer:StopTimer("darktimer")
        inst.components.timer:StartTimer("darktimer", duration)
    end
end

local function onabsorbpoison(inst)--, data)
    setdark(inst, TUNING.TOTAL_DAY_TIME, inst:IsAsleep())
end

local function onworked(inst, worker)
    if not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")
    end
    inst.AnimState:PlayAnimation("mushroom_toad_hit")
end

local function tracktoad(inst, toadstool)
    local function onremovetoad(toadstool)
        if inst._state:value() == 0 then
            inst.components.timer:StartTimer(toadstool.prefab == "toadstool_dark" and "respawndark" or "respawn", 2 + math.random())
        end
    end
    inst:ListenForEvent("onremove", onremovetoad, toadstool)
    inst:ListenForEvent("death", function(toadstool)
        inst:RemoveEventCallback("onremove", onremovetoad, toadstool)
        if inst.components.entitytracker:GetEntity("toadstool") == toadstool then
            inst.components.entitytracker:ForgetEntity("toadstool")
        end
        inst:PushEvent("toadstoolkilled", toadstool)
    end, toadstool)
end

local setstate

local function onspawntoad(inst)
    inst:RemoveEventCallback("animover", onspawntoad)
    inst.SoundEmitter:PlaySound("dontstarve/common/mushroom_up")

    local toadstool = SpawnPrefab(inst._dark:value() and "toadstool_dark" or "toadstool")
    inst.components.entitytracker:TrackEntity("toadstool", toadstool)
    tracktoad(inst, toadstool)
    setstate(inst, 0)

    toadstool.Transform:SetPosition(inst.Transform:GetWorldPosition())
    toadstool.sg:GoToState("surface")
end

local function onworkfinished(inst)
    if inst.components.workable.workable then
        inst.components.workable:SetWorkable(false)
        if inst.AnimState:IsCurrentAnimation("mushroom_toad_hit") then
            inst:ListenForEvent("animover", onspawntoad)
        else
            onspawntoad(inst)
        end
    end
end

local function ongrown(inst)
    inst:RemoveEventCallback("animover", ongrown)
    inst.MiniMapEntity:SetIcon(inst._dark:value() and "toadstool_cap_dark.png" or "toadstool_cap.png")
    inst.AnimState:PlayAnimation("mushroom_toad_idle_loop", true)
    inst:AddComponent("workable")
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnWorkCallback(onworked)
    inst.components.workable:SetOnFinishCallback(onworkfinished)
end

local function ongrowing(inst)
    inst:RemoveEventCallback("animqueueover", ongrowing)
    inst.SoundEmitter:PlaySound("dontstarve/common/mushroom_up")
    inst.AnimState:PlayAnimation("spawn_appear_mushroom")
    inst:ListenForEvent("animover", ongrown)
end

local function ontimerdone(inst, data)
    if inst._state:value() == 0 then
        if data.name == "respawn" then
            setstate(inst, 2)
        elseif data.name == "respawndark" then
            setstate(inst, 2)
            setdark(inst, TUNING.TOTAL_DAY_TIME, true)
        end
    elseif data.name == "darktimer" then
        setnormal(inst, inst:IsAsleep())
    end
end

setstate = function(inst, state)
    state = (state == 1 or state == 2) and state or 0
    if state ~= inst._state:value() then
        if inst._state:value() == 0 then
            inst.components.timer:StopTimer("respawn")
            inst:ListenForEvent("poisonburst", onabsorbpoison)
        elseif inst._state:value() == 2 then
            if inst.components.workable ~= nil then
                inst:RemoveComponent("workable")
                inst:RemoveEventCallback("animover", onspawntoad)
            else
                inst:RemoveEventCallback("animqueueover", ongrowing)
                inst:RemoveEventCallback("animover", ongrown)
            end
        end
        if state == 0 then
            inst:RemoveEventCallback("poisonburst", onabsorbpoison)
            setnormal(inst, true)
            inst.MiniMapEntity:SetIcon("toadstool_hole.png")
            inst.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.AnimState:SetSortOrder(3)
            inst.AnimState:PlayAnimation("picked")
        elseif state == 1 then
            inst.MiniMapEntity:SetIcon(inst._dark:value() and "toadstool_cap_dark.png" or "toadstool_cap.png")
            inst.AnimState:SetLayer(LAYER_WORLD)
            inst.AnimState:SetSortOrder(0)
            inst.AnimState:PlayAnimation("inground")
        elseif inst:IsAsleep() or POPULATING then
            inst.AnimState:SetLayer(LAYER_WORLD)
            inst.AnimState:SetSortOrder(0)
            ongrown(inst)
        elseif inst._state:value() == 0 then
            inst.AnimState:SetLayer(LAYER_WORLD)
            inst.AnimState:SetSortOrder(0)
            inst.AnimState:PlayAnimation("open_inground")
            inst:ListenForEvent("animqueueover", ongrowing)
        else
            inst.AnimState:PlayAnimation("inground_pre")
            inst.AnimState:PushAnimation("open_inground", false)
            inst:ListenForEvent("animqueueover", ongrowing)
        end
        inst._state:set(state)
        inst:PushEvent("toadstoolstatechanged", state)
    end
end

local function getstatus(inst)
    return (inst._state:value() == 0 and "EMPTY")
        or (inst._state:value() == 1 and "INGROUND")
        or nil
end

local function displaynamefn(inst)
    return (inst._state:value() == 0 and STRINGS.NAMES.TOADSTOOL_HOLE)
        or (inst._dark:value() and STRINGS.NAMES.TOADSTOOL_CAP_DARK)
        or nil
end

local function onsave(inst, data)
    data.state = inst._state:value() > 0 and inst._state:value() or nil
end

local function onload(inst, data)
    if data ~= nil and data.state ~= nil then
        setstate(inst, data.state)
    end
end

local function onloadpostpass(inst)
    local toadstool = inst.components.entitytracker:GetEntity("toadstool")
    if toadstool ~= nil then
        tracktoad(inst, toadstool)
    end
    local darktime = inst.components.timer:GetTimeLeft("darktimer") or 0
    if darktime > 0 and inst._state:value() > 0 then
        setdark(inst, darktime, true)
    else
        setnormal(inst, true)
    end
end

local function hastoadstool(inst)
    return inst._state:value() > 0 or inst.components.entitytracker:GetEntity("toadstool") ~= nil
end

local function ontriggerspawn(inst)
    setstate(inst, 2)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("toadstool_hole.png")

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("toadstool")
    inst.AnimState:SetBuild("toadstool_build")
    inst.AnimState:PlayAnimation("picked")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("event_trigger")
    inst:AddTag("absorbpoison")

    --DO THE PHYSICS STUFF MANUALLY SO THAT WE CAN SHUT OFF THE BOSS COLLISION.
    --don't yell at me plz...
    --MakeObstaclePhysics(inst, .5)
    ----------------------------------------------------
    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    --inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCapsule(.5, 2)
    ----------------------------------------------------

    inst._state = net_tinybyte(inst.GUID, "toadstool_cap._state")
    inst._dark = net_bool(inst.GUID, "toadstool_cap._dark")

    inst.displaynamefn = displaynamefn
    inst.scrapbook_anim = "mushroom_toad_idle_loop"
    inst.scrapbook_specialinfo = "TOADSTOOLCAP"
    inst.scrapbook_workable = ACTIONS.CHOP

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("entitytracker")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnLoadPostPass = onloadpostpass

    inst.HasToadstool = hastoadstool

    TheWorld:PushEvent("ms_registertoadstoolspawner", inst)
    inst:ListenForEvent("ms_spawntoadstool", ontriggerspawn)

    return inst
end

local function MakeFX(name, assetname, animname, assets)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(assetname)
        inst.AnimState:SetBuild(assetname.."_build")
        inst.AnimState:PlayAnimation(animname)
        inst.AnimState:SetFinalOffset(1)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheNet:IsDedicated() then
            inst.OnRemoveEntity = OnRemoveFXEntity
        end

        if not TheWorld.ismastersim then
            inst.OnEntityReplicated = OnFXEntityReplicated

            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

return Prefab("toadstool_cap", fn, assets, prefabs),
    MakeFX("toadstool_cap_absorbfx", "toadstool", "absorbfx", assets_absorbfx),
    MakeFX("toadstool_cap_releasefx", "canary", "explodefx", assets_releasefx)
