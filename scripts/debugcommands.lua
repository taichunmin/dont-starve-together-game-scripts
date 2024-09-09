local scrapbookprefabs = require("scrapbook_prefabs")

function d_spawnlist(list, spacing, fn)
    local created = {}
	spacing = spacing or 2
	local num_wide = math.ceil(math.sqrt(#list))

	local pt = ConsoleWorldPosition()
	pt.x = pt.x - num_wide * 0.5 * spacing
	pt.z = pt.z - num_wide * 0.5 * spacing

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			if list[(y*num_wide + x + 1)] then
				local prefab = list[(y*num_wide + x + 1)]
				local count = 1
				local item_fn = nil
				if type(prefab) == "table" then
					count = prefab[2]
					item_fn = prefab[3]
					prefab = prefab[1]
				end
				local inst = SpawnPrefab(prefab)
				if inst ~= nil then
                    table.insert(created, inst)
					inst.Transform:SetPosition((pt + Vector3(x*spacing, 0, y*spacing)):Get())
					if count > 1 then
						if inst.components.stackable then
							inst.components.stackable:SetStackSize(count)
						end
					end
					if item_fn ~= nil then
						item_fn(inst)
					end
					if fn ~= nil then
						fn(inst)
					end
				end
			end
		end
	end
    return created
end

function d_playeritems()
	local items = {}
	for prefab, recipe in pairs(AllRecipes) do
		if recipe.builder_tag and recipe.placer == nil and prefab:find("_builder") == nil then
			items[recipe.builder_tag] = items[recipe.builder_tag] or {}
			table.insert(items[recipe.builder_tag], prefab)
		end
	end
	local items_sorted = {}
	for tag, prefabs in pairs(items) do
		table.insert(items_sorted, tag)
	end
	table.sort(items_sorted)
	local tospawn = {}
	for _, tag in ipairs(items_sorted) do
		table.sort(items[tag])
		for _, prefab in ipairs(items[tag]) do
			if Prefabs[prefab] ~= nil then
				table.insert(tospawn, prefab)
			end
		end
	end
	d_spawnlist(tospawn, 1.5)
end

function d_allmutators()
    c_give("mutator_warrior")
    c_give("mutator_dropper")
    c_give("mutator_hider")
    c_give("mutator_spitter")
    c_give("mutator_moon")
    c_give("mutator_water")
end

function d_allcircuits()
    local module_defs = require("wx78_moduledefs").module_definitions

    local pt = ConsoleWorldPosition()
    local spacing, num_wide = 2, math.ceil(math.sqrt(#module_defs))

    for y = 0, num_wide - 1 do
        for x = 0, num_wide - 1 do
            local def = module_defs[(y*num_wide) + x + 1]
            local circuit = SpawnPrefab("wx78module_"..def.name)
            if circuit ~= nil then
                local spacing_vec = Vector3(x * spacing, 0, y * spacing)
                circuit.Transform:SetPosition((pt + spacing_vec):Get())
            end
        end
    end
end

function d_allheavy()
	local heavy_objs = {
		"cavein_boulder",
		"sunkenchest",
		"sculpture_knighthead",
		"glassspike",
		"moon_altar_idol",
		"oceantreenut",
		"shell_cluster",
		"potato_oversized",
		"chesspiece_knight_stone",
		"chesspiece_knight_marble",
		"chesspiece_knight_moonglass",
		"potatosack"
	}

	local x,y,z = ConsoleWorldPosition():Get()
	local start_x = x
	for i,v in ipairs(heavy_objs) do
		local obj = SpawnPrefab(v)
		obj.Transform:SetPosition(x,y,z)

		x = x + 2.5
		if i == 6 then
			z = z + 2.5
			x = start_x
		end
	end
end

function d_spiders()
    local spiders = {
        "spider",
        "spider_warrior",
        "spider_dropper",
        "spider_hider",
        "spider_spitter",
        "spider_moon",
        "spider_healer",
    }

    for i,v in ipairs(spiders) do
        local spider = c_spawn(v)
        spider.components.follower:SetLeader(ThePlayer)
    end
    c_give("spider_water")
end

function d_particles()
    local emittingfx = {
        "cane_candy_fx",
        "cane_harlequin_fx",
        "cane_victorian_fx",
        "eyeflame",
        "lighterfire_haunteddoll",
        "lighterfire",
        "lunar_goop_cloud_fx",
        "thurible_smoke",
        "torchfire",
        "torchfire_barber",
        "torchfire_carrat",
        "torchfire_nautical",
        "torchfire_pillar",
        "torchfire_pronged",
        "torchfire_rag",
        "torchfire_shadow",
        "torchfire_spooky",
        "torchfire_yotrpillowfight",
        -- Particles below need special handling to function.
        --"frostbreath",
        --"lunarrift_crystal_spawn_fx",
        --"nightsword_curve_fx",
        --"nightsword_lightsbane_fx",
        --"nightsword_sharp_fx",
        --"nightsword_wizard_fx",
        --"reviver_cupid_beat_fx",
        --"reviver_cupid_glow_fx",
    }
    local overridespeed = { -- Some particles want speed to emit.
        cane_harlequin_fx = PI2 * FRAMES,
        cane_victorian_fx = PI2 * FRAMES,
    }
    local created = d_spawnlist(emittingfx, 6)
    local r = 1.5
    for _, v in ipairs(created) do
        v._d_pos = v:GetPosition()
        v._d_theta = 0
        v.persists = false

        local labeler = c_spawn("razor")
        labeler.Transform:SetPosition(v._d_pos:Get())
        labeler.persists = false
        labeler.AnimState:SetScale(0, 0)

        local label = labeler.entity:AddLabel()
        label:SetFontSize(12)
        label:SetFont(BODYTEXTFONT)
        label:SetWorldOffset(0, 0, 0)
        label:SetText(v.prefab)
        label:SetColour(1, 1, 1)
        label:Enable(true)

        v:DoPeriodicTask(FRAMES, function()
            v._d_theta = v._d_theta + (overridespeed[v.prefab] or PI * 0.5 * FRAMES)
            v.Transform:SetPosition(v._d_pos.x + r * math.cos(v._d_theta), 0, v._d_pos.z + r * math.sin(v._d_theta))
        end)
    end
end

function d_decodedata(path)
    print("DECODING",path)
    TheSim:GetPersistentString(path, function(load_success, str)
        if load_success then
            print("LOADED...")
            TheSim:SetPersistentString(path.."_decoded", str, false, function()
                print("SAVED!")
            end)
        else
            print("ERROR LOADING FILE! (wrong path?)")
        end
    end)
end

function d_riftspawns()
    c_announce("Rift open, 10s for spawning..")
    if TheWorld:HasTag("cave") then
        TheWorld:PushEvent("shadowrift_opened")
    else
        TheWorld:PushEvent("lunarrift_opened")
    end
    TheWorld:DoTaskInTime(10, function()
        c_announce("Rifts Spawning..")
        for i = 1, 200 do
            TheWorld.components.riftspawner:SpawnRift()
        end
        TheWorld.components.riftspawner:DebugHighlightRifts()
    end)
end

function d_lunarrift()
    local riftspawner = TheWorld.components.riftspawner
    riftspawner:EnableLunarRifts()
    local pos = ConsoleWorldPosition()
    local x, y, z = TheWorld.Map:GetTileCenterPoint(pos:Get())
    pos.x, pos.y, pos.z = x, y, z
    riftspawner:SpawnRift(pos)
end

function d_shadowrift()
    local riftspawner = TheWorld.components.riftspawner
    riftspawner:EnableShadowRifts()
    local pos = ConsoleWorldPosition()
    local x, y, z = TheWorld.Map:GetTileCenterPoint(pos:Get())
    pos.x, pos.y, pos.z = x, y, z
    riftspawner:SpawnRift(pos)
end

function d_oceanarena()
    local sharkboimanager = TheWorld.components.sharkboimanager
    if sharkboimanager == nil then
        c_announce("Missing sharkboimanager component in TheWorld!")
        return
    end

    sharkboimanager.TEMP_DEBUG_RATE = true
    sharkboimanager:FindAndPlaceOceanArenaOverTime()
end

local TELEPORTBOAT_ITEM_MUST_TAGS = {"_inventoryitem",}
local TELEPORTBOAT_ITEM_CANT_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO",}
local TELEPORTBOAT_BLOCKER_CANT_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO", "_inventoryitem",}
function d_teleportboat(x, y, z)
    local player = ConsoleCommandPlayer()
    if not player then
        c_announce("Not playing as a character.")
        return
    end

    local boat = player:GetCurrentPlatform()
    if boat == nil or not boat:HasTag("boat") then
        c_announce("Not on a boat.")
        return
    end

    if x == nil then
        x, y, z = ConsoleWorldPosition():Get()--TheWorld.Map:GetTileCenterPoint(ConsoleWorldPosition():Get())
    end
    local boatradius = boat:GetSafePhysicsRadius()
    local blocked_ents = TheSim:FindEntities(x, y, z, boatradius + MAX_PHYSICS_RADIUS, nil, TELEPORTBOAT_BLOCKER_CANT_TAGS) -- NOTES(JBK): Add another MAX_PHYSICS_RADIUS for the other entity.
    if blocked_ents[1] then
        c_announce(string.format("Exit is blocked by %s", tostring(blocked_ents[1])))
        return
    end
    local item_ents = TheSim:FindEntities(x, y, z, boatradius, TELEPORTBOAT_ITEM_MUST_TAGS, TELEPORTBOAT_ITEM_CANT_TAGS)

    boat.Physics:Teleport(x, y, z)
    if boat.boat_item_collision then
        -- NOTES(JBK): This must also teleport or it will fling items off of it in a comical fashion from the physics constraint it has.
        boat.boat_item_collision.Physics:Teleport(x, y, z)
    end
    for _, ent in ipairs(item_ents) do
        ent.components.inventoryitem:SetLanded(false, true)
    end

    local walkableplatform = boat.components.walkableplatform
    if walkableplatform ~= nil then
        local players = walkableplatform:GetPlayersOnPlatform()
        for player_on_platform in pairs(players_on_platform) do
            player_on_platform:SnapCamera()
        end
    end
end

function d_resetskilltree()
    local player = ConsoleCommandPlayer()

    if not (player and TheWorld.ismastersim) then
        return
    end

    local skilltreeupdater = player.components.skilltreeupdater
    local skilldefs = require("prefabs/skilltree_defs").SKILLTREE_DEFS[player.prefab]
    if skilldefs ~= nil then
        for skill, data in pairs(skilldefs) do
            skilltreeupdater:DeactivateSkill(skill)
        end
    end

    skilltreeupdater:AddSkillXP(9999999)
end

function d_reloadskilltreedefs()
    require("prefabs/skilltree_defs").DEBUG_REBUILD()

    if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        ThePlayer.HUD:OpenPlayerInfoScreen()
    end
end

function d_printskilltreestringsforcharacter(character)
    character = character or ConsoleCommandPlayer().prefab
    local strings = STRINGS.SKILLTREE[string.upper(character)]

    local skilldefs = require("prefabs/skilltree_defs").SKILLTREE_DEFS[character]

    local str = ""

    for name, data in orderedPairs(skilldefs) do
        local uppercase_name = string.upper(name)
        
        if data.lock_open == nil and strings[uppercase_name.."_TITLE"] == nil then
            str = string.format('%s%s_TITLE = "%s",\n', str, uppercase_name, strings[uppercase_name.."_TITLE"] or "TODO")
        end

        if strings[uppercase_name.."_DESC"] == nil then
            str = string.format('%s%s_DESC = "%s",\n', str, uppercase_name, strings[uppercase_name.."_DESC"] or "TODO")
        end
    end

    print("\n\n"..str)
end

function d_togglelunarhail()
    local riftspawner = TheWorld.components.riftspawner

    if not riftspawner:GetLunarRiftsEnabled() then
        riftspawner:EnableLunarRifts()
    end

    if not riftspawner:IsLunarPortalActive() then
        riftspawner:OnRiftTimerDone()
    end

    TheWorld.net.components.weather:LongUpdate(TUNING.LUNARHAIL_EVENT_COOLDOWN)
end

function d_allsongs()
    c_give("battlesong_durability")
    c_give("battlesong_healthgain")
    c_give("battlesong_sanitygain")
    c_give("battlesong_sanityaura")
    c_give("battlesong_fireresistance")

    c_give("battlesong_instant_taunt")
    c_give("battlesong_instant_panic")
end

function d_allstscostumes()
    c_give("mask_dollhat")
    c_give("mask_dollbrokenhat")
    c_give("mask_dollrepairedhat")
    c_give("costume_doll_body")

    c_give("mask_blacksmithhat")
    c_give("costume_blacksmith_body")

    c_give("mask_mirrorhat")
    c_give("costume_mirror_body")

    c_give("mask_queenhat")
    c_give("costume_queen_body")

    c_give("mask_kinghat")
    c_give("costume_king_body")

    c_give("mask_treehat")
    c_give("costume_tree_body")

    c_give("mask_foolhat")
    c_give("costume_fool_body")
end

function d_domesticatedbeefalo(tendency, saddle)
    local beef = c_spawn('beefalo')
    beef.components.domesticatable:DeltaDomestication(1)
    beef.components.domesticatable:DeltaObedience(0.5)
    beef.components.domesticatable:DeltaTendency(TENDENCY[tendency] or TENDENCY.DEFAULT, 1)
    beef:SetTendency()
    beef.components.domesticatable:BecomeDomesticated()
    beef.components.rideable:SetSaddle(nil, SpawnPrefab(saddle or "saddle_basic"))
end

function d_domestication(domestication, obedience)
    if c_sel().components.domesticatable == nil then
        print("Selected ent not domesticatable")
    end
    if domestication ~= nil then
        c_sel().components.domesticatable:DeltaDomestication(domestication - c_sel().components.domesticatable:GetDomestication())
    end
    if obedience ~= nil then
        c_sel().components.domesticatable:DeltaObedience(obedience - c_sel().components.domesticatable:GetObedience())
    end
end

function d_testwalls()
    local walls = {
        "stone",
        "wood",
        "hay",
        "ruins",
        "moonrock",
    }
    local sx,sy,sz = ConsoleCommandPlayer().Transform:GetWorldPosition()
    for i,mat in ipairs(walls) do
        for j = 0,4 do
            local wall = SpawnPrefab("wall_"..mat)
            wall.Transform:SetPosition(sx + (i*6), sy, sz + j)
            wall.components.health:SetPercent(j*0.25)
        end
        for j = 5,15 do
            local wall = SpawnPrefab("wall_"..mat)
            wall.Transform:SetPosition(sx + (i*6), sy, sz + j)
            wall.components.health:SetPercent(j <= 11 and 1 or 0.5)
        end
    end
end


function d_testruins()
    ConsoleCommandPlayer().components.builder:UnlockRecipesForTech({SCIENCE = 2, MAGIC = 2})
    c_give("log", 20)
    c_give("flint", 20)
    c_give("twigs", 20)
    c_give("cutgrass", 20)
    c_give("lightbulb", 5)
    c_give("healingsalve", 5)
    c_give("batbat")
    c_give("icestaff")
    c_give("firestaff")
    c_give("tentaclespike")
    c_give("slurtlehat")
    c_give("armorwood")
    c_give("minerhat")
    c_give("lantern")
    c_give("backpack")
end

function d_combatgear()
    c_give("armorwood")
    c_give("footballhat")
    c_give("spear")
end

function d_teststate(state)
    c_sel().sg:GoToState(state)
end

function d_anim(animname, loop)
    if GetDebugEntity() then
        GetDebugEntity().AnimState:PlayAnimation(animname, loop or false)
    else
        print("No DebugEntity selected")
    end
end

function d_light(c1, c2, c3)
    TheSim:SetAmbientColour(c1, c2 or c1, c3 or c1)
end

local COMBAT_TAGS = {"_combat"}
function d_combatsimulator(prefab, count, force)
    count = count or 1

    local x,y,z = ConsoleWorldPosition():Get()
    local MakeBattle = nil
    MakeBattle = function()
        local creature = DebugSpawn(prefab)
        creature:ListenForEvent("onremove", MakeBattle)
        creature.Transform:SetPosition(x,y,z)
        if creature.components.knownlocations then
            creature.components.knownlocations:RememberLocation("home", {x=x,y=y,z=z})
        end
        if force then
            local target = FindEntity(creature, 20, nil, COMBAT_TAGS)
            if target then
                creature.components.combat:SetTarget(target)
            end
            creature:ListenForEvent("droppedtarget", function()
                local target = FindEntity(creature, 20, nil, COMBAT_TAGS)
                if target then
                    creature.components.combat:SetTarget(target)
                end
            end)
        end
    end

    for i=1,count do
        MakeBattle()
    end
end

function d_spawn_ds(prefab, scenario)
    local inst = c_spawn(prefab)
    if not inst then
        print("Need to select an entity to apply the scenario to.")
        return
    end

    if inst.components.scenariorunner then
        inst.components.scenariorunner:ClearScenario()
    end

    -- force reload the script -- this is for testing after all!
    package.loaded["scenarios/"..scenario] = nil

    inst:AddComponent("scenariorunner")
    inst.components.scenariorunner:SetScript(scenario)
    inst.components.scenariorunner:Run()
end



---------------------------------------------------
------------ skins functions --------------------
---------------------------------------------------

--For testing legacy skin DLC popup
--AddNewSkinDLCEntitlement("pack_oni_gift") MakeSkinDLCPopup()

local TEST_ITEM_NAME = "birdcage_pirate"
function d_test_thank_you(param)
	local ThankYouPopup = require "screens/thankyoupopup"
	local SkinGifts = require("skin_gifts")
	TheFrontEnd:PushScreen(ThankYouPopup({{ item = param or TEST_ITEM_NAME, item_id = 0, gifttype = SkinGifts.types[param or TEST_ITEM_NAME] or "DEFAULT" }}))
end
function d_test_skins_popup(param)
	local SkinsItemPopUp = require "screens/skinsitempopup"
	TheFrontEnd:PushScreen( SkinsItemPopUp(param or TEST_ITEM_NAME, "Peter", {1.0, 0.2, 0.6, 1.0}) )
end
function d_test_skins_announce(param)
	Networking_SkinAnnouncement("Peter", {1.0, 0.2, 0.6, 1.0}, param or TEST_ITEM_NAME)
end
function d_test_skins_gift(param)
	local GiftItemPopUp = require "screens/giftitempopup"
	TheFrontEnd:PushScreen( GiftItemPopUp(ThePlayer, { param or TEST_ITEM_NAME }, { 0 }) )
end

function d_print_skin_info()

	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    local a = {
        "campfire_cabin",
        "armor_wood_roman",
        "spear_northern",
        "pickaxe_northern"
    }

    for _,v in pairs(a) do
        print( GetSkinName(v), GetSkinUsableOnString(v) )
	end

    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end

function d_skin_mode(mode)
    ConsoleCommandPlayer().components.skinner:SetSkinMode(mode)
end

function d_skin_name(name)
    ConsoleCommandPlayer().components.skinner:SetSkinName(name)
end

function d_clothing(name)
    ConsoleCommandPlayer().components.skinner:SetClothing(name)
end
function d_clothing_clear(type)
    ConsoleCommandPlayer().components.skinner:ClearClothing(type)
end

function d_cycle_clothing()
    local skinslist = TheInventory:GetFullInventory()

    local idx = 1
    local task = nil

    ConsoleCommandPlayer().cycle_clothing_task = ConsoleCommandPlayer():DoPeriodicTask(10,
        function()
            local type, name = GetTypeForItem(skinslist[idx].item_type)
            --print("showing clothing idx ", idx, name, type, #skinslist)
            if (type ~= "base" and type ~= "item") then
                c_clothing(name)
            end

            if idx < #skinslist then
                idx = idx + 1
            else
                print("Ending cycle")
                ConsoleCommandPlayer().cycle_clothing_task:Cancel()
            end
        end)

end

function d_sinkhole()
	c_spawn("antlion_sinkhole"):PushEvent("startcollapse")
end

function d_stalkersetup()
	local mound = c_spawn("fossil_stalker")
	--mound.components.workable:SetWorkLeft(mound.components.workable.maxwork - 1)
	for i = 1, (mound.components.workable.maxwork - 1) do
		mound.form = 1
		mound.components.repairable.onrepaired(mound)
	end

	c_give "shadowheart"
	c_give "atrium_key"
end

function d_resetruins()
	TheWorld:PushEvent("resetruins")
end

-- Get the widget selected by the debug widget editor (WidgetDebug).
-- Try d_getwidget():ScaleTo(3,1,.7)
function d_getwidget()
    return TheFrontEnd.widget_editor.debug_widget_target
end

function d_halloween()
	local spacing = 2
	local num_wide = math.ceil(math.sqrt(NUM_TRINKETS))

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			local inst = SpawnPrefab("trinket_"..(y*num_wide + x + 1))
			if inst ~= nil then
				print(x*spacing,  y*spacing)
				inst.Transform:SetPosition((ConsoleWorldPosition() + Vector3(x*spacing, 0, y*spacing)):Get())
			end
		end
	end

	local candy_wide = math.ceil(math.sqrt(NUM_HALLOWEENCANDY))
	for y = 0, candy_wide-1 do
		for x = 0, candy_wide-1 do
			local inst = SpawnPrefab("halloweencandy_"..(y*candy_wide + x + 1))
			if inst ~= nil then
				print(x*spacing,  y*spacing)
				inst.Transform:SetPosition((ConsoleWorldPosition() + Vector3((x + num_wide)*spacing, 0, (y+num_wide)*spacing)):Get())
			end
		end
	end
end

function d_potions()
	local all_potions = {"halloweenpotion_bravery_small", "halloweenpotion_bravery_large", "halloweenpotion_health_small",  "halloweenpotion_health_large",
						 "halloweenpotion_sanity_small", "halloweenpotion_sanity_large", "halloweenpotion_embers",  "halloweenpotion_sparks",  "livingtree_root"}

	local spacing = 2
	local num_wide = math.ceil(math.sqrt(#all_potions))

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			local inst = SpawnPrefab(all_potions[(y*num_wide + x + 1)])
			if inst ~= nil then
				inst.Transform:SetPosition((ConsoleWorldPosition() + Vector3(x*spacing, 0, y*spacing)):Get())
			end
		end
	end
end

function d_weirdfloaters()
    local weird_float_items =
    {
        "abigail flower",   "axe",              "batbat",       "blowdart_fire",    "blowdart_pipe",    "blowdart_sleep",
        "blowdart_walrus",  "blowdart_yellow",  "boomerang",    "brush",            "bugnet",           "cane",
        "firestaff",        "fishingrod",       "glasscutter",  "goldenaxe",        "goldenpickaxe",
        "goldenshovel",     "grass_umbrella",   "greenstaff",   "hambat",           "hammer",           "houndstooth",
        "houndwhistle",     "icestaff",         "lucy",         "miniflare",        "moonglassaxe",     "multitool_axe_pickaxe",
        "nightstick",       "nightsword",       "opalstaff",    "orangestaff",      "panflute",         "perdfan",
        "pickaxe",          "pitchfork",        "razor",        "redlantern",       "shovel",           "spear",
        "spear_wathgrithr", "staff_tornado",    "telestaff",    "tentaclespike",    "trap",             "umbrella",
        "yellowstaff",      "yotp_food3",
    }

    local spacing = 2
    local num_wide = math.ceil(math.sqrt(#weird_float_items))

    for y = 0, num_wide - 1 do
        for x = 0, num_wide - 1 do
            local inst = SpawnPrefab(weird_float_items[y*num_wide + x + 1])
            if inst ~= nil then
                inst.Transform:SetPosition((ConsoleWorldPosition() + Vector3(x*spacing, 0, y*spacing)):Get())
            end
        end
    end
end

function d_wintersfeast()
	local all_items = GetAllWinterOrnamentPrefabs()
	local spacing = 2
	local num_wide = math.ceil(math.sqrt(#all_items))

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			local inst = SpawnPrefab(all_items[(y*num_wide + x + 1)])
			if inst ~= nil then
				inst.Transform:SetPosition((ConsoleWorldPosition() + Vector3(x*spacing, 0, y*spacing)):Get())
			end
		end
	end
end

function d_wintersfood()
    local spacing = 2
    local num_wide = math.ceil(math.sqrt(NUM_WINTERFOOD))

    for y = 0, num_wide-1 do
        for x = 0, num_wide-1 do
            local inst = SpawnPrefab("winter_food"..(y*num_wide + x + 1))
            if inst ~= nil then
                inst.Transform:SetPosition((ConsoleWorldPosition() + Vector3(x*spacing, 0, y*spacing)):Get())
            end
        end
    end
end

function d_madsciencemats()
	c_mat("halloween_experiment_bravery")
	c_mat("halloween_experiment_health")
	c_mat("halloween_experiment_hunger")
	c_mat("halloween_experiment_sanity")
	c_mat("halloween_experiment_volatile")
	c_mat("halloween_experiment_root")
end

function d_showalleventservers()
	TheFrontEnd._showalleventservers = not TheFrontEnd._showalleventservers
end

function d_lavaarena_skip()
	TheWorld:PushEvent("ms_lavaarena_endofstage", {reason="debug triggered"})
end

function d_lavaarena_speech(dialog, banter_line)
	local is_banter = string.find(string.upper(dialog), "BANTER", 1) ~= nil
	dialog = STRINGS[string.upper(dialog)]
	if dialog ~= nil then
		if is_banter then
			dialog = { dialog[banter_line or math.random(#dialog)] }
		end

		local lines = {}
		for i,v in ipairs(dialog) do
			table.insert(lines, {message=v, duration=3.5, noanim=true})
		end

		local target = TheWorld.components.lavaarenaevent:GetBoarlord()
		if target then
			target:PushEvent("lavaarena_talk", {text=lines})
		end
	end
end

function d_unlockallachievements()
	local achievements = {}
	for k, _ in pairs(EventAchievements:GetActiveAchievementsIdList()) do
		table.insert(achievements, k)
	end

	TheItems:ReportEventProgress(json.encode_compliant(
		{
			WorldID = "dev_"..tostring(math.random(9999999))..tostring(math.random(9999999)),
			Teams =
			{
				{
					Won=true,
					Points=5,
					PlayerStats=
					{
						{KU = TheNet:GetUserID(), PlaytimeMs = 100000, Custom = { UnlockAchievements = achievements }},
					}
				},
			}
		}), function(ku_tbl, success) print( "Report event:", success) dumptable(ku_tbl) end )

end

function d_unlockfoodachievements()
	local achievements = {
    	"food_001", "food_002", "food_003", "food_004", "food_005", "food_006", "food_007", "food_008", "food_009",
	    "food_010", "food_011", "food_012", "food_013", "food_014", "food_015", "food_016", "food_017", "food_018", "food_019",
	    "food_020", "food_021", "food_022", "food_023", "food_024", "food_025", "food_026", "food_027", "food_028", "food_029",
	    "food_030", "food_031", "food_032", "food_033", "food_034", "food_035", "food_036", "food_037", "food_038", "food_039",
	    "food_040", "food_041", "food_042", "food_043", "food_044", "food_045", "food_046", "food_047", "food_048", "food_049",
	    "food_050", "food_051", "food_052", "food_053", "food_054", "food_055", "food_056", "food_057", "food_058", "food_059",
		"food_060",	"food_061", "food_062", "food_063", "food_064", "food_065", "food_066", "food_067", "food_068", "food_069",
	    "food_syrup",
    }

	TheItems:ReportEventProgress(json.encode_compliant(
		{
			WorldID = "dev_"..tostring(math.random(9999999))..tostring(math.random(9999999)),
			Teams =
			{
				{
					Won=true,
					Points=5,
					PlayerStats=
					{
						{KU = TheNet:GetUserID(), PlaytimeMs = 1000, Custom = { UnlockAchievements = achievements }},
					}
				},
			}
		}), function(ku_tbl, success) print( "Report event:", success) dumptable(ku_tbl) end )

end

function d_reportevent(other_ku)
	TheItems:ReportEventProgress(json.encode_compliant(
		{
			WorldID = "dev_"..tostring(math.random(9999999))..tostring(math.random(9999999)),
			Teams =
			{
				{
					Won=true,
					Points=5,
					PlayerStats=
					{
						{KU = TheNet:GetUserID(), PlaytimeMs = 100000, Custom = { UnlockAchievements = {"scotttestdaily_d1", "wintime_30"} }},
						--{KU = other_ku or "KU_test", PlaytimeMs = 60000}
					}
				},
				--{
				--	Won=false,
				--	Points=2,
				--	PlayerStats=
				--	{
				--		{KU = "KU_test2", PlaytimeMs = 6000}
				--	}
				--}
			}
		}), function(ku_tbl, success) print( "Report event:", success) dumptable(ku_tbl) end )
end

function d_ground(ground, pt)
	ground = ground == nil and WORLD_TILES.QUAGMIRE_SOIL or
			type(ground) == "string" and WORLD_TILES[string.upper(ground)]
			or ground

	pt = pt or ConsoleWorldPosition()

    local x, y = TheWorld.Map:GetTileCoordsAtPoint(pt:Get())
    TheWorld.Map:SetTile(x, y, ground)
end

function d_portalfx()
	TheWorld:PushEvent("ms_newplayercharacterspawned", { player = ThePlayer})
end

function d_walls(width, height)
	width = math.floor(width or 10)
	height = math.floor(height or width)

	local pt = ConsoleWorldPosition()
	local left = math.floor(pt.x - width/2)
	local top = math.floor(pt.z + height/2)

	for i = 1, height do
		SpawnPrefab("wall_wood").Transform:SetPosition(left + 1, 0, top - i)
		SpawnPrefab("wall_wood").Transform:SetPosition(left + width, 0, top - i)
	end
	for i = 2, width-1 do
		SpawnPrefab("wall_wood").Transform:SetPosition(left + i, 0, top-1)
		SpawnPrefab("wall_wood").Transform:SetPosition(left + i, 0, top - height)
	end
end

-- 	hidingspot = c_select()  kitcoon = SpawnPrefab("kitcoon_deciduous") if not kitcoon.components.hideandseekhider:GoHide(hidingspot, 0) then kitcoon:Remove() end kitcoon = nil hidingspot = nil
function d_hidekitcoon()
	local hidingspot = ConsoleWorldEntityUnderMouse()
	local kitcoon = SpawnPrefab("kitcoon_deciduous")
	if not kitcoon.components.hideandseekhider:GoHide(hidingspot, 0) then
		kitcoon:Remove()
	end
end

function d_hidekitcoons()
	TheWorld.components.specialeventsetup:_SetupYearOfTheCatcoon()
end

function d_allkitcoons()
	local kitcoons =
	{
		"kitcoon_forest",
		"kitcoon_savanna",
		"kitcoon_deciduous",
		"kitcoon_marsh",
		"kitcoon_grass",
		"kitcoon_rocky",
		"kitcoon_desert",
		"kitcoon_moon",
		"kitcoon_yot",
	}

	d_spawnlist(kitcoons, 3, function(inst) inst._first_nuzzle = false end)
end

function d_allcustomhidingspots()
	local items = table.getkeys(TUNING.KITCOON_HIDING_OFFSET)
	d_spawnlist(items, 6, function(hidingspot)
		local kitcoon = SpawnPrefab("kitcoon_rocky")
		if not kitcoon.components.hideandseekhider:GoHide(hidingspot, 0) then
			kitcoon:Remove()
			hidingspot.AnimState:SetMultColour(1, 0, 0)
		end
	end)
end

function d_hunt()
    if TheWorld then
        local hunter = TheWorld.components.hunter
        if hunter then
            local player = ConsoleCommandPlayer()
            hunter:DebugForceHunt()
        end
    end
end

function d_islandstart()
	c_give("log", 12)
	c_give("rocks", 12)
	c_give("smallmeat", 2)
	c_give("meat", 2)
	c_give("rope", 2)
	c_give("cutgrass", 9)
	c_give("backpack")
	c_give("charcoal", 9)
	c_give("carrot", 3)
	c_give("berries", 12)
	c_give("pickaxe")
	c_give("axe")
	c_give(PickSomeWithDups(1, {"strawhat", "minerhat", "flowerhat"})[1])
	c_give(PickSomeWithDups(1, {"spear", "hambat", "trap"})[1])

    local MainCharacter = ConsoleCommandPlayer()
    if MainCharacter ~= nil and MainCharacter.components.sanity ~= nil then
		MainCharacter.components.sanity:SetPercent(math.random() * 0.4 + 0.2)
	end

end

function d_waxwellworker()
	local player = ConsoleCommandPlayer()
	local x, y, z = player.Transform:GetWorldPosition()

	local pet = player.components.petleash:SpawnPetAt(x, y, z, "shadowworker")
	if pet ~= nil then
		pet.components.knownlocations:RememberLocation("spawn", pet:GetPosition(), true)
	end
end

function d_waxwellprotector()
	local player = ConsoleCommandPlayer()
	local x, y, z = player.Transform:GetWorldPosition()

	local pet = player.components.petleash:SpawnPetAt(x, y, z, "shadowprotector")
	if pet ~= nil then
		pet.components.knownlocations:RememberLocation("spawn", pet:GetPosition(), true)
	end
end

function d_boatitems()
    c_spawn("boat_item")
    c_spawn("mast_item", 3)
    c_spawn("anchor_item")
    c_spawn("steeringwheel_item")
    c_spawn("oar")
end

function d_giveturfs()
    local GroundTiles = require("worldtiledefs")
    for k, v in pairs(GroundTiles.turf) do
        c_give("turf_"..v.name)
    end
end

function d_turfs()
    local GroundTiles = require("worldtiledefs")

	local items = {}
	for k, v in pairs(GroundTiles.turf) do
		table.insert(items, {"turf_"..v.name, 10})
	end

	d_spawnlist(items)
end

local function _SpawnLayout_AddFn(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
    local x = (points_x[current_pos_idx] - width/2.0)  * TILE_SCALE
    local y = (points_y[current_pos_idx] - height/2.0) * TILE_SCALE

    x = math.floor(x*100) / 100.0
    y = math.floor(y*100) / 100.0
    
    local inst = SpawnPrefab(prefab)

    if inst == nil then
        --print(string.format("Prefab %s couldn't be spawned...", tostring(prefab)))

        return
    end

    inst.Transform:SetPosition(x, 0, y)

    if prefab_data then
        if prefab_data.data ~= nil then
            local data = FunctionOrValue(prefab_data.data)
            
            if data ~= nil then
                -- Notes(DiogoW): not ideal, but it'll work for debugging purposes.
                inst:SetPersistData(data, Ents)
                inst:LoadPostPass(Ents, data)
            end
        end

        if prefab_data.scenario ~= nil then
            inst:AddComponent("scenariorunner")
            inst.components.scenariorunner:SetScript(prefab_data.scenario)
            inst.components.scenariorunner:Run()
        end
    end
end

local obj_layout = require("map/object_layout")

function d_spawnlayout(name, offset)
    offset = offset or 3

	local map_width, map_height = TheWorld.Map:GetSize()
	local entities = {}

	local add_fn = {
		fn = _SpawnLayout_AddFn,
		args = {entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
	}

    local x, z = TheWorld.Map:GetTileCoordsAtPoint(ConsoleWorldPosition():Get())

	obj_layout.Place({math.floor(x) - offset, math.floor(z) - offset}, name, add_fn, nil, TheWorld.Map)
end

function d_allfish()

	local fish_defs = require("prefabs/oceanfishdef").fish
	local allfish = {"spoiled_fish", "fishmeat", "fishmeat_cooked", "fishmeat_small", "fishmeat_small_cooked"}

	local pt = ConsoleWorldPosition()
	local pst = TheWorld.Map:IsVisualGroundAtPoint(pt:Get()) and "_inv" or ""
	for k, _ in pairs(fish_defs) do
		table.insert(allfish, k .. pst)
	end

	local spacing = 2
	local num_wide = math.ceil(math.sqrt(#allfish))

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			local inst = SpawnPrefab(allfish[(y*num_wide + x + 1)])
			if inst ~= nil then
				inst.Transform:SetPosition((pt + Vector3(x*spacing, 0, y*spacing)):Get())
			end
		end
	end
end

function d_fishing()
	local items = {"oceanfishingbobber_ball", "oceanfishingbobber_oval",  "twigs", "trinket_8",
					 "oceanfishingbobber_crow", "oceanfishingbobber_robin", "oceanfishingbobber_robin_winter",  "oceanfishingbobber_canary",
					 "oceanfishingbobber_goose", "oceanfishingbobber_malbatross",
				 	"oceanfishinglure_spinner_red", "oceanfishinglure_spinner_blue", "oceanfishinglure_spinner_green",
				 	"oceanfishinglure_spoon_red", "oceanfishinglure_spoon_blue", "oceanfishinglure_spoon_green",
					"oceanfishinglure_hermit_snow", "oceanfishinglure_hermit_rain", "oceanfishinglure_hermit_drowsy", "oceanfishinglure_hermit_heavy",
					 "berries", "butterflywings", "oceanfishingrod"}

	local spacing = 2
	local num_wide = math.ceil(math.sqrt(#items))

	local pt = ConsoleWorldPosition()

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			local inst = SpawnPrefab(items[(y*num_wide + x + 1)])
			if inst ~= nil then
				inst.Transform:SetPosition((pt + Vector3(x*spacing, 0, y*spacing)):Get())
			end
		end
	end
end

function d_tables()
    local items = {"table_winters_feast", "table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast",
                    "table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast",
                    "table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast",
                    "table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast","table_winters_feast",}

    local spacing = 1
    local num_wide = math.ceil(math.sqrt(#items))

    local pt = ConsoleWorldPosition()

    for y = 0, num_wide-1 do
        for x = 0, num_wide-1 do
            local inst = SpawnPrefab(items[(y*num_wide + x + 1)])
            if inst ~= nil then
                inst.Transform:SetPosition((pt + Vector3(x*spacing, 0, y*spacing)):Get())
            end
        end
    end
end

function d_gofishing()
	c_give("oceanfishingrod", 1)
	c_give("oceanfishingbobber_ball", 5)
	c_give("oceanfishingbobber_robin_winter", 5)
	c_give("oceanfishingbobber_malbatross", 5)
	c_give("oceanfishinglure_spinner_red", 5)
	c_give("oceanfishinglure_spinner_green", 5)
end

function d_radius(radius, num, lifetime)
	radius = radius or 4
	num = num or math.max(5, radius*2)
	lifetime = lifetime or 10
	local delta_theta = PI2 / num

	local pt = ConsoleWorldPosition()

	for i = 1, num do

		local p = SpawnPrefab("flint")
		p.Transform:SetPosition(pt.x + radius * math.cos( i*delta_theta ), 0, pt.z - radius * math.sin( i*delta_theta ))
		p:DoTaskInTime(lifetime, p.Remove)
	end
end

function d_ratracer(speed, stamina, direction, reaction)
	local rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.speed = speed or math.random(TUNING.RACE_STATS.MAX_STAT_VALUE + 1) - 1
	rat.components.yotc_racestats.stamina = stamina or math.random(TUNING.RACE_STATS.MAX_STAT_VALUE + 1) - 1
	rat.components.yotc_racestats.direction = direction or math.random(TUNING.RACE_STATS.MAX_STAT_VALUE + 1) - 1
	rat.components.yotc_racestats.reaction = reaction or math.random(TUNING.RACE_STATS.MAX_STAT_VALUE + 1) - 1
	rat:_setcolorfn("RANDOM")
	c_select(rat)
	ConsoleCommandPlayer().components.inventory:GiveItem(rat)
end

function d_ratracers()
    local MainCharacter = ConsoleCommandPlayer()
	local rat

	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.speed = TUNING.RACE_STATS.MAX_STAT_VALUE
	rat:_setcolorfn("white")
	MainCharacter.components.inventory:GiveItem(rat)
	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.speed = 0
	rat:_setcolorfn("yellow")
	MainCharacter.components.inventory:GiveItem(rat)

	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.stamina = TUNING.RACE_STATS.MAX_STAT_VALUE
	rat:_setcolorfn("green")
	MainCharacter.components.inventory:GiveItem(rat)
	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.stamina = 0
	rat:_setcolorfn("brown")
	MainCharacter.components.inventory:GiveItem(rat)

	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.direction = TUNING.RACE_STATS.MAX_STAT_VALUE
	rat:_setcolorfn("blue")
	MainCharacter.components.inventory:GiveItem(rat)
	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.direction = 0
	rat:_setcolorfn("NEUTRAL")
	MainCharacter.components.inventory:GiveItem(rat)

	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.reaction = TUNING.RACE_STATS.MAX_STAT_VALUE
	rat:_setcolorfn("purple")
	MainCharacter.components.inventory:GiveItem(rat)
	rat = DebugSpawn("carrat")
	rat._spread_stats_task:Cancel() rat._spread_stats_task = nil
	rat.components.yotc_racestats.reaction = 0
	rat:_setcolorfn("pink")
	MainCharacter.components.inventory:GiveItem(rat)
end

-- d_setup_placeholders( STRINGS.CHARACTERS.WARLY, "scripts\\speech_warly.lua" )
function d_setup_placeholders( reuse, out_file_name )
	local use_table = nil
	use_table = function( base_speech, reuse_speech )
		for k,v in pairs( base_speech ) do
			if type(v) == "string" then
				if reuse_speech ~= nil and reuse_speech[k] ~= nil then
					--do nothing
				else
					reuse_speech[k] = "TODO"
				end
			else
				--table
				if reuse_speech[k] == nil then
					reuse_speech[k] = {}
				end
				use_table( base_speech[k], reuse_speech[k])
			end
		end
	end
	use_table( STRINGS.CHARACTERS.GENERIC, reuse )

	local out_file = io.open( out_file_name, "w")

	out_file:write("return {\n")

	local write_table = nil
	write_table = function( tbl, tabs )
		for k,v in orderedPairs(tbl) do
			for i=1,tabs do out_file:write("\t") end

			if type(v) == "string" then
				local out_v = string.gsub(v, "\n", "\\n")
				out_v = string.gsub(out_v, "\"", "\\\"")
				if type(k) == "string" then
					out_file:write(k .. " = \"" .. out_v .. "\",\n")
				else
					out_file:write("\"" .. out_v .. "\",\n")
				end
			else
				out_file:write(k .. " =\n")
				for i=1,tabs do out_file:write("\t") end
				out_file:write("{\n")

				write_table( tbl[k], tabs + 1 )

				for i=1,tabs do out_file:write("\t") end
				out_file:write("},\n")
			end
		end
	end

	write_table( reuse, 1 )

	out_file:write("}")
	out_file:close()
end

function d_allshells()
	local x, y, z = TheInput:GetWorldPosition():Get()
	for i=1, 12 do
		local shell=SpawnPrefab("singingshell_large")
		shell.Transform:SetPosition(x + i*2, 0, z)
		shell.components.cyclable:SetStep(i)
		local shell=SpawnPrefab("singingshell_medium")
		shell.Transform:SetPosition(x + i*2, 0, z + 6)
		shell.components.cyclable:SetStep(i)
		local shell=SpawnPrefab("singingshell_small")
		shell.Transform:SetPosition(x + i*2, 0, z + 12)
		shell.components.cyclable:SetStep(i)
	end
end


function d_fish(swim, r,g,b)
	local x, y, z = TheInput:GetWorldPosition():Get()

	local fish
	fish = c_spawn "oceanfish_medium_4"
	if not swim then
		fish:StopBrain()
		fish:SetBrain(nil)
	end
	fish.Transform:SetPosition(x, y, z)
	fish:RemoveTag("NOCLICK")

	fish = c_spawn "oceanfish_medium_3"
	if not swim then
		fish:StopBrain()
		fish:SetBrain(nil)
	end
	fish.Transform:SetPosition(x+2, y, z)
	fish:RemoveTag("NOCLICK")

	fish = c_spawn "oceanfish_medium_8"
	if not swim then
		fish:StopBrain()
		fish:SetBrain(nil)
	end
	fish.Transform:SetPosition(x, y, z+2)
	fish:RemoveTag("NOCLICK")


	fish = c_spawn "oceanfish_medium_3"
	if not swim then
		fish:StopBrain()
		fish:SetBrain(nil)
	end
	fish.Transform:SetPosition(x+2, y, z+2)
	fish:RemoveTag("NOCLICK")
	fish.AnimState:SetAddColour((r or 0)/255, (g or 5)/255, (b or 5)/255, 0)

end

function d_farmplants(grow_stage, oversized)
	local items = {}
	for k, v in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
		if v.product_oversized ~= nil then
			table.insert(items, v.prefab)
		end
	end

	d_spawnlist(items, 2.5,
		function(inst)
			if grow_stage ~= nil then
				for i = 1, grow_stage do
					inst:DoTaskInTime((i-1) * 1 + math.random() * 0.5, function()
							inst.components.growable:DoGrowth()
					end)
				end
			end

            if oversized then
                inst.force_oversized = true
            end
		end)
end
function d_plant(plant, num_wide, grow_stage, spacing)
	spacing = spacing or 1.25

	local pt = ConsoleWorldPosition()
	pt.x = pt.x - num_wide * 0.5 * spacing
	pt.z = pt.z - num_wide * 0.5 * spacing

	for y = 0, num_wide-1 do
		for x = 0, num_wide-1 do
			local inst = SpawnPrefab(plant)
			if inst ~= nil then
				inst.Transform:SetPosition((pt + Vector3(x*spacing, 0, y*spacing)):Get())
				if grow_stage ~= nil then
					for k = 1, grow_stage do
						inst:DoTaskInTime(0.1 * k, function()
							inst.components.growable:DoGrowth()
						end)
					end
				end
			end
		end
	end

end

function d_seeds()
	local items = {}
	for k, v in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
		if v.product_oversized ~= nil then
			table.insert(items, v.seed)
		end
	end
	d_spawnlist(items, 2)
end

function d_fertilizers()
	d_spawnlist(require("prefabs/fertilizer_nutrient_defs").SORTED_FERTILIZERS, 2)
end

function d_oversized()
	local items = {}
	for k, v in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
		if v.product_oversized ~= nil then
			table.insert(items, v.product_oversized)
			end
		end
	d_spawnlist(items, 3)
end

function d_startmoonstorm()
	local pt = ConsoleWorldPosition()
	TheWorld.components.moonstormmanager:StartMoonstorm(TheWorld.Map:GetNodeIdAtPoint(pt.x, pt.y, pt.z))
end

function d_stopmoonstorm()
	TheWorld.components.moonstormmanager:StopCurrentMoonstorm()
end

function d_moonaltars()
	local offset = 7
	local pos = TheInput:GetWorldPosition()
	local altar

	altar = SpawnPrefab("moon_altar")
	altar.Transform:SetPosition(pos.x, 0, pos.z - offset)
	altar:set_stage_fn(2)

	SpawnPrefab("moon_altar_idol").Transform:SetPosition(pos.x, 0, pos.z - offset - 2)

	altar = SpawnPrefab("moon_altar_astral")
	altar.Transform:SetPosition(pos.x - offset, 0, pos.z + offset / 3)
	altar:set_stage_fn(2)

	altar = SpawnPrefab("moon_altar_cosmic")
	altar.Transform:SetPosition(pos.x + offset, 0, pos.z + offset / 3)
end

function d_cookbook()
	TheCookbook.save_enabled = false

	local cooking = require("cooking")
	for cat, cookbook_recipes in pairs(cooking.cookbook_recipes) do
		for prefab, recipe_def in pairs(cookbook_recipes) do
			TheCookbook:LearnFoodStats(prefab)
			TheCookbook:AddRecipe(prefab, {"meat", "meat", "meat", "meat"})
			TheCookbook:AddRecipe(prefab, {"twigs", "berries", "ice", "meat"})
		end
	end
end

function d_statues(material)
	local mats =
	{
		"marble",
		"stone",
		"moonglass",
	}

	local items = {
		"pawn",
		"rook",
		"knight",
		"bishop",
		"muse",
		"formal",
		"hornucopia",
		"pipe",
		"deerclops",
		"bearger",
		"moosegoose",
		"dragonfly",
		"clayhound",
		"claywarg",
		"butterfly",
		"anchor",
		"moon",
		"carrat",
		"beefalo",
		"crabking",
		"malbatross",
		"toadstool",
		"stalker",
		"klaus",
		"beequeen",
		"antlion",
		"minotaur",
		"guardianphase3",
        "eyeofterror",
        "twinsofterror",
        "kitcoon",
        "catcoon",
	}

	local material = (type(material) == "string" and table.contains(mats, material)) and material
					or type(material) == "number" and mats[material]
					or "marble"

	for i, v in ipairs(items) do
		items[i] = "chesspiece_".. v .."_" .. (material or "marble")
	end
	d_spawnlist(items, 5)
end

function d_craftingstations()
	local prefabs = {}
	for k, _ in pairs(PROTOTYPER_DEFS) do
		table.insert(prefabs, k)
	end
	d_spawnlist(prefabs, 6)
end

function d_removeentitywithnetworkid(networkid, x, y, z)
    local ents = TheSim:FindEntities(x,y,z, 1)
    for i, ent in ipairs(ents) do
        if ent and ent.Network and ent.Network:GetNetworkID() == networkid then
            c_remove(ent)
            return
        end
    end
end


function d_recipecards()
	local items = {}

	local cards = require("cooking").recipe_cards
	for _, card in ipairs(cards) do
		table.insert(items, {"cookingrecipecard", 1, function(inst)
			    inst.recipe_name = card.recipe_name
				inst.cooker_name = card.cooker_name
				inst.components.named:SetName(subfmt(STRINGS.NAMES.COOKINGRECIPECARD, { item = STRINGS.NAMES[string.upper(card.recipe_name)] or card.recipe_name }))
			end}
		)
	end

	d_spawnlist(items, 2)
end

function d_spawnfilelist(filename, spacing)
-- the file will need to be located in: \Documents\Klei\DoNotStarveTogether\<steam id>\client_save
-- the fileformat is one prefab per line

	local prefabs = {}

	TheSim:GetPersistentString(filename, function(success, str)
        if success and str ~= nil and #str > 0 then
			for prefab in str:gmatch("[^\r\n]+") do
				table.insert(prefabs, prefab)
			end
		else
			print("d_spawnfilelist failed:", filename, str, success)
		end
	end)

	d_spawnlist(prefabs, spacing)
end

function d_spawnallhats()
	d_spawnlist(ALL_HAT_PREFAB_NAMES)
end

local function spawn_mannequin_and_equip_item(item)
	local ix, iy, iz = item.Transform:GetWorldPosition()
	local stand = SpawnPrefab("sewing_mannequin")
	stand.Transform:SetPosition(ix, iy, iz)
	stand.components.inventory:Equip(item)
end

function d_spawnallhats_onstands()
    local all_hats = {"slurper"}
    for i = 1, #ALL_HAT_PREFAB_NAMES do
        table.insert(all_hats, ALL_HAT_PREFAB_NAMES[i])
    end
	d_spawnlist(all_hats, 3.5, spawn_mannequin_and_equip_item)
end

function d_spawnallarmor_onstands()
	local all_armor =
	{
		"amulet",
		"blueamulet",
		"purpleamulet",
		"orangeamulet",
		"greenamulet",
		"yellowamulet",
		"armor_bramble",
		"armordragonfly",
		"armorgrass",
		"armormarble",
		"armorruins",
		"armor_sanity",
		"armorskeleton",
		"armorslurper",
		"armorsnurtleshell",
		"armorwood",
		"backpack",
		"balloonvest",
		"beargervest",
		"candybag",
		"carnival_vest_a",
		"carnival_vest_b",
		"carnival_vest_c",
		"costume_doll_body",
        "costume_queen_body",
        "costume_king_body",
        "costume_blacksmith_body",
        "costume_mirror_body",
        "costume_tree_body",
        "costume_fool_body",
		"hawaiianshirt",
		"icepack",
		"krampus_sack",
		"onemanband",
		"piggyback",
		"potatosack",
		"raincoat",
		"reflectivevest",
		"seedpouch",
		"spicepack",
		"sweatervest",
		"trunkvest_summer",
		"trunkvest_winter",
	}

	d_spawnlist(all_armor, 3.5, spawn_mannequin_and_equip_item)
end

function d_spawnallhandequipment_onstands()
    local all_hand_equipment =
    {
        "multitool_axe_pickaxe",
        "axe",
        "goldenaxe",
        "balloon",
        "balloonparty",
        "balloonspeed",
        "batbat",
        "bernie_inactive",
        "blowdart_sleep",
        "blowdart_fire",
        "blowdart_pipe",
        "blowdart_yellow",
        "blowdart_walrus",
        "boomerang",
        "brush",
        "bugnet",
        "bullkelp_root",
        "cane",
        "carnivalgame_feedchicks_food",
        "chum",
        "compass",
        "cutless",
        "diviningrod",
        "dumbbell",
        "dumbbell_golden",
        "dumbbell_marble",
        "dumbbell_gem",
        "farm_hoe",
        "golden_farm_hoe",
        "fence_rotator",
        "firepen",
        "fishingnet",
        "fishingrod",
        "glasscutter",
        "gnarwail_horn",
        "hambat",
        "hammer",
        "lighter",
        "lucy",
        "messagebottle_throwable",
        "minifan",
        "lantern",
        "nightstick",
        "nightsword",
        "oar",
        "oar_driftwood",
        "oar_monkey",
        "malbatross_beak",
        "oceanfishingrod",
        "pickaxe",
        "goldenpickaxe",
        "pitchfork",
        "pocketwatch_weapon",
        "propsign",
        "redlantern",
        "reskin_tool",
        "ruins_bat",
        "saddlehorn",
        "shieldofterror",
        "shovel",
        "goldenshovel",
        "sleepbomb",
        "slingshot",
        "spear_wathgrithr",
        "spear",
        "staff_tornado",
        "icestaff",
        "firestaff",
        "telestaff",
        "orangestaff",
        "greenstaff",
        "yellowstaff",
        "opalstaff",
        "tentaclespike",
        "thurible",
        "torch",
        "trident",
        "umbrella",
        "grass_umbrella",
        "wateringcan",
        "premiumwateringcan",
        "waterplant_bomb",
        "waterballoon",
        "whip",
    }

	d_spawnlist(all_hand_equipment, 3.5, spawn_mannequin_and_equip_item)
end

function d_allpillows()
    local all_pillow_equipment = {}
    for material in pairs(require("prefabs/pillow_defs")) do
        table.insert(all_pillow_equipment, "handpillow_"..material)
        table.insert(all_pillow_equipment, "bodypillow_"..material)
    end

    d_spawnlist(all_pillow_equipment, 3.5)
end

function d_allpillows_onstands()
    local all_pillow_equipment = {}
    for material in pairs(require("prefabs/pillow_defs")) do
        table.insert(all_pillow_equipment, "handpillow_"..material)
        table.insert(all_pillow_equipment, "bodypillow_"..material)
    end

    d_spawnlist(all_pillow_equipment, 3.5, spawn_mannequin_and_equip_item)
end

function d_spawnequipment_onstand(...)
	if arg == nil or #arg == 0 then return end

	local stand = SpawnPrefab("sewing_mannequin")
	stand.Transform:SetPosition(ConsoleWorldPosition():Get())

	for _, item in ipairs(arg) do
		stand.components.inventory:Equip(SpawnPrefab(item))
	end
end

--@V2C #TODO: #DELETEME
function d_daywalker(chain)
	local daywalker = c_spawn("daywalker")
	local x, y, z = daywalker.Transform:GetWorldPosition()
	local radius = 6
	local num = 3
	for i = 1, num do
		local theta = i * TWOPI / num + PI * 3 / 4
		local pillar = c_spawn("daywalker_pillar")
		pillar.Transform:SetPosition(
			x + math.cos(theta) * radius,
			0,
			z - math.sin(theta) * radius
		)
		if chain then
			pillar:SetPrisoner(daywalker)
		end
	end

	c_select(daywalker)
end

function d_moonplant()
    if c_sel() then
        TheWorld.components.lunarthrall_plantspawner:SpawnPlant(c_sel())
    end
end

function d_punchingbags()
    local punchingbag_list = {"punchingbag", "punchingbag_lunar", "punchingbag_shadow"}
    d_spawnlist(punchingbag_list, 3.0)
end

function d_skilltreestats()
    local skilltreedata_all = require("prefabs/skilltree_defs")
    local SKILLTREE_METAINFO = skilltreedata_all.SKILLTREE_METAINFO
    local tosort = {}
    for prefab, data in pairs(SKILLTREE_METAINFO) do
        table.insert(tosort, {
            prefab = prefab,
            count = data.TOTAL_SKILLS_COUNT,
            locks = data.TOTAL_LOCKS,
        })
    end
    table.sort(tosort, function(a, b)
        if a.count == b.count then
            return a.prefab < b.prefab
        end
        return a.count < b.count
    end)
    for _, v in ipairs(tosort) do
        print(string.format("%16s, Skill count: %2d, Locks count: %2d", v.prefab, v.count, v.locks))
    end
end

local skiplist = {}
skiplist["blossom_hit_fx"] = true
skiplist["quagmire_parkspike"] = true
skiplist["quagmire_spotspice_shrub"] = true
skiplist["lavaarena_elemental"] = true
skiplist["lavaarena"] = true
skiplist["fireball_hit_fx"] = true
skiplist["quagmire_coin_fx"] = true
skiplist["lavaarena_spectator"] = true
skiplist["global"] = true
skiplist["audio_test_prefab"] = true
skiplist["peghook_hitfx"] = true
skiplist["quagmire_coin4"] = true
skiplist["quagmire_food"] = true
skiplist["lavaarena_boarlord"] = true
skiplist["quagmire"] = true
skiplist["world"] = true
skiplist["shard_network"] = true
skiplist["cave_network"] = true
skiplist["cave"] = true
skiplist["gooball_hit_fx"] = true
skiplist["forest_network"] = true
skiplist["peghook_splashfx"] = true
skiplist["quagmire_network"] = true
skiplist["lavaarena_network"] = true
skiplist["quagmire_mushroomstump"] = true
skiplist["forest"] = true
skiplist["quagmire_parkspike_short"] = true
skiplist["reticulearc"] = true
skiplist["reticuleline"] = true
skiplist["reticulelong"] = true
skiplist["reticuleaoe"] = true
skiplist["reticule"] = true

function d_dumpCreatureTXT()

    local f = io.open("creatures.txt", "w")
    local total = 0
    local str = ""
    if f then
       --"PREFAB","NAME", "HEALTH", "DAMAGE"
       str = str .. string.format("%s;%s;%s;%s\n", "PREFAB","NAME", "HEALTH", "DAMAGE")
        for i,data in pairs(Prefabs)do
            print("=====>",i)
           -- dumptable(data,1,1)
            if not data.base_prefab and not skiplist[i] then -- not a skin
                local t = SpawnPrefab(i)
                if t and t.components.health then
                --if t and (t:HasTag("smallcreature") or t:HasTag("monster") or t:HasTag("animal")) then

                    local name = t.name or "---"
                    local health = t.components.health and t.components.health.maxhealth or 0
                    local damage = t.components.combat and t.components.combat.defaultdamage or 0

                    str = str .. string.format("%s;%s;%s;%s\n", i,name, tostring(health), tostring(damage))
                end
                t:Remove()
                total = total + 1
            else
                print("Skipping")
            end
        end

        f:write(str)
    end
end
function d_dumpItemsTXT()

    local f = io.open("items.txt", "w")
    local total = 0
    local str = ""
    if f then
        for i,data in pairs(Prefabs)do
            if not data.base_prefab and not skiplist[i] then -- not a skin
                local t = SpawnPrefab(i)
                if t and t.components.inventoryitem then
                    str = str..'["'..t.prefab..'"]=true,\n'
                end
                t:Remove()
            end
        end
        --[[
        str = str .. string.format("%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n","PREFAB","NAME","STACKSIZE","DURABILITY","SPOILTIME","FOOD-HEALTH","FOOD-HUNGER","FOOD-SANITY","DAMAGE","PLANAR DAMAGE","ARMOR-%","ARMOR-HEALTH")
        for i,data in pairs(Prefabs)do
            print("=====>",i)
           -- dumptable(data,1,1)
            if not data.base_prefab and not skiplist[i] then -- not a skin
                local t = SpawnPrefab(i)
                if t and t.components.inventoryitem then
                --if t and (t:HasTag("smallcreature") or t:HasTag("monster") or t:HasTag("animal")) then

                    local name = t.name or "---"
                    local stack = t.components.stackable and t.components.stackable.maxsize or 1
                    local durability = t.components.finiteuses and t.components.finiteuses.total or 0
                    local spoiltime = t.components.perishable and t.components.perishable.perishtime or 0

                    local food_health = t.components.edible and t.components.edible.healthvalue or "-"
                    local food_hunger = t.components.edible and t.components.edible.hungervalue or "-"
                    local food_sanity = t.components.edible and t.components.edible.sanityvalue or "-"

                    local weapondamage = t.components.weapon and t.components.weapon.damage or "-"
                    local planardamage = t.components.planardamage and t.components.planardamage.basedamage or "-"
                    local absorb_percent = t.components.armor and t.components.armor.absorb_percent or "-"
                    local condition =    t.components.armor and t.components.armor.condition or "-"

                    str = str .. string.format("%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n", i,name, tostring(stack), tostring(durability), tostring(spoiltime),
                        tostring(food_health), tostring(food_hunger), tostring(food_sanity),
                        tostring(weapondamage), tostring(planardamage), tostring(absorb_percent), tostring(condition)
                        )
                end
                t:Remove()
                total = total + 1
            else
                print("Skipping")
            end
        end
    ]]
        f:write(str)
    end
end

function d_structuresTXT()

    local f = io.open("structures.txt", "w")
    local total = 0
    local str = ""
    if f then
        str = str .. string.format("%s;%s\n","PREFAB","NAME")
        for i,data in pairs(Prefabs)do
            print("=====>",i)
           -- dumptable(data,1,1)
            if not data.base_prefab and not skiplist[i] then -- not a skin
                local t = SpawnPrefab(i)
                if t and not t.components.inventoryitem and not t.components.locomotor and not t:HasTag("fx") then

                --if t and (t:HasTag("smallcreature") or t:HasTag("monster") or t:HasTag("animal")) then

                    local name = t.name or "---"

                    str = str .. string.format("%s;%s\n", i,name)
                end
                t:Remove()
                total = total + 1
            else
                print("Skipping")
            end
        end

        f:write(str)
    end
end

--------------------------------------------------------------------------------------------------------------------

local RECIPE_BUILDER_TAG_LOOKUP = {
    balloonomancer = "wes",
    basicengineer = "winona",
    portableengineer = "winona",
    battlesinger = "wathgrithr",
    bookbuilder = "wickerbottom",
    clockmaker = "wanda",
    elixirbrewer = "wendy",
    ghostlyfriend = "wendy",
    handyperson = "winona",
    masterchef = "warly",
    merm_builder = "wurt",
    pebblemaker = "walter",
    pinetreepioneer = "walter",
    plantkin = "wormwood",
    professionalchef = "warly",
    pyromaniac = "willow",
    shadowmagic = "waxwell",
    spiderwhisperer = "webber",
    strongman = "wolfgang",
    upgrademoduleowner = "wx78",
    valkyrie = "wathgrithr",
    werehuman = "woodie",
}

-- key: string
-- value: string, number, boolean or string array (does not work for map-type tables or arrays of non-strings).
local function Scrapbook_AddInfo(tbl, key, value)
    if value == nil then return end

    assert( checkstring(key), string.format("Parameter [key] must be of type string, and it's [ %s ].", type(key)) )

    if type(value) == "table" then
        value = string.format('{"%s"}', table.concat(value, '", "'))
    end

    local add_quotes = checkstring(value) and value:sub(1, 1) ~= "{"

    table.insert(tbl, string.format('%s=%s', key, add_quotes and '"'..value..'"' or tostring(value)))
end

local function Scrapbook_WriteToFile(buffer)
    local str = "\n-- AUTOGENERATED FROM d_createscrapbookdata()   < debugcommands.lua >\n\nreturn {\n%s\n}\n"
    local entries = {}

    for i, prefab, data in sorted_pairs(buffer) do
        table.insert(entries, string.format('    %s = {%s},', prefab, table.concat(data, ", ")))
    end

    local f = io.open("scripts/screens/redux/scrapbookdata.lua", "w")

    if f ~= nil then
        f:write(string.format(str, table.concat(entries, "\n")))
        f:close()
    end
end

local function Scrapbook_IsOnCraftingFilter(filter, entry)
    return table.contains(CRAFTING_FILTERS[string.upper(filter)].recipes, entry)
end

local function Scrapbook_DefineSubCategory(t)
    local subcat = nil

    local foodtype = t.components.edible ~= nil and t.components.edible.foodtype or nil

    if t:HasOneOfTags({ "wall", "wallbuilder" }) then
        subcat = "wall"
    elseif t.scrapbook_specialinfo == "COSTUME" then
        subcat = "costume"
    elseif t.scrapbook_specialinfo == "WINTERSFEASTCOOKEDFOODS" then
        subcat = "wintersfeastfood"
    elseif t:HasTag("haunted") then
        subcat = "hauntedtoy"
    elseif t:HasTag("singingshell") then
        subcat = "shell"
    elseif t:HasTag("bird") then
        subcat = "bird"
    elseif t:HasTag("pig") and not t:HasTag("manrabbit") then
        subcat = "pig"
    elseif t:HasTag("merm") then
        subcat = "merm"
    elseif t:HasTag("hound") then
        subcat = "hound"
    elseif t:HasTag("chess") then
        subcat = "clockwork"
    elseif t:HasTag("oceanfish") then
        subcat = "oceanfish"
    elseif t:HasTag("wagstafftool") then
        subcat = "wagstafftool"
    elseif t:HasTag("pocketwatch") then
        subcat = "pocketwatch"
    elseif t:HasTag("groundtile") then
        subcat = "turf"
    elseif t:HasTag("backpack") then
        subcat = "backpack"
    elseif t:HasTag("chest") or Scrapbook_IsOnCraftingFilter("CONTAINERS", t.prefab) then
        subcat = "container"
    elseif t:HasTag("battlesong") then
        subcat = "battlesong"
    elseif t:HasTag("ghostlyelixir") then
        subcat = "elixer"
    elseif t:HasTag("farm_plant") then
        subcat = "farmplant"
    elseif t.components.tool or t.scrapbook_subcat == "tool" then
        subcat = "tool"
    elseif t.components.weapon or t.scrapbook_subcat == "weapon" then
        subcat = "weapon"
    elseif t:HasTag("spidermutator") then
        subcat = "mutator"
    elseif foodtype ~= nil and
        foodtype ~= FOODTYPE.GENERIC and foodtype ~= FOODTYPE.GOODIES and foodtype ~= FOODTYPE.MEAT and
        foodtype ~= FOODTYPE.VEGGIE and foodtype ~= FOODTYPE.HORRIBLE and foodtype ~= FOODTYPE.INSECT and
        foodtype ~= FOODTYPE.SEEDS and foodtype ~= FOODTYPE.RAW and foodtype ~= FOODTYPE.BERRY
    then
        subcat = "element"
    elseif t.components.armor or t.prefab == "armorskeleton" then
        subcat = "armor"
    elseif t.pieceid then
        subcat = "statue"
    elseif t.components.equippable and t.components.equippable.equipslot == EQUIPSLOTS.BODY and not t:HasTag("heavy") then
        subcat = "clothing"
    elseif t:HasTag("hat") then
        subcat = "hat"
    elseif t.components.oceanfishingtackle then
        subcat = "tackle"
    elseif t.components.prototyper then
        subcat = "craftingstation"
    elseif t:HasTag("shadow") then
        subcat = "shadow"
    elseif t:HasTag("book") then
        subcat = "book"
    elseif t:HasTag("winter_ornament") then
        subcat = "ornament"
    elseif string.find(t.prefab, "trinket") then
        subcat = "trinket"
    elseif t.components.upgrademodule then
        subcat = "upgrademodule"
    elseif t:HasTag("halloween_ornament") then
        subcat = "halloweenornament"
    elseif t:HasTag("spider") then
        subcat = "spider"
    elseif t:HasTag("insect") then
        subcat = "insect"
    elseif (t:HasTag("tree") or table.contains({"cave_banana_tree"}, t.prefab)) and not t:HasOneOfTags({ "monster", "leif" }) then
        subcat = "tree"
    elseif (t.prefab:find("atrium_")) and not table.contains({"atrium_key"}, t.prefab) then
        subcat = "atrium"
    elseif Scrapbook_IsOnCraftingFilter("RIDING", t.prefab) then
        subcat = "riding"
    elseif Scrapbook_IsOnCraftingFilter("SEAFARING", t.prefab) or
           Scrapbook_IsOnCraftingFilter("SEAFARING", t.prefab.."_item") or
           Scrapbook_IsOnCraftingFilter("SEAFARING", t.prefab.."_kit")
    then
        subcat = "seafaring" -- Keep it low priority!
    elseif t:HasTag("structure") then
        subcat = "structure" -- Keep it low priority!
    end

    if subcat ~= nil and not STRINGS.SCRAPBOOK.SUBCATS[string.upper(subcat)] then
        print(string.format("[!!!!]  Sub-category [ %s ] isn't defined in STRINGS.SCRAPBOOK.SUBCATS!", subcat))
    end

    return subcat
end

local SCRAPBOOK_NAME_LOOKUP =
{
    mooseegg = "mooseegg1",
    moose = "moose1",
    ruins_chair = "relic",
    archive_switch_base = "archive_switch",
    chessjunk1 = "chessjunk1",
    chessjunk2 = "chessjunk1",
    chessjunk3 = "chessjunk1",

    sketch = "sketch_scrapbook",
    tacklesketch = "tacklesketch_scrapbook",
    cookingrecipecard = "cookingrecipecard_scrapbook",
}

local function Scrapbook_DefineName(t)
    local name = t.scrapbook_prefab or SCRAPBOOK_NAME_LOOKUP[t.prefab] or (t:HasTag("farm_plant") and t.prefab) or t.nameoverride or t.prefab

    if not STRINGS.NAMES[string.upper(name)] then
        print(string.format("[!!!!]  Name [ %s ] isn't defined in STRINGS.NAMES!", name))
    end

    return name
end


local function Scrapbook_DefineType(t, entry)
    local thingtype = "thing"

    local foodtype = t.components.edible ~= nil and t.components.edible.foodtype or nil

    if t.components.pointofinterest then
        thingtype = "POI"

    elseif t.scrapbook_thingtype then
        thingtype = t.scrapbook_thingtype

    elseif t:HasTag("oceanfish") then
        thingtype = "creature"

    elseif foodtype ~= nil and (
        foodtype == FOODTYPE.GENERIC or foodtype == FOODTYPE.GOODIES or foodtype == FOODTYPE.MEAT or
        foodtype == FOODTYPE.VEGGIE or foodtype == FOODTYPE.HORRIBLE or foodtype == FOODTYPE.INSECT or
        foodtype == FOODTYPE.SEEDS or foodtype == FOODTYPE.RAW or foodtype == FOODTYPE.BERRY
    ) then
        thingtype = "food"

    elseif t:HasOneOfTags({"epic", "crabking"}) or t.prefab == "shadow_rook" or t.prefab == "shadow_bishop" or t.prefab == "shadow_knight" then
        thingtype = "giant"

    elseif t.prefab == "pumpkin_lantern" or t.prefab == "eyeturret" then
        thingtype = "thing"

    elseif t.prefab == "fused_shadeling_bomb" or
        t.prefab == "smallghost" or
        t.prefab == "wobybig" or
        t.prefab == "stagehand"
    then
        thingtype = "creature"

    elseif t:HasTag("NPCcanaggro") or (
        t.components.health ~= nil and
        t.sg ~= nil and
        not t:HasOneOfTags({ "structure", "boatbumper", "boat" })
    ) then
        thingtype = "creature"

    elseif t.components.inventoryitem and (not t.components.health or t.components.equippable) then
        thingtype = "item"
    end

    if not table.contains(SCRAPBOOK_CATS, thingtype) then
        print(string.format("[!!!!]  Thing type [ %s ] isn't defined in SCRAPBOOK_CATS!", thingtype))
    end

    return thingtype
end

local function Scrapbook_DefineAnimation(t)
    local anim = nil

    if t.scrapbook_anim then
        anim = t.scrapbook_anim
    elseif t:HasTag("campfire") and t.prefab ~= "cotl_tabernacle_level3" then
        anim = "scrapbook"
    elseif t.AnimState:IsCurrentAnimation("idle_dead") then
        anim = "idle_dead"
    elseif t.AnimState:IsCurrentAnimation("idle_cooked") then
        anim = "idle_cooked"
    elseif t.prefab == "shadow_forge_kit" then
        anim = "kit"
    elseif t.prefab == "lunar_forge_kit" then
        anim = "kit"
    elseif t:HasTag("tree") and not t:HasTag("ancienttree") and not table.contains({"livingtree", "marsh_tree", "oceantree", "driftwood_tall", "driftwood_small1", "mushtree_tall_webbed"}, t.prefab) then
        anim = "idle_tall"
    elseif t.winter_ornamentid and t:HasTag("lightbattery") then
        anim = t.winter_ornamentid .. "_on"
    elseif t.winter_ornamentid then
        anim = t.winter_ornamentid
    elseif t.prefab == "dug_bananabush" then
        anim = "idle_big"
    elseif t:HasTag("battlesong") then
        anim = t.prefab
    elseif t.prefab == "abigail_flower" then
        anim = "level3_loop"
    elseif t.AnimState:IsCurrentAnimation("f1") or
        t.AnimState:IsCurrentAnimation("f2") or
        t.AnimState:IsCurrentAnimation("f3") then
        anim = "f1"
    elseif t.AnimState:IsCurrentAnimation("rotten") then
        anim = "rotten"
    elseif t.AnimState:IsCurrentAnimation("pack_loop") then
        anim = "pack_loop"
    elseif t.AnimState:IsCurrentAnimation("idle_loop") then
        anim = "idle_loop"
    elseif t.AnimState:IsCurrentAnimation("idle_med") or t.AnimState:IsCurrentAnimation("idle_tall") or t.AnimState:IsCurrentAnimation("idle_short") then
        anim = "idle_med"
    elseif t.AnimState:IsCurrentAnimation("idle_sit") then
        anim = "idle_sit"
    elseif t.prefab == "squid" or t.prefab == "lightcrab" then
        anim = "idle"
    elseif t.AnimState:IsCurrentAnimation("idle1") or
        t.AnimState:IsCurrentAnimation("idle2") or
        t.AnimState:IsCurrentAnimation("idle3") or
        t.AnimState:IsCurrentAnimation("idle4") or
        t.AnimState:IsCurrentAnimation("idle5") or
        t.AnimState:IsCurrentAnimation("idle6") or
        t.AnimState:IsCurrentAnimation("idle7") or
        t.AnimState:IsCurrentAnimation("idle8") or
        t.AnimState:IsCurrentAnimation("idle9") or
        t.AnimState:IsCurrentAnimation("idle10") then
        anim = "idle1"
    elseif t.AnimState:IsCurrentAnimation("cooked") then
        anim = "cooked"
    elseif t.AnimState:IsCurrentAnimation("fly_loop") then
        anim = "fly_loop"
    elseif t.AnimState:IsCurrentAnimation("anim") then
        anim = "anim"
    elseif t.sg and t.sg:HasState("idle") then
        anim = "idle"
    end

    if not anim then
        local bank = nil
        -- AnimState:GetHistoryData is an unreliable function that should only
        -- be used in dev environments. DO NOT use it in the game code.
        bank, anim = t.AnimState:GetHistoryData()
    end

    return anim
end

local function Scrapbook_GetSanityAura(inst)
    local sanity = inst.components.sanityaura.aura

    if inst.components.sanityaura.aurafn then
        sanity = inst.components.sanityaura.aurafn(inst, ThePlayer)
    end

    return sanity ~= 0 and sanity or nil
end

local function Scrapbook_GetSkillOwner(skill)
    local skilldefs = require("prefabs/skilltree_defs").SKILLTREE_DEFS

    for character, skills in pairs(skilldefs) do
        for name, def in pairs(skills) do
            if skill == name then
                return character
            end
        end
    end
end

--[[
    Manual information available to insert into prefabs:

        scrapbook_adddeps: Add dependencies (string array).
        scrapbook_anim: Anim to play (string).
        scrapbook_animoffsetx: Image position X offset (number).
        scrapbook_animoffsety: Image position Y offset (number).
        scrapbook_animoffsetbgx: Image background position X offset (number).
        scrapbook_animoffsetbgy: Image background position Y offset (number).
        scrapbook_animpercent: Animation percent (number).
        scrapbook_areadamage: Area damage (number).
        scrapbook_bank: Overrides bank (string).
        scrapbook_build: Overrides build (string).
        scrapbook_overridebuild: Build override (string).
        scrapbook_damage: Damage, for creatures (number, string or array with 2 numbers (value range)).
        scrapbook_deps: Overrides default prefab dependencies (string array).
        scrapbook_fueled_max: Overrides components.fueled.maxfuel (number).
        scrapbook_healthvalue: Health food value (number).
        scrapbook_hide: Layers to hide (string array).
        scrapbook_hidehealth: Hide health data (boolean).
        scrapbook_hidesymbol: Symbols to hide (string array).
        scrapbook_hungervalue: Hunger food value (number).
        scrapbook_maxhealth: Override health data (number, string or array with 2 numbers (value range)).
        scrapbook_nodamage: Hide weapon data (damage, planar damage, range) (boolean).
        scrapbook_overridedata: String array or string arrays of symbol override (symbol, build, symbol_in_build).
        scrapbook_persishable: Overrides components.perishable.perishtime (number).
        scrapbook_planardamage: Planar damage, for creatures and weapons (number).
        scrapbook_prefab: Used by "prefab" and "name" entries (string).
        scrapbook_removedeps: Remove dependencies (string array).
        scrapbook_sanityaura: Sanity Aura (number).
        scrapbook_sanityvalue: Sanity food value (number).
        scrapbook_scale: Scale (number).
        scrapbook_specialinfo: Entry in STRINGS.SCRAPBOOK.SPECIALINFO (string).
        scrapbook_speechname: Entry in STRINGS.CHARACTERS.GENERIC.DESCRIBE (string).
        scrapbook_subcat: Sub-Category (string).
        scrapbook_tex: Icon texture (without .tex) (string).
        scrapbook_thingtype: Category (string).
        scrapbook_weapondamage: Damage, for weapons (number, string or array with 2 numbers (value range)).
        scrapbook_weaponrange: Hit range (number).
        scrapbook_workable: Overrides components.workable.action (action).
        scrapbook_alpha: AnimState alpha (number: 0-1).
        scrapbook_facing: Determines a facing (number: FACING_RIGHT, FACING_UPRIGHT...)
]]

local SKIP_SPECIALINFO_CHECK =
{
    WATERINGCAN = true,
    BUNDLEWRAP = true,
    MUSHROOMSPROUT = true,
    DUMBBELL = true,
    BUNDLE = true,
}

-- NOTES(DiogoW): There is no need to recreate this every time d_createscrapbookdata() is called.
-- Use d_printscrapbookrepairmaterialsdata() to update.
local REPAIR_MATERIAL_DATA =
{
    -- Repairers
    dreadstone = { "wall_dreadstone_item", "dreadstone" },
    fossil = { "fossil_piece" },
    gears = { "wall_scrap_item", "wagpunk_bits", "gears" },
    gem = { "opalpreciousgem", "yellowgem", "redgem", "greengem", "bluegem", "purplegem", "orangegem" },
    hay = { "cutgrass", "wall_hay_item" },
    ice = { "ice" },
    kelp = { "boatpatch_kelp", "kelp" },
    moon_altar = { "moon_altar_icon", "moon_altar_crown", "moon_altar_seed", "moon_altar_glass", "moon_altar_idol", "moon_altar_ward" },
    moonrock = { "moonrockcrater", "wall_moonrock_item", "moonrocknugget" },
    nightmare = { "nightmarefuel", "horrorfuel" },
    salt = { "saltrock" },
    sculpture = { "sculpture_bishophead", "sculpture_rooknose", "sculpture_knighthead" },
    shell = { "slurtle_shellpieces" },
    stone = { "cutstone", "wall_stone_item", "rocks" },
    thulecite = { "thulecite_pieces", "thulecite", "wall_ruins_item" },
    vitae = { "mosquitosack" },
    wood = { "boatpatch", "treegrowthsolution", "wall_wood_item", "driftwood_log", "livinglog", "twigs", "log", "boards" },

    -- Repair Kits
    lunarplant = { "lunarplant_kit" },
    voidcloth = { "voidcloth_kit" },
    wagpunk_bits = { "wagpunkbits_kit" },

    -- Upgraders
    chest = { "chestupgrade_stacksize" },
    mast = { "mastupgrade_lamp_item", "mastupgrade_lightningrod_item" },
    spear_lightning = { "moonstorm_static_item" },
    spider = { "silk" },
    waterplant = { "waterplant_planter" },
}

function d_printscrapbookrepairmaterialsdata()
    local repair_data = {}
    local forgerepair_data = {}
    local upgrader_data = {}

    for entry, _ in pairs(scrapbookprefabs) do
        local t = SpawnPrefab(entry)

        local material = t.components.repairer ~= nil and t.components.repairer.repairmaterial or nil

        if material ~= nil then
            repair_data[material] = repair_data[material] or {}
            
            table.insert(repair_data[material], t.scrapbook_prefab or entry)
        end

        local forge_material = t.components.forgerepair ~= nil and t.components.forgerepair.repairmaterial or nil

        if forge_material ~= nil then
            forgerepair_data[forge_material] = forgerepair_data[forge_material] or {}
            
            table.insert(forgerepair_data[forge_material], t.scrapbook_prefab or entry)
        end

        local upgradetype = t.components.upgrader ~= nil and t.components.upgrader.upgradetype or nil

        if upgradetype ~= nil then
            upgrader_data[upgradetype] = upgrader_data[upgradetype] or {}
            
            table.insert(upgrader_data[upgradetype], t.scrapbook_prefab or entry)
        end

        t:Remove()
    end

    local str = {}

    table.insert(str, "\n    -- Repairers")
    for _, material, prefabs in sorted_pairs(repair_data) do
        table.insert(str, string.format('    %s = { "%s" },', material, table.concat(prefabs, '", "')))
    end

    table.insert(str, "\n    -- Repair Kits")
    for _, material, prefabs in sorted_pairs(forgerepair_data) do
        table.insert(str, string.format('    %s = { "%s" },', material, table.concat(prefabs, '", "')))
    end

    table.insert(str, "\n    -- Upgraders")
    for _, type, prefabs in sorted_pairs(upgrader_data) do
        table.insert(str, string.format('    %s = { "%s" },', type, table.concat(prefabs, '", "')))
    end

    print("\n"..table.concat(str, "\n").."\n")
end

local prettyline = "\n_________________________________________\n"

local scrapbook_finiteuses_useamount_modifiers =
{
    "followerherder",
    "repellent",
    "bedazzler",
}

local TechTree = require("techtree")

local NOT_ALLOWED_RECIPE_TECH =
{
    [TechTree.Create(TECH.PERDOFFERING_THREE)] = true,
    [TechTree.Create(TECH.WARGOFFERING_THREE)] = true,
    [TechTree.Create(TECH.PIGOFFERING_THREE)] = true,
    [TechTree.Create(TECH.CARRATOFFERING_THREE)] = true,
    [TechTree.Create(TECH.BEEFOFFERING_THREE)] = true,
    [TechTree.Create(TECH.CATCOONOFFERING_THREE)] = true,
    [TechTree.Create(TECH.RABBITOFFERING_THREE)] = true,
    [TechTree.Create(TECH.DRAGONOFFERING_THREE)] = true,

    [TechTree.Create(TECH.YOTG)] = true,
    [TechTree.Create(TECH.YOTV)] = true,
    [TechTree.Create(TECH.YOTP)] = true,
    [TechTree.Create(TECH.YOTC)] = true,
    [TechTree.Create(TECH.YOTB)] = true,
    [TechTree.Create(TECH.YOT_CATCOON)] = true,
    [TechTree.Create(TECH.YOTR)] = true,
    [TechTree.Create(TECH.YOTD)] = true,
}

function d_createscrapbookdata(print_missing_icons, noreset)
    if not TheWorld.state.isautumn or TheWorld.state.israining then
        -- Force the season (many entities change the build/animation during certain seasons).
        TheWorld:PushEvent("ms_setseason", "autumn")

        -- Stop rain (many entities change the build/animation during rain).
        TheWorld:PushEvent("ms_forceprecipitation", false)

        -- Push events and then rerun the command!
        scheduler:ExecuteInTime(0.05, ExecuteConsoleCommand, nil, string.format("d_createscrapbookdata(%s)", tostring(print_missing_icons or "")))
        return
    end

    c_sethealth(1)
    c_setsanity(1)
    c_sethunger(1)
    c_settemperature(25)
    c_setmoisture(0)

    local _specialevent = WORLD_SPECIAL_EVENT
    WORLD_SPECIAL_EVENT = SPECIAL_EVENTS.NONE

    print(prettyline)
    print("SCRAPBOOK DATA - WARNINGS!\n")

    local icons_missing = {}
    local specialinfo_list = {}
    local scrapbookdata = {}
    local currententry = nil

    local AddInfo = function(...) Scrapbook_AddInfo(scrapbookdata[currententry], ...) end

    local exporter_data_helper = io.open("scripts/scrapbookdata_no_package.lua", "w")
    exporter_data_helper:write("-- AUTOGENERATED FROM d_createscrapbookdata()\n")
    exporter_data_helper:write("return {\n")

    for entry, _ in pairs(scrapbookprefabs) do
        if scrapbookdata[entry] ~= nil then
            print(string.format("Duplicate scrapbook entry [ %s ] in scripts/scrapbook_prefabs.lua.", entry))
            return
        end

        currententry = entry
        scrapbookdata[entry] = {}

        local t = SpawnPrefab(entry)

        if t == nil then
            print(string.format("[!!!!]  Aborting data creation command! Entry [ %s ] is not a valid prefab!", entry))
            return
        end

        if t.AnimState == nil then
            print(string.format("[!!!!]  Aborting data creation command! Entry [ %s ] doesn't have an AnimState component!", entry))
            return
        end

        if t:HasOneOfTags({"FX", "INLIMBO"}) then
            print(string.format("[!!!!]  Prefab [ %s ] has one of these tags [ FX, INLIMBO ] and therefore cannot be unlocked by the scrapbook update function (UpdateScrapbook - player_common_extensions.lua)", entry))
        end

        t.Transform:SetRotation(90)

        ---------------------------------::   NAME   ::---------------------------------

        local name = Scrapbook_DefineName(t)

        ---------------------------------::   SUB-CATEGORIES   ::---------------------------------

        local subcat = Scrapbook_DefineSubCategory(t)

        ---------------------------------::   TYPE   ::---------------------------------

        local thingtype = Scrapbook_DefineType(t, entry)

        ---------------------------------::   ANIMATION   ::---------------------------------

        if t.sg and t.sg:HasState("idle") then
            t.sg:GoToState("idle")
        end

        local anim = Scrapbook_DefineAnimation(t)

        ---------------------------------::   TEX   ::---------------------------------

        local tex = (t.scrapbook_tex or (t.components.inventoryitem ~= nil and t.components.inventoryitem.imagename) or entry)..".tex"

        if thingtype == "item" or thingtype == "food" then
            if not GetInventoryItemAtlas(tex) then
                print(string.format("[!!!!]  Atlas for texture [ %s ] not found in inventoryimagesX!", tex))
            end
        else
            if not GetScrapbookIconAtlas(tex) then
                if print_missing_icons then
                    local file = t.scrapbook_build or t.AnimState:GetBuild()
                    local icon = t.scrapbook_tex or entry
                    local hide = t.scrapbook_hide ~= nil and table.concat(t.scrapbook_hide, '", "') or nil
                    
                    table.insert(icons_missing, { icon=icon, file=file, anim=anim, hide=hide })
                else
                    print(string.format("[!!!!]  Atlas for texture [ %s ] not found in scrapbook_iconsX!", tex))
                end
            end
        end

        -- NOTES(JBK): The hash is redundant data and is only here to aid the exporter for backend services.
        -- So we will save it to a file that does not get loaded for the game.
        exporter_data_helper:write(string.format("[\"%s\"] = 0x%X,\n", entry, hash(entry)))

        AddInfo( "name", name )
        AddInfo( "tex", tex )
        AddInfo( "subcat", subcat )
        AddInfo( "type", thingtype )
        AddInfo( "prefab", t.scrapbook_prefab or entry )

        ---------------------------------::   SPEECHNAME   ::---------------------------------

        local speechname = t.scrapbook_speechname or t.nameoverride or (t.components.inspectable ~= nil and t.components.inspectable.nameoverride) or nil
        if speechname ~= nil and string.upper(speechname) ~= string.upper(entry) then
            AddInfo( "speechname", speechname )
        end

        if t.scrapbook_speechname ~= nil and string.lower(t.scrapbook_speechname) == string.lower(entry) then
            print(string.format("[!!!!]  inst.scrapbook_speechname = %s is unecessary in entry [ %s ]!", t.scrapbook_speechname, entry))
        end

        if t.scrapbook_speechname ~= nil and not STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(t.scrapbook_speechname)] then
            print(string.format("[!!!!]  Speech Name [ %s ] isn't defined in STRINGS.CHARACTERS.GENERIC.DESCRIBE!", t.scrapbook_speechname))
        end

        if t.scrapbook_inspectonseen == nil and
            t.components.inspectable == nil and
            t.components.health == nil and
            t.prefab ~= "archive_switch_base"
        then
            print(string.format("[!!!!] [ %s ] cannot be inspected! Please add \"inst.scrapbook_inspectonseen = true\" to the prefab (common).", entry))
        end

        ---------------------------------::   SANITY   ::---------------------------------

        if t.scrapbook_sanityaura then
            AddInfo( "sanityaura", t.scrapbook_sanityaura )

        elseif t.components.sanityaura and Scrapbook_GetSanityAura(t) then
            AddInfo( "sanityaura", Scrapbook_GetSanityAura(t) )
        end

        ---------------------------------::   HEALTH   ::---------------------------------

        local maxhealth = not t.scrapbook_hidehealth and (t.scrapbook_maxhealth or (t.components.health ~= nil and t.components.health.maxhealth)) or nil
        if maxhealth ~= nil then
            if type(maxhealth) == "table" then
                maxhealth = string.format("%d-%d", maxhealth[1], maxhealth[2])
            end

            AddInfo( "health", maxhealth )
        end

        ---------------------------------::   DAMAGE   ::---------------------------------

        local damage = t.scrapbook_damage or (t.components.combat ~= nil and t.components.combat.defaultdamage) or nil
        if damage ~= nil then
            if type(damage) == "table" then
                local mod = not t.scrapbook_ignoreplayerdamagemod and t.components.combat ~= nil and t.components.combat.playerdamagepercent or 1
                damage = string.format("%d-%d", damage[1]*mod , damage[2]*mod)
            end

            if checkstring(damage) or damage > 0 then
                AddInfo( "damage", (checkstring(damage) or t.scrapbook_damage) and damage or damage * (t.components.combat.playerdamagepercent or 1) )
            end
        end

        local planardamage = t.scrapbook_planardamage or (t.components.planardamage ~= nil and t.components.planardamage.basedamage) or nil
        if planardamage ~= nil and planardamage > 0 then
            AddInfo( "planardamage", planardamage )
        end

        AddInfo( "areadamage", t.scrapbook_areadamage )

        ---------------------------------::   STACK   ::---------------------------------

        if t.components.stackable  then
            local stacksize = t.prefab == "wortox_soul" and TUNING.WORTOX_MAX_SOULS or t.components.stackable.maxsize

            AddInfo( "stacksize", stacksize )
        end

        ---------------------------------::   FOOD   ::---------------------------------

        if t.components.edible  then
            AddInfo( "hungervalue", t.scrapbook_hungervalue or t.components.edible.hungervalue )
            AddInfo( "healthvalue", t.scrapbook_healthvalue or t.components.edible.healthvalue )
            AddInfo( "sanityvalue", t.scrapbook_sanityvalue or t.components.edible.sanityvalue )
        end

        if t.components.edible and t.components.edible.foodtype  then
            AddInfo( "foodtype",   t.components.edible.foodtype )

            if not STRINGS.SCRAPBOOK.FOODTYPE[t.components.edible.foodtype] then
                print(string.format("[!!!!]  Food Type [ %s ] isn't defined in STRINGS.SCRAPBOOK.FOODTYPE!", t.components.edible.foodtype))
            end
        end

        ---------------------------------::   WEAPON   ::---------------------------------

        if (t.components.weapon or t.scrapbook_weapondamage) and not t.scrapbook_nodamage then
            if t.prefab == "bomb_lunarplant" then
                AddInfo( "weapondamage", t.components.weapon.damage )
                AddInfo( "planardamage", TUNING.BOMB_LUNARPLANT_PLANAR_DAMAGE )
                AddInfo( "weaponrange",  t.components.weapon.hitrange )
            else
                if t.scrapbook_weapondamage or (t.components.weapon and t.components.weapon.damage) then

                    local weapondamage = t.scrapbook_weapondamage

                    if type(weapondamage) == "table" then
                        weapondamage = string.format("%d-%d", weapondamage[1] , weapondamage[2])
                    end

                    if not weapondamage and type(t.components.weapon.damage) == "function" then
                        print(string.format(">> Prefab [ %s ] has a function defined for components.weapon.damage!", t.prefab))

                    else
                        if not weapondamage and t.components.weapon.damage then
                            weapondamage = t.components.weapon.damage
                        end
                        AddInfo( "weapondamage", weapondamage )
                    end
                end

                local hitrange = t.scrapbook_weaponrange or (t.components.weapon ~= nil and t.components.weapon.hitrange) or nil
                if hitrange ~= nil then
                    AddInfo( "weaponrange", hitrange )
                end
            end
        end

        ---------------------------------::   ARMOR   ::---------------------------------

        if t.components.armor then
            AddInfo( "armor", t.components.armor.maxcondition )
            AddInfo( "absorb_percent", t.components.armor.absorb_percent )

            if t.components.planardefense and t.components.planardefense.basedefense > 0 then
                AddInfo( "armor_planardefense", t.components.planardefense.basedefense )
            end
        end

        ---------------------------------::   TOOL   ::---------------------------------

        if t.components.finiteuses  then
            -- FIXME(JBK): This is a bad assumption for tools that have multiple uses with different use rates but will fix up most cases.
            local count = 0
            for _ in pairs(t.components.finiteuses.consumption) do
                count = count + 1
            end

            local rate = 1
            if count == 1 then -- Only apply the modifier for if there is one consumer type.
                local k, v = next(t.components.finiteuses.consumption)
                rate = v
            end

            for _, cmpname in ipairs(scrapbook_finiteuses_useamount_modifiers) do
                if t.components[cmpname] ~= nil then
                    rate = t.components[cmpname].use_amount or rate
                    break
                end
            end

            AddInfo( "finiteuses", (t.components.finiteuses.total / rate) )
        end

        local _forgerepairmaterial = t.components.forgerepairable ~= nil and t.components.forgerepairable.repairmaterial or nil

        if _forgerepairmaterial ~= nil and REPAIR_MATERIAL_DATA[_forgerepairmaterial] ~= nil then
            AddInfo( "forgerepairable", REPAIR_MATERIAL_DATA[_forgerepairmaterial] )
        end

        local _repairmaterial = t.components.repairable ~= nil and t.components.repairable.repairmaterial or nil
        if _repairmaterial and REPAIR_MATERIAL_DATA[_repairmaterial] ~= nil then
            if not t.components.repairable.checkmaterialfn then
                AddInfo( "repairitems", REPAIR_MATERIAL_DATA[_repairmaterial] )

            else
                local valid_materials = {}

                for i, mat in ipairs(REPAIR_MATERIAL_DATA[_repairmaterial]) do
                    local mat_inst = SpawnPrefab(mat)
                    
                    if mat_inst ~= nil and t.components.repairable.checkmaterialfn(t, mat_inst) then
                        table.insert(valid_materials, mat)
                    end
                    
                    if mat_inst ~= nil then
                        mat_inst:Remove()
                    end
                end

                AddInfo( "repairitems", valid_materials )
            end
        end

        if t.components.tool ~= nil then
            local actions = {}
            for action, _ in pairs(t.components.tool.actions) do
                table.insert(actions, action.id)
            end
            table.sort(actions)
            AddInfo( "toolactions", actions )
        end

        ---------------------------------::   BUILD   ::---------------------------------

        AddInfo( "scale", t.scrapbook_scale )
        AddInfo( "animpercent", t.scrapbook_animpercent ~= nil and math.clamp(t.scrapbook_animpercent, 0, 1) or nil)
        AddInfo( "overridebuild", t.scrapbook_overridebuild )
        AddInfo( "hide", t.scrapbook_hide )
        AddInfo( "hidesymbol", t.scrapbook_hidesymbol )

        -- AnimState:GetCurrentBankName is an unreliable function that should only
        -- be used in dev environments. DO NOT use it in the game code.
        AddInfo( "build", t.scrapbook_build or t.AnimState:GetBuild() )
        AddInfo( "bank",  t.scrapbook_bank or t.AnimState:GetCurrentBankName() ) --see comments above
        AddInfo( "anim",  anim )

        AddInfo( "facing", t.scrapbook_facing )

        AddInfo( "multcolour", t.scrapbook_multcolour )
        AddInfo( "alpha", t.scrapbook_alpha )

        if t.scrapbook_overridedata then
            if type(t.scrapbook_overridedata[1]) ~= "table" then
                AddInfo( "overridesymbol", t.scrapbook_overridedata )
            else
                local overrides = {}

                for _, tbl in ipairs(t.scrapbook_overridedata) do
                    table.insert(overrides, string.format('{"%s"}', table.concat(tbl, '", "')))
                end

                AddInfo( "overridesymbol", string.format("{%s}", table.concat(overrides, ", ")))
            end

        elseif t:HasTag("campfire") and entry ~= "cotl_tabernacle_level3" then
            local blueflame = t:HasTag("blueflame")

            local override = {
                "flames_wide",                                      -- Campfire Symbol.
                blueflame and "coldfire_fire"   or "campfire_fire", -- Fire Build.
                blueflame and "coldflames_wide" or "flames_wide",   -- Fire Symbol.
            }

            AddInfo( "overridesymbol", override)
        end

        -- TODO(DiogoW): Refactor this.

        if t.prefab == "robin" then
            AddInfo( "animoffsety",  -8 )
        end
        if t.prefab == "robin_winter" then
            AddInfo( "animoffsety",  -15 )
            AddInfo( "animoffsetbgy",  15 )
        end
        if t.prefab == "friendlyfruitfly" then
            AddInfo( "animoffsety",  65 )
        end
        if t.prefab == "fruitfly" then
            AddInfo( "animoffsety",  65 )
        end
        -------------------
        if t.prefab == "minotaur" then
            AddInfo( "animoffsetx",  5 )
        end
        if t.prefab == "lordfruitfly" then
            AddInfo( "animoffsety",  70 )
        end
        if t.prefab == "moonbutterfly" then
            AddInfo( "animoffsetx",  15 )
        end
        if t.prefab == "bee" then
            AddInfo( "animoffsety",  150 )
        end
        if t.prefab == "killerbee" then
            AddInfo( "animoffsety",  150 )
        end
        if t.prefab == "lightflier" then
            AddInfo( "animoffsety",  70 )
        end
        if t.prefab == "beeguard" then
            AddInfo( "animoffsety",  100 )
        end
        if t.prefab == "mosquito" then
            AddInfo( "animoffsety",  100 )
            AddInfo( "animoffsetx",  -20 )
        end
        if t.prefab == "moon_altar_seed" then
            AddInfo( "animoffsety",  20 )
            AddInfo( "animoffsetx",  25 )
        end
        if t.prefab == "moon_altar_glass" then
            AddInfo( "animoffsety",  20 )
            AddInfo( "animoffsetx",  25 )
        end
        if t.prefab == "moon_altar_icon" then
            AddInfo( "animoffsety",  25 )
            AddInfo( "animoffsetx",  25 )
        end
        if t.prefab == "moon_altar_ward" then
            AddInfo( "animoffsety",  20 )
            AddInfo( "animoffsetx",  25 )
        end
        if t.prefab == "moon_altar_crown" then
            AddInfo( "animoffsety",  -20 )
            AddInfo( "animoffsetx",  25 )
            AddInfo( "animoffsetbgy",  30 )
        end
        if t.prefab == "shroomcake" then
            AddInfo( "animoffsety",  -20 )
            AddInfo( "animoffsetbgy",  25 )
        end
        if t.prefab == "vegstinger" then
            AddInfo( "animoffsety",  -10 )
        end
        if t.prefab == "watermelon_oversized" then
            AddInfo( "animoffsety",  -20 )
            AddInfo( "animoffsetbgy",  30 )
        end
        if t.prefab == "saddle_war" then
            AddInfo( "animoffsety",  -20 )
            AddInfo( "animoffsetbgy",  30 )
        end
        if t.prefab == "bunnyman" then
            AddInfo( "animoffsetx",  20 )
        end
        if t.prefab == "bernie_active" then
            AddInfo( "animoffsety",  60 )
            AddInfo( "animoffsetbgy",  -50 )
        end
        if t.prefab == "lightcrab" then
            AddInfo( "animoffsety",  60 )
            AddInfo( "animoffsetbgy",  -50 )
        end
        if t.prefab == "fused_shadeling_bomb" then
            AddInfo( "animoffsety",  60 )
            AddInfo( "animoffsetbgy",  -50 )
        end
        if t.prefab == "smallghost" then
            AddInfo( "animoffsety",  60 )
        end
        if t.prefab == "wx78_scanner_item" then
            AddInfo( "animoffsety",  90 )
        end
        if t.prefab == "eyeofterror_mini" then
            AddInfo( "animoffsety",  40 )
        end
        if t.prefab == "bananajuice" then
            AddInfo( "animoffsety",  -20 )
        end

        AddInfo( "animoffsetx",  t.scrapbook_animoffsetx )
        AddInfo( "animoffsety",  t.scrapbook_animoffsety )
        
        AddInfo( "animoffsetbgx",  t.scrapbook_animoffsetbgx )
        AddInfo( "animoffsetbgy",  t.scrapbook_animoffsetbgy )

        ---------------------------------::   WATERPROOFER   ::---------------------------------

        if t.components.waterproofer and t.components.waterproofer:GetEffectiveness() > 0 then
            AddInfo( "waterproofer",  t.components.waterproofer:GetEffectiveness() )
        end

        ---------------------------------::   INSULATOR   ::---------------------------------

        if t.components.insulator then
            AddInfo( "insulator", t.components.insulator:GetInsulation() )
            AddInfo( "insulator_type", t.components.insulator.type )
        end

        ---------------------------------::   DAPPERNESS   ::---------------------------------

        if t.components.equippable and t.components.equippable.dapperness ~= 0 then
            AddInfo( "dapperness",  t.components.equippable.dapperness )
        end

        ---------------------------------::   FUELED   ::---------------------------------

        if t.components.fueled then
            AddInfo( "fueledmax",    t.scrapbook_fueled_max or t.components.fueled.maxfuel  )
            AddInfo( "fueledrate",   t.scrapbook_fueled_rate or t.components.fueled.rate    )
            AddInfo( "fueledtype1",  t.components.fueled.fueltype )
            AddInfo( "fueleduses",   t.scrapbook_fueled_uses )

            if t.components.fueled.secondaryfueltype then
                AddInfo( "fueledtype2",  t.components.fueled.secondaryfueltype )
            end
        end

        local fueled = t.components.fueled
        if fueled ~= nil and (fueled.fueltype == FUELTYPE.USAGE or fueled.secondaryfueltype == FUELTYPE.USAGE) and not fueled.no_sewing then
            AddInfo( "sewable", true )
        end

        ---------------------------------::   FUEL   ::---------------------------------

        if t.components.fuel and t.components.inventoryitem then
            AddInfo( "fueltype",  t.components.fuel.fueltype )
            AddInfo( "fuelvalue",  t.components.fuel.fuelvalue )
        end

        if t:HasTag("lightbattery") then
            AddInfo( "lightbattery", true )
        end

        ---------------------------------::   PERISHABLE   ::---------------------------------

        if t.scrapbook_persishable then
            AddInfo( "perishable",  t.scrapbook_persishable )
        elseif t.components.perishable then
            AddInfo( "perishable",  t.components.perishable.perishtime )
        end

        ---------------------------------::   OAR   ::---------------------------------

        if t.components.oar then
            AddInfo( "oar_force",  t.components.oar.force )
            AddInfo( "oar_velocity",  t.components.oar.max_velocity )
        end

        ---------------------------------::   TACKLE   ::---------------------------------

        if t.components.oceanfishingtackle ~= nil then
            if t.components.oceanfishingtackle.casting_data then
                AddInfo( "float_range", t.components.oceanfishingtackle.casting_data.dist_max + 5)
                AddInfo( "float_accuracy", t.components.oceanfishingtackle.casting_data.dist_min_accuracy)
            end
            if t.components.oceanfishingtackle.lure_data then
                AddInfo( "lure_charm", t.components.oceanfishingtackle.lure_data.charm)
                AddInfo( "lure_dist", t.components.oceanfishingtackle.lure_data.dist_max)
                AddInfo( "lure_radius", t.components.oceanfishingtackle.lure_data.radius)
            end
        end

        ---------------------------------::   WORKABLE   ::---------------------------------

        if t.scrapbook_workable then
            AddInfo( "workable",  t.scrapbook_workable.id )
        elseif t.components.workable and t.components.workable.action and t.components.workable.workleft > 0 then
            AddInfo( "workable",  t.components.workable.action.id )
        end

        ---------------------------------::   PICKABLE   ::---------------------------------

        if t.components.pickable then
            AddInfo( "pickable", true )
        end

        ---------------------------------::   HARVESTABLE   ::---------------------------------

        if t.components.harvestable then
            AddInfo( "harvestable", true )
        end

        ---------------------------------::   STEWER   ::---------------------------------

        if t.components.stewer then
            AddInfo( "stewer", true )
        end

        ---------------------------------::   ACTIVATABLE   ::---------------------------------

        if t.components.activatable ~= nil and t.GetActivateVerb ~= nil then
            AddInfo( "activatable", t:GetActivateVerb(ThePlayer) )
        end

        ---------------------------------::   FISHABLE   ::---------------------------------

        if t.components.fishable then
            AddInfo( "fishable", true )
        end

        ---------------------------------::   BURNABLE   ::---------------------------------

        if t.components.burnable ~= nil and
            not t.components.burnable.ignorefuel and
            t.components.burnable.canlight and
            not table.contains({"creature", "giant"}, thingtype)
        then
            AddInfo( "burnable", true )
        end

        -----------------------------::   OBSTACLE FLOATER   ::------------------------------

        local _floater = t.components.floater
        if _floater ~= nil and _floater.bob_percent == 0 then
            AddInfo( "floater", {_floater.size, _floater.vert_offset or 0, _floater.xscale, _floater.yscale} )
        end

        ---------------------------------::   DEPENDENCIES   ::---------------------------------

        local _deps = t.scrapbook_deps or shallowcopy(Prefabs[entry].deps)

        local deps = {}

        for i, dep in ipairs(_deps) do
            deps[dep] = true
        end

        if t.components.prototyper and t.prefab ~= "bookstation" then

            for recipe, recipedata in pairs(AllRecipes) do
                local found = false
                for tech,level in pairs(recipedata.level) do
                    if level > 0 then
                        for tree, num in pairs(t.components.prototyper.trees) do
                            if tech == tree and num >= level then
                                deps[tostring(recipe)] = true
                                found = true
                                break
                            end
                        end
                        if found then
                            break
                        end
                    end
                end
            end
        end
        
        local statue_sketch = AllRecipes[entry.."_sketch"]
        if statue_sketch ~= nil and NOT_ALLOWED_RECIPE_TECH[statue_sketch.level] then
            print(string.format("[!!!!] [ %s ] sketch is only available during a specific Chinese new year... So the statue don't go into the scrapbook.", entry))
        end

        local recipe = AllRecipes[t.prefab]

        if recipe ~= nil then
            if NOT_ALLOWED_RECIPE_TECH[recipe.level] then
                print(string.format("[!!!!] [ %s ] is from a Chinese New Year event... These don't go into the scrapbook.", entry))
            end

            if recipe.builder_tag or recipe.builder_skill then
                ------  CRAFTING ICON  ------
                local character = RECIPE_BUILDER_TAG_LOOKUP[recipe.builder_tag] or Scrapbook_GetSkillOwner(recipe.builder_skill)

                if character ~= nil then
                    AddInfo( "craftingprefab", character )
                else
                    print(string.format("[!!!!]  Recipe builder tag/skill [ %s ] isn't in RECIPE_BUILDER_TAG_LOOKUP or isn't a skilltree skill...", recipe.builder_tag))
                end
            end

            for _, data in ipairs(recipe.ingredients) do
                deps[data.type] = true
            end
        end

        -- Loot.
        if t.components.lootdropper ~= nil then
            for dep, _ in pairs(t.components.lootdropper:GetAllPossibleLoot(true)) do
                deps[dep] = true
            end
        end

        if t.components.erasablepaper ~= nil then
            deps[t.components.erasablepaper.erased_prefab] = true
        end

        -- Deployable / Kits.
        local item_prefab = entry.."_item"
        if scrapbookprefabs[item_prefab] then
            deps[item_prefab] = true
        end

        local kit_prefab = entry.."_kit"
        if scrapbookprefabs[kit_prefab] then
            deps[kit_prefab] = true
        end

        local _perishable = t.components.perishable
        if _perishable ~= nil and _perishable.onperishreplacement ~= nil then
            deps[_perishable.onperishreplacement] = true
        end

        -- Spawners.
        local _childspawner = t.components.childspawner
        if _childspawner ~= nil then
            if _childspawner.childname ~= "" then
                deps[_childspawner.childname] = true

            end
            if _childspawner.rarechild ~= nil then
                deps[_childspawner.rarechild] = true
            end
        end

        local _spawner = t.components.spawner
        if _spawner ~= nil and _spawner.childname ~= nil then
            deps[_spawner.childname] = true
        end

        local _periodicspawner = t.components.periodicspawner
        if _periodicspawner ~= nil and _periodicspawner.prefab ~= nil then
            deps[_periodicspawner.prefab] = true
        end

        local product_components = { "pickable", "cookable", "dryable", "harvestable" }

        for i, cmpname in ipairs(product_components) do
            local _cmp = t.components[cmpname]
            if _cmp ~= nil then
                if _cmp.product ~= nil then
                    deps[_cmp.product] = true
                end
            end
        end

        if t.components.waxable ~= nil and not t.components.waxable:NeedsSpray() then
            deps.beeswax = true
        end

        -- Forge Repair Kits.
        if _forgerepairmaterial ~= nil and REPAIR_MATERIAL_DATA[_forgerepairmaterial] ~= nil then
            for i, mat in ipairs(REPAIR_MATERIAL_DATA[_forgerepairmaterial]) do
                deps[mat] = true
            end
        end

        -- Upgradeable: Upgrade types.
        local _upgradetype = t.components.upgradeable ~= nil and t.components.upgradeable.upgradetype or nil
        if _upgradetype ~= nil and REPAIR_MATERIAL_DATA[_upgradetype] ~= nil then
            for i, mat in ipairs(REPAIR_MATERIAL_DATA[_upgradetype]) do
                deps[mat] = true
            end
        end

        if t.scrapbook_adddeps then
            for i, dep in ipairs(t.scrapbook_adddeps) do
                if not table.contains(deps, dep) then
                    deps[dep] = true
                else
                    print(string.format("[!!!!]  Dependency [ %s ] is duplicated in entry [ %s ]...", dep, entry))
                end
            end
        end

        if t.scrapbook_removedeps then
            for i, dep in ipairs(t.scrapbook_removedeps) do
                deps[dep] = nil
            end
        end

        -- Remove itself if it exists.
        deps[entry] = nil

        for dep, _ in pairs(shallowcopy(deps)) do
            if checkstring(dep) and dep:find("_blueprint") then
                deps.blueprint = true
            end

            if checkstring(dep) and dep:find("_sketch") then
                deps.sketch = true
            end

            if not scrapbookprefabs[dep] then
                deps[dep] = nil
            end
        end

        if next(deps) ~= nil then
            deps = table.getkeys(deps)
            table.sort(deps)
            AddInfo( "deps", deps )
        end

        ---------------------------------::   NOTES   ::---------------------------------

        local notes = {} -- Array of strings.

        if t:HasTag("shadow_aligned") then
            table.insert(notes, "shadow_aligned=true")
        end

        if t:HasTag("lunar_aligned") then
            table.insert(notes, "lunar_aligned=true")
        end

        if next(notes) ~= nil then
            AddInfo( "notes", string.format("{%s}", table.concat(notes, ", ")) )
        end

        ---------------------------------::   SPECIAL INFO   ::---------------------------------

        if t.scrapbook_specialinfo ~= nil then
            local info = string.upper(t.scrapbook_specialinfo)

            if info ~= string.upper(t.scrapbook_prefab or entry) then
                AddInfo( "specialinfo", info)
                specialinfo_list[info] = true

                if not STRINGS.SCRAPBOOK.SPECIALINFO[info] then
                    print(string.format("[!!!!]  Special Information [ %s ] for entry [ %s ] isn't defined in STRINGS.SCRAPBOOK.SPECIALINFO!", info, entry))
                end
            elseif not SKIP_SPECIALINFO_CHECK[info] then
                print(string.format("[!!!!]  Special Information [ %s ] for entry [ %s ] isn't required, as it's the name of the prefab!", info, entry))
            end
        else
            specialinfo_list[string.upper(t.scrapbook_prefab or entry)] = true
        end

        ---------------------------------::   END   ::---------------------------------

        t:Remove()
    end

    for info, _ in pairs(STRINGS.SCRAPBOOK.SPECIALINFO) do
        if specialinfo_list[info] == nil then
            print(string.format("[!!!!]  Special Information [ %s ] is in STRINGS.SCRAPBOOK.SPECIALINFO, but it's unused!", info))
        end
    end

    if print_missing_icons then
        print("\n\nScrapbook Missing Icons:\n")
        local str = {}
        for i, data in ipairs(icons_missing) do
            table.insert(
                str,
                string.format(
                    "%s:\n    File: %s.fla\n    Anim: %s%s",
                    data.icon or "??",
                    data.file or "??",
                    data.anim or "??",
                    data.hide ~= nil and string.format("\n    Hide Layers: [ %s ]", data.hide) or ""
                )
            )
        end

        print("\n"..table.concat(str, "\n\n"))
    end

    Scrapbook_WriteToFile(scrapbookdata)

    WORLD_SPECIAL_EVENT = _specialevent

    exporter_data_helper:write("}\n")
    exporter_data_helper:close()

    print(prettyline)

    if not print_missing_icons and not noreset then
        d_unlockscrapbook()
        c_reset()
    end
end

function d_unlockscrapbook()
    TheScrapbookPartitions:DebugUnlockEverything()
end

function d_erasescrapbookentrydata(entry)
    if scrapbookprefabs[entry] == nil then
        print("!!!! Invalid scrapbook entry !!!!")

        return
    end

    TheScrapbookPartitions:UpdateStorageData(hash(entry), -1)
end

local WAXED_PLANTS = require "prefabs/waxed_plant_common"

function d_waxplant(plant)
    plant = plant or ConsoleWorldEntityUnderMouse()

    local wax = c_spawn("beeswax_spray")

    WAXED_PLANTS.WaxPlant(plant, nil, wax)

    wax:Remove()
end

local IGNORE_PATTERN_checkmissingscrapbookentries =
{
    "_FMT",
    "QUAGMIRE",
    "LAVAARENA",
    "SRAPBOOOK",
    "CARNIVAL",
    "_SKETCH",
    "_BUILDER",
    "YOTC",
    "YOTB",
    "_BLUEPRINT",
}

function d_checkmissingscrapbookentries()
    for key, string in pairs(STRINGS.NAMES) do
        local ok = true
        for i, pattern in ipairs(IGNORE_PATTERN_checkmissingscrapbookentries) do
            ok = key:find(pattern) == nil

            if not ok then
                break
            end
        end

        if ok and not scrapbookprefabs[string.lower(key)] then
            print(string.lower(key))
        end
    end
end

--------------------------------------------------------------------------------------------------------------------

-- Hash distribution checks for collisions.
local function _testhash(word, results)
    local collision = nil
    local hashed = hash(word)
    if results[hashed] then
        print("COLLISION", word, hashed)
        collision = true
    end
    results[hashed] = true
    return collision
end
local function _getbins(bitswanted, results)
    local mask = 2 ^ bitswanted - 1
    local bins = {}
    for i = 0, mask do
        bins[i + 1] = 0
    end
    for hashed, _ in pairs(results) do
        local v = bit.band(mask, hashed) + 1
        bins[v] = bins[v] + 1
    end
    return bins
end
local function _printbins(bins, total, collisions)
    local binsmax = #bins
    local highestdiff = -1
    for i = 1, binsmax do
        local v = bins[i]
        local diff = math.abs(100 - ((v * binsmax * 100) / total))
        if diff > highestdiff then
            highestdiff = diff
        end
        print(string.format("Bitmask %02X has %d words diff %.1f%%", i - 1, v, diff))
    end
    print(string.format("Avg: %.1f, Highest Diff: %.1f%%, Collisions: %d", total / binsmax, highestdiff, collisions))
end

function d_testhashes_random(bitswanted, tests)
    bitswanted = math.min(bitswanted or 4, 8)
    tests = tests or 10000

    local printables = {}
    for i = 0x20, 0x7E do -- ASCII
        printables[i - 0x20 + 1] = string.char(i)
    end
    local printableslen = #printables

    local results = {}
    local collisions = 0
    for test = 1, tests do
        local worddata = {}
        local len = math.random(6, 18)
        for l = 1, len do
            worddata[l] = printables[math.random(1, printableslen)]
        end
        local word = table.concat(worddata, "")
        if _testhash(word, results) then
            collisions = collisions + 1
        end
    end

    local bins = _getbins(bitswanted, results)
    _printbins(bins, tests, collisions)
end

function d_testhashes_prefabs(bitswanted)
    bitswanted = math.min(bitswanted or 4, 8)

    local results = {}
    local total = 0
    local collisions = 0
    for word, _ in pairs(Prefabs) do
        if _testhash(word, results) then
            collisions = collisions + 1
        end
        total = total + 1
    end

    local bins = _getbins(bitswanted, results)
    _printbins(bins, total, collisions)
end

function d_require(file)
    package.loaded[file] = nil
    require(file)
end

function d_mapstatistics(count_cutoff, item_cutoff, density_cutoff)
    count_cutoff = count_cutoff or 200
    item_cutoff = item_cutoff or 200
    density_cutoff = density_cutoff or 100
    local data = {}
    local density = {}
    local items = {}
    local itemsincontainers = 0
    for k, v in pairs(Ents) do
        data[v.prefab or "UNKNOWN"] = (data[v.prefab or "UNKNOWN"] or 0) + 1
        if v.Transform then
            local x, y, z = v.Transform:GetWorldPosition()
            local gx, gz = math.floor(x / TILE_SCALE), math.floor(z / TILE_SCALE)
            density[gx] = density[gx] or {}
            density[gx][gz] = (density[gx][gz] or 0) + 1
            if v.components.inventoryitem then
                items[v.prefab or "UNKNOWN"] = (items[v.prefab or "UNKNOWN"] or 0) + 1
                if v.components.inventoryitem.owner then
                    itemsincontainers = itemsincontainers + 1
                end
            end
            if v.components.unwrappable and v.components.unwrappable.itemdata then
                for _, v in ipairs(v.components.unwrappable.itemdata) do
                    items[v.prefab or "UNKNOWN"] = (items[v.prefab or "UNKNOWN"] or 0) + 1
                end
            end
        end
    end
    local sort = {}
    for k, v in pairs(data) do
        table.insert(sort, {prefab = k, count = v,})
    end
    local itemsort = {}
    for k, v in pairs(items) do
        table.insert(itemsort, {prefab = k, count = v,})
    end
    local function sorter(a, b)
        if a.count == b.count then
            return a.prefab < b.prefab
        end
        return a.count < b.count
    end
    table.sort(sort, sorter)
    table.sort(itemsort, sorter)
    print("------------------")
    print("- Map Statistics -")
    print("------------------")
    print("Most prefabs:")
    local total = 0
    for _, v in ipairs(sort) do
        if v.count >= count_cutoff then
            print(v.prefab, v.count)
        end
        total = total + v.count
    end
    print("- Total:", total)
    print("------------------")
    print("Most items:")
    total = 0
    for _, v in ipairs(itemsort) do
        if v.count >= item_cutoff then
            print(v.prefab, v.count)
        end
        total = total + v.count
    end
    print("- Total:", total)
    print("- In containers:", itemsincontainers)
    print("------------------")
    print("High density spots")
    total = 0
    for gx, gzd in pairs(density) do
        for gz, count in pairs(gzd) do
            if count >= density_cutoff then
                total = total + 1
                print(string.format("%.0f 0 %.0f", gx, gz))
            end
        end
    end
    print("- Total:", total)
    print("------------------")
end

local function _DamageListenerFn(inst, data)
    if data.damage ~= nil then
        inst._damage_count = inst._damage_count + data.damage
    end
end

function d_testdps(time, target)
    target = target or ConsoleWorldEntityUnderMouse()
    time = time or 5

    print(string.format("Starting DPS test for: %s, time: %2.2f", tostring(target), time))

    if target._dpstesttask ~= nil then
        target._dpstesttask:Cancel()
        target._dpstesttask = nil

        target:RemoveEventCallback("attacked", _DamageListenerFn)
    end

    target._damage_count = 0

    target:ListenForEvent("attacked", _DamageListenerFn)

    target._dpstesttask = target:DoTaskInTime(time, function(inst)
        print(string.format("DPS: %2.2f [%2.2f/%2.2f]", inst._damage_count/time, inst._damage_count, time))

        inst:RemoveEventCallback("attacked", _DamageListenerFn)
        inst._damage_count = nil
        inst._dpstesttask = nil
    end)
end

function d_timeddebugprefab(x, y, z, lifetime, prefab)
    lifetime = lifetime or 7
    prefab = prefab or "log"

    local debug_item = SpawnPrefab(prefab)
    debug_item.Transform:SetPosition(x, y, z)
    debug_item:DoTaskInTime(lifetime, debug_item.Remove)

    return debug_item -- In case you want to do a multcolour or anything else.
end

function d_prizepouch(prefab, nugget_count)
    nugget_count = nugget_count or 0
    prefab = prefab or "redpouch"

    local pouch = SpawnPrefab(prefab)
    if nugget_count > 0 then
        local prize_items = {}
        for _ = 1, nugget_count do
            table.insert(prize_items, SpawnPrefab("lucky_goldnugget"))
        end
        pouch.components.unwrappable:WrapItems(prize_items)
        for _, prize_item in ipairs(prize_items) do
            prize_item:Remove()
        end
    end

    pouch.Transform:SetPosition(ConsoleWorldPosition():Get())
end

function d_boatracepointers()
    local spawning_list = {}
    for _ = 1, 8 do
        table.insert(spawning_list, "boatrace_checkpoint_indicator")
    end

    local index_counter = 1
    d_spawnlist(spawning_list, 4, function(pointer)
        pointer._index = index_counter
        pointer.AnimState:OverrideSymbol("pointer_tail_art", "boatrace_checkpoint_indicator", "pointer_tail"..index_counter)
        index_counter = index_counter + 1
    end)
end

function d_testsound(soundpath, loopname, volume)
	local soundemitter =
		(c_sel() and c_sel().SoundEmitter) or
		(ThePlayer and ThePlayer.SoundEmitter) or
		(AllPlayers[1] and AllPlayers[1].SoundEmitter) or
		nil

	if soundemitter then
		soundemitter:PlaySound(soundpath, loopname, volume)
	end
end

function d_stopsound(loopname)
	local soundemitter =
		(c_sel() and c_sel().SoundEmitter) or
		(ThePlayer and ThePlayer.SoundEmitter) or
		(AllPlayers[1] and AllPlayers[1].SoundEmitter) or
		nil

	if soundemitter then
		soundemitter:KillSound(loopname)
	end
end

function d_spell(spellnum, item)
	item = item or c_sel()
	item.components.spellbook:SelectSpell(spellnum)
	item.components.spellbook.items[spellnum].execute(item)
end
