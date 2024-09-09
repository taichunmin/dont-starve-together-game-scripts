local thedoll_assets =
{
    Asset("ANIM", "anim/playbill.zip"),
    Asset("INV_IMAGE", "playbill"),
}

local thedoll_prefabs = {
    "marionette_appear_fx",
    "marionette_disappear_fx",
}

local function makeplay(name, _assets, prefabs)
	local assets = { Asset("SCRIPT", "scripts/play_"..name..".lua") }
	for _, v in ipairs(_assets) do
		table.insert(assets, v)
	end

    local play = require("play_"..name)

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("playbill")
        inst.AnimState:SetBuild("playbill")
        inst.AnimState:PlayAnimation("idle")

        MakeInventoryFloatable(inst, "med", 0.05, 0.68)

        if name == "the_doll" then
            inst.scrapbook_specialinfo = "PLAYBILL_THEDOLL"
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:ChangeImageName("playbill")

        inst:AddComponent("inspectable")
        inst:AddComponent("tradable")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

        inst:AddComponent("playbill")
        inst.components.playbill.costumes = play.costumes
        inst.components.playbill.scripts = play.scripts
        inst.components.playbill.starting_act = play.starting_act
        inst.components.playbill.current_act = play.starting_act

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        MakeHauntableLaunchAndIgnite(inst)

        return inst
    end

    return Prefab("playbill_"..name, fn, assets, prefabs)
end

return makeplay("the_doll", thedoll_assets, thedoll_prefabs)