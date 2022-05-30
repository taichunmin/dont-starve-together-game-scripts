local BEEFALO_COSTUMES = require("yotb_costumes")

local function oncanuseaction(self, canuseaction)
    if canuseaction then
        --V2C: Recommended to explicitly add tag to prefab pristine state
        self.inst:AddTag("groomer")
    else
        self.inst:RemoveTag("groomer")
    end
end

local function oncanbedressed(self, canbedressed)
    if canbedressed then
        self.inst:AddTag("dressable")
    else
        self.inst:RemoveTag("dressable")
    end
end

local Groomer = Class(function(self, inst)
    self.inst = inst

    self.changers = {}
    self.enabled = true
    self.canuseaction = true
    self.canbeshared = nil
    self.canbedressed = nil
    self.range = 3
    self.changeindelay = 0
    self.onchangeinfn = nil
    self.ondressupfn = nil
    self.onopenfn = nil
    self.onclosefn = nil

    self:SetCanBeShared(false)

    self.onclosepopup = function(doer, data)
        if data.popup == POPUPS.GROOMER then
            local skins = {
                beef_body = data.args[1],
                beef_horn = data.args[2],
                beef_head = data.args[3],
                beef_feet = data.args[4],
                beef_tail = data.args[5],
                cancel = data.args[6],
            }
            self.onclosegroomer(doer, skins)
        end
    end
    self.onclosegroomer = function(doer, data)
        if data and not data.cancel then
            self:ActivateChanging(doer, data)
        end
        self:EndChanging(doer)
    end

    self.oncloseallgroomer = function(inst, data)
        for i, v in pairs(self.changers) do
            self:EndChanging(i)
        end
    end

end,
nil,
{
    canuseaction = oncanuseaction,
    canbedressed = oncanbedressed,
})


function Groomer:SetOccupant(occupant)
    self.occupant = occupant
end

--Whether this is included in player action collection or not
function Groomer:SetCanUseAction(canuseaction)
    self.canuseaction = canuseaction
end

function Groomer:SetCanBeDressed(canbedressed)
    self.canbedressed = canbedressed
end

function Groomer:Enable(enable)
    self.enabled = enable ~= false
end

local function OnIgnite(inst)
    local towarn = {}
    for k, v in pairs(inst.components.groomer.changers) do
        if k.sg ~= nil and k.sg.currentstate.name == "openwardrobe" then
            table.insert(towarn, k)
        end
    end

    inst.components.groomer:EndAllChanging()

    for i, v in ipairs(towarn) do
        if v.components.talker ~= nil then
            v.components.talker:Say(GetString(inst, "ANNOUNCE_NOWARDROBEONFIRE"))
        end
    end
end

--Whether multiple people can use the wardrobe at once or not
function Groomer:SetCanBeShared(canbeshared)
    if self.canbeshared ~= (canbeshared == true) then
        self.canbeshared = (canbeshared == true)
        if self.canbeshared then
            self.inst:RemoveEventCallback("onignite", OnIgnite)
        else
            self.inst:ListenForEvent("onignite", OnIgnite)
        end
    end
end

function Groomer:SetRange(range)
    self.range = range
end

function Groomer:SetChangeInDelay(delay)
    self.changeindelay = delay
end

function Groomer:CanBeginChanging(doer)
    if not self.enabled then
        return false, "INUSE"
    elseif doer.sg == nil or
        (doer.sg:HasStateTag("busy") and doer.sg.currentstate.name ~= "opengift") then
        return false
    elseif self.shareable then
        return true
    elseif self.inst.burnable ~= nil and self.inst.burnable:IsBurning() then
        return false, "BURNING"
    elseif not self.occupant then
        return false, "NOOCCUPANT"
    elseif self.occupant and self.occupant.components.beard and self.occupant.components.beard.bits < TUNING.BEEFALO_BEARD_BITS then
        return false, "NOTENOUGHHAIR"
    end
    return true
end

function Groomer:BeginChanging(doer)

    if doer and doer.player_classified ~= nil then
        doer.player_classified.hasyotbskin:set(false)
    end

    if not self.changers[doer] then
        local wasclosed = next(self.changers) == nil

        self.changers[doer] = true

        self.inst:ListenForEvent("onremove", self.onclosegroomer, doer)
        self.inst:ListenForEvent("ms_closepopup", self.onclosepopup, doer)
        self.inst:ListenForEvent("unhitched", self.oncloseallgroomer, self.inst)

        if doer.sg.currentstate.name == "opengift" then
            doer.sg.statemem.isopeningwardrobe = true
            doer.sg:GoToState("openwardrobe", { openinggift = true, target = self.canbedressed and self.inst or nil })
        else
            doer.sg:GoToState("openwardrobe", { openinggift = false, target = self.canbedressed and self.inst or nil })
        end

        if wasclosed then
            self.inst:StartUpdatingComponent(self)

            if self.onopenfn ~= nil then
                self.onopenfn(self.inst)
            end
        end
        return true
    end
    return false
end

function Groomer:EndChanging(doer)

    if self.changers[doer] then
        self.changers[doer] = nil
    end

    self.inst:RemoveEventCallback("onremove", self.onclosegroomer, doer)
    self.inst:RemoveEventCallback("ms_closepopup", self.onclosepopup, doer)
    self.inst:RemoveEventCallback("unhitched", self.oncloseallgroomer, self.inst)

    if doer.sg:HasStateTag("inwardrobe") and not doer.sg.statemem.isclosingwardrobe then
        doer.sg.statemem.isclosingwardrobe = true
        doer.AnimState:PlayAnimation("idle_wardrobe1_pst")
        doer.sg:GoToState("idle", true)
    end

    if next(self.changers) == nil then
        self.inst:StopUpdatingComponent(self)
        if self.onclosefn ~= nil then
            self.onclosefn(self.inst)
        end
    end
end

function Groomer:EndAllChanging()
    local toend = {}
    for k, v in pairs(self.changers) do
        table.insert(toend, k)
    end
    for i, v in ipairs(toend) do
        self:EndChanging(v)
    end
end

local function DoChange(self, doer, skins)
    doer.sg.statemem.ischanging = true
    doer.sg:GoToState("dressupwardrobe", function()
        if self.occupant then
            self.occupant.sg:GoToState("skin_change", function()
                self:ApplyTargetSkins(self.occupant, doer, skins)
            end)
        end
    end)
    if self.changefn then
        self.changefn(self.inst)
    end
    return true
end

function Groomer:ActivateChanging(doer, skins)
    if skins == nil or
        next(skins) == nil or
        doer.sg.currentstate.name ~= "openwardrobe" or
        (self.occupant and self.occupant.components.skinner_beefalo == nil) then
            print(self.occupant,doer.sg.currentstate.name)
        return false
    elseif self.occupant then
        return DoChange(self, doer, skins)
    end
end

function Groomer:ApplyTargetSkins(target, doer, skins)

    if target and target.components.skinner_beefalo ~= nil then
        target.AnimState:AssignItemSkins(doer.userid, skins.beef_body or "", skins.beef_horn or "", skins.beef_head or "", skins.beef_feet or "", skins.beef_tail or "")
        target.components.skinner_beefalo:ClearAllClothing()
        target.components.skinner_beefalo:SetClothing(skins.beef_body)
        target.components.skinner_beefalo:SetClothing(skins.beef_horn)
        target.components.skinner_beefalo:SetClothing(skins.beef_head)
        target.components.skinner_beefalo:SetClothing(skins.beef_feet)
        target.components.skinner_beefalo:SetClothing(skins.beef_tail)
        target:PushEvent("dressedup", { wardrobe = self.inst, doer = doer, skins = skins })
    end
end

function Groomer:ApplySkins(doer, diff)
    if doer.components.skinner ~= nil then
        if diff.base ~= nil then
            if Prefabs[diff.base] ~= nil then
                doer.components.skinner:SetSkinName(diff.base)
            end
        end

        if diff.beef_body ~= nil then
            doer.components.skinner:ClearClothing("beef_body")
            if CLOTHING[diff.beef_body] ~= nil then
                doer.components.skinner:SetClothing(diff.beef_body)
            end
        end

        if diff.beef_horn ~= nil then
            doer.components.skinner:ClearClothing("beef_horn")
            if CLOTHING[diff.beef_horn] ~= nil then
                doer.components.skinner:SetClothing(diff.beef_horn)
            end
        end

        if diff.beef_head ~= nil then
            doer.components.skinner:ClearClothing("beef_head")
            if CLOTHING[diff.beef_head] ~= nil then
                doer.components.skinner:SetClothing(diff.beef_head)
            end
        end

        if diff.beef_feet ~= nil then
            doer.components.skinner:ClearClothing("beef_feet")
            if CLOTHING[diff.beef_feet] ~= nil then
                doer.components.skinner:SetClothing(diff.beef_feet)
            end
        end

        if diff.beef_tail ~= nil then
            doer.components.skinner:ClearClothing("beef_tail")
            if CLOTHING[diff.beef_tail] ~= nil then
                doer.components.skinner:SetClothing(diff.beef_tail)
            end
        end
    end
end

function Groomer:GetSkinCategory(skin)
    local category = nil
    for i,set in pairs(BEEFALO_COSTUMES.costumes)do
        for t,part in ipairs(set.skins)do
            if skin == part then
                category = i
            end
        end
    end

    return category
end

function Groomer:OnSave()

    local data = {}

    return data
end

function Groomer:OnLoad(data)

end

--------------------------------------------------------------------------
--Check for auto-closing conditions
--------------------------------------------------------------------------
function Groomer:OnUpdate(dt)
    if next(self.changers) == nil then
        self.inst:StopUpdatingComponent(self)
    else
        local toend = {}
        for k, v in pairs(self.changers) do
            if not (k:IsNear(self.inst, self.range) and
                    CanEntitySeeTarget(k, self.inst)) then
                table.insert(toend, k)
            end
        end
        for i, v in ipairs(toend) do
            self:EndChanging(v)
        end
    end
end

--------------------------------------------------------------------------

function Groomer:OnRemoveFromEntity()
    self:EndAllChanging()
    self.inst:RemoveEventCallback("onignite", OnIgnite)
    self.inst:RemoveTag("groomer")
    self.inst:RemoveTag("dressable")
end

Groomer.OnRemoveEntity = Groomer.EndAllChanging

return Groomer
