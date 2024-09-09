local TIMES_PLAYED_FOR_MAX_WEIGHT = 100

local LoadingTipsData = Class(function(self)
    self.shownloadingtips = {}
    self.dirty = false

    self.loadingtipweights = self:CalculateLoadingTipWeights()
    self.categoryweights = self:CalculateCategoryWeights()
end)

function LoadingTipsData:Reset()
    self.loadingtipweights = {}
    self.shownloadingtips = {}
    self.dirty = true
    self:Save()
end

function LoadingTipsData:Save()
    if not self.dirty then
        return
    end

    local str = json.encode({shownloadingtips = self.shownloadingtips})
    TheSim:SetPersistentString("loadingtips", str, false)
    self.dirty = false
end

function LoadingTipsData:Load()
    self.shownloadingtips = {}
	TheSim:GetPersistentString("loadingtips", function(load_success, data)
		if load_success and data ~= nil then
			local status, decoded_data = pcall( function() return json.decode(data) end )
		    if status and decoded_data then
				self.shownloadingtips = decoded_data.shownloadingtips or {}
                self:CleanupShownLoadingTips()
			else
				print("Failed to load the loading tips!", status, decoded_data)
			end
		end
	end)
end

function LoadingTipsData:CleanupShownLoadingTips()
    -- Check if tip key still exists. If not, remove it from the list
    for key, value in pairs(self.shownloadingtips) do
        if STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS[key] == nil and
            STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_CONSOLE[key] == nil and
            STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_NOT_CONSOLE[key] == nil and
            STRINGS.UI.LOADING_SCREEN_SURVIVAL_TIPS[key] == nil and
            STRINGS.UI.LOADING_SCREEN_LORE_TIPS[key] == nil and
            STRINGS.UI.LOADING_SCREEN_OTHER_TIPS[key] == nil then
                self.shownloadingtips[key] = nil
        end
    end
end

function LoadingTipsData:CalculateCategoryWeights()
    -- Calculate category selection weights based on times played
    local timesplayed =  Profile:GetValue("play_instance")
    local ratio = math.min(timesplayed / TIMES_PLAYED_FOR_MAX_WEIGHT, TIMES_PLAYED_FOR_MAX_WEIGHT)
    local categoryweights = {}
    for k, weight in pairs(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START) do
        local maxweight = LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END[k]
        local progressweight = 0
        if maxweight ~= nil then
            progressweight = (maxweight - weight) / TIMES_PLAYED_FOR_MAX_WEIGHT
        end
        categoryweights[k] = LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START[k] + progressweight
    end
    return categoryweights
end

function LoadingTipsData:CalculateLoadingTipWeights()
    local loadingtipweights = {}

    -- Controls tips, based on platform
    local controltipweights = {}
    local generalcontroltips = self:GenerateLoadingTipWeights(STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS)
    controltipweights = MergeMaps(controltipweights, generalcontroltips)

    -- Add console or non-console tips
    if IsConsole() then
        local consolecontroltips = self:GenerateLoadingTipWeights(STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_CONSOLE)
        controltipweights = MergeMaps(controltipweights, consolecontroltips)
    else
        local notconsolecontroltips = self:GenerateLoadingTipWeights(STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_NOT_CONSOLE)
        controltipweights = MergeMaps(controltipweights, notconsolecontroltips)
    end

    -- Survival tips
    local survivaltipweights = self:GenerateLoadingTipWeights(STRINGS.UI.LOADING_SCREEN_SURVIVAL_TIPS)

    -- Lore tips
    local loretipweights = self:GenerateLoadingTipWeights(STRINGS.UI.LOADING_SCREEN_LORE_TIPS)

    -- Other tips
    local othertipweights = self:GenerateLoadingTipWeights(STRINGS.UI.LOADING_SCREEN_OTHER_TIPS)

    -- Loading screen-dependant tip will be generated when needed
    loadingtipweights[LOADING_SCREEN_TIP_CATEGORIES.CONTROLS] = controltipweights
    loadingtipweights[LOADING_SCREEN_TIP_CATEGORIES.SURVIVAL] = survivaltipweights
    loadingtipweights[LOADING_SCREEN_TIP_CATEGORIES.LORE] = loretipweights
    loadingtipweights[LOADING_SCREEN_TIP_CATEGORIES.OTHER] = othertipweights

    return loadingtipweights
end

function LoadingTipsData:GenerateLoadingTipWeights(stringlist)
    -- Generate tips list with weights based on the amount of times shown
    local tipweights = {}
    for key, value in pairs(stringlist) do
        local existingweight = self.shownloadingtips[key] ~= nil and self.shownloadingtips[key] or 0
        tipweights[key] = 1 / (existingweight + 1) -- The more times a tip is shown, the lower the chance of it getting selected
    end

    return tipweights
end

function LoadingTipsData:IsControlTipBound(controllerid, tipid)
    for key, control in pairs(LOADING_SCREEN_CONTROL_TIP_KEYS[tipid]) do
        local controltocheck = TheInput:ControllerAttached() and LOADING_SCREEN_CONTROLLER_ID_LOOKUP[control] or control
        local controlstring = TheInput:GetLocalizedControl(controllerid, controltocheck)

        -- Check for no control bind
        if controlstring == STRINGS.UI.CONTROLSSCREEN.INPUTS[9][2] then
            return false
        end
    end

    return true
end

function LoadingTipsData:GenerateControlTipText(tipid)
    local tipstring =
    STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS[tipid] ~= nil and STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS[tipid] or
    STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_CONSOLE[tipid] ~= nil and STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_CONSOLE[tipid] or
    STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_NOT_CONSOLE[tipid] ~= nil and STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_NOT_CONSOLE[tipid] or
    STRINGS.UI.LOADING_SCREEN_OTHER_TIPS[tipid] ~= nil and STRINGS.UI.LOADING_SCREEN_OTHER_TIPS[tipid]

    -- Tip has no control mappings; return the text as-is
    if LOADING_SCREEN_CONTROL_TIP_KEYS[tipid] == nil then
        return tipstring
    end

    -- Generate controls-related tips based on platform, control bindings
    local controlslist = {}
    local controllerid = TheInput:GetControllerID()

    -- If the control tip buttons aren't bound to anything, try to fallback to keyboard bindings.
    -- If that still fails, return generic binding controls tip
    if not IsConsole() and not self:IsControlTipBound(controllerid, tipid) then
        if controllerid ~= 0 and self:IsControlTipBound(0, tipid) then
            controllerid = 0
        else
            return STRINGS.UI.LOADING_SCREEN_CONTROL_TIPS_NOT_CONSOLE.TIP_BIND_CONTROLS
        end
    end

    for key, control in pairs(LOADING_SCREEN_CONTROL_TIP_KEYS[tipid]) do
        local controltocheck = TheInput:ControllerAttached() and LOADING_SCREEN_CONTROLLER_ID_LOOKUP[control] or control
        local controlstring = TheInput:GetLocalizedControl(controllerid, controltocheck)
        controlslist[key] = controlstring
    end
    tipstring = subfmt(tipstring, controlslist)

    return tipstring
end

function LoadingTipsData:PickLoadingTip(loadingscreen)

    local loadingtipsoption = Profile:GetLoadingTipsOption()
    if loadingtipsoption == LOADING_SCREEN_TIP_OPTIONS.NONE then
        return
    end

    -- Choose a tip category based on available categories & weighted random selection
    local availablecategories = deepcopy(self.categoryweights)

    if loadingtipsoption == LOADING_SCREEN_TIP_OPTIONS.LORE_ONLY then
        availablecategories.CONTROLS = nil
        availablecategories.SURVIVAL = nil
    elseif loadingtipsoption == LOADING_SCREEN_TIP_OPTIONS.TIPS_ONLY then
        availablecategories.LORE = nil
        availablecategories.LOADING_SCREEN = nil
    end

    -- If the loading screen does not have a tip associated with it, remove it from the available categories
    if STRINGS.SKIN_DESCRIPTIONS[loadingscreen] == nil then
        availablecategories.LOADING_SCREEN = nil
    end

    -- If a category has no tips, make it unavailable for selection
    for category, value in pairs(LOADING_SCREEN_TIP_CATEGORIES) do
        if value ~= LOADING_SCREEN_TIP_CATEGORIES.LOADING_SCREEN and GetTableSize(self.loadingtipweights[value]) == 0 then
            availablecategories[category] = nil;
        end
    end

    local selectedcategory = weighted_random_choice(availablecategories)

    local selectedtipkey = LOADING_SCREEN_TIP_CATEGORIES[selectedcategory] ~= LOADING_SCREEN_TIP_CATEGORIES.LOADING_SCREEN and
                            weighted_random_choice(self.loadingtipweights[LOADING_SCREEN_TIP_CATEGORIES[selectedcategory]] or {}) or
                            loadingscreen

    -- To handle the case where there are no tips at all
    if selectedtipkey == nil then
        return nil
    end

    -- Generate tip data based on the selected tip
    local tipdata = {}
    tipdata.id = selectedtipkey
    tipdata.atlas = LOADING_SCREEN_TIP_ICONS[selectedcategory].atlas
    tipdata.icon = LOADING_SCREEN_TIP_ICONS[selectedcategory].icon

    if LOADING_SCREEN_TIP_CATEGORIES[selectedcategory] == LOADING_SCREEN_TIP_CATEGORIES.CONTROLS then
        tipdata.text = self:GenerateControlTipText(selectedtipkey)
    elseif LOADING_SCREEN_TIP_CATEGORIES[selectedcategory] == LOADING_SCREEN_TIP_CATEGORIES.SURVIVAL then
        tipdata.text = STRINGS.UI.LOADING_SCREEN_SURVIVAL_TIPS[selectedtipkey]
    elseif LOADING_SCREEN_TIP_CATEGORIES[selectedcategory] == LOADING_SCREEN_TIP_CATEGORIES.LORE then
        tipdata.text = STRINGS.UI.LOADING_SCREEN_LORE_TIPS[selectedtipkey]
    elseif LOADING_SCREEN_TIP_CATEGORIES[selectedcategory] == LOADING_SCREEN_TIP_CATEGORIES.LOADING_SCREEN then
        tipdata.text = STRINGS.SKIN_DESCRIPTIONS[selectedtipkey]
    elseif LOADING_SCREEN_TIP_CATEGORIES[selectedcategory] == LOADING_SCREEN_TIP_CATEGORIES.OTHER then
        tipdata.text = self:GenerateControlTipText(selectedtipkey)
    end

    return tipdata
end

function LoadingTipsData:RegisterShownLoadingTip(tip)

    -- Increment the number of times a tip was shown, or add it to the list of shown tips
    if self.shownloadingtips[tip.id] ~= nil then
        self.shownloadingtips[tip.id] = self.shownloadingtips[tip.id] + 1
    else
        self.shownloadingtips[tip.id] = 1
    end

    self.dirty = true
    self:Save()
end

return LoadingTipsData