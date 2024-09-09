local assets =
{
    Asset("ANIM", "anim/moonglass_bigwaterfall.zip"),
}

local function stalactite(num)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("moonglass_bigwaterfall")
        inst.AnimState:SetBuild("moonglass_bigwaterfall")
        inst.AnimState:PlayAnimation("stalactite"..tostring(num), true)

        inst:AddTag("NOBLOCK")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    return Prefab("moonglass_stalactite"..tostring(num), fn, assets)
end

return stalactite(1),
        stalactite(2),
        stalactite(3)
