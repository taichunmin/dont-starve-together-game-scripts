local assets =
{
    Asset("ANIM", "anim/farm_soil.zip"),
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

local function OnBreak(inst)
    if inst:HasTag("soil") and not inst:HasTag("NOCLICK") then
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst.AnimState:PlayAnimation("collapse")
        inst.AnimState:PushAnimation("collapse_idle", false)
		inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(2)
    end
end

local function OnCollapse(inst)
    if inst:HasTag("soil") then
        inst:RemoveTag("soil")
        inst.persists = false
        if inst:HasTag("NOCLICK") then
            inst.AnimState:PlayAnimation("collapse_remove")
        else
            inst:AddTag("NOCLICK")
	        inst:AddTag("NOBLOCK")
            inst.AnimState:PlayAnimation("till_remove")
        end
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function OnSave(inst, data)
    data.broken = inst:HasTag("NOCLICK")
end

local function OnLoad(inst, data)--, ents)
    if data ~= nil and data.broken then
        OnBreak(inst)
        inst.AnimState:PlayAnimation("collapse_idle")
    else
        inst.AnimState:PlayAnimation("till_idle")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("farm_soil")
    inst.AnimState:SetBuild("farm_soil")
    inst.AnimState:PlayAnimation("till_rise")

    inst:AddTag("soil")

	inst:SetPhysicsRadiusOverride(TUNING.FARM_PLANT_PHYSICS_RADIUS)

    inst.CanMouseThrough = CanMouseThrough
    inst.displaynamefn = DisplayNameFn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("till_idle", false)

    inst:ListenForEvent("breaksoil", OnBreak)
    inst:ListenForEvent("collapsesoil", OnCollapse)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("farm_soil", fn, assets)
