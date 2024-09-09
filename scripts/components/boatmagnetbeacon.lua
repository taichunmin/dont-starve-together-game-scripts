local function OnPickup(inst, data)
    local self = inst.components.boatmagnetbeacon
    self:SetIsPickedUp(true)
end

local function OnDropped(inst, data)
    local self = inst.components.boatmagnetbeacon
    self:SetIsPickedUp(false)
end

local function SetupBoatTask(inst, self)
    self = self or inst.components.boatmagnetbeacon
    if not self then
        return
    end

    self:SetBoat(inst:GetCurrentPlatform())

    if self.magnet_guid then
        local x, y, z = inst.Transform:GetWorldPosition()
        local nearby_magnets = TheSim:FindEntities(x, y, z, self.magnet_distance, self.magnet_must_tags, self.magnet_cant_tags)
        local magnet = nil
        for _, nearby_magnet in ipairs(nearby_magnets) do
            if nearby_magnet.components.boatmagnet and nearby_magnet.components.boatmagnet.magnet_guid == self.magnet_guid then
                magnet = nearby_magnet
                break
            end
        end

        if magnet then -- We already know it has the component, from above.
            magnet.components.boatmagnet:PairWithBeacon(inst)
            self.magnet = magnet
            self.magnet_guid = magnet.GUID
        else
            self.magnet = nil
            self.magnet_guid = nil
        end
    end

    self._setup_boat_task = nil
end

local DEFAULT_MAGNET_MUST_TAGS = {"boatmagnet"}
local DEFAULT_MAGNET_CANT_TAGS = {"paired"}
local BoatMagnetBeacon = Class(function(self, inst)
    self.inst = inst
    self.turnedoff = false
    self.ispickedup = false

    --self.boat = nil
    --self.magnet = nil
    --self.magnet_guid = nil

    self.magnet_must_tags = DEFAULT_MAGNET_MUST_TAGS
    self.magnet_cant_tags = DEFAULT_MAGNET_CANT_TAGS
    self.magnet_distance = TUNING.BOAT.BOAT_MAGNET.MAX_DISTANCE

    self.OnBoatRemoved = function() self.boat = nil end
    self.OnBoatDeath = function() self:OnDeath() end

    self._setup_boat_task = self.inst:DoTaskInTime(0, SetupBoatTask, self)

    self.inst:ListenForEvent("onpickup", OnPickup)
    self.inst:ListenForEvent("ondropped", OnDropped)
end)

function BoatMagnetBeacon:OnSave()
    local data = {
        turnedoff = self.turnedoff,
        ispickedup = self.ispickedup,
        magnet_guid = self.magnet_guid,
    }
    return data
end

function BoatMagnetBeacon:OnLoad(data)
    if not data then
        return
    end

    self.turnedoff = data.turnedoff
    if self.turnedoff then
        self.inst:AddTag("turnedoff")
    end

    self.ispickedup = data.ispickedup

     -- NOTES(JBK): 'prev_guid' is for beta worlds that might have this old vague name.
    self.magnet_guid = data.magnet_guid or data.prev_guid

    local inventoryitem = self.inst.components.inventoryitem
    if inventoryitem then
        local image_name = ((not self.boat or self.turnedoff) and "boat_magnet_beacon")
            or "boat_magnet_beacon_on"
        if image_name ~= inventoryitem.imagename then
            inventoryitem:ChangeImageName(image_name)
        end
    end
end

function BoatMagnetBeacon:OnRemoveFromEntity()
	if self._setup_boat_task then
		self._setup_boat_task:Cancel()
        self._setup_boat_task = nil
	end
    self.inst:RemoveEventCallback("onpickup", OnPickup)
    self.inst:RemoveEventCallback("ondropped", OnDropped)
end

function BoatMagnetBeacon:OnRemoveEntity()
    if self then
        self:SetBoat(nil)
    end
end

function BoatMagnetBeacon:GetBoat()
    -- Get the carrying thing first, or the owner entity instance if it is not carried.
    local boat = (self.inst.entity:GetParent() or self.inst):GetCurrentPlatform()
    self.boat = (boat ~= nil and boat:HasTag("boat") and boat) or nil
    return self.boat
end

function BoatMagnetBeacon:SetBoat(boat)
    if boat == self.boat then return end

    if self.boat then
        self.inst:RemoveEventCallback("onremove", self.OnBoatRemoved, self.boat)
        self.inst:RemoveEventCallback("death", self.OnBoatDeath, self.boat)
    end

    self.boat = boat

    if boat then
        self.inst:ListenForEvent("onremove", self.OnBoatRemoved, boat)
        self.inst:ListenForEvent("death", self.OnBoatDeath, boat)
    end
end

function BoatMagnetBeacon:OnDeath()
    if self.inst:IsValid() then
        self:SetBoat(nil)
    end
end

function BoatMagnetBeacon:PairedMagnet()
    return self.magnet
end

function BoatMagnetBeacon:PairWithMagnet(magnet)
    if self.magnet or not magnet then
        return
    end

    self.magnet = magnet
    self.magnet_guid = self.magnet.GUID

    self.inst:ListenForEvent("onremove", self.UnpairWithMagnet, self.magnet)
    self.inst:ListenForEvent("death", self.UnpairWithMagnet, self.magnet)

    self:TurnOnBeacon()
    self.inst:AddTag("paired")
end

function BoatMagnetBeacon:UnpairWithMagnet()
    if not self.magnet then
        return
    end

    self.inst:RemoveEventCallback("onremove", self.UnpairWithMagnet, self.magnet)
    self.inst:RemoveEventCallback("death", self.UnpairWithMagnet, self.magnet)

    self.magnet = nil
    self.magnet_guid = nil

    self:TurnOffBeacon()
    self.inst:RemoveTag("paired")
end

function BoatMagnetBeacon:IsTurnedOff()
    return self.turnedoff
end

function BoatMagnetBeacon:TurnOnBeacon()
    self.turnedoff = false

    if self.inst.components.inventoryitem then
        self.inst.components.inventoryitem:ChangeImageName("boat_magnet_beacon_on")
    end

    if self.inst.sg then
        self.inst.sg:GoToState("activate")
    end
    self.inst:PushEvent("onturnon")

    self.inst:RemoveTag("turnedoff")
end

function BoatMagnetBeacon:TurnOffBeacon()
    self.turnedoff = true

    if self.inst.components.inventoryitem then
        self.inst.components.inventoryitem:ChangeImageName("boat_magnet_beacon")
    end

    self.inst.sg:GoToState("deactivate")
    self.inst:PushEvent("onturnoff")

    self.inst:AddTag("turnedoff")
end

function BoatMagnetBeacon:IsPickedUp()
    return self.ispickedup
end

function BoatMagnetBeacon:SetIsPickedUp(pickedup)
    self.ispickedup = pickedup
    self.boat = (not pickedup and self:GetBoat()) or nil
end

--
function BoatMagnetBeacon:GetDebugString()
    return (self.magnet ~= nil and tostring(self.magnet)) or ""
end

return BoatMagnetBeacon
