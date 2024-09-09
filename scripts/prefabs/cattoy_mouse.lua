local assets =
{
    Asset("ANIM", "anim/cattoy_mouse.zip"),
}

local function panic_update(inst)
    local new_angle = (-1 * inst.Transform:GetRotation()) + GetRandomMinMax(-100, 100)
    inst.components.locomotor:RunInDirection(new_angle)
end

local function panic_cancel(inst)
    inst.components.locomotor:Stop()
    if inst.panic_task ~= nil then
        inst.panic_task:Cancel()
        inst.panic_task = nil
    end
end

local function on_cattoy_playedwith(inst, playing_cat, inst_is_airborne)
    panic_cancel(inst)

    inst.panic_task = inst:DoPeriodicTask(10*FRAMES, panic_update, 0)
    inst.end_panic_task = inst:DoTaskInTime(61*FRAMES, panic_cancel)

    inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/talk")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 0.5, 0.2)

    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBank("cattoy_mouse")
    inst.AnimState:SetBuild("cattoy_mouse")
    inst.AnimState:PlayAnimation("idle", true)

    inst.DynamicShadow:SetSize(1.0, 0.75)

    inst:AddTag("cattoy")
    inst:AddTag("kitcoonfollowtoy")
    inst:AddTag("donotautopick")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.runspeed = 7

    -------------------
    inst:AddComponent("inspectable")

    -------------------
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem:SetSinks(true)

    -------------------
    inst:AddComponent("cattoy")
    inst.components.cattoy:SetOnPlay(on_cattoy_playedwith)

    -------------------
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    -------------------
    MakeHauntable(inst)

    -------------------
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    -------------------
    inst:SetStateGraph("SGcattoy_mouse")

    return inst
end

return Prefab("cattoy_mouse", fn, assets)
