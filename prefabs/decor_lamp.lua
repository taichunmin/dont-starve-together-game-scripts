local assets =
{
    Asset("ANIM", "anim/decor_lamp.zip"),
}
local LAMP_LIGHT_COLOUR = Vector3(180 / 255, 195 / 255, 150 / 255)

local function lamp_turnoff(inst)
    if inst.Light then
        inst.Light:Enable(false)
    end
    inst.components.fueled:StopConsuming()
    inst.components.machine.ison = false
    inst.AnimState:PlayAnimation("off")
    inst.AnimState:PushAnimation("idle")
end

local function lamp_fuelupdate(inst)
    local fuelpercent = inst.components.fueled:GetPercent()
    if inst.Light then
        inst.Light:SetIntensity(Lerp(0.4, 0.6, fuelpercent))
        inst.Light:SetRadius(Lerp(2, 4, fuelpercent))
    end
end

local function lamp_turnon(inst)
    local fueled = inst.components.fueled
    if fueled:IsEmpty() or inst.components.inventoryitem:IsHeld() then return end

    fueled:StartConsuming()
    if inst.Light then
        inst.Light:Enable(true)
    end
    inst.components.machine.ison = true
    inst.AnimState:PlayAnimation("on")
end

local function lamp_ondropped(inst)
    -- Works because of the IsEmpty check in turnon
    lamp_turnoff(inst)
    lamp_turnon(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("decor_lamp")
    inst.AnimState:SetBuild("decor_lamp")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("furnituredecor") -- From "furnituredecor", for optimization

    inst.Light:SetIntensity(0.4)
    inst.Light:SetColour(LAMP_LIGHT_COLOUR.x, LAMP_LIGHT_COLOUR.y, LAMP_LIGHT_COLOUR.z)
    inst.Light:SetFalloff(0.8)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)

    MakeInventoryFloatable(inst, "small", 0.065, 0.85)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    local fueled = inst:AddComponent("fueled")
    fueled.fueltype = FUELTYPE.CAVE
    fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME)
    fueled:SetDepletedFn(lamp_turnoff)
    fueled:SetUpdateFn(lamp_fuelupdate)
    fueled:SetTakeFuelFn(lamp_turnon)
    fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    fueled.accepting = true

    --
    local furnituredecor = inst:AddComponent("furnituredecor")
    furnituredecor.onputonfurniture = lamp_ondropped

    --
    inst:AddComponent("inspectable")

    --
    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetOnDroppedFn(lamp_ondropped)
    inventoryitem:SetOnPutInInventoryFn(lamp_turnoff)

    --
    local machine = inst:AddComponent("machine")
    machine.turnonfn = lamp_turnon
    machine.turnofffn = lamp_turnoff
    machine.cooldowntime = 0

    --
    MakeHauntable(inst)

    --
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("decor_lamp", fn, assets)