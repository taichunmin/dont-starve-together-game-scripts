local FollowText = require "widgets/followtext"

local DEFAULT_OFFSET = Vector3(0, -400, 0)

Line = Class(function(self, message, noanim, duration)
    self.message = message
    self.noanim = noanim
	self.duration = duration
end)

local Talker = Class(function(self, inst)
    self.inst = inst
    self.task = nil
    self.ignoring = nil
    self.mod_str_fn = nil
    self.offset = nil
    self.offset_fn = nil
    self.disablefollowtext = nil
    self.resolvechatterfn = nil
end)

function Talker:SetOffsetFn(fn)
    self.offset_fn = fn
end

local function ResolveChatterString(self, strid, strtbl)
    if self.resolvechatterfn then
        return self.resolvechatterfn(self.inst, strid, strtbl)
    end

    local stringtable = STRINGS[strtbl:value()]
    if stringtable ~= nil then
        return stringtable[strid:value()]
    end

    return nil
end

--"Chatter" functionality works together with ChattyNode and combat shouts, for NPC characters
local function OnChatterDirty(inst)
    local self = inst.components.talker

    if #self.chatter.strtbl:value() > 0 then

        local str = ResolveChatterString(self, self.chatter.strid, self.chatter.strtbl)

        if str ~= nil then
            local t = self.chatter.strtime:value()
            self:Say(str, t > 0 and t or nil, self.chatter.forcetext:value(), self.chatter.forcetext:value(), true)
            return
        end
    end

    self:ShutUp()
end

function Talker:MakeChatter()
    if self.chatter == nil then
        --for npc
        self.chatter =
        {
            strtbl = net_string(self.inst.GUID, "talker.chatter.strtbl", "chatterdirty"),
            strid = net_tinybyte(self.inst.GUID, "talker.chatter.strid", "chatterdirty"),
            strtime = net_tinybyte(self.inst.GUID, "talker.chatter.strtime"),
            forcetext = net_bool(self.inst.GUID, "talker.chatter.forcetext"),
        }
        if not TheWorld.ismastersim then
            self.inst:ListenForEvent("chatterdirty", OnChatterDirty)
        end
    end
end

local function OnCancelChatter(inst, self)
    self.chatter.task = nil
    self.chatter.strtbl:set_local("")
end

--NOTE: forcetext chatter translates to noanim + force say
function Talker:Chatter(strtbl, strid, time, forcetext)
    if self.chatter ~= nil and TheWorld.ismastersim then
        self.chatter.strtbl:set(strtbl)
        --force at least the id dirty, so that it's possible to repeat strings
        self.chatter.strid:set_local(strid)
        self.chatter.strid:set(strid)
        self.chatter.strtime:set(time or 0)
        self.chatter.forcetext:set(forcetext == true)
        if self.chatter.task ~= nil then
            self.chatter.task:Cancel()
        end
        self.chatter.task = self.inst:DoTaskInTime(1, OnCancelChatter, self)
        OnChatterDirty(self.inst)
    end
end

function Talker:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("chatterdirty", OnChatterDirty)
    if TheWorld.ismastersim then
        self.inst:RemoveTag("ignoretalking")
    end
    self:ShutUp()
end

function Talker:IgnoreAll(source)
    if self.ignoring == nil then
        self.ignoring = { [source or self] = true }
        if TheWorld.ismastersim then
            self.inst:AddTag("ignoretalking")
        end
    else
        self.ignoring[source or self] = true
    end
end

function Talker:StopIgnoringAll(source)
    if self.ignoring == nil then
        return
    end
    self.ignoring[source or self] = nil
    if next(self.ignoring) == nil then
        self.ignoring = nil
        if TheWorld.ismastersim then
            self.inst:RemoveTag("ignoretalking")
        end
    end
end

local function sayfn(self, script, nobroadcast, colour, text_filter_context, original_author_netid)
    local player = ThePlayer
    if (not self.disablefollowtext) and self.widget == nil and player ~= nil and player.HUD ~= nil then
        self.widget = player.HUD:AddChild(FollowText(self.font or TALKINGFONT, self.fontsize or 35))
        self.widget:SetHUD(player.HUD.inst)
    end

    if self.widget ~= nil then
        self.widget.symbol = self.symbol
        self.widget:SetOffset(self.offset_fn ~= nil and self.offset_fn(self.inst) or self.offset or DEFAULT_OFFSET)
        self.widget:SetTarget(self.inst)
        if colour ~= nil then
            self.widget.text:SetColour(unpack(colour))
        elseif self.colour ~= nil then
            self.widget.text:SetColour(self.colour.x, self.colour.y, self.colour.z, 1)
        end
    end

    for i, line in ipairs(script) do
		local duration = math.min(line.duration or self.lineduration or TUNING.DEFAULT_TALKER_DURATION, TUNING.MAX_TALKER_DURATION)
        if line.message ~= nil then
            local display_message = GetSpecialCharacterPostProcess(
                        self.inst.prefab,
                        self.mod_str_fn ~= nil and self.mod_str_fn(line.message) or line.message
                    )

            if not nobroadcast then
                TheNet:Talker(line.message, self.inst.entity, duration ~= TUNING.DEFAULT_TALKER_DURATION and duration or nil, text_filter_context, original_author_netid)
            end

            if self.widget ~= nil then
				--print("talker sayfn:", original_author, text_filter_context, display_message)
		        local filtered_message = display_message ~= nil and ApplyLocalWordFilter(display_message, text_filter_context, original_author_netid) or display_message
                self.widget.text:SetString(filtered_message)
            end

            if self.ontalkfn ~= nil then
                self.ontalkfn(self.inst, { noanim = line.noanim, message=display_message })
            end

            self.inst:PushEvent("ontalk", { noanim = line.noanim, duration = duration })
        elseif self.widget ~= nil then
            self.widget:Hide()
        end
        Sleep(duration)
        if not self.inst:IsValid() or (self.widget ~= nil and not self.widget.inst:IsValid()) then
            return
        end
    end

    if self.widget ~= nil then
        self.widget:Kill()
        self.widget = nil
    end

    if self.donetalkingfn ~= nil then
        self.donetalkingfn(self.inst)
    end

    self.inst:PushEvent("donetalking")
    self.task = nil
end

local function CancelSay(self)
    if self.widget ~= nil then
        self.widget:Kill()
        self.widget = nil
    end

    if self.task ~= nil then
        scheduler:KillTask(self.task)
        self.task = nil

        if self.donetalkingfn ~= nil then
            self.donetalkingfn(self.inst)
        end

        self.inst:PushEvent("donetalking")
    end
end

function Talker:Say(script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid)
    if TheWorld.speechdisabled then return nil end
    if TheWorld.ismastersim then
        if not force
            and (self.ignoring ~= nil or
                (self.inst.components.health ~= nil and self.inst.components.health:IsDead() and self.inst.components.revivablecorpse == nil) or
                (self.inst.components.sleeper ~= nil and self.inst.components.sleeper:IsAsleep())) then
            return
        elseif self.ontalk ~= nil then
            self.ontalk(self.inst, script)
        end
    elseif not force then
        if self.inst:HasTag("ignoretalking") then
            return
        elseif self.inst.components.revivablecorpse == nil then
            local health = self.inst.replica.health
            if health ~= nil and health:IsDead() then
                return
            end
        end
    end

    CancelSay(self)
    local lines = type(script) == "string" and { Line(script, noanim, time) } or script
    if lines ~= nil then
        self.task = self.inst:StartThread(function() sayfn(self, lines, nobroadcast, colour, text_filter_context, original_author_netid) end)
    end
end

function Talker:ShutUp()
    CancelSay(self)

    if self.chatter ~= nil and TheWorld.ismastersim then
        self.chatter.strtbl:set("")
        if self.chatter.task ~= nil then
            self.chatter.task:Cancel()
            self.chatter.task = nil
        end
    end
end

Talker.OnRemoveEntity = CancelSay

return Talker
