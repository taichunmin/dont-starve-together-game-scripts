require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sign_mini.zip"),
    Asset("ATLAS_BUILD", "images/inventoryimages1.xml", 256),
    Asset("ATLAS_BUILD", "images/inventoryimages2.xml", 256),
    Asset("ATLAS_BUILD", "images/inventoryimages3.xml", 256),
}

local assets_item =
{
    Asset("ANIM", "anim/sign_mini.zip"),
}

local prefabs =
{
    "minisign_item",
    "minisign_drawn",
}

local prefabs_item =
{
    "minisign",
}

local function ondeploy(inst, pt)--, deployer)
    local ent = SpawnPrefab("minisign", inst.linked_skinname, inst.skin_id )

    if inst.components.stackable ~= nil then
        inst.components.stackable:Get():Remove()
    else
        ent.components.drawable:OnDrawn(inst.components.drawable:GetImage(), nil, inst.components.drawable:GetAtlas(), inst.components.drawable:GetBGImage(), inst.components.drawable:GetBGAtlas())
        ent._imagename:set(inst._imagename:value())
        inst:Remove()
    end

    ent.Transform:SetPosition(pt:Get())
    ent.SoundEmitter:PlaySound("dontstarve/common/sign_craft")
end

local function dig_up(inst)--, worker)
    local image = inst.components.drawable:GetImage()
    if image ~= nil then
        local item = inst.components.lootdropper:SpawnLootPrefab("minisign_drawn", nil, inst.linked_skinname_drawn, inst.skin_id )
        item.components.drawable:OnDrawn(image, nil, inst.components.drawable:GetAtlas(), inst.components.drawable:GetBGImage(), inst.components.drawable:GetBGAtlas())
        item._imagename:set(inst._imagename:value())
    else
        inst.components.lootdropper:SpawnLootPrefab("minisign_item", nil, inst.linked_skinname, inst.skin_id )
    end
    inst:Remove()
end

local function onignite(inst)
    DefaultBurnFn(inst)
    inst.components.drawable:SetCanDraw(false)
end

local function onextinguish(inst)
    DefaultExtinguishFn(inst)
    if inst.components.drawable:GetImage() == nil then
        inst.components.drawable:SetCanDraw(true)
    end
end

local function OnDrawnFn(inst, image, src, atlas, bgimage, bgatlas)
    if image ~= nil then
        inst.AnimState:OverrideSymbol("SWAP_SIGN", atlas or GetInventoryItemAtlas(image..".tex"), image..".tex")
        if bgimage ~= nil then
            inst.AnimState:OverrideSymbol("SWAP_SIGN_BG", bgatlas or GetInventoryItemAtlas(bgimage..".tex"), bgimage..".tex")
        else
            inst.AnimState:ClearOverrideSymbol("SWAP_SIGN_BG")
        end

        if inst:HasTag("sign") then
            inst.components.drawable:SetCanDraw(false)
            inst._imagename:set(src ~= nil and (src.drawnameoverride or src:GetBasicDisplayName()) or "")
            if src ~= nil then
                inst.SoundEmitter:PlaySound("dontstarve/common/together/draw")
            end
        end
    else
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN")
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN_BG")
        if inst:HasTag("sign") then
            if not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
                inst.components.drawable:SetCanDraw(true)
            end
            inst._imagename:set("")
        end
    end
end

local function getstatus(inst)
    return inst.components.drawable:GetImage() == nil
        and "UNDRAWN"
        or nil
end

local function IsLowPriorityAction(act, force_inspect)
    return act == nil
        or act.action == ACTIONS.WALKTO
        or (act.action == ACTIONS.LOOKAT and not force_inspect)
end

--Runs on clients
local function CanMouseThrough(inst)
    if not inst:HasTag("fire") and ThePlayer ~= nil and ThePlayer.components.playeractionpicker ~= nil then
        local force_inspect = ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller:IsControlPressed(CONTROL_FORCE_INSPECT)
        local lmb, rmb = ThePlayer.components.playeractionpicker:DoGetMouseActions(inst:GetPosition(), inst)
        return IsLowPriorityAction(rmb, force_inspect)
            and IsLowPriorityAction(lmb, force_inspect)
    end
end

local function displaynamefn(inst)
    return #inst._imagename:value() > 0
        and subfmt(STRINGS.NAMES.MINISIGN_DRAWN, { item = inst._imagename:value() })
        or STRINGS.NAMES.MINISIGN
end

local function OnSave(inst, data)
    data.imagename =
        inst.components.drawable:GetImage() ~= nil and
        #inst._imagename:value() > 0 and
        inst._imagename:value() ~= STRINGS.NAMES[string.upper(inst.components.drawable:GetImage())] and
        inst._imagename:value() or
        nil
end

local function OnLoad(inst, data)
    inst._imagename:set(
        inst.components.drawable:GetImage() ~= nil and (
            data ~= nil and
            data.imagename ~= nil and
            #data.imagename > 0 and
            data.imagename or
            STRINGS.NAMES[string.upper(inst.components.drawable:GetImage())]
        ) or ""
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sign_mini")
    inst.AnimState:SetBuild("sign_mini")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

	inst:SetDeploySmartRadius(0) --item has special NONE spacing

    inst:AddTag("sign")

    --drawable (from drawable component) added to pristine state for optimization
    inst:AddTag("drawable")

    inst.CanMouseThrough = CanMouseThrough
    inst.displaynamefn = displaynamefn
    inst._imagename = net_string(inst.GUID, "minisign._imagename")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    inst:AddComponent("drawable")
    inst.components.drawable:SetOnDrawnFn(OnDrawnFn)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)

    MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function MakeItem(name, drawn)
    local function item_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("sign_mini")
        inst.AnimState:SetBuild("sign_mini")
        inst.AnimState:PlayAnimation(drawn and "item_drawn" or "item")

        if drawn then
            inst.displaynamefn = displaynamefn
            inst.drawnameoverride = STRINGS.NAMES.MINISIGN
            inst._imagename = net_string(inst.GUID, name.."._imagename")
            --Use planted inspect strings for drawn version
            inst:SetPrefabNameOverride("minisign")
        end

        MakeInventoryFloatable(inst, "med", 0.05, 0.65)

        inst.scrapbook_anim = "item"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        if drawn then
            inst.OnSave = OnSave
            inst.OnLoad = OnLoad

            inst:AddComponent("drawable")
            inst.components.drawable:SetOnDrawnFn(OnDrawnFn)
            inst.components.drawable:SetCanDraw(false)
        else
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeHauntableLaunchAndIgnite(inst)

        return inst
    end

    return Prefab(name, item_fn, assets_item, prefabs_item)
end

return Prefab("minisign", fn, assets, prefabs),
    MakeItem("minisign_item", false),
    MakeItem("minisign_drawn", true),
    MakePlacer("minisign_item_placer", "sign_mini", "sign_mini", "idle"),
    MakePlacer("minisign_drawn_placer", "sign_mini", "sign_mini", "idle")
