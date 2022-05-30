require("constants")
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local ItemTile = Class(Widget, function(self, invitem)
    Widget._ctor(self, "ItemTile")
    self.item = invitem
    self.ismastersim = TheWorld.ismastersim

    --These flags are used by the client to control animation behaviour while
    --stacksize is being tampered with locally to preview inventory actions so
    --that when the next server sync is received, you won't see a double pop
    --on the item tile scaling
    self.isactivetile = false
    self.ispreviewing = false
    self.movinganim = nil
    self.ignore_stacksize_anim = nil
    self.onquantitychangedfn = nil

    -- NOT SURE WAHT YOU WANT HERE
    if invitem.replica.inventoryitem == nil then
        print("NO INVENTORY ITEM COMPONENT"..tostring(invitem.prefab), invitem)
        return
    end

    if self.item:HasTag("show_spoiled") or self:HasSpoilage() then
            self.bg = self:AddChild(Image(HUD_ATLAS, "inv_slot_spoiled.tex"))
        self.bg:SetClickable(false)
    end

    self.basescale = 1

    if self:HasSpoilage() then
        self.spoilage = self:AddChild(UIAnim())
        self.spoilage:GetAnimState():SetBank("spoiled_meter")
        self.spoilage:GetAnimState():SetBuild("spoiled_meter")
        self.spoilage:GetAnimState():AnimateWhilePaused(false)
        self.spoilage:SetClickable(false)
    end

    self.wetness = self:AddChild(UIAnim())
    self.wetness:GetAnimState():SetBank("wet_meter")
    self.wetness:GetAnimState():SetBuild("wet_meter")
    self.wetness:GetAnimState():PlayAnimation("idle")
    self.wetness:GetAnimState():AnimateWhilePaused(false)
    self.wetness:Hide()
    self.wetness:SetClickable(false)

    if self.item:HasTag("rechargeable") then
        self.rechargepct = 1
        self.rechargetime = math.huge
        self.rechargeframe = self:AddChild(UIAnim())
        self.rechargeframe:GetAnimState():SetBank("recharge_meter")
        self.rechargeframe:GetAnimState():SetBuild("recharge_meter")
        self.rechargeframe:GetAnimState():PlayAnimation("frame")
        self.rechargeframe:GetAnimState():AnimateWhilePaused(false)
    end

    if self.item.inv_image_bg ~= nil then
        self.imagebg = self:AddChild(Image(self.item.inv_image_bg.atlas, self.item.inv_image_bg.image, "default.tex"))
        self.imagebg:SetClickable(false)
        if GetGameModeProperty("icons_use_cc") then
            self.imagebg:SetEffect("shaders/ui_cc.ksh")
        end
    end
    self.image = self:AddChild(Image(invitem.replica.inventoryitem:GetAtlas(), invitem.replica.inventoryitem:GetImage(), "default.tex"))
    if GetGameModeProperty("icons_use_cc") then
        self.image:SetEffect("shaders/ui_cc.ksh")
    end

    --self.image:SetClickable(false)

    if self.rechargeframe ~= nil then
        self.recharge = self:AddChild(UIAnim())
        self.recharge:GetAnimState():SetBank("recharge_meter")
        self.recharge:GetAnimState():SetBuild("recharge_meter")
        self.recharge:GetAnimState():AnimateWhilePaused(false)
        self.recharge:SetClickable(false)
    end

    self.inst:ListenForEvent("imagechange",
        function(invitem)
            if self.imagebg ~= nil then
                if self.item.inv_image_bg ~= nil then
                    self.imagebg:SetTexture(self.item.inv_image_bg.atlas, self.item.inv_image_bg.image)
                    self.imagebg:Show()
                else
                    self.imagebg:Hide()
                end
            end
            self.image:SetTexture(invitem.replica.inventoryitem:GetAtlas(), invitem.replica.inventoryitem:GetImage())
        end, invitem)
    if invitem:HasClientSideInventoryImageOverrides() then
        self.inst:ListenForEvent("clientsideinventoryflagschanged",
            function(player)
                if invitem and invitem.replica.inventoryitem then
                    self.image:SetTexture(invitem.replica.inventoryitem:GetAtlas(), invitem.replica.inventoryitem:GetImage())
                end
            end, ThePlayer)
    end
	self.inst:ListenForEvent("inventoryitem_updatetooltip",
		function(invitem)
			if self.focus and not TheInput:ControllerAttached() then
				self:UpdateTooltip()
			end
		end, invitem)
        self.inst:ListenForEvent("inventoryitem_updatespecifictooltip",
            function(player, data)
                if self.focus and not TheInput:ControllerAttached() and invitem.prefab == data.prefab then
                    self:UpdateTooltip()
                end
            end, ThePlayer)
    self.inst:ListenForEvent("stacksizechange",
        function(invitem, data)
            if invitem.replica.stackable ~= nil then
                if self.ignore_stacksize_anim then
                    if self.movinganim ~= nil then
                        self.movinganim.isolddata = true
                    end
                    self:SetQuantity(data.stacksize)
                elseif data.src_pos ~= nil then
                    if self.movinganim ~= nil and not (self.movinganim.inst.components.uianim ~= nil and (self.movinganim.inst.components.uianim.pos_t or 0) > 0) then
                        --cancel previous anim if it hasn't updated even once yet
                        self.movinganim:Kill()
                    end
                    local dest_pos = self:GetWorldPosition()
                    local im = Image(invitem.replica.inventoryitem:GetAtlas(), invitem.replica.inventoryitem:GetImage())
                    if GetGameModeProperty("icons_use_cc") then
                        im:SetEffect("shaders/ui_cc.ksh")
                    end
                    im:MoveTo(Vector3(TheSim:GetScreenPos(data.src_pos:Get())), dest_pos, .3, function()
                        --V2C: tile could be killed already if the user picked it
                        --     up with mouse cursor during the move to animation.
                        if self.inst:IsValid() then
                            local iscurrent = not (self.movinganim ~= nil and self.movinganim.isolddata)
                            if self.movinganim == im then
                                self.movinganim = nil
                            end
                            if iscurrent then
                                self:SetQuantity(data.stacksize)
                                self:ScaleTo(self.basescale * 2, self.basescale, .25)
                            end
                        end
                        im:Kill()
                    end)
                    self.movinganim = im
                elseif not self.ispreviewing then
                    if self.movinganim ~= nil then
                        self.movinganim.isolddata = true
                    end
                    self:SetQuantity(data.stacksize)
                    self:ScaleTo(self.basescale * 2, self.basescale, .25)
                end
            end
        end, invitem)

    self.inst:ListenForEvent("percentusedchange",
        function(invitem, data)
            self:SetPercent(data.percent)
        end, invitem)

    self.inst:ListenForEvent("perishchange",
        function(invitem, data)
            if self:HasSpoilage() then
                self:SetPerishPercent(data.percent)
            elseif invitem:HasTag("fresh") or invitem:HasTag("stale") or invitem:HasTag("spoiled") then
                self:SetPercent(data.percent)
            end
        end, invitem)

    if self.rechargeframe ~= nil then
        self.inst:ListenForEvent("rechargechange",
            function(invitem, data)
                self:SetChargePercent(data.percent)
            end, invitem)

        self.inst:ListenForEvent("rechargetimechange",
            function(invitem, data)
                self:SetChargeTime(data.t)
            end, invitem)
    end

    self.inst:ListenForEvent("wetnesschange",
        function(invitem, wet)
            if not self.isactivetile then
                if wet then
                    self.wetness:Show()
                else
                    self.wetness:Hide()
                end
            end
        end, invitem)

    if not self.ismastersim then
        self.inst:ListenForEvent("stacksizepreview",
            function(invitem, data)
                if data.activecontainer ~= nil and
                    self.parent ~= nil and
                    self.parent.container ~= nil and
                    self.parent.container.inst == data.activecontainer and
                    data.activestacksize ~= nil then
                    self:SetQuantity(data.activestacksize)
                    if data.animateactivestacksize then
                        self:ScaleTo(self.basescale * 2, self.basescale, .25)
                    end
                    self.ispreviewing = true
                elseif self.isactivetile and
                    data.activecontainer == nil and
                    data.activestacksize ~= nil then
                    self:SetQuantity(data.activestacksize)
                    if data.animateactivestacksize then
                        self:ScaleTo(self.basescale * 2, self.basescale, .25)
                    end
                    self.ispreviewing = true
                elseif data.stacksize ~= nil then
                    self:SetQuantity(data.stacksize)
                    if data.animatestacksize then
                        self:ScaleTo(self.basescale * 2, self.basescale, .25)
                    end
                    self.ispreviewing = true
                end
            end, invitem)
    end

    self:Refresh()
end)

function ItemTile:Refresh()
    self.ispreviewing = false
    self.ignore_stacksize_anim = nil

    if self.movinganim == nil and self.item.replica.stackable ~= nil then
        self:SetQuantity(self.item.replica.stackable:StackSize())
    end

    if self.ismastersim then
        if self.item.components.armor ~= nil then
            self:SetPercent(self.item.components.armor:GetPercent())
        elseif self.item.components.perishable ~= nil then
            if self:HasSpoilage() then
                self:SetPerishPercent(self.item.components.perishable:GetPercent())
            else
                self:SetPercent(self.item.components.perishable:GetPercent())
            end
        elseif self.item.components.finiteuses ~= nil then
            self:SetPercent(self.item.components.finiteuses:GetPercent())
        elseif self.item.components.fueled ~= nil then
            self:SetPercent(self.item.components.fueled:GetPercent())
        end

        if self.rechargeframe ~= nil and self.item.components.rechargeable ~= nil then
            self:SetChargePercent(self.item.components.rechargeable:GetPercent())
            self:SetChargeTime(self.item.components.rechargeable:GetRechargeTime())
        end
    elseif self.item.replica.inventoryitem ~= nil then
        self.item.replica.inventoryitem:DeserializeUsage()
    end

    if not self.isactivetile then
        if self.item:GetIsWet() then
            self.wetness:Show()
        else
            self.wetness:Hide()
        end
    end
end

function ItemTile:SetBaseScale(sc)
    self.basescale = sc
    self:SetScale(sc)
end

function ItemTile:OnControl(control, down)
    self:UpdateTooltip()
    return false
end

function ItemTile:UpdateTooltip()
    local str = self:GetDescriptionString()
    self:SetTooltip(str)
    if self.item:GetIsWet() then
        self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
    else
        self:SetTooltipColour(unpack(NORMAL_TEXT_COLOUR))
    end
end

function ItemTile:GetDescriptionString()
    local str = ""
    if self.item ~= nil and self.item:IsValid() and self.item.replica.inventoryitem ~= nil then
        local adjective = self.item:GetAdjective()
        if adjective ~= nil then
            str = adjective.." "
        end
        str = str..self.item:GetDisplayName()

        local player = ThePlayer
        local actionpicker = player.components.playeractionpicker
        local active_item = player.replica.inventory:GetActiveItem()
        if active_item == nil then
            if not (self.item.replica.equippable ~= nil and self.item.replica.equippable:IsEquipped()) then
                --self.namedisp:SetHAlign(ANCHOR_LEFT)
                if TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) then
                    str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY)..": "..STRINGS.INSPECTMOD
                elseif TheInput:IsControlPressed(CONTROL_FORCE_TRADE) and not self.item.replica.inventoryitem:CanOnlyGoInPocket() then
                    if next(player.replica.inventory:GetOpenContainers()) ~= nil then
                        str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY)..": "..((TheInput:IsControlPressed(CONTROL_FORCE_STACK) and self.item.replica.stackable ~= nil) and (STRINGS.STACKMOD.." "..STRINGS.TRADEMOD) or STRINGS.TRADEMOD)
                    end
                elseif TheInput:IsControlPressed(CONTROL_FORCE_STACK) and self.item.replica.stackable ~= nil then
                    str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY)..": "..STRINGS.STACKMOD
                end
            end

            local actions = actionpicker:GetInventoryActions(self.item)
            if #actions > 0 then
                str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)..": "..actions[1]:GetActionString()
            end
        elseif active_item:IsValid() then
            if not (self.item.replica.equippable ~= nil and self.item.replica.equippable:IsEquipped()) then
                if active_item.replica.stackable ~= nil and active_item.prefab == self.item.prefab and active_item.AnimState:GetSkinBuild() == self.item.AnimState:GetSkinBuild() then --active_item.skinname == self.item.skinname (this does not work on clients, so we're going to use the AnimState hack instead)
                    str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY)..": "..STRINGS.UI.HUD.PUT
                else
                    str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY)..": "..STRINGS.UI.HUD.SWAP
                end
            end

            --no RMB hint for quickdrop while holding an item, as that might be confusing since players would think its the item they are holding.
            --the mod never had the hint, and people discovered it just fine, so this should also be fine -Zachary

            local actions = actionpicker:GetUseItemActions(self.item, active_item, true)
            if #actions > 0 then
                str = str.."\n"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)..": "..actions[1]:GetActionString()
            end
        end
    end
    return str
end

function ItemTile:OnGainFocus()
    self:UpdateTooltip()
end

--Callback for overriding quantity display handler (used by construction site containers)
--return true to skip default handler code
function ItemTile:SetOnQuantityChangedFn(fn)
    self.onquantitychangedfn = fn
end

function ItemTile:SetQuantity(quantity)
    if self.onquantitychangedfn ~= nil and self:onquantitychangedfn(quantity) then
        if self.quantity ~= nil then
            self.quantity = self.quantity:Kill()
        end
        return
    elseif not self.quantity then
        self.quantity = self:AddChild(Text(NUMBERFONT, 42))
        self.quantity:SetPosition(2, 16, 0)
    end
    self.quantity:SetString(tostring(quantity))
end

function ItemTile:SetPerishPercent(percent)
    --percent is approximated over the network, so check tags to
    --determine the correct color at the 50% and 20% boundaries.
    if percent < .51 and percent > .49 and self.item:HasTag("fresh") then
        self.spoilage:GetAnimState():OverrideSymbol("meter", "spoiled_meter", "meter_green")
        self.spoilage:GetAnimState():OverrideSymbol("frame", "spoiled_meter", "frame_green")
    elseif percent < .21 and percent > .19 and self.item:HasTag("stale") then
        self.spoilage:GetAnimState():OverrideSymbol("meter", "spoiled_meter", "meter_yellow")
        self.spoilage:GetAnimState():OverrideSymbol("frame", "spoiled_meter", "frame_yellow")
    else
        self.spoilage:GetAnimState():ClearAllOverrideSymbols()
    end
    --don't use 100% frame, since it should be replace by something like "spoiled_food" then
    self.spoilage:GetAnimState():SetPercent("anim", math.clamp(1 - percent, 0, .99))
end

function ItemTile:SetPercent(percent)
	if not self.item:HasTag("hide_percentage") then
		if not self.percent then
			self.percent = self:AddChild(Text(NUMBERFONT, 42))
			if JapaneseOnPS4() then
				self.percent:SetHorizontalSqueeze(0.7)
			end
			self.percent:SetPosition(5,-32+15,0)
		end
		local val_to_show = percent*100
		if val_to_show > 0 and val_to_show < 1 then
			val_to_show = 1
		end
		self.percent:SetString(string.format("%2.0f%%", val_to_show))
    end
end

function ItemTile:SetChargePercent(percent)
	local prev_precent = self.rechargepct
    self.rechargepct = percent
	if self.recharge.shown then
		if percent < 1 then
			self.recharge:GetAnimState():SetPercent("recharge", percent)
			if not self.rechargeframe.shown then
				self.rechargeframe:Show()
			end
			if percent >= 0.9999 then
				self:StopUpdating()
			elseif self.rechargetime < math.huge then
				self:StartUpdating()
			end
		else
			if prev_precent < 1 and not self.recharge:GetAnimState():IsCurrentAnimation("frame_pst") then
				self.recharge:GetAnimState():PlayAnimation("frame_pst")
			end
			if self.rechargeframe.shown then
				self.rechargeframe:Hide()
			end
			self:StopUpdating()
		end
	end
end

function ItemTile:SetChargeTime(t)
    self.rechargetime = t
    if self.rechargetime >= math.huge then
        self:StopUpdating()
    elseif self.rechargepct < .9999 then
        self:StartUpdating()
    end
end

--[[
function ItemTile:CancelDrag()
    self:StopFollowMouse()

    if self.item:HasTag("show_spoiled") or (self.item.components.edible and self.item.components.perishable) then
        self.bg:Show( )
    end

    if self.item.components.perishable and self.item.components.edible then
        self.spoilage:Show()
    end

    self.image:SetClickable(true)
end
--]]

function ItemTile:StartDrag()
    --self:SetScale(1,1,1)
    if self.item.replica.inventoryitem ~= nil then -- HACK HACK: items without an inventory component won't have any of these
        if self.spoilage ~= nil then
            self.spoilage:Hide()
        end
        self.wetness:Hide()
        if self.bg ~= nil then
            self.bg:Hide()
        end
        if self.recharge ~= nil then
            self.recharge:Hide()
			self.rechargeframe:Hide()
			self:StopUpdating()
		end
        self.image:SetClickable(false)
    end
end

function ItemTile:HasSpoilage()
    if self.hasspoilage ~= nil then
        return self.hasspoilage
    elseif not (self.item:HasTag("fresh") or self.item:HasTag("stale") or self.item:HasTag("spoiled")) then
        self.hasspoilage = false
    elseif self.item:HasTag("show_spoilage") then
        self.hasspoilage = true
    else
        for k, v in pairs(FOODTYPE) do
            if self.item:HasTag("edible_"..v) then
                self.hasspoilage = true
                return true
            end
        end
        self.hasspoilage = false
    end
    return self.hasspoilage
end

function ItemTile:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end
    self:SetChargePercent(self.rechargetime > 0 and self.rechargepct + dt / self.rechargetime or .9999)
end

return ItemTile
