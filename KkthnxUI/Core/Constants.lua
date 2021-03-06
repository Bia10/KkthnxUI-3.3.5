local K, C, L, _ = unpack(select(2, ...))

local tonumber, select = tonumber, select
local match = string.match

-- Constants
K.Dummy = function() return end
K.Unit = UnitGUID("player")
K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = select(2, UnitRace("player"))
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Resolution = GetCVar("gxResolution")
K.Color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[K.Class]
K.Version = GetAddOnMetadata("KkthnxUI", "Version")
K.ScreenHeight = tonumber(match(K.Resolution, "%d+x(%d+)"))
K.ScreenWidth = tonumber(match(K.Resolution, "(%d+)x+%d"))
K.WoWBuild = select(2, GetBuildInfo()) K.WoWBuild = tonumber(K.WoWBuild)