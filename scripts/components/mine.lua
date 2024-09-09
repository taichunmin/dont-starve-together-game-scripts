local mine_test_fn = function(dude, inst)
    return not (dude.components.health ~= nil and
                dude.components.health:IsDead())
        and dude.components.combat:CanBeAttacked(inst)
end
local mine_test_tags = { "monster", "character", "animal" }
-- See entityreplica.lua
local mine_must_tags = { "_combat" }
local mine_no_tags = { "notraptrigger", "flying", "ghost", "playerghost", "spawnprotection" }

local function MineTest(inst, self)
    if self.radius ~= nil then
		local notags
		if self.alignment ~= nil then
			notags = { "notraptrigger", "flying", "ghost", "playerghost", "spawnprotection", self.alignment }
		else
			notags = mine_no_tags
		end

        local target = FindEntity(inst, self.radius, mine_test_fn, mine_must_tags, notags, mine_test_tags)
        if target ~= nil then
            self:Explode(target)
        end
    end
end

local function DoDeactivate(inst)
    inst.components.mine:Deactivate()
end

local function onissprung(self, issprung)
    if issprung then
        self.inst:AddTag("minesprung")
        self.inst:RemoveTag("mineactive")
    else
        self.inst:RemoveTag("minesprung")
        if not self.inactive then
            self.inst:AddTag("mineactive")
        end
    end
end

local function oninactive(self, inactive)
    if not self.issprung then
        if inactive then
            self.inst:RemoveTag("mineactive")
        else
            self.inst:AddTag("mineactive")
        end
    end
end

local Mine = Class(function(self, inst)
    self.inst = inst

    self.radius = nil
    self.onexplode = nil
    self.onreset = nil
    self.onsetsprung = nil
    self.testtimefn = nil
    self.target = nil
    self.inactive = true
    self.issprung = false
    self.testtask = nil
    self.alignment = "player"

	inst:ListenForEvent("onputininventory", DoDeactivate)
	inst:ListenForEvent("onpickup", DoDeactivate)
	inst:ListenForEvent("teleported", DoDeactivate)
end,
nil,
{
    issprung = onissprung,
    inactive = oninactive,
})

function Mine:OnRemoveFromEntity()
    self:StopTesting()
	self.inst:RemoveEventCallback("onputininventory", DoDeactivate)
	self.inst:RemoveEventCallback("onpickup", DoDeactivate)
	self.inst:RemoveEventCallback("teleported", DoDeactivate)
    self.inst:RemoveTag("minesprung")
    self.inst:RemoveTag("mineactive")
    self.inst:RemoveTag("mine_not_reusable")
end

function Mine:SetRadius(radius)
    self.radius = radius
end

function Mine:SetOnExplodeFn(fn)
    self.onexplode = fn
end

function Mine:SetOnSprungFn(fn)
    self.onsetsprung = fn
end

function Mine:SetOnResetFn(fn)
    self.onreset = fn
end

function Mine:SetOnDeactivateFn(fn)
    self.ondeactivate = fn
end

function Mine:SetTestTimeFn(fn)
    self.testtimefn = fn
end

function Mine:SetAlignment(alignment)
    self.alignment = alignment
end

function Mine:SetReusable(reusable)
    if reusable then
        self.inst:RemoveTag("mine_not_reusable")
    else
        self.inst:AddTag("mine_not_reusable")
    end
end

function Mine:Reset()
    self:StopTesting()
    self.target = nil
    self.issprung = false
    self.inactive = false
    if self.onreset ~= nil then
        self.onreset(self.inst)
    end
    self:StartTesting()
end

function Mine:StartTesting()
    if self.testtask ~= nil then
        self.testtask:Cancel()
    end

    local next_test_time = self.testtimefn ~= nil and self.testtimefn(self.inst) or (1 + math.random())
    self.testtask = self.inst:DoPeriodicTask(next_test_time, MineTest, .9 + math.random() * .1, self)
end

function Mine:StopTesting()
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = nil
    end
end

function Mine:OnEntitySleep()
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = self.inst:DoPeriodicTask(10, MineTest, nil, self)
    end
end

function Mine:OnEntityWake()
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = nil
        self:StartTesting()
    end
end

function Mine:Deactivate()
    self:StopTesting()
    self.issprung = false
    self.inactive = true
    if self.ondeactivate ~= nil then
        self.ondeactivate(self.inst)
    end
end

function Mine:Spring()
    self.inactive = false
    self.issprung = true
    self:StopTesting()
    if self.onsetsprung ~= nil then
        self.onsetsprung(self.inst)
    end
end

function Mine:GetTarget()
    return self.target
end

function Mine:Explode(target)
    self:StopTesting()
    self.target = target
    self.issprung = true
    self.inactive = false
    ProfileStatsAdd("trap_sprung_"..(target ~= nil and target.prefab or ""))
    if self.onexplode ~= nil then
        self.onexplode(self.inst, target)
    end
end

function Mine:OnSave()
    return (self.issprung and { sprung = true })
        or (self.inactive and { inactive = true })
        or nil
end

function Mine:OnLoad(data)
    if data.sprung then
        self:Spring()
    elseif data.inactive then
        self:Deactivate()
    else
        self:Reset()
    end
end

return Mine
