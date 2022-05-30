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
    local locs = {}
        for k,v in pairs(self.locations) do
            table.insert(locs, {name = k, x = v.x, y = v.y, z = v.z})
        end
    return locs
end

function KnownLocations:DeserializeLocations(data)
    for k,v in pairs(data) do
        self:RememberLocation(v.name, Vector3(v.x, v.y, v.z))
    end
end

function KnownLocations:OnSave()
    local data = {}

    data.locations = self:SerializeLocations()

    return data
end

function KnownLocations:OnLoad(data)
    if data then
        if data.locations then
            self:DeserializeLocations(data.locations)
        end
    end
end

function KnownLocations:RememberLocation(name, pos, dont_overwrite)
    if not self.locations[name] or not dont_overwrite then
        self.locations[name] = pos
		if pos ~= nil and (pos.x ~= pos.x or pos.y ~= pos.y or pos.z ~= pos.z) then
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
