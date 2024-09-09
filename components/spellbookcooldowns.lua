local SpellBookCooldowns = Class(function(self, inst)
	self.inst = inst
	self.ismastersim = TheWorld.ismastersim
	self.cooldowns = {}

	self._onremovecd = function(cd)
		local spellname = cd:GetSpellName()
		if spellname == 0 then
			print("SpellbookCooldowns::_onremovecd: invalid spellname")
		elseif self.cooldowns[spellname] == nil then
			print("SpellbookCooldowns::_onremovecd: missing spellname \""..(cd.dbg_spellname or tostring(spellname)).."\"")
		else
			self.cooldowns[spellname] = nil
		end
	end
end)

local function GetHash(spellname)
	return type(spellname) == "string" and hash(spellname) or spellname
end

--------------------------------------------------------------------------
--Common

function SpellBookCooldowns:IsInCooldown(spellname)
	return self.cooldowns[GetHash(spellname)] ~= nil
end

function SpellBookCooldowns:GetSpellCooldownPercent(spellname)
	local cd = self.cooldowns[GetHash(spellname)]
	return cd and cd:GetPercent() or nil
end

function SpellBookCooldowns:RegisterSpellbookCooldown(cd)
	local spellname = cd:GetSpellName()
	if spellname == 0 then
		print("SpellbookCooldowns::RegisterSpellbookCooldown: invalid spellname")
	elseif self.cooldowns[spellname] then
		print("SpellbookCooldowns::RegisterSpellbookCooldown: duplicate spellname \""..(cd.dbg_spellname or tostring(spellname)).."\"")
	else
		self.cooldowns[spellname] = cd
		self.inst:ListenForEvent("onremove", self._onremovecd, cd)
	end
end

--------------------------------------------------------------------------
--Server only

function SpellBookCooldowns:RestartSpellCooldown(spellname, duration)
	if self.ismastersim then
		local spellhash = GetHash(spellname)
		local cd = self.cooldowns[spellhash]
		if cd then
			cd:RestartSpellCooldown(duration)
		else
			cd = SpawnPrefab("spellbookcooldown")
			cd.entity:SetParent(self.inst.entity)
			cd.Network:SetClassifiedTarget(self.inst)
			cd:InitSpellCooldown(spellhash, duration)
			cd.dbg_spellname = spellname
			self:RegisterSpellbookCooldown(cd)
		end
	end
end

function SpellBookCooldowns:StopSpellCooldown(spellname)
	if self.ismastersim then
		spellname = GetHash(spellname)
		local cd = self.cooldowns[spellname]
		if cd then
			cd:Remove()
		end
	end
end

--------------------------------------------------------------------------
--Debug

function SpellBookCooldowns:GetDebugString()
	local str
	for k, v in pairs(self.cooldowns) do
		str = (str or "")..string.format("\n[%d]%s: %.2f%% (%ds)", v:GetSpellName(), v.dbg_spellname and ("("..v.dbg_spellname..")") or "", v:GetPercent() * 100, v:GetLength())
	end
	return str
end

return SpellBookCooldowns
