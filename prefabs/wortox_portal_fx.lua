local assets =
{
    Asset("ANIM", "anim/wortox_portal.zip"),
}

local function OnAnimOver(inst)
    inst:DoTaskInTime(2 * FRAMES, inst.Remove)
end

local function MakeFX(name, anim)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("wortox_portal")
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetFinalOffset(3)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", OnAnimOver)
        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeFX("wortox_portal_jumpin_fx", "wortox_portal_jumpin"),
    MakeFX("wortox_portal_jumpout_fx", "wortox_portal_jumpout")
