local function onactive(self, active)
    if active then
        self.inst:AddTag("cursed_inventory_item")
    else
        self.inst:RemoveTag("cursed_inventory_item")
    end
end

local function CopyCursedFields(from, to)
    -- NOTES(JBK): Keep these up to date until handling of cursed items is better for stackables.
    to.active = from.active
    to.cursed_target = from.cursed_target
    to.target = from.target
end

local Curseditem = Class(function(self, inst)
    self.inst = inst

    self.active = true
    self.cursed_target = nil
    self.target = nil
    self.CopyCursedFields = CopyCursedFields -- NOTES(JBK) Keep the fields above up to date with this function.

    self.inst:ListenForEvent("onpickup", function(item,data)
            self:Given(item, data)
        end)

    self.inst:ListenForEvent("entitysleep", function() self.inst:StopUpdatingComponent(self) end)
    self.inst:ListenForEvent("entitywake", function() self.inst:StartUpdatingComponent(self) end)

    self.inst:StartUpdatingComponent(self)
end,
nil,
{
    active = onactive,
})

function Curseditem:checkplayersinventoryforspace(player)
    local space = false

    local invcmp = player.components.inventory
    local freeslots = 0
    for i = 1, invcmp.maxslots do
        if not invcmp.itemslots[i] then
            freeslots = freeslots + 1
        end
    end
    local activeiscursed = invcmp.activeitem and invcmp.activeitem.prefab == self.inst.prefab
    if activeiscursed then
        freeslots = freeslots - 1
    end

    if freeslots <= 0 then
        -- Inventory is full, check for partial stacks.
        if self.inst.components.stackable then
            local test_items = invcmp:FindItems(function(itemtest) return itemtest.prefab == self.inst.prefab end)
            for _, stack in ipairs(test_items) do
                if stack.components.stackable and not stack.components.stackable:IsFull() then
                    space  = true
                    break
                end
            end
        end
        if not space and not activeiscursed then
            -- look item to drop
            local test_item = invcmp:FindItem(function(itemtest) return not itemtest:HasTag("nosteal") and itemtest ~= invcmp.activeitem and itemtest.components.inventoryitem.owner == player end)
            if test_item then
                space = true
            end
        end
    else
        space = true
    end

    return space
end

function Curseditem:lookforplayer() 
    if self.inst.findplayertask then
        self.inst.findplayertask:Cancel()
        self.inst.findplayertask = nil
    end

    self.inst.findplayertask = self.inst:DoPeriodicTask(1,function()
        local x,y,z = self.inst.Transform:GetWorldPosition()
        local player = FindClosestPlayerInRangeSq(x,y,z,10*10,true)

        if player and not self:checkplayersinventoryforspace(player)  then
            player = nil
        end

        if player and player.components.cursable and player.components.cursable:IsCursable(self.inst) and not player.components.debuffable:HasDebuff("spawnprotectionbuff") then
            if self.inst.findplayertask then
                self.inst.findplayertask:Cancel()
                self.inst.findplayertask = nil
            end

            self.target = player
            self.starttime = GetTime()
            self.startpos = Vector3(self.inst.Transform:GetWorldPosition())
        end
    end)
end

function Curseditem:CheckForOwner()
    if self.cursed_target.components.health and self.cursed_target.components.health:IsDead() then
        self.inst:RemoveTag("applied_curse")
        self.cursed_target = nil
    end
    if self.cursed_target then        
        if not self.inst:HasTag("INLIMBO") or 
            (self.inst.components.inventoryitem.owner and self.inst.components.inventoryitem.owner ~= self.cursed_target) then
            self.cursed_target.components.cursable:ForceOntoOwner(self.inst)
        end
    end
end

local ATTACHDIST = 2

function Curseditem:OnUpdate(dt)

    if self.cursed_target then
        self:CheckForOwner()
        if self.cursed_target then
            return
        end
    end
    if self.target and self.target:IsValid() and (not self.target.components.health or not self.target.components.health:IsDead()) and self.target.components.cursable and self.target.components.cursable:IsCursable(self.inst) and self:checkplayersinventoryforspace(self.target) then
        local dist = self.inst:GetDistanceSqToInst(self.target)
        if dist < ATTACHDIST*ATTACHDIST then
            self.target.components.cursable:ForceOntoOwner(self.inst)
        else
            local x,y,z = self.target.Transform:GetWorldPosition()
            local angle = self.inst:GetAngleToPoint(x, y, z)*DEGREES
            local dist =  math.sqrt(dist)
            local speed = math.min(Remap( dist ,0,10,20,1)*dt, dist )
            if speed <= 0 then
                self.target = nil
                if not self.inst.findplayertask then
                    self:lookforplayer()
                end
            else
                local offset = Vector3(speed * math.cos( angle ), 0, -speed * math.sin( angle ))
                local x1,y1,z1 = self.inst.Transform:GetWorldPosition()
                self.inst.Transform:SetPosition(x1+offset.x,0,z1+offset.z)

                if self.inst.components.floater:ShouldShowEffect() then
                    self.inst.components.floater:OnLandedServer()
                else
                    self.inst.components.floater:OnNoLongerLandedServer()
                end
            end
        end
    else
        self.target = nil
        if not self.inst.findplayertask then
            self.inst.findplayertask = self.inst:DoTaskInTime(1,function()
                if not self.inst:HasTag("INLIMBO") then
                    self:lookforplayer()
                end
            end)
        end
    end
end

function Curseditem:Given(item, data) 
    self.target = nil
    if data.owner and data.owner.components.cursable then

        if not self.inst:HasTag("applied_curse") then
            data.owner.components.cursable:ApplyCurse(self.inst)
        else 
            if not item.skipspeech then
                data.owner:DoTaskInTime(0.5,function()
                    if self.inst ~= data.owner.components.inventory.activeitem then
                        data.owner.components.talker:Say(GetString(data.owner, "ANNOUNCE_CANT_ESCAPE_CURSE"))
                    end
                end)
            end
        end

    end
end

return Curseditem