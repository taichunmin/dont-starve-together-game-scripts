wxputils = {}

local function GetLevelProgressFraction()
	local level = TheInventory:GetWXPLevel(GetFestivalEventServerName(WORLD_FESTIVAL_EVENT))
    local wxp = TheInventory:GetWXP(GetFestivalEventServerName(WORLD_FESTIVAL_EVENT))
    
    local curr_level_wxp = TheItems:GetWXPForLevel(level)
    local next_level_wxp = TheItems:GetWXPForLevel(level+1)
	return (wxp - curr_level_wxp), (next_level_wxp-curr_level_wxp)
end

function wxputils.GetLevelPercentage()
    local numerator,denominator = GetLevelProgressFraction()
    return numerator / denominator
end

function wxputils.BuildProgressString()
    local numerator,denominator = GetLevelProgressFraction()
    return subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num = numerator, max = denominator})
end


function wxputils.GetLevel(festival_key)
    return TheInventory:GetWXPLevel(GetFestivalEventServerName(festival_key))
end

function wxputils.GetActiveLevel()
    --TheItems:GetLevelForWXP(TheInventory:GetWXP(GetFestivalEventServerName(WORLD_FESTIVAL_EVENT))) --this was the previous calculation we were using, but we have the level already.
	return TheInventory:GetWXPLevel(GetFestivalEventServerName(WORLD_FESTIVAL_EVENT))
end

function wxputils.GetLevelForWXP(wxp)
    return TheItems:GetLevelForWXP(wxp)
end

function wxputils.GetWXPForLevel(level)
    return TheItems:GetWXPForLevel(level), TheItems:GetWXPForLevel(level+1)
end

function wxputils.GetActiveWXP()
    return TheInventory:GetWXP(GetFestivalEventServerName(WORLD_FESTIVAL_EVENT))
end

function wxputils.GetEventStatus(festival_key, cb_fn)
    TheItems:GetEventStatus(GetFestivalEventServerName(festival_key), cb_fn)
end