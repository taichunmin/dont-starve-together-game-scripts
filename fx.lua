local function FinalOffset1(inst)
    inst.AnimState:SetFinalOffset(1)
end

local function FinalOffset2(inst)
    inst.AnimState:SetFinalOffset(2)
end

local function FinalOffset3(inst)
    inst.AnimState:SetFinalOffset(3)
end

local function FinalOffsetNegative1(inst)
    inst.AnimState:SetFinalOffset(-1)
end


local function GroundOrientation(inst)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
end

local function Bloom(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
end

local function BloomOrange(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
--    inst.AnimState:SetMultColour(204/255,131/255,57/255,1)
    inst.AnimState:SetMultColour(219/255,168/255,117/255,1)
    inst.AnimState:SetFinalOffset(1)
end

local function OceanTreeLeafFxFallUpdate(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Transform:SetPosition(x, y - inst.fall_speed * FRAMES, z)
end

local fx =
{
    {
        name = "sanity_raise",
        bank = "blocker_sanity_fx",
        build = "blocker_sanity_fx",
        anim = "raise",
        tintalpha = 0.5,
    },
    {
        name = "sanity_lower",
        bank = "blocker_sanity_fx",
        build = "blocker_sanity_fx",
        anim = "lower",
        tintalpha = 0.5,
    },
    {
        name = "die_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(90/255, 66/255, 41/255),
    },
    {
        name = "lightning_rod_fx",
        bank = "lightning_rod_fx",
        build = "lightning_rod_fx",
        anim = "idle",
    },
    {
        name = "splash",
        bank = "splash",
        build = "splash",
        anim = "splash",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = FinalOffset1,
    },
    {
        name = "ink_splash",
        bank = "squid_watershoot",
        build = "squid_watershoot",
        anim = "splash",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = FinalOffset1,
    },
    {
        name = "bile_splash",
        bank = "bird_bileshoot",
        build = "bird_bileshoot",
        anim = "splash",
        sound = "moonstorm/creatures/mutated_robin/bile_shoot_splash",
        fn = FinalOffset1,
    },
    {
        name = "frogsplash",
        bank = "splash",
        build = "splash",
        anim = "splash",
        sound = "dontstarve/frog/splash",
        fn = FinalOffset1,
    },
    {
        name = "waterballoon_splash",
        bank = "waterballoon",
        build = "waterballoon",
        anim = "used",
        sound = "dontstarve/creatures/pengull/splash",
    },
    {
        name = "balloon_pop_body",
        bank = "balloon_pop",
        build = "balloon_pop",
        anim = "pop_low",
        fn = FinalOffset1,
    },
    {
        name = "balloon_pop_head",
        bank = "balloon_pop",
        build = "balloon_pop",
        anim = "pop_high",
        fn = FinalOffset1,
    },
    {
        name = "spat_splat_fx",
        bank = "spat_splat",
        build = "spat_splat",
        anim = "idle",
    },
    {
        name = "spat_splash_fx_full",
        bank = "spat_splash",
        build = "spat_splash",
        anim = "full",
    },
    {
        name = "spat_splash_fx_med",
        bank = "spat_splash",
        build = "spat_splash",
        anim = "med",
    },
    {
        name = "spat_splash_fx_low",
        bank = "spat_splash",
        build = "spat_splash",
        anim = "low",
    },
    {
        name = "spat_splash_fx_melted",
        bank = "spat_splash",
        build = "spat_splash",
        anim = "melted",
    },
    {
        name = "icing_splat_fx",
        bank = "warg_gingerbread_splat",
        build = "warg_gingerbread_splat",
        anim = "idle",
    },
    {
        name = "icing_splash_fx_full",
        bank = "warg_gingerbread_splash",
        build = "warg_gingerbread_splash",
        anim = "full",
    },
    {
        name = "icing_splash_fx_med",
        bank = "warg_gingerbread_splash",
        build = "warg_gingerbread_splash",
        anim = "med",
    },
    {
        name = "icing_splash_fx_low",
        bank = "warg_gingerbread_splash",
        build = "warg_gingerbread_splash",
        anim = "low",
    },
    {
        name = "icing_splash_fx_melted",
        bank = "warg_gingerbread_splash",
        build = "warg_gingerbread_splash",
        anim = "melted",
    },
    {
        name = "small_puff",
        bank = "small_puff",
        build = "smoke_puff_small",
        anim = "puff",
        sound = "dontstarve/common/deathpoof",
    },
    {
        name = "sand_puff",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
    },
    {
        name = "sand_puff_large_front",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "sand_puff_large_back",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "shadow_puff",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(0, 0, 0),
        tintalpha = .5,
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
        end,
    },
    {
        name = "shadow_puff_solid",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(0, 0, 0),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
        end,
    },
    {
        name = "shadow_puff_large_front",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        transform = Vector3(1.5, 1.5, 1.5),
        tint = Vector3(0, 0, 0),
        tintalpha = .5,
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "shadow_puff_large_back",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        transform = Vector3(1.5, 1.5, 1.5),
        tint = Vector3(0, 0, 0),
        tintalpha = .5,
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "dirt_puff",
        bank = "small_puff",
        build = "smoke_puff_small",
        anim = "puff",
        fn = FinalOffset1,
        --sound = "dontstarve/common/deathpoof",
    },
    {
        name = "splash_ocean", -- this is for the old ocean
        bank = "splash",
        build = "splash_ocean",
        anim = "idle",
        sound = "turnoftides/common/together/water/splash/bird",
    },
    {
        name = "maxwell_smoke",
        bank = "max_fx",
        build = "max_fx",
        anim = "anim",
    },
    {
        name = "shovel_dirt",
        bank = "shovel_dirt",
        build = "shovel_dirt",
        anim = "anim",
    },
    {
        name = "mining_fx",
        bank = "mining_fx",
        build = "mining_fx",
        anim = "anim",
    },
    {
        name = "mining_ice_fx",
        bank = "mining_fx",
        build = "mining_ice_fx",
        anim = "anim",
    },
    --[[{
        name = "pine_needles",
        bank = "pine_needles",
        build = "pine_needles",
        anim = "fall",
    },]]
    {
        name = "pine_needles_chop",
        bank = "pine_needles",
        build = "pine_needles",
        anim = "chop",
    },
    {
        name = "green_leaves_chop",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_green",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "red_leaves_chop",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_red",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "orange_leaves_chop",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_orange",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "yellow_leaves_chop",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_yellow",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "purple_leaves_chop",
        bank = "tree_monster_fx",
        build = "tree_monster_fx",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "green_leaves",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_green",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "red_leaves",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_red",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "orange_leaves",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_orange",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "yellow_leaves",
        bank = "tree_leaf_fx",
        build = "tree_leaf_fx_yellow",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "purple_leaves",
        bank = "tree_monster_fx",
        build = "tree_monster_fx",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "sugarwood_leaf_fx",
        bank = "tree_leaf_fx_quagmire",
        build = "tree_leaf_fx_quagmire",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "sugarwood_leaf_fx_chop",
        bank = "tree_leaf_fx_quagmire",
        build = "tree_leaf_fx_quagmire",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "sugarwood_leaf_withered_fx",
        bank = "tree_leaf_fx_quagmire_withered",
        build = "tree_leaf_fx_quagmire_withered",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "sugarwood_leaf_withered_fx_chop",
        bank = "tree_leaf_fx_quagmire_withered",
        build = "tree_leaf_fx_quagmire_withered",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "tree_petal_fx_chop",
        bank = "tree_petal_fx",
        build = "tree_petal_fx",
        anim = "chop",
    },
    {
        name = "dr_warm_loop_1",
        bank = "diviningrod_fx",
        build = "diviningrod_fx",
        anim = "warm_loop",
        tint = Vector3(105/255, 160/255, 255/255),
    },
    {
        name = "dr_warm_loop_2",
        bank = "diviningrod_fx",
        build = "diviningrod_fx",
        anim = "warm_loop",
        tint = Vector3(105/255, 182/255, 239/255),
    },
    {
        name = "dr_warmer_loop",
        bank = "diviningrod_fx",
        build = "diviningrod_fx",
        anim = "warmer_loop",
        tint = Vector3(255/255, 163/255, 26/255),
    },
    {
        name = "dr_hot_loop",
        bank = "diviningrod_fx",
        build = "diviningrod_fx",
        anim = "hot_loop",
        tint = Vector3(181/255, 32/255, 32/255),
    },
    {
        name = "statue_transition",
        bank = "statue_ruins_fx",
        build = "statue_ruins_fx",
        anim = "transform_nightmare",
        tintalpha = 0.6,
    },
    {
        name = "statue_transition_2",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(0, 0, 0),
        tintalpha = 0.6,
    },
    {
        name = "slurper_respawn",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(0, 0, 0),
        tintalpha = 1.0,
    },
    {
        name = "pandorachest_reset",
        bank = "attune_fx",
        build = "attune_fx",
        anim = "attune_in",
        --sound = "dontstarve/maxwell/shadowmax_despawn",
        tint = Vector3(0, 0, 0),
        tintalpha = 0.6,
    },
    {
        name = "shadow_despawn",
        bank = "statue_ruins_fx",
        build = "statue_ruins_fx",
        anim = "transform_nightmare",
        sound = "dontstarve/maxwell/shadowmax_despawn",
        tintalpha = 0.6,
    },
    {
        name = "mole_move_fx",
        bank = "mole_fx",
        build = "mole_move_fx",
        anim = "move",
        nameoverride = STRINGS.NAMES.MOLE_UNDERGROUND,
        description = function(inst, viewer)
            return GetString(viewer, "DESCRIBE", { "MOLE", "UNDERGROUND" })
        end,
    },
    --[[{
        name = "sparklefx",
        bank = "sparklefx",
        build = "sparklefx",
        anim = "sparkle",
        sound = "dontstarve/common/chest_positive",
        tintalpha = 0.6,
    },]]
    {
        name = "chester_transform_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
    },
    {
        name = "emote_fx",
        bank = "emote_fx",
        build = "emote_fx",
        anim = "emote_fx",
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "tears",
        bank = "tears_fx",
        build = "tears",
        anim = "tears_fx",
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "spawn_fx_tiny",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "tiny",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        fn = FinalOffset1,
    },
    {
        name = "spawn_fx_small",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "small",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        fn = FinalOffset1,
    },
    {
        name = "spawn_fx_medium",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        fn = FinalOffset1,
    },
    {
        name = "spawn_fx_medium_static",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        fn = FinalOffset1,
        update_while_paused = true
    },
    --[[{
        name = "spawn_fx_large",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "large",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
    },]]
    --[[{
        name = "spawn_fx_huge",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "huge",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
    },]]
    {
        name = "spawn_fx_small_high",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "small_high",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
    },
    {
        name = "splash_snow_fx",
        bank = "splash",
        build = "splash_snow",
        anim = "idle",
        sound = "dontstarve_DLC001/common/firesupressor_impact",
    },
    {
        name = "icespike_fx_1",
        bank = "deerclops_icespike",
        build = "deerclops_icespike",
        anim = "spike1",
        sound = "dontstarve/creatures/deerclops/ice_small",
    },
    {
        name = "icespike_fx_2",
        bank = "deerclops_icespike",
        build = "deerclops_icespike",
        anim = "spike2",
        sound = "dontstarve/creatures/deerclops/ice_small",
    },
    {
        name = "icespike_fx_3",
        bank = "deerclops_icespike",
        build = "deerclops_icespike",
        anim = "spike3",
        sound = "dontstarve/creatures/deerclops/ice_small",
    },
    {
        name = "icespike_fx_4",
        bank = "deerclops_icespike",
        build = "deerclops_icespike",
        anim = "spike4",
        sound = "dontstarve/creatures/deerclops/ice_small",
    },
    {
        name = "shock_fx",
        bank = "shock_fx",
        build = "shock_fx",
        anim = "shock",
        sound = "dontstarve_DLC001/common/shocked",
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "werebeaver_shock_fx",
        bank = "shock_fx",
        build = "shock_fx",
        anim = "werebeaver_shock",
        sound = "dontstarve_DLC001/common/shocked",
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "weremoose_shock_fx",
        bank = "shock_fx",
        build = "shock_fx",
        anim = "weremoose_shock",
        sound = "dontstarve_DLC001/common/shocked",
        eightfaced = true,
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "weregoose_shock_fx",
        bank = "shock_fx",
        build = "shock_fx",
        anim = "weregoose_shock",
        sound = "dontstarve_DLC001/common/shocked",
        eightfaced = true,
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "weregoose_feathers1",
        bank = "weregoose_fx",
        build = "weregoose_fx",
        anim = "trail1",
        fn = function(inst)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_feathers2",
        bank = "weregoose_fx",
        build = "weregoose_fx",
        anim = "trail2",
        fn = function(inst)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_feathers3",
        bank = "weregoose_fx",
        build = "weregoose_fx",
        anim = "trail3",
        fn = function(inst)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_splash",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "idle",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_splash_med1",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_splash_med2",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary2",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_splash_less1",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary_small",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_splash_less2",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary_small2",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_ripple1",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "no_splash",
        fn = function(inst)
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "weregoose_ripple2",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "no_splash2",
        fn = function(inst)
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
            if inst.entity:GetParent() ~= nil then
                inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.entity:SetParent(nil)
            end
        end,
    },
    {
        name = "groundpound_fx",
        bank = "bearger_ground_fx",
        build = "bearger_ground_fx",
        sound = "dontstarve_DLC001/creatures/bearger/dustpoof",
        anim = "idle",
    },
    {
        name = "lavaarena_portal_player_fx",
        bank = "lavaarena_player_teleport",
        build = "lavaarena_player_teleport",
        anim = "idle", --NOTE: 6 blank frames at the start for audio syncing
        sound = "dontstarve/common/lava_arena/portal_player",
        bloom = true,
    },
    {
        name = "lavaarena_player_revive_from_corpse_fx",
        bank = "lavaarena_player_revive_fx",
        build = "lavaarena_player_revive_fx",
        anim = "player_revive",
        sound = "dontstarve/common/revive",
        bloom = true,
        fourfaced = true,
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "ember_short_fx",
        bank = "ember_particles",
        build = "lavaarena_ember_particles_fx",
        anim = "pre",
        bloom = true,
        animqueue = true,
        fn = function(inst) inst.AnimState:PushAnimation("loop", false) inst.AnimState:PushAnimation("pst", false) end,
    },
    {
        name = "lavaarena_creature_teleport_smoke_fx_1",
        bank = "lavaarena_creature_teleport_smoke_fx",
        build = "lavaarena_creature_teleport_smoke_fx",
        anim = "smoke_1",
    },
    {
        name = "lavaarena_creature_teleport_smoke_fx_2",
        bank = "lavaarena_creature_teleport_smoke_fx",
        build = "lavaarena_creature_teleport_smoke_fx",
        anim = "smoke_2",
    },
    {
        name = "lavaarena_creature_teleport_smoke_fx_3",
        bank = "lavaarena_creature_teleport_smoke_fx",
        build = "lavaarena_creature_teleport_smoke_fx",
        anim = "smoke_3",
    },
    {
        name = "shadowstrike_slash_fx",
        bank = "lavaarena_shadow_lunge_fx",
        build = "lavaarena_shadow_lunge_fx",
        anim = "line",
        transform = Vector3(1.25, 1.25, 1.25),
        eightfaced = true,
        fn = FinalOffset1,
    },
    {
        name = "shadowstrike_slash2_fx",
        bank = "lavaarena_shadow_lunge_fx",
        build = "lavaarena_shadow_lunge_fx",
        anim = "curve",
        transform = Vector3(1.25, 1.25, 1.25),
        eightfaced = true,
        fn = FinalOffset1,
    },
    {
        name = "firesplash_fx",
        bank = "dragonfly_ground_fx",
        build = "dragonfly_ground_fx",
        anim = "idle",
        bloom = true,
    },
    {
        name = "tauntfire_fx",
        bank = "dragonfly_fx",
        build = "dragonfly_fx",
        anim = "taunt",
        bloom = true,
    },
    {
        name = "attackfire_fx",
        bank = "dragonfly_fx",
        build = "dragonfly_fx",
        anim = "atk",
        bloom = true,
    },
    {
        name = "vomitfire_fx",
        bank = "dragonfly_fx",
        build = "dragonfly_fx",
        anim = "vomit",
        twofaced = true,
        bloom = true,
    },
    {
        name = "wathgrithr_spirit",
        bank = "wathgrithr_spirit",
        build = "wathgrithr_spirit",
        anim = "wathgrithr_spirit",
        sound = "dontstarve_DLC001/characters/wathgrithr/valhalla",
        sounddelay = .2,
    },


    {
        name = "battlesong_attach",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "attach",
    },
    {
        name = "battlesong_loop",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "fx_trebleclef",
    },
    {
        name = "battlesong_detach",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "detach",
    },

    {
        name = "battlesong_durability_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "fx_durability",
    },
    {
        name = "battlesong_healthgain_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "fx_healthgain",
    },
    {
        name = "battlesong_sanitygain_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "fx_sanitygain",
    },
    {
        name = "battlesong_sanityaura_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "fx_sanityaura",
    },
    {
        name = "battlesong_fireresistance_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "fx_fireresistance",
    },
    {
        name = "battlesong_instant_electric_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "quote_electric",
    },
    {
        name = "battlesong_instant_taunt_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "quote_taunt",
    },
    {
        name = "battlesong_instant_panic_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "quote_panic",
    },
    {
        name = "lucy_ground_transform_fx",
        bank = "lucy_axe_fx",
        build = "axe_transform_fx",
        anim = "transform_ground",
    },
    {
        name = "lucy_transform_fx",
        bank = "lucy_axe_fx",
        build = "axe_transform_fx",
        anim = "transform_chop",
    },
    {
        name = "werebeaver_transform_fx",
        bank = "werebeaver_fx",
        build = "werebeaver_fx",
        anim = "transform_back",
        sound = "dontstarve/common/deathpoof",
    },
    {
        name = "weremoose_transform_fx",
        bank = "weremoose_poof_fx",
        build = "weremoose_poof_fx",
        anim = "transform",
    },
    {
        name = "weremoose_transform2_fx",
        bank = "weremoose_poof_fx",
        build = "weremoose_poof_fx",
        anim = "transform2",
        sound = "dontstarve/common/deathpoof",
    },
    {
        name = "weremoose_revert_fx",
        bank = "weremoose_poof_fx",
        build = "weremoose_poof_fx",
        anim = "revert",
        sound = "dontstarve/common/deathpoof",
    },
    {
        name = "weregoose_transform_fx",
        bank = "weregoose_fx",
        build = "werebeaver_fx",
        anim = "transform_back",
        sound = "dontstarve/common/deathpoof",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("were_fur01", "weregoose_fx", "were_fur01")
        end,
    },
    {
        name = "attune_out_fx",
        bank = "attune_fx",
        build = "attune_fx",
        anim = "attune_out",
        sound = "dontstarve/ghost/ghost_haunt",
    },
    {
        name = "attune_in_fx",
        bank = "attune_fx",
        build = "attune_fx",
        anim = "attune_in",
        sound = "dontstarve/ghost/ghost_haunt",
    },
    {
        name = "attune_ghost_in_fx",
        bank = "attune_fx",
        build = "attune_fx",
        anim = "attune_ghost_in",
        sound = "dontstarve/ghost/ghost_haunt",
    },
    {
        name = "beefalo_transform_fx",
        bank = "beefalo_fx",
        build = "beefalo_fx",
        anim = "transform",
        --#TODO: this one
        sound = "dontstarve/ghost/ghost_haunt",
    },
    {
        name = "ghostflower_spirit1_fx",
        bank = "ghostflower",
        build = "ghostflower",
        anim = "fx1",
        sound = "dontstarve/characters/wendy/small_ghost/wisp",
    },
    {
        name = "ghostflower_spirit2_fx",
        bank = "ghostflower",
        build = "ghostflower",
        anim = "fx1",
        sound = "dontstarve/characters/wendy/small_ghost/wisp",

    },
    {
        name = "ghostlyelixir_slowregen_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_regen",
        sound = "dontstarve/characters/wendy/abigail/buff/gen",
        fn = FinalOffset3,
    },
    {
        name = "ghostlyelixir_fastregen_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_heal",
        sound = "dontstarve/characters/wendy/abigail/buff/gen",
        fn = FinalOffset3,
    },
    {
        name = "ghostlyelixir_shield_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_shield",
        sound = "dontstarve/characters/wendy/abigail/buff/shield",
        fn = FinalOffset3,
    },
    {
        name = "ghostlyelixir_attack_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_attack",
        sound = "dontstarve/characters/wendy/abigail/buff/attack",
        fn = FinalOffset3,
    },
    {
        name = "ghostlyelixir_speed_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_speed",
        sound = "dontstarve/characters/wendy/abigail/buff/speed",
        fn = FinalOffset3,
    },
    {
        name = "ghostlyelixir_retaliation_fx",
        bank = "abigail_vial_fx",
        build = "abigail_vial_fx",
        anim = "buff_retaliation",
        sound = "dontstarve/characters/wendy/abigail/buff/retaliation",
        fn = FinalOffset3,
    },
    {
        name = "ghostlyelixir_slowregen_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
	        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_regen_02")
		    inst.AnimState:SetFinalOffset(3)
		end,
    },
    {
        name = "ghostlyelixir_fastregen_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
	        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_heal_02")
		    inst.AnimState:SetFinalOffset(3)
		end,
    },
    {
        name = "ghostlyelixir_shield_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
	        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_shield_02")
		    inst.AnimState:SetFinalOffset(3)
		end,
    },
    {
        name = "ghostlyelixir_attack_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
	        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_attack_02")
		    inst.AnimState:SetFinalOffset(3)
		end,
    },
    {
        name = "ghostlyelixir_speed_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
	        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_speed_02")
		    inst.AnimState:SetFinalOffset(3)
		end,
    },
    {
        name = "ghostlyelixir_retaliation_dripfx",
        bank = "abigail_buff_drip",
        build = "abigail_vial_fx",
        anim = "abigail_buff_drip",
        fn = function(inst)
	        inst.AnimState:OverrideSymbol("fx_swap", "abigail_vial_fx", "fx_retaliation_02")
		    inst.AnimState:SetFinalOffset(3)
		end,
    },
    {
        name = "disease_puff",
        bank = "flies",
        build = "flies",
        anim = "flies_puff",
        sound = "dontstarve/common/flies_appear",
    },
    --[[{
        name = "disease_fx_small",
        bank = "disease_fx",
        build = "disease_fx",
        anim = "disease_small",
        sound = "dontstarve/common/together/diseased/small",
    },
    {
        name = "disease_fx",
        bank = "disease_fx",
        build = "disease_fx",
        anim = "disease",
        sound = "dontstarve/common/together/diseased/small",
    },
    {
        name = "disease_fx_tall",
        bank = "disease_fx",
        build = "disease_fx",
        anim = "disease_tall",
        sound = "dontstarve/common/together/diseased/big",
    },]]
    {
        name = "bee_poof_big",
        bank = "bee_poof",
        build = "bee_poof",
        anim = "anim",
        sound = "dontstarve/common/deathpoof",
        transform = Vector3(1.4, 1.4, 1.4),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(1)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/beeguard/puff", nil, .6)
        end,
    },
    {
        name = "bee_poof_small",
        bank = "bee_poof",
        build = "bee_poof",
        anim = "anim",
        sound = "dontstarve/common/deathpoof",
        transform = Vector3(1.4, 1.4, 1.4),
        fn = FinalOffset1,
    },
    {
        name = "honey_splash",
        bank = "honey_splash",
        build = "honey_splash",
        anim = "anim",
        nofaced = true,
        transform = Vector3(1.4, 1.4, 1.4),
        fn = FinalOffset1,
    },
    {
        name = "bundle_unwrap",
        bank = "bundle",
        build = "bundle",
        anim = "unwrap",
    },
    {
        name = "gift_unwrap",
        bank = "gift",
        build = "gift",
        anim = "unwrap",
    },
    {
        name = "redpouch_unwrap",
        bank = "redpouch",
        build = "redpouch",
        anim = "unwrap",
    },
    {
        name = "redpouch_yotp_unwrap",
        bank = "redpouch",
        build = "redpouch",
        anim = "unwrap",
    },
    {
        name = "redpouch_yotc_unwrap",
        bank = "redpouch",
        build = "redpouch",
        anim = "unwrap",
    },
    {
        name = "redpouch_yotb_unwrap",
        bank = "redpouch",
        build = "redpouch",
        anim = "unwrap",
    },
    {
        name = "redpouch_yot_catcoon_unwrap",
        bank = "redpouch",
        build = "redpouch",
        anim = "unwrap",
    },
    {
        name = "yotc_seedpacket_unwrap",
        bank = "bundle",
        build = "bundle",
        anim = "unwrap",
    },
    {
        name = "yotc_seedpacket_rare_unwrap",
        bank = "bundle",
        build = "bundle",
        anim = "unwrap",
    },
    {
        name = "carnival_seedpacket_unwrap",
        bank = "bundle",
        build = "bundle",
        anim = "unwrap",
    },
    {
        name = "wetpouch_unwrap",
        bank = "wetpouch",
        build = "wetpouch",
        anim = "unwrap",
    },
    {
        name = "hermit_bundle_unwrap",
        bank = "hermit_bundle",
        build = "hermit_bundle",
        anim = "unwrap",
    },
    {
        name = "hermit_bundle_shells_unwrap",
        bank = "hermit_bundle",
        build = "hermit_bundle",
        anim = "unwrap",
    },
    {
        name = "quagmire_seedpacket_unwrap",
        bank = "quagmire_seedpacket",
        build = "quagmire_seedpacket",
        anim = "unwrap",
    },
    {
        name = "quagmire_crate_unwrap",
        bank = "quagmire_crate",
        build = "quagmire_crate",
        anim = "unwrap",
    },
    {
        name = "sinkhole_spawn_fx_1",
        bank = "sinkhole_spawn_fx",
        build = "sinkhole_spawn_fx",
        anim = "idle1",
    },
    {
        name = "sinkhole_spawn_fx_2",
        bank = "sinkhole_spawn_fx",
        build = "sinkhole_spawn_fx",
        anim = "idle2",
    },
    {
        name = "sinkhole_spawn_fx_3",
        bank = "sinkhole_spawn_fx",
        build = "sinkhole_spawn_fx",
        anim = "idle3",
    },
    {
        name = "sinkhole_warn_fx_1",
        bank = "sinkhole_spawn_fx",
        build = "sinkhole_spawn_fx",
        anim = "idle1",
        transform = Vector3(0.75, 0.75, 0.75),
        fn = function(inst) inst.entity:AddSoundEmitter():PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 0.01 }) end,
    },
    {
        name = "sinkhole_warn_fx_2",
        bank = "sinkhole_spawn_fx",
        build = "sinkhole_spawn_fx",
        anim = "idle2",
        transform = Vector3(0.75, 0.75, 0.75),
        fn = function(inst) inst.entity:AddSoundEmitter():PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 0.01 }) end,
    },
    {
        name = "sinkhole_warn_fx_3",
        bank = "sinkhole_spawn_fx",
        build = "sinkhole_spawn_fx",
        anim = "idle3",
        transform = Vector3(0.75, 0.75, 0.75),
        fn = function(inst) inst.entity:AddSoundEmitter():PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 0.01 }) end,
    },
    {
        name = "cavein_debris",
        bank = "cavein_debris_fx",
        build = "cavein_debris_fx",
        anim = "anim",
        fn = function(inst) inst.entity:AddSoundEmitter():PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 0 }) end,
    },
    {
        name = "glass_fx",
        bank = "mining_fx",
        build = "mining_ice_fx",
        anim = "anim",
        sound = "dontstarve/creatures/together/antlion/sfx/sand_to_glass",
    },
    {
        name = "erode_ash",
        bank = "erode_ash",
        build = "erode_ash",
        anim = "idle",
        sound = "dontstarve/common/dust_blowaway",
    },
    {
        name = "sleepbomb_burst",
        bank = "sleepbomb",
        build = "sleepbomb",
        anim = "used",
        sound = "dontstarve/common/together/infection_burst",
    },
    {
        name = "quagmire_portal_player_fx",
        bank = "quagmire_portalspawn_fx",
        build = "quagmire_portalspawn_fx",
        anim = "idle",
        sound = "dontstarve/quagmire/common/portal/spawn",
        fn = FinalOffset1,
    },
    {
        name = "quagmire_portal_playerdrip_fx",
        bank = "quagmire_portaldrip_fx",
        build = "quagmire_portaldrip_fx",
        anim = "idle",
    },
    {
        name = "quagmire_portal_player_splash_fx",
        bank = "quagmire_portalspawn_fx",
        build = "quagmire_portalspawn_fx",
        anim = "exit",
        sound = "dontstarve/creatures/pengull/splash",
        fn = FinalOffset1,
    },
    {
        name = "quagmire_salting_plate_fx",
        bank = "quagmire_salting_fx",
        build = "quagmire_salting_fx",
        anim = "plate",
        sound = "dontstarve/quagmire/common/cooking/salt_shake",
        fn = FinalOffset1,
    },
    {
        name = "quagmire_salting_bowl_fx",
        bank = "quagmire_salting_fx",
        build = "quagmire_salting_fx",
        anim = "bowl",
        sound = "dontstarve/quagmire/common/cooking/salt_shake",
        fn = FinalOffset1,
    },
    {
        name = "halloween_firepuff_1",
        bank = "halloween_embers",
        build = "halloween_embers",
        anim = "puff_1",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "halloween_firepuff_2",
        bank = "halloween_embers",
        build = "halloween_embers",
        anim = "puff_2",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "halloween_firepuff_3",
        bank = "halloween_embers",
        build = "halloween_embers",
        anim = "puff_3",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "halloween_firepuff_cold_1",
        bank = "halloween_embers_cold",
        build = "halloween_embers_cold",
        anim = "puff_1",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "halloween_firepuff_cold_2",
        bank = "halloween_embers_cold",
        build = "halloween_embers_cold",
        anim = "puff_2",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "halloween_firepuff_cold_3",
        bank = "halloween_embers_cold",
        build = "halloween_embers_cold",
        anim = "puff_3",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "halloween_moonpuff",
        bank = "fx_moon_tea",
        build = "moon_tea_fx",
        anim = "puff",
        bloom = true,
        sound = "dontstarve/common/fireAddFuel",
        fn = FinalOffset3,
    },
    {
        name = "mudpuddle_splash",
        bank = "mudsplash",
        build = "mudsplash",
        anim = "anim",
        sound = "dontstarve/creatures/pengull/splash",
        fn = FinalOffset3,
    },
    {
        name = "slide_puff",
        bank = "fx_slidepuff",
        build = "slide_puff",
        anim = "anim",
        fn = FinalOffset1,
    },
    {
        name = "fx_boat_crackle",
        bank = "fx_boat_crack",
        build = "fx_boat_crackle",
        anim = "crackle",
    },
    {
        name = "fx_boat_pop",
        bank = "fx_boat_pop",
        build = "fx_boat_pop",
        anim = "pop",
    },
    {
        name = "boat_mast_sink_fx",
        bank = "mast_01",
        build = "boat_mast2_wip",
        anim = "sink",
    },
    {
        name = "boat_malbatross_mast_sink_fx",
        bank = "mast_malbatross",
        build = "boat_mast_malbatross_build",
        anim = "sink",
    },
    {
        name = "mining_moonglass_fx",
        bank = "glass_mining_fx",
        build = "glass_mining_fx",
        anim = "anim",
    },
    {
        name = "splash_sink",
        bank = "splash_water_drop",
        build = "splash_water_drop",
        anim = "idle_sink",
        fn = function(inst) inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT) end,
        sound = "turnoftides/common/together/water/splash/small",
    },
    {
        name = "ocean_splash_med1",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
			inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ocean_splash_med2",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary2",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
			inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ocean_splash_small1",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary_small",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
			inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ocean_splash_small2",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "stationary_small2",
        sound = "turnoftides/common/together/water/splash/bird",
        fn = function(inst)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
			inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "ocean_splash_ripple1",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "no_splash",
        fn = function(inst)
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
        end,
    },
    {
        name = "ocean_splash_ripple2",
        bank = "splash_weregoose_fx",
        build = "splash_water_drop",
        anim = "no_splash2",
        fn = function(inst)
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
        end,
    },
    {
        name = "washashore_puddle_fx",
        bank = "water_puddle",
        build = "water_puddle",
        anim = "puddle",
        fn = function(inst) inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND) inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround) end,
    },
    {
        name = "round_puff_fx_sm",
        bank = "round_puff_fx",
        build = "round_puff_fx",
        anim = "puff_sm",
        sound = "dontstarve/characters/woodie/moose/hit",
        fn = FinalOffset1,
    },
    {
        name = "round_puff_fx_lg",
        bank = "round_puff_fx",
        build = "round_puff_fx",
        anim = "puff_lg",
        sound = "dontstarve/characters/woodie/moose/hit",
        fn = FinalOffset1,
    },
    {
        name = "round_puff_fx_hi",
        bank = "round_puff_fx",
        build = "round_puff_fx",
        anim = "puff_hi",
    },
	{
		name = "wood_splinter_jump",
		bank = "cookiecutter_fx",
		build = "cookiecutter_fx",
		anim = "wood_splinter_jump",
	},
	{
		name = "wood_splinter_drill",
		bank = "cookiecutter_fx",
		build = "cookiecutter_fx",
		anim = "wood_splinter_drill",
	},

    {
        name = "splash_green_small",
        bank = "pond_splash_fx",
        build = "pond_splash_fx",
        anim = "pond_splash",
        sound = "turnoftides/common/together/water/splash/small",
        fn = FinalOffset1,
    },
    {
        name = "splash_green",
        bank = "pond_splash_fx",
        build = "pond_splash_fx",
        anim = "pond_splash",
        sound = "turnoftides/common/together/water/splash/medium",
        fn = function(inst) inst.Transform:SetScale(2,2,2) inst.AnimState:SetFinalOffset(1) end,
    },
    {
        name = "splash_green_large",
        bank = "pond_splash_fx",
        build = "pond_splash_fx",
        anim = "pond_splash",
        sound = "turnoftides/common/together/water/splash/large",
        fn = function(inst) inst.Transform:SetScale(4,4,4) inst.AnimState:SetFinalOffset(1) end,
    },
--[[  There is art for these. They are just not used anywhere
    {
        name = "splash_teal",
        bank = "pond_splash_fx",
        build = "pond_splash_fx",
        anim = "cave_splash",
    },
    {
        name = "splash_black",
        bank = "pond_splash_fx",
        build = "pond_splash_fx",
        anim = "swamp_splash",
    },
    ]]
    {
        name = "merm_king_splash",
        bank = "merm_king_splash",
        build = "merm_king_splash",
        anim = "merm_king_splash",
        fn = FinalOffset1,
    },
    {
        name = "merm_splash",
        bank = "merm_splash",
        build = "merm_splash",
        anim = "merm_splash",
        fn = FinalOffset1,
    },
    {
        name = "merm_spawn_fx",
        bank = "merm_spawn_fx",
        build = "merm_spawn_fx",
        anim = "splash",
        fn = FinalOffset1,
    },
    {
        name = "ink_puddle_land",
        bank = "squid_puddle",
        build = "squid_puddle",
        anim = "puddle_dry",
        fn = GroundOrientation,
    },
    {
        name = "ink_puddle_water",
        bank = "squid_puddle",
        build = "squid_puddle",
        anim = "puddle_wet",
        fn = GroundOrientation,
    },

    {
        name = "bile_puddle_land",
        bank = "squid_puddle",
        build = "bird_puddle",
        anim = "puddle_dry",
        fn = GroundOrientation,
    },
    {
        name = "bile_puddle_water",
        bank = "squid_puddle",
        build = "bird_puddle",
        anim = "puddle_wet",
        fn = GroundOrientation,
    },

    {
        name = "flotsam_puddle",
        bank = "flotsam",
        build = "flotsam",
        anim = "puddle",
        sound = "dontstarve/creatures/monkey/poopsplat",
        fn = function(inst)
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        end,
    },
    {
        name = "flotsam_break",
        bank = "flotsam",
        build = "flotsam",
        anim = "break",
    },
    {
        name = "winters_feast_depletefood",
        bank = "winters_feast_table_fx",
        build = "winters_feast_table_fx",
        anim = "1",
		bloom = true,
        fn = function(inst)
			inst.AnimState:SetLightOverride(1)
            inst.AnimState:PlayAnimation(math.random(1, 5))
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "winters_feast_food_depleted",
        bank = "winters_feast_table_fx",
        build = "winters_feast_table_fx",
        anim = "burst",
        --sound = ,
        fn = function(inst)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:SetFinalOffset(3)
        end,
    },
    {
        name = "miniboatlantern_loseballoon",
        bank = "lantern_boat",
        build = "yotc_lantern_boat",
        anim = "balloon_fly",
        fn = function(inst)
            inst.Transform:SetSixFaced()
        end,
    },

    {
        name = "crab_king_bubble1",
        bank = "Bubble_fx",
        build ="crab_king_bubble_fx",
        anim = "bubbles_1",
        fn = FinalOffset1,
    },
    {
        name = "crab_king_bubble2",
        bank = "Bubble_fx",
        build ="crab_king_bubble_fx",
        anim = "bubbles_2",
        fn = FinalOffset1,
    },
    {
        name = "crab_king_bubble3",
        bank = "Bubble_fx",
        build ="crab_king_bubble_fx",
        anim = "bubbles_3",
        fn = FinalOffset1,
    },
    {
        name = "crab_king_waterspout",
        bank = "Bubble_fx",
        build ="crab_king_bubble_fx",
        anim = "waterspout",
        sound = "hookline_2/creatures/boss/crabking/waterspout",
        fn = FinalOffset1,
    },
    {
        name = "crab_king_shine",
        bank = "crab_king_shine",
        build ="crab_king_shine",
        anim = "shine",
        fn = Bloom,
    },
    {
        name = "crab_king_icefx",
        bank = "deer_ice_flakes",
        build ="deer_ice_flakes",
        anim = "idle",
        fn = Bloom,
    },
    {
        name = "crabking_ring_fx",
        bank = "crabking_ring_fx",
        build ="crabking_ring_fx",
        anim = "idle",
        fn = GroundOrientation,
    },
    {
        name = "mushroomsprout_glow",
        bank = "mushroomsprout_glow",
        build ="mushroomsprout_glow",
        anim = "mushroomsprout_glow",
        fn = FinalOffset1,
    },
    {
        name = "messagebottle_break_fx",
        bank = "bottle",
        build ="bottle",
        anim = "break",
        sound = "dontstarve/creatures/monkey/poopsplat",
    },
    {
        name = "messagebottle_bob_fx",
        bank = "bottle",
        build ="bottle",
        anim = "bob",
    },
    {
        name = "singingshell_creature_rockfx",
        bank = "singingshell_creature_rockfx",
        build ="singingshell_creature_rockfx",
        anim = "idle",
    },
    {
        name = "singingshell_creature_woodfx",
        bank = "singingshell_creature_woodfx",
        build ="singingshell_creature_woodfx",
        anim = "idle",
    },
    {
        name = "shadowhand_fx",
        bank = "shadowhand_fx",
        build ="shadowhand_fx",
        anim = "idle",
    },
    {
        name = "waterstreak_burst",
        bank = "waterstreak",
        build = "waterstreak",
        anim = "used",
        sixfaced = true,
        sound = "turnoftides/common/together/water/splash/small",
    },
    {
        name = "waterplant_burr_burst",
        bank = "barnacle_burr",
        build = "barnacle_burr",
        anim = "used",
        sound = "dangerous_sea/creatures/water_plant/burr_burst",
    },
    {
        name = "waterplant_destroy",
        bank = "collapse",
        build = "structure_collapse_fx",
        anim = "collapse_small",
        sound = "dangerous_sea/creatures/water_plant/grow",
    },
    {
        name = "mastupgrade_lightningrod_fx",
        bank = "mastupgrade_lightningrod_fx",
        build = "mastupgrade_lightningrod_fx",
        anim = "idle",
    },
    {
        name = "shadow_teleport_in",
        bank = "shadow_teleport",
        build = "shadow_teleport",
        anim = "portal_in",
        fn = GroundOrientation,
    },
    {
        name = "shadow_teleport_out",
        bank = "shadow_teleport",
        build = "shadow_teleport",
        anim = "portal_out",
        fn = GroundOrientation,
    },
    {
        name = "spore_moon_coughout",
        bank = "spore_moon",
        build = "mushroom_spore_moon",
        anim = "pre_cough_out",
    },
    {
        name = "archive_lockbox_player_fx",
        bank = "archive_lockbox_player_fx",
        build = "archive_lockbox_player_fx",
        anim = "activation",
        fn = FinalOffset1,
    },
    {
        name = "moon_altar_link_fx",
        bank = "moon_altar_link_fx",
        build ="moon_altar_link_fx",
        anim = "fx1",
        fn = function(inst)
            local rand = math.random()
            if rand < 0.33 then
                inst.AnimState:PlayAnimation("fx2")
            elseif rand < 0.67 then
                inst.AnimState:PlayAnimation("fx3")
            end
        end
    },
    {
        name = "farm_plant_happy",
        bank = "farm_plant_happiness",
        build = "farm_plant_happiness",
        anim = "happy",
        fn = FinalOffset1,
    },
    {
        name = "farm_plant_unhappy",
        bank = "farm_plant_happiness",
        build = "farm_plant_happiness",
        anim = "unhappy",
        fn = FinalOffset1,
    },
    {
        name = "yotb_confetti",
        bank = "beefalo_fx",
        build = "beefalo_fx",
        anim = "transform",
    },
    {
        name = "carnival_confetti_fx",
        bank = "carnival_confetti",
        build = "carnival_confetti",
        anim = "win",
        fn = FinalOffset1,
        sound = "summerevent/cannon/fire1",
    },
    {
        name = "carnival_sparkle_fx",
        bank = "carnival_sparkle",
        build = "carnival_sparkle",
        anim = "sparkle",
        fn = FinalOffset1,
        sound = "summerevent/cannon/fire2",
    },
    {
        name = "carnival_streamer_fx",
        bank = "carnival_streamer",
        build = "carnival_streamer",
        anim = "streamer",
        fn = FinalOffset1,
        sound = "summerevent/cannon/fire3",
    },
    {
        name = "carnival_unwrap_fx",
        bank = "carnival_unwrap",
        build = "carnival_unwrap",
        anim = "unwrap",
        fn = FinalOffset1,
    },
    {
        name = "alterguardian_spike_breakfx",
        bank = "alterguardian_spike",
        build = "alterguardian_spike",
        anim = "spike_pst",
    },
    {
        name = "alterguardian_spintrail_fx",
        bank = "alterguardian_sinkhole",
        build = "alterguardian_sinkhole",
        anim = "pre",
        animqueue = true,
        fn = function(inst)
            GroundOrientation(inst)
            inst.Transform:SetEightFaced()

            inst.AnimState:PushAnimation("idle", true)
            inst:DoTaskInTime(60*FRAMES, function(i)
                ErodeAway(i, 60*FRAMES)
            end)
        end,
    },
    {
        name = "moon_device_break_stage2",
        bank = "moon_device_break",
        build = "moon_device_break",
        anim = "stage2_break",
        fn = function(inst)
            inst.Transform:SetEightFaced()
        end,
    },
    {
        name = "moon_device_break_stage3",
        bank = "moon_device_break",
        build = "moon_device_break",
        anim = "stage3_break",
    },
    {
        name = "moonstorm_glass_ground_fx",
        bank = "moonglass_charged",
        build = "moonglass_charged_tile",
        anim = "explosion",
        fn = GroundOrientation,
    },
    {
        name = "moonstorm_glass_fx",
        bank = "moonglass_charged",
        build = "moonglass_charged_tile",
        anim = "crack_fx",
    },
    {
        name = "moonstorm_spark_shock_fx",
        bank = "shock_fx",
        build = "shock_fx",
        anim = "weremoose_shock",
        sound = "moonstorm/common/moonstorm/spark_attack",
        eightfaced = true,
        autorotate = true,
        fn = FinalOffset1,
    },
    {
        name = "alterguardian_phase1fallfx",
        bank = "alterguardian_spawn_death",
        build = "alterguardian_spawn_death",
        anim = "fall_pre",
    },
    {
        name = "moon_geyser_explode",
        bank = "moon_altar_geyser",
        build = "moon_geyser",
        anim = "explode",
    },
    {
        name = "moonpulse_fx",
        bank = "moon_altar_geyser",
        build = "moon_geyser",
        anim = "moonpulse",
        fn = function(inst)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end,
    },
    {
        name = "moonpulse2_fx",
        bank = "moon_altar_geyser",
        build = "moon_geyser",
        anim = "moonpulse2",
        fn = function(inst)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end,
    },
    {
        name = "alterguardian_phase3trappst",
        bank = "alterguardian_meteor",
        build = "alterguardian_meteor",
        anim = "meteor_pst",
        sound = "turnoftides/common/together/moon_glass/mine",
    },

    {
        name = "oldager_become_younger_front_fx",
        bank = "wanda_time_fx",
        build = "wanda_time_fx",
        anim = "younger_top",
        nofaced = true,
        fn = FinalOffset1,
    },
    {
        name = "oldager_become_younger_back_fx",
        bank = "wanda_time_fx",
        build = "wanda_time_fx",
        anim = "younger_bottom",
        nofaced = true,
        fn = FinalOffsetNegative1,
    },
    {
        name = "oldager_become_older_fx",
        bank = "wanda_time_fx",
        build = "wanda_time_fx",
        anim = "older",
        nofaced = true,
        fn = FinalOffset1,
    },

    {
        name = "oldager_become_younger_front_fx_mount",
        bank = "wanda_time_fx_mount",
        build = "wanda_time_fx_mount",
        anim = "younger_top",
        nofaced = true,
        fn = FinalOffset1,
    },
    {
        name = "oldager_become_younger_back_fx_mount",
        bank = "wanda_time_fx_mount",
        build = "wanda_time_fx_mount",
        anim = "younger_bottom",
        nofaced = true,
        fn = FinalOffsetNegative1,
    },
    {
        name = "oldager_become_older_fx_mount",
        bank = "wanda_time_fx_mount",
        build = "wanda_time_fx_mount",
        anim = "older",
        nofaced = true,
        fn = FinalOffset1,
    },

    {
        name = "wanda_attack_pocketwatch_old_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function() return "idle_big_"..math.random(3) end,
        sound = "wanda2/characters/wanda/watch/weapon/shadow_hit_old",
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_pocketwatch_normal_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function() return "idle_med_"..math.random(3) end,
        sound = "wanda2/characters/wanda/watch/weapon/nightmare_FX",
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_shadowweapon_old_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function() return "idle_big_"..math.random(3) end,
        sound = "wanda2/characters/wanda/watch/weapon/shadow_hit",
        fn = function(inst)
			inst.AnimState:Hide("white")
			inst.AnimState:SetFinalOffset(1)
		end,
    },
    {
        name = "wanda_attack_shadowweapon_normal_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function() return "idle_med_"..math.random(3) end,
        sound = "wanda2/characters/wanda/watch/weapon/nightmare_FX",
        fn = FinalOffset1,
    },

	{
        name = "pocketwatch_heal_fx",
        bank = "pocketwatch_cast_fx",
        build = "pocketwatch_casting_fx",
        anim = "pocketwatch_heal_fx", --NOTE: 16 blank frames at the start for audio syncing
        --sound = "dontstarve/common/lava_arena/portal_player",
        fn = FinalOffset1,
        bloom = true,
    },
	{
        name = "pocketwatch_heal_fx_mount",
        bank = "pocketwatch_casting_fx_mount",
        build = "pocketwatch_casting_fx_mount",
        anim = "pocketwatch_heal_fx", --NOTE: 16 blank frames at the start for audio syncing
        --sound = "dontstarve/common/lava_arena/portal_player",
        fn = FinalOffset1,
        bloom = true,
    },

	{
        name = "pocketwatch_ground_fx",
        bank = "pocketwatch_cast_fx",
        build = "pocketwatch_casting_fx",
        anim = "pocketwatch_ground", --NOTE: 16 blank frames at the start for audio syncing
        --sound = "dontstarve/common/lava_arena/portal_player",
        fn = GroundOrientation,
        bloom = true,
    },

    {
        name = "spider_mutate_fx",
        bank = "mutate_fx",
        build = "mutate_fx",
        anim = "mutate",
        nofaced = true,
    },

    {
        name = "spider_heal_fx",
        bank = "heal_fx",
        build = "spider_heal_fx",
        anim = "heal",
    },

    {
        name = "spider_heal_target_fx",
        bank = "heal_fx",
        build = "spider_heal_fx",
        anim = "heal_buff",
    },

    {
        name = "spider_heal_ground_fx",
        bank = "heal_fx",
        build = "spider_heal_fx",
        anim = "heal_aoe",
        fn = GroundOrientation,
    },

    {
        name = "treegrowthsolution_use_fx",
        bank = "treegrowthsolution",
        build = "treegrowthsolution",
        anim = "use",
        sound = "waterlogged1/common/use_figjam",
    },
    {
        name = "oceantree_leaf_fx_fall",
        bank = "oceantree_leaf_fx",
        build = "oceantree_leaf_fx",
        anim = "fall",
        fn = function(inst)
            local scale = 1 + 0.3 * math.random()
            inst.Transform:SetScale(scale, scale, scale)
            inst.fall_speed = 2.75 + 3.5 * math.random()
            inst:DoPeriodicTask(FRAMES, OceanTreeLeafFxFallUpdate)
        end,
    },
    {
        name = "oceantree_leaf_fx_chop",
        bank = "oceantree_leaf_fx",
        build = "oceantree_leaf_fx",
        anim = "chop",
    },
    {
        name = "boss_ripple_fx",
        bank = "malbatross_ripple",
        build = "malbatross_ripple",
        anim = "idle",
        fn = function(inst)
            inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
            inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.BOAT_TRAIL)
            inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
        end,
    },
    {
        name = "wolfgang_mighty_fx",
        bank = "fx_wolfgang",
        build = "fx_wolfgang",
        anim = "idle",
        nofaced = true,
        fn = FinalOffsetNegative1,
    },    
    {
        name = "mighty_gym_bell_fail_fx",
        bank = "mighty_gym",
        build = "mighty_gym",
        anim = "gym_bell_fx",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetMultColour(1,0,0,1)
            inst.AnimState:SetFinalOffset(1)
        end,
    },  
    {
        name = "mighty_gym_bell_perfect_fx",
        bank = "mighty_gym",
        build = "mighty_gym",
        anim = "gym_bell_fx",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetMultColour(1,1,1,1)
            inst.AnimState:SetFinalOffset(1)
        end,
    },  
    {
        name = "mighty_gym_bell_succeed_fx",
        bank = "mighty_gym",
        build = "mighty_gym",
        anim = "gym_bell_fx",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetMultColour(1,1,0,1)
            inst.AnimState:SetFinalOffset(1)
        end,
    },

    {
        name = "minotaur_blood1",
        bank = "rook_rhino_blood_fx",
        build = "rook_rhino_blood_fx",
        anim = "blood1",
        sound = "ancientguardian_rework/minotaur2/blood_splurt_small",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, .5)
            inst.Transform:SetTwoFaced()
        end,
    },

    {
        name = "minotaur_blood2",
        bank = "rook_rhino_blood_fx",
        build = "rook_rhino_blood_fx",
        anim = "blood2",
        sound = "ancientguardian_rework/minotaur2/blood_splurt_small",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, .5)
            inst.Transform:SetTwoFaced()
        end,
    },

    {
        name = "minotaur_blood3",
        bank = "rook_rhino_blood_fx",
        build = "rook_rhino_blood_fx",
        anim = "blood3",
        sound = "ancientguardian_rework/minotaur2/blood_splurt_small",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, .5)
            inst.Transform:SetTwoFaced()
        end,
    },

    {
        name = "wx78_heat_steam",
        bank = "wx_fx",
        build = "wx_fx",
        anim = "steam",
    },
    {
        name = "wx78_musicbox_fx",
        bank = "wx_fx",
        build = "wx_fx",
        anim = "music1",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:PlayAnimation("music"..math.random(1, 4))
            inst.AnimState:SetFinalOffset(1)
        end,
    },
}

for cratersteamindex = 1, 4 do
    table.insert(fx, {
        name = "crater_steam_fx"..cratersteamindex,
        bank = "crater_steam",
        build = "crater_steam",
        anim = "steam"..cratersteamindex,
        fn = FinalOffset1,
    })
end

for slowsteamindex = 1, 5 do
    table.insert(fx, {
        name = "slow_steam_fx"..slowsteamindex,
        bank = "slow_steam",
        build = "slow_steam",
        anim = "steam"..slowsteamindex,
        fn = FinalOffset1,
    })
end

for j = 0, 3, 3 do
    for i = 1, 3 do
        table.insert(fx, {
            name = "shadow_shield"..tostring(j + i),
            bank = "stalker_shield",
            build = "stalker_shield",
            anim = "idle"..tostring(i),
            sound = "dontstarve/creatures/together/stalker/shield",
            transform = j > 0 and Vector3(-1, 1, 1) or nil,
            fn = FinalOffset2,
        })
    end
end

local shot_types = {"rocks", "gold", "marble", "thulecite", "freeze", "slow", "poop", "trinket_1"}
for _, shot_type in ipairs(shot_types) do
    table.insert(fx, {
        name = "slingshotammo_hitfx_"..shot_type,
        bank = "slingshotammo",
        build = "slingshotammo",
        anim = "used",
        fn = function(inst)
			if shot_type ~= "rocks" then
		        inst.AnimState:OverrideSymbol("rock", "slingshotammo", shot_type)
			end
		    inst.AnimState:SetFinalOffset(3)
		end,
    })
end

FinalOffset1 = nil
FinalOffset2 = nil

return fx
