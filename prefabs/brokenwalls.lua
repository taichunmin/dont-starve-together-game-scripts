local prefabs =
{
    "collapse_small",
}

function MakeWallType(data)
    local assets =
    {
        Asset("ANIM", "anim/wall.zip"),
        Asset("ANIM", "anim/wall_"..data.name..".zip"),
    }

    local onhit = data.material ~= nil and function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_"..data.material)
    end or nil

    local function onhammered(inst, worker)
        if data.maxloots ~= nil and data.loot ~= nil then
            local num_loots = 1
            for i = 1, num_loots do
                inst.components.lootdropper:SpawnLootPrefab(data.loot)
            end
        end

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if data.material ~= nil then
            fx:SetMaterial(data.material)
        end

        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

        inst:AddTag("wall")

        for k,v in ipairs(data.tags) do
            inst:AddTag(v)
        end

        inst.AnimState:SetBank("wall")
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation("broken", false)

        MakeSnowCoveredPristine(inst)

        --Sneak these into pristine state for optimization
        inst:AddTag("_named")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        --Remove these tags so that they can be added properly when replicating components below
        inst:RemoveTag("_named")

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = "wall_"..data.name

        inst:AddComponent("lootdropper")

        inst:AddComponent("named")
        inst.components.named:SetName(STRINGS.NAMES["WALL_RUINS"])

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        MakeSnowCovered(inst)

        return inst
    end

    return Prefab("brokenwall_"..data.name, fn, assets, prefabs)
end

--6 rock, 8 wood, 4 straw
--NOTE: Stacksize is now set in the actual recipe for the item.
local walldata =
{
    { name = MATERIALS.STONE,       material = "stone", tags = { "stone" },         loot = "rocks",            maxloots = 2, maxhealth = TUNING.STONEWALL_HEALTH    },
    { name = MATERIALS.STONE.."_2", material = "stone", tags = { "stone" },         loot = "rocks",            maxloots = 2, maxhealth = TUNING.STONEWALL_HEALTH    },
    { name = MATERIALS.WOOD,     material = "wood",  tags = { "wood" },             loot = "log",              maxloots = 2, maxhealth = TUNING.WOODWALL_HEALTH     },
    { name = MATERIALS.HAY,      material = "straw", tags = { "grass" },            loot = "cutgrass",         maxloots = 2, maxhealth = TUNING.HAYWALL_HEALTH      },
    { name = "ruins",            material = "stone", tags = { "stone", "ruins" },                              maxloots = 2, maxhealth = TUNING.RUINSWALL_HEALTH    },
    { name = "ruins_2",          material = "stone", tags = { "stone", "ruins" },                              maxloots = 2, maxhealth = TUNING.RUINSWALL_HEALTH    },
    { name = MATERIALS.MOONROCK, material = "stone", tags = { "stone", "moonrock" },                           maxloots = 2, maxhealth = TUNING.MOONROCKWALL_HEALTH },
}

local wallprefabs = {}
for i, v in ipairs(walldata) do
    table.insert(wallprefabs, MakeWallType(v))
end
return unpack(wallprefabs)
