local function MakeArmour(name, data)
    local assets =
    {
        Asset("ANIM", "anim/"..data.build..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.build)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation("anim")

        for i, v in ipairs(data.tags) do
            inst:AddTag(v)
        end
        inst:AddTag("hide_percentage")

        inst.foleysound = data.foleysound

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/armor_lavaarena").master_postinit(inst, name, data.build)

        return inst
    end

    return Prefab(name, fn, assets)
end

local armors = {}
for k, v in pairs({
    ["lavaarena_armorlight"] =
    {
        build = "armor_light",
        tags = { "grass" },
        foleysound = "dontstarve/movement/foley/grassarmour",
    },

    ["lavaarena_armorlightspeed"] =
    {
        build = "armor_lightspeed",
        tags = { "grass" },
        foleysound = "dontstarve/movement/foley/grassarmour",
    },

    ["lavaarena_armormedium"] =
    {
        build = "armor_medium",
        tags = { "wood" },
        foleysound = "dontstarve/movement/foley/logarmour",
    },

    ["lavaarena_armormediumdamager"] =
    {
        build = "armor_mediumdamager",
        tags = { "wood" },
        foleysound = "dontstarve/movement/foley/logarmour",
    },

    ["lavaarena_armormediumrecharger"] =
    {
        build = "armor_mediumrecharger",
        tags = { "wood" },
        foleysound = "dontstarve/movement/foley/logarmour",
    },

    ["lavaarena_armorheavy"] =
    {
        build = "armor_heavy",
        tags = { "marble" },
        foleysound = "dontstarve/movement/foley/marblearmour",
    },

    ["lavaarena_armorextraheavy"] =
    {
        build = "armor_extraheavy",
        tags = { "marble", "heavyarmor" },
        foleysound = "dontstarve/movement/foley/marblearmour",
    },
}) do
    table.insert(armors, MakeArmour(k, v))
end

return unpack(armors)
