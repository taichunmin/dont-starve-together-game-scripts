require("class")
require("util")

local playsound = SoundEmitter.PlaySound
local killsound = SoundEmitter.KillSound
local killallsounds = SoundEmitter.KillAllSounds
local setparameter = SoundEmitter.SetParameter
local setvolume = SoundEmitter.SetVolume
local setlistener = Sim.SetListener

SoundEmitter.SoundDebug = {}

--tweakable parameters
SoundEmitter.SoundDebug.maxRecentSounds = 30  --max number of recent sounds to list in the debug output
SoundEmitter.SoundDebug.maxDistance = 30     --max distance to show

SoundEmitter.SoundDebug.nearbySounds = {}
SoundEmitter.SoundDebug.loopingSounds = {}
SoundEmitter.SoundDebug.soundCount = 0
SoundEmitter.SoundDebug.listenerPos = nil

SoundEmitter.SoundDebug.uiSounds = {}
SoundEmitter.SoundDebug.loopingUISounds = {}
SoundEmitter.SoundDebug.uiSoundCount = 0

TheSim:LoadPrefabs({"sounddebugicon"})

SoundEmitter.PlaySound = function(emitter, event, name, volume, ...)
    local ent = emitter:GetEntity()
    if ent and ent.Transform and SoundEmitter.SoundDebug.listenerPos then
        local pos = Vector3(ent.Transform:GetWorldPosition() )
        local dist = math.sqrt(distsq(pos, SoundEmitter.SoundDebug.listenerPos) )
        if dist < SoundEmitter.SoundDebug.maxDistance or name then
            local soundIcon = nil
            if name and SoundEmitter.SoundDebug.loopingSounds[ent] and SoundEmitter.SoundDebug.loopingSounds[ent][name] then
                soundIcon = SoundEmitter.SoundDebug.loopingSounds[ent][name].icon
            else
                soundIcon = SpawnPrefab("sounddebugicon")
            end
            if soundIcon then
                soundIcon.Transform:SetPosition(pos:Get() )
            end

            local soundInfo = {emitter=emitter, event=event, owner=ent, guid=ent.GUID, prefab=ent.prefab or "", position=pos, dist=dist, volume=volume or 1, icon=soundIcon, callstack=debugstack(2)}
            if name then
                --add to looping sounds list
                soundInfo.params = {}
                if not SoundEmitter.SoundDebug.loopingSounds[ent] then
                    SoundEmitter.SoundDebug.loopingSounds[ent] = {}
                end
                SoundEmitter.SoundDebug.loopingSounds[ent][name] = soundInfo
                if soundIcon then
                    if soundIcon.autokilltask then
                        soundIcon.autokilltask:Cancel()
                        soundIcon.autokilltask = nil
                    end
                    soundIcon.Label:SetText(name)
                end
            else
                --add to oneshot sound list
                SoundEmitter.SoundDebug.soundCount = SoundEmitter.SoundDebug.soundCount + 1
                local index = (SoundEmitter.SoundDebug.soundCount % SoundEmitter.SoundDebug.maxRecentSounds)+1
                soundInfo.count = SoundEmitter.SoundDebug.soundCount
                SoundEmitter.SoundDebug.nearbySounds[index] = soundInfo
                if soundIcon then
                    soundIcon.Label:SetText(tostring(SoundEmitter.SoundDebug.soundCount) )
                end
            end
        end
    else
        local soundInfo = {emitter=emitter, event=event, volume=volume or 1, callstack=debugstack(2)}
        if name then
            --add to looping sounds list
            soundInfo.params = {}
            if not SoundEmitter.SoundDebug.loopingUISounds[name] then
                SoundEmitter.SoundDebug.loopingUISounds[name] = {}
            end
            SoundEmitter.SoundDebug.loopingUISounds[name] = soundInfo
        else
            --add to oneshot sound list
            SoundEmitter.SoundDebug.uiSoundCount = SoundEmitter.SoundDebug.uiSoundCount + 1
            local index = (SoundEmitter.SoundDebug.uiSoundCount % SoundEmitter.SoundDebug.maxRecentSounds)+1
            soundInfo.count = SoundEmitter.SoundDebug.uiSoundCount
            SoundEmitter.SoundDebug.uiSounds[index] = soundInfo
        end
    end

    playsound(emitter, event, name, volume, ...)
end

SoundEmitter.KillSound = function(emitter, name, ...)
    local ent = emitter:GetEntity()
    if SoundEmitter.SoundDebug.loopingSounds[ent] then
        if SoundEmitter.SoundDebug.loopingSounds[ent][name] and SoundEmitter.SoundDebug.loopingSounds[ent][name].icon then
            SoundEmitter.SoundDebug.loopingSounds[ent][name].icon:Remove()
        end
        SoundEmitter.SoundDebug.loopingSounds[ent][name] = nil
    end

    if SoundEmitter.SoundDebug.loopingUISounds[name] then
        SoundEmitter.SoundDebug.loopingUISounds[name] = nil
    end

    killsound(emitter, name, ...)
end

SoundEmitter.KillAllSounds = function(emitter, ...)
    local sounds = SoundEmitter.SoundDebug.loopingSounds[emitter:GetEntity()]
    if sounds then
        for k,v in pairs(sounds) do
            if v.icon then
                v.icon:Remove()
            end
            sounds[v] = nil
        end
        sounds = nil
    end

    local ent = emitter:GetEntity()
    if ent == nil or ent.Transform == nil then
		SoundEmitter.SoundDebug.loopingUISounds = {}
	end

    killallsounds(emitter, ...)
end

SoundEmitter.SetParameter = function(emitter, name, parameter, value, ...)
    local ent = emitter:GetEntity()
    if SoundEmitter.SoundDebug.loopingSounds[ent] and SoundEmitter.SoundDebug.loopingSounds[ent][name] then
        SoundEmitter.SoundDebug.loopingSounds[ent][name].params[parameter] = value
    end

    if SoundEmitter.SoundDebug.loopingUISounds[name] then
        SoundEmitter.SoundDebug.loopingUISounds[name].params[parameter] = value
    end

    setparameter(emitter, name, parameter, value, ...)
end

SoundEmitter.SetVolume = function(emitter, name, volume, ...)
    local ent = emitter:GetEntity()
    if SoundEmitter.SoundDebug.loopingSounds[ent] and SoundEmitter.SoundDebug.loopingSounds[ent][name] then
        SoundEmitter.SoundDebug.loopingSounds[ent][name].volume = volume
    end

    if SoundEmitter.SoundDebug.loopingUISounds[name] then
        SoundEmitter.SoundDebug.loopingUISounds[name].volume = volume
    end
    setvolume(emitter, name, volume, ...)
end

Sim.SetListener = function(sim, x, y, z, ...)
    SoundEmitter.SoundDebug.listenerPos = Vector3(x, y, z)
    setlistener(sim, x, y, z, ...)
end

local function DoUpdate()
    for ent,sounds in pairs(SoundEmitter.SoundDebug.loopingSounds) do
        if not next(sounds) then
            SoundEmitter.SoundDebug.loopingSounds[ent] = nil
        else
            for name,info in pairs(sounds) do
                if not ent:IsValid() or not ent.SoundEmitter or not ent.SoundEmitter:PlayingSound(name) then
                    if info.icon then
                        info.icon:Remove()
                    end
                    sounds[name] = nil
                else
                    local pos = Vector3(ent.Transform:GetWorldPosition() )
                    local dist = math.sqrt(distsq(pos, SoundEmitter.SoundDebug.listenerPos) )
                    info.dist = dist
                    info.pos = pos
                    if info.icon then
                        info.icon.Transform:SetPosition(pos:Get() )
                    end
                end
            end
        end
    end
end
scheduler:ExecutePeriodic(1, DoUpdate)

function GetSoundDebugString()
    local lines = {}
    table.insert(lines, "-------SOUND DEBUG-------")
    table.insert(lines, "Looping Sounds")
    for ent,sounds in pairs(SoundEmitter.SoundDebug.loopingSounds) do
        for name,info in pairs(sounds) do
            if info.dist < SoundEmitter.SoundDebug.maxDistance then
                local params = ""
                for k,v in pairs(info.params) do
                    params = params.." "..k.."="..v
                end
                table.insert(lines, string.format("\t[%s] %s owner:%d %s pos:%s dist:%2.2f volume:%d params:{%s}",
                        name, info.event, info.guid, info.prefab, tostring(info.pos), info.dist, info.volume, params) )
            end
        end
    end
    if SoundEmitter.SoundDebugUI_ENABLED then
        for name,info in pairs(SoundEmitter.SoundDebug.loopingUISounds) do
            local params = ""
            for k,v in pairs(info.params) do
                params = params.." "..k.."="..v
            end
            table.insert(lines, string.format("\t[%s] %s volume:%d params:{%s}",
                    name, info.event, info.volume, params) )
        end
    end
    table.insert(lines, "Recent Sounds")
    for i = SoundEmitter.SoundDebug.soundCount-SoundEmitter.SoundDebug.maxRecentSounds+1, SoundEmitter.SoundDebug.soundCount do
        local index = (i % SoundEmitter.SoundDebug.maxRecentSounds)+1
        if SoundEmitter.SoundDebug.nearbySounds[index] then
            local soundInfo = SoundEmitter.SoundDebug.nearbySounds[index]
            table.insert(lines, string.format("\t[%d] %s owner:%d %s pos:%s dist:%2.2f volume:%d",
                soundInfo.count, soundInfo.event, soundInfo.guid, soundInfo.prefab, tostring(soundInfo.pos), soundInfo.dist, soundInfo.volume) )
        end
    end
    if SoundEmitter.SoundDebugUI_ENABLED then
        for i = SoundEmitter.SoundDebug.uiSoundCount-SoundEmitter.SoundDebug.maxRecentSounds+1, SoundEmitter.SoundDebug.uiSoundCount do
            local index = (i % SoundEmitter.SoundDebug.maxRecentSounds)+1
            if SoundEmitter.SoundDebug.uiSounds[index] then
                local soundInfo = SoundEmitter.SoundDebug.uiSounds[index]
                table.insert(lines, string.format("\t[%d] %s volume:%d",
                    soundInfo.count, soundInfo.event, soundInfo.volume) )
            end
        end
    end
    return table.concat(lines, "\n")
end
