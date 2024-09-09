local AMBIENCE_SOUNDNAME = "amb"

local NIGHTVISION_AMBIENCE_SOUND =
{
    FRUITS = "meta4/ancienttree/nightvision/sway_lp",
    EMPTY  = "meta4/ancienttree/nightvision/sway_lp_nofruit",
}

local function NightVision_HideFruitLayer(inst)
    if inst.components.pickable ~= nil and not inst.components.pickable.caninteractwith then
        inst.AnimState:Hide("fruit")
        inst.AnimState:SetLightOverride(0)

        inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.EMPTY

        inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
        inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
    end
end

local function NightVision_StartPhaseTransitionTask(inst, fn)
    if inst._phasetask ~= nil then
        inst._phasetask:Cancel()
        inst._phasetask = nil
    end

    inst._phasetask = inst:DoTaskInTime(1 + math.random() * 2, fn)
end

local function NightVision_HideFruits(inst)
    inst._phasetask = nil

    if inst.components.pickable == nil or not inst.components.pickable:CanBePicked() then
        return
    end

    if inst.components.pickable.caninteractwith then
        inst.AnimState:PlayAnimation("retract_fruit_full")
        inst.AnimState:PushAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)
    end

    inst.components.pickable.caninteractwith = false

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - FRAMES, NightVision_HideFruitLayer)
end

local function NightVision_ShowFruits(inst)
    inst._phasetask = nil

    if inst.components.pickable == nil then
        return
    end

    inst.AnimState:Show("fruit")
    inst.AnimState:SetLightOverride(0.1)

    inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.FRUITS

    if not inst.components.pickable.caninteractwith then
        inst.AnimState:PlayAnimation("fruit_full")
        inst.AnimState:PushAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)

        inst.SoundEmitter:PlaySound(inst.sounds.onshowfruits)

        inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
        inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
    end

    inst.components.pickable.caninteractwith = true
end

local function NightVision_OnIsNight(inst, isnight, init)
    local pickable = inst.components.pickable

    if pickable == nil then
        inst:StopWatchingWorldState("isnight", inst._OnIsNight)

        return -- Stump, likely.
    end

    if isnight and not inst._showing_fruits and pickable:CanBePicked() then
        inst._showing_fruits = true

        if init or inst:IsAsleep() then
            inst.AnimState:Show("fruit")
            inst.AnimState:SetLightOverride(0.1)
            inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.FRUITS

            if not inst:IsAsleep() then
                inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
                inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
            end

            pickable.caninteractwith = true
        else
            inst:StartPhaseTransitionTask(NightVision_ShowFruits)
        end

    elseif not isnight and inst._showing_fruits then
        inst._showing_fruits = false

        if init or inst:IsAsleep() then
            inst.AnimState:Hide("fruit")
            inst.AnimState:SetLightOverride(0)
            inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.EMPTY

            if not inst:IsAsleep() then
                inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
                inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
            end

            pickable.caninteractwith = false
        else
            inst:StartPhaseTransitionTask(NightVision_HideFruits)
        end
    end
end

local function NightVision_OnPickedFn(inst, picker)
    inst.AnimState:Hide("fruit")
    inst.AnimState:SetLightOverride(0)
    inst._showing_fruits = false

    inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.EMPTY

    if not inst:IsAsleep() then
        inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
        inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
    end
end

local function NightVision_OnMakeEmptyFn(inst)
    inst.AnimState:Hide("fruit")
    inst.AnimState:SetLightOverride(0)
    inst._showing_fruits = false

    inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.EMPTY

    if not inst:IsAsleep() then
        inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
        inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
    end
end

local function _MakeEmpty(inst)
    if inst.components.pickable ~= nil then
        inst.components.pickable:MakeEmpty()
    end
end

local function NightVision_OnRegenFn(inst)
    if not inst:CanRegenFruits() then
        inst:DoTaskInTime(0, _MakeEmpty) -- Needs to be delayed because Pickable:Regen would mess with things set by MakeEmpty.

        return
    end

    if not (TheWorld.state.isnight or TheWorld:HasTag("cave")) then
        inst.components.pickable.caninteractwith = false

        return
    end

    inst.AnimState:Show("fruit")
    inst.AnimState:SetLightOverride(0.1)

    inst.sounds.ambience = NIGHTVISION_AMBIENCE_SOUND.FRUITS

    inst._showing_fruits = true

    if inst:IsAsleep() then
        inst.AnimState:PlayAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)
    else
        inst.AnimState:PlayAnimation("fruit_full")
        inst.AnimState:PushAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)

        inst.SoundEmitter:PlaySound(inst.sounds.onshowfruits)

        inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
        inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local TREE_DEFS =
{
    gem = {
        build = "ancienttree_gem",
        bank  = "ancienttree_gem",

        snowcovered = false,
        directional_fall = false,
        shelter = false,

        GROW_CONSTRAINT =
        {
            TILE = WORLD_TILES.ROCKY,
            SEASON = SEASONS.SUMMER,
        },

        workaction = "MINE",

        --shadow_size = 0,

        fruit_prefab = "ancientfruit_gem",
        numtoharvest = 3,

        LOOT =
        {
            full = {
                { "rocks",    1.0 },
                { "rocks",    1.0 },
                { "rocks",    1.0 },
                { "rocks",    0.5 },
                { "flint",    1.0 },
                { "flint",    0.5 },
                { "charcoal", 1.0 },
                { "charcoal", 0.5 },
            },

            stump = {
                { "rocks",    1.0 },
                { "rocks",    1.0 },
            },
        },

        sounds =
        {
            grow = "dontstarve/common/together/marble_shrub/grow",
            onshowfruits = "meta4/ancienttree/gemfruit/fruiting",
            onpicked = "dontstarve/wilson/harvest_sticks",
            onworkfinish = "dontstarve/forest/treefall", --TODO
            ambience = "meta4/ancienttree/gemfruit/sway_lp",
        },

        physics_rad = 1,

        common_postinit = function(inst)
            inst.AnimState:SetLightOverride(0.1)
            inst.AnimState:SetSymbolLightOverride("fire_parts", 0.5)
            inst.AnimState:SetSymbolLightOverride("fire_glow", 0.5)
            inst.AnimState:SetSymbolBloom("fire_parts")
        end,

        --master_postinit = function(inst)
            --
        --end,
    },

    nightvision = {
        build = "ancienttree_nightvision",
        bank  = "ancienttree_nightvision",

        snowcovered = true,
        directional_fall = true,
        shelter = true,

        GROW_CONSTRAINT =
        {
            TILE = WORLD_TILES.MARSH,
            SEASON = SEASONS.WINTER,
        },

        workaction = "CHOP",

        shadow_size = 4.5,

        fruit_prefab = "ancientfruit_nightvision",
        numtoharvest = 4,

        LOOT =
        {
            full = {
                { "log",      1.0 },
                { "log",      1.0 },
                { "log",      1.0 },
                { "log",      1.0 },
                { "log",      1.0 },
                { "log",      0.5 },
                { "twigs",    1.0 },
                { "twigs",    0.5 },
            },

            stump = {
                { "log",      1.0 },
                { "log",      1.0 },
            },
        },

        sounds =
        {
            grow = "dontstarve/common/together/marble_shrub/grow",
            onshowfruits = "meta4/ancienttree/nightvision/fruiting",
            onpicked = "dontstarve/wilson/harvest_sticks",
            onworkfinish = "dontstarve/forest/treefall",
            ambience = NIGHTVISION_AMBIENCE_SOUND.FRUITS,
        },

        physics_rad = 0.6,

        common_postinit = function(inst)
            inst.AnimState:SetLightOverride(0.1)
            inst.AnimState:SetSymbolLightOverride("fruit", 0.4)
        end,

        master_postinit = function(inst)
            if inst.components.pickable ~= nil then -- Full tree.
                inst._OnIsNight = NightVision_OnIsNight
                inst.StartPhaseTransitionTask = NightVision_StartPhaseTransitionTask

                inst._showing_fruits = true

                inst.components.pickable.onregenfn   = NightVision_OnRegenFn
                inst.components.pickable.onpickedfn  = NightVision_OnPickedFn
                inst.components.pickable.makeemptyfn = NightVision_OnMakeEmptyFn

                if TheWorld:HasTag("cave") then
                    inst:DoTaskInTime(0, inst._OnIsNight, true, true)
                else
                    inst:WatchWorldState("isnight", inst._OnIsNight)
                    inst:DoTaskInTime(0, inst._OnIsNight, TheWorld.state.isnight, true)
                end
            end
        end,
    },
}

local PLANT_DATA =
{
    fruit_regen = { min = 12 * TUNING.TOTAL_DAY_TIME, max = 25 * TUNING.TOTAL_DAY_TIME },
}

setmetatable(TREE_DEFS, {
    __newindex = function(t, k, v)
        v.modded = true
        rawset(t, k, v)
    end,
})


return { TREE_DEFS = TREE_DEFS, PLANT_DATA = PLANT_DATA }