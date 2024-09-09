local assets =
{
    Asset("ANIM", "anim/quagmire_sap.zip"),
}

local prefabs =
{
    "quagmire_burnt_ingredients",
    "quagmire_syrup",
}

local function MakeSap(name, fresh)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBuild("quagmire_sap")
        inst.AnimState:SetBank("quagmire_sap")
        inst.AnimState:PlayAnimation(fresh and "idle" or "idle_spoiled")

        if fresh then
            inst:AddTag("quagmire_stewable")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_sap").master_postinit(inst, fresh)

        return inst
    end

    return Prefab(name, fn, assets, fresh and prefabs or nil)
end

return MakeSap("quagmire_sap", true),
    MakeSap("quagmire_sap_spoiled", false)
