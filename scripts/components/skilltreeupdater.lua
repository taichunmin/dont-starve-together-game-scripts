local skilltreedefs = require "prefabs/skilltree_defs"

local function onplayeractivated(inst)
    local self = inst.components.skilltreeupdater

    if self and not TheNet:IsDedicated() and inst == ThePlayer then
        self.skilltree = TheSkillTree -- skilltreedata type
        self.skilltree.owner = ThePlayer
        self.skilltree.save_enabled = nil -- Disable saving until the activation handshake is complete to preserve client save state.
    end
end

local SkillTreeUpdater = Class(function(self, inst)
    self.inst = inst

    self.skilltree = require("skilltreedata")()
    self.skilltree.owner = inst
    inst:ListenForEvent("playeractivated", onplayeractivated)
end)

-- NOTES(JBK): Wrapper functions to adhere to abstraction layers.

function SkillTreeUpdater:IsActivated(skill)
    return self.skilltree:IsActivated(skill, self.inst.prefab)
end

function SkillTreeUpdater:IsValidSkill(skill)
return self.skilltree:IsValidSkill(skill, self.inst.prefab)
end

function SkillTreeUpdater:GetSkillXP()
    return self.skilltree:GetSkillXP(self.inst.prefab)
end

function SkillTreeUpdater:GetPointsForSkillXP(skillxp)
    return self.skilltree:GetPointsForSkillXP(skillxp)
end

function SkillTreeUpdater:GetAvailableSkillPoints()
    return self.skilltree:GetAvailableSkillPoints(self.inst.prefab)
end

function SkillTreeUpdater:GetPlayerSkillSelection() -- NOTES(JBK): Returns an array table of bitfield entries of all activated skills.
    return self.skilltree:GetPlayerSkillSelection(self.inst.prefab)
end

function SkillTreeUpdater:GetNamesFromSkillSelection(skillselection) -- NOTES(JBK): Gets a skill name key table from an array table of bitfield entries of all activated skills.
    return self.skilltree:GetNamesFromSkillSelection(skillselection, self.inst.prefab)
end

function SkillTreeUpdater:GetActivatedSkills() -- NOTES(JBK): Gets the skill name key table for all currently activated skills.
    return self.skilltree:GetActivatedSkills(self.inst.prefab)
end

function SkillTreeUpdater:CountSkillTag(tag)
    return skilltreedefs.FN.CountTags(self.inst.prefab, tag, self:GetActivatedSkills())
end

function SkillTreeUpdater:HasSkillTag(tag)
    return self:CountSkillTag(tag) > 0
end


function SkillTreeUpdater:ActivateSkill_Client(skill) -- NOTES(JBK): Use ActivateSkill instead.
    local characterprefab = ThePlayer.prefab
    --print("[STUpdater] ActivateSkill CLIENT", characterprefab, skill)
    ThePlayer:PushEvent("onactivateskill_client", {skill = skill,})
end
function SkillTreeUpdater:ActivateSkill_Server(skill) -- NOTES(JBK): Use ActivateSkill instead.
    local characterprefab = self.inst.prefab
    --print("[STUpdater] ActivateSkill SERVER", characterprefab, skill)
    local onactivate = skilltreedefs.SKILLTREE_DEFS[characterprefab][skill].onactivate
    if onactivate then
        onactivate(self.inst)
    end
    self.inst:PushEvent("onactivateskill_server", {skill = skill,})
    self.inst._skilltreeactivatedany:push()
end
function SkillTreeUpdater:ActivateSkill(skill, prefab, fromrpc)
    -- should ignore the prefab paramater as that's just used skilltreedata at frontend
    local characterprefab = self.inst.prefab
    if characterprefab and skill then
        local updated = self.skilltree:ActivateSkill(skill, characterprefab)
        if self.silent then
            return
        end

        if updated then
            if TheWorld.ismastersim then
                if self.inst.userid and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) then
                    self:ActivateSkill_Server(skill)
                    if not fromrpc then
                        SendRPCToClient(CLIENT_RPC.SetSkillActivatedState, self.inst.userid, self.skilltree:GetSkillIDFromName(characterprefab, skill), true)
                    end
                else
                    self:ActivateSkill_Client(skill)
                    self:ActivateSkill_Server(skill)
                end
            elseif self.inst == ThePlayer then
                self:ActivateSkill_Client(skill)
                if not fromrpc then
                    SendRPCToServer(RPC.SetSkillActivatedState, self.skilltree:GetSkillIDFromName(characterprefab, skill), true)
                end
            end
        end
    end
end


function SkillTreeUpdater:DeactivateSkill_Client(skill) -- NOTES(JBK): Use DeactivateSkill instead.
    local characterprefab = ThePlayer.prefab
    --print("[STUpdater] DeactivateSkill CLIENT", characterprefab, skill)
    ThePlayer:PushEvent("ondeactivateskill_client", {skill = skill,})
end
function SkillTreeUpdater:DeactivateSkill_Server(skill) -- NOTES(JBK): Use DeactivateSkill instead.
    local characterprefab = self.inst.prefab
    --print("[STUpdater] DeactivateSkill SERVER", characterprefab, skill)
    local ondeactivate = skilltreedefs.SKILLTREE_DEFS[characterprefab][skill].ondeactivate
    if ondeactivate then
        ondeactivate(self.inst)
    end
    self.inst:PushEvent("ondeactivateskill_server", {skill = skill,})
end
function SkillTreeUpdater:DeactivateSkill(skill, prefab, fromrpc)
    -- should ignore the prefab paramater as that's just used skilltreedata at frontend
    local characterprefab = self.inst.prefab
    if characterprefab and skill then
        local updated = self.skilltree:DeactivateSkill(skill, characterprefab) -- FIXME(JBK): Detect if this will cause skills to get locked, and then also deactivate the whole tree branch recursively.
        if self.silent then
            return
        end

        if updated then
            if TheWorld.ismastersim then
                if self.inst.userid and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) then
                    self:DeactivateSkill_Server(skill)
                    if not fromrpc then
                        SendRPCToClient(CLIENT_RPC.SetSkillActivatedState, self.inst.userid, self.skilltree:GetSkillIDFromName(characterprefab, skill), false)
                    end
                else
                    self:DeactivateSkill_Client(skill)
                    self:DeactivateSkill_Server(skill)
                end
            elseif self.inst == ThePlayer then
                self:DeactivateSkill_Client(skill)
                if not fromrpc then
                    SendRPCToServer(RPC.SetSkillActivatedState, self.skilltree:GetSkillIDFromName(characterprefab, skill), false)
                end
            end
        end
    end
end

function SkillTreeUpdater:AddSkillXP_Client(amount, total) -- NOTES(JBK): Use AddSkillXP instead.
    local characterprefab = ThePlayer.prefab
    --print("[STUpdater] AddSkillXP CLIENT", characterprefab, amount, total)
    ThePlayer:PushEvent("onaddskillxp_client", {amount = amount, total = total})
end
function SkillTreeUpdater:AddSkillXP_Server(amount, total) -- NOTES(JBK): Use AddSkillXP instead.
    local characterprefab = self.inst.prefab
    --print("[STUpdater] AddSkillXP SERVER", characterprefab, amount, total)
    self.inst:PushEvent("onaddskillxp_server", {amount = amount, total = total})
end
function SkillTreeUpdater:AddSkillXP(amount, prefab, fromrpc)
    -- should ignore the prefab paramater as that's just used skilltreedata at frontend
    local characterprefab = self.inst.prefab
    if characterprefab and amount then
        local updated, total = self.skilltree:AddSkillXP(amount, characterprefab)

        if updated then
            if TheWorld.ismastersim then
                if self.inst.userid and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) then
                    self:AddSkillXP_Server(amount, total)
                    if not fromrpc then
                        SendRPCToClient(CLIENT_RPC.AddSkillXP, self.inst.userid, amount)
                    end
                else
                    self:AddSkillXP_Client(amount, total)
                    self:AddSkillXP_Server(amount, total)
                end
            elseif self.inst == ThePlayer then
                self:AddSkillXP_Client(amount, total)
                if not fromrpc then
                    SendRPCToServer(RPC.AddSkillXP, amount)
                end
            end
        end

        if self.inst == ThePlayer and not TheSkillTree.ignorexp then -- Local UI handler.
            if self:GetAvailableSkillPoints() > 0 then
                ThePlayer.new_skill_available_popup = true
                ThePlayer:PushEvent("newskillpointupdated")
            end
        end
    end
end

-- NOTES(JBK): Data layer. Engage at your own risk.

function SkillTreeUpdater:SetSilent(silent) -- Do not network nor activate callbacks and skip skill validation checks.
    silent = silent and true or nil
    self.silent = silent
end

function SkillTreeUpdater:SetSkipValidation(skip) -- Skip skill validation checks.
    skip = skip and true or nil
    self.skilltree.skip_validation = skip
end

function SkillTreeUpdater:OnSave()
    local skilltreeblob = self.skilltreeblob or self.skilltree:EncodeSkillTreeData(self.inst.prefab)
    local skilltreeblobprefab = self.skilltreeblobprefab or self.inst.prefab
    --print("[STUpdater] OnSave", skilltreeblob, skilltreeblobprefab)
    if skilltreeblob ~= TheSkillTree.NILDATA then
        return {skilltreeblob = skilltreeblob, skilltreeblobprefab = skilltreeblobprefab}
    end
end

function SkillTreeUpdater:TransferComponent(newinst)
    --print("[STUpdater] TransferComponent", self.inst, newinst)
    local skilltreeblob = self.skilltreeblob or self.skilltree:EncodeSkillTreeData(self.inst.prefab)
    local skilltreeblobprefab = self.skilltreeblobprefab or self.inst.prefab
    local newcomponent = newinst.components.skilltreeupdater
    if skilltreeblob ~= TheSkillTree.NILDATA then
        newcomponent.skilltreeblob = skilltreeblob
        newcomponent.skilltreeblobprefab = skilltreeblobprefab
    end
    -- FIXME(JBK): Save the data as a backup and if the player loads back in as the original use their old data as a fallback.
end

function SkillTreeUpdater:SetPlayerSkillSelection(skillselection) -- NOTES(JBK): Applies an array table of bitfield entries of all activated skills and does not network anything.
    local activatedskills = self:GetNamesFromSkillSelection(skillselection)
    self:SetSilent(true)
    self:SetSkipValidation(true)
    for skill, _ in pairs(activatedskills) do
        self:ActivateSkill(skill)
    end
    self:SetSilent(false)
    self:SetSkipValidation(false)
    self.skilltreeblob = self.skilltree:EncodeSkillTreeData(self.inst.prefab)
    self.skilltreeblobprefab = self.inst.prefab
end

function SkillTreeUpdater:SendFromSkillTreeBlob(inst)
    -- NOTES(JBK): self.skilltreeblobprefab could be nil from old saves so we will try to apply skills here in that case.
    -- The worst case is that ValidateCharacterData fails and nothing changes.
    if self.skilltreeblob ~= nil and (self.skilltreeblobprefab == nil or self.skilltreeblobprefab == self.inst.prefab) then
        local activatedskills, _badskillxp_donotuse = self.skilltree:DecodeSkillTreeData(self.skilltreeblob)
        -- Delete the stored cache if the validation fails it is bad to keep around.
        self.skilltreeblob = nil
        self.skilltreeblobprefab = nil
        -- At this point the client will have sent their current XP to measure from so use that value and not the local stored invalid XP.
        if self.skilltree:ValidateCharacterData(self.inst.prefab, activatedskills, self:GetSkillXP()) then
            if activatedskills ~= nil then
                self:SetSkipValidation(true) -- Validated already skip checking again.
                self:SetSilent(true)
                for skill, _ in pairs(activatedskills) do
                    self:DeactivateSkill(skill)
                end
                self:SetSilent(false)

                -- Apply skills and network them if need be.
                for skill, _ in pairs(activatedskills) do -- Two loops just in case of activation states.
                    self:ActivateSkill(skill)
                end
                self:SetSkipValidation(false)

            end
            -- Do not use nor send skillxp here.
        end
    end
    self.inst:PushEvent("onsetskillselection_server")
end

function SkillTreeUpdater:OnLoad(data)
    if data then
        self.skilltreeblob = data.skilltreeblob
        self.skilltreeblobprefab = data.skilltreeblobprefab
        --print("[STUpdater] OnLoad", self.skilltreeblob, self.skilltreeblobprefab)
    end
end

return SkillTreeUpdater