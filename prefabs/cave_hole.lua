local assets =
{
    Asset("ANIM", "anim/cave_hole.zip"),
}

local prefabs =
{
    "small_puff",
    "cavehole_flick_warn",
    "cavehole_flick",
}

local loot =
{
    greengem = 0.1,
    yellowgem = 0.4,
    orangegem = 0.4,
    purplegem = 0.4,
    thulecite = 1.0,
    thulecite_pieces = 1.0,
    nightmare_timepiece = 0.1,
}

local loot_stacksize =
{
    thulecite           = function() return math.random(3) end,
    thulecite_pieces    = function() return 4 + math.random(3) end,
}

for k, _ in pairs(loot) do
    table.insert(prefabs, k)
end

local function SetObjectInHole(inst, obj)
    obj.Physics:SetActive(false)
    obj:AddTag("outofreach")
    inst:ListenForEvent("onremove", inst._onremoveobj, obj)
    inst:ListenForEvent("onpickup", inst._onpickupobj, obj)
end

local function tryspawn(inst)
    if inst.allowspawn and #inst.components.objectspawner.objects <= 0 then
        local lootobj = inst.components.objectspawner:SpawnObject(weighted_random_choice(loot))

        if loot_stacksize[lootobj.prefab] ~= nil and lootobj.components.stackable ~= nil then
            local stacksize = loot_stacksize[lootobj.prefab]()
            lootobj.components.stackable:SetStackSize(stacksize)
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        lootobj.Physics:Teleport(x, y, z)

        if not inst:IsAsleep() then
            SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
        end
    end

    inst.allowspawn = false
end

local function OnSave(inst, data)
    data.allowspawn = inst.allowspawn
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.allowspawn = data.allowspawn
    end
end

local function CreateSurfaceAnim()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("cave_hole")
    inst.AnimState:SetBuild("cave_hole")
    inst.AnimState:Hide("hole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst.Transform:SetEightFaced()

    return inst
end

local OUTER_RADIUS = 2.75
local INNER_RADIUS = 1.5
local FLICK_WARN_TIME = 2
local FLICK_TIME = 2 -- Additional time after FLICK_WARN_TIME.

local function build_hole_collision_mesh(radius, height)
    local radius = OUTER_RADIUS
    local height = 6
    local segment_count = 16
    local segment_span = math.pi * 2 / segment_count

    local triangles = {}
    local y0 = 0
    local y1 = height

    for segment_idx = 0, segment_count do

        local angle = segment_idx * segment_span
        local angle0 = angle - segment_span / 2
        local angle1 = angle + segment_span / 2

        local x0 = math.cos(angle0) * radius
        local z0 = math.sin(angle0) * radius

        local x1 = math.cos(angle1) * radius
        local z1 = math.sin(angle1) * radius

        table.insert(triangles, x0)
        table.insert(triangles, y0)
        table.insert(triangles, z0)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y1)
        table.insert(triangles, z1)
    end

    segment_count = 8
    radius = 1.5
    segment_span = math.pi * 2 / segment_count
    for segment_idx = 0, segment_count do

        local angle = segment_idx * segment_span
        local angle0 = angle - segment_span / 2
        local angle1 = angle + segment_span / 2

        local x0 = math.cos(angle0) * radius
        local z0 = math.sin(angle0) * radius

        local x1 = math.cos(angle1) * radius
        local z1 = math.sin(angle1) * radius

        table.insert(triangles, x0)
        table.insert(triangles, y0)
        table.insert(triangles, z0)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y1)
        table.insert(triangles, z1)
    end

	return triangles
end

local function ClearFlickTasks(player)
    if player._caveholecheck_task ~= nil then
        player._caveholecheck_task:Cancel()
        player._caveholecheck_task = nil
    end
    if player._cavehole_task ~= nil then
        player._cavehole_task:Cancel()
        player._cavehole_task = nil
    end
end

local function StopFlickIfAble(player)
    if player.components.health:IsDead() or player:HasTag("playerghost") then
        ClearFlickTasks(player)
        return true
    end
    return false
end

local function ShouldAvoidFlicking(player)
    return player:HasTag("wereplayer")
end

local function DoFlickOn(player, inst)
    if StopFlickIfAble(player) then
        return
    end

    player._cavehole_task = nil

    if ShouldAvoidFlicking(player) then
        return
    end

    if inst:IsValid() then
        local ex, _, ez = player.Transform:GetWorldPosition()
        SpawnPrefab("cavehole_flick").Transform:SetPosition(ex, 0, ez)
        -- A fake redirected so that players do not see the red blood flash.
        player:PushEvent("attacked", { attacker = inst, damage = 0, redirected = player })
        player:PushEvent("knockback", { knocker = inst, radius = OUTER_RADIUS + 1 + math.random(), disablecollision = true })
    end
end

local function DoFlickWarnOn(player, inst)
    if StopFlickIfAble(player) then
        return
    end

    if player._cavehole_task ~= nil then
        if ShouldAvoidFlicking(player) then
            player._cavehole_task:Cancel()
            player._cavehole_task = nil
            return
        end
        local ex, _, ez = player.Transform:GetWorldPosition()
        SpawnPrefab("cavehole_flick_warn").Transform:SetPosition(ex, 0, ez)
        -- Intentionally replacing this task tracker!
        player._cavehole_task = player:DoTaskInTime(FLICK_TIME, DoFlickOn, inst)
    end
end

local function CheckFlick(player, inst)
    if StopFlickIfAble(player) then
        return
    end

    if ShouldAvoidFlicking(player) then
        return
    end

    if player._cavehole_task == nil then
        player._cavehole_task = player:DoTaskInTime(FLICK_WARN_TIME, DoFlickWarnOn, inst)
    end
end

local function OnPlayerNear(inst, player)
    player._caveholecheck_task_count = (player._caveholecheck_task_count or 0) + 1
    if player._caveholecheck_task == nil then
        player._caveholecheck_task = player:DoPeriodicTask(1, CheckFlick, 0, inst)
    end
end

local function OnPlayerFar(inst, player)
    player._caveholecheck_task_count = (player._caveholecheck_task_count or 1) - 1
    if player._caveholecheck_task_count == 0 then
        player._caveholecheck_task_count = nil
        ClearFlickTasks(player)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("groundhole")
    inst._groundhole_innerradius = INNER_RADIUS
    inst._groundhole_outerradius = OUTER_RADIUS
    inst._groundhole_rangeoverride = 0
    inst:AddTag("blocker")
    inst:AddTag("blinkfocus")

    inst.entity:AddPhysics()
    inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetTriangleMesh(build_hole_collision_mesh())

    inst.AnimState:SetBank("cave_hole")
    inst.AnimState:SetBuild("cave_hole")
    inst.AnimState:Hide("surface")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst.MiniMapEntity:SetIcon("cave_hole.png")

    inst.Transform:SetEightFaced()

	inst:SetDeploySmartRadius(3)

    --NOTE: Shadows are on WORLD_BACKGROUND sort order 1
    --      Hole goes above to hide shadows
    --      Surface goes below to reveal shadows
    --Dedicated server does not need to spawn the local animation
    if not TheNet:IsDedicated() then
        CreateSurfaceAnim().entity:SetParent(inst.entity)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("objectspawner")
    inst.components.objectspawner.onnewobjectfn = SetObjectInHole

    inst:AddComponent("playerprox")
	inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetOnPlayerNear(OnPlayerNear)
    inst.components.playerprox:SetOnPlayerFar(OnPlayerFar)
    inst.components.playerprox:SetDist(OUTER_RADIUS, OUTER_RADIUS) -- In case a player manages to squeeze inside the doughnut physics.

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.allowspawn = true
    inst:DoTaskInTime(0, tryspawn)

    inst:ListenForEvent("resetruins", function()
        inst.allowspawn = true
        inst:DoTaskInTime(math.random() * .75, tryspawn)
    end, TheWorld)

    inst._onremoveobj = function(obj)
        table.removearrayvalue(inst.components.objectspawner.objects, obj)
    end

    inst._onpickupobj = function(obj)
        obj.Physics:SetActive(true)
        obj:RemoveTag("outofreach")
        inst._onremoveobj(obj)
        inst:RemoveEventCallback("onremove", inst._onremoveobj, obj)
        inst:RemoveEventCallback("onpickup", inst._onpickupobj, obj)
    end

    return inst
end

return Prefab("cave_hole", fn, assets, prefabs)
