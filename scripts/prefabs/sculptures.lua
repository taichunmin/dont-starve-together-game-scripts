SetSharedLootTable('sculptures_loot',
{
    {'marble', 1.0},
    {'marble', 0.5},
})

local function onworked(inst, worker, workleft)
    if inst._task ~= nil then
        inst:Reanimate()
    elseif workleft <= TUNING.SCULPTURE_COVERED_WORK then
        inst.components.workable.workleft = 0
    end
end

local PIECE_NAME =
{
    ["sculpture_rookbody"] = "sculpture_rooknose",
    ["sculpture_bishopbody"] = "sculpture_bishophead",
    ["sculpture_knightbody"] = "sculpture_knighthead",
}

local function DoStruggle(inst, count)
    inst.AnimState:PlayAnimation("jiggle")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/sculptures/shake")
    inst._task =
        count > 1 and
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), DoStruggle, count - 1) or
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + math.random() + .6, DoStruggle, math.max(1, math.random(3) - 1))
end

local function StartStruggle(inst)
    if inst._task == nil then
        inst._task = inst:DoTaskInTime(math.random(), DoStruggle, 1)
    end
end

local function StopStruggle(inst)
    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function CheckMorph(inst)
    if inst.components.repairable == nil and
        inst.components.workable.workleft > TUNING.SCULPTURE_COVERED_WORK and
        (TheWorld.state.isfullmoon or TheWorld.state.isnewmoon) and
        not inst:IsAsleep() and
        inst._reanimatetask == nil then
        StartStruggle(inst)
    else
        StopStruggle(inst)
    end
end

local function MakeFixed(inst)
    inst.MiniMapEntity:SetIcon(inst.prefab.."_fixed.png")

    inst.components.workable:SetOnWorkCallback(onworked)

    if inst.components.repairable ~= nil then
        inst:RemoveComponent("repairable")

        inst.SoundEmitter:PlaySound("dontstarve/common/together/sculptures/shake")
        inst.AnimState:PlayAnimation("jiggle")
        inst.AnimState:PushAnimation("fixed", false)
    else
        inst.AnimState:PlayAnimation("fixed")
    end

    inst.components.lootdropper:SetChanceLootTable(nil)

    CheckMorph(inst)
end

local function checkpiece(inst, piece)
    local basename = string.sub(inst.prefab, 1, -5) --remove "body" suffix
    if basename == string.sub(piece.prefab, 1, #basename) then
        return true
    end
    return false, "WRONGPIECE"
end

local function MakeBroken(inst)
    inst.AnimState:PlayAnimation("med")

    inst.components.workable:SetOnWorkCallback(nil)

    if inst.components.repairable == nil then
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.SCULPTURE
        inst.components.repairable.onrepaired = MakeFixed
        inst.components.repairable.checkmaterialfn = checkpiece
        inst.components.repairable.noannounce = true
    end

    StopStruggle(inst)
end

local function getstatus(inst)
    return (inst._task ~= nil and "READY")
        or (inst.components.repairable ~= nil and "UNCOVERED")
        or (inst.components.workable.workleft > TUNING.SCULPTURE_COVERED_WORK and "FINISHED")
        or "COVERED"
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function onworkfinished(inst, worker)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")

    MakeBroken(inst)

    if inst.components.lootdropper.chanceloottable ~= nil then
	    inst.components.lootdropper:DropLoot(inst:GetPosition())
        -- say the uncovered state description string
		if worker ~= nil and worker.components.talker ~= nil and worker:HasTag("player") then
            worker.components.talker:Say(inst.components.inspectable:GetDescription(worker, inst, "UNCOVERED"))
        end
	else
		local pos = inst:GetPosition()
        local offset = FindWalkableOffset(pos, math.random() * TWOPI, inst:GetPhysicsRadius(1) + 0.1, 60, false, false, NoHoles) or Vector3(2, 0, 0)
		local piece = SpawnPrefab(PIECE_NAME[inst.prefab])
		piece.Transform:SetPosition((pos + offset):Get())
    end
end

local function onworkload(inst)
    if inst.components.workable.workleft > TUNING.SCULPTURE_COVERED_WORK then
        MakeFixed(inst)
    elseif inst.components.workable.workleft <= 0 then
        MakeBroken(inst)
    end
end

local function onshadowchessroar(inst)
    if inst.components.repairable == nil and inst.components.workable.workleft > TUNING.SCULPTURE_COVERED_WORK then
        inst:Reanimate(inst, true)
    end
end

local function makesculpture(name, physics_radius, scale, second_piece_name, pointofinterest_height)
    local assets =
    {
        Asset("ANIM", "anim/sculpture_"..name..".zip"),
        Asset("MINIMAP_IMAGE", "sculpture_"..name.."body_full.png"),
        Asset("MINIMAP_IMAGE", "sculpture_"..name.."body_fixed.png"),
    }

    local prefabs =
    {
        "marble",
        "gears",
        "chesspiece_"..name.."_sketch",
        "shadow_"..name,
    }

    if second_piece_name ~= nil then
        table.insert(prefabs, "sculpture_"..second_piece_name)
    end

    local function Reanimate(inst, forceshadow)
        if inst._reanimatetask == nil then
            StopStruggle(inst)

            TheWorld:PushEvent("ms_unlockchesspiece", name)
            inst.components.lootdropper:SpawnLootPrefab("chesspiece_"..name.."_sketch")

            inst.components.workable:SetOnWorkCallback(nil)
            inst.components.workable:SetOnFinishCallback(nil)
            inst.components.workable:SetWorkable(false)

            inst.AnimState:PlayAnimation("transform")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
            RemovePhysicsColliders(inst)
            inst:AddTag("NOCLICK")
            inst.persists = false
            inst._reanimatetask = inst:DoTaskInTime(2, ErodeAway)

            local creaturename = name
            if TheWorld.state.isnewmoon or forceshadow then
                creaturename = "shadow_"..creaturename
                inst.components.lootdropper:SpawnLootPrefab("gears")
                inst.components.lootdropper:SpawnLootPrefab("gears")
            end

            local creature = SpawnPrefab(creaturename)
            creature.Transform:SetPosition(inst.Transform:GetWorldPosition())
            creature.Transform:SetRotation(inst.Transform:GetRotation())
            creature.sg:GoToState("taunt")

            local player = creature:GetNearestPlayer(true)
            if player ~= nil and creature:IsNear(player, 20) then
                creature.components.combat:SetTarget(player)
            end
        end
    end

    local onloadpostpass = second_piece_name ~= nil and function(inst)
        local second_piece = SpawnPrefab("sculpture_"..second_piece_name)

        local placed = false
        while not placed do
            local topology = TheWorld.topology
            local area = topology.nodes[math.random(#topology.nodes)]
			if not table.contains(area.tags, "not_mainland") then
				local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 1)
				if #points_x == 1 and #points_y == 1 then
					local x = points_x[1]
					local z = points_y[1]

					if TheWorld.Map:CanPlantAtPoint(x, 0, z) then
						second_piece.Transform:SetPosition(x, 0, z)
						placed = true
					end
				end
			end
        end
    end or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst:AddTag("statue")
        inst:AddTag("sculpture")
        inst:AddTag("chess_moonevent")
        inst:AddTag("antlion_sinkhole_blocker")

        MakeObstaclePhysics(inst, physics_radius)

        inst.Transform:SetFourFaced()
        inst.Transform:SetScale(scale, scale, scale)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild("sculpture_"..name)
        inst.AnimState:PlayAnimation("full")
        inst.AnimState:SetFinalOffset(1)

        inst:SetPrefabName("sculpture_"..name.."body")
        inst.MiniMapEntity:SetIcon(inst.prefab.."_fixed.png")

        inst.scrapbook_anim = "full"
        inst.scrapbook_specialinfo = "SCULPTURE"

        if not TheNet:IsDedicated() and not second_piece_name then
            inst:AddComponent("pointofinterest")
            inst.components.pointofinterest:SetHeight(pointofinterest_height)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_adddeps = { "sculpture_"..name.."head" }

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable("sculptures_loot")

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetMaxWork(TUNING.SCULPTURE_COMPLETE_WORK)
        inst.components.workable:SetWorkLeft(TUNING.SCULPTURE_COVERED_WORK)
        inst.components.workable:SetOnFinishCallback(onworkfinished)
        inst.components.workable:SetOnLoadFn(onworkload)
        inst.components.workable.savestate = true

        MakeHauntableWork(inst)

        inst.OnLoadPostPass = onloadpostpass
        inst.OnEntityWake = CheckMorph
        inst.OnEntitySleep = CheckMorph

        inst:WatchWorldState("isfullmoon", CheckMorph)
        inst:WatchWorldState("isnewmoon", CheckMorph)

        inst:ListenForEvent("shadowchessroar", onshadowchessroar)

        inst.Reanimate = Reanimate

        return inst
    end

    local prefab_name = "sculpture_"..(second_piece_name ~= nil and name or (name.."body"))
    return Prefab(prefab_name, fn, assets, prefabs)
end

local ROOK_VOLUME = 1.575 --2.25 * .7
local KNIGHT_VOLUME = 0.66
local BISHOP_VOLUME = 0.70
local ROOK_SCALE = .7
local KNIGHT_SCALE = 1
local BISHOP_SCALE = 1

return makesculpture("rook",   ROOK_VOLUME,   ROOK_SCALE,   nil, -10),
       makesculpture("rook",   ROOK_VOLUME,   ROOK_SCALE,   "rooknose"),
       makesculpture("knight", KNIGHT_VOLUME, KNIGHT_SCALE, nil, 170),
       makesculpture("knight", KNIGHT_VOLUME, KNIGHT_SCALE, "knighthead"),
       makesculpture("bishop", BISHOP_VOLUME, BISHOP_SCALE, nil, 100),
       makesculpture("bishop", BISHOP_VOLUME, BISHOP_SCALE, "bishophead")
