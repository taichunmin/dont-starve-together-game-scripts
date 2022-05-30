local Strongman = Class(function(self, inst)
    self.inst = inst
end)


function Strongman:DoWorkout(gym)
    self.gym = gym
    self.inst.components.mightiness:Pause()
    self.inst:AddTag("ingym")
end

function Strongman:StopWorkout()
    self.inst:RemoveTag("ingym")
    self.inst.components.mightiness:Resume()
    self.gym = nil
end

return Strongman