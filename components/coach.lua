local Coach = Class(function(self, inst)
    self.inst = inst   
    self.enabled = false
    self.randtime = 30
    self.settime = 10
end)

function Coach:Enable()
    self.enabled = true
    self.inst:AddTag("coaching")
    self:StartInspiring()    
end

function Coach:Disable()
    self.enabled = false
    self.inst:RemoveTag("coaching")
    self:StopInspiring()    
end

local INSPIRE_DIST = 25
local SANITY_BUFF = 5
local function inspire(inst)
     local coach = inst.components.coach

    if not coach.lastcoachtime or (GetTime() - coach.lastcoachtime  > coach.settime) then
        coach.lastcoachtime = GetTime()

        local didinspire = false

        local fightbuff = {}
        local sanitybuff= {}
        if inst.components.leader then
            for follower, i in pairs(inst.components.leader.followers)do
                if follower and follower:GetDistanceSqToInst(inst) < INSPIRE_DIST*INSPIRE_DIST then
                    table.insert(fightbuff,follower)
                end
            end
        end

        for k,v in pairs(AllPlayers) do
            if v:GetDistanceSqToInst(inst) < INSPIRE_DIST*INSPIRE_DIST  and v ~= inst then
                table.insert(sanitybuff,v)
                if v.components.leader then
                    for follower, i in pairs(v.components.leader.followers)do
                        if follower and follower:GetDistanceSqToInst(inst) < INSPIRE_DIST*INSPIRE_DIST then
                            table.insert(fightbuff,follower)
                        end
                    end
                end            
            end
        end

        for i,v in ipairs(sanitybuff) do
            if v.components.sanity and v.components.sanity:GetPercent() < 0.75 then
                v.components.sanity:DoDelta(SANITY_BUFF)
                didinspire = true
            end
        end

        for i,v in ipairs(fightbuff) do
            didinspire = true
            v:DoTaskInTime(0.2+(0.1*i),function()
                v:PushEvent("cheer")
                v:AddDebuff("wolfgang_coach_buff", "wolfgang_coach_buff")
            end)
        end

        if didinspire then
            inst:PushEvent("coach")
        else
            if not coach.noteamlasttime then
                coach.noteamlasttime = true
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_WOLFGANG_NOTEAM"))
            else
                coach.noteamlasttime = nil    
            end
        end
    end
   
    coach.inspiretask = coach.inst:DoTaskInTime((math.random()*coach.randtime) + coach.settime, inspire)
end

function Coach:StartInspiring()
    if not self.inspiretask then
        self.inspiretask = self.inst:DoTaskInTime(TUNING.COACH_TIME_TO_INSPIRE, inspire)
    end
end

function Coach:StopInspiring()
    if self.inspiretask then
        self.inspiretask:Cancel()
        self.inspiretask = nil
    end
end

return Coach