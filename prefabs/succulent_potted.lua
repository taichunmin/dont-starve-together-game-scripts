require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/succulent_potted.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function SetupPlant(inst, plantid)
	if inst.plantid == nil then
		inst.plantid = plantid or math.random(5)
	end

    if inst.plantid == 1 then
		inst.AnimState:ClearOverrideSymbol("succulent")
	else
		inst.AnimState:OverrideSymbol("succulent", "succulent_potted", "succulent"..tostring(inst.plantid))
	end
end

local function onsave(inst, data)
    data.plantid = inst.plantid
end

local function onload(inst, data)
    SetupPlant(inst, data ~= nil and data.plantid or nil)
end

local function onhammered(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("pot")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    
    inst.SoundEmitter:PlaySound("dontstarve/common/together/succulent_craft")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("succulent_potted")
    inst.AnimState:SetBuild("succulent_potted")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cavedweller")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableWork(inst)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("lootdropper")

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

	inst:DoTaskInTime(0, SetupPlant)

    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 

    return inst
end

return Prefab("succulent_potted", fn, assets, prefabs),
    MakePlacer("succulent_potted_placer", "succulent_potted", "succulent_potted", "idle")
