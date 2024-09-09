require "prefabutil"

local shared_assets =
{
    Asset("ANIM", "anim/moon_fissure.zip"),
}

local shared_prefabs =
{
	"moon_fissure",
    "collapse_small",
    "moon_altar_link",
    "moon_altar_link_fx_spawner",
    "moonstorm_spark_shock_fx",
}

local moon_altar_prefabs =
{
    "moon_altar_idol",
    "moon_altar_glass",
    "moon_altar_seed",
}

local moon_altar_crown_prefabs =
{
    "moon_altar_crown",
}

local moon_altar_astral_prefabs =
{
    "moon_altar_ward",
    "moon_altar_icon",
}

local link_fx_spawner_prefabs =
{
    "moon_altar_link_fx",
}

local sounds =
{
    moon_altar =
    {
        place =
        {
            "hookline_2/common/moon_alter/idol/place1",
            "hookline_2/common/moon_alter/idol/place2",
            "hookline_2/common/moon_alter/idol/place3",
        },
        prototyper_on = "hookline_2/common/moon_alter/idol/prox_pre",
        prototyper_off = "hookline_2/common/moon_alter/idol/prox_pst",
        prototyper_loop = "hookline_2/common/moon_alter/idol/LP",
        prototyper_use = "hookline_2/common/moon_alter/idol/use",
        hit = "dontstarve/wilson/chest_close",
    },
    moon_altar_cosmic =
    {
        place = "hookline_2/common/moon_alter/cosmic_crown/place",
        prototyper_on = "hookline_2/common/moon_alter/cosmic_crown/prox_pre",
        prototyper_off = "hookline_2/common/moon_alter/cosmic_crown/prox_pst",
        prototyper_loop = "hookline_2/common/moon_alter/cosmic_crown/LP",
        prototyper_use = "hookline_2/common/moon_alter/cosmic_crown/use",
        hit = "dontstarve/wilson/chest_close",
    },
    moon_altar_astral =
    {
        place = {
            "grotto/common/moon_alter/claw/place1",
            "grotto/common/moon_alter/claw/place2",
        },
        prototyper_on = "grotto/common/moon_alter/claw/prox_pre",
        prototyper_off = "grotto/common/moon_alter/claw/prox_pst",
        prototyper_loop = "grotto/common/moon_alter/claw/LP",
        prototyper_use = "grotto/common/moon_alter/claw/use",
        hit = "dontstarve/wilson/chest_close",
    },
}

local LIGHT_RADIUS = 0.9
local LIGHT_INTENSITY = .6
local LIGHT_FALLOFF = .65

local function OnUpdateFlicker(inst, starttime)
    local time = (GetTime() - starttime) * 15
    local flicker = math.sin(time * 0.7 + math.sin(time * 6.28)) -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetIntensity(LIGHT_INTENSITY + .05 * flicker)
end

local function GetStageAnim(inst, anim)
    return anim..(inst._stage ~= nil and inst._stage or "")
end

local function StartPrototyperSound(inst)
    if inst.components.moonaltarlinktarget.link == nil then
        inst.SoundEmitter:PlaySound(inst._sounds.prototyper_on)
    end
    inst.SoundEmitter:PlaySound(inst._sounds.prototyper_loop, "prototyper_loop")

    if inst._activetask ~= nil then
        inst._activetask:Cancel()
    end
    inst._activetask = nil
end

local function onturnon(inst)
    if not inst._force_on and (inst._stage == nil or inst._stage == 3 or (inst.components.workable.maxwork == TUNING.MOON_ALTAR_ASTRAL_COMPLETE_WORK and inst._stage == 2)) then
        if inst.AnimState:IsCurrentAnimation("proximity_pre") or
            inst.AnimState:IsCurrentAnimation("proximity_loop") or
            inst.AnimState:IsCurrentAnimation(GetStageAnim(inst, "place")) then

            if inst.components.moonaltarlinktarget.link == nil then
                --NOTE: push again even if already playing, in case an idle was also pushed
                inst.AnimState:PushAnimation("proximity_pre")
            end

            if inst._activetask ~= nil then
                inst._activetask:Cancel()
            end
            inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime(), StartPrototyperSound)
        else
            inst.AnimState:PlayAnimation("proximity_pre")

            StartPrototyperSound(inst)
        end

        if inst.components.moonaltarlinktarget.link == nil or not inst.AnimState:IsCurrentAnimation("proximity_loop") then
            inst.AnimState:PushAnimation("proximity_loop", true)
        end
    end
end

local function onturnoff(inst)
    if not inst._force_on then
        if (inst._stage == nil or inst._stage == 3 or (inst.components.workable.maxwork == TUNING.MOON_ALTAR_ASTRAL_COMPLETE_WORK and inst._stage == 2))
            and inst.components.moonaltarlinktarget.link == nil then

            inst.AnimState:PlayAnimation("proximity_pst")
            inst.AnimState:PushAnimation(GetStageAnim(inst, "idle"), false)
        end

        inst.SoundEmitter:KillSound("prototyper_loop")
        if inst.components.moonaltarlinktarget.link == nil then
            inst.SoundEmitter:PlaySound(inst._sounds.prototyper_off)
        end
    end
end

local function onactivate(inst)
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("proximity_loop")

    inst.SoundEmitter:PlaySound(inst._sounds.prototyper_use)
end

local function addprototyper(inst)
	inst:AddComponent("prototyper")
	inst.components.prototyper.onturnon = onturnon
	inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.MOON_ALTAR_FULL
    inst.components.prototyper.onactivate = onactivate
end

local function set_stage(inst, stage)
    if stage == 2 and inst.components.workable.maxwork == TUNING.MOON_ALTAR_ASTRAL_COMPLETE_WORK then
        if inst._stage == 1 then
            inst.AnimState:PlayAnimation("place2")
            inst.AnimState:PushAnimation("idle2", false)
        else
            inst.AnimState:PlayAnimation("idle2")
        end

        -- No longer needs to access shared _WIP line from MOON_ALTAR strings
        inst.nameoverride = nil

        addprototyper(inst)

        inst.components.lootdropper:SetLoot({ "moon_altar_ward", "moon_altar_icon"})

        inst:RemoveComponent("repairable")
        local worldmeteorshower = TheWorld.components.worldmeteorshower
        if worldmeteorshower ~= nil then
            worldmeteorshower.moonrockshell_chance_additionalodds:SetModifier(inst, TUNING.MOONROCKSHELL_CHANCE, "celestial_altar")
        end

        if not POPULATING then
            inst.components.moonaltarlinktarget:TryEstablishLink()
        end
    elseif stage == 3 then
	    if inst._stage == 2 then
            inst.AnimState:PlayAnimation("place3")
            inst.AnimState:PushAnimation("idle3", false)
        else
            inst.AnimState:PlayAnimation("idle3")
        end

		addprototyper(inst)

        inst.components.lootdropper:SetLoot({ "moon_altar_idol", "moon_altar_glass", "moon_altar_seed" })

        inst:RemoveComponent("repairable")
        local worldmeteorshower = TheWorld.components.worldmeteorshower
        if worldmeteorshower ~= nil then
            worldmeteorshower.moonrockshell_chance_additionalodds:SetModifier(inst, TUNING.MOONROCKSHELL_CHANCE, "celestial_altar")
        end

        if not POPULATING then
            inst.components.moonaltarlinktarget:TryEstablishLink()
        end
    elseif stage == 2 then
        if inst._stage == 1 then
            inst.AnimState:PlayAnimation("place2")
            inst.AnimState:PushAnimation("idle2", false)
        else
            inst.AnimState:PlayAnimation("idle2")
        end

        inst.components.lootdropper:SetLoot({ "moon_altar_glass", "moon_altar_seed" })
	end

    inst._stage = stage or 1

    if type(inst._sounds.place) == "table" then
        inst.SoundEmitter:PlaySound(inst._sounds.place[inst._stage ~= nil and inst._stage or 1])
    else
        inst.SoundEmitter:PlaySound(inst._sounds.place)
    end
end

local function on_piece_slotted(inst, slotter, slotted_item)
	set_stage(inst, inst._stage + 1)
end

local function check_piece(inst, piece)
    if (inst._stage == 1 and piece.prefab == "moon_altar_seed") or
            (inst._stage == 2 and piece.prefab == "moon_altar_idol") then
        return true
    else
        return false, "WRONGPIECE"
    end
end

local function check_pieceastral(inst, piece)
    if (inst._stage == 1 and piece.prefab == "moon_altar_ward") then
        return true
    else
        return false, "WRONGPIECE"
    end
end


local function AddRepairable(inst)
    if inst.components.repairable == nil then
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.MOON_ALTAR
        inst.components.repairable.onrepaired = on_piece_slotted
        inst.components.repairable.checkmaterialfn = check_piece
        inst.components.repairable.noannounce = true
    end
end

local function AddRepairableAstral(inst)
    if inst.components.repairable == nil then
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.MOON_ALTAR
        inst.components.repairable.onrepaired = on_piece_slotted
        inst.components.repairable.checkmaterialfn = check_pieceastral
        inst.components.repairable.noannounce = true
    end
end

local function spawn_loot_apart(inst, offset_multiplier)
    local drop_x, drop_y, drop_z = inst.Transform:GetWorldPosition()

    local loot_prefabs = inst.components.lootdropper:GenerateLoot()
    for _, loot_prefab in pairs(loot_prefabs) do
        local spawn_location = Vector3(drop_x + math.random(-1.5, 1.5), drop_y, drop_z + math.random(-1.5, 1.5))
        inst.components.lootdropper:SpawnLootPrefab(loot_prefab, spawn_location)
    end
end

local function onhammered(inst, worker)
	local x, y, z = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)

	local altar = SpawnPrefab("moon_fissure")
	altar.Transform:SetPosition(x, y, z)

    spawn_loot_apart(inst)

	inst:Remove()
end

local function onhit(inst, hitter, work_left, work_done)
    if inst._force_on or (inst.components.moonaltarlinktarget ~= nil and inst.components.moonaltarlinktarget.link ~= nil) then
        -- Undo work
        inst.components.workable.workleft = math.min(inst.components.workable.maxwork, inst.components.workable.workleft + math.ceil(work_done))

        if hitter.components.combat ~= nil and (hitter.components.inventory == nil or not hitter.components.inventory:IsInsulated()) then
            hitter.components.combat:GetAttacked(inst, TUNING.LIGHTNING_DAMAGE, nil, "electric")
        end

        inst:SpawnChild("moonstorm_spark_shock_fx")
    else
        -- If we have no work left, we're going to revert to crack_idle anyway, so don't play any anims.
        if work_left > 0 then
            if (inst.components.prototyper ~= nil and inst.components.prototyper.on)
                or inst.components.moonaltarlinktarget.link ~= nil then

                inst.AnimState:PlayAnimation("hit_proximity")
                inst.AnimState:PushAnimation("proximity_loop", true)
            else
                inst.AnimState:PlayAnimation(GetStageAnim(inst, "hit_inactive"))
                inst.AnimState:PushAnimation(GetStageAnim(inst, "idle"), false)
            end

            if inst._activetask ~= nil then
                inst._activetask:Cancel()
                inst._activetask = nil
            end

            -- inst.SoundEmitter:PlaySound(inst._sounds.hit)
        end
    end
end

local function display_name_fn(inst)
    return (inst:HasTag("prototyper") and STRINGS.NAMES.MOON_ALTAR) or
            STRINGS.NAMES.MOON_ALTAR_WIP
end

local function display_name_astral_fn(inst)
    return (inst:HasTag("prototyper") and STRINGS.NAMES.MOON_ALTAR_ASTRAL) or
            STRINGS.NAMES.MOON_ALTAR_ASTRAL_WIP
end

local function moon_altar_getstatus(inst)
    return inst._stage < 3 and "MOON_ALTAR_WIP" or nil
end

local function moon_altar_astral_getstatus(inst)
    return inst._stage < 2 and "MOON_ALTAR_WIP" or nil
end

local function OnFissureSocket(inst)
    inst.AnimState:PlayAnimation(GetStageAnim(inst, "place"))
    inst.AnimState:PushAnimation(GetStageAnim(inst, "idle"))

    if type(inst._sounds.place) == "table" then
        inst.SoundEmitter:PlaySound(inst._sounds.place[1])
    else
        inst.SoundEmitter:PlaySound(inst._sounds.place)
    end
end

local function OnFissureSocket_CosmicPost(inst)
    inst.components.moonaltarlinktarget:TryEstablishLink()
end

local function OnLink(inst, link)
    inst._force_on = true

    if inst.AnimState:IsCurrentAnimation("hit_proximity")
        or (inst.AnimState:IsCurrentAnimation("place"))
        or (inst.AnimState:IsCurrentAnimation("place3")
        or (inst.prefab == "moon_altar_astral"
            and inst._stage == 1
            and inst.AnimState:IsCurrentAnimation("place2"))) then

        inst.AnimState:PushAnimation("proximity_pre")
        inst.AnimState:PushAnimation("proximity_loop", true)
    elseif inst.AnimState:IsCurrentAnimation("proximity_pre") or inst.AnimState:IsCurrentAnimation("use") then
        inst.AnimState:PushAnimation("proximity_loop", true)
    elseif not inst.AnimState:IsCurrentAnimation("proximity_loop") then
        inst.AnimState:PlayAnimation("proximity_pre")
        inst.AnimState:PushAnimation("proximity_loop", true)
    end
end

local function OnLinkBroken(inst, link)
    if not inst._force_on then
        if inst.components.prototyper ~= nil and not inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_pst")
        end

        inst.AnimState:PushAnimation(GetStageAnim(inst, "idle"))
    end
end

local function OnFoundOtherAltar(inst, other_altar)
    if other_altar ~= nil and other_altar:IsValid() then
        local fx_spawner = SpawnPrefab("moon_altar_link_fx_spawner")
        fx_spawner.Transform:SetPosition(inst:GetPosition():Get())
        fx_spawner:_set_target_position_fn(other_altar:GetPosition())
    end
end

local function MoonAltarCanBeLinked(inst)
    return inst.components.moonaltarlinktarget.link == nil and inst._stage == 3
end

local function MoonAltarCosmicCanBeLinked(inst)
    return inst.components.moonaltarlinktarget.link == nil
end

local function MoonAltarAstralCanBeLinked(inst)
    return inst.components.moonaltarlinktarget.link == nil and inst._stage == 2
end

local function OnEntitySleep(inst)
    if inst._flickertask ~= nil then
        inst._flickertask:Cancel()
		inst._flickertask = nil
    end
end

local function OnEntityWake(inst)
    if inst._flickertask == nil then
	    inst._flickertask = inst:DoPeriodicTask(.1, OnUpdateFlicker, 0, GetTime())
	end
end

local function moon_altar_on_save(inst, data)
    data.stage = inst._stage
    data.force_on = inst._force_on
end

local function moon_altar_on_load(inst, data)
    if data ~= nil then
        if data.stage ~= nil then
            set_stage(inst, data.stage)
        end

        if data.force_on then
            inst._force_on = true
        end
    end
end

local function moon_altar_cosmic_on_save(inst, data)
    data.force_on = inst._force_on
end

local function moon_altar_cosmic_on_load(inst, data)
    if data ~= nil and data.force_on then
        inst._force_on = true
    end
end

local function moon_altar_astral_on_save(inst, data)
    data.stage = inst._stage
    data.force_on = inst._force_on
end

local function moon_altar_astral_on_load(inst, data)
    if data ~= nil then
        if data.stage ~= nil then
            set_stage(inst, data.stage)
        end

        if data.force_on then
            inst._force_on = true
        end
    end
end

local function moon_altar_common_postinit(inst)
    inst.displaynamefn = display_name_fn
end

local function moon_altar_astral_common_postinit(inst)
    inst.displaynamefn = display_name_astral_fn
end

local function moon_altar_master_postinit(inst)
    inst._stage = 1

    inst.components.lootdropper:SetLoot({ "moon_altar_glass" })

    inst.components.inspectable.getstatus = moon_altar_getstatus

    inst.components.workable.workleft = TUNING.MOON_ALTAR_COMPLETE_WORK / 3

    AddRepairable(inst)

    inst.components.moonaltarlinktarget.canbelinkedfn = MoonAltarCanBeLinked

    inst.OnSave = moon_altar_on_save
    inst.OnLoad = moon_altar_on_load
end

local function moon_altar_cosmic_master_postinit(inst)
    inst.components.lootdropper:SetLoot({ "moon_altar_crown" })

    addprototyper(inst)

    inst:ListenForEvent("on_fissure_socket", OnFissureSocket_CosmicPost)
    -- NOTES(JBK): This altar should only exist after socketing so influence the odds as it spawns since it is one piece for the whole altar.
    local worldmeteorshower = TheWorld.components.worldmeteorshower
    if worldmeteorshower ~= nil then
        worldmeteorshower.moonrockshell_chance_additionalodds:SetModifier(inst, TUNING.MOONROCKSHELL_CHANCE, "celestial_altar")
    end

    inst.components.moonaltarlinktarget.canbelinkedfn = MoonAltarCosmicCanBeLinked

    inst.OnSave = moon_altar_cosmic_on_save
    inst.OnLoad = moon_altar_cosmic_on_load
end

local function moon_altar_astral_master_postinit(inst)
    inst._stage = 1

    -- Using this to grab WIP state string of moon_altar
    inst.nameoverride = "moon_altar"

    inst.components.lootdropper:SetLoot({ "moon_altar_icon" })

    inst.components.inspectable.getstatus = moon_altar_astral_getstatus

    inst.components.workable.workleft = TUNING.MOON_ALTAR_ASTRAL_COMPLETE_WORK / 2

    AddRepairableAstral(inst)

    inst.components.moonaltarlinktarget.canbelinkedfn = MoonAltarAstralCanBeLinked

    inst.OnSave = moon_altar_astral_on_save
    inst.OnLoad = moon_altar_astral_on_load
end

local link_device_oneof_tags = { "moon_altar_link", "moon_device" }
local function OnLoadPostPass(inst)
    if inst._force_on then
        local x, _, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, 0, z, 25, nil, nil, link_device_oneof_tags)
        if ents == nil or #ents == 0 then
            -- Broken state, so we make the altar hammerable so the altar
            -- linking and device construction process can be restarted
            inst._force_on = false
            return
        end

        onturnon(inst)
        inst.AnimState:PlayAnimation("proximity_loop", true)
    end
end

local function MakeAltar(name, bank, build, anim, common_postinit, master_postinit, prefabs, work, scrapbookanim)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
	}
    assets = JoinArrays(shared_assets, assets)
    prefabs = prefabs ~= nil and JoinArrays(shared_prefabs, prefabs) or shared_prefabs

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .4)

        inst.MiniMapEntity:SetPriority(5)
        inst.MiniMapEntity:SetIcon(name..".png")

        inst.Light:SetFalloff(LIGHT_FALLOFF)
        inst.Light:SetIntensity(LIGHT_INTENSITY)
        inst.Light:SetRadius(LIGHT_RADIUS)
        inst.Light:SetColour(0.3, 0.45, 0.55)
        inst.Light:EnableClientModulation(true)
        inst._flickertask = inst:DoPeriodicTask(.1, OnUpdateFlicker, 0, GetTime())

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim)

        inst:AddTag("structure")

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_specialinfo = "MOONALTAR"
        inst.scrapbook_anim = scrapbookanim

        inst._sounds = sounds[name]
        -- inst._activetask = nil
        inst._force_on = false

        inst.set_stage_fn = set_stage

        inst:AddComponent("inspectable")

        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetMaxWork(work or TUNING.MOON_ALTAR_COMPLETE_WORK)
	    inst.components.workable.workleft = work or TUNING.MOON_ALTAR_COMPLETE_WORK
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)
        inst.components.workable.savestate = true

        inst:AddComponent("moonaltarlinktarget")
        inst.components.moonaltarlinktarget.onlinkfn = OnLink
        inst.components.moonaltarlinktarget.onlinkbrokenfn = OnLinkBroken
        inst.components.moonaltarlinktarget.onfoundotheraltarfn = OnFoundOtherAltar
        inst.components.moonaltarlinktarget.link_radius = TUNING.MOON_ALTAR_ESTABLISH_LINK_RADIUS

        MakeSnowCovered(inst)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

        inst.OnLoadPostPass = OnLoadPostPass

        inst:ListenForEvent("on_fissure_socket", OnFissureSocket)
        inst:ListenForEvent("calling_moon_relics", function(theworld,data)
            data.caller:RegisterDevice(inst)
        end, TheWorld)

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function markerfn(product)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst:AddTag("moon_altar_astral_marker")
        inst:AddTag("antlion_sinkhole_blocker")

        inst.entity:SetPristine()

        inst.product = product

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end
    return fn
end

local LINK_FX_SPAWNER_FREQ = 0.2
local LINK_FX_SPAWNER_STEPDIST = 3

local function LinkFxSpawnerMoveAndSpawn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local len = VecUtil_Length(inst._target_position.x - x, inst._target_position.z - z)
    if len > 2 then
        local dir_x, dir_z = VecUtil_Normalize(inst._target_position.x - x, inst._target_position.z - z)

        local newpos_x, newpos_z = x + dir_x * LINK_FX_SPAWNER_STEPDIST, z + dir_z * LINK_FX_SPAWNER_STEPDIST
        inst.Transform:SetPosition(newpos_x, 0, newpos_z)

        SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(newpos_x, 0, newpos_z)
    else
        inst:Remove()
    end
end

local function LinkFxSpawnerSetTargetPosition(inst, pos)
    inst._target_position = pos

    inst:DoPeriodicTask(LINK_FX_SPAWNER_FREQ, LinkFxSpawnerMoveAndSpawn)
end

local function link_fx_spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst._set_target_position_fn = LinkFxSpawnerSetTargetPosition

    -- inst._target_position = nil
    inst._distance_traveled = 0

    return inst
end

return
        MakeAltar(
            "moon_altar",                   -- name
            "moon_altar",                   -- bank
            "moon_altar",                   -- build
            "idle1",                        -- anim
            moon_altar_common_postinit,     -- common_postinit
            moon_altar_master_postinit,     -- master_postinit
            moon_altar_prefabs,             -- prefabs
            nil,                            -- work
            "idle3"                        -- scrapbookanim
        ),
        MakeAltar(
            "moon_altar_cosmic",
            "moon_altar_crown",
            "moon_altar_crown",
            "idle",
            nil,
            moon_altar_cosmic_master_postinit,
            moon_altar_crown_prefabs,
            nil,
            "idle"
        ),
        MakeAltar(
            "moon_altar_astral",
            "moon_altar_claw",
            "moon_altar_claw",
            "idle1",
            moon_altar_astral_common_postinit,
            moon_altar_astral_master_postinit,
            moon_altar_astral_prefabs,
            TUNING.MOON_ALTAR_ASTRAL_COMPLETE_WORK,
            "idle2"
        ),

        Prefab("moon_altar_astral_marker_1", markerfn("moon_altar_icon"), nil, moon_altar_astral_prefabs),
        Prefab("moon_altar_astral_marker_2", markerfn("moon_altar_ward"), nil, moon_altar_astral_prefabs),
        Prefab("moon_altar_link_fx_spawner", link_fx_spawner_fn,          nil, link_fx_spawner_prefabs  )