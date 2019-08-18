local assets =
{
    Asset("ANIM", "anim/chester_eyebone.zip"),
    Asset("ANIM", "anim/chester_eyebone_build.zip"),
    Asset("ANIM", "anim/chester_eyebone_snow_build.zip"),
    Asset("ANIM", "anim/chester_eyebone_shadow_build.zip"),
    Asset("INV_IMAGE", "chester_eyebone"),
    Asset("INV_IMAGE", "chester_eyebone_closed"),
    Asset("INV_IMAGE", "chester_eyebone_closed_shadow"),
    Asset("INV_IMAGE", "chester_eyebone_closed_snow"),
    Asset("INV_IMAGE", "chester_eyebone_shadow"),
    Asset("INV_IMAGE", "chester_eyebone_snow"),
}

local SPAWN_DIST = 30

local function OpenEye(inst)
    if not inst.isOpenEye then
        inst.isOpenEye = true
        inst.components.inventoryitem:ChangeImageName(inst.openEye)
        inst.AnimState:PlayAnimation("idle_loop", true)
    end
end

local function CloseEye(inst)
    if inst.isOpenEye then
        inst.isOpenEye = nil
        inst.components.inventoryitem:ChangeImageName(inst.closedEye)
        inst.AnimState:PlayAnimation("dead", true)
    end
end

local function RefreshEye(inst)
    inst.components.inventoryitem:ChangeImageName(inst.isOpenEye and inst.openEye or inst.closedEye)
end

local function MorphShadowEyebone(inst)
    inst.AnimState:SetBuild("chester_eyebone_shadow_build")

    inst.openEye = "chester_eyebone_shadow"
    inst.closedEye = "chester_eyebone_closed_shadow"
    RefreshEye(inst)

    inst.EyeboneState = "SHADOW"
end

local function MorphSnowEyebone(inst)
    inst.AnimState:SetBuild("chester_eyebone_snow_build")

    inst.openEye = "chester_eyebone_snow"
    inst.closedEye = "chester_eyebone_closed_snow"
    RefreshEye(inst)

    inst.EyeboneState = "SNOW"
end

--[[
local function MorphNormalEyebone(inst)
    inst.AnimState:SetBuild("chester_eyebone_build")

    inst.openEye = "chester_eyebone"
    inst.closedEye = "chester_eyebone_closed"
    RefreshEye(inst)

    inst.EyeboneState = "NORMAL"
end
]]

local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    return offset ~= nil and (pt + offset) or nil
end

local function SpawnChester(inst)
    --print("chester_eyebone - SpawnChester")

    local pt = inst:GetPosition()
    --print("    near", pt)

    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        --print("    at", spawn_pt)
        local chester = SpawnPrefab("chester")
        if chester ~= nil then
            chester.Physics:Teleport(spawn_pt:Get())
            chester:FacePoint(pt:Get())

            return chester
        end

    --else
        -- this is not fatal, they can try again in a new location by picking up the bone again
        --print("chester_eyebone - SpawnChester: Couldn't find a suitable spawn point for chester")
    end
end

local StartRespawn

local function StopRespawn(inst)
    if inst.respawntask ~= nil then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function RebindChester(inst, chester)
    chester = chester or TheSim:FindFirstEntityWithTag("chester")
    if chester ~= nil then
        OpenEye(inst)
        inst:ListenForEvent("death", function() StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME) end, chester)

        if chester.components.follower.leader ~= inst then
            chester.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnChester(inst)
    StopRespawn(inst)
    RebindChester(inst, TheSim:FindFirstEntityWithTag("chester") or SpawnChester(inst))
end

StartRespawn = function(inst, time)
    StopRespawn(inst)

    time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnChester)
    inst.respawntime = GetTime() + time
    CloseEye(inst)
end

local function FixChester(inst)
    inst.fixtask = nil
    --take an existing chester if there is one
    if not RebindChester(inst) then
        CloseEye(inst)
        
        if inst.components.inventoryitem.owner ~= nil then
            local time_remaining = inst.respawntime ~= nil and math.max(0, inst.respawntime - GetTime()) or 0
            StartRespawn(inst, time_remaining)
        end
    end
end

local function OnPutInInventory(inst)
    if inst.fixtask == nil then
        inst.fixtask = inst:DoTaskInTime(1, FixChester)
    end
end

local function OnSave(inst, data)
    data.EyeboneState = inst.EyeboneState
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

    if data.EyeboneState == "SHADOW" then
        MorphShadowEyebone(inst)
    elseif data.EyeboneState == "SNOW" then
        MorphSnowEyebone(inst)
    end

    if data.respawntimeremaining ~= nil then
        inst.respawntime = data.respawntimeremaining + GetTime()
    else
        OpenEye(inst)
    end
end

local function GetStatus(inst)
    return inst.respawntask ~= nil and "WAITING" or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("chester_eyebone")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

    inst.AnimState:SetBank("eyebone")
    inst.AnimState:SetBuild("chester_eyebone_build")
    inst.AnimState:PlayAnimation("dead", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.EyeboneState = "NORMAL"
    inst.openEye = "chester_eyebone"
    inst.closedEye = "chester_eyebone_closed"
    inst.isOpenEye = nil

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:ChangeImageName(inst.closedEye)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")

    MakeHauntableLaunch(inst)

    --inst.MorphNormalEyebone = MorphNormalEyebone
    inst.MorphSnowEyebone = MorphSnowEyebone
    inst.MorphShadowEyebone = MorphShadowEyebone

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.fixtask = inst:DoTaskInTime(1, FixChester)

    return inst
end

return Prefab("chester_eyebone", fn, assets)
