local assets =
{
    Asset("ANIM", "anim/abigail_flower.zip"),
    Asset("INV_IMAGE", "abigail_flower2"),
    Asset("INV_IMAGE", "abigail_flower_haunted"),
}

local prefabs =
{
    "abigail",
    "planted_flower",
    "small_puff",
    "petals",
}

local function getstatus(inst)
    if inst._chargestate == 3 then
        return inst.components.inventoryitem.owner ~= nil
            and "HAUNTED_POCKET"
            or "HAUNTED_GROUND"
    end
    local time_charge = inst.components.cooldown:GetTimeToCharged()
    return (time_charge < TUNING.TOTAL_DAY_TIME * .5 and "SOON")
        or (time_charge < TUNING.TOTAL_DAY_TIME * 2 and "MEDIUM")
        or "LONG"
end

local function activate(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "loop")
    inst:ListenForEvent("entity_death", inst._onentitydeath, TheWorld)
end

local function deactivate(inst)
    inst.SoundEmitter:KillAllSounds()
    inst:RemoveEventCallback("entity_death", inst._onentitydeath, TheWorld)
end

local function IsValidLink(inst, player)
    return player:HasTag("ghostlyfriend") and player.abigail == nil
end

local function dodecay(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local canplant =
        TheWorld.Map:CanPlantAtPoint(x, 0, z) and
        TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z, "flower") and
        not (RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z))

    if canplant then
        local radius = inst:GetPhysicsRadius(0)
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, 3, nil, { "NOBLOCK", "_inventoryitem", "locomotor", "FX", "INLIMBO", "DECOR" })) do
            if v ~= inst and v.entity:IsVisible() then
                local spacing = radius + v:GetPhysicsRadius(.25) - .001
                if v:GetDistanceSqToPoint(x, 0, z) < (v.deploy_extra_spacing ~= nil and math.max(v.deploy_extra_spacing * v.deploy_extra_spacing, spacing * spacing) or spacing * spacing) then
                    canplant = false
                    break
                end
            end
        end
    end

    if canplant then
        SpawnPrefab("planted_flower").Transform:SetPosition(x, 0, z)
    else
        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SpawnLootPrefab("petals", Vector3(x, y, z))
    end

    if not inst:IsAsleep() then
        SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
    end

    inst:Remove()
end

local function startdecay(inst)
    if inst._decaytask == nil then
        inst._decaytask = inst:DoTaskInTime(TUNING.ABIGAIL_FLOWER_DECAY_TIME, dodecay)
        inst._decaystart = GetTime()
    end
end

local function stopdecay(inst)
    if inst._decaytask ~= nil then
        inst._decaytask:Cancel()
        inst._decaytask = nil
        inst._decaystart = nil
    end
end

local function onsave(inst, data)
    if inst._decaystart ~= nil then
        local time = GetTime() - inst._decaystart
        if time > 0 then
            data.decaytime = time
        end
    end
end

local function onload(inst, data)
    if inst._decaytask ~= nil and data ~= nil and data.decaytime ~= nil then
        local remaining = math.max(0, TUNING.ABIGAIL_FLOWER_DECAY_TIME - data.decaytime)
        inst._decaytask:Cancel()
        inst._decaytask = inst:DoTaskInTime(remaining, dodecay)
        inst._decaystart = GetTime() + remaining - TUNING.ABIGAIL_FLOWER_DECAY_TIME
    end
end

local function updatestate(inst)
    if inst._playerlink ~= nil and inst.components.cooldown:IsCharged() then
        if inst._chargestate ~= 3 then
            inst._chargestate = 3
            inst.components.inventoryitem:ChangeImageName("abigail_flower_haunted")
            inst.AnimState:PlayAnimation("haunted_pre")
            inst.AnimState:PushAnimation("idle_haunted_loop", true)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            if inst.components.inventoryitem.owner == nil then
                activate(inst)
            end
            if not inst._suppress_landed_events then
                inst:PushEvent("on_no_longer_landed")
            end
        end
    else
        if inst._chargestate == 3 then
            inst.AnimState:ClearBloomEffectHandle()
            deactivate(inst)
        end
        if inst._playerlink ~= nil and inst.components.cooldown:GetTimeToCharged() < TUNING.TOTAL_DAY_TIME then
            if inst._chargestate ~= 2 then
                inst._chargestate = 2
                inst.components.inventoryitem:ChangeImageName("abigail_flower2")
                inst.AnimState:PlayAnimation("idle_2")
                if not inst._suppress_landed_events then
                    inst:PushEvent("on_landed")
                end
            end
        elseif inst._chargestate ~= 1 then
            inst._chargestate = 1
            inst.components.inventoryitem:ChangeImageName("abigail_flower")
            inst.AnimState:PlayAnimation("idle_1")
            if not inst._suppress_landed_events then
                inst:PushEvent("on_landed")
            end
        end
    end
end

local function ondeath(inst, deadthing, killer)
    if inst._chargestate == 3 and
        inst._playerlink ~= nil and
        inst._playerlink.abigail == nil and
        inst._playerlink.components.leader ~= nil and
        inst.components.inventoryitem.owner == nil and
        deadthing ~= nil and
        not (deadthing:HasTag("wall") or
            deadthing:HasTag("balloon") or
            deadthing:HasTag("groundspike") or
            deadthing:HasTag("smashable") or
            deadthing:HasTag("engineering")) then

        if deadthing:IsValid() then
            if not inst:IsNear(deadthing, 16) then
                return
            end
        elseif killer == nil or not inst:IsNear(killer, 16) then
            return
        end

        inst._playerlink.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
        local abigail = SpawnPrefab("abigail")
        if abigail ~= nil then
            abigail.Transform:SetPosition(inst.Transform:GetWorldPosition())
            abigail.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
            abigail:LinkToPlayer(inst._playerlink)
            inst:Remove()
        end
    end
end

local function linktoplayer(inst, player)
    if player ~= nil and IsValidLink(inst, player) then
        inst:ListenForEvent("onremove", inst._onremoveplayer, player)
        inst:ListenForEvent("killed", inst._onplayerkillthing, player)
        inst._playerlink = player
        player.abigail_flowers[inst] = true
    end
end

local function unlink(inst)
    if inst._playerlink ~= nil then
        inst:RemoveEventCallback("onremove", inst._onremoveplayer, inst._playerlink)
        inst:RemoveEventCallback("killed", inst._onplayerkillthing, inst._playerlink)
        inst._playerlink.abigail_flowers[inst] = nil
        inst._playerlink = nil
    end
end

local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onopen", inst._ontogglecontainer, container)
        inst:ListenForEvent("onclose", inst._ontogglecontainer, container)
        inst:ListenForEvent("onremove", inst._onremovecontainer, container)
        inst._container = container
    end
end

local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onopen", inst._ontogglecontainer, inst._container)
        inst:RemoveEventCallback("onclose", inst._ontogglecontainer, inst._container)
        inst:RemoveEventCallback("onremove", inst._onremovecontainer, inst._container)
        inst._container = nil
    end
end

local function topocket(inst, owner)
    stopdecay(inst)
    deactivate(inst)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
    if owner.components.container ~= nil then
        owner = owner.components.container.opener
    end
    if inst._playerlink ~= owner then
        unlink(inst)
        linktoplayer(inst, owner)
        updatestate(inst)
    end
end

local function toground(inst)
    unstore(inst)
    if inst._chargestate == 3 then
        activate(inst)
    elseif inst._playerlink == nil then
        startdecay(inst)
    end
end

local function refresh(inst)
    if inst._playerlink == nil then
        local owner = inst.components.inventoryitem.owner
        if owner ~= nil then
            if owner.components.container ~= nil then
                owner = owner.components.container.opener
            end
            linktoplayer(inst, owner)
            updatestate(inst)
        end
    elseif not IsValidLink(inst, inst._playerlink) then
        unlink(inst)
        updatestate(inst)
        if inst.components.inventoryitem.owner == nil then
            startdecay(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("abigail_flower")
    inst.AnimState:SetBuild("abigail_flower")
    inst.AnimState:PlayAnimation("idle_1")

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("abigail_flower.png")

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._chargestate = nil
    inst._playerlink = nil
    inst._container = nil
    inst._decaytask = nil
    inst._decaystart = nil

    inst._onremoveplayer = function()
        unlink(inst)
        updatestate(inst)
        if inst.components.inventoryitem.owner == nil then
            startdecay(inst)
        end
    end

    inst._onplayerkillthing = function(player, data)
        ondeath(inst, data.victim, player)
    end

    inst._onentitydeath = function(world, data)
        ondeath(inst, data.inst)
    end

    inst._ontogglecontainer = function(container)
        topocket(inst, container)
    end

    inst._onremovecontainer = function()
        unstore(inst)
    end

    inst._suppress_landed_events = true
    inst:DoTaskInTime(0, function(i) i._suppress_landed_events = false end)

    inst:AddComponent("inventoryitem")

    -----------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = TUNING.TOTAL_DAY_TIME * (1 + math.random() * 2)
    inst.components.cooldown.onchargedfn = updatestate
    inst.components.cooldown.startchargingfn = updatestate
    inst.components.cooldown:StartCharging()

    inst:WatchWorldState("phase", updatestate)
    updatestate(inst)
    startdecay(inst)

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload
    inst.OnSave = onsave
    inst.OnRemoveEntity = unlink
    inst.Refresh = refresh

    return inst
end

return Prefab("abigail_flower", fn, assets, prefabs)
