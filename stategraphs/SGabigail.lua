require("stategraphs/commonstates")

local function getidleanim(inst)
    return inst.components.aura.applying and "attack_loop"
        or (inst.is_defensive and math.random() < 0.1 and "idle_custom")
        or "idle"
end

local function startaura(inst)
    if inst.components.health:IsDead() or inst.sg:HasStateTag("dissipate") then
        return
    end

    inst.Light:SetColour(255/255, 32/255, 32/255)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/attack_LP", "angry")
    inst.AnimState:SetMultColour(207/255, 92/255, 92/255, 1)

    local attack_anim = "attack" .. tostring(inst.attack_level or 1)

    inst.attack_fx = SpawnPrefab("abigail_attack_fx")
    inst:AddChild(inst.attack_fx)
    inst.attack_fx.AnimState:PlayAnimation(attack_anim .. "_pre")
    inst.attack_fx.AnimState:PushAnimation(attack_anim .. "_loop", true)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        inst.attack_fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", inst.GUID, "abigail_attack_fx" )
    end

--   inst.attack_fx_ground = SpawnPrefab("abigail_attack_fx_ground")
--   inst:AddChild(inst.attack_fx_ground)
--   inst.attack_fx_ground.AnimState:PlayAnimation(attack_anim .. "_ground_pre")
--   inst.attack_fx_ground.AnimState:PushAnimation(attack_anim .. "_ground_loop", true)
end

local function stopaura(inst)
    inst.Light:SetColour(180/255, 195/255, 225/255)
    inst.SoundEmitter:KillSound("angry")
    inst.AnimState:SetMultColour(1, 1, 1, 1)

    if inst.attack_fx then
        inst.attack_fx:kill_fx(inst.attack_level or 1)
        inst.attack_fx = nil
    end

    if inst.attack_fx_ground then
        inst.attack_fx_ground:kill_fx(inst.attack_level or 1)
        inst.attack_fx_ground = nil
    end
end

local events =
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("startaura", startaura),
    EventHandler("stopaura", stopaura),
    EventHandler("attacked", function(inst)
        if not (inst.components.health:IsDead() or inst.sg:HasStateTag("dissipate")) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("dance", function(inst)
        if not (inst.sg:HasStateTag("dancing") or inst.sg:HasStateTag("busy") or
                inst.components.health:IsDead() or inst.sg:HasStateTag("dissipate")) then
            inst.sg:GoToState("dance")
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local anim = getidleanim(inst)
            if anim ~= nil then
                inst.AnimState:PlayAnimation(anim)
            end
        end,

        onupdate = function(inst)

        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
            EventHandler("startaura", function(inst)
                inst.sg:GoToState("attack_start")
            end),
        },

    },

    State{
        name = "attack_start",
        tags = { "busy", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "appear",
        tags = { "busy", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            -- inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl_one_shot")
			if inst.components.health ~= nil then
		        inst.components.health:SetInvincible(true)
			end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.aura:Enable(true)
	        inst.components.health:SetInvincible(false)
			if inst._playerlink ~= nil then
				inst._playerlink.components.ghostlybond:SummonComplete()
			end
        end,
    },

    State{
        name = "dance",
        tags = {"idle", "dancing"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PushAnimation("dance", true)
        end,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            -- inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl_one_shot")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "dissipate",
        tags = { "busy", "noattack", "nointerrupt", "dissipate" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            -- inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl_one_shot")

	        inst.components.health:SetInvincible(true)
			inst.components.aura:Enable(false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst._playerlink ~= nil and inst._playerlink.components.ghostlybond ~= nil then
						inst.sg:GoToState("dissipated")
					else
						inst:Remove()
					end
                end
            end)
        },

		onexit = function(inst)
	        inst.components.health:SetInvincible(false)
            inst:BecomeDefensive()
		end,
    },

    State{
        name = "dissipated",
        tags = { "busy", "noattack", "nointerrupt", "dissipate" },

        onenter = function(inst)
            inst.Physics:Stop()
			inst.components.aura:Enable(false)
			if inst._playerlink ~= nil then
				inst._playerlink.components.ghostlybond:RecallComplete()
			end
			if inst.components.health:IsDead() then
				inst.components.health:SetCurrentHealth(1)
			end
        end,
    },

    State{
        name = "ghostlybond_levelup",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("flower_change")

			inst.sg.statemem.level = data ~= nil and data.level or nil
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.level == 3 and "dontstarve/characters/wendy/abigail/level_change/2" or "dontstarve/characters/wendy/abigail/level_change/1")
            end),

            TimeEvent(10 * FRAMES, function(inst)
				local fx = SpawnPrefab("abigaillevelupfx")
				fx.entity:SetParent(inst.entity)
                fx.Transform:SetRotation(inst.Transform:GetRotation())

                local skin_build = inst:GetSkinBuild()
                if skin_build ~= nil then
                    fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", inst.GUID, "abigail_attack_fx" )
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if inst.AnimState:AnimDone() or inst.AnimState:GetCurrentAnimationLength() == 0 then
                inst.sg:GoToState("walk")
            else
                inst.components.locomotor:WalkForward()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            local anim = getidleanim(inst)
            if anim ~= nil then
                inst.AnimState:PlayAnimation(anim)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)if math.random() < 0.8 then inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl") end end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("walk")
        end,
    },

    State{
        name = "walk_stop",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            if inst.AnimState:AnimDone() or inst.AnimState:GetCurrentAnimationLength() == 0 then
                inst.sg:GoToState("run")
            else
                inst.components.locomotor:RunForward()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            local anim = getidleanim(inst)
            if anim ~= nil then
                inst.AnimState:PlayAnimation(anim)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst) if math.random() < 0.8 then inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl") end end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

}

return StateGraph("abigail", states, events, "appear")
