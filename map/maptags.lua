
local function MakeTags()
	local map_data =
		{
			["Chester_Eyebone"] = true,
			["Hutch_Fishbowl"] = true,
			["StagehandGarden"] = true,
			["SandstormOasis"] = true,
		}
		
	local map_tags = 
		{
			["Maze"] = function(tagdata)
								return "GLOBALTAG", "Maze"
							end,
			["MazeEntrance"] = function(tagdata)
								return "GLOBALTAG", "MazeEntrance"
							end,
			["Labyrinth"] = function(tagdata)
								return "GLOBALTAG", "Labyrinth"
							end,
			["LabyrinthEntrance"] = function(tagdata)
								return "GLOBALTAG", "LabyrinthEntrance"
							end,
			["OverrideCentroid"] = function(tagdata)
								return "GLOBALTAG", "OverrideCentroid"
							end,
			["RoadPoison"] = function(tagdata)
								return "TAG", "RoadPoison"
							end,
			["ForceConnected"] = function(tagdata)
								return "TAG", "ForceConnected"
							end,
			["ForceDisconnected"] = function(tagdata)
								return "TAG", "ForceDisconnected"
							end,
			["OneshotWormhole"] = function(tagdata)
								return "TAG", "OneshotWormhole"
							end,
			["ExitPiece"] = function(tagdata)
								return "TAG", "ExitPiece"
							end,
			--["ExitPiece"]	= 	function(tagdata)
									--if #tagdata["ExitPiece"] == 0 then
										--return
									--end
																		
									--local item = GetRandomItem(tagdata["ExitPiece"])
									
									--for idx,v in pairs(tagdata["ExitPiece"]) do
										--if v == item then
											--table.remove(tagdata["ExitPiece"], idx)
											--break
										--end
									--end								
									
									--print("Exit piece adding bit", item)
									--return "STATIC", item	
								--end,
								
			["Town"] =  function(tagdata)
							return "TAG", 0x000001	
						end,
			["Chester_Eyebone"] =	function(tagdata)
										if tagdata["Chester_Eyebone"] == false then
											return
										end
										tagdata["Chester_Eyebone"] = false
										return "ITEM", "chester_eyebone"
									end,
			["StagehandGarden"] =	function(tagdata)
										if tagdata["StagehandGarden"] == false then
											return
										end
										tagdata["StagehandGarden"] = false
										return "STATIC", "StagehandGarden"
									end,									
			["Hutch_Fishbowl"] =	function(tagdata)										
										if tagdata["Hutch_Fishbowl"] == false then
											return
										end
										tagdata["Hutch_Fishbowl"] = false
										return "ITEM", "hutch_fishbowl"
									end,

            ["Nightmare"] =           function(tagdata) return "TAG", "Nightmare" end, 
            ["Atrium"] =              function(tagdata) return "TAG", "Atrium" end, 
			["Mist"] =                function(tagdata) return "TAG", "Mist" end,
            ["sandstorm"] =           function(tagdata) return "TAG", "sandstorm" end,
            ["nohunt"] =              function(tagdata) return "TAG", "nohunt" end, 
            ["moonhunt"] =            function(tagdata) return "TAG", "moonhunt" end, 
            ["nohasslers"] =          function(tagdata) return "TAG", "nohasslers" end, 
            ["not_mainland"] =        function(tagdata) return "TAG", "not_mainland" end, 
            ["lunacyarea"] =          function(tagdata) return "TAG", "lunacyarea" end, 

		}
	return {Tag = map_tags, TagData = map_data }
end
return MakeTags
