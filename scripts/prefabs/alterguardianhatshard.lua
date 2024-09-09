local assets =
{
    Asset("ANIM", "anim/alterguardianhatshard.zip"),
    Asset("ANIM", "anim/ui_alterguardianhat_1x1.zip"),
    Asset("INV_IMAGE", "alterguardianhatshard"),
    Asset("INV_IMAGE", "alterguardianhatshard_red"),
    Asset("INV_IMAGE", "alterguardianhatshard_blue"),
    Asset("INV_IMAGE", "alterguardianhatshard_green"),
    Asset("INV_IMAGE", "alterguardianhatshard_open"),
    Asset("INV_IMAGE", "alterguardianhatshard_red_open"),
    Asset("INV_IMAGE", "alterguardianhatshard_blue_open"),
    Asset("INV_IMAGE", "alterguardianhatshard_green_open"),
}

local assets_fx =
{
	Asset("ANIM", "anim/alterguardianhatshard.zip"),
}

local function UpdateInventoryImage(inst)
    local isopen = inst.components.container:IsOpen()
    local name = "alterguardianhatshard" .. (inst._shardcolour or "") .. (isopen and "_open" or "")
    inst.components.inventoryitem:ChangeImageName(name)
end

local function Bounce(inst)
    if inst.components.inventoryitem.owner == nil then
        inst.AnimState:PlayAnimation("bounce", false)
        inst.AnimState:PushAnimation("idle", false)
    else
        inst.AnimState:PlayAnimation("idle", false)
    end
    UpdateInventoryImage(inst)
end

local function OnPutInInventory(inst)
    inst.components.container:Close()
	inst.Light:Enable(false)
end

local function OnDropped(inst)
	if inst._shardcolour then
		inst.Light:Enable(true)
	end
end

local COLOUR_TINT = { 0.4, 0.2 }
local MULT_TINT = { 0.7, 0.35 }

local function UpdateLightState(inst)
    if not inst.components.container:IsEmpty() then
        local item = inst.components.container:GetItemInSlot(1)

        local r = (item.prefab == MUSHTREE_SPORE_RED and 1) or 0
        local g = (item.prefab == MUSHTREE_SPORE_GREEN and 1) or 0
        local b = (item.prefab == MUSHTREE_SPORE_BLUE and 1) or 0

        inst.Light:SetColour(COLOUR_TINT[g+b + 1] + r/3, COLOUR_TINT[r+b + 1] + g/3, COLOUR_TINT[r+g + 1] + b/3)

        if not inst.components.inventoryitem:IsHeld() then
            inst.Light:Enable(true)
        end

        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetMultColour(MULT_TINT[g+b + 1], MULT_TINT[r+b + 1], MULT_TINT[r+g + 1], 1)

        if r == 1 then
            inst._shardcolour = "_red"
        elseif g == 1 then
            inst._shardcolour = "_green"
        elseif b == 1 then
            inst._shardcolour = "_blue"
        end
    else
        inst.AnimState:ClearBloomEffectHandle()
        inst.AnimState:SetMultColour(.7, .7, .7, 1)
		inst.Light:Enable(false)

        inst._shardcolour = nil
    end
    UpdateInventoryImage(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small", 0.07, 0.73)

    inst.AnimState:SetBank("alterguardianhatshard")
    inst.AnimState:SetBuild("alterguardianhatshard")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetMultColour(.7, .7, .7, 1)

    inst.Light:SetRadius(0.5)
    inst.Light:SetFalloff(0.85)
    inst.Light:SetIntensity(0.5)
    inst.Light:Enable(false)

    inst:AddTag("fulllighter")
    inst:AddTag("lightcontainer")
    inst:AddTag("portablestorage")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("alterguardianhatshard")
    inst.components.container.onopenfn = Bounce
	inst.components.container.onclosefn = Bounce
    inst.components.container.acceptsstacks = false
    inst.components.container.droponopen = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0)

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("itemget", UpdateLightState)
    inst:ListenForEvent("itemlose", UpdateLightState)

    return inst
end

local function SetShardColour(inst, colour)
	if colour == "r" then
		inst.AnimState:SetMultColour(1, 0.3, 0.3, 1)
	elseif colour == "g" then
		inst.AnimState:SetMultColour(0.3, 1, 0.3, 1)
	elseif colour == "b" then
		inst.AnimState:SetMultColour(0.3, 0.3, 1, 1)
	--else
	--	inst.AnimState:SetMultColour(1, 1, 1, 1)
	end
	inst.colour = colour
end

local function SetupFxFromHatShard(inst, shard)
	if not shard.components.container:IsEmpty() then
		local item = shard.components.container:GetItemInSlot(1)
		SetShardColour(inst,
			(item.prefab == MUSHTREE_SPORE_RED and "r") or
			(item.prefab == MUSHTREE_SPORE_GREEN and "g") or
			(item.prefab == MUSHTREE_SPORE_BLUE and "b") or
			nil
		)
	end
end

--Used as symbol follower by winona_battery_high
local function symbolfxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("alterguardianhatshard")
	inst.AnimState:SetBuild("alterguardianhatshard")
	inst.AnimState:PlayAnimation("float", true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(0.5)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

	inst.SetupFxFromHatShard = SetupFxFromHatShard

	inst.persists = false

	return inst
end

return Prefab("alterguardianhatshard", fn, assets),
	Prefab("alterguardianhatshard_symbol_fx", symbolfxfn, assets_fx)
