local function onenable(self, enable)
    if enable then
        self.inst:AddTag("debuffable")
    else
        self.inst:RemoveTag("debuffable")
    end
end

local Debuffable = Class(function(self, inst)
    self.inst = inst
    self.enable = true
    self.followsymbol = ""
    self.followoffset = Vector3(0, 0, 0)
    self.debuffs = {}

    --V2C: Recommended to explicitly add tag to prefab pristine state
    --inst:AddTag("debuffable")
end,
nil,
{
    enable = onenable,
})

function Debuffable:IsEnabled()
    return self.enable
end

function Debuffable:Enable(enable)
    self.enable = enable
    if not enable then
        local k = next(self.debuffs)
        while k ~= nil do
            self:RemoveDebuff(k)
            k = next(self.debuffs)
        end
    end
end

function Debuffable:RemoveOnDespawn()
    local toremove = {}
    for k, v in pairs(self.debuffs) do
        if not (v.inst.components.debuff ~= nil and v.inst.components.debuff.keepondespawn) then
            table.insert(toremove, k)
        end
    end
    for i, v in ipairs(toremove) do
        self:RemoveDebuff(v)
    end
end

function Debuffable:SetFollowSymbol(symbol, x, y, z)
    self.followsymbol = symbol
    self.followoffset.x = x
    self.followoffset.y = y
    self.followoffset.z = z
    for k, v in pairs(self.debuffs) do
        if v.inst.components.debuff ~= nil then
            v.inst.components.debuff:ChangeFollowSymbol(symbol, self.followoffset)
        end
    end
end

function Debuffable:HasDebuff(name)
    return self.debuffs[name] ~= nil
end

function Debuffable:GetDebuff(name)
    local debuff = self.debuffs[name]
    return debuff ~= nil and debuff.inst or nil
end

local function RegisterDebuff(self, name, ent)
    if ent.components.debuff ~= nil then
        self.debuffs[name] =
        {
            inst = ent,
            onremove = function() self.debuffs[name] = nil end,
        }
        self.inst:ListenForEvent("onremove", self.debuffs[name].onremove, ent)
        ent.persists = false
        ent.components.debuff:AttachTo(name, self.inst, self.followsymbol, self.followoffset)
    else
        ent:Remove()
    end
end

function Debuffable:AddDebuff(name, prefab)
    if self.enable then
		if self.debuffs[name] == nil then
			local ent = SpawnPrefab(prefab)
			if ent ~= nil then
				RegisterDebuff(self, name, ent)
			end
		else
			self.debuffs[name].inst.components.debuff:Extend(self.followsymbol, self.followoffset)
		end
    end
end

function Debuffable:RemoveDebuff(name)
    local debuff = self.debuffs[name]
    if debuff ~= nil then
        self.debuffs[name] = nil
        self.inst:RemoveEventCallback("onremove", debuff.onremove, debuff.inst)
        if debuff.inst.components.debuff ~= nil then
            debuff.inst.components.debuff:OnDetach()
        else
            debuff.inst:Remove()
        end
    end
end

function Debuffable:OnSave()
    if next(self.debuffs) == nil then
        return
    end

    local data = {}
    for k, v in pairs(self.debuffs) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { debuffs = data }
end

function Debuffable:OnLoad(data)
    if data ~= nil and data.debuffs ~= nil then
        for k, v in pairs(data.debuffs) do
            if self.debuffs[k] == nil then
                local ent = SpawnSaveRecord(v)
                if ent ~= nil then
                    RegisterDebuff(self, k, ent)
                end
            end
        end
    end
end

function Debuffable:GetDebugString()
	local str = "Num Buffs: " .. tostring(GetTableSize(self.debuffs))
	
    for k, v in pairs(self.debuffs) do
		str = str .. "\n  " .. tostring(v.inst.prefab)
	end
		
	return str
end

return Debuffable
