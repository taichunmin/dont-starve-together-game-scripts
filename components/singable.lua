local Singable = Class(function(self, inst)
    self.inst = inst
    self.onsingfn = nil
end)

function Singable:SetOnSing(onsingfn)
    self.onsingfn = onsingfn
end

function Singable:Sing(singer)
    if singer.components.singinginspiration == nil then
        print ("ATTEMPTING TO SING WITH NO INSPIRATION")
        return
    end

    -- if self.inst.components.finiteuses ~= nil then
    --     self.inst.components.finiteuses:Use()
    -- end

    if self.onsingfn then
        self.onsingfn(self.inst, singer)
    end

    singer.components.singinginspiration:AddSong(self.inst.songdata)
end

return Singable