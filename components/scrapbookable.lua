local Scrapbookable = Class(function(self, inst)
    self.inst = inst
end)

function Scrapbookable:SetOnTeachFn(fn)
    self.onteach = fn
end

function Scrapbookable:Teach(doer)
    if self.onteach ~= nil then
        self.onteach(self.inst, doer)
    end

    return true
end

return Scrapbookable