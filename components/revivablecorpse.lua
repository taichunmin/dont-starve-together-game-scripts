--This component runs on client as well
local RevivableCorpse = Class(function(self, inst)
    self.inst = inst

    --Common
    self.ismastersim = TheWorld.ismastersim
    --self.canberevivedbyfn = nil

    --Master simulation
    if self.ismastersim then
        self.revive_health_percet = .5
        self.revivespeedmult = 1
        --self.tagmults = nil
    end
end)

--------------------------------------------------------------------------
--Common (but for clients, should only be used for local player)

function RevivableCorpse:SetCanBeRevivedByFn(fn)
    self.canberevivedbyfn = fn
end

function RevivableCorpse:CanBeRevivedBy(reviver)
    return self.inst:HasTag("corpse")
        and (self.canberevivedbyfn == nil or self.canberevivedbyfn(self.inst, reviver))
end

--------------------------------------------------------------------------
--Server only

function RevivableCorpse:SetReviveSpeedMult(mult)
    if self.ismastersim then
        self.revivespeedmult = mult
    end
end

function RevivableCorpse:SetReviveSpeedMultForTag(tag, mult)
    if mult ~= nil and mult ~= 1 then
        if self.tagmults ~= nil then
            self.tagmults[tag] = mult
        else
            self.tagmults = { [tag] = mult }
        end
    elseif self.tagmults ~= nil then
        self.tagmults[tag] = nil
        if next(self.tagmults) == nil then
            self.tagmults = nil
        end
    end
end

function RevivableCorpse:GetReviveSpeedMult(reviver)
    local mult = self.revivespeedmult
    if self.tagmults ~= nil then
        for k, v in pairs(self.tagmults) do
            if reviver:HasTag(k) then
                mult = mult * v
            end
        end
    end
    return mult
end

function RevivableCorpse:SetCorpse(corpse)
    if self.ismastersim then
        if corpse then
            self.inst:AddTag("corpse")
        else
            self.inst:RemoveTag("corpse")
        end
    end
end

function RevivableCorpse:Revive(reviver)
    if self.ismastersim then
        self.inst:PushEvent("respawnfromcorpse", { source = reviver, user = reviver })
    end
end

function RevivableCorpse:SetReviveHealthPercent(percent)
    if self.ismastersim then
        self.revive_health_percet = percent
    end
end

function RevivableCorpse:GetReviveHealthPercent()
    if self.ismastersim then
        return self.revive_health_percet
    end
end

return RevivableCorpse
