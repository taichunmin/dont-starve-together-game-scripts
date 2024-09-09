--The file is meant for platform specific tweaks to the default game, rather than polluting the code with lots of inline branching.
Print(VERBOSITY.DEBUG, "[Loading platformpostload]")

if PLATFORM == "WIN32_RAIL" then
	local function YesNoTwoThirdsVote(params, voteresults)
		if voteresults.options[1] >= 2 * voteresults.options[2] then
			--Only return 'Yes' result when is greater or equal to two thirds of the vote
			return 1, voteresults.options[1]
		end
	end

	local UserCommands = require("usercommands")
	local kick_command = UserCommands.GetCommandFromName("kick")
	kick_command.voteresultfn = YesNoTwoThirdsVote

	--user commands
	RailUserCommandInject( "help", "帮助", {"指令"} )
	RailUserCommandInject( "emote", "表情", {"表情姓名"} )
	RailUserCommandInject( "rescue", "救命" )
	RailUserCommandInject( "kick", "踢出", {"用户"} )
	RailUserCommandInject( "ban", "封禁", {"用户", "秒"} )
	RailUserCommandInject( "stopvote", "停止投票" )
	RailUserCommandInject( "roll", "摇骰子", {"骰子"} )
	RailUserCommandInject( "rollback", "回滚", {"保存次数"} )
	RailUserCommandInject( "regenerate", "重新生成" )

	RailUserCommandRemove( "bug" )

	--emote commands
	RailUserCommandInject( "wave", "挥手", nil, "再见" )
	RailUserCommandInject( "rude", "挑事" )
	RailUserCommandInject( "happy", "快乐" )
	RailUserCommandInject( "angry", "愤怒" )
	RailUserCommandInject( "cry", "哭" )
	RailUserCommandInject( "no", "不" )
	RailUserCommandInject( "joy", "喜悦" )
	RailUserCommandInject( "dance", "舞蹈" )
	RailUserCommandInject( "sit", "坐下" )
	RailUserCommandInject( "squat", "蹲坐" )
	RailUserCommandInject( "bonesaw", "锯" )
	RailUserCommandInject( "facepalm", "叹" )
	RailUserCommandInject( "kiss", "吻" )
	RailUserCommandInject( "pose", "姿势" )
	RailUserCommandInject( "toast", "干杯" )
end