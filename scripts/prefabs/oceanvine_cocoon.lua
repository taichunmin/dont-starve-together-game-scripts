local assets =
{
    Asset("ANIM", "anim/oceanvine_cocoon.zip"),
    Asset("MINIMAP_IMAGE", "oceanvine_cocoon"),
}

local prefabs =
{
    "character_fire",
    "oceanvine_cocoon_burnt",
    "silk",
    "spider_water",
    "twigs",
}

local burnt_prefabs =
{
    "ash",
    "character_fire",
    "charcoal",
}

SetSharedLootTable('oceanvine_cocoon',
{
    { "silk", 1.0 },
    { "silk", 0.3 },
    { "silk", 0.3 },
    { "twigs", 1.0 },
})

local function play_hit(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")
end

local function cocoon_ignited(inst, source, doer)
    if inst:GetTimeAlive() > 5 then
        local children_released = inst.components.childspawner:ReleaseAllChildren()
        for _, child in ipairs(children_released) do
            child.sg:GoToState("dropper_enter")
        end
    end
    inst.components.childspawner:StopSpawning()

    inst.components.timer:PauseTimer("lookforfish")
end

local function go_to_burnt(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local burnt = SpawnPrefab("oceanvine_cocoon_burnt")
    burnt.Transform:SetPosition(ix, iy, iz)

    if inst._firefx ~= nil then
        inst._firefx:Remove()
    end

    inst:Remove()
end

local function cocoon_burnt(inst)
    inst:AddTag("burnt")
    inst:AddTag("notarget") -- Don't get attacked while we're doing the transition.

    inst.components.burnable.canlight = false
    inst.AnimState:PlayAnimation("burnt_pre")
    inst:PushEvent("burntup")

    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetEnabled(false)
    end

    inst._firefx = SpawnPrefab("character_fire")
    inst._firefx.entity:AddFollower()
    inst._firefx.Follower:FollowSymbol(inst.GUID, "swap_fire", 0, 0, 0)
    inst._firefx.persists = false
    if inst._firefx.components.firefx ~= nil then
        inst._firefx.components.firefx:SetLevel(5, true)
        inst._firefx.components.firefx:AttachLightTo(inst)
    end

    inst:ListenForEvent("animover", go_to_burnt)
end

local function cocoon_extinguish(inst)
    inst.components.childspawner:StartSpawning()

    inst.components.timer:ResumeTimer("lookforfish")
end

local function spawn_one_investigator(inst, target_position)
    local spider = inst.components.childspawner:SpawnChild(nil, nil, 4)
    if spider ~= nil then
        spider.sg:GoToState("dropper_enter")
        spider.components.timer:StartTimer("investigating", TUNING.SPIDER_WATER_INVESTIGATETIMEBASE + 5*math.random())

        if target_position ~= nil then
            spider.components.knownlocations:RememberLocation("investigate", target_position)
        end
    end
end

local function spawn_investigators(inst, data)
    if inst.components.childspawner == nil or inst.components.freezable:IsFrozen() then
        return
    end

    play_hit(inst)

    local target_position = nil

    local num_to_release = math.min(2, inst.components.childspawner.childreninside)
    for i = 1, num_to_release do
        target_position = target_position or (data and data.target and data.target:GetPosition()) or nil

        -- Use local tasks to space out the drops
        -- Could just leverage the timer here, potentially? But I want to pass off the position.
        inst:DoTaskInTime((i-1)*math.random() + (30*FRAMES), spawn_one_investigator, target_position)
    end
end

local function OnQuakeBegin(inst)
    if inst.components.childspawner ~= nil then
        for _, child in pairs(inst.components.childspawner.childrenoutside) do
            child._quaking = true
            if child.components.sleeper ~= nil then
                child.components.sleeper:WakeUp()
            end
        end
    end
end

local function OnQuakeEnd(inst)
    if inst.components.childspawner ~= nil then
        for _, child in pairs(inst.components.childspawner.childrenoutside) do
            child._quaking = nil
        end
    end
end

local SEE_FISH_DISTANCE = 10
local OCEANFISH_TAGS = {"oceanfish"}
local function look_for_fish(inst)
    local look_time = math.random()*TUNING.SEG_TIME
    if inst.components.childspawner.childreninside > 0 then
        -- If we don't have any children to send out, don't bother looking for anything.

        -- Just see if there's a fish somewhere near us. If so, send out a spider to where it is.
        local a_fish = FindEntity(inst, SEE_FISH_DISTANCE,
            function(fish)
                return TheWorld.Map:IsOceanAtPoint(fish.Transform:GetWorldPosition())
            end,
            OCEANFISH_TAGS)
        if a_fish ~= nil then
            -- Spawn out a spider, and send it to investigate.
            local spider = inst.components.childspawner:SpawnChild(nil, nil, 4)
            if spider ~= nil then
                spider.components.knownlocations:RememberLocation("investigate", a_fish:GetPosition())
                spider.sg:GoToState("dropper_enter")
                look_time = (2 + 2*math.random()) * TUNING.SEG_TIME
            end
        end
    end

    -- Irrelevant of whether we did the thing or not, start a timer for our next check.
    inst.components.timer:StartTimer("lookforfish", look_time)
end

local function OnFreeze(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
    inst.AnimState:PlayAnimation("frozen", true)
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

    inst.components.childspawner:StopSpawning()
end

local function OnThaw(inst)
    inst.AnimState:PlayAnimation("frozen_pst", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function OnUnFreeze(inst)
    inst.AnimState:PlayAnimation("idle", true)
    inst.SoundEmitter:KillSound("thawing")
    inst.AnimState:ClearOverrideSymbol("swap_frozen")

    inst.components.childspawner:StartSpawning()
end

local function OnHit(inst, attacker)
    if not inst.components.health:IsDead() then
        spawn_investigators(inst, {target = attacker})

        play_hit(inst)
    end
end

local COCOON_HOME_TAGS = { "cocoon_home" }
local function OnKilled(inst)
    inst.AnimState:PlayAnimation("death")

    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end

    RemovePhysicsColliders(inst)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_destroy")

    local c_pos = inst:GetPosition()
    inst.components.lootdropper:DropLoot(c_pos)

    local nearby_trees = TheSim:FindEntities(c_pos.x, 0, c_pos.z, TUNING.SHADE_CANOPY_RANGE, COCOON_HOME_TAGS)
    if #nearby_trees > 0 then
        nearby_trees[1]:PushEvent("cocoon_destroyed", c_pos)
    end
end

local function on_timer_finished(inst, data)
    if data.name == "lookforfish" then
        look_for_fish(inst)
    end
end

local function on_spider_returned(inst, data)
    if not inst.components.freezable:IsFrozen() then
        play_hit(inst)
    end
end

local function OnSave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt then
        cocoon_burnt(inst)
    end
end

local PRELOAD_RELEASETIME = TUNING.TOTAL_DAY_TIME / 2
local PRELOAD_REGENTIME = TUNING.TOTAL_DAY_TIME / 4
local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, PRELOAD_RELEASETIME, PRELOAD_REGENTIME)
end

local function SummonChildren(inst)
    if not inst.components.health:IsDead() and
            not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then
        play_hit(inst)

        if inst.components.childspawner ~= nil then
            local children_released = inst.components.childspawner:ReleaseAllChildren()

            if children_released then
                for _, v in ipairs(children_released) do
                    v:AddDebuff("spider_summoned_buff", "spider_summoned_buff")

                    v.sg:GoToState("dropper_enter")
                end
            end
        end
    end
end

local ZERO_VECTOR = Vector3(0,0,0)
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 1, 0.25)
    
    inst.DynamicShadow:SetSize(3.5, 2.0)

    inst.AnimState:SetBank("ocean_cocoon")
    inst.AnimState:SetBuild("oceanvine_cocoon")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetMultColour(0.75, 0.1, 1.0, 1)

    inst.MiniMapEntity:SetIcon("oceanvine_cocoon.png")

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("NOBLOCK")                  -- To not block boat deployment.
    inst:AddTag("plant")
    inst:AddTag("spidercocoon")
    inst:AddTag("webbed")

    if not TheNet:IsDedicated() then
        inst:AddComponent("distancefade")
        inst.components.distancefade:Setup(15, 25)
    end

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetBurnTime(15)
    inst.components.burnable:AddBurnFX("character_fire", ZERO_VECTOR, "swap_fire", true)
    inst.components.burnable:SetOnIgniteFn(cocoon_ignited)
    inst.components.burnable:SetOnBurntFn(cocoon_burnt)
    inst.components.burnable:SetOnExtinguishFn(cocoon_extinguish)

    MakeMediumPropagator(inst)

    MakeMediumFreezableCharacter(inst)
    inst:ListenForEvent("freeze", OnFreeze)
    inst:ListenForEvent("onthaw", OnThaw)
    inst:ListenForEvent("unfreeze", OnUnFreeze)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("oceanvine_cocoon")

    inst:AddComponent("inspectable")

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(TUNING.OCEANVINE_COCOON_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.OCEANVINE_COCOON_RELEASE_TIME)

    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.OCEANVINE_COCOON_REGEN_TIME, TUNING.OCEANVINE_ENABLED)
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.OCEANVINE_COCOON_RELEASE_TIME, TUNING.OCEANVINE_ENABLED)

    inst.components.childspawner:SetMaxChildren(math.random(TUNING.OCEANVINE_COCOON_MIN_CHILDREN, TUNING.OCEANVINE_COCOON_MAX_CHILDREN))
    if not TUNING.OCEANVINE_ENABLED then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartRegen()
    inst.components.childspawner:SetGoHomeFn(on_spider_returned)
    inst.components.childspawner.childname = "spider_water"
    inst.components.childspawner.emergencychildname = "spider_water"
    inst.components.childspawner.emergencychildrenperplayer = 1
    inst.components.childspawner.canemergencyspawn = TUNING.OCEANVINE_ENABLED
    inst.components.childspawner.allowwater = true
    inst.components.childspawner.allowboats = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("lookforfish", 2*math.random()*TUNING.SEG_TIME)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(200)

    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(OnHit)

    MakeSnowCovered(inst)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad
    inst.SummonChildren = SummonChildren -- For spider_whistle support.

    inst:ListenForEvent("death", OnKilled)
    inst:ListenForEvent("activated", spawn_investigators)
    inst:ListenForEvent("startquake", function() OnQuakeBegin(inst) end, TheWorld.net)
    inst:ListenForEvent("endquake", function() OnQuakeEnd(inst) end, TheWorld.net)
    inst:ListenForEvent("timerdone", on_timer_finished)

    return inst
end

local function OnBurntKilled(inst)
    -- We can only be attacked once.
    inst:AddTag("noattack")

    inst.AnimState:PlayAnimation("burnt_pst")

    inst.components.lootdropper:SpawnLootPrefab("ash")
    inst.components.lootdropper:SpawnLootPrefab("charcoal")

    inst:ListenForEvent("animover", inst.Remove)
end

local function burntfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 1, 0.25)

    inst.DynamicShadow:SetSize(2.25, 1.0)

    inst.AnimState:SetBank("ocean_cocoon")
    inst.AnimState:SetBuild("oceanvine_cocoon")
    inst.AnimState:PlayAnimation("burnt", true)

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)

    inst:AddComponent("lootdropper")

    inst:ListenForEvent("death", OnBurntKilled)

    return inst
end

return Prefab("oceanvine_cocoon", fn, assets, prefabs),
    Prefab("oceanvine_cocoon_burnt", burntfn, assets, burnt_prefabs)
