﻿local K, C, L, _ = unpack(select(2, ...))

local unpack = unpack
local format = string.format
local CreateFrame, UIParent = CreateFrame, UIParent
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetCurrentMapAreaID = GetCurrentMapAreaID

-- BGScore(by Elv22, edited by Tukz)
-- Map IDs
local WSG = 443
local AV = 401
local SOTA = 512
local IOC = 540
local EOTS = 482
local AB = 461

local classcolor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

local bgframe = CreateFrame("Frame", "InfoBattleGround", UIParent)
bgframe:CreatePanel("Invisible", 300, C["font"].stats_font_size, unpack(C["position"].bgscore))
bgframe:EnableMouse(true)
bgframe:SetScript("OnEnter", function(self)
	local numScores = GetNumBattlefieldScores()
	for i = 1, numScores do
		local name, killingBlows, honorKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone = GetBattlefieldScore(i)
		if name and name == K.Name then
			local curmapid = GetCurrentMapAreaID()
			SetMapToCurrentZone()
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, K.Scale(4))
			GameTooltip:ClearLines()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(STATISTICS, classcolor..name.."|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(HONORABLE_KILLS..":", honorableKills, 1, 1, 1)
			GameTooltip:AddDoubleLine(DEATHS..":", deaths, 1, 1, 1)
			GameTooltip:AddDoubleLine(DAMAGE..":", damageDone, 1, 1, 1)
			GameTooltip:AddDoubleLine(SHOW_COMBAT_HEALING..":", healingDone, 1, 1, 1)
			-- Add extra statistics depending on what BG you are
			if curmapid == IOC or curmapid == AB then
				GameTooltip:AddDoubleLine(L_DATATEXT_BASESASSAULTED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_BASESDEFENDED, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == WSG or curmapid then
				GameTooltip:AddDoubleLine(L_DATATEXT_FLAGSCAPTURED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_FLAGSRETURNED, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == EOTS then
				GameTooltip:AddDoubleLine(L_DATATEXT_FLAGSCAPTURED, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif curmapid == AV then
				GameTooltip:AddDoubleLine(L_DATATEXT_GRAVEYARDSASSAULTED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_GRAVEYARDSDEFENDED, GetBattlefieldStatData(i, 2), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_TOWERSASSAULTED, GetBattlefieldStatData(i, 3), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_TOWERSDEFENDED, GetBattlefieldStatData(i, 4), 1, 1, 1)
			elseif curmapid == SOTA then
				GameTooltip:AddDoubleLine(L_DATATEXT_DEMOLISHERSDESTROYED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_GATESDESTROYED, GetBattlefieldStatData(i, 2), 1, 1, 1)
			end
			GameTooltip:Show()
		end
	end
end)
bgframe:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
bgframe:SetScript("OnMouseUp", function(self, button)
	if MiniMapBattlefieldFrame:IsShown() then
		if button == "RightButton" then
			ToggleBattlefieldMinimap()
		else
			ToggleWorldStateScoreFrame()
		end
	end
end)

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)

local Text1 = InfoBattleGround:CreateFontString(nil, "OVERLAY")
Text1:SetFont(C["font"].basic_font, C["font"].basic_font_size, C["font"].basic_font_style)
Text1:SetShadowOffset(K.mult, -K.mult)
Text1:SetPoint("LEFT", 5, 0)
Text1:SetHeight(C["font"].basic_font_size)

local Text2 = InfoBattleGround:CreateFontString(nil, "OVERLAY")
Text2:SetFont(C["font"].basic_font, C["font"].basic_font_size, C["font"].basic_font_style)
Text2:SetShadowOffset(K.mult, -K.mult)
Text2:SetPoint("LEFT", Text1, "RIGHT", 5, 0)
Text2:SetHeight(C["font"].basic_font_size)

local Text3 = InfoBattleGround:CreateFontString(nil, "OVERLAY")
Text3:SetFont(C["font"].basic_font, C["font"].basic_font_size, C["font"].basic_font_style)
Text3:SetShadowOffset(K.mult, -K.mult)
Text3:SetPoint("LEFT", Text2, "RIGHT", 5, 0)
Text3:SetHeight(C["font"].basic_font_size)

local int = 2
local function Update(self, t)
	int = int - t
	if int < 0 then
		local dmgtxt
		RequestBattlefieldScoreData()
		local numScores = GetNumBattlefieldScores()
		for i = 1, numScores do
			local name, killingBlows, honorKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone = GetBattlefieldScore(i)
			if healingDone > damageDone then
				dmgtxt = (classcolor..SHOW_COMBAT_HEALING.." :|r "..K.ShortValue(healingDone))
			else
				dmgtxt = (classcolor..COMBATLOG_HIGHLIGHT_DAMAGE.." :|r "..K.ShortValue(damageDone))
			end
			if name and name == K.Name then
				Text1:SetText(dmgtxt)
				Text2:SetText(classcolor..COMBAT_HONOR_GAIN.." :|r "..format("%d", honorGained))
				Text3:SetText(classcolor..KILLING_BLOWS.." :|r "..killingBlows)
			end
		end
		int = 2
	end
end

-- Hide text when not in an bg
local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" then
			bgframe:Show()
		else
			Text1:SetText("")
			Text2:SetText("")
			Text3:SetText("")
			bgframe:Hide()
		end
	end
end

Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnUpdate", Update)
Update(Stat, 2)