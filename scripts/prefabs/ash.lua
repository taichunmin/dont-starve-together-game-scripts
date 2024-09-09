local assets =
{
    Asset("ANIM", "anim/ash.zip"),
}

-- NOTE:
-- You have to add a custom DESCRIBE for each item you
-- mark as nonpotatable
local function GetStatus(inst)
    return inst.components.named.name ~= nil
        and string.gsub("REMAINS_"..inst.components.named.name, " ", "_")
        or nil
end

local function OnPickup(inst)
    inst.components.disappears:StopDisappear()
end

local function OnStackSizeChange(inst, data)
    if data ~= nil and data.stacksize ~= nil and data.stacksize > 1 then
        inst.components.named:SetName(nil)
    end
end

local function OnDropped(inst)
    inst.components.disappears:PrepareDisappear()
end

local function OnHaunt(inst)
    inst.components.disappears:Disappear()
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ashes")
    inst.AnimState:SetBuild("ash")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")
    inst:AddTag("ashes")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    ---------------------

    inst:AddComponent("disappears")
    inst.components.disappears.sound = "dontstarve/common/dust_blowaway"
    inst.components.disappears.anim = "disappear"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("named")
    inst.components.named.nameformat = STRINGS.NAMES.ASH_REMAINS

    inst:AddComponent("bait")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.BURNT
    inst.components.edible.hungervalue = 20
    inst.components.edible.healthvalue = 20

    inst:AddComponent("tradable")

    inst:ListenForEvent("stacksizechange", OnStackSizeChange)

    inst:ListenForEvent("ondropped", OnDropped)
    inst.components.disappears:PrepareDisappear()

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown_on_successful_haunt = false
    inst.components.hauntable.usefx = false
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    return inst
end

return Prefab("ash", fn, assets)
