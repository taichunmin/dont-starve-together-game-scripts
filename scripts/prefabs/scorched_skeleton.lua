local assets =
{
    Asset("ANIM", "anim/scorched_skeletons.zip"),
}

local prefabs = {
    "boneshard",
    "collapse_small",
    "ash",
}

local animstates = { 1, 2, 3, 4, 5, 6 }

SetSharedLootTable("scorched_skeleton", {
    {"boneshard", 1.00},
    {"boneshard", 0.75},
    {"ash", 1.00},
    {"ash", 0.75},
    {"ash", 0.50},
    {"ash", 0.25},
})

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")
    inst:Remove()
end

local function onsave(inst, data)
    data.anim = inst.animnum
end

local function onload(inst, data)
    if data ~= nil then
        if data.anim ~= nil then
            inst.animnum = data.anim
            inst.AnimState:PlayAnimation("idle"..inst.animnum)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeSmallObstaclePhysics(inst, 0.25)

    inst.AnimState:SetBank("skeleton")
    inst.AnimState:SetBuild("scorched_skeletons")

    inst.animnum = animstates[math.random(#animstates)]
    inst.AnimState:PlayAnimation("idle"..inst.animnum)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local inspectable = inst:AddComponent("inspectable")
    inspectable:RecordViews()

    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("scorched_skeleton")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnFinishCallback(onhammered)

    if not TheSim:HasPlayerSkeletons() then
        inst:Hide()
        inst:DoTaskInTime(0, inst.Remove)
    end

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return Prefab("scorched_skeleton", fn, assets, prefabs)