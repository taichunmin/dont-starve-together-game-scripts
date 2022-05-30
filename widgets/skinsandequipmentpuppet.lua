local Widget = require "widgets/widget"
local Text = require "widgets/text"
local SkinsPuppet = require "widgets/skinspuppet"

local anims =
{
	scratch = .5,
	hungry = .3,
	eat = .1,
	eatquick = .2,
	wave1 = .1,
	wave2 = .1,
	wave3 = .3,
	happycheer = .1,
	sad = .2,
	angry = .1,
	annoyed = .2,
	facepalm = .2
}

local function VerifyCharacter(character)
    local characterAllowed = false
    for k,v in pairs(DST_CHARACTERLIST) do
        if v == character then
            --print("Character ok", v, character)
            characterAllowed = true
        end
    end

    return characterAllowed
end

local SkinsAndEquipmentPuppet = Class(SkinsPuppet, function(self, character, colour, scale)
    SkinsPuppet._ctor(self, "SkinsAndEquipmentPuppet")

    if VerifyCharacter(character) then
        self.character = character
        self:SetCharacter(character)
    else
        -- This is a mod character or the player was still selecting their character.
        -- Pick a random valid character to replace it.
        newCharacter = DST_CHARACTERLIST[math.random(1, #DST_CHARACTERLIST)]
        --print("Picked new character", character, newCharacter)

        self.character = newCharacter
        self:SetCharacter(newCharacter)
    end


    self.anim:SetScale(unpack(scale))
    self:DoInit(colour)
end)

function SkinsAndEquipmentPuppet:DoInit(colour)

	if BASE_TORSO_TUCK[self.character] then
		--tuck torso into pelvis
		self.animstate:OverrideSkinSymbol("torso", self.character, "torso_pelvis" )
		self.animstate:OverrideSkinSymbol("torso_pelvis", self.character, "torso" )
    end

    self.animstate:SetMultColour(unpack(colour))

    self.name = self:AddChild(Text(NEWFONT, 35, "", WHITE))
    self.name:SetPosition(0, -35)
    self.name:Hide()
end

function SkinsAndEquipmentPuppet:InitSkins(player_data)

    if player_data then

        -- If we got a mod character or something, default to the previously chosen random character.
        local prefabOk = VerifyCharacter(player_data.prefab)
        self.character = prefabOk and player_data.prefab or self.character

        local base = (prefabOk) and player_data.base_skin or nil

    	local clothing = {}
    	clothing["body"] = player_data.body_skin
    	clothing["hand"] = player_data.hand_skin
    	clothing["legs"] = player_data.legs_skin
    	clothing["feet"] = player_data.feet_skin

		--track if there was a body or base so that we can determine later if we want to show the torso item or hat item
		self.has_body = clothing["body"] ~= ""
		self.has_base = base ~= nil

    	self:SetSkins(self.character, base, clothing, true)
    	self.name:SetTruncatedString(player_data.name, 200, 25, true)
    end
end

function SkinsAndEquipmentPuppet:SetTool(tool)
	if tool == "swap_staffs" then
    	self.animstate:OverrideSymbol("swap_object", tool, "swap_redstaff")
    else
    	self.animstate:OverrideSymbol("swap_object", tool, tool)
    end
    self.animstate:Show("ARM_carry")
    self.animstate:Hide("ARM_normal")
end

function SkinsAndEquipmentPuppet:SetTorso(torso)
	if torso ~= "" and not self.has_body then --only put a torso item on when the player didn't have anything in the body slot, show off their cool gear! then
    	if torso == "torso_amulets" then
    		if math.random() <= .5 then
    			self.animstate:OverrideSymbol("swap_body", torso, "purpleamulet")
    		else
    			self.animstate:OverrideSymbol("swap_body", torso, "blueamulet")
    		end
    	else
   			self.animstate:OverrideSymbol("swap_body", torso, "swap_body")
    	end
    end
end

function SkinsAndEquipmentPuppet:SetHat(hat)
	if hat ~= "" and not self.has_base then --only wear a hat when they don't have a base skin, show off the cool gear!
    	self.animstate:OverrideSymbol("swap_hat", hat, "swap_hat")
        self.animstate:Show("HAT")
        self.animstate:Show("HAIR_HAT")
        self.animstate:Hide("HAIR_NOHAT")
        self.animstate:Hide("HAIR")
		self.animstate:Hide("HEAD")
		self.animstate:Show("HEAD_HAT")
    end
end

function SkinsAndEquipmentPuppet:StartAnimUpdate()
	self.animstate:PlayAnimation("idle", true)
    self.animstate:SetTime(math.random()*1.5)

    self:StartUpdating()
end

-- This uses a different anim selection process than SkinsPuppet does
function SkinsAndEquipmentPuppet:OnUpdate(dt)
	self.timetonewanim = self.timetonewanim and self.timetonewanim - dt or 5 +math.random()*5

	if self.timetonewanim < 0 then
		self.animstate:PushAnimation(weighted_random_choice(anims))
		self.animstate:PushAnimation("idle", true)
		self.timetonewanim = 10 + math.random()*15
	end
end

function SkinsAndEquipmentPuppet:OnGainFocus()
	self.name:Show()
	self.timetonewanim = -1
end

function SkinsAndEquipmentPuppet:OnLoseFocus()
	self.name:Hide()
end

return SkinsAndEquipmentPuppet
