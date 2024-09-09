require "prefabutil"

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil and inst:GetCurrentPlatform() == nil then
            inst._pfpos = inst:GetPosition()
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function makeobstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
end

local anims =
{
    { threshold = 0, anim = "broken" },
    { threshold = 0.4, anim = "onequarter" },
    { threshold = 0.5, anim = "half" },
    { threshold = 0.99, anim = "threequarter" },
    { threshold = 1, anim = { "fullA", "fullB", "fullC" } },
}

local function resolveanimtoplay(inst, percent)
    for i, v in ipairs(anims) do
        if percent <= v.threshold then
            if type(v.anim) == "table" then
                -- get a stable animation, by basing it on world position
                local x, y, z = inst.Transform:GetWorldPosition()
                local x = math.floor(x)
                local z = math.floor(z)
                local q1 = #v.anim + 1
                local q2 = #v.anim + 4
                local t = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #v.anim + 1
                return v.anim[t]
            else
                return v.anim
            end
        end
    end
end

local function onhealthchange(inst, old_percent, new_percent)
    local anim_to_play = resolveanimtoplay(inst, new_percent)
    if new_percent > 0 then
        if old_percent <= 0 then
            makeobstacle(inst)
        end
        inst.AnimState:PlayAnimation(anim_to_play.."_hit")
        inst.AnimState:PushAnimation(anim_to_play, false)
    else
        if old_percent > 0 then
            clearobstacle(inst)
        end
        inst.AnimState:PlayAnimation(anim_to_play)
    end
end

local function keeptargetfn()
    return false
end

local function onload(inst,data)
    if inst.components.health:IsDead() then
        clearobstacle(inst)
    end

    if data and data.gridnudge then
        local function normalize(coord)

            local temp = coord%0.5
            coord = coord + 0.5 - temp

            if  coord%1 == 0 then
                coord = coord -0.5
            end

            return coord
        end

        local pt = Vector3(inst.Transform:GetWorldPosition())
        pt.x = normalize(pt.x)
        pt.z = normalize(pt.z)
        inst.Transform:SetPosition(pt.x,pt.y,pt.z)
    end
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local PLAYER_TAGS = { "player" }
local function ValidRepairFn(inst)
    if inst.Physics:IsActive() then
        return true
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then
        return true
    end

    if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, 1, PLAYER_TAGS)) do
            if v ~= inst and
            v.entity:IsVisible() and
            v.components.placer == nil and
            v.entity:GetParent() == nil then
                local px, _, pz = v.Transform:GetWorldPosition()
                if math.floor(x) == math.floor(px) and math.floor(z) == math.floor(pz) then
                    return false
                end
            end
        end
    end
    return true
end

function MakeWallType(data)
    local assets =
    {
        Asset("ANIM", "anim/wall.zip"),
        Asset("ANIM", "anim/wall_"..data.name..".zip"),
    }

    local prefabs =
    {
        "collapse_small",
        "brokenwall_"..data.name,
    }

	local bank = data.name == "dreadstone" and "wall_dreadstone" or "wall"

    local function ondeploywall(inst, pt, deployer)
        --inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
        local wall = SpawnPrefab("wall_"..data.name, inst.linked_skinname, inst.skin_id)
        if wall ~= nil then
            local x = math.floor(pt.x) + .5
            local z = math.floor(pt.z) + .5
            wall.Physics:SetCollides(false)
            wall.Physics:Teleport(x, 0, z)
            wall.Physics:SetCollides(true)
            inst.components.stackable:Get():Remove()

            if data.buildsound ~= nil then
                wall.SoundEmitter:PlaySound(data.buildsound)
            end
        end
    end

    local function onhammered(inst, worker)
        if data.maxloots ~= nil and data.loot ~= nil then
            local num_loots = math.max(1, math.floor(data.maxloots * inst.components.health:GetPercent()))
            for i = 1, num_loots do
                inst.components.lootdropper:SpawnLootPrefab(data.loot)
            end
        end

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if data.material ~= nil then
            fx:SetMaterial(data.material)
        end

        inst:Remove()
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst:AddTag("wallbuilder")

		inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation("idle")

		if data.name == "dreadstone" then
			inst.AnimState:SetSymbolLightOverride("wall_segment_red", 1)
		end

        local item_floats = (data.name == "wood") or (data.name == "hay")
        if item_floats then
            MakeInventoryFloatable(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        if not item_floats then
            inst.components.inventoryitem:SetSinks(true)
        end

        inst:AddComponent("repairer")
        inst.components.repairer.repairmaterial = (data.name == "ruins" and MATERIALS.THULECITE) or (data.name == "scrap" and MATERIALS.GEARS) or data.name
        inst.components.repairer.healthrepairvalue = data.repairhealth or data.maxhealth / 6

        if data.flammable then
            MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
            MakeSmallPropagator(inst)

            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
        end

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploywall
        inst.components.deployable:SetDeployMode(DEPLOYMODE.WALL)

        MakeHauntableLaunch(inst)

        return inst
    end

    local function onhit(inst)
        if data.material ~= nil then
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_"..data.material)
        end

        local healthpercent = inst.components.health:GetPercent()
        if healthpercent > 0 then
            local anim_to_play = resolveanimtoplay(inst, healthpercent)
            inst.AnimState:PlayAnimation(anim_to_play.."_hit")
            inst.AnimState:PushAnimation(anim_to_play, false)
        end
    end

    local function onrepaired(inst)
        if data.buildsound ~= nil then
            inst.SoundEmitter:PlaySound(data.buildsound)
        end
        makeobstacle(inst)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

		inst:SetDeploySmartRadius(0.5) --DEPLOYMODE.WALL assumes spacing of 1

        MakeObstaclePhysics(inst, .5)
        inst.Physics:SetDontRemoveOnSleep(true)

        --inst.Transform:SetScale(1.3,1.3,1.3)

        if data.name == "hay" then
        	--roughly try to match the grass colouring
            local s = 0.9
            inst.AnimState:SetMultColour(s, s, s, 1)
        end

        inst:AddTag("wall")
        inst:AddTag("noauradamage")

		inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation("half")

		if data.name == "dreadstone" then
			inst.AnimState:SetSymbolLightOverride("wall_segment_red", 1)
		end

        for i, v in ipairs(data.tags) do
            inst:AddTag(v)
        end

        MakeSnowCoveredPristine(inst)

        inst._pfpos = nil
        inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
        makeobstacle(inst)
        --Delay this because makeobstacle sets pathfinding on by default
        --but we don't to handle it until after our position is set
        inst:DoTaskInTime(0, InitializePathFinding)

        inst.OnRemoveEntity = onremove

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_specialinfo = "WALLS"
        inst.scrapbook_anim = "half"

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = (data.name == "ruins" and MATERIALS.THULECITE) or (data.name == "scrap" and MATERIALS.GEARS) or data.name
        inst.components.repairable.onrepaired = onrepaired
        inst.components.repairable.testvalidrepairfn = ValidRepairFn

        if data.name == "ruins_2" then
            inst.components.repairable.repairmaterial = MATERIALS.THULECITE
        end
        if data.name == "stone_2" then
            inst.components.repairable.repairmaterial = "stone"
        end

        inst:AddComponent("combat")
        inst.components.combat:SetKeepTargetFunction(keeptargetfn)
        inst.components.combat.onhitfn = onhit

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(data.maxhealth)
        inst.components.health:SetCurrentHealth(data.maxhealth * .5)
        inst.components.health.ondelta = onhealthchange
        inst.components.health.nofadeout = true
        inst.components.health.canheal = false
		if data.playerdamagemod ~= nil then
			inst.components.health:SetAbsorptionAmountFromPlayer(data.playerdamagemod)
		end

        if data.flammable then
            MakeMediumBurnable(inst)
            MakeLargePropagator(inst)
            inst.components.burnable.flammability = .5
            inst.components.burnable.nocharring = true

            --lame!
            if data.name == MATERIALS.WOOD then
                inst.components.propagator.flashpoint = 30 + math.random() * 10
            end
        else
            inst.components.health.fire_damage_scale = 0
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(data.maxwork or 3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        MakeHauntableWork(inst)

        inst.OnLoad = onload

        MakeSnowCovered(inst)

        return inst
    end

    return Prefab("wall_"..data.name, fn, assets, prefabs),
        Prefab("wall_"..data.name.."_item", itemfn, assets, { "wall_"..data.name, "wall_"..data.name.."_item_placer" }),
		MakePlacer("wall_"..data.name.."_item_placer", bank, "wall_"..data.name, "half", false, false, true, nil, nil, "eight")
end

local wallprefabs = {}

--6 rock, 8 wood, 4 straw
--NOTE: Stacksize is now set in the actual recipe for the item.
local walldata =
{
    { name = MATERIALS.STONE,          material = "stone", tags = { "stone" },             loot = "rocks",            maxloots = 2, maxhealth = TUNING.STONEWALL_HEALTH,                      buildsound = "dontstarve/common/place_structure_stone" },
    { name = MATERIALS.STONE.."_2",    material = "stone", tags = { "stone" },             loot = "rocks",            maxloots = 2, maxhealth = TUNING.STONEWALL_HEALTH,                      buildsound = "dontstarve/common/place_structure_stone" },
    { name = MATERIALS.WOOD,     material = "wood",  tags = { "wood" },              loot = "log",              maxloots = 2, maxhealth = TUNING.WOODWALL_HEALTH,     flammable = true, buildsound = "dontstarve/common/place_structure_wood"  },
    { name = MATERIALS.HAY,      material = "straw", tags = { "grass" },             loot = "cutgrass",         maxloots = 2, maxhealth = TUNING.HAYWALL_HEALTH,      flammable = true, buildsound = "dontstarve/common/place_structure_straw" },
    { name = "ruins",            material = "stone", tags = { "stone", "ruins" },    loot = "thulecite_pieces", maxloots = 2, maxhealth = TUNING.RUINSWALL_HEALTH,                      buildsound = "dontstarve/common/place_structure_stone" },
    { name = "ruins_2",          material = "stone", tags = { "stone", "ruins" },    loot = "thulecite_pieces", maxloots = 2, maxhealth = TUNING.RUINSWALL_HEALTH,                      buildsound = "dontstarve/common/place_structure_stone" },
	{
		name = MATERIALS.MOONROCK,
		material = "stone",
		tags = { "stone", "moonrock" },
		loot = "moonrocknugget",
		maxloots = 2,
		maxwork = TUNING.MOONROCKWALL_WORK,
		maxhealth = TUNING.MOONROCKWALL_HEALTH,
		playerdamagemod = TUNING.MOONROCKWALL_PLAYERDAMAGEMOD,
		buildsound = "dontstarve/common/place_structure_stone",
	},
	{
		name = MATERIALS.DREADSTONE,
		material = "stone",
		tags = { "stone", "dreadstone" },
		loot = "dreadstone",
		maxloots = 2,
		maxwork = TUNING.DREADSTONEWALL_WORK,
		maxhealth = TUNING.DREADSTONEWALL_HEALTH,
		playerdamagemod = TUNING.DREADSTONEWALL_PLAYERDAMAGEMOD,
		repairhealth = TUNING.REPAIR_DREADSTONE_HEALTH * 4,
		buildsound = "dontstarve/common/place_structure_stone",
	},
    {
        name ="scrap",
        material = "stone",
        tags = { "stone", "scrap" },
        loot = "wagpunk_bits",
        maxloots = 1,
        maxwork = TUNING.SCRAPWALL_WORK,
        maxhealth = TUNING.SCRAPWALL_HEALTH,
        playerdamagemod = TUNING.SCRAPWALL_PLAYERDAMAGEMOD,
        repairhealth = TUNING.REPAIR_SCRAP_HEALTH * 4,
        buildsound = "dontstarve/common/place_structure_stone",
    },    
}
for i, v in ipairs(walldata) do
    local wall, item, placer = MakeWallType(v)
    table.insert(wallprefabs, wall)
    table.insert(wallprefabs, item)
    table.insert(wallprefabs, placer)
end

return unpack(wallprefabs)

