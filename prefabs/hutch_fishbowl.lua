local assets =
{
    Asset("ANIM", "anim/hutch_fishbowl.zip"),
    Asset("INV_IMAGE", "hutch_fishbowl"),
    Asset("INV_IMAGE", "hutch_fishbowl_dead"),
}

local SPAWN_DIST = 30

local function RefreshFishBowlIcon(inst)
    local icon = inst.currentIcon or inst.fishAlive
    local skin_name = inst:GetSkinName()
    if skin_name ~= nil then
        icon = string.gsub(icon, "hutch_fishbowl", skin_name)
    end
    inst.components.inventoryitem:ChangeImageName(icon)
end

local function FishAlive(inst, instant)
    if not inst.isFishAlive then
        inst.isFishAlive = true
        inst.currentIcon = inst.fishAlive
        RefreshFishBowlIcon(inst)
        if instant then
            inst.AnimState:PlayAnimation("idle_loop", true)
        else
            inst.AnimState:PlayAnimation("revive")
            inst.AnimState:PushAnimation("idle_loop", true)
        end
    end
end

local function FishDead(inst, instant)
    if inst.isFishAlive then
        inst.isFishAlive = nil
        inst.currentIcon = inst.fishDead
        RefreshFishBowlIcon(inst)
        if instant then
            inst.AnimState:PlayAnimation("dead", true)
        else
            inst.AnimState:PlayAnimation("die")
            inst.AnimState:PushAnimation("dead", true)
        end
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetSpawnPoint(pt)
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, SPAWN_DIST, 12, true, true, NoHoles)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function SpawnHutch(inst)
    local pt = inst:GetPosition()
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        local hutch = SpawnPrefab("hutch", inst.linked_skinname, inst.skin_id )
        if hutch ~= nil then
            hutch.Physics:Teleport(spawn_pt:Get())
            hutch:FacePoint(pt:Get())

            return hutch
        end
    --else
        -- this is not fatal, they can try again in a new location by picking up the bone again
        --print("hutch_fishbowl - SpawnHutch: Couldn't find a suitable spawn point for hutch")
    end
end

local StartRespawn

local function StopRespawn(inst)
    if inst.respawntask ~= nil then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
    if inst.fishalivetask ~= nil then
        inst.fishalivetask:Cancel()
        inst.fishalivetask = nil
    end
end

local function RebindHutch(inst, hutch)
    hutch = hutch or TheSim:FindFirstEntityWithTag("hutch")
    if hutch ~= nil then
        FishAlive(inst)
        inst:ListenForEvent("death", function() StartRespawn(inst, TUNING.HUTCH_RESPAWN_TIME) end, hutch)

        if hutch.components.follower.leader ~= inst then
            hutch.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnHutch(inst)
    StopRespawn(inst)
    RebindHutch(inst, TheSim:FindFirstEntityWithTag("hutch") or SpawnHutch(inst))
end

StartRespawn = function(inst, time)
    StopRespawn(inst)

    time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnHutch)
    inst.respawntime = GetTime() + time
    if time > 0 then
        FishDead(inst)
    end
end

local function Onfishalivetask(inst)
    inst.fishalivetask = nil
    FishAlive(inst)
end

local function FixHutch(inst)
    inst.fixtask = nil
    --take an existing hutch if there is one
    if not RebindHutch(inst) then
        local time_remaining = inst.respawntime ~= nil and math.max(0, inst.respawntime - GetTime()) or 0
        if inst.components.inventoryitem.owner ~= nil then
            StartRespawn(inst, time_remaining)
        elseif time_remaining > 0 then
            FishDead(inst)
            if inst.fishalivetask ~= nil then
                inst.fishalivetask:Cancel()
            end
            inst.fishalivetask = inst:DoTaskInTime(time_remaining, Onfishalivetask)
        end
    end
end

local function OnPutInInventory(inst)
    if inst.fixtask == nil then
        inst.fixtask = inst:DoTaskInTime(1, FixHutch)
    end
end

local function OnSave(inst, data)
    if inst.respawntime ~= nil then
        local time = GetTime()
        if inst.respawntime > time then
            data.respawntimeremaining = inst.respawntime - time
        end
    end
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.respawntimeremaining ~= nil then
        inst.respawntime = data.respawntimeremaining + GetTime()
        if data.respawntimeremaining > 0 then
            FishDead(inst, true)
        end
    end
end

local function GetStatus(inst)
    return not inst.isFishAlive and "WAITING" or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("hutch_fishbowl")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

    inst.AnimState:SetBank("fishbowl")
    inst.AnimState:SetBuild("hutch_fishbowl")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fishAlive = "hutch_fishbowl"
    inst.fishDead = "hutch_fishbowl_dead"
    inst.isFishAlive = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:ChangeImageName(inst.fishAlive)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")

    MakeHauntableLaunch(inst)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.RefreshFishBowlIcon = RefreshFishBowlIcon

    inst.fixtask = inst:DoTaskInTime(1, FixHutch)

    return inst
end

return Prefab("hutch_fishbowl", fn, assets)
