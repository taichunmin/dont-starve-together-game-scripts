
local Npc_talker = Class(function(self, inst)
    self.inst = inst
    self.queue = {}
    self.soundqueue = {}
    --self.inst:ListenForEvent("done_npc_talk", function(inst) self:checknextline() end)
end)

function Npc_talker:Say(lines, override, stompable, sound)
    -- override means it wipes out the old queue
    -- stompable means anything else will remove it. And if there's anything queued already it will be ignored


    if override or self.stompable then
       self.queue = {}
       self.soundqueue = {}
       self.stompable = false
    end

    if stompable and #self.queue > 0 then
        return
    end

    if lines then

        table.insert(self.soundqueue,sound or false)

        if type(lines) ~= "table" then
            table.insert(self.queue,lines)
        else
            for i,line in ipairs(lines) do
                if i > 1 then
                    table.insert(self.soundqueue, false)
                end
                table.insert(self.queue, line)
            end
        end
    end

    if stompable then
        self.stompable = true
    end

end

function Npc_talker:haslines()
    if #self.queue > 0 then
        return true
    end
end

function Npc_talker:resetqueue()
    self.queue = {}
    self.soundqueue = {}
end

function Npc_talker:donextline()

    if #self.queue > 0 then
        self.inst.components.talker:Say(self.queue[1])
        if self.soundqueue[1] and type(self.soundqueue[1]) == "string" then
            self.inst.SoundEmitter:PlaySound(self.soundqueue[1])
        end
        table.remove(self.soundqueue,1)
        table.remove(self.queue,1)
    end
end

return Npc_talker
