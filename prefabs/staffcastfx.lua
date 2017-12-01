local assets =
{
    Asset("ANIM", "anim/staff.zip"),
}

local function SetUp(inst, colour)
    inst.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
end

local function MakeStaffFX(anim)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("staff_fx")
        inst.AnimState:SetBuild("staff")
        inst.AnimState:PlayAnimation(anim)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SetUp = SetUp

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return Prefab("staffcastfx", MakeStaffFX("staff"), assets),
    Prefab("staffcastfx_mount", MakeStaffFX("staff_mount"), assets)
