require "prefabutil"

local WAXED_PLANTS = require "prefabs/waxed_plant_common"

local function make_plantable(data)
    local bank = data.bank or data.name
    local assets =
    {
        Asset("ANIM", "anim/"..bank..".zip"),
        Asset("INV_IMAGE", "dug_"..data.name)
    }

    if data.build ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..data.build..".zip"))
    end

    local function ondeploy(inst, pt, deployer)
        local tree = SpawnPrefab(data.name)
        if tree ~= nil then
            tree.Transform:SetPosition(pt:Get())
            inst.components.stackable:Get():Remove()
            if tree.components.pickable ~= nil then
                tree.components.pickable:OnTransplant()
            end
            if deployer ~= nil and deployer.SoundEmitter ~= nil then
                --V2C: WHY?!! because many of the plantables don't
                --     have SoundEmitter, and we don't want to add
                --     one just for this sound!
                deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
            end

            if TheWorld.components.lunarthrall_plantspawner and tree:HasTag("lunarplant_target") then
                TheWorld.components.lunarthrall_plantspawner:setHerdsOnPlantable(tree)
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        --inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst:AddTag("deployedplant")

        inst.AnimState:SetBank(data.bank or data.name)
        inst.AnimState:SetBuild(data.build or data.name)
        inst.AnimState:PlayAnimation("dropped")
        inst.scrapbook_anim = "dropped"

        if data.floater ~= nil then
            MakeInventoryFloatable(inst, data.floater[1], data.floater[2], data.floater[3])
        else
            MakeInventoryFloatable(inst)
        end

        if data.name == "berrybush" or 
           data.name == "berrybush2" or 
           data.name == "berrybush_juicy" or
           data.name == "grass" or
           data.name == "monkeytail" or
           data.name == "bananabush" or
           data.name == "rock_avocado_bush" then
            inst.scrapbook_specialinfo = "PLANTABLE_FERTILIZE"
        end

        if data.name == "sapling" or
           data.name == "sapling_moon" or
           data.name == "marsh_bush" then
            inst.scrapbook_specialinfo = "PLANTABLE"
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = data.inspectoverride or ("dug_"..data.name)
        inst:AddComponent("inventoryitem")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

        MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
        MakeSmallPropagator(inst)

        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("deployable")
        --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        if data.mediumspacing then
            inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)
        end

		if data.halloweenmoonmutable_settings ~= nil then
			inst:AddComponent("halloweenmoonmutable")
			inst.components.halloweenmoonmutable:SetPrefabMutated(data.halloweenmoonmutable_settings.prefab)
		end

        ---------------------
        return inst
    end

    return Prefab("dug_"..data.name, fn, assets)
end

local plantables =
{
    {
        name = "berrybush",
        anim = "dead",
        floater = {"med", 0.2, 0.95},
    },
    {
        name = "berrybush2",
        anim = "dead",
        inspectoverride = "dug_berrybush",
        floater = {"large", 0.2, 0.65},
    },
    {
        name = "berrybush_juicy",
        anim = "dead",
        inspectoverride = "dug_berrybush",
        floater = {"large", 0.025, {0.65, 0.5, 0.65}},
    },
    {
        name = "sapling",
        mediumspacing = true,
        floater = {"large", 0.1, 0.55},
		halloweenmoonmutable_settings = {prefab = "dug_sapling_moon"},
    },
    {
        name = "sapling_moon",
        mediumspacing = true,
        inspectoverride = "dug_sapling",
        floater = {"large", 0.1, 0.55},
    },
    {
        name = "grass",
        build = "grass1",
        mediumspacing = true,
        floater = {"med", 0.1, 0.92},
    },
    {
        name = "marsh_bush",
        mediumspacing = true,
        floater = {"med", 0.1, 0.9},
    },
    {
        name = "rock_avocado_bush",
        inspectoverride = "rock_avocado_bush",
        bank = "rock_avocado",
        build = "rock_avocado_build",
        anim = "dead1",
        floater = {"med", nil, 0.95},
    },
    {
        name = "bananabush",
        anim = "dead",
        floater = {"med", 0.2, 0.95},
    },
    {
        name = "monkeytail",
        bank = "grass",
        build = "reeds_monkeytails",
        mediumspacing = true,
        floater = {"med", 0.1, 0.92},
    },

}

local prefabs = {}

for _, data in ipairs(plantables) do
    table.insert(prefabs, make_plantable(data))
    table.insert(prefabs, MakePlacer("dug_"..data.name.."_placer", data.bank or data.name, data.build or data.name, data.anim or "idle"))

    table.insert(prefabs, WAXED_PLANTS.CreateDugWaxedPlant(data))
end

return unpack(prefabs)
