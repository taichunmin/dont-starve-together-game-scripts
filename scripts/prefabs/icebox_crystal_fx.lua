local assets =
{
    Asset("ANIM", "anim/ice_box.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/icebox_crystal.zip"),
    Asset("PKGREF", "anim/dynamic/icebox_crystal.dyn"),
}

local function OnKillTask(inst)
    inst.AnimState:PlayAnimation("pst")
    inst._killtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)
end

local function Kill(inst)
    if inst._killtask == nil then
		inst._killtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime(), OnKillTask)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icebox_crystal")
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

return Prefab("icebox_crystal_fx", fn, assets)
