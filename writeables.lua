local SignGenerator = require"signgenerator"

local writeables = {}

local kinds = {}

kinds["homesign"] = {
    prompt = "Write on the sign",
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),

    cancelbtn = { text = "Cancel", cb = nil, control = CONTROL_CANCEL },
    middlebtn = { text = "Random", cb = function(inst, doer, widget)
            widget:OverrideText( SignGenerator(inst, doer) )
        end, control = CONTROL_MENU_MISC_2 },
    acceptbtn = { text = "Write it!", cb = nil, control = CONTROL_ACCEPT },

    --defaulttext = SignGenerator,
}
kinds["arrowsign_post"] = kinds["homesign"]
kinds["arrowsign_panel"] = kinds["homesign"]

writeables.makescreen = function(inst, doer)
    local data = kinds[inst.prefab]

    if doer and doer.HUD then
        return doer.HUD:ShowWriteableWidget(inst, data)
    end
end

return writeables
