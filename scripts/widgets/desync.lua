local Widget = require "widgets/widget"

-------------------------------------------------------------------------------------------------------

local SHOW_DELAY = 1
local PERF_INTERVAL = .5
local PERF_INTERVAL_INITIAL = 3
local HUD_ATLAS = "images/hud.xml"
local STATES =
{
    ["waiting"] = { icon = "desync1.tex", blink = 10 },
    ["buffering"] = { icon = "desync2.tex", blink = 7.5 },
    ["warning"] = { icon = "connectivity2.tex", blink = 5, scale = .75 },
    ["alert"] = { icon = "connectivity1.tex", blink = 7.5, scale = .75 },
    ["hostwarning"] = { icon = "hostperf2.tex", blink = 5, scale = .75 },
    ["hostalert"] = { icon = "hostperf1.tex", blink = 7.5, scale = .75 },
}

local Desync = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "Desync")

    local w, h = 60, 80
    self._icon = self:AddChild(Image())
    self._icon:SetClickable(false)
    self._icon:SetPosition(w / 2 + 4, - h / 2 - 3)
    self._icon:SetTint(1, 1, 1, 0)

    self._state = nil
    self._perf = nil
    self._statedirty = false
    self._showhostperf = nil
    self._step = 0
    self._blinkspeed = 10
    self._delay = SHOW_DELAY
    self._perfdelay = PERF_INTERVAL_INITIAL
    self:Hide()
    self:StartUpdating()

    self.inst:ListenForEvent("desync_waiting", function() self:SetState("waiting") end, owner)
    self.inst:ListenForEvent("desync_buffering", function() self:SetState("buffering") end, owner)
    self.inst:ListenForEvent("desync_resumed", function() self:SetState() end, owner)
end)

function Desync:ShowHostPerf(show)
    self._showhostperf = show ~= false or nil
end

function Desync:OnUpdate(dt)
    if self._perfdelay > dt then
        self._perfdelay = self._perfdelay - dt
    else
        self:RefreshPerf()
    end

    --At the end of each blink, check for state change
    if not self.shown then
        return
    elseif self._statedirty and self._step <= 0 then
        local state = STATES[self._state]
        if state ~= nil then
            self._icon:SetTexture(HUD_ATLAS, state.icon)
            self._icon:SetScale(state.scale or 1)
            self._blinkspeed = state.blink
        else
            self._icon:SetTint(1, 1, 1, 0)
            self:Hide()
            --self:StopUpdating()
            self._delay = SHOW_DELAY
            return
        end
    end

    if self._delay > dt then
        self._delay = self._delay - dt
    else
        self._delay = 0
        self._icon:SetTint(1, 1, 1, (self._step > 255 and 510 - self._step or self._step) / 255)
        self._step = self._step + self._blinkspeed
        if self._step >= 510 then
            self._step = 0
        end
    end
end

function Desync:RefreshPerf()
    self._perfdelay = PERF_INTERVAL

    if self._showhostperf then
        local client_objs = TheNet:GetClientTable()
        if client_objs ~= nil then
            for i, v in ipairs(client_objs) do
                if v.performance ~= nil then
                    if v.performance > 0 then
                        self:SetPerf(v.performance > 1 and "hostalert" or "hostwarning")
                        return
                    elseif v.userid == self.owner.userid and TheNet:GetServerIsClientHosted() then
                        self:SetPerf()
                        return
                    end
                elseif v.userid == self.owner.userid then
                    self:SetPerf(
                        v.netscore ~= nil and (
                            (v.netscore > 1 and "alert") or
                            (v.netscore == 1 and "warning")
                        ) or nil
                    )
                    return
                end
            end
        end
        self:SetPerf()
        return
    end

    local client = TheNet:GetClientTableForUser(self.owner.userid)
    local perfscore = client ~= nil and (client.netscore --[[or client.performance]]) or -1
    self:SetPerf(
        (perfscore > 1 and "alert") or
        (perfscore == 1 and "warning") or
        nil)
end

function Desync:SetPerf(perf)
    local statedirty = false
    if STATES[perf] == nil then
        statedirty = self._state == self._perf
        self._perf = nil
    elseif self._perf ~= perf then
        statedirty = self._state == nil or self._state == self._perf
        self._perf = perf
    end
    if statedirty then
        self:SetState(self._perf)
    end
end

function Desync:SetState(state)
    if STATES[state] ~= nil then
        if self._state ~= state then
            self._state = state
            self._statedirty = true
        end
        if not self.shown then
            self:Show()
            --self:StartUpdating()
        end
    elseif self._state ~= self._perf then
        self._state = self._perf
        self._statedirty = true
    end
end

return Desync
