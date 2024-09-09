local Widget           = require "widgets/widget"
local UIAnim           = require "widgets/uianim"
local UpgradeModulesDisplay   = require "widgets/upgrademodulesdisplay"

local function OnSetPlayerMode(inst, self)
    self.modetask = nil

    if self.upgrademodulesdisplay ~= nil then
        if self.onmodulesdirty == nil then
            self.onmodulesdirty = function(owner, data) self:ModulesDirty(data) end
            self.inst:ListenForEvent("upgrademodulesdirty", self.onmodulesdirty, self.owner)
        end
    
        if self.onpopallmodulesevent == nil then
            self.onpopallmodulesevent = function(owner) self:PopAllUpgradeModules() end
            self.inst:ListenForEvent("upgrademoduleowner_popallmodules", self.onpopallmodulesevent, self.owner)
        end
    
        if self.onupgrademodulesenergylevelupdated == nil then
            self.onupgrademodulesenergylevelupdated = function(owner, data) self:UpgradeModulesEnergyLevelDelta(data) end
            self.inst:ListenForEvent("energylevelupdate", self.onupgrademodulesenergylevelupdated, self.owner)
        end
    
        -- statusdisplays hasn't hooked up its listener events when we load prefabs and components,
        -- so we need to actively seek out our initial state here.
        self:SetUpgradeModuleEnergyLevel(self.owner:GetEnergyLevel(), 0)
        self:ModulesDirty(self.owner:GetModulesData())
    end
end

local function OnSetGhostMode(inst, self)
    self.modetask = nil

    if self.onupgrademodulesenergylevelupdated ~= nil then
        self.inst:RemoveEventCallback("energylevelupdate", self.onupgrademodulesenergylevelupdated, self.owner)
        self.onupgrademodulesenergylevelupdated = nil
    end
end

-- Like StatusDisplays, but aligned on the opposite side for splitscreen
local SecondaryStatusDisplays = Class(Widget, function(self, owner)
    Widget._ctor(self, "Status")
    self:UpdateWhilePaused(false)
    self.owner = owner

    if IsGameInstance(Instances.Player1) then
        self.column1 = 50
    else
        self.column1 = -50
    end

    self.modetask = nil
    self.isghostmode = true --force the initial SetGhostMode call to be dirty
    self:SetGhostMode(false)

    self.side_inv = self:AddChild(Widget("side_inv"))
    self.side_inv:SetPosition(self.column1, 0, 0) -- -120

    if owner:HasTag("upgrademoduleowner") then
        self:AddModuleOwnerDisplay()
    end
end)

function SecondaryStatusDisplays:ShowStatusNumbers()
end

function SecondaryStatusDisplays:HideStatusNumbers()
end

function SecondaryStatusDisplays:Layout()
end

---------------------------------------------------------------------------------------------

function SecondaryStatusDisplays:AddModuleOwnerDisplay()
    if self.upgrademodulesdisplay == nil then
        self.upgrademodulesdisplay = self:AddChild(UpgradeModulesDisplay(self.owner))
        self:SetUpgradeModuleEnergyLevel(self.owner:GetEnergyLevel(), 0)
        self:ModulesDirty(self.owner:GetModulesData())

        self.upgrademodulesdisplay:SetPosition(self.column1, -120, 0)
    end
end

---------------------------------------------------------------------------------------------

function SecondaryStatusDisplays:SetGhostMode(ghostmode)
    if not self.isghostmode == not ghostmode then --force boolean
        return
    elseif ghostmode then
        self.isghostmode = true

        if self.side_inv ~= nil then
            self.side_inv:Hide()
        end

        if self.upgrademodulesdisplay ~= nil then
            self.upgrademodulesdisplay:Hide()
        end
    else
        self.isghostmode = nil

        if self.side_inv ~= nil then
            self.side_inv:Show()
        end

        if self.upgrademodulesdisplay ~= nil then
            self.upgrademodulesdisplay:Show()
        end
    end

    if self.modetask ~= nil then
        self.modetask:Cancel()
    end
    self.modetask = self.inst:DoStaticTaskInTime(0, ghostmode and OnSetGhostMode or OnSetPlayerMode, self)
end

----------------------------------------------------------------------------------------------------------
-- WX modules UI

function SecondaryStatusDisplays:ModulesDirty(data)
    self.upgrademodulesdisplay:OnModulesDirty(data)
end

function SecondaryStatusDisplays:PopAllUpgradeModules()
    self.upgrademodulesdisplay:PopAllModules()
end

function SecondaryStatusDisplays:SetUpgradeModuleEnergyLevel(new_level, old_level)
    self.upgrademodulesdisplay:UpdateEnergyLevel(new_level, old_level)
end

function SecondaryStatusDisplays:UpgradeModulesEnergyLevelDelta(data)
    local new_level = (data == nil and 0) or data.new_level
    local old_level = (data == nil and 0) or data.old_level

    self:SetUpgradeModuleEnergyLevel(new_level, old_level)
end

----------------------------------------------------------------------------------------------------------

return SecondaryStatusDisplays
