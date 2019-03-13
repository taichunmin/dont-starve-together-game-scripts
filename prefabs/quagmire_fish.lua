local function _fn(data, common_init_fn, master_init_fn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.build)
    inst.AnimState:SetBuild(data.build)

    inst:AddTag("meat")
    inst:AddTag("catfood")
    inst:AddTag("quagmire_stewable")

    if common_init_fn ~= nil then
        common_init_fn(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_fish").master_postinit(inst)

    if master_init_fn ~= nil then
        master_init_fn(inst)
    end

    return inst
end

local function raw_fn(data)
    local function common_init(inst)
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

        if data.fish then
            inst.AnimState:PlayAnimation("idle", true)
            inst.data = {} -- because fishing stuff
        else
            inst.AnimState:PlayAnimation("idle")
        end
    end

    local function master_init(inst)
        event_server_data("quagmire", "prefabs/quagmire_fish").master_postinit_raw(inst, data)
    end

    return function() return _fn(data, common_init, master_init) end
end

local function cooked_fn(data)
    local function common_init(inst)
        inst.AnimState:PlayAnimation("cooked")
    end

    local function master_init(inst)
        event_server_data("quagmire", "prefabs/quagmire_fish").master_postinit_cooked(inst, data)
    end

    return function() return _fn(data, common_init, master_init) end
end

local prefab_list = {}
local function MakeMeatItem(data)
    table.insert(prefab_list, Prefab(data.name, raw_fn(data), data.assets, data.prefabs))
    table.insert(prefab_list, Prefab(data.cooked, cooked_fn(data), data.assets, data.prefabs))
end

MakeMeatItem({
    name = "quagmire_salmon",
    cooked = "quagmire_salmon_cooked",
    build = "quagmire_salmon",
    fish = true,
    assets =
    {
        Asset("ANIM", "anim/quagmire_salmon.zip"),
    },
    prefabs =
    {
        "quagmire_salmon_cooked",
        "spoiled_food",
        "quagmire_burnt_ingredients",
    },
})

MakeMeatItem({
    name = "quagmire_crabmeat",
    cooked = "quagmire_crabmeat_cooked",
    build = "quagmire_crabmeat",
    assets =
    {
        Asset("ANIM", "anim/quagmire_crabmeat.zip"),
    },
    prefabs =
    {
        "quagmire_crabmeat_cooked",
        "spoiled_food",
        "quagmire_burnt_ingredients",
    },
})

return unpack(prefab_list)
