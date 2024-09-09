require "prefabutil"

local wall_prefabs =
{
    "collapse_small",
}

local DOOR_LOOT = { "boards", "boards", "rope" }
local FENCE_LOOT = { "twigs" }

SetSharedLootTable("fence_junk",
{
	{ "wagpunk_bits",	0.25	},
	{ "twigs",			1.0		},
})

local FINDDOOR_MUST_TAGS = {"door"}
local FINDWALL_MUST_TAGS = {"wall"}
local FINDWALL_CANT_TAGS = {"alignwall"}

local ROT_SIDES = 8
local function CalcRotationEnum(rot)
    return math.floor((math.floor(rot + 0.5) / 45) % ROT_SIDES)
end

local function CalcFacingAngle(rot)
    return CalcRotationEnum(rot) * 45
end

local function IsNarrow(inst)
    return CalcRotationEnum(inst.Transform:GetRotation()) % 2 == 0
end

local function IsEnumNarrow(enum)
    return enum % 2 == 0
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

local function GetPairedDoor(inst, rot)
    local x, y, z = inst.Transform:GetWorldPosition()

    local swingright = IsSwingRight(inst)
    local search_dist = IsNarrow(inst) and 1.2 or 1.6

    local search_x = -math.sin(rot / RADIANS) * search_dist
    local search_y = math.cos(rot / RADIANS) * search_dist

    search_x = x + (swingright and search_x or -search_x)
    search_y = z + (swingright and -search_y or search_y)

    local paired_door = TheSim:FindEntities(search_x,0,search_y, 0.75, FINDDOOR_MUST_TAGS)[1]
    return paired_door
end

local function FindPairedDoor(inst)

    local rot = inst.Transform:GetRotation()
    local other_door = GetPairedDoor(inst, rot)

    -- On a boat and didn't find anything? Try again, but taking boat rotation into account
    local boat = inst:GetCurrentPlatform()
    if other_door == nil and boat and boat:HasTag("boat") then
        local boat_rotation = boat.Transform:GetRotation()
        other_door = GetPairedDoor(inst, rot - boat_rotation)
    end

    if other_door then
        local swingright = IsSwingRight(inst)
        local opposite_swing = swingright ~= IsSwingRight(other_door)

        -- Round rotating angles to three decimal places to avoid imprecision when comparing the door rotations
        local door_rotation = math.floor(inst.Transform:GetRotation() * 1000) / 1000
        local other_rotation = math.floor(other_door.Transform:GetRotation() * 1000) / 1000
        local opposite_rotation = door_rotation ~= other_rotation
        return (opposite_swing ~= opposite_rotation) and other_door or nil
    end

    return nil
end


local function SetOffset(inst, offset)
    if inst.dooranim ~= nil then
        inst.dooranim.Transform:SetPosition(offset, 0, 0)
    end
end

local function ApplyDoorOffset(inst)
    SetOffset(inst, inst.offsetdoor and 0.45 or 0)
end

local function SetOrientation(inst, rotation, rotation_enum)
    --rotation = CalcFacingAngle(rotation)

    inst.Transform:SetRotation(rotation)

    if inst.anims.narrow then
        local is_narrow = false
        if rotation_enum ~= nil then
            is_narrow = IsEnumNarrow(rotation_enum)
        else
            is_narrow = IsNarrow(inst)
        end

        if is_narrow then
            if not inst.bank_narrow_set then
                inst.bank_narrow_set = true
                inst.bank_wide_set = nil
                GetAnimState(inst):SetBank(inst.anims.narrow)
            end
        else
            if not inst.bank_wide_set then
                inst.bank_wide_set = true
                inst.bank_narrow_set = nil
                GetAnimState(inst):SetBank(inst.anims.wide)
            end
        end

        if inst.isdoor then
            ApplyDoorOffset(inst)
        end
    end
end

local function _calcdooroffset(inst)
    if inst == nil or not inst.isdoor then
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local rot = inst.Transform:GetRotation()

    local search_x = -math.sin(rot / RADIANS) * 1.2
    local search_y = math.cos(rot / RADIANS) * 1.2

    local walls = TheSim:FindEntities(x + search_x, 0, z - search_y, 0.25, FINDWALL_MUST_TAGS, FINDWALL_CANT_TAGS)
    if #walls == 0 then
        walls = TheSim:FindEntities(x - search_x, 0, z + search_y, 0.25, FINDWALL_MUST_TAGS, FINDWALL_CANT_TAGS)
    end
    return #walls > 0
end

local function RefreshDoorOffset(inst)
    if inst == nil or (not inst.isdoor) then
        return
    end

    if not IsNarrow(inst) then
        inst.offsetdoor = false
        ApplyDoorOffset(inst)
        return
    end

    local do_offset = _calcdooroffset(inst)

    local otherdoor = FindPairedDoor(inst)
    if otherdoor and do_offset == false then
        do_offset = _calcdooroffset(otherdoor)
    end

    if inst.offsetdoor ~= do_offset then
        inst.offsetdoor = do_offset
        ApplyDoorOffset(inst)
    end
end

local function FixUpFenceOrientation(inst, deployedrotation)
    local x, y, z = inst.Transform:GetWorldPosition()
    local neighbors = TheSim:FindEntities(x,0,z, 1.5, FINDWALL_MUST_TAGS)

    local rot = inst.Transform:GetRotation()
    local neighbor_index = 1
    local neighbor = neighbors[neighbor_index]
    if deployedrotation ~= nil then --has a value for spawned items
        neighbor_index = 2
        neighbor = neighbors[neighbor_index]
        rot = deployedrotation
    end

    if inst.isdoor then
        SetIsSwingRight(inst, false) --set it to false and assume we'll recalculate each frame
    end

    --Only look for parallel fence/gate neighbours when matching rotation and doing swing-side changes
    local this_e = CalcRotationEnum(rot)
    local neighbor_e = nil
    while neighbor ~= nil do
        neighbor_e = CalcRotationEnum(neighbor.Transform:GetRotation())

        if (neighbor.isdoor or neighbor.prefab == "fence") and (this_e % (ROT_SIDES/2) == neighbor_e % (ROT_SIDES/2)) then
            --found a parallel fence/gate neighbour!
            break
        end
        neighbor_index = neighbor_index + 1
        neighbor = neighbors[neighbor_index]
    end

    if neighbor == nil then
        --no fence/gates, try the first item again it should be a wall
        rot = inst.Transform:GetRotation()
        neighbor = neighbors[1]
        if deployedrotation ~= nil then --has a value for spawned items
            neighbor = neighbors[2]
            rot = deployedrotation
        end
    end

    if neighbor ~= nil then
        --align with fence/gate neighbor if we're placing from behind. This exists so that you can fix a hole in a wall from the back of wall. Needed for the case where the camera is obstructed from placing from the front of the wall
        if (neighbor.isdoor or neighbor.prefab == "fence") and (this_e + ROT_SIDES/2) % ROT_SIDES == neighbor_e then
            rot = rot + 180
            this_e = CalcRotationEnum(rot)
        end

        if inst.isdoor then
            if neighbor.isdoor then
                if this_e == neighbor_e then
                    SetIsSwingRight(inst, not IsSwingRight(neighbor))
                end
            else
                local x, y, z = inst.Transform:GetWorldPosition()
                local x1, y1, z1 = neighbor.Transform:GetWorldPosition()
                local rot_to_neighbor = math.atan2(x - x1, z - z1) * RADIANS

                local swing_right = (CalcRotationEnum(rot_to_neighbor) + 4) % ROT_SIDES == CalcRotationEnum(rot)

                SetIsSwingRight(inst, swing_right)
            end
        end
    end

    SetOrientation(inst, rot)
    RefreshDoorOffset(inst)

    GetAnimState(inst):PlayAnimation(GetAnimName(inst, "idle"))
end

-------------------------------------------------------------------------------

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil and inst:GetCurrentPlatform() == nil then
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

local function junk_spawnhitfx(inst)
	local fx = SpawnPrefab("junk_break_fx")
	local x, y, z = inst.Transform:GetWorldPosition()
	local scale = 0.7 + math.random() * 0.2
	fx.Transform:SetPosition(x, y + math.random(), z)
	fx.Transform:SetScale(scale, scale, scale)
	return fx
end

local function junk_onworkfinishedfn(inst, worker)
	if not worker:HasTag("junkmob") then
		inst.components.lootdropper:DropLoot()
	end
	junk_spawnhitfx(inst)
	inst:Remove()
end

local function junk_onworkfn(inst, worker, workleft, numworks)
	if numworks == 0 then
		if worker:HasTag("junkmob") then
			junk_spawnhitfx(inst)
		elseif worker:HasTag("junk") then
			--junk repairs junk XD
			inst.components.workable:SetWorkLeft(3)
			inst.components.health:SetPercent(1)
		end
	end
	onworked(inst)
end

local function junk_workmultiplierfn(inst, worker, numworks)
	return worker:HasTag("junk") and 0 or nil
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

    if inst._isunlocked ~= nil and not inst._isunlocked:value() then
        return false, "LOCKED_GATE"
    end

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

local function lockabledoor_displaynamefn(inst)
    return not inst._isunlocked:value() and STRINGS.NAMES[string.upper(inst.prefab.."_locked")] or nil
end

local function lockabledoor_getstatus(inst)
    return not inst._isunlocked:value() and "LOCKED" or nil
end

local function onusekey(inst, key, doer)
    if not key:IsValid() or key.components.klaussackkey == nil or inst._isunlocked:value() then
        return false, nil, false
    elseif key.components.klaussackkey.keytype ~= inst.klaussackkeyid then
        return false, "QUAGMIRE_WRONGKEY", false
    end

    inst._isunlocked:set(true)
    local otherdoor = FindPairedDoor(inst)
    if otherdoor ~= nil then
        otherdoor._isunlocked:set(true)
    end

    inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/safe/key")

    ToggleDoor(inst)

    return true, nil, true
end

-------------------------------------------------------------------------------

local function onsave(inst, data)

    -- If we're on a boat, save boat rotation value in its own value separate from the standard rotation data
    local boat = inst:GetCurrentPlatform()
    if boat and boat:HasTag("boat") then
        data.boatrotation = inst.Transform:GetRotation()
    else
        local rot = CalcRotationEnum(inst.Transform:GetRotation())
        data.rot = rot > 0 and rot or nil
    end

    data.offsetdoor = inst.offsetdoor
    data.swingright = inst._isswingright ~= nil and inst._isswingright:value() or nil
    data.isopen = inst._isopen ~= nil and inst._isopen:value() or nil
    data.isunlocked = inst._isunlocked ~= nil and inst._isunlocked:value() or nil
    data.variant_num = inst.variant_num or nil
end

local function onload(inst, data)
    if data ~= nil then
        if inst._isunlocked ~= nil then
            inst._isunlocked:set(data.isunlocked == true)
        end

        inst.offsetdoor = data.offsetdoor

        if inst._isswingright ~= nil then
            SetIsSwingRight(inst, data.swingright or (data.doorpairside == 2)) -- data.doorpairside is deprecated v2, swingright is v3
        end

        local rotation = 0
        inst.loaded_rotation_enum = 0
        if data.rotation ~= nil then
            -- very old style of save data. updates save data to v2 format, safe to remove this when we go out of the beta branch
            rotation = data.rotation - 90
            inst.loaded_rotation_enum = CalcRotationEnum(rotation)
        elseif data.rot ~= nil then
            rotation = data.rot*45
            inst.loaded_rotation_enum = data.rot
        end
        SetOrientation(inst, rotation)

        if data.isopen then
            OpenDoor(inst, true)
        elseif inst._isswingright ~= nil and inst._isswingright:value() then
            GetAnimState(inst):PlayAnimation(GetAnimName(inst, "idle"))
        end

        if data.variant_num then
            inst.variant_num = data.variant_num
            inst.AnimState:SetBuild(inst.basebuild .. inst.variant_num)
        end
    end
end

local function onloadpostpass(inst, newents, data)
    if data == nil then
        --Don't crash on mods placing fences in worldgen
    	return
    end

    inst:DoTaskInTime(0, function(inst)
        -- If fences are placed on rotated boats, we need to account for the boat's rotation
        if data.boatrotation ~= nil then
            -- New method for loading rotation on boats; set the orientation directly
            local rot_enum = CalcRotationEnum(inst.Transform:GetRotation())
            SetOrientation(inst, data.boatrotation, rot_enum)
        else
            -- Old method for loading rotation on boats
            local boat = inst:GetCurrentPlatform()
            if boat and boat:HasTag("boat") then
                local fence_rotation = inst.Transform:GetRotation()
                local boat_rotation = boat.Transform:GetRotation()

                if fence_rotation < 0 then
                    fence_rotation = 360 + fence_rotation
                end

                local fence_rotation_enum = inst.loaded_rotation_enum
                local boat_rot_enum = CalcRotationEnum(boat_rotation)

                local base_rotation_enum = fence_rotation_enum - boat_rot_enum
                SetOrientation(inst, base_rotation_enum * 45 + boat_rotation)

                inst.loaded_rotation_enum = nil
            end
        end
    end)
end

local function MakeWall(name, anims, isdoor, klaussackkeyid, data)
    local assets, custom_wall_prefabs

    if isdoor then
        custom_wall_prefabs = { name.."_anim" }
        for i, v in ipairs(wall_prefabs) do
            table.insert(custom_wall_prefabs, v)
        end
    else
        assets =
        {
            Asset("ANIM", "anim/"..anims.wide..".zip"),
        }
        if anims.narrow then
            table.insert(assets, Asset("ANIM", "anim/"..anims.narrow..".zip"))
        end

		if data and data.num_builds then
			for i = 1, data.num_builds do
                local build = (anims.build or anims.wide) .. i
                table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))
            end
		end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState() --V2C: need this even if we are door, for mouseover sorting
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

		inst:SetDeploySmartRadius(0.5) --DEPLOYMODE.WALL assumes spacing of 1

        MakeObstaclePhysics(inst, .5)
        inst.Physics:SetDontRemoveOnSleep(true)

        inst:AddTag("wall")
        inst:AddTag("fence")
        inst:AddTag("alignwall")
        inst:AddTag("noauradamage")
		inst:AddTag("rotatableobject")

		if data then
			if data.tag then
				inst:AddTag(data.tag)
			end
			if data.num_builds then
				inst.variant_num = math.random(data.num_builds)
				inst.basebuild = anims.build or anims.wide
			end
		end

        if isdoor then
            inst.isdoor = true
            inst:AddTag("door")
            inst._isopen = net_bool(inst.GUID, name.."._open", "doorstatedirty")
            inst._isswingright = net_bool(inst.GUID, name.."._swingright", "doorstatedirty")
            if klaussackkeyid ~= nil then
                inst._isunlocked = net_bool(inst.GUID, name.."._unlocked")
                inst.displaynamefn = lockabledoor_displaynamefn
            end
            inst.GetActivateVerb = getdooractionstring
        else
            inst.AnimState:SetBank(anims.wide)
            inst.AnimState:SetBuild((anims.build or anims.wide) .. (inst.variant_num or ""))
            inst.AnimState:PlayAnimation("idle")

            MakeSnowCoveredPristine(inst)
        end

        inst._pfpos = nil
        inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
        makeobstacle(inst)
        --Delay this because makeobstacle sets pathfinding on by default
        --but we don't to handle it until after our position is set
        inst:DoTaskInTime(0, InitializePathFinding)

        inst.OnRemoveEntity = onremove

        -----------------------------------------------------------------------
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            if isdoor then
                inst:DoTaskInTime(0, OnInitDoorClient)
            end

            return inst
        end

        inst.scrapbook_anim    = "idle"
        inst.scrapbook_build   = (anims.build or anims.wide) .. (inst.variant_num and 1 or "")
        inst.scrapbook_bank    = anims.wide
        inst.scrapbook_facing  = FACING_DOWN

        inst:AddComponent("inspectable")

        if isdoor then
            inst.dooranim = SpawnPrefab(name.."_anim")
            inst.dooranim.entity:SetParent(inst.entity)
            inst.highlightforward = inst.dooranim
            if klaussackkeyid ~= nil then
                inst.components.inspectable.getstatus = lockabledoor_getstatus
            end
        end

        inst.anims = anims

        inst:AddComponent("lootdropper")
		if data and data.loot_table then
			inst.components.lootdropper:SetChanceLootTable(data.loot_table)
        else
			inst.components.lootdropper:SetLoot(isdoor and DOOR_LOOT or FENCE_LOOT)
        end

        if TheNet:GetServerGameMode() ~= "quagmire" then
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(3)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onworked)
			if data then
				if data.onworkfinishedfn then
					inst.components.workable:SetOnFinishCallback(data.onworkfinishedfn)
				end
				if data.onworkfn then
					inst.components.workable:SetOnWorkCallback(data.onworkfn)
				end
				if data.workmultiplierfn then
					inst.components.workable:SetWorkMultiplierFn(data.workmultiplierfn)
				end
			end

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
            inst.components.burnable.nocharring = true

            MakeHauntableWork(inst)
        end

        if isdoor then
            inst:AddComponent("activatable")
            inst.components.activatable.OnActivate = ToggleDoor
            inst.components.activatable.standingaction = true

            if klaussackkeyid ~= nil then
                inst:AddComponent("klaussacklock")
                inst.components.klaussacklock:SetOnUseKey(onusekey)
                inst.klaussackkeyid = klaussackkeyid
            end
        else
            MakeSnowCovered(inst)
        end

        inst.OnSave = onsave
        inst.OnLoad = onload
        inst.OnLoadPostPass = onloadpostpass
        inst.SetOrientation = SetOrientation

        return inst
    end

    local prefabs = custom_wall_prefabs or wall_prefabs
    if data and data.prefabs then
        for _, prefab in ipairs(data.prefabs) do
            table.insert(prefabs, prefab)
        end
    end

    return Prefab(name, fn, assets, prefabs)
end

-------------------------------------------------------------------------------
local function MakeWallAnim(name, anims, isdoor)
    local assets =
    {
        Asset("ANIM", "anim/"..anims.wide..".zip"),
    }
    if anims.narrow then
        table.insert(assets, Asset("ANIM", "anim/"..anims.narrow..".zip"))
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

        inst.AnimState:SetBank(anims.wide)
        inst.AnimState:SetBuild(anims.wide)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("FX")

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

    local function ondeploywall(inst, pt, deployer, rot )
        local wall = SpawnPrefab(placement, inst.linked_skinname, inst.skin_id )
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

		MakeInventoryFloatable(inst, "small", nil, 1.1)

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

local function MakeWallPlacer(placer, placement, anims, isdoor)
    local CreateDoorAnim = isdoor and function(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.Transform:SetEightFaced()

        inst.AnimState:SetBank(anims.wide)
        inst.AnimState:SetBuild(anims.wide)
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
        anims.wide,
        anims.wide,
        not isdoor and "idle" or nil,
        nil, nil, true, nil, 0, "eight",
        function(inst)
            inst.components.placer.onupdatetransform = placerupdate
            inst.anims = anims
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
    MakeWallPlacer("fence_gate_item_placer", "fence_gate", {wide="fence_gate", narrow="fence_gate_thin"}, true),

    MakeWall("quagmire_park_gate", {wide="quagmire_park_gate"}, true, "gate_key"),
    MakeWallAnim("quagmire_park_gate_anim", {wide="quagmire_park_gate"}, true),

	MakeWall("fence_junk", {wide="fence_junk", narrow="fence_thin_junk", build="fence_junk_build"}, false, nil,
		{
			num_builds = 3,
			loot_table = "fence_junk",
			tag = "junk_fence",
			onworkfinishedfn = junk_onworkfinishedfn,
			onworkfn = junk_onworkfn,
			workmultiplierfn = junk_workmultiplierfn,
            prefabs = {"junk_break_fx"},
		})
