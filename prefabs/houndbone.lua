local assets =
{
    Asset("ANIM", "anim/hound_base.zip"),
}

local prefabs =
{
    "boneshard",
    "houndstooth",
    "collapse_small",
}

local names = { "piece1", "piece2", "piece3" }

SetSharedLootTable('houndbone',
{
    {'boneshard',  1.00},
})

local function onsave(inst, data)
    data.anim = inst.animname
end

local function onload(inst, data)
    if data ~= nil and data.anim ~= nil then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname)
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("hound_base")
    inst.AnimState:SetBank("houndbase")

    inst:AddTag("bone")

    --MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local bonetype = math.random(#names)
    inst.animname = names[bonetype]
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('houndbone')
    if bonetype == 3 then
        inst.components.lootdropper:AddChanceLoot("houndstooth", .5)
    end

    MakeHauntableLaunch(inst)

    -------------------
    inst:AddComponent("inspectable")

    --MakeSnowCovered(inst)
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("houndbone", fn, assets, prefabs)
