--------------------------------------------------------------------------
--[[ TownPortalRegistry class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "TownPortalRegistry should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _townportals = {}
local _activetownportal = nil


--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------
local function OnTownPortalActivated(inst, townportal)
	if _activetownportal == nil then
		_activetownportal = townportal
		for i, v in ipairs(_townportals) do
			if v ~= townportal then
				v:PushEvent("linktownportals", townportal)
			end
		end
	end
end

local function OnTownPortalDeactivated(inst, portal)
	if _activetownportal ~= nil then
		_activetownportal = nil
		for i, v in ipairs(_townportals) do
			v:PushEvent("linktownportals")
		end
	end
end

local function OnRemoveTownPortal(townportal)
    for i, v in ipairs(_townportals) do
        if v == townportal then
            table.remove(_townportals, i)
            inst:RemoveEventCallback("onremove", OnRemoveTownPortal, townportal)
            break
        end
    end

    if townportal == _activetownportal then
	    OnTownPortalDeactivated()
	end
end

local function OnRegisterTownPortal(inst, townportal)
    for i, v in ipairs(_townportals) do
        if v == townportal then
            return
        end
    end

    table.insert(_townportals, townportal)
    inst:ListenForEvent("onremove", OnRemoveTownPortal, townportal)
    if _activetownportal ~= nil then
	    townportal:PushEvent("linktownportals", _activetownportal)
	end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("ms_registertownportal", OnRegisterTownPortal)
inst:ListenForEvent("townportalactivated", OnTownPortalActivated)
inst:ListenForEvent("townportaldeactivated", OnTownPortalDeactivated)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

local function IsATownPortalActive()
	return _activetownportal ~= nil
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
	local s = "Town Portals: " .. tostring(#_townportals)
	if _activetownportal ~= nil then
		s = s .. ", Town Portal Activated!"
	end
	return s
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
