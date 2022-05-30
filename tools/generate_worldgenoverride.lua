--TO RUN THIS FROM THE GAME TYPE THIS INTO THE CONSOLE
--require 'tools/generate_worldgenoverride'

local Customize = require 'map/customize'
local Levels = require 'map/levels'

local function makedescstring(desc)
    if desc ~= nil then
        local descstring = '\t\t\t-- '
        if type(desc) == 'function' then
            desc = desc()
        end
        for i,v in ipairs(desc) do
            descstring = descstring..string.format('"%s"', v.data)
            if i < #desc then
                descstring = descstring..', '
            end
        end
        return descstring
    else
        return nil
    end
end


local out = {}
table.insert(out, 'return {')
table.insert(out, '\toverride_enabled = true,')


local presets = '\t\t\t-- '
for i, level in ipairs(Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL)) do
    if i > 1 then
        presets = presets .. ', '
    end
    presets = presets .. '"' ..level.data.. '"'
end
table.insert(out, string.format('\tsettings_preset = "%s", %s', Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL)[1].data, presets))

presets = '\t\t\t-- '
for i, level in ipairs(Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL)) do
    if i > 1 then
        presets = presets .. ', '
    end
    presets = presets .. '"' ..level.data.. '"'
end
table.insert(out, string.format('\tworldgen_preset = "%s", %s', Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL)[1].data, presets))

table.insert(out, '\toverrides = {')
local lastgroup = nil
table.insert(out, string.format('\t\t--WORLDSETTINGS'))
for i,item in ipairs(Customize.GetWorldSettingsOptions(nil, true)) do
    if lastgroup ~= item.group then
        if lastgroup ~= nil then
            table.insert(out, '')
        end
        table.insert(out, string.format('\t\t-- %s', string.upper(item.group)))
    end
    lastgroup = item.group

    if item.options ~= nil then
        table.insert(out, string.format('\t\t%s = "%s", %s', item.name, item.default, makedescstring(item.options)))
    else
        table.insert(out, string.format('\t\t%s = "%s",', item.name, item.default))
    end
end
lastgroup = nil
table.insert(out, string.format('\t\t--WORLDGEN'))
for i,item in ipairs(Customize.GetWorldGenOptions(nil, true)) do
    if lastgroup ~= item.group then
        if lastgroup ~= nil then
            table.insert(out, '')
        end
        table.insert(out, string.format('\t\t-- %s', string.upper(item.group)))
    end
    lastgroup = item.group

    if item.options ~= nil then
        table.insert(out, string.format('\t\t%s = "%s", %s', item.name, item.default, makedescstring(item.options)))
    else
        table.insert(out, string.format('\t\t%s = "%s",', item.name, item.default))
    end
end
table.insert(out, '\t},')
table.insert(out, '}')

print(table.concat(out, '\n'))

local path = "worldgenoverride.lua"

local file = assert(io.open(path, "w"))
file:write(table.concat(out, '\n'))
file:close()
print()
print('Wrote to worldgenoverride.lua')
