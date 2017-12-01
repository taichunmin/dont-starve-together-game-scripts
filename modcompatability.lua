
local function UpgradeModLevelFromV1toV2(mod, level)

    if level.version ~= nil and level.version >= 2 then
        return level
    end
    print(string.format("Upgrading mod '%s' level data '%s' from v1 to v2", mod, level.id))

    local ret = deepcopy(level)

    if level.overrides ~= nil then
        for i=#level.overrides,1,-1 do
            local override = level.overrides[i]
            moderror(string.format("Level override for level %s in old format. Please use the new format:\n\t\t%s = \"%s\"", level.id, override[1], override[2]))
            ret.overrides[override[1]] = override[2]

            ret.overrides[i] = nil
        end
    end

    --if level.required_prefabs ~= nil then
        --for i=#level.required_prefabs,1,-1 do
            --local prefab = level.required_prefabs[i]
            --moderror(string.format("Required prefab %s for level %s specified in old format. Please use the new format:\n\t\t%s = 1,", prefab, level.id, prefab))
            --print(("  upgrading required prefab %s..."):format(prefab))
            --if ret.required_prefabs[prefab] ~= nil then
                --ret.required_prefabs[prefab] = ret.required_prefabs[prefab]+1
            --else
                --ret.required_prefabs[prefab] = 1
            --end
            --print(("    count is now %d"):format(ret.required_prefabs[prefab]))

            --ret.required_prefabs[i] = nil
        --end
    --end

    if level.set_pieces ~= nil then
        moderror(string.format("Level %s has a set_pieces table, but that should be in the Task Set now.", level.id))
        level.set_pieces = nil
    end

    if level.location == nil then
        moderror(string.format("Level %s does not specify a location but it is now required.", level.id))
        level.location = "forest"
    end

    return ret
end

return {
    UpgradeModLevelFromV1toV2 = UpgradeModLevelFromV1toV2,
}
