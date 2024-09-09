    local assets =
{
    Asset("ANIM", "anim/statue_maxwell.zip"),
    Asset("ANIM", "anim/statue_maxwell_build.zip"),
    Asset("ANIM", "anim/statue_maxwell_vine_build.zip"),
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

local function invokecharliesanger(inst)
    inst.AnimState:AddOverrideBuild("statue_maxwell_vine_build")
end

local function doCharlieTest(inst)
    if not inst.charlie_test then
        inst.charlie_test = true
        if math.random() < 0.5 then
            inst.charlies_work = true
            invokecharliesanger(inst)
            if math.random()<0.5 then
                if inst.components.workable.workleft == TUNING.MARBLEPILLAR_MINE then
                    local work = math.random(1,TUNING.MARBLEPILLAR_MINE-2)
                    inst.components.workable:WorkedBy(TheWorld, work)
                end
            end
        end
    end
end

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

local function OnSave(inst, data)
    if inst.charlies_work then
        data.charlies_work = inst.charlies_work
    end
    if inst.charlie_test then
        data.charlie_test = inst.charlie_test
    end
end

local function OnLoad(inst, data)
   if data and not data.charlie_test then
        inst.charlie_test= data.charlie_test
   end
   if data and data.charlies_work then
        inst.charlies_work = data.charlies_work
        invokecharliesanger(inst)
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
    inst:AddTag("statue")

    MakeObstaclePhysics(inst, .66)

    inst.MiniMapEntity:SetIcon("statue.png")

    inst.AnimState:SetBank("statue_maxwell")
    inst.AnimState:SetBuild("statue_maxwell_build")
    inst.AnimState:PlayAnimation("idle_full")
    inst.scrapbook_anim = "idle_full"

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

    inst:DoTaskInTime(0,function() 
        doCharlieTest(inst)
    end)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    MakeHauntableWork(inst)

    MakeRoseTarget_CreateFuel(inst)

    return inst
end

return Prefab("statuemaxwell", fn, assets, prefabs)
