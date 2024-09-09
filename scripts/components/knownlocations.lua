local KnownLocations = Class(function(self, inst)
    self.inst = inst
    self.locations = {}
end)

function KnownLocations:GetDebugString()
    --if self.inst.components.debugger == nil then
        --self.inst:AddComponent("debugger")
    --end
    --local ci = 0

    local str = ""
    for k,v in pairs(self.locations) do
        str = str..string.format("%s: %s ", k, tostring(v))

        --self.inst.components.debugger:SetAll("knownloc_"..k, self.inst:GetPosition(), v,
            --{
                --r=(ci%6==0 or ci%6==1 or ci%6==2) and 1 or 0,
                --g=(ci%6==2 or ci%6==3 or ci%6==4) and 1 or 0,
                --b=(ci%6==4 or ci%6==5 or ci%6==0) and 1 or 0,
                --a=1,
            --}
        --)
        --ci = ci+1
    end
    return str
end

function KnownLocations:SerializeLocations()
    local locs = nil
    for location_name, location_position in pairs(self.locations) do
        locs = locs or {}
        table.insert(locs, {
            name = location_name,
            x = location_position.x,
            y = location_position.y,
            z = location_position.z
        })
    end
    return locs
end

function KnownLocations:DeserializeLocations(data)
    for _, location in pairs(data) do
        self:RememberLocation(location.name, Vector3(location.x, location.y, location.z))
    end
end

function KnownLocations:OnSave()
    local serialized_locations = self:SerializeLocations()
    return (serialized_locations ~= nil and {locations = serialized_locations})
        or nil
end

function KnownLocations:OnLoad(data)
    if data and data.locations then
        self:DeserializeLocations(data.locations)
    end
end

function KnownLocations:RememberLocation(name, pos, dont_overwrite)
	if not dont_overwrite or self.locations[name] == nil then
        self.locations[name] = pos
		if pos ~= nil and (isbadnumber(pos.x) or isbadnumber(pos.y) or isbadnumber(pos.z)) then
			print("KnownLocations:RememberLocation position error: ", self.inst.prefab, self.inst:IsValid(), pos.x, pos.y, pos.z)
			error("Error: KnownLocations:RememberLocation() recieved a bad pos value.")
		end
    end
end

function KnownLocations:GetLocation(name)
    return self.locations[name]
end

function KnownLocations:ForgetLocation(name)
    self.locations[name] = nil
end

return KnownLocations
