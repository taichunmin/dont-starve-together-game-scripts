local Winter_TreeSeed = Class(function(self, inst)
    self.inst = inst
    self.winter_tree = "winter_tree"
end)

function Winter_TreeSeed:SetTree(tree)
    self.winter_tree = tree
end

return Winter_TreeSeed
