local skilltreedefs = require "prefabs/skilltree_defs"

local ExperienceCollector = Class(function(self, inst)
    self.inst = inst
    self.xp_period = TUNING.TOTAL_DAY_TIME
    self:SetTask()
end)

function ExperienceCollector:SetTask(time)
    if self.inst.xpgeneration_task then
        self.inst.xpgeneration_task:Cancel()
        self.inst.xpgeneration_task = nil
    end  
    self.inst.xpgeneration_task = self.inst:DoPeriodicTask(self.xp_period,  function() self:UpdateXp() end, time)
end

function ExperienceCollector:UpdateXp()

    if not skilltreedefs.SKILLTREE_DEFS[self.inst.prefab] then
        return nil
    end 
    self.inst.components.skilltreeupdater:AddSkillXP(1)
end

function ExperienceCollector:LongUpdate(dt)
    local timeremaining = 0

    if self.inst.xpgeneration_task then
        timeremaining = GetTaskRemaining(self.inst.xpgeneration_task)
    end

    if dt < timeremaining then
        timeremaining = timeremaining - dt

    else
        dt = dt + (self.xp_period - timeremaining)

        local cycles, remaining = math.modf(dt/self.xp_period)
        
        if cycles > 0 then
            for i=1, cycles do
                self:UpdateXp()
            end
        end

        timeremaining = self.xp_period - (remaining * self.xp_period)
    end

    self:SetTask(timeremaining)
end

function ExperienceCollector:OnSave()
   return
   {
        time = GetTaskRemaining(self.inst.xpgeneration_task)
   }
end

function ExperienceCollector:OnLoad(data)
   if data.time then
        self:SetTask(data.time)
   end
end

return ExperienceCollector