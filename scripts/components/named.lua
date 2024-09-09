local Named = Class(function(self, inst)
    self.inst = inst
    --self.possiblenames = nil
    --self.nameformat = nil
    --self.name = nil
	--self.name_author_netid = nil		-- NOTE: This is the user's platform id, not KU
end)

local function DoSetName(self)
    self.inst.name = self.nameformat ~= nil and string.format(self.nameformat, self.name) or self.name
	self.inst.name_author_netid = self.name_author_netid
    self.inst.replica.named:SetName(self.inst.name, self.inst.name_author_netid or "")
end

function Named:PickNewName()
    if self.possiblenames ~= nil and #self.possiblenames > 0 then
        self.name = self.possiblenames[math.random(#self.possiblenames)]
        DoSetName(self)
    end
end

function Named:SetName(name, author)
    self.name = name
    self.name_author_netid = author ~= nil and TheNet:GetNetIdForUser(author) or nil
    if name == nil then
        self.inst.name = STRINGS.NAMES[string.upper(self.inst.prefab)]
        self.inst.replica.named:SetName("", "")
    else
        DoSetName(self)
    end
end

function Named:OnSave()
    return
        self.name ~= nil
        and {
                name = self.name,
                nameformat = self.nameformat,
                name_author_netid = self.name_author_netid,
            }
        or nil
end

function Named:OnLoad(data)
    if data ~= nil and data.name ~= nil then
        self.nameformat = data.nameformat
        self.name = data.name
        self.name_author_netid = data.name_author_netid
        DoSetName(self)
    end
end

return Named