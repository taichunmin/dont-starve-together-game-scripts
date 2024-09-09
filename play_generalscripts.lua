local fn = require("play_commonfn")

local ERROR = { "ERROR" }

local general_scripts = {}

--[[
    MONOLOGUE_EXAMPLE = {
        cast = MONOLOGUE,  -- THIS IS FOR JUST ANYONE. GOES IN A POOL OF RANDOM CHOICE
        lines = {
                    {roles = {"MONOLOGUE"}, duration = 2.5, line = "line 1"},
                    {roles = {"MONOLOGUE"}, duration = 2.5, line = "line 2"},
        }
    }
]]

general_scripts.WILSON1 = {
    cast = { "wilson" },
    lines = {
        {actionfn = fn.actorsbow,   duration = 2.5, },
        {roles = {"wilson"},        duration = 3.0, line = STRINGS.STAGEACTOR.WILSON1[1]},
        {roles = {"wilson"},        duration = 3.0, line = STRINGS.STAGEACTOR.WILSON1[2]},
        {roles = {"wilson"},        duration = 3.0, line = STRINGS.STAGEACTOR.WILSON1[3]},
        {roles = {"wilson"},        duration = 3.0, line = STRINGS.STAGEACTOR.WILSON1[4]},
        {actionfn = fn.actorsbow,   duration = 0.2, },
    },
}

general_scripts.WALTER1 = {
    cast = { "walter" },
    lines = {
        {roles = {"walter"},    duration = 3.0, line = STRINGS.STAGEACTOR.WALTER1[1]},
        {roles = {"walter"},    duration = 3.0, line = STRINGS.STAGEACTOR.WALTER1[2]},
        {roles = {"walter"},    duration = 4.5, anim = { "emote_pre_sit1", "emote_loop_sit1" }},
        {roles = {"walter"},    duration = 3.0, line = STRINGS.STAGEACTOR.WALTER1[3]},
        {roles = {"walter"},    duration = 3.0, line = STRINGS.STAGEACTOR.WALTER1[4]},
    },
}

general_scripts.WANDA1 = {
    cast = { "wanda" },
    lines = {
        {roles = {"wanda"},     duration = 3.0, line = STRINGS.STAGEACTOR.WANDA1[1]},
        {roles = {"wanda"},     duration = 3.0, line = STRINGS.STAGEACTOR.WANDA1[2]},
        {roles = {"wanda"},     duration = 3.0, line = STRINGS.STAGEACTOR.WANDA1[3]},
        {roles = {"wanda"},     duration = 3.0, line = STRINGS.STAGEACTOR.WANDA1[4]},
        {roles = {"wanda"},     duration = 3.0, line = STRINGS.STAGEACTOR.WANDA1[5]},
        {roles = {"wanda"},     duration = 2.0, line = STRINGS.STAGEACTOR.WANDA1[6]},
        {roles = {"wanda"},     duration = 2.0, line = STRINGS.STAGEACTOR.WANDA1[7]},
        {roles = {"wanda"},     duration = 3.0, line = STRINGS.STAGEACTOR.WANDA1[8]},
    }
}

general_scripts.WARLY1 = {
    cast = { "warly" },
    lines = {
        {roles = {"warly"},     duration = 3.0, line = STRINGS.STAGEACTOR.WARLY1[1]},
        {roles = {"warly"},     duration = 3.0, line = STRINGS.STAGEACTOR.WARLY1[2]},
        {roles = {"warly"},     duration = 3.0, line = STRINGS.STAGEACTOR.WARLY1[3]},
        {roles = {"warly"},     duration = 3.0, line = STRINGS.STAGEACTOR.WARLY1[4]},
        {roles = {"warly"},     duration = 3.0, line = STRINGS.STAGEACTOR.WARLY1[5]},
        {roles = {"warly"},     duration = 2.0, line = STRINGS.STAGEACTOR.WARLY1[6]},
    }
}

general_scripts.WATHGRITHR1 = {
    cast = { "wathgrithr" },
    lines = {
        {actionfn = fn.actorscurtsey,   duration = 2.25 },
        {roles = {"wathgrithr"}, duration = 13*FRAMES, anim = "sing_loop_pre"},
        {   roles = {"wathgrithr"},
            duration = 12*30*FRAMES,
            anim = "sing_loop",
            animtype = "loop",
            castsound = {
                wathgrithr = "stageplay_set/wigfrid_opera/solo"
            },
        },
        {roles = {"wathgrithr"}, duration = 19*FRAMES, anim = "sing_loop_pst"},
        {actionfn = fn.actorsbow,       duration = 2.25 },
    }
}

general_scripts.WAXWELL1 = {
    cast = { "waxwell" },
    lines = {
        {actionfn = fn.findpositions,   duration = 1.0, positions={["waxwell"] = 1}},
        {roles = {"waxwell"},           duration = 3.0, line = STRINGS.STAGEACTOR.WAXWELL1[1]},
        {roles = {"waxwell"},           duration = 3.0, line = STRINGS.STAGEACTOR.WAXWELL1[2]},
        {actionfn=fn.waxwelldancer,     duration = 0.1, theta = 0, radius = 2, caster="waxwell", time = 4.5 },
        {actionfn=fn.waxwelldancer,     duration = 0.1, theta = 1.5*PI, radius = 2.2, caster="waxwell", time = 4.5 },
        {roles = {"waxwell"},           duration = 4.0, anim={"emoteXL_pre_dance0","emoteXL_loop_dance0"}, animtype="loop"},
        {roles = {"waxwell"},           duration = 0.5, anim="emoteXL_pst_dance0"},
        {roles = {"waxwell"},           duration = 3.0, line = STRINGS.STAGEACTOR.WAXWELL1[3]},
    }
}

general_scripts.WEBBER_SPIDER = {
    cast = { "webber" },
    lines = {
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[1]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[2]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[3]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[4]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[5]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[6]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[7]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_SPIDER[8]},
    }
}

general_scripts.WEBBER_BOY = {
    cast = { "webber" },
    lines = {
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_BOY[1]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_BOY[2]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_BOY[3]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_BOY[4]},
        {roles = {"webber"},    duration = 3.0, line = STRINGS.STAGEACTOR.WEBBER_BOY[5]},
    }
}

general_scripts.WENDY1 = {
    cast = { "wendy" },
    lines = {
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[1]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[2]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[3]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[4]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[5]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[6]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[7]},
        {roles = {"wendy"},     duration = 3.0, line = STRINGS.STAGEACTOR.WENDY1[8]},
    }
}

general_scripts.WICKERBOTTOM1 = {
    cast = { "wickerbottom" },
    lines = {
        {roles = {"wickerbottom"}, duration = 3.0, line = STRINGS.STAGEACTOR.WICKERBOTTOM1[1]},
        {roles = {"wickerbottom"}, duration = 3.0, line = STRINGS.STAGEACTOR.WICKERBOTTOM1[2]},
        {roles = {"wickerbottom"}, duration = 3.0, line = STRINGS.STAGEACTOR.WICKERBOTTOM1[3]},
        {roles = {"wickerbottom"}, duration = 3.0, line = STRINGS.STAGEACTOR.WICKERBOTTOM1[4]},
        {roles = {"wickerbottom"}, duration = 3.0, line = STRINGS.STAGEACTOR.WICKERBOTTOM1[5]},
    }
}

general_scripts.WILLOW1 = {
    cast = { "willow" },
    lines = {
        {roles = {"willow"},    duration = 3.0, line = STRINGS.STAGEACTOR.WILLOW1[1]},
        {roles = {"willow"},    duration = 3.0, line = STRINGS.STAGEACTOR.WILLOW1[2]},
        {roles = {"willow"},    duration = 3.0, line = STRINGS.STAGEACTOR.WILLOW1[3]},
        {roles = {"willow"},    duration = 3.0, line = STRINGS.STAGEACTOR.WILLOW1[4]},
        {roles = {"willow"},    duration = 3.0, line = STRINGS.STAGEACTOR.WILLOW1[5], anim="emote_happycheer"},
        {roles = {"willow"},    duration = 3.0, line = STRINGS.STAGEACTOR.WILLOW1[6]},
    }
}

general_scripts.WINONA1 = {
    cast = { "winona" },
    lines = {
        {roles = {"winona"},    duration = 3.0, line = STRINGS.STAGEACTOR.WINONA1[1]},
        {roles = {"winona"},    duration = 3.0, line = STRINGS.STAGEACTOR.WINONA1[2]},
        {roles = {"winona"},    duration = 3.0, line = STRINGS.STAGEACTOR.WINONA1[3]},
        {roles = {"winona"},    duration = 3.0, line = STRINGS.STAGEACTOR.WINONA1[4]},
        {roles = {"winona"},    duration = 3.0, line = STRINGS.STAGEACTOR.WINONA1[5]},
    }
}

general_scripts.WOLFGANG1 = {
    cast = { "wolfgang" },
    lines = {
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[1]},
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[2]},
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[3]},
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[4]},
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[5]},
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[6]},
        {roles = {"wolfgang"},  duration = 3.0, line = STRINGS.STAGEACTOR.WOLFGANG1[7]},
    }
}

general_scripts.WOODIE1 = {
    cast = { "woodie" },
    lines = {
        {roles = {"woodie"},        duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[1]},
        {actionfn = fn.lucytalk,    duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[2], lucytest = "woodie"},
        {actionfn = fn.lucytalk,    duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[3], lucytest = "woodie"},
        {actionfn = fn.lucytalk,    duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[4], lucytest = "woodie"},
        {actionfn = fn.lucytalk,    duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[5], lucytest = "woodie"},
        {actionfn = fn.lucytalk,    duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[6], lucytest = "woodie"},
        {roles = {"woodie"},        duration = 3.0, line = STRINGS.STAGEACTOR.WOODIE1[7], lucytest = "woodie"},
    }
}

general_scripts.WORMWOOD1 = {
    cast = { "wormwood" },
    lines = {
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[1]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[2]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[3]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[4]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[5]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[6]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[7]},
        {roles = {"wormwood"},      duration = 3.0, line = STRINGS.STAGEACTOR.WORMWOOD1[8]},
    }
}

general_scripts.WORTOX1 = {
    cast = { "wortox" },
    lines = {
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[1]},
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[2]},
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[3]},
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[4]},
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[5]},
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[6]},
        {roles = {"wortox"},        duration = 3.0, line = STRINGS.STAGEACTOR.WORTOX1[7]},
    }
}

general_scripts.WURT1 = {
    cast = { "wurt" },
    lines = {
        {roles = {"wurt"},          duration = 3.0, line = STRINGS.STAGEACTOR.WURT1[1]},
        {roles = {"wurt"},          duration = 3.0, line = STRINGS.STAGEACTOR.WURT1[2]},
        {roles = {"wurt"},          duration = 3.0, line = STRINGS.STAGEACTOR.WURT1[3]},
        {roles = {"wurt"},          duration = 3.0, line = STRINGS.STAGEACTOR.WURT1[4]},
        {roles = {"wurt"},          duration = 3.0, line = STRINGS.STAGEACTOR.WURT1[5]},
    }
}

general_scripts.WX1 = {
    cast = { "wx78" },
    lines = {
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[1]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[2]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[3]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[4]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[5]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[6]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[7]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[8]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[9]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[10]},
        {roles = {"wx78"},          duration = 3.0, line = STRINGS.STAGEACTOR.WX1[11]},
    }
}

general_scripts.WES1 = {
    cast = { "wes" },
    lines = {
        {actionfn = fn.actorsbow,   duration = 2.5, },
        {roles = {"wes"},           duration = 3.0, anim = "mime1",}, -- NOTE: Wes doesn't respect passed in animations, so we get a random mime.
        {roles = {"wes"},           duration = 3.0, anim = "mime1",}, -- NOTE: Wes doesn't respect passed in animations, so we get a random mime.
        {roles = {"wes"},           duration = 3.0, anim = "mime1",}, -- NOTE: Wes doesn't respect passed in animations, so we get a random mime.
        {roles = {"wes"},           duration = 3.0, anim = "mime1",}, -- NOTE: Wes doesn't respect passed in animations, so we get a random mime.
        {roles = {"wes"},           duration = 3.0, anim = "mime1",}, -- NOTE: Wes doesn't respect passed in animations, so we get a random mime.
        {roles = {"wes"},           duration = 3.0, anim = "mime1",}, -- NOTE: Wes doesn't respect passed in animations, so we get a random mime.
        {actionfn = fn.actorsbow,   duration = 0.2, },
    }
}

--------------------------------------------------------------------------------
-- ERROR STATES
general_scripts.BAD_COSTUMES = {
    cast = ERROR,
    lines = {
        {actionfn = fn.callbirds,   duration = 2, },
        {roles = {"BIRD2"},         duration = 2.5,     line = STRINGS.STAGEACTOR.BAD_COSTUMES[1]},
        {roles = {"BIRD1"},         duration = 3.5,     line = STRINGS.STAGEACTOR.BAD_COSTUMES[2], sgparam="disappointed"},
        {roles = {"BIRD2"},         duration = 2.5,     line = STRINGS.STAGEACTOR.BAD_COSTUMES[3]},
        {roles = {"BIRD1"},         duration = 2.5,     line = STRINGS.STAGEACTOR.BAD_COSTUMES[4], sgparam="disappointed"},
        {actionfn = fn.exitbirds,   duration = 0.3, },
    }
}

general_scripts.REPEAT_COSTUMES = {
    cast = ERROR,
    lines = {
        {actionfn = fn.callbirds,   duration = 2, },
        {roles = {"BIRD2"},         duration = 2.5,     line = STRINGS.STAGEACTOR.REPEAT_COSTUMES[1], sgparam="disappointed"},
        {roles = {"BIRD1"},         duration = 3.5,     line = STRINGS.STAGEACTOR.REPEAT_COSTUMES[2]},
        {roles = {"BIRD2"},         duration = 2.5,     line = STRINGS.STAGEACTOR.REPEAT_COSTUMES[3], sgparam="disappointed"},
        {actionfn = fn.exitbirds,   duration = 0.3, },
    }
}

general_scripts.NO_SCRIPT = {
    cast = ERROR,
    lines = {
        {actionfn = fn.callbirds,   duration = 2, },
        {roles = {"BIRD2"},         duration = 2.5,     line = STRINGS.STAGEACTOR.NO_SCRIPT[1]},
        {roles = {"BIRD1"},         duration = 3.5,     line = STRINGS.STAGEACTOR.NO_SCRIPT[2]},
        {roles = {"BIRD2"},         duration = 2.5,     line = STRINGS.STAGEACTOR.NO_SCRIPT[3], sgparam="disappointed"},
        {roles = {"BIRD1","BIRD2"}, duration = 1.8,     line = STRINGS.STAGEACTOR.NO_SCRIPT[4], sgparam="disappointed"},
        {actionfn = fn.exitbirds,   duration = 0.3, },
    }
}

return general_scripts