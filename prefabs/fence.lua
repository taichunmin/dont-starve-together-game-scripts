require "prefabutil"

local wall_prefabs =
{
    "collapse_small",
}

local function CalcRotationEnum(rot, isdoor)
    return math.floor((math.floor(rot + 0.5) / 45) % (isdoor and 8 or 4))
end

local function CalcFacingAngle(rot, isdoor)
    return CalcRotationEnum(rot, isdoor) * 45 
end

local function IsNarrow(inst)
    return CalcRotationEnum(inst.Transform:GetRotation()) % 2 == 0
end

local function IsSwingRight(inst)
    if inst._isswingright ~= nil then
        return inst._isswingright:value()
    end
    return inst.isswingright == true
end

local function IsOpen(inst)
    return inst._isopen ~= nil and inst._isopen:value()
end

local function GetAnimName(inst, basename)
    return basename
        ..(IsSwingRight(inst) and "right" or "")
        ..(IsOpen(inst) and "_open" or "")
end

local function GetAnimState(inst)
    return (inst.dooranim or inst).AnimState
end

-------------------------------------------------------------------------------
--Networked data
local function GetDoorRotationOffset(inst, rot)
    --angle1 to get back to hinge
    --angle2 to open door using hinge as pivot
    local sign = IsSwingRight(inst) and -1 or 1
    local angle1 = inst.Transform:GetRotation() * DEGREES
    local angle2 = angle1 + sign * rot * DEGREES
    local len = sign * (IsNarrow(inst) and .5 or .707)
    return
        len * (math.sin(angle2) - math.sin(angle1)),
        0,
        len * (math.cos(angle2) - math.cos(angle1))
end

local function OnDoorStateDirty(inst)
    --V2C: AnimState:SetSortWorldOffset is client side
    if inst.dooranim ~= nil and inst._isopen ~= nil then
        if inst._isopen:value() then
            inst.dooranim.AnimState:SetSortWorldOffset(GetDoorRotationOffset(inst, 100))
        else
            inst.dooranim.AnimState:SetSortWorldOffset(0, 0, 0)
        end
    end
end

local function OnInitDoorClient(inst)
    --V2C: No point doing it any earlier because we need to wait for rotation to set
    inst:ListenForEvent("doorstatedirty", OnDoorStateDirty)
    OnDoorStateDirty(inst)
end

local function OnWallAnimReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        parent.highlightforward = inst
        parent.dooranim = inst
    end
end

-------------------------------------------------------------------------------
-- Fence/Gate Alignment

local function SetIsSwingRight(inst, is_swing_right)
    if inst._isswingright ~= nil then
        inst._isswingright:set(is_swing_right)
    else
        inst.isswingright = is_swing_right
    end
    OnDoorStateDirty(inst)
end

local function FindPairedDoor(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rot = inst.Transform:GetRotation()

    local swingright = IsSwingRight(inst)
    local search_dist = IsNarrow(inst) and 1 or 1.4

    local search_x = -math.sin(rot / RADIANS) * search_dist
    local search_y = math.cos(rot / RADIANS) * search_dist

    search_x = x + (swingright and search_x or -search_x)
    search_y = z + (swingright and -search_y or search_y)

    local other_door = TheSim:FindEntities(search_x,0,search_y, 0.25, {"door"})[1]
    if other_door then
        local opposite_swing = swingright ~= IsSwingRight(other_door)
        local opposite_rotation = inst.Transform:GetRotation() ~= other_door.Transform:GetRotation()
        return (opposite_swing ~= opposite_rotation) and other_door or nil
    end

    return nil
end

local function GetNeighbors(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return TheSim:FindEntities(x,0,z, 1.5, {"wall"})
end

local function SetOffset(inst, offset)
    if inst.dooranim ~= nil then
        inst.dooranim.Transform:SetPosition(offset, 0, 0)
    end
end

local function ApplyDoorOffset(inst)
    SetOffset(inst, inst.offsetdoor and 0.45 or 0)
end

local function SetOrientation(inst, rotation)
    rotation = CalcFacingAngle(rotation, inst.isdoor)

    inst.Transform:SetRotation(rotation)
    if inst.dooranim ~= nil then
        inst.dooranim.Transform:SetRotation(rotation)
    end

    if inst.builds.narrow then
        if IsNarrow(inst) then
            GetAnimState(inst):SetBuild(inst.builds.narrow)
            GetAnimState(inst):SetBank(inst.builds.narrow)
        else
            GetAnimState(inst):SetBuild(inst.builds.wide)
            GetAnimState(inst):SetBank(inst.builds.wide)
        end

        if inst.isdoor then
            ApplyDoorOffset(inst)
        end
    end
end

local function _calcdooroffset(inst, neighbors)
    if inst == nil or not inst.isdoor then
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local rot = inst.Transform:GetRotation()

    local search_x = -math.sin(rot / RADIANS) * 1.2
    local search_y = math.cos(rot / RADIANS) * 1.2

    local walls = TheSim:FindEntities(x + search_x,0, z - search_y, 0.25, {"wall"}, {"alignwall"})
    if #walls == 0 then
        walls = TheSim:FindEntities(x - search_x,0, z + search_y, 0.25, {"wall"}, {"alignwall"})
    end
    return #walls > 0
end

local function RefreshDoorOffset(inst, neighbors)
    if inst == nil or (not inst.isdoor) then
        return
    end

    if not IsNarrow(inst) then
        inst.offsetdoor = false
        ApplyDoorOffset(inst)
        return
    end

    local do_offset = _calcdooroffset(inst, neighbors)

    local otherdoor = FindPairedDoor(inst)
    if otherdoor and do_offset == false then
        do_offset = _calcdooroffset(otherdoor)
    end
        
    if inst.offsetdoor ~= do_offset then
        inst.offsetdoor = do_offset
        ApplyDoorOffset(inst)
    end
end

local function FixUpFenceOrientation(inst, deployedrotation) -- rotates the placer but not the any near by "alignwall"
    local neighbors = GetNeighbors(inst)

    if deployedrotation ~= nil then
        if inst.isdoor then
            local neighbor = neighbors[2]
            if neighbor ~= nil then
                if neighbor.isdoor then
                    SetIsSwingRight(inst, not IsSwingRight(neighbor))
                else
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local x1, y1, z1 = neighbor.Transform:GetWorldPosition()
                    local rot = math.atan2(x - x1, z - z1) * RADIANS
                    SetIsSwingRight(inst, CalcRotationEnum(deployedrotation, true) ~= CalcRotationEnum(rot, true))
                end
            end
        end

        SetOrientation(inst, deployedrotation)
        RefreshDoorOffset(inst, neighbors)
    else
        local neighbor = neighbors[1]
        if neighbor ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local x1, y1, z1 = neighbor.Transform:GetWorldPosition()
            local rot_to_neighbor = math.atan2(x - x1, z - z1) * RADIANS
            local rot = CalcFacingAngle(rot_to_neighbor, inst.isdoor)
            
            if inst.isdoor then
                if Vector3(x - x1, 0, z - z1):Dot(TheCamera:GetRightVec()) < 0 then
                    rot = rot + 180
                end
                
                if neighbor.isdoor then
                    if CalcRotationEnum(neighbor.Transform:GetRotation(), false) == CalcRotationEnum(rot, false) then
						rot = neighbor.Transform:GetRotation()
					end
                    SetIsSwingRight(inst, not IsSwingRight(neighbor))
                else
                    SetIsSwingRight(inst, CalcRotationEnum(rot, true) ~= CalcRotationEnum(rot_to_neighbor, true))

					-- some extra fixup to handle the case when two doors are placed with opposite camera angles, but the found neighbour was a wall even though there is a door on the otherside
					inst.Transform:SetRotation(rot)
					local otherdoor = FindPairedDoor(inst)
					if otherdoor ~= nil then
						rot = otherdoor.Transform:GetRotation()
						SetIsSwingRight(inst, not IsSwingRight(otherdoor))
					end
                end
            end

            SetOrientation(inst, rot)

            RefreshDoorOffset(inst, neighbors)
        else
            if inst.isdoor then
                SetIsSwingRight(inst, false)
            end
            SetOrientation(inst, inst.Transform:GetRotation())
        end
    end

    GetAnimState(inst):PlayAnimation(GetAnimName(inst, "idle"))
end

-------------------------------------------------------------------------------

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil then
            inst._pfpos = inst:GetPosition()
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function makeobstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function keeptargetfn()
    return false
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function onworked(inst)
    GetAnimState(inst):PlayAnimation(GetAnimName(inst, "hit"))
    GetAnimState(inst):PushAnimation(GetAnimName(inst, "idle"), false)
end

local function onhit(inst, attacker, damage)
    inst.components.workable:WorkedBy(attacker)
end

-------------------------------------------------------------------------------
local function SetIsOpen(inst, isopen)
    inst._isopen:set(isopen)
    OnDoorStateDirty(inst)
end

local function OpenDoor(inst, skiptransition)
    if inst == nil then
        return
    end

    SetIsOpen(inst, true)
    clearobstacle(inst)

    if not skiptransition then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/open")
    end

    GetAnimState(inst):PlayAnimation(GetAnimName(inst, "idle"))
end

local function CloseDoor(inst, skiptransition)
    if inst == nil then
        return
    end

    SetIsOpen(inst, false)
    makeobstacle(inst)

    if not skiptransition then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/close")
    end

    GetAnimState(inst):PlayAnimation(GetAnimName(inst, "idle"))
end

local function ToggleDoor(inst)
    inst.components.activatable.inactive = true

    if IsOpen(inst) then
        CloseDoor(inst)
        CloseDoor(FindPairedDoor(inst))
    else
        OpenDoor(inst)
        OpenDoor(FindPairedDoor(inst))
    end
end

local function getdooractionstring(inst)
    return IsOpen(inst) and "CLOSE" or "OPEN"
end
-------------------------------------------------------------------------------

local function onsave(inst, data)
    local rot = CalcRotationEnum(inst.Transform:GetRotation(), inst.isdoor)
    data.rot = rot > 0 and rot or nil
    data.offsetdoor = inst.offsetdoor
    data.swingright = inst._isswingright ~= nil and inst._isswingright:value() or nil
    data.isopen = inst._isopen ~= nil and inst._isopen:value() or nil
end

local function onload(inst, data)
    if data ~= nil then
        inst.offsetdoor = data.offsetdoor

        if inst._isswingright ~= nil then
            SetIsSwingRight(inst, data.swingright or (data.doorpairside == 2)) -- data.doorpairside is deprecated v2, swingright is v3 
        end

        local rotation = 0
        if data.rotation ~= nil then
            -- very old style of save data. updates save data to v2 format, safe to remove this when we go out of the beta branch
            rotation = data.rotation - 90
        elseif data.rot ~= nil then
            rotation = data.rot*45
        end
        SetOrientation(inst, rotation)

        if data.isopen then
            OpenDoor(inst, true)
        elseif inst._isswingright ~= nil and inst._isswingright:value() then
            GetAnimState(inst):PlayAnimation(GetAnimName(inst, "idle"))
        end
    end
end

local function MakeWall(name, builds, isdoor)
    local assets, custom_wall_prefabs

    if isdoor then
        custom_wall_prefabs = { name.."_anim" }
        for i, v in ipairs(wall_prefabs) do
            table.insert(custom_wall_prefabs, v)
        end
    else
        assets =
        {
            Asset("ANIM", "anim/"..builds.wide..".zip"),
        }
        if builds.narrow then
            table.insert(assets, Asset("ANIM", "anim/"..builds.narrow..".zip"))
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState() --V2C: need this even if we are door, for mouseover sorting
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

        MakeObstaclePhysics(inst, .5)
        inst.Physics:SetDontRemoveOnSleep(true)

        inst:AddTag("wall")
        inst:AddTag("alignwall")
        inst:AddTag("noauradamage")
        inst:AddTag("nointerpolate")

        if isdoor then
            inst.isdoor = true
            inst:AddTag("door")
            inst._isopen = net_bool(inst.GUID, name.."._open", "doorstatedirty")
            inst._isswingright = net_bool(inst.GUID, name.."._swingright", "doorstatedirty")
            inst.GetActivateVerb = getdooractionstring
        else
            inst.AnimState:SetBank(builds.wide)
            inst.AnimState:SetBuild(builds.wide)
            inst.AnimState:PlayAnimation("idle")

            MakeSnowCoveredPristine(inst)
        end

        inst._pfpos = nil
        inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
        makeobstacle(inst)
        --Delay this because makeobstacle sets pathfinding on by default
        --but we don't to handle it until after our position is set
        inst:DoTaskInTime(0, InitializePathFinding)

        -----------------------------------------------------------------------
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            if isdoor then
                inst:DoTaskInTime(0, OnInitDoorClient)
            end

            return inst
        end

        if isdoor then
            inst.dooranim = SpawnPrefab(name.."_anim")
            inst.dooranim.entity:SetParent(inst.entity)
            inst.highlightforward = inst.dooranim
        end

        inst.builds = builds

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(
            isdoor and
            { "boards", "boards", "rope" } or
            { "twigs" }
        )

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onworked)

        inst:AddComponent("combat")
        inst.components.combat:SetKeepTargetFunction(keeptargetfn)
        inst.components.combat.onhitfn = onhit

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1)
        inst.components.health:SetAbsorptionAmount(1)
        inst.components.health.fire_damage_scale = 0
        inst.components.health.canheal = false
        inst.components.health.nofadeout = true
        inst:ListenForEvent("death", onhammered)

        MakeMediumBurnable(inst)
        MakeMediumPropagator(inst)
        inst.components.burnable.flammability = .5

        MakeHauntableWork(inst)

        if isdoor then
            inst:AddComponent("activatable")
            inst.components.activatable.OnActivate = ToggleDoor
            inst.components.activatable.standingaction = true
        else
            MakeSnowCovered(inst)
        end

        inst.OnRemoveEntity = onremove

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(name, fn, assets, custom_wall_prefabs or wall_prefabs)
end

-------------------------------------------------------------------------------
local function MakeWallAnim(name, builds, isdoor)
    local assets =
    {
        Asset("ANIM", "anim/"..builds.wide..".zip"),
    }
    if builds.narrow then
        table.insert(assets, Asset("ANIM", "anim/"..builds.narrow..".zip"))
    end

    local function fn()
        local inst = CreateEntity()

        if isdoor then
            --V2C: speecial =) must be the 1st tag added b4 AnimState component
            inst:AddTag("can_offset_sort_pos")
        end

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

        inst.AnimState:SetBank(builds.wide)
        inst.AnimState:SetBuild(builds.wide)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("FX")
        inst:AddTag("nointerpolate")

        if isdoor then
            inst.AnimState:Hide("mouseover")
        end

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst.OnEntityReplicated = OnWallAnimReplicated

            return inst
        end

        MakeSnowCovered(inst)

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

-------------------------------------------------------------------------------
local function MakeInvItem(name, placement, animdata, isdoor)
    local assets =
    {
        Asset("ANIM", "anim/"..animdata..".zip"),
    }
    local item_prefabs =
    {
        placement,
    }

    local function ondeploywall(inst, pt, deployer, rot)
        local wall = SpawnPrefab(placement) 
        if wall ~= nil then 
            local x = math.floor(pt.x) + .5
            local z = math.floor(pt.z) + .5

            wall.Physics:SetCollides(false)
            wall.Physics:Teleport(x, 0, z)
            wall.Physics:SetCollides(true)
            inst.components.stackable:Get():Remove()

            FixUpFenceOrientation(wall, rot or 0)

            wall.SoundEmitter:PlaySound("dontstarve/common/place_structure_wood")
        end
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst:AddTag(isdoor and "gatebuilder" or "fencebuilder")

        inst.AnimState:SetBank(animdata)
        inst.AnimState:SetBuild(animdata)
        inst.AnimState:PlayAnimation("inventory")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploywall
        inst.components.deployable:SetDeployMode(DEPLOYMODE.WALL)

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(name, itemfn, assets, item_prefabs)
end


-------------------------------------------------------------------------------
local function placerupdate(inst)
    FixUpFenceOrientation(inst, nil)
end

local function MakeWallPlacer(placer, placement, builds, isdoor)
    local CreateDoorAnim = isdoor and function(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.Transform:SetEightFaced()

        inst.AnimState:SetBank(builds.wide)
        inst.AnimState:SetBuild(builds.wide)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:Hide("mouseover")
        inst.AnimState:SetLightOverride(1)

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        return inst
    end or nil

    return MakePlacer(
        placer,
        builds.wide,
        builds.wide,
        not isdoor and "idle" or nil,
        nil, nil, true, nil, 0, "eight", 
        function(inst)
            inst.components.placer.onupdatetransform = placerupdate
            inst.builds = builds
            if isdoor then
                inst.isdoor = true
                inst.isswingright = false
                inst.dooranim = CreateDoorAnim()
                inst.dooranim.entity:SetParent(inst.entity)
                inst.components.placer:LinkEntity(inst.dooranim)
            end
        end)
end

return MakeWall("fence", {wide="fence", narrow="fence_thin"}, false),
    MakeInvItem("fence_item", "fence", "fence", false),
    MakeWallPlacer("fence_item_placer", "fence", {wide="fence", narrow="fence_thin"}, false),

    MakeWall("fence_gate", {wide="fence_gate", narrow="fence_gate_thin"}, true),
    MakeWallAnim("fence_gate_anim", {wide="fence_gate", narrow="fence_gate_thin"}, true),
    MakeInvItem("fence_gate_item", "fence_gate", "fence_gate", true),
    MakeWallPlacer("fence_gate_item_placer", "fence_gate", {wide="fence_gate", narrow="fence_gate_thin"}, true)
