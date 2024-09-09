local assets =
{
    Asset("ANIM", "anim/decor_flowervase.zip"),
    Asset("ANIM", "anim/swap_flower.zip"),
    Asset("INV_IMAGE", "decor_flowervase"),
    Asset("INV_IMAGE", "decor_flowervase_flowers"),
    Asset("INV_IMAGE", "decor_flowervase_wilted"),
}

local function RefreshImage(inst)
	local skinname = inst:GetSkinName()
	local imagename =
		inst._flower_id and
		((skinname or "decor_flowervase")..(inst._wilttask and "_flowers" or "_wilted")) or
		skinname
		--nil if it's default empty and unskinned

	if inst.components.inventoryitem.imagename ~= imagename then
		inst.components.inventoryitem:ChangeImageName(imagename)
	end
end

local function flower_vase_updatelight(inst)
    if inst._wilttask then
        local remaining = GetTaskRemaining(inst._wilttask) / TUNING.ENDTABLE_FLOWER_WILTTIME
        inst.Light:SetRadius(1.5 + (1.5 * remaining))
        inst.Light:SetIntensity(0.4 + (0.4 * remaining))
        inst.Light:SetFalloff(0.8 + (1 - 1 * remaining))
    end
end

local function flower_vase_lightoff(inst)
    inst.Light:Enable(false)
end

local function flower_vase_ondropped(inst)
    if inst._flower_id and inst._wilttask and TUNING.VASE_FLOWER_SWAPS[inst._flower_id].lightsource then
        inst.AnimState:SetLightOverride(0.3)
        inst.Light:Enable(true)
        inst._lighttask = inst:DoPeriodicTask(TUNING.ENDTABLE_LIGHT_UPDATE + math.random(), flower_vase_updatelight, 0)
    else
        inst.AnimState:SetLightOverride(0)
        inst.Light:Enable(false)
    end
end

-- FLOWER WILT/SET
local function flower_vase_wilt_flower(inst)
    if inst._hack_do_not_wilt then
        if inst._wilttask ~= nil then
            inst._wilttask:Cancel()
            inst._wilttask = nil
        end
        inst._wilttask = inst:DoTaskInTime(inst._hack_do_not_wilt, flower_vase_wilt_flower)
        return
    end

    inst.AnimState:ShowSymbol("swap_flower")
    inst.AnimState:OverrideSymbol("swap_flower", "swap_flower", "f"..tostring(inst._flower_id).."_wilt")
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")

    if inst._lighttask then
        inst.Light:Enable(false)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end

    if inst._wilttask then
        inst._wilttask:Cancel()
        inst._wilttask = nil
    end

	RefreshImage(inst)
end

local function flower_vase_set_flower(inst, flower_id, wilt_time, giver)
    if giver and giver.components.sanity and (not inst._flower_id or not inst._wilttask) then
        local sanity_boost = TUNING.VASE_FLOWER_SWAPS[flower_id].sanityboost
        if sanity_boost ~= 0 then
            giver.components.sanity:DoDelta(sanity_boost)
        end
    end

    inst._flower_id = flower_id

    inst.AnimState:ShowSymbol("swap_flower")
    inst.AnimState:OverrideSymbol("swap_flower", "swap_flower", "f"..tostring(flower_id))
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")

    if inst._lighttask then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
    if not inst.components.inventoryitem:IsHeld() and TUNING.VASE_FLOWER_SWAPS[flower_id].lightsource then
        inst.AnimState:SetLightOverride(0.3)
        inst.Light:Enable(true)
        inst._lighttask = inst:DoPeriodicTask(TUNING.ENDTABLE_LIGHT_UPDATE + math.random(), flower_vase_updatelight, 0)
        inst._hack_do_not_wilt = nil
    else
        inst.AnimState:SetLightOverride(0)
        inst.Light:Enable(false)
        inst._hack_do_not_wilt = wilt_time
    end

    if wilt_time then
        if inst._wilttask then
            inst._wilttask:Cancel()
        end
        inst._wilttask = inst:DoTaskInTime(wilt_time, flower_vase_wilt_flower)
    end

	RefreshImage(inst)
end

--
local function flower_vase_ondecorate(inst, giver, item)
    local item_perishable = item.components.perishable
    local wilt_time = (item_perishable and item_perishable:GetPercent() or 1) * TUNING.ENDTABLE_FLOWER_WILTTIME
    local flower_id = GetRandomItem(TUNING.VASE_FLOWER_MAP[item.prefab])
    flower_vase_set_flower(inst, flower_id, wilt_time, giver)
end

local function flower_vase_lootsetfn(lootdropper)
    if lootdropper.inst._flower_id then
        lootdropper:SetLoot({"spoiled_food"})
    end
end

local function flower_vase_getstatus(inst)
    return (not inst._flower_id and "EMPTY")
        or (not inst._wilttask and "WILTED")
        or (TUNING.VASE_FLOWER_SWAPS[inst._flower_id].lightsource and
            ((GetTaskRemaining(inst._wilttask) / TUNING.ENDTABLE_FLOWER_WILTTIME) < 0.1 and "OLDLIGHT"
            or "FRESHLIGHT"))
        or nil
end

-- BURNABLE
local function onignite(inst)
    inst.components.vase:Disable()
    if inst._flower_id then
        inst._hack_do_not_wilt = nil
        flower_vase_wilt_flower(inst)
    end

    DefaultBurnFn(inst)
end

local function onextinguish(inst)
    inst.components.vase:Enable()
    DefaultExtinguishFn(inst)
end

local function onburnt(inst)
    inst.components.vase:Disable()
    if inst._flower_id then
        inst.components.lootdropper:SpawnLootPrefab("ash")
    end
    inst._flower_id = nil

    if inst._wilttask then
        inst._wilttask:Cancel()
        inst._wilttask = nil
    end

    inst.Light:Enable(false)
    if inst._lighttask then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end

    inst.AnimState:HideSymbol("swap_flower")
    inst.AnimState:SetLightOverride(0)

    -- This will also spawn an ash, so we spawn 2 if there was a flower in the vase.
    DefaultBurntFn(inst)
end

--
local function OnLongUpdate(inst, dt)
    if inst._wilttask then
        local time_remaining = GetTaskRemaining(inst._wilttask) - dt
        inst._wilttask:Cancel()

        if time_remaining > 0 then
            inst._wilttask = inst:DoTaskInTime(time_remaining, flower_vase_wilt_flower)
        else
            flower_vase_wilt_flower(inst)
        end
    end
end

-- SAVE/LOAD
local function OnSave(inst, data)
    data.flower_id = inst._flower_id
    if inst._wilttask then
        data.wilt_time = GetTaskRemaining(inst._wilttask)
    end
end

local function OnLoad(inst, data)
    if not data then return end

    if data.flower_id then
        if data.wilt_time then
            flower_vase_set_flower(inst, data.flower_id, data.wilt_time)
        else
            inst._flower_id = data.flower_id
            flower_vase_wilt_flower(inst)
        end
    end
end

--
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("decor_flowervase")
    inst.AnimState:SetBuild("decor_flowervase")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:HideSymbol("swap_flower")

    inst:AddTag("furnituredecor") -- From "furnituredecor", for optimization

    inst.Light:SetFalloff(0.9)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1.5)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(false)

    MakeInventoryFloatable(inst, "small", 0.05, 0.65)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --inst._flower_id = nil
    --inst._wilttask = nil
    --inst._lighttask = nil

    --
    local furnituredecor = inst:AddComponent("furnituredecor")
    furnituredecor.onputonfurniture = flower_vase_ondropped

    --
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = flower_vase_getstatus

    --
    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetOnDroppedFn(flower_vase_ondropped)
    inventoryitem:SetOnPutInInventoryFn(flower_vase_lightoff)

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetLootSetupFn(flower_vase_lootsetfn)

    --
    local vase = inst:AddComponent("vase")
    vase.ondecorate = flower_vase_ondecorate

    --
    MakeHauntable(inst)

    --
    local burnable = MakeSmallBurnable(inst)
    burnable:SetOnIgniteFn(onignite)
    burnable:SetOnExtinguishFn(onextinguish)
    burnable:SetOnBurntFn(onburnt)

    MakeSmallPropagator(inst)

    --
    inst.OnLongUpdate = OnLongUpdate
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	inst.RefreshImage = RefreshImage --used by prefabskin.lua as well, to support reskin_tool

    return inst
end

return Prefab("decor_flowervase", fn, assets)