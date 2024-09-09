local curse_monkey = require("curse_monkey_util")

local Cursable = Class(function(self, inst)
    self.inst = inst
    self.curses = {}
end)

function Cursable:ApplyCurse(item,curse)
	local num = 1
	if item then
		curse = item.components.curseditem.curse
		item.components.curseditem.cursed_target = self.inst
		if item.components.stackable then
			num = item.components.stackable:StackSize()
		end
	end

	self.curses[curse] = (self.curses[curse] or 0) + num
	if curse == "MONKEY" then
		curse_monkey.docurse(self.inst, self.curses[curse])
	end

	item:AddTag("applied_curse")
end

function Cursable:RemoveCurse(curse, numofitems, dropitems)

	local tag = nil
	if curse == "MONKEY" then
		tag = "monkey_token"
	end
	if tag then
		local function finditem(testitem)
			return testitem:HasTag(tag)
		end
		for i = 1, numofitems do
			local item = self.inst.components.inventory:FindItem(finditem)

			if item then
				if dropitems then
					local newcurse = SpawnPrefab(item.prefab)
					newcurse.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
					newcurse.components.inventoryitem:OnDropped(true)
				end
				self.inst.components.inventory:ConsumeByName(item.prefab, 1)
			end
		end
	end

	self.curses[curse] = math.max(0, (self.curses[curse] or 0) - numofitems)

	if curse == "MONKEY" then
		curse_monkey.uncurse(self.inst, self.curses[curse])
	end
end

function Cursable:IsCursable(item)
	if self.inst:HasTag("ghost") then
		return nil
	end
	if self.inst.components.debuffable and self.inst.components.debuffable:HasDebuff("spawnprotectionbuff") then
		return false
	end

	if not self.inst.components.inventory:IsFull() then
		return true
	else

    	if item.components.stackable then
        	local test_items =self.inst.components.inventory:FindItems(function(itemtest) return itemtest.prefab == item.prefab end)
        	for i,stack in ipairs(test_items)do
        		if not stack.components.stackable:IsFull() then
        			return true
        		end
        	end
    	end

		local test_item =self.inst.components.inventory:FindItem(function(itemtest) return not itemtest:HasTag("nosteal") and itemtest ~= self.inst.components.inventory.activeitem and itemtest.components.inventoryitem.owner == self.inst  end)
		if test_item then
			return true
		end
	end
end

function Cursable:ForceOntoOwner(item)

	-- THIS NEEDS TO LOOK FOR AN INCOMPLETE STACK AS WELL BEFORE KICKING AN ITEM OUT
	if self.inst and self.inst:IsValid() and (not self.inst.components.health or not self.inst.components.health:IsDead()) then
        -- check for space
        local drop = true
        
        if self.inst.components.inventory:IsFull() then
        	
        	-- first look for incomplete stack
        	if item.components.stackable then
	        	local test_items =self.inst.components.inventory:FindItems(function(itemtest) return itemtest.prefab == item.prefab  end) --and itemtest ~= self.inst.components.inventory.activeitem
	        	for i,stack in ipairs(test_items)do
	        		if stack.components.stackable and not stack.components.stackable:IsFull() then
	        			drop = false
	        			break
	        		end
	        	end
        	end

        	if drop then
            	-- make space
            	local test_item =self.inst.components.inventory:FindItem(function(itemtest) return not itemtest:HasTag("nosteal") and itemtest ~= self.inst.components.inventory.activeitem and itemtest.components.inventoryitem.owner == self.inst end)
            	self.inst.components.inventory:DropItem(test_item, true, true)
        	end
        end
        if item.components.inventoryitem.owner then
        	item.components.inventoryitem:RemoveFromOwner(true)
    	end
        item.prevcontainer = nil
        item.prevslot = nil
        local pos = nil
        if not item:HasTag("INLIMBO") then
        	pos = Vector3(item.Transform:GetWorldPosition())
        end
     	self.inst.components.inventory:GiveItem(item, nil, pos)
    end
end

function Cursable:Died()
    local curses =  self.inst.components.inventory:FindItems(function(thing) return thing.components.curseditem end)
    for i, curse in ipairs(curses) do
        local cursedtype = curse.components.curseditem.curse
        local num = curse.components.stackable and curse.components.stackable:StackSize() or 1
        self:RemoveCurse(cursedtype,num,true)
    end
end

function Cursable:OnSave()
	return
	{
	--	curses = self.curses
	}
end

function Cursable:OnLoad(data)
	--[[
	if data and data.curses then
		self.curses = data.curses

		for curse, num in pairs(self.curses)do
			if curse == "MONKEY" then
				for i=1,num do
					self:ApplyCurse(curse)
				end
			end
		end
	end
	]]
end

return Cursable
