local function oncanbesearched(self)
    self.inst:AddOrRemoveTag("searchable", self.canbesearched and self.caninteractwith)
end

local function onquicksearch(self, quicksearch)
    self.inst:AddOrRemoveTag("quicksearch", quicksearch)
end

local function onjostlesearch(self, jostlesearch)
    self.inst:AddOrRemoveTag("jostlesearch", jostlesearch)
end

---------------------------------------------
-- SAM:
-- A component with a very pared down version of pickable behaviour
-- (just the interaction, without any of the automated cycles/growing stuff)
-- Could be updated to have a generic product + search count setup;
-- for now it's just a passthrough to an "on search" function.
local Searchable = Class(function(self, inst)
    self.inst = inst

    self.caninteractwith = true
    self.remove_when_searched = false
    self.quicksearch = false
    self.jostlesearch = false

    self.canbesearched = nil
    self.onsearchfn = nil
end,
nil,
{
    canbesearched = oncanbesearched,
    caninteractwith = oncanbesearched,
    quicksearch = onquicksearch,
    jostlesearch = onjostlesearch,
})

function Searchable:OnRemoveEntity()
    self.inst:RemoveTag("searchable")
    self.inst:RemoveTag("quicksearch")
    self.inst:RemoveTag("jostlesearch")
end

function Searchable:Search(searcher)
    if not (self.canbesearched and self.caninteractwith) then
        return false
    end

    local search_result, result_reason = true, nil
    if self.onsearchfn then
        search_result, result_reason = self.onsearchfn(self.inst, searcher)
    end

    if search_result then
        self.inst:PushEvent("searched", searcher)

        if self.remove_when_searched then
            self.inst:Remove()
        end
    end

    return search_result, result_reason
end

-- Save/Load
function Searchable:OnSave()
    return (self.caninteractwith and {caninteractwith = true})
        or nil
end

function Searchable:OnLoad(data)
    if data.caninteractwith then
        self.caninteractwith = data.caninteractwith
    end
end

-- Debug string
function Searchable:GetDebugString()
    local debug_string = ""

    if self.caninteractwith then
        debug_string = debug_string.."can interact with; "
    end
    if self.canbesearched then
        debug_string = debug_string.."can be searched;"
    end

    return debug_string
end

--
return Searchable