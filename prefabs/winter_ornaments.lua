
local BLINK_PERIOD = 1.2

local NUM_BASIC_ORNAMENT = 12
local NUM_FANCY_ORNAMENT = 8
local NUM_LIGHT_ORNAMENT = 8
local NUM_FESTIVALEVENTS_ORNAMENT = 5

--NOTE: update mushroom_light.lua when adding coloured light bulbs!

local ORNAMENT_GOLD_VALUE =
{
    ["basic"] = 1,
    ["fancy"] = 2,
    ["light"] = 3,
}

local LIGHT_DATA =
{
    { colour = Vector3(1, .1, .1) },
    { colour = Vector3(.1, 1, .1) },
    { colour = Vector3(.5, .5, 1) },
    { colour = Vector3(1, 1, 1) },
}

local FANCY_FLOATER_SCALES =
{
    0.65,
    0.75,
    0.60,
    0.60,
    0.75,
    0.75,
    0.70,
    0.70,
}

local PLAIN_FLOATER_SCALE = 0.65
local LIGHT_FLOATER_SCALE = 0.70

function GetAllWinterOrnamentPrefabs()
    local decor =
    {
        "winter_ornament_boss_antlion",
        "winter_ornament_boss_bearger",
        "winter_ornament_boss_beequeen",
        "winter_ornament_boss_deerclops",
        "winter_ornament_boss_dragonfly",
        "winter_ornament_boss_fuelweaver",
        "winter_ornament_boss_klaus",
        "winter_ornament_boss_krampus",
        "winter_ornament_boss_moose",
        "winter_ornament_boss_noeyeblue",
        "winter_ornament_boss_noeyered",
        "winter_ornament_boss_toadstool",
		"winter_ornament_boss_toadstool_misery",
        "winter_ornament_boss_minotaur",
		"winter_ornament_boss_crabking",
		"winter_ornament_boss_crabkingpearl",
		"winter_ornament_boss_hermithouse",
		"winter_ornament_boss_pearl",
        "winter_ornament_boss_celestialchampion1",
        "winter_ornament_boss_celestialchampion2",
        "winter_ornament_boss_celestialchampion3",
        "winter_ornament_boss_celestialchampion4",
        "winter_ornament_boss_eyeofterror1",
        "winter_ornament_boss_eyeofterror2",
        "winter_ornament_boss_wagstaff",    
    }
    for i = 1, NUM_BASIC_ORNAMENT do
        table.insert(decor, "winter_ornament_plain" .. tostring(i))
    end
    for i = 1, NUM_FANCY_ORNAMENT do
        table.insert(decor, "winter_ornament_fancy" .. tostring(i))
    end
    for i = 1, NUM_LIGHT_ORNAMENT do
        table.insert(decor, "winter_ornament_light" .. tostring(i))
    end
    for i = 1, NUM_FESTIVALEVENTS_ORNAMENT do
        table.insert(decor, "winter_ornament_festivalevents" .. tostring(i))
    end
    return decor
end

function GetRandomBasicWinterOrnament()
    return "winter_ornament_plain"..math.random(NUM_BASIC_ORNAMENT)
end

function GetRandomFancyWinterOrnament()
    return "winter_ornament_fancy"..math.random(NUM_FANCY_ORNAMENT)
end

function GetRandomLightWinterOrnament()
    return "winter_ornament_light"..math.random(NUM_LIGHT_ORNAMENT)
end

function GetRandomFestivalEventWinterOrnament()
	return "winter_ornament_festivalevents"..math.random(NUM_FESTIVALEVENTS_ORNAMENT)
end

local function updatelight(inst, data)
    if data ~= nil and data.name == "blink" then
        inst.ornamentlighton = not inst.ornamentlighton
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if owner ~= nil then
            owner:PushEvent("updatelight", inst)
        else
            inst.Light:Enable(inst.ornamentlighton)
            inst.AnimState:PlayAnimation(inst.winter_ornamentid .. (inst.ornamentlighton and "_on" or "_off"))
        end
        if not inst.components.timer:TimerExists("blink") then
            inst.components.timer:StartTimer("blink", BLINK_PERIOD)
        end
    end
end

local function ondropped(inst)
    inst.ornamentlighton = false
    updatelight(inst, { name = "blink" })
    inst.components.fueled:StartConsuming()
end

local function onpickup(inst, by)
    if by ~= nil and by:HasTag("winter_tree") then
        if not inst.components.timer:TimerExists("blink") then
            inst.ornamentlighton = false
            updatelight(inst, { name = "blink" })
        end
        inst.components.fueled:StartConsuming()
    else
        inst.ornamentlighton = false
        inst.Light:Enable(false)
        inst.components.timer:StopTimer("blink")
        if by ~= nil and by:HasTag("lamp") then
            inst.components.fueled:StartConsuming()
        else
            inst.components.fueled:StopConsuming()
        end
    end
end

local function onentitywake(inst)
    if inst.components.timer:IsPaused("blink") then
        inst.components.timer:ResumeTimer("blink")
    elseif inst.components.fueled.consuming then
        updatelight(inst, { name = "blink" })
    end
end

local function onentitysleep(inst)
    inst.components.timer:PauseTimer("blink")
end

local function ondepleted(inst)
    inst.ornamentlighton = false
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
        owner:PushEvent("updatelight", inst)
    end
    inst.Light:Enable(false)
    inst.AnimState:PlayAnimation(inst.winter_ornamentid.."_off")
    inst.components.timer:StopTimer("blink")
    inst.components.fueled:StopConsuming()
    inst.components.inventoryitem:SetOnDroppedFn(nil)
    inst.components.inventoryitem:SetOnPutInInventoryFn(nil)
    inst.OnEntitySleep = nil
    inst.OnEntityWake = nil
    inst.OnSave = nil
    if inst.components.fuel ~= nil then
        inst:RemoveComponent("fuel")
    end
end

local function onsave(inst, data)
    data.ornamentlighton = inst.ornamentlighton
end

local function onload(inst, data)
    if inst.components.fueled:IsEmpty() then
        ondepleted(inst)
    elseif data ~= nil then
        inst.ornamentlighton = data.ornamentlighton
    end
end

local function MakeOrnament(ornamentid, overridename, lightdata, build, float_scale)
	build = build or "winter_ornaments"

	local assets =
	{
		Asset("ANIM", "anim/"..build..".zip"),
	}

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst, 0.1)

        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)

        inst:AddTag("winter_ornament")
        inst:AddTag("molebait")
        inst:AddTag("cattoy")

        inst.winter_ornamentid = ornamentid
		inst.winter_ornament_build = build

        inst:SetPrefabNameOverride(overridename)

        if lightdata then
            inst.entity:AddLight()
            inst.Light:SetFalloff(0.7)
            inst.Light:SetIntensity(.5)
            inst.Light:SetRadius(0.5)
            inst.Light:SetColour(lightdata.colour.x, lightdata.colour.y, lightdata.colour.z)
            inst.Light:Enable(false)

            inst:AddTag("lightbattery")

            inst.AnimState:PlayAnimation(tostring(ornamentid).."_on")
            inst.scrapbook_anim = tostring(ornamentid).."_on"
        else
            inst.AnimState:PlayAnimation(tostring(ornamentid))
            inst.scrapbook_anim = tostring(ornamentid)
        end

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_specialinfo = "WINTERTREE_ORNAMENT"
        inst.scrapbook_build = build

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        if float_scale ~= nil then
            inst.components.floater:SetScale(float_scale)
        end

        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = ORNAMENT_GOLD_VALUE[string.sub(ornamentid, 1, 5)] or 1

        if lightdata then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = FUELTYPE.USAGE
            inst.components.fueled.no_sewing = true
            inst.components.fueled:InitializeFuelLevel(160 * TUNING.TOTAL_DAY_TIME)
            inst.components.fueled:SetDepletedFn(ondepleted)
            inst.components.fueled:StartConsuming()

            inst:AddComponent("timer")
            inst:ListenForEvent("timerdone", updatelight)

            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
            inst.components.fuel.fueltype = FUELTYPE.CAVE


            inst.components.inventoryitem:SetOnDroppedFn(ondropped)
            inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)

            inst.OnEntitySleep = onentitysleep
            inst.OnEntityWake = onentitywake
            inst.OnSave = onsave
            inst.OnLoad = onload

            inst.ornamentlighton = math.random() < .5
            inst.components.timer:StartTimer("blink", math.random() * BLINK_PERIOD)
        else
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        end

        ---------------------
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("winter_ornament_"..tostring(ornamentid), fn, assets)
end

local ornament =
{
  --MakeOrnament(ornamentid,              overridename, lightdata,        build,       float_scale)
    MakeOrnament("festivalevents1", "winter_ornamentforge", nil, "winter_ornaments2018", 0.95),
    MakeOrnament("festivalevents2", "winter_ornamentforge", nil, "winter_ornaments2018", 0.95),
    MakeOrnament("festivalevents3", "winter_ornamentforge", nil, "winter_ornaments2018", 1.00),
    MakeOrnament("festivalevents4", "winter_ornamentgorge", nil, "winter_ornaments2018", 0.80),
    MakeOrnament("festivalevents5", "winter_ornamentgorge", nil, "winter_ornaments2018", 0.80),

    MakeOrnament("boss_antlion", "winter_ornamentboss", nil, nil, 0.70),
    MakeOrnament("boss_bearger", "winter_ornamentboss", nil, nil, 0.75),
    MakeOrnament("boss_beequeen", "winter_ornamentboss"),
    MakeOrnament("boss_deerclops", "winter_ornamentboss"),
    MakeOrnament("boss_dragonfly", "winter_ornamentboss"),
    MakeOrnament("boss_fuelweaver", "winter_ornamentboss", nil, nil, 0.60),
    MakeOrnament("boss_klaus", "winter_ornamentboss", nil, nil, 0.90),
    MakeOrnament("boss_krampus", "winter_ornamentboss", nil, nil, 0.65),
    MakeOrnament("boss_moose", "winter_ornamentboss", nil, nil, 0.70),
    MakeOrnament("boss_noeyeblue", "winter_ornamentboss", nil, nil, 0.90),
    MakeOrnament("boss_noeyered", "winter_ornamentboss", nil, nil, 0.90),
    MakeOrnament("boss_toadstool", "winter_ornamentboss"),

    MakeOrnament("boss_malbatross", "winter_ornamentboss", nil, "winter_ornaments2019", 0.95),

    MakeOrnament("boss_crabking", "winter_ornamentboss", nil, "winter_ornaments2020", 0.9),
    MakeOrnament("boss_crabkingpearl", "winter_ornamentboss", nil, "winter_ornaments2020", 0.9),
    MakeOrnament("boss_minotaur", "winter_ornamentboss", nil, "winter_ornaments2020", 0.9),
    MakeOrnament("boss_toadstool_misery", "winter_ornamentboss", nil, "winter_ornaments2020"),

    MakeOrnament("boss_hermithouse", "winter_ornamentpearl", nil, "winter_ornaments2020", 0.8),
    MakeOrnament("boss_pearl", "winter_ornamentpearl", nil, "winter_ornaments2020", 0.6),

    MakeOrnament("boss_celestialchampion1", "winter_ornamentboss", nil, "winter_ornaments2021", 0.8),
    MakeOrnament("boss_celestialchampion2", "winter_ornamentboss", nil, "winter_ornaments2021", 0.6),
    MakeOrnament("boss_celestialchampion3", "winter_ornamentboss", nil, "winter_ornaments2021", 0.6),
    MakeOrnament("boss_celestialchampion4", "winter_ornamentboss", nil, "winter_ornaments2021", 0.6),
    MakeOrnament("boss_eyeofterror1", "winter_ornamentboss", nil, "winter_ornaments2021", 0.6),
    MakeOrnament("boss_eyeofterror2", "winter_ornamentboss", nil, "winter_ornaments2021", 0.6),
    MakeOrnament("boss_wagstaff", "winter_ornamentboss", nil, "winter_ornaments2021", 0.6),

    MakeOrnament("boss_daywalker",        "winter_ornamentboss", nil, "winter_ornaments2023", 0.8),
    MakeOrnament("shadowthralls",         "winter_ornamentboss", nil, "winter_ornaments2023", 0.8),
    MakeOrnament("boss_mutateddeerclops", "winter_ornamentboss", nil, "winter_ornaments2023", 0.8),
    MakeOrnament("boss_mutatedbearger",   "winter_ornamentboss", nil, "winter_ornaments2023", 0.8),
    MakeOrnament("boss_mutatedwarg",      "winter_ornamentboss", nil, "winter_ornaments2023", 1.3),
}

for i = 1, NUM_BASIC_ORNAMENT do
    table.insert(ornament, MakeOrnament("plain"..i, "winter_ornament", nil, nil, PLAIN_FLOATER_SCALE))
end
for i = 1, NUM_FANCY_ORNAMENT do
    table.insert(ornament, MakeOrnament("fancy"..i, "winter_ornament", nil, nil, FANCY_FLOATER_SCALES[i]))
end
for i = 1, NUM_LIGHT_ORNAMENT do
    table.insert(ornament, MakeOrnament("light"..i, "winter_ornamentlight", LIGHT_DATA[((i - 1) % 4) + 1], nil, LIGHT_FLOATER_SCALE))
end

return unpack(ornament)
