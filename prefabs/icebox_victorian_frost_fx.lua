local assets =
{
    Asset("ANIM", "anim/ice_box.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/icebox_victorian.zip"),
    Asset("PKGREF", "anim/dynamic/icebox_victorian.dyn"),
}

local function OnKillTask(inst)
    inst.AnimState:PlayAnimation("pst")
    inst._killtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)
end

local function Kill(inst)
    if inst._killtask == nil then
        local len = inst.AnimState:GetCurrentAnimationLength()
        inst._killtask = inst:DoTaskInTime(len - (inst.AnimState:GetCurrentAnimationTime() % len), OnKillTask)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icebox_victorian")
    inst.AnimState:SetBuild("ice_box")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("loop")

    inst.persists = false

    inst.Kill = Kill

    return inst
end

return Prefab("icebox_victorian_frost_fx", fn, assets)
