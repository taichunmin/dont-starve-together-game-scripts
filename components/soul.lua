--For generating component actions

local Soul = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("soul")
end)

return Soul
