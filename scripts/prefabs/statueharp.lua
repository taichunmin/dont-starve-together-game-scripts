local assets =
{
    Asset("ANIM", "anim/statue_small.zip"),
    Asset("ANIM", "anim/statue_small_harp_build.zip"),
    Asset("ANIM", "anim/statue_small_harp_vine_build.zip"),
    Asset("MINIMAP_IMAGE", "statue_small"),
}

local prefabs =
{
    "marble",
    "rock_break_fx",
}

SetSharedLootTable( 'statue_harp',
{
    {'marble',  1.0},
    {'marble',  1.0},
    {'marble',  0.3},
})

local function invokecharliesanger(inst)
    inst.AnimState:AddOverrideBuild("statue_small_harp_vine_build")
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

local function OnWorked(inst, worker, workleft)
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

local function OnWorkLoad(inst)
    OnWorked(inst, nil, inst.components.workable.workleft)
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
        inst.charlie_test = data.charlie_test
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

    MakeObstaclePhysics(inst, 0.66)

    inst:AddTag("statue")

    inst.AnimState:SetBank("statue_small")
    inst.AnimState:SetBuild("statue_small")
    inst.AnimState:OverrideSymbol("swap_statue", "statue_small_harp_build", "swap_statue")
    inst.AnimState:PlayAnimation("full")

    inst.scrapbook_build = "statue_small_harp_build"
    inst.scrapbook_anim = "full"

    inst.MiniMapEntity:SetIcon("statue_small.png")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('statue_harp')

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnLoadFn(OnWorkLoad)
    inst.components.workable.savestate = true

    inst:DoTaskInTime(0, doCharlieTest)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave  

    MakeHauntableWork(inst)

    MakeRoseTarget_CreateFuel(inst)

    return inst
end

return Prefab("statueharp", fn, assets, prefabs)