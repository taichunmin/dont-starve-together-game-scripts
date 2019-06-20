local assets =
{
    Asset("ANIM", "anim/grass.zip"),
    Asset("ANIM", "anim/grass1.zip"),
    Asset("ANIM", "anim/grass_diseased_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local grasspart_assets =
{
    Asset("ANIM", "anim/grass.zip"),
    Asset("ANIM", "anim/grass1.zip"),
}

local prefabs =
{
    "cutgrass",
    "dug_grass",
    "disease_puff",
    "diseaseflies",
    "spoiled_food",
    "grassgekko",
    "grasspartfx",
}

local function SpawnDiseasePuff(inst)
    SpawnPrefab("disease_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function canmorph(inst)
    return inst.AnimState:IsCurrentAnimation("idle")
        and not (inst.components.diseaseable ~= nil and
                inst.components.diseaseable:IsDiseased())
end

local function triggernearbymorph(inst, quick, range)
    range = range or 1

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range, { "renewable" }, { "INLIMBO" })
    local count = 0

    for i, v in ipairs(ents) do
        if v ~= inst and
            v.prefab == "grass" and
            v.components.timer ~= nil and
            not (v.components.timer:TimerExists("morphdelay") or
                v.components.timer:TimerExists("morphing") or
                v.components.timer:TimerExists("morphrelay")) then

            count = count + 1

            if canmorph(v) and math.random() < .75 then
                v.components.timer:StartTimer(
                    "morphing",
                    ((not quick or count > 3) and .75 + math.random() * 1.5) or
                    (.2 + math.random() * .2) * count
                )
            else
                v.components.timer:StartTimer("morphrelay", count * FRAMES)
            end
        end
    end

    if count <= 0 and range < 4 then
        triggernearbymorph(inst, quick, range * 2)
    end
end

local function dig_up(inst, worker)
    if inst.components.pickable ~= nil and inst.components.lootdropper ~= nil then
        local withered = inst.components.witherable ~= nil and inst.components.witherable:IsWithered()
        local diseased = inst.components.diseaseable ~= nil and inst.components.diseaseable:IsDiseased()

        if diseased then
            SpawnDiseasePuff(inst)
        elseif inst.components.diseaseable ~= nil and inst.components.diseaseable:IsBecomingDiseased() then
            SpawnDiseasePuff(inst)
            if worker ~= nil then
                worker:PushEvent("digdiseasing")
            end
        elseif not TheWorld.state.iswinter
            and worker ~= nil
            and worker:HasTag("player")
            and math.random() < TUNING.GRASSGEKKO_MORPH_CHANCE then
            triggernearbymorph(inst, true)
        end

        if inst.components.pickable:CanBePicked() then
            inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        end

        inst.components.lootdropper:SpawnLootPrefab(
            (withered or diseased) and
            "cutgrass" or
            "dug_grass"
        )
    end
    inst:Remove()
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
    if not POPULATING and
        (   inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered() or
            inst.AnimState:IsCurrentAnimation("idle_dead")
        ) then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("picked", false)
    else
        inst.AnimState:PlayAnimation("picked")
    end
end

local function makebarrenfn(inst, wasempty)
    if not POPULATING and
        (   inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered()
        ) then
        inst.AnimState:PlayAnimation(wasempty and "empty_to_dead" or "full_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end

local function onpickedfn(inst, picker)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    inst.AnimState:PlayAnimation("picking")

    if inst.components.diseaseable ~= nil and inst.components.diseaseable:IsDiseased() then
        SpawnDiseasePuff(inst)
    elseif inst.components.diseaseable ~= nil and inst.components.diseaseable:IsBecomingDiseased() then
        SpawnDiseasePuff(inst)
        if picker ~= nil then
            picker:PushEvent("pickdiseasing")
        end
    elseif not TheWorld.state.iswinter
        and picker ~= nil
        and picker:HasTag("player")
        and math.random() < TUNING.GRASSGEKKO_MORPH_CHANCE then
        triggernearbymorph(inst, true)
    end

    if inst.components.pickable:IsBarren() then
        inst.AnimState:PushAnimation("empty_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PushAnimation("picked", false)
    end
end

local function SetDiseaseBuild(inst)
    inst.AnimState:SetBuild("grass_diseased_build")
end

local function ondiseasedfn(inst)
    inst.components.pickable:ChangeProduct("spoiled_food")
    if POPULATING then
        SetDiseaseBuild(inst)
    elseif inst.components.pickable:CanBePicked() then
        inst.AnimState:PlayAnimation("rustle")
        inst.AnimState:PushAnimation("idle", true)
        SpawnDiseasePuff(inst)
        inst:DoTaskInTime(4 * FRAMES, SetDiseaseBuild)
    else
        if inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered() or
            inst.components.pickable:IsBarren() then
            inst.AnimState:PlayAnimation("rustle_dead")
            inst.AnimState:PushAnimation("idle_dead", false)
        else
            inst.AnimState:PlayAnimation("rustle_empty")
            inst.AnimState:PushAnimation("picked", false)
        end
        inst:DoTaskInTime(2 * FRAMES, SpawnDiseasePuff)
        inst:DoTaskInTime(6 * FRAMES, SetDiseaseBuild)
    end
end

local function makediseaseable(inst)
    if inst.components.diseaseable == nil then
        inst:AddComponent("diseaseable")
        inst.components.diseaseable:SetDiseasedFn(ondiseasedfn)
    end
end

local function onmorphtimer(inst, data)
    local morphing = data.name == "morphing"
    if morphing or data.name == "morphrelay" then
        if morphing and canmorph(inst) then
            local x, y, z = inst.Transform:GetWorldPosition()
            if #TheSim:FindEntities(x, y, z, TUNING.GRASSGEKKO_DENSITY_RANGE, { "grassgekko" }) < TUNING.GRASSGEKKO_MAX_DENSITY then
                local gekko = SpawnPrefab("grassgekko")
                gekko.Transform:SetPosition(x, y, z)
                gekko.sg:GoToState("emerge")

                local partfx = SpawnPrefab("grasspartfx")
                partfx.Transform:SetPosition(x, y, z)
                partfx.Transform:SetRotation(inst.Transform:GetRotation())
                partfx.AnimState:SetMultColour(inst.AnimState:GetMultColour())

                triggernearbymorph(inst, false)
                inst:Remove()
                return
            end
        end
        inst.components.timer:StartTimer("morphdelay", GetRandomWithVariance(TUNING.GRASSGEKKO_MORPH_DELAY, TUNING.GRASSGEKKO_MORPH_DELAY_VARIANCE))
        triggernearbymorph(inst, false)
    end
end

local function makemorphable(inst)
    if inst.components.timer == nil then
        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", onmorphtimer)
    end
end

local function ontransplantfn(inst)
    inst.components.pickable:MakeBarren()
    makediseaseable(inst)
    makemorphable(inst)
    inst.components.diseaseable:RestartNearbySpread()
    inst.components.timer:StartTimer("morphdelay", GetRandomWithVariance(TUNING.GRASSGEKKO_MORPH_DELAY, TUNING.GRASSGEKKO_MORPH_DELAY_VARIANCE))
end

local function OnPreLoad(inst, data)
    if data ~= nil then
        if data.pickable ~= nil and data.pickable.transplanted then
            makediseaseable(inst)
            makemorphable(inst)
        else
            if data.diseaseable ~= nil then
                makediseaseable(inst)
            end
            if data.timer ~= nil then
                makemorphable(inst)
            end
        end
    end
end

local function grass(name, stage)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon("grass.png")

        inst.AnimState:SetBank("grass")
        inst.AnimState:SetBuild("grass1")
        inst.AnimState:PlayAnimation("idle", true)

        inst:AddTag("plant")
        inst:AddTag("renewable")

        --witherable (from witherable component) added to pristine state for optimization
        inst:AddTag("witherable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.AnimState:SetTime(math.random() * 2)
        local color = 0.75 + math.random() * 0.25
        inst.AnimState:SetMultColour(color, color, color, 1)

        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

        inst.components.pickable:SetUp("cutgrass", TUNING.GRASS_REGROW_TIME)
        inst.components.pickable.onregenfn = onregenfn
        inst.components.pickable.onpickedfn = onpickedfn
        inst.components.pickable.makeemptyfn = makeemptyfn
        inst.components.pickable.makebarrenfn = makebarrenfn
        inst.components.pickable.max_cycles = 20
        inst.components.pickable.cycles_left = 20
        inst.components.pickable.ontransplantfn = ontransplantfn

        inst:AddComponent("witherable")

        if stage == 1 then
            inst.components.pickable:MakeBarren()
        end

        inst:AddComponent("lootdropper")
        inst:AddComponent("inspectable")

		if not GetGameModeProperty("disable_transplanting") then
			inst:AddComponent("workable")
			inst.components.workable:SetWorkAction(ACTIONS.DIG)
			inst.components.workable:SetOnFinishCallback(dig_up)
			inst.components.workable:SetWorkLeft(1)
		end
        ---------------------

        MakeMediumBurnable(inst)
        MakeSmallPropagator(inst)
        MakeNoGrowInWinter(inst)
        MakeHauntableIgnite(inst)
        ---------------------

        inst.OnPreLoad = OnPreLoad
        inst.MakeDiseaseable = makediseaseable

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function grasspart_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("grass")
    inst.AnimState:SetBuild("grass1")
    inst.AnimState:PlayAnimation("grass_part")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return grass("grass", 0),
    grass("depleted_grass", 1),
    Prefab("grasspartfx", grasspart_fn, grasspart_assets)
