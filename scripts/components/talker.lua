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

    local strtbl_value = strtbl:value()
    local table_entries = strtbl_value:split(".")
    local num_entries = #table_entries
    local stringtable = STRINGS
    for i, entry in ipairs(table_entries) do
        stringtable = stringtable[entry]
        if stringtable == nil then
            return nil
        elseif i == num_entries then
            local id = strid:value()
            return (id == 0 and stringtable) or stringtable[id]
        end
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
            local forcetext = self.chatter.forcetext:value()
            self:Say(str, (t > 0 and t) or nil, forcetext, forcetext, true)

            local echotochatpriority = self.chatter.echotochatpriority:value()
            if echotochatpriority > 0 then
                local hud = ThePlayer and ThePlayer.HUD or nil
                if hud and ThePlayer:GetDistanceSqToInst(inst) <= PLAYER_CAMERA_SEE_DISTANCE_SQ then -- NOTES(JBK): Replicate range check for chatter. [RCCHATTER]
                    -- Replicate to chat.
                    local name_colour = self.name_colour and {self.name_colour.x, self.name_colour.y, self.name_colour.z, 1} or WHITE
                    local colour = self.colour and {self.colour.x, self.colour.y, self.colour.z, 1} or WHITE
                    ChatHistory:OnChatterMessage(inst, name_colour, str, colour, self.chaticon, self.chaticonbg, echotochatpriority)
                end
            end
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
            strid = net_smallbyte(self.inst.GUID, "talker.chatter.strid", "chatterdirty"),
            strtime = net_tinybyte(self.inst.GUID, "talker.chatter.strtime"),
            forcetext = net_bool(self.inst.GUID, "talker.chatter.forcetext"),
            echotochatpriority = net_tinybyte(self.inst.GUID, "talker.chatter.echotochatpriority"),
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
-- NOTES(JBK): "echotochatpriority" will replicate the text into the player's chatbox if they are nearby to see it.
function Talker:Chatter(strtbl, strid, time, forcetext, echotochatpriority)
    if self.chatter ~= nil and TheWorld.ismastersim then
        self.chatter.strtbl:set(strtbl)
        --force at least the id dirty, so that it's possible to repeat strings
        strid = strid or 0
        self.chatter.strid:set_local(strid)
        self.chatter.strid:set(strid)
        self.chatter.strtime:set(time or 0)
        self.chatter.forcetext:set(forcetext == true)
        echotochatpriority = (echotochatpriority == true and CHATPRIORITIES.LOW)
            or ((echotochatpriority == false or echotochatpriority == nil) and CHATPRIORITIES.NOCHAT)
            or echotochatpriority
        self.chatter.echotochatpriority:set(echotochatpriority)
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

local function sayfn(self, script, nobroadcast, colour, text_filter_context, original_author_netid, onfinishedlinesfn, sgparam)

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
            if ThePlayer and not self.inst:HasTag("monkey") and ThePlayer:HasTag("wonkey") then
                display_message = CraftGiberish()
            end

            if self.inst.speech_override_fn then
                display_message = self.inst.speech_override_fn(self.inst,display_message)
            end

            if not nobroadcast then
                TheNet:Talker(
                    line.message,
                    self.inst.entity,
                    (duration ~= TUNING.DEFAULT_TALKER_DURATION and duration) or nil,
                    text_filter_context,
                    original_author_netid)
            end

            if self.widget ~= nil then
				--print("talker sayfn:", original_author, text_filter_context, display_message)
                if text_filter_context == nil or text_filter_context == TEXT_FILTER_CTX_UNKNOWN then
                    -- NOTES(JBK): Assume the text comes from the game if not specified.
                    text_filter_context = TEXT_FILTER_CTX_GAME
                end
		        local filtered_message = (display_message ~= nil
                        and ApplyLocalWordFilter(display_message, text_filter_context, original_author_netid))
                    or display_message
                self.widget.text:SetString(filtered_message)
            end

            if self.ontalkfn ~= nil then
                self.ontalkfn(self.inst, { noanim = line.noanim, message=display_message })
            end

            self.inst:PushEvent("ontalk", { noanim = line.noanim, duration = duration, sgparam=sgparam })
        elseif self.widget ~= nil then
            self.widget:Hide()
        end

        Sleep(duration)

        if onfinishedlinesfn then
            if i >= #script then
                onfinishedlinesfn(self.inst)
            end
        end

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

function Talker:Say(script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid, onfinishedlinesfn, sgparam)

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
        self.task = self.inst:StartThread(function() sayfn(self, lines, nobroadcast, colour, text_filter_context, original_author_netid, onfinishedlinesfn, sgparam) end)
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
