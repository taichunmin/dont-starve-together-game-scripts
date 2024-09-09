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
    if inst:HasTag("soil") and not inst:HasTag("NOBLOCK") then
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst.AnimState:PlayAnimation("collapse")
        inst.AnimState:PushAnimation("collapse_idle", false)
		inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(2)
    end
end

local function CancelPlowing(inst)
	if inst._plow ~= nil then
		inst:RemoveEventCallback("onremove", inst._onremoveplow, inst._plow)
		inst:RemoveEventCallback("finishplowing", inst._onfinishplowing, inst._plow)
		inst._plow = nil
		inst._onremoveplow = nil
		inst._onfinishplowing = nil
	end
end

local function OnCollapse(inst)
	CancelPlowing(inst)
    if inst:HasTag("soil") then
        inst:RemoveTag("soil")
        inst.persists = false
        if inst:HasTag("NOBLOCK") then
            inst.AnimState:PlayAnimation("collapse_remove")
        else
            inst:AddTag("NOCLICK")
	        inst:AddTag("NOBLOCK")
            inst.AnimState:PlayAnimation("till_remove")
        end
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function SetPlowing(inst, plow)
	CancelPlowing(inst)
	inst._plow = plow
	inst._onremoveplow = function()
		OnCollapse(inst)
	end
	inst._onfinishplowing = function(plow)
		CancelPlowing(inst)
		if not inst:HasTag("NOBLOCK") then
			inst:RemoveTag("NOCLICK")
		end
	end
	inst:ListenForEvent("onremove", inst._onremoveplow, plow)
	inst:ListenForEvent("finishplowing", inst._onfinishplowing, plow)
	inst:AddTag("NOCLICK")
end

local function OnSave(inst, data)
	data.broken = inst:HasTag("NOBLOCK")
	if inst._plow ~= nil then
		data.plow = inst._plow.GUID
		return { inst._plow.GUID } --refs
	end
end

local function OnLoad(inst, data)--, ents)
    if data ~= nil and data.broken then
        OnBreak(inst)
        inst.AnimState:PlayAnimation("collapse_idle")
    else
        inst.AnimState:PlayAnimation("till_idle")
    end
end

local function OnLoadPostPass(inst, ents, data)
	if data ~= nil and data.plow ~= nil then
		local plow = ents[data.plow]
		if plow ~= nil then
			SetPlowing(inst, plow.entity)
		else
			OnCollapse(inst)
		end
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

	inst:SetDeploySmartRadius(0.5) --match visuals, seeds use CUSTOM spacing
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

	--Works with farm_plow
	--inst._plow = nil
	inst.SetPlowing = SetPlowing

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("farm_soil", fn, assets)
