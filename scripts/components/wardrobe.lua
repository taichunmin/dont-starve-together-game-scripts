local function oncanuseaction(self, canuseaction)
    if canuseaction then
        --V2C: Recommended to explicitly add tag to prefab pristine state
        self.inst:AddTag("wardrobe")
    else
        self.inst:RemoveTag("wardrobe")
    end
end

local function oncanbedressed(self, canbedressed)
    if canbedressed then
        self.inst:AddTag("dressable")
    else
        self.inst:RemoveTag("dressable")
    end
end

local Wardrobe = Class(function(self, inst)
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
        if data.popup == POPUPS.WARDROBE then
            local skins = {
                base = data.args[1],
                body = data.args[2],
                hand = data.args[3],
                legs = data.args[4],
                feet = data.args[5],
            }
            self.onclosewardrobe(doer, skins)
        end
    end
    self.onclosewardrobe = function(doer, skins) -- yay closures ~gj -- yay ~v2c -- yay ~peter -- yay ~zach
        if self.changers[doer] and not self:ActivateChanging(doer, skins) then
            self:EndChanging(doer)
        end
    end
end,
nil,
{
    canuseaction = oncanuseaction,
    canbedressed = oncanbedressed,
})

--Whether this is included in player action collection or not
function Wardrobe:SetCanUseAction(canuseaction)
    self.canuseaction = canuseaction
end

function Wardrobe:SetCanBeDressed(canbedressed)
    self.canbedressed = canbedressed
end

function Wardrobe:Enable(enable)
    self.enabled = enable ~= false
end

local function OnIgnite(inst)
    local towarn = {}
    for k, v in pairs(inst.components.wardrobe.changers) do
        if k.sg ~= nil and k.sg.currentstate.name == "openwardrobe" then
            table.insert(towarn, k)
        end
    end

    inst.components.wardrobe:EndAllChanging()

    for i, v in ipairs(towarn) do
        if v.components.talker ~= nil then
            v.components.talker:Say(GetString(inst, "ANNOUNCE_NOWARDROBEONFIRE"))
        end
    end
end

--Whether multiple people can use the wardrobe at once or not
function Wardrobe:SetCanBeShared(canbeshared)
    if self.canbeshared ~= (canbeshared == true) then
        self.canbeshared = (canbeshared == true)
        if self.canbeshared then
            self.inst:RemoveEventCallback("onignite", OnIgnite)
        else
            self.inst:ListenForEvent("onignite", OnIgnite)
        end
    end
end

function Wardrobe:SetRange(range)
    self.range = range
end

function Wardrobe:SetChangeInDelay(delay)
    self.changeindelay = delay
end

function Wardrobe:CanBeginChanging(doer)
    if not self.enabled then
        return false, "INUSE"
    elseif self.changers[doer] or
        doer.sg == nil or
        (doer.sg:HasStateTag("busy") and doer.sg.currentstate.name ~= "opengift") then
        return false
    elseif self.shareable then
        return true
    elseif self.inst.burnable ~= nil and self.inst.burnable:IsBurning() then
        return false, "BURNING"
    elseif next(self.changers) ~= nil then
        return false, "INUSE"
    end
    return true
end

function Wardrobe:BeginChanging(doer)
    if not self.changers[doer] then
        local wasclosed = next(self.changers) == nil

        self.changers[doer] = true

        self.inst:ListenForEvent("onremove", self.onclosewardrobe, doer)
        self.inst:ListenForEvent("ms_closepopup", self.onclosepopup, doer)

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

function Wardrobe:EndChanging(doer)
    if self.changers[doer] then
        self.inst:RemoveEventCallback("onremove", self.onclosewardrobe, doer)
        self.inst:RemoveEventCallback("ms_closepopup", self.onclosepopup, doer)

        self.changers[doer] = nil
        doer:PushEvent("onskinschanged") -- NOTES(JBK): Yay.

        if doer.sg:HasStateTag("inwardrobe") and not doer.sg.statemem.isclosingwardrobe then
            doer.sg.statemem.isclosingwardrobe = true
            doer.AnimState:PlayAnimation(doer.sg.statemem.isopeninggift and "gift_open_pst" or "idle_wardrobe1_pst")
            doer.sg:GoToState("idle", true)
        end

        if next(self.changers) == nil then
            self.inst:StopUpdatingComponent(self)

            if self.onclosefn ~= nil then
                self.onclosefn(self.inst)
            end
        end
    end
end

function Wardrobe:EndAllChanging()
    local toend = {}
    for k, v in pairs(self.changers) do
        table.insert(toend, k)
    end
    for i, v in ipairs(toend) do
        self:EndChanging(v)
    end
end

local function DoTargetChanging(self, doer, skins)
    doer.sg.statemem.ischanging = true
    doer.sg:GoToState("dressupwardrobe", function()
        if self.ondressupfn ~= nil then
            self.ondressupfn(self.inst, function() self:ApplyTargetSkins(self.inst, doer, skins) end)
        else
            self:ApplyTargetSkins(self.inst, doer, skins)
        end
    end)
    return true
end

local function DoDoerChanging(self, doer, skins)
    local old = doer.components.skinner:GetClothing()

    local character_bases = GetCharacterSkinBases(doer.prefab)
    if skins.base ~= nil and character_bases[skins.base] == nil then
    	skins.base = doer.prefab.."_none"
	end

    local diff =
    {
        base = skins.base ~= nil and skins.base ~= old.base and skins.base or nil,
        body = skins.body ~= nil and skins.body ~= old.body and skins.body or nil,
        hand = skins.hand ~= nil and skins.hand ~= old.hand and skins.hand or nil,
        legs = skins.legs ~= nil and skins.legs ~= old.legs and skins.legs or nil,
        feet = skins.feet ~= nil and skins.feet ~= old.feet and skins.feet or nil,
    }

    if next(diff) == nil then
        return false
    end

    doer.sg.statemem.ischanging = true

    if self.canbeshared then
        doer.sg:GoToState("changeoutsidewardrobe", function() self:ApplySkins(doer, diff) end)
    else
        self:ApplySkins(doer, diff)

        doer.sg:GoToState("changeinwardrobe", self.changeindelay)

        if self.onchangeinfn ~= nil then
            self.onchangeinfn(self.inst)
        end
    end
    return true
end

function Wardrobe:ActivateChanging(doer, skins)
    if skins == nil or
        next(skins) == nil or
        doer.sg.currentstate.name ~= "openwardrobe" or
        doer.components.skinner == nil then
        return false
    elseif self.canbedressed then
        return DoTargetChanging(self, doer, skins)
    else
        return DoDoerChanging(self, doer, skins)
    end
end

function Wardrobe:ApplyTargetSkins(target, doer, skins)
    if target.components.skinner ~= nil then
        target.AnimState:AssignItemSkins(doer.userid, skins.body or "", skins.hand or "", skins.legs or "", skins.feet or "")
        target.components.skinner:ClearAllClothing()
        target.components.skinner:SetClothing(skins.body)
        target.components.skinner:SetClothing(skins.hand)
        target.components.skinner:SetClothing(skins.legs)
        target.components.skinner:SetClothing(skins.feet)
        target:PushEvent("dressedup", { wardrobe = self.inst, doer = doer, skins = skins })
    end
end

function Wardrobe:ApplySkins(doer, diff)
    if doer.components.skinner ~= nil then
        if diff.base ~= nil then
            if Prefabs[diff.base] ~= nil then
                doer.components.skinner:SetSkinName(diff.base)
            end
        end

        if diff.body ~= nil then
            doer.components.skinner:ClearClothing("body")
            if CLOTHING[diff.body] ~= nil then
                doer.components.skinner:SetClothing(diff.body)
            end
        end

        if diff.hand ~= nil then
            doer.components.skinner:ClearClothing("hand")
            if CLOTHING[diff.hand] ~= nil then
                doer.components.skinner:SetClothing(diff.hand)
            end
        end

        if diff.legs ~= nil then
            doer.components.skinner:ClearClothing("legs")
            if CLOTHING[diff.legs] ~= nil then
                doer.components.skinner:SetClothing(diff.legs)
            end
        end

        if diff.feet ~= nil then
            doer.components.skinner:ClearClothing("feet")
            if CLOTHING[diff.feet] ~= nil then
                doer.components.skinner:SetClothing(diff.feet)
            end
        end
    end
end

--------------------------------------------------------------------------
--Check for auto-closing conditions
--------------------------------------------------------------------------

function Wardrobe:OnUpdate(dt)
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

function Wardrobe:OnRemoveFromEntity()
    self:EndAllChanging()
    self.inst:RemoveEventCallback("onignite", OnIgnite)
    self.inst:RemoveTag("wardrobe")
    self.inst:RemoveTag("dressable")
end

Wardrobe.OnRemoveEntity = Wardrobe.EndAllChanging

return Wardrobe
