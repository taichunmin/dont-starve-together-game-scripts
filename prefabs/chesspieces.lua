local function MooseGooseRandomizeName(inst)
    inst._altname:set(math.random() < .5)
end

local PIECES =
{
    {name="pawn",			moonevent=false,    gymweight=3},
    {name="rook",			moonevent=true,     gymweight=3},
    {name="knight",			moonevent=true,     gymweight=3},
    {name="bishop",			moonevent=true,     gymweight=3},
    {name="muse",			moonevent=false,    gymweight=3},
    {name="formal",			moonevent=false,    gymweight=3},
    {name="hornucopia",		moonevent=false,    gymweight=3},
    {name="pipe",			moonevent=false,    gymweight=3},

    {name="deerclops",		moonevent=false,    gymweight=4},
    {name="bearger",		moonevent=false,    gymweight=4},
    {name="moosegoose",		moonevent=false,    gymweight=4,
        common_postinit = function(inst)
            inst._altname = net_bool(inst.GUID, "chesspiece_moosegoose._altname")
            inst.displaynamefn = function(inst)
                return inst._altname:value() and STRINGS.NAMES[string.upper(inst.prefab).."_ALT"] or nil
            end
        end,
        master_postinit = function(inst)
            inst:DoPeriodicTask(5, MooseGooseRandomizeName)
            MooseGooseRandomizeName(inst)
        end,
    },
    {name="dragonfly",		     moonevent=false,    gymweight=4},
    {name="clayhound",		     moonevent=false,    gymweight=3},
    {name="claywarg",		     moonevent=false,    gymweight=3},
    {name="butterfly",		     moonevent=false,    gymweight=3},
    {name="anchor",			     moonevent=false,    gymweight=3},
    {name="moon",			     moonevent=false,    gymweight=4},
    {name="carrat",			     moonevent=false,    gymweight=3},
    {name="beefalo",		     moonevent=false,    gymweight=3},
    {name="crabking",		     moonevent=false,    gymweight=4},
    {name="malbatross",		     moonevent=false,    gymweight=4},
    {name="toadstool",		     moonevent=false,    gymweight=4},
    {name="stalker",		     moonevent=false,    gymweight=4},
    {name="klaus",			     moonevent=false,    gymweight=4},
    {name="beequeen",		     moonevent=false,    gymweight=4},
    {name="antlion",		     moonevent=false,    gymweight=4},
    {name="minotaur",		     moonevent=false,    gymweight=4},
    {name="guardianphase3",      moonevent=false,    gymweight=4},
    {name="eyeofterror",	     moonevent=false,    gymweight=4},
    {name="twinsofterror",	     moonevent=false,    gymweight=4},
    {name="kitcoon",		     moonevent=false,    gymweight=3},
    {name="catcoon",		     moonevent=false,    gymweight=3},
    {name="manrabbit",           moonevent=false,    gymweight=3},
    {name="daywalker",           moonevent=false,    gymweight=4},
    {name="deerclops_mutated",   moonevent=false,    gymweight=4},
    {name="warg_mutated",        moonevent=false,    gymweight=4},
    {name="bearger_mutated",     moonevent=false,    gymweight=4},
    {name="yotd",                moonevent=false,    gymweight=3},
    {name="sharkboi",            moonevent=false,    gymweight=4},
}

local MOON_EVENT_RADIUS = 12
local MOON_EVENT_MINPIECES = 3

local MOONGLASS_NAME = "moonglass"
local MATERIALS =
{
    {name="marble",         prefab="marble",        inv_suffix=""},
    {name="stone",          prefab="cutstone",      inv_suffix="_stone"},
    {name=MOONGLASS_NAME,   prefab="moonglass",  inv_suffix="_moonglass"},
}

local PHYSICS_RADIUS = .45

local function GetBuildName(pieceid, materialid)
    local build = "swap_chesspiece_" .. PIECES[pieceid].name

    if materialid then
        build = build .. "_" .. MATERIALS[materialid].name
    end

    return build
end

local function SetMaterial(inst, materialid)
	inst.materialid = materialid
	local build = GetBuildName(inst.pieceid, materialid)
    inst.AnimState:SetBuild(build)

	inst.components.lootdropper:SetLoot({MATERIALS[materialid].prefab})

	inst.components.symbolswapdata:SetData(build, "swap_body")

    local inv_image_suffix = (materialid ~= nil and MATERIALS[materialid].inv_suffix) or ""
    inst.components.inventoryitem:ChangeImageName("chesspiece_"..PIECES[inst.pieceid].name..inv_image_suffix)
end

local MOONCHESS_MUST_TAGS = { "chess_moonevent" }
local MOONCHESS_CANT_TAGS = { "INLIMBO" }

local function DoStruggle(inst, count)
    if inst.forcebreak then
        if inst.components.workable ~= nil then
            inst.AnimState:PlayAnimation("jiggle")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/sculptures/shake")
            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() * 0.8, function(inst)
                if inst and inst.components.workable then
                    inst.components.workable:Destroy(inst)
                end
            end)
        end
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, MOON_EVENT_RADIUS, MOONCHESS_MUST_TAGS, MOONCHESS_CANT_TAGS)
        inst.AnimState:PlayAnimation("jiggle")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/sculptures/shake")
        inst._task =
            count > 1 and
            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), DoStruggle, count - 1) or
            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + math.random() + .6, DoStruggle, math.max(1, math.random(3) - 1))
    end
end

local function StartStruggle(inst)
    if inst._task == nil then
        inst._task = inst:DoTaskInTime(math.random(), DoStruggle, 1)
    end
end

local function StopStruggle(inst)
    if inst._task ~= nil and inst.forcebreak ~= true then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function CheckMorph(inst)
    if (inst.materialid ~= nil and MATERIALS[inst.materialid].name == MOONGLASS_NAME) then
        return
    end

    if PIECES[inst.pieceid].moonevent
        and TheWorld.state.isnewmoon
        and not inst:IsAsleep() then

        StartStruggle(inst)
    else
        StopStruggle(inst)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", GetBuildName(inst.pieceid, inst.materialid), "swap_body")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function onworkfinished(inst)
    local is_moonglass = (inst.materialid ~= nil and MATERIALS[inst.materialid].name == MOONGLASS_NAME)

    if not is_moonglass and (inst._task ~= nil or inst.forcebreak) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")

        local creature = SpawnPrefab("shadow_"..PIECES[inst.pieceid].name)
        creature.Transform:SetPosition(inst.Transform:GetWorldPosition())
        creature.Transform:SetRotation(inst.Transform:GetRotation())
        creature.sg:GoToState("taunt")

        local player = creature:GetNearestPlayer(true)
        if player ~= nil and creature:IsNear(player, 20) then
            creature.components.combat:SetTarget(player)
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, MOON_EVENT_RADIUS, MOONCHESS_MUST_TAGS)
        for i, v in ipairs(ents) do
            v.forcebreak = true
        end
    end

    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function getstatus(inst)
    return (inst._task ~= nil and "STRUGGLE")
        or nil
end

local function OnShadowChessRoar(inst, forcebreak)
    inst.forcebreak = true
    StartStruggle(inst)
end

local function onsave(inst, data)
    data.materialid = inst.materialid
end

local function onload(inst, data)
    if data ~= nil then
        SetMaterial(inst, data.materialid or 1)

        -- The moonglass sculptures don't need any of the shadow creature stuff.
        if (inst.materialid ~= nil and MATERIALS[inst.materialid].name == MOONGLASS_NAME) then
            inst:RemoveTag("chess_moonevent")
            inst:RemoveTag("event_trigger")
            inst.OnEntityWake = nil
            inst.OnEntitySleep = nil

            inst:StopWatchingWorldState("isnewmoon", CheckMorph)
            inst:RemoveEventCallback("shadowchessroar", OnShadowChessRoar)
        end
    end
end

local function islightgymweight(id)
    if PIECES[id].gymweight then

    end
end

local function makepiece(pieceid, materialid)
    local build = GetBuildName(pieceid, materialid)

    local assets =
    {
        Asset("ANIM", "anim/chesspiece.zip"),
    }

    local prefabs =
    {
		"collapse_small",

		"underwater_salvageable",
		"splash_green",
    }
    if materialid then
        table.insert(prefabs, MATERIALS[materialid].prefab)
        table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))
        table.insert(assets, Asset("INV_IMAGE", "chesspiece_"..PIECES[pieceid].name..MATERIALS[materialid].inv_suffix))
    else
        for m = 1, #MATERIALS do
            local p = "chesspiece_" .. PIECES[pieceid].name .. "_" .. MATERIALS[m].name
            table.insert(prefabs, p)

            table.insert(assets, Asset("INV_IMAGE", "chesspiece_"..PIECES[pieceid].name..MATERIALS[m].inv_suffix))
        end
    end
    if PIECES[pieceid].moonevent and (materialid == nil or MATERIALS[materialid].name ~= MOONGLASS_NAME) then
        table.insert(prefabs, "shadow_"..PIECES[pieceid].name)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeHeavyObstaclePhysics(inst, PHYSICS_RADIUS)
        inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)

        inst.AnimState:SetBank("chesspiece")
        inst.AnimState:SetBuild("swap_chesspiece_"..PIECES[pieceid].name.."_marble")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("heavy")
        inst.gymweight = PIECES[pieceid].gymweight or 2

        if PIECES[pieceid].moonevent and (materialid == nil or MATERIALS[materialid].name ~= MOONGLASS_NAME) then
            inst:AddTag("chess_moonevent")
            inst:AddTag("event_trigger")
        end

        inst:SetPrefabName("chesspiece_"..PIECES[pieceid].name)

        if PIECES[pieceid].common_postinit ~= nil then
            PIECES[pieceid].common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heavyobstaclephysics")
        inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("lootdropper")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
		inst.components.workable:SetOnFinishCallback(onworkfinished)

		inst:AddComponent("submersible")
		inst:AddComponent("symbolswapdata")
		inst.components.symbolswapdata:SetData(build, "swap_body")

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst.OnLoad = onload
        inst.OnSave = onsave

        if not TheWorld:HasTag("cave") and (materialid == nil or MATERIALS[materialid].name ~= MOONGLASS_NAME) then
            if PIECES[pieceid].moonevent then
                inst.OnEntityWake = CheckMorph
                inst.OnEntitySleep = CheckMorph
                inst:WatchWorldState("isnewmoon", CheckMorph)
            end

            inst:ListenForEvent("shadowchessroar", OnShadowChessRoar)
        end

        inst.pieceid = pieceid
        if materialid then
            SetMaterial(inst, materialid)
        end

        if PIECES[pieceid].master_postinit ~= nil then
            PIECES[pieceid].master_postinit(inst)
        end

        return inst
    end

    local prefabname = materialid and ("chesspiece_"..PIECES[pieceid].name.."_"..MATERIALS[materialid].name) or ("chesspiece_"..PIECES[pieceid].name)
    return Prefab(prefabname, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function builderonbuilt(inst, builder)
    local prototyper = builder.components.builder.current_prototyper
    if prototyper ~= nil and prototyper.CreateItem ~= nil then
        prototyper:CreateItem("chesspiece_"..PIECES[inst.pieceid].name)
    else
        local piece = SpawnPrefab("chesspiece_"..PIECES[inst.pieceid].name.."_marble")
        piece.Transform:SetPosition(builder.Transform:GetWorldPosition())
    end

    inst:Remove()
end

local function makebuilder(pieceid)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("CLASSIFIED")

        --[[Non-networked entity]]
        inst.persists = false

        --Auto-remove if not spawned by builder
        inst:DoTaskInTime(0, inst.Remove)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.pieceid = pieceid
        inst.OnBuiltFn = builderonbuilt

        return inst
    end

    return Prefab("chesspiece_"..PIECES[pieceid].name.."_builder", fn, nil, { "chesspiece_"..PIECES[pieceid].name })
end

--------------------------------------------------------------------------

local chesspieces = {}
for p = 1,#PIECES do
    table.insert(chesspieces, makepiece(p))
    table.insert(chesspieces, makebuilder(p))
    for m = 1,#MATERIALS do
        table.insert(chesspieces, makepiece(p, m))
    end
end

return unpack(chesspieces)
