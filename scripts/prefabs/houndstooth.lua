local assets =
{
    Asset("ANIM", "anim/hounds_tooth.zip"),
    Asset("ANIM", "anim/hounds_tooth_water.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("houndstooth")
    inst.AnimState:SetBuild("hounds_tooth")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("blowpipeammo")
    inst:AddTag("reloaditem_ammo") -- Action string.

    inst.pickupsound = "rock"

    MakeInventoryFloatable(inst, "small", nil, {0.6, 0.55, 0.6})
    inst.AnimState:AddOverrideBuild("hounds_tooth_water")

    --selfstacker (from selfstacker component) added to pristine state for optimization
    inst:AddTag("selfstacker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("reloaditem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("selfstacker")

    MakeHauntableLaunchAndSmash(inst)

    inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:PlayAnimation("float") end)
    inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:PlayAnimation("idle") end)

    return inst
end

return Prefab("houndstooth", fn, assets)