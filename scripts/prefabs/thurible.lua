local assets =
{
    Asset("ANIM", "anim/thurible.zip"),
    Asset("ANIM", "anim/swap_thurible.zip"),
}

local prefabs =
{
    "thuriblebody",
    "thurible_smoke",
}

local function DoExtinguishSound(inst, owner)
    inst._soundtask = nil
    (owner ~= nil and owner:IsValid() and owner.SoundEmitter or inst.SoundEmitter):PlaySound("dontstarve/common/fireOut")
end

local function PlayExtinguishSound(inst)
    if inst._soundtask == nil and inst:GetTimeAlive() > 0 then
        inst._soundtask = inst:DoTaskInTime(0, DoExtinguishSound, inst.components.inventoryitem.owner)
    end
end

local function PlayIgniteSound(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    elseif not POPULATING then
        inst._smoke.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
    end
end

local function onremovesmoke(smoke)
    smoke._thurible._smoke = nil
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:StartConsuming()
        inst:AddTag("shadowlure")

        if inst._body ~= nil or not inst.components.inventoryitem:IsHeld() then
            if inst._smoke == nil then
                inst._smoke = SpawnPrefab("thurible_smoke")
                inst._smoke.entity:AddFollower()
                inst._smoke._thurible = inst
                inst:ListenForEvent("onremove", onremovesmoke, inst._smoke)
                PlayIgniteSound(inst)
            end
            if inst._body ~= nil and
                not inst._body.entity:IsVisible() and
                inst.components.inventoryitem.owner ~= nil then
                inst._smoke.Follower:FollowSymbol(inst.components.inventoryitem.owner.GUID, "swap_object", 68, -70, 0)
            else
                inst._smoke.Follower:FollowSymbol((inst._body or inst).GUID, "thurible_swing", 0, 185, 0)
            end
        elseif inst._smoke ~= nil then
            inst._smoke:Remove()
            PlayExtinguishSound(inst)
        end
    end
end

local function turnoff(inst)
    inst.components.fueled:StopConsuming()
    inst:RemoveTag("shadowlure")

    if inst._smoke ~= nil then
        inst._smoke:Remove()
        PlayExtinguishSound(inst)
    end
end

local function OnRemove(inst)
    if inst._smoke ~= nil then
        inst._smoke:Remove()
    end
    if inst._body ~= nil then
        inst._body:Remove()
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function ToggleOverrideSymbols(inst, owner)
    if owner.sg == nil or (owner.sg:HasStateTag("nodangle")
            or (owner.components.rider ~= nil and owner.components.rider:IsRiding()
                and not owner.sg:HasStateTag("forcedangle"))) then
        owner.AnimState:OverrideSymbol("swap_object", "swap_thurible", "swap_thurible")
        inst._body:Hide()
        if inst._smoke ~= nil then
            inst._smoke.Follower:FollowSymbol(owner.GUID, "swap_object", 65, 0, 0)
        end
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_thurible", "swap_thurible_stick")
        inst._body:Show()
        if inst._smoke ~= nil then
            inst._smoke.Follower:FollowSymbol(inst._body.GUID, "thurible_swing", 0, 185, 0)
        end
    end
end

local function onremovebody(body)
    body._thurible._body = nil
end

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst._body ~= nil then
        inst._body:Remove()
    end
    inst._body = SpawnPrefab("thuriblebody")
    inst._body._thurible = inst
    inst:ListenForEvent("onremove", onremovebody, inst._body)

    inst._body.entity:SetParent(owner.entity)
    inst._body.entity:AddFollower()
    inst._body.Follower:FollowSymbol(owner.GUID, "swap_object", 68, -130, 0)
    inst._body:ListenForEvent("newstate", function(owner, data)
        ToggleOverrideSymbols(inst, owner)
    end, owner)

    ToggleOverrideSymbols(inst, owner)

    if not inst.components.fueled:IsEmpty() then
        turnon(inst)
    end
end

local function onunequip(inst, owner)
    if inst._body ~= nil then
        if inst._body.entity:IsVisible() then
            --need to see the thurible when animating putting away the object
            owner.AnimState:OverrideSymbol("swap_object", "swap_thurible", "swap_thurible")
        end
        inst._body:Remove()
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    turnoff(inst)
end

local function onequiptomodel(inst, owner, from_ground)
    turnoff(inst)
end

local function nofuel(inst)
	inst:RemoveTag("shadow_item")
    if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner ~= nil then
        local data =
        {
            prefab = inst.prefab,
            equipslot = inst.components.equippable.equipslot,
            announce = "ANNOUNCE_THURIBLE_OUT",
        }
        turnoff(inst)
        inst.components.inventoryitem.owner:PushEvent("itemranout", data)
    else
        turnoff(inst)
    end
end

local function CLIENT_PlayFuelSound(inst)
	local parent = inst.entity:GetParent()
	local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
	if container ~= nil and container:IsOpenedBy(ThePlayer) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	end
end

local function SERVER_PlayFuelSound(inst)
	local owner = inst.components.inventoryitem.owner
	if owner == nil then
		inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	elseif inst.components.equippable:IsEquipped() and owner.SoundEmitter ~= nil then
		owner.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	else
		inst.playfuelsound:push()
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			CLIENT_PlayFuelSound(inst)
		end
	end
end

local function ontakefuel(inst)
	inst:AddTag("shadow_item")
	SERVER_PlayFuelSound(inst)
    if inst.components.equippable:IsEquipped() or not inst.components.inventoryitem:IsHeld() then
        turnon(inst)
    end
end

local function OnLoad(inst, data)
    if inst.components.fueled:IsEmpty() then
        nofuel(inst)
    end
end

local function GetShadowLevel(inst)
	return not inst.components.fueled:IsEmpty() and TUNING.THURIBLE_SHADOW_LEVEL or 0
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("thurible")
    inst.AnimState:SetBuild("thurible")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetFinalOffset(1)

	inst:AddTag("shadow_item")
    inst:AddTag("shadowlure")
    inst:AddTag("nopunch")

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

	inst.playfuelsound = net_event(inst.GUID, "thurible.playfuelsound")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		--delayed because we don't want any old events
		inst:DoTaskInTime(0, inst.ListenForEvent, "thurible.playfuelsound", CLIENT_PlayFuelSound)

        return inst
    end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled:InitializeFuelLevel(TUNING.THURIBLE_FUEL_MAX)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled.accepting = true

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.THURIBLE_SHADOW_LEVEL)
	inst.components.shadowlevel:SetLevelFn(GetShadowLevel)

    MakeHauntableLaunch(inst)

    inst.OnRemoveEntity = OnRemove
    inst.OnLoad = OnLoad

    inst._smoke = nil
    turnon(inst)

    return inst
end

local function thuriblebodyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("thurible")
    inst.AnimState:SetBuild("thurible")
    inst.AnimState:PlayAnimation("idle_body_loop", true)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst.persists = false

    return inst
end

return Prefab("thurible", fn, assets, prefabs),
    Prefab("thuriblebody", thuriblebodyfn)
