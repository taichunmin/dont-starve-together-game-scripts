local assets =
{
    Asset("ANIM", "anim/quagmire_key.zip"),
}

local function MakeKey(name, anim)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_key")
        inst.AnimState:SetBuild("quagmire_key")
        inst.AnimState:PlayAnimation(anim)

        inst:AddTag("irreplaceable")

        --klaussackkey (from klaussackkey component) added to pristine state for optimization
        inst:AddTag("klaussackkey")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_key").master_postinit(inst, anim)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeKey("quagmire_key", "safe_key"),
    MakeKey("quagmire_key_park", "park_key")
