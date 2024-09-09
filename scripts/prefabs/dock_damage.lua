local assets =
{
    Asset("ANIM", "anim/dock_damage.zip"),
}

local function setdamagepercent(inst,damage)
    inst.damage = damage

    local idle_index = (damage < 0.33 and "1")
        or (damage < 0.66 and "2")
        or "3"
    inst.AnimState:PlayAnimation("idle"..idle_index)
end

local function OnRepaired(inst, doer, repair_item)
    local repairvalue = repair_item.components.repairer and repair_item.components.repairer.healthrepairvalue
    if repairvalue then
        if TheWorld.components.dockmanager then
            -- Repair the dock at our location if we are repaired.
            local x, y, z = inst.Transform:GetWorldPosition()
            TheWorld.components.dockmanager:DamageDockAtPoint(x, y, z, -repairvalue)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("dock_damage")
    inst.AnimState:SetBuild("dock_damage")
    inst.AnimState:PlayAnimation("idle1")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.WOOD
    inst.components.repairable.onrepaired = OnRepaired
    inst.components.repairable.healthrepairable = true
    inst.components.repairable.justrunonrepaired = true

    inst.setdamagepecent = setdamagepercent
    inst.damage = 0

    return inst
end

return Prefab("dock_damage", fn, assets)
