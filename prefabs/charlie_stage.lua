local assets =
{
    Asset("ANIM", "anim/charlie_stage.zip"),
}

local postassets =
{
    Asset("ANIM", "anim/charlie_curtains.zip"),
    Asset("MINIMAP_IMAGE", "charlie_stage_post"),
}

local seatassets =
{
    Asset("ANIM", "anim/charlie_seat.zip"),
}

local prefabs =
{
    "charlie_heckler",
    "charlie_lecturn",
    "charlie_seat",
    "charlie_stage",
    "charlie_stage_lip",
    "costume_doll_body",
    "hedgehound",
    "hedgehound_bush",
    "mask_dollhat",
    "playbill_the_doll",
    "sewing_mannequin",
}

local function StagePlay_ActiveFn(params, parent, best_dist_sq)
    local pan_gain, heading_gain, distance_gain = TheCamera:GetGains()
    TheCamera:SetGains(1.5, heading_gain, distance_gain)
    TheCamera:SetDistance(30)
end

local CAMERAFOCUS_UPDATERDATA = { ActiveFn = StagePlay_ActiveFn }
local function OnFocusCamera(inst)
    if inst._camerafocusvalue > FRAMES then
        inst._camerafocusvalue = inst._camerafocusvalue - FRAMES
        local k = math.min(1, inst._camerafocusvalue) / 1
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 10 * k, 28 * k, 4, CAMERAFOCUS_UPDATERDATA)
    else
        inst._camerafocustask:Cancel()
        inst._camerafocustask = nil
        inst._camerafocusvalue = nil
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() > 0 then
        if inst._camerafocus:value() <= 1 then
            inst._camerafocusvalue = math.huge
            if inst._camerafocustask == nil then
                inst._camerafocustask = inst:DoPeriodicTask(0, OnFocusCamera)
                OnFocusCamera(inst)
            end
        elseif inst._camerafocustask ~= nil then
            inst._camerafocusvalue = 3
            OnFocusCamera(inst)
        end
    elseif inst._camerafocustask ~= nil then
        inst._camerafocustask:Cancel()
        inst._camerafocustask = nil
        inst._camerafocusvalue = nil
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function SetCameraFocus(inst, level)
    if level ~= inst._camerafocus:value() then
        inst._camerafocus:set(level)
        if not TheNet:IsDedicated() then
            OnCameraFocusDirty(inst)
        end
    end
end

-- Mid-Stageplay Background Music ----------------------------------------------------

local function UpdateGameMusic(inst)
    if (ThePlayer ~= nil and ThePlayer:IsValid())
            and ThePlayer:IsNear(inst, TUNING.CHARLIE_STAGE_MUSIC_RANGE) then
        -- Dynamic music can handle 0, but we might as well avoid the event push if we can.
        local music_type = inst._musictype:value()
        if music_type > 0 then
            ThePlayer:PushEvent("stageplaymusic", music_type)
        end
    end
end

local function setup_stagepost_music_check(inst)
    inst._musiccheck = inst:DoPeriodicTask(1, UpdateGameMusic)
end

local function OnStagePostWake(inst)
    if not TheNet:IsDedicated() then
        setup_stagepost_music_check(inst)
    end
end

local function OnStagePostSleep(inst)
    if inst._musiccheck ~= nil then
        inst._musiccheck:Cancel()
        inst._musiccheck = nil
    end
end

local function SetStagePostMusicType(inst, music_type)
    music_type = string.lower(music_type or 0)
    local new_value = 0
    if music_type == "happy" or music_type == 1 then
        new_value = 1
    elseif music_type == "mysterious" or music_type == 2 then
        new_value = 2
    elseif music_type == "drama" or music_type == 3 then
        new_value = 3
    end
    inst._musictype:set(new_value)
end

--------------------------------------------------------------------------------

local function spawnhound(inst, reward, theta)
    local pos = inst:GetPosition()

    local radius = 10
    local offset = FindWalkableOffset(pos, theta, radius, nil, false, true)
        or Vector3FromTheta(theta, radius)

    local bush = SpawnPrefab("hedgehound_bush")
    bush.Transform:SetPosition((pos + offset):Get())
    bush:SetReward(reward)
end

-- NOTES(JBK): 'name' field is useful for mods to interface with the rewards for looking to modify content dynamically but has no instrinsic value.
local REWARDPOOL = {
    {name = "miner", "pickaxe", "minerhat", "lightbulb"},
    {name = "farmer", "wateringcan", "farm_hoe", "farm_plow_item"},
    {name = "fisher", "oceanfishingrod", "oceanfishingbobber_ball", "oceanfishinglure_spoon_red"},
    {name = "hiker", "axe", "backpack", "shovel"},
    {name = "hunter", "spear", "armorgrass", "trap"},
    {name = "weather", "earmuffshat", "meat_dried", "umbrella"},
    {name = "tailor", "tophat", "sewing_kit", "grass_umbrella"},
}

local function OnPlayPerformed(inst, data)
    if not data.next and not data.error then
        local REWARDS = inst._rewardpool[math.random(1, #inst._rewardpool)]
        local theta = math.random() * TWOPI
        for _, reward in ipairs(REWARDS) do -- NOTES(JBK): Keep this ipairs because rewards metadata is being stored in the table.
            inst:DoTaskInTime(1 + (math.random()*2), spawnhound, reward, theta)
            theta = theta + PI/6
        end
        inst.components.stageactingprop:DisableProp(TUNING.CHARLIE_STAGE_RESET_TIME + (math.random()* TUNING.CHARLIE_STAGE_RESET_TIME_VARIABLE ))
    end
end

local function enablefn(inst)
    if inst.sg:HasStateTag("closed") then
        inst.sg:GoToState("open")
    end
end

local function disablefn(inst)
    if not inst.sg:HasStateTag("closed") then
        inst.sg:GoToState("close")
    end
end

local function on_stage_performance_begun(inst, script, cast)
    SetCameraFocus(inst, 1)

    inst._sic_usher_on_attacker = inst._sic_usher_on_attacker or function(member, data)
        for usher, _ in pairs(inst._ushers) do
            -- We'd prefer to suggest the target to the first usher we find
            -- that doesn't already have a target it's attacking.
            if not usher.components.combat:HasTarget() then
                usher.components.combat:SuggestTarget(data.attacker)
                break
            end
        end
    end

    if cast ~= nil then
        for role, data in pairs(cast) do
            data.castmember:ListenForEvent("attacked", inst._sic_usher_on_attacker)
        end
    end

    TheWorld:PushEvent("pausehounded", { source = inst })
end

local function on_stage_performance_ended(inst, ender, script, cast)
    SetCameraFocus(inst, 0)

    if cast ~= nil then
        for role, data in pairs(cast) do
            data.castmember:RemoveEventCallback("attacked", inst._sic_usher_on_attacker)
        end
    end

    TheWorld:PushEvent("unpausehounded", { source = inst })

    -- Clear the music irrelevant of how the stage performance ended
    inst._musictype:set(0)
end

local function spawn_stage_prefab(inst, angle, dist, prefab)
    local stage_position = inst:GetPosition()

    local offset = FindWalkableOffset(stage_position, angle, dist, nil, false, true)
        or Vector3FromTheta(angle, dist)

    local prefab_instance = SpawnPrefab(prefab)
    prefab_instance.Transform:SetPosition((stage_position + offset):Get())

    return prefab_instance
end

local function spawndollmannequin(inst, angle, dist)
    local mannequin = spawn_stage_prefab(inst, angle, dist, "sewing_mannequin")
    local mannequin_pos = mannequin:GetPosition()

    local dollmask = SpawnPrefab("mask_dollhat")
    dollmask.Transform:SetPosition(mannequin_pos.x, 0, mannequin_pos.z)

    local dollbody = SpawnPrefab("costume_doll_body")
    dollbody.Transform:SetPosition(mannequin_pos.x, 0, mannequin_pos.z)

    if mannequin.components.inventory then
        mannequin.components.inventory:Equip(dollmask)
        mannequin.components.inventory:Equip(dollbody)
    else
        Launch(dollmask, mannequin, 1)
        Launch(dollbody, mannequin, 1)
    end
end

--------------------------------------------------------------------------------
local USHERS_MUSTHAVE_TAGS = {"stageusher"}
local USHERS_CANTHAVE_TAGS = {"ghost", "player", "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt"}
local function setup(inst)
    if not inst.loaded then
        local x,y,z = inst.Transform:GetWorldPosition()

        local lecturn = SpawnPrefab("charlie_lecturn")
        local dist = 1.41 * 7.25
        local angle = -PI/6
        local offset = Vector3(dist * math.cos( angle ), 0, -dist * math.sin( angle ))
        lecturn.Transform:SetPosition(x+offset.x,0,z+offset.z)
        lecturn.components.playbill_lecturn:SetStage(inst)
        inst.components.entitytracker:TrackEntity("lecturn", lecturn)

        local playbill = SpawnPrefab("playbill_the_doll")
        lecturn.components.playbill_lecturn:SwapPlayBill(playbill)

        spawn_stage_prefab(inst, 0.25*PI, 1.41 * 6, "stageusher")
        spawn_stage_prefab(inst, 1.25*PI, 1.41 * 6, "stageusher")

        spawndollmannequin(inst, -PI/3, 1.41 * 7.25)
    end

    inst.components.stageactingprop:SpawnBirds(inst)

    inst.lip = SpawnPrefab("charlie_stage_lip")
    inst:AddChild(inst.lip)

    inst.floor = SpawnPrefab("charlie_stage")
    inst:AddChild(inst.floor)

    local increment = (PI/7)
    spawn_stage_prefab(inst,  -PI/4 + (increment*0.5),  6, "charlie_seat")
    spawn_stage_prefab(inst,  -PI/4 + (increment*1.5),  6, "charlie_seat")
    spawn_stage_prefab(inst,  -PI/4 - (increment*1.5),  6, "charlie_seat")
    spawn_stage_prefab(inst,  -PI/4 - (increment*0.5),  6, "charlie_seat")
    
    if inst:HasTag("stageactingprop") then
        enablefn(inst)
    else
        disablefn(inst)
    end

    -- Collect nearby ushers into our targetting list as we set up.
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local nearby_ushers = TheSim:FindEntities(
        ix, iy, iz, 22, USHERS_MUSTHAVE_TAGS, USHERS_CANTHAVE_TAGS
    )
    inst._unhook_usher = inst._unhook_usher or function(u)
        inst:RemoveEventCallback("onremove", inst._unhook_usher, u)
        inst._ushers[u] = nil
    end
    for _, usher in ipairs(nearby_ushers) do
        inst._ushers[usher] = true
        inst:ListenForEvent("onremove", inst._unhook_usher, usher)
    end
end

--------------------------------------------------------------------------------
local STAGE_RADIUS = 4.3
local REGISTERED_FIND_TEMPTILE_ENTITIES_TAGS = nil
local function OnUpdateStageTempTile(inst, x, y, z)
    if REGISTERED_FIND_TEMPTILE_ENTITIES_TAGS == nil then
        REGISTERED_FIND_TEMPTILE_ENTITIES_TAGS = TheSim:RegisterFindTags(
            {"locomotor"},
            {"flying", "ghost", "playerghost", "INLIMBO", "FX", "DECOR"}
        )
    end

    local temptile_entities = TheSim:FindEntities_Registered(x, y, z, STAGE_RADIUS, REGISTERED_FIND_TEMPTILE_ENTITIES_TAGS)
    if #temptile_entities > 0 then
        for _, temptile_entity in ipairs(temptile_entities) do
            temptile_entity.components.locomotor:PushTempGroundSpeedMultiplier(1.0, WORLD_TILES.MOSAIC_GREY)

            temptile_entity:PushEvent("onstage")
        end
    end
end

local function OnUpdateStageTempTile_Client(inst, x, y, z)
    if ThePlayer ~= nil and ThePlayer.components.locomotor ~= nil
            and not ThePlayer:HasTag("playerghost")
            and ThePlayer:GetDistanceSqToPoint(x, 0, z) < STAGE_RADIUS * STAGE_RADIUS then
        ThePlayer.components.locomotor:PushTempGroundSpeedMultiplier(1.0, WORLD_TILES.MOSAIC_GREY)
    end
end

local function setup_stage_temptile_test(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local temptile_test_fn = (TheWorld.ismastersim and OnUpdateStageTempTile) or OnUpdateStageTempTile_Client
    inst._temptile_test_task = inst:DoPeriodicTask(0, temptile_test_fn, nil, x, y, z)
    temptile_test_fn(inst, x, y, z)
end

local function on_stage_wake(inst)
    if inst._temptile_test_task == nil then
        setup_stage_temptile_test(inst)
    end
end

local function on_stage_sleep(inst)
    if inst._temptile_test_task ~= nil then
        inst._temptile_test_task:Cancel()
        inst._temptile_test_task = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("charlie_stage")
    inst.AnimState:SetBuild("charlie_Stage")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("stage")
    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.scrapbook_specialinfo = "CHARLIESTAGE"

    inst:DoTaskInTime(0, setup_stage_temptile_test)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.OnEntityWake = on_stage_wake
    inst.OnEntitySleep = on_stage_sleep

    return inst
end

local function lipfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("charlie_stage")
    inst.AnimState:SetBuild("charlie_stage")
    inst.AnimState:PlayAnimation("lip")
    inst.AnimState:SetFinalOffset(0)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)

    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.Transform:SetRotation(90)

    inst.Transform:SetScale(0.98,0.98,0.98)

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function onsave(inst,data)
    data.loaded = true
end
local function onload(inst,data)
    if data and data.loaded then
        inst.loaded = data.loaded
    end
end

local function postfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("charlie_curtains")
    inst.AnimState:SetBuild("charlie_curtains")
    inst.AnimState:PlayAnimation("idle_open")

    inst.MiniMapEntity:SetIcon("charlie_stage_post.png")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(181/255, 210/255, 247/255)
    inst.components.talker.offset = Vector3(0, -715, 0)

    inst._camerafocus = net_tinybyte(inst.GUID, "charlie_stage._camerafocus", "camerafocusdirty")
    inst._camerafocustask = nil

    inst._musictype = net_tinybyte(inst.GUID, "charlie_stage._musictype")
    inst._musictype:set_local(0)

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(-90)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)

        setup_stagepost_music_check(inst)

        return inst
    end
    
    inst:AddComponent("stageactingprop")
    inst.components.stageactingprop:SetEnabledFn(enablefn)
    inst.components.stageactingprop:SetDisabledFn(disablefn)
    inst.components.stageactingprop.onperformancebegun = on_stage_performance_begun
    inst.components.stageactingprop.onperformanceended = on_stage_performance_ended

    inst:AddComponent("inspectable")

    inst:AddComponent("entitytracker")

    inst:SetStateGraph("SGcharlie_stage_post")

    inst.SetMusicType = SetStagePostMusicType

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.OnEntityWake = OnStagePostWake
    inst.OnEntitySleep = OnStagePostSleep

    inst._ushers = {}
    inst._rewardpool = REWARDPOOL -- NOTES(JBK): Useful for mods.
    inst:ListenForEvent("play_performed", OnPlayPerformed)

    inst:DoTaskInTime(0, setup)

    MakeRoseTarget_CreateFuel(inst)

    return inst
end

local function seatfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("charlie_seat")
    inst.AnimState:SetBuild("charlie_seat")
    inst.AnimState:PlayAnimation("test")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("charlie_stage", fn, assets, prefabs),
       Prefab("charlie_stage_lip", lipfn, assets, prefabs),
       Prefab("charlie_stage_post", postfn, postassets, prefabs),
       Prefab("charlie_seat", seatfn, seatassets, prefabs)
