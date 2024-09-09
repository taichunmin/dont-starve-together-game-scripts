
local prefabs =
{
    "spoiled_food",
}

local function MakePreparedFood(data)
	local foodassets =
	{
		Asset("ANIM", "anim/cook_pot_food.zip"),
		Asset("INV_IMAGE", data.name),
	}

	if data.overridebuild then
        table.insert(foodassets, Asset("ANIM", "anim/"..data.overridebuild..".zip"))
	end

	local spicename = data.spice ~= nil and string.lower(data.spice) or nil
    if spicename ~= nil then
        table.insert(foodassets, Asset("ANIM", "anim/spices.zip"))
        table.insert(foodassets, Asset("ANIM", "anim/plate_food.zip"))
        table.insert(foodassets, Asset("INV_IMAGE", spicename.."_over"))
    end

    local foodprefabs = prefabs
    if data.prefabs ~= nil then
        foodprefabs = shallowcopy(prefabs)
        for i, v in ipairs(data.prefabs) do
            if not table.contains(foodprefabs, v) then
                table.insert(foodprefabs, v)
            end
        end
    end

    local function DisplayNameFn(inst)
        return subfmt(STRINGS.NAMES[data.spice.."_FOOD"], { food = STRINGS.NAMES[string.upper(data.basename)] })
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

		local food_symbol_build = nil
        if spicename ~= nil then
            inst.AnimState:SetBuild("plate_food")
            inst.AnimState:SetBank("plate_food")
            inst.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)

            inst:AddTag("spicedfood")

            inst.inv_image_bg = { image = (data.basename or data.name)..".tex" }
            inst.inv_image_bg.atlas = GetInventoryItemAtlas(inst.inv_image_bg.image)

			food_symbol_build = data.overridebuild or "cook_pot_food"
        else
			inst.AnimState:SetBuild(data.overridebuild or "cook_pot_food")
			inst.AnimState:SetBank("cook_pot_food")
        end

        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("swap_food", data.overridebuild or "cook_pot_food", data.basename or data.name)
        inst.scrapbook_overridedata = {"swap_food", data.overridebuild or "cook_pot_food", data.basename or data.name}

        if data.scrapbook and data.scrapbook.specialinfo then
            inst.scrapbook_specialinfo = data.scrapbook.specialinfo
        end

        inst:AddTag("preparedfood")

        if data.tags ~= nil then
            for i,v in pairs(data.tags) do
                inst:AddTag(v)
            end
        end

        if data.basename ~= nil then
            inst:SetPrefabNameOverride(data.basename)
            if data.spice ~= nil then
                inst.displaynamefn = DisplayNameFn
            end
        end

        if data.floater ~= nil then
            MakeInventoryFloatable(inst, data.floater[1], data.floater[2], data.floater[3])
        else
            MakeInventoryFloatable(inst)
        end

        if data.scrapbook_sanityvalue ~= nil then
            inst.scrapbook_sanityvalue = data.scrapbook_sanityvalue
        end

        if data.scrapbook_healthvalue ~= nil then
            inst.scrapbook_healthvalue = data.scrapbook_healthvalue
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

		inst.food_symbol_build = food_symbol_build or data.overridebuild
		inst.food_basename = data.basename

        inst:AddComponent("edible")
        inst.components.edible.healthvalue = data.health
        inst.components.edible.hungervalue = data.hunger
        inst.components.edible.foodtype = data.foodtype or FOODTYPE.GENERIC
        inst.components.edible.secondaryfoodtype = data.secondaryfoodtype or nil
        inst.components.edible.sanityvalue = data.sanity or 0
        inst.components.edible.temperaturedelta = data.temperature or 0
        inst.components.edible.temperatureduration = data.temperatureduration or 0
        inst.components.edible.nochill = data.nochill or nil
        inst.components.edible.spice = data.spice
        inst.components.edible:SetOnEatenFn(data.oneatenfn)

        inst:AddComponent("inspectable")
        inst.wet_prefix = data.wet_prefix

        inst:AddComponent("inventoryitem")
		if data.OnPutInInventory then
			inst:ListenForEvent("onputininventory", data.OnPutInInventory)
		end

        if spicename ~= nil then
            inst.components.inventoryitem:ChangeImageName(spicename.."_over")
        elseif data.basename ~= nil then
            inst.components.inventoryitem:ChangeImageName(data.basename)
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        if data.perishtime ~= nil and data.perishtime > 0 then
            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(data.perishtime)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"
        end

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndPerish(inst)
        ---------------------

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")

        ------------------------------------------------

        return inst
    end
    -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
    --print(string.format("%s %s", data.foodtype or FOODTYPE.GENERIC, data.name))
    return Prefab(data.name, fn, foodassets, foodprefabs)
end

local prefs = {}

for k, v in pairs(require("preparedfoods")) do
    table.insert(prefs, MakePreparedFood(v))
end

for k, v in pairs(require("preparedfoods_warly")) do
    table.insert(prefs, MakePreparedFood(v))
end

for k, v in pairs(require("spicedfoods")) do
    table.insert(prefs, MakePreparedFood(v))
end

return unpack(prefs)


-- NOTES(JBK): These are here to make this file findable.
--[[
FOODTYPE.GENERIC sweettea
FOODTYPE.GENERIC sweettea_spice_chili
FOODTYPE.GENERIC sweettea_spice_garlic
FOODTYPE.GENERIC sweettea_spice_salt
FOODTYPE.GENERIC sweettea_spice_sugar
FOODTYPE.GENERIC wetgoop
FOODTYPE.GENERIC wetgoop_spice_chili
FOODTYPE.GENERIC wetgoop_spice_garlic
FOODTYPE.GENERIC wetgoop_spice_salt
FOODTYPE.GENERIC wetgoop_spice_sugar
FOODTYPE.GOODIES frozenbananadaiquiri
FOODTYPE.GOODIES frozenbananadaiquiri_spice_chili
FOODTYPE.GOODIES frozenbananadaiquiri_spice_garlic
FOODTYPE.GOODIES frozenbananadaiquiri_spice_salt
FOODTYPE.GOODIES frozenbananadaiquiri_spice_sugar
FOODTYPE.GOODIES icecream
FOODTYPE.GOODIES icecream_spice_chili
FOODTYPE.GOODIES icecream_spice_garlic
FOODTYPE.GOODIES icecream_spice_salt
FOODTYPE.GOODIES icecream_spice_sugar
FOODTYPE.GOODIES jellybean
FOODTYPE.GOODIES jellybean_spice_chili
FOODTYPE.GOODIES jellybean_spice_garlic
FOODTYPE.GOODIES jellybean_spice_salt
FOODTYPE.GOODIES jellybean_spice_sugar
FOODTYPE.GOODIES shroomcake
FOODTYPE.GOODIES shroomcake_spice_chili
FOODTYPE.GOODIES shroomcake_spice_garlic
FOODTYPE.GOODIES shroomcake_spice_salt
FOODTYPE.GOODIES shroomcake_spice_sugar
FOODTYPE.GOODIES taffy
FOODTYPE.GOODIES taffy_spice_chili
FOODTYPE.GOODIES taffy_spice_garlic
FOODTYPE.GOODIES taffy_spice_salt
FOODTYPE.GOODIES taffy_spice_sugar
FOODTYPE.GOODIES voltgoatjelly
FOODTYPE.GOODIES voltgoatjelly_spice_chili
FOODTYPE.GOODIES voltgoatjelly_spice_garlic
FOODTYPE.GOODIES voltgoatjelly_spice_salt
FOODTYPE.GOODIES voltgoatjelly_spice_sugar
FOODTYPE.MEAT baconeggs
FOODTYPE.MEAT baconeggs_spice_chili
FOODTYPE.MEAT baconeggs_spice_garlic
FOODTYPE.MEAT baconeggs_spice_salt
FOODTYPE.MEAT baconeggs_spice_sugar
FOODTYPE.MEAT barnaclepita
FOODTYPE.MEAT barnaclepita_spice_chili
FOODTYPE.MEAT barnaclepita_spice_garlic
FOODTYPE.MEAT barnaclepita_spice_salt
FOODTYPE.MEAT barnaclepita_spice_sugar
FOODTYPE.MEAT barnaclestuffedfishhead
FOODTYPE.MEAT barnaclestuffedfishhead_spice_chili
FOODTYPE.MEAT barnaclestuffedfishhead_spice_garlic
FOODTYPE.MEAT barnaclestuffedfishhead_spice_salt
FOODTYPE.MEAT barnaclestuffedfishhead_spice_sugar
FOODTYPE.MEAT barnaclesushi
FOODTYPE.MEAT barnaclesushi_spice_chili
FOODTYPE.MEAT barnaclesushi_spice_garlic
FOODTYPE.MEAT barnaclesushi_spice_salt
FOODTYPE.MEAT barnaclesushi_spice_sugar
FOODTYPE.MEAT barnaclinguine
FOODTYPE.MEAT barnaclinguine_spice_chili
FOODTYPE.MEAT barnaclinguine_spice_garlic
FOODTYPE.MEAT barnaclinguine_spice_salt
FOODTYPE.MEAT barnaclinguine_spice_sugar
FOODTYPE.MEAT bonesoup
FOODTYPE.MEAT bonesoup_spice_chili
FOODTYPE.MEAT bonesoup_spice_garlic
FOODTYPE.MEAT bonesoup_spice_salt
FOODTYPE.MEAT bonesoup_spice_sugar
FOODTYPE.MEAT bonestew
FOODTYPE.MEAT bonestew_spice_chili
FOODTYPE.MEAT bonestew_spice_garlic
FOODTYPE.MEAT bonestew_spice_salt
FOODTYPE.MEAT bonestew_spice_sugar
FOODTYPE.MEAT bunnystew
FOODTYPE.MEAT bunnystew_spice_chili
FOODTYPE.MEAT bunnystew_spice_garlic
FOODTYPE.MEAT bunnystew_spice_salt
FOODTYPE.MEAT bunnystew_spice_sugar
FOODTYPE.MEAT californiaroll
FOODTYPE.MEAT californiaroll_spice_chili
FOODTYPE.MEAT californiaroll_spice_garlic
FOODTYPE.MEAT californiaroll_spice_salt
FOODTYPE.MEAT californiaroll_spice_sugar
FOODTYPE.MEAT ceviche
FOODTYPE.MEAT ceviche_spice_chili
FOODTYPE.MEAT ceviche_spice_garlic
FOODTYPE.MEAT ceviche_spice_salt
FOODTYPE.MEAT ceviche_spice_sugar
FOODTYPE.MEAT figkabab
FOODTYPE.MEAT figkabab_spice_chili
FOODTYPE.MEAT figkabab_spice_garlic
FOODTYPE.MEAT figkabab_spice_salt
FOODTYPE.MEAT figkabab_spice_sugar
FOODTYPE.MEAT fishsticks
FOODTYPE.MEAT fishsticks_spice_chili
FOODTYPE.MEAT fishsticks_spice_garlic
FOODTYPE.MEAT fishsticks_spice_salt
FOODTYPE.MEAT fishsticks_spice_sugar
FOODTYPE.MEAT fishtacos
FOODTYPE.MEAT fishtacos_spice_chili
FOODTYPE.MEAT fishtacos_spice_garlic
FOODTYPE.MEAT fishtacos_spice_salt
FOODTYPE.MEAT fishtacos_spice_sugar
FOODTYPE.MEAT frogfishbowl
FOODTYPE.MEAT frogfishbowl_spice_chili
FOODTYPE.MEAT frogfishbowl_spice_garlic
FOODTYPE.MEAT frogfishbowl_spice_salt
FOODTYPE.MEAT frogfishbowl_spice_sugar
FOODTYPE.MEAT frogglebunwich
FOODTYPE.MEAT frogglebunwich_spice_chili
FOODTYPE.MEAT frogglebunwich_spice_garlic
FOODTYPE.MEAT frogglebunwich_spice_salt
FOODTYPE.MEAT frogglebunwich_spice_sugar
FOODTYPE.MEAT frognewton
FOODTYPE.MEAT frognewton_spice_chili
FOODTYPE.MEAT frognewton_spice_garlic
FOODTYPE.MEAT frognewton_spice_salt
FOODTYPE.MEAT frognewton_spice_sugar
FOODTYPE.MEAT guacamole
FOODTYPE.MEAT guacamole_spice_chili
FOODTYPE.MEAT guacamole_spice_garlic
FOODTYPE.MEAT guacamole_spice_salt
FOODTYPE.MEAT guacamole_spice_sugar
FOODTYPE.MEAT honeyham
FOODTYPE.MEAT honeyham_spice_chili
FOODTYPE.MEAT honeyham_spice_garlic
FOODTYPE.MEAT honeyham_spice_salt
FOODTYPE.MEAT honeyham_spice_sugar
FOODTYPE.MEAT honeynuggets
FOODTYPE.MEAT honeynuggets_spice_chili
FOODTYPE.MEAT honeynuggets_spice_garlic
FOODTYPE.MEAT honeynuggets_spice_salt
FOODTYPE.MEAT honeynuggets_spice_sugar
FOODTYPE.MEAT hotchili
FOODTYPE.MEAT hotchili_spice_chili
FOODTYPE.MEAT hotchili_spice_garlic
FOODTYPE.MEAT hotchili_spice_salt
FOODTYPE.MEAT hotchili_spice_sugar
FOODTYPE.MEAT justeggs
FOODTYPE.MEAT justeggs_spice_chili
FOODTYPE.MEAT justeggs_spice_garlic
FOODTYPE.MEAT justeggs_spice_salt
FOODTYPE.MEAT justeggs_spice_sugar
FOODTYPE.MEAT kabobs
FOODTYPE.MEAT kabobs_spice_chili
FOODTYPE.MEAT kabobs_spice_garlic
FOODTYPE.MEAT kabobs_spice_salt
FOODTYPE.MEAT kabobs_spice_sugar
FOODTYPE.MEAT koalefig_trunk
FOODTYPE.MEAT koalefig_trunk_spice_chili
FOODTYPE.MEAT koalefig_trunk_spice_garlic
FOODTYPE.MEAT koalefig_trunk_spice_salt
FOODTYPE.MEAT koalefig_trunk_spice_sugar
FOODTYPE.MEAT leafloaf
FOODTYPE.MEAT leafloaf_spice_chili
FOODTYPE.MEAT leafloaf_spice_garlic
FOODTYPE.MEAT leafloaf_spice_salt
FOODTYPE.MEAT leafloaf_spice_sugar
FOODTYPE.MEAT leafymeatburger
FOODTYPE.MEAT leafymeatburger_spice_chili
FOODTYPE.MEAT leafymeatburger_spice_garlic
FOODTYPE.MEAT leafymeatburger_spice_salt
FOODTYPE.MEAT leafymeatburger_spice_sugar
FOODTYPE.MEAT leafymeatsouffle
FOODTYPE.MEAT leafymeatsouffle_spice_chili
FOODTYPE.MEAT leafymeatsouffle_spice_garlic
FOODTYPE.MEAT leafymeatsouffle_spice_salt
FOODTYPE.MEAT leafymeatsouffle_spice_sugar
FOODTYPE.MEAT lobsterbisque
FOODTYPE.MEAT lobsterbisque_spice_chili
FOODTYPE.MEAT lobsterbisque_spice_garlic
FOODTYPE.MEAT lobsterbisque_spice_salt
FOODTYPE.MEAT lobsterbisque_spice_sugar
FOODTYPE.MEAT lobsterdinner
FOODTYPE.MEAT lobsterdinner_spice_chili
FOODTYPE.MEAT lobsterdinner_spice_garlic
FOODTYPE.MEAT lobsterdinner_spice_salt
FOODTYPE.MEAT lobsterdinner_spice_sugar
FOODTYPE.MEAT meatballs
FOODTYPE.MEAT meatballs_spice_chili
FOODTYPE.MEAT meatballs_spice_garlic
FOODTYPE.MEAT meatballs_spice_salt
FOODTYPE.MEAT meatballs_spice_sugar
FOODTYPE.MEAT meatysalad
FOODTYPE.MEAT meatysalad_spice_chili
FOODTYPE.MEAT meatysalad_spice_garlic
FOODTYPE.MEAT meatysalad_spice_salt
FOODTYPE.MEAT meatysalad_spice_sugar
FOODTYPE.MEAT monsterlasagna
FOODTYPE.MEAT monsterlasagna_spice_chili
FOODTYPE.MEAT monsterlasagna_spice_garlic
FOODTYPE.MEAT monsterlasagna_spice_salt
FOODTYPE.MEAT monsterlasagna_spice_sugar
FOODTYPE.MEAT monstertartare
FOODTYPE.MEAT monstertartare_spice_chili
FOODTYPE.MEAT monstertartare_spice_garlic
FOODTYPE.MEAT monstertartare_spice_salt
FOODTYPE.MEAT monstertartare_spice_sugar
FOODTYPE.MEAT moqueca
FOODTYPE.MEAT moqueca_spice_chili
FOODTYPE.MEAT moqueca_spice_garlic
FOODTYPE.MEAT moqueca_spice_salt
FOODTYPE.MEAT moqueca_spice_sugar
FOODTYPE.MEAT pepperpopper
FOODTYPE.MEAT pepperpopper_spice_chili
FOODTYPE.MEAT pepperpopper_spice_garlic
FOODTYPE.MEAT pepperpopper_spice_salt
FOODTYPE.MEAT pepperpopper_spice_sugar
FOODTYPE.MEAT perogies
FOODTYPE.MEAT perogies_spice_chili
FOODTYPE.MEAT perogies_spice_garlic
FOODTYPE.MEAT perogies_spice_salt
FOODTYPE.MEAT perogies_spice_sugar
FOODTYPE.MEAT seafoodgumbo
FOODTYPE.MEAT seafoodgumbo_spice_chili
FOODTYPE.MEAT seafoodgumbo_spice_garlic
FOODTYPE.MEAT seafoodgumbo_spice_salt
FOODTYPE.MEAT seafoodgumbo_spice_sugar
FOODTYPE.MEAT surfnturf
FOODTYPE.MEAT surfnturf_spice_chili
FOODTYPE.MEAT surfnturf_spice_garlic
FOODTYPE.MEAT surfnturf_spice_salt
FOODTYPE.MEAT surfnturf_spice_sugar
FOODTYPE.MEAT talleggs
FOODTYPE.MEAT talleggs_spice_chili
FOODTYPE.MEAT talleggs_spice_garlic
FOODTYPE.MEAT talleggs_spice_salt
FOODTYPE.MEAT talleggs_spice_sugar
FOODTYPE.MEAT turkeydinner
FOODTYPE.MEAT turkeydinner_spice_chili
FOODTYPE.MEAT turkeydinner_spice_garlic
FOODTYPE.MEAT turkeydinner_spice_salt
FOODTYPE.MEAT turkeydinner_spice_sugar
FOODTYPE.MEAT unagi
FOODTYPE.MEAT unagi_spice_chili
FOODTYPE.MEAT unagi_spice_garlic
FOODTYPE.MEAT unagi_spice_salt
FOODTYPE.MEAT unagi_spice_sugar
FOODTYPE.MEAT veggieomlet
FOODTYPE.MEAT veggieomlet_spice_chili
FOODTYPE.MEAT veggieomlet_spice_garlic
FOODTYPE.MEAT veggieomlet_spice_salt
FOODTYPE.MEAT veggieomlet_spice_sugar
FOODTYPE.ROUGHAGE beefalofeed
FOODTYPE.ROUGHAGE beefalofeed_spice_chili
FOODTYPE.ROUGHAGE beefalofeed_spice_garlic
FOODTYPE.ROUGHAGE beefalofeed_spice_salt
FOODTYPE.ROUGHAGE beefalofeed_spice_sugar
FOODTYPE.ROUGHAGE beefalotreat
FOODTYPE.ROUGHAGE beefalotreat_spice_chili
FOODTYPE.ROUGHAGE beefalotreat_spice_garlic
FOODTYPE.ROUGHAGE beefalotreat_spice_salt
FOODTYPE.ROUGHAGE beefalotreat_spice_sugar
FOODTYPE.VEGGIE asparagussoup
FOODTYPE.VEGGIE asparagussoup_spice_chili
FOODTYPE.VEGGIE asparagussoup_spice_garlic
FOODTYPE.VEGGIE asparagussoup_spice_salt
FOODTYPE.VEGGIE asparagussoup_spice_sugar
FOODTYPE.VEGGIE bananajuice
FOODTYPE.VEGGIE bananajuice_spice_chili
FOODTYPE.VEGGIE bananajuice_spice_garlic
FOODTYPE.VEGGIE bananajuice_spice_salt
FOODTYPE.VEGGIE bananajuice_spice_sugar
FOODTYPE.VEGGIE bananapop
FOODTYPE.VEGGIE bananapop_spice_chili
FOODTYPE.VEGGIE bananapop_spice_garlic
FOODTYPE.VEGGIE bananapop_spice_salt
FOODTYPE.VEGGIE bananapop_spice_sugar
FOODTYPE.VEGGIE butterflymuffin
FOODTYPE.VEGGIE butterflymuffin_spice_chili
FOODTYPE.VEGGIE butterflymuffin_spice_garlic
FOODTYPE.VEGGIE butterflymuffin_spice_salt
FOODTYPE.VEGGIE butterflymuffin_spice_sugar
FOODTYPE.VEGGIE dragonchilisalad
FOODTYPE.VEGGIE dragonchilisalad_spice_chili
FOODTYPE.VEGGIE dragonchilisalad_spice_garlic
FOODTYPE.VEGGIE dragonchilisalad_spice_salt
FOODTYPE.VEGGIE dragonchilisalad_spice_sugar
FOODTYPE.VEGGIE dragonpie
FOODTYPE.VEGGIE dragonpie_spice_chili
FOODTYPE.VEGGIE dragonpie_spice_garlic
FOODTYPE.VEGGIE dragonpie_spice_salt
FOODTYPE.VEGGIE dragonpie_spice_sugar
FOODTYPE.VEGGIE figatoni
FOODTYPE.VEGGIE figatoni_spice_chili
FOODTYPE.VEGGIE figatoni_spice_garlic
FOODTYPE.VEGGIE figatoni_spice_salt
FOODTYPE.VEGGIE figatoni_spice_sugar
FOODTYPE.VEGGIE flowersalad
FOODTYPE.VEGGIE flowersalad_spice_chili
FOODTYPE.VEGGIE flowersalad_spice_garlic
FOODTYPE.VEGGIE flowersalad_spice_salt
FOODTYPE.VEGGIE flowersalad_spice_sugar
FOODTYPE.VEGGIE freshfruitcrepes
FOODTYPE.VEGGIE freshfruitcrepes_spice_chili
FOODTYPE.VEGGIE freshfruitcrepes_spice_garlic
FOODTYPE.VEGGIE freshfruitcrepes_spice_salt
FOODTYPE.VEGGIE freshfruitcrepes_spice_sugar
FOODTYPE.VEGGIE fruitmedley
FOODTYPE.VEGGIE fruitmedley_spice_chili
FOODTYPE.VEGGIE fruitmedley_spice_garlic
FOODTYPE.VEGGIE fruitmedley_spice_salt
FOODTYPE.VEGGIE fruitmedley_spice_sugar
FOODTYPE.VEGGIE gazpacho
FOODTYPE.VEGGIE gazpacho_spice_chili
FOODTYPE.VEGGIE gazpacho_spice_garlic
FOODTYPE.VEGGIE gazpacho_spice_salt
FOODTYPE.VEGGIE gazpacho_spice_sugar
FOODTYPE.VEGGIE glowberrymousse
FOODTYPE.VEGGIE glowberrymousse_spice_chili
FOODTYPE.VEGGIE glowberrymousse_spice_garlic
FOODTYPE.VEGGIE glowberrymousse_spice_salt
FOODTYPE.VEGGIE glowberrymousse_spice_sugar
FOODTYPE.VEGGIE jammypreserves
FOODTYPE.VEGGIE jammypreserves_spice_chili
FOODTYPE.VEGGIE jammypreserves_spice_garlic
FOODTYPE.VEGGIE jammypreserves_spice_salt
FOODTYPE.VEGGIE jammypreserves_spice_sugar
FOODTYPE.VEGGIE mandrakesoup
FOODTYPE.VEGGIE mandrakesoup_spice_chili
FOODTYPE.VEGGIE mandrakesoup_spice_garlic
FOODTYPE.VEGGIE mandrakesoup_spice_salt
FOODTYPE.VEGGIE mandrakesoup_spice_sugar
FOODTYPE.VEGGIE mashedpotatoes
FOODTYPE.VEGGIE mashedpotatoes_spice_chili
FOODTYPE.VEGGIE mashedpotatoes_spice_garlic
FOODTYPE.VEGGIE mashedpotatoes_spice_salt
FOODTYPE.VEGGIE mashedpotatoes_spice_sugar
FOODTYPE.VEGGIE nightmarepie
FOODTYPE.VEGGIE nightmarepie_spice_chili
FOODTYPE.VEGGIE nightmarepie_spice_garlic
FOODTYPE.VEGGIE nightmarepie_spice_salt
FOODTYPE.VEGGIE nightmarepie_spice_sugar
FOODTYPE.VEGGIE potatosouffle
FOODTYPE.VEGGIE potatosouffle_spice_chili
FOODTYPE.VEGGIE potatosouffle_spice_garlic
FOODTYPE.VEGGIE potatosouffle_spice_salt
FOODTYPE.VEGGIE potatosouffle_spice_sugar
FOODTYPE.VEGGIE potatotornado
FOODTYPE.VEGGIE potatotornado_spice_chili
FOODTYPE.VEGGIE potatotornado_spice_garlic
FOODTYPE.VEGGIE potatotornado_spice_salt
FOODTYPE.VEGGIE potatotornado_spice_sugar
FOODTYPE.VEGGIE powcake
FOODTYPE.VEGGIE powcake_spice_chili
FOODTYPE.VEGGIE powcake_spice_garlic
FOODTYPE.VEGGIE powcake_spice_salt
FOODTYPE.VEGGIE powcake_spice_sugar
FOODTYPE.VEGGIE pumpkincookie
FOODTYPE.VEGGIE pumpkincookie_spice_chili
FOODTYPE.VEGGIE pumpkincookie_spice_garlic
FOODTYPE.VEGGIE pumpkincookie_spice_salt
FOODTYPE.VEGGIE pumpkincookie_spice_sugar
FOODTYPE.VEGGIE ratatouille
FOODTYPE.VEGGIE ratatouille_spice_chili
FOODTYPE.VEGGIE ratatouille_spice_garlic
FOODTYPE.VEGGIE ratatouille_spice_salt
FOODTYPE.VEGGIE ratatouille_spice_sugar
FOODTYPE.VEGGIE salsa
FOODTYPE.VEGGIE salsa_spice_chili
FOODTYPE.VEGGIE salsa_spice_garlic
FOODTYPE.VEGGIE salsa_spice_salt
FOODTYPE.VEGGIE salsa_spice_sugar
FOODTYPE.VEGGIE stuffedeggplant
FOODTYPE.VEGGIE stuffedeggplant_spice_chili
FOODTYPE.VEGGIE stuffedeggplant_spice_garlic
FOODTYPE.VEGGIE stuffedeggplant_spice_salt
FOODTYPE.VEGGIE stuffedeggplant_spice_sugar
FOODTYPE.VEGGIE trailmix
FOODTYPE.VEGGIE trailmix_spice_chili
FOODTYPE.VEGGIE trailmix_spice_garlic
FOODTYPE.VEGGIE trailmix_spice_salt
FOODTYPE.VEGGIE trailmix_spice_sugar
FOODTYPE.VEGGIE vegstinger
FOODTYPE.VEGGIE vegstinger_spice_chili
FOODTYPE.VEGGIE vegstinger_spice_garlic
FOODTYPE.VEGGIE vegstinger_spice_salt
FOODTYPE.VEGGIE vegstinger_spice_sugar
FOODTYPE.VEGGIE waffles
FOODTYPE.VEGGIE waffles_spice_chili
FOODTYPE.VEGGIE waffles_spice_garlic
FOODTYPE.VEGGIE waffles_spice_salt
FOODTYPE.VEGGIE waffles_spice_sugar
FOODTYPE.VEGGIE watermelonicle
FOODTYPE.VEGGIE watermelonicle_spice_chili
FOODTYPE.VEGGIE watermelonicle_spice_garlic
FOODTYPE.VEGGIE watermelonicle_spice_salt
FOODTYPE.VEGGIE watermelonicle_spice_sugar
]]
