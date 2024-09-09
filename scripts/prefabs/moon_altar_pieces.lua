local PHYSICS_RADIUS = .1

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function makepiece(name, socket_product)
    local assets =
    {
        Asset("ANIM", "anim/moon_altar_pieces.zip"),
        Asset("ANIM", "anim/swap_altar_"..name.."piece.zip"),
	    Asset("MINIMAP_IMAGE", "moon_altar_"..name.."_piece"),
	}

	local piece_prefabs =
	{
		"underwater_salvageable",
		"splash_green",
	}

    local function onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_body", "swap_altar_"..name.."piece", "swap_body")
    end


    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
		inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

		inst.MiniMapEntity:SetIcon("moon_altar_"..name.."_piece.png")

        MakeSmallHeavyObstaclePhysics(inst, PHYSICS_RADIUS)
        inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)

        inst.AnimState:SetBank("moon_altar_pieces")
        inst.AnimState:SetBuild("swap_altar_"..name.."piece")
        inst.AnimState:PlayAnimation("anim")

        inst.scrapbook_anim = "anim"
        inst.scrapbook_specialinfo = "ALTARPLUG"

        inst:AddTag("irreplaceable")
        inst:AddTag("nonpotatable")
        inst:AddTag("heavy")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._socket_product = socket_product

        inst:AddComponent("heavyobstaclephysics")
        inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)
        inst.components.heavyobstaclephysics:MakeSmallObstacle()

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY

        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("repairer")
        inst.components.repairer.repairmaterial = MATERIALS.MOON_ALTAR

        -- There are 3 altar piece variations, so each one repairs 1/3rd of the total amount.
		inst.components.repairer.workrepairvalue = TUNING.MOON_ALTAR_COMPLETE_WORK / 3

		inst:AddComponent("submersible")
		inst:AddComponent("symbolswapdata")
		inst.components.symbolswapdata:SetData("swap_altar_"..name.."piece", "swap_body")

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("calling_moon_relics", function(theworld,data)
            data.caller:RegisterDevice(inst)
        end, TheWorld)

        return inst
    end

    return Prefab("moon_altar_"..name, fn, assets, piece_prefabs)
end

local function OnWork(inst, worker, workleft, numworks)
    if workleft <= 0 then

		local x, y, z = inst.Transform:GetWorldPosition()
		SpawnPrefab("moon_altar_"..inst._altar_piece).Transform:SetPosition(x, y, z)

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(x, y, z)

		if worker ~= nil and worker:HasTag("player") and worker.components.talker ~= nil then
			worker.components.talker:Say(GetString(worker, "ANNOUNCE_MOONALTAR_MINE", string.upper(inst._altar_piece).."_REVEAL"))
		end

        inst:Remove()
    else
		if worker ~= nil and worker.components.talker ~= nil then
			if (workleft + numworks >= TUNING.MOONALTAR_ROCKS_MINE / 3) and (workleft < TUNING.MOONALTAR_ROCKS_MINE / 3) then
				worker.components.talker:Say(GetString(worker, "ANNOUNCE_MOONALTAR_MINE", string.upper(inst._altar_piece).."_LOW"))
			elseif (workleft + numworks >= TUNING.MOONALTAR_ROCKS_MINE * 2 / 3) and (workleft < TUNING.MOONALTAR_ROCKS_MINE * 2 / 3) then
				worker.components.talker:Say(GetString(worker, "ANNOUNCE_MOONALTAR_MINE", string.upper(inst._altar_piece).."_MED"))
			end
		end
        inst.AnimState:PlayAnimation(
            (workleft < TUNING.MOONALTAR_ROCKS_MINE / 3 and "low") or
            (workleft < TUNING.MOONALTAR_ROCKS_MINE * 2 / 3 and "med") or
            "full"
        )
    end
end

local function makerockpiece(name, socket_product)
    local assets =
    {
        Asset("ANIM", "anim/altar_"..name.."piece.zip"),
	    Asset("MINIMAP_IMAGE", "moon_altar_"..name.."_rock"),
    }

	local rock_prefabs =
	{
		"rock_break_fx",
		"collapse_small",
		"moon_altar_"..name,
	}

	local anim = "altar_"..name.."piece"

    local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddMiniMapEntity()
		inst.entity:AddNetwork()

		MakeObstaclePhysics(inst, 1)

		inst.MiniMapEntity:SetIcon("moon_altar_"..name.."_rock.png")

		inst.AnimState:SetBank(anim)
		inst.AnimState:SetBuild(anim)
		inst.AnimState:PlayAnimation("full")

        inst.scrapbook_anim = "full"
        inst.scrapbook_specialinfo = "MOON_ALTAR_ROCK"

		MakeSnowCoveredPristine(inst)

		inst:AddTag("boulder")

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst._altar_piece = name

		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetLoot({ "moon_altar_"..name })

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.MINE)
		inst.components.workable:SetWorkLeft(TUNING.MOONALTAR_ROCKS_MINE)
		inst.components.workable:SetOnWorkCallback(OnWork)

		inst:AddComponent("inspectable")

		MakeSnowCovered(inst)
		MakeHauntableWork(inst)

        inst:ListenForEvent("calling_moon_relics", function(theworld,data)
            data.caller:RegisterDevice(inst)
        end, TheWorld)

        return inst
    end

    return Prefab("moon_altar_rock_"..name, fn, assets, rock_prefabs)
end



local function makemarker(name, socket_product)

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("moon_altar_marker")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    return Prefab("moon_altar_marker")
end

--For searching: "moon_altar_idol", "moon_altar_glass", "moon_altar_seed", "moon_altar_crown", "moon_altar_rock_glass", "moon_altar_rock_seed", "moon_altar_rock_idol" ,"moon_altar_ward", "moon_altar_icon"
return
    makerockpiece("idol"),
    makepiece("idol"),
	makerockpiece("glass"),
    makepiece("glass", "moon_altar"),
    makerockpiece("seed"),
    makepiece("seed"),

    makepiece("crown", "moon_altar_cosmic"),

    makepiece("ward"),
    makepiece("icon", "moon_altar_astral")
