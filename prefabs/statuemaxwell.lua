local assets =
{
    Asset("ANIM", "anim/statue_maxwell.zip"),
    Asset("MINIMAP_IMAGE", "statue"),
}

local prefabs =
{
    "marble",
    "rock_break_fx",
    "chesspiece_formal_sketch",
}

SetSharedLootTable('statue_maxwell',
{
    { 'chesspiece_formal_sketch', 1.00},
    { 'marble', 1.00 },
    { 'marble', 1.00 },
    { 'marble', 0.33 },
})

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
        TheWorld:PushEvent("ms_unlockchesspiece", "formal")
        inst.components.lootdropper:DropLoot(pos)
        inst:Remove()
    elseif workleft < TUNING.MARBLEPILLAR_MINE / 3 then
        inst.AnimState:PlayAnimation("hit_low")
        inst.AnimState:PushAnimation("idle_low")
    elseif workleft < TUNING.MARBLEPILLAR_MINE * 2 / 3 then
        inst.AnimState:PlayAnimation("hit_med")
        inst.AnimState:PushAnimation("idle_med")
    else
        inst.AnimState:PlayAnimation("hit_full")
        inst.AnimState:PushAnimation("idle_full")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("maxwell")
    inst.entity:AddTag("statue")

    MakeObstaclePhysics(inst, .66)

    inst.MiniMapEntity:SetIcon("statue.png")

    inst.AnimState:SetBank("statue_maxwell")
    inst.AnimState:SetBuild("statue_maxwell")
    inst.AnimState:PlayAnimation("idle_full")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('statue_maxwell')

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    --TODO: Custom variables for mining speed/cost
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)

    MakeHauntableWork(inst)

    return inst
end

return Prefab("statuemaxwell", fn, assets, prefabs)
