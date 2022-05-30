local assets =
{
    Asset("ANIM", "anim/blueprint_tackle.zip"),
}

-- Note: The index is saved, always add to the end of the list! and never reorder!
local SKETCHES =
{
	{ item = "oceanfishingbobber_ball",				recipe = "oceanfishingbobber_ball" },
	{ item = "oceanfishingbobber_oval",				recipe = "oceanfishingbobber_oval" },
	{ item = "oceanfishingbobber_crow",				recipe = "oceanfishingbobber_crow" },
	{ item = "oceanfishingbobber_robin",			recipe = "oceanfishingbobber_robin" },
	{ item = "oceanfishingbobber_robin_winter",		recipe = "oceanfishingbobber_robin_winter" },
	{ item = "oceanfishingbobber_canary",			recipe = "oceanfishingbobber_canary" },
	{ item = "oceanfishingbobber_goose",			recipe = "oceanfishingbobber_goose" },
	{ item = "oceanfishingbobber_malbatross",		recipe = "oceanfishingbobber_malbatross" },
    { item = "oceanfishinglure_hermit_drowsy",      recipe = "oceanfishinglure_hermit_drowsy" },
    { item = "oceanfishinglure_hermit_rain",        recipe = "oceanfishinglure_hermit_rain" },
    { item = "oceanfishinglure_hermit_heavy",       recipe = "oceanfishinglure_hermit_heavy" },
    { item = "oceanfishinglure_hermit_snow",        recipe = "oceanfishinglure_hermit_snow" },
}

local function onload(inst, data)
    if data ~= nil and data.sketchid ~= nil then
        inst.sketchid = data.sketchid
        inst.components.named:SetName(subfmt(STRINGS.NAMES.TACKLESKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[inst.sketchid].recipe)] }))
	    inst.components.teacher:SetRecipe(SKETCHES[inst.sketchid].recipe)
        if SKETCHES[inst.sketchid].image ~= nil then
            inst.components.inventoryitem:ChangeImageName(SKETCHES[inst.sketchid].image)
        end
    end
end

local function onsave(inst, data)
    data.sketchid = inst.sketchid
end

local function GetRecipeName(inst)
    return SKETCHES[inst.sketchid].recipe
end

local function GetSpecificSketchPrefab(inst)
    return SKETCHES[inst.sketchid].item.."_tacklesketch"
end

local function OnTeach(inst, learner)
    learner:PushEvent("learnrecipe", { teacher = inst, recipe = inst.components.teacher.recipe })
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint_tackle")
    inst.AnimState:SetBuild("blueprint_tackle")
    inst.AnimState:PlayAnimation("idle")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")
    inst:AddTag("tacklesketch")

    inst:SetPrefabName("tacklesketch")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

	--inst:AddComponent("tacklesketch")
    inst:AddComponent("teacher")
    inst.components.teacher.onteach = OnTeach

    inst:AddComponent("named")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.sketchid = 1

    inst.GetRecipeName = GetRecipeName
    inst.GetSpecificSketchPrefab = GetSpecificSketchPrefab

    return inst
end

local function MakeSketchPrefab(sketchid)
    return function()
        local inst = fn()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sketchid = sketchid

        inst.components.named:SetName(subfmt(STRINGS.NAMES.TACKLESKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[sketchid].recipe)] }))
	    inst.components.teacher:SetRecipe(SKETCHES[sketchid].recipe)

        if SKETCHES[sketchid].image ~= nil then
            inst.components.inventoryitem:ChangeImageName(SKETCHES[sketchid].image)
        end

        return inst
    end
end

local ret = {}
table.insert(ret, Prefab("tacklesketch", fn, assets))
for i, v in ipairs(SKETCHES) do
    local temp_assets = assets
    if v.image ~= nil then
        temp_assets = { Asset("INV_IMAGE", v.image) }
        for _, asset in ipairs(assets) do
            table.insert(temp_assets, asset)
        end
    end
    table.insert(ret, Prefab(v.item.."_tacklesketch", MakeSketchPrefab(i), temp_assets))
end

return unpack(ret)
