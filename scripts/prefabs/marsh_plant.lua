local assets =
{
    Asset("ANIM", "anim/marsh_plant.zip"),
    Asset("ANIM", "anim/pond_plant_cave.zip"),
}

local function fn(bank, build)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle", true)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        MakeMediumBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableIgnite(inst)

        inst:AddComponent("inspectable")

        return inst
    end
end

return Prefab("marsh_plant", fn("marsh_plant", "marsh_plant"), assets),
    Prefab("pond_algae", fn("pond_rock", "pond_plant_cave"), assets)