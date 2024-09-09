local DURATION = .5

local DSP =
{
    mufflehat =
    {
        lowdsp =
        {
            ["set_music"] = 750,
            ["set_ambience"] = 750,
            ["set_sfx/set_ambience"] = 750,
            ["set_sfx/movement"] = 750,
            ["set_sfx/creature"] = 750,
            ["set_sfx/player"] = 750,
            ["set_sfx/voice"] = 750,
            ["set_sfx/sfx"] = 750,
        },
        duration = DURATION,
    },
}

local function OnEquipChanged(inst)
    local self = inst.components.playerhearing
    local inventory = inst.replica.inventory
    local dirty = false
    for k, v in pairs(DSP) do
        if self[k] == not inventory:EquipHasTag(k) then
            self[k] = not self[k]
            dirty = true
        end
    end
    if dirty then
        self:UpdateDSPTables()
    end
end

local function OnInit(inst, self)
    inst:ListenForEvent("equip", OnEquipChanged)
    inst:ListenForEvent("unequip", OnEquipChanged)
    if not TheWorld.ismastersim then
        --Client only event, because when inventory is closed, we will stop
        --getting "equip" and "unequip" events, but we can also assume that
        --our inventory is emptied.
        inst:ListenForEvent("inventoryclosed", OnEquipChanged)
    end
    OnEquipChanged(inst)
end

local PlayerHearing = Class(function(self, inst)
    self.inst = inst

    for k, v in pairs(DSP) do
        self[k] = false
    end
    self.dsptables = {}

    inst:DoTaskInTime(0, OnInit, self)
end)

function PlayerHearing:GetDSPTables()
    return self.dsptables
end

function PlayerHearing:UpdateDSPTables()
    for k, v in pairs(DSP) do
        if self[k] then
            if self.dsptables[k] == nil then
                self.dsptables[k] = v
                self.inst:PushEvent("pushdsp", v)
            end
        elseif self.dsptables[k] ~= nil then
            self.dsptables[k] = nil
            self.inst:PushEvent("popdsp", v)
        end
    end
end

return PlayerHearing
