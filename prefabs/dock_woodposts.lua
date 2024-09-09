local assets =
{
    Asset("ANIM", "anim/dock_woodposts.zip"),
}

local prefabs =
{
    "collapse_small",
}

local loot =
{
    "log",
}

local function OnHammered(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function OnHit(inst)
	local idleanim = "idle"..inst._post_id
	if inst.AnimState:IsCurrentAnimation(idleanim) or inst.AnimState:GetCurrentAnimationFrame() >= 15 then
		inst.AnimState:PlayAnimation("place"..inst._post_id)
		inst.AnimState:SetFrame(11)
		inst.AnimState:PushAnimation(idleanim, false)
	end
end

local function setpostid(inst, id)
    if inst._post_id == nil or (id ~= nil and inst._post_id ~= id) then
        inst._post_id = id or tostring(math.random(1, 3))
        inst.AnimState:PlayAnimation("idle"..inst._post_id)
    end
end

local function onsave(inst, data)
    data.post_id = inst._post_id
end

local function onload(inst, data)
    setpostid(inst, (data ~= nil and data.post_id) or nil)
end

local function place(inst)
    inst.SoundEmitter:PlaySound("monkeyisland/dock/post_place")
    
    inst.AnimState:PlayAnimation("place"..inst._post_id)
	inst.AnimState:PushAnimation("idle"..inst._post_id, false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2) --dock_woodposts_item deployspacing/2

    inst.AnimState:SetBank("dock_woodposts")
    inst.AnimState:SetBuild("dock_woodposts")
    inst.AnimState:PlayAnimation("idle1")

    inst.scrapbook_inspectonseen = true

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle3"

    ---------------------------------------------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    ---------------------------------------------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
	inst.components.workable:SetOnWorkCallback(OnHit)

    ---------------------------------------------------------------
    --inst._post_id = nil
    if not POPULATING then
        setpostid(inst)
    end

    inst.place = place
    ---------------------------------------------------------------
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function ondeploy(inst, pt, deployer)
    local prop = SpawnPrefab("dock_woodposts", inst.linked_skinname, inst.skin_id )
    if prop ~= nil then
        prop.Transform:SetPosition(pt.x,pt.y,pt.z)
        prop:place()  
        inst:Remove()
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dock_woodposts")
    inst.AnimState:SetBuild("dock_woodposts")
    inst.AnimState:PlayAnimation("item")

    MakeInventoryFloatable(inst, "med", 0.2, 0.75)
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -------------------------------------------------------
    inst:AddComponent("inspectable")

    -------------------------------------------------------
    inst:AddComponent("inventoryitem")

    -------------------------------------------------------
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)
    inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)

    -------------------------------------------------------
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("dock_woodposts", fn, assets, prefabs),
    Prefab("dock_woodposts_item", itemfn, assets, prefabs),
    MakePlacer("dock_woodposts_item_placer", "dock_woodposts", "dock_woodposts", "idle1")
