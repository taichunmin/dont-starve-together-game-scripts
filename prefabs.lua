require("class")
--require("entityscript")
--PREFABS.LUA
require("prefabskins")

Prefab = Class( function(self, name, fn, assets, deps, force_path_search)
    self.name = string.sub(name, string.find(name, "[^/]*$"))  --remove any legacy path on the name
    self.desc = ""
    self.fn = fn
    self.assets = assets or {}
    self.deps = deps or {}
    self.force_path_search = force_path_search or false

    if PREFAB_SKINS[self.name] ~= nil then
		for _,prefab_skin in pairs(PREFAB_SKINS[self.name]) do
			table.insert( self.deps, prefab_skin )
		end
    end
end)

function Prefab:__tostring()
    return string.format("Prefab %s - %s", self.name, self.desc)
end

Asset = Class( function(self, type, file, param)
    self.type = type
    self.file = file
    self.param = param
end)