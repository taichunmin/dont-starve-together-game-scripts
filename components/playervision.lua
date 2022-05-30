local GHOSTVISION_COLOURCUBES =
{
    day = "images/colour_cubes/ghost_cc.tex",
    dusk = "images/colour_cubes/ghost_cc.tex",
    night = "images/colour_cubes/ghost_cc.tex",
    full_moon = "images/colour_cubes/ghost_cc.tex",
}

local NIGHTVISION_COLOURCUBES =
{
    day = "images/colour_cubes/mole_vision_off_cc.tex",
    dusk = "images/colour_cubes/mole_vision_on_cc.tex",
    night = "images/colour_cubes/mole_vision_on_cc.tex",
    full_moon = "images/colour_cubes/mole_vision_off_cc.tex",
}

local NIGHTVISION_PHASEFN =
{
    blendtime = 0.25,
    events = {},
    fn = nil,
}

local NIGHTMARE_COLORCUBES =
{
    calm = "images/colour_cubes/ruins_dark_cc.tex",
    warn = "images/colour_cubes/ruins_dim_cc.tex",
    wild = "images/colour_cubes/ruins_light_cc.tex",
    dawn = "images/colour_cubes/ruins_dim_cc.tex",
}

local NIGHTMARE_PHASEFN =
{
    blendtime = 8,
    events = { "nightmarephasechanged" }, -- note: actual (client-side) world component event, not worldstate
    fn = function()
        return TheWorld.state.nightmarephase
    end,
}

local function OnEquipChanged(inst)
    local self = inst.components.playervision
    if self.nightvision == not inst.replica.inventory:EquipHasTag("nightvision") then
        self.nightvision = not self.nightvision
        if not self.forcenightvision then
            self:UpdateCCTable()
            inst:PushEvent("nightvision", self.nightvision)
        end
    end
    if self.gogglevision == not inst.replica.inventory:EquipHasTag("goggles") then
        self.gogglevision = not self.gogglevision
        if not self.forcegogglevision then
            inst:PushEvent("gogglevision", { enabled = self.gogglevision })
        end
    end
    if self.nutrientsvision == not inst.replica.inventory:EquipHasTag("nutrientsvision") then
        self.nutrientsvision = not self.nutrientsvision
        if not self.forcenutrientsvision and self.inst == ThePlayer then
            TheWorld:PushEvent("nutrientsvision", { enabled = self.nutrientsvision })
        end
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
        if inst.replica.inventory == nil then
            --V2C: clients c_spawning characters ...grrrr
            return
        end
    end
    OnEquipChanged(inst)
end

local function OnAreaChanged(inst, data)
    inst.components.playervision:SetNightmareVision(data ~= nil and data.tags ~= nil and table.contains(data.tags, "Nightmare"))
end

local PlayerVision = Class(function(self, inst)
    self.inst = inst

    self.ghostvision = false
    self.nightmarevision = false
    self.nightvision = false
    self.forcenightvision = false
    self.gogglevision = false
    self.forcegogglevision = false
    self.nutrientsvision = false
    self.forcenutrientsvision = false
    self.overridecctable = nil
    self.currentcctable = nil
    self.currentccphasefn = nil

    inst:DoTaskInTime(0, OnInit, self)
    inst:ListenForEvent("changearea", OnAreaChanged)
end)

function PlayerVision:HasGhostVision()
    return self.ghostvision
end

function PlayerVision:HasNightmareVision()
    return self.nightmarevision
end

function PlayerVision:HasNightVision()
    return self.nightvision or self.forcenightvision
end

function PlayerVision:HasGoggleVision()
    return self.gogglevision or self.forcegogglevision
end

function PlayerVision:HasNutrientsVision()
    return self.nutrientsvision or self.forcenutrientsvision
end

function PlayerVision:GetCCPhaseFn()
    return self.currentccphasefn
end

function PlayerVision:GetCCTable()
    return self.currentcctable
end

function PlayerVision:UpdateCCTable()
    local cctable =
        (self.ghostvision and GHOSTVISION_COLOURCUBES)
        or self.overridecctable
        or ((self.nightvision or self.forcenightvision) and NIGHTVISION_COLOURCUBES)
        or (self.nightmarevision and NIGHTMARE_COLORCUBES)
        or nil

    local ccphasefn =
        (cctable == NIGHTVISION_COLOURCUBES and NIGHTVISION_PHASEFN)
        or (cctable == NIGHTMARE_COLORCUBES and NIGHTMARE_PHASEFN)
        or nil

    if cctable ~= self.currentcctable then
        self.currentcctable = cctable
        self.currentccphasefn = ccphasefn
        self.inst:PushEvent("ccoverrides", cctable)
        self.inst:PushEvent("ccphasefn", ccphasefn)
    end
end

function PlayerVision:SetGhostVision(enabled)
    if not self.ghostvision ~= not enabled then
        self.ghostvision = enabled == true
        self:UpdateCCTable()
        self.inst:PushEvent("ghostvision", self.ghostvision)
    end
end

function PlayerVision:SetNightmareVision(enabled)
    if not self.nightmarevision ~= not enabled then
        self.nightmarevision = enabled == true
        self:UpdateCCTable()
        self.inst:PushEvent("nightmarevision", self.nightmarevision)
    end
end

function PlayerVision:ForceNightVision(force)
    if not self.forcenightvision ~= not force then
        self.forcenightvision = force == true
        if not self.nightvision then
            self:UpdateCCTable()
            self.inst:PushEvent("nightvision", self.forcenightvision)
        end
    end
end

function PlayerVision:ForceGoggleVision(force)
    if not self.forcegogglevision ~= not force then
        self.forcegogglevision = force == true
        if not self.gogglevision then
            self.inst:PushEvent("gogglevision", { enabled = self.forcegogglevision })
        end
    end
end

function PlayerVision:ForceNutrientVision(force)
    if not self.forcenutrientsvision ~= not force then
        self.forcenutrientsvision = force == true
        if not self.nutrientsvision and self.inst == ThePlayer then
            TheWorld:PushEvent("nutrientsvision", { enabled = self.forcenutrientsvision })
        end
    end
end

function PlayerVision:SetCustomCCTable(cctable)
    if self.overridecctable ~= cctable then
        self.overridecctable = cctable
        self:UpdateCCTable()
    end
end

return PlayerVision
