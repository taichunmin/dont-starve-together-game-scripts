local assets =
{
    Asset("ANIM", "anim/boat_mast2.zip"),
    Asset("INV_IMAGE", "mast_item"),
    Asset("ANIM", "anim/seafarer_mast.zip"),
}

local prefabs =
{
	"boat_mast_sink_fx",
	"collapse_small",
}

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

    if inst.components.mast and hammerer ~= inst.components.mast.boat then
        inst.components.mast:SetBoat(nil)
    end
    inst:Remove()
end

local function on_hit(inst, hitter)
    if inst.components.mast and not inst.components.mast.is_sail_transitioning then
        if inst.components.mast.is_sail_raised then
            inst.AnimState:PlayAnimation("open2_hit")
            inst.AnimState:PushAnimation("open_loop",true)
        else
            inst.AnimState:PlayAnimation("closed_hit")
            inst.AnimState:PushAnimation("closed",true)
        end
    end
end


local function onburnt(inst)
	inst:AddTag("burnt")

	local mast = inst.components.mast
	if mast.boat ~= nil then
		mast.boat.components.boatphysics:RemoveMast(mast)
	end

	inst:RemoveComponent("mast")
end

local function onsave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end

	if inst.components.mast == nil or inst.components.mast.boat == nil then
		data.rotation = inst.Transform:GetRotation()
		data.is_sail_raised = inst.components.mast and inst.components.mast.is_sail_raised or nil
	end
end

local function onload(inst, data)
	if data ~= nil then
		if data.burnt then
			inst.components.burnable.onburnt(inst)
			inst:PushEvent("onburnt")
		end
		if data.rotation then
			inst.Transform:SetRotation(data.rotation)
		end
		if data.is_sail_raised and inst.components.mast ~= nil then
			inst.components.mast:SailUnfurled()
		end
	end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .2)

    inst.Transform:SetEightFaced()

    inst:AddTag("NOBLOCK")
    inst:AddTag("structure")
    inst:AddTag("mast")

    inst.AnimState:SetBank("mast_01")
    inst.AnimState:SetBuild("boat_mast2")
    inst.AnimState:PlayAnimation("closed")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeLargeBurnable(inst, nil, nil, true)
	inst:ListenForEvent("onburnt", onburnt)
    MakeLargePropagator(inst)

    inst:AddComponent("hauntable")
    inst:AddComponent("inspectable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("mast")

    -- The loot that this drops is generated from the uncraftable recipe; see recipes.lua for the items.
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)
    inst.components.workable:SetOnWorkCallback(on_hit)
    

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function ondeploy(inst, pt, deployer, rot)
    local mast = SpawnPrefab( "mast", inst.linked_skinname, inst.skin_id )
    if mast ~= nil then
        mast.Physics:SetCollides(false)
        mast.Physics:Teleport(pt.x, 0, pt.z)
        mast.Physics:SetCollides(true)
        mast.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/place")
        mast.AnimState:PlayAnimation("place")
        mast.AnimState:PushAnimation("closed", false)
        if rot then
            mast.Transform:SetRotation(rot)
			mast.save_rotation = true
        end
        inst:Remove()
    end
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("boat_accessory")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seafarer_mast")
    inst.AnimState:SetBuild("seafarer_mast")
    inst.AnimState:PlayAnimation("IDLE")

    MakeInventoryFloatable(inst, "med", 0.25, 0.83)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy   
    inst.components.deployable:SetDeployMode(DEPLOYMODE.MAST) 
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)   

    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")    

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mast", fn, assets, prefabs),
       Prefab("mast_item", item_fn, assets),
       MakePlacer("mast_item_placer", "mast_01", "boat_mast2", "closed", nil,nil,nil,nil,0,"eight")
