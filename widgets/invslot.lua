local ItemSlot = require "widgets/itemslot"

local InvSlot = Class(ItemSlot, function(self, num, atlas, bgim, owner, container)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.container = container
    self.num = num
end)

function InvSlot:OnControl(control, down)
    if InvSlot._base.OnControl(self, control, down) then return true end
    if not down then
        return false
    end
    if control == CONTROL_ACCEPT then
        --generic click, with possible modifiers
        if TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) then
            self:Inspect()
        elseif TheInput:IsControlPressed(CONTROL_FORCE_TRADE) then
            if self:CanTradeItem() then
                self:TradeItem(TheInput:IsControlPressed(CONTROL_FORCE_STACK))
            else
                return false
            end
        else
            self:Click(TheInput:IsControlPressed(CONTROL_FORCE_STACK))
        end
    elseif control == CONTROL_SECONDARY then
        --alt use (usually RMB)
        if TheInput:IsControlPressed(CONTROL_FORCE_TRADE) then
            self:DropItem(TheInput:IsControlPressed(CONTROL_FORCE_STACK))
        else
            self:UseItem()
        end
        --the rest are explicit control presses for controllers
    elseif control == CONTROL_SPLITSTACK then
        self:Click(true)
    elseif control == CONTROL_TRADEITEM then
        if self:CanTradeItem() then
            self:TradeItem(false)
        else
            return false
        end
    elseif control == CONTROL_TRADESTACK then
        if self:CanTradeItem() then
            self:TradeItem(true)
        else
            return false
        end
    elseif control == CONTROL_INSPECT then
        self:Inspect()
    else
        return false
    end
    return true
end

function InvSlot:Click(stack_mod)
    local slot_number = self.num
    local character = ThePlayer
    local inventory = character and character.replica.inventory or nil
    local active_item = inventory and inventory:GetActiveItem() or nil
    local container = self.container
    local container_item = container and container:GetItemInSlot(slot_number) or nil

    if active_item ~= nil or container_item ~= nil then
        if container_item == nil then
            --Put active item into empty slot
            if container:CanTakeItemInSlot(active_item, slot_number) then
                if active_item.replica.stackable ~= nil and
                    active_item.replica.stackable:IsStack() and
                    (stack_mod or not container:AcceptsStacks()) then
                    --Put one only
                    container:PutOneOfActiveItemInSlot(slot_number)
                else
                    --Put entire stack
                    container:PutAllOfActiveItemInSlot(slot_number)
                end
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
            else
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            end
        elseif active_item == nil then
            --Take active item from slot
            if stack_mod and
                container_item.replica.stackable ~= nil and
                container_item.replica.stackable:IsStack() then
                --Take one only
                container:TakeActiveItemFromHalfOfSlot(slot_number)
            else
                --Take entire stack
                container:TakeActiveItemFromAllOfSlot(slot_number)
            end
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
        elseif container:CanTakeItemInSlot(active_item, slot_number) then
            if container_item.prefab == active_item.prefab and container_item.AnimState:GetSkinBuild() == active_item.AnimState:GetSkinBuild() and container_item.replica.stackable ~= nil and container:AcceptsStacks() then --active_item.prefab and container_item.skinname (this does not work on clients, so we're going to use the AnimState hack instead)
                --Add active item to slot stack
                if stack_mod and
                    active_item.replica.stackable ~= nil and
                    active_item.replica.stackable:IsStack() and
                    not container_item.replica.stackable:IsFull() then
                    --Add only one
                    container:AddOneOfActiveItemToSlot(slot_number)
                else
                    --Add entire stack
                    container:AddAllOfActiveItemToSlot(slot_number)
                end
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")

            elseif active_item.replica.stackable ~= nil and active_item.replica.stackable:IsStack() and not container:AcceptsStacks() then
                container:SwapOneOfActiveItemWithSlot(slot_number)

            elseif container:AcceptsStacks() or not (active_item.replica.stackable ~= nil and active_item.replica.stackable:IsStack()) then
                --Swap active item with slot item
                container:SwapActiveItemWithSlot(slot_number)
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
            else
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            end
        else
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
        end
    end
end

local function FindBestContainer(self, item, containers, exclude_containers)
    if item == nil or containers == nil then
        return
    end

    --Construction containers
    --NOTE: reusing containerwithsameitem variable
    local containerwithsameitem = self.owner ~= nil and self.owner.components.constructionbuilderuidata ~= nil and self.owner.components.constructionbuilderuidata:GetContainer() or nil
    if containerwithsameitem ~= nil then
        if containers[containerwithsameitem] ~= nil and (exclude_containers == nil or not exclude_containers[containerwithsameitem]) then
            local slot = self.owner.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
            if slot ~= nil then
                local container = containerwithsameitem.replica.container
                if container ~= nil and container:CanTakeItemInSlot(item, slot) then
                    local existingitem = container:GetItemInSlot(slot)
                    if existingitem == nil or (container:AcceptsStacks() and existingitem.replica.stackable ~= nil and not existingitem.replica.stackable:IsFull()) then
                        return containerwithsameitem
                    end
                end
            end
        end
        containerwithsameitem = nil
    end

    --local containerwithsameitem = nil --reused with construction containers code above
    local containerwithemptyslot = nil
    local containerwithnonstackableslot = nil

    for k, v in pairs(containers) do
        if exclude_containers == nil or not exclude_containers[k] then
            local container = k.replica.container or k.replica.inventory
            if container ~= nil and container:CanTakeItemInSlot(item) then
                local isfull = container:IsFull()
                if container:AcceptsStacks() then
                    if not isfull and containerwithemptyslot == nil then
                        containerwithemptyslot = k
                    end
                    if item.replica.equippable ~= nil and container == k.replica.inventory then
                        local equip = container:GetEquippedItem(item.replica.equippable:EquipSlot())
                        if equip ~= nil and equip.prefab == item.prefab and equip.skinname == item.skinname then
                            if equip.replica.stackable ~= nil and not equip.replica.stackable:IsFull() then
                                return k
                            elseif not isfull and containerwithsameitem == nil then
                                containerwithsameitem = k
                            end
                        end
                    end
                    for k1, v1 in pairs(container:GetItems()) do
                        if v1.prefab == item.prefab and v1.skinname == item.skinname then
                            if v1.replica.stackable ~= nil and not v1.replica.stackable:IsFull() then
                                return k
                            elseif not isfull and containerwithsameitem == nil then
                                containerwithsameitem = k
                            end
                        end
                    end
                elseif not isfull and containerwithnonstackableslot == nil then
                    containerwithnonstackableslot = k
                end
            end
        end
    end

    return containerwithsameitem or containerwithemptyslot or containerwithnonstackableslot
end

function InvSlot:CanTradeItem()
    local item = self.container and self.container:GetItemInSlot(self.num) or nil
    return not (item ~= nil and item.replica.inventoryitem ~= nil and item.replica.inventoryitem:CanOnlyGoInPocket())
end

--moves items between open containers
function InvSlot:TradeItem(stack_mod)
    local slot_number = self.num
    local character = ThePlayer
    local inventory = character and character.replica.inventory or nil
    local container = self.container
    local container_item = container and container:GetItemInSlot(slot_number) or nil

    if character ~= nil and inventory ~= nil and container_item ~= nil then
        local opencontainers = inventory:GetOpenContainers()
        if next(opencontainers) == nil then
            return
        end

        local overflow = inventory:GetOverflowContainer()
        local backpack = nil
        if overflow ~= nil and overflow:IsOpenedBy(character) then
            backpack = overflow.inst
            overflow = backpack.replica.container
            if overflow == nil then
                backpack = nil
            end
        else
            overflow = nil
        end

        --find our destination container
        local dest_inst = nil
        if container == inventory then
            local playercontainers = backpack ~= nil and { [backpack] = true } or nil
            dest_inst = FindBestContainer(self, container_item, opencontainers, playercontainers)
                or FindBestContainer(self, container_item, playercontainers)
        elseif container == overflow then
            dest_inst = FindBestContainer(self, container_item, opencontainers, { [backpack] = true })
                or (inventory:IsOpenedBy(character)
                    and FindBestContainer(self, container_item, { [character] = true })
                    or nil)
        else
            local exclude_containers = { [container.inst] = true }
            if backpack ~= nil then
                exclude_containers[backpack] = true
            end
            dest_inst = FindBestContainer(self, container_item, opencontainers, exclude_containers) or
                (inventory:IsOpenedBy(character) and character or backpack)
        end

        --if a destination container/inv is found...
        if dest_inst ~= nil then
            if stack_mod and
                container_item.replica.stackable ~= nil and
                container_item.replica.stackable:IsStack() then
                container:MoveItemFromHalfOfSlot(slot_number, dest_inst)
            else
                container:MoveItemFromAllOfSlot(slot_number, dest_inst)
            end
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
        else
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
        end
    end
end

function InvSlot:DropItem(wholestack)
    if self.owner and self.owner.replica.inventory and self.tile and self.tile.item then
        self.owner.replica.inventory:DropItemFromInvTile(self.tile.item, wholestack)
    end
end

function InvSlot:UseItem()
    if self.tile ~= nil and self.tile.item ~= nil then
        local inventory = ThePlayer ~= nil and ThePlayer.replica.inventory or nil
        if inventory ~= nil then
            inventory:UseItemFromInvTile(self.tile.item)
        end
    end
end

function InvSlot:Inspect()
    if self.tile ~= nil and self.tile.item ~= nil then
        local inventory = ThePlayer ~= nil and ThePlayer.replica.inventory or nil
        if inventory ~= nil then
            inventory:InspectItemFromInvTile(self.tile.item)
        end
    end
end

--------------------------------------------------------------------------

function InvSlot:ConvertToConstructionSlot(ingredient, amount)
    if ingredient ~= nil then
        self:SetBGImage2(ingredient:GetAtlas(), ingredient.type..".tex", { 1, 1, 1, .4 })
        self.highlight_scale = 1.7

        local function onquantitychanged(tile, quantity)
            self:SetLabel(
                string.format("%i/%i", amount + quantity, ingredient.amount),
                (amount + quantity >= ingredient.amount and { .25, .75, .25, 1 }) or
                (quantity > 0 and { 1, 1, 1, 1 }) or
                { .7, .7, .7, 1 }
            )
            --return true skips updating the item tile's stack counter display
            return true
        end

        local function ontilechanged(self, tile)
            if tile ~= nil then
                self.bgimage2:Hide()
                tile:SetOnQuantityChangedFn(onquantitychanged)
                if tile.item == nil then
                    --should not happend
                    onquantitychanged(tile, 0)
                elseif tile.item.replica.stackable ~= nil then
                    tile:SetQuantity(tile.item.replica.stackable:StackSize())
                else
                    onquantitychanged(tile, 1)
                end
            else
                self.bgimage2:Show()
                onquantitychanged(nil, 0)
            end
        end

        self:SetOnTileChangedFn(ontilechanged)
        ontilechanged(self, self.tile)
    else
        self:SetBGImage2()
        self:SetLabel()
        self:SetOnTileChangedFn()
        self.highlight_scale = 1.6

        if self.tile ~= nil then
            self.tile:SetOnQuantityChangedFn()
            if self.tile.item ~= nil and self.tile.item.replica.stackable ~= nil then
                self.tile:SetQuantity(self.tile.item.replica.stackable:StackSize())
            end
        end
    end

    self.base_scale = 1.5
    self:SetScale(self.base_scale)
end

return InvSlot
