local function MooseGooseRandomizeName(inst)
    inst._altname:set(math.random() < .5)
end

local PIECES =
{
    {name="pawn",       moonevent=false},
    {name="rook",       moonevent=true},
    {name="knight",     moonevent=true},
    {name="bishop",     moonevent=true},
    {name="muse",       moonevent=false},
    {name="formal",     moonevent=false},
    {name="hornucopia", moonevent=false},
    {name="pipe",       moonevent=false},

    {name="deerclops",  moonevent=false},
    {name="bearger",    moonevent=false},
    {name="moosegoose", moonevent=false,
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
    {name="dragonfly",  moonevent=false},
    {name="clayhound",  moonevent=false},
    {name="claywarg",   moonevent=false},
} 

local MOON_EVENT_RADIUS = 12
local MOON_EVENT_MINPIECES = 3

local MATERIALS =
{
    {name="marble",     prefab="marble"},
    {name="stone",      prefab="cutstone"},
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
    inst.AnimState:SetBuild(GetBuildName(inst.pieceid, materialid))

    inst.components.lootdropper:SetLoot({MATERIALS[materialid].prefab})
end

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
        local ents = TheSim:FindEntities(x, y, z, MOON_EVENT_RADIUS, { "chess_moonevent" }, { "INLIMBO" })
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
    if PIECES[inst.pieceid].moonevent 
        and TheWorld.state.isnewmoon and
        not inst:IsAsleep() then

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
    if inst._task ~= nil or inst.forcebreak then
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
        local ents = TheSim:FindEntities(x, y, z, MOON_EVENT_RADIUS, { "chess_moonevent" })
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
    data.pieceid = inst.pieceid
end

local function onload(inst, data)
    if data ~= nil then
        inst.pieceid = data.pieceid
        SetMaterial(inst, data.materialid or 1)
    end
end

local function makepiece(pieceid, materialid)
    local build = GetBuildName(pieceid, materialid)

    local assets =
    {
        Asset("ANIM", "anim/chesspiece.zip"),
        Asset("INV_IMAGE", "chesspiece_"..PIECES[pieceid].name),
    }

    local prefabs = 
    {
        "collapse_small",
    }
    if materialid then
        table.insert(prefabs, MATERIALS[materialid].prefab)
        table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))
    else
        for m = 1, #MATERIALS do
            local p = "chesspiece_" .. PIECES[pieceid].name .. "_" .. MATERIALS[m].name
            table.insert(prefabs, p)
        end
    end
    if PIECES[pieceid].moonevent then
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
        if PIECES[pieceid].moonevent then
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
        inst.components.inventoryitem:ChangeImageName("chesspiece_"..PIECES[pieceid].name)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(onworkfinished)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst.OnLoad = onload
        inst.OnSave = onsave

        if not TheWorld:HasTag("cave") then
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
        local piece = SpawnPrefab("chesspiece_"..PIECES[inst.pieceid].name)
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
