--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Nutrients_Visual_Manager class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

    assert(not TheNet:IsDedicated(), "Nutrients_Visual_Manager should not exist on dedicated servers")

    --------------------------------------------------------------------------
    --[[ Public Member Variables ]]
    --------------------------------------------------------------------------

    self.inst = inst

    --------------------------------------------------------------------------
    --[[ Private Member Variables ]]
    --------------------------------------------------------------------------

    local _world = TheWorld
    local nutrients_visuals = {}
    local nutrients_vision = false

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function ToggleNutrientsVision(player, data)
        if nutrients_vision ~= data.enabled then
            nutrients_vision = data.enabled
            for visual in pairs(nutrients_visuals) do
                self:UpdateVisualAnimState(visual)
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:UpdateVisualAnimState(visual)
        if not nutrients_vision then
            visual.AnimState:SetMultColour(0, 0, 0, 1)
            visual.AnimState:SetAddColour(40/255, 20/255, 20/255, 0)
            visual.AnimState:SetLayer(LAYER_GROUND)
            visual.AnimState:SetSortOrder(1)
        else
            visual.AnimState:SetMultColour(1, 1, 1, 1)
            visual.AnimState:SetAddColour(0, 0, 0, 0)
            visual.AnimState:SetLayer(LAYER_BACKGROUND)
            visual.AnimState:SetSortOrder(1)
        end
    end

    function self:RegisterNutrientsVisual(visual)
        nutrients_visuals[visual] = true
    end

    function self:UnregisterNutrientsVisual(visual)
        nutrients_visuals[visual] = nil
    end

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    function self:GetDebugString()
        local s = ""
        return s
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    self.inst:ListenForEvent("nutrientsvision", ToggleNutrientsVision)

    end)
