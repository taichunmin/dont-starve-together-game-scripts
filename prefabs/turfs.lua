local GroundTiles = require("worldtiledefs")

local prefabs =
{
    "gridplacer",
}

local function make_turf(tile, data)
    local function ondeploy(inst, pt, deployer)
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
        end

        local map = TheWorld.Map
        local original_tile_type = map:GetTileAtPoint(pt:Get())
        local x, y = map:GetTileCoordsAtPoint(pt:Get())
        if x ~= nil and y ~= nil then
            map:SetTile(x, y, tile)
            map:RebuildLayer(original_tile_type, x, y)
            map:RebuildLayer(tile, x, y)
        end

        local minimap = TheWorld.minimap.MiniMap
        minimap:RebuildLayer(original_tile_type, x, y)
        minimap:RebuildLayer(tile, x, y)

        inst.components.stackable:Get():Remove()
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.bank_build)
        inst.AnimState:SetBuild(data.bank_build)
        inst.AnimState:PlayAnimation(data.anim)

        inst:AddTag("groundtile")
        inst:AddTag("molebait")

        MakeInventoryFloatable(inst, "med", nil, 0.65)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("bait")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetUseGridPlacer(true)

        ---------------------
        return inst
    end

    local assets =
    {
        Asset("ANIM", "anim/"..data.bank_build..".zip"),
        Asset("INV_IMAGE", "turf_"..data.name)
    }
    return Prefab("turf_"..data.name, fn, assets, prefabs)
end

local ret = {}
for k, v in pairs(GroundTiles.turf) do
    table.insert(ret, make_turf(k, v))
end
return unpack(ret)
