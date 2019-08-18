local assets =
{
    Asset("ANIM", "anim/books.zip"),
    --Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "tentacle",
    "splash_ocean",
}

--helper function for book_gardening
local function trygrowth(inst)
    if inst:IsInLimbo()
        or (inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered()) then
        return
    end

    if inst.components.pickable ~= nil then
        if inst.components.pickable:CanBePicked() and inst.components.pickable.caninteractwith then
            return
        end
        inst.components.pickable:FinishGrowing()
    end

    if inst.components.crop ~= nil and (inst.components.crop.rate or 0) > 0 then
        inst.components.crop:DoGrow(1 / inst.components.crop.rate, true)
    end

    if inst.components.growable ~= nil then
        -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
        if ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump")) or
                inst.components.growable.magicgrowable then
            inst.components.growable:DoGrowth()
        end
    end

    if inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and inst:HasTag("mushroom_farm") then
        inst.components.harvestable:Grow()
    end
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
                        return #TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, { "INLIMBO", "FX" }) <= 0
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
            local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, nil, nil, { "magicalbird" })
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
    },

    {
        name = "book_sleep",
        uses = 5,
        fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheNet:GetPVPEnabled() and
                        TheSim:FindEntities(x, y, z, range, nil, { "playerghost", "FX", "DECOR", "INLIMBO" }, { "sleeper", "player" }) or
                        TheSim:FindEntities(x, y, z, range, { "sleeper" }, { "player", "FX", "DECOR", "INLIMBO" })
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
    },

    {
        name = "book_gardening",
        uses = 5,
        fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheSim:FindEntities(x, y, z, range, nil, { "pickable", "stump", "withered", "INLIMBO" })
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

local books = {}
for i, v in ipairs(book_defs) do
    table.insert(books, MakeBook(v))
end
book_defs = nil
return unpack(books)
