local EquipSlot = require("equipslotutil")

local PlayerAvatarData = Class(function(self, inst)
    self.inst = inst

    --self.hasdata = nil
    --self.allowemptyname = nil
    --self.allowburnt = nil

    --self.strings = nil
    --self.skins = nil
    --self.numbers = nil
    --self.equip = nil
    --self.unsupported_equips = nil

    --self.savestrings = nil
    --self.saveskins = nil
    --self.savenumbers = nil
    --self.saveequip = nil
end)

function PlayerAvatarData:SetAllowEmptyName(allow)
    self.allowemptyname = allow ~= false
end

function PlayerAvatarData:SetAllowBurnt(allow)
    self.allowburnt = allow ~= false
end

function PlayerAvatarData:AddNameData(save)
    if self.strings == nil then
        self.hasdata = true
        self.savestrings = save
        self.strings =
        {
            name = net_string(self.inst.GUID, "playeravatardata.name"),
            prefab = net_string(self.inst.GUID, "playeravatardata.prefab"),
        }
    end
end

function PlayerAvatarData:AddBaseSkinData(save)
    if self.skins == nil then
        self.hasdata = true
        self.saveskins = save
        self.skins = {}
    end
    if self.skins.base_skin == nil then
        --Skin strings are translated to nil when empty
        self.skins.base_skin = net_string(self.inst.GUID, "playeravatardata.base_skin")
    end
end

function PlayerAvatarData:AddClothingData(save)
    if self.skins == nil then
        self.hasdata = true
        self.saveskins = save
        self.skins = {}
    end
    if self.skins.body_skin == nil then
        --Skin strings are translated to nil when empty
        self.skins.body_skin = net_string(self.inst.GUID, "playeravatardata.body_skin")
        self.skins.hand_skin = net_string(self.inst.GUID, "playeravatardata.hand_skin")
        self.skins.legs_skin = net_string(self.inst.GUID, "playeravatardata.legs_skin")
        self.skins.feet_skin = net_string(self.inst.GUID, "playeravatardata.feet_skin")
    end
end

function PlayerAvatarData:AddAgeData(save)
    if self.numbers == nil then
        self.hasdata = true
        self.savenumbers = save
        self.numbers =
        {
            playerage = net_ushortint(self.inst.GUID, "playeravatardata.playerage"),
        }
    end
end

function PlayerAvatarData:AddEquipData(save)
    if self.equip == nil then
        self.hasdata = true
        self.saveequip = save
        self.equip = {}
        for i = 1, EquipSlot.Count() do
            table.insert(self.equip, net_string(self.inst.GUID, "playeravatardata.equip["..tostring(i).."]"))
        end
        --self.unsupported_equips = nil
    end
end

function PlayerAvatarData:AddPlayerData(save)
    self:AddNameData(save)
    self:AddBaseSkinData(save)
    self:AddClothingData(save)
    self:AddAgeData(save)
    self:AddEquipData(save)
end

--Always return a new table because this data is used in place
--of TheNet:GetClientTable, where the return value is modified
--most of the time by the screens using it.
function PlayerAvatarData:GetData()
    if not self.hasdata then
        return TheNet:GetClientTableForUser(self.inst.userid)
    elseif (not self.allowemptyname and self.strings ~= nil and self.strings.name:value() == "")
        or (not self.allowburnt and self.inst:HasTag("burnt")) then
        return
    end

    local data = {}

    if self.strings ~= nil then
        for k, v in pairs(self.strings) do
            data[k] = v:value()
        end
    end

    if self.skins ~= nil then
        for k, v in pairs(self.skins) do
            --Skin strings are translated to nil when empty
            data[k] = v:value() ~= "" and v:value() or nil
        end
    end

    if self.numbers ~= nil then
        for k, v in pairs(self.numbers) do
            data[k] = v:value()
        end
    end

    if self.equip ~= nil then
        data.equip = {}

        for i, v in ipairs(self.equip) do
            table.insert(data.equip, v:value())
        end
    end

    return data
end

function PlayerAvatarData:SetData(client_obj)
    if not self.hasdata then
        return
    elseif self.strings ~= nil then
        for k, v in pairs(self.strings) do
            v:set(client_obj ~= nil and client_obj[k] or "")
        end
    end

    if self.skins ~= nil then
        for k, v in pairs(self.skins) do
            v:set(client_obj ~= nil and client_obj[k] or "")
        end
    end

    if self.numbers ~= nil then
        for k, v in pairs(self.numbers) do
            v:set(client_obj ~= nil and client_obj[k] or 0)
        end
    end

    if self.equip ~= nil then
        for i, v in ipairs(self.equip) do
            v:set(client_obj ~= nil and client_obj.equip ~= nil and client_obj.equip[i] or "")
        end
    end
end

function PlayerAvatarData:OnSave()
    if not self.hasdata then
        return
    end

    local data = {}

    if self.savestrings then
        for k, v in pairs(self.strings) do
            data[k] = v:value()
        end
    end

    if self.saveskins then
        for k, v in pairs(self.skins) do
            --Skin strings are translated to nil when empty
            data[k] = v:value() ~= "" and v:value() or nil
        end
    end

    if self.savenumbers then
        for k, v in pairs(self.numbers) do
            data[k] = v:value()
        end
    end

    if self.saveequip then
        data.equip = {}

        --translate equipslot id to name
        --names never change, but ids change if slots are added/removed
        if self.unsupported_equips ~= nil then
            for k, v in pairs(self.unsupported_equips) do
                data.equip[k] = v
            end
        end
        for i, v in ipairs(self.equip) do
            data.equip[EquipSlot.FromID(i)] = v:value()
        end
    end

    return next(data) ~= nil and data or nil
end

function PlayerAvatarData:OnLoad(data)
    if not self.hasdata then
        return
    elseif data.equip ~= nil then
        --translate equipslot name back to id
        local temp = {}
        for k, v in pairs(data.equip) do
            local eslotid = EquipSlot.ToID(k)
            if eslotid ~= nil then
                temp[eslotid] = v
            elseif self.unsupported_equips == nil then
                self.unsupported_equips = { [k] = v }
            else
                self.unsupported_equips[k] = v
            end
        end
        data.equip = temp
    end
    self:SetData(data)
end

return PlayerAvatarData
