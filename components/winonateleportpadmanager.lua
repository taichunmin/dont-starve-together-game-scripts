-- WinonaTeleportPadManager class definition
local WinonaTeleportPadManager = Class(function(self, inst)
    assert(TheWorld.ismastersim, "WinonaTeleportPadManager should not exist on client")
    self.inst = inst

    self.winonateleportpads = {}
    self.inst:ListenForEvent("ms_registerwinonateleportpad", self.OnRegisterWinonaTeleportPad_Bridge)
end)
function WinonaTeleportPadManager:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("ms_registerwinonateleportpad", self.OnRegisterWinonaTeleportPad_Bridge)
    for winonateleportpad, winonateleportpaddata in pairs(self.winonateleportpads) do
        self.inst:RemoveEventCallback("onremove", winonateleportpaddata.onremove, winonateleportpad)
        self.inst:RemoveEventCallback("onbuilt", winonateleportpaddata.onbuilt, winonateleportpad)
    end
end

---------------------------------------------------------------------

function WinonaTeleportPadManager:GetAllWinonaTeleportPads()
    return self.winonateleportpads
end

---------------------------------------------------------------------

WinonaTeleportPadManager.OnRegisterWinonaTeleportPad_Bridge = function(inst, winonateleportpad)
    local self = inst.components.winonateleportpadmanager
    self:OnRegisterWinonaTeleportPad(winonateleportpad)
end
function WinonaTeleportPadManager:OnRegisterWinonaTeleportPad(winonateleportpad)
    local winonateleportpaddata = {}
    local function onremove()
        self.winonateleportpads[winonateleportpad] = nil
    end
    local onbuilttask = nil
    local function onbuilt()
        if onbuilttask ~= nil then
            onbuilttask:Cancel()
            onbuilttask = nil
        end

        self.winonateleportpads[winonateleportpad] = winonateleportpaddata
        self.inst:ListenForEvent("onremove", onremove, winonateleportpad)
    end
    winonateleportpaddata.onremove = onremove
    winonateleportpaddata.onbuilt = onbuilt
    self.inst:ListenForEvent("onbuilt", onbuilt, winonateleportpad)
    onbuilttask = winonateleportpad:DoTaskInTime(0, onbuilt)
end

return WinonaTeleportPadManager
