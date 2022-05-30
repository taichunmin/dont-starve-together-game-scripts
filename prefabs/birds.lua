--[[
birds.lua

Different birds are just reskins of crow without any special powers at the moment.
To make a new bird add it at the bottom of the file as a 'makebird(name)' call

This assumes the bird already has a build, inventory icon, sounds and a feather_name prefab exists, unless no_feather is set

]]--

local brain = require "brains/birdbrain"

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("flight")
end

local BIRD_TAGS = { "bird" }
local function OnAttacked(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, BIRD_TAGS)
    local num_friends = 0
    local maxnum = 5
    for k, v in pairs(ents) do
        if v ~= inst then
            v:PushEvent("gohome")
            num_friends = num_friends + 1
        end

        if num_friends > maxnum then
            return
        end
    end
end

local function OnTrapped(inst, data)
    if data and data.trapper and data.trapper.settrapsymbols then
        data.trapper.settrapsymbols(inst.trappedbuild)
    end
end

local function OnPutInInventory(inst)
    --Otherwise sleeper won't work if we're in a busy state
    inst.sg:GoToState("idle")
end

local function OnDropped(inst)
    inst.sg:GoToState("stunned")
end

local function ChooseItem()
    local mercy_items =
    {
        "flint",
        "flint",
        "flint",
        "twigs",
        "twigs",
        "cutgrass",
    }
    return mercy_items[math.random(#mercy_items)]
end

local function ChooseSeeds()
    return not TheWorld.state.iswinter and "seeds" or nil
end

local function SpawnPrefabChooser(inst)
    if TheWorld.state.cycles <= 3 then
        -- The item drop is for drop-in players, players from the start of the game have to forage like normal
        return ChooseSeeds()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, 20, true)

    -- Give item if only fresh players are nearby
    local oldestplayer = -1
    for i, player in ipairs(players) do
        if player.components.age ~= nil then
            local playerage = player.components.age:GetAgeInDays()
            if playerage > oldestplayer then
                oldestplayer = playerage
            end
        end
    end

    if oldestplayer >= 3 then
        local year = TheWorld.state.autumnlength + TheWorld.state.winterlength + TheWorld.state.springlength + TheWorld.state.summerlength
        if oldestplayer <= TheWorld.state.autumnlength then
            return ChooseSeeds()
        elseif oldestplayer <= year then
            return math.random() <= 0.8 and ChooseSeeds() or nil
        else
            return math.random() <= 0.6 and ChooseSeeds() or nil
        end
    end

    -- Lower chance for older players to get item
    return oldestplayer >= 0
        and math.random() < .35 - oldestplayer * .1
        and ChooseItem()
        or ChooseSeeds()
end

--------------------------------------------------------------------------

local function StopExhalingGas(inst)
    if inst._gasdowntask ~= nil then
        inst._gasdowntask:Cancel()
        inst._gasdowntask = nil
    end
end

local function OnExhaleGas(inst)
    if inst._gaslevel > 1 then
        inst._gaslevel = inst._gaslevel - 1
    else
        inst._gaslevel = 0
        StopExhalingGas(inst)
    end
end

local function StartExhalingGas(inst)
    if inst._gaslevel > 0 and inst._gasdowntask == nil then
        inst._gasdowntask = inst:DoPeriodicTask(TUNING.SEG_TIME, OnExhaleGas, TUNING.SEG_TIME * (.5 + math.random() * .5))
    end
end

local function TestGasLevel(inst, gaslevel)
    --Trigger with increasing chance from level 12 -> 24
    if gaslevel > 12 and math.random() * 12 < gaslevel - 12 then
        local cage = inst.components.occupier:GetOwner()
        if cage ~= nil and cage:HasTag("cage") then
            local data = { bird = inst, poisoned_prefab = "canary_poisoned" }
            TheWorld:PushEvent("birdpoisoned", data)
            cage:PushEvent("birdpoisoned", data)
        end
    end
end

local function OnInhaleGas(inst)
    if TheWorld.components.toadstoolspawner:IsEmittingGas() then
        inst._gaslevel = inst._gaslevel + 1
        TestGasLevel(inst, inst._gaslevel)
    elseif inst._gaslevel > 0 then
        inst._gaslevel = math.max(0, inst._gaslevel - 1)
    end
end

local function StopInhalingGas(inst)
    if inst._gasuptask ~= nil then
        inst._gasuptask:Cancel()
        inst._gasuptask = nil

        StartExhalingGas(inst)
    end
end

local function StartInhalingGas(inst)
    if inst._gasuptask == nil then
        inst._gasuptask = inst:DoPeriodicTask(TUNING.SEG_TIME, OnInhaleGas, TUNING.SEG_TIME * (.5 + math.random() * .5))

        StopExhalingGas(inst)
    end
end

local function OnCanaryOccupied(inst, cage)
    if cage ~= nil and cage:HasTag("cage") then
        StartInhalingGas(inst)
    else
        StopInhalingGas(inst)
    end
end

local function OnCanarySave(inst, data)
    data.gaslevel = inst._gaslevel > 0 and math.ceil(inst._gaslevel) or nil
end

local function OnCanaryLoad(inst, data)
    if data ~= nil and data.gaslevel ~= nil then
        inst._gaslevel = math.max(0, math.floor(data.gaslevel))
    end
end

--------------------------------------------------------------------------

local function makebird(name, soundname, no_feather, bank, custom_loot_setup, water_bank)
    local assets =
    {
        Asset("ANIM", "anim/crow.zip"),
        Asset("ANIM", "anim/"..name.."_build.zip"),
        Asset("SOUND", "sound/birds.fsb"),
    }

    if bank ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..bank..".zip"))
    end

    if water_bank ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..water_bank..".zip"))
    end

    local prefabs = name == "quagmire_pigeon" and
    {
        "quagmire_smallmeat",
        "quagmire_cookedsmallmeat",
    } or
    {
        "seeds",
        "smallmeat",
        "cookedsmallmeat",

        --mercy items
        "flint",
        "twigs",
        "cutgrass",
    }

	if not no_feather then
        table.insert(prefabs, "feather_"..name)
	end

    if name == "canary" then
        table.insert(prefabs, "canary_poisoned")
    end

	local soundbank = "dontstarve"
	if type(soundname) == "table" then
		soundbank = soundname.bank
		soundname = soundname.name
	end

    local function fn()
        local inst = CreateEntity()

        --Core components
        inst.entity:AddTransform()
        inst.entity:AddPhysics()
        inst.entity:AddAnimState()
        inst.entity:AddDynamicShadow()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        --Initialize physics
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        if water_bank ~= nil then
            -- Birds that float can pass through LIMITS walls, i.e. when hopping.
            inst.Physics:CollidesWith(COLLISION.GROUND)
        else
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end
        inst.Physics:SetMass(1)
        inst.Physics:SetSphere(1)

        inst:AddTag("bird")
        inst:AddTag(name)
        inst:AddTag("smallcreature")
        inst:AddTag("likewateroffducksback")
        inst:AddTag("stunnedbybomb")

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

        inst.Transform:SetTwoFaced()

        inst.AnimState:SetBank(bank or "crow")
        inst.AnimState:SetBuild(name.."_build")
        inst.AnimState:PlayAnimation("idle")

        inst.DynamicShadow:SetSize(1, .75)
        inst.DynamicShadow:Enable(false)

        MakeFeedableSmallLivestockPristine(inst)

        if water_bank ~= nil then
            MakeInventoryFloatable(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sounds =
        {
            takeoff = soundbank.."/birds/takeoff_"..soundname,
            chirp = soundbank.."/birds/chirp_"..soundname,
            flyin = "dontstarve/birds/flyin",
        }

        inst.trappedbuild = name.."_build"

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.locomotor:SetTriggersCreep(false)
        inst:SetStateGraph("SGbird")

        inst:AddComponent("lootdropper")
		if custom_loot_setup ~= nil then
			custom_loot_setup(inst, prefabs)
		else
			if not no_feather then
				inst.components.lootdropper:AddRandomLoot("feather_"..name, name == "canary" and .1 or 1)
			end
			inst.components.lootdropper:AddRandomLoot(name == "quagmire_pigeon" and "quagmire_smallmeat" or "smallmeat", 1)
			inst.components.lootdropper.numrandomloot = 1
		end

        inst:AddComponent("occupier")

        inst:AddComponent("eater")
        inst.components.eater:SetDiet({ FOODTYPE.SEEDS }, { FOODTYPE.SEEDS })

        inst:AddComponent("sleeper")
        inst.components.sleeper.watchlight = true
        inst.components.sleeper:SetSleepTest(ShouldSleep)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem.canbepickedupalive = true
        if water_bank == nil then
            inst.components.inventoryitem:SetSinks(true)
        end

        inst:AddComponent("cookable")
        inst.components.cookable.product = name == "quagmire_pigeon" and "quagmire_cookedsmallmeat" or "cookedsmallmeat"

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.BIRD_HEALTH)
        inst.components.health.murdersound = "dontstarve/wilson/hit_animal"

        inst:AddComponent("inspectable")

        if water_bank ~= nil then
            inst.flyawaydistance = TUNING.WATERBIRD_SEE_THREAT_DISTANCE
        else
            inst.flyawaydistance = TUNING.BIRD_SEE_THREAT_DISTANCE
        end

        if TheNet:GetServerGameMode() ~= "quagmire" then
            inst:AddComponent("combat")
            inst.components.combat.hiteffectsymbol = "crow_body"

            MakeSmallBurnableCharacter(inst, "crow_body")
            MakeTinyFreezableCharacter(inst, "crow_body")
        end

        inst:SetBrain(brain)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
		inst.components.hauntable.panicable = true

        if not GetGameModeProperty("disable_bird_mercy_items") then
            inst:AddComponent("periodicspawner")
            inst.components.periodicspawner:SetPrefab(SpawnPrefabChooser)
            inst.components.periodicspawner:SetDensityInRange(20, 2)
            inst.components.periodicspawner:SetMinimumSpacing(8)
        end

        inst:ListenForEvent("ontrapped", OnTrapped)
        inst:ListenForEvent("attacked", OnAttacked)

        local birdspawner = TheWorld.components.birdspawner
        if birdspawner ~= nil then
            inst:ListenForEvent("onremove", birdspawner.StopTrackingFn)
            inst:ListenForEvent("enterlimbo", birdspawner.StopTrackingFn)
            -- inst:ListenForEvent("exitlimbo", birdspawner.StartTrackingFn)
            birdspawner:StartTracking(inst)
        end

        MakeFeedableSmallLivestock(inst, TUNING.BIRD_PERISH_TIME, OnPutInInventory, OnDropped)

        if name == "canary" and TheWorld.components.toadstoolspawner ~= nil then
            inst.components.occupier.onoccupied = OnCanaryOccupied
            inst:ListenForEvent("exitlimbo", StopInhalingGas)
            inst._gasuptask = nil
            inst._gasdowntask = nil
            inst._gaslevel = 0

            --Other bird poisoned
            inst:ListenForEvent("birdpoisoned", function(world, data)
                if data.bird ~= inst then
                    inst._gaslevel = math.min(inst._gaslevel, math.random(6) - 1)
                end
            end, TheWorld)

            inst.OnSave = OnCanarySave
            inst.OnLoad = OnCanaryLoad
        end

        if water_bank ~= nil then
            inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:SetBank(water_bank) end)
            inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:SetBank(bank or "crow") end)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function puffin_loot_setup(inst, prefab_deps)
	inst.components.lootdropper:AddRandomLoot("feather_crow", 1)
	inst.components.lootdropper:AddRandomLoot("smallmeat", 1)
	inst.components.lootdropper.numrandomloot = 1

    table.insert(prefab_deps, "feather_crow")
end

return makebird("crow", "crow"),
    makebird("robin", "robin"),
    makebird("robin_winter", "junco"),
    makebird("canary", "canary"),
    makebird("quagmire_pigeon", "quagmire_pigeon", true),
    makebird("puffin", {name="puffin", bank="turnoftides"}, true, "puffin", puffin_loot_setup, "puffin_water")
