local xputil = {}

local function GetLevelProgressFraction()
	local level = TheInventory:GetWXPLevel()
    local wxp = TheInventory:GetWXP()
    
    local curr_level_wxp = TheItems:GetWXPForLevel(level)
    local next_level_wxp = TheItems:GetWXPForLevel(level+1)
	return (wxp - curr_level_wxp), (next_level_wxp-curr_level_wxp)
end

function xputil.GetLevelPercentage()
    local numerator,denominator = GetLevelProgressFraction()
    return numerator / denominator
end

function xputil.BuildProgressString()
    local numerator,denominator = GetLevelProgressFraction()
    return subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num = numerator, max = denominator})
end

return xputil
