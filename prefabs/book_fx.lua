local assets =
{
    Asset("ANIM", "anim/book_fx.zip")
}

local function MakeBookFX(anim, tint)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.Transform:SetFourFaced()

        inst:AddTag("FX")

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("book_fx")
        inst.AnimState:SetBuild("book_fx")
        inst.AnimState:PlayAnimation(anim)
        --inst.AnimState:SetScale(1.5, 1, 1)
        inst.AnimState:SetFinalOffset(3)
        if tint ~= nil then
            inst.AnimState:SetMultColour(unpack(tint))
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return Prefab("book_fx", MakeBookFX("book_fx", { .4, .4, .4, .4 }), assets),
    Prefab("book_fx_mount", MakeBookFX("book_fx_mount", { .4, .4, .4, .4 }), assets),
    Prefab("waxwell_book_fx", MakeBookFX("book_fx", { 0, 0, 0, 1 }), assets)
