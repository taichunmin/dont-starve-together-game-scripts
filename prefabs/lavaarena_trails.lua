local assets =
{
    Asset("ANIM", "anim/lavaarena_trails_basic.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local prefabs =
{
    "fossilizing_fx",
    "fossilized_break_fx",
    "lavaarena_creature_teleport_medium_fx",
}

local NUM_VARIATIONS = 2

local function MakeTrails(name, variation, customprefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst.DynamicShadow:SetSize(3.25, 1.75)
        inst.Transform:SetFourFaced()
        inst.Transform:SetScale(1.2, 1.2, 1.2)

        inst:SetPhysicsRadiusOverride(1.25)
        MakeCharacterPhysics(inst, 500, inst.physicsradiusoverride)

        inst.AnimState:SetBank("trails")
        inst.AnimState:SetBuild("lavaarena_trails_basic")
        inst.AnimState:PlayAnimation("idle_loop", true)

        if variation ~= nil then
            inst.AnimState:OverrideSymbol("armour", "lavaarena_trails_basic", "armour"..variation)
            inst.AnimState:OverrideSymbol("mouth", "lavaarena_trails_basic", "mouth"..variation)
        end

        if name ~= "trails" then
            inst:SetPrefabNameOverride("trails")
        end

        inst.AnimState:AddOverrideBuild("fossilized")

        inst:AddTag("LA_mob")
        inst:AddTag("monster")
        inst:AddTag("hostile")
        inst:AddTag("largecreature")

        --fossilizable (from fossilizable component) added to pristine state for optimization
        inst:AddTag("fossilizable")

        ------------------------------------------

        if TheWorld.components.lavaarenamobtracker ~= nil then
            TheWorld.components.lavaarenamobtracker:StartTracking(inst)
        end

        ------------------------------------------

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/lavaarena_trails").master_postinit(inst)

        return inst
    end

    return Prefab(name, fn, assets, customprefabs or prefabs)
end

--For searching: "trails", "trails1", "trails2"
local ret = {}
local prefs = {}
for i, v in ipairs(prefabs) do
    table.insert(prefs, v)
end
for i = 1, NUM_VARIATIONS do
    local v = tostring(i)
    local name = "trails"..v
    table.insert(prefs, name)
    table.insert(ret, MakeTrails(name, v))
end
table.insert(ret, MakeTrails("trails", nil, prefs))
prefs = nil
return unpack(ret)
