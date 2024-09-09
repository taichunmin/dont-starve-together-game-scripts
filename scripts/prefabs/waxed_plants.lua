local WAXED_PLANTS = require "prefabs/waxed_plant_common"

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS

ASSETS = {
    Asset("SCRIPT", "scripts/prefabs/waxed_plant_common.lua")
}

-------------------------------------------------------------------------------------------------

-- Reused stuff.

local function Plantable_GetAnimFn(inst)
    if inst.components.pickable ~= nil and inst.components.pickable:CanBePicked() then
        return "idle"
    end

    if (
        inst.components.pickable ~= nil and
        inst.components.pickable:IsBarren()
    ) or (
        inst.components.witherable ~= nil and
        inst.components.witherable:IsWithered()
    ) then
        return "dead"
    end

    return "picked"
end

local function Tree_MultColorFn()
    return .5 + math.random() * .5
end

local function Tree_Minimap_CommonPostInit(inst)
    inst.MiniMapEntity:SetPriority(-1)
end

-------------------------------------------------------------------------------------------------

local BERRY_TYPES  = { "berries", "berriesmore", "berriesmost" }
local BERRY_HIDDEN = { "berries", "berriesmore" }

local BERRYBUSH_ANIMSET = {
    idle         = { anim = "idle", hidesymbols = BERRY_HIDDEN},
    picked       = { anim = "idle", hidesymbols = BERRY_TYPES},
    dead         = { anim = "dead" },
}

local function CreateWaxedBerryBush(name)
    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=name,
        bank=name,
        build=name,
        minimapicon=name,
        anim="idle",
        action="DIG",
        physics={MakeSmallObstaclePhysics, 0.1},
        animset=BERRYBUSH_ANIMSET,
        getanim_fn=Plantable_GetAnimFn,
        assets=ASSETS,
    }) 
end

-------------------------------------------------------------------------------------------------

local GRASS_ANIMSET = {
    idle         = { anim = "idle"      },
    picked       = { anim = "picked"    },
    dead         = { anim = "idle_dead" },
}

local function Grass_MultColorFn()
    return 0.75 + math.random() * 0.25
end

local SAPLING_ANIMSET = {
    idle         = { anim = "sway"      },
    picked       = { anim = "empty"    },
    dead         = { anim = "idle_dead" },
}

local function CreateWaxedSapling(is_moon)
    local name = is_moon and "sapling_moon" or "sapling"

    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=name,
        bank=name,
        build=name,
        nameoverride = "sapling",
        minimapicon="sapling",
        anim="sway",
        action="DIG",
        animset=SAPLING_ANIMSET,
        getanim_fn=Plantable_GetAnimFn,
        assets=ASSETS,
        mediumspacing = true,
    })
end

-------------------------------------------------------------------------------------------------

local BANANABUSH_ANIMSET = {
    empty    = { anim = "idle_empty"  },
    small    = { anim = "idle_small"  },
    normal   = { anim = "idle_medium" },
    tall     = { anim = "idle_big"    },
    dead     = { anim = "dead"        },
}

local function BananaBush_GetAnimFn(inst)
    if (
        inst.components.pickable ~= nil and
        inst.components.pickable:IsBarren()
    ) or (
        inst.components.witherable ~= nil and
        inst.components.witherable:IsWithered()
    ) then
        return "dead"
    end

    local stagedata = inst.components.growable ~= nil and inst.components.growable:GetCurrentStageData() or nil

    if stagedata ~= nil then
        return stagedata.name
    end

    return "tall"
end

-------------------------------------------------------------------------------------------------

local MARSH_BUSH_ANIMSET = {
    idle   = { anim = "idle"      },
    picked = { anim = "picked"    },
    dead   = { anim = "idle_dead" },
}

-------------------------------------------------------------------------------------------------

local FARMPLANT_ANIMSET = {
    randomseed       = { anim = "sow_idle"           },
    seed             = { anim = "crop_seed"          },
    sprout           = { anim = "crop_sprout"        },
    small            = { anim = "crop_small"         },
    med              = { anim = "crop_med"           },
    full             = { anim = "crop_full"          },
    full_oversized   = { anim = "crop_oversized"     },
    rotten           = { anim = "crop_rot"           },
    rotten_oversized = { anim = "crop_rot_oversized" },
}

local function FarmPlant_GetAnimFn(inst)
    if inst.plant_def ~= nil and inst.plant_def.is_randomseed then
        return "randomseed"
    end

    local stagedata = inst.components.growable ~= nil and inst.components.growable:GetCurrentStageData() or nil

    if stagedata ~= nil then
        return stagedata.name .. (inst.is_oversized and "_oversized" or "")
    end

    return "full"
end

local function WaxedFarmPlant_MasterPostInit(inst)
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")
    inst:SetPhysicsRadiusOverride(TUNING.FARM_PLANT_PHYSICS_RADIUS)
end

-- NOTES(DiogoW): Missing special GetDisplayName...
local function CreateWaxedFarmPlant(plant_def)
    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=plant_def.prefab,
        bank=plant_def.bank,
        build=plant_def.build,
        anim=plant_def.is_randomseed and "sow_idle" or "crop_full",
        action="DIG",
        animset=FARMPLANT_ANIMSET,
        getanim_fn=FarmPlant_GetAnimFn,
        master_postinit=WaxedFarmPlant_MasterPostInit,
        assets=ASSETS,
        deploysmartradius = 0.5,
    }) 
end

-------------------------------------------------------------------------------------------------

local WEEDPLANT_ANIMSET = {
    small         = { anim = "crop_small"   },
    small_mature  = { anim = "crop_picked"  },
    med           = { anim = "crop_med"     },
    full          = { anim = "crop_full"    },
    bolting       = { anim = "crop_bloomed" },
}

local function WeedPlant_GetAnimFn(inst)
    local stagedata = inst.components.growable ~= nil and inst.components.growable:GetCurrentStageData() or nil

    if stagedata ~= nil then
        if inst.mature and stagedata.name == "small" then
            return "small_mature"
        end
    
        return stagedata.name
    end

    return "full"
end

-- NOTES(DiogoW): Missing special GetDisplayName...
local function CreateWaxedWeedPlant(plant_def)
    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=plant_def.prefab,
        bank=plant_def.bank,
        build=plant_def.build,
        anim="crop_full",
        action="DIG",
        animset=WEEDPLANT_ANIMSET,
        getanim_fn=WeedPlant_GetAnimFn,
        master_postinit=WaxedFarmPlant_MasterPostInit,
        assets=ASSETS,
        deploysmartradius = 0.5,
    }) 
end

-------------------------------------------------------------------------------------------------

local MARBLESHRUB_STAGES = { "short", "normal", "tall" }

local MARBLESHRUB_ANIMSET = {}

for _, stage in ipairs(MARBLESHRUB_STAGES) do
    MARBLESHRUB_ANIMSET[stage.."1"] = { anim = "idle_"..stage }

    for i=2, 3 do
        MARBLESHRUB_ANIMSET[stage..i] = {
            anim = "idle_"..stage,
            minimap = "marbleshrub"..i..".png",
            overridesymbol = { "marbleshrub_top1", "marbleshrub_build", "marbleshrub_top"..i }
        }
    end
end

local function Marbleshrub_GetAnimFn(inst)
    if inst.statedata ~= nil and inst.statedata.name ~= nil then
        return inst.statedata.name..(inst.shapenumber or 1)
    end

    return "tall1"
end

-------------------------------------------------------------------------------------------------

local ROCK_AVOCADO_BUSH_ANIMSET = {}

for i=1, 4 do
    ROCK_AVOCADO_BUSH_ANIMSET["stage_"..i] = { anim = "idle"..i}
end

local function RockAvocadoBush_GetAnimFn(inst)
    local stagedata = inst.components.growable ~= nil and inst.components.growable:GetCurrentStageData() or nil

    if stagedata ~= nil then
        return stagedata.name
    end

    return "stage_1"
end

-------------------------------------------------------------------------------------------------

local function TreeSapling_GetAnimFn(inst)
    return inst.prefab
end

local function CreateWaxedTreeSapling(name, _build, _anim, deployspacing)
    local animset = { [name.."_sapling"] = { anim = _anim } }

    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=name.."_sapling",
        bank=_build,
        build=_build,
        anim=_anim,
        action="DIG",
        animset=animset,
        getanim_fn=TreeSapling_GetAnimFn,
        assets=ASSETS,
        deployspacing = deployspacing,
    })
end

-------------------------------------------------------------------------------------------------

local EVERGREEN_ANIMSET_LIST = {
    "sway1_loop", "sway2_loop", "burnt", "stump"
}

local EVERGREEN_BUILD =
{
    evergreen = {
        build="evergreen_new",
        bank = "evergreen_short",
    },

    evergreen_sparse = {
        build="evergreen_new_2",
        bank = "evergreen_short",
    },

    twiggytree = {
        build="twiggy_build",
        bank = "twiggy",
    },
}

local EVERGREEN_MINIMAPICON_LOOKUP = {
    evergreen = {
        sway1_loop = "evergreen.png",
        sway2_loop = "evergreen.png",
        stump = "evergreen_stump.png",
        burnt = "evergreen_burnt.png",
    },

    evergreen_sparse = {
        sway1_loop = "evergreen_lumpy.png",
        sway2_loop = "evergreen_lumpy.png",
        stump = "evergreen_stump.png",
        burnt = "evergreen_burnt.png",
    },

    twiggytree = {
        sway1_loop = "twiggy.png",
        sway2_loop = "twiggy.png",
        stump = "twiggy_stump.png",
        burnt = "twiggy_burnt.png",
    }
}

local function Evergreen_GetAnimFn(inst)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        return inst.prefab .."_".. inst.anims.burnt
    end

    if inst:HasTag("stump") then
        return inst.prefab .."_".. inst.anims.stump
    end

    local sway = inst.AnimState:IsCurrentAnimation(inst.anims.sway2) and inst.anims.sway2 or inst.anims.sway1

    return inst.prefab .."_".. sway
end

local function CreateWaxedEvergreen(name)
    local data = EVERGREEN_BUILD[name]

    local animset = {
        [name.."_idle_old"]   = { anim = "idle_old",  minimap = EVERGREEN_MINIMAPICON_LOOKUP[name].sway2_loop},
        [name.."_stump_old"]  = { anim = "stump_old", minimap = EVERGREEN_MINIMAPICON_LOOKUP[name].stump, stump = true},
    }

    for _, anim in ipairs(EVERGREEN_ANIMSET_LIST) do
        local short, normal, tall = anim.."_short", anim.."_normal", anim.."_tall"
        
        local minimapicon = EVERGREEN_MINIMAPICON_LOOKUP[name][anim]
        
        local short_key, normal_key, tall_key = name.."_"..short, name.."_"..normal, name.."_"..tall

        animset[short_key]  = {anim = short,  minimap = minimapicon, stump = anim == "stump"}
        animset[normal_key] = {anim = normal, minimap = minimapicon, stump = anim == "stump"}
        animset[tall_key]   = {anim = tall,   minimap = minimapicon, stump = anim == "stump"}
    end

    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=name,
        bank=data.bank,
        build=data.build,
        anim="sway1_loop_tall",
        action="CHOP",
        physics={MakeObstaclePhysics, .25},
        animset=animset,
        getanim_fn=Evergreen_GetAnimFn,
        multcolor=Tree_MultColorFn,
        common_postinit=Tree_Minimap_CommonPostInit,
        assets=ASSETS,
    }) 
end

-------------------------------------------------------------------------------------------------

local DECIDUOUSTREE_ANIMSET_LIST = {
    "sway1_loop", "sway2_loop", "burnt", "stump"
}

local DECIDUOUSTREE_LEAVES_BUILD = {
    normal = "tree_leaf_green_build",
    yellow = "tree_leaf_yellow_build",
    red    = "tree_leaf_red_build",
    orange = "tree_leaf_orange_build",
    barren = "nil",
}

local DECIDUOUSTREE_ANIMSET = {}

for _, anim in ipairs(DECIDUOUSTREE_ANIMSET_LIST) do
    if anim == "burnt" or anim == "stump" then
        local short, normal, tall = anim.."_short", anim.."_normal", anim.."_tall"
        
        local minimapicon = "tree_leaf_"..anim..".png"

        DECIDUOUSTREE_ANIMSET[short]  = {anim = short,  minimap = minimapicon, stump = anim == "stump"}
        DECIDUOUSTREE_ANIMSET[normal] = {anim = normal, minimap = minimapicon, stump = anim == "stump"}
        DECIDUOUSTREE_ANIMSET[tall]   = {anim = tall,   minimap = minimapicon, stump = anim == "stump"}

    else
        for name, overridebuild in pairs(DECIDUOUSTREE_LEAVES_BUILD) do
            local short, normal, tall = anim.."_short", anim.."_normal", anim.."_tall"
        
            local minimapicon = "tree_leaf.png"

            local short_key, normal_key, tall_key = name.."_"..short, name.."_"..normal, name.."_"..tall
            local overridedata = overridebuild ~= "nil" and { "swap_leaves", overridebuild, "swap_leaves" } or nil
    
            DECIDUOUSTREE_ANIMSET[short_key]  = {anim = short,  minimap = minimapicon, overridesymbol = overridedata}
            DECIDUOUSTREE_ANIMSET[normal_key] = {anim = normal, minimap = minimapicon, overridesymbol = overridedata}
            DECIDUOUSTREE_ANIMSET[tall_key]   = {anim = tall,   minimap = minimapicon, overridesymbol = overridedata}
        end
    end
end

local function DeciduousTree_GetAnimFn(inst)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        return inst.anims.burnt
    end

    if inst:HasTag("stump") then
        return inst.anims.stump
    end

    local sway = inst.AnimState:IsCurrentAnimation(inst.anims.sway2) and inst.anims.sway2 or inst.anims.sway1

    return inst.build .."_".. sway
end

local function DeciduousTree_CommonPostInit(inst)
    Tree_Minimap_CommonPostInit(inst)

    inst.AnimState:Hide("mouseover")
end

-------------------------------------------------------------------------------------------------

local MOON_AND_PALMCONE_TREE_ANIMSET_LIST = {
    "sway1_loop", "sway2_loop", "burnt", "stump"
}

local MOONTREE_ANIMSET = {}
local PALCONETREE_ANIMSET = {}

for _, anim in ipairs(MOON_AND_PALMCONE_TREE_ANIMSET_LIST) do
    local short, normal, tall = anim.."_short", anim.."_normal", anim.."_tall"
    
    local needs_minimapicon = anim == "burnt" or anim == "stump"

    local moontree_minimapicon    = needs_minimapicon and "moon_tree_"..anim..".png" or nil
    local palconetree_minimapicon = needs_minimapicon and "palmcone_tree_"..anim..".png" or nil

    MOONTREE_ANIMSET[short]  = {anim = short,  minimap = moontree_minimapicon, stump = anim == "stump"}
    MOONTREE_ANIMSET[normal] = {anim = normal, minimap = moontree_minimapicon, stump = anim == "stump"}
    MOONTREE_ANIMSET[tall]   = {anim = tall,   minimap = moontree_minimapicon, stump = anim == "stump"}

    PALCONETREE_ANIMSET[short]  = {anim = short,  minimap = palconetree_minimapicon, stump = anim == "stump"}
    PALCONETREE_ANIMSET[normal] = {anim = normal, minimap = palconetree_minimapicon, stump = anim == "stump"}
    PALCONETREE_ANIMSET[tall]   = {anim = tall,   minimap = palconetree_minimapicon, stump = anim == "stump"}
end

local function MoonAndPalmconeTree_GetAnimFn(inst)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        return "burnt_"..inst.size
    end

    if inst:HasTag("stump") then
        return "stump_"..inst.size
    end

    local sway = inst.AnimState:IsCurrentAnimation("sway2_loop_"..inst.size) and "sway2_loop_"..inst.size or "sway1_loop_"..inst.size

    return sway
end

local function MoonAndPalmconeTree_MultColour(inst)
    return 0.75 + math.random() * 0.25
end

-------------------------------------------------------------------------------------------------

local OCEANTREE_ANIMSET_LIST = {
    "sway1_loop", "sway2_loop", "burnt", "stump"
}

local OCEAN_TREE_BUD_SYMBOLS = {}

for i=0, 7 do
    table.insert(OCEAN_TREE_BUD_SYMBOLS, "tree_bud"..i)
end

local OCEANTREE_ANIMSET = {
    sway1         = {anim = "sway1_loop", hidesymbols = OCEAN_TREE_BUD_SYMBOLS                            },
    sway2         = {anim = "sway2_loop", hidesymbols = OCEAN_TREE_BUD_SYMBOLS                            },
    sway1_bloomed = {anim = "sway1_loop",                                                                 },
    sway2_bloomed = {anim = "sway2_loop",                                                                 },
    stump         = {anim = "stump", minimap = "oceantree_stump.png", hidesymbols = OCEAN_TREE_BUD_SYMBOLS},
    burnt         = {anim = "burnt", minimap = "oceantree_burnt.png", hidesymbols = OCEAN_TREE_BUD_SYMBOLS},
}

local function OceanTree_GetAnimFn(inst)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        return "burnt"
    end

    if inst:HasTag("stump") then
        return "stump"
    end

    local sway = inst.AnimState:IsCurrentAnimation(inst.anims.sway2) and "sway2" or "sway1"

    if #inst.buds_used > 0 then
        return sway.."_bloomed"
    end

    return sway
end

local function OceanTree_CommonPostInit(inst)
    Tree_Minimap_CommonPostInit(inst)

    inst:AddTag("ignorewalkableplatforms")

    inst:SetPhysicsRadiusOverride(2.35)
end

local function OceanTree_OnConfigure(inst)
    local suffix = string.gsub(string.gsub(inst.AnimState:GetBuild(), "oceantree_", ""), "_jammed_build", "")

    inst:SpawnChild("oceantree_ripples_"..suffix)
    inst:SpawnChild("oceantree_roots_"..suffix)
end

-------------------------------------------------------------------------------------------------

local ANCIENT_TREE_DEFS = require("prefabs/ancienttree_defs").TREE_DEFS
local ANCIENT_TREE_FRUIT_SYMBOLS = { "fruit" }

local ANCIENT_TREE_ANIMSET = {
    sway1         = {anim = "sway1_loop", hidesymbols = ANCIENT_TREE_FRUIT_SYMBOLS},
    sway2         = {anim = "sway2_loop", hidesymbols = ANCIENT_TREE_FRUIT_SYMBOLS},
    sway1_full    = {anim = "sway1_loop",                                         },
    sway2_full    = {anim = "sway2_loop",                                         },
}

for type, data in pairs(ANCIENT_TREE_DEFS) do
    local stump = type.."_stump"

    ANCIENT_TREE_ANIMSET[stump] = {anim = "stump", hidesymbols = ANCIENT_TREE_FRUIT_SYMBOLS, minimap = "ancienttree_"..stump..".png", stump = true}
end

local function AncientTree_GetAnimFn(inst)
    if inst:HasTag("stump") then
        return inst.type.."_stump"
    end

    local sway = inst.AnimState:IsCurrentAnimation("sway2_loop") and "sway2" or "sway1"

    if inst:HasTag("pickable") then
        return sway.."_full"
    end

    return sway
end

local function AncientTree_MultColour(inst)
    return 0.75 + math.random() * 0.25
end

local function CreateWaxedAncientTree(type, data)
    local name = "ancienttree_"..type

    local function common_post_init(inst)
        inst.MiniMapEntity:SetPriority(3)

        if data.shadow_size ~= nil then
            inst.entity:AddDynamicShadow()

            inst.DynamicShadow:SetSize(data.shadow_size, data.shadow_size)
        end

        if data.common_postinit ~= nil then
            data.common_postinit(inst)
        end
    end

    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=name,
        bank=data.bank,
        build=data.build,
        minimapicon=name,
        anim="sway1_loop",
        action=data.workaction,
        physics={MakeObstaclePhysics, data.physics_rad},
        animset=ANCIENT_TREE_ANIMSET,
        getanim_fn=AncientTree_GetAnimFn,
        multcolor=AncientTree_MultColour,
        common_postinit=common_post_init,
        assets=ASSETS,
        deployspacing = DEPLOYSPACING.PLACER_DEFAULT,
    }) 
end

-------------------------------------------------------------------------------------------------

local ANCIENT_TREE_SAPLING_ANIMSET = {
    seed   = {anim = "idle_planted"},
    sprout = {anim = "sprout_idle" },
}

local function AncientTreeSapling_GetAnimFn(inst)
    if inst.statedata ~= nil then
        return inst.statedata.name
    end

    return "seed"
end

local function AncientTreeSapling_GetDisplayNameFn(inst)
    local is_seed = inst.AnimState:IsCurrentAnimation(ANCIENT_TREE_SAPLING_ANIMSET.seed.anim)

    return STRINGS.NAMES[is_seed and "ANCIENTTREE_SEED_PLANTED" or inst.displayname]
end

local function AncientTreeSapling_GetInventoryPrefab(inst)
    local is_seed = inst.savedata.anim == "seed"

    if is_seed then
        return nil -- No dug prefab!
    end

    return inst.plantprefab.."_item_waxed"
end

local function CreateWaxedAncientTreeSapling(type, data)
    local function common_post_init(inst)
        inst.displaynamefn = AncientTreeSapling_GetDisplayNameFn

        if data.common_postinit ~= nil then
            data.common_postinit(inst)
        end
    end

    local name = "ancienttree_"..type.."_sapling"

    return WAXED_PLANTS.CreateWaxedPlant({
        prefab=name,
        bank=data.bank,
        build=data.build,
        anim="sprout_idle",
        action="DIG",
        animset=ANCIENT_TREE_SAPLING_ANIMSET,
        inventoryitem=AncientTreeSapling_GetInventoryPrefab,
        getanim_fn=AncientTreeSapling_GetAnimFn,
        multcolor=AncientTree_MultColour,
        common_postinit=common_post_init,
        assets=ASSETS,
        deployspacing = DEPLOYSPACING.PLACER_DEFAULT,
    }) 
end

-------------------------------------------------------------------------------------------------

local ret = {
    CreateWaxedBerryBush("berrybush"),
    CreateWaxedBerryBush("berrybush2"),
    CreateWaxedBerryBush("berrybush_juicy"),

    CreateWaxedEvergreen("evergreen"),
    CreateWaxedEvergreen("evergreen_sparse"),
    CreateWaxedEvergreen("twiggytree"),

    CreateWaxedSapling(false),
    CreateWaxedSapling(true),

    CreateWaxedTreeSapling( "pinecone",      "pinecone",       "idle_planted"  ),
    CreateWaxedTreeSapling( "lumpy",         "pinecone",       "idle_planted2" ),
    CreateWaxedTreeSapling( "acorn",         "acorn",          "idle_planted"  ),
    CreateWaxedTreeSapling( "twiggy_nut",    "twiggy_nut",     "idle_planted"  ),
    CreateWaxedTreeSapling( "marblebean",    "marblebean",     "idle_planted"  ),
    CreateWaxedTreeSapling( "moonbutterfly", "baby_moon_tree", "idle",        DEPLOYSPACING.PLACER_DEFAULT ),
    CreateWaxedTreeSapling( "palmcone",      "palmcone_seed",  "idle_planted"  ),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="grass",
        bank="grass",
        build="grass1",
        minimapicon="grass",
        anim="idle",
        action="DIG",
        animset=GRASS_ANIMSET,
        getanim_fn=Plantable_GetAnimFn,
        multcolor=Grass_MultColorFn,
        assets=ASSETS,
        deployspacing = DEPLOYSPACING.MEDIUM,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="marsh_bush",
        bank="marsh_bush",
        build="marsh_bush",
        minimapicon="marsh_bush",
        anim="idle",
        action="DIG",
        animset=MARSH_BUSH_ANIMSET,
        getanim_fn=Plantable_GetAnimFn,
        common_postinit=Tree_Minimap_CommonPostInit,
        multcolor=Tree_MultColorFn,
        assets=ASSETS,
        deployspacing = DEPLOYSPACING.MEDIUM,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="bananabush",
        bank="bananabush",
        build="bananabush",
        minimapicon="bananabush",
        anim="idle_big",
        action="DIG",
        animset=BANANABUSH_ANIMSET,
        getanim_fn=BananaBush_GetAnimFn,
        assets=ASSETS,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="marbleshrub",
        bank="marbleshrub",
        build="marbleshrub",
        anim="idle_tall",
        action="MINE",
        minimapicon="marbleshrub1",
        multcolor=Tree_MultColorFn,
        physics={MakeObstaclePhysics, 0.1},
        animset=MARBLESHRUB_ANIMSET,
        getanim_fn=Marbleshrub_GetAnimFn,
        common_postinit=Tree_Minimap_CommonPostInit,
        assets=ASSETS,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="monkeytail",
        bank="grass",
        build="reeds_monkeytails",
        anim="idle",
        action="DIG",
        minimapicon="monkeytail",
        animset=GRASS_ANIMSET,
        getanim_fn=Plantable_GetAnimFn,
        multcolor=Grass_MultColorFn,
        assets=ASSETS,
        deployspacing = DEPLOYSPACING.MEDIUM,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="rock_avocado_bush",
        bank="rock_avocado",
        build="rock_avocado_build",
        anim="idle1",
        action="DIG",
        minimapicon="rock_avocado",
        animset=ROCK_AVOCADO_BUSH_ANIMSET,
        physics={MakeSmallObstaclePhysics, 0.1},
        getanim_fn=RockAvocadoBush_GetAnimFn,
        assets=ASSETS,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="deciduoustree",
        bank="tree_leaf",
        build="tree_leaf_trunk_build",
        anim="sway1_loop_tall",
        action="CHOP",
        physics={MakeObstaclePhysics, .25},
        animset=DECIDUOUSTREE_ANIMSET,
        getanim_fn=DeciduousTree_GetAnimFn,
        common_postinit=DeciduousTree_CommonPostInit,
        multcolor=Tree_MultColorFn,
        assets=ASSETS,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="moon_tree",
        bank="moon_tree",
        build="moon_tree",
        anim="sway1_loop_tall",
        minimapicon="moon_tree",
        action="CHOP",
        physics={MakeObstaclePhysics, .5},
        animset=MOONTREE_ANIMSET,
        getanim_fn=MoonAndPalmconeTree_GetAnimFn,
        common_postinit=Tree_Minimap_CommonPostInit,
        multcolor=MoonAndPalmconeTree_MultColour,
        assets=ASSETS,
        deployspacing = DEPLOYSPACING.PLACER_DEFAULT,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="palmconetree",
        bank="palmTree",
        build="palmcone_build",
        anim="sway1_loop_tall",
        minimapicon="palmcone_tree",
        action="CHOP",
        physics={MakeObstaclePhysics, .5},
        animset=PALCONETREE_ANIMSET,
        getanim_fn=MoonAndPalmconeTree_GetAnimFn,
        common_postinit=Tree_Minimap_CommonPostInit,
        multcolor=MoonAndPalmconeTree_MultColour,
        assets=ASSETS,
    }),

    WAXED_PLANTS.CreateWaxedPlant({
        prefab="oceantree",
        bank="oceantree_tall",
        build="oceantree_tall",
        anim="sway1_loop",
        minimapicon="oceantree_tall",
        action="CHOP",
        physics={MakeWaterObstaclePhysics, 0.80, 2, 0.75},
        animset=OCEANTREE_ANIMSET,
        getanim_fn=OceanTree_GetAnimFn,
        common_postinit=OceanTree_CommonPostInit,
        onconfigure_fn=OceanTree_OnConfigure,
        multcolor=Tree_MultColorFn,
        assets=ASSETS,
    }),
}

-------------------------------------------------------------------------------------------------

for i, data in pairs(PLANT_DEFS) do
    table.insert(ret, CreateWaxedFarmPlant(data))
end

for i, data in pairs(WEED_DEFS) do
    table.insert(ret, CreateWaxedWeedPlant(data))
end

for type, data in pairs(ANCIENT_TREE_DEFS) do
    table.insert(ret, CreateWaxedAncientTree(type, data))
    table.insert(ret, CreateWaxedAncientTreeSapling(type, data))
end

-------------------------------------------------------------------------------------------------

return unpack(ret)
