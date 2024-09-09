PopupManagerWidget = Class(function(self, data)
    data = data or {}

    self.validaterpcfn = function() return true end
    self.fn = function() end
end)

function PopupManagerWidget:Close(inst, ...)
    if TheWorld ~= nil then -- NOTES(JBK): This is here for running debug panels at the main menu.
        if not TheWorld.ismastersim then
            SendRPCToServer(RPC.ClosePopup, self.code, self.mod_name, ...)
        else
            inst:PushEvent("ms_closepopup", {popup = self, args = {...}})
        end
    end
end

function PopupManagerWidget:__tostring()
    return string.format("%s (%d)", self.id, self.code)
end

POPUPS = {
    GIFTITEM = PopupManagerWidget(),
    WARDROBE = PopupManagerWidget(),
    GROOMER = PopupManagerWidget(),
    COOKBOOK = PopupManagerWidget(),
    PLANTREGISTRY = PopupManagerWidget(),
    SKILLTREE = PopupManagerWidget(),
    PLAYERINFO = PopupManagerWidget(),
    SCRAPBOOK = PopupManagerWidget(),
    INSPECTACLES = PopupManagerWidget(),
}

POPUPS_BY_POPUP_CODE = {}

POPUP_IDS = {}
for k, v in orderedPairs(POPUPS) do
    v.id = k
    table.insert(POPUP_IDS, k)
    v.code = #POPUP_IDS
    POPUPS_BY_POPUP_CODE[v.code] = v
end

MOD_POPUPS_BY_POPUP_CODE = {}
MOD_POPUP_IDS = {} --This will be filled in when mods add POPUPS via AddPopup in modutil.lua

function GetPopupFromPopupCode(popupcode, mod_name)
    if mod_name then
        return MOD_POPUPS_BY_POPUP_CODE[mod_name] and MOD_POPUPS_BY_POPUP_CODE[mod_name][popupcode]
    else
        return POPUPS_BY_POPUP_CODE[popupcode]
    end
end

function GetPopupIDFromPopupCode(popupcode, mod_name)
    if mod_name then
        return MOD_POPUP_IDS[mod_name] and MOD_POPUP_IDS[mod_name][popupcode]
    else
        return POPUP_IDS[popupcode]
    end
end

POPUPS.GIFTITEM.validaterpcfn = function(usewardrobe)
    return optbool(usewardrobe)
end

POPUPS.GIFTITEM.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseItemManagerScreen()
        elseif not inst.HUD:OpenItemManagerScreen() then
            POPUPS.GIFTITEM:Close(inst)
        end
    end
end

POPUPS.WARDROBE.validaterpcfn = function(base_skin, body_skin, hand_skin, legs_skin, feet_skin)
    return optstring(base_skin) and optstring(body_skin) and optstring(hand_skin) and optstring(legs_skin) and optstring(feet_skin)
end

POPUPS.WARDROBE.fn = function(inst, show, target)
    if inst.HUD then
        if not show then
            inst.HUD:CloseWardrobeScreen()
        elseif not inst.HUD:OpenWardrobeScreen(target) then
            POPUPS.WARDROBE:Close(inst)
        end
    end
end

POPUPS.GROOMER.validaterpcfn = function(beef_body_skin, beef_horn_skin, beef_head_skin, beef_feet_skin, beef_tail_skin, cancel)
    return optstring(beef_body_skin) and optstring(beef_horn_skin) and optstring(beef_head_skin) and optstring(beef_feet_skin) and optstring(beef_tail_skin) and optbool(cancel)
end

POPUPS.GROOMER.fn = function(inst, show, target, filter)
    if inst.HUD then
        if not show then
            inst.HUD:CloseGroomerScreen()
        elseif not inst.HUD:OpenGroomerScreen(target, filter) then
            POPUPS.GROOMER:Close(inst)
        end
    end
end

POPUPS.COOKBOOK.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseCookbookScreen()
        elseif not inst.HUD:OpenCookbookScreen() then
            POPUPS.COOKBOOK:Close(inst)
        end
    end
end

POPUPS.PLANTREGISTRY.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:ClosePlantRegistryScreen()
        elseif not inst.HUD:OpenPlantRegistryScreen() then
            POPUPS.PLANTREGISTRY:Close(inst)
        end
    end
end

POPUPS.PLAYERINFO.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:ClosePlayerInfoScreen()
        elseif not inst.HUD:OpenPlayerInfoScreen() then
            POPUPS.PLAYERINFO:Close(inst)
        end
    end
end

POPUPS.SCRAPBOOK.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseScrapbookScreen()
        elseif not inst.HUD:OpenScrapbookScreen() then
            POPUPS.SCRAPBOOK:Close(inst)
        end
    end
end

POPUPS.INSPECTACLES.validaterpcfn = function(solution)
    return optuint(solution)
end

POPUPS.INSPECTACLES.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseInspectaclesScreen()
        elseif not inst.HUD:OpenInspectaclesScreen() then
            POPUPS.INSPECTACLES:Close(inst)
        end
    end
end
