ChattyNode = Class(BehaviourNode, function(self, inst, chatlines, child)
    BehaviourNode._ctor(self, "ChattyNode", {child})

    self.inst = inst
    self.chatlines = chatlines
    self.nextchattime = nil
end)

function ChattyNode:Visit()
    local child = self.children[1]

    child:Visit()
    self.status = child.status

    if self.status == RUNNING then
        local t = GetTime()
        if self.nextchattime == nil or t > self.nextchattime then
            if type(self.chatlines) == "table" then
                --legacy, will only show on host
                local str = self.chatlines[math.random(#self.chatlines)]
                self.inst.components.talker:Say(str)
            else
                --Will be networked if talker:MakeChatter() was initialized
                local strtbl = STRINGS[self.chatlines]
                if strtbl ~= nil then
                    local strid = math.random(#strtbl)
                    self.inst.components.talker:Chatter(self.chatlines, strid)
                end
            end
            self.nextchattime = t + 10 + math.random() * 10
        end
        if self.nextchattime ~= nil then
            self:Sleep(self.nextchattime - t)
        end
    end
end

