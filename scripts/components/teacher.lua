local Teacher = Class(function(self, inst)
    self.inst = inst
    self.recipe = nil
end)

function Teacher:SetRecipe(recipe)
    self.recipe = recipe
end

function Teacher:Teach(target)
    if self.recipe == nil then
        self.inst:Remove()
        return false
    elseif target.components.builder == nil then
        return false
	elseif target.components.builder:KnowsRecipe(self.recipe, true) then
        return false, "KNOWN"
    elseif not target.components.builder:CanLearn(self.recipe) then
        return false, "CANTLEARN"
    else
        target.components.builder:UnlockRecipe(self.recipe)
        if self.onteach then
            self.onteach(self.inst, target)
        end
        self.inst:Remove()
        return true
	end
end

return Teacher