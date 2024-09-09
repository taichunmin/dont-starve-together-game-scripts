require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/mighty_gym.zip"),
    Asset("ANIM", "anim/fx_wolfgang.zip"),
    Asset("MINIMAP_IMAGE", "mighty_gym"),
}

local prefabs =
{
	"potatosack",
}

-----------------------------------------------------------------------

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle_empty", true)
        inst.components.mightygym:UnloadWeight()
    end
end

local function onbuilt(inst)
    for i=1, 2 do
        local potatosack = SpawnPrefab("potatosack")
        inst.components.mightygym:LoadWeight(potatosack)
    end
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("wolfgang2/common/gym/place")
end

local function onburnt(inst)
    inst:RemoveComponent("heavyobstacleusetarget")
    inst.components.mightygym:UnloadWeight()
end

local function OnUseHeavy(inst, doer, heavy_item)
    if heavy_item == nil then
		return
	end

	doer.components.inventory:RemoveItem(heavy_item)
	inst.components.mightygym:LoadWeight(heavy_item)

	return true
end


local function onremoved(inst)
    if inst.components.mightygym.strongman then
        inst.components.mightygym:CharacterExitGym(inst.components.mightygym.strongman)
    end
end
--------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("mighty_gym.png")

    MakeObstaclePhysics(inst, 1)

    inst:AddTag("structure")
    inst:AddTag("gym")

    inst.use_heavy_obstacle_string_key = "LOAD_GYM"

    inst.AnimState:SetBank("mighty_gym")
    inst.AnimState:SetBuild("mighty_gym")
    inst.AnimState:OverrideSymbol("fx_star", "fx_wolfgang", "fx_star")
    inst.AnimState:OverrideSymbol("fx_star_part", "fx_wolfgang", "fx_star_part")

    inst.AnimState:PlayAnimation("idle_empty", true)
    inst.scrapbook_anim = "idle_empty"
    inst.scrapbook_overridebuild = "mighty_gym"

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_specialinfo = "MIGHTYGYM"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGmighty_gym")

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("mightygym")

    inst:AddComponent("heavyobstacleusetarget")
	inst.components.heavyobstacleusetarget.on_use_fn = OnUseHeavy

    inst:AddComponent("inventory")
	inst.components.inventory.ignorescangoincontainer = true
	inst.components.inventory.maxslots = 2

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onburnt", onburnt)
    inst:ListenForEvent("onremove", onremoved)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    MakeHauntableWork(inst)

    return inst
end

return Prefab("mighty_gym", fn, assets, prefabs),
	MakePlacer("mighty_gym_placer", "mighty_gym", "mighty_gym", "idle_empty")
