local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS

local function GetFertilizerKey(inst)
    return inst.prefab
end

local function fertilizerresearchfn(inst)
    return inst:GetFertilizerKey()
end

local function makefertilizer(name, nutrients)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local prefabs =
    {
        "gridplacer_farmablesoil",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        MakeInventoryFloatable(inst, "small", 0.2, 0.95)
        MakeDeployableFertilizerPristine(inst)

        inst:AddTag("fertilizerresearchable")

        inst.GetFertilizerKey = GetFertilizerKey

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("fertilizerresearchable")
        inst.components.fertilizerresearchable:SetResearchFn(fertilizerresearchfn)

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.FERTILIZER_USES)
        inst.components.finiteuses:SetUses(TUNING.FERTILIZER_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fertilizer")
        inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
        inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
        inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
        inst.components.fertilizer:SetNutrients(nutrients[1], nutrients[2], nutrients[3])

        inst:AddComponent("smotherer")

        MakeDeployableFertilizer(inst)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return makefertilizer("fertilizer", FERTILIZER_DEFS.fertilizer.nutrients)