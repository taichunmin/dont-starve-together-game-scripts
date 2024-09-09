local function OnUpdateGiftItems(inst)
    inst.components.giftreceiver:RefreshGiftCount()
end

local function OnInit(inst, delay)
    if delay > 0 then
        inst:DoTaskInTime(0, OnInit, delay - 1)
    else
        --From GiftingManager.cpp
        inst:ListenForEvent("ms_updategiftitems", OnUpdateGiftItems)
        OnUpdateGiftItems(inst)
    end
end

local function ongiftcount(self, giftcount)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.hasgift:set(giftcount > 0)
    end
end

local function ongiftmachine(self, giftmachine)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.hasgiftmachine:set(giftmachine ~= nil)
    end
end

local GiftReceiver = Class(function(self, inst)
    self.inst = inst

    self.giftcount = 0
    self.giftmachine = nil

    self.onclosepopup = function(doer, data)
        if data.popup == POPUPS.GIFTITEM then
            self:OnStopOpenGift(data.args[1])
        end
    end
    inst:ListenForEvent("ms_closepopup", self.onclosepopup)
    --Delay init because a couple frames to wait for userid set
    inst:DoTaskInTime(0, OnInit, 1)
end,
nil,
{
    giftcount = ongiftcount,
    giftmachine = ongiftmachine,
})

function GiftReceiver:OnRemoveFromEntity()
    inst:RemoveEventCallback("ms_closepopup", self.onclosepopup)
    inst:RemoveEventCallback("ms_updategiftitems", OnUpdateGiftItems)
end

function GiftReceiver:HasGift()
    return self.giftcount > 0
end

function GiftReceiver:RefreshGiftCount()
    local giftcount = TheInventory:GetClientGiftCount(self.inst.userid)
    if giftcount ~= self.giftcount then
        local old = self.giftcount
        self.giftcount = giftcount
        if self.giftmachine ~= nil then
            if giftcount > 0 then
                if old <= 0 then
                    self.giftmachine:PushEvent("ms_addgiftreceiver", self.inst)
                end
            elseif old > 0 then
                self.giftmachine:PushEvent("ms_removegiftreceiver", self.inst)
            end
        end
    end
end

function GiftReceiver:SetGiftMachine(inst)
    if self.giftmachine ~= inst then
        local old = self.giftmachine
        self.giftmachine = inst
        if self.giftcount > 0 then
            if old ~= nil then
                old:PushEvent("ms_removegiftreceiver", self.inst)
            end
            if inst ~= nil then
                inst:PushEvent("ms_addgiftreceiver", self.inst)
            end
        end
        if inst == nil then
            self:OnStopOpenGift()
        end
    end
end

function GiftReceiver:OpenNextGift()
    if self.giftcount > 0 and self.giftmachine ~= nil then
        self.inst:PushEvent("ms_opengift")
    end
end

function GiftReceiver:OnStartOpenGift()
    if self.giftmachine ~= nil then
        self.giftmachine:PushEvent("ms_giftopened")
    end
end

function GiftReceiver:OnStopOpenGift(usewardrobe)
    self.inst:PushEvent("ms_doneopengift", usewardrobe and { wardrobe = self.giftmachine } or nil)
end

return GiftReceiver
