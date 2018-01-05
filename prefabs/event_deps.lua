--[[
Use this file for dependencies that are only required during a specific event.
 - Don't move SPECIAL_EVENT.NONE loading screens in here (from global.lua), in case
   of events that don't have their own loading screens.
 - Don't make special event backend prefabs exclusive to the event, since events
   automatically come and go in regular world save files.
--]]

--------------------------------------------------------------------------
local SPECIAL_EVENT_DEPS =
{
    [SPECIAL_EVENTS.HALLOWED_NIGHTS] =
    {
        global =
        {
            assets =
            {
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_halloween1.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_halloween1.tex"),
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_halloween2.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_halloween2.tex"),
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_halloween3.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_halloween3.tex"),
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_halloween4.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_halloween4.tex"),
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_halloween5.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_halloween5.tex"),
            },
        },
    },

    [SPECIAL_EVENTS.WINTERS_FEAST] =
    {
        global =
        {
            assets =
            {
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_christmas1.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_christmas1.tex"),
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_christmas2.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_christmas2.tex"),
            },
        },

        frontend =
        {
            assets =
            {
                Asset("PKGREF", "sound/music_frontend_winters_feast.fsb"),
            },
        },
    },

    [SPECIAL_EVENTS.YOTG] =
    {
        global =
        {
            assets =
            {
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_yotg1.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_yotg1.tex"),
                Asset("DYNAMIC_ATLAS", "images/bg_spiral_fill_yotg2.xml"),
                Asset("PKGREF", "images/bg_spiral_fill_yotg2.tex"),
            },
        },

        frontend =
        {
            assets =
            {
                Asset("DYNAMIC_ANIM", "anim/dynamic/frontend_perd.zip"),
                Asset("PKGREF", "sound/music_frontend_yotg.fsb"),
            },
        },
    },
}

--------------------------------------------------------------------------
local FESTIVAL_EVENT_DEPS =
{
    [FESTIVAL_EVENTS.LAVAARENA] =
    {
        frontend =
        {
            assets =
            {
                Asset("PKGREF", "sound/lava_arena.fsb"),
            },
        },
    },
}

--------------------------------------------------------------------------
--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn()
    return CreateEntity()
end

local ret = {}
local function AddDependencyPrefab(name, env)
    table.insert(ret, Prefab(name, fn, env.assets, env.prefabs))
end
for k, v in pairs(SPECIAL_EVENTS) do
    local deps = SPECIAL_EVENT_DEPS[v] or {}
    AddDependencyPrefab(v.."_event_global", deps.global or {})
    AddDependencyPrefab(v.."_event_frontend", deps.frontend or {})
    AddDependencyPrefab(v.."_event_backend", deps.backend or {})
end
for k, v in pairs(FESTIVAL_EVENTS) do
    local deps = FESTIVAL_EVENT_DEPS[v] or {}
    AddDependencyPrefab(v.."_fest_global", deps.global or {})
    AddDependencyPrefab(v.."_fest_frontend", deps.frontend or {})
    AddDependencyPrefab(v.."_fest_backend", deps.backend or {})
end
return unpack(ret)
