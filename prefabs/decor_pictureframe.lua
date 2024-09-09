local assets =
{
    Asset("ANIM", "anim/decor_pictureframe.zip"),
    Asset("INV_IMAGE", "decor_pictureframe"),
    Asset("INV_IMAGE", "decor_pictureframe_drawn"),
    Asset("ATLAS_BUILD", "images/inventoryimages1.xml", 256),
    Asset("ATLAS_BUILD", "images/inventoryimages2.xml", 256),
    Asset("ATLAS_BUILD", "images/inventoryimages3.xml", 256),
}

local function item_frame_displaynamefn(inst)
    local imagename = inst._imagename:value()
    return (#imagename > 0 and subfmt(STRINGS.NAMES.DECOR_PICTUREFRAME_DRAWN, {item = imagename}))
        or STRINGS.NAMES.DECOR_PICTUREFRAME
end

local function OnImageNameDirty(inst)
	inst.drawnameoverride = #inst._imagename:value() > 0 and STRINGS.NAMES.DECOR_PICTUREFRAME_DRAWING or nil
end

local function RefreshImage(inst)
	local skinname = inst:GetSkinName()
	local imagename =
		#inst._imagename:value() > 0 and
		((skinname or "decor_pictureframe").."_drawn") or
		skinname
		--nil if it's default empty and unskinned

	if inst.components.inventoryitem.imagename ~= imagename then
		inst.components.inventoryitem:ChangeImageName(imagename)
	end
end

local function SetImageNameAndIcon(inst, name)
	inst._imagename:set(name)
	OnImageNameDirty(inst)
	RefreshImage(inst)
end

local function item_frame_ondrawn(inst, image, src, atlas, bgimage, bgatlas)
    if image then
        inst.AnimState:OverrideSymbol("SWAP_SIGN", atlas or GetInventoryItemAtlas(image..".tex"), image..".tex")
        if not bgimage then
            inst.AnimState:ClearOverrideSymbol("SWAP_SIGN_BG")
        else
            inst.AnimState:OverrideSymbol("SWAP_SIGN_BG", bgatlas or GetInventoryItemAtlas(bgimage..".tex"), bgimage..".tex")
        end

        inst.components.drawable:SetCanDraw(false)

        if src then
			SetImageNameAndIcon(inst, src.drawnameoverride or src:GetBasicDisplayName() or "")
            --inst.SoundEmitter:PlaySound("dontstarve/common/together/draw")
        else
			SetImageNameAndIcon(inst, "")
        end
    else
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN")
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN_BG")

        local burnable = inst.components.burnable
        if not (burnable and burnable:IsBurning()) then
            inst.components.drawable:SetCanDraw(true)
        end
		SetImageNameAndIcon(inst, "")
    end
end

-- Burnable
local function onignite(inst)
    DefaultBurnFn(inst)
    inst.components.drawable:SetCanDraw(false)
end

local function onextinguish(inst)
    DefaultExtinguishFn(inst)
    if not inst.components.drawable:GetImage() then
        inst.components.drawable:SetCanDraw(true)
    end
end

-- Description status
local function GetStatus(inst)
    return (not inst.components.drawable:GetImage() and "UNDRAWN")
        or nil
end

-- SAVE/LOAD
local function OnSave(inst, data)
    local imagename = inst._imagename:value()
    local drawable_image = inst.components.drawable:GetImage()
    data.imagename = (drawable_image ~= nil and #imagename > 0
        and imagename ~= STRINGS.NAMES[string.upper(drawable_image)]
        and imagename)
        or nil
end

local function OnLoad(inst, data)
    local imagename = ""
    local drawable_image = inst.components.drawable:GetImage()
    if drawable_image then
        if data and data.imagename and data.imagename and #data.imagename > 0 then
            imagename = data.imagename
        else
            imagename = STRINGS.NAMES[string.upper(drawable_image)]
        end
    end

	SetImageNameAndIcon(inst, imagename)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("decor_pictureframe")
    inst.AnimState:SetBuild("decor_pictureframe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("drawable") -- From "drawable", for optimization
    inst:AddTag("furnituredecor") -- From "furnituredecor", for optimization

    -- So that we can inject the name of the thing we've drawn into the display name
	inst._imagename = net_string(inst.GUID, "decor_pictureframe._imagename", "imagenamedirty")
    inst.displaynamefn = item_frame_displaynamefn
	--inst.drawnameoverride = nil

    MakeInventoryFloatable(inst, "med", 0.05, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst:ListenForEvent("imagenamedirty", OnImageNameDirty)

        return inst
    end

    --
    local drawable = inst:AddComponent("drawable")
    drawable:SetOnDrawnFn(item_frame_ondrawn)

    --
    inst:AddComponent("furnituredecor")

    --
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = GetStatus

    --
    inst:AddComponent("inventoryitem")

    --
    MakeHauntable(inst)

    --
    local burnable = MakeSmallBurnable(inst)
    burnable:SetOnIgniteFn(onignite)
    burnable:SetOnExtinguishFn(onextinguish)

    MakeSmallPropagator(inst)

    --
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	inst.RefreshImage = RefreshImage --used by prefabskin.lua as well, to support reskin_tool

    return inst
end

return Prefab("decor_pictureframe", fn, assets)