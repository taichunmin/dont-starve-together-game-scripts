wxputils = {}

local function GetLevelProgressFraction()
	local level = TheInventory:GetWXPLevel(GetActiveFestivalEventServerName())
    local wxp = TheInventory:GetWXP(GetActiveFestivalEventServerName())

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


function wxputils.GetLevel(festival_key, season)
    return TheInventory:GetWXPLevel(GetFestivalEventServerName(festival_key, season))
end

function wxputils.GetActiveLevel()
	return TheInventory:GetWXPLevel(GetActiveFestivalEventServerName())
end

function wxputils.GetLevelForWXP(wxp)
    return TheItems:GetLevelForWXP(wxp)
end

function wxputils.GetWXPForLevel(level)
    return TheItems:GetWXPForLevel(level), TheItems:GetWXPForLevel(level+1)
end

function wxputils.GetActiveWXP()
    return TheInventory:GetWXP(GetActiveFestivalEventServerName())
end

function wxputils.GetEventStatus(festival_key, season, cb_fn)
    TheItems:GetEventStatus(GetFestivalEventServerName(festival_key, season), cb_fn)
end