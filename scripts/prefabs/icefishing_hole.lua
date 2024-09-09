local assets = {
    Asset("ANIM", "anim/icefishing_hole.zip"),
}

local prefabs = {
    "splash_green_large",
}

local function build_hole_collision_mesh(radius, height, segment_count)
    local triangles = {}
    local y0 = 0
    local y1 = height

    local segment_span = math.pi * 2 / segment_count
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

local function CheckForFixed(player, inst)
    player._icefishing_hole_task = nil
    if inst:IsValid() then
        local x, _, z = inst.Transform:GetWorldPosition()
        if player:GetDistanceSqToInst(inst) < inst._hole_radius * inst._hole_radius then
            local ex, ey, ez = player.Transform:GetWorldPosition()
            local dx, dz = ex - x, ez - z
            local dist = math.sqrt(dx * dx + dz * dz)
            local player_radius = (player.Physics:GetRadius() or 1) + .2
            if dist == 0 then
                dist = 1
                dx = player_radius
            else
                dx, dz = (player_radius + inst._hole_radius) * dx / dist, (player_radius + inst._hole_radius) * dz / dist
            end
            player.Transform:SetPosition(x + dx, 0, z + dz)
        end
    end
end
local function OnPlayerNear(inst, player)
    local x, _, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("splash_green_large").Transform:SetPosition(x, 0, z)
    -- A fake redirected so that players do not see the red blood flash.
    player:PushEvent("attacked", { attacker = inst, damage = 0, redirected = player })
    player:PushEvent("knockback", { knocker = inst, radius = inst._hole_radius + 1 + math.random(), disablecollision = true })
    if player._icefishing_hole_task ~= nil then
        player._icefishing_hole_task:Cancel()
        player._icefishing_hole_task = nil
    end
    player._icefishing_hole_task = player:DoTaskInTime(1, CheckForFixed, inst) -- In case the player is ignoring knockbacks we want them out.
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    local RADIUS = 1.7
    inst.Physics:SetTriangleMesh(build_hole_collision_mesh(RADIUS, 6, 16))

    inst.AnimState:SetBuild("icefishing_hole")
    inst.AnimState:SetBank("icefishing_hole")
	inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    --inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("icefishing_hole.png")

    inst:AddTag("pond")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst:AddTag("NOCLICK")
    inst:AddTag("virtualocean")
    inst:AddTag("oceanfishingfocus")

    inst:AddTag("groundhole")
    inst:AddTag("ignorewalkableplatforms") -- Just in case.

	inst:SetDeploySmartRadius(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._hole_radius = RADIUS

    local playerprox = inst:AddComponent("playerprox")
    playerprox:SetTargetMode(playerprox.TargetModes.AllPlayers)
    playerprox:SetOnPlayerNear(OnPlayerNear)
    playerprox:SetDist(RADIUS, RADIUS) -- In case a player manages to get inside the fishing boundary uninvited.

    return inst
end

return Prefab( "icefishing_hole", fn, assets, prefabs)
