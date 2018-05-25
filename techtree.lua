local TechTree = {}

local AVAILABLE_TECH =
{
    "SCIENCE",
    "MAGIC",
    "ANCIENT",
    "SHADOW",
    "CARTOGRAPHY",
    "SCULPTING",
    "ORPHANAGE", --teehee
    "PERDOFFERING",
    "WARGOFFERING",
}

local function Create(t)
    t = t or {}
    for i, v in ipairs(AVAILABLE_TECH) do
        t[v] = t[v] or 0
    end
    return t
end

return
{
    AVAILABLE_TECH = AVAILABLE_TECH,
    Create = Create,
}
