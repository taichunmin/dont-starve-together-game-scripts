--Down when sane, up when insane.
local assets =
{
    Asset("ANIM", "anim/blocker_sanity.zip"),
    Asset("ANIM", "anim/blocker_sanity_fx.zip"),
	Asset("MINIMAP_IMAGE", "obelisk"),
}

local prefabs =
{
    "sanity_raise",
    "sanity_lower",
}

local COLLISION_SIZE = 1 --must be an int
local NEAR_DIST_SQ = 10 * 10
local FAR_DIST_SQ = 11 * 11

local UPDATE_INTERVAL = .2
local UPDATE_OFFSET = 0 --used to stagger periodic updates across entities

--V2C: Use a shared add/remove wall because regions may overlap
local PF_SHARED = {}

local function AddSharedWall(pathfinder, x, z, inst)
    local id = tostring(x)..","..tostring(z)
    if PF_SHARED[id] == nil then
        PF_SHARED[id] = { [inst] = true }
        pathfinder:AddWall(x, 0, z)
    else
        PF_SHARED[id][inst] = true
    end
end

local function RemoveSharedWall(pathfinder, x, z, inst)
    local id = tostring(x)..","..tostring(z)
    if PF_SHARED[id] ~= nil then
        PF_SHARED[id][inst] = nil
        if next(PF_SHARED[id]) ~= nil then
            return
        end
        PF_SHARED[id] = nil
    end
    pathfinder:RemoveWall(x, 0, z)
end

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pftable == nil then
            inst._pftable = {}
            local pathfinder = TheWorld.Pathfinder
            local x, y, z = inst.Transform:GetWorldPosition()
            x = math.floor(x * 100 + .5) / 100
            z = math.floor(z * 100 + .5) / 100
            for dx = -COLLISION_SIZE, COLLISION_SIZE do
                local x1 = x + dx
                for dz = -COLLISION_SIZE, COLLISION_SIZE do
                    local z1 = z + dz
                    AddSharedWall(pathfinder, x1, z1, inst)
                    table.insert(inst._pftable, { x1, z1 })
                end
            end
        end
    elseif inst._pftable ~= nil then
        local pathfinder = TheWorld.Pathfinder
        for i, v in ipairs(inst._pftable) do
            RemoveSharedWall(pathfinder, v[1], v[2], inst)
        end
        inst._pftable = nil
    end
end

local function InitializePathFinding(inst, isready)
    if isready then
        inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
        OnIsPathFindingDirty(inst)
    else
        inst:DoTaskInTime(0, InitializePathFinding, true)
    end
end

local function updatephysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
	if not inst.conceal then
		inst.Physics:CollidesWith(COLLISION.ITEMS)
		if inst.active then
			inst.Physics:CollidesWith(COLLISION.CHARACTERS)
		end
	end
end

local function OnActiveStateChanged(inst)
	inst.active = inst.active_queue
	inst._ispathfinding:set(inst.active_queue and not inst.conceal)
	updatephysics(inst)
end

local function OnConcealStateChanged(inst)
	inst.conceal = inst.conceal_queued
	if not inst.conceal then
		LaunchAndClearArea(inst, COLLISION_SIZE, 0.5, 0.5, .2, COLLISION_SIZE)
	end

	OnActiveStateChanged(inst)
end

local function dotransition(inst)
	inst.transition_task = nil
	if inst.conceal ~= inst.conceal_queued then
		if not inst.sg:HasStateTag("busy") then
			if inst.conceal_queued then
				inst.sg:GoToState("conceal", inst.active)
			else
				inst.sg:GoToState("reveal")
			end
		end
	elseif inst.active ~= inst.active_queue and not inst.conceal_queued then
		inst.sg:GoToState(inst.active_queue and "raise" or "lower")
	end
end

local function refresh(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	if inst.conceal or inst.conceal_queued then
		-- nothing to do here
    elseif inst.active then
        inst.active_queue = false
        for i, v in ipairs(AllPlayers) do
            if not v:HasTag("notarget") and
                v.components.sanity ~= nil and
                ((v.components.sanity:IsSane() and inst.activeonsane) or (v.components.sanity:IsInsane() and not inst.activeonsane)) then
                local p1x, p1y, p1z = v.Transform:GetWorldPosition()
                if distsq(x, z, p1x, p1z) < FAR_DIST_SQ then
			        inst.active_queue = true
                    break
                end
            end
        end
    else
		inst.active_queue = false
        for i, v in ipairs(AllPlayers) do
            if not v:HasTag("notarget") and
                v.components.sanity ~= nil and
                ((v.components.sanity:IsSane() and inst.activeonsane) or (v.components.sanity:IsInsane() and not inst.activeonsane)) then
                local p1x, p1y, p1z = v.Transform:GetWorldPosition()
                if distsq(x, z, p1x, p1z) < NEAR_DIST_SQ then
			        inst.active_queue = true
                    break
                end
            end
        end
    end

	if (inst.conceal ~= inst.conceal_queued or inst.active_queue ~= inst.active) and inst.transition_task == nil then
        inst.transition_task = inst:DoTaskInTime(math.random(), dotransition)
	end
end

local function AddRefreshTask(inst)
	if inst._refreshtask == nil then
		inst._refreshtask = inst:DoPeriodicTask(UPDATE_INTERVAL, refresh, UPDATE_OFFSET)

		--Stagger updates for next spawned entity
		UPDATE_OFFSET = UPDATE_OFFSET + FRAMES
		if UPDATE_OFFSET > UPDATE_INTERVAL then
			UPDATE_OFFSET = 0
		end
	end
end

local function ConcealForMinigame(inst, conceal)
	inst.conceal_queued = conceal or nil
	inst.active_queue = false
end

local function getstatus(inst)
    return inst.active and "ACTIVE" or "INACTIVE"
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function commonfn(tags)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, COLLISION_SIZE)

    inst.MiniMapEntity:SetIcon("obelisk.png")

    inst.AnimState:SetBank("blocker_sanity")
    inst.AnimState:SetBuild("blocker_sanity")
    inst.AnimState:PlayAnimation("idle_inactive")

    inst:AddTag("antlion_sinkhole_blocker")
	for _, v in ipairs(tags) do
		inst:AddTag(v)
	end

	updatephysics(inst)

    inst._pftable = nil
    inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    InitializePathFinding(inst, TheWorld.ismastersim)

    inst.OnRemoveEntity = onremove

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.active = false
	inst.active_queue = false
--    inst.conceal = nil
--    inst.conceal_queued = nil


    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:SetStateGraph("SGnightmarerock")

	AddRefreshTask(inst)

	inst.OnActiveStateChanged = OnActiveStateChanged
	inst.OnConcealStateChanged = OnConcealStateChanged

	inst.ConcealForMinigame = ConcealForMinigame

    return inst
end

local function insanityrock()
    local inst = commonfn({"insanityrock"})

    inst.activeonsane = false

    return inst
end

local function sanityrock()
    local inst = commonfn({"sanityrock"})

    inst.activeonsane = true

    return inst
end

return Prefab("insanityrock", insanityrock, assets, prefabs),
       Prefab("sanityrock", sanityrock, assets, prefabs)