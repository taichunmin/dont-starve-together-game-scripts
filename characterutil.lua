-- Utility functions for loading character data (portraits, avatars, etc).

require("dlcsupport")

-- Load the shield portrait for input character into the input widget.
--
-- character is something like 'wilson'
function SetShieldPortraitTexture(image_widget, character)
    -- Official characters use _none for their shield portraits, but
    -- many mods use bare character name.
    image_widget:SetTexture("bigportraits/"..character..".xml", character.."_none.tex", character..".tex")
end

-- Load the oval portrait for input character into the input widget.
--
-- Returns whether the oval portrait atlas was found.
-- character is something like 'wilson'
-- skin is something like 'wilson_formal'
function SetSkinnedOvalPortraitTexture(image_widget, character, skin)
    if softresolvefilepath("bigportraits/"..skin..".xml") then 
        -- Try to load the oval and fall back to the unskinned shield if it's stored here.
        image_widget:SetTexture("bigportraits/"..skin..".xml", skin.."_oval.tex", character.."_none.tex")
        return true
    else
        -- No skinnable oval portrait. Load the shield portrait instead.
        SetShieldPortraitTexture(image_widget, character)
        return false
    end
end

-- Like SetSkinnedOvalPortraitTexture but with default skin.
--
-- character is something like 'wilson'
function SetOvalPortraitTexture(image_widget, character)
    return SetSkinnedOvalPortraitTexture(image_widget, character, character .."_none")
end

-- Load the oval portrait for input character into the input widget.
-- Returns whether the oval portrait atlas was found.
function SetHeroNameTexture_Grey(image_widget, character)
    local hero_atlas = "images/names_"..character..".xml"
    if softresolvefilepath(hero_atlas) then 
        image_widget:SetTexture(hero_atlas, character..".tex")
        -- SetTexture may still fail if the texture doesn't exist.
        return true
    end
end

-- Load the oval portrait for input character into the input widget.
-- Returns whether the oval portrait atlas was found.
function SetHeroNameTexture_Gold(image_widget, character)
    local hero_atlas = "images/names_gold_"..character..".xml"
    if softresolvefilepath(hero_atlas) then 
        image_widget:SetTexture(hero_atlas, character..".tex")
        -- SetTexture may still fail if the texture doesn't exist.
        return true
    else
      -- Mod characters aren't likely to have gold, so fall back to grey.
      return SetHeroNameTexture_Grey(image_widget, character)
    end
end

-- Load the avatar image for input character into the input widget.
--
-- Avatars are images of character's heads.
-- Returns the atlas and texture.
-- character is something like 'wilson'
function GetCharacterAvatarTextureLocation(character)
    local avatar_location = "images/avatars.xml"
    -- Random isn't a real character, but we treat it like one for display
    -- purposes.
    if character == "random" or table.contains(GetOfficialCharacterList(), character) then
        -- Normal flow. Nothing special.
    elseif table.contains(MODCHARACTERLIST, character) then
        local mod_location = MOD_AVATAR_LOCATIONS[character] or MOD_AVATAR_LOCATIONS["Default"]
        avatar_location = string.format("%savatar_%s.xml", mod_location, character)
    else
        -- A valid name is probably a mod character that didn't register itself
        -- in MODCHARACTERLIST.
        local has_name = character ~= nil and character ~= ""
        if has_name then
            character = "mod"
        else
            character = "unknown"
        end
    end
    return avatar_location, string.format("avatar_%s.tex", character)
end

-- Get title for character.
--
-- character is something like 'wilson'
-- skin is something like 'wilson_formal'
function GetCharacterTitle(character, skin)
    if skin and skin ~= "" then
        return GetSkinName(skin)
    end
    return STRINGS.CHARACTER_TITLES[character]
end


local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function GetKilledByFromMorgueRow(data)
    if data.killed_by == nil then
        return ""
    elseif data.pk then
        --If it's a PK, then don't do any remapping or reformatting on the player's name
        return data.killed_by
    end

    local killed_by =
        (data.killed_by == "nil" and (data.character == "waxwell" and "charlie" or "darkness")) or
        (data.killed_by == "unknown" and "shenanigans") or
        (data.killed_by == "moose" and (math.random() < .5 and "moose1" or "moose2")) or
        data.killed_by

    killed_by = STRINGS.NAMES[string.upper(killed_by)] or STRINGS.NAMES.SHENANIGANS

    return killed_by:gsub("(%a)([%w_']*)", tchelper)
end

