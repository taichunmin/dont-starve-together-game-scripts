local assets =
{
    Asset("ANIM", "anim/marble_pillar.zip"),
}

local prefabs =
{
    "marble",
    "rock_break_fx",
}

SetSharedLootTable( 'marble_pillar',
{
    {'marble', 1.00},
    {'marble', 1.00},
    {'marble', 0.33},
})

local function onworked(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("marble_pillar")
    inst.AnimState:SetBuild("marble_pillar")
    inst.AnimState:PlayAnimation("full")
    inst.scrapbook_anim = "full"

    inst.MiniMapEntity:SetIcon("marblepillar.png")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('marble_pillar')

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(onworked)

    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    return inst
end

return Prefab("marblepillar", fn, assets, prefabs)
