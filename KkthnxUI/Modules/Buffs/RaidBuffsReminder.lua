local K, C, L, _ = unpack(select(2, ...))
if C["reminder"].raid_buffs_enable ~= true then return end

-- Raid buffs on player(by Elv22)
-- Locals

local pairs = pairs
local select = select

local UIParent = UIParent
local CreateFrame = CreateFrame
local UIFrameFadeOut, UIFrameFadeIn = UIFrameFadeOut, UIFrameFadeIn
local IsInInstance = IsInInstance
local GetSpellInfo = GetSpellInfo

local flaskbuffs = K.RaidBuffsReminder["Flask"]
local battleelixirbuffs = K.RaidBuffsReminder["BattleElixir"]
local guardianelixirbuffs = K.RaidBuffsReminder["GuardianElixir"]
local foodbuffs = K.RaidBuffsReminder["Food"]
local visible
local flasked
local battleelixired
local guardianelixired
local food
local spell3
local spell4
local spell5
local spell6

-- Set buffs 3-6 depending on your roll
local function SetCasterOnlyBuffs()
	Spell3Buff = {
		20217, -- Blessing of Kings
		69378, -- Drums of Forgotten Kings
		25898, -- Greater Blessing of Kings
	}
	Spell4Buff = {
		72588, -- Gift of the Wild
		48469, -- Mark of the Wild
	}
	Spell5Buff = {
		43002, -- Arcane Brilliance
		61316, -- Dalaran Brilliance
		42995, -- Arcane Intellect
		48100, -- Scroll of Intellect VIII
	}
	Spell6Buff = {
		48936, -- Blessing of Wisdom
		58777, -- Mana Spring Totem
		48938, -- Greater Blessing Of Wisdom
	}
end
	
-- Setup everyone else's buffs
local function SetBuffs()
	Spell3Buff = {	-- Total Stats
		1126, -- Mark of the Wild
		20217, -- Blessing of Kings
		69378, -- Drums of Forgotten Kings
		25898, -- Greater Blessing of Kings
	}
	Spell4Buff = {	-- Total Stamina
		21562, -- Power Word: Fortitude
		469, -- Commanding Shout
		6307, -- Blood Pact
		72588, -- Gift of the Wild
		48469, -- Mark of the Wild
		20911, -- Blessing of Sanctuary
		25899, -- Greater Blessing Of Sanctuary
		48162, -- Prayer of Fortitude
		69377, -- Runescroll of Fortitude
		48161, -- Power Word: Fortitude
	}
	Spell5Buff = {	-- Total Str + Agi
		--6673, -- Battle Shout
		8076, -- Strength of Earth
		57330, -- Horn of Winter
	}
	Spell6Buff = {	-- Total AP
		53138, -- Abom Might
		19506, -- Trushot
		30808, -- Unleashed Rage
		19740, -- Blessing of Might
		48932, -- Blessing of Might
		48934, -- Greater Blessing Of Might
		47436, -- Battle Shout
	}
end

-- We need to check if you have two differant elixirs if your not flasked, before we say your not flasked
local function CheckElixir(unit)
	if battleelixirbuffs and battleelixirbuffs[1] then
		for i, battleelixirbuffs in pairs(battleelixirbuffs) do
			local spellname = select(1, GetSpellInfo(battleelixirbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(battleelixirbuffs)))
				battleelixired = true
				break
			else
				battleelixired = false
			end
		end
	end

	if guardianelixirbuffs and guardianelixirbuffs[1] then
		for i, guardianelixirbuffs in pairs(guardianelixirbuffs) do
			local spellname = select(1, GetSpellInfo(guardianelixirbuffs))
			if UnitAura("player", spellname) then
				guardianelixired = true
				if not battleelixired then
					FlaskFrame.t:SetTexture(select(3, GetSpellInfo(guardianelixirbuffs)))
				end
				break
			else
				guardianelixired = false
			end
		end
	end

	if guardianelixired == true and battleelixired == true then
		FlaskFrame:SetAlpha(C["reminder"].raid_buffs_alpha)
		flasked = true
		return
	else
		FlaskFrame:SetAlpha(1)
		flasked = false
	end
end

-- Main Script
local function OnAuraChange(self, event, arg1, unit)
	if event == "UNIT_AURA" and arg1 ~= "player" then return end

	-- If We're a caster we may want to see differant buffs
	if K.Role == "Caster" or K.Role == "Healer" then
		SetCasterOnlyBuffs() 
	else
		SetBuffs()
	end

	-- Start checking buffs to see if we can find a match from the list
	if flaskbuffs and flaskbuffs[1] then
		FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs[1])))
		for i, flaskbuffs in pairs(flaskbuffs) do
			local spellname = select(1, GetSpellInfo(flaskbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs)))
				FlaskFrame:SetAlpha(C["reminder"].raid_buffs_alpha)
				flasked = true
				break
			else
				CheckElixir()
			end
		end
	end

	if foodbuffs and foodbuffs[1] then
		FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs[1])))
		for i, foodbuffs in pairs(foodbuffs) do
			local spellname = select(1, GetSpellInfo(foodbuffs))
			if UnitAura("player", spellname) then
				FoodFrame:SetAlpha(C["reminder"].raid_buffs_alpha)
				FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
				food = true
				break
			else
				FoodFrame:SetAlpha(1)
				food = false
			end
		end
	end

	for i, Spell3Buff in pairs(Spell3Buff) do
		local spellname = select(1, GetSpellInfo(Spell3Buff))
		if UnitAura("player", spellname) then
			Spell3Frame:SetAlpha(C["reminder"].raid_buffs_alpha)
			Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
			spell3 = true
			break
		else
			Spell3Frame:SetAlpha(1)
			Spell3Frame.t:SetTexture(select(3, GetSpellInfo(Spell3Buff)))
			spell3 = false
		end
	end

	for i, Spell4Buff in pairs(Spell4Buff) do
		local spellname = select(1, GetSpellInfo(Spell4Buff))
		if UnitAura("player", spellname) then
			Spell4Frame:SetAlpha(C["reminder"].raid_buffs_alpha)
			Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
			spell4 = true
			break
		else
			Spell4Frame:SetAlpha(1)
			Spell4Frame.t:SetTexture(select(3, GetSpellInfo(Spell4Buff)))
			spell4 = false
		end
	end

	for i, Spell5Buff in pairs(Spell5Buff) do
		local spellname = select(1, GetSpellInfo(Spell5Buff))
		if UnitAura("player", spellname) then
			Spell5Frame:SetAlpha(C["reminder"].raid_buffs_alpha)
			Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
			spell5 = true
			break
		else
			Spell5Frame:SetAlpha(1)
			Spell5Frame.t:SetTexture(select(3, GetSpellInfo(Spell5Buff)))
			spell5 = false
		end
	end

	for i, Spell6Buff in pairs(Spell6Buff) do
		local spellname = select(1, GetSpellInfo(Spell6Buff))
		if UnitAura("player", spellname) then
			Spell6Frame:SetAlpha(C["reminder"].raid_buffs_alpha)
			Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
			spell6 = true
			break
		else
			Spell6Frame:SetAlpha(1)
			Spell6Frame.t:SetTexture(select(3, GetSpellInfo(Spell6Buff)))
			spell6 = false
		end
	end

	local inInstance, instanceType = IsInInstance()
	if not (inInstance and (instanceType == "raid")) and C["reminder"].raid_buffs_always == false then
		RaidBuffReminder:SetAlpha(0)
		visible = false
	elseif flasked == true and food == true and spell3 == true and spell4 == true and spell5 == true and spell6 == true then
		if not visible then
			RaidBuffReminder:SetAlpha(0)
			visible = false
		end
		if visible then
			UIFrameFadeOut(RaidBuffReminder, 0.5)
			visible = false
		end
	else
		if not visible then
			UIFrameFadeIn(RaidBuffReminder, 0.5)
			visible = true
		end
	end
end

-- Create Anchor
local RaidBuffsAnchor = CreateFrame("Button", "RaidBuffsAnchor", UIParent)
RaidBuffsAnchor:SetWidth((C["reminder"].raid_buffs_size * 6) + 15)
RaidBuffsAnchor:SetHeight(C["reminder"].raid_buffs_size)
RaidBuffsAnchor:SetPoint(unpack(C.position.raid_buffs))

-- Create Main bar
local raidbuff_reminder = CreateFrame("Frame", "RaidBuffReminder", UIParent)
raidbuff_reminder:CreatePanel("Invisible", (C["reminder"].raid_buffs_size * 6) + 15, C["reminder"].raid_buffs_size + 4, "TOPLEFT", RaidBuffsAnchor, "TOPLEFT", 0, 4)
raidbuff_reminder:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
raidbuff_reminder:RegisterEvent("UNIT_INVENTORY_CHANGED")
raidbuff_reminder:RegisterEvent("UNIT_AURA")
raidbuff_reminder:RegisterEvent("PLAYER_ENTERING_WORLD")
raidbuff_reminder:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
raidbuff_reminder:RegisterEvent("CHARACTER_POINTS_CHANGED")
raidbuff_reminder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
raidbuff_reminder:SetScript("OnEvent", OnAuraChange)

-- Function to create buttons
local function CreateButton(name, relativeTo, firstbutton)
	local button = CreateFrame("Frame", name, RaidBuffReminder)
	if firstbutton == true then
		button:CreatePanel("Default", C["reminder"].raid_buffs_size, C["reminder"].raid_buffs_size, "BOTTOMLEFT", relativeTo, "BOTTOMLEFT", 0, 0)
	else
		button:CreatePanel("Default", C["reminder"].raid_buffs_size, C["reminder"].raid_buffs_size, "LEFT", relativeTo, "RIGHT", 3, 0)
	end
	button:SetFrameLevel(RaidBuffReminder:GetFrameLevel() + 2)

	button.t = button:CreateTexture(name..".t", "OVERLAY")
	button.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.t:SetPoint("TOPLEFT", 2, -2)
	button.t:SetPoint("BOTTOMRIGHT", -2, 2)
end

-- Create Buttons
do
	CreateButton("FlaskFrame", RaidBuffReminder, true)
	CreateButton("FoodFrame", FlaskFrame, false)
	CreateButton("Spell3Frame", FoodFrame, false)
	CreateButton("Spell4Frame", Spell3Frame, false)
	CreateButton("Spell5Frame", Spell4Frame, false)
	CreateButton("Spell6Frame", Spell5Frame, false)
end