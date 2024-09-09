local function MakePlate(basedish, dishtype, assets)
    local assets =
    {
        Asset("ANIM", "anim/quagmire_generic_"..basedish..".zip"),
        Asset("ATLAS", "images/quagmire_food_common_inv_images.xml"),
        Asset("IMAGE", "images/quagmire_food_common_inv_images.tex"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_generic_"..basedish)
        inst.AnimState:SetBuild("quagmire_generic_"..basedish)
        inst.AnimState:OverrideSymbol("generic_"..basedish, "quagmire_generic_"..basedish, dishtype.."_"..basedish)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("quagmire_replater")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_plates").master_postinit(inst, basedish, dishtype)

        return inst
    end

    return Prefab("quagmire_"..basedish.."_"..dishtype, fn, assets)
end

return MakePlate("plate", "silver"),
    MakePlate("bowl", "silver")
