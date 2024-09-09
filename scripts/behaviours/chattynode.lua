ChattyNode = Class(BehaviourNode, function(self, inst, chatlines, child, delay, rand_delay, enter_delay, enter_delay_rand)
    BehaviourNode._ctor(self, "ChattyNode", {child})

    self.inst = inst
    if type(chatlines) == "table" and chatlines.chatterparams then
        -- NOTES(JBK): Having chatterparams allows for meta information about how to present the text using chatter.
        -- { name = "STRINGTABLENAME", chatterparams = { ... }, }
        self.chatlines = chatlines.name
        self.chatter_time = chatlines.chatterparams.time
        self.chatter_forcetext = chatlines.chatterparams.forcetext
        self.chatter_echotochatpriority = chatlines.chatterparams.echotochatpriority
    else
        self.chatlines = chatlines
    end
    self.nextchattime = 0
	self.delay = delay
	self.rand_delay = rand_delay

	self.enter_delay = enter_delay
	self.enter_delay_rand = enter_delay_rand
end)

function ChattyNode:Visit()
    local child = self.children[1]
    child:Visit()
	local prev_status = self.status
    self.status = child.status

    if self.status == RUNNING then
        local t = GetTime()

		if prev_status ~= RUNNING then
			-- Allow for an initial delay when entering the node.
            -- Use this for things like Wander, where you stay in the state
            -- for a long time, and frequently enter it.
            local enter_delay_rand = (self.enter_delay_rand ~= nil and math.random() * self.enter_delay_rand) or 0
			self.nextchattime = t + (self.enter_delay or 0) + enter_delay_rand - FRAMES
		end

        if self.nextchattime == nil or t > self.nextchattime then
            if type(self.chatlines) == "function" then
                local str = self.chatlines(self.inst)
				if str ~= nil then
					if self.inst.components.npc_talker then
                        local splits = str:split(".")
                        if STRINGS[splits[1]] ~= nil then
                            local echotochatpriority = (self.chatter_echotochatpriority == true and 1)
                                or (self.chatter_echotochatpriority == false and 0)
                                or self.chatter_echotochatpriority
                            self.inst.components.npc_talker:Chatter(str, nil, echotochatpriority, nil, true)
                        else
						    self.inst.components.npc_talker:Say(str,nil,true)
                        end
					else
						self.inst.components.talker:Say(str)
					end
				end
            elseif type(self.chatlines) == "table" then
                --legacy, will only show on host
                local r = #self.chatlines
                if r == 0 then
                    -- NOTES(JBK): This will crash let us print more information before it does.
                    dumptable(self.chatlines)
                end
                local str = self.chatlines[math.random(r)]
                self.inst.components.talker:Say(str)
            else
                --Will be networked if talker:MakeChatter() was initialized
                local strtbl = STRINGS[self.chatlines]
                if strtbl ~= nil then
                    local strid = (type(strtbl) == "table" and math.random(#strtbl)) or 0
                    local echotochatpriority = (self.chatter_echotochatpriority == true and 1)
                        or (self.chatter_echotochatpriority == false and 0)
                        or self.chatter_echotochatpriority
                    self.inst.components.talker:Chatter(
                        self.chatlines,
                        strid,
                        self.chatter_time,
                        self.chatter_forcetext,
                        echotochatpriority
                    )
                end
            end
            self.nextchattime = t + (self.delay or 10) + math.random() * (self.rand_delay or 10)
        end
        if self.nextchattime ~= nil then
            self:Sleep(self.nextchattime - t)
        end
    end
end

