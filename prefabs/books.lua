local assets =
{
    Asset("ANIM", "anim/books.zip"),
    --Asset("SOUND", "sound/common.fsb"),
}

local prefabs = -- this should really be broken up per book...
{
    "tentacle",
    "splash_ocean",
	"book_horticulture_spell",
}

local TENTACLES_BLOCKED_CANT_TAGS = { "INLIMBO", "FX" }
local BIRDSMAXCHECK_MUST_TAGS = { "magicalbird" }
local SLEEPTARGET_PVP_ONEOF_TAGS = { "sleeper", "player" }
local SLEEPTARGET_NOPVP_MUST_TAGS = { "sleeper" }
local SLEEPTARGET_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local GARDENING_CANT_TAGS = { "pickable", "stump", "withered", "barren", "INLIMBO" }

local SILVICULTURE_ONEOF_TAGS = { "silviculture", "tree", "winter_tree" }
local SILVICULTURE_CANT_TAGS = { "pickable", "stump", "withered", "barren", "INLIMBO" }

local HORTICULTURE_CANT_TAGS = { "pickable", "stump", "withered", "barren", "INLIMBO", "silviculture", "tree", "winter_tree" }

--helper function for book_gardening
local function trygrowth(inst)
    if not inst:IsValid()
		or inst:IsInLimbo()
        or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then

        return false
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

    if inst.components.growable ~= nil then
        -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
        if inst.components.growable.magicgrowable or ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump")) then
			if inst.components.growable.domagicgrowthfn ~= nil then
				return inst.components.growable:DoMagicGrowth()
			else
	            return inst.components.growable:DoGrowth()
			end
        end
    end

    if inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and inst:HasTag("mushroom_farm") then
        if inst.components.harvestable:Grow() then
			return true
		end
    end

	return false
end

local function GrowNext(spell, reader)
	while spell._next <= #spell._targets do
		local target = spell._targets[spell._next]
		spell._next = spell._next + 1

		if target:IsValid() and trygrowth(target) then
			spell._count = spell._count + 1
			if spell._count < TUNING.BOOK_GARDENING_MAX_TARGETS then
				spell:DoTaskInTime(0.1 + 0.3 * math.random(), GrowNext)
				return
			else
				break
			end
		end
	end

	spell:Remove()
end

local function do_book_horticulture_spell(spell, reader)
    local x, y, z = reader.Transform:GetWorldPosition()
    local range = 30
    spell._targets = TheSim:FindEntities(x, y, z, range, nil, HORTICULTURE_CANT_TAGS)
	if #spell._targets == 0 then
		spell:Remove()
		return
	end

	spell._next = 1
	spell._count = 0
	GrowNext(spell, reader)
end

local book_defs =
{
    {
        name = "book_tentacles",
        uses = 5,
        fn = function(inst, reader)
            local pt = reader:GetPosition()
            local numtentacles = 3

            reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

            reader:StartThread(function()
                for k = 1, numtentacles do
                    local theta = math.random() * 2 * PI
                    local radius = math.random(3, 8)

                    local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                        local pos = pt + offset
                        --NOTE: The first search includes invisible entities
                        return #TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, TENTACLES_BLOCKED_CANT_TAGS) <= 0
                            and TheWorld.Map:IsPassableAtPoint(pos:Get())
							and TheWorld.Map:IsDeployPointClear(pos, nil, 1)
                    end)

                    if result_offset ~= nil then
                        local x, z = pt.x + result_offset.x, pt.z + result_offset.z
                        local tentacle = SpawnPrefab("tentacle")
                        tentacle.Transform:SetPosition(x, 0, z)
                        tentacle.sg:GoToState("attack_pre")

                        --need a better effect
                        SpawnPrefab("splash_ocean").Transform:SetPosition(x, 0, z)
                        ShakeAllCameras(CAMERASHAKE.FULL, .2, .02, .25, reader, 40)
                    end

                    Sleep(.33)
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
        uses = 3,
        fn = function(inst, reader)
            local birdspawner = TheWorld.components.birdspawner
            if birdspawner == nil then
                return false
            end

            local pt = reader:GetPosition()

            reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

            --we can actually run out of command buffer memory if we allow for infinite birds
            local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, BIRDSMAXCHECK_MUST_TAGS)
            if #ents > 30 then
                reader.components.talker:Say(GetString(reader, "ANNOUNCE_WAYTOOMANYBIRDS"))
            else
                local num = math.random(10, 20)
                if #ents > 20 then
                    reader.components.talker:Say(GetString(reader, "ANNOUNCE_TOOMANYBIRDS"))
                else
                    num = num + 10
                end
                reader:StartThread(function()
                    for k = 1, num do
                        local pos = birdspawner:GetSpawnPoint(pt)
                        if pos ~= nil then
                            local bird = birdspawner:SpawnBird(pos, true)
                            if bird ~= nil then
                               bird:AddTag("magicalbird")
                            end
                        end
                        Sleep(math.random(.2, .25))
                    end
                end)
            end

            return true
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
        uses = 5,
        fn = function(inst, reader)
            local pt = reader:GetPosition()
            local num_lightnings = 16

            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

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
        uses = 5,
        fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheNet:GetPVPEnabled() and
                        TheSim:FindEntities(x, y, z, range, nil, SLEEPTARGET_CANT_TAGS, SLEEPTARGET_PVP_ONEOF_TAGS) or
                        TheSim:FindEntities(x, y, z, range, SLEEPTARGET_NOPVP_MUST_TAGS, SLEEPTARGET_CANT_TAGS)
            for i, v in ipairs(ents) do
                if v ~= reader and
                    not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
                    not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
                    not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
                    local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
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
                end
            end
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_sleep then
                reader.peruse_sleep(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_SLEEP"))
            return true
        end,
    },

    {
        name = "book_gardening",
        uses = 5,
        fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

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
        uses = 5,
        fn = function(inst, reader)
			if reader.components.sanity ~= nil then
	            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
			end

            local spell = SpawnPrefab("book_horticulture_spell")
            spell.Transform:SetPosition(reader.Transform:GetWorldPosition())
			do_book_horticulture_spell(spell, reader)

            return true
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
        name = "book_silviculture",
        uses = 5,
        fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheSim:FindEntities(x, y, z, range, nil, SILVICULTURE_CANT_TAGS, SILVICULTURE_ONEOF_TAGS)
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
            if reader.peruse_silviculture then
                reader.peruse_silviculture(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_SILVICULTURE"))
            return true
        end,
    },
}

local function MakeBook(def)
    --[[local morphlist = {}
    for i, v in ipairs(book_defs) do
        if v ~= def then
            table.insert(morphlist, v.name)
        end
    end]]

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("books")
        inst.AnimState:SetBuild("books")
        inst.AnimState:PlayAnimation(def.name)

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book.onread = def.fn
        inst.components.book.onperuse = def.perusefn

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

local function book_horticulture_spell_fn()
	local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.entity:Hide()

    inst:AddTag("CLASSIFIED")

	inst.persists = false

	return inst
end

local books = { Prefab("book_horticulture_spell", book_horticulture_spell_fn) }
for i, v in ipairs(book_defs) do
    table.insert(books, MakeBook(v))
end
book_defs = nil
return unpack(books)
