require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/gingerbread_house1.zip"),
    Asset("ANIM", "anim/gingerbread_house2.zip"),
    Asset("ANIM", "anim/gingerbread_house3.zip"),
    Asset("ANIM", "anim/gingerbread_house4.zip"),
}

local prefabs =
{
    "wintersfeastfuel",
    "gingerdeadpig",
    "crumbs",
}

SetSharedLootTable( 'gingerbreadhouse',
{
    {'wintersfeastfuel',  1.00},
    {'crumbs',            1.00},
    {'crumbs',            1.00},
    {'crumbs',            1.00},
    {'crumbs',            1.00},
    {'crumbs',            1.00},
})


local animdata =
{
    { build = "gingerbread_house1", bank = "gingerbread_house1" },
    { build = "gingerbread_house3", bank = "gingerbread_house2" },
    { build = "gingerbread_house2", bank = "gingerbread_house2" },
    { build = "gingerbread_house4", bank = "gingerbread_house1" },
}

local function sethousetype(inst, bank, build)
	if build == nil or bank == nil then
		local index = math.random(#animdata)
		inst.build = animdata[index].build
		inst.bank  = animdata[index].bank
	else
        inst.build = build
        inst.bank = bank
	end

    inst.AnimState:SetBuild(inst.build)
    inst.AnimState:SetBank(inst.bank)
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")

    if not inst:HasTag("burnt") then
        inst.components.lootdropper:DropLoot()
        if math.random() < 0.3 then
            local gingerdeadman = SpawnPrefab("gingerdeadpig")
            gingerdeadman.Transform:SetPosition(x, y, z)
            inst.components.lootdropper:SpawnLootPrefab("wintersfeastfuel", Point(x,y,z))
        end
    end

    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function OnSave(inst, data)
    data.build = inst.build
    data.bank = inst.bank
end

local function OnLoad(inst, data)
	sethousetype(inst, data ~= nil and data.bank, data ~= nil and data.build)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank(animdata[1].build)
    inst.AnimState:SetBuild(animdata[1].bank)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	if not POPULATING then
		sethousetype(inst)
	end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('gingerbreadhouse')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("inspectable")

    MakeSnowCovered(inst)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("gingerbreadhouse", fn, assets, prefabs)