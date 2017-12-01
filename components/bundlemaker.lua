local BundleMaker = Class(function(self, inst)
    self.inst = inst
    self.bundlingprefab = nil
    self.bundledprefab = nil
    self.onstartbundlingfn = nil
end)

function BundleMaker:SetBundlingPrefabs(bundling, bundled)
    self.bundlingprefab = bundling
    self.bundledprefab = bundled
end

function BundleMaker:SetOnStartBundlingFn(fn)
    self.onstartbundlingfn = fn
end

function BundleMaker:OnStartBundling(doer)
    if self.onstartbundlingfn ~= nil then
        self.onstartbundlingfn(self.inst, doer)
    end
end

return BundleMaker
