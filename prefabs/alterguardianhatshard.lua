local assets =
{
    Asset("ANIM", "anim/alterguardianhatshard.zip"),
    Asset("ANIM", "anim/ui_alterguardianhat_1x1.zip"),
    Asset("INV_IMAGE", "alterguardianhatshard"),
    Asset("INV_IMAGE", "alterguardianhatshard_red"),
    Asset("INV_IMAGE", "alterguardianhatshard_blue"),
    Asset("INV_IMAGE", "alterguardianhatshard_green"),
}

local function bounce(inst)
    inst.AnimState:PlayAnimation("bounce", false)
    inst.AnimState:PushAnimation("idle", false)
end

local function OnPutInInventory(inst)
    inst.components.container:Close()
end

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end

local COLOUR_TINT = { 0.4, 0.2 }
local MULT_TINT = { 0.7, 0.35 }
local function UpdateLightState(inst)
    local was_on = inst.Light:IsEnabled()
    if not inst.components.container:IsEmpty() then
        local item = inst.components.container:GetItemInSlot(1)
        local r = (item.prefab == MUSHTREE_SPORE_RED and 1) or 0
        local g = (item.prefab == MUSHTREE_SPORE_GREEN and 1) or 0
        local b = (item.prefab == MUSHTREE_SPORE_BLUE and 1) or 0
        inst.Light:SetColour(COLOUR_TINT[g+b + 1] + r/3, COLOUR_TINT[r+b + 1] + g/3, COLOUR_TINT[r+g + 1] + b/3)
        inst.AnimState:SetMultColour(MULT_TINT[g+b + 1], MULT_TINT[r+b + 1], MULT_TINT[r+g + 1], 1)

        if r == 1 then
            inst.components.inventoryitem:ChangeImageName("alterguardianhatshard_red")
        elseif g == 1 then
            inst.components.inventoryitem:ChangeImageName("alterguardianhatshard_green")
        elseif b == 1 then
            inst.components.inventoryitem:ChangeImageName("alterguardianhatshard_blue")
        end

        if not was_on then
            inst.Light:Enable(true)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
    else
        if was_on then
            inst.Light:Enable(false)
            inst.AnimState:ClearBloomEffectHandle()
        end
        inst.AnimState:SetMultColour(.7, .7, .7, 1)

        inst.components.inventoryitem:ChangeImageName("alterguardianhatshard")
    end
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

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("alterguardianhatshard")
    inst.components.container.onopenfn = bounce
	inst.components.container.onclosefn = bounce
    inst.components.container.acceptsstacks = false
    inst.components.container.droponopen = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0)

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("itemget", UpdateLightState)
    inst:ListenForEvent("itemlose", UpdateLightState)

    return inst
end

return Prefab("alterguardianhatshard", fn, assets)
