local assets =
{
    Asset("ANIM", "anim/halloween_ornaments.zip"),
}

local FLOATER_PROPERTIES =
{
    {"small",   0.1,    0.95},
    {"med",     0.1,    0.60},
    {"small",   0.1,    0.95},
    {"small",   0.1,    0.85},
    {"small",   0.1,    0.95},
    {"small",   0.1,    0.95},
}

local function MakeOrnament(ornamentid)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst, 0.1)

        inst.AnimState:SetBank("halloween_ornaments")
        inst.AnimState:SetBuild("halloween_ornaments")
        inst.AnimState:PlayAnimation("decor_"..ornamentid)
        inst.scrapbook_anim = "decor_"..ornamentid

		inst:AddTag("halloween_ornament")
        inst:AddTag("molebait")
        inst:AddTag("cattoy")

        local fp = FLOATER_PROPERTIES[ornamentid]
        MakeInventoryFloatable(inst, fp[1], fp[2], fp[3])

        inst.scrapbook_specialinfo = "HALLOWEEN_ORNAMENT"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

		inst.halloween_ornamentid = ornamentid

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        ---------------------
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("halloween_ornament_"..tostring(ornamentid), fn, assets)
end

local ornament = {}
for i = 1, NUM_HALLOWEEN_ORNAMENTS do
    table.insert(ornament, MakeOrnament(i))
end

return unpack(ornament)
