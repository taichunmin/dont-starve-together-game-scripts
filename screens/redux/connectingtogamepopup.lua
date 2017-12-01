local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"

local ConnectingToGamePopup = Class(GenericWaitingPopup, function(self)
    GenericWaitingPopup._ctor(self, "ConnectingToGamePopup", STRINGS.UI.NOTIFICATION.CONNECTING)
end)

function ConnectingToGamePopup:OnCancel()
    -- Ignore base implementation and do it all ourself.
    self:Disable()

    -- V2C: what was the following comment for??
    -- "This might be problematic for when in-game?"
    -- V2C: Oh i see. =) this comment must have been
    --      for shard migration.
    TheNet:JoinServerResponse(true) -- cancel join
    TheNet:Disconnect(false)
    TheFrontEnd:PopScreen()

    TheSystemService:StopDedicatedServers() -- just in case, we need to closes the server if the player cancel the connection

    if IsMigrating() then
        -- Still does not handle in-game, but
        -- this one's for canceling migration
        DoRestart(false)
    end
end

return ConnectingToGamePopup
