﻿local K, C, L, _ = unpack(select(2, ...))
if C["tooltip"].enable ~= true then return end

local pairs = pairs
local unpack = unpack
local select = select
local next = next
local format = string.format
local min, max = math.min, math.max

local CreateFrame = CreateFrame
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local GetItem, GetItemInfo, GetItemQualityColor = GetItem, GetItemInfo, GetItemQualityColor
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local GetMouseFocus = GetMouseFocus
local GetGuildInfo = GetGuildInfo
local UnitExists = UnitExists
local UnitPVPName = UnitPVPName
local UnitFactionGroup = UnitFactionGroup
local hooksecurefunc = hooksecurefunc
local UnitIsAFK, UnitIsDND = UnitIsAFK, UnitIsDND

-- Based on aTooltip(by ALZA)
local tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	FriendsTooltip,
	ConsolidatedBuffsTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	AtlasLootTooltip,
	QuestHelperTooltip,
	QuestGuru_QuestWatchTooltip,
}

for _, tt in pairs(tooltips) do
	tt:SetBackdrop(K.Backdrop)
	tt:HookScript("OnShow", function(self)
		self:SetBackdropColor(unpack(C["media"].backdrop_color))
		if C["blizzard"].dark_textures == true then
			self:SetBackdropBorderColor(unpack(C["blizzard"].dark_textures_color))
		else
			self:SetBackdropBorderColor(unpack(C["media"].border_color))
		end

	end)
end

local anchor = CreateFrame("Frame", "TooltipAnchor", UIParent)
anchor:SetSize(200, 40)
anchor:SetPoint(unpack(C.position.tooltip))

-- Hide PVP text
PVP_ENABLED = ""

-- Statusbar
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("LEFT",4,0)
GameTooltipStatusBar:SetPoint("RIGHT",-4,0)
GameTooltipStatusBar:SetPoint("BOTTOM", GameTooltipStatusBar:GetParent(),"TOP",0,-8)
GameTooltipStatusBar:SetHeight(5)
-- Gametooltip Statusbar Background
GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
GameTooltipStatusBar.bg:SetPoint("TOPLEFT",-0,0)
GameTooltipStatusBar.bg:SetPoint("BOTTOMRIGHT",0,-0)
GameTooltipStatusBar.bg:SetTexture(1,1,1)
GameTooltipStatusBar.bg:SetVertexColor(1/3, 1/3, 1/3)

-- Tooltip Font Changes
if C["tooltip"].fontoutline == true then
	GameTooltipHeaderText:SetFont(C["font"].tooltip_font, C["font"].tooltip_font_size + 2, C["font"].tooltip_font_style)
	GameTooltipHeaderText:SetShadowOffset(0, 0)
	GameTooltipText:SetFont(C["font"].tooltip_font, C["font"].tooltip_font_size, C["font"].tooltip_font_style)
	GameTooltipText:SetShadowOffset(0, 0)
	GameTooltipTextSmall:SetFont(C["font"].tooltip_font, C["font"].tooltip_font_size - 1, C["font"].tooltip_font_style)
	GameTooltipTextSmall:SetShadowOffset(0, 0)
else
	GameTooltipHeaderText:SetFont(C["font"].tooltip_font, C["font"].tooltip_font_size + 2)
	GameTooltipText:SetFont(C["font"].tooltip_font, C["font"].tooltip_font_size)
	GameTooltipTextSmall:SetFont(C["font"].tooltip_font, C["font"].tooltip_font_size - 1)
end

-- Item Quaility Border
if C["tooltip"].quality_border_color == true then
	for _, tt in pairs({
		GameTooltip,
		ItemRefTooltip,

		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
	}) do
		tt:HookScript('OnTooltipSetItem', function(self)
			local name, item = self:GetItem()
			if (item) then
				local quality = select(3, GetItemInfo(item))
				if (quality) then
					local r, g, b = GetItemQualityColor(quality)
					self:SetBackdropBorderColor(r, g, b)
				end
			end
		end)

		tt:HookScript('OnTooltipCleared', function(self)
			self:SetBackdropBorderColor(unpack(C["media"].border_color))
		end)
	end
end

-- Raid icon
local ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
ricon:SetHeight(18)
ricon:SetWidth(18)
ricon:SetPoint("BOTTOM", GameTooltip, "TOP", 0, 5)

GameTooltip:HookScript("OnHide", function(self) ricon:SetTexture(nil) end)

-- Add "Targeted By" line
local targetedList = {}
local ClassColors = {}
local token
for class, color in next, RAID_CLASS_COLORS do
	ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
end

local function AddTargetedBy()
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers()
	if numParty > 0 or numRaid > 0 then
		for i = 1, (numRaid > 0 and numRaid or numParty) do
			local unit = (numRaid > 0 and "raid"..i or "party"..i)
			if UnitIsUnit(unit.."target", token) and not UnitIsUnit(unit, "player") then
				local _, class = UnitClass(unit)
				targetedList[#targetedList + 1] = ClassColors[class]
				targetedList[#targetedList + 1] = UnitName(unit)
				targetedList[#targetedList + 1] = "|r, "
			end
		end
		if #targetedList > 0 then
			targetedList[#targetedList] = nil
			GameTooltip:AddLine(" ", nil, nil, nil, 1)
			local line = _G["GameTooltipTextLeft"..GameTooltip:NumLines()]
			if not line then return end
			line:SetFormattedText(L_TOOLTIP_WHO_TARGET.." (|cffffffff%d|r): %s", (#targetedList + 1) / 3, table.concat(targetedList))
			wipe(targetedList)
		end
	end
end

-- Unit tooltip styling
function GameTooltip_UnitColor(unit)
	if not unit then return end
	local r, g, b

	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		if color then
			r, g, b = color.r, color.g, color.b
		else
			r, g, b = 1, 1, 1
		end
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) or UnitIsDead(unit) then
		r, g, b = 0.6, 0.6, 0.6
	else
		local reaction = K.oUF_colors.reaction[UnitReaction(unit, "player")]
		if reaction then
			r, g, b = reaction[1], reaction[2], reaction[3]
		else
			r, g, b = 1, 1, 1
		end
	end

	return r, g, b
end

local function GameTooltipDefault(tooltip, parent)
	if C["tooltip"].cursor == true then
		tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
	else
		tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("BOTTOMRIGHT", TooltipAnchor, "BOTTOMRIGHT", 0, 0)
		tooltip.default = 1
	end
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", GameTooltipDefault)

if C["tooltip"].shift_modifer == true then
	local ShiftShow = function()
		if IsShiftKeyDown() then
			GameTooltip:Show()
		else
			if not HoverBind.enabled then
				GameTooltip:Hide()
			end
		end
	end
	GameTooltip:SetScript("OnShow", ShiftShow)
	local EventShow = function()
		if arg1 == "LSHIFT" and arg2 == 1 then
			GameTooltip:Show()
		elseif arg1 == "LSHIFT" and arg2 == 0 then
			GameTooltip:Hide()
		end
	end
	local sh = CreateFrame("Frame")
	sh:RegisterEvent("MODIFIER_STATE_CHANGED")
	sh:SetScript("OnEvent", EventShow)
else
	if C["tooltip"].cursor == true then
		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
			if InCombatLockdown() and C["tooltip"].hide_combat and not IsShiftKeyDown() then
				self:Hide()
			else
				self:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 20, 20)
			end
		end)
	else
		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self)
			if InCombatLockdown() and C["tooltip"].hide_combat and not IsShiftKeyDown() then
				self:Hide()
			else
				self:SetPoint("BOTTOMRIGHT", TooltipAnchor, "BOTTOMRIGHT", 0, 0)
			end
		end)
	end
end

if C["tooltip"].health_value == true then
	GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
		if not value then return end
		local min, max = self:GetMinMaxValues()
		if (value < min) or (value > max) then return end
		self:SetStatusBarColor(0, 1, 0)
		local _, unit = GameTooltip:GetUnit()
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			if not self.text then
				self.text = self:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
				self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, 10)
			end
			self.text:Show()
			local hp = K.ShortValue(min).." / "..K.ShortValue(max)
			self.text:SetText(hp)
			self.text:SetShadowOffset(K.mult, -K.mult)
		end
	end)
end

local OnTooltipSetUnit = function(self)
	local lines = self:NumLines()
	local unit = (select(2, self:GetUnit())) or (GetMouseFocus() and GetMouseFocus():GetAttribute("unit")) or (UnitExists("mouseover") and "mouseover") or nil

	if not unit then return end

	local name, realm = UnitName(unit)
	local race, englishRace = UnitRace(unit)
	local level = UnitLevel(unit)
	local levelColor = GetQuestDifficultyColor(level)
	local classification = UnitClassification(unit)
	local creatureType = UnitCreatureType(unit)
	local _, faction = UnitFactionGroup(unit)
	local _, playerFaction = UnitFactionGroup("player")
	local UnitPVPName = UnitPVPName

	if level and level == -1 then
		if classification == "worldboss" then
			level = "|cffff0000|r"..BOSS
		else
			level = "|cffff0000??|r"
		end
	end

	if classification == "rareelite" then classification = " R+"
	elseif classification == "rare" then classification = " R"
	elseif classification == "elite" then classification = "+"
else classification = "" end


	if UnitPVPName(unit) and C["tooltip"].title then
		name = UnitPVPName(unit)
	end

	_G["GameTooltipTextLeft1"]:SetText(name)

	if UnitIsPlayer(unit) then
		if UnitIsAFK(unit) then
			self:AppendText((" %s"):format("|cffE7E716"..L_CHAT_AFK.."|r"))
		elseif UnitIsDND(unit) then
			self:AppendText((" %s"):format("|cffFF0000"..L_CHAT_DND.."|r"))
		end

		if UnitIsPlayer(unit) and faction ~= playerFaction then
			local hex = "cffff3333"
			if faction == "Alliance" then
				hex = "cff69ccf0"
			end
			self:AppendText((" [|%s%s|r]"):format(hex, faction:sub(1, 2)))
		end

		if GetGuildInfo(unit) then
			_G["GameTooltipTextLeft2"]:SetFormattedText("%s", GetGuildInfo(unit))
			if UnitIsInMyGuild(unit) then
				_G["GameTooltipTextLeft2"]:SetTextColor(1, 1, 0)
			else
				_G["GameTooltipTextLeft2"]:SetTextColor(0, 1, 1)
			end
		end

		local n = GetGuildInfo(unit) and 3 or 2
		-- thx TipTac for the fix above with color blind enabled
		if GetCVar("colorblindMode") == "1" then n = n + 1 end
		_G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%02x%02x%02x%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, race or UNKNOWN)

		for i = 2, lines do
			local line = _G["GameTooltipTextLeft"..i]
			if not line or not line:GetText() then return end
			if line and line:GetText() and (line:GetText() == FACTION_HORDE or line:GetText() == FACTION_ALLIANCE) then
				line:SetText()
				break
			end
		end
	else
		for i = 2, lines do
			local line = _G["GameTooltipTextLeft"..i]
			if not line or not line:GetText() then return end
			if (level and line:GetText():find("^"..LEVEL)) or (creatureType and line:GetText():find("^"..creatureType)) then
				local r, g, b = GameTooltip_UnitColor(unit)
				line:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level, classification, creatureType or "")
				break
			end
		end
	end

	if C["tooltip"].target == true and UnitExists(unit.."target") then
		local r, g, b = GameTooltip_UnitColor(unit.."target")
		local text = ""

		if UnitIsEnemy("player", unit.."target") then
			r, g, b = unpack(K.oUF_colors.reaction[1])
		elseif not UnitIsFriend("player", unit.."target") then
			r, g, b = unpack(K.oUF_colors.reaction[4])
		end

		if UnitName(unit.."target") == UnitName("player") then
			text = "|cfffed100"..STATUS_TEXT_TARGET..":|r ".."|cffff0000> "..UNIT_YOU.." <|r"
		else
			text = "|cfffed100"..STATUS_TEXT_TARGET..":|r "..UnitName(unit.."target")
		end

		self:AddLine(text, r, g, b)
	end

	if C["tooltip"].raid_icon == true then
		local raidIndex = GetRaidTargetIndex(unit)
		if raidIndex then
			ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..raidIndex)
		end
	end

	if C["tooltip"].who_targetting == true then
		token = unit AddTargetedBy()
	end
end

GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

-- Adds guild rank to tooltips(GuildRank by Meurtcriss)
if C["tooltip"].rank == true then
	GameTooltip:HookScript("OnTooltipSetUnit", function(self, ...)
		-- Get the unit
		local _, unit = self:GetUnit()
		if not unit then
			local mFocus = GetMouseFocus()
			if mFocus and mFocus.unit then
				unit = mFocus.unit
			end
		end
		-- Get and display guild rank
		if UnitIsPlayer(unit) then
			local guildName, guildRank = GetGuildInfo(unit)
			if guildName then
				self:AddLine(RANK..": |cffffffff"..guildRank.."|r")
			end
		end
	end)
end

-- Hide tooltips in combat for action bars, pet bar and stance bar
if C["tooltip"].hidebuttons == true then
	local CombatHideActionButtonsTooltip = function(self)
		if not IsShiftKeyDown() then
			self:Hide()
		end
	end

	hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
	hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
	hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
end

-- Fix GameTooltipMoneyFrame font size
local function FixFont(self)
	for i = 1, 2 do
		if _G["GameTooltipMoneyFrame"..i] then
			_G["GameTooltipMoneyFrame"..i.."PrefixText"]:SetFontObject("GameTooltipText")
			_G["GameTooltipMoneyFrame"..i.."SuffixText"]:SetFontObject("GameTooltipText")
			_G["GameTooltipMoneyFrame"..i.."GoldButton"]:SetNormalFontObject("GameTooltipText")
			_G["GameTooltipMoneyFrame"..i.."SilverButton"]:SetNormalFontObject("GameTooltipText")
			_G["GameTooltipMoneyFrame"..i.."CopperButton"]:SetNormalFontObject("GameTooltipText")
		end
	end
	for i = 1, 2 do
		if _G["ItemRefTooltipMoneyFrame"..i] then
			_G["ItemRefTooltipMoneyFrame"..i.."PrefixText"]:SetFontObject("GameTooltipText")
			_G["ItemRefTooltipMoneyFrame"..i.."SuffixText"]:SetFontObject("GameTooltipText")
			_G["ItemRefTooltipMoneyFrame"..i.."GoldButton"]:SetNormalFontObject("GameTooltipText")
			_G["ItemRefTooltipMoneyFrame"..i.."SilverButton"]:SetNormalFontObject("GameTooltipText")
			_G["ItemRefTooltipMoneyFrame"..i.."CopperButton"]:SetNormalFontObject("GameTooltipText")
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", FixFont)
ItemRefTooltip:HookScript("OnTooltipSetItem", FixFont)