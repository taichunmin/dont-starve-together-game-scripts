-- Constants.
local RIFTPORTAL_CONST = {
    AFFINITY = {
        NONE = "NONE",
        LUNAR = "LUNAR",
        SHADOW = "SHADOW",
        --X = "X",
    }
}


-- These will be used for falling back in case a definition function is not defined for a portal.
local FALLBACK_DEFS = {
    GetNextRiftSpawnLocation = function(_map, rift_def)
        -- _map is TheWorld.Map
        local x, y, z = _map:FindBestSpawningPointForArena(rift_def.CustomAllowTest, true, nil)
        if x then
            x, y, z = _map:GetTileCenterPoint(x, y, z)
        end
        return x, z
    end,
    CustomAllowTest = function(_map, x, y, z)
        -- _map is TheWorld.Map
        return true -- Return true to allow the point.
    end,
    Affinity = RIFTPORTAL_CONST.AFFINITY.NONE,
}


local RIFTPORTAL_DEFS = {}
local function CreateRiftPortalDefinition(rift_portal_prefab, rift_portal_definition)
    -- Retrofit undefined function definitions for mods to have a template fallback.
    for name, fn in pairs(FALLBACK_DEFS) do
        rift_portal_definition[name] = rift_portal_definition[name] or fn
    end

    -- Assign.
    RIFTPORTAL_DEFS[rift_portal_prefab] = rift_portal_definition
end


-- Generic utility functions with rift portals in mind.
local RIFTPORTAL_FNS = {
    CreateRiftPortalDefinition = CreateRiftPortalDefinition,
}


return {
    RIFTPORTAL_DEFS = RIFTPORTAL_DEFS,
    RIFTPORTAL_FNS = RIFTPORTAL_FNS,
    RIFTPORTAL_CONST = RIFTPORTAL_CONST,
    FALLBACK_DEFS = FALLBACK_DEFS,
}
