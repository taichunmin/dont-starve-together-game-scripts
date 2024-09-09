local assets =
{
    Asset("ANIM", "anim/quagmire_soil.zip"),
}

local function IsLowPriorityAction(act)
    return act == nil or act.action ~= ACTIONS.PLANTSOIL
end

--Runs on clients
local function CanMouseThrough(inst)
    if ThePlayer ~= nil and ThePlayer.components.playeractionpicker ~= nil then
        local lmb, rmb = ThePlayer.components.playeractionpicker:DoGetMouseActions(inst:GetPosition(), inst)
        return IsLowPriorityAction(rmb) and IsLowPriorityAction(lmb), true
    end
end

local function DisplayNameFn(inst)
    return TheInput:ControllerAttached() and TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_USEONSCENE).." "..GetActionString(ACTIONS.PLANTSOIL.id) or ""
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_soil")
    inst.AnimState:SetBuild("quagmire_soil")
    inst.AnimState:PlayAnimation("rise")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("soil")

    inst.CanMouseThrough = CanMouseThrough
    inst.displaynamefn = DisplayNameFn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_soil").master_postinit(inst)

    return inst
end

return Prefab("quagmire_soil", fn, assets)
