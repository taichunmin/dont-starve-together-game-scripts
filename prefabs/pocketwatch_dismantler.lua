local assets =
{
    Asset("ANIM", "anim/pocketwatch_dismantler.zip"),
}

local prefabs = 
{
	"brokentool",
	"shadow_puff_solid",
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pocketwatch_dismantler")
    inst.AnimState:SetBuild("pocketwatch_dismantler")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("pocketwatch_dismantler")
	
    inst:AddComponent("inspectable")

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("pocketwatch_dismantler", fn, assets, prefabs)