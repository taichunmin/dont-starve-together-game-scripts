local YOTB_SkinUnlocker = Class(function(self, inst)
    self.inst = inst
end)

function YOTB_SkinUnlocker:SetSkin(skin)
    self.skin = skin
end

function YOTB_SkinUnlocker:GetSkin()
    return self.skin
end

return YOTB_SkinUnlocker