local TextListPopup = require "screens/redux/textlistpopup"

local function BuildOptionalModLink(mod_name)
    if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
        local link_fn, is_generic_url = ModManager:GetLinkForMod(mod_name)
        if is_generic_url then
            return nil
        else
            return link_fn
        end
    else
        return nil
    end
end

local function BuildModList(mod_ids)
    local mods = {}
    for i,v in ipairs(mod_ids) do
        table.insert(mods, {
                text = KnownModIndex:GetModFancyName(v) or v,
                -- Adding onclick with the idea that if you have a ton of
                -- mods, you'd want to be able to jump to information about
                -- the problem ones.
                onclick = BuildOptionalModLink(v),
            })
    end
    return mods
end

local function QueryName(modname, modtable, textlistpopup)
    if IsWorkshopMod(modname) then
        TheSim:QueryWorkshopModName(GetWorkshopIdNumber(modname),
            function(isSuccessful, modname)
                if isSuccessful then
                    modtable.text = modname
                    if textlistpopup ~= nil then
                        textlistpopup.scroll_list:RefreshView()
                    end
                else
                    print("Workshop Name Query Failed!")
                end
            end
        )
    end
end

local ModsListPopup = Class(TextListPopup, function(self, mods_list, title_text, body_text, buttons, spacing, querynames)
    local built_mods_list = BuildModList(mods_list)
    TextListPopup._ctor(self, built_mods_list, title_text, body_text, buttons, spacing, true)
    if querynames then
        for _, mod in ipairs(built_mods_list) do
            QueryName(mod.text, built_mods_list[_], self)
        end
    end
end)

return ModsListPopup