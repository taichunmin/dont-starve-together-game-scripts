


-- Note:
-- This file is only here to reduce merge conflicts between PC and console builds, sorry! 

-- see splitscreenutils.lua for more functions

if IsConsole() then
	return
end

Instances = {
	Player1 		= 0,
	Player2 		= 1,
	Server 			= 2,
	CaveServer 		= 3,
	Overlay 		= 4,
}

function IsGameInstance( instance_id )
	return instance_id == Instances.Player1
end

function IsSplitScreen()
	return false
end

function HaveMultipleViewports()
	return false
end