local assets =
{
    Asset("ANIM", "anim/kitcoon_nametag.zip"),
}

local prefabs =
{

}

require("writeables").AddLayout("kitcoon_nametag", 
{
    prompt = STRINGS.KITCOON_NAMING.MENU_PROMPT,
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),
	maxcharacters = TUNING.KITCOON_NAMING_MAX_LENGTH,

    cancelbtn = {
        text = STRINGS.KITCOON_NAMING.MENU_CANCEL,
        cb = nil,
        control = CONTROL_CANCEL
    },
    middlebtn = {
        text = STRINGS.KITCOON_NAMING.MENU_RANDOM,
        cb = function(inst, doer, widget)
            widget:OverrideText( STRINGS.KITCOON_NAMING.NAMES[math.random(#STRINGS.KITCOON_NAMING.NAMES)] )
        end,
        control = CONTROL_MENU_MISC_2
    },
    acceptbtn = {
        text = STRINGS.KITCOON_NAMING.MENU_ACCEPT,
        cb = nil,
        control = CONTROL_ACCEPT
    },
})

local function OnUseOnKitcoon(inst, target, doer)
	inst.naming_target = target

	if inst.components.writeable ~= nil then
	    inst.components.writeable:BeginWriting(doer)
	end

    if target.components.locomotor ~= nil then
        target.components.locomotor:StopMoving()
    end

	target.is_being_named = true

	if inst.onrmeove_naming_target == nil then	
		inst.onrmeove_naming_target = function(t)
			inst.components.writeable:EndWriting()
			inst.naming_target = nil
		end
	end
    inst:ListenForEvent("onremove", inst.onrmeove_naming_target, inst.naming_target)

	return true
end

local function OnNamedByWriteable(inst, new_name, writer)
    if new_name ~= nil and inst.naming_target ~= nil and inst.naming_target:IsValid() and inst.naming_target.components.named ~= nil then
        inst.naming_target.components.named:SetName(new_name, writer ~= nil and writer.userid or nil)
    end
end

local function OnWritingEnded(inst)
	if inst.naming_target ~= nil then
		inst.naming_target.is_being_named = nil
	end
    inst:RemoveEventCallback("onremove", inst.onrmeove_naming_target, inst.naming_target)
	inst.naming_target = nil

	inst.components.useabletargeteditem:StopUsingItem()
end

local function on_stop_use(inst)

end

local function IsKitcoon(inst, target, doer)
	return target:HasTag("kitcoon")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kitcoon_nametag")
    inst.AnimState:SetBuild("kitcoon_nametag")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

	inst.UseableTargetedItem_ValidTarget = IsKitcoon		-- Note: Runs on client

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("writeable")
	inst.components.writeable:SetDefaultWriteable(false)
	inst.components.writeable:SetAutomaticDescriptionEnabled(false)
	inst.components.writeable:SetWriteableDistance(TUNING.KITCOON_NAMING_DIST)
	inst.components.writeable:SetOnWrittenFn(OnNamedByWriteable)
	inst.components.writeable:SetOnWritingEndedFn(OnWritingEnded)
	inst.components.writeable.remove_after_write = true

    inst:AddComponent("inventoryitem")

    inst:AddComponent("useabletargeteditem")
    inst.components.useabletargeteditem:SetOnUseFn(OnUseOnKitcoon)
    inst.components.useabletargeteditem:SetOnStopUseFn(on_stop_use)

    return inst
end

return Prefab("kitcoon_nametag", fn, assets)
