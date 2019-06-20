local assets =
{
    Asset("ANIM", "anim/statue_small_type1_build.zip"), -- muse 1
    Asset("ANIM", "anim/statue_small_type2_build.zip"), -- muse 2
    Asset("ANIM", "anim/statue_small_type3_build.zip"), -- urn
    Asset("ANIM", "anim/statue_small_type4_build.zip"), -- pawn
    Asset("ANIM", "anim/statue_small.zip"),
    Asset("MINIMAP_IMAGE", "statue_small"),
}

local prefabs =
{
    "marble",
    "rock_break_fx",
}

--V2C: switched to SKETCH_UNLOCKS table, but keeping this here for searching
--[[local sketchloot =
{
    "chesspiece_muse_sketch",
    "chesspiece_muse_sketch",
    "",
    "chesspiece_pawn_sketch",
}]]

local SKETCH_UNLOCKS =
{
    "muse",
    "muse",
    "",
    "pawn",
}

for i, v in ipairs(SKETCH_UNLOCKS) do
    if v ~= "" then
        table.insert(prefabs, "chesspiece_"..v.."_sketch")
    end
end

SetSharedLootTable('statue_marble',
{
    {'marble',  1.0},
    {'marble',  1.0},
    {'marble',  0.3},
})

local function OnWorked(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())

        local chesspiecename = SKETCH_UNLOCKS[inst.typeid]
        if chesspiecename ~= nil and chesspiecename:len() > 0 then
            TheWorld:PushEvent("ms_unlockchesspiece", chesspiecename)
        end

        inst.components.lootdropper:DropLoot(pos)
        inst:Remove()
    else
        inst.AnimState:PlayAnimation(
            (workleft < TUNING.MARBLEPILLAR_MINE / 3 and "low") or
            (workleft < TUNING.MARBLEPILLAR_MINE * 2 / 3 and "med") or
            "full"
        )
    end
end

local function OnWorkLoad(inst)
    OnWorked(inst, nil, inst.components.workable.workleft)
end

local function setstatuetype(inst, typeid)
    typeid = typeid or math.random(4)
    if typeid ~= inst.typeid then
        inst.typeid = typeid
        inst.AnimState:OverrideSymbol("swap_statue", "statue_small_type"..tostring(typeid).."_build", "swap_statue")
    end
end

local function GetStatus(inst)
    return "TYPE"..tostring(inst.typeid)
end

local function lootsetfn(lootdropper)
    local chesspiecename = SKETCH_UNLOCKS[lootdropper.inst.typeid]
    if chesspiecename ~= "" then
        lootdropper:SetLoot({ chesspiecename ~= nil and ("chesspiece_"..chesspiecename.."_sketch") or nil })
    end
end

local function onsave(inst, data)
    data.typeid = inst.typeid
end

local function onload(inst, data)
    if data ~= nil and data.typeid ~= nil then
        setstatuetype(inst, data.typeid)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst.entity:AddTag("statue")

    inst.AnimState:SetBank("statue_small")
    inst.AnimState:SetBuild("statue_small")
    inst.AnimState:OverrideSymbol("swap_statue", "statue_small_type1_build", "swap_statue")
    inst.AnimState:PlayAnimation("full")

    inst.MiniMapEntity:SetIcon("statue_small.png")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('statue_marble')
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnLoadFn(OnWorkLoad)
    inst.components.workable.savestate = true

    MakeHauntableWork(inst)

    inst.typeid = 1
    setstatuetype(inst)

    --------SaveLoad
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

function specificfn(id)
    return function()
        local inst = fn()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:SetPrefabName("statue_marble")
        setstatuetype(inst, id)

        return inst
    end
end

return Prefab("statue_marble", fn, assets, prefabs),
       Prefab("statue_marble_muse", specificfn(1), assets, prefabs),
       Prefab("statue_marble_pawn", specificfn(4), assets, prefabs)
