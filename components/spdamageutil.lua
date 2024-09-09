local SpDamageUtil = {} -- Singleton.


local SpTypeMap = {}
SpDamageUtil.DefineSpType = function(sptype, spdata)
    local fns = SpTypeMap[sptype]
    assert(fns == nil) -- Unique namespace across everything including mods.

    SpTypeMap[sptype] = spdata
end


-- NOTES(JBK): If DefineSpType is given a definition with fields that are missing these will be used instead.
-- This will be the case when we add more functions here and mods will not have them defined.
local Fallbacks = {
    GetDamage = function(ent) return 0 end,
    GetDefense = function(ent) return 0 end,
}

SpDamageUtil.DefineSpType("planar", {
    GetDamage = function(ent)
        return ent.components.planardamage ~= nil and ent.components.planardamage:GetDamage() or 0
    end,
    GetDefense = function(ent)
        return ent.components.planardefense ~= nil and ent.components.planardefense:GetDefense() or 0
    end,
})


SpDamageUtil.GetSpDamageForType = function(ent, sptype)
	local fns = SpTypeMap[sptype]
	return fns ~= nil and (fns.GetDamage or Fallbacks.GetDamage)(ent) or 0
end

SpDamageUtil.GetSpDefenseForType = function(ent, sptype)
	local fns = SpTypeMap[sptype]
	return fns ~= nil and (fns.GetDefense or Fallbacks.GetDefense)(ent) or 0
end

SpDamageUtil.CollectSpDamage = function(ent, tbl)
	for sptype in pairs(SpTypeMap) do
		local dmg = SpDamageUtil.GetSpDamageForType(ent, sptype)
		if dmg > 0 then
			tbl = tbl or {}
			tbl[sptype] = (tbl[sptype] or 0) + dmg
		end
	end
	return tbl
end

SpDamageUtil.MergeSpDamage = function(tbl1, tbl2)
	if tbl1 ~= nil and tbl2 ~= nil then
		for k, v in pairs(tbl2) do
			tbl1[k] = (tbl1[k] or 0) + v
		end
		return tbl1
	end
	return tbl1 or tbl2
end

SpDamageUtil.CalcTotalDamage = function(tbl)
	local dmg = 0
	if tbl ~= nil then
		for k, v in pairs(tbl) do
			dmg = dmg + v
		end
	end
	return dmg
end

SpDamageUtil.ApplyMult = function(tbl, mult)
	if tbl ~= nil then
		for k, v in pairs(tbl) do
			tbl[k] = mult ~= 0 and v * mult or nil
		end
		if next(tbl) == nil then
			tbl = nil
		end
	end
	return tbl
end

SpDamageUtil.ApplySpDefense = function(ent, tbl)
	if tbl ~= nil then
		for k, v in pairs(tbl) do
			local def = SpDamageUtil.GetSpDefenseForType(ent, k)
			if def > 0 then
				tbl[k] = v > def and v - def or nil
			end
		end
		if next(tbl) == nil then
			tbl = nil
		end
	end
	return tbl
end

-- Mod accessors for internal data tables.
-- Mods modifying these should be careful and very mindful of other mods interfacing with them.
SpDamageUtil._SpTypeMap = SpTypeMap
SpDamageUtil._Fallbacks = Fallbacks

return SpDamageUtil
