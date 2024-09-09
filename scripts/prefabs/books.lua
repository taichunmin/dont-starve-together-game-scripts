local assets =
{
    Asset("ANIM", "anim/books.zip"),
    --Asset("SOUND", "sound/common.fsb"),
}

local assets_fx =
{
    Asset("ANIM", "anim/fx_books.zip"),
}

local TENTACLES_BLOCKED_CANT_TAGS = { "INLIMBO", "FX" }
local BIRDSMAXCHECK_MUST_TAGS = { "magicalbird" }
local SLEEPTARGET_PVP_ONEOF_TAGS = { "sleeper", "player" }
local SLEEPTARGET_NOPVP_MUST_TAGS = { "sleeper" }
local SLEEPTARGET_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local GARDENING_CANT_TAGS = { "pickable", "stump", "withered", "barren", "INLIMBO" }

local SILVICULTURE_ONEOF_TAGS = { "leif", "silviculture", "tree", "winter_tree" }
local SILVICULTURE_CANT_TAGS = { "magicgrowth", "player", "FX", "pickable", "stump", "withered", "barren", "INLIMBO", "ancienttree" }

local HORTICULTURE_ONEOF_TAGS = { "plant", "lichen", "oceanvine", "mushroom_farm", "kelp" }
local HORTICULTURE_CANT_TAGS = { "magicgrowth", "player", "FX", "leif", "pickable", "stump", "withered", "barren", "INLIMBO", "silviculture", "tree", "winter_tree" }

local FIRE_CANT_TAGS = { "INLIMBO", "lighter" }
local FIRE_ONEOF_TAGS = { "fire", "smolder" }

local TEMPERATURE_THAW_CANT_TAGS = { "INLIMBO", "frozen" }
local TEMPERATURE_THAW_MUST_TAGS = { "freezable" }

local BEES_MUST_TAGS = { "beequeen" }

local function MaximizePlant(inst)
    if inst.components.farmplantstress ~= nil then
        if inst.components.farmplanttendable then
			inst.components.farmplanttendable:TendTo()
		end

        inst.magic_tending = true
        local _x, _y, _z = inst.Transform:GetWorldPosition()
        local x, y = TheWorld.Map:GetTileCoordsAtPoint(_x, _y, _z)

        local nutrient_consumption = inst.plant_def.nutrient_consumption
        TheWorld.components.farming_manager:AddTileNutrients(x, y, nutrient_consumption[1]*6, nutrient_consumption[2]*6, nutrient_consumption[3]*6)
    end
end

--helper function for book_gardening
local function trygrowth(inst, maximize)
    if not inst:IsValid()
		or inst:IsInLimbo()
        or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then

        return false
    end

    if inst:HasTag("leif") then
        inst.components.sleeper:GoToSleep(1000)
        return true
    end

    if maximize then
        MaximizePlant(inst)
    end

    if inst.components.growable ~= nil then
        -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
        if inst.components.growable.magicgrowable or ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump")) then
            if inst.components.simplemagicgrower ~= nil then
                inst.components.simplemagicgrower:StartGrowing()
                return true
            elseif inst.components.growable.domagicgrowthfn ~= nil then
                -- The upgraded horticulture book has a delayed start to make sure the plants get tended to first
                inst.magic_growth_delay = maximize and 2 or nil
                inst.components.growable:DoMagicGrowth()

                return true
            else
                return inst.components.growable:DoGrowth()
            end
        end
    end

    if inst.components.pickable ~= nil then
        if inst.components.pickable:CanBePicked() and inst.components.pickable.caninteractwith then
            return false
        end
        if inst.components.pickable:FinishGrowing() then
			inst.components.pickable:ConsumeCycles(1) -- magic grow is hard on plants
			return true
		end
    end

    if inst.components.crop ~= nil and (inst.components.crop.rate or 0) > 0 then
        if inst.components.crop:DoGrow(1 / inst.components.crop.rate, true) then
			return true
		end
    end

    if inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and inst:HasTag("mushroom_farm") then
        if inst.components.harvestable:IsMagicGrowable() then
            inst.components.harvestable:DoMagicGrowth()
            return true
        else
            if inst.components.harvestable:Grow() then
                return true
            end
        end

    end

	return false
end

local function GrowNext(spell)
	while #spell._targets > 0 do
		local target = table.remove(spell._targets, 1)
		if target:IsValid() and trygrowth(target, spell._maximize) then
			if spell._count > 1 then
				spell._count = spell._count - 1
				spell:DoTaskInTime(0.1 + 0.3 * math.random(), GrowNext)
				return
			end
			break
		end
	end
	spell:Remove()
end

local function book_horticulture_spell_OnSave(inst, data)
	local refs = {}
	for i, v in ipairs(inst._targets) do
		table.insert(refs, v.GUID)
	end
	data.targets = refs
	data.count = inst._count
	data.maximize = inst._maximize
	return refs
end

local function book_horticulture_spell_OnLoadPostPass(inst, newents, data)
	inst._count = data.count or 0
	inst._maximize = inst.maximize
	inst._targets = {}
	if data.targets ~= nil then
		for i, v in ipairs(data.targets) do
			v = newents[v]
			if v ~= nil and v.entity ~= nil then
				table.insert(inst._targets, v.entity)
			end
		end
	end
	inst:DoTaskInTime(0.3 * math.random(), GrowNext)
end

local function book_horticulture_spell_fn()
	local inst = CreateEntity()

	if not TheWorld.ismastersim then
		--Not meant for client!
		inst:DoTaskInTime(0, inst.Remove)

		return inst
	end

	inst.entity:AddTransform()

	--[[Non-networked entity]]
	inst.entity:Hide()

	inst:AddTag("CLASSIFIED")

	inst.OnSave = book_horticulture_spell_OnSave
	inst.OnLoadPostPass = book_horticulture_spell_OnLoadPostPass

	return inst
end

local function do_book_horticulture_spell(x, z, max_targets, maximize)
	local ents = TheSim:FindEntities(x, 0, z, 30, nil, HORTICULTURE_CANT_TAGS, HORTICULTURE_ONEOF_TAGS)
	local targets = {}
	for i, v in ipairs(ents) do
		if v.components.pickable ~= nil or v.components.crop ~= nil or v.components.growable ~= nil or v.components.harvestable ~= nil then
			table.insert(targets, v)
		end
	end

	if #targets == 0 then
		return false, "NOHORTICULTURE"
	end

	local spell = SpawnPrefab("book_horticulture_spell")
	spell.Transform:SetPosition(x, 0, z)
	spell._targets = targets
	spell._count = max_targets
	spell._maximize = maximize

	GrowNext(spell)

	return true
end

local book_defs =
{
    {
        name = "book_tentacles",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_HUGE,
        peruse_sanity = TUNING.SANITY_HUGE,
        fx_under = "tentacles",
        layer_sound = { frame = 22, sound = "wickerbottom_rework/book_spells/tentacles" },
        deps =
        {
            "tentacle",
            "splash_ocean",
        },
        fn = function(inst, reader)
            local pt = reader:GetPosition()
            local numtentacles = 3
            local num_fails = 0

            local positions = {}

            for k = 1, numtentacles do
                local theta = math.random() * TWOPI
                local radius = math.random(3, 8)

                local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                    local pos = pt + offset
                    --NOTE: The first search includes invisible entities
                    return #TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, TENTACLES_BLOCKED_CANT_TAGS) <= 0
                        and TheWorld.Map:IsPassableAtPoint(pos:Get())
                        and TheWorld.Map:IsDeployPointClear(pos, nil, 1)
                end)

                if result_offset ~= nil then
                    table.insert(positions, {x = pt.x + result_offset.x, z = pt.z + result_offset.z})
                else
                    num_fails = num_fails + 1
                end
            end

            if num_fails >= numtentacles then
                return false, "NOTENTACLEGROUND"
            end

            reader:StartThread(function()
                for i, pos in ipairs(positions) do
                    local tentacle = SpawnPrefab("tentacle")
                    tentacle.Transform:SetPosition(pos.x, 0, pos.z)
                    tentacle.sg:GoToState("attack_pre")

                    --need a better effect
                    SpawnPrefab("splash_ocean").Transform:SetPosition(pos.x, 0, pos.z)
                    ShakeAllCameras(CAMERASHAKE.FULL, .2, .02, .25, reader, 40)

                    Sleep(0.33)
                end
            end)

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_tentacles then
                reader.peruse_tentacles(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_TENTACLES"))
            return true
        end,
    },

    {
        name = "book_birds",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_HUGE,
        peruse_sanity = TUNING.SANITY_HUGE,
        fx = "fx_book_birds",
        fxmount = "fx_book_birds_mount",
        fn = function(inst, reader)
            local birdspawner = TheWorld.components.birdspawner
            if birdspawner == nil then
                return false
            end

            local pt = reader:GetPosition()

            --we can actually run out of command buffer memory if we allow for infinite birds
            local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, BIRDSMAXCHECK_MUST_TAGS)
            if #ents > 30 then
                return false, "WAYTOOMANYBIRDS"
            elseif #ents > 20 then
                return false, "TOOMANYBIRDS"
            end
            local num = math.random(10, 20)
            if #ents <= 10 then
                num = num + 10
            end

            local success = false
            local delay = 0
            for k = 1, num do
                local pos = birdspawner:GetSpawnPoint(pt)
                if pos ~= nil then
                    local bird = birdspawner:SpawnBird(pos, true)
                    if bird ~= nil then
                        bird:AddTag("magicalbird")
                        bird.sg:GoToState("delay_glide", delay)
                        delay = delay + .034 + .033 * math.random()
                        success = true
                    end
                end
            end
            return success
        end,
        perusefn = function(inst,reader)
            if reader.peruse_birds then
                reader.peruse_birds(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_BIRDS"))
            return true
        end,
    },

    {
        name = "book_brimstone",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx_over = "lightning",
        fn = function(inst, reader)
            if TheWorld.net == nil or TheWorld.net.components.weather == nil then
                return false
            end

            local pt = reader:GetPosition()
            local num_lightnings = 16

            reader:StartThread(function()
                for k = 0, num_lightnings do
                    local rad = math.random(3, 15)
                    local angle = k * 4 * PI / num_lightnings
                    local pos = pt + Vector3(rad * math.cos(angle), 0, rad * math.sin(angle))
                    TheWorld:PushEvent("ms_sendlightningstrike", pos)
                    Sleep(.3 + math.random() * .2)
                end
            end)
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_brimstone then
                reader.peruse_brimstone(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_BRIMSTONE"))
            return true
        end,
    },

    {
        name = "book_sleep",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_LARGE,
        fx = "fx_book_sleep",
        fxmount = "fx_book_sleep_mount",
        fn = function(inst, reader)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheNet:GetPVPEnabled() and
                        TheSim:FindEntities(x, y, z, range, nil, SLEEPTARGET_CANT_TAGS, SLEEPTARGET_PVP_ONEOF_TAGS) or
                        TheSim:FindEntities(x, y, z, range, SLEEPTARGET_NOPVP_MUST_TAGS, SLEEPTARGET_CANT_TAGS)

            if #ents == 0 then
                return false, "NOSLEEPTARGETS"
            end

            for i, v in ipairs(ents) do
                if v ~= reader and
                    not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
                    not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
                    not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
                    local ismount, mount
                    if v.components.rider ~= nil then
                        ismount = v.components.rider:IsRiding()
                        mount = v.components.rider:GetMount()
                    end
                    if mount ~= nil then
                        mount:PushEvent("ridersleep", { sleepiness = 10, sleeptime = 20 })
                    end
                    if v.components.sleeper ~= nil then
                        v.components.sleeper:AddSleepiness(10, 20)
                    elseif v.components.grogginess ~= nil then
                        v.components.grogginess:AddGrogginess(10, 20)
                    else
                        v:PushEvent("knockedout")
                    end

                    local fx = SpawnPrefab(ismount and "fx_book_sleep_mount" or "fx_book_sleep")
                    fx.Transform:SetPosition(v.Transform:GetWorldPosition())
                    fx.Transform:SetRotation(v.Transform:GetRotation())
                end
            end
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_sleep then
                reader.peruse_sleep(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_SLEEP"))
            if reader.SoundEmitter ~= nil then
                reader.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/sleep")
            end
            return true
        end,
    },

    {
        name = "book_gardening",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fn = function(inst, reader)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheSim:FindEntities(x, y, z, range, nil, GARDENING_CANT_TAGS)
            if #ents > 0 then
                trygrowth(table.remove(ents, math.random(#ents)))
                if #ents > 0 then
                    local timevar = 1 - 1 / (#ents + 1)
                    for i, v in ipairs(ents) do
                        v:DoTaskInTime(timevar * math.random(), trygrowth)
                    end
                end
            end
            return true
		end,
        perusefn = function(inst,reader)
            if reader.peruse_gardening then
                reader.peruse_gardening(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_GARDENING"))
            return true
        end,
    },

    {
        name = "book_horticulture",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx_under = "plants_small",
        deps = { "book_horticulture_spell" },
        fn = function(inst, reader)
			local x, y, z = reader.Transform:GetWorldPosition()
			return do_book_horticulture_spell(x, z, TUNING.BOOK_GARDENING_MAX_TARGETS)
		end,
        
        perusefn = function(inst,reader)
            if reader.peruse_horticulture then
                reader.peruse_horticulture(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_HORTICULTURE"))
            return true
        end,
    },

    {
        name = "book_horticulture_upgraded",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_HUGE,
        fx_under = "plants_big",
        layer_sound = { frame = 22, sound = "wickerbottom_rework/book_spells/upgraded_horticulture" },
        deps = { "book_horticulture_spell" },
        fn = function(inst, reader)
			local x, y, z = reader.Transform:GetWorldPosition()
			return do_book_horticulture_spell(x, z, TUNING.BOOK_GARDENING_UPGRADED_MAX_TARGETS, true)
        end,

        perusefn = function(inst,reader)
            if reader.peruse_horticulture_upgraded then
                reader.peruse_horticulture_upgraded(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_HORTICULTURE_UPGRADED"))
            return true
        end,
    },

    {
        name = "book_silviculture",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx_under = "roots",
        layer_sound = { frame = 17, sound = "wickerbottom_rework/book_spells/silviculture" },
        fn = function(inst, reader)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local _ents = TheSim:FindEntities(x, y, z, range, nil, SILVICULTURE_CANT_TAGS, SILVICULTURE_ONEOF_TAGS)
            local ents = {}

            for k,v in pairs(_ents) do
                if v.components.pickable ~= nil or v.components.crop ~= nil 
                   or v.components.growable ~= nil or v.components.harvestable ~= nil or v:HasTag("leif") then
                    table.insert (ents, v)
                end
            end

            if #ents > 0 then
                trygrowth(table.remove(ents, math.random(#ents)))
                if #ents > 0 then
                    local timevar = 1 - 1 / (#ents + 1)
                    for i, v in ipairs(ents) do
                        v:DoTaskInTime(timevar * math.random(), trygrowth)
                    end
                end
            else
                return false, "NOSILVICULTURE"
            end
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_silviculture then
                reader.peruse_silviculture(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_SILVICULTURE"))
            return true
        end,
    },

    {
        name = "book_fish",
        uses = 3,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_HUGE,
        fx = "fx_book_fish",
        fx_under = "fish",
        fn = function(inst, reader)
            local schoolspawner = TheWorld.components.schoolspawner
            if schoolspawner == nil then
                return false, "NOWATERNEARBY"
            end

            local FISH_SPAWN_OFFSET = 10
            local x, y, z = reader.Transform:GetWorldPosition()
            local delta_theta = PI2 / 18
            local failed_spawn = 0
            
            for i=1, TUNING.BOOK_FISH_AMOUNT do
                local theta = math.random() * TWOPI
                local failed_attempts = 0
                local max_failed_attempts = 36

                while failed_attempts < max_failed_attempts do
                    local spawn_offset = Vector3(math.random(1,3), 0, math.random(1,3))
                    local spawn_point = Vector3(x + math.cos(theta) * FISH_SPAWN_OFFSET, 0, z + math.sin(theta) * FISH_SPAWN_OFFSET)
                    local num_fish_spawned = schoolspawner:SpawnSchool(spawn_point, nil, spawn_offset)

                    if num_fish_spawned == nil or num_fish_spawned == 0 then
                        theta = theta + delta_theta
                        failed_attempts = failed_attempts + 1

                        if failed_attempts >= max_failed_attempts then
                            failed_spawn = failed_spawn + 1
                        end
                    else -- Success
                        break
                    end
                end
            end

            if failed_spawn >= TUNING.BOOK_FISH_AMOUNT then
                return false, "NOWATERNEARBY"
            end

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_fish then
                reader.peruse_fish(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_FISH"))
            return true
        end,
    },

    {
        name = "book_fire",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx = "fx_book_fire",
        fxmount = "fx_book_fire_mount",
        deps = { "firepen" },
        fn = function(inst, reader)
            local x, y, z = reader.Transform:GetWorldPosition()
            local fires = TheSim:FindEntities(x, y, z, TUNING.BOOK_FIRE_RADIUS, nil, FIRE_CANT_TAGS, FIRE_ONEOF_TAGS)

            if #fires > 0 then
                local fire_count = 0

                for i, fire in ipairs(fires) do
                    if fire.components.burnable then
                        if fire:HasTag("fire") then
                            fire_count = fire_count + 1
                        else
                            fire_count = fire_count + 0.5
                        end

                        -- Extinguish smoldering/fire and reset the propagator to a heat of .2
                        fire.components.burnable:Extinguish(true, 0)
                    end
                end
                
                local equipped_item = reader.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equipped_item ~= nil and equipped_item:HasTag("firepen") then
                    
                    local current = equipped_item.components.finiteuses.current
                    local total = equipped_item.components.finiteuses.total
                    if current < total then
                        equipped_item.components.finiteuses:SetUses(math.min(current + fire_count, total))
                    end
                
                elseif reader.components.inventory:HasItemWithTag("firepen", 1) then
                    local items = reader.components.inventory:GetItemsWithTag("firepen")
                    local success = false
                    
                    for _, item in ipairs(items) do
                        local total = item.components.finiteuses.total
                        local current = item.components.finiteuses.current
                        if current < total then
                            item.components.finiteuses:SetUses(math.min(current + fire_count, total))
                            success = true
                            break
                        end
                    end

                    if not success then
                        local firepen = SpawnPrefab("firepen")
                        firepen.components.finiteuses:SetUses(math.min(fire_count, firepen.components.finiteuses.total))
                        reader.components.inventory:GiveItem(firepen)
                    end
                else
                    local firepen = SpawnPrefab("firepen")
                    firepen.components.finiteuses:SetUses(math.min(fire_count, firepen.components.finiteuses.total))
                    reader.components.inventory:GiveItem(firepen)
                end
            else
                return false, "NOFIRES"
            end

            return true
        end,

        perusefn = function(inst,reader)
            if reader.peruse_fire then
                reader.peruse_fire(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_FIRE"))
            return true
        end,
    },

    {
        name = "book_web",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_LARGE,
        deps = { "book_web_ground" },
        fn = function(inst, reader)
            local x, y, z = reader.Transform:GetWorldPosition()
            local ground_web = SpawnPrefab("book_web_ground")
            ground_web.Transform:SetPosition(x,y,z)
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_web then
                reader.peruse_web(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_WEB"))
            return true
        end,
    },

    {
        name = "book_temperature",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_LARGE,
        deps = { "fx_book_temperature", "fx_book_temperature_mount" },
        fn = function(inst, reader)
            local x, y, z = reader.Transform:GetWorldPosition()
            local players = FindPlayersInRange( x, y, z, TUNING.BOOK_TEMPERATURE_RADIUS, true )
            
            for _, player in pairs(players) do
                player.components.temperature:SetTemperature(TUNING.BOOK_TEMPERATURE_AMOUNT)
                player.components.moisture:SetMoistureLevel(0)

                local fx = SpawnPrefab(player.components.rider ~= nil and player.components.rider:IsRiding() and "fx_book_temperature_mount" or "fx_book_temperature")
                fx.Transform:SetPosition(player.Transform:GetWorldPosition())
                fx.Transform:SetRotation(player.Transform:GetRotation())

                local items = player.components.inventory:ReferenceAllItems()
                for _, item in ipairs(items) do
                    if item.components.inventoryitem ~= nil then
                        item.components.inventoryitem:DryMoisture()
                    end
                end
            end

            local frozens = TheSim:FindEntities(x, y, z, TUNING.BOOK_TEMPERATURE_RADIUS, TEMPERATURE_THAW_MUST_TAGS, TEMPERATURE_THAW_CANT_TAGS)
            for _, frozen in ipairs(frozens) do
                if frozen.components.freezable then -- Just in case.
                    frozen.components.freezable:Unfreeze()
                end
            end

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_temperature then
                reader.peruse_temperature(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_TEMPERATURE"))
            return true
        end,
    },

    {
        name = "book_light",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_LARGE,
        fx = "fx_book_light",
        deps = { "booklight" },
        fn = function(inst, reader)
            TheWorld:PushEvent("ms_forcequake")
            local x, y, z = reader.Transform:GetWorldPosition()
            local light = SpawnPrefab("booklight")
            light.Transform:SetPosition(x,y,z)

            light:SetDuration(TUNING.TOTAL_DAY_TIME/2)

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_light then
                reader.peruse_light(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_LIGHT"))
            return true
        end,
    },

    {
        name = "book_light_upgraded",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_HUGE,
        fx = "fx_book_light_upgraded",
        deps = { "booklight" },
        fn = function(inst, reader)
            TheWorld:PushEvent("ms_forcequake")
            local x, y, z = reader.Transform:GetWorldPosition()
            local light = SpawnPrefab("booklight")
            light.Transform:SetPosition(x,y,z)

            -- TODO: is 2 days too much?
            light:SetDuration(TUNING.TOTAL_DAY_TIME * 2)
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_light_upgraded then
                reader.peruse_light_upgraded(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_LIGHT_UPGRADED"))
            return true
        end,
    },

    {
        name = "book_rain",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_LARGE,
        fx = "fx_book_rain",
        fxmount = "fx_book_rain_mount",
        fn = function(inst, reader)
            if TheWorld.state.precipitation ~= "none" then
                TheWorld:PushEvent("ms_forceprecipitation", false)
            else
                TheWorld:PushEvent("ms_forceprecipitation", true)
            end

            local x, y, z = reader.Transform:GetWorldPosition()
            local size = TILE_SCALE

            for i = x-size, x+size do
                for j = z-size, z+size do
                    if TheWorld.Map:GetTileAtPoint(i, 0, j) == WORLD_TILES.FARMING_SOIL then
                        TheWorld.components.farming_manager:AddSoilMoistureAtPoint(i, y, j, 100)
                    end
                end
            end

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_rain then
                reader.peruse_rain(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_RAIN"))
            return true
        end,
    },

    {
        name = "book_moon",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_HUGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx = "fx_book_moon",
        fxmount = "fx_book_moon_mount",
        fn = function(inst, reader)

            if TheWorld:HasTag("cave") then
                return false, "NOMOONINCAVES"
            elseif TheWorld.state.moonphase == "full" then
                return false, "ALREADYFULLMOON"
            end

            TheWorld:PushEvent("ms_setmoonphase", {moonphase = "full"})

            if not TheWorld.state.isnight then
                reader.components.talker:Say(GetString(reader, "ANNOUNCE_BOOK_MOON_DAYTIME"))
            end

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_moon then
                reader.peruse_moon(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_MOON"))
            return true
        end,
    },

    {
        name = "book_bees",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx = "fx_book_bees",
        deps =
        {
            "beeguard",
            "bee_poof_big",
        },
        fn = function(inst, reader)
            reader:MakeGenericCommander()

            local beescount = TUNING.BOOK_BEES_AMOUNT

            if reader.components.commander:GetNumSoldiers("beeguard") + beescount > TUNING.BOOK_MAX_GRUMBLE_BEES then
                return false, "TOOMANYBEES"
            end

            local x, y, z = reader.Transform:GetWorldPosition()
            
            local radius = TUNING.BEEGUARD_GUARD_RANGE * 0.5
            local delta_theta = PI2 / beescount
            
            for i = 1, beescount do
                reader:DoTaskInTime(i * 0.075, function() 
                    local pos_x, pos_y, pos_z = x + radius * math.cos((i-1) * delta_theta), 0, z + radius * math.sin((i-1) * delta_theta)

                    reader:DoTaskInTime(0.1 * i, function() 
                        local fx = SpawnPrefab("fx_book_bees")
                        fx.Transform:SetPosition(pos_x,pos_y,pos_z)
                    end)
                    
                    reader:DoTaskInTime(0.15 * i, function()
                        local queen = TheSim:FindEntities(x, y, z, 16, BEES_MUST_TAGS)[1] or nil

                        local bee = SpawnPrefab("beeguard")
                        bee.Transform:SetPosition(pos_x, pos_y, pos_z)
                        bee:AddToArmy(queen or reader)
                        SpawnPrefab("bee_poof_big").Transform:SetPosition(pos_x, pos_y, pos_z)
                    end)
                end)
            end

            return true
        end,

        perusefn = function(inst,reader)
            if reader.peruse_bees then
                reader.peruse_bees(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_BEES"))
            return true
        end,
    },

    {
        name = "book_research_station",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = TUNING.SANITY_LARGE,
        deps = { "fx_book_research_station", "fx_book_research_station_mount" },
        fn = function(inst, reader)
            local x, y, z = reader.Transform:GetWorldPosition()
            local players = FindPlayersInRange( x, y, z, TUNING.BOOK_RESEARCH_STATION_RADIUS, true )

            for k,player in pairs(players) do
                player.components.builder:GiveTempTechBonus({SCIENCE = 2, MAGIC = 2, SEAFARING = 2})

                local fx = SpawnPrefab(player.components.rider ~= nil and player.components.rider:IsRiding() and "fx_book_research_station_mount" or "fx_book_research_station")
                fx.Transform:SetPosition(player.Transform:GetWorldPosition())
                fx.Transform:SetRotation(player.Transform:GetRotation())
            end
            
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_research_station then
                reader.peruse_research_station(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_RESEARCH_STATION"))
            return true
        end,
    },
}

local function MakeBook(def)
    local prefabs
    if def.deps ~= nil then
        prefabs = {}
        for i, v in ipairs(def.deps) do
            table.insert(prefabs, v)
        end
    end
    if def.fx ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fx)
    end
    if def.fxmount ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fxmount)
    end
    if def.fx_over ~= nil then
        prefabs = prefabs or {}
        local fx_over_prefab = "fx_"..def.fx_over.."_over_book"
        table.insert(prefabs, fx_over_prefab)
        table.insert(prefabs, fx_over_prefab.."_mount")
    end
    if def.fx_under ~= nil then
        prefabs = prefabs or {}
        local fx_under_prefab = "fx_"..def.fx_under.."_under_book"
        table.insert(prefabs, fx_under_prefab)
        table.insert(prefabs, fx_under_prefab.."_mount")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("books")
        inst.AnimState:SetBuild("books")
        inst.AnimState:PlayAnimation(def.name)
        inst.scrapbook_anim = def.name

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        inst:AddTag("book")
        inst:AddTag("bookcabinet_item")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst.def = def
        inst.swap_build = "swap_books"
        inst.swap_prefix = def.name

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book:SetOnRead(def.fn)
        inst.components.book:SetOnPeruse(def.perusefn)
        inst.components.book:SetReadSanity(def.read_sanity)
        inst.components.book:SetPeruseSanity(def.peruse_sanity)
        inst.components.book:SetFx(def.fx, def.fxmount)

        inst:AddComponent("inventoryitem")

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(def.name, fn, assets, prefabs)
end

local function MakeFX(name, anim, ismount)
    if ismount then
        name = name.."_mount"
        anim = anim.."_mount"
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddFollower()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if ismount then
            inst.Transform:SetSixFaced() --match mounted player
        else
            inst.Transform:SetFourFaced() --match player
        end

        inst.AnimState:SetBank("fx_books")
        inst.AnimState:SetBuild("fx_books")
        inst.AnimState:PlayAnimation(anim)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", inst.Remove)
        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets_fx)
end

local ret = { Prefab("book_horticulture_spell", book_horticulture_spell_fn) }
for i, v in ipairs(book_defs) do
    table.insert(ret, MakeBook(v))
    if v.fx_over ~= nil then
        v.fx_over_prefab = "fx_"..v.fx_over.."_over_book"
        table.insert(ret, MakeFX(v.fx_over_prefab, v.fx_over, false))
        table.insert(ret, MakeFX(v.fx_over_prefab, v.fx_over, true))
    end
    if v.fx_under ~= nil then
        v.fx_under_prefab = "fx_"..v.fx_under.."_under_book"
        table.insert(ret, MakeFX(v.fx_under_prefab, v.fx_under, false))
        table.insert(ret, MakeFX(v.fx_under_prefab, v.fx_under, true))
    end
end
book_defs = nil
return unpack(ret)
