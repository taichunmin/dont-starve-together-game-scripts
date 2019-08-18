local assets =
{
    Asset("ANIM", "anim/construction_plans.zip"),
}

local function MakePlans(name, targets)
    local constr_name = name.."_constr"
    local prefabs =
    {
        constr_name,
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("construction_plans")
        inst.AnimState:SetBuild("construction_plans")
        inst.AnimState:PlayAnimation(constr_name)

        MakeInventoryFloatable(inst)

        for i, v in ipairs(targets) do
            --"XXXXX_plans" (from constructionplans component) added to pristine state for optimization
            inst:AddTag(v.."_plans")
        end

        inst.constructionname = name

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = "construction_plans"

        inst:AddComponent("inventoryitem")

        inst:AddComponent("constructionplans")
        for i, v in ipairs(targets) do
            inst.components.constructionplans:AddTargetPrefab(v, constr_name)
        end

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(constr_name.."_plans", fn, assets, prefabs)
end

return MakePlans("multiplayer_portal_moonrock", { "multiplayer_portal" })
