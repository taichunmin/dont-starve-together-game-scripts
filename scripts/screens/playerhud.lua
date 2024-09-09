local Screen = require "widgets/screen"
local ContainerWidget = require("widgets/containerwidget")
local WriteableWidget = require("widgets/writeablewidget")
local Controls = require("widgets/controls")
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local IceOver = require "widgets/iceover"
local FireOver = require "widgets/fireover"
local BloodOver = require "widgets/bloodover"
local BeefBloodOver = require "widgets/beefbloodover"
local HeatOver = require "widgets/heatover"
local FumeOver = require "widgets/fumeover"
local MiasmaOver = require("widgets/miasmaover")
local MiasmaCloudsOver = require("widgets/miasmacloudsover")
local SandOver = require "widgets/sandover"
local SandDustOver = require "widgets/sanddustover"
local MoonstormOver = require "widgets/moonstormover"
local MoonstormOver_Lightning = require "widgets/moonstormover_lightning"
local RainDomeOver = require("widgets/raindomeover")
local Leafcanopy = require "widgets/leafcanopy"
local MindControlOver = require "widgets/mindcontrolover"
local InkOver = require "widgets/inkover"
local WagpunkUI = require "widgets/wagpunkui"
local GogglesOver = require "widgets/gogglesover"
local NutrientsOver = require "widgets/nutrientsover"
local ScrapMonocleOver = require "widgets/scrapmonocleover"
local NightVisionFruitOver = require "widgets/nightvisionfruitover"
local InspectaclesOver = require("widgets/inspectaclesover")
local RoseGlassesOver = require("widgets/roseglassesover")
local BatOver = require "widgets/batover"
local FlareOver = require "widgets/flareover"
local EndOfMatchPopup = require "widgets/redux/endofmatchpopup"
local PopupNumber = require "widgets/popupnumber"
local RingMeter = require "widgets/ringmeter"
local easing = require("easing")
local PauseScreen = require "screens/redux/pausescreen"
local ChatInputScreen = require "screens/chatinputscreen"
local PlayerStatusScreen = require "screens/playerstatusscreen"
local InputDialogScreen = require "screens/inputdialog"
local CookbookPopupScreen = require "screens/cookbookpopupscreen"
local PlantRegistryPopupScreen = require "screens/plantregistrypopupscreen"
local PlayerInfoPopupScreen = require "screens/playerinfopopupscreen"
local ScrapbookScreen = require "screens/redux/scrapbookscreen"
local InspectaclesScreen = require("screens/redux/inspectaclesscreen")

local TargetIndicator = require "widgets/targetindicator"

local EventAnnouncer = require "widgets/eventannouncer"
local GiftItemPopUp = require "screens/giftitempopup"
local GridWardrobePopupScreen = require "screens/redux/wardrobepopupgridloadout"
local GridGroomerPopupScreen = require "screens/redux/groomerpopupgridloadout"
local GridScarecrowClothingPopupScreen = require "screens/redux/scarecrowpopupgridloadout"
local PlayerAvatarPopup = require "widgets/playeravatarpopup"
local DressupAvatarPopup = require "widgets/dressupavatarpopup"

local PlayerHud = Class(Screen, function(self)
    Screen._ctor(self, "HUD")

    self.overlayroot = self:AddChild(Widget("overlays"))

    self.under_root = self:AddChild(Widget("under_root"))
    self.root = self:AddChild(Widget("root"))
    self.over_root = self:AddChild(Widget("over_root"))
    self.popupstats_root = self:AddChild(Widget("popupstats_root"))

    self.playerstatusscreen = nil
    self.giftitempopup = nil
    self.wardrobepopup = nil
    self.groomerpopup = nil
    self.playeravatarpopup = nil
    self.recentgifts = nil
    self.recentgiftstask = nil

    self.inst:ListenForEvent("continuefrompause", function() self:RefreshControllers() end, TheWorld)
    self.inst:ListenForEvent("endofmatch", function(world, data) self:ShowEndOfMatchPopup(data) end, TheWorld)

    if not TheWorld.ismastersim then
        self.inst:ListenForEvent("deactivateworld", function()
            --Essential cleanup when client is notified of
            --pending server c_reset or c_regenerateworld.
            if self.playeravatarpopup ~= nil then
                if self.playeravatarpopup.started and self.playeravatarpopup.inst:IsValid() then
                    self.playeravatarpopup:Close()
                end
                self.playeravatarpopup = nil
            end
            if self.playerstatusscreen ~= nil then
                if self.playerstatusscreen.shown then
                    self.playerstatusscreen:Close()
                end
                self.playerstatusscreen:CloseUserCommandPickerScreen()
            end
        end, TheWorld)
    else
        self.inst:ListenForEvent("ms_closepopups", self.onclosepopups)
    end
end)

function PlayerHud:CreateOverlays(owner)
    self.overlayroot:KillAllChildren()
    self.under_root:KillAllChildren()
    self.over_root:KillAllChildren()

    self.vig = self.overlayroot:AddChild(UIAnim())
    self.vig:GetAnimState():SetBuild("vig")
    self.vig:GetAnimState():SetBank("vig")
    self.vig:GetAnimState():PlayAnimation("basic", true)
    self.vig:GetAnimState():AnimateWhilePaused(false)

    self.vig:SetHAnchor(ANCHOR_MIDDLE)
    self.vig:SetVAnchor(ANCHOR_MIDDLE)
    self.vig:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self.vig:SetClickable(false)

    self.drops_vig = self.overlayroot:AddChild(UIAnim())
    self.drops_vig:GetAnimState():SetBuild("paddle_over")
    self.drops_vig:GetAnimState():SetBank("paddle_over")
    self.drops_vig:GetAnimState():PlayAnimation("over", true)
    self.drops_vig:GetAnimState():AnimateWhilePaused(false)

    self.drops_vig:SetHAnchor(ANCHOR_MIDDLE)
    self.drops_vig:SetVAnchor(ANCHOR_MIDDLE)
    self.drops_vig:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self.drops_vig:SetClickable(false)
    self.drops_vig:Hide()
    self.drops_alpha= 0

    self.inst:ListenForEvent("moisturedelta", function(inst, data)
			if owner.components.raindomewatcher ~= nil and owner.components.raindomewatcher:IsUnderRainDome() then
				self.dropsplash = nil
				if self.droptask ~= nil then
					self.droptask:Cancel()
					self.droptask = nil
				end
			elseif data.new > data.old then
                self.dropsplash = true
                if self.droptask then
                    self.droptask:Cancel()
                end
                self.droptask = self.inst:DoSimTaskInTime(3,function() self.dropsplash = nil end)
            end
        end, owner)

    self.leafcanopy = self.overlayroot:AddChild(Leafcanopy(owner))
    self.raindomeover = self.overlayroot:AddChild(RainDomeOver(owner))

    self.storm_root = self.over_root:AddChild(Widget("storm_root"))
    self.storm_overlays = self.storm_root:AddChild(Widget("storm_overlays"))
    self.sanddustover = self.storm_overlays:AddChild(SandDustOver(owner))

    self.moonstormdust = self.storm_overlays:AddChild(Image("images/overlays_moonstorm.xml", "moonstorm.tex"))
    self.moonstormdust:SetEffect( "shaders/moonstorm.ksh" )
    self.moonstormdust:EnableEffectParams2(true)
    self.moonstormdust:SetHAnchor(ANCHOR_MIDDLE)
    self.moonstormdust:SetVAnchor(ANCHOR_MIDDLE)
    self.moonstormdust:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.moonstormdust:SetBlendMode(1)
    self.moonstormdust:SetUVMode(WRAP_MODE.WRAP)
    self.moonstormdust:Hide()
    self.moonstormdust:SetClickable(false)
    self.moonstormover_lightning = self.storm_overlays:AddChild(MoonstormOver_Lightning(owner))

	self.miasmaclouds = self.storm_overlays:AddChild(MiasmaCloudsOver(owner))

    self.mindcontrolover = self.over_root:AddChild(MindControlOver(owner))

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        self.batover = self.overlayroot:AddChild(BatOver(owner))
    end
    self.sandover = self.overlayroot:AddChild(SandOver(owner, self.sanddustover))
    self.moonstormover = self.overlayroot:AddChild(MoonstormOver(owner, self.moonstormdust))
	self.miasmaover = self.overlayroot:AddChild(MiasmaOver(owner, self.miasmaclouds))

    self.gogglesover = self.overlayroot:AddChild(GogglesOver(owner, self.storm_overlays))
    self.nutrientsover = self.overlayroot:AddChild(NutrientsOver(owner))
    self.scrapmonocleover = self.overlayroot:AddChild(ScrapMonocleOver(owner))
    self.nightvisionfruitover = self.overlayroot:AddChild(NightVisionFruitOver(owner))
    self.inspectaclesover = self.overlayroot:AddChild(InspectaclesOver(owner))
    self.roseglassesover = self.overlayroot:AddChild(RoseGlassesOver(owner))
    self.bloodover = self.overlayroot:AddChild(BloodOver(owner))
    self.beefbloodover = self.overlayroot:AddChild(BeefBloodOver(owner))
    self.iceover = self.overlayroot:AddChild(IceOver(owner))
    self.fireover = self.overlayroot:AddChild(FireOver(owner))
    self.heatover = self.overlayroot:AddChild(HeatOver(owner))
    self.fumeover = self.overlayroot:AddChild(FumeOver(owner))
    self.flareover = self.overlayroot:AddChild(FlareOver(owner))

    self.InkOver = self.overlayroot:AddChild(InkOver(owner))
    self.Wagpunkui = self.overlayroot:AddChild(WagpunkUI(owner))    

    self.clouds = self.under_root:AddChild(UIAnim())
    self.clouds.cloudcolour = GetGameModeProperty("cloudcolour") or {1, 1, 1}
    self.clouds:SetClickable(false)
    self.clouds:SetHAnchor(ANCHOR_MIDDLE)
    self.clouds:SetVAnchor(ANCHOR_MIDDLE)
    self.clouds:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)
    self.clouds:GetAnimState():SetBank("clouds_ol")
    self.clouds:GetAnimState():SetBuild("clouds_ol")
    self.clouds:GetAnimState():SetForceSinglePass(true)
    self.clouds:GetAnimState():PlayAnimation("idle", true)
    self.clouds:GetAnimState():SetMultColour(self.clouds.cloudcolour[1], self.clouds.cloudcolour[2], self.clouds.cloudcolour[3], 0)
    self.clouds:Hide()

    self.serverpause_underlay = self.under_root:AddChild(Image("images/global.xml", "square.tex"))
    self.serverpause_underlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.serverpause_underlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.serverpause_underlay:SetVAnchor(ANCHOR_MIDDLE)
    self.serverpause_underlay:SetHAnchor(ANCHOR_MIDDLE)
    self.serverpause_underlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.serverpause_underlay:SetTint(0,0,0,0.5)
	self.serverpause_underlay:Hide()
	self.serverpaused = false
    self:SetServerPaused(TheNet:IsServerPaused(true))

    self.eventannouncer = self.under_root:AddChild(Widget("eventannouncer_root"))
    self.eventannouncer:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.eventannouncer:SetHAnchor(ANCHOR_MIDDLE)
    self.eventannouncer:SetVAnchor(ANCHOR_TOP)
    self.eventannouncer = self.eventannouncer:AddChild(Widget("eventannouncer"))
    self.eventannouncer:SetPosition(0, GetGameModeProperty("eventannouncer_offset") or 0)

    if TheFrontEnd:GetActiveScreen() == ThePlayer.HUD then
        ThePlayer.HUD:OffsetServerPausedWidget(TheFrontEnd.serverpausewidget)
    end
end

function PlayerHud:OnDestroy()
    --Hack for holding offset when transitioning from giftitempopup to wardrobepopup
    TheCamera:PopScreenHOffset(self)

    if self.playerstatusscreen ~= nil then
        self.playerstatusscreen:CloseUserCommandPickerScreen()
        self.playerstatusscreen:Kill()
        self.playerstatusscreen = nil
    end
    Screen.OnDestroy(self)
end

function PlayerHud:OnLoseFocus()
    Screen.OnLoseFocus(self)
    TheInput:EnableMouse(true)

    self:CloseCrafting()
	self:CloseSpellWheel()
    if self:IsControllerInventoryOpen() then
        self:CloseControllerInventory()
    end

    if self.owner ~= nil and TheInput:ControllerAttached() then
        self.owner.replica.inventory:ReturnActiveItem()
    end
    if self.controls ~= nil then
        self.controls.hover:Hide()
        self.controls.item_notification:ToggleHUDFocus(false)
        self.controls.skilltree_notification:ToggleHUDFocus(false)

        local resurrectbutton = self.controls.status:GetResurrectButton()
        if resurrectbutton ~= nil then
            resurrectbutton:ToggleHUDFocus(false)
        end
    end
end

function PlayerHud:OnGainFocus()
    Screen.OnGainFocus(self)
    local controller = TheInput:ControllerAttached()
    TheInput:EnableMouse(not controller)

    if self.controls ~= nil then
        self.controls:SetHUDSize()
        if controller then
            self.controls.hover:Hide()
        else
            self.controls.hover:Show()
        end
        self.controls.item_notification:ToggleHUDFocus(true)
        self.controls.skilltree_notification:ToggleHUDFocus(true)
        local resurrectbutton = self.controls.status:GetResurrectButton()
        if resurrectbutton ~= nil then
            resurrectbutton:ToggleHUDFocus(true)
        end
    end

    if not TheInput:ControllerAttached() then
        if self:IsControllerInventoryOpen() then
            self:CloseControllerInventory()
        end
    end
end

function PlayerHud:Toggle(targetindicators)
    if self.shown then
        self:Hide()
        if targetindicators and self.targetindicators then
            for i, target in pairs(self.targetindicators) do
                target:Hide()
            end
        end
    else
        self:Show()
        if self.targetindicators then
            for i, target in pairs(self.targetindicators) do
                target:Show()
            end
        end
    end
end

function PlayerHud:Hide()
    self.shown = false
    self.root:Hide()

    --Normally, HUD hides are tied to gameplay logic, but we need to manually force close some locally controlled FE popup screens.
    self.controls.votedialog:CloseControllerVoteScreen()
    if self.playerstatusscreen ~= nil then
        self.playerstatusscreen:CloseUserCommandPickerScreen()
    end
end

function PlayerHud:Show()
    self.shown = true
    self.root:Show()
end

function PlayerHud:GetFirstOpenContainerWidget()
    local k, v = next(self.controls.containers)
    return v
end

local function CloseAllChestContainerWidgets(self)
	for _, v in pairs(self.controls.containers) do
		--cheap check for "chest" type containers
		if v:GetParent() == self.controls.containerroot then
			v:Close()
		end
	end
end

local function CloseContainerWidget(self, container, side)
    for k, v in pairs(self.controls.containers) do
        if v.container == container then
            v:Close()
        end
    end
end

function PlayerHud:CloseContainer(container, side)
    if container == nil then
        return
    elseif side and (TheInput:ControllerAttached() or Profile:GetIntegratedBackpack()) then
        self.controls.inv.rebuild_pending = true
    else
        CloseContainerWidget(self, container, side)
    end
end

local function OpenContainerWidget(self, container, side)
    local containerwidget = ContainerWidget(self.owner)
	local parent = side and self.controls.containerroot_side
					or (container.replica.container ~= nil and container.replica.container.type == "hand_inv") and self.controls.inv.hand_inv
                    or (container.replica.container ~= nil and container.replica.container.type == "side_inv") and self.controls.secondary_status.side_inv
                    or (container.replica.container ~= nil and container.replica.container.type == "side_inv_behind") and self.controls.containerroot_side_behind
					or self.controls.containerroot

	parent:AddChild(containerwidget)

    --self.controls[side and "containerroot_side" or "containerroot"]:AddChild(containerwidget)
    --self.controls.bottom_root:AddChild(containerwidget)
    --self.controls.inv.hand_inv:AddChild(containerwidget)

	containerwidget:MoveToBack()
    containerwidget:Open(container, self.owner)
    self.controls.containers[container] = containerwidget

	if parent == self.controls.containerroot then
		self:CloseSpellWheel()
	end
end

function PlayerHud:OpenContainer(container, side)
    if container == nil then
        return
    elseif side and (TheInput:ControllerAttached() or Profile:GetIntegratedBackpack()) then
        self.controls.inv.rebuild_pending = true
    else
        OpenContainerWidget(self, container, side)
    end
end

function PlayerHud:RemoveDressupWidget()
    if self.dressupAvatarPopUpcreen then
        self.dressupAvatarPopUpcreen:Kill()
        self.dressupAvatarPopUpcreen = nil
    end 
end

function PlayerHud:TogglePlayerInfoPopup(player_name, data, show_net_profile, force)
    if self.dressupAvatarPopUpcreen ~= nil then
        self.dressupAvatarPopUpcreen:Close()
        self.dressupAvatarPopUpcreen = nil
    elseif self.OpenPlayerInfoScreen ~= nil then
        POPUPS.PLAYERINFO:Close(self.owner)
        self:OpenPlayerInfoScreen(player_name, data, show_net_profile, force)
    end
end

--ThePlayer.HUD:ShowEndOfMatchPopup({victory=true})
function PlayerHud:ShowEndOfMatchPopup(data)
    self.inst:DoTaskInTime(data.victory and 2.5 or 0, function()
        if self.endofmatchpopup == nil then
            local popupdata =
            {
                title = data.victory and STRINGS.UI.HUD.LAVAARENA_WIN_TITLE or STRINGS.UI.HUD.LAVAARENA_LOSE_TITLE,
                body = data.victory and STRINGS.UI.HUD.LAVAARENA_WIN_BODY or STRINGS.UI.HUD.LAVAARENA_LOSE_BODY,
            }
            self.endofmatchpopup = self.root:AddChild(EndOfMatchPopup(self.owner, popupdata))
        end
    end)
end

function PlayerHud:OpenScreenUnderPause(screen)
    if self:IsPauseScreenOpen() then
        TheFrontEnd:InsertScreenUnderTop(screen)
    else
        TheFrontEnd:PushScreen(screen)
    end
end

function PlayerHud:OpenItemManagerScreen()
    --Hack for holding offset when transitioning from giftitempopup to wardrobepopup
    TheCamera:PopScreenHOffset(self)
    self:ClearRecentGifts()

    if self.giftitempopup ~= nil and self.giftitempopup.inst:IsValid() then
        TheFrontEnd:PopScreen(self.giftitempopup)
    end
    local item = TheInventory:GetUnopenedItems()[1]
    if item ~= nil then
        self.giftitempopup = GiftItemPopUp(self.owner, { item.item_type }, { item.item_id })
        self:OpenScreenUnderPause(self.giftitempopup)
        return true
    else
        return false
    end
end

local function OnClearRecentGifts(inst, self)
    self.recentgiftstask = nil
    self:ClearRecentGifts()
end

function PlayerHud:CloseItemManagerScreen()
    --Hack for holding offset when transitioning from giftitempopup to wardrobepopup
    TheCamera:PopScreenHOffset(self)
    if self.recentgiftstask == nil then
        self.recentgiftstask = self.inst:DoTaskInTime(0, OnClearRecentGifts, self)
    end

    if self.giftitempopup ~= nil then
        if self.giftitempopup.inst:IsValid() then
            TheFrontEnd:PopScreen(self.giftitempopup)
        end
        self.giftitempopup = nil
    end
end

function PlayerHud:OpenWardrobeScreen(target)
    --Hack for holding offset when transitioning from giftitempopup to wardrobepopup
    TheCamera:PopScreenHOffset(self)

    if self.wardrobepopup ~= nil and self.wardrobepopup.inst:IsValid() then
        TheFrontEnd:PopScreen(self.wardrobepopup)
    end

    if target ~= nil then
        self.wardrobepopup =
            GridScarecrowClothingPopupScreen(
                target,
                self.owner,
                Profile
            )
    else
        self.wardrobepopup =
            GridWardrobePopupScreen(
                self.owner,
                Profile,
                self.recentgifts ~= nil and self.recentgifts.item_types or nil,
                self.recentgifts ~= nil and self.recentgifts.item_ids or nil
            )
    end

    if not TheWorld.ismastersim then
        local map = TheFrontEnd:GetOpenScreenOfType("MapScreen")
        if map ~= nil and self.controls ~= nil then
            self.controls:HideMap()
        end
    end

    self:ClearRecentGifts()
    self:OpenScreenUnderPause(self.wardrobepopup)
    return true
end

function PlayerHud:CloseWardrobeScreen()
    local activescreen = TheFrontEnd:GetActiveScreen()

    if activescreen == nil then return end

    if activescreen.name ~= "ItemServerContactPopup" then
        --Hack for holding offset when transitioning from giftitempopup to wardrobepopup
        TheCamera:PopScreenHOffset(self)
        self:ClearRecentGifts()

        if self.wardrobepopup ~= nil then
            if self.wardrobepopup.inst:IsValid() then
                TheFrontEnd:PopScreen(self.wardrobepopup)
            end
            self.wardrobepopup = nil
        end
    else
        self.inst:DoTaskInTime(.2, function()
            self:CloseWardrobeScreen()
        end)
    end
end


function PlayerHud:OpenGroomerScreen(target,filter)
    --Hack for holding offset when transitioning from giftitempopup to groomerpopup
    TheCamera:PopScreenHOffset(self)

    if self.groomerpopup ~= nil and self.groomerpopup.inst:IsValid() then
        TheFrontEnd:PopScreen(self.groomerpopup)
    end

    assert(target, "No Target for skinning")
   -- assert(target.components.skinner_beefalo, "TARGET IS NOT SKINABLE BEEFALO")
    self.groomerpopup =
        GridGroomerPopupScreen(
            target,
            self.owner,
            Profile,
            nil,
            nil,
            filter
        )

    if not TheWorld.ismastersim then
        local map = TheFrontEnd:GetOpenScreenOfType("MapScreen")
        if map ~= nil and self.controls ~= nil then
            self.controls:HideMap()
        end
    end

    self:ClearRecentGifts()
    self:OpenScreenUnderPause(self.groomerpopup)
    return true
end

function PlayerHud:CloseGroomerScreen()
    local activescreen = TheFrontEnd:GetActiveScreen()

    if activescreen == nil then return end

    if activescreen.name ~= "ItemServerContactPopup" then
        --Hack for holding offset when transitioning from giftitempopup to groomerpopup
        TheCamera:PopScreenHOffset(self)
        self:ClearRecentGifts()

        if self.groomerpopup ~= nil then
            if self.groomerpopup.inst:IsValid() then
                TheFrontEnd:PopScreen(self.groomerpopup)
            end
            self.groomerpopup = nil
        end
    else
        self.inst:DoTaskInTime(.2, function()
            self:CloseGroomerScreen()
        end)
    end
end

function PlayerHud:OpenCookbookScreen()
    self:CloseCookbookScreen()
    self.cookbookscreen = CookbookPopupScreen(self.owner)
    self:OpenScreenUnderPause(self.cookbookscreen)
    return true
end

function PlayerHud:CloseCookbookScreen()
    if self.cookbookscreen ~= nil then
        if self.cookbookscreen.inst:IsValid() then
            TheFrontEnd:PopScreen(self.cookbookscreen)
		end
        self.cookbookscreen = nil
    end
end

function PlayerHud:OpenPlantRegistryScreen()
    self:ClosePlantRegistryScreen()
    self.plantregistryscreen = PlantRegistryPopupScreen(self.owner)
    self:OpenScreenUnderPause(self.plantregistryscreen)
    return true
end

function PlayerHud:ClosePlantRegistryScreen()
    if self.plantregistryscreen ~= nil then
        if self.plantregistryscreen.inst:IsValid() then
            TheFrontEnd:PopScreen(self.plantregistryscreen)
		end
        self.plantregistryscreen = nil
    end
end

function PlayerHud:OpenPlayerInfoScreen(player_name, data, show_net_profile, force)
    self:ClosePlayerInfoScreen()
    if data and data.inst ~= nil and data.inst:HasTag("dressable") then
        self.dressupAvatarPopUpcreen = self.controls.right_root:AddChild( DressupAvatarPopup(self.owner, player_name, data) )
        self.dressupAvatarPopUpcreen.started = false
        self.dressupAvatarPopUpcreen:Start()
    else
        self.playerinfoscreen = PlayerInfoPopupScreen(self.owner, player_name, data, show_net_profile, force)
        self:OpenScreenUnderPause(self.playerinfoscreen)
        return true
    end
end

function PlayerHud:ClosePlayerInfoScreen()
    if self.playerinfoscreen ~= nil then
        if self.playerinfoscreen.inst:IsValid() then
            TheFrontEnd:PopScreen(self.playerinfoscreen)
        end
        self.playerinfoscreen = nil
    end
end

function PlayerHud:OpenScrapbookScreen()
    self:CloseScrapbookScreen()
    self.scrapbookscreen = ScrapbookScreen(self.owner)
    self:OpenScreenUnderPause(self.scrapbookscreen)
    return true
end

function PlayerHud:CloseScrapbookScreen()
    if self.scrapbookscreen ~= nil then
        if self.scrapbookscreen.inst:IsValid() then
            TheFrontEnd:PopScreen(self.scrapbookscreen)
        end
        self.scrapbookscreen = nil
    end
end

function PlayerHud:OpenInspectaclesScreen()
    self:CloseInspectaclesScreen()
    self.inspectaclesscreen = InspectaclesScreen(self.owner)
    self:OpenScreenUnderPause(self.inspectaclesscreen)
    return true
end

function PlayerHud:CloseInspectaclesScreen()
    if self.inspectaclesscreen ~= nil then
        if self.inspectaclesscreen.inst:IsValid() then
            TheFrontEnd:PopScreen(self.inspectaclesscreen)
        end
        self.inspectaclesscreen = nil
    end
end

--Helper for transferring data between screens when transitioning from giftitempopup to wardrobepopup
function PlayerHud:SetRecentGifts(item_types, item_ids)
    if self.recentgiftstask ~= nil then
        self.recentgiftstask:Cancel()
        self.recentgiftstask = nil
    end
    self.recentgifts = { item_types = item_types, item_ids = item_ids }
end

--Helper for transferring data between screens when transitioning from giftitempopup to wardrobepopup
function PlayerHud:ClearRecentGifts()
    if self.recentgiftstask ~= nil then
        self.recentgiftstask:Cancel()
        self.recentgiftstask = nil
    end
    self.recentgifts = nil
end

function PlayerHud:RefreshControllers() -- this is really the event handler for "continuefrompause"
    local controller_mode = TheInput:ControllerAttached()
	if controller_mode then
	    TheFrontEnd:StopTrackingMouse()
	end

	TheFrontEnd:UpdateRepeatDelays()

	local integrated_backpack = controller_mode or Profile:GetIntegratedBackpack()
    if self.controls.inv.controller_build ~= controller_mode or self.controls.inv.integrated_backpack ~= integrated_backpack then
        self.controls.inv.rebuild_pending = true
        local overflow = self.owner.replica.inventory:GetOverflowContainer()
        if overflow == nil then
            --switching to controller inv with no backpack
            --don't animate out from the backpack position
            self.controls.inv.rebuild_snapping = true
        elseif controller_mode or integrated_backpack then
            --switching to controller with backpack
            --close mouse backpack container widget
            CloseContainerWidget(self, overflow.inst, overflow:IsSideWidget())
        elseif overflow:IsOpenedBy(self.owner) then
            --switching to mouse with backpack
            --reopen backpack if it was opened
            OpenContainerWidget(self, overflow.inst, overflow:IsSideWidget())
        end
    end

	self.controls.craftingmenu:RefreshControllers(controller_mode)

	if self._CraftingHintAllRecipesEnabled ~= Profile:GetCraftingHintAllRecipesEnabled() then
		self.owner:PushEvent("refreshcrafting")
		self._CraftingHintAllRecipesEnabled = Profile:GetCraftingHintAllRecipesEnabled()
	end

end

function PlayerHud:ShowWriteableWidget(writeable, config)
    if writeable == nil then
        return
    else
        self.writeablescreen = WriteableWidget(self.owner, writeable, config)
        self:OpenScreenUnderPause(self.writeablescreen)
        if TheFrontEnd:GetActiveScreen() == self.writeablescreen then
            -- Have to set editing AFTER pushscreen finishes.
            self.writeablescreen.edit_text:SetEditing(true)
        end
        return self.writeablescreen
    end
end

function PlayerHud:CloseWriteableWidget()
    if self.writeablescreen then
        self.writeablescreen:Close()
        self.writeablescreen = nil
    end
end

function PlayerHud:GoSane()
    self.vig:GetAnimState():PlayAnimation("basic", true)
end

function PlayerHud:GoInsane()
    self.vig:GetAnimState():PlayAnimation("insane", true)
end

function PlayerHud:GoEnlightened()
    self.vig:GetAnimState():PlayAnimation("basic", true)
end

function PlayerHud:SetMainCharacter(maincharacter)
    if maincharacter then
        maincharacter.HUD = self
        self.owner = maincharacter

		self._CraftingHintAllRecipesEnabled = Profile:GetCraftingHintAllRecipesEnabled() -- cache the value so we can refresh the crafting menu with it changes

        self:CreateOverlays(self.owner)
        self.controls = self.root:AddChild(Controls(self.owner))

        self.inst:ListenForEvent("gosane", function() self:GoSane() end, self.owner)
        self.inst:ListenForEvent("goinsane", function() self:GoInsane() end, self.owner)
        self.inst:ListenForEvent("goenlightened", function() self:GoEnlightened() end, self.owner)
		self.inst:ListenForEvent("newactiveitem", function(owner, data)
				if data ~= nil and data.item ~= nil then
					self:CloseSpellWheel()
				end
			end, self.owner)

        if self.owner.replica.sanity ~= nil then
            if self.owner.replica.sanity:IsCrazy() then
                self:GoInsane()
            elseif self.owner.replica.sanity:IsEnlightened() then
                self:GoEnlightened()
            end
        end

        local overflow = maincharacter.replica.inventory ~= nil and maincharacter.replica.inventory:GetOverflowContainer() or nil
        if overflow ~= nil then
            overflow:Close()
            overflow:Open(maincharacter)
        end

    end
end

function PlayerHud:OnUpdate(dt)
    if Profile ~= nil and self.vig ~= nil then
        if RENDER_QUALITY.LOW == Profile:GetRenderQuality() or TheConfig:IsEnabled("hide_vignette") then
            self.vig:Hide()
        else
            self.vig:Show()
        end
    end

    -- Indicate if history recording is active
    if CAN_USE_DBUI and self.controls ~= nil then
        if TheFrontEnd.debugMenu.history:IsEnabled() then
			if self.controls.historyrecordingindicator == nil then
				self.controls.historyrecordingindicator = self.controls:AddChild(Text(DEFAULTFONT, 64))
				self.controls.historyrecordingindicator:SetPosition(400, 180, 0)
				self.controls.historyrecordingindicator:SetString("*** History recording ON ***")
				self.controls.historyrecordingindicator:SetColour(UICOLOURS.RED)
				self.controls.historyrecordingindicator:SetHAnchor(ANCHOR_LEFT)
				self.controls.historyrecordingindicator:SetVAnchor(ANCHOR_BOTTOM)
			end
        elseif self.controls.historyrecordingindicator ~= nil then
            self.controls.historyrecordingindicator.inst.widget:Kill()
            self.controls.historyrecordingindicator = nil
        end
    end

    if CHEATS_ENABLED and self.owner ~= nil and self.controls ~= nil then
        -- Just an indicator so we can tell if we're in godmode or not
        if self.owner:HasTag("invincible") then
            if self.controls.godmodeindicator == nil then
                self.controls.godmodeindicator = self.controls.inv:AddChild(UIAnim())
                self.controls.godmodeindicator:GetAnimState():SetBank("pigman")
                self.controls.godmodeindicator:GetAnimState():SetBuild("pig_guard_build")
                self.controls.godmodeindicator:SetHAnchor(ANCHOR_LEFT)
                self.controls.godmodeindicator:SetVAnchor(ANCHOR_BOTTOM)
                self.controls.godmodeindicator:SetPosition(100, 50, 0)
                self.controls.godmodeindicator:SetScale(0.2, 0.2, 0.2)
                self.controls.godmodeindicator:GetAnimState():PlayAnimation("idle_happy")
                self.controls.godmodeindicator:GetAnimState():PushAnimation("idle_loop")
            end
        elseif self.controls.godmodeindicator ~= nil then
            self.controls.godmodeindicator:GetAnimState():PlayAnimation("death")
            self.controls.godmodeindicator.inst:DoTaskInTime(2, function(inst) inst.widget:Kill() end)
            self.controls.godmodeindicator = nil
        end
    end
    if self.leafcanopy then
        self.leafcanopy:OnUpdate(dt)
    end

	if self.owner ~= nil then
		local spellbook = self:GetCurrentOpenSpellBook()
		if spellbook ~= nil then
			if not spellbook:IsValid() or spellbook:HasTag("fueldepleted") then
				self:CloseSpellWheel()
			else
				local inventoryitem = spellbook.replica.inventoryitem
				if inventoryitem == nil or not inventoryitem:IsGrandOwner(self.owner) then
					self:CloseSpellWheel()
				end
			end
		end
	end
end

function PlayerHud:HideControllerCrafting()
    local pt = self.controls.craftingmenu:GetPosition()
    self.controls.craftingmenu:MoveTo(pt, Vector3(-200, pt.y, pt.z), .25)
end

function PlayerHud:ShowControllerCrafting()
    local pt = self.controls.craftingmenu:GetPosition()
    self.controls.craftingmenu:MoveTo(pt, Vector3(0, pt.y, pt.z), .25)
end

function PlayerHud:OpenControllerInventory()
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
    TheFrontEnd:StopTrackingMouse()

    self:CloseCrafting()
	self:CloseSpellWheel()

    self.controls.inv:OpenControllerInventory()
    self.controls.item_notification:ToggleController(true)
    self.controls.yotb_notification:ToggleController(true)
    self.controls.skilltree_notification:ToggleController(true)
    self.controls:ShowStatusNumbers()

    self.owner.components.playercontroller:OnUpdate(0)
end

function PlayerHud:CloseControllerInventory()
    if self:IsControllerInventoryOpen() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
    end
    self.controls:HideStatusNumbers()
    self.controls.inv:CloseControllerInventory()
    self.controls.item_notification:ToggleController(false)
    self.controls.yotb_notification:ToggleController(false)
    self.controls.skilltree_notification:ToggleController(false)
end

function PlayerHud:HasInputFocus()
    --We're checking that the active screen is NOT us, because HUD
    --is always active, and we're saying that it locks input focus
    --when anything else is active on top of it.
    local active_screen = TheFrontEnd:GetActiveScreen()
    return (active_screen ~= nil and active_screen ~= self)
		or TheFrontEnd.textProcessorWidget ~= nil
        or (self.controls ~= nil and (self.controls.inv.open or ((self:IsCraftingOpen() or self:IsSpellWheelOpen()) and TheInput:ControllerAttached())))
        or self.modfocus ~= nil
end

function PlayerHud:SetModFocus(modname, focusid, hasfocus)
    if hasfocus then
        if self.modfocus == nil then
            self.modfocus = { [modname] = { [focusid] = true } }
        elseif self.modfocus[modname] == nil then
            self.modfocus[modname] = { [focusid] = true }
        else
            self.modfocus[modname][focusid] = true
        end
    elseif self.modfocus ~= nil and self.modfocus[modname] ~= nil and self.modfocus[modname][focusid] then
        self.modfocus[modname][focusid] = nil
        if next(self.modfocus[modname]) == nil then
            self.modfocus[modname] = nil
            if next(self.modfocus) == nil then
                self.modfocus = nil
            end
        end
    end
end

function PlayerHud:IsControllerInventoryOpen()
    return self.controls ~= nil and self.controls.inv.open
end

function PlayerHud:IsControllerCraftingOpen() -- deprecated - please switch to using IsCraftingOpen() or playercontroller:IsEnabled()
    return self.controls ~= nil and self.controls.craftingmenu:IsCraftingOpen()
end

function PlayerHud:IsCraftingOpen()
    return self.controls ~= nil and self.controls.craftingmenu:IsCraftingOpen()
end

function PlayerHud:IsCraftingBlockingGameplay()
	-- deprecated
    return false
end

function PlayerHud:IsControllerVoteOpen()
    return self.controls ~= nil and self.controls.votedialog:IsControllerVoteOpen()
end

function PlayerHud:IsVoteOpen()
    return self.controls ~= nil and self.controls.votedialog:IsOpen()
end

function PlayerHud:IsPauseScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and active_screen.name == "PauseScreen"
end

function PlayerHud:IsChatInputScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and active_screen.name == "ChatInputScreen"
end

function PlayerHud:IsConsoleScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and active_screen.name == "ConsoleScreen"
end

function PlayerHud:IsMapScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and active_screen.name == "MapScreen"
end

function PlayerHud:IsStatusScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and active_screen.name == "PlayerStatusScreen"
end

function PlayerHud:IsItemManagerScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and active_screen.name == "GiftItemPopUp"
end

function PlayerHud:IsWardrobeScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and (active_screen.name == "WardrobePopupScreen" or active_screen.name == "GridScarecrowClothingPopupScreen")
end

function PlayerHud:IsGroomerScreenOpen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    return active_screen ~= nil and (active_screen.name == "GroomerPopupScreen")
end

function PlayerHud:IsPlayerAvatarPopUpOpen()
    return self.playeravatarpopup ~= nil
        and self.playeravatarpopup.started
        and self.playeravatarpopup.inst:IsValid()
end

function PlayerHud:IsPlayerInfoPopUpOpen()
    return self.PlayerInfoPopupScreen ~= nil
        and self.PlayerInfoPopupScreen.inst:IsValid()
end

function PlayerHud:OpenCrafting(search)
	if not self:IsCraftingOpen() and not GetGameModeProperty("no_crafting") then
		self:CloseSpellWheel()
		if self:IsControllerInventoryOpen() then
			self:CloseControllerInventory()
		end

		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
		self.controls.craftingmenu:Open(search)

		self.controls.item_notification:ToggleController(true)
		self.controls.yotb_notification:ToggleController(true)
        self.controls.skilltree_notification:ToggleController(true)
	end
end

function PlayerHud:CloseCrafting()
    if self:IsCraftingOpen() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
	    self.controls.craftingmenu:Close()

		self.controls.item_notification:ToggleController(false)
		self.controls.yotb_notification:ToggleController(false)
        self.controls.skilltree_notification:ToggleController(false)
    end
end

function PlayerHud:IsSpellWheelOpen()
	return self.controls.spellwheel:IsOpen()
end

function PlayerHud:GetCurrentOpenSpellBook()
	return self.controls.spellwheel.invobject
end

function PlayerHud:OpenSpellWheel(invobject, items, radius, focus_radius, bgdata)
	self:CloseCrafting()
	if self:IsControllerInventoryOpen() then
		self:CloseControllerInventory()
	end
	CloseAllChestContainerWidgets(self)
	local itemscpy = {}
	for i, v in ipairs(items) do
		itemscpy[i] = shallowcopy(v)
		if v.execute ~= nil then
			itemscpy[i].execute = function()
				invobject.components.spellbook:SelectSpell(i)
				v.execute(invobject)
			end
			itemscpy[i].onfocus = function()
				for j, v in ipairs(items) do
					v.selected = i == j or nil
				end
				if invobject.components.spellbook.focussound then
					TheFocalPoint.SoundEmitter:PlaySound(invobject.components.spellbook.focussound)
				end
			end
		end
	end
	self.controls.spellwheel:SetScale(TheFrontEnd:GetProportionalHUDScale()) --instead of GetHUDScale(), because parent already has SCALEMODE_PROPORTIONAL
	self.controls.spellwheel:SetItems(itemscpy, radius, focus_radius)
	self.controls.spellwheel:Open()

	if bgdata then
		local bg = self.controls.spellwheel:AddChild(UIAnim())
		bg:GetAnimState():SetBuild(bgdata.build)
		bg:GetAnimState():SetBank(bgdata.bank)
		bg:GetAnimState():PlayAnimation(bgdata.anim, bgdata.loop)
		if bgdata.widget_scale then
			bg:SetScale(bgdata.widget_scale)
		end
		bg:MoveToBack()
		self.controls.spellwheel.bg = bg
	end

	local old = self.controls.spellwheel.invobject
	self.controls.spellwheel.invobject = invobject
	if old ~= nil and old:IsValid() then
		old:PushEvent("closespellwheel")
	end
	invobject:PushEvent("openspellwheel")
	local sfx = invobject.components.spellbook ~= nil and invobject.components.spellbook.opensound or nil
	if sfx ~= nil then
		TheFocalPoint.SoundEmitter:PlaySound(sfx)
	end
end

function PlayerHud:CloseSpellWheel(is_execute)
	self.controls.spellwheel:Close()

	if self.controls.spellwheel.bg then
		self.controls.spellwheel.bg:Kill()
		self.controls.spellwheel.bg = nil
	end

	local old = self.controls.spellwheel.invobject
	if old ~= nil then
		self.controls.spellwheel.invobject = nil
		if old:IsValid() then
			old:PushEvent("closespellwheel")
		end
		if old.components.spellbook ~= nil then
			local sfx
			if is_execute then
				sfx = old.components.spellbook.executesound
			else
				sfx = old.components.spellbook.closesound
			end
			if sfx ~= nil then
				TheFocalPoint.SoundEmitter:PlaySound(sfx)
			end
		end
	end
end

function PlayerHud:ShowPlayerStatusScreen(click_to_close, onclosefn)
    if self.playerstatusscreen == nil then
        self.playerstatusscreen = PlayerStatusScreen(self.owner)
    end
	self.playerstatusscreen.onclosefn = onclosefn
	self.playerstatusscreen.click_to_close = click_to_close
    TheFrontEnd:PushScreen(self.playerstatusscreen)
    self.playerstatusscreen:MoveToFront()
    self.playerstatusscreen:Show()
end

function PlayerHud:InspectSelf()
    if self:IsVisible() and
        self.owner.components.playercontroller:IsEnabled() then
        local client_obj = TheNet:GetClientTableForUser(self.owner.userid)
        if client_obj ~= nil then
            --client_obj.inst = self.owner --don't track yourself
            self:TogglePlayerInfoPopup(client_obj.name, client_obj)
            return true
        end
    end
end

function PlayerHud:OnControl(control, down)
    if PlayerHud._base.OnControl(self, control, down) then
        return true
    elseif not self.shown then
		if self.serverpaused and down and control == CONTROL_SERVER_PAUSE then
			SetServerPaused(false)
			return true
		end
        return
    end

    if down then
        if control == CONTROL_INSPECT then
            if self:IsVisible() and
                self:IsPlayerInfoPopUpOpen() and
                self.owner.components.playercontroller:IsEnabled() then
                self:TogglePlayerInfoPopup()
                return true
            elseif self.controls.votedialog:CheckControl(control, down) then
                return true
            elseif self.owner.components.playercontroller:GetControllerTarget() == nil
                and self:InspectSelf() then
                return true
            end
        elseif control == CONTROL_INSPECT_SELF and self:InspectSelf() then
            return true
        end
    elseif control == CONTROL_PAUSE then
		if TheInput:ControllerAttached() then
            self.owner.components.playercontroller:CancelAOETargeting()
            self:CloseCrafting()
			self:CloseSpellWheel()
            if self:IsControllerInventoryOpen() then
                self:CloseControllerInventory()
            end
            TheFrontEnd:PushScreen(PauseScreen())
		else
			local closed = false
			if self.owner.components.playercontroller:IsAOETargeting() then
	            self.owner.components.playercontroller:CancelAOETargeting()
				closed = true
			end
            if self:IsCraftingOpen() then
                self:CloseCrafting()
                closed = true
            end
			if self:IsSpellWheelOpen() then
				self:CloseSpellWheel()
				closed = true
			end
			if self:IsPlayerInfoPopUpOpen() and
                self:TogglePlayerInfoPopup() then
                closed = true
			end
			if not closed then
	            TheFrontEnd:PushScreen(PauseScreen())
			end
		end
        return true
	elseif control == CONTROL_CRAFTING_PINLEFT then
		if self.controls ~= nil and self.controls.craftingmenu ~= nil and self.controls.craftingmenu.pinbar ~= nil then
			self.controls.craftingmenu.pinbar:GoToPrevPage()
			return true
		end
	elseif control == CONTROL_CRAFTING_PINRIGHT then
		if self.controls ~= nil and self.controls.craftingmenu ~= nil and self.controls.craftingmenu.pinbar ~= nil then
			self.controls.craftingmenu.pinbar:GoToNextPage()
			return true
		end
    elseif control == CONTROL_SERVER_PAUSE then
        SetServerPaused()
        return true
    end

    --V2C: This kinda hax? Cuz we don't rly want to set focus to it I guess?
    local resurrectbutton = self.controls.status:GetResurrectButton()
    if resurrectbutton ~= nil and resurrectbutton:CheckControl(control, down) then
        return true
    elseif self.controls.item_notification:CheckControl(control, down) then
        return true
    elseif self.controls.skilltree_notification:CheckControl(control, down) then
        return true        
    elseif not down then
        if control == CONTROL_MAP then
            if not self:IsMapScreenOpen() then
				self:CloseCrafting()
				self:CloseSpellWheel()
                if self:IsControllerInventoryOpen() then
                    self:CloseControllerInventory()
                end
            end
            self.controls:ToggleMap()
            return true
        elseif control == CONTROL_CANCEL and TheInput:ControllerAttached() then
            if self:IsCraftingOpen() then
                self:CloseCrafting()
                return true
			elseif self:IsSpellWheelOpen() then
				self:CloseSpellWheel()
				return true
            elseif self:IsControllerInventoryOpen() then
                self:CloseControllerInventory()
                return true
            end
        elseif control == CONTROL_TOGGLE_PLAYER_STATUS then
            self:ShowPlayerStatusScreen(true)
            return true
		elseif control == CONTROL_TOGGLE_SAY then
			TheFrontEnd:PushScreen(ChatInputScreen(false))
			return true
		elseif control == CONTROL_TOGGLE_WHISPER then
			TheFrontEnd:PushScreen(ChatInputScreen(true))
			return true
		elseif control == CONTROL_TOGGLE_SLASH_COMMAND then
			local chat_input_screen = ChatInputScreen(false)
			chat_input_screen.chat_edit:SetString("/")
			TheFrontEnd:PushScreen(chat_input_screen)
			return true
		elseif control == CONTROL_START_EMOJI then
			local chat_input_screen = ChatInputScreen(false)
			chat_input_screen.chat_edit:SetString(":")
			TheFrontEnd:PushScreen(chat_input_screen)
			return true
        end
    elseif control == CONTROL_SHOW_PLAYER_STATUS then
        if not self:IsPlayerAvatarPopUpOpen() or self.playeravatarpopup.settled then
            self:ShowPlayerStatusScreen()
        end
        return true
    elseif control == CONTROL_OPEN_CRAFTING then
        if self:IsCraftingOpen() then
			if TheInput:IsControlPressed(CONTROL_CRAFTING_MODIFIER) then
				self.controls.craftingmenu.craftingmenu:StartSearching(true)
			else
	            self:CloseCrafting()
			end
            return true
        elseif not GetGameModeProperty("no_crafting") then
            local inventory = self.owner.replica.inventory
            if inventory ~= nil and inventory:IsVisible() then
                self:OpenCrafting(TheInput:IsControlPressed(CONTROL_CRAFTING_MODIFIER))
                return true
            end
        end
    elseif control == CONTROL_OPEN_INVENTORY then
        if self:IsControllerInventoryOpen() then
            self:CloseControllerInventory()
            return true
        end
        local inventory = self.owner.replica.inventory
        if inventory ~= nil and inventory:IsVisible() and inventory:GetNumSlots() > 0 then
            self:OpenControllerInventory()
            return true
        end
    elseif control >= CONTROL_INV_1 and control <= CONTROL_INV_10 then
        --inventory hotkeys
        local inventory = self.owner.replica.inventory
        if inventory ~= nil and inventory:IsVisible() then
			local hot_key_num = control - CONTROL_INV_1 + 1

			if TheInput:IsControlPressed(CONTROL_CRAFTING_MODIFIER) then
				self.controls.craftingmenu:SelectPin(hot_key_num)
			else
				local item = inventory:GetItemInSlot(hot_key_num)
				if item ~= nil then
					self.owner.replica.inventory:UseItemFromInvTile(item)
				end
			end
            return true
        end
    elseif control >= CONTROL_INV_11 and control <= CONTROL_INV_15 then
        -- Inventory hotkeys part two.
        local inventory = self.owner.replica.inventory
        if inventory ~= nil and inventory:IsVisible() then
			local hot_key_num = control - CONTROL_INV_11 + 11

            -- No crafting menu pins!
			local item = inventory:GetItemInSlot(hot_key_num)
            if item ~= nil then
                self.owner.replica.inventory:UseItemFromInvTile(item)
            end
            return true
        end
    end
end

function PlayerHud:OnRawKey(key, down)
    if PlayerHud._base.OnRawKey(self, key, down) then
        return true
    end
    -- NOTES(JBK): Add controls to the files below to allow players to edit bound keys do not use OnRawKey for forced binds unless in dev only.
    -- strings.lua, constants.lua, playerhud.lua, optionsscreen.lua, DontStarveInputHandler.h, DontStarveInputHandler.cpp, InputDefinitions.h
    -- I am leaving this function stub here for dev testing only and maybe a mod already hooked it.
end

local DROPS_ALPHA_INCREASE_RATE = 0.01
local DROPS_ALPHA_DECREASE_RATE = 0.05
function PlayerHud:UpdateDrops(camera)

    if self.dropsplash  then
        if self.drops_alpha >= 1 then
            return
        end

        if self.drops_alpha <= 0 then
            self.drops_vig:Show()
            self.drops_alpha = DROPS_ALPHA_INCREASE_RATE
        elseif self.drops_alpha < 1 then
            self.drops_alpha = self.drops_alpha + DROPS_ALPHA_INCREASE_RATE
        end

        self.drops_vig.inst.AnimState:SetMultColour(1, 1, 1, self.drops_alpha)
    elseif self.drops_alpha > 0 then
        if self.drops_alpha > 0 then
            self.drops_alpha = self.drops_alpha - DROPS_ALPHA_DECREASE_RATE
            self.drops_vig.inst.AnimState:SetMultColour(1, 1, 1, self.drops_alpha)
        end

        if self.drops_alpha <= 0 then
            self.drops_alpha = 0
            self.drops_vig:Hide()
        end
    end
end

function PlayerHud:UpdateClouds(camera)
    --this is kind of a weird place to do all of this, but the anim *is* a hud asset...
    if camera.distance and not camera.dollyzoom then
        local dist_percent = (camera.distance - camera.mindist) / (camera.maxdist - camera.mindist)
        local cutoff = TUNING.HUD_CLOUD_CUTOFF
        if dist_percent > cutoff then
            if not self.clouds_on then
                camera.should_push_down = true
                self.clouds_on = true
                self.clouds:Show()
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/clouds", "windsound")
                TheMixer:PushMix("high")
            end
            local p = easing.outCubic(dist_percent - cutoff, 0, .5, 1 - cutoff)
            self.clouds:GetAnimState():SetMultColour(self.clouds.cloudcolour[1], self.clouds.cloudcolour[2], self.clouds.cloudcolour[3], p)
            TheFocalPoint.SoundEmitter:SetVolume("windsound", p)
        elseif self.clouds_on then
            camera.should_push_down = false
            self.clouds_on = false
            self.clouds:Hide()
            TheFocalPoint.SoundEmitter:KillSound("windsound")
            TheMixer:PopMix("high")
        end
    end
end

function PlayerHud:AddTargetIndicator(target, data)
    if not self.targetindicators then
        self.targetindicators = {}
    end

    local ti = self.under_root:AddChild(TargetIndicator(self.owner, target, data))
    table.insert(self.targetindicators, ti)
end

function PlayerHud:HasTargetIndicator(target)
    if not self.targetindicators then return end

    for i,v in pairs(self.targetindicators) do
        if v and v:GetTarget() == target then
            return true
        end
    end
    return false
end

function PlayerHud:RemoveTargetIndicator(target)
    if not self.targetindicators then return end

    local index = nil
    for i,v in pairs(self.targetindicators) do
        if v and v:GetTarget() == target then
            index = i
            break
        end
    end
    if index then
        local ti = table.remove(self.targetindicators, index)
        if ti then ti:Kill() end
    end
end

function PlayerHud:ShowPopupNumber(val, size, pos, height, colour, burst)
    self.popupstats_root:AddChild(PopupNumber(self.owner, val, size, pos, height, colour, burst))
end

function PlayerHud:ShowRingMeter(pos, duration, starttime)
    if self.ringmeter == nil then
        self.ringmeter = self.popupstats_root:AddChild(RingMeter(self.owner))
    end
    self.ringmeter:SetWorldPosition(pos)
    self.ringmeter:StartTimer(duration, starttime)
end

function PlayerHud:HideRingMeter(success, duration)
    if self.ringmeter ~= nil then
        if success then
            self.ringmeter:FlashOut(duration)
        else
            self.ringmeter:FadeOut(duration)
        end
        self.ringmeter = nil
    end
end

function PlayerHud:SetServerPaused(paused)
    if paused and not Profile:GetHidePauseUnderlay() then
        self.serverpause_underlay:Show()
    else
        self.serverpause_underlay:Hide()
    end
	self.serverpaused = paused
end

function PlayerHud:OffsetServerPausedWidget(serverpausewidget)
    if self.eventannouncer then
        serverpausewidget:SetOffset(self.eventannouncer:GetPosition():Get())
    end
end

return PlayerHud
