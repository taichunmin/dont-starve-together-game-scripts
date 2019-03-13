local assets =
{
    Asset("ANIM", "anim/quagmire_seedpacket.zip"),
}

local function displaynamefn(inst)
    return STRINGS.NAMES[string.upper("quagmire_seedpacket_"..(inst._id:value() > 0 and tostring(inst._id:value()) or "mix"))]
end

local function MakeSeedPacket(id)
    local prefabs
    if id == nil then
        prefabs =
        {
            "ash",
            "quagmire_seedpacket_unwrap",
        }
    elseif id == "mix" then
        prefabs = { "quagmire_seedpacket" }
        for i = 1, QUAGMIRE_NUM_SEEDS_PREFABS do
            table.insert(prefabs, "quagmire_seeds_"..tostring(i))
        end
    else
        prefabs =
        {
            "quagmire_seedpacket",
            "quagmire_seeds_"..tostring(id)
        }
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_seedpacket")
        inst.AnimState:SetBuild("quagmire_seedpacket")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("bundle")

        --unwrappable (from unwrappable component) added to pristine state for optimization
        inst:AddTag("unwrappable")

        inst._id = net_tinybyte(inst.GUID, "quagmire_seedpacket._id", "iddirty")
        inst.displaynamefn = displaynamefn
        if id ~= nil then
            inst:SetPrefabName("quagmire_seedpacket")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_seedpackets").master_postinit(inst, id)

        return inst
    end

    return Prefab("quagmire_seedpacket"..(id ~= nil and ("_"..tostring(id)) or ""), fn, assets, prefabs)
end

local ret =
{
    MakeSeedPacket(),
    MakeSeedPacket("mix"),
}
for i = 1, QUAGMIRE_NUM_SEEDS_PREFABS do
    table.insert(ret, MakeSeedPacket(i))
end
return unpack(ret)
